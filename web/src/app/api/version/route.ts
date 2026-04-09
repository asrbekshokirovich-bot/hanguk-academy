import { NextResponse } from 'next/server';

export async function GET() {
  let dynamicHash = "EXPECTED_HASH_FALLBACK";

  try {
    // Dynamically retrieve the latest hash directly from the CI pipeline release assets
    const hashRes = await fetch(
      "https://github.com/asrbekshokirovich-bot/hanguk-academy/releases/latest/download/hanguk_academy.apk.sha256",
      { cache: "no-store" } // Always grab fresh hash, do not cache stale OTA keys
    );
    if (hashRes.ok) {
      dynamicHash = (await hashRes.text()).trim();
    }
  } catch (e) {
    console.error("Failed to dynamically fetch latest APK Hash", e);
  }

  // Simulates a database query for the latest production configuration.
  return NextResponse.json({
    latest_version: "1.0.1",
    download_url: "https://github.com/asrbekshokirovich-bot/hanguk-academy/releases/latest/download/hanguk_academy.apk",
    sha256_checksum: dynamicHash,
  });
}
