#!/bin/bash
echo "Bash version ${BASH_VERSION}..."

for i in {0..30}
do
  echo "on est dans la boucle $i ..."
  ./to_be_run_CV048.sh SBTS23R2_ENB_9999_221202_000007
done
