from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from ..models.pipeline import DealStatus


class PipelineBase(BaseModel):
    name: str
    description: Optional[str] = None


class PipelineCreate(PipelineBase):
    pass


class PipelineUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None


class PipelineResponse(PipelineBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class DealBase(BaseModel):
    title: str
    description: Optional[str] = None
    value: float = 0.0
    status: DealStatus = DealStatus.LEAD
    pipeline_id: int
    contact_id: int


class DealCreate(DealBase):
    pass


class DealUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    value: Optional[float] = None
    status: Optional[DealStatus] = None
    pipeline_id: Optional[int] = None
    contact_id: Optional[int] = None


class DealResponse(DealBase):
    id: int
    created_at: datetime
    updated_at: datetime
    closed_at: Optional[datetime] = None

    class Config:
        from_attributes = True
