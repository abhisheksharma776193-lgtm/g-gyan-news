G GYAN NEWS — Production setup guide (Hindi)
=============================================

यह package website code + SQL schema है। यह अपने-आप deploy नहीं हुई है। नीचे के steps मोबाइल browser से किए जा सकते हैं।

1) SUPABASE DATABASE + LOGIN
- https://supabase.com पर account बनाकर नया project बनाएं।
- Dashboard -> SQL Editor -> New query खोलें।
- इस package की supabase-schema.sql का पूरा content paste करके Run करें।
- Authentication -> Users -> Add user से अपना email और मजबूत password वाला admin user बनाएं। Email confirmation मांगे तो verify करें।
- Authentication -> Users में उस user की UUID/ID कॉपी करें।
- SQL Editor में यह query चलाएं, UUID बदलकर:
  insert into public.profiles(id,role) values('YOUR-REAL-USER-UUID','admin')
  on conflict(id) do update set role='admin';
- Project Settings -> API (या Connect/API Keys) से Project URL और public anon/publishable key लें।

2) FRONTEND CONFIGURE करें
- index.html को code editor या GitHub के web editor में खोलें।
- इन lines को खोजें:
  const SUPABASE_URL="PASTE_YOUR_SUPABASE_PROJECT_URL";
  const SUPABASE_ANON_KEY="PASTE_YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY";
- placeholders को अपने project URL और public anon/publishable key से बदलें। Quotes रहने दें।
- service_role/secret key कभी भी HTML, GitHub या browser में न डालें।

3) GITHUB PAGES से LIVE करें
- https://github.com पर sign in करें और New repository बनाएं, जैसे g-gyan-news-site।
- index.html को repository के root में upload करें।
- Repository -> Settings -> Pages -> Build and deployment में “Deploy from a branch” चुनें।
- Branch main और folder /(root) चुनकर Save करें।
- कुछ मिनट बाद GitHub Pages द्वारा दिखाया गया URL खोलें।
- URL/key placeholders बदलना और database setup करना deployment से पहले जरूरी है।

4) TEST
- Logged-out browser में केवल published news दिखनी चाहिए।
- Admin email/password से login करके news create/edit/draft/publish/delete टेस्ट करें।
- किसी सामान्य user से admin actions की अनुमति नहीं होनी चाहिए।
- Photo/video links सार्वजनिक HTTPS URLs हों।

SECURITY / LIMITATIONS
- यह setup Supabase Auth, Postgres और RLS policies इस्तेमाल करता है। Admin privileges database में जाँची जाती हैं; सिर्फ UI छिपाने पर निर्भर नहीं है।
- यह frontend media URL स्वीकार करता है, file upload नहीं। Media hosting बाद में जोड़ें।
- Automatic RSS/API live feed अभी शामिल नहीं है; इसके लिए server-side Edge Function/cron और API provider की जरूरत होगी। API secrets frontend में न रखें।
- Production संचालन से पहले Supabase backups, account recovery, MFA (यदि उपलब्ध), privacy/contact/copyright pages और परीक्षण पूरे करें।
- किसी भी RSS/API/image/video के उपयोग में संबंधित सेवा की terms, attribution और copyright नियम मानें।
- अगर खबरें लोड न हों: SQL run हुआ है, table/policies बनी हैं, और URL/key सही project के हैं यह जाँचें।
- अगर login के बाद पोस्ट save न हो: Auth user UUID सही profiles row में admin role पर है या नहीं जाँचें।
