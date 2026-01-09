<script lang="ts">
	import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card';
</script>

<svelte:head>
	<title>Terms of Service - Islamic Jeopardy</title>
</svelte:head>

<div class="container mx-auto px-4 py-8 max-w-4xl">
	<Card class="border-2 shadow-lg">
		<CardHeader>
			<CardTitle class="text-3xl">Terms of Service</CardTitle>
			<p class="text-sm text-muted-foreground">Last updated: January 2025</p>
		</CardHeader>
		<CardContent class="prose prose-sm max-w-none space-y-6">
			<section>
				<h2 class="text-xl font-semibold mb-3">1. Acceptance of Terms</h2>
				<p class="text-muted-foreground">
					By accessing and using Islamic Jeopardy ("the Service"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the Service.
				</p>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">2. Description of Service</h2>
				<p class="text-muted-foreground">
					Islamic Jeopardy is an educational trivia game platform that allows users to test their knowledge of Islam through interactive quiz games. Users can play existing games, create their own games, and compete on leaderboards.
				</p>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">3. User Accounts</h2>
				<ul class="list-disc list-inside text-muted-foreground space-y-1">
					<li>You may play games without an account.</li>
					<li>Creating games requires a registered account.</li>
					<li>You are responsible for maintaining the security of your account.</li>
					<li>You must provide accurate information when creating an account.</li>
					<li>You may not share your account with others.</li>
				</ul>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">4. User-Generated Content</h2>
				<p class="text-muted-foreground mb-2">When creating games, you agree that:</p>
				<ul class="list-disc list-inside text-muted-foreground space-y-1">
					<li>All content must be accurate and appropriate for Islamic education.</li>
					<li>Content must not contain misinformation about Islam or Islamic teachings.</li>
					<li>Content must be respectful and family-friendly.</li>
					<li>You own or have the right to use any content you submit.</li>
					<li>We may remove content that violates these terms without notice.</li>
				</ul>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">5. Prohibited Conduct</h2>
				<p class="text-muted-foreground mb-2">You agree not to:</p>
				<ul class="list-disc list-inside text-muted-foreground space-y-1">
					<li>Create content that is offensive, hateful, or discriminatory</li>
					<li>Spread misinformation about Islamic teachings</li>
					<li>Use the Service for any illegal purpose</li>
					<li>Attempt to hack, disrupt, or damage the Service</li>
					<li>Create multiple accounts to manipulate scores or ratings</li>
					<li>Harass or abuse other users</li>
					<li>Use automated systems to access the Service</li>
				</ul>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">6. Intellectual Property</h2>
				<p class="text-muted-foreground">
					The Service, including its design, features, and content (excluding user-generated content), is owned by Islamic Jeopardy. You may not copy, modify, or distribute our intellectual property without permission. User-generated games remain the intellectual property of their creators, but by publishing them, you grant us a license to display and distribute them on the platform.
				</p>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">7. Disclaimer of Warranties</h2>
				<p class="text-muted-foreground">
					The Service is provided "as is" without warranties of any kind. We do not guarantee that the Service will be error-free, secure, or continuously available. While we strive for accuracy in Islamic content, we encourage users to verify information with qualified Islamic scholars.
				</p>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">8. Limitation of Liability</h2>
				<p class="text-muted-foreground">
					To the maximum extent permitted by law, Islamic Jeopardy shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the Service. Our total liability shall not exceed the amount you paid to use the Service (if any).
				</p>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">9. Termination</h2>
				<p class="text-muted-foreground">
					We reserve the right to suspend or terminate your account at any time for violations of these terms. You may also delete your account at any time. Upon termination, your right to use the Service ceases immediately.
				</p>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">10. Changes to Terms</h2>
				<p class="text-muted-foreground">
					We may modify these terms at any time. Continued use of the Service after changes constitutes acceptance of the new terms. We will make reasonable efforts to notify users of significant changes.
				</p>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">11. Governing Law</h2>
				<p class="text-muted-foreground">
					These terms shall be governed by and construed in accordance with applicable laws. Any disputes shall be resolved through good-faith negotiation or, if necessary, through appropriate legal channels.
				</p>
			</section>

			<section>
				<h2 class="text-xl font-semibold mb-3">12. Contact</h2>
				<p class="text-muted-foreground">
					For questions about these terms, please contact us through our <a href="/feedback" class="text-primary hover:underline">feedback page</a>.
				</p>
			</section>
		</CardContent>
	</Card>
</div>
