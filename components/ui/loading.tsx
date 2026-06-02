export function LoadingSpinner(): JSX.Element {
  return (
    <div className="flex items-center justify-center p-8">
      <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
    </div>
  );
}

export function LoadingSkeleton(): JSX.Element {
  return (
    <div className="animate-pulse space-y-4">
      <div className="h-4 bg-slate-200 rounded w-3/4"></div>
      <div className="h-4 bg-slate-200 rounded w-1/2"></div>
      <div className="h-4 bg-slate-200 rounded w-5/6"></div>
    </div>
  );
}

export function CardSkeleton(): JSX.Element {
  return (
    <div className="bg-white border border-slate-200 rounded-lg p-6 animate-pulse">
      <div className="h-6 bg-slate-200 rounded w-2/3 mb-4"></div>
      <div className="space-y-3">
        <div className="h-4 bg-slate-200 rounded w-full"></div>
        <div className="h-4 bg-slate-200 rounded w-4/5"></div>
      </div>
    </div>
  );
}
