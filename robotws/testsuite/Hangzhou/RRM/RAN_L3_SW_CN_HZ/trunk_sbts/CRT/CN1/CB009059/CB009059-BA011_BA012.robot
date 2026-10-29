*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_BOO_AP_LOO
...            owner-ha.zheng    team-CN1ET    release-SBTS24R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    @{NRCELL_11_NRREL}
...    @{PARAMS_FOR_9059}
...    @{PARAMS_FOR_CA}
...    @{8311_enable}
...    @{FDD_DLMIMO}

@{PARAMS_FOR_9059}
...    NRBTS-1/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-12:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-13:cellAggrLevel=FR1 CA incompatible
...    NRBTS-1/NRDRB-14:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-18:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-19:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA

@{FDD_DLMIMO}
...    NRCELL:actGbrRacTdEnhResourcePriority=true
...    NRCELL:actGBRAdmissionControl=off
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRBTS:actSlowPrbPooling=true
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true
...    NRCELL-11:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-12:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-13:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-14:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL:fPdcchMonOccsnPo=2
...    NRCELL-1:maxNumOfCaUsersNRCell=60
...    NRCELL-1:maxNumOfUsersPerNRCell=90
...    NRCELL-1:msg1FrequencyStart=1
...    NRCELL-2:maxNumOfCaUsersNRCell=60
...    NRCELL-2:maxNumOfUsersPerNRCell=90
...    NRCELL-2:msg1FrequencyStart=1
...    NRCELL-3:maxNumOfCaUsersNRCell=120
...    NRCELL-3:maxNumOfUsersPerNRCell=190
...    NRCELL-3:msg1FrequencyStart=10
...    NRCELL-11:maxNumOfUsersPerNRCell=160
...    NRCELL-11:maxNumOfCaUsersNRCell=160
...    NRCELL-12:maxNumOfUsersPerNRCell=160
...    NRCELL-12:maxNumOfCaUsersNRCell=160
...    NRCELL-13:maxNumOfUsersPerNRCell=160
...    NRCELL-13:maxNumOfCaUsersNRCell=160
...    NRCELL-14:maxNumOfUsersPerNRCell=160
...    NRCELL-14:maxNumOfCaUsersNRCell=160
...    NRCELL:maxNumOfSCellAlloc=90
...    NRCELL:maxNumOfUsersPerCell=90
...    NRCELL:maxNumOfRrcSA=90
...    NRCELL:maxNumOfNrDcSnUsers=90

@{8311_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20
...    NRBTS:caBackoffTimerUeOh=20
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=10
...    NRBTS:timerPostOverheating=5
...    NRBTS:actOverheatingAssistance=true
...    NRBTS:timerOverheatIndProhibit=1s

@{PARAMS_FOR_CA}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:maxNumScellsDlFr1=4
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    NRCELL:actCDrx=false
...    NRCELL:actAperCsi=false
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{NRCELL_11_NRREL}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

@{pdu_check}
...    Pdu Session Resource Setup
...    QoS Routing Table
...    QFI:1 5QI:6
...    eventA1
...    freqBandIndicatorNR 71

@{FTT_CA}
...    rrcReconfigurationComplete
...    pcid:60, scellIdx:0
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    frequencyBandList.*\{.*41.*\}\.:::2
...    overheatingIndicationProhibitTimer s1
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully

@{scell_release}
...    SCellIndex 1 deactivated successfully
...    SCellIndex 2 deactivated successfully
...    overheatingAssistanceConfig release : NULL
...    sCellToReleaseList.*\{.*1.*\}\.
...    sCellToReleaseList.*\{.*2.*\}\.
...    eventA1

@{qos_modified_to_9}
...    Created FiveQi:Qfi mapping fiveQi 9 qfi 2
...    Removed FiveQi:Qfi mapping fiveQi 6 qfi 1
...    Added QosFlow with QFI:2 fiveQI:9

@{qos_modified_to_7}
...    Created FiveQi:Qfi mapping fiveQi 7 qfi 2
...    Removed FiveQi:Qfi mapping fiveQi 6 qfi 1
...    Added QosFlow with QFI:2 fiveQI:7

@{qos_modified_to_8}
...    Created FiveQi:Qfi mapping fiveQi 8 qfi 2
...    Removed FiveQi:Qfi mapping fiveQi 6 qfi 1
...    Added QosFlow with QFI:2 fiveQI:8

@{PM_Counters_BA011}
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=3
...    NRCELL-11:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=1

@{OnlineParam_BA012_1}
...    NRBTS:actBufferBasedSCellAddition=disabled
...    NRBTS:actSCellReleaseForInactiveSCell=disabled

@{OnlineParam_BA012_2}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL-11:maxNumOfNonGBRBearersSA=550

@{maxNumOfNonGBRBearersSA_1}
...    NRCELL-11:maxNumOfNonGBRBearersSA=1

@{maxNumOfNonGBRBearersSA_500}
...    NRCELL-11:maxNumOfNonGBRBearersSA=500

@{ics_with_pdu}
...    Initial Context Setup Successful
...    QoS Routing Table
...    QFI:1 5QI:6
...    eventA1
...    freqBandIndicatorNR 71

@{FTT_CA_add}
...    rrcReconfigurationComplete
...    pcid:60, scellIdx:0
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    frequencyBandList.*\{.*41.*\}\.:::2
...    overheatingIndicationProhibitTimer s1
...    eventA2

@{FTT_CA_active}
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully

@{reconfig}
...    eventA1
...    sCellToReleaseList.*\{.*2.*\}\.
...    rrcReconfigurationComplete

@{fail_add_drb3}
...    reportConfigToRemoveList.*\{.*1.*\}\.
...    measIdToRemoveList.*\{.*1.*\}\.

@{pass_add_drb3}
...    QoS Routing Table
...    @{fail_add_drb3}
...    fiveQi 8 qfi 1
...    rrcReconfigurationComplete

@{PM_Counters_BA012}
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-11:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=1

${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039
#This counter shows the number of times SCell addition is allowed for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040
#This counter shows the number of times SCell addition is prevented for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.


${SA_Capa_3T3F_overheating}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B2ABB08873E238F11C7A06
...    7D813E31CF9863CA1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C0000000000000000
...    0040E1E027FFC00001FFF000001700003802CF0F1300038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000
...    E208000010B02B0F13000388C0000042C0AC5C46000E208007104000028581587850001C4C00000C160562E2600071040038500000102C0A
...    C5C4C000E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000082C0AC
...    5C28000E23000711800001058158B898001C46000E140000040B02B0F11800388C00000C2C0AC9C28000E14000710400388C001C4C00000E
...    1617593850001C28000E20800710400389800001C2C3F593850001C41000E2080071180038980000202C0BC1C28000012160205E0E208000
...    0A0B0102F07118000050580817838980000242C040803808D00A202640411740101150B428913639F0E14489B1CF870A244D8E7C3851226C
...    73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081
...    B1CF811204081B1CF810A040D8E7C09502040810206CB5E1C8810204081B2D78722040810206CB5E1C089B1CF870206C00004081B0000102
...    06C0000001F1618C6318C6318C6318C6318C6318DE82E003C00281C1401C0C02500700060240040603E09002000000010000020080000000
...    400000802000008010000060080000400400002802001004010040000300200001C010008000000200002001000012008000030040000500
...    200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED03410000096524040000659494100002
...    96525040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E59494100
...    00C96524040000C594900CD2A8BA55554AAAE95455058AA0B1541A2A94C55268AA031540A2A93555078A160178095028140A05028140A050
...    28140A05028140A050281400282020180300801002101002008040300610080100202018030080600C10100C018040300610080100202018
...    030080100220100C01804030060100C018202004010080100440100200404008010100C018040300601002004802004008080600C0201803
...    0080600C020040080040080300080600C3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828705A0

*** Test Cases ***
CB009059-ET-BA011_CA_backoff_timer_for_UE_overheating_interaction_covBasedA1_SCell_Addition_method
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    CB009059 NRBTS.caBackoffTimerUeOh interaction when SCell Addition method is covBasedA1
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...          UE81-UE83 3CC PCELL(cell-11) SCELLs(cell-1+cell-2)
    ...    2.Test Case Steps:
    ...         Step A. 1.UE81 attaches to Cell-1 and no PDU session be established during the UE ICS.
    ...                 2.AMF sends UE81 the NGAP: PDU SESSION RESOURCE SETUP REQUEST to setup NRDRB-1 message to the gNB-CU-CP.
    ...                 3.A1 scell addition MR send from UE81 to gNB.
    ...                 4.DL data transmission is increased such that the PCell throughput is exceeded.
    ...                 5.UE81 send RRC UE Assistance Information message containing the OverheatingAssistance IE with
    ...                 reducedMaxCCs and reducedCCsDL set to "0".
    ...                 6.A1 scell addition MR send from UE81 to gNB.
    ...                 7.UE81 PDU session modification procedure is triggered and DRB-1 is released and DRB-4 established.
    ...                 8.DL data transmission is increased such that the PCell throughput is exceeded.
    ...         Step B. 1.UE82 attaches to Cell-1 and no PDU session be established during the UE ICS.
    ...                 2.AMF sends UE82 the NGAP: PDU SESSION RESOURCE SETUP REQUEST to setup NRDRB-1 message to the gNB-CU-CP.
    ...                 3.A1 scell addition MR send from UE82 to gNB.
    ...                 4.DL data transmission is increased such that the PCell throughput is exceeded.
    ...                 5.UE82 send RRC UE Assistance Information message containing the OverheatingAssistance IE with
    ...                 reducedMaxCCs and reducedCCsDL set to "0".
    ...                 6.A1 scell addition MR send from UE82 to gNB.
    ...                 7.UE82 PDU session modification procedure is triggered and DRB-1 is released and DRB-2 established.
    ...                 8.DL data transmission is increased such that the PCell throughput is exceeded.
    ...         Step C. 1.UE83 attaches to Cell-1 and no PDU session be established during the UE ICS.
    ...                 2.AMF sends UE83 the NGAP: PDU SESSION RESOURCE SETUP REQUEST to setup NRDRB-1 message to the gNB-CU-CP.
    ...                 3.A1 scell addition MR send from UE83 to gNB.
    ...                 4.DL data transmission is increased such that the PCell throughput is exceeded.
    ...                 5.UE83 send RRC UE Assistance Information message containing the OverheatingAssistance IE with
    ...                 reducedMaxCCs and reducedCCsDL set to "0".
    ...                 6.A1 scell addition MR send from UE83 to gNB.
    ...                 7.UE83 PDU session modification procedure is triggered and DRB-1 is released and DRB-3 established.
    ...                 8.DL data transmission is increased such that the PCell throughput is exceeded.
    ...         Step D. check counters
    ...    3. Expected Results:
    ...         Step A. 1.UE81 attached successfully.
    ...                 2.DRB-1 Setup successfully, A1 scell addition measconfig send to UE.
    ...                 3.gNB-CU sends a private unacknowledged F1AP message to the gNB-DU to activate DL data buffer monitoring.
    ...                 4.gNB-DU triggers a DL buffer monitoring criterion notification to the gNB-CU; scell addition for
    ...                 3CC trigger successfully; RRC Reconfiguration message includes in OtherConfig-v1540 IE the
    ...                 parameter overheatingIndicationProhibitTimer with value equal to NRBTS/timerOverheatIndProhibit.
    ...                 5.gNB-DU sends the MAC CE de-activating all UE configured SCells; gNB-DU sends a private
    ...                 unacknowledged F1AP message to the gNB-CU for SCell release. (The message includes the UE context
    ...                 ID, this SCell's ID, and the reason for the release request:UE overheating and release timer for
    ...                 inactivity exceeded, SCell is released due to overheating and the UE is not in CA, the gNB
    ...                 starts the CA configuration backoff timer for UE overheating (caBackoffTimerUeOh value is used)).
    ...                 A1 scell addition measconfig send to UE.
    ...                 6.GNB suspend the scell addition.
    ...                 7.DRB-1 is released and DRB-4 established, gNB-CU sends a private unacknowledged F1AP message
    ...                 to the gNB-DU to activate DL data buffer monitoring; gNB activates DL buffer monitoring for
    ...                 SCell Addition, GNB-CU send private unacknowledged F1AP message to the gNB-DU to activate DL data buffer monitoring
    ...                 8.gNB-DU triggers a DL buffer monitoring criterion notification to the gNB-CU. UE81 scell addition trigger.
    ...         Step B. 1.UE82 attached successfully.
    ...                 2.DRB-1 Setup successfully, A1 scell addition measconfig send to UE.
    ...                 3.gNB-CU sends a private unacknowledged F1AP message to the gNB-DU to activate DL data buffer monitoring.
    ...                 4.gNB-DU triggers a DL buffer monitoring criterion notification to the gNB-CU; scell addition for
    ...                 3CC trigger successfully; RRC Reconfiguration message includes in OtherConfig-v1540 IE the
    ...                 parameter overheatingIndicationProhibitTimer with value equal to NRBTS/timerOverheatIndProhibit.
    ...                 5.gNB-DU sends the MAC CE de-activating all UE configured SCells; gNB-DU sends a private
    ...                 unacknowledged F1AP message to the gNB-CU for SCell release. (The message includes the UE context
    ...                 ID, this SCell's ID, and the reason for the release request:UE overheating and release timer for
    ...                 inactivity exceeded, SCell is released due to overheating and the UE is not in CA, the gNB
    ...                 starts the CA configuration backoff timer for UE overheating (caBackoffTimerUeOh value is used)).
    ...                 A1 scell addition measconfig send to UE.
    ...                 6.GNB suspend the scell addition.
    ...                 7.DRB-1 is released and DRB-2 established, gNB-CU sends a private unacknowledged F1AP message
    ...                 to the gNB-DU to activate DL data buffer monitoring; gNB activates DL buffer monitoring for
    ...                 SCell Addition, GNB-CU send private unacknowledged F1AP message to the gNB-DU to activate DL data buffer monitoring
    ...                 8.No scell addition trigger.
    ...         Step C. 1.UE82 attached successfully.
    ...                 2.DRB-1 Setup successfully, A1 scell addition measconfig send to UE.
    ...                 3.gNB-CU sends a private unacknowledged F1AP message to the gNB-DU to activate DL data buffer monitoring.
    ...                 4.gNB-DU triggers a DL buffer monitoring criterion notification to the gNB-CU; scell addition for
    ...                 3CC trigger successfully; RRC Reconfiguration message includes in OtherConfig-v1540 IE the
    ...                 parameter overheatingIndicationProhibitTimer with value equal to NRBTS/timerOverheatIndProhibit.
    ...                 5.gNB-DU sends the MAC CE de-activating all UE configured SCells; gNB-DU sends a private
    ...                 unacknowledged F1AP message to the gNB-CU for SCell release. (The message includes the UE context
    ...                 ID, this SCell's ID, and the reason for the release request:UE overheating and release timer for
    ...                 inactivity exceeded, SCell is released due to overheating and the UE is not in CA, the gNB
    ...                 starts the CA configuration backoff timer for UE overheating (caBackoffTimerUeOh value is used)).
    ...                 A1 scell addition measconfig send to UE.
    ...                 6.GNB suspend the scell addition.
    ...                 7.DRB-1 is released and DRB-3 established, gNB-CU sends a private unacknowledged F1AP message
    ...                 to the gNB-DU to activate DL data buffer monitoring; gNB activates DL buffer monitoring for
    ...                 SCell Addition, GNB-CU send private unacknowledged F1AP message to the gNB-DU to activate DL data buffer monitoring
    ...                 8.No scell addition trigger.
    ...         Step D. check counters successful
    [Tags]    QC_46730    AB011    CA_LABEL-FTT(10Mhz_FDD_n71+60Mhz_TDD_n41+60Mhz_TDD_n41)
    clear counter files    False
    backoff timer interaction with A1 SCell Addition    ue_id=81    DRB_add=4    qos_modified=${qos_modified_to_9}
    ...    pass_CA=${FTT_CA}
    backoff timer interaction with A1 SCell Addition    ue_id=82    DRB_add=2    qos_modified=${qos_modified_to_7}
    ...    pass_CA=Started Downlink    fail_CA=${FTT_CA}
    backoff timer interaction with A1 SCell Addition    ue_id=83    DRB_add=3    qos_modified=${qos_modified_to_8}
    ...    pass_CA=Started Downlink    fail_CA=${FTT_CA}
    check counters    ${PM_Counters_BA011}
#    Check Wireshark Log    ${CURDIR}${/}A2A_BA011${/}a2a_gnb.ini    wait_string=UEContextReleaseComplete::9

CB009059-ET-BA012_CA_allowed_after_last_SCell_release_covBasedA1_SCell_Addition
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    SCell(s) are released due to A2 measurement report received. After the last SCell Release the gNB activates
    ...    event A1 measurement in the gNB-DU if at least one FR1 CA eligible DRB is established and no FR1 CA
    ...    incompatible DRB is established.
    ...    The last SCell is released due to one of the following:
    ...    Prolonged data inactivity, UE overheating, Bad SCell RLQ
    ...    After the SCell Release due to data inactivity or bad SCell RLQ, if the gNB is no longer in CA, the gNB
    ...    activates DL buffer monitoring in the gNB-DU if at least one FR1 CA eligible DRB is established and no FR1 CA
    ...    incompatible DRB is established. As per legacy behavior, if the last SCell is released due to UE overheating,
    ...    the caBackoffTimerUeOh timer is started to delay the check for activating DL buffer monitoring for SCell Addition.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...          UE81 3CC PCELL(cell-11) SCELLs(cell-1+cell-2)
    ...    2.Test Case Steps:
    ...         Step A. UE81 attaches to Cell-1 and PDU session be established during the UE ICS.
    ...                 DRB-1 is allocated in PDU session 1
    ...         Step B. A1 scell addition MR send from UE81 to gNB.
    ...         Step C. DL data transmission is increased such that the PCell throughput is exceeded.
    ...         Step D. UE81 triggers A2 measurement reports for Cell-1
    ...         Step E. UE81 triggers A2 measurement reports for Cell-2
    ...         Step F. online change cell1.maxNumOfNonGBRBearersSA=1, UE1 PDU session resource setup procedure is
    ...                 triggered and DRB-3 is established.
    ...         Step G. online change cell1.maxNumOfNonGBRBearersSA=500, UE1 PDU session resource setup procedure is
    ...                 triggered and DRB-3 is established.
    ...         Step H. check counters
    ...    3. Expected Results:
    ...         Step A: UE81 attaches and DRB setup successful
    ...         Step B: gNB configures Cell-1 and Cell-2 as SCells at the UE. A2 based SCell release measconfig send to UE
    ...         Step C: DRB-1 non-GBR DL data is scheduled on the PCell and SCells.
    ...         Step D. The gNB releases cell1 SCell
    ...         Step E. The gNB releases cell2 SCell, UE is configured with A1 measurement for SCell Addition In the
    ...                 same RRCReconfiguration message for the last SCell to be released
    ...         Step F. PDU session resource setup procedure fails, the gNB keeps event A1 measurement for SCell
    ...                 Addition activated at the UE.
    ...         Step G. A1 measurement for SCell Addition is deactivated in the same RRCReconfiguration message that is
    ...                 used for the DRB configuration to the UE.
    [Tags]    QC_344356    AB012    CA_LABEL-FTT(10Mhz_FDD_n71+60Mhz_TDD_n41+60Mhz_TDD_n41)
    clear counter files
    OnlineParamChange    ${OnlineParam_BA012_1}
    UE attach with PDU Session resoure setup    ics=off    pass_pdu=${ics_with_pdu}
    trigger A1 scell addtion with CA add    pass_CA=${FTT_CA_add}
    Sent Throughput and trigger CA active    pass_CA=${FTT_CA_active}
    Verify Throughput pcell and scells
    Trigger A2 ScellRelease    carrierfreq=504990    scell_id=1
    Trigger A2 ScellRelease    carrierfreq=531870    scell_id=2    reconfig=${reconfig}
    online change and trigger DRB3    fail_pdu=${fail_add_drb3}   pass_pdu=${pass_add_drb3}
    check counters    ${PM_Counters_BA012}
    [Teardown]    BA012_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/7cells_3T4F_8pipes

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    Update Cfg    ue_nr_capabilities id=81 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosflow id=5 5qi=71 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3,4,5 qos_rules=1,2 default=on ue=1-6 amf=1

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

BA012_Teardown
    OnlineParamChange    ${OnlineParam_BA012_2}
    Common Test Teardown And Stop Capture Logs

UE attach with PDU Session resoure setup
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${ics}=on    ${pass_pdu}=none
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_3T3F_overheating}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_param id=1 send_ics_registration=${ics}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${pass_pdu}

trigger A1 scell addtion with no CA add
    [Arguments]    ${ue_id}=81    ${carrierfreq}=127450    ${srsrp_nr}=90    ${srsrq_nr}=90    ${pass_CA}=none    ${fail_CA}=none
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=${srsrp_nr}
    ...    pass_regexp=measurementReport    fail_regexp=${fail_CA}

Sent Throughput and trigger CA add
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${pass_CA}=none    ${fail_CA}=none
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=1    pass_regexp=${pass_CA}
    ...    fail_regexp=${fail_CA}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=35 trf_id=1    pass_regexp=Started Uplink

UE Assistance Information for Overheating
    [Arguments]    ${ue_id}=81    ${scell_release}=none
    Execute Egate Command
    ...    ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsUL=0 reducedCCsDL=0    pass_regexp=${scell_release}

stop Throughput
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id}    pass_regexp=Traffic was stopped

PDU Session modified
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${DRB_add}=4    ${DRB_del}=1    ${qos_modified}=none
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${DRB_add} qosflows_to_del=${DRB_del} by=amf
    ...    pass_regexp=${qos_modified}

backoff timer interaction with A1 SCell Addition
    [Arguments]    ${ue_id}=81    ${DRB_add}=4    ${qos_modified}=none    ${pass_CA}=none    ${fail_CA}=none
    UE attach with PDU Session resoure setup    ue_id=${ue_id}    pass_pdu=${pdu_check}
    trigger A1 scell addtion with no CA add    ue_id=${ue_id}    fail_CA=${FTT_CA}
    Sent Throughput and trigger CA add    ue_id=${ue_id}    pass_CA=${FTT_CA}
    Verify Throughput pcell and scells    ue_id=${ue_id}
    UE Assistance Information for Overheating    ue_id=${ue_id}    scell_release=${scell_release}
    stop Throughput    ue_id=${ue_id}
    trigger A1 scell addtion with no CA add    ue_id=${ue_id}    fail_CA=${FTT_CA}
    PDU Session modified    ue_id=${ue_id}    DRB_add=${DRB_add}    qos_modified=${qos_modified}
    Sent Throughput and trigger CA add    ue_id=${ue_id}    qfi_id=2    pass_CA=${pass_CA}    fail_CA=${fail_CA}
    Release Ues    ue_type=all

trigger A1 scell addtion with CA add
    [Arguments]    ${ue_id}=81    ${carrierfreq}=127450    ${srsrp_nr}=90    ${srsrq_nr}=90    ${pass_CA}=none    ${fail_CA}=none
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=${srsrp_nr}
    ...    pass_regexp=${pass_CA}    fail_regexp=${fail_CA}

Sent Throughput and trigger CA active
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${pass_CA}=none    ${fail_CA}=none
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=1    pass_regexp=${pass_CA}
    ...    fail_regexp=${fail_CA}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=35 trf_id=1    pass_regexp=Started Uplink

Verify Throughput pcell and scells
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=340    ${Tput_ul}=30    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000> 0
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${ue_dl_tput}    Evaluate    ${dl_throughput}+${scell1_tput}+${scell2_tput}
    Should Be True    ${ue_dl_tput}/1000 >${Tput_dl}

Trigger A2 ScellRelease
    [Arguments]    ${carrierfreq}=504990    ${ue_id}=81    ${scell_id}=1    ${reconfig}=rrcReconfigurationComplete
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=${carrierfreq}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=7 scell_rsrq=7
    ...    pass_regexp=${reconfig}

online change and trigger DRB3
    [Arguments]    ${ue_id}=81    ${fail_pdu}=none    ${pass_pdu}=none
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    OnlineParamChange    ${maxNumOfNonGBRBearersSA_1}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1
    ...    pass_regexp=unsuccessful due to RAN radio resources not available     fail_regexp=${fail_pdu}
    OnlineParamChange    ${maxNumOfNonGBRBearersSA_500}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=3 gw=3 nwslice=1    pass_regexp=${pass_pdu}
    Release Ues    ue_type=all
