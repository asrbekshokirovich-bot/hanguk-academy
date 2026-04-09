import { BookOpen, Calendar, Video, Brain, LogOut } from "lucide-react";
import Link from "next/link";

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex h-screen bg-[var(--color-surface-900)] overflow-hidden">
      {/* Sidebar */}
      <aside className="w-64 glass-card border-r border-slate-700/50 flex flex-col justify-between">
        <div>
          <div className="p-6">
            <h2 className="text-xl font-bold tracking-tight text-white">
              Hanguk<span className="text-brand-400">Academy</span>
            </h2>
          </div>
          <nav className="flex flex-col gap-2 px-4 mt-6">
            <Link href="/dashboard/student" className="flex items-center gap-3 px-4 py-3 text-slate-300 hover:text-white hover:bg-slate-800/50 rounded-xl transition-all">
              <Calendar className="w-5 h-5 text-brand-400" /> My Schedule
            </Link>
            <Link href="/dashboard/student/vault" className="flex items-center gap-3 px-4 py-3 text-slate-300 hover:text-white hover:bg-slate-800/50 rounded-xl transition-all">
              <Video className="w-5 h-5 text-brand-400" /> Recorded Vault
            </Link>
            <Link href="/dashboard/student/ai-tutor" className="flex items-center gap-3 px-4 py-3 text-slate-300 hover:text-white hover:bg-slate-800/50 rounded-xl transition-all">
              <Brain className="w-5 h-5 text-brand-400" /> AI Practice
            </Link>
          </nav>
        </div>
        
        <div className="p-4 border-t border-slate-700/50">
          <button className="flex w-full items-center gap-3 px-4 py-3 text-slate-400 hover:text-red-400 hover:bg-red-400/10 rounded-xl transition-all">
            <LogOut className="w-5 h-5" /> Sign Out
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 overflow-y-auto w-full relative">
        <div className="absolute top-0 right-0 w-[400px] h-[400px] bg-brand-500/5 rounded-full blur-[100px] pointer-events-none" />
        <div className="p-8">
          {children}
        </div>
      </main>
    </div>
  );
}
