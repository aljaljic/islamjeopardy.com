import adapterCloudflare from '@sveltejs/adapter-cloudflare';
import adapterStatic from '@sveltejs/adapter-static';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

const isIOS = process.env.BUILD_TARGET === 'ios';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		adapter: isIOS
			? adapterStatic({
					pages: 'build',
					assets: 'build',
					fallback: 'index.html',
					precompress: false,
					strict: false
				})
			: adapterCloudflare()
	},
	preprocess: vitePreprocess()
};

export default config;
