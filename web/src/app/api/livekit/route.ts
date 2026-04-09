import { AccessToken } from 'livekit-server-sdk';
import { NextRequest, NextResponse } from 'next/server';

export async function GET(req: NextRequest) {
  const room = req.nextUrl.searchParams.get('room');
  const participant = req.nextUrl.searchParams.get('participant');

  if (!room) {
    return NextResponse.json({ error: 'Missing "room"' }, { status: 400 });
  }

  // Define placeholders or fetch from .env
  const apiKey = process.env.LIVEKIT_API_KEY || 'dev_key';
  const apiSecret = process.env.LIVEKIT_API_SECRET || 'dev_secret_please_change_this_for_production_use';
  
  const identity = participant || `student-${Math.floor(Math.random() * 1000)}`;

  const at = new AccessToken(apiKey, apiSecret, {
    identity: identity,
  });

  at.addGrant({
    roomJoin: true,
    room: room,
    canPublish: true,
    canSubscribe: true,
    canPublishData: true,
  });

  const token = await at.toJwt();

  return NextResponse.json({ token });
}
