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
    // Anti-Tamper: MutationObserver ensures the DOM nodes cannot be deleted via DevTools without triggering a harsh reset.
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.removedNodes.length > 0) {
          console.warn("Watermark tampering detected. Reloading secure context.");
          window.location.reload();
        }
      });
    });

    const watermarkContainer = document.getElementById('watermark-container');
    if (watermarkContainer) {
      observer.observe(watermarkContainer, { childList: true, subtree: true });
    }

    return () => {
      observer.disconnect();
    };
  }, [supabase]);

  return (
    <div id="watermark-container" className="fixed inset-0 pointer-events-none z-[9999] overflow-hidden opacity-[0.08] flex flex-wrap justify-between items-center select-none" aria-hidden="true">
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
