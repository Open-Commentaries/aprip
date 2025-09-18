<script lang="ts">
	import type { PassageConfig } from '$lib/types.js';
	import { resolve } from '$app/paths';
	import CTS_URN from '$lib/cts_urn.js';
	import NavigationItem from './NavigationItem.svelte';

	interface Props {
		passage: PassageConfig;
		currentPassageUrn?: string;
	}

	let { passage, currentPassageUrn }: Props = $props();
	let currentUrn = $derived(currentPassageUrn ? new CTS_URN(currentPassageUrn) : null);
	let passageUrn = $derived(new CTS_URN(passage.urn));
	let isUnderlined = $derived(
		currentUrn
			? passageUrn.contains(currentUrn) ||
					(!passage.subpassages?.length && passageUrn.isEqual(currentUrn))
			: false
	);
</script>

<li class="rounded-none">
	{#if passage.subpassages?.length}
		<details open={isUnderlined}>
			<summary>
				<span class:underline={isUnderlined}>{passage.label} {passage.ref}</span>
			</summary>
			<ul>
				{#each passage.subpassages as subpassage (`${passage.ref}-${subpassage.ref}`)}
					<NavigationItem passage={subpassage} {currentPassageUrn} />
				{/each}
			</ul>
		</details>
	{:else}
		<a href={resolve('/passages/[urn]', { urn: passage.urn })}>
			<span class:underline={isUnderlined}>{passage.label} {passage.ref}</span>
		</a>
	{/if}
</li>
