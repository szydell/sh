#!/bin/bash


cd /srv/02-mumps.pl/src
rm -rf *
rm -rf .git

wget --mirror --convert-links --adjust-extension --page-requisites --no-parent "http://tinco.pair.com/bhaskar/gtm/doc/"

git init
git add tinco*

git grep -l '013851696010511438525:' | xargs sed -i "s/013851696010511438525:.*/008883911881491959604:nja0buk6qz4\';/g"

rsync -r /srv/02-mumps.pl/src/tinco.pair.com/bhaskar/gtm/doc/ /srv/02-mumps.pl/www/

cd /srv/02-mumps.pl/www/

function charconv {

FILELIST=$(find . -type f -name "*.html")

for file in $FILELIST
do
  iconv --from-code='latin1' --to-code='ASCII//TRANSLIT' "$file" | sponge "$file"
done

}

#time charconv



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


