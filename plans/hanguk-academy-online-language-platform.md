# Blueprint: Hanguk Academy Online Language Platform

## Context & Architecture Decisions
1. **Backend**: Supabase (PostgreSQL) for Authentication, real-time database, and edge functions.
2. **Video Provider**: LiveKit for scalable WebRTC routing, paired with LiveKit Egress for automatic cloud recording of the 3x/week group lessons.
3. **DRM & Security**: 
   - **Web**: Custom dynamic watermarking overlay moving randomly across the player containing the user's ID/Email.
   - **Apps (Flutter)**: Platform channels leveraging `FLAG_SECURE` (Android) and `UIScreen.capturedDidChangeNotification` (iOS) to block system-level screen recording. Screenshots will be permitted if the OS API allows differentiation (often difficult, fallback is full block).
4. **AI Features**: 
   - Real-time OpenAI Voice Conversation Partner.
   - Post-lesson Transcript Summarization (Whisper/Deepgram + GPT-4o) to generate study notes, vocabulary lists, and practice quizzes.

## Global Invariants (Must strictly hold true throughout project)
- All components must follow `.agents/skills/frontend-patterns` and `.agents/skills/dart-flutter-patterns`.
- Supabase RLS (Row Level Security) must strictly limit video access to authenticated, enrolled students.
- Web app design should enforce the overarching "stunning, glassmorphic" aesthetic.

---

## Step 1: Next.js Foundation & Marketing
**Context Brief:** We need to establish the central workspace for the Next.js marketing and core web application. We're using Next.js (App Router), Tailwind CSS (or modern vanilla CSS), and Supabase for Auth.
**Task List:**
- [ ] Initialize Next.js project in the root directory.
- [ ] Set up global aesthetic CSS tokens (Dark mode, neon highlights, glassmorphism).
- [ ] Build the landing/marketing page detailing AI features, 3x/week courses, and pricing.
- [ ] Integrate Supabase Client & Auth UI (Login/Register).
**Exit Criteria / Verification:**
- `npm run build` succeeds.
- Landing page renders perfectly on mobile/desktop without layout shifts.
- User can successfully register and log in via Supabase.

## Step 2: Student & Teacher Dashboards (Class Scheduling)
**Context Brief:** The system hosts group lessons 3 times per week. Students and teachers need dedicated dashboards to view schedules and active cohorts.
**Task List:**
- [ ] Create Supabase schema for `users`, `cohorts`, `schedules`, and `enrollments`.
- [ ] Enable RLS on all newly created tables.
- [ ] Build the Student Dashboard (upcoming classes, past recorded classes).
- [ ] Build the Teacher Dashboard (manage schedule, start class button).
**Exit Criteria / Verification:**
- Teacher can create a 3x/week schedule cohort.
- Student can enroll and view upcoming slots.

## Step 3: Video Classroom & Cloud Recording (LiveKit)
**Context Brief:** The core delivery mechanism. Group lessons run via LiveKit. The session must be automatically recorded for students to review.
**Task List:**
- [ ] Set up a LiveKit project (can use LiveKit Cloud for dev) and create a Next.js API route to generate participant tokens.
- [ ] Build the custom Video Room UI (Teacher spotlight, student grid) using `@livekit/components-react`.
- [ ] Trigger LiveKit Egress (Cloud Recording) automatically when the teacher clicks "Start Class".
- [ ] Implement Web Watermarking DRM: Overlay a moving `<canvas>` or `<div>` with student email across the video player.
**Exit Criteria / Verification:**
- Teacher and student can join a mock LiveKit room.
- Video correctly records and saves to S3/Supabase Storage.
- Watermark is visible and difficult to casually remove via DOM.

## Step 4: AI Language Partner & Automated Study Notes
**Context Brief:** Differentiating factors. Post-class and independent study AI features.
**Task List:**
- [ ] Integrate OpenAI Realtime / WebRTC API for the voice-to-voice 1-on-1 practice room.
- [ ] Create an edge function triggered when a LiveKit recording completes: Transcribes audio via Whisper, passes to GPT-4o to generate vocab lists and summaries, and saves to Postgres.
- [ ] Build the UI for students to view these generated study notes attached to their past classes.
**Exit Criteria / Verification:**
- Function successfully parses a mock transcript and returns structured JSON (vocab, summary).
- Student can interact with the voice bot with latency < 1s.

## Step 5: Flutter Cross-Platform Applications
**Context Brief:** Porting the web functionality into native iOS, Android, and Windows/macOS desktop apps using Flutter.
**Task List:**
- [ ] Initialize a new Flutter project in a `mobile/` directory.
- [ ] Implement Supabase Auth (Flutter).
- [ ] Implement the LiveKit Flutter SDK for video viewing.
- [ ] Add the heavy native DRM: Use a plugin or MethodChannel to enforce `FLAG_SECURE` on Android and equivalent on iOS to prevent screen recording.
**Exit Criteria / Verification:**
- Project builds on Android/iOS simulators.
- A user can log in and view their class schedule natively.
