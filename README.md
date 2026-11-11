# PISA SCHOOL 360

**DATA-DRIVEN EDUCATION. BETTER FUTURE.**  
Muallif: **N. TALATBEKOV**

PISA SCHOOL 360 — maktab ta’limi sifatini mustaqil diagnostika qilish, so‘rovnoma va test natijalarini yig‘ish, statistik tahlil qilish hamda rivojlanish strategiyasini shakllantirish uchun mo‘ljallangan platforma.

> Ushbu loyiha OECD yoki rasmiy PISA dasturining mahsuloti emas, ular bilan rasmiy hamkorlikni anglatmaydi. Natijalar rasmiy PISA ballari yoki reytinglari sifatida talqin qilinmasligi kerak.

## Texnologiyalar
- React 19 + TypeScript + Vite
- Tailwind CSS
- Supabase Auth + PostgreSQL + RLS
- Recharts
- Lucide icons

## GitHub'ga yuklash

1. ZIP faylni oching.
2. Ichidagi `pisa-school-360` papkasini GitHub repository'ga yuklang.
3. GitHub'da `Add file → Upload files` orqali papka ichidagi fayllarni yuklash yoki Git bilan push qilish mumkin.

Terminal orqali:

```bash
git init
git add .
git commit -m "Initial PISA SCHOOL 360 project"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```

## Lokal ishga tushirish

Node.js 20+ tavsiya etiladi.

```bash
npm install
cp .env.example .env
npm run dev
```

`.env` fayliga Supabase ma'lumotlarini kiriting:

```env
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

## Supabase sozlash

1. Supabase'da yangi project yarating.
2. SQL Editor'da `supabase/schema.sql` faylini ishga tushiring.
3. Keyin `supabase/seed.sql` faylini ishga tushiring.
4. Project URL va anon key'ni `.env` fayliga kiriting.
5. Authentication → Users orqali foydalanuvchilarni yarating.
6. Har bir foydalanuvchi uchun `profiles` jadvalida rol va `school_id` belgilang.

**Xavfsizlik eslatmasi:** `service_role` kalitini hech qachon frontendga yoki GitHub repository'ga joylamang. Faqat anon key ishlating. Production'da barcha RLS policy'larni test qiling; ayniqsa bolalar shaxsiy ma'lumotlari, ota-ona ruxsati, eksport va respondentlararo cheklovlarni mustaqil audit qiling.

## Loyiha tuzilishi

```text
pisa-school-360/
├── src/
│   ├── App.tsx
│   ├── main.tsx
│   ├── styles.css
│   ├── types.ts
│   └── lib/supabase.ts
├── supabase/
│   ├── schema.sql
│   └── seed.sql
├── .env.example
├── package.json
└── README.md
```

## Muhim ishlab chiqish holati

Ushbu ZIP — ishlaydigan React/Vite boshlang‘ich loyihasi, premium dashboard interfeysi va kengaytiriladigan PostgreSQL/Supabase ma'lumotlar bazasi asosidir. So‘rovnoma CRUD, to‘liq test topshirish oqimi, server-side ball hisoblash, AI API, PDF/XLSX eksport, avtomatik deadline triggerlari va barcha 10 rol uchun production darajasidagi ruxsatlar keyingi ishlab chiqish bosqichlarida yakunlanishi kerak. Dashboarddagi `—` qiymatlar ataylab qo‘yilgan: uydirma statistika ko‘rsatilmaydi.

## PISA metodologiyasi bo‘yicha ehtiyot choralari
- Rasmiy PISA metodologiyasi va ruxsat etilgan materiallardan mustaqil foydalanish qoidalariga rioya qiling.
- PISA uslubidagi topshiriqlarni o‘zingiz ishlab chiqing yoki foydalanish huquqi mavjud materiallardan foydalaning.
- Kichik respondent guruhlarida shaxsni aniqlashga olib keladigan kesimlarni yashiring.
- Korrelyatsiya sabab-oqibatni isbotlamaydi.
- Ochiq javoblarni rubrika asosida baholang; zarur holatda ekspert tekshiruviga yuboring.
