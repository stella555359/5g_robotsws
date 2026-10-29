*** Settings ***
Documentation  Tests for ASOG

Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NLG_10829_2ASIM_1ABIO_1ABIA_2ABIP_3AHLOB_3AHFIG_3AEHC    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot

Resource          ../../LOGS/LOGS__CNI_42395_Snapshot_startup_Log_ERROR_prints_ASIA_ASIK.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10312_Seat/commissioning/SCF_01_TRUNK.xml


${NETACT_LAB}    &{srnclab1047}

*** Test Cases ***
LOGS__Snapshot_startup_Log_ERROR_prints
    [Setup]    Run Keywords    LOGS__CNI_42395_Snapshot_startup_Log_ERROR_prints_ASIA_ASIK.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI_42395_Snapshot_startup_Log_ERROR_prints_ASIA_ASIK
    ...    AND    Set Library Search Order    LOGS__CNI_42395_Snapshot_startup_Log_ERROR_prints_ASIA_ASIK
    [Timeout]    14400
    TC__LOGS__CNI_42395_Snapshot_startup_Log_ERROR_prints
    [Teardown]    Run Keywords    LOGS__CNI_42395_Snapshot_startup_Log_ERROR_prints_ASIA_ASIK.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
