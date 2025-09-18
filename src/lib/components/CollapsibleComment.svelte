<script lang="ts">
	import type { Author, Comment } from '$lib/types.js';

	interface Props {
		comment: Comment;
		stringifyCommentCitation: (comment: Comment) => string;
	}

	let { comment, stringifyCommentCitation }: Props = $props();

	let authors = $derived(comment.commentaryAttributes?.authors as Author[]);
	let isHighlighted = $derived(comment.isHighlighted);
	let isOpen = $derived(isHighlighted);

	function toggleDetails(_e: Event) {
		isOpen = !isOpen;

		if (!isOpen) {
			isHighlighted = false;
		}
	}
</script>

<div
	class="collapse-arrow collapse mb-2 rounded-xs border"
	class:border-2={isHighlighted}
	class:border-secondary={isOpen && isHighlighted}
	class:collapse-open={isOpen}
	id={comment.urn}
>
	<div
		class="collapse-title"
		role="button"
		tabindex="0"
		onclick={toggleDetails}
		onkeyup={(event) => {
			if (event.key === 'Enter') {
				event.stopPropagation();
				toggleDetails(event);
			}
		}}
	>
		<h3 class="text-b ase-content cursor-pointer text-sm font-bold">
			<span class="text-sm font-medium text-slate-600"
				><a data-sveltekit-reload href={`?gloss=${comment.urn}`}
					>{stringifyCommentCitation(comment)}</a
				></span
			>
		</h3>
		{#if comment.lemma}
			<small class="mx-w-2xl mt-1 text-sm text-slate-600">
				{comment.transcript || comment.lemma}
			</small>
		{/if}
	</div>
	<div class="collapse-content float-right">
		<p class="comment-body prose max-w-2xl font-serif text-sm text-gray-800">
			{@html comment.body}
		</p>
	</div>
</div>

<style lang="postcss">
	.comment-body :global(a) {
		@apply underline;
	}
</style>
