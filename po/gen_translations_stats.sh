#!/bin/bash

# This script prints translations statistics for .po files
# existing in the current directory
export LC_ALL=C

echo "Translations statistics"
echo "Date: "$(date -R)
echo

echo "Note: completion % in the chart below may not be quite correct"
echo "      when fuzzy translations exist but do not appear in the source."
echo "      For exact results, run make update-po with up to date POTFILES.in."
echo "      comp % = trans / (trans + fuzzy + untrans)"
echo

(echo "Language  Comp(%) Trans Fuzzy Untrans Total"; \
for i in *.po; do
	msgfmt --statistics -o /dev/null $i 2>&1 \
	| perl -ne '
		my ($tr_done, $tr_fuzz, $tr_un) = (0, 0, 0);
		$tr_done = $1 if /(\d+) translated messages/;
		$tr_fuzz = $1 if /(\d+) fuzzy translations/;
		$tr_un = $1 if /(\d+) untranslated messages/;
		my $tr_tot = $tr_done + $tr_fuzz + $tr_un;
		printf "%8.0f|%s|%7.2f|%5d|%5d|%7d|%5d\n",
			10000*$tr_done/$tr_tot, "'"${i%%.po}"'",
			100*$tr_done/$tr_tot, $tr_done, $tr_fuzz, $tr_un,
			$tr_tot if $tr_tot;';
done | sort -t '|' -b -k1,1nr -k2,2 | sed 's/^ *[0-9]*//' | tr ' |' '| '
) | column -t -c 80 | tr '|' ' '
echo

