<script lang="ts">
	import CollapsibleComment from '$lib/components/CollapsibleComment.svelte';
	import Navigation from '$lib/components/Navigation/Navigation.svelte';

	import { page } from '$app/state';
	import CTS_URN from '$lib/cts_urn.js';

	import { type Comment } from '../../$types.js';

	const { data } = $props();
	const { criticalText, comments, toc } = $derived(data);

	const stringifyCommentCitation = (comment: Comment) => {
		const { integerCitations } = new CTS_URN(comment.urn);

		return `Nagy (2025) on ${integerCitations[0].join('.')}`;
	};

	$inspect(comments.length);
</script>

<div class="container flex">
	<div class="h-40 max-h-40 flex-1">
		<Navigation passages={toc} currentPassageUrn={page.params.urn as string} />
	</div>

	<section class="mx-4 flex-2">
		{#each criticalText as textBlock (textBlock?.urn)}
			<div class="pt-2 indent-8">{@html textBlock?.body}</div>
		{/each}
	</section>

	<section class="mx-4 flex-1">
		{#each comments as comment (comment?.urn)}
			<CollapsibleComment {comment} {stringifyCommentCitation} } />
		{/each}
	</section>
</div>
