import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
	appId: 'com.islamjeopardy.app',
	appName: 'Islamic Jeopardy',
	webDir: 'build',
	server: {
		androidScheme: 'https',
		iosScheme: 'https',
		url: 'https://islamjeopardy.com'
	},
	ios: {
		contentInset: 'automatic',
		preferredContentMode: 'mobile',
		backgroundColor: '#ffffff',
		scrollEnabled: true,
		allowsLinkPreview: false // Prevents 3D touch link previews
	},
	plugins: {
		SplashScreen: {
			launchAutoHide: true,
			backgroundColor: '#ffffff',
			showSpinner: false
		},
		Keyboard: {
			resize: 'body',
			resizeOnFullScreen: true
		}
	}
};

export default config;
