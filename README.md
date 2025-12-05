# Enterprise CRM with AI Integration

An Enterprise CRM system built with Next.js, FastAPI, and PostgreSQL, featuring AI-powered chat assistance using local LLM via llama-cpp-python.

## Quick Start

Get started in under 5 minutes with Docker:

```bash
git clone https://github.com/kairosci/ai-crm.git
cd ai-crm
cp .env.example .env
make deploy
```

Access at http://localhost

**See [QUICKSTART.md](docs/QUICKSTART.md)** for detailed setup instructions  
**See [PRODUCTION.md](docs/PRODUCTION.md)** for production deployment

## Features

- **Contacts Management**: Add, view, and manage customer contacts
- **Pipeline Tracking**: Organize deals through customizable sales pipelines
- **Task Management**: Create and track tasks with priority levels
- **AI Chat Plugin**: Floating AI assistant accessible from any page, with contextual suggestions and natural language interface to manage CRM operations using local LLM (no external API required)

## Technology Stack

### Backend
- **FastAPI**: Modern Python web framework for building APIs
- **SQLAlchemy**: ORM for database operations
- **PostgreSQL**: Robust relational database
- **LangChain**: Framework for building LLM applications
- **llama-cpp-python**: Local LLM inference using GGUF models

### Frontend
- **Next.js 15**: React framework with App Router
- **TypeScript**: Type-safe development
- **Tailwind CSS**: Utility-first CSS framework

## Architecture

The system uses a LangChain agent that loads a local GGUF model via llama-cpp-python. CRUD operations are exposed as LangChain Tools, enabling the AI to perform real database operations through function calling.

## Quick Start with Makefile

We provide a comprehensive Makefile to streamline development operations:

```bash
# Complete setup (installs dependencies, starts database)
make setup

# Start both backend and frontend development servers
make dev

# Or start them separately
make dev-backend  # Backend on http://localhost:8000
make dev-frontend # Frontend on http://localhost:3000

# See all available commands
make help
```

## Setup Instructions

### Prerequisites

- Python 3.10+
- Node.js 18+
- Docker (for PostgreSQL via docker-compose)
- GGUF model file (optional, for AI features)

### Manual Setup (Alternative to Makefile)

#### Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Create a `.env` file based on `.env.example`:
```bash
cp .env.example .env
```

5. Configure your database URL and model path in `.env`:
```
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/crm_db
MODEL_PATH=./models/model.gguf
MODEL_N_CTX=2048
MODEL_N_GPU_LAYERS=0
```

6. Start PostgreSQL and create the database:
```bash
docker compose up -d postgres
createdb crm_db
```

7. Download a GGUF model file and place it in the `models/` directory. You can download models from:
   - Hugging Face: https://huggingface.co/models?search=gguf
   - TheBloke's models: https://huggingface.co/TheBloke

8. Run the backend:
```bash
python run.py
```

The API will be available at http://localhost:8000
API documentation at http://localhost:8000/docs

#### Frontend Setup

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env.local` file (optional):
```
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
```

4. Run the development server:
```bash
npm run dev
```

The frontend will be available at http://localhost:3000

## Database Schema

### Contacts
- Personal information (name, email, phone)
- Company details (company, position)
- Notes and timestamps

### Pipelines
- Name and description
- Contains multiple deals

### Deals
- Title, description, value
- Status (lead, qualified, proposal, negotiation, won, lost)
- Linked to pipeline and contact

### Tasks
- Title, description
- Priority (low, medium, high, urgent)
- Status (todo, in_progress, completed, cancelled)
- Linked to contact
- Due dates and completion tracking

## AI Chat Plugin Usage

The AI assistant is available as a floating plugin accessible from any page in the CRM. Click the blue chat button in the bottom-right corner to open the assistant.

### Key Features
- **Always Available**: Access the AI assistant from any page without navigation
- **Contextual Suggestions**: Get relevant quick actions based on your current page
- **Minimize/Maximize**: Collapse the chat to a compact header when not in use
- **Notification Badge**: See unread message counts when the chat is minimized or closed
- **Modern UI**: Smooth animations and gradient styling for a polished experience

The AI assistant can help you manage your CRM using natural language. Examples:

### Creating Contacts
```
"Create a contact named John Doe with email john@example.com"
"Add a new contact: Jane Smith, jane@company.com, works at Acme Corp"
```

### Managing Pipelines
```
"Create a pipeline called Sales Pipeline"
"Show me all pipelines"
```

### Creating Deals
```
"Create a deal worth $50000 for contact ID 1 in pipeline ID 1"
"Add a new deal called Enterprise Contract valued at $100k"
```

### Managing Tasks
```
"Create a task to follow up with contact ID 1"
"Add a high priority task: Send proposal to client"
```

### Viewing Data
```
"Show me all contacts"
"List all deals"
"What tasks do I have?"
```

## API Endpoints

### Contacts
- `GET /api/v1/contacts` - List all contacts
- `POST /api/v1/contacts` - Create a new contact
- `GET /api/v1/contacts/{id}` - Get a specific contact
- `PUT /api/v1/contacts/{id}` - Update a contact
- `DELETE /api/v1/contacts/{id}` - Delete a contact

### Pipelines
- `GET /api/v1/pipelines` - List all pipelines
- `POST /api/v1/pipelines` - Create a new pipeline
- `GET /api/v1/pipelines/{id}` - Get a specific pipeline
- `PUT /api/v1/pipelines/{id}` - Update a pipeline
- `DELETE /api/v1/pipelines/{id}` - Delete a pipeline

### Deals
- `GET /api/v1/deals` - List all deals
- `POST /api/v1/deals` - Create a new deal
- `GET /api/v1/deals/{id}` - Get a specific deal
- `PUT /api/v1/deals/{id}` - Update a deal
- `DELETE /api/v1/deals/{id}` - Delete a deal

### Tasks
- `GET /api/v1/tasks` - List all tasks
- `POST /api/v1/tasks` - Create a new task
- `GET /api/v1/tasks/{id}` - Get a specific task
- `PUT /api/v1/tasks/{id}` - Update a task
- `DELETE /api/v1/tasks/{id}` - Delete a task

### AI Chat
- `POST /api/v1/chat` - Send a message to the AI assistant

## Development

### Available Makefile Commands

Run `make help` to see all available commands. Key commands include:

**Setup and Installation:**
```bash
make install              # Install all dependencies (backend + frontend)
make install-backend      # Install backend Python dependencies
make install-frontend     # Install frontend Node dependencies
make setup                # Complete project setup (install + db)
```

**Development:**
```bash
make dev                  # Run both backend and frontend in parallel
make dev-backend          # Run backend development server only
make dev-frontend         # Run frontend development server only
```

**Database:**
```bash
make db-start             # Start PostgreSQL using Docker
make db-stop              # Stop PostgreSQL
make db-create            # Create the CRM database
make db-shell             # Open PostgreSQL shell
```

**Docker:**
```bash
make docker-up            # Start all services with docker-compose
make docker-down          # Stop all services
make docker-clean         # Stop and remove all containers and volumes
```

**Build:**
```bash
make build                # Build both backend and frontend
make build-backend        # Validate backend code
make build-frontend       # Build frontend for production
```

**Testing:**
```bash
make test                 # Run all tests
make test-backend         # Run backend tests
make test-frontend        # Run frontend tests
```

**Linting:**
```bash
make lint                 # Lint both backend and frontend
make lint-backend         # Lint backend Python code
make lint-frontend        # Lint frontend TypeScript code
```

**Cleaning:**
```bash
make clean                # Clean all build artifacts
make clean-backend        # Clean backend artifacts
make clean-frontend       # Clean frontend artifacts
```

### Backend Structure
```
backend/
├── app/
│   ├── api/
│   │   ├── crud.py       # CRUD operations
│   │   └── routes.py     # API endpoints
│   ├── models/           # SQLAlchemy models
│   │   ├── contact.py
│   │   ├── pipeline.py
│   │   └── task.py
│   ├── schemas/          # Pydantic schemas
│   ├── services/
│   │   └── ai_agent.py   # LangChain AI agent
│   ├── database.py       # Database connection
│   └── main.py          # FastAPI application
└── run.py               # Run script
```

### Frontend Structure
```
frontend/
├── app/
│   ├── chat/            # Legacy chat page (kept for direct access)
│   ├── contacts/        # Contacts page
│   ├── pipelines/       # Pipelines page
│   ├── tasks/           # Tasks page
│   ├── layout.tsx       # Root layout with navigation and ChatPlugin
│   └── page.tsx         # Home page
├── components/
│   └── ChatPlugin.tsx   # Floating AI chat plugin component
└── lib/
    └── api.ts           # API client
```

## Production Deployment

The project includes complete production infrastructure:

- **Docker & Docker Compose**: Multi-container setup with health checks
- **Nginx**: Reverse proxy with rate limiting and SSL/TLS support
- **Monitoring**: Health check endpoints and structured logging
- **Security**: CORS, security headers, environment-based configuration
- **Backups**: Automated database backup and restore scripts
- **CI/CD**: GitHub Actions workflow for testing and building
- **Documentation**: Comprehensive guides and troubleshooting

### Deployment Options

1. **Quick Deploy**: `make deploy` (see [QUICKSTART.md](docs/QUICKSTART.md))
2. **Production Deploy**: Follow [PRODUCTION.md](docs/PRODUCTION.md) guide
3. **Development**: `make dev-up` (database only, run code locally)

### Available Commands

```bash
make help              # Show all commands
make deploy            # Deploy to production
make backup            # Backup database
make logs              # View logs
make health            # Check service health
```

See [Makefile](Makefile) for all available commands.

## Documentation

- **[QUICKSTART.md](docs/QUICKSTART.md)** - Get started in 5 minutes
- **[PRODUCTION.md](docs/PRODUCTION.md)** - Complete production deployment guide
- **[TODO.md](docs/TODO.md)** - Roadmap and future features
- **[docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md)** - Detailed setup instructions
- **[docs/EXAMPLES.md](docs/EXAMPLES.md)** - API and AI chat examples
- **[nginx/README.md](nginx/README.md)** - SSL/TLS configuration

## Notes

- The AI agent requires a GGUF model file to function. Without it, the chat feature will display a warning message but the rest of the CRM will work normally.
- For production use, consider using a more powerful LLM and adjusting the `MODEL_N_GPU_LAYERS` setting if you have GPU support.
- The system uses local AI inference, ensuring data privacy and no external API dependencies.
- All production infrastructure (Docker, nginx, monitoring, backups) is included and ready to use.

## Contributing

See [TODO.md](docs/TODO.md) for planned features and how to contribute.

## License

See LICENSE file for details.