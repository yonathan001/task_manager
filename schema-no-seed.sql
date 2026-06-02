-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
CREATE TYPE user_role AS ENUM ('owner', 'member');
CREATE TYPE task_status AS ENUM ('todo', 'in_progress', 'done');

-- Workspaces table
CREATE TABLE workspaces (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workspace members table (critical for RLS)
CREATE TABLE workspace_members (
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role user_role NOT NULL DEFAULT 'member',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (workspace_id, user_id)
);

-- Projects table
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks table
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  status task_status NOT NULL DEFAULT 'todo',
  assignee_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  due_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security on all tables
ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE workspace_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- =============================================
-- RLS POLICIES FOR WORKSPACES
-- =============================================

-- Workspaces: SELECT
CREATE POLICY "Users can view workspaces they are members of"
ON workspaces FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM workspace_members
    WHERE workspace_members.workspace_id = workspaces.id
    AND workspace_members.user_id = auth.uid()
  )
);

-- Workspaces: INSERT
CREATE POLICY "Authenticated users can create workspaces"
ON workspaces FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

-- Workspaces: UPDATE
CREATE POLICY "Workspace owners can update workspaces"
ON workspaces FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM workspace_members
    WHERE workspace_members.workspace_id = workspaces.id
    AND workspace_members.user_id = auth.uid()
    AND workspace_members.role = 'owner'
  )
);

-- Workspaces: DELETE
CREATE POLICY "Workspace owners can delete workspaces"
ON workspaces FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM workspace_members
    WHERE workspace_members.workspace_id = workspaces.id
    AND workspace_members.user_id = auth.uid()
    AND workspace_members.role = 'owner'
  )
);

-- =============================================
-- RLS POLICIES FOR WORKSPACE_MEMBERS
-- =============================================

-- Workspace Members: SELECT
CREATE POLICY "Users can view members of their workspaces"
ON workspace_members FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM workspace_members wm
    WHERE wm.workspace_id = workspace_members.workspace_id
    AND wm.user_id = auth.uid()
  )
);

-- Workspace Members: INSERT
CREATE POLICY "Workspace owners can add members"
ON workspace_members FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM workspace_members
    WHERE workspace_members.workspace_id = workspace_members.workspace_id
    AND workspace_members.user_id = auth.uid()
    AND workspace_members.role = 'owner'
  )
  OR NOT EXISTS (
    SELECT 1 FROM workspace_members
    WHERE workspace_members.workspace_id = workspace_members.workspace_id
  )
);

-- Workspace Members: UPDATE
CREATE POLICY "Workspace owners can update member roles"
ON workspace_members FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM workspace_members wm
    WHERE wm.workspace_id = workspace_members.workspace_id
    AND wm.user_id = auth.uid()
    AND wm.role = 'owner'
  )
);

-- Workspace Members: DELETE
CREATE POLICY "Workspace owners can remove members"
ON workspace_members FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM workspace_members wm
    WHERE wm.workspace_id = workspace_members.workspace_id
    AND wm.user_id = auth.uid()
    AND wm.role = 'owner'
  )
);

-- =============================================
-- RLS POLICIES FOR PROJECTS
-- =============================================

-- Projects: SELECT
CREATE POLICY "Users can view projects in their workspaces"
ON projects FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM workspace_members
    WHERE workspace_members.workspace_id = projects.workspace_id
    AND workspace_members.user_id = auth.uid()
  )
);

-- Projects: INSERT
CREATE POLICY "Workspace members can create projects"
ON projects FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM workspace_members
    WHERE workspace_members.workspace_id = projects.workspace_id
    AND workspace_members.user_id = auth.uid()
  )
);

-- Projects: UPDATE
CREATE POLICY "Workspace members can update projects"
ON projects FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM workspace_members
    WHERE workspace_members.workspace_id = projects.workspace_id
    AND workspace_members.user_id = auth.uid()
  )
);

-- Projects: DELETE
CREATE POLICY "Workspace owners can delete projects"
ON projects FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM workspace_members
    WHERE workspace_members.workspace_id = projects.workspace_id
    AND workspace_members.user_id = auth.uid()
    AND workspace_members.role = 'owner'
  )
);

-- =============================================
-- RLS POLICIES FOR TASKS
-- =============================================

-- Tasks: SELECT
CREATE POLICY "Users can view tasks in their workspace projects"
ON tasks FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM projects
    JOIN workspace_members ON workspace_members.workspace_id = projects.workspace_id
    WHERE projects.id = tasks.project_id
    AND workspace_members.user_id = auth.uid()
  )
);

-- Tasks: INSERT
CREATE POLICY "Workspace members can create tasks"
ON tasks FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM projects
    JOIN workspace_members ON workspace_members.workspace_id = projects.workspace_id
    WHERE projects.id = tasks.project_id
    AND workspace_members.user_id = auth.uid()
  )
);

-- Tasks: UPDATE
CREATE POLICY "Workspace members can update tasks"
ON tasks FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM projects
    JOIN workspace_members ON workspace_members.workspace_id = projects.workspace_id
    WHERE projects.id = tasks.project_id
    AND workspace_members.user_id = auth.uid()
  )
);

-- Tasks: DELETE
CREATE POLICY "Workspace members can delete tasks"
ON tasks FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM projects
    JOIN workspace_members ON workspace_members.workspace_id = projects.workspace_id
    WHERE projects.id = tasks.project_id
    AND workspace_members.user_id = auth.uid()
  )
);

-- Enable Realtime for tasks table
ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
