"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

export default function RegisterPage() {
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  const router = useRouter();
  const supabase = createClient();

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session) {
        router.push("/dashboard");
      }
    });
  }, [router, supabase.auth]);

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    
    // Create the pseudo-email mapping
    const pseudoEmail = `${phone.trim()}@hanguk.auth`;

    const { error } = await supabase.auth.signUp({
      email: pseudoEmail,
      password: password,
    });

    if (error) {
      // Forcefully strip 'email' from Supabase heuristic error responses to preserve phone-first locale.
      setError(error.message.replace(/email/gi, "phone number").replace(/Email/g, "Phone number"));
      setLoading(false);
    } else {
      router.push("/dashboard");
    }
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen p-6">
      <Link href="/login" className="absolute top-8 left-8 flex items-center gap-2 text-slate-400 hover:text-white transition-colors">
        <ChevronLeft className="w-5 h-5" /> Back to Login
      </Link>
      
      <motion.div 
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="glass-card w-full max-w-md p-8 rounded-2xl flex flex-col gap-6"
      >
        <div className="text-center">
          <h2 className="text-3xl font-bold text-white mb-2">Join the Cohort</h2>
          <p className="text-slate-400 text-sm">Create an account using your phone number.</p>
        </div>

        <form className="flex flex-col gap-4 mt-4" onSubmit={handleRegister}>
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-slate-300">Phone Number</label>
            <input 
              type="tel" 
              required
              placeholder="e.g. 5550199"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              className="px-4 py-3 bg-surface-900/50 border border-slate-700 rounded-xl focus:border-brand-500 focus:ring-1 focus:ring-brand-500 outline-none text-white transition-all"
            />
          </div>
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-slate-300">Password</label>
            <input 
              type="password" 
              required
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="px-4 py-3 bg-surface-900/50 border border-slate-700 rounded-xl focus:border-brand-500 focus:ring-1 focus:ring-brand-500 outline-none text-white transition-all"
            />
          </div>

          {error && (
            <div className="p-3 bg-red-500/10 border border-red-500/20 rounded-xl flex items-start gap-2 text-red-400 text-sm">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 flex-shrink-0 mt-0.5" viewBox="0 0 20 20" fill="currentColor">
                <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
              </svg>
              <span className="leading-tight">{error}</span>
            </div>
          )}

          <button 
            disabled={loading} 
            className="mt-4 px-6 py-3 bg-brand-500 text-surface-900 font-bold rounded-xl hover:bg-brand-400 transition-colors disabled:opacity-50 shadow-[0_0_20px_rgba(45,212,191,0.2)]"
          >
            {loading ? "Registering..." : "Create Account"}
          </button>
        </form>

        <p className="text-center text-sm text-slate-400 mt-4">
          Already have an account? <Link href="/login" className="text-brand-400 hover:text-brand-300 underline">Log In</Link>
        </p>
      </motion.div>
    </div>
  );
}
