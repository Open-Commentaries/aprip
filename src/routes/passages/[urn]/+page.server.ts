import { getNamedEntitiesForPassage, getPassage } from '$lib/functions';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ params: params }) => {
	const { criticalText, comments, toc } = await getPassage(params.urn);
	const namedEntities = getNamedEntitiesForPassage(params.urn);

	return {
		criticalText,
		comments,
		namedEntities,
		toc
	};
};
