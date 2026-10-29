*** Settings ***
Documentation
...
...  AUTHOR          :   Chaithanya.H,S  chaithanya.h_s@nokia.com
...  MAINTAINER      :   Chaithanya.H,S  chaithanya.h_s@nokia.com
...  INTRODUCTION    :   CNI-109585 Scanning_and_recovery_success_for_Multiple_UE_supporting_large_smallBWP_To_psBWP
...  TEST SET NAME   :   CNI109585_B_11_CB008954_large_small_ToPsBWP_SwitchFailure_scanning_recovery_success_robustness
...  TESTING SPLIT   :   Split-B
...  REFERENCES      :   CNI-109585-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_25858

Resource         ./CNI109585_resource.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Library          ta5g_enb
Library          ta5g_pm_counters

Suite Setup         Run keywords    Suite setup from scratch
...                 AND    CNI109585_resource.Perform SCF Delta Commissioning with MULTILBWP_CHANGES_SCAN.json
...                 AND    CNI109585_resource.Perform SCF Delta Commissioning with Counter_parameter.json
...                 AND    CNI109585_resource.Perform SCF Delta Commissioning with CELL3_FREQ_CHANGES.json

...                 AND    Configure eth3 IP
...                 AND    Load CFG and verify cell status   ${wts_cfg_file}   3    3

#Test Teardown    Run Keywords    Run Keyword and Ignore Error    Get Sos Report

Test Teardown    Run Keywords    Run Keyword and Ignore Error      wts_sim_keywords.Clean edaemon and egate
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
#${wts_cfg_file}        ${CURDIR}/config/wts/basic_setup_BWP_SWITCH_8954.cfg
${wts_cfg_file}        ${CURDIR}/../CB013684/config/basic_setup_cell1_cni109585_cell2_cb013684.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${UE_ID}       1
${QFI_ID1}     1
${TRF_ID1}     1
${Q_O_ADD1}    1
${Target_Cells}    1
${epc_log_path}    /tmp/
${Start_UE_ID_LBWP}    3
${End_UE_ID_LBWP}      3
${UE_ID_LBWP}    3
${UE_ID_SBWP}    4
${Start_UE_ID_SBWP}    4
${End_UE_ID_SBWP}      4

*** Test Cases ***
[1][1.0] CNI109585B_11_CB008954_largeToPsBWP_SwitchFailure_scanning_recovery_success
    Set test variable      ${LOG_PATH}
    ${TEST_LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${TEST_LOG_PATH}
    log to console   Suite setup successful ...
    Run Keyword and continue on failure    Start log   btslog
    Scanning And Recovery successful    UE_ID=${UE_ID_LBWP}
    Run Keyword and continue on failure    Validate Counters For Scanning And Recovery Success
    Scanning And Recovery successful    UE_ID=${UE_ID_SBWP}
    Run Keyword and continue on failure    Validate Counters For Scanning And Recovery Success SBWP
    Run Keyword and continue on failure    Stop log   btslog      test_scenario=attach_log

*** Keywords ***
Scanning And Recovery successful
    [Arguments]    ${UE_ID}
    wts_sim_keywords.UE Register should be Successful     ue_id=${UE_ID}
    wts_sim_keywords.Trigger data    ue_id=${UE_ID}     dir=dl      pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=mbps
    ...    traffic_rate=1
    wts_sim_keywords.Trigger data    ue_id=${UE_ID}     dir=ul       pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=mbps
    ...     traffic_rate=1
#    Register multi ues and send 1 mbps data    start_ue_id=${start_ue_id}   end_ue_id=${end_ue_id}
    log to console   attach and data trigger complete for all ues ...
    Wait until the next Measurement Period starts
    Run Keyword and continue on failure    Start log  biptaf
    AP commands to Drop bwp switching DCIs SUE    profile_id=1    num_dci_drop=6     UE_ID=${UE_ID}
    wts_sim_keywords.Trigger data    ue_id=${UE_ID}     dir=dl      pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=kbps
    ... 	traffic_rate=10
    wts_sim_keywords.Trigger data    ue_id=${UE_ID}     dir=ul       pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=kbps
    ... 	traffic_rate=10
#    Trigger dl_ul data in kbps     start_ue_id=${start_ue_id}   end_ue_id=${end_ue_id}    dl_rate=10    ul_rate=10
    log to console    Traffic reduced to kbps ...
    Run Keyword and continue on failure    Stop log   biptaf