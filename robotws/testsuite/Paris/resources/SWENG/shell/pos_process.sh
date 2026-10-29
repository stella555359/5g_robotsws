#!/usr/bin/bash
gzip -d *.gz
## header bottom
for file in A*.xml; do
    if [ -e "$file" ]; then
        sed -E 's/^<\?xml version="1\.0"\?><OMeS version="2\.3">//; s/<\/OMeS>$//' "$file" > "$file.tmp"
        mv "$file.tmp" "$file"
        echo "Processed $file"
    fi
done

for file in *.xml; do
  cat "$file" >> PM.xml
done
sed -i '1i<?xml version="1.0"?>\n<OMeS>' PM.xml
sed -i '$a</OMeS>' PM.xml
## add mapping file
beg_name=$(ls | grep A | cut -d'+' -f1 | cut -d'A' -f2 | head -n 1)
end_name=$(ls | grep A | cut -d'-' -f2 | cut -d'+' -f1 | head -n 1)
old_name=$(basename "$(pwd)" | awk -F '_PM_' '{print $2}')
prefix=$(basename "$(pwd)" | awk -F '_PM_' '{print $1}')
## delete A*.xml
rm A*.xml
cd ..
touch DIR___${prefix}_PM_${old_name}__PERIOD__${beg_name}_to_${end_name}