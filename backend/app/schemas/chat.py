from pydantic import BaseModel
from typing import Optional


class ChatMessage(BaseModel):
    message: str
    context: Optional[str] = None


class ChatResponse(BaseModel):
    response: str
    action_taken: Optional[str] = None
