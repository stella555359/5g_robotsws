*** Settings ***
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/rad_flags.robot
Resource    ../resources/BTS_log_level.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam

*** Variables ***
${STARTUP_TIMEOUT}  10  # Timeout for BTS to startup after reset, default value 10 [min]


*** Keywords ***
TC__LOGS__Log_Level_Restore_Bts_Log_Level
    [Documentation]
    ...
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-15671
    ...
    ...  ******************
    ...  Basic information
    ...  *****************
    ...
    ...  Step 0: Preconditions
    ...  Check if swconfig.txt and swconfig_local.txt files are available on BTS and make a local copy of those files.
    ...
    ...  Step 1: Verify Bts Log Level In WebEM
    ...  Login to WebEM and check if BTS Log Level is correctly set based on the AaSyslog flags.
    ...
    ...  Step 2: Restore Bts Log Level In WebEM
    ...  Perform BTS Log Level restore using WebEM and verify if swconfig.txt and swconfig_local.txt files should be
    ...  removed from BTS and BTS Log Level should be set to Normal.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 2019-05-17 - https://jira3.int.net.nokia.com/browse/TAT-15671 - Initial Creation
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 15.04.2023 - TAT-25131 - resource imports changed due to repo migration
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Log_Level_Restore_Bts_Log_Level.png#
    ...


    Set Tags    CA-LOGS    OWNER-lukasz.targonski@nokia.com    AUTHOR-lukasz.targonski@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS17

    Step 0: Preconditions
    Step 1: Verify Bts Log Level In WebEM
    Step 2: Restore Bts Log Level In WebEM


Step 0: Preconditions
    Log  \nPreconditions  console=${True}
    Set Test Variable  &{LOG_LEVEL_MAP}  1=Full  2=Normal  6=Minimum  other=Different than Minimum, Normal or Full

    sshLibrary.Open Connection  ${SMOD1['IP']}
    sshLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    ${target_bd}=  sshLibrary.List Files In Directory  /ffs/run  swconfig*.txt
    Run Keyword If  'swconfig.txt' in ${target_bd}  Run Keywords
    ...  Run Keyword And Ignore Error  Get File From System Module  source_path=/ffs/run/swconfig.txt  destination_path=${BTS Files}/swconfig.txt
    ...  AND  Set Test Variable  ${SWCONFIG_DOWNLOADED}  ${True}
    ...  ELSE  Set Test Variable  ${SWCONFIG_DOWNLOADED}  ${False}
    Run Keyword If  'swconfig_local.txt' in ${target_bd}  run keywords
    ...  Run Keyword And Ignore Error
    ...  Get File From System Module  source_path=/ffs/run/swconfig_local.txt  destination_path=${BTS Files}/swconfig_local.txt
    ...  AND  Set Test Variable  ${SWCONFIG_LOCAL_DOWNLOADED}  ${True}
    ...  ELSE  Set Test Variable  ${SWCONFIG_LOCAL_DOWNLOADED}  ${False}

Step 1: Verify Bts Log Level In WebEM
    [Documentation]
    ...  In Step 1 It is checked current BTS Log Level is correctly displayed in WebEM.

    Log  \nStep 1: Verify Bts Log Level In WebEM  console=${True}
    ${log_level_value}  rad_flags.Read Bts Log Level Value from AaSyslog
    BTS_log_level.WebEM Login
    BTS_log_level.Go To BTS Log Level View
    ${WebEM_log_level_is_correct}  BTS_log_level.Check If BTS Log Level In WebEM Is Set To  ${log_level_value}
    Close Browser
    Run Keyword If  ${WebEM_log_level_is_correct}
    ...  Log  BTS log level read from WebEM is correctly set to: ${LOG_LEVEL_MAP['${log_level_value}']}  console=${True}
    ...  ELSE  FAIL  BTS log level read from WebEM is incorrectly set to: ${LOG_LEVEL_MAP['${log_level_value}']}

Step 2: Restore Bts Log Level In WebEM
    [Documentation]
    ...  In Step 2 Bts Log Level is restored to default value. swconfig.txt and swconfig_local.txt files should be removed from BTS,
    ...  log level should be set to Normal.

    Log  \nStep 2: Restore Bts Log Level In WebEM  console=${True}
    BTS_log_level.WebEM Login
    BTS_log_level.Go To BTS Log Level View
    BTS_log_level.Restore Bts Log Level
    ${WebEM_log_level_is_correct}  BTS_log_level.Check If BTS Log Level In WebEM Is Set To  2
    Close Browser
    Run Keyword If  ${WebEM_log_level_is_correct}
    ...  Log  BTS log level read from WebEM is correctly set to: Normal  console=${True}
    ...  ELSE  FAIL  BTS log level read from WebEM is not set to: Normal  console=${True}

    sshLibrary.Open Connection  ${SMOD1['IP']}
    sshLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    ${target_bd}=  sshLibrary.List Files In Directory  /ffs/run  swconfig*.txt
    ${swconfig_file_is_present}  Set Variable If  'swconfig.txt' in ${target_bd}  ${True}  ${False}
    ${swconfig_local_file_is_present}  Set Variable If  'swconfig_local.txt' in ${target_bd}  ${True}  ${False}

    Run Keyword If  ${swconfig_file_is_present} or ${swconfig_local_file_is_present}
    ...  FAIL  swconfig.txt or swconfig_local.txt file is present on BTS
    ...  ELSE  Log  swconfig.txt and swconfig_local.txt file are not present on BTS  console=${True}

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}
    Run Keyword If  ${SWCONFIG_DOWNLOADED}  Run Keywords
    ...    ssh.Connect To    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu   alias=OAM-conn
    ...    AND  Log  Restoring swconfig.txt file  console=${True}
    ...    AND  ssh.Upload_file    ${BTS Files}/swconfig.txt  /ffs/run/swconfig.txt    connection=OAM-conn


    Run Keyword If  ${SWCONFIG_LOCAL_DOWNLOADED}  Run Keywords
    ...    ssh.Connect To    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu   alias=OAM-conn
    ...    AND  Log  Restoring swconfig_local.txt file  console=${True}
    ...    AND  ssh.Upload_file    ${BTS Files}/swconfig_local.txt  /ffs/run/swconfig_local.txt    connection=OAM-conn

    Run Keyword If  ${SWCONFIG_DOWNLOADED} or ${SWCONFIG_LOCAL_DOWNLOADED}  Run Keywords
    ...  coam.Reset Site  600
    ...  AND  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  30s  Verify all BTS states
    ...  AND  Log  All cells and modules reached working state  console=${True}

Verify all BTS states
    ${BTS_state_is_correct}    Verify BTS proceduralState  OnAir
    ${system_modules_working}  Verify system modules states
    ${radio_modules_working}   Verify radio modules states
    ${cells_GSM_onair}         Verify GSM cells states
    ${cells_WCDMA_onair}       Verify WCDMA cells states
    ${cells_LTE_onair}         Verify LTE cells states
    ${cells_NR_onair}          Verify NR cells states
    ${BTS_modules_states}=  Set Variable If  ${BTS_state_is_correct} and ${system_modules_working} and ${radio_modules_working}
    ...  ${True}  ${False}
    ${Cells_states}=        Set Variable If  ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair} and ${cells_NR_onair}
    ...  ${True}  ${False}
    Run Keyword If  ${BTS_modules_states} and ${Cells_states}
    ...  Log  BTS verification status passed    console=${True}
    ...  ELSE  Fail  At least one module, cell or BTS proceduralState indicates a faulty state!

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
