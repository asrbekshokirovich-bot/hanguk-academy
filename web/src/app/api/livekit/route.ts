import { AccessToken } from 'livekit-server-sdk';
import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

export async function GET(req: NextRequest) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized access. Must be logged in.' }, { status: 401 });
  }

  const room = req.nextUrl.searchParams.get('room');

  if (!room) {
    return NextResponse.json({ error: 'Missing "room"' }, { status: 400 });
  }

  // Define placeholders or fetch from .env
  const apiKey = process.env.LIVEKIT_API_KEY || 'dev_key';
  const apiSecret = process.env.LIVEKIT_API_SECRET || 'dev_secret_please_change_this_for_production_use';
  
  const identity = user.email || `student-${user.id.substring(0, 8)}`;

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
