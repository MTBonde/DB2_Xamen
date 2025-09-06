# User Management API Specification

## Overview
RESTful API for managing users in the Recipe & Ingredient Management Database application. This API provides full CRUD operations for user entities following REST principles and HTTP standards.

**Base URL**: `http://localhost:5000/api`  
**API Version**: 1.0  
**Content Type**: `application/json`

---

## Authentication
*Note: Authentication will be added in future iterations. Current version operates without authentication for development and demonstration purposes.*

---

## User Entity

### User Model
```json
{
  "userId": 1,
  "email": "user@example.com",
  "passwordHash": "hashed_password_string",
  "createdAt": "2025-09-06T10:30:00Z"
}
```

### Field Descriptions
| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `userId` | integer | Auto-generated | Unique user identifier | Primary key, auto-increment |
| `email` | string | Yes | User's email address | Must be valid email format, unique |
| `passwordHash` | string | Yes | Hashed password | Min 8 characters before hashing |
| `createdAt` | datetime | Auto-generated | Account creation timestamp | ISO 8601 format |

---

## API Endpoints

### 1. Get All Users
**GET** `/api/users`

Retrieves a list of all users in the system.

#### Request
```http
GET /api/users HTTP/1.1
Host: localhost:5000
Accept: application/json
```

#### Query Parameters
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `search` | string | No | Search users by email | `?search=john` |
| `limit` | integer | No | Maximum number of results | `?limit=10` |
| `offset` | integer | No | Number of results to skip | `?offset=20` |

#### Response
**200 OK**
```json
{
  "users": [
    {
      "userId": 1,
      "email": "john.doe@example.com",
      "passwordHash": "[HIDDEN]",
      "createdAt": "2025-09-06T10:30:00Z"
    },
    {
      "userId": 2,
      "email": "jane.smith@example.com", 
      "passwordHash": "[HIDDEN]",
      "createdAt": "2025-09-06T11:15:00Z"
    }
  ],
  "totalCount": 2
}
```

**500 Internal Server Error**
```json
{
  "error": "Database connection failed",
  "details": "Unable to connect to PostgreSQL database"
}
```

---

### 2. Get User by ID
**GET** `/api/users/{id}`

Retrieves a specific user by their unique identifier.

#### Request
```http
GET /api/users/1 HTTP/1.1
Host: localhost:5000
Accept: application/json
```

#### Path Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | integer | Yes | Unique user identifier |

#### Response
**200 OK**
```json
{
  "userId": 1,
  "email": "john.doe@example.com",
  "passwordHash": "[HIDDEN]",
  "createdAt": "2025-09-06T10:30:00Z"
}
```

**404 Not Found**
```json
{
  "error": "User not found",
  "details": "No user exists with ID: 1"
}
```

**400 Bad Request**
```json
{
  "error": "Invalid user ID",
  "details": "User ID must be a positive integer"
}
```

---

### 3. Create New User
**POST** `/api/users`

Creates a new user account in the system.

#### Request
```http
POST /api/users HTTP/1.1
Host: localhost:5000
Content-Type: application/json

{
  "email": "newuser@example.com",
  "password": "securePassword123"
}
```

#### Request Body
```json
{
  "email": "string (required)",
  "password": "string (required, min 8 characters)"
}
```

#### Response
**201 Created**
```json
{
  "userId": 3,
  "email": "newuser@example.com",
  "passwordHash": "[HIDDEN]",
  "createdAt": "2025-09-06T12:00:00Z"
}
```

**400 Bad Request**
```json
{
  "error": "Validation failed",
  "details": {
    "email": ["Email is required", "Email format is invalid"],
    "password": ["Password must be at least 8 characters long"]
  }
}
```

**409 Conflict**
```json
{
  "error": "Email already exists",
  "details": "A user with this email address already exists"
}
```

---

### 4. Update User
**PUT** `/api/users/{id}`

Updates an existing user's information.

#### Request
```http
PUT /api/users/1 HTTP/1.1
Host: localhost:5000
Content-Type: application/json

{
  "email": "updated.email@example.com",
  "password": "newSecurePassword456"
}
```

#### Path Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | integer | Yes | Unique user identifier |

#### Request Body
```json
{
  "email": "string (optional)",
  "password": "string (optional, min 8 characters)"
}
```

#### Response
**200 OK**
```json
{
  "userId": 1,
  "email": "updated.email@example.com",
  "passwordHash": "[HIDDEN]",
  "createdAt": "2025-09-06T10:30:00Z"
}
```

**404 Not Found**
```json
{
  "error": "User not found",
  "details": "No user exists with ID: 1"
}
```

**400 Bad Request**
```json
{
  "error": "Validation failed",
  "details": {
    "email": ["Email format is invalid"],
    "password": ["Password must be at least 8 characters long"]
  }
}
```

**409 Conflict**
```json
{
  "error": "Email already exists",
  "details": "Another user with this email address already exists"
}
```

---

### 5. Delete User
**DELETE** `/api/users/{id}`

Permanently removes a user from the system.

#### Request
```http
DELETE /api/users/1 HTTP/1.1
Host: localhost:5000
```

#### Path Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | integer | Yes | Unique user identifier |

#### Response
**204 No Content**
```
(Empty response body)
```

**404 Not Found**
```json
{
  "error": "User not found",
  "details": "No user exists with ID: 1"
}
```

**400 Bad Request**
```json
{
  "error": "Invalid user ID",
  "details": "User ID must be a positive integer"
}
```

---

## HTTP Status Codes

| Status Code | Meaning | Usage |
|-------------|---------|--------|
| `200 OK` | Success | GET, PUT operations successful |
| `201 Created` | Resource created | POST operations successful |
| `204 No Content` | Success, no content | DELETE operations successful |
| `400 Bad Request` | Client error | Invalid request data or parameters |
| `404 Not Found` | Resource not found | Requested user doesn't exist |
| `409 Conflict` | Resource conflict | Email already exists |
| `500 Internal Server Error` | Server error | Database or system errors |

---

## Error Response Format

All error responses follow a consistent format:

```json
{
  "error": "Brief error description",
  "details": "Detailed error information or validation errors",
  "timestamp": "2025-09-06T12:00:00Z",
  "path": "/api/users/1"
}
```

---

## Rate Limiting
*Note: Rate limiting will be implemented in future versions for production deployment.*

---

## Testing

### Sample cURL Commands

**Get all users:**
```bash
curl -X GET http://localhost:5000/api/users \
  -H "Accept: application/json"
```

**Create new user:**
```bash
curl -X POST http://localhost:5000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpassword123"
  }'
```

**Update user:**
```bash
curl -X PUT http://localhost:5000/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newemail@example.com"
  }'
```

**Delete user:**
```bash
curl -X DELETE http://localhost:5000/api/users/1
```

---

**Last Updated**: 2025-09-06  
**API Version**: 1.0  
**Documentation Version**: 1.0