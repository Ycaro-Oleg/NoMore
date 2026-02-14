# NoMore

## Project Overview

**NoMore** is a web application designed to reduce procrastination through commitment enforcement, loss aversion, and behavioral analytics.

This is NOT a task manager.

It is a behavioral accountability system that creates consequences for inaction.

Core philosophy:
> No more excuses. No more tomorrow. No more procrastination.

The system should feel strict, minimal, and psychologically powerful.

---

# Primary Objective

Build a commitment-based productivity web app where users:

1. Create a commitment (task + deadline).
2. Attach a stake (financial or behavioral).
3. Face automatic consequences if they fail.
4. Gain behavioral insights about avoidance patterns.

The goal is to reduce procrastination by increasing psychological and financial cost of inaction.

---

# Core Product Principles

- Minimal UI
- Strong emotional tone
- No feature bloat
- Focus on commitment enforcement
- Behavioral psychology > productivity fluff
- Friction is intentional

---

# Core Features (MVP)

## 1. User Authentication

- Email/password
- JWT-based session
- Secure authentication

## 2. Commitment Creation

A commitment contains:

- Title
- Optional description
- Category
- Deadline (datetime)
- Stake type:
  - None
  - Streak penalty
  - Monetary stake (future)
- Status:
  - Active
  - Completed
  - Failed

Rules:

- Commitments cannot be edited after deadline passes.
- Deadlines cannot be extended in MVP.
- A background job must monitor deadlines and auto-fail expired commitments.

---

## 3. Commitment Lifecycle

States:

- Active
- Completed (user marks before deadline)
- Failed (auto-triggered after deadline)

If deadline passes and not completed:
→ Automatically mark as FAILED.

---

## 4. Basic Analytics

User dashboard must show:

- Completion rate (%)
- Fail rate
- Current streak
- Total commitments
- Most failed category

Keep analytics simple but meaningful.

---

## 5. Focus Mode (Basic Version)

- User activates focus session.
- Timer starts (Pomodoro-style).
- Session stored in database.
- Session history available.

No browser blocking in MVP.

---

# Future Features (DO NOT BUILD YET)

- Stripe deposit system
- Public accountability pages
- Website blocking extension
- AI behavioral coach
- "Brutal Mode"
- Social sharing

Architecture must allow future extension without major refactor.

---

# Tech Stack (MANDATORY)

Backend:

- Ruby on Rails (API-only mode)
- PostgreSQL
- Sidekiq for background jobs
- Redis (for Sidekiq)

Frontend:

- Next.js (latest stable)
- TypeScript
- TailwindCSS
- ShadCN UI (or similar component library)

Authentication:

- JWT-based aut- Secure password hashing

Deployment:

- Dockerized
- Ready for deployment on:
  - Fly.io or Render (backend)
  - Vercel (frontend)

Payments (future-ready):

- Stripe integration prepared but not implemented

---

# Architecture Requirements

- Clean REST API structure
- Proper service objects (no fat controllers)
- Background job to monitor expired commitments
- Environment-based config
- .env setup
- Docker support
- Scalable structure
- Proper DB indexing on deadline + user_id

---

# Database Core Models

User:

- id
- email
- password_digest
- created_at

Commitment:

- id
- user_id
- title
- description
- category
- deadline (datetime)
- status (enum: active, completed, failed)
- created_at

FocusSession:

- id
- user_id
- started_at
- ended_at
- duration_seconds

---

# Tone & UX Direction

UI tone should feel:

- Direct
- Serious
- Slightly confrontational
- Minimalist (dark mode default)

Examples of system messages:

Instead of:
"Task completed"

Use:
"You did what you said you would."

Instead of:
"You missed deadline"

Use:
"You chose comfort."

---

# Constraints

- No overengineering.
- Keep MVP buildable in under 2 weeks.
- Clean code > clever code.
- Avoid premature microservices.
- Single Rails API + single Next frontend.

---

# Deliverables Expected From Claude

- Backend scaffold
- Database migrations
- Model definitions
- API routes
- Controller logic
- Background job implementation
- Frontend pages
- API integration
- Basic dashboard UI
- Docker configuration
- README with setup instructions

Claude is responsible for implementation details.

---

# Success Criteria

The app must:

- Allow user to create commitments
- Automatically fail expired commitments
- Show dashboard stats
- Support focus sessions
- Be production-ready deployable

---

# Positioning

NoMore is not for organized people.

It is for people who:

- Know what to do
- But keep delaying it

It adds consequences to intention.
