wget -O index.html -q https://randomword.com/
cat index.html | grep '"random_word">' | sed 's/<div id="random_word">//' | sed 's/<\/div>//' | xargs >> words.txt

