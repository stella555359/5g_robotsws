*** Settings ***
Documentation  Description:  CBRS Library with keywords operating with SAS Simulator


*** Keywords ***
Prepare SAS Files
    [Documentation]  Description:           Prepare fresh SAS files with specific configuration.${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                pawel.rokicki@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${alias}=default       # SAS alias: by default it will be crated in /home/ute/SASSim/default
    ...          ${port}=4433           # IP port
    ...          ${config}=None         # SASSim.conf file if not provided than default one will be created
    ...          ${version}=2.0         # SAS version 2.0 or 1.2 or 1.0 only
    ...          ${repository}=/home/ute/SASSimRepo    # dir where SAS repo is stored

    ${is_repo_present}  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${repository}
    IF  not ${is_repo_present}  Get SAS Gerrit Repository

    Run  rm -r /home/ute/SASSim/${alias}
    Run  mkdir /home/ute/SASSim
    Run  cp -r ${repository}/uri/test/py/tools/SASSim/ /home/ute/SASSim/${alias}

    IF  '${config}' == 'None'
        Prepare Default SAS Config  ${alias}  ${port}  ${version}
    ELSE
        Prepare Custom SAS Config  ${alias}  ${port}  ${config}
    END
    ${sas_manager}  OperatingSystem.Get File  /home/ute/SASSim/${alias}/SAS_Manager.py
    ${sas_manager}  Replace String  ${sas_manager}  server_port = 443  server_port = ${port}
    Create File  /home/ute/SASSim/${alias}/SAS_Manager.py  ${sas_manager}
    Unblock SAS In Iptables


Start SAS Process
    [Documentation]  Description:           Prepare and run fresh instance of SAS Simulator      ${\n}
    ...              Return:                Process Id & logs dir                                ${\n}
    ...              Output:                { ${int}, ${string} }                                ${\n}
    ...              Author:                michal.kosicki@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]  ${alias}=default       # SAS alias: by default it will be crated in /home/ute/SASSim/default
    ...          ${port}=4433           # IP port
    ...          ${config}=None         # SASSim.conf file if not provided than default one will be created
    ...          ${version}=2.0         # SAS version 2.0 or 1.2 or 1.0 only
    ...          ${repository}=/home/ute/SASSimRepo    # dir where SAS repo is stored

    Prepare SAS Files  ${alias}  ${port}  ${config}  ${version}  ${repository}
    ${handle}  Start Process  python3  /home/ute/SASSim/${alias}/SAS_Sim.py
    ${pid}  Get Process Id  ${handle}
    ${logs_path}  Set Variable  /home/ute/SASSim/${alias}/SAS_Sim.log

    RETURN  ${pid}  ${logs_path}


Prepare Default SAS Config
    [Arguments]  ${alias}  ${port}  ${version}
    [Documentation]  Author: michal.kosicki@nokia.com
    ...  Maintainer: Michal Kosicki

    ${sas_config}  OperatingSystem.Get File  ${CURDIR}/Configuration/SAS_Sim.conf
    ${sas_config}  Replace String  ${sas_config}  {port}  ${port}
    ${sas_config}  Replace String  ${sas_config}  {alias}  ${alias}
    ${sas_config}  Replace String  ${sas_config}  ts_version = v2.0  ts_version = v${version}
    Create File  /home/ute/SASSim/${alias}/SAS_Sim.conf  ${sas_config}


Prepare Custom SAS Config
    [Arguments]  ${alias}  ${port}  ${config}
    [Documentation]  Author: michal.kosicki@nokia.com
    ...  Maintainer: Michal Kosicki

    ${sas_config}  OperatingSystem.Get File  ${config}
    ${sas_config}  Replace String  ${sas_config}  {port}  ${port}
    ${sas_config}  Replace String  ${sas_config}  {alias}  ${alias}
    Create File  /home/ute/SASSim/${alias}/SAS_Sim.conf  ${sas_config}


Unblock SAS In Iptables
    [Documentation]  Author: michal.kosicki@nokia.com
    ...  Maintainer: Michal Kosicki

    Run  sudo iptables -F
    Run  sudo iptables -X
    Run  sudo iptables-save


Start SAS HTTPS Proxy
    [Arguments]  ${alias}  ${port}
    [Documentation]  Author: michal.kosicki@nokia.com
    ...  Maintainer: Michal Kosicki

    ${proxy}  OperatingSystem.Get File  /home/ute/SASSim/${alias}/HttpsProxy.py
    ${proxy}  Replace String  ${proxy}  PORT_NUM = 4431  PORT_NUM = ${port}
    ${proxy}  Replace String  ${proxy}  LOG_FILE = 'HttpsProxy.log'  LOG_FILE = '/home/ute/SASSim/${alias}/HttpsProxy.log'
    Create File  /home/ute/SASSim/${alias}/HttpsProxy.py  ${proxy}
    ${handle}  Start Process  python3  /home/ute/SASSim/${alias}/HttpsProxy.py
    ${pid}  Get Process Id  ${handle}
    ${https_logs_path}  Set Variable  /home/ute/SASSim/${alias}/HttpsProxy.log

    RETURN  ${pid}  ${https_logs_path}


Kill All SAS Processes
    [Documentation]  Author: michal.kosicki@nokia.com
    ...  Maintainer: Michal Kosicki

    ${pids}  Run  pgrep -f SAS_Sim
    ${pids_number}  Get Line Count  ${pids}

    FOR  ${i}  IN RANGE  ${pids_number}
        ${pid}  Get Line  ${pids}  ${i}
        Run  kill -9 ${pid}
    END


Kill All SAS Proxy Processes
    [Documentation]    Author: michal.kosicki@nokia.com
    ...                Maintainer: Michal Kosicki

    ${pids}   Run    pgrep -f HttpsProxy.py
    ${pids_number}   Get Line Count    ${pids}

    FOR    ${i}    IN RANGE    ${pids_number}
        ${pid}   Get Line    ${pids}    ${i}
        Run    kill -9 ${pid}
    END


Send Command To SAS Manager
    [Arguments]  ${alias}  ${command}
    [Documentation]  Author: michal.kosicki@nokia.com
    ...  Maintainer: Michal Kosicki

    Run  screen -S sas_manager -d -m    # -L ${TEST_LOGS_DIR_PATH}/sas_manager.log
    Sleep  1s
    Run  screen -S sas_manager -p 0 -X stuff "cd /home/ute/SASSim/${alias}^M"
    Sleep  1s
    Run  screen -S sas_manager -p 0 -X stuff "python3 SAS_Manager.py^M"
    Sleep  1s
    Run  screen -S sas_manager -p 0 -X stuff "${command}^M"
    Sleep  1s
    Run  screen -S sas_manager -p 0 -X stuff "exit^M"
    Sleep  1s
    Run  screen -S sas_manager -p 0 -X stuff "exit^M"


Get SAS Logs To Logs Dir
    [Arguments]  ${alias}=default  ${name}=SAS_Sim
    [Documentation]  Author: michal.kosicki@nokia.com

    OperatingSystem.Copy File  /home/ute/SASSim/${alias}/SAS_Sim.log  ${TEST_LOGS_DIR_PATH}/${name}_${alias}.log
    ${parsed_SAS_communication}  Communication CBSD SAS  SAS_Sim_log_file=${TEST_LOGS_DIR_PATH}/${name}_${alias}.log
    FOR  ${item}  IN  @{parsed_SAS_communication}
        Append To File  path=${TEST_LOGS_DIR_PATH}/${name}_${alias}_parsed.log  content=${item}${\n}
    END


Get SAS Proxy Logs To Logs Dir
    [Arguments]  ${alias}
    [Documentation]  Author: lukasz.lechowicz@nokia.com

    Copy File  /home/ute/SASSim/${alias}/HttpsProxy.log  ${TEST_LOGS_DIR_PATH}/HttpsProxy_${alias}.log


Start SAS Sim With Custom Certificates
    [Arguments]  ${alias}=default  ${config}=none
    [Documentation]  Author: aleksandra.chudzik@nokia.com

    IF  '${config}'!='none'
        Remove File  /home/ute/SASSim/${alias}/SAS_Sim.conf
        Copy File  ${config}  /home/ute/SASSim/${alias}/SAS_Sim.conf
    END

    ${handle}  Start Process  python3  /home/ute/SASSim/${alias}/SAS_Sim.py
    ${pid}  Get Process Id  ${handle}
    ${logs_path}  Set Variable  /home/ute/SASSim/${alias}/SAS_Sim.log

    RETURN  ${pid}  ${logs_path}


Get SAS Gerrit Repository
    [Documentation]  Download latest version of repository where SASSim is stored
    [Arguments]  ${dir}=/home/ute/SASSimRepo    #Target location to save donwloaded files

    OperatingSystem.Remove Directory  ${dir}  recursive=True
    OperatingSystem.Create Directory  ${dir}

    Run  cd ${dir}; git init 2>&1 | tee prepare_repo.log
    Run  cd ${dir}; git remote add origin ssh://gerrit.ext.net.nokia.com:29418/MN/OAM/APIGW/sysadapt 2>&1 | tee prepare_repo.log
    Run  cd ${dir}; git -c core.sshCommand="ssh -i ~/.ssh/id_rsa -o 'StrictHostKeyChecking no'" pull origin master 2>&1 | tee prepare_repo.log

    OperatingSystem.Wait Until Created  path=${dir}/uri/test/py/tools/SASSim/nokia04.cert
    OperatingSystem.Wait Until Created  path=${dir}/uri/test/py/tools/SASSim/nokia04.key
    OperatingSystem.Wait Until Created  path=${dir}/uri/test/py/tools/SASSim/ca.cert
