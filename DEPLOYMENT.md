# Deployment Guide

## Prerequisites

1. **Supabase Project**
   - Create a project at [supabase.com](https://supabase.com)
   - Note your project URL and anon key

2. **Vercel Account**
   - Create an account at [vercel.com](https://vercel.com)
   - Install Vercel CLI: `npm i -g vercel`

## Step 1: Set Up Supabase Database

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy the entire contents of `schema.sql`
4. Paste and execute the SQL

This will:
- Create all tables with proper relationships
- Set up RLS policies for all operations
- Enable realtime for tasks table
- Insert seed data (2 workspaces, 4 projects, 15 tasks)

## Step 2: Update Seed Data User IDs

The seed data uses placeholder user IDs. You need to replace them with real user IDs:

1. Create 2 test users:
   - Go to Authentication → Users → Add User
   - Or use your signup page after deployment
   
2. Copy the user IDs from the Users list

3. Update the `workspace_members` table:
   ```sql
   UPDATE workspace_members 
   SET user_id = 'YOUR_FIRST_USER_ID' 
   WHERE user_id = '00000000-0000-0000-0000-000000000001';
   
   UPDATE workspace_members 
   SET user_id = 'YOUR_SECOND_USER_ID' 
   WHERE user_id = '00000000-0000-0000-0000-000000000002';
   
   UPDATE tasks 
   SET assignee_id = 'YOUR_FIRST_USER_ID' 
   WHERE assignee_id = '00000000-0000-0000-0000-000000000001';
   
   UPDATE tasks 
   SET assignee_id = 'YOUR_SECOND_USER_ID' 
   WHERE assignee_id = '00000000-0000-0000-0000-000000000002';
   ```

## Step 3: Deploy Edge Function

1. Install Supabase CLI:
   ```bash
   npm install -g supabase
   ```

2. Login to Supabase:
   ```bash
   supabase login
   ```

3. Link your project:
   ```bash
   supabase link --project-ref YOUR_PROJECT_REF
   ```

4. Deploy the Edge Function:
   ```bash
   supabase functions deploy get-overdue-tasks
   ```

## Step 4: Deploy to Vercel

### Option 1: Via Vercel Dashboard

1. Go to [vercel.com/new](https://vercel.com/new)
2. Import your GitHub repository
3. Add environment variables:
   - `NEXT_PUBLIC_SUPABASE_URL`: Your Supabase project URL
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`: Your Supabase anon key
4. Deploy

### Option 2: Via CLI

1. From the project root:
   ```bash
   vercel
   ```

2. Follow the prompts

3. Add environment variables:
   ```bash
   vercel env add NEXT_PUBLIC_SUPABASE_URL
   vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY
   ```

4. Redeploy:
   ```bash
   vercel --prod
   ```

## Step 5: Test RLS Security

To verify RLS is working correctly:

1. Sign up as User A
2. Create or view tasks in a workspace
3. Note the workspace/project IDs from the URL
4. Sign out and sign up as User B
5. Try to access User A's URLs directly
6. You should NOT see User A's data unless User B is also a member of that workspace

## Troubleshooting

### Build Fails

- Ensure all environment variables are set
- Check that Supabase project is accessible
- Verify schema was executed successfully

### Auth Not Working

- Check Supabase URL and anon key are correct
- Verify email confirmation settings in Supabase Auth settings
- Check browser console for errors

### Realtime Not Working

- Verify realtime is enabled in Supabase settings
- Check that `ALTER PUBLICATION` was executed in schema.sql
- Ensure tasks table has realtime enabled

### Edge Function Errors

- Verify function was deployed: `supabase functions list`
- Check function logs: `supabase functions logs get-overdue-tasks`
- Ensure CORS headers are properly set

## Post-Deployment Checklist

- [ ] Can sign up new users
- [ ] Can sign in with test users
- [ ] Can view workspaces
- [ ] Can view projects
- [ ] Can view tasks
- [ ] Can edit tasks inline
- [ ] Tasks update in realtime
- [ ] Filters work and persist in URL
- [ ] Overdue tasks button returns data
- [ ] Cannot access other users' workspaces
- [ ] RLS prevents cross-workspace data leaks

## Environment Variables Reference

```bash
# Public (safe to expose in client)
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here

# Note: Service role key should NEVER be used in client-side code
# The anon key is protected by RLS policies
```
