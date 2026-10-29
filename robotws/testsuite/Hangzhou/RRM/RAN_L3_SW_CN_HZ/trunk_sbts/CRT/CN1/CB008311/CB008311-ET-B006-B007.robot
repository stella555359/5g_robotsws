*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-sherry.zhang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008311    release-5G23R3
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    pass:True,fail:True
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa
...    @{PARAMS_FOR_IODT_ABIO_2T4F}
...    @{same frequency}
...    @{NRREL}
...    @{CA_enable}
...    @{8311_enable}

@{NRREL}
#NRRELL for case06 cell12 and cell2
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:lcrId=2
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12:a1MeasSCellAddEnabled=rsrqCombined
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=35
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=35
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-12:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=4
...    NRCELL-12:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=40
...    NRCELL-12:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=80ms
...    NRCELL-2:a2MeasSCellRelEnabled=rsrqCombined
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2ThresholdSCellRelSsbRsrp=48|a2TimeToTriggerSCellRelSsbRsrp=80ms
...    NRCELL-2:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2ThresholdSCellRelSsbRsrq=60|a2TimeToTriggerSCellRelSsbRsrq=80ms
#NRRELL for case07 cell2 and cell11
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2:a1MeasSCellAddEnabled=rsrqCombined
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=35
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=35
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-2:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=4
...    NRCELL-2:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=40
...    NRCELL-2:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=80ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrqCombined
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2ThresholdSCellRelSsbRsrp=48|a2TimeToTriggerSCellRelSsbRsrp=80ms
...    NRCELL-11:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2ThresholdSCellRelSsbRsrq=60|a2TimeToTriggerSCellRelSsbRsrq=80ms

@{8311_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1

@{8311_disable}
...    NRBTS:actBufferBasedSCellAddition=disabled

@{CA_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actHoOptimizationCa=true
...    NRBTS-1:actRanSharing=false
...    NRCELL:actCDrx=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:actBeamforming=false
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=20|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:dlSCellConfigLevel=2
...    NRCELL:dlSCellConfigLevelNum=5

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

@{parameter_B007}
...    NRCELL-2:dlSCellConfigLevel=50
...    NRCELL-2:dlSCellConfigLevelNum=200

@{parameter_B007_recover}
...    NRCELL-2:dlSCellConfigLevel=2
...    NRCELL-2:dlSCellConfigLevelNum=5

@{A2_Realse}
...    Successfully reconfigured dual connectivity
...    Sending SgNB Modification Confirm
...    sCellToReleaseList

*** Test Cases ***
CB008311-ET-B006_2CC_FT_NSA_Online parameter modification_Buffer-based one shot SCell Addition feature activation_deactivation
    [Documentation]
    ...    1. This user scenario describes the successful feature flag Online modification Buffer-based one shot SCell Addition with
    ...       covbasedA1 SCell Addition Method.
    ...    2. Configuration:
    ...       cell12-cell2
    ...    3. Test Case Steps:
    ...       1). UE91 attaches to the LTE cell and initiates EN-DC toward the FDD NR cell12, sends A1 MR with Entry condition for SCell Addition
    ...           High DL data rate starts for UE91 and buffer overflow happens at DU, UE91 in CA status.
    ...           UE92 attaches to the LTE cell and initiates EN-DC toward the FDD NR cell12, sends A1 MR with Entry condition for SCell Addition
    ...           High DL data rate starts for UE92 and buffer overflow happens at DU, UE92 in CA status.
    ...       2). Operator online reconfigures NRBTS.actBufferBasedSCellAddition= disabled and new parameters committed.
    ...           Trigger A2 based SCell release procedure for UE91 and completes successfully.
    ...           Trigger A1 MR with Entry condition for UE91 for SCell Addition and gnb configured TDD Cell2 as scell to UE91.
    ...           Here gNB-CU will not performs DL buffer monitoring activation since actBufferBasedSCellAddition= disabled.
    ...       3). Operator online reconfigures NRBTS.actBufferBasedSCellAddition= oneShot_Dl_Fr1 and new parameters committed.
    ...           Trigger A2 based SCell release procedure for UE91 and completes successfully.
    ...           Trigger A2 based SCell release procedure for UE92 and completes successfully.
    ...       4). Trigger A1 MR with Entry condition for UE91 for SCell Addition.
    ...           CU sends a private unacknowledged F1AP message to DU to activate DL data buffer monitoring,when DL buffer overflows
    ...           and cannot be drained by serving cell, DU sends private unacknowledged F1AP message to CU to inform CU DL buffer overflow
    ...           condition. DU stops DL data buffer monitoring. gNB configures TDD Cell2 as scell to the UE91.
    ...       5). Stop traffic on UE92 and trigger A1 MR with Entry condition.
    ...           CU sends a private unacknowledged F1AP message to DU to activate DL data buffer monitoring. DU don't sends private unacknowledged
    ...           F1AP message to CU to inform CU DL buffer overflow since here is no traffic and sell addition will not performed.
    ...       6). Trigger A1 MR with leaving condition for UE92 and Start traffic.
    ...           CU sends a private unacknowledged F1AP message to DU to deactivate DL data buffer monitoring,UE92 not have CA configured.
    [Tags]    QC_279042    owner-sherry.zhang    B006    CA_LABEL-FT(15MHz_FDD_n71+50MHz_TDD_n78)
    Step1 NSA UEs in CA status
    Step2 online disable actBufferBasedSCellAddition
    Step3 online enable actBufferBasedSCellAddition
    Step4 Trigger A1 MR for UE91 for SCell Addition
    Step5 Stop traffic on UE92 and trigger A1 MR for SCell Addition
    Step6 Trigger A1 MR with leaving condition and Start traffic on UE92
    UE Detach From gNB    ue_id=91
    UE Detach From gNB    ue_id=92
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008311B006${/}a2a.ini    wait_string=UEContextReleaseComplete::2
    [Teardown]    B006_Teardown

CB008311-ET-B007_2CC_TF_NSA_Online parameter modification dlSCellConfigLevel and dlSCellConfigLevelNum
    [Documentation]
    ...    1. This user scenario describes the successful dlSCellConfigLevel and dlSCellConfigLevelNum Online modification
    ...       Buffer-based one shot SCell Addition with covbasedA1 SCell Addition.
    ...    2. Configuration:
    ...       cell2-cell11
    ...    3. Test Case Steps:
    ...       1). UE91 attaches to the LTE cell and initiates EN-DC toward the FDD NR cell2, A1 MR for SCell addition is configured.
    ...           Trigger A1 MR with Entry condition for UE91 for SCell Addition, A2 MR for SCell release is configured.
    ...           CU sends a private unacknowledged F1AP message to DU to activate DL data buffer monitoring.
    ...           High DL data rate starts for UE91 and DU sends private unacknowledged F1AP message to CU to inform CU DL buffer overflow
    ...           condition. DU stops DL data buffer monitoring. gNB configures FDD Cell11 as scell to the UE91.
    ...       2). Operator online reconfigures dlSCellConfigLevel=50 and dlSCellConfigLevelNum=200 and new parameters committed.
    ...           Trigger A2 based SCell release procedure for UE91 and completes successfully.
    ...           Trigger A1 MR with Entry condition for UE91 for SCell Addition.
    ...           CU sends a private unacknowledged F1AP message to DU to activate DL data buffer monitoring, With the higher dlSCellConfigLevel
    ...           and dlSConfigLevelNum parameters, the PCell throughput is sufficient to keep, DU not sends private unacknowledged F1AP message
    ...           to CU to inform CU DL buffer overflow, UE91 not in CA status.
    ...       3). Operator online reconfigures dlSCellConfigLevel=2 and dlSCellConfigLevelNum=5 and new parameters committed.
    ...           Trigger A1 MR with leaving condition for UE91 to imform L2PS to stop buffer monitoring, since PS will take new dlSCellConfigLevel
    ...           and dlSCellConfigLevelNum value in new DLBufferMonitoringInd:start.
    ...           Trigger A1 MR with Entry condition for UE91 for SCell Addition.
    ...           CU sends a new private unacknowledged F1AP message to DU to activate DL data buffer monitoring and update dlSCellConfigLevel
    ...           and dlSConfigLevelNum parameters. With the lower dlSCellConfigLevel and dlSConfigLevelNum parameters, the PCell throughput is
    ...           not sufficient to keep, DU sends private unacknowledged F1AP message to CU to inform CU DL buffer overflow, DU stops DL data
    ...           buffer monitoring. gNB configures FDD Cell11 as scell to the UE91.
    [Tags]    QC_279040    owner-sherry.zhang    B007    CA_LABEL-TF(50MHz_TDD_n78+10MHz_FDD_n66)
    Step1 UE91 in CA status
    Step2 online reconfigure dlSCellConfigLevel and dlSCellConfigLevelNum to bigger value
    Step3 online recover dlSCellConfigLevel and dlSCellConfigLevelNum
    UE Detach From gNB    ue_id=91
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008311B007${/}a2a.ini    wait_string=UEContextReleaseComplete::1
    [Teardown]    B007_Teardown

*** Keywords ***
Test Teardown
    UE Detach From gNB

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

B006_Teardown
    OnlineParamChange    ${8311_enable}
    Common Test Teardown And Stop Capture Logs

B007_Teardown
    OnlineParamChange    ${parameter_B007_recover}
    Common Test Teardown And Stop Capture Logs

Step1 NSA UEs in CA status
    NSA UE Attach To Target Cell    cell_id=12    ue_id=91
    Trigger A1 MR    carrierfreq=126750    srsrp_nr=37    srsrq_nr=46    ue_id=91
    Send Throuput For NSA    ue_id=91
    Verify Throuput on Pscell and Scell For NSA    ue_id=91
    NSA UE Attach To Target Cell    cell_id=12    ue_id=92
    Trigger A1 MR    carrierfreq=126750    srsrp_nr=37    srsrq_nr=46    ue_id=92
    Send Throuput For NSA    ue_id=92
    Verify Throuput on Pscell and Scell For NSA    ue_id=92

Step2 online disable actBufferBasedSCellAddition
    OnlineParamChange    ${8311_disable}
    Trigger A2 MR for scell release    carrierfreq=633216    scell_rsrp=47    scell_rsrq=60    ue_id=91
    Trigger A1 MR    carrierfreq=126750    srsrp_nr=37    srsrq_nr=46    ue_id=91

Step3 online enable actBufferBasedSCellAddition
    OnlineParamChange    ${8311_enable}
    Trigger A2 MR for scell release    carrierfreq=633216    scell_rsrp=47    scell_rsrq=60    ue_id=91
    Trigger A2 MR for scell release    carrierfreq=633216    scell_rsrp=47    scell_rsrq=60    ue_id=92

Step4 Trigger A1 MR for UE91 for SCell Addition
    Trigger A1 MR    carrierfreq=126750    srsrp_nr=37    srsrq_nr=46    ue_id=91
    Verify Throuput on Pscell and Scell For NSA    ue_id=91

Step5 Stop traffic on UE92 and trigger A1 MR for SCell Addition
    Stop Throuput For NSA    ue_id=92
    Trigger A1 MR    carrierfreq=126750    srsrp_nr=37    srsrq_nr=46    ue_id=92
    Verify no Scell add for NSA when no traffic    ue_id=92

Step6 Trigger A1 MR with leaving condition and Start traffic on UE92
    Trigger A1 MR    carrierfreq=126750    srsrp_nr=32    srsrq_nr=34    ue_id=92
    Send Throuput For NSA    ue_id=92
    Verify no Scell add for NSA    ue_id=92

Step1 UE91 in CA status
    NSA UE Attach To Target Cell    cell_id=2    ue_id=91
    Trigger A1 MR        carrierfreq=633216    srsrp_nr=37    srsrq_nr=46    ue_id=91
    Send Throuput For NSA    ue_id=91
    Verify Throuput on Pscell and Scell For NSA

Step2 online reconfigure dlSCellConfigLevel and dlSCellConfigLevelNum to bigger value
    OnlineParamChange    ${parameter_B007}
    Trigger A2 MR for scell release    carrierfreq=424090    scell_rsrp=47    scell_rsrq=60    ue_id=91
    Trigger A1 MR    carrierfreq=633216    srsrp_nr=37    srsrq_nr=46    ue_id=91
    Verify no Scell add for NSA

Step3 online recover dlSCellConfigLevel and dlSCellConfigLevelNum
    OnlineParamChange    ${parameter_B007_recover}
    Trigger A1 MR    carrierfreq=633216    srsrp_nr=32    srsrq_nr=34    ue_id=91
    Trigger A1 MR    carrierfreq=633216    srsrp_nr=37    srsrq_nr=46    ue_id=91
    Verify Throuput on Pscell and Scell For NSA

NSA UE Attach To Target Cell
    [Arguments]    ${cell_id}=12    ${ue_id}=91
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    pass_regexp=reported successful RA    fail_regexp=SCellIndex 9 activated successfully at airphone

Send Throuput For NSA
    [Arguments]    ${ue_id}=91
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    15s    #sleep for stable traffic

Stop Throuput For NSA
    [Arguments]    ${ue_id}=92
    Execute Egate Command    trf_data_stop ue=${ue_id} id=2    pass_regexp=Traffic was stopped
    sleep    15s    #sleep for stable traffic

Trigger A1 MR
    [Arguments]    ${event_type}=A1    ${carrierfreq}=632736    ${srsrp_nr}=37    ${srsrq_nr}=46    ${ue_id}=91    ${pass_reg}=RRC
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_reg}

Trigger A2 MR for scell release
    [Arguments]    ${event_type}=A2    ${carrierfreq}=632736    ${scell_rsrp}=47    ${scell_rsrq}=60    ${ue_id}=91
    ...    ${scell_id}=9    ${pass_reg}=${A2_Realse}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} scell=${scell_id}
    ...    scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_reg}

Verify no Scell add for NSA
    [Arguments]    ${ue_id}=91    ${scell_id}=9    ${Tput_dl}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    Should Not Match Regexp    ${scell_tput}    CellIndex-[9] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[10]
    Should Be True    ${dl_throughput}/1000>${Tput_dl}

Verify no Scell add for NSA when no traffic
    [Arguments]    ${ue_id}=92    ${scell_id}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    Should Not Match Regexp    ${scell_tput}    CellIndex-[9] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[10]

Verify Throuput on Pscell and Scell For NSA
    [Arguments]    ${ue_id}=91    ${pcell_dl}=40    ${scell_dl}=30    ${ul}=6    ${pcell_id}=8    ${scell_id}=9
    sleep    15s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${pcell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Detach From gNB
    [Arguments]    ${ue_id}=91
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: detached    timeout=10s
