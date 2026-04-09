import { Users, PlayCircle, Settings } from "lucide-react";

export default function TeacherDashboard() {
  return (
    <div className="flex flex-col gap-8 max-w-5xl mx-auto">
      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-bold text-white mb-2">Instructor Panel</h1>
          <p className="text-slate-400">Manage your cohorts and launch classrooms.</p>
        </div>
        <button className="px-4 py-2 border border-slate-700 hover:bg-slate-800 rounded-lg text-slate-300 transition-colors flex items-center gap-2">
          <Settings className="w-4 h-4" /> Manage Schedules
        </button>
      </div>

      <div className="grid md:grid-cols-2 gap-6">
        {/* Active Class */}
        <div className="glass-card p-8 rounded-2xl border border-indigo-500/30 flex flex-col justify-between gap-6 shadow-[0_0_30px_rgba(99,102,241,0.1)]">
          <div>
            <div className="text-indigo-400 text-sm font-bold tracking-wider uppercase mb-2">Class Ready</div>
            <h2 className="text-3xl font-bold text-white mb-2">Cohort B - Beginner</h2>
            <p className="text-slate-400">12 Students enrolled. Auto-recording (Egress) will initialize when joined.</p>
          </div>
          <button className="px-6 py-4 bg-indigo-500 text-white font-bold rounded-xl hover:bg-indigo-400 flex items-center justify-center gap-2 transition-all w-full">
            <PlayCircle className="w-6 h-6" /> Start Live Classroom
          </button>
        </div>

        <div className="glass-card p-6 rounded-2xl border border-slate-700/50">
          <h3 className="text-lg font-bold text-white mb-4 flex items-center gap-2">
            <Users className="w-5 h-5 text-indigo-400" /> My Cohorts
          </h3>
          <div className="flex flex-col gap-3">
            <div className="p-4 bg-slate-800/50 rounded-xl flex justify-between items-center border border-slate-700/30">
              <div>
                <div className="font-semibold text-slate-200">Cohort A - Intermediate</div>
                <div className="text-sm text-slate-500 mt-1">M, W, F @ 10:00 AM</div>
              </div>
              <div className="text-right">
                <span className="text-white font-bold">15</span>
                <div className="text-xs text-slate-500">Students</div>
              </div>
            </div>
            <div className="p-4 bg-slate-800/50 rounded-xl flex justify-between items-center border border-slate-700/30 border-l-2 border-l-indigo-500">
              <div>
                <div className="font-semibold text-slate-200">Cohort B - Beginner</div>
                <div className="text-sm text-slate-500 mt-1">T, Th, S @ 6:00 PM</div>
              </div>
              <div className="text-right">
                <span className="text-white font-bold">12</span>
                <div className="text-xs text-slate-500">Students</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
