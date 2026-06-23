import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

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
    const { jobTitle } = await req.json();

    const appId = Deno.env.get("ADZUNA_APP_ID");
    const appKey = Deno.env.get("ADZUNA_APP_KEY");

    let listings = [];
    let isFallback = false;

    if (appId && appKey) {
      // Try multiple country endpoints
      const countries = ["gb", "us", "za", "ng"];
      for (const country of countries) {
        try {
          const url =
            `https://api.adzuna.com/v1/api/jobs/${country}/search/1` +
            `?app_id=${appId}&app_key=${appKey}` +
            `&what=${encodeURIComponent(jobTitle)}&results_per_page=5` +
            `&content-type=application/json`;

          const res = await fetch(url);
          if (!res.ok) continue;
          const data = await res.json();

          if (data.results?.length > 0) {
            listings = data.results.map((job: any) => ({
              title: job.title ?? jobTitle,
              company: job.company?.display_name ?? "Company",
              location: job.location?.display_name ?? "Remote",
              salary:
                job.salary_min && job.salary_max
                  ? `£${Math.round(job.salary_min / 1000)}k – ${Math.round(
                      job.salary_max / 1000
                    )}k`
                  : null,
              url: job.redirect_url ?? null,
              description: job.description?.substring(0, 200) ?? null,
              postedAt: job.created ?? new Date().toISOString(),
            }));
            break;
          }
        } catch (_) {
          continue;
        }
      }
    }

    if (listings.length === 0) {
      listings = fallbackListings(jobTitle);
      isFallback = true;
    }

    return new Response(JSON.stringify({ listings, isFallback }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(
      JSON.stringify({
        listings: fallbackListings(""),
        isFallback: true,
        error: (error as Error).message,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

function fallbackListings(jobTitle: string) {
  const now = new Date();
  return [
    {
      title: `Senior ${jobTitle}`,
      company: "TechFlow Systems",
      location: "Remote / London",
      salary: "£55k – 70k",
      url: "https://www.linkedin.com/jobs",
      description: "Join our team to build products used by millions.",
      postedAt: new Date(now.getTime() - 2 * 60 * 60 * 1000).toISOString(),
    },
    {
      title: jobTitle,
      company: "Creative Pulse",
      location: "Manchester, UK",
      salary: "£40k – 50k",
      url: "https://www.linkedin.com/jobs",
      description: "Award-winning team looking for a passionate professional.",
      postedAt: new Date(now.getTime() - 5 * 60 * 60 * 1000).toISOString(),
    },
    {
      title: `Junior ${jobTitle}`,
      company: "Fintech Hub",
      location: "Lagos, Nigeria",
      salary: "₦800k – 1.2M",
      url: "https://www.linkedin.com/jobs",
      description: "Growing fintech team looking for talented individuals.",
      postedAt: new Date(now.getTime() - 24 * 60 * 60 * 1000).toISOString(),
    },
  ];
}