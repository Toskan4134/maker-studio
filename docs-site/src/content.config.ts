import { defineCollection } from "astro:content";
import { docsSchema } from "@astrojs/starlight/schema";
import { makerStudioDocsLoader } from "./lib/docs-loader";

export const collections = {
  docs: defineCollection({ loader: makerStudioDocsLoader(), schema: docsSchema() }),
};
