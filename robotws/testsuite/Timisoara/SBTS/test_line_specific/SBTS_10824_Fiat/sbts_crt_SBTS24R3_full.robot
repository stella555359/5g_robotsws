*** Settings ***
Force Tags       QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_NL_10824_1ASIL_1ABIP_1ABIQ_1AVQL_1AHBCC    SBTS24R3
Library          XML  use_lxml=True
Resource         taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource         ../../LOGS/LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10824_Fiat/commissioning/SCF_01_SBTS24R3.xml

${NETACT_LAB}    &{srnclab1015}

*** Test Cases ***
[1]13_CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs
    [Setup]    Run Keywords    LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs
    ...    AND    Set Library Search Order    LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs
    [Timeout]    14400
    TC__LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs
    [Teardown]    Run Keywords    LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
