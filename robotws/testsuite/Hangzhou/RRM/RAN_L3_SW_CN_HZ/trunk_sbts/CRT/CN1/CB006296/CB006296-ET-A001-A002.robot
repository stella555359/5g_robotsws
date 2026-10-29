*** Settings ***
Documentation     Inter MeNb HO without SgNB change normal and abnormal scenarios.
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT_no_cloud    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG2    owner-junhui.he    release-SBTS22R3    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{delete useless cell}
...    delete:MRBTS-1/NRBTS-1/NRCELL-2
...    delete:MRBTS-1/NRBTS-1/NRCELLGRP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
...    NRDU-1:refNrCellGroup=0
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs

@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:actInterMeNBMobility=true
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=NSA
...    delete:NRCELL-1:trackingAreaDN

${UE_ID}    11
${INTER_MENB_HO_RRC_RECONF_SUCC}    M55128C00504
@{counters_origin}    ${INTER_MENB_HO_RRC_RECONF_SUCC}=0
@{counters_success}    ${INTER_MENB_HO_RRC_RECONF_SUCC}=1
@{counters_fail}    ${INTER_MENB_HO_RRC_RECONF_SUCC}=0
${SA_NSA_MODEL}    NSA

*** Test Cases ***
CB006296-ET-A001_Verify_SgNB_addition_support_for_inter_MeNB_HO_without_change_in_SCG_configuration
    [Documentation]    US1:MeNB changes,without SgNB changing
    [Tags]    QC_47220    A001
    Clear Counter Files
#    Check Counters    @{counters_origin}
    Start To Capture Wireshark Log    Normal
    Nsa Attach Ue ${UE_ID}
    #Start To Capture Wireshark Log    Normal
    Trigger Normal HO
    Analysis A001 normal scenario
    Check Counters    @{counters_success}
    [Teardown]    Recover Env And Test Teardown

CB006296-ET-A002_Verify_excpetion_scenario_target_MeNB_sends_sgnbrelreq_before_sends_SgNBReconfCom_to_SgNB
    [Documentation]    US2 : During HO procedure,trigger target Menb sends sgnb_rel_req to SgNB before itself sedns sgnb_reconf_complete to SgNB.
    [Tags]    QC_61527
    Clear Counter Files
    Check Counters    @{counters_origin}
    Start To Capture Wireshark Log    Abnormal
    Nsa Attach Ue ${UE_ID}
    Trigger Abnormal Scenario During HO
    Analysis A002 abnormal scenario
    Check Counters    @{counters_fail}
    Ue Detach
	

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=1
    Precondition

Modify Cfg
    ${eNB11}    catenate
    ...    set_enb id=11 plmn=311:489 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127 x2u=10.0.1.137
    ...    type=simulated x2_peers=1
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    ${eNB11_cell11}    catenate
    ...    set_cell id=11 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:12218 earfcn=2000:20000 tdd_cell=on mandatory_for_activation=off
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7
    Update Cfg    ${eNB11}
    Update Cfg    ${eNB11_cell11}

Perform Steps After Onair
    Delta Commission Parameters    ${delete useless cell}

Nsa Attach Ue ${UE_ID}
    Execute Egate Command    ue_attach id=${UE_ID}    pass_regexp=UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${UE_ID} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    pass_regexp=reported successful RA

Precondition
    Execute Egate Command    trace protocol=x2 enb=11 on
    Execute Egate Command    enb_x2_link_up enb=11 target=2    pass_regexp=is up    timeout=20s
    Execute Egate Command    enb_endc_param id=1 keep_endc_on_ho=on
    Execute Egate Command    enb_endc_param id=11 keep_endc_on_ho=on

Trigger Normal HO
    Execute Egate Command    ue_ho id=${UE_ID} ho_mode=INTRA_LTE enb=11 cell=11
    ...    pass_regexp==== Intra-SGW X2 Handover \\(eNB 1 -> eNB 11\\) completed ===
    ...    timeout=20s    sleep_time=5

Analysis A001 normal scenario
    Check Wireshark Log    ${CURDIR}${/}a2a_CB006296_A001${/}a2a.ini    name=Normal    wait_string=UEContextRelease::1
	
Recover Env And Test Teardown
    Execute Egate Command    ue_detach id=${UE_ID}    UE${UE_ID}: detached    timeout=20s
    Execute Egate Command    ue_change_location id=${UE_ID} cell=1 enb=1    location updated to eNB-1 cell 1    timeout=20s
    Common Test Teardown And Stop Capture Logs

Trigger Abnormal Scenario During HO
    Execute Egate Command    enb_endc_param id=11 ue_context_kept_indicator=off
    Execute Egate Command    enb_endc_param id=11 menb_failure_scenario=sgnb_rel_request_before_sgnb_reconf_complete
    Execute Egate Command    ue_ho id=${UE_ID} ho_mode=INTRA_LTE enb=11 cell=11    The UE stays at source cell - eNB 1 Cell 1    
    ...    timeout=20s    sleep_time=5

Analysis A002 abnormal scenario
    Check Wireshark Log    ${CURDIR}${/}a2a_CB006296_A002${/}a2a.ini    name=Abnormal    wait_string=ErrorIndication::1

Ue Detach
    Execute Egate Command    ue_detach id=${UE_ID}    UE${UE_ID}: detached    timeout=20s
