*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env And IP added for simGNB
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CxT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-Blues_SGT&A    owner-zora.wang    owner-christine.chen    release-5G23R4     CB008281
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{8281_enable}

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

@{OnlineParam_A008_changeEcidMeasSupervisionTimer}
...    NRBTS:nrEcidMeasSupervisionTimer=6000
...    NRBTS:actIntraFreqHoSA=true
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a5MeasEnabled=none
...    NRBTS/NRPMRNL-1:miNrRelReportCu=15min

@{OnlineParam_A008_recovery_changeEcidMeasSupervisionTimer}
...    NRBTS:nrEcidMeasSupervisionTimer=2100
...    NRBTS:actIntraFreqHoSA=false
...    NRBTS/NRPMRNL-1:miNrRelReportCu=disabled

@{OnlineParam_A014_changetimerRRCGuard}
...    NRBTS:timerRRCGuard=5000
...    NRBTS:nrEcidMeasSupervisionTimer=6000
...    NRBTS:actIntraFreqHoSA=true
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a5MeasEnabled=none
...    NRBTS/NRPMRNL-1:miNrRelReportCu=15min

@{OnlineParam_A014_recovery_changetimerRRCGuard}
...    NRBTS:timerRRCGuard=2000
...    NRBTS:nrEcidMeasSupervisionTimer=2100
...    NRBTS:actIntraFreqHoSA=false
...    NRBTS/NRPMRNL-1:miNrRelReportCu=disabled

@{relation_for_cell-2}
#...    NRBTS/NRCELL-2/NRREL-1:gNbId=1
#...    NRBTS/NRCELL-2/NRREL-1:gNbIdLength=22
#...    NRBTS/NRCELL-2/NRREL-1:lcrId=1
#...    NRBTS/NRCELL-2/NRREL-1:gnbPlmn:mcc=311
#...    NRBTS/NRCELL-2/NRREL-1:gnbPlmn:mnc=489
#...    NRBTS/NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=653780
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=35
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=true
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3


@{PM_Counters_Check_A008}
...    NRCELL-1:${NRPPA_MEASINIT_FAIL_TMPUNAV_D}=1

@{PM_Counters_Check_A014}
...    NRCELL-1:${NRPPA_MEASINIT_FAIL_TMPUNAV_D}=1

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
CB008281-ET-A001_A002_A017_verify feature deactivation and active
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
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
    [Tags]     QC_302899
    Clear Counter Files    wait=${False}
    SA UE attach with single PDU
    SA UE attach with single PDU    ue_id=2
    trigger E-CID Measurement Initiation request    meas_qty=Cell-ID
    trigger E-CID Measurement Initiation request    tid=2
    trigger E-CID Measurement Initiation request    tid=3    meas_qty=SS-RSRQ
    OnlineParamChange    ${8281_disable}
    trigger E-CID Measurement Initiation request    ue_id=2    pass_regexp=Received ECID Measurement Failure
    OnlineParamChange    ${8281_enable}
    trigger E-CID Measurement Initiation request    ue_id=2    tid=2    meas_qty=SS-RSRP,Timing_Advance_Type_1
    trigger E-CID Measurement Initiation request    tid=4    meas_qty=NR_Angle_of_Arrival    pass_regexp=Received ECID Measurement Failure
    UE Deregister From gNB
    UE Deregister From gNB    ue_id=2
    Check Wireshark Log    ${CURDIR}${/}A2A_A001${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    Check Counters    ${PM_Counters_A001}
    [Teardown]    A001_Teardown

CB008281-ET-A009_Verify that gNB-CU-CP sends E-CID MEASUREMENT INITIATION FAILURE when there is no Measurement Report from UE
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:Verify that gNB-CU-CP sends E-CID MEASUREMENT INITIATION FAILURE
    ...       when there is no Measurement Report from UE for any of the E-CID Measurement Quantities and E-CID Measurement supervision
    ...       timer expired activation configuration is updated at NRCELL level.
    ...    2. Test Case Steps:
    ...      1) setup SA call for UE1 sucessfully.
    ...      2) delay 3s to send MR.
    ...      3) egate trigger "E-CID Measurement Initiation request" containing Measurement Quantity requested:SS-RSRP and SS-RSRQ from LMF to UE1.
    ...      4) UE Deregister From gNB.
    [Tags]     QC_301661    A009
    OnlineParamChange    ${relation_for_cell-2}
	X2 Link for simulated gNB-35
    SA UE attach with single PDU
    set precondition delay Measurement Report from UE    1    3000    381
    trigger E-CID Measurement Initiation request    meas_qty=SS-RSRP,SS-RSRQ    pass_regexp=Received ECID Measurement Failure
	set precondition delay Measurement Report from UE    1    1000    381
    trigger E-CID Measurement Initiation request    meas_qty=SS-RSRP,SS-RSRQ    pass_regexp=Received ECID Measurement Response
    set precondition delay Measurement Report from UE    1    1000    61
    trigger E-CID Measurement Initiation request    meas_qty=SS-RSRP,SS-RSRQ    pass_regexp=Received ECID Measurement Response
    Recover Measurement Report from UE
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}A2A_A009${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008281-ET-A008_Verify that gNB-CU-CP sends E-CID MEASUREMENT INITIATION FAILURE when there is no response from UE for the RRCReconfiguration
    [Documentation]
    ...    1. The purpose of this test case is to check that gNB-CU-CP sends E-CID MEASUREMENT INITIATION FAILURE when there is no response
    ...    from UE for the RRCReconfiguration sent with Measurement configuration.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured actUlNrEcIdPosMethod=true, nrEcidMeasSupervisionTimer=6000, timerRRCGuard=2000
    ...    3. Test Case Steps:
    ...    a. setup SA call
    ...    b. Check DL and UL throughput
    ...    c. LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE set to 'On-Demand' and Measurement Quantity requested is
    ...     'SS-RSRP & SS-RSRQ'. and check no RRCReconfigurationComplete from the UE and RRC Reconfiguration timer expiry event is triggered.
    ...    d. Deregister the ue, check a2a and counter
    [Tags]    QC_302900    christine.chen    A008
    Clear Counter Files
    OnlineParamChange    ${OnlineParam_A008_changeEcidMeasSupervisionTimer}
    UE attach cell    ue_id=1    cell_id=1
    Send Throuput and check Throuput
    Trigger E-CID and RRCReconfiguration timeout
    UE Deregister From gNB    ue_id=1
    Check WireShark Log    ${CURDIR}${/}A2A_A_008${/}a2a.ini    wait_string=UEContextRelease::27
    Check Counters    ${PM_Counters_Check_A008}
    [Teardown]    A008 TestTeardown

CB008281-ET-A014_Verify the termination of E-CID Measurement when UE Context Release Command received before the RRCReconfiguration is sent to UE
    [Documentation]
    ...    1. The purpose of this test case is to check that gNB-CU-CP initiates termination of E-CID MEASUREMENT when UE
    ...    Context Release Command received from AMF.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured actUlNrEcIdPosMethod=true, nrEcidMeasSupervisionTimer=6000, timerRRCGuard=5000
    ...    3. Test Case Steps:
    ...    a. setup SA call
    ...    b. Check DL and UL throughput
    ...    c. LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE set to 'On-Demand' and Measurement Quantity requested
    ...    is 'SS-RSRP & SS-RSRQ', and meanwhile AMF send "NGAP:UE Context Release Command"
    ...    d. Deregister the ue, check a2a and counter
    [Tags]    QC_302901    christine.chen    A014
    Clear Counter Files
    OnlineParamChange    ${OnlineParam_A014_changetimerRRCGuard}
    UE attach cell    ue_id=1    cell_id=1
    Send Throuput and check Throuput
    Trigger E-CID and UE ctx release
    UE Deregister From gNB    ue_id=1
    Check WireShark Log    ${CURDIR}${/}A2A_A_014${/}a2a.ini    wait_string=UEContextRelease::24    
    Check Counters    ${PM_Counters_Check_A014}
    [Teardown]    A014 TestTeardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env And IP added for simGNB
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri_2N77_AEQU_AEQK

Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh
    ${V_1}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666 
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${V_1}
	Update Cfg    gnb_set id=3 s1u=10.0.1.126 plmn=311:489 gnb_id=0x23:22 type=simulated daemon=:22222 x2=10.0.1.126:36422
	
A001_Teardown
    OnlineParamChange    ${8281_enable}
    Common Test Teardown And Stop Capture Logs

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

A014 TestTeardown
    OnlineParamChange    ${OnlineParam_A014_recovery_changetimerRRCGuard}
    Common Test Teardown And Stop Capture Logs

A008 TestTeardown
    OnlineParamChange    ${OnlineParam_A008_recovery_changeEcidMeasSupervisionTimer}
    Common Test Teardown And Stop Capture Logs

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

#set precondition delay Measurement Report from UE
#    [Arguments]    ${ue_id}=1
#    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
#    ...    delay=3000 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
#    Execute Egate Command    ${cmd}    pass_regexp=send this meas report

set precondition delay Measurement Report from UE
    [Arguments]    ${ue_id}=1    ${delay_time}=3000    ${neighbor_cell}=51
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=${delay_time} srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40 phycell_id=${neighbor_cell} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report


Recover Measurement Report from UE
    [Arguments]    ${ue_id}=1
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=0 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report

X2 Link for simulated gNB-35
    Execute Egate Command    enb_x2_link_up enb=1 target=3    
    ...    pass_regexp=is UP
