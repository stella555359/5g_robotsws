*** Settings ***
Documentation  Trunk tests
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NLWG_10831_1ASIB_1ABIO_1ABIN_1ABIA_1FXDB_1AHBCB_1AHBOA   SBTS00
#
Variables    ./../../../../SBTS/resources/common_vars.py
Resource    ../../../../SBTS/resources/pm_logs_frame.robot
Resource     L3_call.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01
${MRBTS_ID}    10312

${COMMISSIONING_PATH}=    SEPARATOR=
...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10831_Tesla/commissioning/SCF_01_TRUNK.xml

${Snap_by_fault_to_LSS_max5_in_24hPATH}=    SEPARATOR=
...  LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination_and_limit_of_maximum_5snapshots_within_24hours


*** Test Cases ***

Test_Call
    [Tags]      ReTest
    [Setup]    Run Keywords       sleep    1s    #test_call_NSA.TC Setup
    ...    AND    Modify Resource Search Order    test_call_NSA
    ...    AND    Set Library Search Order    test_call_NSA
    [Timeout]    14400
#    TC__test_call_SA
#    Run Keyword    UE__NR_SA_PS_Call
     Run Keyword   Step0: Call For T&T vdu33


*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
