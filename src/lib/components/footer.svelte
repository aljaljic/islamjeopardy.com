<script lang="ts">
	let year = new Date().getFullYear();
</script>

<footer class="border-t bg-slate-50 dark:bg-slate-900 mt-auto">
	<div class="h-px bg-gray-600 dark:bg-gray-400 w-full"></div>
	<div class="max-w-7xl mx-auto px-4 sm:px-8 py-16">
		<div class="flex lg:items-start md:flex-row md:flex-nowrap flex-wrap flex-col">
			<!-- Logo and Description -->
			<div class="w-64 flex-shrink-0 md:mx-0 mx-auto text-center md:text-left">
				<a aria-current="page" class="flex justify-center md:justify-start items-center gap-2" href="/">
					<div class="relative flex items-center justify-center w-12 h-12 rounded-xl gradient-primary shadow-lg shadow-primary/25">
						<!-- Mosque icon matching navigation -->
						<svg class="h-6 w-6 text-white" viewBox="0 0 64 64" fill="currentColor" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
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
					<span class="text-2xl font-medium tracking-tight text-gradient">Islamic Jeopardy</span>
				</a>
				<p class="mt-4 text-md text-muted-foreground">
					Test your knowledge of Islam through fun and engaging trivia games
				</p>
				<p class="mt-1 text-sm text-muted-foreground">
					Copyright © {year} - All rights reserved
				</p>
			</div>

			<!-- Links Section -->
			<div class="flex-grow flex flex-wrap md:pl-24 -mb-10 md:mt-0 mt-10 text-center">
				<!-- Quick Links -->
				<div class="lg:w-1/3 md:w-1/2 w-full px-4">
					<div class="font-semibold tracking-widest text-sm md:text-left mb-3 text-foreground">LINKS</div>
					<div class="flex flex-col justify-center items-center md:items-start gap-2 mb-10 text-base">
						<a class="transition-colors hover:text-foreground/80 text-muted-foreground text-md hover:text-primary" href="/play-now">Play Now</a>
						<a class="transition-colors hover:text-foreground/80 text-muted-foreground text-md hover:text-primary" href="/leaderboard">Leaderboard</a>
						<a class="transition-colors hover:text-foreground/80 text-muted-foreground text-md hover:text-primary" href="/feedback">Feedback</a>
					</div>
				</div>

				<!-- Legal -->
				<div class="lg:w-1/3 md:w-1/2 w-full px-4">
					<div class="font-semibold tracking-widest text-sm md:text-left mb-3 text-foreground">LEGAL</div>
					<div class="flex flex-col justify-center items-center md:items-start gap-2 mb-10 text-base">
						<a class="transition-colors hover:text-foreground/80 text-muted-foreground text-md hover:text-primary" href="/terms">Terms of Service</a>
						<a class="transition-colors hover:text-foreground/80 text-muted-foreground text-md hover:text-primary" href="/privacy">Privacy Policy</a>
					</div>
				</div>

				<!-- Support -->
				<div class="lg:w-1/3 md:w-1/2 w-full px-4">
					<div class="font-semibold tracking-widest text-sm md:text-left mb-3 text-foreground">SUPPORT</div>
					<div class="flex flex-col justify-center items-center md:items-start gap-2 mb-10 text-base">
						<a class="transition-colors hover:text-foreground/80 text-muted-foreground text-md hover:text-primary" href="/feedback">Contact Us</a>
						<a href="mailto:support@islamjeopardy.com" target="_blank" class="transition-colors hover:text-foreground/80 text-muted-foreground text-md hover:text-primary">Email Support</a>
						<a href="https://twitter.com/adel_ljaljic" target="_blank" rel="noopener noreferrer" class="transition-colors hover:text-foreground/80 text-muted-foreground text-md hover:text-primary" aria-label="Twitter">
							<svg fill="currentColor" viewBox="0 0 24 24" class="h-5 w-5">
								<path d="M8.29 20.251c7.547 0 11.675-6.253 11.675-11.675 0-.178 0-.355-.012-.53A8.348 8.348 0 0022 5.92a8.19 8.19 0 01-2.357.646 4.118 4.118 0 001.804-2.27 8.224 8.224 0 01-2.605.996 4.107 4.107 0 00-6.993 3.743 11.65 11.65 0 01-8.457-4.287 4.106 4.106 0 001.27 5.477A4.072 4.072 0 012.8 9.713v.052a4.105 4.105 0 003.292 4.022 4.095 4.095 0 01-1.853.07 4.108 4.108 0 003.834 2.85A8.233 8.233 0 012 18.407a11.616 11.616 0 006.29 1.84"></path>
							</svg>
						</a>
					</div>
				</div>

				<!-- Maker -->
				<div class="lg:w-1/3 md:w-1/2 w-full px-4">
					<div class="font-semibold tracking-widest text-sm md:text-left mb-3 text-foreground">BY MAKER OF ISLAMJEOPARDY</div>
					<div class="flex flex-col justify-center items-center md:items-start gap-2 mb-10 text-base">
						<a href="https://codedeen.com" target="_blank" rel="noopener noreferrer" class="transition-colors hover:text-foreground/80 text-muted-foreground text-md hover:text-primary">CodeDeen</a>
						<a href="https://svelteship.com" target="_blank" rel="noopener noreferrer" class="transition-colors hover:text-foreground/80 text-muted-foreground text-md hover:text-primary">SvelteShip</a>
						<a href="https://fastbatch.io" target="_blank" rel="noopener noreferrer" class="transition-colors hover:text-foreground/80 text-muted-foreground text-md hover:text-primary">FastBatch</a>
						<a href="https://postchad.com" target="_blank" rel="noopener noreferrer" class="transition-colors hover:text-foreground/80 text-muted-foreground text-md hover:text-primary">PostChad</a>
						<a href="https://tryhijab.com" target="_blank" rel="noopener noreferrer" class="transition-colors hover:text-foreground/80 text-muted-foreground text-md hover:text-primary">TryHijab</a>
					</div>
				</div>
			</div>
		</div>
	</div>
</footer>
