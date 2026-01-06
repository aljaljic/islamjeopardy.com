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
		LogOut,
		Sparkles
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
				<Sparkles class="h-5 w-5 text-white" />
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
