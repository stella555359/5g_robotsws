#!/bin/bash
TC='Test case [1|2|3|4|5]*'
# check is it too many argument
if [[ $# -gt 5 ]]; then echo 'too many arguments' >&2
exit 1
fi
# check is argument 1 exist, and is it a number from range 1 to 5
if [[ $1 ]]; then
  if [[ "$1" =~ ^[1-5]+$ ]]; then TC="Test case [$1]*"
  else
    echo "'$1' is not a number from range 1 to 5" >&2
    exit 1
    fi
fi
# check is argument 2 exist, and is it a number from range 1 to 5, and is it greater than argument 1
if [[ $2 ]]; then
  if [[ "$2" =~ ^[1-5]+$ ]]; then TC="Test case [$1|$2]*"
  else
    echo "'$2' is not a number from range 1 to 5" >&2
    exit 1
    fi
  if [[ $2 -le $1 ]]; then
    echo "wrong order, $2 is not greater than $1" >&2
    exit 1
    fi
fi
# check is argument 3 exist, and is it a number from range 1 to 5, and is it greater than argument 2
if [[ $3 ]]; then
  if [[ "$3" =~ ^[1-5]+$ ]]; then TC="Test case [$1|$2|$3]*"
  else
    echo "'$3' is not a number from range 1 to 5" >&2
    exit 1
    fi
  if [[ $3 -le $2 ]]; then
    echo "wrong order, $3 is not greater than $2" >&2
    exit 1
    fi
fi
# check is argument 4 exist, and is it a number from range 1 to 5, and is it greater than argument 3
if [[ $4 ]]; then
  if [[ "$4" =~ ^[1-5]+$ ]]; then TC="Test case [$1|$2|$3|$4]*"
  else
    echo "'$4' is not a number from range 1 to 5" >&2
    exit 1
    fi
  if [[ $4 -le $3 ]]; then
    echo "wrong order, $4 is not greater than $3" >&2
    exit 1
    fi
fi
# check is argument 5 exist, and is it a number from range 1 to 5, and is it greater than argument 4
if [[ $5 ]]; then
  if [[ "$5" =~ ^[1-5]+$ ]]; then TC="Test case [$1|$2|$3|$4|$5]*"
  else
    echo "'$5' is not a number from range 1 to 5" >&2
    exit 1
    fi
  if [[ $5 -le $4 ]]; then
    echo "wrong order, $5 is not greater than $4" >&2
    exit 1
    fi
fi
echo -e "\v***** start NETACT_FEATURE.robot for $TC *****\v"
cd ~; deacticate; rm /home/ute/netact_console.txt; source /home/ute/test_repo/bin/activate; robot -t "$TC" -L TRACE -b /home/ute/logs/debug.log -d /home/ute/logs/ /home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/SFE/UUF/Netact/NETACT_FEATURE.robot | tee -ia netact_console.txt
