print_help(){
#  echo "Usages: $0 [-u <ute build version>] [-p <py tag>]  #py tag: py36 or py39 or py310"
  echo "Usages: $0 [-u <ute build version>] [-p <py tag>]  #py tag: py36 or py39"
  echo "Example 1: instal TA env with latest ute build and default python version same as UTE"
  echo "    $0"
  echo "Example 2: specify ute build version, install default python"
  echo "    $0 -u 2341.01.00"
  echo "Example 3: specify python tag, install latest ute build"
  echo "    $0 -p py39"
  echo "Example 4: specify ute build and python tag"
  echo "    $0 -u 2341.01.00 -p py39"
}

get_testline_site(){
  if [ -e "/opt/ute/reservation.context.json" ]
  then
    site=$(cat "/opt/ute/reservation.context.json" | grep -o '"site": "[^"]*' | sed 's/"site": "//' | sed 's/[A-Z]/\L&/g')
  else
    site="hangzhou"
  fi
  echo $site
}

update_sources_list(){
  # backup debian_repo.list
  if [ ! -e "/home/ute/debian_repo.list_org" ] && [ -e "/etc/apt/sources.list.d/debian_repo.list" ]
  then
    cp /etc/apt/sources.list.d/debian_repo.list /home/ute/debian_repo.list_org
  fi
  # update debian_repo.list
  default_server="deb [ trusted=yes ] https://artifactory-espoo2.ute.nsn-rdnet.net/artifactory/ute-debian-virtual/ bookworm main ute"
  hz_server="deb [ trusted=yes ] https://artifactory-hz1.ext.net.nokia.com/artifactory/ute-debian-virtual/ bookworm main ute"
  if [ $1 = "hangzhou" ]
  then
    server=${hz_server}
  else
    server=${default_server}
  fi
  echo ${server} | sudo tee "/etc/apt/sources.list.d/debian_repo.list" > /dev/null
}

update_pip_conf(){
  # backup pip.conf
  if [ ! -e "/home/ute/pip.conf_org" ] && [ -e "/home/ute/.pip/pip.conf" ]
  then
    cp /home/ute/.pip/pip.conf /home/ute/pip.conf_org
  fi
  # update pip.conf
  mkdir -p /home/ute/.pip
  echo "[global]" > /home/ute/.pip/pip.conf
  if [ $1 = "hangzhou" ]
  then
    echo "index-url = https://artifactory-hz1.int.net.nokia.com/artifactory/api/pypi/ute-pypi-virtual/simple" >> /home/ute/.pip/pip.conf
  else
    echo "index-url = https://artifactory-espoo2.int.net.nokia.com/artifactory/api/pypi/ute-pypi-virtual/simple" >> /home/ute/.pip/pip.conf
  fi
  echo "disable-pip-version-check = True" >> /home/ute/.pip/pip.conf
}

#teardown(){
#  rm -rf /opt/iphy/latest
#  mv /home/ute/wts_bak/$WTS_DIR_NAME /opt/iphy; rm -rf /home/ute/wts_bak
#  ln -s /opt/iphy/$WTS_DIR_NAME /opt/iphy/latest
#}
#trap 'teardown' EXIT

install_ute_build(){
  echo -e "\e[32m[INFO] start to install ute build\e[0m"
  site=$(get_testline_site)
  update_sources_list $site
  bash -ce 'while fuser /var/lib/dpkg/lock; do echo "dpkg is used"; sleep 1; done;
  sudo apt-get update; sudo apt-get install --yes ute-client;'
  if [ -z "$1" ]; then
    latest_ute=$(apt-cache showpkg ute | sed -n -r -e '/^Dependencies:/,/^Provides:/s/(.*) - .*(ute-wts \([[:alnum:] \.-]*\)).*/\1 --- \2/gp' | head -1  | awk '{print $1}')
    ute_version=$latest_ute
  else
    ute_version=$1
  fi
  bash -ce "ute install ${ute_version}; dpkg-query -s ute 2>&1 | grep -i version"
}

install_ta_lib(){
  # decide python version and dependencies file
  if [ -z "$1" ] || [ "$1" = "py310" ]; then
    py_version="3.10.12"
    dependencies_file="dependencies.py310-rf50.lock"
    cmd="rm -rf /home/ute/test_repo; pyenv virtualenv-delete -f test_repo; pyenv virtualenv $py_version test_repo; pyenv activate test_repo;
    python -m pip -V; ln -s \$VIRTUAL_ENV /home/ute/test_repo;
    python -m pip --disable-pip-version-check install --no-deps -r /home/ute/test_repository/$dependencies_file;
    echo -e \"\e[32m[INFO] \$(/home/ute/.pyenv/versions/$py_version/envs/test_repo/bin/robot --version)\e[0m\";
    pyenv deactivate"
  elif [ "$1" = "py39" ]; then
    py_version="3.9.14"
    dependencies_file="dependencies.py39.lock"
    cmd="rm -rf /home/ute/test_repo; pyenv virtualenv-delete -f test_repo; pyenv virtualenv $py_version test_repo; pyenv activate test_repo;
    python -m pip -V; ln -s \$VIRTUAL_ENV /home/ute/test_repo;
    python -m pip --disable-pip-version-check install --no-deps -r /home/ute/test_repository/$dependencies_file;
    echo -e \"\e[32m[INFO] \$(/home/ute/.pyenv/versions/$py_version/envs/test_repo/bin/robot --version)\e[0m\";
    pyenv deactivate"
  else:
    echo "not support $1 yet, ask zhangyin for help"
    exit 1
  fi

  if [ ! -e "/home/ute/.pyenv/versions/$py_version" ]; then
    echo -e "\033[0;31m[ERR] no /home/ute/.pyenv/versions/$py_version, need reinstall VM debian system\033[0m"
    exit 1
  fi

  # pull robotws
  echo -e "\e[32m[INFO] pull robotws\e[0m"
  bash -elc "rm -rf /home/ute/test_repository;
  ln -s /home/ute/MN/UTE/robotws /home/ute/test_repository;
  cd /home/ute/test_repository;
  git pull origin master"

  # install ta libraries
  echo -e "\e[32m[INFO] start to install TA libraries\e[0m"
  site=$(get_testline_site)
  update_pip_conf $site

  if [ -z "$VIRTUAL_ENV" ]; then
    bash -elc "$cmd"
  else
    bash -elc "pyenv deactivate; $cmd"
  fi
}

update_bashrc(){
  grep 'robot="source /home/ute/test_repo/bin/activate' /home/ute/.bashrc
  if [ "$?" != "0" ]; then
    echo 'alias robot="source /home/ute/test_repo/bin/activate; robot"' >> /home/ute/.bashrc
  fi
}

######################################
# show help
if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ $(($# % 2)) -eq 1 ]; then
  print_help
  exit 0
fi

# get command options
while getopts "u:p:" opt; do
  case $opt in
    u)
      ute_version="$OPTARG"
      ;;
    p)
      py_tag=$(echo "$OPTARG" | tr '[:upper:]' '[:lower:]')
      ;;
    \?)
      echo "invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# main
install_ute_build $ute_version
install_ta_lib $py_tag
update_bashrc
echo -e "\e[32m[INFO] Please open a new console and start to execute TA case\e[0m"
