from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware  # <-- IMPORT ADDED
from sqlalchemy.orm import Session
from datetime import timedelta
import string
import random

import models, schemas, auth
from database import engine, get_db

# Create all tables in the database
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="EduNexus API")

# --- CORS CONFIGURATION ADDED HERE ---
# This tells your browser it's okay for the frontend to talk to this backend.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],          # Allows all origins (great for Flutter Web's changing ports)
    allow_credentials=False,      # Must be False when allow_origins is "*"
    allow_methods=["*"],          # Allows all HTTP methods (POST, GET, PUT, etc.)
    allow_headers=["*"],          # Allows all headers (including your Auth Bearer tokens)
)
# -------------------------------------

def generate_unique_code():
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

# --- AUTH ROUTES ---
@app.post("/signup", response_model=schemas.UserResponse)
def signup(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    hashed_password = auth.get_password_hash(user.password)
    db_user = models.User(
        name=user.name, 
        email=user.email, 
        role=user.role, 
        hashed_password=hashed_password
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@app.post("/login", response_model=schemas.Token)
def login(user_credentials: schemas.UserLogin, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.email == user_credentials.email).first()
    if not user or not auth.verify_password(user_credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": user.email, "role": user.role}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users/me", response_model=schemas.UserResponse)
def read_users_me(current_user: models.User = Depends(auth.get_current_user)):
    return current_user

# --- CLASSROOM ROUTES ---
@app.post("/classrooms", response_model=schemas.ClassroomResponse)
def create_classroom(
    classroom: schemas.ClassroomCreate, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(auth.get_current_user)
):
    if current_user.role != 'manager':
        raise HTTPException(status_code=403, detail="Only managers can create classrooms")
    
    unique_code = generate_unique_code()
    # Ensure code is unique (simple loop)
    while db.query(models.Classroom).filter(models.Classroom.unique_code == unique_code).first():
        unique_code = generate_unique_code()

    db_classroom = models.Classroom(name=classroom.name, unique_code=unique_code, manager_id=current_user.id)
    db.add(db_classroom)
    db.commit()
    db.refresh(db_classroom)
    return db_classroom

@app.get("/classrooms", response_model=list[schemas.ClassroomResponse])
def get_my_classrooms(db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    if current_user.role == 'manager':
        return db.query(models.Classroom).filter(models.Classroom.manager_id == current_user.id).all()
    else:
        # Teachers and students see approved classrooms
        memberships = db.query(models.ClassroomMember).filter(
            models.ClassroomMember.user_id == current_user.id,
            models.ClassroomMember.status == 'approved'
        ).all()
        return [m.classroom for m in memberships]

@app.post("/classrooms/join", response_model=schemas.ClassroomMemberResponse)
def join_classroom(
    join_request: schemas.ClassroomJoin, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(auth.get_current_user)
):
    if current_user.role == 'manager':
        raise HTTPException(status_code=400, detail="Managers cannot join classrooms using a code")
        
    classroom = db.query(models.Classroom).filter(models.Classroom.unique_code == join_request.unique_code).first()
    if not classroom:
        raise HTTPException(status_code=404, detail="Classroom not found")
        
    existing_member = db.query(models.ClassroomMember).filter(
        models.ClassroomMember.classroom_id == classroom.id,
        models.ClassroomMember.user_id == current_user.id
    ).first()
    
    if existing_member:
        raise HTTPException(status_code=400, detail="Already requested to join or a member")
        
    member = models.ClassroomMember(classroom_id=classroom.id, user_id=current_user.id, status='pending')
    db.add(member)
    db.commit()
    db.refresh(member)
    return member

@app.get("/classrooms/{classroom_id}/members", response_model=list[schemas.ClassroomMemberWithUserResponse])
def get_classroom_members(
    classroom_id: str, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(auth.get_current_user)
):
    classroom = db.query(models.Classroom).filter(models.Classroom.id == classroom_id).first()
    if not classroom:
        raise HTTPException(status_code=404, detail="Classroom not found")
    if classroom.manager_id != current_user.id:
        raise HTTPException(status_code=403, detail="Only manager can view all pending/approved members")
        
    return db.query(models.ClassroomMember).filter(models.ClassroomMember.classroom_id == classroom_id).all()

@app.put("/classrooms/{classroom_id}/members/{user_id}/approve", response_model=schemas.ClassroomMemberResponse)
def approve_member(
    classroom_id: str, 
    user_id: str, 
    approval: schemas.ClassroomMemberApprove,
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(auth.get_current_user)
):
    classroom = db.query(models.Classroom).filter(models.Classroom.id == classroom_id).first()
    if not classroom or classroom.manager_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    member = db.query(models.ClassroomMember).filter(
        models.ClassroomMember.classroom_id == classroom_id,
        models.ClassroomMember.user_id == user_id
    ).first()
    
    if not member:
        raise HTTPException(status_code=404, detail="Member request not found")
        
    member.status = approval.status
    db.commit()
    db.refresh(member)
    return member

# --- ASSIGNMENT ROUTES ---
def is_approved_member(db: Session, classroom_id: str, user_id: str):
    member = db.query(models.ClassroomMember).filter(
        models.ClassroomMember.classroom_id == classroom_id,
        models.ClassroomMember.user_id == user_id,
        models.ClassroomMember.status == 'approved'
    ).first()
    return member is not None

@app.get("/classrooms/{classroom_id}/assignments", response_model=list[schemas.AssignmentResponse])
def get_assignments(classroom_id: str, db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    if not is_approved_member(db, classroom_id, current_user.id) and current_user.role != 'manager':
        raise HTTPException(status_code=403, detail="Not a member of this classroom")
    return db.query(models.Assignment).filter(models.Assignment.classroom_id == classroom_id).all()

@app.post("/classrooms/{classroom_id}/assignments", response_model=schemas.AssignmentResponse)
def create_assignment(
    classroom_id: str, 
    assignment: schemas.AssignmentCreate, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(auth.get_current_user)
):
    if current_user.role != 'teacher':
        raise HTTPException(status_code=403, detail="Only teachers can create assignments")
    if not is_approved_member(db, classroom_id, current_user.id):
        raise HTTPException(status_code=403, detail="Not a member of this classroom")
        
    db_assignment = models.Assignment(
        **assignment.model_dump(), 
        classroom_id=classroom_id, 
        created_by=current_user.id
    )
    db.add(db_assignment)
    db.commit()
    db.refresh(db_assignment)
    return db_assignment

# --- ANNOUNCEMENT ROUTES ---
@app.get("/classrooms/{classroom_id}/announcements", response_model=list[schemas.AnnouncementResponse])
def get_announcements(classroom_id: str, db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    if not is_approved_member(db, classroom_id, current_user.id) and current_user.role != 'manager':
        raise HTTPException(status_code=403, detail="Not a member of this classroom")
    return db.query(models.Announcement).filter(models.Announcement.classroom_id == classroom_id).all()

@app.post("/classrooms/{classroom_id}/announcements", response_model=schemas.AnnouncementResponse)
def create_announcement(
    classroom_id: str, 
    announcement: schemas.AnnouncementCreate, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(auth.get_current_user)
):
    if current_user.role == 'student':
        raise HTTPException(status_code=403, detail="Students cannot create announcements")
    # For teachers, must be member. Managers might be able to post if needed, but let's restrict to teachers/managers in the class
    if current_user.role != 'manager' and not is_approved_member(db, classroom_id, current_user.id):
         raise HTTPException(status_code=403, detail="Not a member of this classroom")

    db_announcement = models.Announcement(
        **announcement.model_dump(), 
        classroom_id=classroom_id, 
        created_by=current_user.id
    )
    db.add(db_announcement)
    db.commit()
    db.refresh(db_announcement)
    return db_announcement