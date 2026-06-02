-- Grant necessary permissions to authenticated users on all tables

-- Workspaces table
GRANT SELECT, INSERT, UPDATE, DELETE ON public.workspaces TO authenticated;

-- Workspace members table
GRANT SELECT, INSERT, UPDATE, DELETE ON public.workspace_members TO authenticated;

-- Projects table
GRANT SELECT, INSERT, UPDATE, DELETE ON public.projects TO authenticated;

-- Tasks table
GRANT SELECT, INSERT, UPDATE, DELETE ON public.tasks TO authenticated;

-- Grant usage on sequences (for auto-incrementing IDs if needed)
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;
