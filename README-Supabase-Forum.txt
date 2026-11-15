TCU Business Management forum setup
======================================

The site remains a static, flat-file GitHub Pages site. Supabase provides shared accounts and forum storage; GitHub Pages cannot provide accounts or server-side database permissions.

1. Create a Supabase project.
2. In Authentication > Providers, enable Email/password sign-in and keep email confirmation enabled. Users must confirm control of their @gms.tcu.edu.tw inbox before they can post.
3. In Authentication URL configuration, set the Site URL to the published GitHub Pages address and add that exact address to allowed Redirect URLs. Include the repository subpath if the site is published under one.
4. Open Supabase SQL Editor and run supabase-forum-setup.sql.
5. In the project Connect/API settings, copy the Project URL and Publishable key. In index.html, replace PASTE_YOUR_SUPABASE_PROJECT_URL_HERE and PASTE_YOUR_SUPABASE_PUBLISHABLE_KEY_HERE. Use only the public Publishable key (or legacy anon key). Never put a Secret or service_role key in index.html.
6. Upload index.html, all image files, both career guide images, and these forum setup files together at the GitHub Pages repository root. Keep all image filenames and capitalization unchanged.

The RLS policies allow visitors to read discussions, allow authenticated @gms.tcu.edu.tw accounts to post and reply, let members delete their own posts and replies, and allow 113114202@gms.tcu.edu.tw to delete any post or reply. Anonymous display hides a user's chosen display name; the database retains an owner ID so ownership rules can be enforced. Passwords are managed by Supabase Auth and are never stored in the HTML.

The Publishable key is intended to be public. Database safety comes from the included RLS policies. Never expose a Secret/service_role key.
