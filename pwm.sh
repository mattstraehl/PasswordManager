#!/bin/bash

# system related configurations
BASEDIR=$(dirname $0)
FILE_DEC=$BASEDIR/pws
FILE_ENC=$BASEDIR/pws.nc
FILE_ENC_BU=$BASEDIR/pws.nc~

PW_LENGTH=12

randPW(){
  echo `< /dev/urandom tr -dc A-Za-z0-9_. | fold -w $PW_LENGTH | grep '[_.]' | head -n 1`
}

encrypt(){
  mcrypt -a blowfish $FILE_DEC
}

decrypt(){
  (test -f $FILE_ENC && mcrypt -d $FILE_ENC) || touch $FILE_DEC
}

checkEntry(){
  resultCount=`cat $FILE_DEC | grep $1 | wc -l`
  if [ $resultCount -ne $2 ]; then
    >&2 echo "$0: error: entry name cannot be matched: result count: $resultCount"
    return 1
  fi
  return 0
}

clean(){
  rm -f $FILE_DEC $FILE_ENC_BU
}

# check if sufficient arguments are supplied
if [ $# -ne 2 ]; then
  >&2 echo "$0: error: sufficient arguments must be supplied"
  exit 1
fi

# check if $FILE_DEC exists
if [ -f $FILE_DEC ]; then
  >&2 echo "$0: error: file $FILE_DEC exists"
  exit 1
fi

# main
if [ "$1" = "put" ]; then
  decrypt
  if [ $? -eq 0 ]; then
    checkEntry $2 0
    if [ $? -ne 0 ]; then
      clean
      exit 1
    fi
    echo $2" "$(randPW) >> $FILE_DEC && sort $FILE_DEC -o $FILE_DEC
    test -f $FILE_ENC && mv $FILE_ENC $FILE_ENC_BU
    encrypt
    if [ $? -eq 0 ]; then
      echo "Password was stored."
    else
      test -f $FILE_ENC_BU && mv $FILE_ENC_BU $FILE_ENC
    fi
  fi
elif [ "$1" = "get" ]; then
  decrypt
  if [ $? -eq 0 ]; then
    checkEntry $2 1
    if [ $? -ne 0 ]; then
      clean
      exit 1
    fi
    cat $FILE_DEC | grep $2 | awk -F ' ' '{ print $2 }' | tr -d '\n' | xsel -ib
    echo "Password was copied to clipboard."
  fi
else
  >&2 echo "$0: error: command $1 unknown"
  exit 1
fi

clean

exit 0

