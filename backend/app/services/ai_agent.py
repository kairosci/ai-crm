from typing import Optional, Dict, Any
from langchain.llms import LlamaCpp
from langchain.agents import Tool, AgentExecutor, create_react_agent
from langchain.prompts import PromptTemplate
from langchain.memory import ConversationBufferMemory
from sqlalchemy.orm import Session
import os
import json

from ..api import crud
from ..schemas import ContactCreate, PipelineCreate, DealCreate, TaskCreate


class CRMAIAgent:
    """AI Agent for CRM operations using LangChain and llama-cpp-python"""
    
    def __init__(self):
        self.llm = None
        self.agent_executor = None
        self.memory = ConversationBufferMemory(memory_key="chat_history")
        
    def initialize(self):
        """Initialize the LLM and agent"""
        model_path = os.getenv("MODEL_PATH", "./models/model.gguf")
        n_ctx = int(os.getenv("MODEL_N_CTX", "2048"))
        n_gpu_layers = int(os.getenv("MODEL_N_GPU_LAYERS", "0"))
        
        # Check if model exists
        if not os.path.exists(model_path):
            print(f"Warning: Model file not found at {model_path}. AI agent will not be available.")
            return False
        
        # Initialize LlamaCpp
        self.llm = LlamaCpp(
            model_path=model_path,
            n_ctx=n_ctx,
            n_gpu_layers=n_gpu_layers,
            temperature=0.7,
            max_tokens=512,
            top_p=0.95,
            verbose=False
        )
        
        # Create tools
        tools = self._create_tools()
        
        # Create agent prompt
        template = """Answer the following questions as best you can. You have access to the following tools:

{tools}

Use the following format:

Question: the input question you must answer
Thought: you should always think about what to do
Action: the action to take, should be one of [{tool_names}]
Action Input: the input to the action
Observation: the result of the action
... (this Thought/Action/Action Input/Observation can repeat N times)
Thought: I now know the final answer
Final Answer: the final answer to the original input question

Begin!

Chat History: {chat_history}

Question: {input}
Thought: {agent_scratchpad}"""

        prompt = PromptTemplate.from_template(template)
        
        # Create agent
        agent = create_react_agent(self.llm, tools, prompt)
        
        # Create agent executor
        self.agent_executor = AgentExecutor(
            agent=agent,
            tools=tools,
            memory=self.memory,
            verbose=True,
            handle_parsing_errors=True,
            max_iterations=3
        )
        
        return True
    
    def _create_tools(self):
        """Create LangChain tools for CRM operations"""
        return [
            Tool(
                name="create_contact",
                func=self._tool_create_contact,
                description="Create a new contact. Input should be JSON with fields: first_name, last_name, email, phone (optional), company (optional), position (optional), notes (optional). Example: {\"first_name\": \"John\", \"last_name\": \"Doe\", \"email\": \"john@example.com\"}"
            ),
            Tool(
                name="get_contacts",
                func=self._tool_get_contacts,
                description="Get all contacts. Input: 'all' or empty string."
            ),
            Tool(
                name="get_contact",
                func=self._tool_get_contact,
                description="Get a specific contact by ID. Input should be the contact ID as a number."
            ),
            Tool(
                name="create_pipeline",
                func=self._tool_create_pipeline,
                description="Create a new pipeline. Input should be JSON with fields: name, description (optional). Example: {\"name\": \"Sales Pipeline\", \"description\": \"Main sales funnel\"}"
            ),
            Tool(
                name="get_pipelines",
                func=self._tool_get_pipelines,
                description="Get all pipelines. Input: 'all' or empty string."
            ),
            Tool(
                name="create_deal",
                func=self._tool_create_deal,
                description="Create a new deal. Input should be JSON with fields: title, value, pipeline_id, contact_id, description (optional), status (optional: lead/qualified/proposal/negotiation/won/lost). Example: {\"title\": \"Enterprise Deal\", \"value\": 50000, \"pipeline_id\": 1, \"contact_id\": 1}"
            ),
            Tool(
                name="get_deals",
                func=self._tool_get_deals,
                description="Get all deals. Input: 'all' or empty string."
            ),
            Tool(
                name="create_task",
                func=self._tool_create_task,
                description="Create a new task. Input should be JSON with fields: title, contact_id, description (optional), priority (optional: low/medium/high/urgent), status (optional: todo/in_progress/completed/cancelled). Example: {\"title\": \"Follow up call\", \"contact_id\": 1, \"priority\": \"high\"}"
            ),
            Tool(
                name="get_tasks",
                func=self._tool_get_tasks,
                description="Get all tasks. Input: 'all' or empty string."
            ),
        ]
    
    # Tool implementation methods
    def _tool_create_contact(self, input_str: str) -> str:
        """Tool to create a contact"""
        try:
            from ..database import SessionLocal
            data = json.loads(input_str)
            contact_data = ContactCreate(**data)
            db = SessionLocal()
            contact = crud.create_contact(db, contact_data)
            db.close()
            return f"Contact created successfully with ID {contact.id}: {contact.first_name} {contact.last_name} ({contact.email})"
        except Exception as e:
            return f"Error creating contact: {str(e)}"
    
    def _tool_get_contacts(self, input_str: str) -> str:
        """Tool to get all contacts"""
        try:
            from ..database import SessionLocal
            db = SessionLocal()
            contacts = crud.get_contacts(db, skip=0, limit=10)
            db.close()
            if not contacts:
                return "No contacts found."
            result = "Contacts:\n"
            for c in contacts:
                result += f"- ID {c.id}: {c.first_name} {c.last_name} ({c.email}) - {c.company or 'No company'}\n"
            return result
        except Exception as e:
            return f"Error getting contacts: {str(e)}"
    
    def _tool_get_contact(self, input_str: str) -> str:
        """Tool to get a specific contact"""
        try:
            from ..database import SessionLocal
            contact_id = int(input_str)
            db = SessionLocal()
            contact = crud.get_contact(db, contact_id)
            db.close()
            if not contact:
                return f"Contact with ID {contact_id} not found."
            return f"Contact ID {contact.id}: {contact.first_name} {contact.last_name}\nEmail: {contact.email}\nPhone: {contact.phone or 'N/A'}\nCompany: {contact.company or 'N/A'}\nPosition: {contact.position or 'N/A'}\nNotes: {contact.notes or 'N/A'}"
        except Exception as e:
            return f"Error getting contact: {str(e)}"
    
    def _tool_create_pipeline(self, input_str: str) -> str:
        """Tool to create a pipeline"""
        try:
            from ..database import SessionLocal
            data = json.loads(input_str)
            pipeline_data = PipelineCreate(**data)
            db = SessionLocal()
            pipeline = crud.create_pipeline(db, pipeline_data)
            db.close()
            return f"Pipeline created successfully with ID {pipeline.id}: {pipeline.name}"
        except Exception as e:
            return f"Error creating pipeline: {str(e)}"
    
    def _tool_get_pipelines(self, input_str: str) -> str:
        """Tool to get all pipelines"""
        try:
            from ..database import SessionLocal
            db = SessionLocal()
            pipelines = crud.get_pipelines(db, skip=0, limit=10)
            db.close()
            if not pipelines:
                return "No pipelines found."
            result = "Pipelines:\n"
            for p in pipelines:
                result += f"- ID {p.id}: {p.name} - {p.description or 'No description'}\n"
            return result
        except Exception as e:
            return f"Error getting pipelines: {str(e)}"
    
    def _tool_create_deal(self, input_str: str) -> str:
        """Tool to create a deal"""
        try:
            from ..database import SessionLocal
            data = json.loads(input_str)
            deal_data = DealCreate(**data)
            db = SessionLocal()
            deal = crud.create_deal(db, deal_data)
            db.close()
            return f"Deal created successfully with ID {deal.id}: {deal.title} (${deal.value}) - Status: {deal.status}"
        except Exception as e:
            return f"Error creating deal: {str(e)}"
    
    def _tool_get_deals(self, input_str: str) -> str:
        """Tool to get all deals"""
        try:
            from ..database import SessionLocal
            db = SessionLocal()
            deals = crud.get_deals(db, skip=0, limit=10)
            db.close()
            if not deals:
                return "No deals found."
            result = "Deals:\n"
            for d in deals:
                result += f"- ID {d.id}: {d.title} (${d.value}) - Status: {d.status} - Pipeline ID: {d.pipeline_id}\n"
            return result
        except Exception as e:
            return f"Error getting deals: {str(e)}"
    
    def _tool_create_task(self, input_str: str) -> str:
        """Tool to create a task"""
        try:
            from ..database import SessionLocal
            data = json.loads(input_str)
            task_data = TaskCreate(**data)
            db = SessionLocal()
            task = crud.create_task(db, task_data)
            db.close()
            return f"Task created successfully with ID {task.id}: {task.title} - Priority: {task.priority}, Status: {task.status}"
        except Exception as e:
            return f"Error creating task: {str(e)}"
    
    def _tool_get_tasks(self, input_str: str) -> str:
        """Tool to get all tasks"""
        try:
            from ..database import SessionLocal
            db = SessionLocal()
            tasks = crud.get_tasks(db, skip=0, limit=10)
            db.close()
            if not tasks:
                return "No tasks found."
            result = "Tasks:\n"
            for t in tasks:
                result += f"- ID {t.id}: {t.title} - Priority: {t.priority}, Status: {t.status}, Contact ID: {t.contact_id}\n"
            return result
        except Exception as e:
            return f"Error getting tasks: {str(e)}"
    
    def process_message(self, message: str) -> Dict[str, Any]:
        """Process a user message through the AI agent"""
        if not self.agent_executor:
            return {
                "response": "AI agent is not initialized. Please ensure the model file is available.",
                "action_taken": None
            }
        
        try:
            result = self.agent_executor.invoke({"input": message})
            return {
                "response": result.get("output", "No response generated."),
                "action_taken": "Processed through AI agent"
            }
        except Exception as e:
            return {
                "response": f"Error processing message: {str(e)}",
                "action_taken": None
            }


# Global agent instance
ai_agent = CRMAIAgent()
