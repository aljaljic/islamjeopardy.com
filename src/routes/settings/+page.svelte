<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card';
	import { Input } from '$lib/components/ui/input';
	import { Settings, Trash2, AlertTriangle, LogOut } from 'lucide-svelte';
	import { enhance } from '$app/forms';
	import { toast } from '$lib/stores/toast';
	import type { ActionData } from './$types';

	let { form, data }: { form: ActionData; data: any } = $props();
	let showDeleteConfirmation = $state(false);
	let confirmationText = $state('');

	function handleDeleteClick() {
		showDeleteConfirmation = true;
		confirmationText = '';
	}

	function handleCancelDelete() {
		showDeleteConfirmation = false;
		confirmationText = '';
	}
</script>

<div class="container mx-auto max-w-2xl py-8 px-4">
	<Card class="border-2 shadow-xl">
		<CardHeader>
			<div class="flex items-center gap-3">
				<div class="flex h-12 w-12 items-center justify-center rounded-xl gradient-primary shadow-lg shadow-primary/25">
					<Settings class="h-6 w-6 text-white" />
				</div>
				<div>
					<CardTitle class="text-2xl">Account Settings</CardTitle>
					<CardDescription>Manage your account preferences</CardDescription>
				</div>
			</div>
		</CardHeader>
		<CardContent class="space-y-6">
			<!-- Account Information -->
			<div class="space-y-2">
				<h3 class="text-lg font-semibold">Account Information</h3>
				<div class="rounded-lg bg-muted p-4">
					<p class="text-sm text-muted-foreground">
						<span class="font-medium">Email:</span> {data.session?.user?.email}
					</p>
					<p class="text-sm text-muted-foreground mt-2">
						<span class="font-medium">User ID:</span> {data.session?.user?.id.slice(0, 8)}...
					</p>
				</div>
			</div>

			<hr class="border-border" />

			<!-- Danger Zone -->
			<div class="space-y-4">
				<div>
					<h3 class="text-lg font-semibold text-destructive">Danger Zone</h3>
					<p class="text-sm text-muted-foreground mt-1">
						Permanently delete your account and all associated data. This action cannot be undone.
					</p>
				</div>

				{#if !showDeleteConfirmation}
					<Button
						variant="destructive"
						onclick={handleDeleteClick}
						class="gap-2 touch-target"
					>
						<Trash2 class="h-4 w-4" />
						Delete Account
					</Button>
				{:else}
					<Card class="border-destructive/50 bg-destructive/5">
						<CardContent class="pt-6">
							<div class="space-y-4">
								<div class="flex items-start gap-3">
									<AlertTriangle class="h-5 w-5 text-destructive shrink-0 mt-0.5" />
									<div class="space-y-2">
										<p class="font-semibold text-destructive">Are you absolutely sure?</p>
										<p class="text-sm text-muted-foreground">
											This will permanently delete your account, all your games, ratings, and other data.
											This action cannot be undone.
										</p>
									</div>
								</div>

								<form
									method="POST"
									action="?/deleteAccount"
									use:enhance={() => {
										return async ({ result, update }) => {
											if (result.type === 'success') {
												toast.success('Account deleted successfully');
											} else if (result.type === 'failure') {
												toast.error(result.data?.error || 'Failed to delete account');
											}
											await update();
										};
									}}
								>
									<div class="space-y-4">
										<div class="space-y-2">
											<label for="confirmation" class="text-sm font-medium">
												Type <span class="font-mono font-bold">DELETE</span> to confirm:
											</label>
											<Input
												id="confirmation"
												name="confirmation"
												type="text"
												placeholder="DELETE"
												bind:value={confirmationText}
												required
												class="touch-target"
											/>
										</div>

										{#if form?.error}
											<div class="flex items-start gap-3 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
												<AlertTriangle class="h-5 w-5 shrink-0 mt-0.5" />
												<span>{form.error}</span>
											</div>
										{/if}

										<div class="flex gap-3">
											<Button
												type="submit"
												variant="destructive"
												disabled={confirmationText !== 'DELETE'}
												class="flex-1 gap-2 touch-target"
											>
												<Trash2 class="h-4 w-4" />
												Delete My Account
											</Button>
											<Button
												type="button"
												variant="outline"
												onclick={handleCancelDelete}
												class="touch-target"
											>
												Cancel
											</Button>
										</div>
									</div>
								</form>
							</div>
						</CardContent>
					</Card>
				{/if}
			</div>

			<hr class="border-border" />

			<!-- Logout -->
			<div class="space-y-2">
				<h3 class="text-lg font-semibold">Session</h3>
				<form method="POST" action="/auth/logout">
					<Button variant="outline" type="submit" class="gap-2 touch-target">
						<LogOut class="h-4 w-4" />
						Logout
					</Button>
				</form>
			</div>
		</CardContent>
	</Card>
</div>
