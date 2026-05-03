import uuid
import datetime
from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from database import Base

def generate_uuid():
    return str(uuid.uuid4())

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    role = Column(String, nullable=False) # 'manager', 'teacher', 'student'
    hashed_password = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    # Relationships
    managed_classrooms = relationship("Classroom", back_populates="manager", foreign_keys="[Classroom.manager_id]")
    memberships = relationship("ClassroomMember", back_populates="user")
    created_assignments = relationship("Assignment", back_populates="creator")
    submissions = relationship("Submission", back_populates="student")

class Classroom(Base):
    __tablename__ = "classrooms"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    name = Column(String, nullable=False)
    unique_code = Column(String, unique=True, index=True, nullable=False)
    manager_id = Column(String, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    # Relationships
    manager = relationship("User", back_populates="managed_classrooms")
    members = relationship("ClassroomMember", back_populates="classroom")
    assignments = relationship("Assignment", back_populates="classroom")
    announcements = relationship("Announcement", back_populates="classroom")
    materials = relationship("Material", back_populates="classroom")

class ClassroomMember(Base):
    __tablename__ = "classroom_members"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    classroom_id = Column(String, ForeignKey("classrooms.id"))
    user_id = Column(String, ForeignKey("users.id"))
    status = Column(String, default="pending") # 'pending', 'approved', 'rejected'
    joined_at = Column(DateTime, default=datetime.datetime.utcnow)

    # Relationships
    classroom = relationship("Classroom", back_populates="members")
    user = relationship("User", back_populates="memberships")

class Assignment(Base):
    __tablename__ = "assignments"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    classroom_id = Column(String, ForeignKey("classrooms.id"))
    title = Column(String, nullable=False)
    description = Column(String)
    deadline = Column(DateTime, nullable=False)
    created_by = Column(String, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    # Relationships
    classroom = relationship("Classroom", back_populates="assignments")
    creator = relationship("User", back_populates="created_assignments")
    submissions = relationship("Submission", back_populates="assignment")

class Submission(Base):
    __tablename__ = "submissions"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    assignment_id = Column(String, ForeignKey("assignments.id"))
    student_id = Column(String, ForeignKey("users.id"))
    file_url = Column(String, nullable=False)
    grade = Column(Float, nullable=True)
    submitted_at = Column(DateTime, default=datetime.datetime.utcnow)

    # Relationships
    assignment = relationship("Assignment", back_populates="submissions")
    student = relationship("User", back_populates="submissions")

class Announcement(Base):
    __tablename__ = "announcements"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    classroom_id = Column(String, ForeignKey("classrooms.id"))
    title = Column(String, nullable=False)
    content = Column(String, nullable=False)
    created_by = Column(String, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    # Relationships
    classroom = relationship("Classroom", back_populates="announcements")

class Material(Base):
    __tablename__ = "materials"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    classroom_id = Column(String, ForeignKey("classrooms.id"))
    title = Column(String, nullable=False)
    file_url = Column(String, nullable=False)
    uploaded_by = Column(String, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    # Relationships
    classroom = relationship("Classroom", back_populates="materials")
