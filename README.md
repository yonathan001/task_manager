# Task Manager - Multi-Workspace Task Management

A production-grade task management application built with Next.js, TypeScript, Supabase, and Vercel.

## Timeline

**Start Time:** [INSERT YOUR START TIME HERE - Date, Time, Timezone]  
**End Time:** [INSERT YOUR END TIME HERE - Date, Time, Timezone]

## What's Complete and Working

### Core Requirements ✅

1. **Authentication (R1-R2)**
   - Sign up, sign in, sign out via Supabase Auth
   - Proper SSR client pattern implementation
   - Middleware for auth protection

2. **Database Schema with RLS (R1)**
   - Complete schema with all 4 tables (workspaces, workspace_members, projects, tasks)
   - Row Level Security policies for ALL 4 operations (SELECT, INSERT, UPDATE, DELETE) on every table
   - Workspace isolation enforced via workspace_members table
   - Auto-generated TypeScript types from Supabase schema

3. **Realtime Updates (R3)**
   - Task updates sync immediately across all connected users
   - Supabase channels with proper cleanup on unmount
   - Filtered subscriptions by project_id

4. **URL-Based Filtering (R4)**
   - Filter by status (todo/in_progress/done)
   - Filter by assignee (assigned/unassigned)
   - Multiple filters work simultaneously
   - Shareable URLs restore exact filter state
   - No component state used for filters

5. **Inline Editing (R5)**
   - All task fields editable inline (title, description, status, due_date)
   - Clear save/cancel affordances
   - Intentional UX with proper styling

6. **Loading/Empty/Error States (R6)**
   - Skeleton loaders for async data
   - Empty states with CTAs
   - Error messages displayed properly
   - No blank screens

7. **Optimistic UI (R7) - BONUS**
   - Status changes update immediately
   - Rollback on failure with user-visible feedback
   - Toast notification for 3 seconds on error

8. **Edge Function (R8) - BONUS**
   - `/supabase/functions/get-overdue-tasks/index.ts`
   - Accepts project_id and returns overdue tasks
   - RLS enforced via user's JWT token
   - UI button triggers function and displays results

### Technical Standards ✅

- **Zero `any` types** - All types explicit throughout
- **TypeScript strict mode** - Generated types from Supabase used everywhere
- **ESLint passing** - No errors
- **Progressive Git commits** - Multiple meaningful commits showing development flow
- **Environment variables** - `.env.example` provided

### Screens Implemented ✅

1. Authentication (Sign up/Sign in)
2. Workspace Dashboard (with project overview and task counts)
3. Project View (task list with filters)
4. Task Detail (inline editing panel)

## How to Run Locally

### Prerequisites
- Node.js 18+ installed
- A Supabase account and project

### Setup Instructions (5 commands)

1. **Clone and install dependencies**
```bash
npm install
```

2. **Set up environment variables**
```bash
cp .env.example .env.local
# Edit .env.local and add your Supabase URL and Anon Key
```

3. **Run the schema in your Supabase project**
   - Go to Supabase Dashboard → SQL Editor
   - Copy and paste the entire contents of `schema.sql`
   - Run the SQL (includes seed data with 2 workspaces, 4 projects, 15 tasks)

4. **Update seed data user IDs (Important!)**
   - Create 2 test users via Supabase Auth UI or sign up page
   - Copy their user IDs from Supabase Auth → Users
   - Replace placeholder UUIDs in the `workspace_members` table in your Supabase dashboard

5. **Start development server**
```bash
npm run dev
```

Visit `http://localhost:3000` and sign in with your test user.

### Deploy Edge Function (Optional)
```bash
npx supabase functions deploy get-overdue-tasks
```

## Architecture Decisions

### What I'd Keep
1. **Supabase SSR Pattern** - Properly implemented for server/client components
2. **URL-based filtering** - Clean, shareable, and persistent
3. **Realtime subscriptions** - Scoped to specific projects, not global
4. **Optimistic UI** - Immediate feedback with proper rollback

### What I'd Change With More Time
1. **User Profiles Table** - Currently using auth.users directly; would create profiles table for assignee names
2. **Batch Operations** - Add ability to update multiple tasks at once
3. **Task Creation UI** - Currently only seed data; need create/delete task forms
4. **Workspace Switcher** - Add a dropdown in header for quick workspace switching
5. **Advanced Filters** - Date ranges, multiple assignee selection, search
6. **Tests** - Unit tests for utils, E2E tests for critical flows
7. **Error Boundaries** - React error boundaries for better error isolation
8. **Loading States** - More granular loading states per operation

## Known Issues

1. **Assignee Display** - Shows assignee_id instead of name (needs profiles table or join)
2. **No Task Creation** - Can only edit existing seeded tasks
3. **No Workspace Creation** - UI placeholder exists but not implemented
4. **Mobile Responsiveness** - Basic responsive layout but could be optimized
5. **Edge Function URL** - Hardcoded to use NEXT_PUBLIC_SUPABASE_URL (needs deployment)

## Technical Highlights

- **Zero `any` Types** - Fully typed with generated Supabase types
- **RLS Security** - All 4 CRUD operations protected on all tables
- **Server Components** - Data fetched on server where possible
- **Optimistic Updates** - With automatic rollback and user feedback
- **Realtime Sync** - Tasks update across users in real-time
- **Clean Architecture** - Proper separation of concerns

## Project Structure

```
task-manager/
├── app/
│   ├── actions/          # Server actions (auth)
│   ├── login/            # Login page
│   ├── signup/           # Signup page
│   ├── workspace/        # Workspace detail pages
│   ├── project/          # Project detail pages
│   └── page.tsx          # Homepage (workspace list)
├── components/
│   ├── ui/               # Reusable UI components
│   ├── workspace/        # Workspace-specific components
│   └── project/          # Project/task components
├── lib/
│   ├── supabase/         # Supabase client utilities
│   └── utils.ts          # Helper functions
├── supabase/
│   └── functions/        # Edge functions
├── types/
│   └── database.ts       # Generated Supabase types
└── schema.sql            # Database schema with RLS and seed data
```

## Security Notes

- All RLS policies enforce workspace membership
- No service role key exposed in client code
- User JWT passed to Edge Function for RLS enforcement
- Middleware protects all authenticated routes

## Dependencies

- **Next.js 15** - App Router for Server Components
- **TypeScript** - Full type safety
- **Supabase** - Database, Auth, Realtime, Edge Functions
- **Tailwind CSS** - Utility-first styling
- **Radix UI** - Accessible component primitives

---

Built as a take-home assignment demonstrating production-grade full-stack development with strict TypeScript, comprehensive RLS, realtime features, and modern React patterns.
