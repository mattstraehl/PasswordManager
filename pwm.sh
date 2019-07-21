#!/bin/bash

# System related configurations
BASEDIR=$(dirname $0)
FILE_DEC=$BASEDIR/pws
FILE_ENC=$BASEDIR/pws.nc
FILE_ENC_BU=$BASEDIR/pws.nc~

PW_LENGTH=16

randomPassword(){
  echo "$(< /dev/urandom tr -dc A-Za-z0-9_. | fold -w $PW_LENGTH | grep '[_.]' | head -n 1)"
}

encrypt(){
  mcrypt -a blowfish $FILE_DEC
}

decrypt(){
  if [[ -f $FILE_ENC ]]; then
    mcrypt -d $FILE_ENC || exit 1
  else
    touch $FILE_DEC
  fi
}

checkEntry(){
  resultCount=$(cat $FILE_DEC | grep $1 | wc -l)
  if (( $resultCount != $2 )); then
    >&2 echo "$0: error: entry name not vaild: result count: $resultCount"
    exit 1
  fi
}

main(){
  # Check if sufficient arguments are supplied
  if (( $# != 2 )); then
    >&2 echo "$0: error: sufficient arguments must be supplied"
    exit 1
  fi

  # Check if $FILE_DEC already exists
  if [[ -f $FILE_DEC ]]; then
    >&2 echo "$0: error: file $FILE_DEC already exists"
    exit 1
  fi

  # Removes all temp files on exit and sigint
  trap "{ rm -f $FILE_DEC $FILE_ENC_BU; }" EXIT SIGINT

  # Main
  if [[ "$1" = "put" ]]; then
    decrypt
    checkEntry $2 0
    echo $2" "$(randomPassword) >> $FILE_DEC && sort $FILE_DEC -o $FILE_DEC
    test -f $FILE_ENC && mv $FILE_ENC $FILE_ENC_BU
    encrypt
    if (( $? == 0 )); then
      echo "Password was stored."
    else
      test -f $FILE_ENC_BU && mv $FILE_ENC_BU $FILE_ENC
    fi
  elif [[ "$1" = "get" ]]; then
    decrypt
    checkEntry $2 1
    cat $FILE_DEC | grep $2 | awk -F ' ' '{ print $2 }' | tr -d '\n' | xsel -ib
    echo "Password was copied to clipboard."
  else
    >&2 echo "$0: error: command $1 unknown"
    exit 1
  fi
}

main "$@"

