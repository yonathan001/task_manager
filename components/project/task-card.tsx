'use client';

import { useState } from 'react';
import type { Database } from '@/types/database';
import { createClient } from '@/lib/supabase/client';
import { formatDate, isOverdue } from '@/lib/utils';
import { Button } from '@/components/ui/button';

type Task = Database['public']['Tables']['tasks']['Row'];
type TaskStatus = Database['public']['Enums']['task_status'];

interface TaskCardProps {
  task: Task;
}

export function TaskCard({ task }: TaskCardProps): React.JSX.Element {
  const [isEditing, setIsEditing] = useState<boolean>(false);
  const [editedTask, setEditedTask] = useState<Task>(task);
  const [saving, setSaving] = useState<boolean>(false);
  const [optimisticStatus, setOptimisticStatus] = useState<TaskStatus | null>(null);
  const [previousStatus, setPreviousStatus] = useState<TaskStatus>(task.status);
  const [showRollbackMessage, setShowRollbackMessage] = useState<boolean>(false);
  const supabase = createClient();

  const displayStatus = optimisticStatus || task.status;

  async function handleSave(): Promise<void> {
    setSaving(true);
    
    const { error } = await supabase
      .from('tasks')
      .update({
        title: editedTask.title,
        description: editedTask.description,
        status: editedTask.status,
        due_date: editedTask.due_date,
      })
      .eq('id', task.id);

    if (error) {
      alert('Failed to save: ' + error.message);
    } else {
      setIsEditing(false);
    }
    
    setSaving(false);
  }

  function handleCancel(): void {
    setEditedTask(task);
    setIsEditing(false);
  }

  async function handleStatusChange(newStatus: TaskStatus): Promise<void> {
    setPreviousStatus(task.status);
    setOptimisticStatus(newStatus);
    setShowRollbackMessage(false);
    
    const { error } = await supabase
      .from('tasks')
      .update({ status: newStatus })
      .eq('id', task.id);

    if (error) {
      setOptimisticStatus(previousStatus);
      setShowRollbackMessage(true);
      setTimeout(() => setShowRollbackMessage(false), 3000);
    } else {
      setOptimisticStatus(null);
    }
  }

  const statusColors = {
    todo: 'bg-slate-100 text-slate-700',
    in_progress: 'bg-yellow-100 text-yellow-700',
    done: 'bg-green-100 text-green-700',
  };

  const statusLabels = {
    todo: 'To Do',
    in_progress: 'In Progress',
    done: 'Done',
  };

  return (
    <div className="bg-white border border-slate-200 rounded-lg p-5 hover:border-slate-300 transition">
      {showRollbackMessage && (
        <div className="mb-3 bg-red-50 border border-red-200 text-red-700 px-3 py-2 rounded text-sm">
          Failed to update status. Changes have been reverted.
        </div>
      )}
      
      {isEditing ? (
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Title</label>
            <input
              type="text"
              value={editedTask.title}
              onChange={(e): void => setEditedTask({ ...editedTask, title: e.target.value })}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Description</label>
            <textarea
              value={editedTask.description || ''}
              onChange={(e): void => setEditedTask({ ...editedTask, description: e.target.value })}
              rows={3}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none resize-none"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Status</label>
              <select
                value={editedTask.status}
                onChange={(e): void => setEditedTask({ ...editedTask, status: e.target.value as TaskStatus })}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
              >
                <option value="todo">To Do</option>
                <option value="in_progress">In Progress</option>
                <option value="done">Done</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Due Date</label>
              <input
                type="date"
                value={editedTask.due_date ? editedTask.due_date.split('T')[0] : ''}
                onChange={(e): void => {
                  const dateValue = e.target.value ? new Date(e.target.value).toISOString() : null;
                  setEditedTask({ ...editedTask, due_date: dateValue });
                }}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
              />
            </div>
          </div>

          <div className="flex gap-2 pt-2">
            <Button onClick={handleSave} disabled={saving} size="sm">
              {saving ? 'Saving...' : 'Save'}
            </Button>
            <Button onClick={handleCancel} variant="outline" size="sm" disabled={saving}>
              Cancel
            </Button>
          </div>
        </div>
      ) : (
        <div>
          <div className="flex items-start justify-between gap-4 mb-3">
            <div className="flex-1">
              <h3 className="text-lg font-semibold text-slate-900">{task.title}</h3>
              {task.description && (
                <p className="text-slate-600 mt-1 text-sm">{task.description}</p>
              )}
            </div>
            <button
              onClick={(): void => setIsEditing(true)}
              className="text-sm text-blue-600 hover:text-blue-700 font-medium flex-shrink-0"
            >
              Edit
            </button>
          </div>

          <div className="flex flex-wrap items-center gap-3">
            <div className="flex gap-2">
              {(['todo', 'in_progress', 'done'] as TaskStatus[]).map((status) => (
                <button
                  key={status}
                  onClick={(): Promise<void> => handleStatusChange(status)}
                  className={`px-3 py-1 rounded-full text-xs font-medium transition ${
                    displayStatus === status
                      ? statusColors[status]
                      : 'bg-slate-50 text-slate-500 hover:bg-slate-100'
                  }`}
                >
                  {statusLabels[status]}
                </button>
              ))}
            </div>

            {task.due_date && (
              <span
                className={`text-xs font-medium ${
                  isOverdue(task.due_date, task.status)
                    ? 'text-red-600'
                    : 'text-slate-600'
                }`}
              >
                {formatDate(task.due_date)}
              </span>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
