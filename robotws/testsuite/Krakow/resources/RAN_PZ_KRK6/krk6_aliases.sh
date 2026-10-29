#!/bin/bash

#testing
alias select_tests="vi /home/ute/MN/UTE/robotws/testsuite/Krakow/resources/RAN_PZ_KRK6/test_lists/$(uname -n | awk -F '-integration' '{print $1}').toml"
alias select_tests_gedit="gedit /home/ute/MN/UTE/robotws/testsuite/Krakow/resources/RAN_PZ_KRK6/test_lists/$(uname -n | awk -F '-integration' '{print $1}').toml"

#navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias test_lists="cd /home/ute/MN/UTE/robotws/testsuite/Krakow/resources/RAN_PZ_KRK6/test_lists"
alias krk6_regression="cd /home/ute/MN/UTE/robotws/testsuite/Krakow/RRM/RAN_PZ/regression/KRK6"
alias krk6_resources="cd /home/ute/MN/UTE/robotws/testsuite/Krakow/resources/RAN_PZ_KRK6"
alias pubs="cd /home/ute/pubs/userspace"
alias ws="cd /home/ute/MN/UTE/robotws"
alias logs="cd /home/ute/CRT_MANUAL_RUNS"
alias syve="cd /home/ute/syve/WMP/manual_runs"
alias airphone_regression="cd /home/ute/MN/UTE/robotws/testsuite/Krakow/RRM/Airphone"

#git
alias gc_robotws="git clone https://wrgitlab.ext.net.nokia.com/RAN/robotws.git /home/ute/MN/UTE/robotws"
alias gc_testline_configuration="git clone https://wrgitlab.ext.net.nokia.com/RAN/configuration-management/testline_configuration.git /home/ute/testline_configuration"
alias gc_topology_configs="git clone https://gitlabe2.ext.net.nokia.com/uca/ran/topology-configs.git /home/ute/topology-configs"
alias git_file_history="git log --pretty=format:\"%C(blue)%h%Creset %C(magenta)[%cD]%Creset %C(red)%d%Creset %s %C(green) [%an]%Creset\" --abbrev-commit --follow -- "

#other
alias krk6_aliases="grep alias /home/ute/MN/UTE/robotws/testsuite/Krakow/resources/RAN_PZ_KRK6/krk6_aliases.sh | sort"
alias sanity_checks="cd /home/ute/MN/UTE/robotws; yes | pip install ci-pipeline-steps; ci-pipeline run_sanity .; cd -"
alias pp="echo oZPS0POrRieRtu"

#venv
alias test_repo_activate="source /home/ute/test_repo/bin/activate"
alias tra="source /home/ute/test_repo/bin/activate"
alias test_repo_update="source /home/ute/test_repo/bin/activate; pip install -r ~/MN/UTE/robotws/dependencies.py311-rf50.lock"

#testline
alias tl_ip="ip a | grep inet | grep eth0 | cut -d '/' -f 1 | cut -d ' ' -f 6"
alias tl_config="cd ~/testline_configuration/$(uname -n | cut -d'-' -f1-3 | sed 's/-/_/g')"
alias tl_commissionings="cd ~/MN/UTE/robotws/commissionings/Krakow/$(uname -n | cut -d'-' -f1-3 | sed 's/-/_/g')"
alias ecolab_install="pip install taf.tools.ecolab"
alias ecolab_power_on="ecolab_cli power_on -c /home/ute/testline_configuration/`uname -n | sed -r 's/(.*)-[0-9]$/\1/' | tr "-" "_"`/__init__.py;"
alias ecolab_power_off="ecolab_cli power_off -c /home/ute/testline_configuration/`uname -n | sed -r 's/(.*)-[0-9]$/\1/' | tr "-" "_"`/__init__.py"
alias pubs_setup="cd && ./MN/UTE/robotws/testsuite/Krakow/resources/RAN_PZ_KRK6/mount_storages.sh -t pubs -u pubs -p pubs123; cd && ./MN/UTE/robotws/testsuite/Krakow/resources/RAN_PZ_KRK6/mount_storages.sh -t syve -u pubs -p emssim4Nokia#"
alias builds_folder="sudo apt update && sudo apt install nfs-common -y;mkdir /home/ute/BUILDS;sudo mount.nfs -o ro 10.89.7.3:/brick /home/ute/BUILDS"

#tools
alias jsontool="python -m json.tool"
