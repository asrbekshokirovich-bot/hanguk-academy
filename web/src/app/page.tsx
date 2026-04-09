"use client";

import { motion, Variants } from "framer-motion";
import { Mic, Video, Brain, Shield, ChevronRight } from "lucide-react";
import Link from "next/link";

export default function Home() {
  const containerVariants: Variants = {
    hidden: { opacity: 0 },
    visible: { 
      opacity: 1, 
      transition: { staggerChildren: 0.1 } 
    }
  };

  const itemVariants: Variants = {
    hidden: { y: 20, opacity: 0 },
    visible: { y: 0, opacity: 1, transition: { type: "spring", stiffness: 100 } }
  };

  return (
    <div className="flex flex-col items-center min-h-screen overflow-hidden">
      {/* Navigation */}
      <nav className="w-full max-w-7xl mx-auto px-6 py-6 flex justify-between items-center z-10 relative">
        <div className="text-2xl font-bold tracking-tighter">
          Hanguk<span className="text-gradient">Academy</span>
        </div>
        <div className="flex gap-4">
          <Link href="/login" className="px-5 py-2 text-sm font-medium hover:text-brand-300 transition-colors">
            Log In
          </Link>
          <Link href="/login" className="px-5 py-2 text-sm font-medium bg-brand-500 hover:bg-brand-400 text-surface-900 rounded-full transition-all shadow-[0_0_20px_rgba(45,212,191,0.4)]">
            Start Learning
          </Link>
        </div>
      </nav>

      {/* Hero Section */}
      <main className="flex-1 w-full max-w-7xl mx-auto px-6 pt-20 pb-32 flex flex-col items-center text-center relative z-10">
        <motion.div
          initial="hidden"
          animate="visible"
          variants={containerVariants}
          className="max-w-4xl"
        >
          <motion.div variants={itemVariants} className="inline-flex items-center gap-2 px-3 py-1 rounded-full glass border border-brand-500/30 text-brand-300 text-sm mb-8">
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-brand-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2 w-2 bg-brand-500"></span>
            </span>
            Enrollment open for the next 3x/week Cohort
          </motion.div>

          <motion.h1 variants={itemVariants} className="text-5xl md:text-7xl font-bold tracking-tight mb-8 leading-[1.1]">
            Master Korean with <br/>
            <span className="text-gradient">AI-Powered Immersion</span>
          </motion.h1>
          
          <motion.p variants={itemVariants} className="text-lg md:text-xl text-slate-300 mb-12 max-w-2xl mx-auto leading-relaxed">
            Join elite 3x a week live group classes. Practice anytime with our real-time OpenAI voice partner, and get automated AI study notes after every session.
          </motion.p>
          
          <motion.div variants={itemVariants} className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <Link href="/login" className="group px-8 py-4 bg-brand-500 text-surface-900 font-bold rounded-full text-lg hover:bg-brand-400 flex items-center gap-2 transition-all hover:scale-105 shadow-[0_0_30px_rgba(45,212,191,0.5)]">
              Join Cohort Now <ChevronRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
            </Link>
          </motion.div>
        </motion.div>

        {/* Features Grid */}
        <motion.div 
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6, duration: 0.8 }}
          className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mt-32 w-full text-left"
        >
          <FeatureCard 
            icon={<Video className="text-brand-400 w-6 h-6" />}
            title="Live WebRTC Classes"
            description="High-fidelity, ultra-low latency group lessons 3 times a week with expert instructors."
          />
          <FeatureCard 
            icon={<Shield className="text-brand-400 w-6 h-6" />}
            title="Premium Recorded Vault"
            description="All sessions are auto-recorded to the cloud. Protected by dynamic DRM watermarks."
          />
          <FeatureCard 
            icon={<Mic className="text-brand-400 w-6 h-6" />}
            title="AI Voice Partner"
            description="Practice speaking 24/7. Our real-time OpenAI tutor corrects your pronunciation instantly."
          />
          <FeatureCard 
            icon={<Brain className="text-brand-400 w-6 h-6" />}
            title="Auto Study Notes"
            description="Transcripts are analyzed by GPT-4o to generate bespoke vocabulary lists and quizzes."
          />
        </motion.div>
      </main>

      {/* Decorative Orbs */}
      <div className="absolute top-1/4 left-1/4 w-[500px] h-[500px] bg-brand-500/10 rounded-full blur-[120px] pointer-events-none" />
      <div className="absolute bottom-1/4 right-1/4 w-[600px] h-[600px] bg-indigo-500/10 rounded-full blur-[150px] pointer-events-none" />
    </div>
  );
}

function FeatureCard({ icon, title, description }: { icon: React.ReactNode, title: string, description: string }) {
  return (
    <div className="glass-card p-8 rounded-2xl flex flex-col gap-4 border border-slate-700/50 hover:border-brand-500/50 transition-colors group">
      <div className="p-3 bg-slate-800/50 rounded-lg w-fit group-hover:scale-110 transition-transform">
        {icon}
      </div>
      <h3 className="text-xl font-semibold text-slate-100">{title}</h3>
      <p className="text-slate-400 leading-relaxed text-sm">
        {description}
      </p>
    </div>
  );
}
