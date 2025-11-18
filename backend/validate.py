"""
Validation script to check the backend structure without running it.
This can be used after installing dependencies to verify everything works.
"""
import sys

def validate_structure():
    """Validate backend structure and imports"""
    errors = []
    
    try:
        from app.main import app
        print("✓ FastAPI app imported")
    except Exception as e:
        errors.append(f"✗ Failed to import FastAPI app: {e}")
    
    try:
        from app.database import Base, engine, get_db, init_db
        print("✓ Database module imported")
    except Exception as e:
        errors.append(f"✗ Failed to import database module: {e}")
    
    try:
        from app.models import Contact, Pipeline, Deal, Task
        print("✓ All models imported")
    except Exception as e:
        errors.append(f"✗ Failed to import models: {e}")
    
    try:
        from app.api import crud
        print("✓ CRUD operations imported")
    except Exception as e:
        errors.append(f"✗ Failed to import CRUD operations: {e}")
    
    try:
        from app.api.routes import router
        print("✓ API routes imported")
    except Exception as e:
        errors.append(f"✗ Failed to import API routes: {e}")
    
    try:
        from app.services.ai_agent import ai_agent, CRMAIAgent
        print("✓ AI agent imported")
    except Exception as e:
        errors.append(f"✗ Failed to import AI agent: {e}")
    
    if errors:
        print("\n❌ Validation failed with errors:")
        for error in errors:
            print(f"  {error}")
        sys.exit(1)
    else:
        print("\n✅ All validations passed!")
        print("\nNext steps:")
        print("1. Make sure PostgreSQL is running")
        print("2. Configure .env file with your database URL and model path")
        print("3. Run: python run.py")
        sys.exit(0)

if __name__ == "__main__":
    print("Validating backend structure...\n")
    validate_structure()
