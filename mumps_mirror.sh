#!/bin/bash

find /srv/02-mumps.pl/www/tinco.pair.com -name "*.tmp" -delete

httrack "http://tinco.pair.com/bhaskar/gtm/doc/" -O "/srv/02-mumps.pl/www" -v -%F "<!-- Mirrored [from host %s [file %s]] -->" --retries=10 --timeout=90 --sockets=8 --mirror || :

echo "httrack finished"

cd /srv/02-mumps.pl/www/tinco.pair.com/bhaskar/gtm/doc

function charconv {

FILELIST=$(find . -type f -name "*.html")

for file in $FILELIST
do
  iconv --from-code='latin1' --to-code='ASCII//TRANSLIT' "$file" | sponge "$file"
done

}

time charconv

git grep -l '013851696010511438525:' | xargs sed -i "s/013851696010511438525:.*/008883911881491959604:nja0buk6qz4\';/g"


pdfs="books/ao/UNIX_manual/ao_UNIX_screen.pdf books/pg/UNIX_manual/pg_UNIX_screen.pdf books/mr/manual/mr_screen.pdf"

for pdf in $pdfs
do
  revision=$(pdfgrep "Revision V" ${pdf} | head -1 | tr -s '[:blank:]' | cut -d" " -f 2,3,4,5,6)
  docname=$(echo $pdf | cut -d"/" -f4)
  if ! echo $revision | grep Revision; then
    echo "Revision variable contains: ${revision}" | mail -s "ERROR parsing revision for PDF at mumps.pl" "marcin@szydelscy.pl"
    exit 1
  else
    if git status ${pdf} | egrep -i "modified|untracked"; then
      sed -i "s/\($docname)\).*/\1 $revision/" README.md 
      git add ${pdf}
      git add README.md
      git commit -m "${revision}"
      echo "New ${docname} revision, download at https://mumps.pl/${pdf} or https://github.com/szydell/gtmdoc/blob/master/${pdf}" | mail -s "New ${docname} released, ${revision}" "marcin@szydelscy.pl"
    fi
  fi
done

git add *.pdf && git commit -m "pdf update $(date +'%Y%m%d-%H:%M')" || :
git add *.html && git commit -m "html update $(date +'%Y%m%d-%H:%M')" || :
git add * && git commit -m "$(date +'%Y%m%d-%H:%M')" || :
git push || :

