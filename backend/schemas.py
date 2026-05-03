from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional, List

# Token
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

# User
class UserBase(BaseModel):
    name: str
    email: EmailStr
    role: str # 'manager', 'teacher', 'student'

class UserCreate(UserBase):
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(UserBase):
    id: str
    created_at: datetime
    class Config:
        from_attributes = True

# Classroom
class ClassroomBase(BaseModel):
    name: str

class ClassroomCreate(ClassroomBase):
    pass

class ClassroomResponse(ClassroomBase):
    id: str
    unique_code: str
    manager_id: str
    created_at: datetime
    class Config:
        from_attributes = True

# Classroom Member
class ClassroomJoin(BaseModel):
    unique_code: str

class ClassroomMemberApprove(BaseModel):
    status: str # 'approved', 'rejected'

class ClassroomMemberResponse(BaseModel):
    id: str
    classroom_id: str
    user_id: str
    status: str
    joined_at: datetime
    class Config:
        from_attributes = True

class ClassroomMemberWithUserResponse(ClassroomMemberResponse):
    user: UserResponse

# Assignment
class AssignmentBase(BaseModel):
    title: str
    description: Optional[str] = None
    deadline: datetime

class AssignmentCreate(AssignmentBase):
    pass

class AssignmentResponse(AssignmentBase):
    id: str
    classroom_id: str
    created_by: str
    created_at: datetime
    class Config:
        from_attributes = True

# Submission
class SubmissionBase(BaseModel):
    file_url: str

class SubmissionCreate(SubmissionBase):
    pass

class SubmissionGrade(BaseModel):
    grade: float

class SubmissionResponse(SubmissionBase):
    id: str
    assignment_id: str
    student_id: str
    grade: Optional[float] = None
    submitted_at: datetime
    class Config:
        from_attributes = True

# Announcement
class AnnouncementBase(BaseModel):
    title: str
    content: str

class AnnouncementCreate(AnnouncementBase):
    pass

class AnnouncementResponse(AnnouncementBase):
    id: str
    classroom_id: str
    created_by: str
    created_at: datetime
    class Config:
        from_attributes = True

# Material
class MaterialBase(BaseModel):
    title: str
    file_url: str

class MaterialCreate(MaterialBase):
    pass

class MaterialResponse(MaterialBase):
    id: str
    classroom_id: str
    uploaded_by: str
    created_at: datetime
    class Config:
        from_attributes = True
