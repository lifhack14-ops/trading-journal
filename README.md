# Trading Journal

A standalone private trading journal built as a static web app with Supabase Auth, Postgres Row Level Security, and a private screenshot bucket.

## Setup
1. Enable GitHub Pages: repository **Settings → Pages → Deploy from a branch → main → /(root)**.
2. Create a **separate Supabase project** for this app.
3. In the Supabase SQL Editor, run the entire `supabase.sql` file.
4. From Supabase Project Settings → API, copy the Project URL and the public publishable key (or legacy anon key).
5. Open the GitHub Pages site, enter those values in the setup screen, then create an account and sign in.
6. Add a test trade. Sign in on a second device with the same account to verify synchronization.

## Security
- Trade rows are protected by Row Level Security policies tied to `auth.uid()`.
- Screenshots are stored in a private bucket and paths are scoped to the authenticated user's UUID.
- Only use the public publishable/anon key in the browser. Never expose a `service_role` or secret key.
- The GitHub repository contains public application code; it must not contain trade data, passwords, or Supabase secret keys.
- AI analysis currently creates a prompt to copy into ChatGPT; it does not send data automatically.

This is a starter implementation. Test authentication, RLS and screenshot access before entering real trading records. Not financial advice.
