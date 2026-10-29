*** Settings ***
Force Tags       CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_TDD
...              CRT    5G_RAN_FDD    SBTS00    RAN_5G    5G_RAN    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Prasanta
...              :contact: prasanta.kumar_nayak@nokia.com
...              :Requirement ID: 5G_RAN_USR_RRM_25477
...              :Description:This test scenario verifies the behavior of gNodeB when a PDU Session Resource Setup
...              request is received S-NSSAI which is not configured at the gNodeB and to verify that  gNodeB will
...              switch  non configured S-NSSAI to default configured
...              S-NSSAI  and proceed with the establishment of PDU session with default S-NSSAI.



Resource         ./basic_resource.robot


Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=one_plmn_multiple_slice_tc6.xml
...                 AND     sleep    180s
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    180s
...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file}
...                 AND     Sleep    60s





Suite Teardown      Run Keywords    Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Teardown    Run Keywords       Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport


*** Variables ***
${wts_cfg_file}      ${CURDIR}/config/wts/one_plmn_multiple_slice_tc6.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
&{nwslice_ID}   ${1}=1    ${2}=2     ${3}=3     ${4}=3
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${SST_CFG}    1
${SD1}    13714341
${SD2}    2
${SD3}    3
${SD4}    4

@{sl_ue1}    ${7}    ${3}
@{sl_ue2}    ${8}    ${8}
@{sl_ue3}    ${9}    ${2}
&{ue_info}   ${1}=${sl_ue1}     ${2}=${sl_ue2}     ${3}=${sl_ue3}    ${4}=${sl_ue3}
#${epc_log_path}    /tmp/
#${TEST_NAME}            Cell_setup
*** Test Cases ***
[1]CNI121217_CB013052-A_B2_TC6_Graceful_handling_during_PDU_Session_Resource_Setup_for_multiple_PDU_session_with_SRB2_setup
    [Documentation]   This scenario is to verify multiple PDU session and slice provided in pdu session message is
    ...    not configured at the gNodeB so PDU session will be eatsblsished via the default slice.

    MultiUE Register should be Successful custom    1    1    1    ics_wo_pdu=${1}
    MultiUE Trigger UL Traffic for SA    1    1     mbps    10
    MultiUE Trigger DL Traffic for SA    1    1     mbps    10
    Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    ngap.PDUSessionResourceSetupRequest_element    ngap
     ...     ${1}
    ${sl_ue1}    Create List    13714341
    Set To Dictionary    ${ue_info}     ${1}       ${sl_ue1}
    Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap
    ...     ${1}
    Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    f1ap.UEContextSetupRequest_element    f1ap    ${1}
    UE Register should be Successful custom    2
    UE Make PDU session     ${2}    1     ics_wo_pdu=${1}

    Set To Dictionary    ${ue_info}     ${2}       ${sl_ue1}
    Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap
    ...     ${2}
    Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    f1ap.UEContextSetupRequest_element    f1ap    ${2}
    Set To Dictionary    ${nwslice_ID}     ${2}    1
    UE Make PDU session     ${2}    2     ics_wo_pdu=${1}
    ${pdu_list}    Create List    ${1}    ${2}
    # Making 15 PDU sessions for the UE
    FOR     ${i}    IN RANGE    ${3}    ${16}
    UE Make PDU session     ${2}    ${i}     ics_wo_pdu=${1}
    MultiUE Trigger UL Traffic for SA    2    2     mbps    10    pdu_id=${i}   qfi_id=1
    MultiUE Trigger DL Traffic for SA    2    2     mbps    10    pdu_id=${i}   qfi_id=1
    sleep     60s
    Validate DL Traffic For MultiUE for SA    2    2    10    pdu_id=${i}   qfi_id=1
    Validate UL Traffic For MultiUE for SA    2    2    10    pdu_id=${i}   qfi_id=1
    END

    UE Register should be Successful custom    3
    wtsrunner.smf_param      additional_qosflows_to_activate=6,7      id=1
    UE Make PDU session     ${3}    1     ics_wo_pdu=${1}

    ${qfi_list}    Create List    ${1}    ${2}    ${3}
    Trigger Traffic on QFI wise      ${1}      mbps     10     ${qfi_list}
    sleep     120s
    Validate Traffic on QFI wise  ${1}   ${10}    ${qfi_list}

    wtsrunner.smf_param      additional_qosflows_to_activate=7      id=1
    Modify NIDD parameters   MRBTS-1/NRBTS-1   update   actSliceSwitchToDefault    false
    UE Make PDU session     ${3}    3     neg=${1}
    Modify NIDD parameters   MRBTS-1/NRBTS-1   update   actSliceSwitchToDefault    true
    UE Make PDU session     ${3}    4     ics_wo_pdu=${1}
    sleep    60s
    MultiUE Trigger UL Traffic for SA    3    3     mbps    10    pdu_id=${4}   qfi_id=1
    MultiUE Trigger DL Traffic for SA    3    3     mbps    10    pdu_id=${4}   qfi_id=1
    sleep     60s
    Validate DL Traffic For MultiUE for SA    3    3    10    pdu_id=${4}   qfi_id=1
    Validate UL Traffic For MultiUE for SA    3    3    10    pdu_id=${4}   qfi_id=1
    Validate Traffic on QFI wise  ${1}   ${10}    ${qfi_list}

    Start Log    cprt
    Make emergency call vonr    ${4}    ${1}    ics_wo_pdu=${1}
    ${cprt_log}     Stop Log  cprt  test_scenario=UE_${4}_${1}

    Trigger VoNR DL Traffic for SA    ${4}    pdu_id=1     trf_id=1     qfi_id=2    rtp_codec=custom
    Trigger VoNR UL Traffic for SA    ${4}    pdu_id=1     trf_id=1     qfi_id=2    rtp_codec=custom
    sleep     60s
    Validate DL Traffic For SA   ${4}     dl_rate=0.023      pdu_id=1    qfi_id=2
    Validate UL Traffic For SA   ${4}     ul_rate=0.023      pdu_id=1    qfi_id=2


    MultiUE Deregister should be Successful    1    4
    ${Counters}    Create Dictionary     ${SLICE_FALLBACK_SUC}=${19}     ${NG_FLOW_SETUP_FAIL_WRONG_MSG}=${2}
    ...     ${NRRCC_RRC_STPREQ_EMERGENCY}=${1}    ${NRRCC_RRC_STPSUCC_EMERGENCY}=${1}
    Wait until the next Measurement Period starts
    sleep    600s

    Verify Counters modi   ${Counters}    NRCELL-1


*** Keywords ***


Trigger Traffic on QFI wise
    [Arguments]     ${ue_id}      ${unit}      ${rate}     ${qfis}
    [Documentation]   Triiger Traffic on QFI wise

    FOR    ${qfi}    IN RANGE    @{qfis}
       MultiUE Trigger DL Traffic for SA    ${ue_id}    ${ue_id}     ${unit}    ${rate}    qfi_id=${qfi}
       MultiUE Trigger UL Traffic for SA    ${ue_id}    ${ue_id}     ${unit}    ${rate}    qfi_id=${qfi}
    END

Validate Traffic on QFI wise
    [Arguments]    ${ue_id}      ${rate}    ${qfis}
    [Documentation]   Triiger Traffic on QFI wise

    FOR    ${qfi}    IN RANGE    @{qfis}
       Validate UL Traffic For MultiUE for SA    ${ue_id}    ${ue_id}    ${rate}    qfi_id=${qfi}
       Validate DL Traffic For MultiUE for SA    ${ue_id}    ${ue_id}    ${rate}    qfi_id=${qfi}
    END
