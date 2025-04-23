User Authentication System

A full-stack user authentication system with a FastAPI backend, MySQL database, and Flutter frontend, orchestrated using Docker.

Repository
GitHub: https://github.com/BrandonPrince/user-auth-system


Clone the repository: <br/>
git clone https://github.com/BrandonPrince/user-auth-system.git  <br/>

Architecture  <br/>
Backend: FastAPI (Python) with SQLAlchemy for database interactions, JWT for authentication, and CORS middleware for cross-origin requests.  <br/>
Database: MySQL 8.0.  <br/>
Frontend: Flutter app for registration, login, profile updates, and logout, supporting Android emulator and web.  <br/>
Docker: Containers for backend and database.  <br/>

Prerequisites  <br/>
Docker and Docker Compose  <br/>
Flutter 3.0+ (for frontend)  <br/>
Git  <br/>

Backend Setup:  <br/>
Run Docker Compose to start backend and database:  <br/>

docker-compose up -d --build  <br/>
The backend automatically creates the users table and inserts a test user (email: test@example.com, password: password) on startup.  <br/>
 <br/>
Access API at http://localhost:8000 (Swagger UI: http://localhost:8000/docs).  <br/>
 <br/>
Frontend Setup:  <br/>

Navigate to frontend/:  <br/>
cd frontend  <br/>

Install dependencies:  <br/>
flutter pub get  <br/>

Run the app:  <br/>

For Android emulator:  <br/>
flutter run  <br/>

For web:  <br/>
flutter run -d chrome  <br/>


Backend URL Configuration:  <br/>
Android Emulator: Uses http://10.0.2.2:8000 (set in lib/config.dart).  <br/>
Web: Uses http://localhost:8000. If it times out:  <br/>

Find your host IP:  <br/>
Windows: ipconfig (e.g., IPv4 Address: 192.168.x.x)  <br/>
macOS/Linux: ifconfig or ip addr (e.g., inet 192.168.x.x)  <br/>
 
Update lib/config.dart to http://<your-ip>:8000.  <br/>

Ensure backend has CORS middleware (allow_origins=["*"] in backend/app/main.py).  <br/>

Usage  <br/>
Register: Click “Don’t have an account? Register” to create an account. There are validations on the fields  <br/>
Login: Use test@example.com and password or a registered account. There are validations on the fields  <br/>
Update Profile: View current details and update.  <br/>
Logout: Click “Logout” to return to the login screen.  <br/>
 <br/>

Database Verification:  <br/>
docker exec -it user-auth-system-db-1 mysql -u root -p  <br/>

USE user_auth_db;  <br/>
SELECT * FROM users;  <br/>

Notes  <br/>
Security: Passwords are hashed with bcrypt, and JWT tokens have a 30-minute expiry.  <br/>
Portability: Docker and config.dart ensure cross-platform compatibility.  <br/>
 
Troubleshooting:  <br/>
If web build times out, check firewall (port 8000) or use host IP.  <br/>
Ensure Docker containers are running (docker-compose ps).  <br/>
Check backend logs: docker logs user-auth-system-backend-1.  <br/>
