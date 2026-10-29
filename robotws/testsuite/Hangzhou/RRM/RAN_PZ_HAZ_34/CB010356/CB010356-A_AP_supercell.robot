*** Settings ***
Documentation
...    author: Geng lishuo
...    contact: lishuo.geng@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/supercell_ecpri
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R1    tl-CLOUD_5G_I_MP_AP_LOOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${SYSCOM_FLAG}    True
${NRPPA_TRP_INFO_RESPONSE_FILTER}    nrppa.id == 30

${nRcellIdentifier_all_supercell}    SEPARATOR=
...    [RE]0000040010 .*,[RE]0000040010 .*,[RE]0000040020 .*,[RE]0000040020 .*,[RE]0000040030
...    .*,[RE]0000040030 .*

*** Test Cases ***
CB010356-A-B3_ET_01_02_Successful TRP Information Exchange for Specific TRPs with Super Cell
    [Documentation]  cover CB010356-A-B3_ET_01_02

    [Tags]    TC03    owner-lishuo.geng
    log to console    step: config ngRanAccessPointPostion for every subcell
    delta commission parameters and wait cells onair    ${CB010356_ngRanAccessPointPosition}    timeout=300
    log to console    step: lmf requests all trps with nr_pci,sfn_init_time
    start to capture wireshark log    tag=1_all_trp
    trigger TRP Information request for All TRPs    trp_info_type=nr_pci,ng-ran_cgi,nr_arfcn,trp_type
    ${trp_info}    create list    tRP-ID=1,2,3,4,5,6
    ...                           pCI-NR=50,50,51,51,52,52
    ...                           aRFCN=650000,650000,650000,650000,650000,650000
    ...                           cGI-NR/pLMN-Identity=134198,134198,134198,134198,134198,134198
    ...                           cGI-NR/nRcellIdentifier=${nRcellIdentifier_all_supercell}
    download and check wireshark fields    tag=1_all_trp
    ...                                    filter=${NRPPA_TRP_INFO_RESPONSE_FILTER}
    ...                                    check_fields=${trp_info}

    log to console    step: lmf requests trp23,1(23 not existing) with geo-coordinates,ssb_config,sfn_init_time
    start to capture wireshark log    tag=3_trp23_trp1
    trigger TRP Information request for Specific TRP    tid=23,1    trp_info_type=geo-coordinates,ssb_config,sfn_init_time
    ${trp_info}    create list    tRP-ID=1
    ...                           sFNInitialisationTime=[RE]967fbbffffff258c .*
    # ssb_config
    ...                           sSB-Configuration/sSB-frequency=650016
    ...                           sSB-Configuration/sSB-subcarrier-spacing=[RE]kHz30 .*
    ...                           sSB-Configuration/sSB-Transmit-power=0
    ...                           sSB-Configuration/sSB-periodicity=[RE]ms20 .*
    ...                           sSB-Configuration/sSB-half-frame-offset=0
    ...                           sSB-Configuration/sSB-SFN-offset=0
    ...                           sSB-Configuration/sSB-BurstPosition=[RE]mediumBitmap .*
    ...                           sSB-Configuration/sFN-initialisation-time=[RE]967fbc0000000000 .*
    ...                           sSBinformation/pCI-NR=50
    download and check wireshark fields    tag=3_trp23_trp1
    ...                       filter=${NRPPA_TRP_INFO_RESPONSE_FILTER}
    ...                       check_fields=${trp_info}

    log to console    step:lock NRCELL2
    lock NRCell2
    log to console    step: request trp info for lock cell, TRPInformationFailure respond
    start to capture wireshark log    tag=5_lock_cell
    trigger TRP Information request for Specific TRP    tid=4    trp_info_type=ng-ran_cgi,nr_arfcn,trp_type,sfn_init_time
    ...    pass_regexp=LMF Received TRPInformationFailure
    download and check wireshark fields    tag=5_lock_cell
    ...                       filter=nrppa.radioNetwork == 2
    ...                       check_fields=radioNetwork=[RE]requested-item-temporarily-not-available .*

    log to console    step: request ng-ran_cgi,nr_arfcn,trp_type for unknown trp id 11, TRPInformationFailure respond
    start to capture wireshark log    tag=6_for_unknown_trp
    trigger TRP Information request for Specific TRP    tid=11    trp_info_type=ng-ran_cgi,nr_arfcn,trp_type
    ...    pass_regexp=LMF Received TRPInformationFailure
    download and check wireshark fields    tag=6_for_unknown_trp
    ...                       filter=nrppa.radioNetwork == 2
    ...                       check_fields=radioNetwork=[RE]requested-item-temporarily-not-available .*

    [Teardown]    Unlock NRcells And Collect Logs

*** Keywords ***
Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh
    Update Cfg    set_lmf id=2 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef12345678gh

    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=4
    Update Cfg    set_qosflow id=5 5qi=6
    Update Cfg    set_qosflow id=6 5qi=7
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1

trigger TRP Information request for All TRPs
    #lmf_send_trp_info_req id=1 amf_id=1 gnb_id=2 nrppa_transaction_id=0 trp_info_type=nr_pci
    [Arguments]    ${trp_info_type}    ${lmf_id}=1    ${transaction_id}=1    ${pass_regexp}=LMF Received TRPInformationResponse
    ${cmd}    Catenate    lmf_send_trp_info_req id=${lmf_id} amf_id=1 gnb_id=2 nrppa_transaction_id=${transaction_id}
    ...    trp_info_type=${trp_info_type}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

trigger TRP Information request for Specific TRP
    #lmf_send_trp_info_req id=1 amf_id=1 gnb_id=2 nrppa_transaction_id=0 trp_info_type=nr_pci trp_id=$_trp_id}
    [Arguments]    ${trp_info_type}    ${tid}=1    ${lmf_id}=1   ${transaction_id}=1     ${pass_regexp}=LMF Received TRPInformationResponse
    ${cmd}    Catenate    lmf_send_trp_info_req id=${lmf_id} amf_id=1 gnb_id=2 nrppa_transaction_id=${transaction_id} trp_id=${tid}
    ...    trp_info_type=${trp_info_type}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}

Unlock NRcells And Collect Logs
    Unlock NRCell2
    common test teardown and stop capture logs


