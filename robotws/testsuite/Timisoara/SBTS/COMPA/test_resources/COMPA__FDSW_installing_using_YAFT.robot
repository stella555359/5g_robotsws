*** Settings ***
Documentation
    ...  Main purpose of TC is installing FDSW SW on SM using internal script - YAFT

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${SOFTWARE_PATTERN}  FDSW  # Pattern for software which will be installed
${SOFTWARE_DIRECTORY}  /home/ute/btsauto/TARGET_SW  # Directory with software, which will be installed
${SWCONFIG_PATH}  ${EMPTY}  # Path to prepared swconfig.txt
${WAIT_FOR_SITE_RESET_DSC}  ${FALSE}  # Option for DSC setup
${TIMEOUT_FOR_RESET_WAITING}  360  # How many seconds should KW wait for reset
${PING_STABLE_TIMEOUT}  400  # Timeout for ping until target is stable


*** Keywords ***
TC__COMPA__FDSW_installing_using_YAFT
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-4856
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.02.2017 - https://jira3.int.net.nokia.com/browse/TAT-4856 - New Test Case
    ...  - 27.02.2018 - https://jira3.int.net.nokia.com/browse/TAT-8124 - Yaft installation updated, added hran compa setup
    ...  - 06.05.2010 - TAT-15703 - COMPA - SBTS SOAM installing using YAFT failed with YAFT error
    ...  - 07.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17803 - Remove imports of hran_swbt libraries in COMPA TCs
    ...  - 22.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-18060 - Add possibility of using IP:192.168.255.119 to YAFT
    ...  - 03.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-17856 - Add support for Rescue Console ( >=FDSW18SP)
    ...  - 20.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18328 - Add option to wait for Site Reset (DSC)
    ...  - 08.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24252 - Remove ute_btssm library and check FDSW version
    ...  - 18.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25398 - failed with List '${sw_file}' has no item in index 0.
    ...  - 29.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29098 - Add Ping stable timeout variable for fixing ping timeout
    ...  - 12.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29098 - Fix RC connection
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-4856.png

    Set Tags  CA-COMPA  OWNER-daniel.cozma@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  AUTHOR-jaroslaw.piszczala@nokia.com  PHASE-COMPA  PHASE-CRT
    ...  SW-FDSW

    Step0: Verify SSH Connection
    Step1: Install Software
    Step2: Wait Till BTS Is Stable
    Step3: Check Software Version


Step0: Verify SSH Connection
    Log Step Header  Step0: Verify SSH connection
    Setup Hran Compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Run Keyword And Ignore Error
    ...  Verify SSH Connection And Enable If Necessary
    Check If IP Address For BTS Is 119 Or 129
    ${yaft_lock_status}  Yaft Lock Check  ${MSM_IP}
    IF  ${yaft_lock_status}  Yaft Lock Remove


Step1: Install Software
    [Timeout]  15m

    Log Step Header  Step1: Install software
    IF  ${WAIT_FOR_SITE_RESET_DSC}
      Ping Check After SWM Operation  ping_loss_timeout=${TIMEOUT_FOR_RESET_WAITING}  stability_min_up=60  ping_address=${MSM_IP}
    END
    Check FDSW Software
    Install Software Using Yaft  software_pattern=${SOFTWARE_PATTERN}  software_directory=${SOFTWARE_DIRECTORY}  swconfig_path=${SWCONFIG_PATH}
    ...  msm_ip=${MSM_IP}


Step2: Wait Till BTS Is Stable
    Log Step Header  Step2: Wait till BTS is stable
    Sleep  300s
    ${ping_stable_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5x  20
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=0  timeout=${PING_STABLE_TIMEOUT}
    IF  ${ping_stable_status}
      Log  BTS is stable after installing ${TARGET_SW_PATTERN}  console=true
    ELSE
      Recovery Power Hardware
    END

Step3: Check Software Version
    Log Step Header  Step3: Check software version
    Verify SSH Connection And Enable If Necessary
    ${active_sw}  ${passive_sw}  Get Active And Passive SW Version From Rescue Console
    Set Tags For Software  SW_AFTER_OPERATION  ${active_sw}  ${passive_sw}
    Check If Software Match Software Pattern  ${active_sw}  ${SOFTWARE_PATTERN}


Check If IP Address For BTS Is 119 Or 129
    Log  Check if IP address for BTS is 119 or 129  console=true
    ${ping_119}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=192.168.255.119  timeout=5
    ${ping_129}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=192.168.255.129  timeout=5
    IF  ${ping_119}
      Set Test Variable  ${MSM_IP}  192.168.255.119
    ELSE IF  ${ping_129}
      Set Test Variable  ${MSM_IP}  192.168.255.129
    ELSE
      Fail  BTS is not reachable
    END
    Log  Will use IP:${MSM_IP} for YAFT procedure  console=true


Check FDSW Software
    ${sw_file}  OperatingSystem.List Files In Directory  ${SOFTWARE_DIRECTORY}  *FDSW*
    ${sw_match}  Get Regexp Matches  ${sw_file}[0]  FDSW(...)  1
    IF  '${sw_match}[0]'<'18'  Fail  Software is not compatible.


TC Setup
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  admin_launch=${FALSE}  syslog_launch=${FALSE}  infomodel_launch=${FALSE}  modules_check=${FALSE}  cells_check=${FALSE}
    ...  alarms_check=${FALSE}


TC Teardown
    Remove Unzipped Sw Folder After Installation  ${SOFTWARE_DIRECTORY}
    Common Test Teardown
