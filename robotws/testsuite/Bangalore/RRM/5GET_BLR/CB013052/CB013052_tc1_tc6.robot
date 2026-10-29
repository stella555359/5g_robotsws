*** Settings ***
Force Tags       CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_TDD
...              CRT    5G_RAN_FDD    SBTS00    RAN_5G    5G_RAN    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Prasanta
...              :contact: Prasanta.kumar_nayak@nokia.com
...             This test case verifies that PDU session establsihment procedure when the slice provided is not
...             configured  at the gNodeB.
...             Rquirement Id:   5G_RAN_USR_RRM_25475



Resource         ./basic_resource.robot

Suite Teardown      Run Keywords    Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Teardown    Run Keywords       Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport
#...                 AND     DCAP Disconnect To gNB


Test Setup       Start_capture_testcase_default_logging

*** Variables ***
${wts_cfg_file}      ${CURDIR}/config/wts/tc1.cfg
${wts_cfg_file_tc6}      ${CURDIR}/config/wts/one_plmn_multiple_slice_tc6.cfg
${wts_cfg_file_tc7}     ${CURDIR}/config/wts/slice_basic_setup_multi_ue_Xn_HO.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
&{nwslice_ID}   ${1}=1    ${2}=2     ${3}=3     ${4}=3
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${MCC}    311
${MNC}     489
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
*** Test Cases ***
[1][1.0]_CNI121217_CB013052-A_B1_TC1_Graceful_handling_during_ICS__with_multiple_PDU_sessions_procedure
   [Documentation]   This scenario is to verify the multiple PDU session establishment procedure and slice info shared
   ...      in PUD establishment is not configured at the gNodeB.
   [Setup]		Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
	...                 AND     Perform SCF Delta Commissioning with tc1.json
	...                 AND     sleep    120s
	...                 AND     gnb.Perform gNB reboot
	...                 AND     sleep    120s
	...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file}
	...                 AND     Sleep    60s
    Wait until the next Measurement Period starts
     ${sl_ue1}    Create List    13714341    3
     ${sl_ue2}    Create List     2     2
    FOR    ${ue_id}  IN RANGE   ${1}    ${3}
     UE Register should be Successful custom    ${ue_id}
     Start Log    cprt
     Wait for next pdu session    ${ue_id}
     UE Make PDU session wo validation     ${ue_id}    1
     #PDU session 1 will use def    cnt=1 Ue2 def cnt=2
     Set To Dictionary    ${nwslice_ID}     ${1}       6
     UE Make PDU session wo validation     ${ue_id}    2
     sleep    5s
     ${cprt_log}     Stop Log  cprt  test_scenario=UE_${ue_id}
     MultiUE Trigger UL Traffic for SA    ${ue_id}    ${ue_id}     mbps    10
     MultiUE Trigger DL Traffic for SA    ${ue_id}    ${ue_id}     mbps    10

     MultiUE Trigger UL Traffic for SA    ${ue_id}    ${ue_id}     mbps    10    pdu_id=2
     MultiUE Trigger DL Traffic for SA    ${ue_id}    ${ue_id}     mbps    10    pdu_id=2
     Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    ngap.InitialContextSetupRequest_element    ngap    ${ue_id}

     Run Keyword if    ${ue_id}==${1}    Set To Dictionary    ${ue_info}     ${1}       ${sl_ue1}
     Run Keyword if    ${ue_id}==${2}    Set To Dictionary    ${ue_info}     ${2}       ${sl_ue2}
     Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap    ${ue_id}
     Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    f1ap.UEContextSetupRequest_element    f1ap    ${ue_id}
     sleep    60s
     Validate DL Traffic For MultiUE for SA    ${ue_id}    ${ue_id}     dl_rate=10   pdu_id=1   qfi_id=1
     Validate DL Traffic For MultiUE for SA    ${ue_id}    ${ue_id}     dl_rate=10   pdu_id=2   qfi_id=1
     Validate UL Traffic For MultiUE for SA    ${ue_id}    ${ue_id}     ul_rate=10   pdu_id=1   qfi_id=1
     Validate UL Traffic For MultiUE for SA    ${ue_id}    ${ue_id}     ul_rate=10   pdu_id=2   qfi_id=1

     Modify NIDD parameters   MRBTS-1/NRBTS-1/SNSSAI-1   update   administrativeState    Locked


    END
    Log To console      Lock the nssai

    Modify NIDD parameters   MRBTS-1/NRBTS-1/SNSSAI-2   update   administrativeState    Locked
    # now NSSAI-3 will be the default one UE 3 logs
    UE Register should be Successful custom    ${3}


    Start Log    cprt
#    Wait for next pdu session    ${3}

    UE Make PDU session wo validation     ${3}     1     # def cnt=4
    Set To Dictionary    ${nwslice_ID}     ${3}    5
    sleep    10s
    wtsrunner.smf_param      additional_qosflows_to_activate=4,6      id=1
    UE Make PDU session wo validation     ${3}     2    #non def cnt=4
    sleep    5s
    ${cprt_log}     Stop Log  cprt  test_scenario=UE_${3}
    Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    ngap.InitialContextSetupRequest_element    ngap    ${3}

    ${sl_ue3}    Create List     3     3
    Set To Dictionary    ${ue_info}     ${3}       ${sl_ue3}
    Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap    ${3}
    Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    f1ap.UEContextSetupRequest_element    f1ap    ${3}
    MultiUE Trigger UL Traffic for SA    ${3}    ${3}     mbps    30
    MultiUE Trigger DL Traffic for SA    ${3}    ${3}     mbps    30
#    MultiUE Trigger UL Traffic for SA    ${3}    ${3}     mbps    30     qfi_id=2
#    MultiUE Trigger DL Traffic for SA    ${3}    ${3}     mbps    30     qfi_id=2

    MultiUE Trigger UL Traffic for SA    ${3}    ${3}     mbps    30     pdu_id=2
    MultiUE Trigger DL Traffic for SA    ${3}    ${3}     mbps    30     pdu_id=2
    MultiUE Trigger UL Traffic for SA    ${3}    ${3}     mbps    30     qfi_id=2    pdu_id=2
    MultiUE Trigger DL Traffic for SA    ${3}    ${3}     mbps    30     qfi_id=2    pdu_id=2

    Sleep    60s
    Validate DL Traffic For MultiUE for SA    ${3}    ${3}     dl_rate=30   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${3}    ${3}     ul_rate=30   pdu_id=1   qfi_id=1
#    Validate DL Traffic For MultiUE for SA    ${3}    ${3}     dl_rate=30   pdu_id=1   qfi_id=2
#    Validate UL Traffic For MultiUE for SA    ${3}    ${3}     ul_rate=30   pdu_id=1   qfi_id=2

    Validate UL Traffic For MultiUE for SA    ${3}    ${3}     ul_rate=30   pdu_id=2   qfi_id=1
    Validate DL Traffic For MultiUE for SA    ${3}    ${3}     dl_rate=30   pdu_id=2   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${3}    ${3}     ul_rate=30   pdu_id=2   qfi_id=2
    Validate DL Traffic For MultiUE for SA    ${3}    ${3}     dl_rate=30   pdu_id=2   qfi_id=2


    MultiUE Deregister should be Successful    1    3
    Modify NIDD parameters   MRBTS-1/NRBTS-1/SNSSAI-3   update   administrativeState    Locked


    ${sl_ue1}    Create List    ${3}    ${3}
    ${sl_ue2}    Create List    ${8}    ${8}

    Set To Dictionary    ${ue_info}     ${1}       ${sl_ue1}
    Set To Dictionary    ${ue_info}     ${2}       ${sl_ue2}
    wtsrunner.smf_param      additional_qosflows_to_activate=4      id=1
    FOR    ${ue_id}  IN RANGE   ${1}    ${3}
     UE Register should be Successful custom    ${ue_id}
     Start Log    cprt
     Wait for next pdu session    ${ue_id}
     UE Make PDU session wo validation     ${ue_id}    1
     Set To Dictionary    ${nwslice_ID}     ${1}       6
     #slice 3 -->6 is locked cnt=4+2=6+2=8
     UE Make PDU session wo validation     ${ue_id}    2
     sleep    5s
     ${cprt_log}     Stop Log  cprt  test_scenario=UE_iter_1_${ue_id}
     MultiUE Trigger UL Traffic for SA    ${ue_id}    ${ue_id}     mbps    10
     MultiUE Trigger DL Traffic for SA    ${ue_id}    ${ue_id}     mbps    10

     MultiUE Trigger UL Traffic for SA    ${ue_id}    ${ue_id}     mbps    10    pdu_id=2
     MultiUE Trigger DL Traffic for SA    ${ue_id}    ${ue_id}     mbps    10    pdu_id=2
     Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    ngap.InitialContextSetupRequest_element    ngap
     ...     ${ue_id}
     ${sl_ue1}    Create List    ${4}    ${4}
     ${sl_ue2}    Create List    ${4}    ${4}
     Run Keyword if    ${ue_id}==${1}    Set To Dictionary    ${ue_info}     ${1}       ${sl_ue1}
     Run Keyword if    ${ue_id}==${2}    Set To Dictionary    ${ue_info}     ${2}       ${sl_ue2}
     Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap
     ...     ${ue_id}
     Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    f1ap.UEContextSetupRequest_element    f1ap    ${ue_id}
     sleep    60s
     Validate DL Traffic For MultiUE for SA    ${ue_id}    ${ue_id}     dl_rate=10   pdu_id=1   qfi_id=1
     Validate UL Traffic For MultiUE for SA    ${ue_id}    ${ue_id}     ul_rate=10   pdu_id=1   qfi_id=1
     Validate UL Traffic For MultiUE for SA    ${ue_id}    ${ue_id}     ul_rate=10   pdu_id=2   qfi_id=1
     Validate DL Traffic For MultiUE for SA    ${ue_id}    ${ue_id}     dl_rate=10   pdu_id=2   qfi_id=1
    END
    Modify NIDD parameters   MRBTS-1/NRBTS-1/SNSSAI-2   update   administrativeState    Unlocked
    Set To Dictionary    ${nwslice_ID}     ${3}    3
    UE Register should be Successful custom    ${3}


    Start Log    cprt
#    Wait for next pdu session    ${3}
    UE Make PDU session wo validation     ${3}     1        #cnt= 8+1=9
    sleep    10s
    Set To Dictionary    ${nwslice_ID}     ${3}    5
    wtsrunner.smf_param      additional_qosflows_to_activate=4,6      id=1
    UE Make PDU session wo validation     ${3}     2
    sleep    5s
    ${cprt_log}     Stop Log  cprt  test_scenario=UE_iter_1_${3}
    ${sl_ue3}     Create List    ${9}    ${2}
    set To Dictionary    ${ue_info}     ${3}       ${sl_ue3}
    Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    ngap.InitialContextSetupRequest_element    ngap    ${3}
    ${sl_ue3}     Create List    ${2}    ${2}
    set To Dictionary    ${ue_info}     ${3}       ${sl_ue3}

    Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap    ${3}
    Verify message     ${cprt_log}[cprt]/NODECPRT_GNB.pcap    f1ap.UEContextSetupRequest_element    f1ap    ${3}

    ${Counters}    Create Dictionary     ${SLICE_FALLBACK_SUC}=${10}
    sleep    600s
    Wait until the current Measurement Period stops

    Verify Counters modi   ${Counters}    NRCELL-1
    ${Counters}    Create Dictionary     ${SA_NGBR_DRB_REQ_SLICE}=${-1}
    ${prefix}    set variable    MRBTS-1/NRBTS-1/PLMN-PLMN/
    ${slices}    Create List    ${prefix}MCC-${MCC}/MNC-${MNC}/PLMN-PLMN/SST-${${SST_CFG}}/SD-${SD1}
    ...    ${prefix}MCC-${MCC}/MNC-${MNC}/PLMN-PLMN/SST-${${SST_CFG}}/SD-${SD2}
    ...     ${prefix}MCC-${MCC}/MNC-${MNC}/PLMN-PLMN/SST-${${SST_CFG}}/SD-${SD3}
    ...    ${prefix}MCC-${MCC}/MNC-${MNC}/PLMN-PLMN/SST-${${SST_CFG}}/SD-${SD4}


    ${moc}      set variable     MCC-${MCC}/MNC-${MNC}/PLMN-PLMN/SST-${${SST_CFG}}
    ${val_SA_NGBR_DRB_REQ_SLICE}    Verify Counters modi   ${Counters}    ${moc}    slices=${slices}


    ${Counters}    Create Dictionary     ${SA_NGBR_DRB_SUCC_SLICE}=${-1}
    ${val_SA_NGBR_DRB_SUCC_SLICE}    Verify Counters modi   ${Counters}    ${moc}   slices=${slices}

    ${rc}    Compare counters    ${slices}    ${val_SA_NGBR_DRB_REQ_SLICE}    ${val_SA_NGBR_DRB_SUCC_SLICE}

    ${Counters}    Create Dictionary     ${SA_GBR_DRB_REQ_SLICE}=${-1}
    ${val_SA_GBR_DRB_SUCC_SLICE}    Verify Counters modi   ${Counters}    ${moc}    slices=${slices}
    ${val_SA_GBR_DRB_REQ_SLICE}    Verify Counters modi   ${Counters}    ${moc}    slices=${slices}
    ${rc}    Compare counters    ${slices}    ${val_SA_GBR_DRB_REQ_SLICE}    ${val_SA_GBR_DRB_SUCC_SLICE}
    ${Counters}    Create Dictionary     ${NG_FLOW_SETUP_FAIL_WRONG_MSG}=${0}    ${NG_FLOW_STP_SUC_SLI_FBK_PMQAP}=${13}
    Verify Counters modi   ${Counters}    NRCELL-1
    Should Contain      ${rc}     Pass

[1]CNI121217_CB013052-A_B2_TC6_Graceful_handling_during_PDU_Session_Resource_Setup_for_multiple_PDU_session_with_SRB2_setup
    [Documentation]   This scenario is to verify multiple PDU session and slice provided in pdu session message is
    ...    not configured at the gNodeB so PDU session will be eatsblsished via the default slice.
	[Setup]		Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
	...                 AND     Find Scfc And Fix And Send Full Commissioning
	...                         scfc_filename=one_plmn_multiple_slice_tc6.xml
	...                 AND     sleep    180s
	...                 AND     gnb.Perform gNB reboot
	...                 AND     sleep    180s
	...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file_tc6}
	...                 AND     Sleep    60s


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
Wait for next pdu session
    [Arguments]    ${ue_id}
        wtsrunner.amf_ue_pdu_setup_param     id=1     ue=${ue_id}    action=delay_till_next_pdu_setup

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
