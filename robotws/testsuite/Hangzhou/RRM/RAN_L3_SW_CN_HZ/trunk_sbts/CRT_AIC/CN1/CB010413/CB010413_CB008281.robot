*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_Aic    master_vDU    CRT    vDUCNF00
...    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    SANSA_FS_ECPRI_CMWV_TDD_CPRI_CMWV_FDD    owner-jianfen.shen    release-5G24R3    team-DevHZ5_SG02

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F

${SA_UE_ID_1}    1
${SA_UE_ID_2}    2
@{PARAMS_IN_SCF_CU}
...    @{8281_enable}

@{PARAMS_IN_SCF_DU1}

@{8281_enable}
...    NRCELL:actUlNrEcIdPosMethod=true
...    NRBTS:timerRRCGuard=2000
...    NRBTS:nrEcidMeasSupervisionTimer=2100

@{8281_disable}
...    NRCELL:actUlNrEcIdPosMethod=false

@{PM_Counters_A001}
...    NRCELL-2:NNGCC:${NRPPA_MEASINIT_REQ_D}=6
...    NRCELL-2:NNGCC:${NRPPA_MEASINIT_RESP_D}=4
...    NRCELL-2:NNGCC:${NRPPA_MEASINIT_FAIL_NOTSUP_D}=2

${NRPPA_MEASINIT_FAIL_TMPUNAV_D}    M55125C00027
#Num of UL UE-associated NRPPA transport messages with E-CID measurement initiation failure with cause "Requested Item Temporarily not Available"
#for Reporting Type 'On-Demand' per NR Cell
${NRPPA_MEASINIT_REQ_D}    M55125C00024
#Num of DL UE-associated NRPPA transport messages with E-CID measurement initiation requests for Reporting Type "On-Demand" per NR cell.
${NRPPA_MEASINIT_RESP_D}    M55125C00025
#Num of UL UE-associated NRPPA transport messages with E-CID measurement initiation response for Reporting Type "On-Demand" per NR cell.
${NRPPA_MEASINIT_FAIL_NOTSUP_D}    M55125C00026
#Num of UL UE-associated NRPPA transport messages with E-CID measurement initiation failure with cause "Requested Item not Supported" per NR Cell.

*** Test Cases ***
CB010413_CB008281-ET-A001_A002_A017_verify feature deactivation and active
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       This case is migration from classical case: CB008281-ET-A001_A002_A017_verify feature deactivation and active
    ...       A001 : feature activation configuration parameters for "UL NR-ECID positioning method" and verify that feature
    ...       activation configuration is updated at NRCELL level.
    ...       A002 : Successful E-CID Measurement Reporting for On-Demand Request .
    ...       A017 :US B7: Verify the handling of un-supported measurement quantities received in the E-CID MEASUREMENT INITIATION REQUEST from LMF.
    ...    2. Test Case Steps:
    ...      1). setup SA call for UE1 and UE2 sucessfully.
    ...      2). egate trigger "E-CID Measurement Initiation request" only containing Measurement Quantity requested: cell-id from LMF to UE1.
    ...          E-CID MEASUREMENT INTIATION REQUEST(s) are accepted by the gNB-CU-CP for Report Characteristics set to 'On-Demand',gNB-CU-CP
    ...          initiates E-CID MEASUREMENT INITIATION RESPONSE to LMF, the gNB-CU-CP clears the E-CID Measurement Context.
    ...      3). egate trigger "E-CID Measurement Initiation request" containing Measurement Quantity requested:"SS-RSRP" from LMF to UE1.
    ...          E-CID MEASUREMENT INTIATION REQUEST(s) are accepted by the gNB-CU-CP for Report Characteristics set to 'On-Demand',
    ...          gNB-CU-CP initiates the Intra-NR Intra-Frequency Periodic measurement configuration by RRCReconfiguration message.
    ...          simUE1 send MeasurementReport(with MeasQuantityResults containing rsrp) includes both the Serving cell and
    ...          Neighbour Cell Measurements.gNB-CU-CP stops timer 'E-CID Measurement supervision timer', forms the E-CID MEASUREMENT INITIATION
    ...          RESPONSE with E-CID Measurement Result(with Measured Results containing "Result SS-RSRP" and send it to LMF node.
    ...          On Successful initiation of E-CID MEASUREMENT INITIATION RESPONSE to LMF, the gNB-CU-CP clears the E-CID Measurement Context.
    ...      4). egate trigger "E-CID Measurement Initiation request" containing Measurement Quantity requested:"SS-RSRQ" from LMF to UE1.
    ...          E-CID MEASUREMENT INTIATION REQUEST(s) are accepted by the gNB-CU-CP for Report Characteristics set to 'On-Demand',
    ...          gNB-CU-CP initiates the Intra-NR Intra-Frequency Periodic measurement configuration by RRCReconfiguration message.
    ...          simUE1 send MeasurementReport(with MeasQuantityResults containing rsrp) includes both the Serving cell and
    ...          Neighbour Cell Measurements.gNB-CU-CP stops timer 'E-CID Measurement supervision timer', forms the E-CID MEASUREMENT INITIATION
    ...          RESPONSE with E-CID Measurement Result(with Measured Results containing "Result SS-RSRP" and send it to LMF node.
    ...          On Successful initiation of E-CID MEASUREMENT INITIATION RESPONSE to LMF, the gNB-CU-CP clears the E-CID Measurement Context.
    ...      5).set NRBTS/NRCELL/actUlNrEcIdPosMethod = False,The feature CB008281-A is deactivated,and cells are operating. egate trigger
    ...         "E-CID Measurement Initiation request" from LMF to UE2. gNB-CU-CP identifies the feature CB008281 is not activated
    ...          and forms E-CID MEASUREMENT INITIATION FAILURE(RNL Cause = "Requested Item Not Supported") and send it to the LMF.
    ...      6) set NRBTS/NRCELL/actUlNrEcIdPosMethod = True,egate trigger "E-CID Measurement Initiation request" containing
    ...         Measurement Quantity requested:SS-RSRP and Timing_Advance_Type_1(not supported) from LMF to UE2.
    ...          gNB-CU-CP initiates the Intra-NR Intra-Frequency Periodic measurement configuration by RRCReconfiguration message.
    ...          simUE1 send MeasurementReport(with MeasQuantityResults containing rsrp) includes both the Serving cell and
    ...          Neighbour Cell Measurements.gNB-CU-CP stops timer 'E-CID Measurement supervision timer', forms the E-CID MEASUREMENT INITIATION
    ...          RESPONSE with E-CID Measurement Result(with Measured Results containing "Result SS-RSRP" and send it to LMF node.
    ...          On Successful initiation of E-CID MEASUREMENT INITIATION RESPONSE to LMF, the gNB-CU-CP clears the E-CID Measurement Context.
    ...      7). egate trigger "E-CID Measurement Initiation request" containing Measurement Quantity requested:NR_Angle_of_Arrival.
    ...         gNB-CU-CP identifies meas_qty not supported,and forms E-CID MEASUREMENT INITIATION FAILURE
    ...         (RNL Cause = "Requested Item Not Supported") and send it to the LMF.
    ...      8). Deregister all ue and check counter.
    [Tags]     QC_347871
    Clear Counter Files Cu Aic    wait=False
    SA UE attach with single PDU    ue_id=${SA_UE_ID_1}
    SA UE attach with single PDU    ue_id=${SA_UE_ID_2}
    trigger E-CID Measurement Initiation request    ue_id=${SA_UE_ID_1}    meas_qty=Cell-ID
    trigger E-CID Measurement Initiation request    ue_id=${SA_UE_ID_1}    tid=2
    trigger E-CID Measurement Initiation request    ue_id=${SA_UE_ID_1}    tid=3    meas_qty=SS-RSRQ
    OnlineParamChangeCU    ${8281_disable}
    trigger E-CID Measurement Initiation request    ue_id=${SA_UE_ID_2}    pass_regexp=Received ECID Measurement Failure
    OnlineParamChangeCU    ${8281_enable}
    trigger E-CID Measurement Initiation request    ue_id=${SA_UE_ID_2}    tid=2    meas_qty=SS-RSRP,Timing_Advance_Type_1
    trigger E-CID Measurement Initiation request    ue_id=${SA_UE_ID_1}    tid=4    meas_qty=NR_Angle_of_Arrival
    ...    pass_regexp=Received ECID Measurement Failure
    UE Deregister From gNB    ue_id=${SA_UE_ID_1}
    UE Deregister From gNB    ue_id=${SA_UE_ID_2}
    Check WireShark Log Aic    ${CURDIR}${/}A2A_8281${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    Check Counters Cu Aic    ${PM_Counters_A001}
    [Teardown]    A001_Teardown

*** Keywords ***
Modify Cfg Aic
    Update Cfg Aic    set_lmf id=1 daemon=$SERVER_IP:$EDAEMON_PORT nfId=abcdef01234567gh

A001_Teardown
    OnlineParamChangeCU    ${8281_enable}
    Common Test Teardown And Stop Capture Logs Aic

OnlineParamChangeCU
    [Arguments]    ${Online_Param}
    Delta Commission Parameters Cu    ${Online_Param}
    Cells Should Be Onair Du

UE attach cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table

Trigger E-CID and RRCReconfiguration timeout
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=5000
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=1000 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report
    ${cmd1}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=1 lmf_ue_measurement_id=1 report_characteristics=OnDemand
    ...    meas_qty=SS-RSRP,SS-RSRQ
    Execute Egate Command    ${cmd1}    pass_regexp=rrcReconfiguration
    sleep    7s    #wait nrEcidMeasSupervisionTimer timeout

Trigger E-CID and UE ctx release
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=2000
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=3000 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report
    ${cmd1}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=1 lmf_ue_measurement_id=1 report_characteristics=OnDemand
    ...    meas_qty=SS-RSRP,SS-RSRQ
    Execute Egate Command    ${cmd1}    pass_regexp=rrcReconfiguration
    Execute Egate Command    ue_ng_ctx_release id=${ue_id} by=amf cause=NAS_normal_release    pass_regexp=Received UE Context Release Complete
    sleep    7s    #wait nrEcidMeasSupervisionTimer timeout

Send Throuput and check Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    pass_regexp=UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=10 trf_id=2    pass_regexp=UE ${ue_id}: UDP DL
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput for cell    ue_id=1

Verify Throuput for cell
    [Arguments]    ${ue_id}=1    ${dl}=8    ${ul}=8    ${pdu_id}=1
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000 >${dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}
	
SA UE attach with single PDU
    [Arguments]    ${ue_id}=1    ${target_cells}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached    timeout=10s

trigger E-CID Measurement Initiation request
    [Arguments]    ${ue_id}=1    ${meas_qty}=SS-RSRP    ${tid}=1    ${pass_regexp}=Received ECID Measurement Response
    ${cmd}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=${tid} lmf_ue_measurement_id=${tid}
    ...    report_characteristics=OnDemand meas_qty=${meas_qty}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    sleep    1s    #Deregister takes a certain amount of time to guarantee
