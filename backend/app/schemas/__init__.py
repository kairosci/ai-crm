from .contact import ContactCreate, ContactUpdate, ContactResponse
from .pipeline import PipelineCreate, PipelineUpdate, PipelineResponse, DealCreate, DealUpdate, DealResponse
from .task import TaskCreate, TaskUpdate, TaskResponse
from .chat import ChatMessage, ChatResponse

__all__ = [
    "ContactCreate", "ContactUpdate", "ContactResponse",
    "PipelineCreate", "PipelineUpdate", "PipelineResponse",
    "DealCreate", "DealUpdate", "DealResponse",
    "TaskCreate", "TaskUpdate", "TaskResponse",
    "ChatMessage", "ChatResponse"
]
