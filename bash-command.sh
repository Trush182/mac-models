#!/bin/bash

SERNUM=$(system_profiler SPHardwareDataType | grep Serial | cut -d : -f 2 | cut -d ' ' -f 2 | awk '{$1=$1};1')

if [[ (("${#SERNUM}"> 11)) ]]; then
  SERIAL=$( echo $SERNUM | tail -c 5 )
  DEVICE_SERIAL_CURL=$(curl -s "https://support-sp.apple.com/sp/product?cc=$SERIAL")
  DEVICE_YEAR=$( echo $DEVICE_SERIAL_CURL | grep -o 'Early\|Mid\|Late\|20[^',']*' | tr -d ')' | cut -f1 -d "<")
  if [ -z "$DEVICE_YEAR" ]; then
    DEIVCE_IDENTIFIER=$(sysctl hw.model | awk '{print $NF}')
    DEVICE_MODEL_CURL=$(curl -s "https://raw.githubusercontent.com/Trush182/mac-models/main/models" | grep "|$DEIVCE_IDENTIFIER\| \+\$DEIVCE_IDENTIFIER" | cut -f1 -d"|")
    DEVICE_YEAR=$( echo "$DEVICE_MODEL_CURL" | grep -o 'Early\|Mid\|Late\|20[^',']*'| tr -d ')' )
    DEVICE_YEAR_COUNT=$(echo $DEVICE_YEAR | grep -o 'Early\|Mid\|Late\|20[^',']*' | grep -o '20' | wc -l)
    if (($DEVICE_YEAR_COUNT > 1)); then
      DEVICE_YEAR=$( echo $DEVICE_YEAR | grep -o 'Early\|Mid\|Late\|20[^',']*' | sed 's/[0-9][0-9][0-9][0-9]/ & or /')
    fi
  elif [ -z "$DEVICE_YEAR" ]; then
    DEVICE_YEAR="Année inconnue"
  fi
elif [[ (("${#SERNUM}" < 11)) ]]; then
  DEIVCE_IDENTIFIER=$(sysctl hw.model | awk '{print $NF}')
  DEVICE_MODEL_CURL=$(curl -s "https://raw.githubusercontent.com/Trush182/mac-models/main/models" | grep "|$DEIVCE_IDENTIFIER\| \+\$DEIVCE_IDENTIFIER" | cut -f1 -d"|")
  if [[ $DEVICE_MODEL_CURL = *"("*")"* ]]; then
    DEVICE_MODEL=$( echo $DEVICE_MODEL_CURL | cut -f1 -d"|" )	
    DEVICE_YEAR=$( echo "$DEVICE_MODEL" | grep -o 'Early\|Mid\|Late\|20[^',']*' | tr -d ')' )
  elif [ -z $DEVICE_MODEL_CURL ]; then
    DEVICE_MODEL_CURL=$(curl -s "https://raw.githubusercontent.com/Trush182/mac-models/main/models" | grep "$DEIVCE_IDENTIFIER" | cut -f1 -d"|")
    DEVICE_YEAR_COUNT=$(echo $DEVICE_YEAR | grep -o 'Early\|Mid\|Late\|20[^',']*' | grep -o '20' | wc -l)
    if (($DEVICE_YEAR_COUNT > 1)); then
      DEVICE_YEAR=$( echo $DEVICE_YEAR | grep -o 'Early\|Mid\|Late\|20[^',']*' | sed 's/[0-9][0-9][0-9][0-9]/ & or /')
    fi
  elif [ -z $DEVICE_YEAR ]; then
    DEVICE_YEAR="Année inconnue"
  fi
fi

echo $DEVICE_YEAR
