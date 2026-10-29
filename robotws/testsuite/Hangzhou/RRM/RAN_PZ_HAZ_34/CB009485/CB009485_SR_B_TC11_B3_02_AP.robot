*** Settings ***
Documentation
...    author: Zhu Yuhua
...    contact: yuhua.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LO
...            owner-yuhua.zhu   team-PZ3_7    release-SBTS26R1
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${ue_nr_capabilities}    SEPARATOR=
...    E1A03FA0474E7AEFFFFFAFC2200782E0203C127BE7FFFFF800F00C6FBE00050370101F8E0155DF0A3FE2F08762F82087F540A083D951D2206
...    24FAC41E420F081425BE7E57771DF001DDC77C000CC005000742AEF851FF17843B17C1043FAA05041ECA8E9103127D620F2107840A12DF3F3
...    3BB8EF800EEE3BE000660028003A1577C4DFF8BC21D8BE0821FD502820F65474881893EB1079083C205096F9F95DFC7FC0077F1FF00033001
...    4001D00650389A000000C40A83C4D000C2680004C40AC1C4D080004620540E268400033102B070A0200021881507850001828000298810090
...    0A2026C04605000C2508206811B649F0214285B24F810236C93E04085B24F810276C93E042853B649F000160C318C631BFFFE000138036002
...    800301C1401C0C4270070007000603E0488200000041000002208004000004100080000882001004001040020080220800402008410008040
...    188200100C021040020180601B072F2A2B072F2A28060800004B2CA82000032CB2A0800014B2CA02000072CB2801A83D5D2AAAA0F174AA283
...    839804F9BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C0
...    700001400600400C010020808020040200801001C0180180400300A00A01801001C0180380400700A01201802001C0380180800301200A028
...    01041C0080180100300400A0080103801001004002004004010001AB0602072125262728770000000361781C06000601A
${ue_eutra_nr_capabilities}    SEPARATOR=
...    C10060B71B03004040CA00389A0000000FD00000000081B8981002060E2680000103F400000000206E360400818103071340000101FA00000
...    00010370B0200E8080000303F400000000206E26040081838040000100FD0000000008100800803004809B000804180004020001008000402
...    020080108000201000080404008011800040200010080004020200400840002010100200440001008000402020040080
${ue_eutra_capabilities}    SEPARATOR=
...    DD9FF43081A808081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C108208030
...    4218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B0820082841051820838410041420820610
...    40105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...    E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71E000
...    20406080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E780C000048080C2609A143C037FC00000A00000061000880
...    004
${ue_radio_capability}    SEPARATOR=
...    041a790822de1a03fa0474e7aefffffafc2200782e0203c127be7fffff800f00c6fbe00050370101f8e0155df0a3fe2f08762f82087f540a0
...    83d951d220624fac41e420f081425be7e57771df001ddc77c000cc005000742aef851ff17843b17c1043faa05041eca8e9103127d620f2107
...    840a12df3f33bb8ef800eee3be000660028003a1577c4dff8bc21d8be0821fd502820f65474881893eb1079083c205096f9f95dfc7fc0077f
...    1ff000330014001d00650389a000000c40a83c4d000c2680004c40ac1c4d080004620540e268400033102b070a02000218815078500018280
...    002988100900a2026c04605000c2508206811b649f0214285b24f810236c93e04085b24f810276c93e042853b649f000160c318c631bfffe0
...    00138036002800301c1401c0c4270070007000603e04882000000410000022080040000041000800008820010040010400200802208004020
...    08410008040188200100c021040020180601b072f2a2b072f2a28060800004b2ca82000032cb2a0800014b2ca02000072cb2801a83d5d2aaa
...    a0f174aa283839804f9bf01c070079bf01c070079bf01c070079bf01c070079bf01c070079bf01c070079bf01c070079bf01c070079bf01c0
...    70079bf01c0700001400600400c010020808020040200801001c0180180400300a00a01801001c0180380400700a01201802001c038018080
...    0301200a02801041c0080180100300400a0080103801001004002004004010001ab0602072125262728770000000361781c06000601a50239
...    bb3fe861035010102e0b82efc1bf335942004408020a540000a0ccbe7f83762697864045efc1bb135646084308210c2084304218210410060
...    84300300304018200c10860060044208005a3eaa30a040708200828c1042c208020a3041460821610401050820a3041070820082841040c20
...    8020b205c1705c1705c1705c1705c1705c1705c1705c1705c1705c1705c1705c1705c1705c1705c1705c1705c1705c1705c1705c1705c1705
...    c1705c1705c1705c1705df8a0000336421e1e1e2e11fc5c878787878787878787878710f0f0f0e00008bf060000102020880cd0007ce3c000
...    4080c10181c2c4c6c707507eff896b4c03217f9bd4000c01b648000100000825cf01800009010184c134287806ff8000014000000c2001100
...    00800
@{CB008698_A_B1_04_with_CB008232}
...    @{CB008232}
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=true
...    NRBTS:maxNumOfPreemptions=20
...    NRCELL-1:allowEmergencyReservForTempUse=false
...    NRCELL-1:numOfRadioResReservForTempUse=1
...    NRCELL-1:preferNsaPreemption=true
...    NRCELL-1:maxNumOfRrcSA=3
...    NRCELL-1:maxNumOfUsersPerCell=10
#...    NRCELL-1:maxNumOfUsersNRCell=10
...    NRCELL-1:maxNumOfUsersPerNRCell=10
...    NRCELL-1:maxNumOfCaUsersNRCell=2
...    NRCELL-1:maxNumOfSCellAlloc=2
...    NRBTS/NRCELLGRP-0:maxNumOfRrcCGRPSA=10
...    NRCELL-2:allowEmergencyReservForTempUse=false
...    NRCELL-2:numOfRadioResReservForTempUse=30
...    NRCELL-2:preferNsaPreemption=false
...    NRCELL-2:maxNumOfRrcSA=2
#...    NRCELL-2:maxNumOfUsersNRCell=2
...    NRCELL-2:maxNumOfUsersPerNRCell=2
...    NRCELL-2:maxNumOfCaUsersNRCell=2
...    NRCELL-2:maxNumOfSCellAlloc=2
...    NRCELL-2:maxNumOfUsersPerCell=2
...    NRBTS/NRCELLGRP-1:maxNumOfRrcCGRPSA=10
...    NRBTS/NRDU-1:numOfDrbsReservForTempUse=120
...    NRBTS/NRDU-1:maxNumOfRrcConUEsPerDU=30
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:timerRejectWait=10

@{CB008232}
...    NRCELL-1:actPriorityAccess=true
...    NRBTS:applyPriorityAccess=HPA
...    NRBTS/NRPRIOACC_PROFILE-1:nrPlmnIdx=1
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMax=6
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMin=4
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMax=3
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMin=1
...    NRCELL-1:numOfRadioResReservForPa=1
...    NRBTS/NRDU-1:numOfDrbsReservForPa=0
...    NRCELL-1:tPageCorrInt=3000
...    NRCELL-1:raPrioritizationForAI=MPS
...    NRCELL-1:powerRampingStepHighPriorityCbra=dB4
...    NRCELL-1:powerRampingStep=dB2
...    NRCELL-1:pagingPrioLevelPaMax=1
...    NRCELL-1:pagingPrioLevelPaMin=1

@{Counters_Check_ET_A_4}
...    NRCELL-1:${SA_UE_CTX_REL_PREEM}=1
...    NRCELL-1:${NG_FLOW_REL_GNB_PREEM}=3
...    NRCELL-1/PLMN-PLMN/NRPMQAP-1:${NG_FLOW_REL_GNB_PREEM_PMQAP}=3
${SA_UE_CTX_REL_PREEM}    M55125C11501
${NG_FLOW_REL_GNB_PREEM_PMQAP}    M55163C01001
${NG_FLOW_REL_GNB_PREEM}    M55125C11504

${DEBUG_LOG_LEVEL}    0

#${CUUEReleaseRecord_F}    nsetapx.CuVendorExtensionRecordDataType == 0
${CUUEReleaseRecord_F}    nsetapx.reason == 3

*** Test Cases ***

CB009485_SR_B_TC11_B3_02_Verify gNB-CU UE Release Trace Record is reported for successful CU-CP Resource preemption for SA higher priority request
    Pre-Set    ${CB008698_A_B1_04_with_CB008232}
	start to capture wireshark log    preemption
    Register 3 UEs and ICS with qosflows
    UE Register To GNB    ue_id=4
    Only HPA UE Can Register To GNB    ue_id=5
    UE1 Preempted By UE4
    Check Counters    ${Counters_Check_ET_A_4}
    #Check RRC Log    ${CURDIR}${/}a2a_CB008698-A-B1-04${/}a2a.ini
	${CUUEReleaseRecord}    create list    ueReleaseRecord/data-r1/trigger=gNB
	...                                       ueReleaseRecord/data-r1/reason=preemption
	...                                       ueReleaseRecord/data-r1/ueCtxReleaseReqSendTime=[RE].*
	...                                       ueReleaseRecord/data-r1/ueCtxReleaseCmdRcvTime=[RE].*
	...                                       ueReleaseRecord/data-r1/ueCtxReleaseCmplSendTime=[RE].*
	...                                       ueReleaseRecord/data-r1/rrcReleaseSendTime=[RE].*
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    preemption    ${CUUEReleaseRecord_F}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${CUUEReleaseRecord_F}
    ...                       check_fields=${CUUEReleaseRecord}
	...                       packet_num=all
    Release Ues    ue_type=all


*** Keywords ***
Perform Steps After Onair
    Start TCE    ${TCE_PORT}

Modify Cfg
    Update Cfg    trace_sim protocol=xn uec=1 amf=1 enb=3 on
    Update Cfg    uec_param id=1 srb_reordering_enabled=on
    Update Cfg    set_qosflow id=1 5qi=1 priority=1 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=2 5qi=2 priority=2 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=3 5qi=3 priority=3 pci=shall_not_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg    set_qosflow id=4 5qi=4 priority=4 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=5 5qi=5 priority=5 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=6 5qi=6 priority=6 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=7 5qi=7 default=on priority=7 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=8 5qi=8 priority=8 pci=may_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg    set_qosflow id=9 5qi=9 priority=9 pci=shall_not_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1
    Update Cfg    set_nwslice id=2 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A6 default=off ue=all amf=1
    Update Cfg    ue_nr_capabilities id=1-5 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg    ue_param id=1-5 nr_usage_setting=voice_centric ue_nr_capabilities=${ue_nr_capabilities}
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.4.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.5.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=7 ue_nat_ip=72.23.6.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=8 ue_nat_ip=72.23.7.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=9 ue_nat_ip=72.23.8.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    ${V_2}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5,0x1:0xd143a6 amf=1
    Update Cfg    ${V_2}
    Update Cfg    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666 gscn=7880
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false sib1_period=3000
    ${V_3}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 daemon=10.0.2.1:22222 gnb_id=0x19:28 nssai=0x01:0xD143A5
    ...    x2_peers=none xn=10.0.1.126 amf=1
    Update Cfg    ${V_3}
    ${V_4}    catenate
    ...    set_cell id=1 gnb=4 pci=4:0 earfcn=39750:39750 tac=200 proxy=10.0.2.93:9999 nrci=0x1 tdd_cell=on bw=20MHz
    ...    technology=lte mandatory_for_activation=off
    Update Cfg    ${V_4}
    Update Cfg    gnb_param id=4 xn_listening_socket=1 send_xn_setup=false
    Update Cfg    ue_param id=1-5 ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_capabilities=${ue_eutra_capabilities}
    ${V_5}    catenate
    ...    ue_param id=31-35 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} ue_eutra_capabilities=${ue_eutra_capabilities}
    Update Cfg     ${V_5}

Pre-Set
    [Arguments]    ${delta_params}
    OnlineParamChange    ${delta_params}
    Set UE Parameters Before Register
    Clean up AMF param to startup
    Clear Counter files

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

set UE history info
    [Arguments]    ${ue_id}=1    ${history_id}=1
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=${history_id} action=commit
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=${history_id}

Set UE Parameters Before Register
    set UE history info    ue_id=1    history_id=1
    set UE history info    ue_id=2    history_id=1
    set UE history info    ue_id=3    history_id=1
    set UE history info    ue_id=4    history_id=1
    set UE history info    ue_id=5    history_id=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    pass_regexp=GNB-3: XnAP Link with GNB-2
    Execute Egate Command    set_pdu_param ue=1,2 pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=1,2 pdu=2 trf_type=internal
    Execute Egate Command    ue_change_location id=1-5 enb=2 cell=1

Clean up AMF param to startup
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_ue_pdu_setup_param id=1 reset
    Execute Egate Command    amf_ue_ics_param id=1 reset
    Execute Egate Command    amf_ue_ics_param id=1 include_ue_capabilities=off


UE PDU Session setup
    [Arguments]    ${pdu}=1    ${ue_id}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=1    ${output_1}=1    ${output_2}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}
    ...    pass_regexp=${pass_regexp}
    Should Contain    ${ret1}    ${output_1}
    Should Contain    ${ret1}    ${output_2}

Additional qosflows to activate
    [Arguments]    ${id}=1    ${addition_qosflow}=1
    Execute Egate Command      smf_param id=${id} reset
    Execute Egate Command      smf_param id=${id} additional_qosflows_to_activate=${addition_qosflow}

Register 3 UEs and ICS with qosflows
    UE Register To GNB      ue_id=1
    UE Register To GNB      ue_id=2
    UE Register To GNB      ue_id=3
    Additional qosflows to activate    id=1    addition_qosflow=6,9
    UE PDU Session setup    pdu=1    ue_id=1    nwslice=1    gw=1    pass_regexp=QoS Routing Table    output_1=Setup QosFlow with QFI:3
    UE PDU Session setup    pdu=2    ue_id=2    nwslice=1    gw=2    pass_regexp=QoS Routing Table    output_1=Setup QosFlow with QFI:3
    Additional qosflows to activate    id=1    addition_qosflow=8,9
    UE PDU Session setup    pdu=3    ue_id=3    nwslice=1    gw=3    pass_regexp=QoS Routing Table    output_1=Setup QosFlow with QFI:3

UE1 Preempted By UE4
    Additional qosflows to activate    id=1    addition_qosflow=5,6
    UE PDU Session setup    pdu=4    ue_id=4    nwslice=1    gw=4    pass_regexp=QoS Routing Table    output_1=Setup QosFlow with QFI:3
    #...    output_2=value Cause : radioNetwork : release-due-to-pre-emption

UE Register To GNB
    [Arguments]    ${ue_id}=1    ${estab_cause}=mo-Signalling    ${pass_regexp}=UE now in NG RM Regist
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${estab_cause}
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
    ...    pass_regexp=${pass_regexp}

Only HPA UE Can Register To GNB
    [Arguments]    ${ue_id}=5
    UE Register To GNB    ue_id=${ue_id}    estab_cause=emergency    pass_regexp=detached
    UE Register To GNB    ue_id=${ue_id}    estab_cause=mps-PriorityAccess    pass_regexp=detached
    UE Register To GNB    ue_id=${ue_id}    estab_cause=mcs-PriorityAccess    pass_regexp=detached
    UE Register To GNB    ue_id=${ue_id}    estab_cause=highPriorityAccess    pass_regexp=UE now in NG RM Regist
