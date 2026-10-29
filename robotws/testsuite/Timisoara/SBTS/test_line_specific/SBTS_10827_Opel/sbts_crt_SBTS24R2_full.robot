*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_L_10827_1ASIB_3ABIC_1AEQP    SBTS24R2
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__Snapshot.robot
Resource          ../../LOGS/LOGS__CNI-19956_Log_File_Documentation_Availability_Check.robot
Resource          ../../LOGS/LOGS__CNI-19956_Log_File_Documentation_Content_Check.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01
${COMMISSIONING_PATH}
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10827_Opel/commissioning/SCF_01_SBTS24R2.xml

*** Test Cases ***
[1]Automated__LOGS__Snapshot
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__Snapshot.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot
    ...    AND    Set Library Search Order    LOGS__Snapshot
    [Timeout]    14400
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order

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
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
