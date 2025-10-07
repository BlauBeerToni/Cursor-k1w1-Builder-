# Supabase Build Tracking Integration

This document explains how to integrate Supabase build tracking into your Flutter app for real-time progress monitoring of GitHub Actions builds.

## Setup

### 1. Supabase Configuration

1. **Create a new Supabase project** at [supabase.com](https://supabase.com)

2. **Run the SQL setup** in your Supabase SQL Editor:

```sql
-- Create build_runs table with RLS policies
create extension if not exists pgcrypto;

create table if not exists build_runs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  prompt text not null,
  repo text,
  commit_sha text,
  run_id bigint,
  status text not null default 'queued',
  step text default 'queued',
  step_index int default 0,
  steps_total int default 8,
  apk_url text,
  aab_url text,
  started_at timestamptz default now(),
  finished_at timestamptz,
  duration_ms int
);

alter table build_runs enable row level security;

-- RLS Policies
create policy "owner read" on build_runs for select using (auth.uid() = user_id);
create policy "owner write" on build_runs for insert with check (auth.uid() = user_id);
create policy "owner update" on build_runs for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
```

3. **Get your Supabase credentials**:
   - Go to Settings > API
   - Copy your Project URL and anon/public key

4. **Deploy the Edge Function** (optional, for webhook handling):
   ```bash
   supabase functions deploy build-callback
   ```

### 2. Environment Configuration

Update your `.env` file with Supabase credentials:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
ANDROID_APP_ID=com.your.app.id
BUILD_WEBHOOK_URL=https://your-project.supabase.co/functions/v1/build-callback
```

### 3. Flutter Dependencies

The following dependencies are already included in `pubspec.yaml`:
- `supabase_flutter: ^2.5.0`
- `flutter_riverpod: ^2.4.9` (for state management)

Run `flutter pub get` to install dependencies.

## Usage

### Basic Integration

The system is already integrated into your app's bootstrap process. Here's how to use it:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prompt_apk_builder/features/builds/build_runs_service.dart';
import 'package:prompt_apk_builder/features/builds/build_providers.dart';

// 1. Create a new build run
final userId = Supabase.instance.client.auth.currentUser!.id;
final buildId = await BuildRunsService().createRun(
  userId: userId,
  prompt: 'Your build prompt here',
  repo: 'https://github.com/username/repo',
);

// 2. Watch build progress using Riverpod
class BuildScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(buildRunStreamProvider(buildId)).when(
      data: (run) => BuildProgressWidget(run: run),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

// 3. Display progress
class BuildProgressWidget extends StatelessWidget {
  final BuildRun run;

  const BuildProgressWidget({required this.run});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(value: BuildRunsService.progress(run)),
        Text('${run.step} • ${run.status}'),
        Text('Progress: ${(BuildRunsService.progress(run) * 100).toStringAsFixed(0)}%'),
        if (BuildRunsService.eta(run) != null)
          Text('ETA: ${BuildRunsService.eta(run)!.inMinutes}m ${BuildRunsService.eta(run)!.inSeconds.remainder(60)}s'),
      ],
    );
  }
}
```

### GitHub Actions Integration

1. **Set up your workflow** to call the webhook at each step:

```yaml
- name: Mark step (pub_get)
  if: ${{ env.BUILD_ID != '' && secrets.BUILD_WEBHOOK_URL != '' }}
  run: |
    curl -sS -X POST "$BUILD_WEBHOOK_URL" \
      -H 'Content-Type: application/json' \
      -d "{\"build_id\": \"${{ env.BUILD_ID }}\", \"step\":\"pub_get\",\"step_index\":1,\"status\":\"running\"}" || true
```

2. **Pass the build_id** to your workflow:

```dart
// When triggering the workflow, pass the build_id
final buildId = await createBuildRun(...);
// Trigger GitHub Actions with build_id
```

### Edge Function Webhook (Optional)

The included Edge Function (`supabase/functions/build-callback/index.ts`) handles webhook calls from GitHub Actions and updates the database using the service role key for authenticated database writes.

## Architecture

### Core Components

1. **BuildRun Model** (`lib/features/builds/model/build_run.dart`)
   - Data model for build runs with all necessary fields

2. **BuildRunsService** (`lib/features/builds/build_runs_service.dart`)
   - Service class for creating, watching, and updating build runs
   - Includes progress calculation and ETA estimation

3. **Riverpod Providers** (`lib/features/builds/build_providers.dart`)
   - Stream provider for real-time build watching
   - Progress and ETA providers for computed values

4. **Bootstrap Integration** (`lib/app/bootstrap.dart`)
   - Initializes Supabase with your environment configuration

### Real-time Updates

The system uses Supabase's real-time subscriptions to automatically update the UI when build progress changes:

```dart
final buildStream = ref.watch(buildRunStreamProvider(buildId));
```

### Progress Calculation

Progress is calculated as a percentage (0.0 to 1.0) based on the current step index vs total steps:

```dart
static double progress(BuildRun r) {
  if (r.stepsTotal <= 0) return 0;
  final p = r.stepIndex / r.stepsTotal;
  return p.clamp(0, 1).toDouble();
}
```

### ETA Estimation

ETA is estimated based on elapsed time and current progress:

```dart
static Duration? eta(BuildRun r) {
  if (r.startedAt == null || r.stepIndex <= 0) return null;
  final elapsed = DateTime.now().difference(r.startedAt!);
  final perStep = elapsed.inMilliseconds / r.stepIndex;
  final remaining = ((r.stepsTotal - r.stepIndex) * perStep).round();
  return Duration(milliseconds: remaining);
}
```

## Security

- **Anon Key**: Used in the Flutter app for read/write operations on user-owned records
- **Service Role Key**: Used only in Edge Functions for authenticated database operations
- **Row Level Security**: Ensures users can only access their own build runs
- **Authentication**: Requires users to be logged in to create or view build runs

## Example Implementation

See `lib/features/builds/build_tracking_example.dart` for a complete example of how to integrate build tracking into your UI.

## Next Steps

1. Set up your Supabase project and run the SQL schema
2. Update your `.env` file with Supabase credentials
3. Run `flutter pub get` to install dependencies
4. Implement build creation and progress display in your UI
5. Set up GitHub Actions workflow with webhook calls
6. Deploy the Edge Function for webhook handling (optional)

The system is designed to be lightweight, secure, and easy to integrate into existing Flutter applications.