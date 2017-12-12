numWords=4
variance=0
subs='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890'
imLazy=`echo 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890' | grep -o .`

function getWord() {
  wget -O index.html -q https://randomword.com/
  cat index.html | grep '"random_word">' | sed 's/<div id="random_word">//' | sed 's/<\/div>//' |
  xargs >> words.txt
}


function argParse() {
  while getopts ":n:t:" arg; do
    case $arg in
    n)
      if [[ $OPTARG =~ [1-8] ]]; then
        numWords=$OPTARG
      fi;;

    t)
      if [[ $OPTARG -ge 0 ]] && [[ $OPTARG -le 1 ]]; then
        variance=$OPTARG
      fi;;
    esac
  done
}

function substitutes () {
  echo "subbing"
  sed ':a;N;$!ba;s/\n//g' words.txt > word.txt
  array=($(cat word.txt | grep -o .))
  echo ${array[*]} "is array"
    for ((i=0 ; i<${#words[@]}; i++)) ; do
        if [[ $variance -ge $RANDOM ]]; then
          change=`shuf -i 1-62 -n 1`
          array[$i]=imLazy[$change]
        fi
    echo ${array[2]}
    done
}

function allTheWords () {
  x=1
  while [ $x -le $numWords ]; do
    echo "word retrieval"
    getWord
    x=$(( $x + 1 ))
  done

  substitutes
}

argParse $@
allTheWords
