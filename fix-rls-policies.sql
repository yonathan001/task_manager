-- Fix infinite recursion in workspace_members RLS policies

-- Drop the problematic SELECT policy
DROP POLICY IF EXISTS "Users can view members of their workspaces" ON workspace_members;

-- Create a simpler, non-recursive SELECT policy
CREATE POLICY "Users can view members of their workspaces"
ON workspace_members FOR SELECT
USING (
  workspace_id IN (
    SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
  )
);

-- Drop and recreate INSERT policy
DROP POLICY IF EXISTS "Workspace owners can add members" ON workspace_members;

CREATE POLICY "Workspace owners can add members"
ON workspace_members FOR INSERT
WITH CHECK (
  -- Allow if user is owner of the workspace
  EXISTS (
    SELECT 1 FROM workspace_members wm
    WHERE wm.workspace_id = workspace_members.workspace_id
    AND wm.user_id = auth.uid()
    AND wm.role = 'owner'
  )
  OR
  -- Allow first member (for new workspace creation)
  NOT EXISTS (
    SELECT 1 FROM workspace_members wm
    WHERE wm.workspace_id = workspace_members.workspace_id
  )
);
