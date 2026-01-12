import { browser } from '$app/environment';

export function isIOS(): boolean {
	if (!browser) return false;
	return /iPad|iPhone|iPod/.test(navigator.userAgent) || 
		(navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1); // iPad on iOS 13+
}
