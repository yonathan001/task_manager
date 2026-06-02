import { createClient } from '@/lib/supabase/server';
import { redirect } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { signout } from '@/app/actions/auth';
import { EmptyState } from '@/components/ui/empty-state';

interface WorkspacePageProps {
  params: Promise<{ workspaceId: string }>;
}

async function getWorkspaceData(workspaceId: string) {
  const supabase = await createClient();
  
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: workspace, error: workspaceError } = await supabase
    .from('workspaces')
    .select('id, name')
    .eq('id', workspaceId)
    .single();

  if (workspaceError || !workspace) redirect('/');

  const { data: projects, error: projectsError } = await supabase
    .from('projects')
    .select(`
      id,
      name,
      created_at,
      tasks:tasks(id, status)
    `)
    .eq('workspace_id', workspaceId)
    .order('created_at', { ascending: false });

  if (projectsError) throw projectsError;

  return { workspace, projects: projects || [], user };
}

export default async function WorkspacePage({ params }: WorkspacePageProps) {
  const { workspaceId } = await params;
  const { workspace, projects, user } = await getWorkspaceData(workspaceId);

  return (
    <div className="min-h-screen bg-slate-50">
      <header className="bg-white border-b border-slate-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center gap-4">
              <Link href="/" className="text-blue-600 hover:text-blue-700 text-sm font-medium">
                ← Back
              </Link>
              <h1 className="text-xl font-bold text-slate-900">{workspace.name}</h1>
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
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-slate-900">Projects</h2>
          <p className="text-slate-600 mt-1">Select a project to view and manage tasks</p>
        </div>

        {projects.length === 0 ? (
          <EmptyState
            title="No projects yet"
            description="Create your first project to start organizing tasks"
            action={<Button>Create Project</Button>}
          />
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {projects.map((project) => {
              const tasksByStatus = project.tasks?.reduce(
                (acc, task) => {
                  acc[task.status] = (acc[task.status] || 0) + 1;
                  return acc;
                },
                {} as Record<string, number>
              ) || {};

              const totalTasks = project.tasks?.length || 0;

              return (
                <Link
                  key={project.id}
                  href={`/project/${project.id}`}
                  className="bg-white border border-slate-200 rounded-lg p-6 hover:shadow-md hover:border-blue-300 transition group"
                >
                  <h3 className="text-lg font-semibold text-slate-900 group-hover:text-blue-600 transition">
                    {project.name}
                  </h3>
                  <p className="text-sm text-slate-600 mt-2">{totalTasks} tasks</p>

                  <div className="mt-4 space-y-2">
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-slate-600">To Do</span>
                      <span className="font-medium text-slate-900">{tasksByStatus.todo || 0}</span>
                    </div>
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-slate-600">In Progress</span>
                      <span className="font-medium text-yellow-600">{tasksByStatus.in_progress || 0}</span>
                    </div>
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-slate-600">Done</span>
                      <span className="font-medium text-green-600">{tasksByStatus.done || 0}</span>
                    </div>
                  </div>

                  <div className="mt-4 pt-4 border-t border-slate-100">
                    <div className="w-full bg-slate-100 rounded-full h-2">
                      <div
                        className="bg-green-500 h-2 rounded-full transition-all"
                        style={{
                          width: totalTasks > 0 ? `${((tasksByStatus.done || 0) / totalTasks) * 100}%` : '0%',
                        }}
                      ></div>
                    </div>
                  </div>
                </Link>
              );
            })}
          </div>
        )}
      </main>
    </div>
  );
}
