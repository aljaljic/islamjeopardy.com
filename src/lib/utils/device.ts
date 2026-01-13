import { browser } from '$app/environment';

export function isIOS(): boolean {
	if (!browser) return false;
	return /iPad|iPhone|iPod/.test(navigator.userAgent) || 
		(navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1); // iPad on iOS 13+
}

// Detect if running inside Capacitor native app (not just iOS Safari)
export function isCapacitorApp(): boolean {
	if (!browser) return false;
	// Capacitor injects this global when running in native app
	const win = window as Window & { Capacitor?: { isNativePlatform?: () => boolean } };
	return !!win.Capacitor?.isNativePlatform?.();
}

// Check if user is on mobile (iOS or Android)
export function isMobile(): boolean {
	if (!browser) return false;
	return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ||
		(navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
}
