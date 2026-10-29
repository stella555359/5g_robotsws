*** Settings ***
Force Tags       CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_TDD
...              CRT    5G_RAN_FDD    SBTS00    RAN_5G    5G_RAN    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Prerana N S
...              :contact: prerana.n_s@nokia.com
...              :Requirement ID: 5G_RAN_USR_RRM_27891
...              :Description:This user scenario describes the case to online deactivate PDU Session
...              Resource Release when RLC max retransmission error detected at gNB-DU.



Resource         ./basic_resource.robot
#Resource         ../CB012261/CB012261_resource.robot


Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with MOC_GBR_DRB_Creation_Activation.json
...                 AND     sleep    1m
...                 AND     Perform SCF Delta Commissioning with TC7.json
...                 AND     sleep    1m
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_scf_MRBTS-1_2_16_UTE5GCLASSICAL4145_20250710-1318.json
...                 AND     sleep    1m
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_scf_MRBTS-1_2_16_UTE5GCLASSICAL4145_20250710-1135.json
...                 AND     sleep    1m
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    2m
...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file}
...                 AND     Sleep    1m

Suite Teardown      Run Keywords    Log To console  Suitetardown
...                 AND        Kill WTS processes Using WTS_Runner
...                 AND     Stop Log     snapshot    sosreport

Test Teardown    Run Keyword and Ignore Error  Stop Log   btslog      cprt

*** Variables ***
${wts_cfg_file}      ${CURDIR}/config/wts/default.cfg
#${wts_cfg_file}      ${CURDIR}/config/wts/basic_setup.cfg
#${wts_cfg_file1}      ${CURDIR}/config/wts/basic_setup_tc10.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID1}        1
${UE_ID2}        2
${UE_ID3}       3
${PDU2}        2
${PDU3}         3
${nwslice_ID}    1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${trf_ID}    1
${Timeout_SA}    40
${start_ue_id}      ${1}
${end_ue_id}      ${3}
${pdu_addition_pattern}        Pdu Session Resource Setup Response Message
${NG_FLOW_REL_ABNORMAL_INSESSION}       M55125C09026
${NG_FLOW_GNB_REL_RADIO_PROCD_FL}       M55125C09029
${NG_FLOW_GNB_REL_RDPRCDFL_PMQAP}       M55163C00016
${NG_FLOW_SETUP_FAIL_UNSPECIFIED}       M55125C09011
${NG_FLOW_REL}                          M55125C08503
${NG_FLOW_REL_ABNORMAL}                 M55125C09028

*** Test Cases ***
[1][1.0] CNI129151_B4_TC7_Online_deactivate_PDU_Session_Resource_Release_due_to_RLC_max_retransmission_error

    [tags]     TC1
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
#    Wait until the next Measurement Period starts  additional_time=${0}

    Repeat
    Stop Log     btslog     cprt    test_scenario=log1
    Repeat
    Stop Log     btslog     cprt    test_scenario=log2
    Repeat
    Stop Log     btslog     cprt    test_scenario=log3
    Repeat
    Stop Log     btslog     cprt    test_scenario=log4
    Repeat
    Stop Log     btslog     cprt    test_scenario=log5

    Link SCOUT SCF to Configuration ID for Reporting



[1]CNI129151_IWK1_TC8_ PDU_Session_Resource_Release_due_to_RLC_max_retransmission_error_one_after_another

    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
#    Wait until the next Measurement Period starts  additional_time=${0}
    Start Log      btslog     cprt

    ${ue_to_bearer_list}       ${lcid_list}       MultiUE Register should be Successful with lcid     1    10   pdu_id=1
    Log to Console    ${lcid_list}

    sleep   30s
#total 3 UEs and 3 PDUs each and each PDU has 2qfi+default qfi

    UE PDU Addition should be Successful    ue_id=${UE_ID1}     pdu_id=2     nw_id=1    gw_id=2
    sleep   5s
    UE PDU Addition should be Successful    ue_id=${UE_ID1}     pdu_id=3     nw_id=1    gw_id=3
    sleep   5s
    UE PDU Addition should be Successful     ue_id=${UE_ID2}    pdu_id=2     nw_id=1    gw_id=2
    sleep   5s
    UE PDU Addition should be Successful     ue_id=${UE_ID2}    pdu_id=3     nw_id=1    gw_id=3
    sleep   5s
    UE PDU Addition should be Successful    ue_id=${UE_ID3}     pdu_id=2     nw_id=1    gw_id=2
    sleep   5s
    UE PDU Addition should be Successful    ue_id=${UE_ID3}     pdu_id=3     nw_id=1    gw_id=3

    sleep   10s

    ${lcid_1}      PDU Modfication to add additional qfi    1    3   pdu_id=1    qosflows_to_add=10
    ${lcid_2}      PDU Modfication to add additional qfi    1    3   pdu_id=2    qosflows_to_add=11
    ${lcid_2}      PDU Modfication to add additional qfi    1    3   pdu_id=3    qosflows_to_add=12


    MultiUE Trigger DL Traffic for SA   1    3   Traffic_rate=mbps   dl_rate=50   pdu_id=1      qfi_id=1
    MultiUE Trigger DL Traffic for SA   1    3   Traffic_rate=mbps   dl_rate=50   pdu_id=1      qfi_id=2
    MultiUE Trigger DL Traffic for SA   1    3   Traffic_rate=mbps   dl_rate=50   pdu_id=2      qfi_id=1
    MultiUE Trigger DL Traffic for SA   1    3   Traffic_rate=mbps   dl_rate=50   pdu_id=2      qfi_id=2
    MultiUE Trigger DL Traffic for SA   1    3   Traffic_rate=mbps   dl_rate=50   pdu_id=3      qfi_id=1
    MultiUE Trigger DL Traffic for SA   1    3   Traffic_rate=mbps   dl_rate=50   pdu_id=3      qfi_id=2

    sleep   10s

    Trigger RLC max retransmission error    1    1     prof=1      lcid=5    sn=1     ##pdu2 UE1
    Sleep      60s
    Trigger RLC max retransmission error    1    1     prof=2      lcid=6    sn=1    ##pdu3 UE1
    Sleep      60s
    Trigger RLC max retransmission error    2    2     prof=3      lcid=5    sn=1   ##pdu2 UE2
    Sleep      60s
    Trigger RLC max retransmission error    2    2     prof=4      lcid=6    sn=1   ##pdu3 UE2
    Sleep      60s
    Trigger RLC max retransmission error    3    3     prof=5      lcid=5    sn=1   ##pdu2 UE3
    Sleep      60s
    Trigger RLC max retransmission error    3    3     prof=6      lcid=6    sn=1   ##pdu3 UE3
    Sleep      60s

    Check MultiUE UE State Display      1    3       ACTIVE

    sleep   30s

    Trigger RLC max retransmission error    1    1     prof=7      lcid=4    sn=1     ##pdu2 UE1
    Sleep      60s
    Trigger RLC max retransmission error    2    2     prof=8      lcid=4    sn=1    ##pdu3 UE1
    Sleep      60s
    Trigger RLC max retransmission error    3    3     prof=9      lcid=4    sn=1   ##pdu2 UE2
    Sleep      60s

    Check MultiUE UE State Display      1    3       IDLE

    ${path}    Stop Log      btslog     cprt

    MultiUE Deregister should be Successful     1   3

    Verify Packets      ${path}[cprt]     ngap.PDUSessionResourceNotify_element     radioNetwork

    ${Counters}    Create Dictionary     ${NG_FLOW_REL_ABNORMAL_INSESSION}=${18}
    ...        ${NG_FLOW_GNB_REL_RADIO_PROCD_FL}=${12}     ${NG_FLOW_SETUP_FAIL_UNSPECIFIED}=${0}   ${NG_FLOW_REL}=${18}
    ...        ${NG_FLOW_REL_ABNORMAL}=${18}

    Verify Counters    ${Counters}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

[1]CNI129151_IWK3_TC10_CB010686_B2_B3_PDU_Session_Resource_Release_and_PDU_Session_Resource_Modify_after_PDU_Session_Resource_Notify
     Perform SCF Delta Commissioning with Delta_Config_B1_TC10.json
     sleep    60
     gnb.Perform gNB reboot
     sleep    180
     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces    ${wts_cfg_file1}

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

    start log    cprt
    Trigger RLC max retransmission error    2    2     prof=1      lcid=7    sn=1
    Sleep     60s
    ${scen6}    Stop log      cprt     test_scenario=scen6
    verify pduSessionNotify message     ${scen6}[cprt]/NODECPRT_GNB.pcap
    verify RLC injected DRB is in toBeRealeased item     ${scen6}[cprt]/NODECPRT_GNB.pcap   lcid=7
    Sleep    5s

    start log    cprt
    Trigger RLC max retransmission error    2    2     prof=1      lcid=8    sn=1
    Sleep     60s
    ${scen7}    Stop log      cprt     test_scenario=scen7
    verify pduSessionNotify message     ${scen7}[cprt]/NODECPRT_GNB.pcap
    verify RLC injected DRB is in toBeRealeased item     ${scen7}[cprt]/NODECPRT_GNB.pcap   lcid=8
    Sleep    5s

    start log    cprt
    Trigger RLC max retransmission error    2    2     prof=1      lcid=9    sn=1
    Sleep     60s
    ${scen8}    Stop log      cprt      btslog     test_scenario=scen8
#    verify pduSessionNotify message     ${scen8}[cprt]/NODECPRT_GNB.pcap
#    verify RLC injected DRB is in toBeRealeased item     ${scen8}[cprt]/NODECPRT_GNB.pcap   lcid=9
    Sleep    2s

    Check MultiUE UE State Display      1    1       ACTIVE
    Check MultiUE UE State Display      2    2       IDLE

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
     FOR        ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
     wtsrunner.ue_pdu_session_modify      ue=${ue_idx}       pdu=${pdu_id}    qosflows_to_add=${qosflows_to_add}
     ...             by=amf
     Sleep      2s
     END

2nd PDU addition
    [Arguments]    ${start_ue_id}     ${end_ue_id}    ${gw_id}=1

    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
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
    [Arguments]     ${start_ue_id}    ${end_ue_id}      ${state}=${EMPTY}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_disp     id=${ue_idx}
    ${output}   wtsrunner.read_wtsemu_output_until_re        expected=opc_key    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    ${state}    partial_match=${TRUE}
    Log to Console    ${output}
    Should Contain    ${output}   ${state}
    Log to Console    UE: ${ue_idx} moved to ${state} state
    END
Repeat
    Start Log      btslog     cprt
    ${ue_to_bearer_list}       ${lcid_list}       MultiUE Register should be Successful with lcid     1    3    pdu_id=1
    Log to Console    ${lcid_list}
    Add multiple PDU session with lcid    1    3       pdu_id=2

    PDU Modfication to add additional qfi    1    1   pdu_id=2    qosflows_to_add=12
    PDU Modfication to add additional qfi    2    2   pdu_id=2    qosflows_to_add=6
    PDU Modfication to add additional qfi    3    3   pdu_id=2    qosflows_to_add=2
    PDU Modfication to add additional qfi    3    3   pdu_id=2    qosflows_to_add=3

    Add multiple PDU session with lcid    2    3       pdu_id=3
    PDU Modfication to add additional qfi    2    2   pdu_id=3    qosflows_to_add=2
    PDU Modfication to add additional qfi    2    2   pdu_id=3    qosflows_to_add=3
    PDU Modfication to add additional qfi    3    3   pdu_id=3    qosflows_to_add=6

    MultiUE Trigger DL Traffic for SA   1    1   Traffic_rate=mbps   dl_rate=175   pdu_id=1      qfi_id=1
    MultiUE Trigger DL Traffic for SA   1    1   Traffic_rate=mbps   dl_rate=175   pdu_id=2      qfi_id=1
    MultiUE Trigger DL Traffic for SA   1    1   Traffic_rate=mbps   dl_rate=175   pdu_id=2      qfi_id=2

    MultiUE Trigger DL Traffic for SA   2    2   Traffic_rate=mbps   dl_rate=175   pdu_id=1      qfi_id=1
    MultiUE Trigger DL Traffic for SA   2    2   Traffic_rate=mbps   dl_rate=175   pdu_id=2      qfi_id=1
    MultiUE Trigger DL Traffic for SA   2    2   Traffic_rate=mbps   dl_rate=175   pdu_id=2      qfi_id=2
    MultiUE Trigger DL Traffic for SA   2    2   Traffic_rate=mbps   dl_rate=175   pdu_id=3      qfi_id=1
    MultiUE Trigger DL Traffic for SA   2    2   Traffic_rate=kbps   dl_rate=32   pdu_id=3      qfi_id=2
    MultiUE Trigger DL Traffic for SA   2    2   Traffic_rate=rtp_codec   dl_rate=amr_wb_18_25   pdu_id=3      qfi_id=3

    MultiUE Trigger DL Traffic for SA   3    3   Traffic_rate=mbps   dl_rate=175   pdu_id=1      qfi_id=1
    MultiUE Trigger DL Traffic for SA   3    3   Traffic_rate=mbps   dl_rate=175   pdu_id=2      qfi_id=1
    MultiUE Trigger DL Traffic for SA   3    3   Traffic_rate=mbps   dl_rate=175   pdu_id=2      qfi_id=2
    MultiUE Trigger DL Traffic for SA   3    3   Traffic_rate=rtp_codec   dl_rate=amr_wb_18_25   pdu_id=2      qfi_id=3
    MultiUE Trigger DL Traffic for SA   3    3   Traffic_rate=mbps   dl_rate=175   pdu_id=3      qfi_id=1
    MultiUE Trigger DL Traffic for SA   3    3   Traffic_rate=mbps   dl_rate=175   pdu_id=3      qfi_id=2

    Perform SCF Delta Commissioning with Delta_config_deactivate.json

    Trigger RLC max retransmission error    1    1     prof=1      lcid=4    sn=1
    Sleep      120s
    Trigger RLC max retransmission error    2    2     prof=2      lcid=4    sn=1
    Sleep      120s
#    Trigger RLC max retransmission error    3    3     prof=4      lcid=4    sn=1
    Trigger RLC max retransmission error    3    3     prof=3      lcid=4    sn=1
    Sleep      120s
    Check MultiUE UE State Display      1    3       IDLE
    Sleep      120s

    MultiUE Deregister should be Successful     1   3

    sleep  30s

    ${ue_to_bearer_list}       ${lcid_list}       MultiUE Register should be Successful with lcid     1    3    pdu_id=1
    Log to Console    ${lcid_list}
    Add multiple PDU session with lcid    1    3       pdu_id=2

    PDU Modfication to add additional qfi    1    1   pdu_id=2    qosflows_to_add=12
    PDU Modfication to add additional qfi    2    2   pdu_id=2    qosflows_to_add=6
    PDU Modfication to add additional qfi    3    3   pdu_id=2    qosflows_to_add=2
    PDU Modfication to add additional qfi    3    3   pdu_id=2    qosflows_to_add=3

    Add multiple PDU session with lcid    2    3       pdu_id=3
    PDU Modfication to add additional qfi    2    2   pdu_id=3    qosflows_to_add=2
    PDU Modfication to add additional qfi    2    2   pdu_id=3    qosflows_to_add=3
    PDU Modfication to add additional qfi    3    3   pdu_id=3    qosflows_to_add=6

    MultiUE Trigger DL Traffic for SA   1    1   Traffic_rate=mbps   dl_rate=175   pdu_id=1      qfi_id=1
    MultiUE Trigger DL Traffic for SA   1    1   Traffic_rate=mbps   dl_rate=175   pdu_id=2      qfi_id=1
    MultiUE Trigger DL Traffic for SA   1    1   Traffic_rate=mbps   dl_rate=175   pdu_id=2      qfi_id=2

    MultiUE Trigger DL Traffic for SA   2    2   Traffic_rate=mbps   dl_rate=175   pdu_id=1      qfi_id=1
    MultiUE Trigger DL Traffic for SA   2    2   Traffic_rate=mbps   dl_rate=175   pdu_id=2      qfi_id=1
    MultiUE Trigger DL Traffic for SA   2    2   Traffic_rate=mbps   dl_rate=175   pdu_id=2      qfi_id=2
    MultiUE Trigger DL Traffic for SA   2    2   Traffic_rate=mbps   dl_rate=175   pdu_id=3      qfi_id=1
    MultiUE Trigger DL Traffic for SA   2    2   Traffic_rate=kbps   dl_rate=32   pdu_id=3      qfi_id=2
    MultiUE Trigger DL Traffic for SA   2    2   Traffic_rate=rtp_codec   dl_rate=amr_wb_18_25   pdu_id=3      qfi_id=3

    MultiUE Trigger DL Traffic for SA   3    3   Traffic_rate=mbps   dl_rate=175   pdu_id=1      qfi_id=1
    MultiUE Trigger DL Traffic for SA   3    3   Traffic_rate=mbps   dl_rate=175   pdu_id=2      qfi_id=1
    MultiUE Trigger DL Traffic for SA   3    3   Traffic_rate=mbps   dl_rate=175   pdu_id=2      qfi_id=2
    MultiUE Trigger DL Traffic for SA   3    3   Traffic_rate=rtp_codec   dl_rate=amr_wb_18_25   pdu_id=2      qfi_id=3
    MultiUE Trigger DL Traffic for SA   3    3   Traffic_rate=mbps   dl_rate=175   pdu_id=3      qfi_id=1
    MultiUE Trigger DL Traffic for SA   3    3   Traffic_rate=mbps   dl_rate=175   pdu_id=3      qfi_id=2

    sleep  30s

    Perform SCF Delta Commissioning with Delta_config_activate.json

    Trigger RLC max retransmission error    1    1     prof=1      lcid=4    sn=1
    Sleep      60s
    Trigger RLC max retransmission error    2    2     prof=2      lcid=4    sn=1
    Sleep      60s
    Trigger RLC max retransmission error    2    2     prof=3      lcid=5    sn=1
    Sleep      60s
    Trigger RLC max retransmission error    3    3     prof=4      lcid=4    sn=1
    Sleep      60s
    Trigger RLC max retransmission error    3    3     prof=5      lcid=6    sn=1
    Sleep      200s

    Check MultiUE UE State Display      1    3       ACTIVE

    MultiUE Deregister should be Successful     1   3

Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    common_setup_teardown.Configure UTE ETH3
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    #${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready - ${BBoard_Type}

    Log To console     loading cfg file
    Start Log   btslog    cprt
    Start WTS Using WTS_Runner      ${wts_cfg_file}
    ${cprt_log_1}     Stop Log  cprt  test_scenario=cellsetup
    set suite variable    ${cprt_log_1}
    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup_sys
    set suite variable    ${cell_sys_log}


