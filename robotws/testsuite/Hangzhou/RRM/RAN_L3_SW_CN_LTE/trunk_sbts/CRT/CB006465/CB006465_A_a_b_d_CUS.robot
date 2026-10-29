*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               team-VRF_HAZ3_T08    release-SBTS22R1    owner-dawid.dul    owner-huabao.jiang
Resource          ../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}
@{A_a_b_1}
...    LNBTS:actUL256QamForEnDc=disabled
...    LNCEL-11:actUl256QamChQualEst=true
...    LNCEL-12:actUl256QamChQualEst=true
...    LNCEL-13:actUl256QamChQualEst=true
...    LNCEL-14:actUl256QamChQualEst=true
...    LNCEL-17:actUl256QamChQualEst=true
...    LNCEL-18:actUl256QamChQualEst=true
...    LNCEL-19:actUl256QamChQualEst=true
${UECapabilityInformation}
...    (ue-CategoryDL-v1450 eq 20) and (ue-CategoryDL-v1530 eq 26) and (ue-CategoryUL-v1530 eq 26)
${first_scell_add}
...    dl-CarrierFreq-r10 eq 3100 and ul-CarrierFreq-r10 eq 21100 and enable256QAM-r14 is not present
${pcell_conf_1}
...    physicalConfigDedicated contains (pusch-ConfigDedicated-v1430 contains (enable256QAM-r14 contains (setup is present)))
${scell_conf}
...    sCellToAddModList-r10 contains (sCellIndex-r10 eq 1 and ((physicalConfigDedicatedSCell-r10 contains
...    (pusch-ConfigDedicated-v1430 contains (enable256QAM-r14 contains (setup is present))))))
@{CounterList}
...    LNCEL-11:M8080C134=1
...    LNCEL-11:M8080C135=1
...    LNCEL-11:M8007C29>30
...    LNCEL-11:M8007C29<650

*** Test Cases ***
CB006465_A_a_b_1_UL_256QAM_for_EN_DC_capable_UE_Channel_Quality_Monitoring_enabled_FDD_and_TDD
    [Tags]
    [Documentation]
    ...    DESCRIPTION:
    ...    This test covers the following CFAM scenarios:
    ...    - CB006465-A-a.2 UL 256 QAM configuration before EN-DC Setup - Channel Quality Monitoring is enabled
    ...    - CB006465-A-b#1.2 – CQM enabled – DL&UL SCell configured - 256QAM in UL configured on both PCell and SCell – during EN-DC
    ...      setup SCell is downgraded, 256QAM in UL released and CQM stopped
    ...    - CB006465 #11: Online modification of CB006465 feature flag from 'disabled' to 'nonConcurrent'
    ...    - CB006465-A-l UE with high ue-CategoryUl - Channel Quality Monitoring enabled
    ...
    ...    The eNB is composed out of one ASIA board and three ABIA boards.
    ...    The following radio heads (simulated) are used and cells are configured:
    ...    - AREA with cell id 11, band  3,  5 MHz DL EARFCN: 1400 UL EARFCN: 19400
    ...    - AHHA with cell id 12, band  7,  5 MHz DL EARFCN: 3400 UL EARFCN: 21400
    ...    - AREA with cell id 13, band  3,  5 MHz DL EARFCN: 1400 UL EARFCN: 19400
    ...    - AHHA with cell id 14, band  7,  5 MHz DL EARFCN: 3100 UL EARFCN: 21100
    ...    - AZHA with cell id 17, band 41, 10 MHz EARFCN: 40590
    ...    - AZHA with cell id 18, band 41, 10 MHz EARFCN: 40334
    ...    - AZQC with cell id 19, band 42, 10 MHz EARFCN: 42590
    ...
    ...    Cell 11 has CAREL relation for cell 12.
    ...    Cell 17 has CAREL relation for cell 19.
    ...
    ...    UE_1 supports the following band combinations:
    ...    - EUTRA band combination DL CA_3A-7A / UL CA_3A_7A with 256 QAM
    ...    - MR-DC band combination DL DC_3A-7A_n78A / UL DC_3A-7A
    ...    UE_2 supports the following band combinations:
    ...    - EUTRA band combination DL CA_41A-42A / UL CA_41A_42A with 256 QAM
    ...    - MR-DC band combination DL DC_41A-42A_n78A / UL DC_41A-42A
    ...    UE_1 and UE_2 have two non GBR bearers with QCI = 6 (pure LTE) and QCI = 8 (EN_DC eligible)
    ...    which are added at Initial Cotext Setup.
    ...
    ...    The gNB (simulated) hosts (among others) cell id 22 (physical cell id 381) with NR band n78.
    ...
    ...    Main eNB settings:
    ...    - qciTab6 has lteNrDualConnectSupport = disabled
    ...    - qciTab8 has lteNrDualConnectSupport = EN-DC
    ...    - Step wise SCell addition is enabled, i.e. actAdvStepwiseScellAdd = off and numTxWithHighNonGbr = 1
    ...    - UL modulation scheme is set to 256QAM on all cells.
    ...    - DL modulation scheme is set to QPSK on all cells (DL throughput is limited due to overall UE simulator instability).
    ...    - Channel Quality Monitoring (ChQualMon) for UL 256 QAM is enabled on all cells, i.e. actUl256QamChQualEst = true
    ...    - For better ChQualMon performance we set ulpcUplevSch = -88dBm and ulpcUpqualSch = 35dB
    ...    - The actUL256QamForEnDc is set to nonConcurrent which means that EN-DC capable UEs will be
    ...      configured with UL 256 QAM when possible. <- this is the CB006465 feautre flag, the main flag of the test.
    ...    - Dynamic EN-DC triggering through B1 NR measurments is enabled, i.e. actDynTrigLteNrDualConnectivity = true.
    ...    - 'Dynamic trigger method' in dynTriggerLteNrDcConfList is set to coverageBased
    ...    - Carreir aggregation for LTE NR EN-DC scenarios is enabled actCAggrLteNrDualConnectivity = enhanced_CA_LTE_NR.
    ...    - UL carrier aggregation for EN-DC capable UE is enabled, i.e. actULCaForEnDc = nonConcurrentULCaAndEnDc.
    ...    - UL driven carrier aggregation is enabled, i.e. actUlTraffDrivUlCa = true.
    ...
    ...    The following fields in TTI traces are checked to determine whether UL 256 QAM is configured or not:
    ...    - For FDD:
    ...        * ETtiTraceUlParUe_Ul256QamModTable = 256QamTable
    ...        * ETtiTraceUlParUe_Modulation = 256QAM
    ...    - For TDD UL 256 QAM is configured when:
    ...        * ETtiTraceUlParUe_256QamModulationTable = 256QamTable
    ...        * ETtiTraceUlParUe_preMcs >= 23 (according to Table 8.6.1-3 3GPP TS 36.213)
    ...
    ...    Whether the transient phase took place or not is check with:
    ...    - For FDD:
    ...        * ETtiTraceUlParUe_Ul256QamModTable = Non256QamTransient
    ...        * ETtiTraceUlParUe_Modulation = QPSK
    ...    - For TDD:
    ...        * ETtiTraceUlParUe_256QamModulationTable = Non256QamTableTransient
    ...        * ETtiTraceUlParUe_preMcs = 0
    Delta Commission Parameters    ${A_a_b_1}
    Set ENDC
    Set poor radio conditions (RSSI=-115 PHR=10) for UE_1 for PCell
    Set poor radio conditions (RSSI=-115 PHR=10) for UE_1 for SCell-1
    Set observers for UE_1 for One SCell addition flow_alias SCELL_ADD_2 message_alias first_scell_add
    Set observers for UE_1 for UECapabilityInformation
    Attach UE_1 to cell 11
    Start DL and UL traffic on bearer with QCI6 for UE_1
    Set observers for UE_1 for lack of PCell and SCell UL 256 QAM configuration flow_alias CELL_RECONF_3 message_alias cell_reconf
    Set excellent radio conditions (RSSI=-70 PHR=63) for UE_1 for PCell
    Set excellent radio conditions (RSSI=-70 PHR=63) for UE_1 for SCell-1
    Verify that flow not occurred flow_alias CELL_RECONF_3

    Set observers for UE_1 for lack of PCell and SCell UL 256 QAM configuration flow_alias CELL_RECONF_4 message_alias cell_reconf
    Set actUL256QamForEnDc to nonConcurrent on eNB-1
    Verify that flow not occurred flow_alias CELL_RECONF_4

    Set observers for UE_1 for SCell release and addition flow_alias scell_rel_add_2
    Trigger SCell release and SCell addition for UE_1
    Verify that UE_1 had its SCell released flow_alias scell_rel_add_2

    Set observers for UE_1 for PCell UL 256 QAM configuration due to CQM
    start to capture enb ttitrace
#    Start collecting Tti traces  cell_id=11  transient_phase=True  alias_id=1
    Set excellent radio conditions (RSSI=-70 PHR=63) for UE_1 for PCell
    Verify that for UE_1 PCell was configured with UL 256 QAM at RRC level
    stop capture enb ttitrace
#    Stop collecting Tti traces  cell_id=11
#    Verify transient phase  cell_id=11  direction=non256QAM_to_256QAM  duplex_mode=FDD  cqm=enabled  alias_id=1
#    Verify UE modulation at MAC PS level  expected_modulation=256QAM  cell_id=11  duplex_mode=FDD  cqm=enabled  alias_id=1

    Set observers for UE_1 for SCell UL 256 QAM configuration due to CQM
#    Start collecting Tti traces  cell_id=12  transient_phase=True  alias_id=1
    start to capture enb ttitrace
    Set excellent radio conditions (RSSI=-70 PHR=63) for UE_1 for SCell-1
    Verify that for UE_1 the SCell with sCellIndex-1 was configured with UL 256 QAM at RRC level
#    Stop collecting Tti traces  cell_id=12
    stop capture enb ttitrace
#    Verify transient phase  cell_id=12  direction=non256QAM_to_256QAM  duplex_mode=FDD  cqm=enabled  alias_id=1
#    Verify UE modulation at MAC PS level  expected_modulation=256QAM  cell_id=12  duplex_mode=FDD  cqm=enabled  alias_id=1

#    Start Rtpm Collection Interval  wait_for_next_minute_start=True
    start rtpm counter
    Set observers for UE_1 for UL 256 QAM PCell release and SCell downgrade flow_alias scell_rel_dwngrade message_alias scell_reconf
#    Start collecting Tti traces  cell_id=11  transient_phase=True  alias_id=2
    start to capture enb ttitrace
    Set observers for CA EN-DC establishment for UE_1
    Trigger UE_1 to send B1-NR measurement report containing NR CELL-22 parameters
    stop capture enb ttitrace
#    Verify transient phase  cell_id=11  direction=256QAM_to_non256QAM  duplex_mode=FDD  cqm=enabled  alias_id=2
#    Verify UE modulation at MAC PS level  expected_modulation=Non256Qam  cell_id=11  duplex_mode=FDD  cqm=enabled  alias_id=2
    Trigger ENDC release for UE_1
#    Stop Rtpm Collection Interval
#    # CB006465-A-d + Online change from disabled to nonConcurrent can be added once CFAM3 is ready.
    Detach UE_1
    check rtpm counters    ${CounterList}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=7CELLs_FDD_2B3_2B7_TDD_2B41_1B42    ue_count=1    cfg=cus.yaml
    Create Alias
    execute egate command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    execute egate command    trace_sim on mme=1 protocol=s1

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=2    id_type=wts

Set ENDC
    execute egate command    gnb_endc_param id=2 selected_band_combination_nr=2:1 scg_dl_dist_percent=1

Set poor radio conditions (RSSI=-115 PHR=10) for UE_1 for PCell
    execute uex command  ue_ul_power_control id=1 phr_value_override=10 phr_operation=permanent sim_rssi=-115 scell=0 pathloss=0
Set poor radio conditions (RSSI=-115 PHR=10) for UE_1 for SCell-1
    execute uex command  ue_ul_power_control id=1 phr_value_override=10 phr_operation=permanent sim_rssi=-115 scell=1 pathloss=0
    sleep    10s
Set observers for UE_1 for One SCell addition flow_alias SCELL_ADD_2 message_alias first_scell_add
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    UE_1:RRC_RRCConnectionReconfiguration(${first_scell_add})
#Verify that UE_1 was configured with 1 SCell with DL EARFCN 3100 and UL EARFCN 21100 flow_alias: SCELL_ADD_2 message_alias: first_scell_add
#Verify that for UE_1 PCell was not configured with UL 256 QAM at RRC level flow_alias: SCELL_ADD_2 message_alias: first_scell_add
#Verify that for UE_1 the SCell with sCellIndex-1 was not configured with UL 256 QAM
#at RRC level flow_alias: SCELL_ADD_2 message_alias:first_scell_add
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=SCELL_ADD_2    overall_timeout=60

Set observers for UE_1 for lack of PCell and SCell UL 256 QAM configuration flow_alias CELL_RECONF_3 message_alias cell_reconf
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration as cell_reconf
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=CELL_RECONF_3    overall_timeout=60

Start DL and UL traffic on bearer with QCI6 for UE_1
    EXECUTE UEX COMMAND    trf_data_start qci=6 ue=1 dir=dl_and_ul Mbps=20 protocol=udp
    flow occurred as expected     alias=SCELL_ADD_2

Set observers for UE_1 for UECapabilityInformation
    Expect Message Flow
    ...    UE_1:RRC_UECapabilityInformation(${UECapabilityInformation})
    ...    alias=UE_1_attach    overall_timeout=60
Attach UE_1 to cell 11
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionRequest
    ...    UE_1:RRC_RRCConnectionSetup
    ...    UE_1:RRC_RRCConnectionSetupComplete
    ...    UE_1:RRC_RRCConnectionReconfiguration
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_1_ATTACH    overall_timeout=120
    execute uex command    ue_attach id=1 cell=11
    Flow Occurred As Expected    alias=UE_1_ATTACH

Trigger ENDC release for UE_1
    Sleep  30  #Sleep to increase PM counter M8007C29 (UE_ACTIVE_TIME_UL_256QAM)
    execute egate command  enb_ue_dc_release ue=1 bearer=8 by=gnb cause=off
    Sleep   10

Set excellent radio conditions (RSSI=-70 PHR=63) for UE_1 for PCell
    execute uex command    ue_ul_power_control id=1 phr_value_override=63 phr_operation=permanent sim_rssi=-70 scell=0 pathloss=0
    sleep    10s

Set excellent radio conditions (RSSI=-70 PHR=63) for UE_1 for SCell-1
    execute uex command    ue_ul_power_control id=1 phr_value_override=63 phr_operation=permanent sim_rssi=-70 scell=1 pathloss=0
    sleep    10s

Verify that flow not occurred flow_alias CELL_RECONF_3
    flow not occurred for message    alias=CELL_RECONF_3

Set observers for UE_1 for lack of PCell and SCell UL 256 QAM configuration flow_alias CELL_RECONF_4 message_alias cell_reconf
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration as cell_reconf
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=CELL_RECONF_4    overall_timeout=60

Set actUL256QamForEnDc to nonConcurrent on eNB-1
    delta commission parameters    LNBTS:actUL256QamForEnDc=nonConcurrent

Verify that flow not occurred flow_alias CELL_RECONF_4
    flow not occurred for message    alias=CELL_RECONF_4

Set observers for UE_1 for SCell release and addition flow_alias scell_rel_add_2
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration as scell_rel
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    UE_1:RRC_RRCConnectionReconfiguration(dl-CarrierFreq-r10 eq 3100 and ul-CarrierFreq-r10 eq 21100)
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=scell_rel_add_2    overall_timeout=180

Trigger SCell release and SCell addition for UE_1
    execute uex command    trf_data_stop ue=1
    sleep    60s
    execute uex command    ue_ul_power_control id=1 phr_value_override=10 phr_operation=permanent sim_rssi=-115 scell=0 pathloss=0
    sleep    10s
    execute uex command    ue_ul_power_control id=1 phr_value_override=10 phr_operation=permanent sim_rssi=-115 scell=1 pathloss=0
    sleep    10s
    execute uex command    trf_data_start qci=6 ue=1 dir=dl_and_ul Mbps=20 protocol=udp

Verify that UE_1 had its SCell released flow_alias scell_rel_add_2
    Flow Occurred As Expected    alias=scell_rel_add_2

Set observers for UE_1 for PCell UL 256 QAM configuration due to CQM
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${pcell_conf_1})
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=pcell_256_conf_1    overall_timeout=60

Verify that for UE_1 PCell was configured with UL 256 QAM at RRC level
   Flow Occurred As Expected    alias=pcell_256_conf_1

Set observers for UE_1 for SCell UL 256 QAM configuration due to CQM
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${scell_conf})
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=scell_256_conf_1    overall_timeout=60

Verify that for UE_1 the SCell with sCellIndex-1 was configured with UL 256 QAM at RRC level
    Flow Occurred As Expected    alias=scell_256_conf_1

Set observers for UE_1 for UL 256 QAM PCell release and SCell downgrade flow_alias scell_rel_dwngrade message_alias scell_reconf
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(dl-CarrierFreq-r10 eq 3100 and ul-CarrierFreq-r10 is not present)
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=scell_rel_dwngrade   overall_timeout=30

Set observers for CA EN-DC establishment for UE_1
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    alias=en_dc_setup_1    overall_timeout=60

Trigger UE_1 to send B1-NR measurement report containing NR CELL-22 parameters
    execute uex command    ue_measurement_send id=1 event=B1_NR phycell_id=381 nrsrp=90 srsrp=30
    Flow Occurred As Expected    alias=en_dc_setup_1
    Flow Occurred As Expected    alias=scell_rel_dwngrade

Detach UE_1
   execute uex command    ue_detach id=1