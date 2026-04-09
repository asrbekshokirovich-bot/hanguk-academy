import { NextRequest, NextResponse } from 'next/server';
import { GoogleGenAI } from '@google/genai';

export async function POST(req: NextRequest) {
  try {
    const { transcript } = await req.json();
    
    if (!transcript) {
      return NextResponse.json({ error: 'Missing transcript' }, { status: 400 });
    }

    const ai = new GoogleGenAI({ 
      apiKey: process.env.GEMINI_API_KEY || 'AIzaSyAzszM7BVvNyWubIGmOEhm5Xl9_D6DEgPE' 
    });
    
    const prompt = `You are an elite Korean language AI tutor for Hanguk Academy. Summarize the following classroom video transcript into a highly structured markdown 'Smart Note'.
Use these strict sections:
1. **Core Phrases & Vocabulary:** (List Korean words, Romanization, and English meaning)
2. **Grammar Insight:** (Extract any grammar rules discussed)
3. **Actionable Practice:** (Give the student 2 sentences to practice building)

Transcript: 
"${transcript}"`;

    const response = await ai.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: prompt,
    });

    return NextResponse.json({ summary: response.text });
  } catch (error: any) {
    console.error("AI Generation Error:", error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
