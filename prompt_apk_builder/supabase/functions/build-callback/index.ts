// Supabase Edge Function for Build Progress Callbacks
// This function receives webhook calls from GitHub Actions and updates the build_runs table

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  try {
    const body = await req.json().catch(() => ({}));
    const {
      build_id,
      step,
      step_index,
      status,
      run_id,
      apk_url,
      aab_url
    } = body;

    // Validate required fields
    if (!build_id) {
      return new Response('Missing build_id', { status: 400 });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    const updates: any = {
      step,
      step_index,
      run_id,
    };

    if (status) updates.status = status;
    if (apk_url) updates.apk_url = apk_url;
    if (aab_url) updates.aab_url = aab_url;

    // Set finished_at if status is success or failed
    if (status === 'success' || status === 'failed') {
      updates.finished_at = new Date().toISOString();
    }

    const { error } = await supabase
      .from('build_runs')
      .update(updates)
      .eq('id', build_id);

    if (error) {
      console.error('Error updating build run:', error);
      return new Response(error.message, { status: 500 });
    }

    return new Response('ok', { status: 200 });
  } catch (error) {
    console.error('Error in build-callback function:', error);
    return new Response('Internal server error', { status: 500 });
  }
});