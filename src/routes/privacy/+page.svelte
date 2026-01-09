<script lang="ts">
	import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card';
</script>

<svelte:head>
	<title>Privacy Policy - Islamic Jeopardy</title>
</svelte:head>

<div class="container mx-auto px-4 py-8 max-w-4xl">
	<Card class="border-2 shadow-lg">
		<CardHeader>
			<CardTitle class="text-3xl">Privacy Policy</CardTitle>
			<p class="text-sm text-muted-foreground">Last updated: January 2025</p>
		</CardHeader>
		<CardContent class="prose prose-sm max-w-none space-y-6">
			<section>
				<h2 class="text-xl font-semibold mb-3">1. Introduction</h2>
				<p class="text-muted-foreground">
					Welcome to Islamic Jeopardy ("we," "our," or "us"). We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and safeguard your information when you use our website and services.
				</p>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">2. Information We Collect</h2>
				<p class="text-muted-foreground mb-2">We collect the following types of information:</p>
				<ul class="list-disc list-inside text-muted-foreground space-y-1">
					<li><strong>Account Information:</strong> When you create an account, we collect your email address, username, and display name.</li>
					<li><strong>Game Data:</strong> Games you create, play history, scores, and ratings.</li>
					<li><strong>Usage Data:</strong> How you interact with our service, including pages visited and features used.</li>
					<li><strong>Device Information:</strong> Browser type, device type, and operating system for service optimization.</li>
				</ul>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">3. How We Use Your Information</h2>
				<p class="text-muted-foreground mb-2">We use your information to:</p>
				<ul class="list-disc list-inside text-muted-foreground space-y-1">
					<li>Provide and maintain our trivia game service</li>
					<li>Allow you to create and share trivia games</li>
					<li>Display leaderboards and game statistics</li>
					<li>Send important service-related notifications</li>
					<li>Improve and optimize our platform</li>
					<li>Respond to your feedback and support requests</li>
				</ul>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">4. Data Storage and Security</h2>
				<p class="text-muted-foreground">
					Your data is stored securely using Supabase, a trusted database provider with industry-standard security measures. We implement appropriate technical and organizational measures to protect your personal data against unauthorized access, alteration, or destruction.
				</p>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">5. Data Sharing</h2>
				<p class="text-muted-foreground mb-2">We do not sell your personal data. We may share limited information in these circumstances:</p>
				<ul class="list-disc list-inside text-muted-foreground space-y-1">
					<li><strong>Public Game Content:</strong> Games you create and publish are visible to other users.</li>
					<li><strong>Leaderboards:</strong> Your display name and scores may appear on public leaderboards.</li>
					<li><strong>Legal Requirements:</strong> When required by law or to protect our rights.</li>
				</ul>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">6. Your Rights</h2>
				<p class="text-muted-foreground mb-2">You have the right to:</p>
				<ul class="list-disc list-inside text-muted-foreground space-y-1">
					<li>Access your personal data</li>
					<li>Correct inaccurate data</li>
					<li>Delete your account and associated data</li>
					<li>Export your data</li>
					<li>Opt out of non-essential communications</li>
				</ul>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">7. Cookies and Local Storage</h2>
				<p class="text-muted-foreground">
					We use cookies and local storage to maintain your session, remember your preferences, and track game progress. These are essential for the service to function properly.
				</p>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">8. Children's Privacy</h2>
				<p class="text-muted-foreground">
					Our service is designed to be family-friendly. Children under 13 should use the service under parental supervision. We do not knowingly collect personal information from children under 13 without parental consent.
				</p>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">9. Changes to This Policy</h2>
				<p class="text-muted-foreground">
					We may update this privacy policy from time to time. We will notify you of any significant changes by posting the new policy on this page and updating the "Last updated" date.
				</p>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">10. Contact Us</h2>
				<p class="text-muted-foreground">
					If you have any questions about this privacy policy or our data practices, please contact us through our <a href="/feedback" class="text-primary hover:underline">feedback page</a>.
				</p>
			</section>
		</CardContent>
	</Card>
</div>
