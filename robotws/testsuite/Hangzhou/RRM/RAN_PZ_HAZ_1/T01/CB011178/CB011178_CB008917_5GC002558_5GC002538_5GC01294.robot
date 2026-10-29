*** Settings ***
Documentation
...   Author:  zhixia
...   Contact: zhixia.qin@nokia-sbell.com

Suite Setup       Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC
Test Setup        Common Test Setup For AIC
Test Teardown     Common Test Teardown For AIC

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22
...                CRT
...                TRUNK


Test Timeout    360 minutes

Resource    ../../Resources/Cloud/AIC_Common_Resource.robot
Resource     Common_KeyWord.robot



*** Test Cases ***
Pre_condition_attenuator
    Run Keyword And Ignore Error  Set attenuator   value1=40   value3=40  value5=40   value7=40  value10=0   value12=0
    Run Keyword And Ignore Error  Set attenuator   value9=20  RU_id=${1}   du_id=${1}   model=${tl.attenuator[1].model}
    ...   attenuator_id=${1}
    Run Keyword And Ignore Error  Set attenuator   value14=0   value16=0   RU_id=${2}   model=${tl.attenuator[2].model}
     ...   attenuator_id=${2}

Pre_condition_UE
    Run Keyword And Ignore Error   Prepare Multi UEs For Dingli

CB010411_TC01_RMOD_1_CB010411_5GC002538_F_InterWorking_2Beam_8x4MIMO_TwoUEs
    [Tags]    QC_32354       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 17/03/2023,Qin zhixia,initial version
    ...    17.3.2023,zhixia.qin@nokia-sbell.com, draft
    ...    using beamforming to test. celltype=4DL4UL
    ${dl_expcted_tput_on}  Set Variable   360
    ${dl_expcted_tput_off}  Set Variable   300
    Prepare UE For Dingli   ue_index=3
    Detach single UE For Dingli    ue_index=3
    Log to Console    \n***enable 2538***
    Enable Disable 5GC002538   true    true   true  false  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
#    wait until keyword succeeds    60    10    vDU Check All Cells Status Should Be Onair
    Attach single UE For Dingli   ue_index=3
    Start DL Traffic For Dingli   ue_index=3
    sleep    60s
    ${tput_pdsch_on}=    AIC_UE.pioneer.Check Throughput     direction=dl    ue_alias=UE_3   expected_throughput=${dl_expcted_tput_on}
    log to console         ${tput_pdsch_on}
    Run Keyword And Ignore Error    Stop single UE For Dingli  ue_index=2
    Log to Console    \n***disable 2538***
    Enable Disable 5GC002538   false    false   false  false  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
#    wait until keyword succeeds    60    10    vDU Check All Cells Status Should Be Onair
    Attach single UE For Dingli    ue_index=3
    Start DL Traffic For Dingli    ue_index=3
    sleep    60s
    ${tput_pdsch_off}=    AIC_UE.pioneer.Check Throughput     direction=dl    ue_alias=UE_3    expected_throughput=${dl_expcted_tput_off}
    log to console         ${tput_pdsch_off}
    Compare Tput    ${tput_pdsch_on}    ${tput_pdsch_off}
    [Teardown]    CB010411_TC01 Teardown

CB009552_TC07_RMOD_1_CB009552_C_007_RAN-NIC_Event_Based_IQ_Data_Capture_L2_event_M2M
    [Tags]    QC_32390           QCD_MN_RAN      QCP_RAN_VRF
    log to console    L2PS suspicious event
    Set L2PS Rnd Debug Paramters   subCellId=${0}
    @{ul_nr_subcell_list}   create list
    ${alias}   set variable   vdu_con
    &{ul_subcell_dict}  Create Dictionary
    set to dictionary  ${ul_subcell_dict}  nrCellId=${1}   subCellId=${0}
    append to list   ${ul_nr_subcell_list}   ${ul_subcell_dict}
    log to console   ${ul_nr_subcell_list}

    @{dl_nr_subcell_list}   create list
    &{dl_subcell_dict}  Create Dictionary
    set to dictionary  ${dl_subcell_dict}  nrCellId=${1}   subCellId=${0}
    append to list   ${dl_nr_subcell_list}   ${dl_subcell_dict}

    Activate IQ Data Data Configuration and Delete Operation   ul_nr_subcell_list=${ul_nr_subcell_list}
    ...   dl_nr_subcell_list=${dl_nr_subcell_list}
    ...   capture_on_event_from_l1_hi_and_l1_low=${False}  alias=${alias}
    Prepare UE For Dingli   ue_index=3
    Attach single UE For Dingli   ue_index=3
    Run Keyword And Ignore Error  Start UL Traffic For Dingli   ue_index=3
    Detach single UE For Dingli   ue_index=3
    wait until keyword succeeds    5 min    10 sec    get alarm for vdu   alias=${alias}   expect_fault_id=8101    alarm_exist_flag=${True}
    ${snapshot_file}    Log Collection    start    snapshot    product_type=vdu    bts_index=${0}    cudu_index=${0}
    [Teardown]    CB009552_TC07 Teardown

CB009552_TC05_RMOD_1_CB009552_C_005_RAN-NIC_Event_Based_IQ_Data_Capture_Ext2_WebEM
    [Tags]    QC_32389           QCD_MN_RAN      QCP_RAN_VRF
    log to console    ULPHY suspicious event
    @{new_value_list}  Create List  31 - EPhyEvent_PuschSnapshotVerification
    Enable suspicious event   new_value=${new_value_list}
    @{ul_nr_subcell_list}   create list
    ${alias}   set variable   vdu_con
    &{ul_subcell_dict}  Create Dictionary
    set to dictionary  ${ul_subcell_dict}  nrCellId=${1}   subCellId=${0}
    append to list   ${ul_nr_subcell_list}   ${ul_subcell_dict}
    log to console   ${ul_nr_subcell_list}
    Activate IQ Data Data Configuration and Delete Operation   ul_nr_subcell_list=${ul_nr_subcell_list}    alias=${alias}
    Prepare UE For Dingli   ue_index=3
    Attach single UE For Dingli   ue_index=3
    Run Keyword And Ignore Error  Start UL Traffic For Dingli   ue_index=3
    wait until keyword succeeds    2 min    10 sec    get alarm for vdu   alias=${alias}   expect_fault_id=8101    alarm_exist_flag=${True}
    Parse iqdata Log   alias=${alias}
     ...   filter_pattern=.*E529_l1a_IqSnapshotBuffer.bin.xz
     ...   iq_file_name=MRBTS-${MRBTS_ID}_E529_l1a_IqSnapshotBuffer.bin.xz
     get alarm for vdu   alias=${alias}   expect_fault_id=8101    alarm_exist_flag=${False}
    [Teardown]    CB009552_TC05 Teardown

CB009552_TC28_CB009552_C_028_L1_IQ_Capture_On_Demand_UTF
    [Tags]    QC_32383           QCD_MN_RAN      QCP_RAN_VRF
    Activate Service Port
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${argument_demand}
    Log Collection    start    L1_IQ    product_type=vdu    bts_index=${0}    dict_argument=${dict_argument}
    sleep    1min
    ${local_file_path}    Log Collection    stop_and_download    L1_IQ    product_type=vdu    bts_index=${0}    dict_argument=${dict_argument}

CB009552_TC29_CB009552_C_029_L1_IQ_Capture_Event_based_UTF
    [Tags]    QC_32384           QCD_MN_RAN     QCP_RAN_VRF
    Activate Service Port
    Prepare UE For Dingli   ue_index=2
    Parse iqdata Log for UTF
     ...   filter_pattern=.*E529_l1a_iqSnapshotBuffer.bin.xz
     ...   iq_file_name=MRBTS-${MRBTS_ID}_E529_l1a_iqSnapshotBuffer.bin.xz
    [Teardown]    CB009552_TC29 Teardown

CB011178_TC02_CB011178_5GC002558_A_Activate_PRB_blanking_functionality_for_UE_in_SA_mode
     [Tags]    QC_32455       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 20/09/2023,Qin zhixia,initial version
    ...    10.7.2023,zhixia.qin@nokia-sbell.com, draft
    ...    using beamforming to test. celltype=4DL4UL
    ${dl_expected_tput}  Set Variable   120
    ${ul_expected_tput}  Set Variable   55
    Prepare UE For Dingli   ue_index=0
    Detach single UE For Dingli   ue_index=0
    Log to Console    \n***enable 2558***
    Enable Disable 5GC002558   delta_file_path=${case_path}/config/5GC002558_20M_enbale.json
    sleep  300s
#    BTS Operation    operation=verify    product_type=vdu   cudu_index=0    verify_status=CELL_ONAIR
    Attach single UE For Dingli   ue_index=0
    Start DL Traffic For Dingli   ue_index=0
    Start UL Traffic For Dingli   ue_index=0
    ${tput_ul}=    AIC_UE.pioneer.Check Throughput     direction=ul    ue_alias=UE_0    expected_throughput=${ul_expected_tput}
    log to console         ${tput_ul}
    ${tput_dl}=    AIC_UE.pioneer.Check Throughput     direction=dl    ue_alias=UE_0    expected_throughput=${dl_expected_tput}
    log to console         ${tput_dl}
    [Teardown]    CB011178_TC02 Teardown

*** Keywords ***

CB010411_TC01 Teardown
    Run Keyword And Ignore Error    Stop single UE For Dingli    ue_index=2
    Run Keyword And Ignore Error    Stop single UE For Dingli    ue_index=3
    Common Test Teardown For AIC

CB009552_TC07 Teardown
    [Arguments]    ${alias}=vdu_conn
    Deactivate IQ Data Data Configuration and Delete Operation   alias=${alias}
    Restore L2PS Rnd Debug Paramters
    Run Keyword And Ignore Error   Stop single UE For Dingli  ue_index=2
    Run Keyword And Ignore Error   Stop single UE For Dingli  ue_index=3
    Common Test Teardown For AIC

CB009552_TC05 Teardown
    [Arguments]    ${alias}=vdu_conn
    Deactivate IQ Data Data Configuration and Delete Operation   alias=${alias}
    Disable suspicious event
    Run Keyword And Ignore Error    Stop single UE For Dingli  ue_index=2
    Run Keyword And Ignore Error    Stop single UE For Dingli  ue_index=3
    Common Test Teardown For AIC

CB009552_TC29 Teardown
    Run Keyword And Ignore Error    Stop single UE For Dingli    ue_index=2
    Common Test Teardown For AIC

CB011178_TC01 Teardown
    Run Keyword And Ignore Error    Stop single UE For Dingli    ue_index=0
    Common Test Teardown For AIC

CB011178_TC02 Teardown
    Run Keyword And Ignore Error    Stop single UE For Dingli    ue_index=0
    Enable Disable 5GC002558    delta_file_path=${case_path}/config/5GC002558_20M_disable.json
    sleep  300s
    wait until keyword succeeds    10 min    30 sec    BTS Operation    operation=verify    product_type=vdu
    ...  cudu_index=0    verify_status=CELL_ONAIR
    Common Test Teardown For AIC