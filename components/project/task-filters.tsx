'use client';

import { useRouter, useSearchParams, usePathname } from 'next/navigation';

interface TaskFiltersProps {
  currentFilters: { status?: string; assignee?: string };
}

export function TaskFilters({ currentFilters }: TaskFiltersProps): React.JSX.Element {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  function updateFilter(key: string, value: string): void {
    const params = new URLSearchParams(searchParams.toString());
    if (value === 'all' || !value) {
      params.delete(key);
    } else {
      params.set(key, value);
    }
    router.push(`${pathname}?${params.toString()}`);
  }

  return (
    <div className="bg-white border border-slate-200 rounded-lg p-4">
      <div className="flex flex-wrap gap-4">
        <div className="flex items-center gap-2">
          <label htmlFor="status-filter" className="text-sm font-medium text-slate-700">
            Status:
          </label>
          <select
            id="status-filter"
            value={currentFilters.status || 'all'}
            onChange={(e): void => updateFilter('status', e.target.value)}
            className="px-3 py-1.5 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
          >
            <option value="all">All</option>
            <option value="todo">To Do</option>
            <option value="in_progress">In Progress</option>
            <option value="done">Done</option>
          </select>
        </div>

        <div className="flex items-center gap-2">
          <label htmlFor="assignee-filter" className="text-sm font-medium text-slate-700">
            Assignee:
          </label>
          <select
            id="assignee-filter"
            value={currentFilters.assignee || 'all'}
            onChange={(e): void => updateFilter('assignee', e.target.value)}
            className="px-3 py-1.5 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"
          >
            <option value="all">All</option>
            <option value="assigned">Assigned</option>
            <option value="unassigned">Unassigned</option>
          </select>
        </div>

        {(currentFilters.status || currentFilters.assignee) && (
          <button
            onClick={(): void => router.push(pathname)}
            className="text-sm text-blue-600 hover:text-blue-700 font-medium"
          >
            Clear filters
          </button>
        )}
      </div>
    </div>
  );
}
