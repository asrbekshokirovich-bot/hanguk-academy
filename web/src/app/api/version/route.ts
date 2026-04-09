import { NextResponse } from 'next/server';

export async function GET() {
  // Simulates a database query for the latest production configuration.
  return NextResponse.json({
    latest_version: "1.0.1",
    download_url: "https://hanguk-academy.vercel.app/app-release.apk",
  });
}
