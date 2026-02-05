# Payment Processing System – Local Setup Guide

This repository contains a simple payment processing system composed of two Spring Boot applications:

- **payment-api** — main API handling incoming payment requests, storing them in PostgreSQL, and accepting callbacks from the worker.
- **payment-worker** — worker service responsible for receiving tasks from the API, performing simulated CPU-heavy computations, and sending callbacks back to the API.

The entire system is designed to run locally using Docker and environment variables.

---

# 🧱 1. Components Overview

### **Payment API**
- Receives `/payments` requests
- Saves payment with status `PENDING` into PostgreSQL
- Sends request to worker: `/worker/process`
- Receives callback: `/payments/internal/{id}/complete`
- Updates status to `COMPLETED`
- Returns payment status on `/payments/{id}`

### **Payment Worker**
- Receives task from API
- Logs that it received a payment
- Performs artificial CPU computations based on env variable
- Sends callback to API to mark payment as completed

---

# 🐘 2. Start the PostgreSQL Database (Docker)

- Run PostgreSQL locally:

```powershell

docker run --rm -p 5433:5432 --name payments-db -e POSTGRES_DB=payments -e POSTGRES_USER=payments -e POSTGRES_PASSWORD=payments -e POSTGRES_HOST_AUTH_METHOD=trust postgres:16 

```
--- 

# 🚀 3. Run payment-api ( Without Docker )

```powershell

cd payment-api 
export PAYMENT_DB_URL="jdbc:postgresql://localhost:5433/payments"
export PAYMENT_DB_USER="payments"
export PAYMENT_DB_PASSWORD="payments"
export PAYMENT_WORKER_BASE_URL="http://localhost:8090"
mvn clean package
mvn spring-boot:run


```

--- 

# ⚙️ 4. Run payment-worker ( Without Docker )

```powershell

cd payment-worker
export PAYMENT_WORKER_PORT="8090"
export PAYMENT_API_BASE_URL="http://localhost:8080" 
export WORKER_CPU_LOAD_MS="500"
mvn clean package
mvn spring-boot:run

---  

# 🧪 5. Test the Full Payment Flow

You can test the full API → Worker → API callback flow using **Postman**.

### **Create POST Request**
**URL:**  : http://localhost:8080/payments
**Header:** : Content-Type : application/json
**Body (raw JSON):**
```json
{
    "customerId":"cust-123",
    "amountInCents":1999,
    "currency":"EUR"
}

```

**Output(raw JSON):**
```json
{
    "id": "00cbdb48-882e-4a0c-9997-6994652c0ea7",
    "status": "PENDING"
}
```

### **Create Get Request**
**URL:**  : http://localhost:8080/payments/<your_id>
**Header:** : Content-Type : application/json

**Output(raw JSON):**
```json
{
    "id": "00cbdb48-882e-4a0c-9997-6994652c0ea7",
    "status": "COMPLETED"
}
```

---  

# 📌 6. Required Tools

- Java 17+

- Maven 3+

- Docker

- PowerShell / CMD / Terminal