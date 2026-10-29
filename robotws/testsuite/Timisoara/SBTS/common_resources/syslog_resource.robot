*** Settings ***
Library  taf.sw.syslog  WITH NAME  syslog
Resource  ca_SBTS_general.robot

Documentation  This suite contains KWs used by some TCs and resources.


*** Keywords ***
Verify Swconfig.Txt File And Flag On PC
    [Documentation]
    ...  This keyword verifies if swconfig.txt exists on Primary Core.
    ...  If swconfig file exists, flag is verified next.
    ...  If swconfig does not exist on PC or flag si not present in it, syslog collection won't start.
    ...  *AUTHOR*: anna.benzar@nokia.com

    Open Connection To Primary Core
    SSHLibrary.Write  cd /ffs/run
    SSHLibrary.Set Client Configuration  prompt=${SPACE}>
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ls -l | grep swconfig.txt
    ${pc_output}  SSHLibrary.Read Until Prompt
    ${pc_status}  Run Keyword And Return Status
    ...  Should Contain  ${pc_output}  swconfig.txt
    Run Keyword If  ${pc_status} == ${FALSE}
    ...  Run Keywords
    ...  Set Test Restriction  swconfig file does not exist on PC. Syslog collection won't start.
    ...  AND
    ...  Return From Keyword
    ${flag_2_status}  Run Keyword And Return Status
    ...  Verify Swconfig Flag To Have The Given Value  0x10041  2
    ${flag_5_status}  Run Keyword And Return Status
    ...  Verify Swconfig Flag To Have The Given Value  0x10041  5
    Run Keyword If  ${flag_2_status} or ${flag_5_status}
    ...  Set Test Variable  ${PC_FLAG_EXISTS}  ${TRUE}
    ...  ELSE
    ...  Set Test Restriction  Flag: 0x10041 does not exist in swconfig file on PC. Syslog collection won't start.
    Log  ${PC_FLAG_EXISTS}

    [Teardown]  Run Keywords  SSHLibrary.Switch Connection  primary_ssh  AND  SSHLibrary.Close Connection


Verify Swconfig.Txt File And Flag On SC
    [Documentation]
    ...  This keyword verifies if swconfig.txt exists on Secondary Core.
    ...  If swconfig file exists, flag is verified next.
    ...  If swconfig does not exist on SC or flag si not present in it, syslog collection won't start.
    ...  *AUTHOR*: anna.benzar@nokia.com

    Open Connection To Secondary Core Through VM  secondary_core_ssh
    SSHLibrary.Write  cd /ffs/run
    SSHLibrary.Set Client Configuration  prompt=${SPACE}>
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ls -l | grep swconfig.txt
    ${sc_output}  SSHLibrary.Read Until Prompt
    ${sc_status}  Run Keyword And Return Status
    ...  Should Contain  ${sc_output}  swconfig.txt
    Run Keyword If  ${sc_status} == ${FALSE}
    ...  Run Keywords
    ...  Set Test Restriction  swconfig file does not exist on SC. Syslog collection won't start.
    ...  AND
    ...  Return From Keyword
    ${flag_2_status}  Run Keyword And Return Status
    ...  Verify Swconfig Flag To Have The Given Value  0x10041  2
    ${flag_5_status}  Run Keyword And Return Status
    ...  Verify Swconfig Flag To Have The Given Value  0x10041  5
    Run Keyword If  ${flag_2_status} or ${flag_5_status}
    ...  Set Test Variable  ${SC_FLAG_EXISTS}  ${TRUE}
    ...  ELSE
    ...  Set Test Restriction  Flag: 0x10041 does not exist in swconfig file on SC. Syslog collection won't start.
    Run Keyword If  ${flag_5_status}
    ...  Set Test Variable  ${UNIFIED_SYSLOGS}  ${TRUE}
    Log  ${SC_FLAG_EXISTS}

    [Teardown]  Run Keywords  SSHLibrary.Switch Connection  secondary_core_ssh  AND  SSHLibrary.Close Connection


Open Connection To Secondary Core Through VM
    [Documentation]  Opens SSH connection to the secondary core via VM using the given alias.
    [Arguments]  ${alias}

    Open Connection To Secondary VM Through Public Key  ${alias}
    SSHLibrary.Write  ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "192.168.255.119"
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ssh toor4nsn@192.168.255.119
    SSHLibrary.Set Client Configuration  prompt=Password:
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  oZPS0POrRieRtu
    SSHLibrary.Set Client Configuration  prompt=:~ >
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  pwd
    ${output}  SSHLibrary.Read Until Prompt
    Should Contain  ${output}  /user/toor4nsn  Connection to SC failed. [NOK]


Verify Swconfig Flag To Have The Given Value
    [Documentation]
    ...  This keyword verifies the value of a given flag in swconfig.txt.
    ...  Connection to PC or SC must be opened beforehand.
    ...  *AUTHOR*: anna.benzar@nokia.com
    [Arguments]  ${flag}  ${value}

    SSHLibrary.Set Client Configuration  timeout=10s
    SSHLibrary.Write  cat /ffs/run/swconfig.txt
    ${swconfig_output}  SSHLibrary.Read Until Prompt
    ${flag_line}  Get Lines Containing String  ${swconfig_output}  ${flag}
    ${flag_matches}  Get Regexp Matches  ${flag_line}  (\\n|^)${flag}(${SPACE}*)=(${SPACE}*)${value}
    Should Not Be Empty  ${flag_matches}  Flag: ${flag} not found with given value: ${value}. [NOK]


Start Syslog Collection On ${module}
    [Documentation]
    ...  This keyword starts syslog collection on BTS or PC.
    ...  If syslog collection is started on BTS ${ALL_SYSLOGS_STARTED} is set on ${TRUE}.
    ...  If syslog collection is started on PC ${PC_SYSLOGS_STARTED} is set on ${TRUE}.
    ...  *AUTHOR*: anna.benzar@nokia.com

    Log  Trying to start syslog collection on ${module}...  console=True
    Run Keyword And Ignore Error  Teardown aliases and kill syslog processes  before_collection_ssh
    ${output}  OperatingSystem.Run  pyenv global
    ${output}  Get Regexp Matches  ${output}  [0-9]+\.[0-9]+\.[0-9]+
    ${python_version}  Set Variable  ${output}[0]
    ${syslog_started}  Run Keyword And Return Status  Wait Until Keyword Succeeds  2 min  10 sec
    ...  syslog.Start Syslog  log_dir=${UDP_LOGS}
    ...                       log_name=SYSLOG_${module}_UDP
    ...                       host_ip=${PC_IP1}
    ...                       add_line_number=True
    ...                       virtualenv_dir=/home/ute/.pyenv/versions/${python_version}/envs/test_repo
    ...                       alias=SYSLOG_${module}_UDP
    Run Keyword If  ${syslog_started}
    ...  Log  Syslog collection started on ${module}...  console=True
    ...  ELSE
    ...  Set Test Restriction  ${module} syslog collection did not start and will not be collected during TC execution.
    Run Keyword If  '${module}' == 'BTS'
    ...  Set Test Variable  ${ALL_SYSLOGS_STARTED}  ${syslog_started}
    ...  ELSE
    ...  Set Test Variable  ${PC_SYSLOGS_STARTED}  ${syslog_started}


Start SC Syslog Collection
    [Documentation]
    ...  This keyword starts syslog collection on SC.
    ...  If syslog is started succesfully, ${SC_SYSLOGS_STARTED} is set on ${TRUE}.

    Log  Trying to start syslog collection on Secondary Core...  console=True
    ${sc_python_version}  Get Python Version For Secondary VM
    ${syslog_started}  Run Keyword And Return Status  Wait Until Keyword Succeeds  2 min  10 sec
    ...  syslog.Start Syslog  log_dir=${UDP_LOGS}
    ...                       log_name=SYSLOG_SC_UDP
    ...                       host_ip=${PC_IP2}
    ...                       add_line_number=True
    ...                       virtualenv_dir=/home/ute/.pyenv/versions/${sc_python_version}/envs/test_repo
    ...                       alias=SYSLOG_SC_UDP
    Run Keyword If  ${syslog_started}
    ...  Log  Syslog collection started on Secondary Core...  console=True
    ...  ELSE
    ...  Set Test Restriction  SC syslog collection did not start and will not be collected during TC execution.
    Set Test Variable  ${SC_SYSLOGS_STARTED}  ${syslog_started}


Teardown aliases and kill syslog processes
    [Documentation]
    ...  This keyword stops all aliases for syslog and kills all syslog processes on Primary VM and Secondary VM.
    [Arguments]  ${alias}

    syslog.Teardown All Aliases For Syslog
    Log  Kill syslog processes on primary VM.  console=true
    Process.Run Process  pkill -f cli_syslog  shell=${TRUE}
    Run Keyword If  ${SMOD2_EXISTS}
    ...  Kill syslog processes on secondary VM  ${alias}

    ${command_output}  OperatingSystem.Run  ps aux | grep btslog
    ${btslog_line}  Get Lines Containing String  ${command_output}  /opt/btslog/btslog ss-style
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${btslog_line}
    Return From Keyword If  not(${status})
    ${string}  Get Regexp Matches  ${btslog_line}  ute${SPACE}+[0-9]+
    ${pid}  Fetch From Right  ${string}[0]  ${SPACE}
    OperatingSystem.Run  kill -9 ${pid}


Kill syslog processes on secondary VM
    [Documentation]  Kills syslog-related processes (e.g. cli_syslog) on the secondary VM.
    [Arguments]  ${alias}

    Log  Kill syslog processes on secondary VM.  console=true
    Open Connection To Secondary VM Through Public Key  ${alias}
    SSHLibrary.Write  pkill -f cli_syslog
    SSHLibrary.Read until Prompt

    [Teardown]  Run Keywords  SSHLibrary.Switch Connection  ${alias}  AND  SSHLibrary.Close Connection

Unarchive Syslogs From UDPLogs Directory
    [Documentation]
    ...  This keyword unarchives tar.gz files from current UDPLogs directory.
    ...  All syslog files will be saved in "${UDPLogs}/Unarchived" directory.

    ${syslog_archives}  OperatingSystem.List Directory  ${UDP_LOGS}  pattern=*.tar.gz
    OperatingSystem.Run  mkdir ${UDP_LOGS}/Unarchived
    FOR  ${file}  IN  @{syslog_archives}
        OperatingSystem.Run  tar -xf ${UDP_LOGS}/${file} -C ${UDP_LOGS}/Unarchived
    END
    Directory Should Not Be Empty  ${UDP_LOGS}/Unarchived  Didn't manage to unarchive syslog archives. [NOK]


Delete Unarchived Syslogs From UDPLogs Directory
    [Documentation]
     ...  This keyword deletes "Unarchived" directory from UDPLogs.

     ${exists_status}  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${UDP_LOGS}/Unarchived
     Return From Keyword If  not(${exists_status})
     OperatingSystem.Run  rm -rf ${UDP_LOGS}/Unarchived
