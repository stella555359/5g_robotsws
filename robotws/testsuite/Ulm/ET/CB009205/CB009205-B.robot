*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: B3 describes how A1 measurements for steering UE to preferred NR layer is configured during NG based handover.
...                 B4 describes the behaviour, after a UE in RRC_CONNECTED state re-establishes successfully to the selected cell


Resource          CB009205-B_Keywords.robot

Suite Setup       Prepare TL
Suite Teardown    Run Keywords
...               CB009205-B_Keywords.Reload Original Iphy File    AND
...               sqd65_keywords.Sqd65 Common Teardown

Test Setup        Perform Preconditions of Test Scenario
Test Teardown     Perform Postconditions of Test Scenario

*** Test Cases ***
[1]CB009205_B_B3_Configuration_of_A1_measurements_for_steering_UE_to_preferred_NR_layer_during_NG_based_handover
    [Documentation]   Configuration of A1 measurements for steering UE to preferred NR layer during NG based handover
    ...               Alt#5 - diff A1 config on source/target side
    [Tags]    B3  B3_1
    Register UE to the simgNB and setup pdu session                      ue_nr_capabilities=${UE_CAPA_TDD_B3_Band78}
    Verify Measurement ID Is Configured    A1                            ue_id=1
    Verify Measurement ID Is Configured    A3                            ue_id=1
    Start data traffic in egate                                          ue_id=1    direction=dl    pdu=1    qfi=1    mbps=1    size=1000
    Trigger NG HO from simgNB to realgNB
    Verify Measurement ID Is Configured    A1                            ue_id=1

[2]CB009205_B_B3_Configuration_of_A1_measurements_for_steering_UE_to_preferred_NR_layer_during_NG_based_handover
    [Documentation]    If no NRHOIF, then A1 is not configured
    [Tags]    B3  B3_2
    Remove NRHOIF MO
    Register UE to the simgNB and setup pdu session                      ue_nr_capabilities=${UE_CAPA_TDD_B3_Band78}
    Verify Measurement ID Is Configured    A1                            ue_id=1
    Verify Measurement ID Is Configured    A3                            ue_id=1
    Start data traffic in egate                                          ue_id=1    direction=dl    pdu=1    qfi=1    mbps=1    size=1000
    Trigger NG HO from simgNB to realgNB
    Verify Measurement ID is absent        A1                            ue_id=1

[3]CB009205_B_B3_Configuration_of_A1_measurements_for_steering_UE_to_preferred_NR_layer_during_NG_based_handover
    [Documentation]    UE supports gNB CA combination
    [Tags]    B3  B3_3
    Enable Carrier Aggregation FR1 TDD SA
    Enable Blind CA
    Register UE to the simgNB and setup pdu session                      ue_nr_capabilities=${UE_CAPA_TDD}
    Verify Measurement ID Is Configured    A1                            ue_id=1
    Verify Measurement ID Is Configured    A3                            ue_id=1
    Start data traffic in egate                                          ue_id=1    direction=dl    pdu=1    qfi=1    mbps=1    size=1000
    Trigger NG HO from simgNB to realgNB
    Verify Measurement ID is absent        A1                            ue_id=1
    [Teardown]   Perform Postconditions of Test Scenario CA disabled

[4]CB009205_B_B3_Configuration_of_A1_measurements_for_steering_UE_to_preferred_NR_layer_during_NG_based_handover
    [Documentation]    Alt#6 - A1 config on source and no A1 config on target gNB
    [Tags]    B3  B3_4
    Disable A1 based traffic steering to preferred NR layer
    Register UE to the simgNB and setup pdu session                      ue_nr_capabilities=${UE_CAPA_TDD_B3_Band78}
    Verify Measurement ID Is Configured    A1                            ue_id=1
    Verify Measurement ID Is Configured    A3                            ue_id=1
    Start data traffic in egate                                          ue_id=1    direction=dl    pdu=1    qfi=1    mbps=1    size=1000
    Trigger NG HO from simgNB to realgNB
    Verify Measurement ID is absent        A1                            ue_id=1

[5]CB009205_B_B3_Configuration_of_A1_measurements_for_steering_UE_to_preferred_NR_layer_during_NG_based_handover
    [Documentation]    Alt#7 - A1 config not on source but in target gNB
    [Tags]    B3  B3_5
    Disable A1 configuration on simgNB
    Register UE to the simgNB and setup pdu session                      ue_nr_capabilities=${UE_CAPA_TDD_B3_Band78}
    Verify Measurement ID is absent        A1                            ue_id=1
    Verify Measurement ID Is Configured    A3                            ue_id=1
    Start data traffic in egate                                          ue_id=1    direction=dl    pdu=1    qfi=1    mbps=1    size=1000
    Trigger NG HO from simgNB to realgNB
    Verify Measurement ID Is Configured    A1                            ue_id=1

[6]CB009205_B_B3_Configuration_of_A1_measurements_for_steering_UE_to_preferred_NR_layer_during_NG_based_handover
    [Documentation]    Alt#8 - A1 configuration after UECapabilityEnquiry
    [Tags]    B3  B3_6
    Disable A1 configuration on simgNB
    Register UE to the simgNB and setup pdu session                      ue_nr_capabilities=${UE_CAPA_TDD_B3_7_Band41}
    Verify Measurement ID is absent        A1                            ue_id=1
    Verify Measurement ID Is Configured    A3                            ue_id=1
    Start data traffic in egate                                          ue_id=1    direction=dl    pdu=1    qfi=1    mbps=1    size=1000
    UE Param                                                             id=1       ue_nr_capabilities=${UE_CAPA_TDD_B3_Band78}
    Trigger NG HO from simgNB to realgNB
    Verify Measurement ID Is Configured    A1                            ue_id=1

[3]CB009205_B_B4_Recongiuration_of_A1_measurements_after_successful_RRC_Re-establishment_to_the_same_gNB-DU
    [Documentation]    Alt#2 - Mobility profile is activated and mobility profile selected for UE(NRMOPR_SA.a1MeasHOPrefNRLayerEnabledSA)
    ...                => includes main case
    [Tags]    TC4_3
    Enable Mobility Profile                                              a1MeashoPrefNRLayerEnabledSA=rsrq
    Register UE to the gNB and setup pdu session
    Verify Measurement ID Is Configured    A1                            ue_id=1
    Start data traffic in egate                                          ue_id=1    direction=dl    pdu=1    qfi=1    mbps=1    size=1000
    UE RRC Reestablish                                                   ue_id=1    gnb=2  cell=1
    Verify Measurement ID Is Configured    A1                            ue_id=1

[1]CB009205_B_B4_Recongiuration_of_A1_measurements_after_successful_RRC_Re-establishment_to_the_same_gNB-DU
    [Documentation]  Alt#1- actA1HoPrefNRLayer is deactivated
    [Tags]    TC4_1
    Register UE to the gNB and setup pdu session
    Verify Measurement ID Is Configured    A1                            ue_id=1
    Disable A1 based traffic steering to preferred NR layer
    UE RRC Reestablish                                                   ue_id=1    gnb=2  cell=1
    Verify Measurement ID is absent        A1                            ue_id=1

[2]CB009205_B_B4_Recongiuration_of_A1_measurements_after_successful_RRC_Re-establishment_to_the_same_gNB-DU
    [Documentation]  Alt#1 - a1MeasHOPrefNRLayerEnabledSA is deactivated
    [Tags]    TC4_2
    Register UE to the gNB and setup pdu session
    Verify Measurement ID Is Configured    A1                            ue_id=1
    A1 measurement configuration for steering UE to preferred NR Layer enabled SA   a1MeashoPrefNRLayerEnabledSA=none
    UE RRC Reestablish                                                   ue_id=1    gnb=2  cell=1
    Verify Measurement ID is absent        A1                            ue_id=1

[1]CB009205_B_B5_Handling_of_A1_Measurement_Report_for_steering_UE_to_preferred_NR_layer
    [Documentation]  Handling of A1 Measurement Report for steering UE to preferred NR layer
    [Tags]   B5  B5_1
    Apply Config for B_B5
    Register UE
    ${a1TimeToTriggerhoSsbRsrp}=           Remove String   ${a1MeashoPrefNRLayerSsbRsrpSA['a1TimeToTriggerhoSsbRsrp']}  ms
    ${a1MeasConfigValues}=                 Catenate
    ...                                    Type: event, hysteresis: ${a1MeashoPrefNRLayerSsbRsrpSA['a1HysteresisSsbRsrp']},
    ...                                    TimeToTrigger: ${a1TimeToTriggerhoSsbRsrp} ms,
    ...                                    ReportOnLeave: false, EventA1: Threshold: RSRP ${a1MeashoPrefNRLayerSsbRsrpSA['a1ThresholdhoSsbRsrp']}

    Verify Measurement ID is configured    A1
    Verify Measurement Config Values       ${a1MeasConfigValues}
    Wait until the next Measurement Period starts
    Send NR Measurement Report             A1
    Verify Measurement ID is configured    A4  carrier_freq=${ssbFrequency_nrhoif-1}
    Verify Measurement ID is configured    A1
    Verify PM Counters                     B_B5
    Verify PCMD Trace

[2]CB009205_B_B5_Handling_of_A1_Measurement_Report_for_steering_UE_to_preferred_NR_layer
    [Documentation]  Alt#4 - A1 MR discarded when NRCELL.a4MeasHigherPrioFreqMaxReactSA(>0) equal to number of times a4 reactivation done
    [Tags]   B5  B5_2
    Apply Config for B_B5
    Register UE
    ${numOfa4PeriodicMeasCycles}=          Evaluate  ${a4MeasHigherPrioFreqMaxReactSA_B5} + 1
    a4PeriodicMeasCycles                   a4PeriodicMeasControl=${a4PeriodicMeasControlSA_B5}  numOfa4PeriodicMeasCycles=${numOfa4PeriodicMeasCycles}
    Verify Measurement ID is configured    A1
    Verify Measurement ID is absent        A4  carrier_freq=${ssbFrequency_nrhoif-1}
    Verify Measurement is ignored          A1

[3]CB009205_B_B5_Handling_of_A1_Measurement_Report_for_steering_UE_to_preferred_NR_layer
    [Documentation]  Alt#7 - A1 MR discarded when a4RetryTimer or a4SupervisonTimer is running
    [Tags]   B5  B5_3
    Apply Config for B_B5
    Register UE
    Send NR Measurement Report             A1   # activate a4PeriodicMeasCycle
    Verify Measurement ID is configured    A4   carrier_freq=${ssbFrequency_nrhoif-1}
    Verify Measurement is ignored          A1   timeout=1s  # A4 active
    Wait For RrcReconfigurationComplete    timeout=${a4PeriodicMeasControlSA_B5['a4Fr1SupervisionTimer']}
    Verify Measurement ID is absent        A4   carrier_freq=${ssbFrequency_nrhoif-1}
    Verify Measurement is ignored          A1   timeout=1s  # A4 deactivated

[1]CB009205_B_B6_Parameter_online_modification
    [Documentation]  Disable A1 based traffic steering to preferred NR layer for SA
    ...              TBD: optional UE2:  If A4 measurement report is received then it will be processed and handover executed
    [Tags]    B6  B6_1
    Register UE                            # UE1
    Disable A1 based traffic steering to preferred NR layer
    Verify Measurement ID is configured    A1
    Wait until the next Measurement Period starts
    Send NR Measurement Report             A1
    Verify Measurement ID is configured    A4  carrier_freq=${ssbFrequency_nrhoif-1}
    Verify Measurement ID is configured    A1
    Verify PM Counters                     B_B5
    Deregister UE

    Enable A1 based traffic steering to preferred NR layer
    Max Reactivation of A4 Meas for Mobility to higher Prio   1

    Register UE                            # UE2 (optional/legacy)
    Send NR Measurement Report             A1
    Verify Measurement ID is configured    A4  carrier_freq=${ssbFrequency_nrhoif-1}
    Disable A1 based traffic steering to preferred NR layer
    Wait until a4PeriodicMeasCycle finish
    Send NR Measurement Report             A1
    Verify Measurement ID is configured    A4  carrier_freq=${ssbFrequency_nrhoif-1}
    Deregister UE

    Register UE
    Verify Measurement ID is absent        A1
    Enable A1 based traffic steering to preferred NR layer
    Verify Measurement ID is absent        A1

[2]CB009205_B_B6_Parameter_online_modification
    [Documentation]  Modify RSRP measurement parameters for steering UE to preferred NR layer for SA
    [Tags]    B6  B6_2
    Apply Config for B_62_63               a1MeashoPrefNRLayerEnabledSA=rsrqCombined
    Register UE                            # UE1
    Verify Measurement is ignored          A1  meas_values=phycell_id=50 srsrp_nr=61 srsrq_nr=20
    Apply Config for B_62_63               a1MeashoPrefNRLayerEnabledSA=rsrqCombined  a1HysteresisSsbRsrp=0
    Send NR Measurement Report             A1  meas_values=phycell_id=50 srsrp_nr=61 srsrq_nr=20
    Verify Measurement ID is configured    A4  carrier_freq=${ssbFrequency_nrhoif-1}
    Verify Measurement ID is configured    A1
    Deregister UE

    Apply Config for B_62_63               a1MeashoPrefNRLayerEnabledSA=rsrqCombined
    Register UE                            # UE2
    Send NR Measurement Report             A1  meas_values=phycell_id=50 srsrp_nr=75 srsrq_nr=20
    Verify Measurement is ignored          A1  timeout=1s  meas_values=phycell_id=50 srsrp_nr=75 srsrq_nr=20
    Apply Config for B_62_63               a1MeashoPrefNRLayerEnabledSA=rsrqCombined  a1HysteresisSsbRsrp=0
    Wait until a4PeriodicMeasCycle finish
    Send NR Measurement Report             A1  meas_values=phycell_id=50 srsrp_nr=61 srsrq_nr=20
    Verify Measurement ID is configured    A4  carrier_freq=${ssbFrequency_nrhoif-1}
    Verify Measurement ID is configured    A1

[3]CB009205_B_B6_Parameter_online_modification
    [Documentation]  Modify RSRQ measurement parameters for steering UE to preferred NR layer for SA
    [Tags]    B6  B6_3
    Apply Config for B_62_63               a1MeashoPrefNRLayerEnabledSA=rsrpCombined
    Register UE                            # UE1
    Verify Measurement is ignored          A1  meas_values=phycell_id=50 srsrp_nr=30 srsrq_nr=50
    Apply Config for B_62_63               a1MeashoPrefNRLayerEnabledSA=rsrpCombined  a1ThresholdhoSsbRsrq=49
    Send NR Measurement Report             event=A1  meas_values=phycell_id=50 srsrp_nr=30 srsrq_nr=50
    Verify Measurement ID is configured    A4  carrier_freq=${ssbFrequency_nrhoif-1}
    Verify Measurement ID is configured    A1
    Deregister UE

    Apply Config for B_62_63               a1MeashoPrefNRLayerEnabledSA=rsrpCombined
    Register UE                            # UE2
    Send NR Measurement Report             A1  meas_values=phycell_id=50 srsrp_nr=30 srsrq_nr=64
    Apply Config for B_62_63               a1MeashoPrefNRLayerEnabledSA=rsrpCombined  a1ThresholdhoSsbRsrq=49
    Wait until a4PeriodicMeasCycle finish
    Send NR Measurement Report             A1  meas_values=phycell_id=50 srsrp_nr=30 srsrq_nr=50
    Verify Measurement ID is configured    A4  carrier_freq=${ssbFrequency_nrhoif-1}
    Verify Measurement ID is configured    A1

[4]CB009205_B_B6_Parameter_online_modification
    [Documentation]  [4a1] NRCELL.a1MeashoPrefNRLayerEnabledSA is set to 0(none)
    [Tags]    B6  B6_4
    Register UE                            # UE1
    Verify Measurement ID is configured    A1
    A1 measurement configuration for steering UE to preferred NR Layer enabled SA  a1MeashoPrefNRLayerEnabledSA=none
    Verify Measurement is ignored          A1
    A1 measurement configuration for steering UE to preferred NR Layer enabled SA  a1MeashoPrefNRLayerEnabledSA=rsrp
    Send NR Measurement Report             A1
    Verify Measurement ID is configured    A4  carrier_freq=${ssbFrequency_nrhoif-1}
    Deregister UE

    Register UE                            # UE2 (optional/legacy)
    Send NR Measurement Report             A1
    A1 measurement configuration for steering UE to preferred NR Layer enabled SA  a1MeashoPrefNRLayerEnabledSA=none
    Run Keyword and Ignore Error           Wait until a4PeriodicMeasCycle finish
    Verify Measurement is ignored          A1

[5]CB009205_B_B6_Parameter_online_modification
    [Documentation]  [4a2] NRCELL.a1MeashoPrefNRLayerEnabledSA is set to 0(none) with Mobility Profile enabled
    [Tags]    B6  B6_5
    Enable Mobility Profile
    Register UE                            # UE1
    Verify Measurement ID is configured    A1
    A1 measurement configuration for steering UE to preferred NR Layer enabled SA
    ...                                    dist_name=MRBTS-1/NRBTS-1/NRMOPR_SA-1  a1MeashoPrefNRLayerEnabledSA=none
    Verify Measurement is ignored          A1
    A1 measurement configuration for steering UE to preferred NR Layer enabled SA
    ...                                    dist_name=MRBTS-1/NRBTS-1/NRMOPR_SA-1  a1MeashoPrefNRLayerEnabledSA=rsrp
    Send NR Measurement Report             A1
    Verify Measurement ID is configured    A4  carrier_freq=${ssbFrequency_nrhoif-1}

[6]CB009205_B_B6_Parameter_online_modification
    [Documentation]  [4b1] NRCELL.a1MeashoPrefNRLayerEnabledSA is modified from rsrp to rsrqCombined
    ...              (rsrp threshold is checked by gNB)
    [Tags]    B6  B6_6
    Register UE                            # UE1
    Send NR Measurement Report             event=A1  meas_values=phycell_id=50 srsrp_nr=60 srsrq_nr=20
    Verify Measurement ID is configured    A4  carrier_freq=${ssbFrequency_nrhoif-1}
    Deregister UE
    Register UE
    Apply Config for B_62_63               a1MeashoPrefNRLayerEnabledSA=rsrqCombined
    Verify Measurement is ignored          A1  meas_values=phycell_id=50 srsrp_nr=60 srsrq_nr=20
    Deregister UE

    Apply Config for B_62_63               a1MeashoPrefNRLayerEnabledSA=rsrp
    Register UE                            # UE2   (optional/legacy)
    Send NR Measurement Report             A1
    Apply Config for B_62_63               a1MeashoPrefNRLayerEnabledSA=rsrqCombined
    Verify Measurement is ignored          A1  meas_values=phycell_id=50 srsrp_nr=60 srsrq_nr=20  timeout=1s   # A4 active
    Wait until a4PeriodicMeasCycle finish
    Verify Measurement is ignored          A1  meas_values=phycell_id=50 srsrp_nr=60 srsrq_nr=20

[7]CB009205_B_B6_Parameter_online_modification
    [Documentation]  [4b2] NRCELL.a1MeashoPrefNRLayerEnabledSA is modified from rsrp to rsrpCombined
    ...              (rsrq threshold is checked by gNB)
    [Tags]    B6  B6_7
    Register UE                            # UE1
    Send NR Measurement Report             A1  meas_values=phycell_id=50 srsrp_nr=30 srsrq_nr=50
    Verify Measurement ID is configured    A4  carrier_freq=${ssbFrequency_nrhoif-1}
    Deregister UE
    Register UE
    Apply Config for B_62_63               a1MeashoPrefNRLayerEnabledSA=rsrpCombined
    Verify Measurement is ignored          A1  meas_values=phycell_id=50 srsrp_nr=30 srsrq_nr=50

[8]CB009205_B_B6_Parameter_online_modification
    [Documentation]  [4b3] NRCELL.a1MeashoPrefNRLayerEnabledSA is modified from rsrpCombined to rsrpAndRsrq with Mobility Profile enabled
    [Tags]    B6  B6_8
    Enable Mobility Profile                a1MeashoPrefNRLayerEnabledSA=rsrpCombined
    Register UE                            # UE1
    Verify Measurement is ignored          A1  meas_values=phycell_id=50 srsrp_nr=30 srsrq_nr=50
    A1 measurement configuration for steering UE to preferred NR Layer enabled SA
    ...                                    dist_name=NRBTS-1/NRMOPR_SA-1   a1MeashoPrefNRLayerEnabledSA=rsrpAndRsrq
    Send NR Measurement Report             A1
    Verify Measurement ID is configured    A4  carrier_freq=${ssbFrequency_nrhoif-1}

[10]CB009205_B_B6_Parameter_online_modification
    [Documentation]  Modify NRCELL.a4MeasHigherPrioFreqMaxReactSA
    [Tags]    B6  B6_10
    Register UE                            # UE1
    Verify Measurement ID is configured    A1
    Max Reactivation of A4 Meas for Mobility to higher Prio   1
    a4PeriodicMeasCycles                   a4PeriodicMeasControl=${a4PeriodicMeasControlSA}  numOfa4PeriodicMeasCycles=2
    Verify Measurement is ignored          A1

[9]CB009205_B_B6_Parameter_online_modification
    [Documentation]  CA configuration added for UE
    [Tags]    B6  B6_9
    Register UE                            # UE1
    Verify Measurement ID is configured    A1
    Enable Blind CA
    Verify Measurement ID is configured    A1
    Max Reactivation of A4 Meas for Mobility to higher Prio   1
    a4PeriodicMeasCycles                   numOfa4PeriodicMeasCycles=2
    Verify Measurement ID is configured    A1
    Deregister UE
    Register UE                            pass_regexp=SCellIndex 1 activated successfully at airphone
    Verify Measurement ID is absent        A1

PR669502_No_more_A4_configuration_deconfiguration_after_the_RRE_which_comes_after_the_first_A1_A4_MR
    [Documentation]  CNI_88822_PR669502_No more A4 configuration de-configuration after the RRE which comes after the first A1_A4 MR
    [Tags]    PR669502  CNI_88822
    Enable Additional Configuration for CNI_88822_PR669502
    Register UE to the gNB and setup pdu session                         ue_nr_capabilities=${UE_CAPA_TDD_CNI88822}
    Verify Measurement ID Is Configured    A1                            ue_id=1
    Start data traffic in egate                                          ue_id=1    direction=dl    pdu=1    qfi=1    mbps=1    size=1000
    Verify a4PeriodicMeasCycle before and after RRE
    Verify Measurement is ignored          A1
