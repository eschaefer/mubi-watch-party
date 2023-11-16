import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";
import webExtension from "@samrum/vite-plugin-web-extension";
import createReScriptPlugin from "@jihchi/vite-plugin-rescript";
import path from "path";
import { getManifest } from "./src/manifest";

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
	const env = loadEnv(mode, process.cwd(), "");

	return {
		plugins: [
			react(),
			createReScriptPlugin(),
			webExtension({
				manifest: getManifest(Number(env.MANIFEST_VERSION)),
			}),
		],
		resolve: {
			alias: {
				"~": path.resolve(__dirname, "./src"),
			},
		},
	};
});
