#!/bin/bash
# Args: script to run


SCRIPT=${1}

for SUBJECT in ${ALL_SUBJECTS[@]}; do
  source $SCRIPT $SUBJECT $2 $3 $4 $5
done
