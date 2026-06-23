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
    const { profile, quiz } = await req.json();

    const authHeader = req.headers.get("Authorization")!;
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } }
    );

    const {
      data: { user },
      error: authError,
    } = await supabaseClient.auth.getUser();

    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Clear previous matches so each roadmap generation is fresh
    await supabaseClient
      .from("career_matches")
      .delete()
      .eq("user_id", user.id);

    let matches;
    let source = "ai";

    try {
      matches = await generateWithOpenAI(profile, quiz);
    } catch (error) {
      console.error("OpenAI failed, using fallback:", error);
      matches = getFallbackMatches();
      source = "fallback";
    }

    const { data: savedMatches, error: dbError } = await supabaseClient
      .from("career_matches")
      .insert(
        // deno-lint-ignore no-explicit-any
        matches.map((match: any) => ({
          user_id: user.id,
          title: match.title,
          summary: match.summary,
          match_reason: match.matchReason,
          fit_score: match.fitScore,
          required_skills: match.requiredSkills,
          outlook: match.outlook,
          roadmap: match.roadmap,
          source,
        }))
      )
      .select();

    if (dbError) throw dbError;

    return new Response(
      JSON.stringify({ matches: savedMatches, source }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Edge function error:", error);
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});

// deno-lint-ignore no-explicit-any
async function generateWithOpenAI(profile: any, quiz: any) {
  // Using Groq free tier instead of OpenAI
  const apiKey = Deno.env.get("GROQ_API_KEY");
  if (!apiKey) throw new Error("Groq key not configured");

  const systemPrompt = `You are a warm, encouraging career guidance counsellor for students.
Return ONLY valid JSON. No prose, no markdown fences, no explanation before or after the JSON.
Always return exactly 3 career matches.`;

  const userPrompt = `A student has completed a self-discovery quiz. Suggest exactly 3 personalised career paths.

Student profile:
- Name: ${profile.displayName || "Student"}
- Age band: ${profile.ageBand || "Unknown"}
- Education stage: ${profile.educationStage || "Unknown"}

Their quiz responses:
- Interests: ${(quiz.interests || []).join(", ") || "Not specified"}
- Values: ${(quiz.values || []).join(", ") || "Not specified"}
- Strengths: ${(quiz.strengths || []).join(", ") || "Not specified"}
- Work style: ${quiz.workStyle || "Not specified"}
- Vision: ${(quiz.vision || []).join(", ") || "Not specified"}

Return this exact JSON structure:
{
  "matches": [
    {
      "title": "Career Title (2-4 words)",
      "summary": "One sentence on what this person does day-to-day.",
      "matchReason": "One sentence referencing THIS student's actual answers — not generic.",
      "fitScore": 82,
      "requiredSkills": [
        {"name": "Skill Name", "level": "beginner"}
      ],
      "outlook": "One honest sentence about job market demand.",
      "roadmap": [
        {"order": 1, "title": "Step title", "detail": "Specific, actionable guidance."},
        {"order": 2, "title": "Step title", "detail": "Specific, actionable guidance."},
        {"order": 3, "title": "Step title", "detail": "Specific, actionable guidance."}
      ]
    }
  ]
}

Rules:
- fitScore between 60-95
- 2-4 requiredSkills per career
- Exactly 3 roadmap steps per career
- matchReason must reference the student's specific interests/values/strengths
- Avoid clichés like "follow your passion"
- Be realistic and encouraging, not corporate`;

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
        max_tokens: 2000,
        temperature: 0.7,
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt },
        ],
      }),
    }
  );

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
  const parsed = JSON.parse(cleaned);
  return parsed.matches;
}


function getFallbackMatches() {
  return [
    {
      title: "UX Designer",
      summary:
        "UX Designers research how people use products and create interfaces that feel natural and satisfying.",
      matchReason:
        "Your creative thinking and interest in how people behave makes UX design a strong natural fit.",
      fitScore: 82,
      requiredSkills: [
        { name: "UI Design", level: "beginner" },
        { name: "User Research", level: "beginner" },
      ],
      outlook:
        "Strong global demand with remote-friendly roles across tech, fintech, and health sectors.",
      roadmap: [
        {
          order: 1,
          title: "Learn the basics",
          detail:
            "Complete Google's free UX Design Certificate on Coursera. Focus on user research and wireframing.",
        },
        {
          order: 2,
          title: "Build a portfolio piece",
          detail:
            "Redesign an app you use daily. Document your process — research, sketches, prototype. This is your first case study.",
        },
        {
          order: 3,
          title: "Get real experience",
          detail:
            "Apply for internships or offer to help a local business with their website. One real project beats ten theoretical ones.",
        },
      ],
    },
    {
      title: "Data Scientist",
      summary:
        "Data Scientists find meaningful patterns in large datasets to help organisations make smarter decisions.",
      matchReason:
        "Your analytical strengths and love of learning translate directly into the data science skillset.",
      fitScore: 75,
      requiredSkills: [
        { name: "Python", level: "beginner" },
        { name: "Stats", level: "beginner" },
      ],
      outlook:
        "One of the fastest-growing roles globally — every industry needs people who can make sense of data.",
      roadmap: [
        {
          order: 1,
          title: "Start with Python",
          detail:
            "Complete Python for Everybody on Coursera. Focus on data types, loops, and functions before anything else.",
        },
        {
          order: 2,
          title: "Learn data tools",
          detail:
            "Pick up pandas and matplotlib on Kaggle's free courses. Work through real datasets from day one.",
        },
        {
          order: 3,
          title: "Complete a project",
          detail:
            "Analyse a public dataset on something you care about and publish it on GitHub. This is your portfolio.",
        },
      ],
    },
    {
      title: "Product Manager",
      summary:
        "Product Managers decide what gets built, why it matters, and whether it's working — bridging users, business, and engineering.",
      matchReason:
        "Your leadership instincts and big-picture thinking align well with what great product managers do.",
      fitScore: 68,
      requiredSkills: [
        { name: "Strategy", level: "intermediate" },
        { name: "Agile", level: "beginner" },
      ],
      outlook:
        "Highly valued in tech and startups — strong salary potential, but typically needs 1-2 years of adjacent experience first.",
      roadmap: [
        {
          order: 1,
          title: "Read the fundamentals",
          detail:
            "Start with 'Inspired' by Marty Cagan. It gives you the mental models every product manager needs.",
        },
        {
          order: 2,
          title: "Get hands-on exposure",
          detail:
            "Join a student startup, hackathon, or open-source project in a coordination role. Real exposure beats theory.",
        },
        {
          order: 3,
          title: "Document your thinking",
          detail:
            "Write product teardowns of apps you love and publish them online. This is your proof of thinking.",
        },
      ],
    },
  ];
}