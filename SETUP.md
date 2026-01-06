# Islamic Jeopardy - Setup Guide

## Current Progress

✅ Dependencies installed (Supabase, shadcn-svelte, Zod)
✅ .env files created
✅ Database schema created (`supabase/schema.sql`)
✅ Supabase integration setup (hooks, client, types)

## Next Steps - **ACTION REQUIRED**

### 1. Create Supabase Project

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Create a new project
3. Wait for the database to be provisioned (~2 minutes)

### 2. Run Database Schema

1. In your Supabase dashboard, go to **SQL Editor**
2. Click **New Query**
3. Copy and paste the entire contents of `supabase/schema.sql`
4. Click **Run** to execute the schema
5. Verify in the **Table Editor** that all tables were created:
   - profiles
   - categories (should have 8 rows seeded)
   - games
   - game_categories
   - questions
   - ratings
   - favorites
   - game_plays

### 3. Configure Environment Variables

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon/public key** (long string starting with `eyJ...`)

3. Update `.env` file:
```env
PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
PUBLIC_SUPABASE_ANON_KEY=your-actual-anon-key-here
RESEND_API_KEY=re_your-resend-api-key-here
```

### 4. Configure Resend (for Feedback Form)

1. Go to [https://resend.com](https://resend.com) and create an account
2. Create an API key in the Resend dashboard
3. Add the API key to your `.env` file as `RESEND_API_KEY`
4. Verify your domain in Resend (or use the test domain for development)
5. Update the `from` email address in `src/routes/feedback/+page.server.ts` to match your verified domain

**Note:** For development, you can use Resend's test mode, but you'll need to verify a domain for production use.

### 5. Generate TypeScript Types (Optional but Recommended)

Run this command to generate accurate TypeScript types from your database:

```bash
npx supabase gen types typescript --project-id YOUR_PROJECT_ID > src/lib/types/database.types.ts
```

Replace `YOUR_PROJECT_ID` with your actual project ID (from the Project URL).

**Note:** I've already created placeholder types, so this step is optional but will provide more accurate types.

### 6. Enable Email Auth in Supabase

1. Go to **Authentication** → **Providers** in your Supabase dashboard
2. Enable **Email** provider (it should be enabled by default)
3. Optionally enable **Google** or **Apple** for social auth (recommended for mobile)

## What's Been Built So Far

### File Structure Created
```
src/
├── lib/
│   ├── supabase/
│   │   └── client.ts          # Supabase client factory
│   ├── types/
│   │   └── database.types.ts  # Database TypeScript types
│   └── utils/                 # (empty, ready for utilities)
├── routes/
│   ├── +layout.svelte         # Root layout (unchanged)
│   ├── +layout.server.ts      # Server session loading
│   └── +layout.ts             # Client Supabase setup
├── hooks.server.ts            # Server-side Supabase integration
├── hooks.client.ts            # Client error handling
└── app.d.ts                   # Updated with Supabase types

supabase/
└── schema.sql                 # Complete database schema

.env                           # Environment variables (needs your credentials)
.env.example                   # Template for environment variables
```

### Database Schema Features

- **8 tables** with full Row Level Security (RLS) policies
- **Automatic triggers** for:
  - Updating game ratings when ratings change
  - Incrementing play counts
  - Creating user profiles on signup
- **8 pre-seeded categories**: Prophets, Quran, Hadith, Sunnah, Islamic Beliefs, Islamic Manners, Islamic History, General Knowledge
- **Difficulty levels**: Kids, Beginner, Advanced
- **Support for**: 1-8 players per game
- **Rating system**: 1-5 stars with reviews

## Ready to Continue?

Once you've completed steps 1-4 above (create Supabase project, run schema, update .env, configure Resend), I can continue building:

1. **Authentication system** (login, signup, protected routes)
2. **shadcn-svelte UI components** (buttons, cards, forms, etc.)
3. **Game creation wizard** (4-step flow)
4. **Game discovery & browsing**
5. **Local multiplayer gameplay**
6. **Rating & favorites system**
7. **User profiles**
8. **Mobile optimizations**

## Testing the Setup

Once you've updated the `.env` file, you can test that everything is working by running:

```bash
pnpm dev
```

The app should start without errors. If you see TypeScript errors about environment variables, make sure your `.env` file is properly configured.

## Need Help?

- **Supabase Docs**: https://supabase.com/docs
- **SvelteKit Docs**: https://kit.svelte.dev/docs
- **shadcn-svelte**: https://www.shadcn-svelte.com/

## What's Next in Development?

After you complete the setup steps, I'll continue with:

1. ✅ Phase 1: Foundation (COMPLETE)
2. 🔄 Phase 2: Authentication (NEXT)
   - Login/signup pages
   - Protected routes
   - Auth components
3. 📋 Phase 3: UI Foundation
4. 📋 Phase 4: Game Discovery
5. 📋 Phase 5: Game Creation
6. 📋 Phase 6: Game Playing
7. 📋 Phase 7: Rating & Favorites
8. 📋 Phase 8: User Profiles
9. 📋 Phase 9: Mobile & Polish
10. 📋 Phase 10: Deployment

Let me know once you've completed the Supabase setup, and I'll continue building the application!
