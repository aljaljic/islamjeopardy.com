<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import { Input } from '$lib/components/ui/input';
	import {
		Card,
		CardContent,
		CardDescription,
		CardHeader,
		CardTitle
	} from '$lib/components/ui/card';
	import { Textarea } from '$lib/components/ui/textarea';
	import { Select } from '$lib/components/ui/select';
	import { Switch } from '$lib/components/ui/switch';
	import type { PageData, ActionData } from './$types';

	let { data, form }: { data: PageData; form: ActionData } = $props();

	// Wizard state
	let currentStep = $state(1);

	// Step 1: Basic Info
	let title = $state('');
	let description = $state('');
	let difficulty = $state<'kids' | 'beginner' | 'advanced'>('beginner');
	let isPublic = $state(true);

	// Step 2: Category Selection
	let selectedCategories = $state<
		Array<{
			category_id: string;
			name: string;
			category_type: string;
		}>
	>([]);

	// Step 3: Questions (organized by category and points)
	let questions = $state<
		Map<string, Map<number, { question_text: string; answer_text: string }>>
	>(new Map());

	const POINT_VALUES = [100, 200, 300, 400, 500];

	// Step navigation
	function canProceedToStep2() {
		return title.trim().length >= 3;
	}

	function canProceedToStep3() {
		return selectedCategories.length === 5;
	}

	function canProceedToStep4() {
		let count = 0;
		for (const [, pointMap] of questions) {
			for (const [, q] of pointMap) {
				if (q.question_text.trim() && q.answer_text.trim()) {
					count++;
				}
			}
		}
		return count === 25;
	}

	function getFilledQuestionCount() {
		let count = 0;
		for (const [, pointMap] of questions) {
			for (const [, q] of pointMap) {
				if (q.question_text.trim() && q.answer_text.trim()) {
					count++;
				}
			}
		}
		return count;
	}

	function toggleCategory(category: (typeof data.categories)[0]) {
		const index = selectedCategories.findIndex((c) => c.category_id === category.id);
		if (index >= 0) {
			selectedCategories = selectedCategories.filter((c) => c.category_id !== category.id);
		} else if (selectedCategories.length < 5) {
			selectedCategories = [
				...selectedCategories,
				{
					category_id: category.id,
					name: category.name,
					category_type: category.category_type
				}
			];
		}
	}

	function initializeQuestionsForCategories() {
		const newQuestions = new Map<
			string,
			Map<number, { question_text: string; answer_text: string }>
		>();
		for (const cat of selectedCategories) {
			const pointMap = new Map<number, { question_text: string; answer_text: string }>();
			for (const points of POINT_VALUES) {
				pointMap.set(points, { question_text: '', answer_text: '' });
			}
			newQuestions.set(cat.category_id, pointMap);
		}
		questions = newQuestions;
	}

	function getQuestionData() {
		const questionArray = [];
		for (const [categoryId, pointMap] of questions) {
			for (const [points, q] of pointMap) {
				questionArray.push({
					category_id: categoryId,
					points,
					question_text: q.question_text,
					answer_text: q.answer_text
				});
			}
		}
		return questionArray;
	}

	function updateQuestion(
		categoryId: string,
		points: number,
		field: 'question_text' | 'answer_text',
		value: string
	) {
		const map = questions.get(categoryId);
		if (map) {
			const existing = map.get(points);
			if (existing) {
				map.set(points, { ...existing, [field]: value });
				questions = new Map(questions);
			}
		}
	}
</script>

<div class="container mx-auto px-4 py-8">
	<!-- Progress indicator -->
	<div class="mb-8">
		<div class="flex items-center justify-center gap-2">
			{#each [1, 2, 3, 4] as step}
				<div class="flex items-center">
					<div
						class="flex h-10 w-10 items-center justify-center rounded-full text-sm font-medium
							{currentStep >= step
							? 'bg-primary text-primary-foreground'
							: 'bg-muted text-muted-foreground'}"
					>
						{step}
					</div>
					{#if step < 4}
						<div class="h-0.5 w-8 md:w-12 {currentStep > step ? 'bg-primary' : 'bg-muted'}"></div>
					{/if}
				</div>
			{/each}
		</div>
		<div class="mt-2 flex justify-center gap-4 text-xs md:gap-8 md:text-sm text-muted-foreground">
			<span class={currentStep >= 1 ? 'text-foreground' : ''}>Basics</span>
			<span class={currentStep >= 2 ? 'text-foreground' : ''}>Categories</span>
			<span class={currentStep >= 3 ? 'text-foreground' : ''}>Questions</span>
			<span class={currentStep >= 4 ? 'text-foreground' : ''}>Review</span>
		</div>
	</div>

	<!-- Step 1: Basic Info -->
	{#if currentStep === 1}
		<Card class="mx-auto max-w-2xl">
			<CardHeader>
				<CardTitle>Create New Game</CardTitle>
				<CardDescription>Start by setting up the basic details of your game</CardDescription>
			</CardHeader>
			<CardContent class="space-y-6">
				<div class="space-y-2">
					<label for="title" class="text-sm font-medium">Game Title *</label>
					<Input
						id="title"
						bind:value={title}
						placeholder="e.g., Stories of the Prophets"
						maxlength={100}
					/>
					<p class="text-xs text-muted-foreground">At least 3 characters</p>
				</div>

				<div class="space-y-2">
					<label for="description" class="text-sm font-medium">Description</label>
					<Textarea
						id="description"
						bind:value={description}
						placeholder="Describe what this game covers..."
						maxlength={500}
					/>
				</div>

				<div class="space-y-2">
					<label for="difficulty" class="text-sm font-medium">Difficulty Level *</label>
					<Select id="difficulty" bind:value={difficulty}>
						<option value="kids">Kids (Ages 5-10)</option>
						<option value="beginner">Beginner (Ages 10+)</option>
						<option value="advanced">Advanced</option>
					</Select>
				</div>

				<div class="flex items-center justify-between">
					<div>
						<p class="text-sm font-medium">Make Public</p>
						<p class="text-xs text-muted-foreground">Allow others to play your game</p>
					</div>
					<Switch bind:checked={isPublic} />
				</div>

				<div class="flex justify-end">
					<Button onclick={() => (currentStep = 2)} disabled={!canProceedToStep2()}>
						Next: Select Categories
					</Button>
				</div>
			</CardContent>
		</Card>
	{/if}

	<!-- Step 2: Category Selection -->
	{#if currentStep === 2}
		<Card class="mx-auto max-w-4xl">
			<CardHeader>
				<CardTitle>Select 5 Categories</CardTitle>
				<CardDescription>
					Choose the categories for your game board ({selectedCategories.length}/5 selected)
				</CardDescription>
			</CardHeader>
			<CardContent>
				<div class="grid gap-4 sm:grid-cols-2 md:grid-cols-4">
					{#each data.categories as category}
						{@const isSelected = selectedCategories.some((c) => c.category_id === category.id)}
						<button
							type="button"
							onclick={() => toggleCategory(category)}
							disabled={!isSelected && selectedCategories.length >= 5}
							class="rounded-lg border-2 p-4 text-left transition-all
								{isSelected ? 'border-primary bg-primary/10' : 'border-border hover:border-primary/50'}
								{!isSelected && selectedCategories.length >= 5
								? 'cursor-not-allowed opacity-50'
								: ''}"
						>
							<p class="font-medium">{category.name}</p>
							{#if category.description}
								<p class="text-xs text-muted-foreground">{category.description}</p>
							{/if}
						</button>
					{/each}
				</div>

				<div class="mt-6 flex justify-between">
					<Button variant="outline" onclick={() => (currentStep = 1)}>Back</Button>
					<Button
						onclick={() => {
							initializeQuestionsForCategories();
							currentStep = 3;
						}}
						disabled={!canProceedToStep3()}
					>
						Next: Add Questions
					</Button>
				</div>
			</CardContent>
		</Card>
	{/if}

	<!-- Step 3: Questions -->
	{#if currentStep === 3}
		<div class="mx-auto max-w-6xl">
			<div class="mb-6 text-center">
				<h2 class="text-2xl font-bold">Add Questions</h2>
				<p class="text-muted-foreground">
					Add 5 questions for each category ({getFilledQuestionCount()}/25 complete). Higher points
					= harder questions.
				</p>
			</div>

			{#each selectedCategories as category}
				<Card class="mb-6">
					<CardHeader>
						<CardTitle class="text-lg">{category.name}</CardTitle>
					</CardHeader>
					<CardContent>
						<div class="space-y-4">
							{#each POINT_VALUES as points}
								{@const q = questions.get(category.category_id)?.get(points)}
								<div class="rounded-lg border p-4">
									<div class="mb-2 flex items-center justify-between">
										<span class="font-medium text-primary">{points} Points</span>
										{#if q?.question_text.trim() && q?.answer_text.trim()}
											<span class="text-xs text-green-600">Complete</span>
										{/if}
									</div>
									<div class="grid gap-4 md:grid-cols-2">
										<div class="space-y-2">
											<label for="q-{category.category_id}-{points}" class="text-sm font-medium">Question</label>
											<Textarea
												id="q-{category.category_id}-{points}"
												placeholder="Enter the question..."
												value={q?.question_text ?? ''}
												oninput={(e) =>
													updateQuestion(
														category.category_id,
														points,
														'question_text',
														e.currentTarget.value
													)}
											/>
										</div>
										<div class="space-y-2">
											<label for="a-{category.category_id}-{points}" class="text-sm font-medium">Answer</label>
											<Textarea
												id="a-{category.category_id}-{points}"
												placeholder="Enter the answer..."
												value={q?.answer_text ?? ''}
												oninput={(e) =>
													updateQuestion(
														category.category_id,
														points,
														'answer_text',
														e.currentTarget.value
													)}
											/>
										</div>
									</div>
								</div>
							{/each}
						</div>
					</CardContent>
				</Card>
			{/each}

			<div class="flex justify-between">
				<Button variant="outline" onclick={() => (currentStep = 2)}>Back</Button>
				<Button onclick={() => (currentStep = 4)} disabled={!canProceedToStep4()}>
					Next: Review
				</Button>
			</div>
		</div>
	{/if}

	<!-- Step 4: Review -->
	{#if currentStep === 4}
		<Card class="mx-auto max-w-4xl">
			<CardHeader>
				<CardTitle>Review Your Game</CardTitle>
				<CardDescription>Make sure everything looks correct before publishing</CardDescription>
			</CardHeader>
			<CardContent>
				<div class="space-y-6">
					<div>
						<h3 class="font-medium text-muted-foreground">Title</h3>
						<p class="text-lg">{title}</p>
					</div>

					<div>
						<h3 class="font-medium text-muted-foreground">Description</h3>
						<p>{description || 'No description'}</p>
					</div>

					<div>
						<h3 class="font-medium text-muted-foreground">Difficulty</h3>
						<p class="capitalize">{difficulty}</p>
					</div>

					<div>
						<h3 class="font-medium text-muted-foreground">Visibility</h3>
						<p>{isPublic ? 'Public' : 'Private'}</p>
					</div>

					<div>
						<h3 class="font-medium text-muted-foreground">Categories</h3>
						<div class="mt-2 flex flex-wrap gap-2">
							{#each selectedCategories as cat}
								<span class="rounded-full bg-primary/10 px-3 py-1 text-sm">{cat.name}</span>
							{/each}
						</div>
					</div>

					<div>
						<h3 class="font-medium text-muted-foreground">Questions</h3>
						<p>25 questions ready</p>
					</div>
				</div>

				{#if form?.error}
					<div class="mt-4 rounded-md bg-destructive/15 p-3 text-sm text-destructive">
						{form.error}
					</div>
				{/if}

				<form method="POST" class="mt-6 flex justify-between">
					<Button type="button" variant="outline" onclick={() => (currentStep = 3)}>Back</Button>
					<input
						type="hidden"
						name="gameData"
						value={JSON.stringify({
							title,
							description,
							difficulty,
							is_public: isPublic,
							categories: selectedCategories,
							questions: getQuestionData()
						})}
					/>
					<Button type="submit">Publish Game</Button>
				</form>
			</CardContent>
		</Card>
	{/if}
</div>
