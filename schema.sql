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

-- =============================================
-- SEED DATA
-- =============================================

-- Insert test user IDs (you'll need to replace these with actual user IDs from Supabase Auth)
-- For now, using placeholder UUIDs that you'll update after creating auth users

-- Seed Workspaces
INSERT INTO workspaces (id, name) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Acme Corporation'),
  ('22222222-2222-2222-2222-222222222222', 'Tech Startup Inc');

-- Seed Workspace Members (update user_id values after auth setup)
-- User 1 will be owner of workspace 1, member of workspace 2
-- User 2 will be owner of workspace 2, member of workspace 1
INSERT INTO workspace_members (workspace_id, user_id, role) VALUES
  ('11111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000001', 'owner'),
  ('11111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000002', 'member'),
  ('22222222-2222-2222-2222-222222222222', '00000000-0000-0000-0000-000000000002', 'owner'),
  ('22222222-2222-2222-2222-222222222222', '00000000-0000-0000-0000-000000000001', 'member');

-- Seed Projects
INSERT INTO projects (id, workspace_id, name) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Website Redesign'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'Mobile App Development'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '22222222-2222-2222-2222-222222222222', 'Marketing Campaign'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', '22222222-2222-2222-2222-222222222222', 'Product Launch');

-- Seed Tasks (15 tasks across different projects and statuses)
INSERT INTO tasks (project_id, title, description, status, assignee_id, due_date) VALUES
  -- Website Redesign tasks
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Design homepage mockup', 'Create initial design concepts for the new homepage', 'done', '00000000-0000-0000-0000-000000000001', NOW() - INTERVAL '5 days'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Implement responsive navigation', 'Build mobile-friendly navigation component', 'in_progress', '00000000-0000-0000-0000-000000000002', NOW() + INTERVAL '3 days'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Setup CI/CD pipeline', 'Configure automated deployment workflow', 'todo', '00000000-0000-0000-0000-000000000001', NOW() + INTERVAL '7 days'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Write unit tests', 'Add test coverage for core components', 'todo', NULL, NOW() + INTERVAL '10 days'),
  
  -- Mobile App Development tasks
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Setup React Native project', 'Initialize app with required dependencies', 'done', '00000000-0000-0000-0000-000000000002', NOW() - INTERVAL '10 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Implement authentication flow', 'Add login and signup screens', 'in_progress', '00000000-0000-0000-0000-000000000001', NOW() + INTERVAL '2 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Design app icon and splash screen', 'Create branding assets for mobile', 'todo', '00000000-0000-0000-0000-000000000002', NOW() + INTERVAL '5 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Integrate push notifications', 'Setup Firebase Cloud Messaging', 'todo', NULL, NOW() + INTERVAL '14 days'),
  
  -- Marketing Campaign tasks
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Define target audience', 'Research and document ideal customer profile', 'done', '00000000-0000-0000-0000-000000000002', NOW() - INTERVAL '15 days'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Create social media content', 'Design posts for Instagram and LinkedIn', 'in_progress', '00000000-0000-0000-0000-000000000001', NOW() + INTERVAL '1 day'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Launch email campaign', 'Send newsletter to subscriber list', 'todo', '00000000-0000-0000-0000-000000000002', NOW() + INTERVAL '4 days'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Analyze campaign metrics', 'Review performance data and ROI', 'todo', NULL, NOW() - INTERVAL '2 days'),
  
  -- Product Launch tasks
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Finalize product features', 'Complete feature freeze and documentation', 'done', '00000000-0000-0000-0000-000000000001', NOW() - INTERVAL '20 days'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Conduct beta testing', 'Run user acceptance tests with pilot group', 'in_progress', '00000000-0000-0000-0000-000000000002', NOW() + INTERVAL '6 days'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Prepare launch announcement', 'Write press release and blog post', 'todo', '00000000-0000-0000-0000-000000000001', NOW() - INTERVAL '1 day');

-- Enable Realtime for tasks table
ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
