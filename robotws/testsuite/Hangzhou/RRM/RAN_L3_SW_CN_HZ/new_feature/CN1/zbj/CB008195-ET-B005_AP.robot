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
...    0x890001=0    0x890002=0    0x890003=1    0x890004=1    0x890005=0    0x890006=0    0x890008=0    0x5902A0=1
@{Result_F003}
...    rrcReconfigurationComplete
...    pcid:50, scellIdx:1
...    SCellIndex 1 activated successfully
@{Expect_Failed_Result_F003}
...    rrcReconfigurationComplete
${pdu_id}    1
${gw_id}    1

@{expect_Resume}
...    rrcResumeRequest1
...    rrcResume
...    rrcResumeComplete

@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    nextHopChainingCount
...    t380
...    NR_RRC_INACTIVE
...    Is INACTIVE

*** Test Cases ***
CB008195-ET-B005_Verify Suc SA GBR DRB cell limits with maxNumOfGBRBearersSA in Common pool and maxGBRTrafficLimit in dedicate pool during PDU setup
    [Documentation]
    ...    The test scenario is intended to verify This user scenario:
    ...    The purpose of this test case is to verify gNB behavior with Slice Aware Admission Control enabled when PDU session setup with GBR
    ...    bearers is requested and all resources required for PDU session, DRB(s) and SDAP can be allocated within Resource Group dedicated pool.
    ...    executed for each statically configured GBR <threshold> listed below:
    ...    NRCELL.maxNumOfGBRBearersSA
    ...    NRCELL.maxGBRTrafficLimit
    ...    Test Case Setings:
    ...    NRBTS-1/NRCELL-2:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-2
    ...    NRBTS-1/NRCELL-1:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1
    ...    ================================================================================================================
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=SNSSAI-1
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=46    # 46%*10 = 4.6, max 4 ,  common pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=16    # 16*10 = 1.6, max 1 ,  dedicated pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=40    # 40%*10 = 4.0, max 4,  common pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=22    # 22%*10 = 2.2, max 2,  dedicated pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=50    # 50%*10 = 5.0, max 5,  common pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=32    # 32%*10 = 3.2, max 3,  dedicated pool
    ...    =================================================================================================================
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=SNSSAI-1
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=15     # 15%*10 = 1.5, max 1,  common pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=13     # 13%*10 = 1.3, max 1,  dedicated pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:maxQuota=87     # 87%*10 = 8.7, max 8,  common pool.
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:minQuota=30     # 30%*10 = 3.0, max 3,  dedicated pool.
    ...    ==================================================================================================================
    ...    Step1: SA UE81 with SNSSAI-1 attach at CELL-1 , then start traffic;
    ...    Expected Result: Ue attach successfully in RG-2 with dedicate resouce;stable DL throughput for UE(No BLER, DTX, NACK, CRC KO);
    ...    Step2: SA UE82 with SNSSAI-1 attach at CELL-2 , then start traffic;
    ...    Expected Result: Ue attach successfully;stable DL throughput for UE; (now poolremaincommon=11-used-dedicated=11-1-10=0)
    ...    Step11: check the counters.
    [Tags]    QC_69848    F003    E003
    Clear Counter files
    UE SA Attach To Target Cell with traffic    cell_id=1    ue_id=81    nwslice=1    addqosflow=1    dlmbps=10    ulmbps=1
    UE SA Attach To Target Cell with traffic    cell_id=1    ue_id=82    nwslice=1    addqosflow=1    dlmbps=10    ulmbps=1
    Check Counters    pm_counters_expression=${PM_Counters_Check_ET_F03_01}

*** Keywords ***
Modify Cfg
    ${gnb3_cell1}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01
    ...    tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=524310:524310 gscn=6549 mandatory_for_activation=off
   Update Cfg    ${gnb3_cell1}
   Delete Cfg    set_qosflow id=1 5qi=6 default=on
   Update Cfg    set_qosflow id=1 5qi=1 gfbr_ul=2000 gfbr_dl=2000 mfbr_ul=20000 mfbr_dl=20000 qos_flow_type=gbr ue=all
   Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=2000 gfbr_dl=2000 mfbr_ul=20000 mfbr_dl=20000 qos_flow_type=gbr ue=all
   Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=2000 gfbr_dl=2000 mfbr_ul=20000 mfbr_dl=20000 qos_flow_type=gbr ue=all
   Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=2000 gfbr_dl=2000 mfbr_ul=20000 mfbr_dl=20000 qos_flow_type=gbr ue=all
   Update Cfg    set_qosflow id=5 5qi=5 default=on
   Update Cfg    set_qosflow id=6 5qi=6
   Update Cfg    set_qosflow id=7 5qi=7
   Update Cfg    set_qosflow id=8 5qi=8
   Update Cfg    set_amf_region id=1 tac_list=0,200,300 plmn=311:489,311:500
   Update Cfg    set_nwslice id=1 snssai=0x01:13714341 default=on ue=all amf_region_id=1 plmn_list=311:489,311:500
   Update Cfg    set_nwslice id=2 snssai=0x01:13714342 ue=all amf_region_id=1 plmn_list=311:489,311:500
   Update Cfg    set_nwslice id=3 snssai=0x01:13714343 ue=all amf_region_id=1 plmn_list=311:489,311:500

Set GFBR
    [Arguments]    ${qosflow}=4    ${gfbr_dl}=2000    ${gfbr_ul}=2000
    Execute Egate Command    qosflow_modify qos_flow=${qosflow} gfbr_dl=${gfbr_dl} gfbr_ul=${gfbr_ul}

UE Trigger Release To RRC_INACTIVE State
    [Arguments]    ${ue_id}=81
    BuiltIn.Log    UE${ue_id} Trigger Release To RRC_INACTIVE State...    console=${True}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=inactive    pass_regexp=@{INACTIVE_check}        timeout=120s
    Execute Egate Command    ue_disp    pass_regexp=Configured UEs

UE Trigger RRCResume
    [Arguments]    ${ue_id}=81    ${targetCell_id}=1    ${pass_regexp}=${None}    ${fail_regexp}=${None}
    BuiltIn.Log    UE${ue_id} Trigger RRCResume To Type2 Cell${targetCell_id}...    console=${True}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${targetCell_id}
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Send And Verify Throughput    ue_id=${ue_id}


Verify succesful intra-gNB SCell Addition if multiple-cell pooled resource limits check resources are assigned within dedicated pool
    UE SA Attach To Target Cell    ue_id=81    nwslice=2    cell_id=11
    UE SA Attach To Target Cell    ue_id=83    nwslice=2    cell_id=11
    UE SA Attach To Target Cell    ue_id=82    nwslice=1    cell_id=2
    Trigger ScellAdd or ScellChange    ${Result_F003}    ue_id=81    phycell_id=60    srsrp_nr=91    scell_id=1
    Trigger ScellAdd or ScellChange and expect failed    ${Expect_Failed_Result_F003}    ue_id=83    phycell_id=60    srsrp_nr=91    scell_id=1
    Release Ues    ue_id=82
    Trigger ScellAdd or ScellChange    ${Result_F003}    ue_id=83    phycell_id=60    srsrp_nr=91    scell_id=1

Verify Online change of quotas in RGs while PDU sessions are ongoing
    UE SA Attach To Target Cell failed    ue_id=82    nwslice=1    cell_id=2
    Delta Commission Parameters    ${DELTA_PARAS_QUOTA}
    UE SA Attach To Target Cell    ue_id=82    nwslice=1    cell_id=2

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

UE SA Attach To Target Cell with traffic
    [Arguments]    ${cell_id}=1    ${ue_id}=81    ${pcell_dl}=0    ${nwslice}=1    ${addqosflow}=4    ${dlmbps}=50    ${ulmbps}=10
    ${Set_AMF_Send_CNAI_In_UE_ICS}    catenate
    ...    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${Set_AMF_Send_CNAI_In_UE_ICS}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${addqosflow}
    Send Throuput    ue_id=${ue_id}   dlmbps=${dlmbps}    ulmbps=${ulmbps}
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}

Send Throuput
    [Arguments]    ${ue_id}=81    ${dlmbps}=150    ${ulmbps}=20
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=2 dir=dl mbps=${dlmbps} trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=2 dir=ul mbps=${ulmbps} trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=0    ${qfi}=2
    sleep    10s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=81 scell=0-7 type=pdsch
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi}    direction=ul    rate_type=ave
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

UE SA Attach To Target Cell failed
    [Arguments]    ${ue_id}=1    ${gnb}=2    ${cell_id}=2    ${nwslice}=1    ${gw}=1
    BuiltIn.Log    SA UE${ue_id} Attach...    console=${True}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${gnb} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gw}
    ...    pass_regexp=cause RAN radio resources not available
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off



