import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { company, role, experienceLevel, userProfile } = await req.json();

    const authHeader = req.headers.get("Authorization")!;
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: authError } = await supabaseClient.auth.getUser();
    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    let analysis;
    try {
      analysis = await generateWithGroq(company, role, experienceLevel, userProfile);
    } catch (error) {
      console.error("Groq failed, using fallback:", error);
      analysis = getFallbackAnalysis(company, role);
    }

    // Save to dream_company_goals
    const { data: saved, error: dbError } = await supabaseClient
      .from("dream_company_goals")
      .insert({
        user_id: user.id,
        company,
        role,
        experience_level: experienceLevel,
        you_have: analysis.youHave,
        you_need: analysis.youNeed,
        reality_check: analysis.realityCheck,
        steps: analysis.steps,
        current_step: 0,
        is_active: true,
      })
      .select()
      .single();

    if (dbError) throw dbError;

    return new Response(
      JSON.stringify({ goal: saved, analysis }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Edge function error:", error);
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
async function generateWithGroq(
  company: string,
  role: string,
  experienceLevel: string,
  userProfile: any
) {
  const apiKey = Deno.env.get("GROQ_API_KEY");
  console.log("Groq key present:", !!apiKey);
  if (!apiKey) throw new Error("Groq key not configured");

  const prompt = `You are a career expert helping a student land their dream job.
Return ONLY valid JSON. No prose, no markdown fences.

A student wants to become a ${role} at ${company}.
Experience level: ${experienceLevel}
Their existing profile:
- Interests: ${(userProfile?.interests || []).join(", ") || "Not specified"}
- Values: ${(userProfile?.values || []).join(", ") || "Not specified"}
- Strengths: ${(userProfile?.strengths || []).join(", ") || "Not specified"}

Return this exact JSON:
{
  "youHave": ["skill1", "skill2", "skill3"],
  "youNeed": [
    {"skill": "Skill Name", "level": "beginner"}
  ],
  "realityCheck": "One honest sentence about realistic timeline.",
  "steps": [
    {
      "order": 1,
      "title": "STEP TITLE IN CAPS",
      "detail": "Specific actionable description.",
      "taskCount": 8,
      "resourceCount": 3,
      "status": "active"
    }
  ]
}

Rules:
- youHave: 2-4 skills the student likely already has based on their profile
- youNeed: 3-5 critical missing skills for this specific role at this company
- realityCheck: honest, warm, not discouraging — give a timeframe
- steps: exactly 6 steps, first is "active", rest are "locked"
- steps must be specific to ${company} and ${role}
- taskCount between 6-15, resourceCount between 2-6`;

  // AbortController gives us a hard timeout on the fetch itself
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 20000); // 20s

  try {
    const response = await fetch(
      "https://api.groq.com/openai/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "llama-3.3-70b-versatile",
          max_tokens: 1500,
          temperature: 0.7,
          messages: [{ role: "user", content: prompt }],
        }),
        signal: controller.signal,
      }
    );

    clearTimeout(timeoutId);

    if (!response.ok) {
      const err = await response.text();
      throw new Error(`Groq ${response.status}: ${err}`);
    }

    const data = await response.json();
    const content = data.choices[0].message.content;
    const cleaned = content
      .replace(/```json\n?/g, "")
      .replace(/```\n?/g, "")
      .trim();

    console.log("Groq responded successfully");
    return JSON.parse(cleaned);
  } catch (err: any) {
    clearTimeout(timeoutId);
    if (err.name === "AbortError") {
      throw new Error("Groq API timed out after 20 seconds");
    }
    throw err;
  }
}

function getFallbackAnalysis(company: string, role: string) {
  return {
    youHave: ["Problem Solving", "Communication", "Adaptability"],
    youNeed: [
      { skill: "Technical Foundation", level: "beginner" },
      { skill: "Industry Knowledge", level: "beginner" },
      { skill: "Company-Specific Skills", level: "intermediate" },
    ],
    realityCheck: `Landing a ${role} role at ${company} typically takes 6-12 months of focused preparation.`,
    steps: [
      { order: 1, title: "CORE FOUNDATIONS", detail: `Master the fundamental skills required for ${role} at ${company}.`, taskCount: 10, resourceCount: 4, status: "active" },
      { order: 2, title: "BUILD YOUR SKILLS", detail: "Develop the technical and soft skills specific to this role.", taskCount: 12, resourceCount: 5, status: "locked" },
      { order: 3, title: "REAL PROJECTS", detail: "Build portfolio projects that demonstrate your capabilities.", taskCount: 8, resourceCount: 3, status: "locked" },
      { order: 4, title: "NETWORK ACTIVELY", detail: `Connect with ${company} employees and attend relevant events.`, taskCount: 6, resourceCount: 2, status: "locked" },
      { order: 5, title: "INTERVIEW PREP", detail: "Practice common interview questions and technical assessments.", taskCount: 15, resourceCount: 6, status: "locked" },
      { order: 6, title: "THE FINAL PUSH", detail: "Polish your application, resume, and cover letter specifically for this role.", taskCount: 7, resourceCount: 3, status: "locked" },
    ],
  };
}