import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import Link from 'next/link';
import { signout } from './actions/auth';
import { CardSkeleton } from '@/components/ui/loading';
import { EmptyState } from '@/components/ui/empty-state';
import { Button } from '@/components/ui/button';
import { Suspense } from 'react';

async function getWorkspaces() {
  const supabase = await createClient();
  
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    redirect('/login');
  }

  const { data: workspaces, error } = await supabase
    .from('workspaces')
    .select(`
      id,
      name,
      created_at,
      projects:projects(
        id,
        tasks:tasks(id, status)
      )
    `)
    .order('created_at', { ascending: false });

  if (error) throw error;

  return { workspaces, user };
}

async function WorkspaceList() {
  const { workspaces, user } = await getWorkspaces();

  if (!workspaces || workspaces.length === 0) {
    return (
      <EmptyState
        title="No workspaces yet"
        description="Create your first workspace to start organizing your projects and tasks"
        action={
          <Button>Create Workspace</Button>
        }
      />
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {workspaces.map((workspace) => {
        const totalTasks = workspace.projects?.reduce(
          (acc, project) => acc + (project.tasks?.length || 0),
          0
        ) || 0;
        
        const tasksByStatus = workspace.projects?.reduce(
          (acc, project) => {
            project.tasks?.forEach((task) => {
              acc[task.status] = (acc[task.status] || 0) + 1;
            });
            return acc;
          },
          {} as Record<string, number>
        ) || {};

        return (
          <Link
            key={workspace.id}
            href={`/workspace/${workspace.id}`}
            className="bg-white border border-slate-200 rounded-lg p-6 hover:shadow-md hover:border-blue-300 transition group"
          >
            <h3 className="text-lg font-semibold text-slate-900 group-hover:text-blue-600 transition">
              {workspace.name}
            </h3>
            <p className="text-sm text-slate-600 mt-2">
              {workspace.projects?.length || 0} projects • {totalTasks} tasks
            </p>
            
            <div className="mt-4 flex gap-4 text-sm">
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-slate-400"></div>
                <span className="text-slate-600">{tasksByStatus.todo || 0} To Do</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-yellow-400"></div>
                <span className="text-slate-600">{tasksByStatus.in_progress || 0} In Progress</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-green-500"></div>
                <span className="text-slate-600">{tasksByStatus.done || 0} Done</span>
              </div>
            </div>
          </Link>
        );
      })}
    </div>
  );
}

export default async function HomePage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    redirect('/login');
  }

  return (
    <div className="min-h-screen bg-slate-50">
      <header className="bg-white border-b border-slate-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <h1 className="text-xl font-bold text-slate-900">Task Manager</h1>
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
          <h2 className="text-2xl font-bold text-slate-900">Your Workspaces</h2>
          <p className="text-slate-600 mt-1">Select a workspace to view projects and tasks</p>
        </div>

        <Suspense fallback={
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <CardSkeleton />
            <CardSkeleton />
            <CardSkeleton />
          </div>
        }>
          <WorkspaceList />
        </Suspense>
      </main>
    </div>
  );
}
