import { useMemo, useState } from 'react'
import {
  Activity, BarChart3, BookOpen, BrainCircuit, Building2, ClipboardList,
  Download, FileSpreadsheet, FileText, GraduationCap, LayoutDashboard,
  Menu, Search, Settings, ShieldCheck, Users, X, ChevronDown, Sparkles,
  Target, TrendingUp, CheckCircle2, Clock3, Globe2
} from 'lucide-react'
import {
  ResponsiveContainer, AreaChart, Area, XAxis, YAxis, CartesianGrid,
  Tooltip, BarChart, Bar
} from 'recharts'
import { isSupabaseConfigured, supabase } from './lib/supabase'
import { roles, type Role } from './types'

const groups = ['O‘quvchilar', 'Ota-onalar', 'O‘qituvchilar', 'Direktorlar', 'Psixologlar', 'Mahalla vakillari']
const domains = ['O‘qish savodxonligi', 'Matematik savodxonlik', 'Tabiiy-ilmiy savodxonlik', 'Raqamli dunyoda ta’lim', 'Tanqidiy fikrlash', 'Muammo yechish']
const trend = [{ name: 'Yan', score: 54 }, { name: 'Fev', score: 59 }, { name: 'Mar', score: 57 }, { name: 'Apr', score: 66 }, { name: 'May', score: 71 }, { name: 'Iyun', score: 76 }]
const barData = [{ name: 'O‘qish', score: 72 }, { name: 'Matematika', score: 64 }, { name: 'Tabiiy fan', score: 68 }, { name: 'Raqamli', score: 79 }]

const nav = [
  { label: 'Boshqaruv paneli', icon: LayoutDashboard },
  { label: 'So‘rovnomalar', icon: ClipboardList },
  { label: 'Test markazi', icon: GraduationCap },
  { label: 'Respondentlar', icon: Users },
  { label: 'Statistik tahlil', icon: BarChart3 },
  { label: 'AI analitika', icon: BrainCircuit },
  { label: 'Hisobotlar', icon: FileText },
  { label: 'Rivojlanish rejasi', icon: Target },
  { label: 'Monitoring', icon: Activity },
  { label: 'Maktablar', icon: Building2 },
  { label: 'Sozlamalar', icon: Settings }
]

function App() {
  const [active, setActive] = useState('Boshqaruv paneli')
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [role, setRole] = useState<Role>('school_admin')
  const [lang, setLang] = useState('UZ')
  const [query, setQuery] = useState('')
  const [notice, setNotice] = useState('')
  const [busy, setBusy] = useState(false)

  const visibleNav = useMemo(() => nav.filter(n => n.label.toLowerCase().includes(query.toLowerCase())), [query])

  async function generateReport() {
    setBusy(true); setNotice('')
    try {
      if (!supabase) {
        setNotice('Hisobot moduli tayyor. Haqiqiy ma’lumotlarni hisoblash uchun avval Supabase loyihasini ulang.')
      } else {
        const { data, error } = await supabase.from('analytics_snapshots').select('*').order('created_at', { ascending: false }).limit(1)
        if (error) throw error
        setNotice(data?.length ? 'Oxirgi statistik snapshot topildi. To‘liq hisobot moduli server funksiyasi bilan kengaytiriladi.' : 'Hozircha tahlil uchun ma’lumot yetarli emas. Avval so‘rovnoma va test javoblarini yig‘ing.')
      }
    } catch (e) {
      setNotice(e instanceof Error ? e.message : 'Hisobotni tayyorlashda xatolik yuz berdi.')
    } finally { setBusy(false) }
  }

  return <div className="app-shell">
    <aside className={`sidebar ${sidebarOpen ? 'open' : ''}`}>
      <div className="brand"><div className="brand-mark">P<span>360</span></div><div><b>PISA SCHOOL 360</b><small>EDUCATION INTELLIGENCE</small></div><button className="mobile-close" onClick={() => setSidebarOpen(false)}><X size={18}/></button></div>
      <div className="school-chip"><div className="school-icon"><Building2 size={18}/></div><div><b>Ta’lim diagnostikasi</b><small>Mustaqil platforma</small></div><ChevronDown size={15}/></div>
      <div className="nav-caption">ASOSIY MENYU</div>
      <nav>{visibleNav.map(item => { const Icon = item.icon; return <button key={item.label} className={`nav-item ${active === item.label ? 'selected' : ''}`} onClick={() => { setActive(item.label); setSidebarOpen(false) }}><Icon size={18}/><span>{item.label}</span>{item.label === 'AI analitika' && <i>AI</i>}</button> })}</nav>
      <div className="sidebar-bottom"><div className="secure"><ShieldCheck size={17}/><div><b>Ma’lumotlar himoyasi</b><small>Rollar va ruxsatlar nazorati</small></div></div><div className="author">N. TALATBEKOV <span>v1.0.0</span></div></div>
    </aside>
    {sidebarOpen && <button className="backdrop" onClick={() => setSidebarOpen(false)} aria-label="Close menu"/>}
    <main className="main">
      <header className="topbar"><div className="top-left"><button className="hamburger" onClick={() => setSidebarOpen(true)}><Menu/></button><div><div className="crumb">PISA SCHOOL 360 <span>/</span> {active}</div><div className="page-title">{active}</div></div></div><div className="top-actions"><button className="lang" onClick={() => setLang(lang === 'UZ' ? 'RU' : lang === 'RU' ? 'EN' : 'UZ')}><Globe2 size={16}/>{lang}</button><select className="role-select" value={role} onChange={e => setRole(e.target.value as Role)} aria-label="Rolni tanlash">{roles.map(r => <option value={r.value} key={r.value}>{r.label}</option>)}</select><div className="avatar">NT</div></div></header>
      <div className="content">
        <section className="welcome-row"><div><div className="eyebrow"><span className="live-dot"/> TA’LIM SIFATINI MA’LUMOTLAR ASOSIDA BAHOLASH</div><h1>Ta’limni raqamlarda <em>ko‘ring.</em></h1><p>Maktab rivojlanishi uchun diagnostika, tahlil va amaliy qarorlar — yagona platformada.</p></div><button className="primary-btn" onClick={generateReport} disabled={busy}><Sparkles size={17}/>{busy ? 'TAYYORLANMOQDA...' : 'YAKUNIY TAHLILNI YARATISH'}</button></section>
        {notice && <div className="notice"><CheckCircle2 size={17}/>{notice}<button onClick={() => setNotice('')}><X size={15}/></button></div>}
        {!isSupabaseConfigured && <div className="setup-alert"><span>!</span><div><b>Supabase ulanmagan</b><small>.env fayliga Supabase URL va anon key kiriting. Hozirgi ko‘rsatkichlar faqat interfeys namunasidir, real statistika emas.</small></div></div>}
        <div className="stat-grid">
          <Stat icon={Users} label="Respondentlar" value="—" meta="Ma’lumot yig‘ilgach hisoblanadi" />
          <Stat icon={ClipboardList} label="Faol so‘rovnomalar" value="—" meta="So‘rovnoma moduli" />
          <Stat icon={GraduationCap} label="Test topshirganlar" value="—" meta="Test markazi" />
          <Stat icon={TrendingUp} label="O‘rtacha natija" value="—" meta="Valid javoblar asosida" />
        </div>
        <div className="section-heading"><div><h2>Ta’lim sifati monitoringi</h2><p>Real ma’lumotlar ulanganidan keyin dinamik yangilanadi</p></div><button className="outline-btn"><Clock3 size={15}/> Davr: barcha vaqt</button></div>
        <div className="chart-grid">
          <div className="panel chart-panel"><div className="panel-head"><div><b>Natijalar dinamikasi</b><small>Davrlar kesimida o‘zgarish</small></div><span className="tag">MONITORING</span></div><div className="empty-chart"><Activity size={24}/><b>Ma’lumotlar kutilmoqda</b><small>Javoblar yig‘ilgach trend grafigi shakllanadi.</small></div></div>
          <div className="panel chart-panel"><div className="panel-head"><div><b>Kompetensiyalar</b><small>Yo‘nalishlar bo‘yicha natijalar</small></div><span className="tag">TEST</span></div><div className="empty-chart"><BarChart3 size={24}/><b>Hali natijalar mavjud emas</b><small>Test markazidagi valid natijalar ko‘rsatiladi.</small></div></div>
        </div>
        <div className="section-heading"><div><h2>Diagnostika yo‘nalishlari</h2><p>Platformaning asosiy tadqiqot modullari</p></div></div>
        <div className="module-grid">{[
          ['O‘qish savodxonligi','Matnni tushunish, dalilni baholash va xulosa chiqarish','BookOpen'],
          ['Matematik savodxonlik','Hayotiy vaziyatlarda matematik fikrlash','BarChart3'],
          ['Tabiiy-ilmiy savodxonlik','Ilmiy dalillar, hodisalar va tajribalarni tahlil qilish','Activity'],
          ['Raqamli dunyoda ta’lim','Raqamli muhitda axborot va muammo bilan ishlash','Globe2'],
          ['Tanqidiy fikrlash','Mantiq, dalil va manbalarni baholash','BrainCircuit'],
          ['Muammo yechish','Muammoni aniqlash va yechim samaradorligini tekshirish','Target']
        ].map((m,i) => <div className="module-card" key={m[0]}><div className="module-num">0{i+1}</div><b>{m[0]}</b><p>{m[1]}</p><span>Mustaqil diagnostika moduli <span>↗</span></span></div>)}</div>
        <div className="section-heading"><div><h2>Respondent guruhlari</h2><p>Har bir guruh uchun alohida so‘rovnoma va tahlil</p></div></div>
        <div className="group-grid">{groups.map((g,i)=><div className="group-card" key={g}><div className="group-icon">{[<GraduationCap/>,<Users/>,<BookOpen/>,<Building2/>,<BrainCircuit/>,<Globe2/>][i]}</div><div><b>{g}</b><small>Profil va diagnostika savollari</small></div><span>→</span></div>)}</div>
        <footer><b>PISA SCHOOL 360</b><span>DATA-DRIVEN EDUCATION. BETTER FUTURE.</span><small>Muallif: N. TALATBEKOV · Mustaqil diagnostika platformasi. OECD bilan rasmiy hamkorlik yoki tasdiq mavjudligini anglatmaydi.</small></footer>
      </div>
    </main>
  </div>
}

function Stat({ icon: Icon, label, value, meta }: { icon: typeof Users; label: string; value: string; meta: string }) {
  return <div className="stat-card"><div className="stat-top"><span>{label}</span><div><Icon size={18}/></div></div><strong>{value}</strong><small>{meta}</small></div>
}

export default App
