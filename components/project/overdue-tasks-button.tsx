'use client';

import { useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Button } from '@/components/ui/button';

interface OverdueTask {
  id: string;
  title: string;
  description: string | null;
  due_date: string;
  status: string;
  assignee_id: string | null;
}

interface OverdueTasksButtonProps {
  projectId: string;
}

export function OverdueTasksButton({ projectId }: OverdueTasksButtonProps): JSX.Element {
  const [loading, setLoading] = useState<boolean>(false);
  const [overdueTasks, setOverdueTasks] = useState<OverdueTask[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const supabase = createClient();

  async function fetchOverdueTasks(): Promise<void> {
    setLoading(true);
    setError(null);

    try {
      const { data: { session } } = await supabase.auth.getSession();
      
      if (!session) {
        setError('Not authenticated');
        return;
      }

      const response = await fetch(
        `${process.env.NEXT_PUBLIC_SUPABASE_URL}/functions/v1/get-overdue-tasks`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${session.access_token}`,
          },
          body: JSON.stringify({ projectId }),
        }
      );

      if (!response.ok) {
        throw new Error(`Failed to fetch: ${response.statusText}`);
      }

      const result = await response.json();
      setOverdueTasks(result.overdueTasks);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="space-y-4">
      <Button
        onClick={fetchOverdueTasks}
        disabled={loading}
        variant="outline"
        size="sm"
      >
        {loading ? 'Loading...' : 'Check Overdue Tasks'}
      </Button>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
          {error}
        </div>
      )}

      {overdueTasks && (
        <div className="bg-white border border-slate-200 rounded-lg p-4">
          <h3 className="font-semibold text-slate-900 mb-3">
            Overdue Tasks ({overdueTasks.length})
          </h3>
          {overdueTasks.length === 0 ? (
            <p className="text-slate-600 text-sm">No overdue tasks</p>
          ) : (
            <ul className="space-y-2">
              {overdueTasks.map((task) => (
                <li key={task.id} className="text-sm border-l-4 border-red-400 pl-3 py-1">
                  <p className="font-medium text-slate-900">{task.title}</p>
                  <p className="text-slate-600">
                    Due: {new Date(task.due_date).toLocaleDateString()}
                  </p>
                </li>
              ))}
            </ul>
          )}
        </div>
      )}
    </div>
  );
}
