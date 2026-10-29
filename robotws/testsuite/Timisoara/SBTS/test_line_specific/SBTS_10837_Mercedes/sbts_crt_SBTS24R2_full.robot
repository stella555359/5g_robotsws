*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_NL_ASOE_AZQO_AEQN_AHCA    SBTS24R2
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__Snapshot.robot
Resource          ../../LOGS/LOGS__Snapnshot_Collection_Triggered_By_Syslog_Substring.robot


Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
#    ...    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_8048_Sowa/commissioning/SCF_01_SBTS24R2.xml
     ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10837_Mercedes/commissioning/SCF_01_SBTS24R2.xml
#${NETACT_LAB}    &{srnclab1046}
${NETACT_LAB}    &{srnclab2003}

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

[1]Automated__LOGS__Snapshot_Collection_Triggered_By_Syslog_Substring
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_COLLECTION_TIMEOUT}    2700
    ...    AND    LOGS__Snapnshot_Collection_Triggered_By_Syslog_Substring.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapnshot_Collection_Triggered_By_Syslog_Substring
    ...    AND    Set Library Search Order    LOGS__Snapnshot_Collection_Triggered_By_Syslog_Substring
    [Timeout]    14400
    TC__LOGS__Snapnshot_Collection_Triggered_By_Syslog_Substring
    [Teardown]    Run Keywords    LOGS__Snapnshot_Collection_Triggered_By_Syslog_Substring.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
