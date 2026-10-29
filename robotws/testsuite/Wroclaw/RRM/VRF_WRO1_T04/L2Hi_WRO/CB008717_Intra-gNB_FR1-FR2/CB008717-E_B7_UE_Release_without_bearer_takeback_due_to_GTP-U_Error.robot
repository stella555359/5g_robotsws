*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py
Documentation
...    author: Lukasz Filipek
...    maintainer: Lukasz Filipek (lukasz.filipek@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${TRAFFIC_DURATION_SEC_E_B7}=   5m

*** Keywords ***
CB008717-E_B7_UE_Release_without_bearer_takeback_due_to_GTP-U_Error
    Register Nrdc Ue With DL And Ul Traffic With A4
    Check Dl And Ul Data Traffic On Mcg And Scg Leg
    Set Expected Message Flow For UE Context Release For UE1
    Trigger GTP-U Error
    Verify Expected Message Flow For UE Context Release For UE1

Register Nrdc Ue With DL And Ul Traffic With A4
    Register Ue With Default Pdu Session
    Start Traffic 300Mbps In DL and 200Mbps In Ul
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2
    Send A4 Measurement
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2

Trigger GTP-U Error
    Execute egate command    cmd=upf_ue_pdu_inject_error_ind id=1 ue=1 pdu=1 abnormal_scenario=none

Start Traffic 300Mbps In DL and 200Mbps In Ul
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=uec_param id=1 scg_ul_dist_percent=50
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=100 trf_id=2

Check Dl And Ul Data Traffic On Mcg And Scg Leg
    Sleep    ${TRAFFIC_DURATION_SEC_E_B7}
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pdsch
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pdsch scell=1
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pusch
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pusch scell=1
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=dl
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=ul
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
    ...    pdu_id=1    qfi_id=1
    ...    expected_throughput=300    unit=mbps    margin=0.2    direction=dl
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
    ...    pdu_id=1    qfi_id=1
    ...    expected_throughput=200    unit=mbps    margin=0.2    direction=ul
