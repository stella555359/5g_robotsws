*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_L_ASOF_AZQC    SBTS24R1
Library           XML  use_lxml=True
Resource       taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource       ../../LOGS/LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_100793_Gandalf/commissioning/SCF_01_SBTS24R1.xml

*** Test Cases ***
[1]Automated__LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords
    [Setup]    Run Keywords    LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords
    ...    AND    Set Library Search Order    LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords
    [Timeout]    14400
    TC__LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords
    [Teardown]    Run Keywords    LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
