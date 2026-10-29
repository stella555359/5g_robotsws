*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Test Teardown With Check Log Size
Force Tags    QCD_MN_RAN    QCP_RAN_ET    vDUCNF23R3    RAN_5G    CRT    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD    team-DevHZ5_SG1    owner-tom.li    release-5G23R3
Resource    ../../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F
${GNB_BIP_FLAG}  ${True}
${SOS_REPORT_FLAG}    pass:False,fail:True
${SNAPSHOT_FLAG}     pass:True,fail:True
${TTITRACE_FLAG_CU}  ${True}
${TTITRACE_FLAG_DU1}  ${True}
${AP_BIP_FLAG}  ${True}
${AP_TTITRACE_FLAG}  ${True}

@{PARAMS_IN_SCF_CU}    @{HO}    @{NRREL}    @{SRB3}    @{A3_event}    @{5GC000732}
@{PARAMS_IN_SCF_DU1}    @{DU_NRREL}    @{SSB}

@{5GC000732}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tRLFindForDUSA=2000ms
...    NRBTS:tWaitingRlRecoverSA=4000ms

@{HO}
...    NRBTS-1:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min

...    NRBTS:actConflictConfiguration=true

@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{A3_event}
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:sMeasConfigSsbRsrp=1

@{SRB3}
...    NRBTS-1:srb3SupportEnabled=true
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=3
...    NRBTS-1:cipherPrefL:nea2_128=4
...    NRBTS-1:cipherPrefL:nea3_128=2
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{SSB}
...    NRCELL:cbraPreamblesPerSsb=n60
...    NRCELL:rsrpThresholdSSB=11

@{DU_NRREL}
...    NRCELL/NRREL-1

${ue_id}    31

*** Test Cases ***
CB008926-SR-B-B1_ET_01_07_UE RRC reestablishment successful to different cell in same vDU
    [Tags]
    Set UE Parameters Before Register
    SA UEs ICS
    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=31    target_gnbCell=1
    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=32    target_gnbCell=2
    UE reestablish to cell    ue_id=1    cell_id=2
    Release Ues    ue_type=all

*** Keywords ***
Set UE Parameters Before Register
    set UE history info    ue_id=1    history_id=1
    set UE history info    ue_id=2    history_id=2
    Execute Egate Command    set_pdu_param ue=1,2 pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=1,2 pdu=2 trf_type=internal
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true sib1_period=3000
    Execute Egate Command    enb_x2_link_up enb=1 target=2    pass_regexp=is up
    Execute Egate Command    gnb_param id=2 sa_ho=ng_based
    Execute Egate Command    trace_sim amf=1 on

set UE history info
    [Arguments]    ${ue_id}=1    ${history_id}=1
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=${history_id} action=commit
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=${history_id}

NSA UE ICS and setup ENDC to TargetGnbCell
    [Arguments]    ${ue_id}    ${target_gnbCell}
    UE Attach To ENB    ${ue_id}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_gnbCell} bearer=2 type=split_scg
    ...    pass_regexp=reported successful RA
    Execute Egate Command    ue_disp

Register For Normal Call and create PDU Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    [return]    ${AMF_UE_NGAP_ID_UE}    ${RAN_UE_NGAP_ID_UE}
    Register For Normal Call Successfully    ${ue_id}    ${cell_id}
    ${AMF_UE_NGAP_ID_UE}    ${RAN_UE_NGAP_ID_UE}    UE PDU Session Setup    ${ue_id}    ${ue_id}

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${gw_id}=1
    [return]    ${AMF_UE_NGAP_ID_UE[0]}    ${RAN_UE_NGAP_ID_UE[0]}
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table
    ${AMF_UE_NGAP_ID_UE}    Get Regexp Matches    ${ret1}    value AMF-UE-NGAP-ID : (\\d+)    1
    ${RAN_UE_NGAP_ID_UE}    Get Regexp Matches    ${ret1}    value RAN-UE-NGAP-ID : (\\d+)    1

UE Attach To ENB
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE

Register For Normal Call Successfully
    [Arguments]    ${ue_id}    ${cell_id}    ${enb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    UE Register To GNB    ${ue_id}

Modify UE Establishemnt Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}

UE Register To GNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg

UE reestablish to cell
    [Arguments]    ${ue_id}    ${cell_id}=1
    ${expect_output}    Create List
    ...    UE1: NR RRC Reestablishment suc
    ...    message c1 : rrcReconfigurationComplete
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id}    pass_regexp=${expect_output}

SA UEs ICS
    Register For Normal Call and create PDU Successfully    ue_id=1    cell_id=1
    Register For Normal Call and create PDU Successfully    ue_id=2    cell_id=1
    Register For Normal Call and create PDU Successfully    ue_id=3    cell_id=2
    Register For Normal Call and create PDU Successfully    ue_id=4    cell_id=2

Test Teardown With Check Log Size
    Run Keyword And Ignore Error  Run Keyword Unless  ${GNB_IQ_DATA_FLAG} is ${False}
    ...  Run Keyword If  '${IQ_DU_ID}'=='1'  Collect Iq Data Vdu1  ${IQ_DATALINK}  ${VDU_NAMESPACE}
    ...  ELSE  Collect Iq Data Vdu${IQ_DU_ID}  ${IQ_DATALINK}  ${VDU${IQ_DU_ID}_NAMESPACE}
    Run Keyword And Ignore Error  Run Keyword If  ${AP_IQ_DATA_FLAG} is ${True}  Capture Ap IQ Data
    Release Ues  ue_type=all
    Sleep  10s  # make sure UE release procedure finished
    Run Keyword If  ${RESOURCES_LEAKAGE_FLAG} is ${True}  Check Resources Leakage Aic
    Check No New Active Faults
    Common Test Teardown Aic
    Run Keyword If Test Failed  Set Test Variable  ${SOS_REPORT_FLAG_WORK}  ${SOS_REPORT_FLAG_DIC['fail']}
    Run Keyword If Test Passed  Set Test Variable  ${SOS_REPORT_FLAG_WORK}  ${SOS_REPORT_FLAG_DIC['pass']}
    Set Suite Variable  ${SOS_REPORT_FLAG_WORK}
    Stop Capture Logs Aic
    Stop RRC Log Aic
    Run Keyword And Ignore Error  _Copy Config Files To Log Dir Aic
    ## Analyze Logs need further adapt later***
    Analyze Logs  test_status=${TEST_STATUS}
    ${l1up_size}     Execute Cmd On Pc  ls -l ${SAVE LOG DIRECTORY}/gnb_bip_logs | grep l1up |awk {'print $5'}
    ${l2biphi_size}    Execute Cmd On Pc  ls -l ${SAVE LOG DIRECTORY}/gnb_bip_logs | grep l2biphi |awk {'print $5'}
    ${ttitrace_du_size}     Execute Cmd On Pc  ls -l ${SAVE LOG DIRECTORY}/du_ttitrace | grep ttitrace_du.pcap0$ |awk {'print $5'}
    ${emil_size}    Execute Cmd On Pc  ls -l ${SAVE LOG DIRECTORY}/emil_log_cu | grep results.zip |awk {'print $5'}    
    ${ap_bip_size}    Execute Cmd On Pc  ls -l ${SAVE LOG DIRECTORY}/ap_bip_logs | grep ap_bip_filtering_off.pcap0$ |awk {'print $5'}  
    #Should Be True    ${l1up_size}>5000000
    #Should Be True    ${l2biphi_size}>200000
    #Should Be True    ${ttitrace_du_size}>3000000
    #Should Be True    ${emil_size}>300000
    #Should Be True    ${ap_bip_size}>5000000
    Run Keyword And Ignore Error  Run Keyword If  '${REMOVE_LOGS}'=='on'  Run Keyword If Test Passed
    ...  Remove Directory  ${SAVE LOG DIRECTORY}  ${True}
    Run Keyword If  '${REMOVE_LOGS}'=='off'  Compress Directory Aic  ${SAVE LOG DIRECTORY}