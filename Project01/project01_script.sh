commands () {
  if [ "$1" = 1 ]
  then
      echo "what would you like to output?"
      read userWord
      echo $userWord
  elif [ "$1" = 2 ]
  then
    echo hello
    find ~/CS1XA3 -type f -name '*' -exec cat {} + > TODO.log
    sed -i s/$/'#TODO'/ TODO.log

  fi
}

if [ $# -eq 0 ]
then
    echo "Which command would you like to execute?"
    echo "1) output a word"
    echo "2) create TODO log"
    read varInput
    commands $varInput
else
    for var in "$@"
    do
        commands $var
    done
fi
