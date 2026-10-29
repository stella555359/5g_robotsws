*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env And IP added for simGNB
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs And start TCE
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT_no_cloud    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-CN3ET    owner-lishuo.geng    release-SBTS24R2     CB009842
Resource    ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    True
@{PARAMS_IN_SCF}
...    @{8281_enable}
...    @{9842_enable}
...    @{PCMD_related}

@{9842_enable}
...    NRCELL:actUlNrEcIdTAdv=true
...    NRBTS:nrEcidMeasSupervisionTimer=2600

@{8281_enable}
...    NRCELL:actUlNrEcIdPosMethod=true
...    NRBTS:timerRRCGuard=2000

@{9842_disable}
...    NRCELL:actUlNrEcIdTAdv=false

@{rlf_and_supervision}
...    NRBTS:nrEcidMeasSupervisionTimer=6100
...    NRBTS:tRLFindForDU=300ms
...    NRBTS:tRLFindForDUSA=300ms
...    NRCELL:rlpDetCsiBsiThreshold=3
...    NRCELL:rlpDetDlHarqThreshold=2

@{A-B3_ET_10_01}
...    @{online_modify_srbInactivityTimer}
...    NRBTS:nrEcidMeasSupervisionTimer=6500

@{A-B3_ET_10_01_recover}
...    @{online_modify_srbInactivityTimerSA_recovery}
...    NRBTS:nrEcidMeasSupervisionTimer=2600

@{online_modify_srbInactivityTimer}
...    NRBTS:drbInactivityTimerSA=1
...    NRBTS:srbInactivityTimerSA=1

@{online_modify_srbInactivityTimerSA_recovery}
...    NRBTS:srbInactivityTimerSA=60
...    NRBTS:drbInactivityTimerSA=60

@{PCMD_related}    @{TCE}    @{NRMTRACECU}    @{CellTrace_enable}    @{traceAll}    @{PCMD_enable}    @{PeriodicUeMeas}
...    @{PCMD_DU_enable}    @{NRSTRACECU}

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

@{NRSTRACECU}
...    NRBTS-1/NRCTRLTS-1/NRSTRACECU-1
...    NRBTS-1/NRCTRLTS-1/NRSTRACECU-1:nrStraceCuId=1
...    NRBTS-1/NRCTRLTS-1/NRSTRACECU-1:applyDefNrTceForAllSessions=true
...    NRBTS-1/NRCTRLTS-1/NRSTRACECU-1:certTypeForTlsAuth=RSA
...    NRBTS-1/NRCTRLTS-1/NRSTRACECU-1:defaultNrTceIdentifier=1
...    NRBTS-1/NRCTRLTS-1/NRSTRACECU-1:nrTcePortNumber=49100
...    NRBTS-1/NRCTRLTS-1/NRSTRACECU-1:tlsEnabled=false

@{PM_Counters_Check_A025}
...    NRCELL-1:${F1_ECID_MEASINIT_REQ}=1
...    NRCELL-1:${F1_ECID_MEASINIT_RESP}=1

@{PM_Counters_Check_A01}
...    NRCELL-2:${F1_ECID_MEASINIT_REQ}=2
...    NRCELL-2:${F1_ECID_MEASINIT_RESP}=2

${F1_ECID_MEASINIT_REQ}    M55113C00013
${F1_ECID_MEASINIT_RESP}    M55113C00014

@{ECID_failure_and_UE_Inactivity}
...    ECID Measurement Initiation Request sent
...    Received ECID Measurement Failure
...    Received UE Context Release Complete
...    UE1: IS IDLE

@{FAULTS_EXCLUDED_CHECKING}
...    8000

*** Test Cases ***
CB009842-SR-A-B4_ET_25_01_Verify the trace and counter when TADV measurement reporting for UL NR-ECID position measurement method
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:Verify the trace and counter when TADV measurement
    ...       reporting for UL NR-ECID position measurement method
    ...    2. Test Case Steps:
    ...      1) setup SA call for UE1 sucessfully.
    ...      2) egate trigger "E-CID Measurement Initiation request" containing Measurement Quantity requested: Tadv from LMF to UE1.
    ...      3) gNB response id-e-CIDMeasurementInitiation with all the mandatory IEs and NR-TADV IE filled
    ...      4)check counter F1_ECID_MEASINIT_REQ and F1_ECID_MEASINIT_RESP
    ...      5) check trace
    [Tags]    owner-lixia.zhou    TC25
    Clear Counter Files    wait=${False}
    SA UE attach with single PDU for SBA trace    ue_id=1    target_cells=1
    trigger E-CID Measurement Initiation request    meas_qty=NR_Timing_Advance
    UE Deregister From gNB For SBA    ue_id=1
    Check WireShark Log    ${CURDIR}${/}A2A_A025${/}a2a.ini    wait_string=UEContextRelease::18
    Check Counters    ${PM_Counters_Check_A025}

CB009842-SR-A-B3_ET_08_01_Verify that gNB-CU-CP initiates termination of E-CID MEASUREMENT when RLF detection is notified by gNB-DU
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:Verify that gNB-CU-CP initiates termination
    ...       of E-CID MEASUREMENT when RLF detection is notified by gNB-DU
    ...    2. Test Case Steps:
    ...      1) setup SA call for UE1 sucessfully.
    ...      2) delay 8s to send MR.
    ...      3) egate trigger "E-CID Measurement Initiation request" containing Measurement Quantity requested:SS-RSRP and
    ...         and Tadv from LMF to UE1.
    ...      4) during waiting for rsrp report, triger RLF from DU
    ...      5) gNB response id-e-CIDMeasurementInitiation with E-CIDMeasurementInitiationFailure contain error
    ...         "radioNetwork: requested-item-temporarily-not-available"
    [Tags]    owner-lixia.zhou    TC08
	[Setup]    Common Test Setup And Start To Capture Logs
    OnlineParamChange    ${rlf_and_supervision}
    SA UE attach with single PDU
    Delay Measurement Report from UE
    trigger E-CID Measurement Initiation request then UE CONTEXT MODIFICATION REQUIRED with the cause indicating the RL Failure
    Rlf recover to deactive
    Check WireShark Log    ${CURDIR}${/}A2A_A008${/}a2a.ini    wait_string=UEContextRelease::27
    [Teardown]    case8_teardown

CB009842-SR-A-B1_ET_01_01_Feature Activation and Deactivation successfully of TADV measurement reporting for UL NR-ECID position measurement
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       feature activation configuration parameters for Tadv and verify that feature activation configuration is updated at NRCELL level.
    ...       Successful Tadv Report for On-Demand Request.
    ...    2. Test Case Steps:
    ...      1)setup SA call for UE1 sucessfully.
    ...      2)UE-1: LMF trigger "E-CID Measurement Initiation request" with measurementQuantitiesValue: NR Timing Advance and
    ...       ReportCharacteristics: OnDemand
    ...      gNB response E-CID Measurement Initiation Failure with RNL Cause = "Requested Item Not Supported" since feature flag is disabled
    ...      3)Online change NRCELL:actUlNrEcIdTAdv=true
    ...      4)UE-1: LMF trigger "E-CID Measurement Initiation request" with measurementQuantitiesValue: NR Timing Advance and
    ...       ReportCharacteristics: OnDemand
    ...      gNB response E-CID MEASUREMENT INITIATION RESPONSE with all the mandatory IEs and NR-TADV IE filled
    ...      5)Online change NRCELL:actUlNrEcIdTAdv=false
    ...      6)UE-1: LMF trigger "E-CID Measurement Initiation request" with measurementQuantitiesValue: NR Timing Advance and
    ...       ReportCharacteristics: OnDemand
    ...      gNB response E-CID Measurement Initiation Failure with RNL Cause = "Requested Item Not Supported" since feature flag is disabled
    ...      7)Online change NRCELL:actUlNrEcIdTAdv=true
    ...      8)setup SA call for UE2 sucessfully.
    ...      9)UE-1: LMF trigger "E-CID Measurement Initiation request" with measurementQuantitiesValue: NR Timing Advance and
    ...       ReportCharacteristics: OnDemand
    ...      gNB response E-CID MEASUREMENT INITIATION RESPONSE with all the mandatory IEs and NR-TADV IE filled
    ...      10)check counters and wireshark
    [Tags]    owner-lishuo.geng
    [Setup]    A001_Setup
    SA UE attach with single PDU    ue_id=1
    trigger E-CID Measurement Initiation request    ue_id=1    meas_qty=NR_Timing_Advance    pass_regexp=Received ECID Measurement Failure
    OnlineParamChange    ${9842_enable}
    trigger E-CID Measurement Initiation request    ue_id=1    meas_qty=NR_Timing_Advance
    OnlineParamChange    ${9842_disable}
    trigger E-CID Measurement Initiation request    ue_id=1    meas_qty=NR_Timing_Advance    pass_regexp=Received ECID Measurement Failure
    OnlineParamChange    ${9842_enable}
    SA UE attach with single PDU    ue_id=2
    trigger E-CID Measurement Initiation request    ue_id=2    meas_qty=NR_Timing_Advance
    Deregister UE And Check Counters And Check Wireshark Log For case001

CB009842-SR-A-B5_ET_15_01_Successful E-CID Measurement Reporting for TADV along with RSRP and RSRQ with failure due to measurement report timeout
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:Verify that gNB-CU-CP sends E-CID MEASUREMENT INITIATION RESPONSE with
    ...        Tadv and Cell-Id when there is no Measurement Report from UE for any of the E-CID Measurement Quantities and E-CID Measurement
    ...        supervision timer expired activation configuration is updated at NRCELL level.
    ...    2. Test Case Steps:
    ...      1) setup SA call for UE1 sucessfully.
    ...      2) delay 3s to send MR.
    ...      3) egate trigger "E-CID Measurement Initiation request" containing Measurement Quantity requested:SS-RSRP and SS-RSRQ
    ...         and Tadv from LMF to UE1.
    ...      4) gNB response E-CID MEASUREMENT INITIATION RESPONSE with NR-TADV value and Cell-ID filled
    [Tags]     owner-lishuo.geng
    OnlineParamChange    ${9842_enable}
    SA UE attach with single PDU
    Delay Measurement Report from UE
    trigger E-CID Measurement Initiation request    meas_qty=SS-RSRP,SS-RSRQ,NR_Timing_Advance
    Recover Measurement Report from UE
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}A2A_A015${/}a2a.ini    wait_string=UEContextReleaseComplete::8

CB009842-SR-A-B3_ET_10_01_Verify that E-CID Measurement is terminated by the gNB-CU-CP when UE Inactivity is detected by the gNB-CU-CP
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:Verify that E-CID Measurement is terminated
    ...       by the gNB-CU-CP when UE Inactivity is detected by the gNB-CU-CP
    ...    2. Test Case Steps:
    ...      1) setup SA call for UE1 sucessfully.
    ...      2) delay 2s to send MR.
    ...      3) UE-1: LMF trigger "E-CID Measurement Initiation request" with measurementQuantitiesValue: NR Timing Advance and sS-RSRP,
    ...         ReportCharacteristics: onDemand
    ...      4) gNB-CU-CP received E1AP: BearerContextInactivityNotification from gNB-CU-UP after inactivity timer (1s)expired
    ...      5) gNB-CU-CP stops the "E-CID Measurement supervision timer",
    ...         forms "E-CID MEASUREMENT INITIATION FAILURE (RNL Cause = "Requested Item Temporarily not Available") to the LMF.
    ...        Then UE release
    [Tags]    owner-xu.wang
    [setup]    Common Test Setup And Start To Capture Logs
    OnlineParamChange    ${A-B3_ET_10_01}
    SA UE attach with single PDU    sleep_time=0
    Delay Measurement Report from UE    delay=2000
    trigger E-CID Measurement Initiation request    meas_qty=SS-RSRP,NR_Timing_Advance    pass_regexp=${ECID_failure_and_UE_Inactivity}
    Check Wireshark Log    ${CURDIR}${/}A2A_A010${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    [teardown]    Teardown for A-B3_ET_10_01


*** Keywords ***
Common Suite Setup And Setup Airphone Env And IP added for simGNB
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri_2N77_AEQU_AEQK

Common Test Setup And Start To Capture Logs And start TCE
    Common Test Setup And Start To Capture Logs
    Start TCE    ${TCE_PORT}

Teardown for A-B3_ET_10_01
    onlineparamchange    ${A-B3_ET_10_01_recover}
    Common Test Teardown And Stop Capture Logs

Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh

trigger E-CID Measurement Initiation request then UE CONTEXT MODIFICATION REQUIRED with the cause indicating the RL Failure
    [Arguments]    ${ue_id}=1    ${tid}=1
    ${cmd}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=${tid} lmf_ue_measurement_id=${tid}
    ...    report_characteristics=OnDemand meas_qty=SS-RSRP,NR_Timing_Advance
    ${cmd1}    Catenate    rlf_testmode_nr profile_id=1 num_stop_csi_report=200 num_stop_dlharq_tx=100
    ${uctmr_cmd}    Catenate    ue_testmode_set_nr id=${ue_id} testmode=rlf action=activate profile_id=1
    Execute Egate Command    ${cmd1}
    Execute Egate Command    ${cmd}    pass_regexp=saved periodic meas report will be sent after 8000 ms with MeasId
    ${ret1}=    Execute Egate Command    ${uctmr_cmd}    pass_regexp=UE Context Release Complete

SA UE attach with single PDU for SBA trace
    [Arguments]    ${ue_id}=1    ${target_cells}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    ${command}    Catenate    amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=on
    ...    trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1 trace_depth=medium ifaces_to_trace=Uu,NG-C,Xn-C tce_ip=${TCE_IP}
    Execute Egate Command    ${command}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful

case8_teardown
    Rlf recover to deactive
    Common Test Teardown And Stop Capture Logs

UE Deregister From gNB For SBA
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ng_ue_trace_stop id=${ue_id} trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached    timeout=10s

Delay Measurement Report from UE
    [Arguments]    ${ue_id}=1    ${delay}=8000
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=${delay} srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report

Recover Measurement Report from UE
    [Arguments]    ${ue_id}=1
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=0 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report

Rlf recover to deactive
    Execute Egate Command    rlf_testmode_nr profile_id=1 num_stop_csi_report=200 num_stop_dlharq_tx=100
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=rlf action=deactivate profile_id=1

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

trigger E-CID Measurement Initiation request
    [Arguments]    ${ue_id}=1    ${meas_qty}=SS-RSRP    ${tid}=1    ${pass_regexp}=Received ECID Measurement Response
    ${cmd}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=${tid} lmf_ue_measurement_id=${tid}
    ...    report_characteristics=OnDemand meas_qty=${meas_qty}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    sleep    1s    #wait nrEcidMeasSupervisionTimer timeout

Deregister UE And Check Counters And Check Wireshark Log For case001
    UE Deregister From gNB    ue_id=1
    UE Deregister From gNB    ue_id=2
    Check Counters    ${PM_Counters_Check_A01}
    Check Wireshark Log    ${CURDIR}${/}A2A_A001${/}a2a.ini    wait_string=UEContextReleaseComplete::14

SA UE attach with single PDU
    [Arguments]    ${ue_id}=1    ${target_cells}=2    ${sleep_time}=5
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${sleep_time}
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached    timeout=10s

A001_Setup
    Common Test Setup And Start To Capture Logs
    OnlineParamChange    ${9842_disable}
    Clear Counter Files    wait=${False}
