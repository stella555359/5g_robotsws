*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-ha.zheng
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008290    release-5G23R1
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{PARAMS_FOR_IODT_ABIO_2T4F}
...    @{same frequency}
...    @{NRREL}
...    @{8290_enable}
...    @{ho}

@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellPrio=1
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=13
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellPrio=2
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=35
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=1
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:lcrId=2
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:fiveGsTac=200
...    NRADJNRCELL-1:freqBandIndicatorNR=41
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=524310
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actHoOptimizationCa=true
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:actRanSharing=false
...    NRCELL:actCDrx=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:actBeamforming=false
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRCELL:cellDepType=SA+NSA

...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=20|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2ThresholdSCellRelSsbRsrp=34|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=60
...    NRCELL-13:weightForSCellSelection=60
...    NRCELL-1:weightForSCellSelection=80
...    NRCELL-2:weightForSCellSelection=80
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=524310
...    MRBTS-1/NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=6549
...    MRBTS-1/NRBTS-1/NRCELL-1:type0CoresetConfigurationIndex=10
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnDl=424000
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnUl=344000
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13:type0CoresetConfigurationIndex=7
...    MRBTS-1/NRBTS-1/NRCELL-13:gscnOrSsPbchArfcn=5300

@{ho}
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min

@{OnlineParamChange_B016}
...    NRBTS-1:actIntraNrNgHo=sourceAndTarget
...    NRBTS-1:tNgRelocExecDeltN=3000
...    NRBTS-1:tNgRelocPrepN=2000
...    NRBTS-1:tNgRelocOverallN=2000
...    NRBTS-1:tNgRelocCancelN =2000
...    NRCELL-1/NRREL-2:handoverAllowedSA=XnHoNotAllowed

@{OnlineParam_B016_recover}
...    NRBTS-1:actIntraNrNgHo=disabled
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed

@{Result_B012}
...    rrcReconfigurationComplete
...    pcid:51, scellIdx:2
...    SCellIndex 2 activated successfully

@{Result_B016}
...    rrcReconfigurationComplete
...    pcid:51, scellIdx:2
...    SCellIndex 2 activated successfully

${pdu_id}    1
${gw_id}    1
${nwslice}    1

*** Test Cases ***
CB008290-ET-B012_Verify_A6_configured_successfully_after_intra_freq_inter_gnb_ho_in_and_scell_auto_added
    [Documentation]
    ...    1. This user scenario describes the successful configuration of A6 measurement for the purpose of SCell swap
    ...       for FR1 CA UE in SA mode when UE joins a cell via incoming handover and the A1 criteria for SCell addition
    ...       is satisfied. A1 measurement on UE is skipped and SCell is added immediately on target cell.
    ...    2. Configuration:
    ...       FDD Cell11/Cell13 configure to same frequency. NRADJGNB/NRADJNRCELL have some Frequency with NRCELL-1.
    ...       cell1-cell2, cell1-cell11, cell1-cell13
    ...    3. Test Case Steps:
    ...       1). UE registers successfully and PDU session is setup successfully on cell 1, Start UL/DL data.
    ...           A1 meas for scell addition configured, mobility A3 configured, DRX setup.
    ...           DL/UL throughput on TDD PCell can reach the expected value.
    ...       2). A3 for mobility measurement report from 5G-UE.
    ...           inter gnb intra frequency handover to sim gnb NRADJNRCELL-1 successfully
    ...       3). A3 for mobility measurement report from 5G-UE, rsrp lower than a1ThresholdSCellAddSsbRsrpTDD,
    ...           higher than a1ThresholdSCellAddSsbRsrpFDD
    ...           inter gnb intra frequency handover from sim gnb NRADJNRCELL-1 to cell1 successfully
    ...           cell 11 added as scell, A6 configured for scell swap , A1 configured for scell change ,
    ...           A2 configured for scell released, A3 configured for intraFreHO
    ...       4). A1 for scell change measurement report from 5G-UE, rsrp higher than a1ThresholdSCellAddSsbRsrpTDD
    ...           SCell change to higher priority TDD cell2 successfully, A6/A1 released
    ...       5). A2 for scell release measurement report from 5G-UE,
    ...           scell release successfully
    ...       6).release UE
    ...           UE release successfully
    [Tags]    QC_47048    owner-ha.zheng    B012
    Set UE Parameters Before Register
    UE Attach To Target Cell
    trigger A3 intra ferquency inter gnb ho to sim gnb
    trigger A3 intra ferquency inter gnb ho to real gnb
    Trigger ScellAdd or ScellChange    ${Result_B012}    phycell_id=51    srsrp_nr=91    scell_id=2
    trigger A2 Scell Release    scell_id=2
    UE Deregister From gNB
#    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B012${/}a2a.ini    wait_string=UEContextReleaseComplete::6

CB008290-ET-B016_Verify_A6_configured_successfully_after_NG_ho_in_and_scell_auto_added
    [Documentation]
    ...    1. This user scenario describes the successful configuration of A6 measurement for the purpose of SCell swap
    ...       for FR1 CA UE in SA mode when UE joins a cell via incoming handover and the A1 criteria for SCell addition
    ...       is satisfied. A1 measurement on UE is skipped and SCell is added immediately on target cell.
    ...    2. Configuration:
    ...       FDD Cell11/Cell13 configure to same frequency. NRADJGNB/NRADJNRCELL have some Frequency with NRCELL-1.
    ...       cell1-cell2, cell1-cell11, cell1-cell13
    ...    3. Test Case Steps:
    ...       1). UE registers successfully and PDU session is setup successfully on cell 1, Start UL/DL data.
    ...           A1 meas for scell addition configured, mobility A3 configured, DRX setup.
    ...           DL/UL throughput on TDD PCell can reach the expected value.
    ...       2). A3 for mobility measurement report from 5G-UE.
    ...           inter gnb intra frequency handover through ng to sim gnb NRADJNRCELL-1 successfully
    ...       3). A3 for mobility measurement report from 5G-UE, rsrp lower than a1ThresholdSCellAddSsbRsrpTDD,
    ...           higher than a1ThresholdSCellAddSsbRsrpFDD
    ...           inter gnb intra frequency handover through ng from sim gnb NRADJNRCELL-1 to cell1 successfully
    ...           cell 11 added as scell, A6 configured for scell swap , A1 configured for scell change ,
    ...           A2 configured for scell released, A3 configured for intraFreHO
    ...       4). A1 for scell change measurement report from 5G-UE, rsrp higher than a1ThresholdSCellAddSsbRsrpTDD
    ...           SCell change to higher priority TDD cell2 successfully, A6/A1 released
    ...       5). A2 for scell release measurement report from 5G-UE,
    ...           scell release successfully
    ...       6).release UE
    ...           UE release successfully
    [Tags]    QC_47046    owner-ha.zheng    B016
    OnlineParamChange    ${OnlineParamChange_B016}
    Set UE Parameters Before Register    send_xn_setup=false    ho_type=ng_based
    UE Attach To Target Cell
    trigger A3 intra ferquency inter gnb ho to sim gnb
    trigger A3 intra ferquency inter gnb ho to real gnb
    Trigger ScellAdd or ScellChange    ${Result_B016}    phycell_id=51    srsrp_nr=91    scell_id=2
    trigger A2 Scell Release    scell_id=2
    UE Deregister From gNB
#    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B016${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    [Teardown]    B016_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Modify Cfg
    ${gnb3_cell1}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01
    ...    tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=524310:524310 gscn=6549 mandatory_for_activation=off
   Update Cfg    ${gnb3_cell1}

B016_Teardown
    OnlineParamChange    ${OnlineParam_B016_recover}
    Common Test Teardown And Stop Capture Logs

Set UE Parameters Before Register
    [Arguments]    ${send_xn_setup}=true    ${ho_type}=xn_based
    Execute Egate Command    ue_history_information_list id=1 action=reset
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=81 ue_history_list=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=${send_xn_setup} sa_ho=${ho_type}
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    #build XN setup
    Execute Egate Command    ue_gnb_param id=81 candidate_cells_hex_for_interrat_ho=0B1FFAB95F571630684325A3C7

UE Attach To Target Cell
    [Arguments]    ${cell_id}=1    ${ue_id}=81    ${pcell_dl}=610
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    Should Contain    ${ret1}    drx-Config setup
    Send Throuput
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=8
    sleep    10s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pcell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=10    ${scell_dl}=10    ${ul}=8    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger ScellAdd or ScellChange
    [Arguments]    ${Result}    ${event_type}=A1    ${carrierfreq}=523950    ${srsrp_nr}=80    ${srsrq_nr}=50    ${ue_id}=81
    ...    ${pcell_dl}=500    ${scell_dl}=400    ${scell_id}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${Result}
    Verify Throuput on Pcell and Scell    pcell_dl=${pcell_dl}    scell_dl=${scell_dl}    scell_id=${scell_id}

trigger A3 intra ferquency inter gnb ho to sim gnb
    [Arguments]    ${event_type}=A3    ${carrierfreq}=523950    ${srsrp_nr}=11    ${srsrq_nr}=11    ${ue_id}=81
    ...    ${nrsrp_nr}=61    ${nrsrq_nr}=61    ${source_gnb}=EXT_ENB-2    ${target_gnb}=ENB-3
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr} phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    Inter-eNB handover from ${source_gnb}.1 to ${target_gnb}.1 performed

trigger A3 intra ferquency inter gnb ho to real gnb
    [Arguments]    ${event_type}=A3    ${carrierfreq}=523950    ${srsrp_nr}=11    ${srsrq_nr}=11    ${ue_id}=81
    ...    ${phycell_id}=50    ${nrsrp_nr}=71    ${nrsrq_nr}=71    ${source_gnb}=ENB-3    ${target_gnb}=EXT_ENB-2
    ...    ${pcell_dl}=300    ${scell_dl}=65    ${scell_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr} phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}
    ...    pass_regexp=drx-Config setup
    Should Contain    ${ret1}    Inter-eNB handover from ${source_gnb}.1 to ${target_gnb}.1 performed
    Should Contain    ${ret1}    physCellId 60
    Verify Throuput on Pcell and Scell    pcell_dl=${pcell_dl}    scell_dl=${scell_dl}    scell_id=${scell_id}

trigger A2 Scell Release
    [Arguments]    ${event_type}=A2    ${carrierfreq}=633216    ${srsrp_nr}=7    ${srsrq_nr}=7    ${ue_id}=81    ${scell_id}=2
    ...    ${pcell_dl}=610
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} scell=${scell_id}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}






