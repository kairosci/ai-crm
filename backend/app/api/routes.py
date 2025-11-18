from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from ..schemas import (
    ContactCreate, ContactUpdate, ContactResponse,
    PipelineCreate, PipelineUpdate, PipelineResponse,
    DealCreate, DealUpdate, DealResponse,
    TaskCreate, TaskUpdate, TaskResponse,
    ChatMessage, ChatResponse
)
from . import crud
from ..services.ai_agent import ai_agent

router = APIRouter()

# Contact endpoints
@router.post("/contacts", response_model=ContactResponse, status_code=status.HTTP_201_CREATED)
def create_contact(contact: ContactCreate, db: Session = Depends(get_db)):
    """Create a new contact"""
    return crud.create_contact(db, contact)


@router.get("/contacts", response_model=List[ContactResponse])
def get_contacts(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all contacts"""
    return crud.get_contacts(db, skip=skip, limit=limit)


@router.get("/contacts/{contact_id}", response_model=ContactResponse)
def get_contact(contact_id: int, db: Session = Depends(get_db)):
    """Get a specific contact"""
    contact = crud.get_contact(db, contact_id)
    if contact is None:
        raise HTTPException(status_code=404, detail="Contact not found")
    return contact


@router.put("/contacts/{contact_id}", response_model=ContactResponse)
def update_contact(contact_id: int, contact: ContactUpdate, db: Session = Depends(get_db)):
    """Update a contact"""
    updated_contact = crud.update_contact(db, contact_id, contact)
    if updated_contact is None:
        raise HTTPException(status_code=404, detail="Contact not found")
    return updated_contact


@router.delete("/contacts/{contact_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_contact(contact_id: int, db: Session = Depends(get_db)):
    """Delete a contact"""
    if not crud.delete_contact(db, contact_id):
        raise HTTPException(status_code=404, detail="Contact not found")
    return None


# Pipeline endpoints
@router.post("/pipelines", response_model=PipelineResponse, status_code=status.HTTP_201_CREATED)
def create_pipeline(pipeline: PipelineCreate, db: Session = Depends(get_db)):
    """Create a new pipeline"""
    return crud.create_pipeline(db, pipeline)


@router.get("/pipelines", response_model=List[PipelineResponse])
def get_pipelines(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all pipelines"""
    return crud.get_pipelines(db, skip=skip, limit=limit)


@router.get("/pipelines/{pipeline_id}", response_model=PipelineResponse)
def get_pipeline(pipeline_id: int, db: Session = Depends(get_db)):
    """Get a specific pipeline"""
    pipeline = crud.get_pipeline(db, pipeline_id)
    if pipeline is None:
        raise HTTPException(status_code=404, detail="Pipeline not found")
    return pipeline


@router.put("/pipelines/{pipeline_id}", response_model=PipelineResponse)
def update_pipeline(pipeline_id: int, pipeline: PipelineUpdate, db: Session = Depends(get_db)):
    """Update a pipeline"""
    updated_pipeline = crud.update_pipeline(db, pipeline_id, pipeline)
    if updated_pipeline is None:
        raise HTTPException(status_code=404, detail="Pipeline not found")
    return updated_pipeline


@router.delete("/pipelines/{pipeline_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_pipeline(pipeline_id: int, db: Session = Depends(get_db)):
    """Delete a pipeline"""
    if not crud.delete_pipeline(db, pipeline_id):
        raise HTTPException(status_code=404, detail="Pipeline not found")
    return None


# Deal endpoints
@router.post("/deals", response_model=DealResponse, status_code=status.HTTP_201_CREATED)
def create_deal(deal: DealCreate, db: Session = Depends(get_db)):
    """Create a new deal"""
    return crud.create_deal(db, deal)


@router.get("/deals", response_model=List[DealResponse])
def get_deals(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all deals"""
    return crud.get_deals(db, skip=skip, limit=limit)


@router.get("/deals/{deal_id}", response_model=DealResponse)
def get_deal(deal_id: int, db: Session = Depends(get_db)):
    """Get a specific deal"""
    deal = crud.get_deal(db, deal_id)
    if deal is None:
        raise HTTPException(status_code=404, detail="Deal not found")
    return deal


@router.put("/deals/{deal_id}", response_model=DealResponse)
def update_deal(deal_id: int, deal: DealUpdate, db: Session = Depends(get_db)):
    """Update a deal"""
    updated_deal = crud.update_deal(db, deal_id, deal)
    if updated_deal is None:
        raise HTTPException(status_code=404, detail="Deal not found")
    return updated_deal


@router.delete("/deals/{deal_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_deal(deal_id: int, db: Session = Depends(get_db)):
    """Delete a deal"""
    if not crud.delete_deal(db, deal_id):
        raise HTTPException(status_code=404, detail="Deal not found")
    return None


# Task endpoints
@router.post("/tasks", response_model=TaskResponse, status_code=status.HTTP_201_CREATED)
def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    """Create a new task"""
    return crud.create_task(db, task)


@router.get("/tasks", response_model=List[TaskResponse])
def get_tasks(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all tasks"""
    return crud.get_tasks(db, skip=skip, limit=limit)


@router.get("/tasks/{task_id}", response_model=TaskResponse)
def get_task(task_id: int, db: Session = Depends(get_db)):
    """Get a specific task"""
    task = crud.get_task(db, task_id)
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@router.put("/tasks/{task_id}", response_model=TaskResponse)
def update_task(task_id: int, task: TaskUpdate, db: Session = Depends(get_db)):
    """Update a task"""
    updated_task = crud.update_task(db, task_id, task)
    if updated_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return updated_task


@router.delete("/tasks/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(task_id: int, db: Session = Depends(get_db)):
    """Delete a task"""
    if not crud.delete_task(db, task_id):
        raise HTTPException(status_code=404, detail="Task not found")
    return None


# AI Chat endpoint
@router.post("/chat", response_model=ChatResponse)
def chat(message: ChatMessage):
    """Send a message to the AI agent"""
    result = ai_agent.process_message(message.message)
    return ChatResponse(**result)
