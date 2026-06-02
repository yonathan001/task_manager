'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Database } from '@/types/database';
import { TaskCard } from './task-card';
import { EmptyState } from '@/components/ui/empty-state';
import { LoadingSpinner } from '@/components/ui/loading';

type Task = Database['public']['Tables']['tasks']['Row'];

interface TaskListProps {
  projectId: string;
  initialTasks: Task[];
  filters: { status?: string; assignee?: string };
}

export function TaskList({ projectId, initialTasks, filters }: TaskListProps): JSX.Element {
  const [tasks, setTasks] = useState<Task[]>(initialTasks);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const supabase = createClient();

  useEffect(() => {
    setTasks(initialTasks);
  }, [initialTasks]);

  useEffect(() => {
    const channel = supabase
      .channel(`project-${projectId}-tasks`)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'tasks',
          filter: `project_id=eq.${projectId}`,
        },
        (payload) => {
          if (payload.eventType === 'INSERT') {
            setTasks((current) => [payload.new as Task, ...current]);
          } else if (payload.eventType === 'UPDATE') {
            setTasks((current) =>
              current.map((task) =>
                task.id === payload.new.id ? (payload.new as Task) : task
              )
            );
          } else if (payload.eventType === 'DELETE') {
            setTasks((current) =>
              current.filter((task) => task.id !== payload.old.id)
            );
          }
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [projectId, supabase]);

  const filteredTasks = tasks.filter((task) => {
    if (filters.status && task.status !== filters.status) return false;
    if (filters.assignee === 'assigned' && !task.assignee_id) return false;
    if (filters.assignee === 'unassigned' && task.assignee_id) return false;
    return true;
  });

  if (loading) {
    return <LoadingSpinner />;
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
        <p className="font-medium">Error loading tasks</p>
        <p className="text-sm mt-1">{error}</p>
      </div>
    );
  }

  if (filteredTasks.length === 0) {
    return (
      <EmptyState
        title={tasks.length === 0 ? 'No tasks yet' : 'No tasks match your filters'}
        description={
          tasks.length === 0
            ? 'Create your first task to get started'
            : 'Try adjusting your filters to see more tasks'
        }
      />
    );
  }

  return (
    <div className="space-y-3">
      {filteredTasks.map((task) => (
        <TaskCard key={task.id} task={task} />
      ))}
    </div>
  );
}
