"use client";

import React, { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';

export default function WatermarkOverlay() {
  const [stampText, setStampText] = useState("Loading Identity...");
  const supabase = createClient();

  useEffect(() => {
    async function loadIdentity() {
      const { data: { session } } = await supabase.auth.getSession();
      if (session?.user?.email) {
        setStampText(`${session.user.email} - HANGUK ACADEMY CONFIDENTIAL`);
      } else {
        setStampText("ANON_VIEWER - HANGUK ACADEMY CONFIDENTIAL");
      }
    }
    loadIdentity();
  }, [supabase]);

  return (
    <div className="fixed inset-0 pointer-events-none z-[9999] overflow-hidden opacity-[0.08] flex flex-wrap justify-between items-center select-none" aria-hidden="true">
      {Array.from({ length: 48 }).map((_, i) => (
        <div 
          key={i} 
          className="p-8 transform -rotate-[30deg] text-white whitespace-nowrap text-xl font-bold tracking-widest mix-blend-overlay"
        >
          {stampText}
        </div>
      ))}
    </div>
  );
}
