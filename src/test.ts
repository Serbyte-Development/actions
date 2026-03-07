import {emailTemplate, systemPrompt} from "./assets";
import OpenAI from "openai";
import "dotenv/config";

async function mockRun() {
  try {
    const openai = new OpenAI({apiKey: process.env.OPENAI_API_KEY});

    // Mock commits
    const commits = [{message: "fixed mobile nav bug"}, {message: "updated FAQ section"}, {message: "added checkout validation"}];

    // Create user content
    const commitMessages = commits.map(c => `- ${c.message.trim()}`).join("\n");

    // Hit OpenAI
    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {role: "system", content: systemPrompt},
        {role: "user", content: commitMessages}
      ]
    });
    console.log(completion);

    const summary = completion?.choices?.[0]?.message?.content?.trim();
    if (!summary) throw new Error("Empty OpenAI response");

    const siteLabel = "automedicskirkland.com";

    // Fill {{BODY}} and {{SITE_LABEL}} inside full email template
    const finalEmail = emailTemplate.replace("{{BODY}}", summary).replace(/{{SITE_LABEL}}/g, siteLabel);

    // Instead of core.setOutput, just log it
    console.log("🔥 FINAL EMAIL:");
    console.log(finalEmail);
  } catch (error) {
    console.error("❌ Test run failed:", error);
  }
}

mockRun();
