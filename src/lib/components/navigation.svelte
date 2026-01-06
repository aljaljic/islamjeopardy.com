<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import { Sheet } from '$lib/components/ui/sheet';
	import type { Session } from '@supabase/supabase-js';
	import {
		Menu,
		Home,
		Gamepad2,
		PlusCircle,
		FolderOpen,
		LogIn,
		UserPlus,
		LogOut
	} from 'lucide-svelte';
	import { page } from '$app/stores';

	let { session }: { session: Session | null } = $props();
	let mobileMenuOpen = $state(false);

	// Check if current path matches
	function isActive(path: string): boolean {
		return $page.url.pathname === path;
	}

	const navLinkClass = (path: string) =>
		`flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 touch-target no-tap-highlight ${
			isActive(path)
				? 'bg-primary/10 text-primary font-semibold'
				: 'hover:bg-muted active:bg-muted/80 text-foreground/80'
		}`;
</script>

<nav class="sticky top-0 z-40 border-b bg-card/95 backdrop-blur-md supports-[backdrop-filter]:bg-card/80 safe-top">
	<div class="container mx-auto flex h-16 items-center justify-between px-4">
		<!-- Logo -->
		<a href="/" class="flex items-center gap-2 group no-tap-highlight">
			<div class="relative flex items-center justify-center w-10 h-10 rounded-xl gradient-primary shadow-lg shadow-primary/25 group-active:scale-95 transition-transform">
				<!-- Mosque icon matching favicon -->
				<svg class="h-5 w-5 text-white" viewBox="0 0 64 64" fill="currentColor" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
					<!-- Base building structure -->
					<rect x="16" y="38" width="32" height="14" fill="currentColor" rx="1"/>
					<!-- Central dome on top - semicircle pointing up -->
					<path d="M32 38 Q 18 38, 18 30 Q 18 24, 24 22 Q 28 20, 32 20 Q 36 20, 40 22 Q 46 24, 46 30 Q 46 38, 32 38" fill="currentColor"/>
					<!-- Left minaret -->
					<rect x="10" y="32" width="3" height="20" fill="currentColor" rx="0.5"/>
					<circle cx="11.5" cy="32" r="2" fill="currentColor"/>
					<!-- Right minaret -->
					<rect x="51" y="32" width="3" height="20" fill="currentColor" rx="0.5"/>
					<circle cx="52.5" cy="32" r="2" fill="currentColor"/>
					<!-- Door -->
					<rect x="28" y="46" width="8" height="6" fill="none" stroke="currentColor" stroke-width="2"/>
					<!-- Crescent moon on top -->
					<path d="M32 18 C 30 18, 28.5 18.8, 28.5 20 C 28.5 21.2, 30 22, 32 22 C 34 22, 35.5 21.2, 35.5 20 C 35.5 18.8, 34 18, 32 18" fill="currentColor"/>
				</svg>
			</div>
			<span class="text-xl font-bold text-gradient hidden sm:inline">
				Islamic Jeopardy
			</span>
		</a>

		<!-- Desktop Navigation -->
		<div class="hidden items-center gap-2 md:flex">
			<a href="/" class={navLinkClass('/')}>
				<Home class="h-4 w-4" />
				<span>Home</span>
			</a>

			{#if session}
				<a href="/games/new" class={navLinkClass('/games/new')}>
					<PlusCircle class="h-4 w-4" />
					<span>Create</span>
				</a>
				<a href="/games/my-games" class={navLinkClass('/games/my-games')}>
					<FolderOpen class="h-4 w-4" />
					<span>My Games</span>
				</a>
				<form method="POST" action="/auth/logout" class="ml-2">
					<Button variant="ghost" type="submit" class="gap-2 touch-target">
						<LogOut class="h-4 w-4" />
						<span>Logout</span>
					</Button>
				</form>
			{:else}
				<a href="/auth/login">
					<Button variant="ghost" class="gap-2 touch-target">
						<LogIn class="h-4 w-4" />
						<span>Login</span>
					</Button>
				</a>
				<a href="/auth/signup">
					<Button class="gap-2 gradient-primary border-0 text-white shadow-lg shadow-primary/25 active:shadow-primary/15 transition-all touch-target press-effect">
						<UserPlus class="h-4 w-4" />
						<span>Sign Up</span>
					</Button>
				</a>
			{/if}
		</div>

		<!-- Mobile Menu Button -->
		<Button
			variant="ghost"
			size="icon"
			class="md:hidden touch-target press-effect"
			onclick={() => (mobileMenuOpen = true)}
			aria-label="Open menu"
		>
			<Menu class="h-6 w-6" />
		</Button>
	</div>
</nav>

<!-- Mobile Sheet Menu -->
<Sheet bind:open={mobileMenuOpen} side="left">
	<nav class="flex flex-col gap-1">
		<a href="/" class={navLinkClass('/')} onclick={() => (mobileMenuOpen = false)}>
			<Home class="h-5 w-5" />
			<span>Home</span>
		</a>
		<a href="/play-now" class={navLinkClass('/play-now')} onclick={() => (mobileMenuOpen = false)}>
			<Gamepad2 class="h-5 w-5" />
			<span>Play Now</span>
		</a>

		{#if session}
			<hr class="my-3 border-border" />
			<a href="/games/new" class={navLinkClass('/games/new')} onclick={() => (mobileMenuOpen = false)}>
				<PlusCircle class="h-5 w-5" />
				<span>Create Game</span>
			</a>
			<a href="/games/my-games" class={navLinkClass('/games/my-games')} onclick={() => (mobileMenuOpen = false)}>
				<FolderOpen class="h-5 w-5" />
				<span>My Games</span>
			</a>
			<hr class="my-3 border-border" />
			<form method="POST" action="/auth/logout">
				<button
					type="submit"
					class="flex w-full items-center gap-3 px-4 py-3 rounded-xl text-destructive hover:bg-destructive/10 active:bg-destructive/20 transition-colors touch-target"
				>
					<LogOut class="h-5 w-5" />
					<span>Logout</span>
				</button>
			</form>
		{:else}
			<hr class="my-3 border-border" />
			<a href="/auth/login" class={navLinkClass('/auth/login')} onclick={() => (mobileMenuOpen = false)}>
				<LogIn class="h-5 w-5" />
				<span>Login</span>
			</a>
			<a href="/auth/signup" onclick={() => (mobileMenuOpen = false)}>
				<button class="flex w-full items-center gap-3 px-4 py-3 rounded-xl gradient-primary text-white font-semibold shadow-lg shadow-primary/25 active:shadow-primary/15 transition-all touch-target">
					<UserPlus class="h-5 w-5" />
					<span>Sign Up</span>
				</button>
			</a>
		{/if}
	</nav>
</Sheet>
