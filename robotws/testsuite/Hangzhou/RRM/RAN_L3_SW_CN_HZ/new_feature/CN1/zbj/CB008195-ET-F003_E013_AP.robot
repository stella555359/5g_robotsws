*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-CLOUD_5G_I_BOO_AP_LOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${EMIL_FLAG}    ${False}
${AUTO_ANALYSIS_FLAG}    ${False}
${SYSCOM_FLAG}    ${True}
${SNAPSHOT_FLAG}    pass:False,fail:False
${SOS_REPORT_FLAG}    pass:False,fail:False
${GNB_BIP_FLAG}    ${False}
${AP_BIP_FLAG}    ${False}
${RECREATE_WIRESHARK_FLAG}    ${False}
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
#SYSLOG output severity prints (0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable)
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
@{Result_F003}
...    rrcReconfigurationComplete
...    pcid:50, scellIdx:1
...    SCellIndex 1 activated successfully

@{Expect_Failed_Result_F003}
...    rrcReconfigurationComplete

@{Online_Param}
...    NRBTS-1/NRCELL-2:sliceAwareAdmissionCtrlEnabled=true
...    NRCELL-2:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-2

@{Online_Param_back}
...    NRBTS-1/NRCELL-2:sliceAwareAdmissionCtrlEnabled=false
...    delete:NRCELL-2:nrResourceGroupProfileRacDN

${expected_scaling_factor_1}    SEPARATOR=
...    [Scaling factor] = 0.818; [Multicell group type]: L2POOL;[Resource type]: UeContxt;
${expected_scaling_factor_2}    SEPARATOR=
...    [Scaling factor] = 0.666; [Multicell group type]: L2POOL;[Resource type]: UeContxt;
${expected_nrcell1-1}     NRCELL-1:rgRacMinQuotaLimitationInfo=${expected_scaling_factor_1}
${expected_nrcell2-2}     NRCELL-2:rgRacMinQuotaLimitationInfo=${expected_scaling_factor_2}


${pdu_id}    1
${gw_id}    1
${PLMN_1}    311:489
${PLMN_2}    311:500


*** Test Cases ***
CB008195-E-ET_013_Verify_Cell_level_Slice_Aware_Admission_Control_while_PDU_session_is_ongoing_and_SPID_modification
    [Documentation]
    ...    The test scenario is intended to verify:
    ...    1.This user scenario describes This user scenario describes the gNB behavior while activation of Slice-Aware
    ...    Admission Control when there is established PDU session..
    ...    2.
    ...    Test Case Setings:
    ...    NRBTS-1/NRCELL:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1
    ...    ================================================================================================================
    ...   "NRCELL-14:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-2",
    ...   "NRCELL-11:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-2",
    ...   # "NRCELL-2:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-2",
    ...   "NRCELL-1:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-1:applyCellRacForPrivilegedUE=1",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1|nrResourceGroupId=1",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2|nrResourceGroupId=2",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=SNSSAI-1",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=NRPLMN-1|resourceDN=NRPLMN-1",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=90",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=90",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=NRPLMN-2|resourceDN=NRPLMN-2",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=10",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=10",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-1:nrResourceGroupProfileId=1",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1|nrResourceGroupId=1",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2|nrResourceGroupId=2",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=SNSSAI-1",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=NRPLMN-1|resourceDN=NRPLMN-1",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=26",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=0",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:nrResourceList:resourceDN=NRPLMN-2|resourceDN=NRPLMN-2",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:maxQuota=74",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:minQuota=24",
    ...   "NRBTS-1/NRRESOURCEGROUP_PROFILE-2:nrResourceGroupProfileId=2",
    ...    =================================================================================================================
    [Tags]    QC_*    E013
    Clear Counter files
#    Checking the scalingFactor    expected_scalingfactor=${expected_nrcell1-1}
    UE Attach To Target Cell    ue_id=81    nwslice=1    cell_id=2
    NSA UE attach    ue_id=91    selected_plmn=${PLMN_1}    target_cells=2
    NSA UE attach failed    ue_id=92    selected_plmn=${PLMN_1}    target_cells=2
    Delta Commission Parameters    ${Online_Param}
#    Checking the scalingFactor    expected_scalingfactor=${expected_nrcell2-2}
    UE Attach To Target Cell    ue_id=85    nwslice=2    cell_id=2
    UE Attach To Target Cell failed    ue_id=86    cell_id=2
    Check Counters    pm_counters_expression=${PM_Counters_Check_ET_F03}

*** Keywords ***
Modify Cfg
    ${gnb3_cell1}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01
    ...    tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=524310:524310 gscn=6549 mandatory_for_activation=off
   Update Cfg    ${gnb3_cell1}
   Update Cfg    set_amf_region id=1 tac_list=0,200,300 plmn=311:489,311:500
   Update Cfg    set_nwslice id=1 snssai=0x01:13714341 default=on ue=all amf_region_id=1 plmn_list=311:489,311:500
   Update Cfg    set_nwslice id=2 snssai=0x01:13714342 ue=all amf_region_id=1 plmn_list=311:489,311:500
   Update Cfg    set_nwslice id=3 snssai=0x01:13714343 ue=all amf_region_id=1 plmn_list=311:489,311:500

Set UE Parameters Before Register
    [Arguments]    ${send_xn_setup}=true    ${ho_type}=xn_based
    Execute Egate Command    ue_history_information_list id=1 action=reset
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=81 ue_history_list=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=${send_xn_setup} sa_ho=${ho_type}
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    #build XN setup
    Execute Egate Command    ue_gnb_param id=81 candidate_cells_hex_for_interrat_ho=0B1FFAB95F571630684325A3C7

UE Attach To Target Cell
    [Arguments]    ${cell_id}=1    ${ue_id}=81    ${pcell_dl}=0    ${nwslice}=3
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    Should Contain    ${ret1}    drx-Config setup
    Send Throuput    ue_id=${ue_id}
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}

UE Attach To Target Cell failed
    [Arguments]    ${cell_id}=1    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    RRC Reject was received
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=0
    sleep    10s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pcell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=10    ${scell_dl}=10    ${ul}=0    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Trigger ScellAdd or ScellChange
    [Arguments]    ${Result}    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=80    ${srsrq_nr}=50    ${ue_id}=81
    ...    ${pcell_dl}=0    ${scell_dl}=0    ${scell_id}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${Result}
    Verify Throuput on Pcell and Scell    pcell_dl=${pcell_dl}    scell_dl=${scell_dl}    scell_id=${scell_id}

Trigger ScellAdd or ScellChange and expect failed
    [Arguments]    ${expected_failed_result}    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=80    ${srsrq_nr}=50    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    fail_regexp=${expected_failed_result}

NSA UE attach
    [Arguments]  ${ue_id}=91    ${selected_plmn}=311:489    ${target_cells}=1    ${bearer_id}=2
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 selected_plmn=${selected_plmn}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    UE${ue_id}: Proxy \\(eNB 2 cell ${target_cells}\\) reported successful RA

NSA UE attach failed
    [Arguments]  ${ue_id}=91    ${selected_plmn}=311:489    ${target_cells}=1    ${bearer_id}=2
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 selected_plmn=${selected_plmn}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    no-radio-resources-available
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: ----- UE-initiated NAS DETACH PROCEDURE IS COMPLETED -----

Checking the scalingFactor
    [Arguments]  ${expected_scalingfactor}
    Object Should Exist    ${expected_scalingfactor}    timeout=10
