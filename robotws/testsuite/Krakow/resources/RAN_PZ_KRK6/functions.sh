#!/bin/bash 

fr() {
# ------------------------------------------------------------------------------
# Description:
#  Changes current directory to feature directory with provided ending
#
# Usage:
#  fr 1234  
# ------------------------------------------------------------------------------

  feature_path=$(find /home/ute/MN/UTE/robotws/testsuite/Krakow/RRM/RAN_PZ/regression/KRK6 /home/ute/MN/UTE/robotws/testsuite/Krakow/RRM/Airphone -type d -name "*$1" -printf "%p\n" 2>/dev/null | head -n 1)
  if [ -n "$feature_path" ]; then
    cd "$feature_path"
  else
    echo "No feature directory found ending in $1"
  fi
}

switch_to_gitlab(){
# ------------------------------------------------------------------------------
# Description:
#   Changes remote url of robotws repository and performs git fetch 
# ------------------------------------------------------------------------------
    cd ~/MN/UTE/robotws
    git remote set-url origin https://wrgitlab.ext.net.nokia.com/RAN/robotws.git
    git fetch
    cd -
}

select_branch(){                                                                                                                                                                                               
# ------------------------------------------------------------------------------
# Description:
#   Allows to select branch from list filtered by provided substring 
#
# Usage:
#  select_branch <branch_name_substring>
# ------------------------------------------------------------------------------
   readarray -t branches < <(git branch --all | grep -i $1 | sed 's.remotes/origin/..g')
   echo "Select branch:"
   select branch in "${branches[@]}"
   do    
      git checkout $branch
      break
  done
}

