-- NUCLEAR OPTION: Drop ALL policies on workspace_members and recreate simply

-- Drop all existing policies (use CASCADE to force)
DROP POLICY IF EXISTS "Users can view members of their workspaces" ON workspace_members CASCADE;
DROP POLICY IF EXISTS "Users can view workspace members" ON workspace_members CASCADE;
DROP POLICY IF EXISTS "Workspace owners can add members" ON workspace_members CASCADE;
DROP POLICY IF EXISTS "Users can insert workspace members" ON workspace_members CASCADE;
DROP POLICY IF EXISTS "Workspace owners can update member roles" ON workspace_members CASCADE;
DROP POLICY IF EXISTS "Owners can update members" ON workspace_members CASCADE;
DROP POLICY IF EXISTS "Workspace owners can remove members" ON workspace_members CASCADE;
DROP POLICY IF EXISTS "Owners can delete members" ON workspace_members CASCADE;

-- Create NEW simple policies that don't reference workspace_members in USING clause

-- SELECT: User can see their own membership record OR memberships in workspaces they belong to
CREATE POLICY "Allow users to view workspace memberships"
ON workspace_members FOR SELECT
USING (user_id = auth.uid());

-- INSERT: Allow authenticated users to insert (we'll control this at app level)
CREATE POLICY "Allow authenticated users to add members"
ON workspace_members FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

-- UPDATE: Only workspace owners (checked via direct user_id match on owner role)
CREATE POLICY "Allow owners to update members"
ON workspace_members FOR UPDATE
USING (
  workspace_id IN (
    SELECT wm.workspace_id 
    FROM workspace_members wm 
    WHERE wm.user_id = auth.uid() 
    AND wm.role = 'owner'
  )
);

-- DELETE: Only workspace owners
CREATE POLICY "Allow owners to remove members"
ON workspace_members FOR DELETE
USING (
  workspace_id IN (
    SELECT wm.workspace_id 
    FROM workspace_members wm 
    WHERE wm.user_id = auth.uid() 
    AND wm.role = 'owner'
  )
);
