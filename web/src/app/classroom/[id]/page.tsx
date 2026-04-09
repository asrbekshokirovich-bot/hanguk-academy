"use client";

import { useEffect, useState } from 'react';
import {
  LiveKitRoom,
  VideoConference,
  GridLayout,
  ParticipantTile,
  RoomAudioRenderer,
  ControlBar,
  useTracks,
  AudioConference,
} from '@livekit/components-react';
import '@livekit/components-styles';
import { useParams } from 'next/navigation';
import WatermarkOverlay from '@/components/WatermarkOverlay';

export default function ClassroomPage() {
  const params = useParams();
  const room = (params?.id as string) || 'default-room';
  const [token, setToken] = useState("");
  
  // Note: For a real project, point this to your explicit LiveKit Cloud URL.
  // Example: wss://your-project.livekit.cloud
  const liveKitUrl = process.env.NEXT_PUBLIC_LIVEKIT_URL || 'wss://your-placeholder.livekit.cloud';

  useEffect(() => {
    (async () => {
      try {
        const resp = await fetch(`/api/livekit?room=${room}`);
        const data = await resp.json();
        setToken(data.token);
      } catch (e) {
        console.error(e);
      }
    })();
  }, [room]);

  if (token === "") {
    return (
      <div className="flex h-screen w-full items-center justify-center bg-surface-900 text-brand-400">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-brand-400"></div>
      </div>
    );
  }

  return (
    <div className="relative h-screen w-full bg-surface-900 overflow-hidden" data-lk-theme="default">
      {/* 
        DRM overlay is positioned absolutely on top. 
        It applies pointer-events-none and mix-blend-mode to dynamically print the user's email diagonally over the video player stream, hindering direct, clean screen recording. 
      */}
      <WatermarkOverlay />
      
      <LiveKitRoom
        video={true}
        audio={true}
        token={token}
        serverUrl={liveKitUrl}
        // Use the default VideoConference component from LiveKit
        // which includes a robust pre-built layout for group video.
        className="w-full h-full relative z-10"
      >
        {/* Render group video and controls */}
        <VideoConference />
        {/* Render audio output */}
        <RoomAudioRenderer />
      </LiveKitRoom>
    </div>
  );
}
