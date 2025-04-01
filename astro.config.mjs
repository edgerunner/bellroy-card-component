import { defineConfig } from "astro/config";
import elmstronaut from "elmstronaut";

export default defineConfig({
  integrations: [elmstronaut()],
});
