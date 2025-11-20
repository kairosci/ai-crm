# Setup Guide - Enterprise CRM

This guide will help you set up and run the Enterprise CRM system with AI integration.

## Quick Start

### 1. Start PostgreSQL Database

Using Docker Compose (recommended):
```bash
docker-compose up -d
```

Or install PostgreSQL manually and create a database:
```bash
createdb crm_db
```

### 2. Setup Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
```

Edit `.env` file with your database connection and model path.

### 3. Download AI Model (Optional)

The AI chat feature requires a GGUF model file. You can:

1. Download a small model for testing:
   - TinyLlama (1.1B): https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF
   - Llama 2 7B: https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF

2. Place the model file in `backend/models/` directory

3. Update the `MODEL_PATH` in `.env`:
   ```
   MODEL_PATH=./models/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf
   ```

**Note:** The CRM will work without the model file, but the AI chat feature will not be available.

### 4. Run Backend

```bash
cd backend
python run.py
```

Backend will be available at:
- API: http://localhost:8000
- Docs: http://localhost:8000/docs

### 5. Setup Frontend

Open a new terminal:

```bash
cd frontend
npm install
npm run dev
```

Frontend will be available at: http://localhost:3000

## Testing the System

### 1. Create a Contact

Visit http://localhost:3000/contacts and click "Add Contact"

Or use the API:
```bash
curl -X POST "http://localhost:8000/api/v1/contacts" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "John",
    "last_name": "Doe",
    "email": "john@example.com",
    "company": "Acme Corp"
  }'
```

### 2. Create a Pipeline

Use the AI chat:
```
"Create a pipeline called Sales Pipeline"
```

Or use the API:
```bash
curl -X POST "http://localhost:8000/api/v1/pipelines" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sales Pipeline",
    "description": "Main sales funnel"
  }'
```

### 3. Create a Deal

Use the AI chat:
```
"Create a deal worth $50000 for contact ID 1 in pipeline ID 1 called Enterprise Contract"
```

### 4. Create a Task

Use the AI chat:
```
"Create a high priority task to follow up with contact ID 1"
```

## AI Chat Examples

The AI assistant can help you manage the CRM using natural language:

### Contact Management
- "Create a contact named Jane Smith with email jane@company.com"
- "Show me all contacts"
- "Get contact with ID 1"

### Pipeline Management
- "Create a pipeline called Q4 Sales"
- "Show me all pipelines"

### Deal Management
- "Create a deal titled 'Enterprise Contract' worth $100000 in pipeline 1 for contact 1"
- "Show me all deals"

### Task Management
- "Create a task to send proposal to contact 1"
- "Create a high priority task: Schedule demo call"
- "Show me all tasks"

## Troubleshooting

### Backend Issues

**Database connection error:**
- Make sure PostgreSQL is running
- Check `DATABASE_URL` in `.env` file
- Verify database exists: `psql -l`

**Model loading error:**
- The system will work without a model, but AI chat won't function
- Download a GGUF model file and place it in `backend/models/`
- Update `MODEL_PATH` in `.env`

**Import errors:**
- Make sure virtual environment is activated
- Reinstall dependencies: `pip install -r requirements.txt`

### Frontend Issues

**API connection error:**
- Make sure backend is running on port 8000
- Check CORS settings in `backend/app/main.py`

**Build errors:**
- Clear Next.js cache: `rm -rf .next`
- Reinstall dependencies: `rm -rf node_modules && npm install`

## Production Deployment

### Backend

1. Use a production WSGI server:
```bash
pip install gunicorn
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker
```

2. Configure environment variables for production
3. Set up PostgreSQL with proper credentials
4. Use a reverse proxy (nginx)

### Frontend

1. Build for production:
```bash
npm run build
npm start
```

2. Or deploy to Vercel/Netlify

### Security Considerations

- Change default database credentials
- Use environment variables for sensitive data
- Enable HTTPS
- Implement authentication/authorization
- Regular security updates

## Model Selection

For production use, consider:

- **Small models (1-3B)**: Fast, lower resource usage, suitable for basic tasks
  - TinyLlama 1.1B
  - Phi-2 2.7B

- **Medium models (7-13B)**: Better understanding, still reasonable resource usage
  - Llama 2 7B
  - Mistral 7B

- **Large models (30B+)**: Best performance, requires significant resources
  - Llama 2 70B
  - Mixtral 8x7B

### GPU Acceleration

To use GPU acceleration:

1. Install CUDA and cuDNN
2. Install llama-cpp-python with GPU support:
```bash
CMAKE_ARGS="-DLLAMA_CUBLAS=on" pip install llama-cpp-python
```
3. Set `MODEL_N_GPU_LAYERS` in `.env` to offload layers to GPU

## Support

For issues or questions, please refer to:
- README.md for general information
- Backend API docs: http://localhost:8000/docs
- LangChain docs: https://python.langchain.com/docs/
- llama-cpp-python docs: https://github.com/abetlen/llama-cpp-python
