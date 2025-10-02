#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';

const csvPath = path.resolve(
	'static/named-entity-annotations/tlg0525.tlg001.perseus-grc2.entities.csv'
);
const jsonOutPath = path.resolve(
	'static/named-entity-annotations/tlg0525.tlg001.perseus-grc2.entities.json'
);

const rawCSV = fs.readFileSync(csvPath).toString('utf-8');
const rows = rawCSV.split('\r\n');
const columnNames = rows.shift().split(',');

const entities = rows.reduce((acc, row) => {
	const entity = {};
	const splitRow = row.split(',').map((s) => s.trim());

	for (let i = 0, l = columnNames.length; i < l; i++) {
		const name = columnNames[i];

		entity[name] = splitRow[i];
	}

	const id = entity.aligned_translation_location;

	if (!id) {
		return acc;
	}

	acc[id] = entity;

	return acc;
}, {});

fs.writeFileSync(jsonOutPath, JSON.stringify(entities));
