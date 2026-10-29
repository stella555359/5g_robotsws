*** Settings ***
Documentation
...    author:  Keyun Ma
...    contact: keyun.ma@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/4cells_2T2F
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R1    tl-CLOUD_5G_I_LO_AP_LO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
#${EMIL_FLAG}    ${False}
#${AUTO_ANALYSIS_FLAG}    ${False}
${SYSCOM_FLAG}    ${True}
#${SNAPSHOT_FLAG}    pass:False,fail:False
#${SOS_REPORT_FLAG}    pass:False,fail:False
#${GNB_BIP_FLAG}    ${False}
#${AP_BIP_FLAG}    ${False}
#${RECREATE_WIRESHARK_FLAG}    ${False}

${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SWCONFIG}    0x1003F=1    0x10040=1    0x10041=1    0x1002A=1    0x4F0214=0    0x590072=1    0x66001b=1
...    0x890001=0    0x890002=0    0x890003=1    0x890004=1    0x890005=0    0x890006=0    0x890008=0
#"0x1003F=1"   # ERadCcs_AaSysLogInputLevel,0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable
#"0x10040=1"   # ERadCcs_AaSysLogOutputLevel
#"0x10041=1"   # OutputMode,0=none 1=all 2=udp 3=sic 4=standard output 5=local 6=remote 7=not valid
#"0x1002A=1"   # EMIL, AaTrace used flag:0=not used, 1=used, 2=used only (ignore configuration messages)
#"0x4F0214=0"  # ignore HWF file information in gNB
#"0x590072=1"  # CP_RT
#"0x66001b=1"  # CP_NRT
#"0x890001=0"  # CP_NB log level
#"0x890002=0"  # CP_SB log level
#"0x890003=1"  # CP_UE log level
#"0x890004=1"  # CP_CL log level
#"0x890005=0"  # CP_IF log level
#"0x890006=0"  # CP_SCTP log level
#"0x890008=0"  # CP_E2 log level

@{PARAMS_IN_VENDOR}
...    guaranteedResourceRatioPerCell=20
...    maxNumPucchF3PCSIPerSlotL1Pool=30
...    maxNumPucchF1SRPerSlotL1Pool=30
...    maxNumOfUserL2Pool=20
...    maxNumOfDRBL2Pool=20

*** Test Cases ***
CB008195-ET_C027_Verify_Unsuccessful_NSA_non-GBR_DRB_Admission_Rejecting_in_RG_that_reach_minQuota_with_multiple-cell_pooled_resources_of_handover
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    Verify Unsuccessful NSA non-GBR DRB Admission Rejecting UE context in RG that reach minQuota and
    ...    there is no unused and unreserved multiple-cell pooled resources in Case of PScCell Change
    ...    Requirement Coverage: 5G_RAN_USR_RRM_24990
    ...    2. Test Case Steps:
    ...         Step1: NSA UE11 (2 drb) attach to CELL1 with PLMN-1 with traffic in cell-1
    ...         Step2: NSA UE14 (1drb) attach to CELL1 with PLMN-2 with traffic in cell-1
    ...         Step3: NSA UE11 perform pscell change to cell 3.
    ...         Step4: release all ue
    ...    3. Expected Results:
    ...         step1: UE11 attach success in ResourceGroupId-1
    ...         while 1 drb using dedicated resouce and 2nd drb using common resource with PLMN-1,
    ...         now poolcommonremain=20-used-dedicated=20-2-8-1-8=1
    ...         step2: UE14 attach success in ResourceGroupId-2 with last
    ...         poolcommonremain. now poolcommonremain=0
    ...         step3: HO should be failed since no common resouce.SgNBAdditionRequestReject
    ...         message to MeNB, with Cause Group set to "Radio Network" and Cause
    ...         value set to "no-radio-resources-available";
    [Tags]    QC_XXXXX    C027
    Clear Counter Files
    setup X2 link to gNBs
    NSA UE attach with two DRBs    ue_id=11    selected_plmn=311:489    target_cells=1
    NSA UE attach with one DRB    ue_id=14    selected_plmn=311:406    target_cells=1
    HO from CELL-1 to CELL-3 failed
    Check Counters    ${PM_Counters_C027}
    Release UEs    ue_type=all

*** Keywords ***
Modify Cfg
    ${set_ue11}    catenate    set_ue simulated id=11 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645400
    ${set_ue12}    catenate    set_ue simulated id=12 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645401
    ${set_ue13}    catenate    set_ue simulated id=13 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645402
    ${set_ue14}    catenate    set_ue simulated id=14 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:406:21645403
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    set_bearer id=3 ue=11 qci=8 pdn=1
    Update Cfg    set_bearer id=4 ue=11 qci=7 pdn=1
    Update Cfg    set_bearer id=3 ue=12 qci=8 pdn=1
    Update Cfg    set_bearer id=4 ue=12 qci=7 pdn=1
    Update Cfg    set_bearer id=3 ue=13 qci=8 pdn=1
    Update Cfg    set_bearer id=4 ue=13 qci=7 pdn=1
    Update Cfg    set_bearer id=3 ue=14 qci=8 pdn=1
    Update Cfg    set_bearer id=4 ue=14 qci=7 pdn=1
    Update Cfg    ${set_ue11}
    Update Cfg    ${set_ue12}
    Update Cfg    ${set_ue13}
    Update Cfg    ${set_ue14}

NSA UE attach with two DRBs
    [Arguments]  ${ue_id}=11    ${selected_plmn}=311:489    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 selected_plmn=${selected_plmn}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    UE${ue_id}: Proxy \\(eNB 2 cell ${target_cells}\\) reported successful RA
    Execute Egate Command    bearer_add ue=${ue_id} id=4 filter=0 precedence=0    PGW-initiated Bearer Creation
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=4 by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg

NSA UE attach with one DRB
    [Arguments]  ${ue_id}=11    ${selected_plmn}=311:489    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 selected_plmn=${selected_plmn}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    UE${ue_id}: Proxy \\(eNB 2 cell ${target_cells}\\) reported successful RA
HO from CELL-1 to CELL-3 failed
    ${A3_measid}    get nr meas id for specific type and frequency    ue_id=11    carrierfreq=127210    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=11 meas_id=${A3_measid} event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=61 nrsrp_nr=31 nrsrq_nr=31
    ...   Bearer-type change from SCG-split to MCG is successful
setup X2 link to gNBs
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up

