*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/10cells_ecpri_100M/2_AEQE_4_AWHQN
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R1    tl-CLOUD_5G_I_MP_AP_LOOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
@{PARAMS_IN_SWCONFIG}
...    0x59029B=1
...    0x890092=1

${SYSCOM_FLAG}    True
${NRPPA_TRP_INFO_RESPONSE_FILTER}    nrppa.id == 30


*** Test Cases ***
CB010356-A-B1_ET_01_02_Successful TRP Information Exchange for all TRPs even Cell is Locked
    [Documentation]  cover CB010356-A-B1_ET_01_02 and
    ...    CB010356-A-B1_ET_01_04_Successful TRP Information Exchange for Part Information Supported
    [Tags]    TC01
#    log to console    step: enable 10356 on NRCELL4,5,6
#    delta commission parameters and wait cells onair    ${CB010356_3CELLS_ENABLE}    timeout=300
#
#    log to console    step: lock all positioning cells:NRCELL4,5,6
#    Lock NRCell4
#    Lock NRCell5
#    Lock NRCell6
    log to console    step: lock all positioning cells
    Delta Commission Parameters  NRCELL:administrativeState=Locked

    log to console    step: lmf requests all trps with nr_pci,sfn_init_time
    start to capture wireshark log    tag=1_all_trp
    trigger TRP Information request for All TRPs    trp_info_type=nr_pci,sfn_init_time
    ${trp_info}    create list    tRP-ID=1,2,3,4,5,6,7,8,9,10
    ...                           pCI-NR=50,51,52,53,54,55,56,57,58,59
    ...                           sfn_init_time=not_existing
    download and check wireshark fields    tag=1_all_trp
    ...                                    filter=${NRPPA_TRP_INFO_RESPONSE_FILTER}
    ...                                    check_fields=${trp_info}

#    log to console    step: lmf requests trp4,10(10 feature disabled) with ng-ran_cgi,nr_arfcn,trp_type,sfn_init_time
#    start to capture wireshark log    tag=2_trp4_trp10
#    trigger TRP Information request for Specific TRP    tid=4,10    trp_info_type=ng-ran_cgi,nr_arfcn,trp_type,sfn_init_time
#    ${trp_info}    create list    tRP-ID=4
#    ...                           cGI-NR/pLMN-Identity=134198
#    ...                           cGI-NR/nRcellIdentifier=[RE]0000040040 .*
#    ...                           aRFCN=660000
#    ...                           TRPType=[RE]trp .*
#    ...                           sfn_init_time=not_existing
#    download and check wireshark fields    tag=2_trp4_trp10
#    ...                                    filter=${NRPPA_TRP_INFO_RESPONSE_FILTER}
#    ...                                    check_fields=${trp_info}

    log to console    step: lmf requests trp5,14(14 not existing) with geo-coordinates,ssb_config,sfn_init_time
    start to capture wireshark log    tag=3_trp5_trp14
    trigger TRP Information request for Specific TRP    tid=5,14    trp_info_type=geo-coordinates,ssb_config,sfn_init_time
    ${trp_info}    create list    tRP-ID=5
    ...                           sfn_init_time=not_existing
    # geo-coordinates
    ...                           tRPPosition/latitudeSign=[RE]north .*
    ...                           tRPPosition/latitude=0
    ...                           tRPPosition/longitude=0
    ...                           tRPPosition/directionOfAltitude=[RE]height .*
    ...                           tRPPosition/altitude=0
    ...                           tRPPosition/uncertaintySemi-major=0
    ...                           tRPPosition/uncertaintySemi-minor=0
    ...                           tRPPosition/orientationOfMajorAxis=0
    ...                           tRPPosition/uncertaintyAltitude=0
    ...                           tRPPosition/confidence=100
    # ssb_config
    ...                           sSB-Configuration/sSB-frequency=653856
    ...                           sSB-Configuration/sSB-subcarrier-spacing=[RE]kHz30 .*
    ...                           sSB-Configuration/sSB-Transmit-power=-9    # equal to NRCELL-5.ssPbchBlockPower
    ...                           sSB-Configuration/sSB-periodicity=[RE]ms20 .*
    ...                           sSB-Configuration/sSB-half-frame-offset=0
    ...                           sSB-Configuration/sSB-SFN-offset=0
    ...                           sSB-Configuration/sSB-BurstPosition=[RE]mediumBitmap .*
    ...                           sSB-Configuration/sFN-initialisation-time=not_existing
    ...                           sSBinformation/pCI-NR=54
    download and check wireshark fields    tag=3_trp5_trp14
    ...                       filter=${NRPPA_TRP_INFO_RESPONSE_FILTER}
    ...                       check_fields=${trp_info}

    log to console    step: request only sfn_init_time, TRPInformationFailure respond
    start to capture wireshark log    tag=4_only_sfn_init_time
    trigger TRP Information request for All TRPs    trp_info_type=sfn_init_time        pass_regexp=LMF Received TRPInformationFailure
    download and check wireshark fields    tag=4_only_sfn_init_time
    ...                       filter=nrppa.radioNetwork == 2
    ...                       check_fields=radioNetwork=[RE]requested-item-temporarily-not-available .*

    log to console    step: unlock NRCELL6 and request only sfn_init_time
    Unlock NRCell6
    start to capture wireshark log    tag=5_only_sfn_init_time
    trigger TRP Information request for All TRPs    trp_info_type=sfn_init_time
    ${trp_info}    create list    tRP-ID=6
    ...                           sFNInitialisationTime=[RE]967fbbffffff258c .*
    download and check wireshark fields    tag=5_only_sfn_init_time
    ...                       filter=${NRPPA_TRP_INFO_RESPONSE_FILTER}
    ...                       check_fields=${trp_info}

    log to console    step: request supported TRP info and unsupported prs config, spatial direction info
    start to capture wireshark log    tag=6_including_unsupported
    ${supported_trp_info}    set variable    nr_pci,ng-ran_cgi,nr_arfcn,ssb_config,sfn_init_time,geo-coordinates,trp_type
    ${unsupported_trp_info}    set variable    prs_config,spatial_direction_info
#    trigger TRP Information request for All TRPs    trp_info_type=${supported_trp_info},${unsupported_trp_info}
    trigger TRP Information request for Specific TRP    tid=4,5,6    trp_info_type=${supported_trp_info},${unsupported_trp_info}
    ${trp_info}    create list    tRP-ID=4,5,6
    ...                           TRPInformationTypeResponseItem: pCI-NR/pCI-NR=53,54,55
    ...                           cGI-NR/nRcellIdentifier=[RE]0000040040 .*,[RE]0000040050 .*,[RE]0000040060 .*
    ...                           aRFCN=660000,653780,660000
    ...                           sSB-frequency=657312,653856,657312
    ...                           sSBinformation/pCI-NR=53,54,55
    ...                           sSB-Configuration/sFN-initialisation-time=[RE]967fbc0000000000 .*    # only trp6 has this field
    ...                           geographicalCoordinates/tRPPosition/latitude=0,0,0
    ...                           TRPType=[RE]trp .*,[RE]trp .*,[RE]trp .*
    ...                           sFNInitialisationTime=[RE]967fbbffffff258c .*    # only trp6 has this field
    download and check wireshark fields    tag=6_including_unsupported
    ...                       filter=${NRPPA_TRP_INFO_RESPONSE_FILTER}
    ...                       check_fields=${trp_info}
    [Teardown]    Unlock NRcells And Collect Logs

CB010356-A-B2_ET_01_02_No supporting of TRP Information Exchange
    [Documentation]    Cover CB010356-A-B2_ET_01_03_Madentarty IE missing in TRP Information Request
    ...    CB010356-A-B2_ET_01_04_Only Unsupported TRP Information Type Is Requested
    ...    CB010356-A-B2_ET_01_05_No information can be provided to LMF in gNB-DU

    log to console    step: request unsupported prs config, spatial direction info
    start to capture wireshark log    tag=1_only_prs_config_and_spatial_direction_info
    trigger TRP Information request for All TRPs    trp_info_type=prs_config,spatial_direction_info
    ...                                             pass_regexp=LMF Received TRPInformationFailure
    download and check wireshark fields    tag=1_only_prs_config_and_spatial_direction_info
    ...                                    filter=nrppa.radioNetwork == 1
    ...                                    check_fields=radioNetwork=[RE]requested-item-not-supported .*

    log to console    step: request unsupported prs config
    start to capture wireshark log    tag=2_only_prs_config
    trigger TRP Information request for All TRPs    trp_info_type=prs_config    pass_regexp=LMF Received TRPInformationFailure
    download and check wireshark fields    tag=2_only_prs_config
    ...                                    filter=nrppa.radioNetwork == 1
    ...                                    check_fields=radioNetwork=[RE]requested-item-not-supported .*

    log to console    step: request unsupported spatial direction info
    start to capture wireshark log    tag=3_only_spatial_direction_info
    trigger TRP Information request for Specific TRP    tid=2    trp_info_type=spatial_direction_info
    ...    pass_regexp=LMF Received TRPInformationFailure
    download and check wireshark fields    tag=3_only_spatial_direction_info
    ...                                    filter=nrppa.radioNetwork == 1
    ...                                    check_fields=radioNetwork=[RE]requested-item-not-supported .*

    log to console    step: request TRP info with missing TRP info Typelist
    start to capture wireshark log    tag=4_missing_TRP_info_typelist
    trigger TRP Information request for All TRPs With Missing TRP Info Typelist    trp_info_type=nr_pci,nr_arfcn
    ...    pass_regexp=LMF Received TRPInformationFailure
    download and check wireshark fields    tag=4_missing_TRP_info_typelist
    ...                                    filter=nrppa.protocol == 1
    ...                                    check_fields=protocol=[RE]abstract-syntax-error-reject .*

    log to console    step: lock positioning cell-1
    Delta Commission Parameters  NRCELL-1:administrativeState=Locked
    log to console    step: request unsupported sfn_init_time
    start to capture wireshark log    tag=5_only_sfn_init_time
    trigger TRP Information request for Specific TRP    tid=1    trp_info_type=sfn_init_time
    ...    pass_regexp=LMF Received TRPInformationFailure
    download and check wireshark fields    tag=5_only_sfn_init_time
    ...                                    filter=nrppa.radioNetwork == 2
    ...                                    check_fields=radioNetwork=[RE]requested-item-temporarily-not-available .*
    [Teardown]    Unlock NRcell_1 And Collect Logs


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

trigger TRP Information request for All TRPs With Missing TRP Info Typelist
    [Arguments]    ${trp_info_type}    ${lmf_id}=1    ${transaction_id}=1    ${pass_regexp}=LMF Received TRPInformationResponse
    ${cmd}    Catenate    lmf_send_trp_info_req id=${lmf_id} amf_id=1 gnb_id=2 nrppa_transaction_id=${transaction_id}
    ...    trp_info_type=${trp_info_type} action=missing_mandatory_ie missing_mandatory_ie_name=trp_info_type_list
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

Unlock NRcells And Collect Logs
#    Unlock NRCell4
#    Unlock NRCell5
#    Unlock NRCell6
    Delta Commission Parameters  NRCELL:administrativeState=Unlocked
    common test teardown and stop capture logs

Unlock NRcell_1 And Collect Logs
    Unlock NRCell1
    common test teardown and stop capture logs

