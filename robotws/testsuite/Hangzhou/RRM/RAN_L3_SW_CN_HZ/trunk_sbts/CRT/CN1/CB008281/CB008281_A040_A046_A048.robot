*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-christine.chen
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008281    release-SBTS23R4
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{intraFreqintragnb}
...    @{8281}
...    @{PCMD_related}
...    @{732}

@{8281}
...    NRCELL:actUlNrEcIdPosMethod=true
...    NRBTS:nrEcidMeasSupervisionTimer=6500

@{732}
...    NRBTS:rrcReestabTypeSA=sameGNB

@{intraFreqintragnb}
...    NRBTS:actSaUeBasedInterFreqAnrNr=false
...    NRBTS:actIntraFreqHoSA=true
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRBTS:actInterFreqHoSA=true
...    NRBTS/NRPMRNL-1:miNrRelReportCu=15min

@{PCMD_related}    @{TCE}    @{NRMTRACECU}    @{CellTrace_enable}    @{traceAll}    @{PCMD_enable}    @{PeriodicUeMeas}
...    @{PCMD_DU_enable}

@{TCE}
...    MRBTS/MNL-1/TCEADM-1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=${TCE_IP}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=${TCE_PORT}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tlsEnabled=false
...    NRBTS/NRCTRLTS-1

@{NRMTRACECU}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:scope=allResources
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1

@{CellTrace_enable}
...    NRBTS:actCellTraceReport=true
...    NRBTS:actSubscriberTraceReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all

@{PCMD_enable}
...    NRBTS:actPCMDReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true

@{traceAll}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=all

@{PeriodicUeMeas}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=TraceOnly

@{PCMD_DU_enable}
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:actPCMDReporting=true
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:jobType=TraceOnly
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrTceIdentifier=1
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:scope=allResources
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mcc=311
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mnc=489
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mncLength=3
...    NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:traceId=1

@{online_modify_srbInactivityTimer}
...    NRBTS:drbInactivityTimerSA=4
...    NRBTS:srbInactivityTimerSA=4

@{online_modify_srbInactivityTimerSA_recovery}
...    NRBTS:srbInactivityTimerSA=60
...    NRBTS:drbInactivityTimerSA=60

@{PM_Counters_Check_A040}
...    NRCELL-1:${NRPPA_MEASINIT_FAIL_PRERR_D}=3
...    NRCELL-1:${NRPPA_ERR_IND_PRERR_D}=2
...    NRCELL-1:${NRPPA_MEASINIT_FAIL_NOTSUP_D}=1

${NRPPA_MEASINIT_FAIL_PRERR_D}    M55125C00028
#Num of UL UE-associated NRPPA transport messages with E-CID measurement initiation failure due to protocol error per NR cell
${NRPPA_ERR_IND_PRERR_D}    M55125C00034
#Num of UL UE-associated NRPPA transport messages with NRPPA: ErrorIndication per NR cell
${NRPPA_MEASINIT_FAIL_NOTSUP_D}    M55125C00026
#Number of UL UE-associated NRPPA transport messages with E-CID measurement initiation failure with cause "Requested Item not Supported" per NR Cell

${ECID_without_Measurement_Quantity}    SEPARATOR=
...    0008403C000004000A00020001005500020000005900111061626364656630313233343536376768002E00141300020000010D0000020002
...    0001000003000100
${ECID_without_Report_Characteristics_IE}    SEPARATOR=
...    00084048000004000A00020001005500020000005900111061626364656630313233343536376768002E00201F0002000001190000020002
...    0001000005000D04000B00022000000B00022040
${ECID_with_duplicated_for_Report}    SEPARATOR=
...    00084063000004000A00020001005500020000005900111061626364656630313233343536376768002E003B3A0002000001340000050002
...    000100000300010000030001000005000D04000B00022000000B000220400005000D04000B00022000000B00022040
${ECID_without_LMF_UE_Measurement_ID}    SEPARATOR=
...    00084048000004000A00020001005500020000005900111061626364656630313233343536376768002E00201F0002000001190000020003
...    0001000005000D04000B00022000000B00022040
${ECID_request_received_with_Measurement_ID_out_of_range}    SEPARATOR=
...    00084050000004000A00020001005500020000005900111061626364656630313233343536376768002E0028270002000001210000030002
...    00048002010100030001000005000D04000B00022000000B00022040
${ECID_request_received_with_Periodic}    SEPARATOR=
...    0008404D000004000A00020001005500020000005900111061626364656630313233343536376768002E00252400020000011E0000030002
...    00010000030001400005000D04000B00022000000B00022040

${ECID_MS_Failure}
...    Received ECID Measurement Failure with NRPPATransactionID
${Invalid_NRPPA_PDU}
...    LMF Received ErrorIndication with NRPPATransactionId

@{ECID_failure_and_UE_Inactivity}
...    ECID Measurement Initiation Request sent
...    Received ECID Measurement Failure
...    Received UE Context Release Complete
...    UE1: IS IDLE

*** Test Cases ***
CB008281_A040_Verify Cell Trace when that gNB-CU-CP sends E-CID MEASUREMENT INITIATION FAILURE when missing the mandatory IE in Request
    [Documentation]
    ...    1. The purpose of this test case is to check that gNB-CU-CP sends E-CID MEASUREMENT INITIATION FAILURE when the E-CID MEASUREMENT
    ...    INITIATION REQUEST is missing the mandatory IE's.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured actUlNrEcIdPosMethod=true, nrEcidMeasSupervisionTimer=6500
    ...    3. Test Case Steps:
    ...    a. setup SA call and check throuput
    ...    b. LMF sends E-CID MEASUREMENT INITIATION REQUEST without Measurement Quantity and return transfer-syntax-error.
    ...    c. LMF sends E-CID MEASUREMENT INITIATION REQUEST without Report Characteristics IE and return transfer-syntax-error.
    ...    d. LMF sends E-CID MEASUREMENT INITIATION REQUEST with duplicated for Report Characteristics IE and Measurement Quantity and return
    ...    abstract-syntax-error-falsely-constructed-message
    ...    e. LMF sends E-CID MEASUREMENT INITIATION REQUEST without LMF UE Measurement ID IE and return transfer-syntax-error
    ...    f. LMF sends E-CID MEASUREMENT INITIATION REQUEST containing UE Measurement ID that is out of range and return transfer-syntax-error
    ...    g. LMF sends E-CID MEASUREMENT INITIATION REQUEST containing request received with 'Periodic' and return requested-item-not-supported
    ...    h. check log for Cell Trace and/or Subscriber & Equipment trace record
    ...    i. check counter
    [Tags]    QC_304047    christine.chen    A040
    Clear Counter Files    wait=${False}
    UE attach cell    ue_id=1    cell_id=1
    Send Throuput and check Throuput
    Trigger ECID and modify Report IE    ECID_report=${ECID_without_Measurement_Quantity}    pass_regexp=${ECID_MS_Failure}
    Trigger ECID and modify Report IE    ECID_report=${ECID_without_Report_Characteristics_IE}    pass_regexp=${ECID_MS_Failure}
    Trigger ECID and modify Report IE    ECID_report=${ECID_with_duplicated_for_Report}    pass_regexp=${ECID_MS_Failure}
    Trigger ECID and modify Report IE    ECID_report=${ECID_without_LMF_UE_Measurement_ID}    pass_regexp=${Invalid_NRPPA_PDU}
    Trigger ECID and modify Report IE    ECID_report=${ECID_request_received_with_Measurement_ID_out_of_range}    pass_regexp=${Invalid_NRPPA_PDU}
    Trigger ECID and modify Report IE    ECID_report=${ECID_request_received_with_Periodic}    pass_regexp=${ECID_MS_Failure}
    UE Deregister From gNB    ue_id=1
    Check WireShark Log    ${CURDIR}${/}A2A_A_040${/}a2a.ini    wait_string=UEContextRelease::18
    Check Counters    ${PM_Counters_Check_A040}

CB008281_A046_Verify NR Cell measurements record when the reporting of E-CID MEASUREMENT Results when UE initiates RRE Request
    [Documentation]
    ...    1. The purpose of this test case is to Verify the reporting of E-CID MEASUREMENT Results when UE detects Radio link failure
    ...    and initiates RRCReestablishment Request.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured actUlNrEcIdPosMethod=true, nrEcidMeasSupervisionTimer=6500,rrcReestabTypeSA=sameGNB
    ...    3. Test Case Steps:
    ...    a. setup SA call
    ...    b. send throuput and check throupt
    ...    c. LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE set to "On-Demand" and Measurement Quantity
    ...    requested is 'SS-RSRP & SS-RSRQ'. while waiting for the MeasurementReport for the E-CID Measurement Quantities, gnb received
    ...    "RRCReestablishmentRequest" from the UE. UE send E-CID Measurement report before release of the UE measurements to UE. LMF received
    ...    E-CID MEASUREMENT INITIATION FAILURE with cause:Requested Item Temporarily not Available
    ...    d. UE deregist
    [Tags]    QC_304048    christine.chen    A046
    UE attach cell    ue_id=1    cell_id=1
    Send Throuput and check Throuput
    Trigger ECID and RRCReestablishmentRequest
    UE Deregister From gNB    ue_id=1
    Check WireShark Log    ${CURDIR}${/}A2A_A_046${/}a2a.ini    wait_string=UEContextRelease::18

CB008281_A048_Verify Cell Trace when that E-CID Measurement is terminated when UE Inactivity
    [Documentation]
    ...    1. The purpose of this test case is to Verify that E-CID Measurement is terminated by the gNB-CU-CP when UE Inactivity is
    ...    detected by the gNB-CU-CP and Context clean-up is initiated.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured actUlNrEcIdPosMethod=true, nrEcidMeasSupervisionTimer=6500,drbInactivityTimerSA=4,srbInactivityTimerSA=4.
    ...    3. Test Case Steps:
    ...    a. setup SA call
    ...    b. send throuput and check throupt
    ...    c. LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE set to "On-Demand" and Measurement Quantity
    ...    requested is 'SS-RSRP & SS-RSRQ'. while waiting for the MeasurementReport for the E-CID Measurement Quantities,Event 1: E1AP:
    ...    BearerContextInactivityNotification from gNB-CU-UP. LMF received E-CID MEASUREMENT INITIATION FAILURE with cause:Requested Item
    ...    Temporarily not Available
    ...    d. UE deregist
    [Tags]    QC_304050    christine.chen    A048
    OnlineParamChange    ${online_modify_srbInactivityTimer}
    UE attach cell    ue_id=1    cell_id=1
    sleep    3s    #wait srbtimer timeout
    Trigger ECID and UE inactivity
    UE Deregister From gNB    ue_id=1
    Check WireShark Log    ${CURDIR}${/}A2A_A_048${/}a2a.ini    wait_string=UEContextRelease::42
    [Teardown]    A048 TestTeardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15
    Start TCE    ${TCE_PORT}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

A048 TestTeardown
    OnlineParamChange    ${online_modify_srbInactivityTimerSA_recovery}
    Common Test Teardown And Stop Capture Logs

Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh

UE attach cell
    [Arguments]    ${ue_id}    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

Trigger ECID and modify Report IE
    [Arguments]    ${ECID_report}=${ECID_without_Measurement_Quantity}    ${pass_regexp}=Received ECID Measurement Failure    ${ue_id}=1
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=3000 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report
    Execute Egate Command    send_hex source=amf:1 target=gnb:2 hex=${ECID_report}    pass_regexp=${pass_regexp}

Trigger ECID and RRCReestablishmentRequest
    [Arguments]    ${ue_id}=1
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=3000 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report
    ${cmd1}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=1 lmf_ue_measurement_id=1 report_characteristics=OnDemand
    ...    meas_qty=SS-RSRP,SS-RSRQ
    Execute Egate Command    ${cmd1}    pass_regexp=rrcReconfigurationComplete
    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=otherFailure    pass_regexp=rrcReconfigurationComplete

Trigger ECID and UE inactivity
    [Arguments]    ${ue_id}=1
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=5000 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report
    ${cmd1}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=1 lmf_ue_measurement_id=1 report_characteristics=OnDemand
    ...    meas_qty=SS-RSRP,SS-RSRQ
    Execute Egate Command    ${cmd1}    pass_regexp=${ECID_failure_and_UE_Inactivity}

Send Throuput and check Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=10 trf_id=2    UE ${ue_id}: UDP DL
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput for cell    ue_id=1

Verify Throuput for cell
    [Arguments]    ${ue_id}=1    ${dl}=8    ${ul}=8    ${pdu_id}=1
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000 >${dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

