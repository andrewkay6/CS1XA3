commands () {
  if [ "$1" = 1 ]
  then
      echo "what would you like to output?"
      read userWord
      echo $userWord
  elif [ "$1" = 2 ]
  then
    grep -r -h -s '#TODO' ~/CS1XA3 > TODO.log
  elif [ "$1" = 3 ]
  then
    echo "HTML: `find ~/CS1XA3 -name "*.html" -type f | wc -l` "
    echo "Javascript: `find ~/CS1XA3 -name "*.js" -type f | wc -l` "
    echo "CSS: `find ~/CS1XA3 -name "*.css" -type f | wc -l` "
    echo "Python: `find ~/CS1XA3 -name "*.py" -type f | wc -l` "
    echo "Haskell: `find ~/CS1XA3 -name "*.hs" -type f | wc -l` "
    echo "Bash: `find ~/CS1XA3 -name "*.sh" -type f | wc -l` "
  elif [ "$1" = 4 ]
  then
    echo Please enter a URL
    read URL
    echo Enter a file name
    read fileName
    mkdir HTML
    touch HTML/$fileName.html
    wget -O - $URL > ./HTML/$fileName.html

  fi

}

if [ $# -eq 0 ]
then
    echo "Which command would you like to execute?"
    echo "1) output a word"
    echo "2) create TODO log"
    echo "3) file type count"
    echo "4) save HTML code from URL"

    read varInput
    commands $varInput
else
    for var in "$@"
    do
        commands $var
    done
fi
