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
      "summary": "2-3 sentences describing what this person does day-to-day, the impact they have, and what makes it meaningful.",
      "matchReason": "2-3 sentences referencing THIS student's actual answers — explain specifically why their interests, values and strengths make this a strong fit.",
      "fitScore": 82,
      "requiredSkills": [
        {"name": "Skill Name", "level": "beginner|intermediate|advanced"}
      ],
      "outlook": "2-3 honest sentences about job market demand, salary range, and growth trajectory.",
      "roadmap": [
        {
          "order": 1,
          "title": "Step title",
          "detail": "Detailed, specific, actionable guidance — at least 3 sentences explaining what to do, how to do it, and why it matters at this stage.",
          "resources": [
            {
              "name": "Full course or resource name",
              "platform": "Coursera|YouTube|Udemy|freeCodeCamp|Khan Academy|edX|Kaggle|GitHub|Book|Website",
              "url": "https://actual-url.com",
              "isFree": true
            }
          ]
        }
      ]
    }
  ]
}

Rules:
- fitScore between 60-95 (realistic — not 100%)
- 10-30 requiredSkills per career with honest levels
- roadmap must have between 10 and 30 steps per career — be thorough
- Each roadmap step detail must be at least 2-3 sentences
- Each roadmap step must have 1-3 resources — real, specific, accessible courses or materials
- Resources must have real URLs that actually exist — no made-up links
- Prefer free resources (Coursera free audit, YouTube, freeCodeCamp, Khan Academy, Kaggle) but paid is fine if it's the best option
- Steps should progress logically: foundations → skills → practice → portfolio → networking → job search → interview → landing the role
- matchReason must reference the student's specific answers
- Avoid clichés like "follow your passion"
- Be realistic, warm, and encouraging`;
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
  const content = data.choices?.[0]?.message?.content ?? "";

  if (!content || typeof content !== "string" || !content.trim()) {
    console.warn("Roadmap response was empty; using fallback matches");
    return getFallbackMatches();
  }

  const parsed = parseModelJson(content);
  const matches = normalizeMatches(parsed);
  if (!matches) {
    console.warn("Roadmap response was invalid; using fallback matches");
    return getFallbackMatches();
  }
  return matches;
}

function parseModelJson(content: string) {
  const cleaned = content
    .replace(/```json\n?/g, "")
    .replace(/```\n?/g, "")
    .trim();

  const candidates = [cleaned];
  const extractedCandidates = extractJsonCandidates(cleaned);
  candidates.push(...extractedCandidates);

  for (const candidate of candidates) {
    try {
      return JSON.parse(candidate);
    } catch {
      const withQuotedKeys = candidate.replace(
        /([{,]\s*)([A-Za-z0-9_]+)(\s*:)/g,
        '$1"$2"$3'
      );

      try {
        return JSON.parse(withQuotedKeys);
      } catch {
        // try next candidate
      }
    }
  }

  return null;
}

function extractJsonCandidates(text: string) {
  const candidates: string[] = [];
  const markers = ["matches", "\"matches\"", "data", "\"data\""];

  for (const marker of markers) {
    const index = text.indexOf(marker);
    if (index < 0) continue;

    const openBrace = text.lastIndexOf("{", index);
    const openBracket = text.lastIndexOf("[", index);
    const startIndex = Math.max(openBrace, openBracket);

    if (startIndex < 0) continue;

    const candidate = extractBalancedJson(text, startIndex);
    if (candidate) {
      candidates.push(candidate);
    }
  }

  const generic = extractBalancedJson(text, text.indexOf("{"));
  if (generic) {
    candidates.push(generic);
  }

  const genericArray = extractBalancedJson(text, text.indexOf("["));
  if (genericArray) {
    candidates.push(genericArray);
  }

  return [...new Set(candidates)];
}

function extractBalancedJson(text: string, startIndex: number) {
  if (startIndex < 0) return null;

  const startChar = text[startIndex];
  if (startChar !== "{" && startChar !== "[") return null;

  let depth = 0;
  let inString = false;
  let escaped = false;
  const endChar = startChar === "{" ? "}" : "]";

  for (let i = startIndex; i < text.length; i++) {
    const char = text[i];

    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (char === "\\") {
        escaped = true;
      } else if (char === '"') {
        inString = false;
      }
      continue;
    }

    if (char === '"') {
      inString = true;
      continue;
    }

    if (char === startChar) {
      depth++;
    } else if (char === endChar) {
      depth--;
      if (depth === 0) {
        return text.slice(startIndex, i + 1);
      }
    }
  }

  return null;
}

function normalizeMatches(payload: unknown) {
  if (Array.isArray(payload)) {
    return payload;
  }

  if (payload && typeof payload === "object") {
    const data = payload as Record<string, unknown>;
    if (Array.isArray(data.matches)) {
      return data.matches;
    }
    if (Array.isArray(data.data)) {
      return data.data;
    }
    if (data.data && typeof data.data === "object") {
      const nested = data.data as Record<string, unknown>;
      if (Array.isArray(nested.matches)) {
        return nested.matches;
      }
    }
  }

  return null;
}

function getFallbackMatches() {
  return [
    {
      title: "UX Designer",
      summary:
        "UX Designers research how people use products and craft interfaces that feel natural, intuitive, and satisfying. They sit at the intersection of psychology, design, and technology — translating user needs into experiences that actually work. It's a career that rewards curiosity about people and a sharp eye for detail.",
      matchReason:
        "Your creative thinking and interest in how people behave makes UX a natural fit. People who value making a real difference tend to thrive in UX because the work has visible, tangible impact on real users every single day. Your strength in explaining things clearly is also a core UX skill — you'll present design decisions to teams and stakeholders constantly.",
      fitScore: 82,
      requiredSkills: [
        { name: "UI Design", level: "beginner" },
        { name: "User Research", level: "beginner" },
        { name: "Wireframing", level: "beginner" },
        { name: "Figma", level: "beginner" },
        { name: "Prototyping", level: "intermediate" },
      ],
      outlook:
        "UX design has strong and growing global demand — every digital product needs designers. Entry-level roles typically start around $50-70k in Western markets, with senior designers earning $90-130k+. Remote work is very common, which opens global opportunities even from Nigeria or Africa.",
      roadmap: [
        {
          order: 1,
          title: "Understand what UX actually is",
          detail: "Before touching any tools, spend one week reading and watching. The goal is to understand that UX is about solving human problems, not making things look pretty. This foundation will shape every design decision you make going forward.",
          resources: [
            { name: "The Design of Everyday Things — Don Norman", platform: "Book", url: "https://www.amazon.com/Design-Everyday-Things-Revised-Expanded/dp/0465050654", isFree: false },
            { name: "Intro to UX Design — AJ&Smart", platform: "YouTube", url: "https://www.youtube.com/c/AJSmart", isFree: true },
            { name: "What is UX Design? — Google", platform: "YouTube", url: "https://www.youtube.com/watch?v=v6n1i0qojws", isFree: true },
          ],
        },
        {
          order: 2,
          title: "Complete the Google UX Design Certificate",
          detail: "This is the most respected free entry-level UX certificate available. It covers the full UX process: empathize, define, ideate, prototype, and test. It takes about 6 months at 10 hours/week but you can audit it free and go at your own pace.",
          resources: [
            { name: "Google UX Design Professional Certificate", platform: "Coursera", url: "https://www.coursera.org/professional-certificates/google-ux-design", isFree: true },
          ],
        },
        {
          order: 3,
          title: "Learn Figma from scratch",
          detail: "Figma is the industry standard design tool used at every major company. Start with Figma's own free tutorials, then move on to the official Figma YouTube channel. Give yourself 2-3 weeks of daily practice — the goal is to wireframe and prototype without getting stuck on the tool itself.",
          resources: [
            { name: "Figma for Beginners (4-part series)", platform: "YouTube", url: "https://www.youtube.com/watch?v=FTFaQWZBqQ8", isFree: true },
            { name: "Figma Crash Course", platform: "YouTube", url: "https://www.youtube.com/watch?v=jwCmIBJ8Jtc", isFree: true },
            { name: "Figma Official Tutorial Docs", platform: "Website", url: "https://help.figma.com/hc/en-us/categories/360002051613", isFree: true },
          ],
        },
        {
          order: 4,
          title: "Learn visual design fundamentals",
          detail: "You don't need to be an artist, but you need to understand the principles: typography, color theory, spacing, and visual hierarchy. These principles apply to every screen you'll ever design. Read and apply each principle to a small project as you go.",
          resources: [
            { name: "Refactoring UI — Adam Wathan & Steve Schoger", platform: "Book", url: "https://www.refactoringui.com", isFree: false },
            { name: "Design fundamentals for non-designers", platform: "YouTube", url: "https://www.youtube.com/watch?v=wIuVvCuiJhU", isFree: true },
            { name: "Canva Design School", platform: "Website", url: "https://www.canva.com/learn/design/", isFree: true },
          ],
        },
        {
          order: 5,
          title: "Conduct your first user interviews",
          detail: "Find 3 real people and ask them about an app they use daily. Ask open-ended questions and listen without guiding. The skill of asking questions that reveal real needs — not just feature requests — is what separates good UX designers from mediocre ones. Write up your findings in a clear document.",
          resources: [
            { name: "How to conduct user interviews — NNGroup", platform: "YouTube", url: "https://www.youtube.com/watch?v=Qq3OiHQ-HCU", isFree: true },
            { name: "User Interviews 101 — Nielsen Norman Group", platform: "Website", url: "https://www.nngroup.com/articles/user-interviews/", isFree: true },
          ],
        },
        {
          order: 6,
          title: "Build your first portfolio case study",
          detail: "Pick an app with a known usability problem and redesign it using the full UX process: research, define the problem, ideate, wireframe, prototype, test. Document every step in detail. One thorough case study is worth more than ten shallow ones — hiring managers read these carefully.",
          resources: [
            { name: "How to create a UX case study", platform: "YouTube", url: "https://www.youtube.com/watch?v=pRBGhBbPqik", isFree: true },
            { name: "UX Portfolio tips — Sarah Doody", platform: "YouTube", url: "https://www.youtube.com/c/SarahDoody", isFree: true },
          ],
        },
        {
          order: 7,
          title: "Learn accessibility and inclusive design",
          detail: "Understanding WCAG accessibility guidelines puts you ahead of most junior designers. Learn about contrast ratios, screen reader compatibility, and designing for different abilities. Many companies now legally require accessible products — knowing this makes you significantly more hireable.",
          resources: [
            { name: "Introduction to Web Accessibility — W3C", platform: "edX", url: "https://www.edx.org/course/web-accessibility-introduction", isFree: true },
            { name: "Accessibility fundamentals — Google", platform: "Website", url: "https://web.dev/accessibility/", isFree: true },
          ],
        },
        {
          order: 8,
          title: "Build a second case study in a different domain",
          detail: "If your first case study was an e-commerce app, do a health app or a productivity tool next. This shows range and adaptability. Two strong, detailed case studies are enough to start applying for junior roles — quality always beats quantity.",
          resources: [
            { name: "Daily UI challenge for inspiration", platform: "Website", url: "https://www.dailyui.co", isFree: true },
            { name: "Mobbin — real app design patterns for reference", platform: "Website", url: "https://mobbin.com", isFree: true },
          ],
        },
        {
          order: 9,
          title: "Create your portfolio website",
          detail: "Build a clean portfolio site that showcases your case studies. It doesn't need to be fancy — it needs to be clear and load fast. Recruiters spend 30 seconds on a portfolio, so make those seconds count. Include a short About section and an easy way to contact you.",
          resources: [
            { name: "Build a portfolio on Framer (free)", platform: "Website", url: "https://www.framer.com", isFree: true },
            { name: "Webflow University", platform: "Website", url: "https://university.webflow.com", isFree: true },
            { name: "Best UX portfolio examples — UX Collective", platform: "Website", url: "https://uxdesign.cc", isFree: true },
          ],
        },
        {
          order: 10,
          title: "Join UX communities and get feedback",
          detail: "Share your work on Dribbble, Behance, and the UX subreddit. Join Slack communities like Design Community and UX Mastery. Ask for feedback ruthlessly — every critique makes your work better. Connect with designers on LinkedIn and comment meaningfully on their posts.",
          resources: [
            { name: "r/userexperience — Reddit UX community", platform: "Website", url: "https://www.reddit.com/r/userexperience/", isFree: true },
            { name: "UX Collective — articles and community", platform: "Website", url: "https://uxdesign.cc", isFree: true },
            { name: "Dribbble", platform: "Website", url: "https://dribbble.com", isFree: true },
          ],
        },
        {
          order: 11,
          title: "Do a usability audit of 10 apps you use",
          detail: "Pick 10 apps or websites you use regularly and write a mini UX teardown of each. What works? What frustrates you? What would you change and why? These notes build your critical eye, give you talking points in interviews, and help you form strong UX opinions — something senior designers specifically look for in juniors.",
          resources: [
            { name: "How to do a UX audit — NNGroup", platform: "Website", url: "https://www.nngroup.com/articles/ux-expert-reviews/", isFree: true },
          ],
        },
        {
          order: 12,
          title: "Volunteer on a real project",
          detail: "Offer your UX skills to a nonprofit, student startup, or open source project. Real projects with real constraints and real stakeholders are worth more than any personal project. You'll build relationships, earn references, and discover how design works in a team environment.",
          resources: [
            { name: "Catchafire — volunteer design projects", platform: "Website", url: "https://www.catchafire.org", isFree: true },
            { name: "Open Source Design", platform: "Website", url: "https://opensourcedesign.net", isFree: true },
          ],
        },
        {
          order: 13,
          title: "Prepare your interview toolkit",
          detail: "UX interviews have three parts: portfolio walkthrough, design challenge, and cultural fit questions. Practice walking through each case study out loud and time yourself to 10 minutes per case. Research design challenge formats — many companies give you a problem and ask you to sketch a solution in 30-60 minutes. Prepare 3 stories about problems you've solved.",
          resources: [
            { name: "UX Interview questions and answers", platform: "YouTube", url: "https://www.youtube.com/watch?v=XRMzLbm7sGE", isFree: true },
            { name: "How to ace the UX design challenge", platform: "Website", url: "https://www.nngroup.com/articles/ux-design-interview-challenge/", isFree: true },
          ],
        },
        {
          order: 14,
          title: "Apply broadly — internships and junior roles",
          detail: "Apply to internships, junior roles, contract work, and freelance projects. Tailor your portfolio and cover letter to each company. Research each company's products before applying and mention something specific you'd improve. Don't wait until you feel ready — most junior designers feel underprepared when they land their first role.",
          resources: [
            { name: "LinkedIn Jobs — UX Designer", platform: "Website", url: "https://www.linkedin.com/jobs/ux-designer-jobs/", isFree: true },
            { name: "UX Jobs Board", platform: "Website", url: "https://www.uxjobsboard.com", isFree: true },
            { name: "Behance Jobs", platform: "Website", url: "https://www.behance.net/joblist", isFree: true },
          ],
        },
        {
          order: 15,
          title: "Land your first role and keep learning",
          detail: "Your first UX job is where your real education begins. Ask questions constantly, observe senior designers, and document your own growth. Set a goal to contribute to at least one shipped product in your first 6 months. After 12-18 months of real experience, you'll have enough to move to a mid-level role or specialize in UX research, product design, or design systems.",
          resources: [
            { name: "Nielsen Norman Group — UX career paths", platform: "Website", url: "https://www.nngroup.com/articles/ux-career-paths/", isFree: true },
            { name: "UX Collective newsletter", platform: "Website", url: "https://newsletter.uxdesign.cc", isFree: true },
          ],
        },
      ],
    },
    {
      title: "Data Scientist",
      summary:
        "Data Scientists extract meaningful insights from large, complex datasets to help organisations make smarter decisions. They combine statistics, programming, and domain knowledge to find patterns invisible to the naked eye. It's one of the most intellectually demanding careers in tech — and one of the most rewarding for people who love asking why.",
      matchReason:
        "Your analytical strengths and love of learning map directly to what data science demands every day. People who enjoy researching and exploring ideas tend to thrive because data science is fundamentally about curiosity — asking the right question is often harder than finding the answer. Your persistence is also critical: data rarely gives up its secrets without a fight.",
      fitScore: 75,
      requiredSkills: [
        { name: "Python", level: "intermediate" },
        { name: "Statistics", level: "intermediate" },
        { name: "SQL", level: "intermediate" },
        { name: "Data Visualization", level: "beginner" },
        { name: "Machine Learning", level: "beginner" },
      ],
      outlook:
        "Data science remains one of the fastest-growing fields globally — every industry now generates data and needs people who can make sense of it. Entry-level salaries range from $60-85k in Western markets. The field is evolving rapidly with AI, so continuous learning is essential, but that also means the ceiling is very high for people who stay current.",
      roadmap: [
        {
          order: 1,
          title: "Build Python foundations",
          detail: "Python is the primary language of data science. Focus on variables, data types, loops, functions, and file handling. Spend 4-6 weeks here and don't rush — weak Python foundations will slow you down in every step that follows.",
          resources: [
            { name: "Python for Everybody — Dr. Chuck (free audit)", platform: "Coursera", url: "https://www.coursera.org/specializations/python", isFree: true },
            { name: "Python Tutorial — freeCodeCamp", platform: "YouTube", url: "https://www.youtube.com/watch?v=rfscVS0vtbw", isFree: true },
            { name: "Automate the Boring Stuff with Python (free online)", platform: "Website", url: "https://automatetheboringstuff.com", isFree: true },
          ],
        },
        {
          order: 2,
          title: "Learn statistics — the real kind",
          detail: "Data science without statistics is guesswork. Study descriptive statistics, probability distributions, hypothesis testing, and regression. The goal isn't to become a mathematician — it's to understand what your data is actually telling you and when results are meaningful vs coincidence.",
          resources: [
            { name: "Statistics and Probability — Khan Academy", platform: "Khan Academy", url: "https://www.khanacademy.org/math/statistics-probability", isFree: true },
            { name: "Statistics for Data Science — StatQuest with Josh Starmer", platform: "YouTube", url: "https://www.youtube.com/@statquest", isFree: true },
            { name: "Think Stats — Allen Downey (free PDF)", platform: "Book", url: "https://greenteapress.com/thinkstats2/html/index.html", isFree: true },
          ],
        },
        {
          order: 3,
          title: "Master SQL",
          detail: "Almost all real-world data lives in relational databases. Learn SELECT, WHERE, GROUP BY, JOIN, and subqueries. Practice on real datasets. Strong SQL skills often impress interviewers more than machine learning knowledge — it's the most immediately useful skill in a real data team.",
          resources: [
            { name: "SQL Tutorial — Mode Analytics", platform: "Website", url: "https://mode.com/sql-tutorial/", isFree: true },
            { name: "SQLZoo interactive practice", platform: "Website", url: "https://sqlzoo.net", isFree: true },
            { name: "SQL for Data Science — Coursera", platform: "Coursera", url: "https://www.coursera.org/learn/sql-for-data-science", isFree: true },
          ],
        },
        {
          order: 4,
          title: "Master pandas and NumPy",
          detail: "These are the core Python libraries for data manipulation. Learn how to load, clean, filter, merge, and transform datasets. Data cleaning typically takes 70-80% of a data scientist's time on real projects — this skill is more valuable than it sounds and directly impacts the quality of every analysis you'll ever do.",
          resources: [
            { name: "Pandas course — Kaggle (free)", platform: "Kaggle", url: "https://www.kaggle.com/learn/pandas", isFree: true },
            { name: "NumPy tutorial — freeCodeCamp", platform: "YouTube", url: "https://www.youtube.com/watch?v=QUT1VHiLmmI", isFree: true },
            { name: "Python Data Science Handbook (free online)", platform: "Website", url: "https://jakevdp.github.io/PythonDataScienceHandbook/", isFree: true },
          ],
        },
        {
          order: 5,
          title: "Learn data visualization",
          detail: "Learn matplotlib and seaborn for Python charts, and explore Tableau Public for interactive dashboards. Practice by creating at least 5 different visualisation types from real datasets. Good visualisation is a communication skill — the goal is making patterns obvious to people who haven't seen the raw data.",
          resources: [
            { name: "Data Visualization — Kaggle (free)", platform: "Kaggle", url: "https://www.kaggle.com/learn/data-visualization", isFree: true },
            { name: "Tableau Public (free tool)", platform: "Website", url: "https://public.tableau.com", isFree: true },
            { name: "Matplotlib tutorial — Corey Schafer", platform: "YouTube", url: "https://www.youtube.com/playlist?list=PL-osiE80TeTvipOqomVEeZ1HRrcEvtZB_", isFree: true },
          ],
        },
        {
          order: 6,
          title: "Complete your first real data project",
          detail: "Find a dataset on a topic you genuinely care about — sports, music, climate, healthcare — and analyse it end to end. Clean it, explore it, visualise it, and write up your findings clearly. This is your first portfolio piece. The topic matters less than showing you can go from raw data to real insight.",
          resources: [
            { name: "Kaggle Datasets", platform: "Kaggle", url: "https://www.kaggle.com/datasets", isFree: true },
            { name: "Google Dataset Search", platform: "Website", url: "https://datasetsearch.research.google.com", isFree: true },
            { name: "UC Irvine ML Repository", platform: "Website", url: "https://archive.ics.uci.edu", isFree: true },
          ],
        },
        {
          order: 7,
          title: "Introduction to machine learning",
          detail: "Focus on understanding the concepts first: supervised vs unsupervised learning, overfitting, cross-validation, and evaluation metrics. Then implement in Python with scikit-learn. Don't try to memorize algorithms — focus on understanding when and why to use each one.",
          resources: [
            { name: "Machine Learning Specialization — Andrew Ng", platform: "Coursera", url: "https://www.coursera.org/specializations/machine-learning-introduction", isFree: true },
            { name: "Intro to Machine Learning — Kaggle (free)", platform: "Kaggle", url: "https://www.kaggle.com/learn/intro-to-machine-learning", isFree: true },
            { name: "scikit-learn documentation and tutorials", platform: "Website", url: "https://scikit-learn.org/stable/tutorial/", isFree: true },
          ],
        },
        {
          order: 8,
          title: "Build a machine learning project",
          detail: "Apply ML to a real problem — predicting house prices, classifying emails, or sentiment analysis on tweets are classic starting points. Use scikit-learn and document your process thoroughly: what problem did you solve, what approach did you take, what were your results? Publish on GitHub. This becomes your second portfolio piece.",
          resources: [
            { name: "Intermediate Machine Learning — Kaggle", platform: "Kaggle", url: "https://www.kaggle.com/learn/intermediate-machine-learning", isFree: true },
            { name: "Hands-On ML with scikit-learn (free first chapters)", platform: "Book", url: "https://github.com/ageron/handson-ml3", isFree: true },
          ],
        },
        {
          order: 9,
          title: "Practice on Kaggle competitions",
          detail: "Enter at least 3 Kaggle competitions — even finishing last teaches you more than any course. Read the winning solutions of past competitions. The community is generous with knowledge. Kaggle also builds your public profile which many recruiters actively check.",
          resources: [
            { name: "Kaggle Competitions", platform: "Kaggle", url: "https://www.kaggle.com/competitions", isFree: true },
            { name: "How to get started on Kaggle — Abhishek Thakur", platform: "YouTube", url: "https://www.youtube.com/watch?v=GJBg0NU-Umc", isFree: true },
          ],
        },
        {
          order: 10,
          title: "Learn deep learning basics",
          detail: "Deep learning is increasingly central to modern data science. Learn what neural networks are, how they're trained, and when they're appropriate to use — they're not always the best tool. fast.ai's course is the most practical free deep learning resource available.",
          resources: [
            { name: "Practical Deep Learning for Coders — fast.ai (free)", platform: "Website", url: "https://course.fast.ai", isFree: true },
            { name: "Deep Learning Specialization — Andrew Ng", platform: "Coursera", url: "https://www.coursera.org/specializations/deep-learning", isFree: true },
            { name: "Neural Networks — 3Blue1Brown", platform: "YouTube", url: "https://www.youtube.com/playlist?list=PLZHQObOWTQDNU6R1_67000Dx_ZCJB-3pi", isFree: true },
          ],
        },
        {
          order: 11,
          title: "Build your GitHub portfolio",
          detail: "Create a clean GitHub profile with at least 3 well-documented projects. Each repo should have a clear README explaining the project, dataset, methodology, key findings, and instructions to reproduce the results. Recruiters and hiring managers look at GitHub — make it easy for them to understand your work in under 2 minutes.",
          resources: [
            { name: "How to build a data science portfolio — Ken Jee", platform: "YouTube", url: "https://www.youtube.com/watch?v=1aXk2RViq3c", isFree: true },
            { name: "GitHub for beginners", platform: "YouTube", url: "https://www.youtube.com/watch?v=RGOj5yH7evk", isFree: true },
          ],
        },
        {
          order: 12,
          title: "Learn SQL for advanced analytics",
          detail: "Go beyond basic SQL into window functions, CTEs, and performance optimization. These are the skills that separate a junior data analyst from a real data scientist in a production environment. Practice with LeetCode's database problems.",
          resources: [
            { name: "Advanced SQL — Mode Analytics", platform: "Website", url: "https://mode.com/sql-tutorial/introduction-to-sql/", isFree: true },
            { name: "LeetCode Database problems", platform: "Website", url: "https://leetcode.com/problemset/database/", isFree: true },
          ],
        },
        {
          order: 13,
          title: "Network in the data community",
          detail: "Join Kaggle discussions, the data science subreddit, and LinkedIn data science groups. Attend PyData virtual conferences and local meetups. Connect with data scientists and ask thoughtful questions about their work. Many junior data science roles are filled through referrals — your network matters as much as your skills.",
          resources: [
            { name: "r/datascience — Reddit", platform: "Website", url: "https://www.reddit.com/r/datascience/", isFree: true },
            { name: "Towards Data Science — Medium publication", platform: "Website", url: "https://towardsdatascience.com", isFree: true },
            { name: "PyData conference talks (free on YouTube)", platform: "YouTube", url: "https://www.youtube.com/@PyDataTV", isFree: true },
          ],
        },
        {
          order: 14,
          title: "Prepare for technical interviews",
          detail: "Data science interviews typically include a SQL test, Python/statistics questions, a take-home project, and a case study presentation. Practice SQL problems on LeetCode and HackerRank. Review statistics fundamentals. Do at least 2 mock take-home projects under time pressure. The ability to explain your reasoning clearly is as important as getting the right answer.",
          resources: [
            { name: "Data Science Interview Questions — Glassdoor", platform: "Website", url: "https://www.glassdoor.com/Interview/data-scientist-interview-questions-SRCH_KO0,14.htm", isFree: true },
            { name: "Ace the Data Science Interview — book", platform: "Book", url: "https://www.acethedatascienceinterview.com", isFree: false },
            { name: "HackerRank SQL practice", platform: "Website", url: "https://www.hackerrank.com/domains/sql", isFree: true },
          ],
        },
        {
          order: 15,
          title: "Apply for roles and keep building",
          detail: "Apply broadly — junior data analyst, data scientist, and ML engineer roles all build toward the same long-term career. Many successful data scientists started as data analysts. Don't wait until you feel completely ready — apply with what you have and keep learning in parallel. Your first role is where your real education begins.",
          resources: [
            { name: "LinkedIn Jobs — Data Scientist", platform: "Website", url: "https://www.linkedin.com/jobs/data-scientist-jobs/", isFree: true },
            { name: "Kaggle Jobs board", platform: "Kaggle", url: "https://www.kaggle.com/jobs", isFree: true },
            { name: "Built In — tech job board", platform: "Website", url: "https://builtin.com/jobs", isFree: true },
          ],
        },
      ],
    },
    {
      title: "Product Manager",
      summary:
        "Product Managers decide what gets built, why it matters, and whether it's working. They sit at the intersection of users, business, and engineering — translating messy real-world problems into clear product decisions. It's a career that demands both analytical rigour and deep human empathy, rewarding people who can hold the big picture while caring deeply about the details.",
      matchReason:
        "Your leadership instincts and big-picture thinking align well with what great product managers do every day. People who value making a real difference thrive in PM because the work is directly connected to outcomes that affect real users. Your ability to listen, understand different perspectives, and bring people together is also a core PM skill — the role is fundamentally about alignment across teams.",
      fitScore: 68,
      requiredSkills: [
        { name: "Product Strategy", level: "intermediate" },
        { name: "Agile / Scrum", level: "beginner" },
        { name: "Data Analysis", level: "beginner" },
        { name: "User Research", level: "beginner" },
        { name: "Stakeholder Communication", level: "intermediate" },
      ],
      outlook:
        "Product management is one of the most sought-after roles in tech with strong compensation and influence. However, it's also competitive — most PMs come from adjacent roles or have an MBA. Entry is harder than other tech roles but the career ceiling is very high, with senior PMs often transitioning to VP, Director, or founder roles.",
      roadmap: [
        {
          order: 1,
          title: "Understand what product management actually is",
          detail: "Many people pursue PM without understanding how different it is from project management. Start by reading the definitive book on modern PM, then supplement with video content from practitioners. This foundation prevents the most common mistake aspiring PMs make — thinking the role is about managing people or projects rather than outcomes.",
          resources: [
            { name: "Inspired — Marty Cagan", platform: "Book", url: "https://www.amazon.com/INSPIRED-Create-Tech-Products-Customers/dp/1119387507", isFree: false },
            { name: "Lenny's Podcast — Product management deep dives", platform: "YouTube", url: "https://www.youtube.com/@LennysPodcast", isFree: true },
            { name: "What does a product manager actually do? — Product School", platform: "YouTube", url: "https://www.youtube.com/watch?v=yUOC-Y0f5ZQ", isFree: true },
          ],
        },
        {
          order: 2,
          title: "Learn the product development lifecycle",
          detail: "Study how products move from idea to launch: discovery, definition, design, development, testing, and release. Understand Agile, Scrum, and Kanban — these are the frameworks most product teams use. Knowing this process is table stakes for any PM role and will make every subsequent step easier.",
          resources: [
            { name: "Agile Fundamentals — Coursera (free audit)", platform: "Coursera", url: "https://www.coursera.org/learn/agile-development", isFree: true },
            { name: "Scrum Guide (official, free PDF)", platform: "Website", url: "https://scrumguides.org/scrum-guide.html", isFree: true },
            { name: "Product Management Fundamentals — LinkedIn Learning", platform: "Website", url: "https://www.linkedin.com/learning/", isFree: false },
          ],
        },
        {
          order: 3,
          title: "Develop user empathy through research",
          detail: "Great PMs are obsessed with users. Practice conducting user interviews — find 5 people who use a product you're interested in and ask open-ended questions about their experience. The skill of asking questions that reveal real needs rather than feature requests is one of the hardest and most valuable skills a PM can have.",
          resources: [
            { name: "How to conduct user interviews — UX Mastery", platform: "YouTube", url: "https://www.youtube.com/watch?v=Qq3OiHQ-HCU", isFree: true },
            { name: "Just Enough Research — Erika Hall", platform: "Book", url: "https://abookapart.com/products/just-enough-research", isFree: false },
          ],
        },
        {
          order: 4,
          title: "Learn to write product specs and PRDs",
          detail: "A Product Requirements Document is how PMs communicate what to build and why. Study examples of real PRDs, then practice writing your own for a feature you'd add to an existing product. Include the problem statement, user stories, success metrics, and out-of-scope items. Clear writing is one of the most underrated PM skills.",
          resources: [
            { name: "How to write a PRD — Lenny Rachitsky", platform: "Website", url: "https://www.lennysnewsletter.com/p/how-to-write-a-product-requirements", isFree: true },
            { name: "Product Spec templates — Notion", platform: "Website", url: "https://www.notion.so/templates/product-specs", isFree: true },
          ],
        },
        {
          order: 5,
          title: "Build basic data analysis skills",
          detail: "PMs make decisions based on data. Learn SQL enough to query a database and pull metrics. Understand key metrics: DAU/MAU, retention rate, conversion rate, and NPS. You don't need to be a data scientist, but you need to be data-literate enough to form and test hypotheses about user behaviour.",
          resources: [
            { name: "SQL for Product Managers — Mode Analytics", platform: "Website", url: "https://mode.com/sql-tutorial/", isFree: true },
            { name: "Metrics for product managers — Lenny Rachitsky", platform: "Website", url: "https://www.lennysnewsletter.com/p/north-star-metric", isFree: true },
            { name: "Google Analytics for Beginners", platform: "Website", url: "https://skillshop.exceedlms.com/student/catalog/list?category_ids=53-google-analytics", isFree: true },
          ],
        },
        {
          order: 6,
          title: "Study great products obsessively",
          detail: "Pick 5 products you admire and do a deep teardown of each. Why does each feature exist? What problem does it solve? What metric does it likely improve? What trade-offs did the team probably make? Write these up as product essays and share them publicly. This builds product intuition — something that's very hard to teach but essential for PM success.",
          resources: [
            { name: "Product teardowns — Lenny's Newsletter", platform: "Website", url: "https://www.lennysnewsletter.com", isFree: true },
            { name: "Stratechery — Ben Thompson product analysis", platform: "Website", url: "https://stratechery.com", isFree: false },
            { name: "Every product teardown — YouTube search", platform: "YouTube", url: "https://www.youtube.com/results?search_query=product+teardown", isFree: true },
          ],
        },
        {
          order: 7,
          title: "Learn prioritisation frameworks",
          detail: "PMs are constantly saying no to good ideas so they can focus on the best ones. Learn RICE (Reach, Impact, Confidence, Effort), MoSCoW, and the Kano model. Practice applying each to a real product scenario. Understanding when to use which framework — and knowing their limitations — separates thoughtful PMs from mechanical ones.",
          resources: [
            { name: "Product prioritisation frameworks — ProductPlan", platform: "Website", url: "https://www.productplan.com/learn/product-management-frameworks/", isFree: true },
            { name: "RICE scoring — Intercom", platform: "Website", url: "https://www.intercom.com/blog/rice-simple-prioritization-for-product-managers/", isFree: true },
          ],
        },
        {
          order: 8,
          title: "Get hands-on experience in a real product role",
          detail: "Join a student startup, hackathon, or open source project in a product coordination role. Even managing a small community or student project teaches you the fundamentals of coordinating people toward a goal under real constraints. Document everything you learn — these stories become interview gold.",
          resources: [
            { name: "Product Hunt — find early stage startups to join", platform: "Website", url: "https://www.producthunt.com", isFree: true },
            { name: "Hackathon websites — Devpost", platform: "Website", url: "https://devpost.com", isFree: true },
          ],
        },
        {
          order: 9,
          title: "Learn UX and design thinking basics",
          detail: "PMs work closely with designers and need to speak their language. Take a free design thinking course and learn wireframing basics. You don't need to design, but you need to critique designs intelligently. Understanding usability principles makes you a much better product partner to your design team.",
          resources: [
            { name: "Design Thinking — IDEO+Coursera", platform: "Coursera", url: "https://www.coursera.org/learn/design-thinking-innovation", isFree: true },
            { name: "Wireframing basics — Figma", platform: "Website", url: "https://www.figma.com/resource-library/wireframing/", isFree: true },
          ],
        },
        {
          order: 10,
          title: "Learn how to work with engineers",
          detail: "PMs who can't communicate with engineers struggle. Learn basic technical concepts: APIs, databases, front-end vs back-end, and system architecture. You don't need to code, but understanding how software is built helps you scope work realistically and earn engineering respect from day one.",
          resources: [
            { name: "How the internet works — Khan Academy", platform: "Khan Academy", url: "https://www.khanacademy.org/computing/computers-and-internet", isFree: true },
            { name: "Technical skills for PMs — Exponent", platform: "YouTube", url: "https://www.youtube.com/@tryexponent", isFree: true },
            { name: "The Pragmatic Programmer — Andrew Hunt", platform: "Book", url: "https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/", isFree: false },
          ],
        },
        {
          order: 11,
          title: "Build a portfolio of product thinking",
          detail: "Write product teardowns, feature pitches, and case studies and publish them on Medium or Substack. Pick real companies and propose a feature — include the problem, your research, success metrics, and your reasoning. This portfolio is often more valuable than a CV for getting your first PM role.",
          resources: [
            { name: "Medium — write and publish product essays", platform: "Website", url: "https://medium.com", isFree: true },
            { name: "Substack — build a product newsletter", platform: "Website", url: "https://substack.com", isFree: true },
          ],
        },
        {
          order: 12,
          title: "Learn about growth and metrics",
          detail: "Growth is increasingly central to product management. Understand pirate metrics (AARRR: Acquisition, Activation, Retention, Referral, Revenue) and how to run A/B tests. Build a habit of asking 'how would we measure success?' for every product decision you make.",
          resources: [
            { name: "Hacking Growth — Sean Ellis", platform: "Book", url: "https://www.amazon.com/Hacking-Growth-Fastest-Growing-Companies-Breakout/dp/045149721X", isFree: false },
            { name: "Growth metrics for PMs — Lenny Rachitsky", platform: "Website", url: "https://www.lennysnewsletter.com/p/what-is-good-retention-issue-29", isFree: true },
          ],
        },
        {
          order: 13,
          title: "Network intentionally with PMs",
          detail: "PM is a relationship-driven career. Connect with PMs on LinkedIn and ask for 20-minute informational chats. Join PM communities and attend virtual events. Many junior PM roles are filled through referrals from people who've seen your thinking — your network matters as much as your skills.",
          resources: [
            { name: "Lenny's Slack community (free tier)", platform: "Website", url: "https://www.lennysnewsletter.com/p/lenny-community", isFree: true },
            { name: "Mind the Product community", platform: "Website", url: "https://www.mindtheproduct.com", isFree: true },
            { name: "Product School free events", platform: "Website", url: "https://productschool.com/free-product-management-resources/", isFree: true },
          ],
        },
        {
          order: 14,
          title: "Prepare for PM interviews",
          detail: "PM interviews are unlike any other. They typically include product design questions, estimation questions, strategy questions, and behavioral questions. Practice the STAR format for behavioral questions. Do at least 10 mock interviews with peers or in PM communities. The goal is to think out loud clearly and confidently under pressure.",
          resources: [
            { name: "Decode and Conquer — Lewis Lin", platform: "Book", url: "https://www.lewis-lin.com/decode-and-conquer", isFree: false },
            { name: "Exponent PM interview practice", platform: "Website", url: "https://www.tryexponent.com", isFree: false },
            { name: "PM interview questions — YouTube", platform: "YouTube", url: "https://www.youtube.com/results?search_query=product+manager+interview+questions", isFree: true },
          ],
        },
        {
          order: 15,
          title: "Target the right entry points into PM",
          detail: "Breaking into PM directly is hard without experience. The best entry paths are APM programs at large companies, transitioning from an adjacent role like engineering, design, data, or customer success, or joining an early-stage startup where roles are more fluid. Focus on companies whose products you genuinely care about — that passion is visible in interviews.",
          resources: [
            { name: "APM programs list — Lenny Rachitsky", platform: "Website", url: "https://www.lennysnewsletter.com/p/the-ultimate-list-of-apm-programs", isFree: true },
            { name: "LinkedIn Jobs — Associate Product Manager", platform: "Website", url: "https://www.linkedin.com/jobs/associate-product-manager-jobs/", isFree: true },
          ],
        },
      ],
    },
  ];
}