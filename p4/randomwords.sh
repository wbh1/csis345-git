numWords=4
variance=0
subs='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890'
imLazy=($(echo 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890' | grep -o .))

function getWord() {
  wget -O index.html -q https://randomword.com/
  cat index.html | grep '"random_word">' | sed 's/<div id="random_word">//' | sed 's/<\/div>//' | xargs >> words.txt
}


function argParse() {
  while getopts ":n:t:" arg; do
    case $arg in
    n)
      if [[ $OPTARG =~ [1-8] ]]; then
        numWords=$OPTARG
      fi;;

    t)
      var1=$OPTARG
      var2=`echo $var1 \* 100 | bc -l`
      variance=${var2%.*}
      if [[ $variance -ge 0 ]] && [[ $variance -le 100 ]]; then
        :
      else
        echo "Invalid variance. Please provide float between 0.0 and 1.0"
      fi;;
   
   esac
  done
}

function substitutes () {
  sed ':a;N;$!ba;s/\n//g' words.txt > word.txt
  array=($(cat word.txt | grep -o .))
    for ((i=0 ; i<${#array[@]}; i++)) ; do
        rando=`shuf -i 0-100 -n 1`
        if [[ $variance -ge $rando ]]; then
          change=`shuf -i 1-62 -n 1`
          array[$i]=${imLazy[$change]}
        fi
    done
  rm words.txt
  echo ${array[*]} > word.txt
  sed -i "s/ //g" word.txt
  cat word.txt
}

function allTheWords () {
  x=1
  while [ $x -le $numWords ]; do
    getWord
    x=$(( $x + 1 ))
  done

  substitutes
}

argParse $@
allTheWords
