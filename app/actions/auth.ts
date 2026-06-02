'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';

export async function login(formData: FormData): Promise<{ error?: string }> {
  const supabase = await createClient();

  const data = {
    email: formData.get('email') as string,
    password: formData.get('password') as string,
  };

  const { error } = await supabase.auth.signInWithPassword(data);

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/', 'layout');
  redirect('/');
}

export async function signup(formData: FormData): Promise<{ error?: string }> {
  const supabase = await createClient();

  const data = {
    email: formData.get('email') as string,
    password: formData.get('password') as string,
  };

  const { error, data: authData } = await supabase.auth.signUp(data);

  if (error) {
    return { error: error.message };
  }

  // Create a default workspace for the new user
  if (authData.user) {
    const { data: workspace, error: workspaceError } = await supabase
      .from('workspaces')
      .insert({ name: 'My Workspace' })
      .select()
      .single();

    if (!workspaceError && workspace) {
      await supabase.from('workspace_members').insert({
        workspace_id: workspace.id,
        user_id: authData.user.id,
        role: 'owner',
      });
    }
  }

  revalidatePath('/', 'layout');
  redirect('/');
}

export async function signout(): Promise<void> {
  const supabase = await createClient();
  await supabase.auth.signOut();
  revalidatePath('/', 'layout');
  redirect('/login');
}
