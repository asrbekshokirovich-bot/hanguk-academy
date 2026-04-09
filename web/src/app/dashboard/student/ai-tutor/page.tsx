"use client";

import { useState } from 'react';
import { Brain, Sparkles, Send } from "lucide-react";
import ReactMarkdown from 'react-markdown';

export default function AITutorPage() {
  const [transcript, setTranscript] = useState("");
  const [summary, setSummary] = useState("");
  const [isGenerating, setIsGenerating] = useState(false);

  const handleGenerate = async () => {
    if (!transcript.trim()) return;
    setIsGenerating(true);
    setSummary("");
    
    try {
      const res = await fetch('/api/ai/summarize', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ transcript })
      });
      const data = await res.json();
      if (data.summary) {
        setSummary(data.summary);
      } else {
        setSummary("Error: Could not generate smart notes.");
      }
    } catch (e) {
      setSummary("Network Error occurred.");
    } finally {
      setIsGenerating(false);
    }
  };

  return (
    <div className="flex flex-col gap-8 max-w-5xl mx-auto h-[calc(100vh-100px)]">
      <div>
        <h1 className="text-3xl font-bold text-white mb-2 flex items-center gap-3">
          <Brain className="w-8 h-8 text-brand-400" /> AI Practice & Smart Notes
        </h1>
        <p className="text-slate-400">Paste your raw class transcripts here to generate instant, structured Korean study guides using Gemini 2.5 Flash.</p>
      </div>

      <div className="flex flex-col lg:flex-row gap-6 flex-1 min-h-0">
        {/* Input Pane */}
        <div className="glass-card p-6 flex flex-col gap-4 rounded-2xl w-full lg:w-1/2 border border-slate-700/50">
          <h3 className="text-lg font-bold text-white">Raw Transcript</h3>
          <textarea 
            value={transcript}
            onChange={(e) => setTranscript(e.target.value)}
            className="flex-1 w-full bg-slate-900/50 rounded-xl border border-slate-700/50 p-4 text-slate-300 focus:outline-none focus:border-brand-500 resize-none"
            placeholder="Paste raw audio transcript here (e.g., from LiveKit Egress or an external file)..."
          />
          <button 
            onClick={handleGenerate}
            disabled={isGenerating || !transcript.trim()}
            className="w-full py-4 bg-brand-500 text-surface-900 font-bold rounded-xl hover:bg-brand-400 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 transition-all"
          >
            {isGenerating ? (
              <><div className="animate-spin rounded-full h-5 w-5 border-b-2 border-surface-900"></div> Generating...</>
            ) : (
              <><Sparkles className="w-5 h-5" /> Generate Smart Notes</>
            )}
          </button>
        </div>

        {/* Output Pane */}
        <div className="glass-card p-6 flex flex-col gap-4 rounded-2xl w-full lg:w-1/2 border border-brand-500/20 shadow-[0_0_30px_rgba(45,212,191,0.05)] overflow-y-auto">
          <h3 className="text-lg font-bold text-brand-400 flex items-center gap-2">
            AI Extracted Notes 
          </h3>
          <div className="flex-1 bg-slate-900/30 rounded-xl border border-slate-700/30 p-6 text-slate-200 overflow-y-auto prose prose-invert prose-brand max-w-none">
            {summary ? (
              <ReactMarkdown>{summary}</ReactMarkdown>
            ) : (
              <div className="h-full flex flex-col items-center justify-center text-slate-500 text-center">
                <Send className="w-12 h-12 mb-4 opacity-20" />
                <p>Your structured notes will appear here.</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
