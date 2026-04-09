"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";

export default function LoginPage() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen p-6">
      <Link href="/" className="absolute top-8 left-8 flex items-center gap-2 text-slate-400 hover:text-white transition-colors">
        <ChevronLeft className="w-5 h-5" /> Back
      </Link>
      
      <motion.div 
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="glass-card w-full max-w-md p-8 rounded-2xl flex flex-col gap-6"
      >
        <div className="text-center">
          <h2 className="text-3xl font-bold text-white mb-2">Welcome Back</h2>
          <p className="text-slate-400 text-sm">Enter your credentials to access your cohort.</p>
        </div>

        <form className="flex flex-col gap-4 mt-4" onSubmit={(e) => e.preventDefault()}>
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-slate-300">Email Address</label>
            <input 
              disabled
              type="email" 
              placeholder="student@example.com"
              className="px-4 py-3 bg-surface-900/50 border border-slate-700 rounded-xl focus:border-brand-500 focus:ring-1 focus:ring-brand-500 outline-none text-white transition-all disabled:opacity-50"
            />
          </div>
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-slate-300">Password</label>
            <input 
              disabled
              type="password" 
              placeholder="••••••••"
              className="px-4 py-3 bg-surface-900/50 border border-slate-700 rounded-xl focus:border-brand-500 focus:ring-1 focus:ring-brand-500 outline-none text-white transition-all disabled:opacity-50"
            />
          </div>

          <button disabled className="mt-4 px-6 py-3 bg-brand-500 text-surface-900 font-bold rounded-xl hover:bg-brand-400 transition-colors disabled:opacity-50 shadow-[0_0_20px_rgba(45,212,191,0.2)]">
            Sign In with Supabase
          </button>
        </form>

        <p className="text-center text-sm text-slate-400 mt-4">
          Don&apos;t have an account? <Link href="/register" className="text-brand-400 hover:text-brand-300 underline">Enroll Now</Link>
        </p>
      </motion.div>
    </div>
  );
}
