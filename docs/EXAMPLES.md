# Usage Examples

This document provides practical examples of using the Enterprise CRM system.

## API Examples

### Using curl

#### Create a Contact
```bash
curl -X POST "http://localhost:8000/api/v1/contacts" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Alice",
    "last_name": "Johnson",
    "email": "alice@techcorp.com",
    "phone": "+1-555-0123",
    "company": "TechCorp Inc",
    "position": "CTO",
    "notes": "Interested in enterprise plan"
  }'
```

#### Get All Contacts
```bash
curl "http://localhost:8000/api/v1/contacts"
```

#### Update a Contact
```bash
curl -X PUT "http://localhost:8000/api/v1/contacts/1" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+1-555-9999",
    "notes": "Meeting scheduled for next week"
  }'
```

#### Create a Pipeline
```bash
curl -X POST "http://localhost:8000/api/v1/pipelines" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Q4 Enterprise Sales",
    "description": "Fourth quarter enterprise deals"
  }'
```

#### Create a Deal
```bash
curl -X POST "http://localhost:8000/api/v1/deals" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Enterprise License - TechCorp",
    "description": "100 user licenses for 1 year",
    "value": 50000.00,
    "status": "qualified",
    "pipeline_id": 1,
    "contact_id": 1
  }'
```

#### Create a Task
```bash
curl -X POST "http://localhost:8000/api/v1/tasks" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Send proposal to Alice",
    "description": "Prepare and send enterprise proposal document",
    "priority": "high",
    "status": "todo",
    "contact_id": 1,
    "due_date": "2024-12-31T17:00:00Z"
  }'
```

#### Chat with AI
```bash
curl -X POST "http://localhost:8000/api/v1/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Show me all contacts"
  }'
```

### Using Python

```python
import requests

BASE_URL = "http://localhost:8000/api/v1"

# Create a contact
contact_data = {
    "first_name": "Bob",
    "last_name": "Smith",
    "email": "bob@startup.io",
    "company": "StartupCo"
}
response = requests.post(f"{BASE_URL}/contacts", json=contact_data)
contact = response.json()
print(f"Created contact: {contact['id']}")

# Get all contacts
response = requests.get(f"{BASE_URL}/contacts")
contacts = response.json()
print(f"Total contacts: {len(contacts)}")

# Create a pipeline
pipeline_data = {
    "name": "Sales Pipeline",
    "description": "Main sales funnel"
}
response = requests.post(f"{BASE_URL}/pipelines", json=pipeline_data)
pipeline = response.json()

# Create a deal
deal_data = {
    "title": "Startup Deal",
    "value": 25000.0,
    "status": "lead",
    "pipeline_id": pipeline["id"],
    "contact_id": contact["id"]
}
response = requests.post(f"{BASE_URL}/deals", json=deal_data)
deal = response.json()

# Chat with AI
chat_data = {
    "message": f"Create a task to follow up with contact ID {contact['id']}"
}
response = requests.post(f"{BASE_URL}/chat", json=chat_data)
result = response.json()
print(f"AI response: {result['response']}")
```

### Using JavaScript/TypeScript

```typescript
const BASE_URL = 'http://localhost:8000/api/v1';

// Create a contact
async function createContact() {
  const response = await fetch(`${BASE_URL}/contacts`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      first_name: 'Carol',
      last_name: 'Davis',
      email: 'carol@company.com',
      company: 'DataCorp'
    })
  });
  const contact = await response.json();
  console.log('Created contact:', contact.id);
  return contact;
}

// Get all contacts
async function getContacts() {
  const response = await fetch(`${BASE_URL}/contacts`);
  const contacts = await response.json();
  console.log('Total contacts:', contacts.length);
  return contacts;
}

// Chat with AI
async function chatWithAI(message: string) {
  const response = await fetch(`${BASE_URL}/chat`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ message })
  });
  const result = await response.json();
  console.log('AI:', result.response);
  return result;
}

// Example usage
(async () => {
  const contact = await createContact();
  await chatWithAI(`Create a high priority task for contact ${contact.id}`);
})();
```

## AI Chat Examples

### Basic Queries

**List all contacts:**
```
"Show me all contacts"
"List all contacts"
"Get all contacts"
```

**Get specific contact:**
```
"Get contact with ID 1"
"Show me contact 1"
```

**List deals:**
```
"Show me all deals"
"What deals do we have?"
```

**List tasks:**
```
"Show me all tasks"
"What tasks do I have?"
```

### Creating Records

**Create a contact:**
```
"Create a contact named David Brown with email david@example.com"
"Add a new contact: Sarah Miller, sarah@company.com, works at MegaCorp"
"Create contact: first name Emma, last name Wilson, email emma@tech.com, phone 555-1234"
```

**Create a pipeline:**
```
"Create a pipeline called Enterprise Sales"
"Add a new pipeline named Q1 2024 Sales Pipeline"
```

**Create a deal:**
```
"Create a deal worth $75000 for contact ID 1 in pipeline ID 1"
"Add a deal titled 'Premium Package' valued at $100000 in pipeline 1 for contact 2"
"Create a new deal: title 'Annual Contract', value 50000, pipeline 1, contact 1, status qualified"
```

**Create a task:**
```
"Create a task to follow up with contact ID 1"
"Add a high priority task: Send proposal to client"
"Create task: title 'Schedule demo', priority urgent, contact 1"
```

### Complex Queries

**Workflow example:**
```
User: "Create a contact named Jennifer Lee with email jennifer@bigcorp.com at BigCorp Inc"
AI: Contact created successfully with ID 5...

User: "Create a pipeline called Enterprise Deals 2024"
AI: Pipeline created successfully with ID 3...

User: "Create a deal worth $200000 for contact 5 in pipeline 3 called BigCorp Enterprise License"
AI: Deal created successfully...

User: "Create a high priority task to send contract to contact 5"
AI: Task created successfully...

User: "Show me all deals"
AI: Deals: [lists all deals including the new one]
```

## Frontend Usage Examples

### Adding a Contact via UI

1. Navigate to http://localhost:3000/contacts
2. Click "Add Contact" button
3. Fill in the form:
   - First Name: John
   - Last Name: Doe
   - Email: john@example.com
   - Phone: (optional)
   - Company: Example Corp
   - Position: Sales Manager
4. Click "Create Contact"

### Using AI Chat

1. Navigate to http://localhost:3000/chat
2. Type your query in natural language
3. Examples:
   - "Create a contact named Sarah with email sarah@company.com"
   - "Show me all contacts"
   - "Create a pipeline called Sales Q4"
   - "Add a task to call contact 1 tomorrow"

### Viewing Pipelines and Deals

1. Navigate to http://localhost:3000/pipelines
2. View all pipelines with their deals
3. See deal status, value, and contact information

### Managing Tasks

1. Navigate to http://localhost:3000/tasks
2. View all tasks with filters (All, To Do, In Progress, Completed)
3. Click checkbox to mark tasks as complete
4. See task priority, status, and contact information

## Integration Examples

### Webhook Integration (Example)

```python
# webhook_handler.py
from fastapi import FastAPI, Request
import requests

app = FastAPI()

CRM_API = "http://localhost:8000/api/v1"

@app.post("/webhook/new-signup")
async def handle_new_signup(request: Request):
    """Handle new user signups from external system"""
    data = await request.json()
    
    # Create contact in CRM
    contact_data = {
        "first_name": data["first_name"],
        "last_name": data["last_name"],
        "email": data["email"],
        "company": data.get("company", ""),
        "notes": f"Signed up via {data.get('source', 'unknown')}"
    }
    
    response = requests.post(f"{CRM_API}/contacts", json=contact_data)
    contact = response.json()
    
    # Create a follow-up task
    task_data = {
        "title": f"Follow up with {contact['first_name']}",
        "description": "Send welcome email and schedule onboarding call",
        "priority": "high",
        "status": "todo",
        "contact_id": contact["id"]
    }
    
    requests.post(f"{CRM_API}/tasks", json=task_data)
    
    return {"status": "success", "contact_id": contact["id"]}
```

### Automated Reporting (Example)

```python
# daily_report.py
import requests
from datetime import datetime

CRM_API = "http://localhost:8000/api/v1"

def generate_daily_report():
    """Generate daily CRM report"""
    
    # Get all data
    contacts = requests.get(f"{CRM_API}/contacts").json()
    deals = requests.get(f"{CRM_API}/deals").json()
    tasks = requests.get(f"{CRM_API}/tasks").json()
    
    # Calculate metrics
    total_deal_value = sum(deal["value"] for deal in deals)
    won_deals = [d for d in deals if d["status"] == "won"]
    pending_tasks = [t for t in tasks if t["status"] != "completed"]
    
    report = f"""
    Daily CRM Report - {datetime.now().strftime('%Y-%m-%d')}
    
    Contacts: {len(contacts)}
    Total Deals: {len(deals)}
    Total Deal Value: ${total_deal_value:,.2f}
    Won Deals: {len(won_deals)}
    Pending Tasks: {len(pending_tasks)}
    """
    
    print(report)
    return report

if __name__ == "__main__":
    generate_daily_report()
```

## Tips and Best Practices

1. **Always validate input data** before sending to the API
2. **Use proper error handling** for API requests
3. **Leverage the AI chat** for quick data entry and queries
4. **Create meaningful task descriptions** to track follow-ups
5. **Use pipeline statuses** to track deal progress
6. **Add detailed notes** to contacts for better context
7. **Set task priorities** to organize your workflow
8. **Regular data backups** of your PostgreSQL database
