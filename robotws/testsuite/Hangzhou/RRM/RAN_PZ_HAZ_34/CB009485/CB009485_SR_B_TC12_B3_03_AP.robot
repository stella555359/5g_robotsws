*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env And Start TCE
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS26R1    tl-CLOUD_5G_I_LO_AP_LO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${UE_Capabilities}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E1DE38720C3
...    8002064F1F570004F001C0013C002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36
...    26EB04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898087AD8202020E
...    1DE38720C38002064F1F55000005000000108389A00000000404D0301C020227B058060005038080E0600B00E000D07C0000000000
...    001CA9A0002000012CB2A00695550103800580000002004008D58980008101820283038405880889098C909293139425389B40

${ueReleaseRecord_F}    nsetapx.CuVendorExtensionRecordDataType == 0
${rrcrelease_redirect_lte_F}    (nr-rrc.c1 == 2 ) && (nr-rrc.redirectedCarrierInfo == 1) && (!nsetapx)


*** Test Cases ***
CB009485_SR_B_TC12_B3_03 Verify gNB-CU UE Release Trace Record is reported for successful Emergency Fallback via redirection
    [Documentation]
    ...   This case covers the following sub cases
    ...   CB009485_SR_B_TC10_B3_01 Verify gNB-CU UE Release Trace Record is reported for successful Redirection based on A2 measurements
    ...   CB009485_SR_B_TC12_B3_03 Verify gNB-CU UE Release Trace Record is reported for successful Emergency Fallback
    ...   via redirection on reception of B1 measurement
    # CB009485_SR_B_TC10_B3_01
    log to console    ===== case1: redirect to NR based on A2 ====
    start to capture wireshark log    case1
    log to console    step: ue1 with plmn1 attach to cell1, report A2 to redirect to NR
    SA Attach UE     ue_id=1    cell_id=1
    report A2 and redirect to NR    ue_id=1
    ${ueReleaseRecord}    create list
    ...        ueReleaseRecord/data-r1/trigger=gNB
    ...        ueReleaseRecord/data-r1/reason=redirection
    ...        ueReleaseRecord/data-r1/ueCtxReleaseReqSendTime=existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmdRcvTime=existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmplSendTime=existing
    ...        ueReleaseRecord/data-r1/rrcReleaseSendTime=existing
    ...        ueReleaseRecord/data-r1/redirectionType=redirNR
    download and check wireshark fields    tag=case1
    ...                                    filter=${ueReleaseRecord_F}
    ...                                    check_fields=${ueReleaseRecord}

    log to console    ===== case2: redirect to LTE based on A2 ====
    start to capture wireshark log    case2
    log to console    step: ue2 with plmn1 attach to cell2, report A2 to redirect to LTE
    SA Attach UE     ue_id=2    cell_id=2
    report A2 and redirect to LTE    ue_id=2
    ${ueReleaseRecord}    create list
    ...        ueReleaseRecord/data-r1/trigger=gNB
    ...        ueReleaseRecord/data-r1/reason=redirection
    ...        ueReleaseRecord/data-r1/ueCtxReleaseReqSendTime=existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmdRcvTime=existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmplSendTime=existing
    ...        ueReleaseRecord/data-r1/rrcReleaseSendTime=existing
    ...        ueReleaseRecord/data-r1/redirectionType=redirLTE
    download and check wireshark fields    tag=case2
    ...                                    filter=${ueReleaseRecord_F}
    ...                                    check_fields=${ueReleaseRecord}

    # CB009485_SR_B_TC12
    log to console    ===== case3: voice fallback based on B1 ====
    start to capture wireshark log    case3
    log to console    step1: UE3 with plmn1 attach to cell1 with 5qi5
    execute egate command    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on voice_fallback=on
    SA Attach UE     ue_id=3    cell_id=1

    log to console    step2: add 5qi1 and report B1 to trigger voice fallback
    execute egate command    ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=2 by=amf    rrcReconfigurationComplete
    report B1 and voice fallback to LTE    ue_id=3
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    tag=case3    filter=${ueReleaseRecord_F}
    ${rrcrlease}    create list    redirectedCarrierInfo/eutra/eutraFrequency=38000
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${rrcrelease_redirect_lte_F}
    ...                       check_fields=${rrcrlease}
    ${ueReleaseRecord_c3_c4}    create list
    ...        ueReleaseRecord/data-r1/trigger=gNB
    ...        ueReleaseRecord/data-r1/reason=voiceFallback
    ...        ueReleaseRecord/data-r1/ueCtxReleaseReqSendTime=existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmdRcvTime=existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmplSendTime=existing
    ...        ueReleaseRecord/data-r1/rrcReleaseSendTime=existing
    ...        ueReleaseRecord/data-r1/redirectionType=redirVoiceFallbackLTE
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${ueReleaseRecord_F}
    ...                       check_fields=${ueReleaseRecord_c3_c4}

    log to console    ===== case4: blind voice fallback ====
    start to capture wireshark log    case4
    log to console    step1: UE4 with plmn1 attach to cell1 with 5qi5
    execute egate command    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on voice_fallback=on
    SA Attach UE     ue_id=4    cell_id=1

    log to console    step2: add 5qi1 and don't report B1, UE blind voice fallback
    execute egate command    ue_pdu_session_modify ue=4 pdu=1 qosflows_to_add=2 by=amf    rrcReconfigurationComplete
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    tag=case4    filter=${ueReleaseRecord_F}
    ${rrcrlease}    create list    redirectedCarrierInfo/eutra/eutraFrequency=38100
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${rrcrelease_redirect_lte_F}
    ...                       check_fields=${rrcrlease}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${ueReleaseRecord_F}
    ...                       check_fields=${ueReleaseRecord_c3_c4}

    log to console    ===== case5: emergency fallback based on B1 ====
    start to capture wireshark log    case5
    log to console    step1: UE5 register with ICS
    execute egate command    amf_param id=1 full_nas_auth=on
    execute egate command    amf_param id=1 send_ics_registration=on
    execute egate command    amf_ue_ics_param id=1 ue=all emergency_fb=on target_cn=epc
    execute egate command    ue_register id=5 nwslice=1    pass_regexp=Received REGISTRATION COMPLETE
    execute egate command    amf_ue_ics_param id=1 reset
    execute egate command    amf_param id=1 send_ics_registration=off

    log to console    step2: report B1 to trigger emergency fallback
    report B1 and voice fallback to LTE    ue_id=5
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    tag=case5    filter=${ueReleaseRecord_F}
    ${rrcrlease}    create list    redirectedCarrierInfo/eutra/eutraFrequency=38000
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${rrcrelease_redirect_lte_F}
    ...                       check_fields=${rrcrlease}
    ${ueReleaseRecord_c5_c6}    create list
    ...        ueReleaseRecord/data-r1/trigger=amf
    ...        ueReleaseRecord/data-r1/reason=emergencyFallback
    ...        ueReleaseRecord/data-r1/ueCtxReleaseReqSendTime=existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmdRcvTime=existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmplSendTime=existing
    ...        ueReleaseRecord/data-r1/rrcReleaseSendTime=existing
    ...        ueReleaseRecord/data-r1/redirectionType=redirLTE
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${ueReleaseRecord_F}
    ...                       check_fields=${ueReleaseRecord_c5_c6}

    log to console    ===== case6: blind emergency fallback ====
    start to capture wireshark log    case6
    log to console    step1: UE6 register with ICS
    execute egate command    amf_param id=1 full_nas_auth=on
    execute egate command    amf_param id=1 send_ics_registration=on
    execute egate command    amf_ue_ics_param id=1 ue=all emergency_fb=on target_cn=epc
    execute egate command    ue_register id=6 nwslice=1    pass_regexp=Received REGISTRATION COMPLETE
    execute egate command    amf_ue_ics_param id=1 reset
    execute egate command    amf_param id=1 send_ics_registration=off

    log to console    step2: don't report B1 and UE blind emergency fallback
    execute egate command    set_log flush    UE6: IS IDLE
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    tag=case6    filter=${ueReleaseRecord_F}
    ${rrcrlease}    create list    redirectedCarrierInfo/eutra/eutraFrequency=38100
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${rrcrelease_redirect_lte_F}
    ...                       check_fields=${rrcrlease}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${ueReleaseRecord_F}
    ...                       check_fields=${ueReleaseRecord_c5_c6}

*** Keywords ***
Common Suite Setup And Setup Airphone Env And Start TCE
    Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=20
    Check all NG links is up
    Start TCE    ${TCE_PORT}
    execute egate command    amf_param id=1 full_nas_auth=on send_ics_registration=off
    execute egate command    amf_ue_ics_param id=1 reset

Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,100,200,788 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=0,100,200,788 plmn=311:490
    Update Cfg    set_amf_region id=3 tac_list=0,100,200,788 plmn=311:491
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-6 qos_flows=1,2 qos_rules=1,2
    Update Cfg    ue_nr_capabilities id=1-6 voice_over_nr=on:on:off


Check all NG links is up
    object should exist    SERVEDAMF-1:ngLinkStatus=Active
    object should exist    SERVEDAMF-2:ngLinkStatus=Active
    object should exist    SERVEDAMF-3:ngLinkStatus=Active

SA Attach UE
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful    timeout=20s
    ...    sleep_time=5

report A2 and redirect to NR
    [Arguments]    ${ue_id}    ${carrierfreq}=636576
    ${A2_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${pass_regexp}    create list    UE${ue_id}: IS IDLE
    ...                              redirectedCarrierInfo nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A2_measid} event=A2 srsrp_nr=30 srsrq_nr=30    ${pass_regexp}

report A2 and redirect to LTE
    [Arguments]    ${ue_id}    ${carrierfreq}=636576
    ${A2_measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${pass_regexp}    create list    UE${ue_id}: IS IDLE
    ...                              redirectedCarrierInfo eutra
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A2_measid} event=A2 srsrp_nr=30 srsrq_nr=30    ${pass_regexp}

report B1 and voice fallback to LTE
    [Arguments]    ${ue_id}    ${carrierfreq}=38000
    ${measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=B1
    ...    carrierfreq_rat=EUTRAN
    ${pass_regexp}    create list    UE${ue_id}: IS IDLE
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=B1 srsrp_nr=40 phycell_id=10 nrsrp_nr=50 nrsrq_nr=34
    ...    ${pass_regexp}

download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}    ${times}=1
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}    ${times}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}
    ...                       packet_num=all
