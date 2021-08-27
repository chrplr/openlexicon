# /bin/sh

WORD_LIST=/usr/share/dict/words
DB=initial_segments.txt  # delete this file when you provide a new word_list
PSEUDOWORD_LIST=pseudos.txt

cat >tabulate_initial_segments.awk <<EOF
{ for (i=1; i <= length(\$1); i++)
          n[substr(tolower(\$1), 1, i)]++;
}
END{ for (i in n) print(i, n[i]); }
EOF

cat >compute_unicity_point.awk <<EOF
BEGIN{ while (getline < DB) n[\$1]=\$2; }
{ for (i=1; i <= length(\$1); i++)
        if (!(substr(\$1, 1, i) in n)) {
            print(\$1, i);
            break
        }
}
EOF

if [ ! -r "$DB" ];
then
   awk -f tabulate_initial_segments.awk < "${WORD_LIST}" >"${DB}"
fi

awk -v DB="${DB}" -f compute_unicity_point.awk "${PSEUDOWORD_LIST}"
