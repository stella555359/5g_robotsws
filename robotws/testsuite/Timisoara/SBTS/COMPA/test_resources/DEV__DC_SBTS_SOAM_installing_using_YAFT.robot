*** Settings ***
Documentation
    ...  Main purpose of TC is installing SBTS SW on dual core SMs using internal script - YAFT

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${TARGET_SW_PATTERN}  SBTS  # Pattern for software which will be installed
${SW_DIRECTORY}  /home/ute/CLEANING_SW  # Directory with software, which will be installed
${SWCONFIG_PATH}  /home/ute/swconfigs/swconfig.txt  # Path to prepared swconfig.txt
${PING_STABLE_TIMEOUT}  400  # Timeout for ping until target is stable

*** Keywords ***
TC__DEV__DC_SBTS_SOAM_installing_using_YAFT
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10988
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  24.07.2018 - https://jira3.int.net.nokia.com/browse/TAT-10988
    ...  28.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17535 - Changes timeouts (Step3)
    ...  14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  28.2.2023  - https://jiradc.ext.net.nokia.com/browse/TAT-24279 - Remove unzipped sw folder after install for more space available on VM
    ...  17.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26557 - Enable SSH on SBTS for FDSW software
    ...  24.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29020 - Add Ping stable timeout variable for fixing ping timeout
    ...  04.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29361 - Fix for ASIA+FSMF configuration
    ...  12.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29882 - Fix for smod not installed
    ...  16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29883 - Teardown admin connection in tc preconditions
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-10988.png

    Set Tags  CA-COMPA  OWNER-daniel.cozma@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  PHASE-CRT  PHASE-COMPA  SW-SBTS17  SW-SBTS18  SW-SBTS19

    TC Preconditions
    Step1: Install Software On ESM
    Step2: Install Software On MSM
    Step3: Wait Until BTS Stabilizes
    Step4: Check Active Alarms And Software Version


TC Preconditions
    Log Important Message  TC Preconditions
    Setup Hran Compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Verify SSH Connection And Enable If Necessary
    ssh.Connect To  ${PC_IP2}  ute  ute
    Check Available Ping Of ESM
    Log  ESM ping:${ESM_IP}  console=true
    Setup SSH Keys On Extension  ${ESM_IP}
    SW File Availability On Master VM
    SW File Availability On Extension VM
    # Start Admin
    # ${sm_variant}  Wait Until Keyword Succeeds  20m  1m  Check SMOD To Not Have Availability Status
    # Log  ${PACKAGE_MASTER}  console=true
    # ${ASIA}  Set Variable  'ASIA AirScale Common'
    # ${FSMF}  Set Variable  'Flexi System Module Outdoor FSMF'
    # IF  '${sm_variant[0]}[productName]'==${ASIA} and '${sm_variant[1]}[productName]'==${FSMF} and '${PACKAGE_MASTER}' >= 'SBTS23R1'
    # ...  Fail  Test cannot be use for ASIA+FSMF configuration starting with 23R1
    Upload Swconfig To Extension

    # [Teardown]  coam.Teardown Admin


Check SMOD To Not Have Availability Status
    ${smods}  coam.Get parameters for all  SMOD
    FOR  ${smod}  IN  @{smods}
        Dictionary Should Not Contain Key  ${smod}  availabilityStatus
    END
    Log  ${smods[0]}[productName]  console=true
    Log  ${smods[1]}[productName]  console=true

    RETURN  ${smods}

Step1: Install Software On ESM
    Log Step Header  step1: Install Software On ESM
    Execute Yaft On Extension
    Execute Reboot On ESM
    Check If ESM Is Reachable


Step2: Install Software On MSM
    Log Step Header  step2: Install Software On MSM
    Check If MSM Is Reachable
    TRY
        ${yaft_status}  Install Software From Directory Using Yaft  software_pattern=${TARGET_SW_PATTERN}  ssh_user=${SMOD1['USERNAME']}
        ...  ssh_password=${SMOD1['PASSWORD']}  msm_ip=${SMOD1['TRS_IP']}  ignore_fsps=${TRUE}  packages_directory=${SW_DIRECTORY}
        ...  swconfig_path=${SWCONFIG_PATH}  log_directory=${TEST_FILES}
    EXCEPT  OSError: *  type=glob  AS  ${error}
        Log  Wait for reboot.  console=true
        IF  "Ping timed out" in """${error}"""
            ${ip}  Create List  ${OAM_BTS_IP}
            ping.Wait For No Ping  ${ip}  timeout=120
        ELSE
            Fail  ${error}
        END
        ${yaft_status}  Set Variable  ${TRUE}
    END
    IF  ${yaft_status}
      Log  Install with yaft ended successfully  console=true
    ELSE
      Set Test Failed  YAFT error. Check log for more information  fail_fast=${TRUE}
    END


Step3: Wait Until BTS Stabilizes
    Log Step Header  step3: Wait until BTS stabilizes
    Sleep  300s
    ${ping_stable_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5x  20
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=0  timeout=${PING_STABLE_TIMEOUT}
    IF  ${ping_stable_status}
      Log  BTS is stable after installing ${TARGET_SW_PATTERN}  console=true
    ELSE
      Set Test Failed  BTS is not stable after installing ${TARGET_SW_PATTERN}  fail_fast=${TRUE}
    END


Step4: Check Active Alarms And Software Version
    Log Step Header  step4: Check active alarms and software version
    Start Admin
    Start Infomodel
    Admin Check Active Alarms TAF
    ${customized_pattern}  Get Regexp Matches  ${TARGET_SW_PATTERN}  .*SBTS.*?_(.*)  1
    ${customized_pattern}  Set Variable If  len(${customized_pattern}) > 0  ${customized_pattern[0]}  ${TARGET_SW_PATTERN}
    ${active_sw}  Infomodel Get Active SW Version
    Log  Active SW: ${active_sw}  console=true
    Should Match Regexp  ${active_sw}  ${customized_pattern}
    Log  Active software match expected pattern  console=true


Check Available Ping Of ESM
    Log  Check available ping on ESM  console=true
    ${esm_ping_119}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=192.168.255.119  timeout=5  remote_host=${PC_IP2}
    ${esm_ping_129}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=192.168.255.129  timeout=5  remote_host=${PC_IP2}
    IF  ${esm_ping_129}
      Set Test Variable  ${ESM_IP}  192.168.255.129
    ELSE IF  ${esm_ping_119}
      Set Test Variable  ${ESM_IP}  192.168.255.119
    ELSE
      Fail  ESM is not reachable
    END


SW File Availability On Master VM
    Log  Get newest sw file from ${SW_DIRECTORY}  console=true
    ${package_master_path}  hran_file_operations.Get Newest File From Directory  ${SW_DIRECTORY}  *.zip
    Log  SW file path:${package_master_path}  console=true
    ${path}  ${package_master}  Split Path  ${package_master_path}
    Log  SW file:${package_master}  console=true
    IF  '${package_master}'== ${None}  Fail  No proper SW file found in ${SW_DIRECTORY}
    Set Test Variable  ${PACKAGE_MASTER}


SW File Availability On Extension VM
    Log  Check if SW file already exists in directory:${SW_DIRECTORY} on extension VM: ${PC_IP2}  console=true
    ${status}  ${package_extension}  Run Keyword And Ignore Error
    ...  ssh.Execute  ls ${SW_DIRECTORY} | grep .zip$
    Log  Files in directory: ${package_extension}  console=true
    ${package_extension}  Strip String  ${package_extension}
    ${package_present}  Run Keyword And Return Status
    ...  Should Match  ${package_extension}  ${PACKAGE_MASTER}
    IF  ${package_present} != ${TRUE}  Upload SW File To Extension
    Log  Remove old yaft logs on extension VM  console=true
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  ssh.Execute  rm -r /tmp/yaft_logs/
    ${return_code}  ssh.Get Exit Status
    Log  Return code: ${return_code}  console=true


Upload Swconfig To Extension
    Log  Check if swconfig exists in: ${SWCONFIG_PATH}  console=true
    OperatingSystem.File Should Exist  ${SWCONFIG_PATH}
    Log  Swich swconfig in /opt/yaft/libyaft/  console=true
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  ssh.Execute  sudo rm /opt/yaft/libyaft/swconfig.txt
    ${status}  ${msg_upload}  Run Keyword And Ignore Error
    ...  Run And Return Rc And Output  scp ${SWCONFIG_PATH} ute@${PC_IP2}:/tmp/swconfig.txt
    Log  Return code:${msg_upload[0]}  console=true
    ${status}  ${msg_upload}  Run Keyword And Ignore Error
    ...  ssh.Execute  sudo mv /tmp/swconfig.txt /opt/yaft/libyaft/swconfig.txt
    ${return_code}  ssh.Get Exit Status
    Log  Return code: ${return_code}  console=true


Upload SW File To Extension
    Log  Upload SW File To Extension${\n}Remove ${SW_DIRECTORY} on extension VM  console=true
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  ssh.Execute  sudo rm -r ${SW_DIRECTORY}
    ${return_code}  ssh.Get Exit Status
    Log  Return code: ${return_code}  console=true
    Log  Create ${SW_DIRECTORY} on extension VM  console=true
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  ssh.Execute  mkdir -p ${SW_DIRECTORY}
    ${return_code}  ssh.Get Exit Status
    Log  Return code: ${return_code}  console=true
    Log  Upload SW file to extension VM  console=true
    ${status}  ${msg_upload}  Run Keyword And Ignore Error
    ...  Run And Return Rc And Output  scp ${SW_DIRECTORY}/*.zip ute@${PC_IP2}:${SW_DIRECTORY}
    Log  Status: ${status}  console=true
    ${status_ls}  ${msg_ls}  Run Keyword And Ignore Error
    ...  ssh.Execute  ls -l ${SW_DIRECTORY}
    IF  '${msg_upload[0]}'=='1'  Fail  msg: ${msg_upload}


Execute Yaft On Extension
    Log  Execute yaft on extension  console=true
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  ssh.Execute
    ...  python /opt/yaft/yaft.py -i ${ESM_IP} -z ${SW_DIRECTORY}/${PACKAGE_MASTER} -l /tmp/yaft_logs -R --ignore_FSPs --clean_to_default
    Download Yaft Log From Extension
    ssh.Assert Exit Status  0
    Log  Yaft on extension performed successfully  console=true


Check If ESM Is Reachable
    Log  Check if ESM is reachable  console=true
    FOR  ${run}  IN RANGE  1  30
        Log  Try:${run} -> Check ping status for 192.168.255.119 and 192.168.255.119  console=true
        ${esm_ping_regain_119}  Run Keyword And Return Status
        ...  Wait For Target To Be Reachable  hostname=192.168.255.119  timeout=5  remote_host=${PC_IP2}
        ${esm_ping_regain_129}  Run Keyword And Return Status
        ...  Wait For Target To Be Reachable  hostname=192.168.255.129  timeout=5  remote_host=${PC_IP2}
        Return From Keyword If  ${esm_ping_regain_119} or ${esm_ping_regain_129}
    END
    Fail  ESM didn't regain ping in timeout


Execute Reboot On ESM
    Log  Execute reboot on ESM  console=true
    ${vm_conn_proxy}  ssh.Connect To  ${PC_IP2}  ute  ute
    ssh.Connect To  ${ESM_IP}  toor4nsn  oZPS0POrRieRtu  proxy=${vm_conn_proxy}
    Run Keyword And Ignore Error  ssh.Execute  mount -o remount,rw,sync /ffs/stb
    Run Keyword And Ignore Error  ssh.Execute  rm -rf /ffs/stb/config/*
    ${status}  ${msg}  Run Keyword And Ignore Error  ssh.Execute  reboot
    ${return_code}  ssh.Get Exit Status
    Log  Return code: ${return_code}  console=true
    Log  Check if ESM is not reachable  console=true
    ${esm_ping_lost}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${ESM_IP}  timeout=60  remote_host=${PC_IP2}
    Return From Keyword If  ${esm_ping_lost}
    Fail  ESM didn't lose ping

    [Teardown]  Disconnect  ${vm_conn_proxy}


Download Yaft Log From Extension
    Log  Download yaft log from extension  console=true
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  Run And Return Rc And Output  scp ute@${PC_IP2}:/tmp/yaft_logs/*.log ${TEST_FILES}
    Log  Return code: ${msg[1]}  console=true


Check If MSM Is Reachable
    Log  Check if MSM is reachable  console=true
    Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=120
    Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=120  timeout=700


TC Setup
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  admin_launch=${FALSE}  syslog_launch=${TRUE}  infomodel_launch=${FALSE}  modules_check=${FALSE}  cells_check=${FALSE}
    ...  alarms_check=${FALSE}


TC Teardown
    Remove Unzipped Sw Folder After Installation  ${SW_DIRECTORY}
    Common Test Teardown  collect_snapshot=never
