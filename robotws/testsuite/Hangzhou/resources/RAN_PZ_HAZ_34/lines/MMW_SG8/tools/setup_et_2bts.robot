*** Settings ***
Documentation
...    Author:yin zhang
...    contact:yin.zhang@nokia-sbell.com
...    squad group:VRF3_7
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown
Resource          ../resources/DevHZ5_resource_ET.robot

*** Variables ***
${GNB_CONFIG}    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F
${SA_UE_ID}    1
${NSA_UE_ID}    31

*** Test Cases ***
Setup GNB
    Test SA UE Traffic
    Test NSA UE Traffic

*** Keywords ***
Start BTS With Specified Config Files
    Common Suite Setup And Setup 2Airphone Env    tl_type=${GNB_CONFIG}

Test SA UE Traffic
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${wait_timer}=0.5
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered    sleep_time=${wait_timer}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    QoS Routing Table    sleep_time=${wait_timer}
    Traffic Should Be Ok    ue_id=${ue_id}    pdu=1    type=SA

Test NSA UE Traffic
    [Arguments]    ${ue_id}=${NSA_UE_ID}    ${cmd_endc_regexp}=reported successful RA    ${wait_timer}=0.5
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE    sleep_time=${wait_timer}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    ${cmd_endc_regexp}
    ...    sleep_time=${wait_timer}
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA


