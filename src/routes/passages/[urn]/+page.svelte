<script lang="ts">
	import CollapsibleComment from '$lib/components/CollapsibleComment.svelte';
	import Navigation from '$lib/components/Navigation/Navigation.svelte';

	import { page } from '$app/state';
	import CTS_URN from '$lib/cts_urn.js';

	import { type Comment } from '$lib/types.js';

	const { data } = $props();
	const { criticalText, comments, namedEntities, toc } = $derived(data);

	const stringifyCommentCitation = (comment: Comment) => {
		const { integerCitations } = new CTS_URN(comment.urn);

		return `Nagy (2025) on ${integerCitations[0].join('.')}`;
	};

	$effect(() => {
		const urn = new CTS_URN(page.params.urn as string);

		for (const entity of namedEntities) {
			const spanLocation = entity.aligned_translation_location;
			const spanId = `@urn:cts:${urn.collection}:${urn.workComponent}.aprip-nagy:${urn.citations[0]}.${spanLocation.split('.').slice(2)}`;
			const el = document.getElementById(spanId);

			if (el && entity.entity_link) {
				const a = document.createElement('a');

				a.href = entity.entity_link;
				a.className = 'link entity';
				a.dataset['entitytype'] = entity.entity_type;
				el.replaceWith(a);
				a.appendChild(el);
			}
		}
	});
</script>

<div class="flex m-0">
	<div class="h-40 max-h-40 flex-1">
		<Navigation passages={toc} currentPassageUrn={page.params.urn as string} />
	</div>

	<section class="mx-4 flex-2">
		{#each criticalText as textBlock (textBlock?.urn)}
			<div class="pt-2 indent-8" id={textBlock?.urn}>{@html textBlock?.body}</div>
		{/each}
	</section>

	<section class="mx-4 flex-1">
		{#each comments as comment (comment?.urn)}
			<CollapsibleComment comment={comment as Comment} {stringifyCommentCitation} />
		{/each}
	</section>
</div>

<style>
	:global(.entity) {
		padding: 2px;
		background-color: green;
	}

	:global(.entity[data-entitytype='LOC']) {
		background-color: lightgoldenrodyellow;
	}

	:global(.entity[data-entitytype='MISC']) {
		background-color: lightgray;
	}

	:global(.entity[data-entitytype='PER']) {
		background-color: lightcoral;
	}
</style>
