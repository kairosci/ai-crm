from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from ..models import Contact, Pipeline, Deal, Task
from ..schemas import (
    ContactCreate, ContactUpdate,
    PipelineCreate, PipelineUpdate,
    DealCreate, DealUpdate,
    TaskCreate, TaskUpdate
)


# Contact CRUD
def create_contact(db: Session, contact: ContactCreate) -> Contact:
    """Create a new contact"""
    db_contact = Contact(**contact.model_dump())
    db.add(db_contact)
    db.commit()
    db.refresh(db_contact)
    return db_contact


def get_contact(db: Session, contact_id: int) -> Optional[Contact]:
    """Get contact by ID"""
    return db.query(Contact).filter(Contact.id == contact_id).first()


def get_contacts(db: Session, skip: int = 0, limit: int = 100) -> List[Contact]:
    """Get all contacts with pagination"""
    return db.query(Contact).offset(skip).limit(limit).all()


def update_contact(db: Session, contact_id: int, contact: ContactUpdate) -> Optional[Contact]:
    """Update contact"""
    db_contact = get_contact(db, contact_id)
    if db_contact is None:
        return None
    
    update_data = contact.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_contact, field, value)
    
    db_contact.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(db_contact)
    return db_contact


def delete_contact(db: Session, contact_id: int) -> bool:
    """Delete contact"""
    db_contact = get_contact(db, contact_id)
    if db_contact is None:
        return False
    db.delete(db_contact)
    db.commit()
    return True


# Pipeline CRUD
def create_pipeline(db: Session, pipeline: PipelineCreate) -> Pipeline:
    """Create a new pipeline"""
    db_pipeline = Pipeline(**pipeline.model_dump())
    db.add(db_pipeline)
    db.commit()
    db.refresh(db_pipeline)
    return db_pipeline


def get_pipeline(db: Session, pipeline_id: int) -> Optional[Pipeline]:
    """Get pipeline by ID"""
    return db.query(Pipeline).filter(Pipeline.id == pipeline_id).first()


def get_pipelines(db: Session, skip: int = 0, limit: int = 100) -> List[Pipeline]:
    """Get all pipelines with pagination"""
    return db.query(Pipeline).offset(skip).limit(limit).all()


def update_pipeline(db: Session, pipeline_id: int, pipeline: PipelineUpdate) -> Optional[Pipeline]:
    """Update pipeline"""
    db_pipeline = get_pipeline(db, pipeline_id)
    if db_pipeline is None:
        return None
    
    update_data = pipeline.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_pipeline, field, value)
    
    db_pipeline.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(db_pipeline)
    return db_pipeline


def delete_pipeline(db: Session, pipeline_id: int) -> bool:
    """Delete pipeline"""
    db_pipeline = get_pipeline(db, pipeline_id)
    if db_pipeline is None:
        return False
    db.delete(db_pipeline)
    db.commit()
    return True


# Deal CRUD
def create_deal(db: Session, deal: DealCreate) -> Deal:
    """Create a new deal"""
    db_deal = Deal(**deal.model_dump())
    db.add(db_deal)
    db.commit()
    db.refresh(db_deal)
    return db_deal


def get_deal(db: Session, deal_id: int) -> Optional[Deal]:
    """Get deal by ID"""
    return db.query(Deal).filter(Deal.id == deal_id).first()


def get_deals(db: Session, skip: int = 0, limit: int = 100) -> List[Deal]:
    """Get all deals with pagination"""
    return db.query(Deal).offset(skip).limit(limit).all()


def update_deal(db: Session, deal_id: int, deal: DealUpdate) -> Optional[Deal]:
    """Update deal"""
    db_deal = get_deal(db, deal_id)
    if db_deal is None:
        return None
    
    update_data = deal.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_deal, field, value)
    
    db_deal.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(db_deal)
    return db_deal


def delete_deal(db: Session, deal_id: int) -> bool:
    """Delete deal"""
    db_deal = get_deal(db, deal_id)
    if db_deal is None:
        return False
    db.delete(db_deal)
    db.commit()
    return True


# Task CRUD
def create_task(db: Session, task: TaskCreate) -> Task:
    """Create a new task"""
    db_task = Task(**task.model_dump())
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task


def get_task(db: Session, task_id: int) -> Optional[Task]:
    """Get task by ID"""
    return db.query(Task).filter(Task.id == task_id).first()


def get_tasks(db: Session, skip: int = 0, limit: int = 100) -> List[Task]:
    """Get all tasks with pagination"""
    return db.query(Task).offset(skip).limit(limit).all()


def update_task(db: Session, task_id: int, task: TaskUpdate) -> Optional[Task]:
    """Update task"""
    db_task = get_task(db, task_id)
    if db_task is None:
        return None
    
    update_data = task.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_task, field, value)
    
    # Mark as completed if status changed to completed
    if task.status and task.status.value == "completed" and not db_task.is_completed:
        db_task.is_completed = True
        db_task.completed_at = datetime.utcnow()
    
    db_task.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(db_task)
    return db_task


def delete_task(db: Session, task_id: int) -> bool:
    """Delete task"""
    db_task = get_task(db, task_id)
    if db_task is None:
        return False
    db.delete(db_task)
    db.commit()
    return True
