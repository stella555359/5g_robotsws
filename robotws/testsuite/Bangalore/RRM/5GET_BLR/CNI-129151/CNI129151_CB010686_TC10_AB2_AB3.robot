*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS25R1    CONFIGURED

Documentation
...             author:                 neravati.dheeraj_nehru@nokia.com
...             maintainer:             neravati.dheeraj_nehru@nokia.com
...
...             INTRODUCTION:      In this test scenario PDU Session Resource Release and PDU Session Resource Modify
...                                are triggered after PDU Session Resource Notify
...             TEST SET NAME:     CNI129151_IWK3_TC10_CB010686_B2_B3_PDU_Session_Resource_Release_and_PDU_Session_
...                                Resource_Modify_after_PDU_Session_Resource_Notify
...             TESTING SPLIT:     See CNI129151 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CNI129151 CFAM
...             REQUIREMENTS:      5G_RAN_USR_RRM_27827


Resource         ./basic_resource.robot
Resource         ../CB012261/CB012261_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...              AND     Perform SCF Delta Commissioning with Delta_Config_B1_TC10_JIO.json
...              AND     sleep    60
...              AND     gnb.Perform gNB reboot
...              AND     sleep    181
#...              AND     OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
#...              AND     sleep    60
#...              AND     OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3
#...              AND     sleep    60
...              AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces    ${wts_cfg_file}

Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt
...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Kill WTS processes Using WTS_Runner
#...                 AND   Link SCOUT SCF to Configuration ID for Reporting

Test Teardown       Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***

#${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_tc10_JIO.cfg
${wts_cfg_file}    ${WTS_DIR}/basic_setup.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${start_ue_id}        1
${end_ue_id}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${nw_id}    1
${ue_id}    1
${TEST_NAME}        test_case
${radparam}         SEPARATOR=${EMPTY}    0x890073 = 0      # it resolves E1 packects visibility issue in wireshark
${duration}         60

*** Test Cases ***
[1]CNI129151_IWK3_TC10_CB010686_B2_B3_PDU_Session_Resource_Release_and_PDU_Session_Resource_Modify_after_PDU_Session_Resource_Notify

    Log To console  Scenario1
    Start Log      btslog
    ${crnti_list1}=      MultiUE Register should be Successful    1      1      nw_id=1
    2nd PDU addition    1    1
    3rd PDU addition    1    1
    PDU Modfication to add additional qfi    1    1   pdu_id=1    qosflows_to_add=4
    PDU Modfication to add additional qfi    1    1   pdu_id=1    qosflows_to_add=5
    PDU Modfication to add additional qfi    1    1   pdu_id=1    qosflows_to_add=6

    start log    cprt
    Start traffic for UE    1      1    pdu_id=1
    Start traffic for UE    1      1    pdu_id=2
    Start traffic for UE    1      1    pdu_id=3
    Trigger RLC max retransmission error    1    1     prof=1      lcid=4    sn=1
    Sleep      60s
    ${scen1}    Stop log      cprt     test_scenario=scen1

    verify pduSessionNotify message     ${scen1}[cprt]/NODECPRT_GNB.pcap
    verify RLC injected DRB is in toBeRealeased item     ${scen1}[cprt]/NODECPRT_GNB.pcap   lcid=4

    start log    cprt
    Trigger RLC max retransmission error    1    1     prof=2      lcid=5    sn=1
    sleep      60s
    ${scen2}    Stop log      cprt     test_scenario=scen2
    verify pduSessionNotify message     ${scen2}[cprt]/NODECPRT_GNB.pcap
    verify RLC injected DRB is in toBeRealeased item     ${scen2}[cprt]/NODECPRT_GNB.pcap   lcid=5


    Log To console  Scenario3
    ${crnti_list2}=      MultiUE Register should be Successful    2      2      nw_id=1
    2nd PDU addition    2    2    gw_id=2
    3rd PDU addition    2    2    gw_id=2
    Multi PDU addition    2    2    pdu=4    gw_id=2
    Multi PDU addition    2    2    pdu=5    gw_id=2
    Multi PDU addition    2    2    pdu=6    gw_id=2
    PDU Modfication to add additional qfi    2    2   pdu_id=1    qosflows_to_add=4
    PDU Modfication to add additional qfi    2    2   pdu_id=1    qosflows_to_add=5
    PDU Modfication to add additional qfi    2    2   pdu_id=1    qosflows_to_add=6
    start log    cprt
    Start traffic for UE    2      2    pdu_id=1
    Start traffic for UE    2      2    pdu_id=2
    Start traffic for UE    2      2    pdu_id=3
    Start traffic for UE    2      2    pdu_id=4
    Start traffic for UE    2      2    pdu_id=5
    Start traffic for UE    2      2    pdu_id=6
    Trigger RLC max retransmission error    2    2     prof=1      lcid=4    sn=1
    Sleep      60s
    ${scen3}    Stop log      cprt     test_scenario=scen3

    verify pduSessionNotify message     ${scen3}[cprt]/NODECPRT_GNB.pcap
    verify RLC injected DRB is in toBeRealeased item     ${scen3}[cprt]/NODECPRT_GNB.pcap   lcid=4

    start log    cprt
    Inject PDU Error   2     2     2
    ${scen4}    Stop log      cprt     test_scenario=scen4
    verify pduSessionNotify message for gtp error     ${scen4}[cprt]/NODECPRT_GNB.pcap
    Sleep    5s

    start log    cprt
    Trigger RLC max retransmission error    2    2     prof=1      lcid=6    sn=1
    Sleep     60s
    ${scen5}    Stop log      cprt     test_scenario=scen5
    verify pduSessionNotify message     ${scen5}[cprt]/NODECPRT_GNB.pcap
    verify RLC injected DRB is in toBeRealeased item     ${scen5}[cprt]/NODECPRT_GNB.pcap   lcid=6
    Sleep    5s

#    start log    cprt
#    Trigger RLC max retransmission error    2    2     prof=1      lcid=7    sn=1
#    Sleep     60s
#    ${scen6}    Stop log      cprt     test_scenario=scen6
#    verify pduSessionNotify message     ${scen6}[cprt]/NODECPRT_GNB.pcap
#    verify RLC injected DRB is in toBeRealeased item     ${scen6}[cprt]/NODECPRT_GNB.pcap   lcid=7
#    Sleep    5s

#    start log    cprt
#    Trigger RLC max retransmission error    2    2     prof=1      lcid=8    sn=1
#    Sleep     60s
#    ${scen7}    Stop log      cprt     test_scenario=scen7
#    verify pduSessionNotify message     ${scen7}[cprt]/NODECPRT_GNB.pcap
#    verify RLC injected DRB is in toBeRealeased item     ${scen7}[cprt]/NODECPRT_GNB.pcap   lcid=8
#    Sleep    5s

#    start log    cprt
#    Trigger RLC max retransmission error    2    2     prof=1      lcid=9    sn=1
#    Sleep     60s
#    ${scen8}    Stop log      cprt      btslog     test_scenario=scen8
#    verify pduSessionNotify message     ${scen8}[cprt]/NODECPRT_GNB.pcap
#    verify RLC injected DRB is in toBeRealeased item     ${scen8}[cprt]/NODECPRT_GNB.pcap   lcid=9
#    Sleep    2s

    Check MultiUE UE State Display      1    1       ACTIVE
#    Check MultiUE UE State Display      2    2       IDLE

    OperatingSystem.Run    cp ${WTS_DIR}/egate_console.log ${LOG_PATH}


*** Keywords ***
Start traffic for UE
    [Arguments]    ${S_UE_id}     ${E_UE_id}    ${pdu_id}=1
    MultiUE Trigger DL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   dl_rate=175   pdu_id=${pdu_id}
    ...      trf_id=1       qfi_id=1
    MultiUE Trigger UL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   ul_rate=175   pdu_id=${pdu_id}
    ...      trf_id=1       qfi_id=1


PDU Modfication to add additional qfi
     [Arguments]          ${start_ue_id}     ${end_ue_id}      ${pdu_id}=1     ${qosflows_to_add}=1
     FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
     wtsrunner.ue_pdu_session_modify      ue=${ue_idx}       pdu=${pdu_id}    qosflows_to_add=${qosflows_to_add}
     ...             by=amf
     Sleep      2s
     END

2nd PDU addition
    [Arguments]    ${start_ue_id}     ${end_ue_id}    ${gw_id}=1

    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.set_pdu_param    ue=${ue_idx}    pdu=2    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=2    gw=${gw_id}    ue=${ue_idx}    nwslice=1
    Sleep      2s
    END

3rd PDU addition
    [Arguments]    ${start_ue_id}     ${end_ue_id}    ${gw_id}=1

    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.set_pdu_param    ue=${ue_idx}    pdu=3    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=3    gw=${gw_id}    ue=${ue_idx}    nwslice=1
    Sleep      2s
    END

Multi PDU addition
    [Arguments]    ${start_ue_id}     ${end_ue_id}     ${pdu}=1     ${gw_id}=1

    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.set_pdu_param    ue=${ue_idx}    pdu=${pdu}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu}    gw=${gw_id}    ue=${ue_idx}    nwslice=1
    Sleep      2s
    END

verify pduSessionNotify message
    [Arguments]    ${cprt_log}

    ${pdmlFile}          analyzer.pcap_to_pdml    ${cprt_log}      ngap.PDUSessionResourceNotifyReleasedTransfer_element
    ${fail_cause_code}    analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                        packetName=ngap.PDUSessionResourceNotifyReleasedTransfer_element
    ...                                        path=.*radioNetwork$
    ...                                        endPacket=1
    Should BE Equal    ${fail_cause_code}   24

verify pduSessionNotify message for gtp error
    [Arguments]    ${cprt_log}

    ${pdmlFile}          analyzer.pcap_to_pdml    ${cprt_log}      ngap.PDUSessionResourceNotifyReleasedTransfer_element
    ${fail_cause_code}    analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                        packetName=ngap.PDUSessionResourceNotifyReleasedTransfer_element
    ...                                        path=.*transport$
    ...                                        endPacket=1
    Should BE Equal    ${fail_cause_code}   0

verify RLC injected DRB is in toBeRealeased item
    [Arguments]    ${cprt_log}    ${lcid}
    ${filter}   Set variable    f1ap.radioNetwork==1
    ${pdmlFile}          analyzer.pcap_to_pdml    ${cprt_log}         ${filter}
    ${drbid}    analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                        packetName=f1ap.radioNetwork
    ...                                        path=.*dRBID$
    ...                                        endPacket=1
    Should BE Equal    ${drbid}    ${lcid}

    ${fail_cause_code}    analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                        packetName=f1ap.radioNetwork
    ...                                        path=.*radioNetwork$
    ...                                        endPacket=1
    Should BE Equal    ${fail_cause_code}   1

    ${pdmlFile}          analyzer.pcap_to_pdml    ${cprt_log}         ngap
    ${rc}    Run and Return RC   cat ${pdmlFile}|grep -i ngap.UEContextReleaseCommand_element
    log to console    ${rc}
    Should Not Be Equal     ${rc}      ${0}

Inject PDU Error
     [Arguments]   ${start_ue_id}    ${end_ue_id}    ${pdu_profile}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.upf_ue_pdu_inject_error_ind     ue=${ue_idx}     id=1     pdu=${pdu_profile}     abnormal_scenario=none
#    sleep   1s
#    ute_wtssim.Execute Egate Command And Wait For Data    ${pdu_error}
#    ...    pass_regexp=Successfully released PDU Session with ID ${pdu_profile}      timeout=60
    sleep     3s
    END

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Check MultiUE UE State Display
    [Arguments]     ${start_ue_id}    ${end_ue_id}		${state}=${EMPTY}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_disp     id=${ue_idx}
    ${output}   wtsrunner.read_wtsemu_output_until_re        expected=opc_key    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    ${state}    partial_match=${TRUE}
    Log to Console    ${output}
    Should Contain    ${output}   ${state}
    Log to Console    UE: ${ue_idx} moved to ${state} state
    END
