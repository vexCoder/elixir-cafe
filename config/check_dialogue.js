const fs = require('fs/promises');

const checkDialogues = async () => {
	const json_raw = await fs.readFile(`./dialogues.json`, 'utf8');

	const json = JSON.parse(json_raw);

	const nexts = json.map(v => {
		return [v.next, ...(v.responses ?? []).map(r => r.next)];
	}).flat()

	const nexts_unique = [...new Set(nexts)];

	const missing = nexts_unique.filter(v => !json.find(d => d.id === v));

	if (missing.length > 0) {
		console.log('Missing dialogues: ', missing);
	}

	const targets = json.map(v => v.target)
	console.log('Targets: ', [...new Set(targets)]);
}

checkDialogues();