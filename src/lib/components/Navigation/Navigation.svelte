<script lang="ts">
	import type { PassageConfig } from '$lib/types.js';

	import NavigationItem from './NavigationItem.svelte';

	interface Props {
		passages: PassageConfig[];
		currentPassageUrn: string;
	}

	let { passages, currentPassageUrn }: Props = $props();
</script>

<ul class="menu overflow-x-hidden overflow-y-auto bg-base-200">
	{#each passages as passage (passage.urn)}
		<NavigationItem {passage} {currentPassageUrn} />
	{/each}
</ul>
