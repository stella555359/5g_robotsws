*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_LW_1ASIA_2ABIA_FXDB_FRGU_2FXED_2FRHC    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__CNI-19956_Log_File_Documentation_Availability_Check.robot
Resource          ../../LOGS/LOGS__CNI-19956_Log_File_Documentation_Content_Check.robot
Resource          ../../LOGS/LOGS__Snapshot.robot

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...   /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5077_Tesla/commissioning/SCF_01_TRUNK.xml


*** Test Cases ***
[1]Automated__LOGS__CNI-19956_Log_File_Documentation_Availability_Check
    [Setup]    Run Keywords    LOGS__CNI-19956_Log_File_Documentation_Availability_Check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-19956_Log_File_Documentation_Availability_Check
    ...    AND    Set Library Search Order    LOGS__CNI-19956_Log_File_Documentation_Availability_Check
    [Timeout]    14400
    TC__LOGS__CNI-19956_Log_File_Documentation_Availability_Check.robot
    [Teardown]    Run Keywords    LOGS__CNI-19956_Log_File_Documentation_Availability_Check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-19956_Log_File_Documentation_Content_Check
    [Setup]    Run Keywords    LOGS__CNI-19956_Log_File_Documentation_Content_Check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-19956_Log_File_Documentation_Content_Check
    ...    AND    Set Library Search Order    LOGS__CNI-19956_Log_File_Documentation_Content_Check
    [Timeout]    14400
    TC__LOGS__CNI-19956_Log_File_Documentation_Content_Check.robot
    [Teardown]    Run Keywords    LOGS__CNI-19956_Log_File_Documentation_Content_Check.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***

