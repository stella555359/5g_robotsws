*** Settings ***
#Force Tags    STATE_CONFIGURED   RAN_5G   RAN_5G_TDD   5G_RAN_TDD   5G_RAN    SBTS00   SBTS23R1    master_classicalbts_all
#...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...    CA_BTS_OAM_VERIF

Force Tags    RAN_4G   RAN_4G_FDD   4G_RAN_FDD   4G_RAN    SBTS00   SBTS23R1   SBTS23R2   SRAN    CRT   QCD_MN_RAN  QCP_RAN_ST    GENERAL_ST_CB006577
...   CLOUD_R4BO9_CUS


Documentation
...    Author: Szlovak Monika (monika.szlovak@nokia.com)
...    Maintainer: Szlovak Monika (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB006577
...    Sample execution: /opt/ute/python3/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d /opt/ute/logs/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB006577/general.robot
...    Dryrun: /opt/ute/python3/bin/robot -t "39_WebEM_CLI_shall_support_command_softwareUpdate_with_DCC_user"
...    Dryrun: /opt/ute/python3/bin/robot -t "38_WebEM_CLI_shall_support_command_reset_with_DCC_user"
...    --dryrun --log NONE --report NONE --output NONE -v CONFIGURATION:dryrun -C off -d /opt/ute/logs -L TRACE
...    testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB006577/general.robot

Resource    ./resources/CB006577.robot

#Suite Setup       Suite Preconditions
Suite Setup       Run Keywords  Suite Preconditions
...               AND           ADMIN_CLI Suite Setup
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***
[1]WebEM__CLI_shall_support_command_getRadParam_with_DCC_user
    [Tags]   CRT
    [Documentation]
    ...
    4_WebEM_CLI_shall_support_command_getRadParam_with_DCC_user

[1]WebEM__CLI_shall_support_command_startIPCaptureFile_with_DCC_user
    [Tags]   CRT
    [Documentation]
    ...
    8_WebEM_CLI_shall_support_command_startIPCaptureFile_with_DCC_user

[1]WebEM__CLI_shall_support_command_checkAntennas_with_DCC_user
    [Tags]   CRT
    [Documentation]
    ...
    13_WebEM_CLI_shall_support_command_checkAntennas_with_DCC_user

[1]WebEM__CLI_shall_support_command_checkFans_with_DCC_user
    [Tags]   CRT
    [Documentation]
    ...
    15_WebEM_CLI_shall_support_command_checkFans_with_DCC_user

[1]WebEM__CLI_shall_support_command_checkHw_with_DCC_user
    [Tags]   CRT
    [Documentation]
    ...
    16_WebEM_CLI_shall_support_command_checkHw_with_DCC_user

[1]WebEM__CLI_shall_support_command_getBasebandModuleList_with_DCC_user
    [Tags]   CRT
    [Documentation]
    ...
    22_WebEM_CLI_shall_support_command_getBasebandModuleList_with_DCC_user

[1]WebEM__CLI_shall_support_command_getRmodMeasurementsList_with_DCC_user
    [Tags]   CRT
    [Documentation]
    ...
    26_WebEM_CLI_shall_support_command_getRmodMeasurementsList_with_DCC_user

[1]WebEM__CLI_shall_support_command_getSystemModuleList_with_DCC_user
    [Tags]   CRT
    [Documentation]
    ...
    28_WebEM_CLI_shall_support_command_getSystemModuleList_with_DCC_user

[1]WebEM__CLI_shall_support_command_softwareUpdate_with_DCC_user
    [Tags]   CRT
    [Documentation]
    ...
    39_WebEM_CLI_shall_support_command_softwareUpdate_with_DCC_user

[1]WebEM__CLI_shall_support_command_getNmsState_with_DCC_user
    [Tags]   CRT
    [Documentation]
    ...
    45_WebEM_CLI_shall_support_command_getNmsState_with_DCC_user

[1]WebEM__CLI_shall_support_command_getAllTroubleshootingScripts_DCC_user
    [Tags]   CRT
    [Documentation]
    ...
    46_WebEM_CLI_shall_support_command_getAllTroubleshootingScripts_DCC_user

[1]WebEM__CLI_shall_support_command_getRADDebugParameters_with_DCC_user
    [Tags]   CRT
    [Documentation]
    ...
    52_WebEM_CLI_shall_support_command_getRADDebugParameters_with_DCC_user

[1]WebEM__CLI_shall_support_command_resetAllRADDebugParameters_with_DCC_user
    [Tags]   CRT
    [Documentation]
    ...
    56_WebEM_CLI_shall_support_command_resetAllRADDebugParameters_with_DCC_user





