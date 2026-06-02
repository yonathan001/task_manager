import { createClient } from '@/lib/supabase/server';
import { redirect } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { signout } from '@/app/actions/auth';
import { TaskList } from '@/components/project/task-list';
import { TaskFilters } from '@/components/project/task-filters';
import { OverdueTasksButton } from '@/components/project/overdue-tasks-button';

interface ProjectPageProps {
  params: Promise<{ projectId: string }>;
  searchParams: Promise<{ status?: string; assignee?: string }>;
}

async function getProjectData(projectId: string) {
  const supabase = await createClient();
  
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: project, error: projectError } = await supabase
    .from('projects')
    .select(`
      id,
      name,
      workspace_id,
      workspaces!inner(id, name)
    `)
    .eq('id', projectId)
    .single();

  if (projectError || !project) redirect('/');

  const { data: tasks, error: tasksError } = await supabase
    .from('tasks')
    .select('*')
    .eq('project_id', projectId)
    .order('created_at', { ascending: false });

  if (tasksError) throw tasksError;

  return { project, tasks: tasks || [], user, workspaceId: project.workspace_id };
}

export default async function ProjectPage({ params, searchParams }: ProjectPageProps) {
  const { projectId } = await params;
  const filters = await searchParams;
  const { project, tasks, user, workspaceId } = await getProjectData(projectId);

  return (
    <div className="min-h-screen bg-slate-50">
      <header className="bg-white border-b border-slate-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center gap-4">
              <Link href={`/workspace/${workspaceId}`} className="text-blue-600 hover:text-blue-700 text-sm font-medium">
                ← Back to {project.workspaces.name}
              </Link>
              <h1 className="text-xl font-bold text-slate-900">{project.name}</h1>
            </div>
            <div className="flex items-center gap-4">
              <span className="text-sm text-slate-600">{user.email}</span>
              <form action={signout}>
                <Button type="submit" variant="outline" size="sm">
                  Sign out
                </Button>
              </form>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-6 flex justify-between items-start">
          <TaskFilters currentFilters={filters} />
          <OverdueTasksButton projectId={projectId} />
        </div>

        <TaskList projectId={projectId} initialTasks={tasks} filters={filters} />
      </main>
    </div>
  );
}
