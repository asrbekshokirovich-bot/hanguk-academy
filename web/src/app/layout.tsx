import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  themeColor: "#0f172a", // Matches var(--color-surface-900)
};

export const metadata: Metadata = {
  title: "Hanguk Academy - Premium AI Korean Learning",
  description: "Master Korean with 3x/week live group classes, AI voice partners, and automated study notes.",
};


export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className={`${inter.className} min-h-screen bg-[var(--color-surface-900)] selection:bg-brand-500/30`}>
        <div className="fixed inset-0 -z-10 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-brand-900/20 via-surface-900 to-surface-900" />
        {children}
      </body>
    </html>
  );
}
