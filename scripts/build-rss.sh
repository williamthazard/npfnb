cd ..
function addformer() {
  if [[ $n > 10 ]]; then
      ((past=pagenum-1))
      echo "<br/><a href=../log/log${past}.html>[ former]</a>" >> ../${log}.html
  fi
}
function addfinal() {
  if [[ $n > 10 ]]; then
      echo "<br/><br/><a href=../log/log0.html>[final]</a>" >> ../${log}.html
  fi
}
function addfirst() {
  if [[ $((pagenum-1)) == 0 ]]; then
      echo "<br/><br/><a href=../log/log${pages}.html>[first]</a>" >> ../${log}.html
    else
      echo "<a href=../log/log${pages}.html>[first]</a>" >> ../${log}.html
  fi
}
function paginate() {
  if [[ $((n % 10)) == 0 ]]; then
    echo "<p class='center'>" >> ../${log}.html
    addformer
    ((pagenum=pagenum+1))
    echo "<a href=../log/log${pagenum}.html>[further]</a>" >> ../${log}.html
    addfinal
    addfirst
    echo "</p>" >> ../${log}.html
    cat ../../log-foot.htm_ >> ../${log}.html
    log="log"$pagenum
    cat ../../sub-head.htm_ > ../${log}.html
    echo "<h1><p class='center'>log</p></h1>" >> ../${log}.html
    echo "<p class='center'><a href=../>[return]</a></p><br/>" >> ../${log}.html
  fi
}
echo ">> build rss"
cd log/entries
n=1
pagenum=0
log="log"$pagenum
cat ../../sub-head.htm_ > ../${log}.html
echo "<h1><p class='center'>log</p></h1>" >> ../${log}.html
echo "<p class='center'><a href=../>[return]</a></p>" >> ../${log}.html
cat ../start_rss.xml_ > ../rss.xml
marks=(*.md)
hypes=(*.html)
pages=$(( ${#hypes[@]}/10 ))
min=1
max=$(( ${#marks[@]} ))
while [[ min -lt max ]] ; do
    # Swap current first and last elements
    x="${marks[$min]}"
    marks[$min]="${marks[$max]}"
    marks[$max]="$x"
    # Move closer
    (( min++, max-- ))
done
for file in $marks ; do
  date=$(date -r ${file} +%D)
  file=${file%.*}
  name=${file#*/}
  folder=$(basename $(pwd))
  target=${file}.html
  page=$(( ${n}/10 ))
  cat ../../entry-head.htm_ > ${target}
  echo "<br/><p><a href=../../log/log${page}.html>${name}</a></p>" >> ${target}
  cmark --unsafe ${file}.md >> ${target}
  cat ../../log-foot.htm_ >> ${target}
  echo $name
  paginate
  ((n=n+1))
  # append to index
  echo "<p><a href=entries/${target}>${name}</a></p>" >> ../${log}.html
  cmark --unsafe ${file}.md >> ../${log}.html
  echo "<br/>" >> ../${log}.html
  # append to rss
  echo "<item>" >> ../rss.xml
  echo "<title>log / ${name}</title>" >> ../rss.xml
  echo "<link>https://npfnb.co/log/${folder}/${name}.html</link>" >> ../rss.xml
  echo "<guid>https://npfnb.co/log/${folder}/${name}.html</guid>" >> ../rss.xml
  echo "<description><![CDATA[" >> ../rss.xml
  cmark --unsafe ${file}.md >> ../rss.xml
  echo "]]></description>" >> ../rss.xml
  date=$(date -r ${file}.md "+%a, %d %b %Y %T EST")
  echo "<pubDate>$date</pubDate>" >> ../rss.xml 
  echo "</item>" >> ../rss.xml
done
((past=pagenum-1))
# echo "<p class='center'>" >> ../${log}.html
# echo "<br/><a href=../log/log${past}.html>[former]</a>" >> ../${log}.html
# echo "<br/><br/><a href=../log/log0.html>[final]</a>" >> ../${log}.html
# echo "</p>" >> ../${log}.html
cat ../../log-foot.htm_ >> ../${log}.html
date=$(date -r ../${log}.html +%D)
sed -i '' -e 's#DATE#'$date'#g' ../${log}.html
cat ../end_rss.xml_ >> ../rss.xml
cd ..
cp -p -f log0.html index.html