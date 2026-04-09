"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { motion } from "framer-motion";
import { LogOut, BookOpen, Video, ShieldCheck } from "lucide-react";

export default function DashboardPage() {
  const [phoneNumber, setPhoneNumber] = useState<string | null>("Loading...");
  const router = useRouter();
  const supabase = createClient();

  useEffect(() => {
    async function verifySession() {
      const { data: { session }, error } = await supabase.auth.getSession();
      
      if (error || !session) {
        router.push("/login");
        return;
      }

      // Strip the pseudo domain to display the true phone number
      const email = session.user.email || "";
      const phone = email.replace("@hanguk.auth", "");
      setPhoneNumber(phone);
    }

    verifySession();
  }, [router, supabase.auth]);

  const handleLogout = async () => {
    await supabase.auth.signOut();
    router.push("/login");
  };

  return (
    <div className="min-h-screen p-8 text-white relative">
      <header className="flex justify-between items-center mb-12">
        <h1 className="text-2xl font-bold">
          Hanguk<span className="text-brand-400">Academy</span> Dashboard
        </h1>
        <div className="flex items-center gap-6">
          <div className="flex items-center gap-2 text-sm text-slate-300 bg-surface-800/50 px-4 py-2 rounded-full border border-surface-700/50">
            <ShieldCheck className="w-4 h-4 text-brand-400" />
            <span className="font-mono">{phoneNumber}</span>
          </div>
          <button 
            onClick={handleLogout}
            className="flex items-center gap-2 text-red-400 hover:text-red-300 transition-colors text-sm font-medium"
          >
            <LogOut className="w-4 h-4" /> Sign Out
          </button>
        </div>
      </header>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 max-w-6xl mx-auto">
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="glass-card p-6 rounded-2xl flex flex-col gap-4 border border-brand-500/20"
        >
          <div className="w-12 h-12 bg-surface-800 rounded-xl flex items-center justify-center mb-2">
            <Video className="w-6 h-6 text-brand-400" />
          </div>
          <h3 className="text-xl font-bold">Next Class</h3>
          <p className="text-slate-400 text-sm">Your next live WebRTC immersion session begins in 2 hours.</p>
          <button className="mt-auto py-2 px-4 bg-brand-500 text-surface-900 font-bold rounded-lg hover:bg-brand-400 transition-colors">
            Enter Classroom
          </button>
        </motion.div>

        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="glass-card p-6 rounded-2xl flex flex-col gap-4"
        >
          <div className="w-12 h-12 bg-surface-800 rounded-xl flex items-center justify-center mb-2">
            <BookOpen className="w-6 h-6 text-brand-400" />
          </div>
          <h3 className="text-xl font-bold">Study Notes</h3>
          <p className="text-slate-400 text-sm">Review your automatically generated AI Smart Notes from previous sessions.</p>
          <button className="mt-auto py-2 px-4 bg-surface-700 text-white font-medium rounded-lg hover:bg-surface-600 transition-colors">
            View Vault
          </button>
        </motion.div>
      </div>
    </div>
  );
}
