-- =============================================
-- SEED DATA with Real User IDs
-- =============================================

-- Seed Workspaces
INSERT INTO workspaces (id, name) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Acme Corporation'),
  ('22222222-2222-2222-2222-222222222222', 'Tech Startup Inc');

-- Seed Workspace Members
-- User 1 (9cae23fb-6617-4918-a0ac-1dc0a7a77002) is owner of workspace 1, member of workspace 2
-- User 2 (8ed0d2a1-58d3-4d61-bc65-269eadd078bc) is owner of workspace 2, member of workspace 1
INSERT INTO workspace_members (workspace_id, user_id, role) VALUES
  ('11111111-1111-1111-1111-111111111111', '9cae23fb-6617-4918-a0ac-1dc0a7a77002', 'owner'),
  ('11111111-1111-1111-1111-111111111111', '8ed0d2a1-58d3-4d61-bc65-269eadd078bc', 'member'),
  ('22222222-2222-2222-2222-222222222222', '8ed0d2a1-58d3-4d61-bc65-269eadd078bc', 'owner'),
  ('22222222-2222-2222-2222-222222222222', '9cae23fb-6617-4918-a0ac-1dc0a7a77002', 'member');

-- Seed Projects
INSERT INTO projects (id, workspace_id, name) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Website Redesign'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'Mobile App Development'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '22222222-2222-2222-2222-222222222222', 'Marketing Campaign'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', '22222222-2222-2222-2222-222222222222', 'Product Launch');

-- Seed Tasks (15 tasks across different projects and statuses)
INSERT INTO tasks (project_id, title, description, status, assignee_id, due_date) VALUES
  -- Website Redesign tasks
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Design homepage mockup', 'Create initial design concepts for the new homepage', 'done', '9cae23fb-6617-4918-a0ac-1dc0a7a77002', NOW() - INTERVAL '5 days'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Implement responsive navigation', 'Build mobile-friendly navigation component', 'in_progress', '8ed0d2a1-58d3-4d61-bc65-269eadd078bc', NOW() + INTERVAL '3 days'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Setup CI/CD pipeline', 'Configure automated deployment workflow', 'todo', '9cae23fb-6617-4918-a0ac-1dc0a7a77002', NOW() + INTERVAL '7 days'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Write unit tests', 'Add test coverage for core components', 'todo', NULL, NOW() + INTERVAL '10 days'),
  
  -- Mobile App Development tasks
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Setup React Native project', 'Initialize app with required dependencies', 'done', '8ed0d2a1-58d3-4d61-bc65-269eadd078bc', NOW() - INTERVAL '10 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Implement authentication flow', 'Add login and signup screens', 'in_progress', '9cae23fb-6617-4918-a0ac-1dc0a7a77002', NOW() + INTERVAL '2 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Design app icon and splash screen', 'Create branding assets for mobile', 'todo', '8ed0d2a1-58d3-4d61-bc65-269eadd078bc', NOW() + INTERVAL '5 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Integrate push notifications', 'Setup Firebase Cloud Messaging', 'todo', NULL, NOW() + INTERVAL '14 days'),
  
  -- Marketing Campaign tasks
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Define target audience', 'Research and document ideal customer profile', 'done', '8ed0d2a1-58d3-4d61-bc65-269eadd078bc', NOW() - INTERVAL '15 days'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Create social media content', 'Design posts for Instagram and LinkedIn', 'in_progress', '9cae23fb-6617-4918-a0ac-1dc0a7a77002', NOW() + INTERVAL '1 day'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Launch email campaign', 'Send newsletter to subscriber list', 'todo', '8ed0d2a1-58d3-4d61-bc65-269eadd078bc', NOW() + INTERVAL '4 days'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Analyze campaign metrics', 'Review performance data and ROI', 'todo', NULL, NOW() - INTERVAL '2 days'),
  
  -- Product Launch tasks
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Finalize product features', 'Complete feature freeze and documentation', 'done', '9cae23fb-6617-4918-a0ac-1dc0a7a77002', NOW() - INTERVAL '20 days'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Conduct beta testing', 'Run user acceptance tests with pilot group', 'in_progress', '8ed0d2a1-58d3-4d61-bc65-269eadd078bc', NOW() + INTERVAL '6 days'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Prepare launch announcement', 'Write press release and blog post', 'todo', '9cae23fb-6617-4918-a0ac-1dc0a7a77002', NOW() - INTERVAL '1 day');
