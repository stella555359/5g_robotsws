*** Settings ***
Documentation
    ...  Main purpose of TC is installing SBTS SW on SM using internal script - YAFT

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${TARGET_SW_PATTERN}  SBTS  # Pattern for software which will be installed
${TARGET_SW_DIRECTORY}  /home/ute/btsauto/TARGET_SW  # Directory with software, which will be installed
${SWCONFIG_PATH}  ${EMPTY}  # Path to prepared swconfig.txt
${WAIT_SBTS_REBOOT}  200   # Timeout after SBTS reboot


*** Keywords ***
TC__DEV__SBTS_SOAM_installing_using_YAFT
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-8524
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.02.2018 - https://jira3.int.net.nokia.com/browse/TAT-8524
    ...  - 06.05.2019 - TAT-15703  COMPA - SBTS SOAM installing using YAFT failed with YAFT error
    ...  - 22.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-18127 - Change min_dowtime and timeout in step2
    ...  - 28.2.2023  - https://jiradc.ext.net.nokia.com/browse/TAT-24279 - Remove unzipped sw folder after install for more space available on VM
    ...  - 24.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29438 - Add timeout after SBTS reboot
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/DEV__SBTS_SOAM_installing_using_YAFT.png

    Set Tags  CA-COMPA  AUTHOR-tomasz.1.filipek@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  SW-SBTS17  SW-SBTS18

    TC Preconditions
    Step1: Install Software
    Step2: Wait Until BTS Stabilizes
    Step3: Check Active Alarms And Software Version


TC Preconditions
    Log Step Header  TC Preconditions
    Setup Hran Compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Verify SSH Connection And Enable If Necessary
    ${yaft_lock_status}  Yaft Lock Check
    Run Keyword If  ${yaft_lock_status}
    ...  Yaft Lock Remove


Step1: Install Software
    [Timeout]  15m

    Log Step Header  Step1: Install software
    ${yaft_status}  Install Software From Directory Using Yaft  software_pattern=${TARGET_SW_PATTERN}  ssh_user=${SMOD1['USERNAME']}
    ...  ssh_password=${SMOD1['PASSWORD']}  msm_ip=${SMOD1['TRS_IP']}  packages_directory=${TARGET_SW_DIRECTORY}  swconfig_path=${SWCONFIG_PATH}
    ...  log_directory=${TEST_FILES}  ignore_fsps=${TRUE}
    Run Keyword If  ${yaft_status}
    ...  Log To Console With Time  Install with yaft ended successfully
    ...  ELSE
    ...  Set Test Failed  YAFT error. Check log for more information  fail_fast=${TRUE}


Step2: Wait Until BTS Stabilizes
    Log Step Header  Step2: Wait until BTS stabilizes
    Sleep  ${WAIT_SBTS_REBOOT}
    ${ping_status}  Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=600  timeout=1800
    Run Keyword If  ${ping_status}
    ...  Log To Console With Time  BTS is stable after installing ${TARGET_SW_PATTERN}
    ...  ELSE
    ...  Set Test Failed  BTS is not stable after installing ${TARGET_SW_PATTERN}  fail_fast=${TRUE}


Step3: Check Active Alarms And Software Version
    Log Step Header  Step3: Check software version and active alarms
    Start Admin
    Start Infomodel
    Admin Check Active Alarms TAF
    ${customized_pattern}  Get Regexp Matches  ${TARGET_SW_PATTERN}  .*SBTS.*?_(.*)  1
    ${customized_pattern}  Set Variable If  len(${customized_pattern}) > 0  ${customized_pattern[0]}  ${TARGET_SW_PATTERN}
    ${active_sw}  Infomodel Get Active SW Version
    Log  Active SW: ${active_sw}  console=true
    Should Match Regexp  ${active_sw}  ${customized_pattern}
    Log  Active software match expected pattern  console=true


TC Setup
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  admin_launch=${FALSE}  syslog_launch=${TRUE}  infomodel_launch=${FALSE}  modules_check=${FALSE}  cells_check=${FALSE}
    ...  alarms_check=${FALSE}


TC Teardown
    Remove Unzipped Sw Folder After Installation  ${TARGET_SW_DIRECTORY}
    Common Test Teardown
