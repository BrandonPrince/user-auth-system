User Authentication System

A full-stack user authentication system with a FastAPI backend, MySQL database, and Flutter frontend, orchestrated using Docker.

Repository
GitHub: https://github.com/BrandonPrince/user-auth-system


Clone the repository:
git clone https://github.com/BrandonPrince/user-auth-system.git

Architecture
Backend: FastAPI (Python) with SQLAlchemy for database interactions, JWT for authentication, and CORS middleware for cross-origin requests.
Database: MySQL 8.0.
Frontend: Flutter app for registration, login, profile updates, and logout, supporting Android emulator and web.
Docker: Containers for backend and database.

Prerequisites
Docker and Docker Compose
Flutter 3.0+ (for frontend)
Git

Backend Setup:
Run Docker Compose to start backend and database:

docker-compose up -d --build
The backend automatically creates the users table and inserts a test user (email: test@example.com, password: password) on startup.

Access API at http://localhost:8000 (Swagger UI: http://localhost:8000/docs).

Frontend Setup:

Navigate to frontend/:
cd frontend

Install dependencies:
flutter pub get

Run the app:

For Android emulator:
flutter run

For web:
flutter run -d chrome


Backend URL Configuration:
Android Emulator: Uses http://10.0.2.2:8000 (set in lib/config.dart).
Web: Uses http://localhost:8000. If it times out:

Find your host IP:
Windows: ipconfig (e.g., IPv4 Address: 192.168.x.x)
macOS/Linux: ifconfig or ip addr (e.g., inet 192.168.x.x)

Update lib/config.dart to http://<your-ip>:8000.

Ensure backend has CORS middleware (allow_origins=["*"] in backend/app/main.py).

Usage
Register: Click “Don’t have an account? Register” to create an account. There are validations on the fields
Login: Use test@example.com and password or a registered account. There are validations on the fields
Update Profile: View current details and update.
Logout: Click “Logout” to return to the login screen.


Database Verification:
docker exec -it user-auth-system-db-1 mysql -u root -p

USE user_auth_db;
SELECT * FROM users;

Notes
Security: Passwords are hashed with bcrypt, and JWT tokens have a 30-minute expiry.
Portability: Docker and config.dart ensure cross-platform compatibility.

Troubleshooting:
If web build times out, check firewall (port 8000) or use host IP.
Ensure Docker containers are running (docker-compose ps).
Check backend logs: docker logs user-auth-system-backend-1.
