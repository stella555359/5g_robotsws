*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_BOO_AP_LOO
...            owner-Tingjian.Mao    team-CN1ET    release-SBTS24R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}CB009059-BA008_BA009_BA010.robot
@{PARAMS_IN_SCF}
...    @{NRCELL_3_NRREL}
...    @{NRCELL_11_NRREL}
...    @{PARAMS_FOR_9059}
...    @{PARAMS_FOR_CA}
...    @{8311_enable}
...    @{Overheating_enable}
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRBTS:actSlowPrbPooling=true
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true

@{PARAMS_FOR_9059}
...    NRBTS-1/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-12:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-13:cellAggrLevel=FR1 CA incompatible
...    NRBTS-1/NRDRB-14:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-18:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-19:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA

@{8311_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20

@{Overheating_enable}
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
...    NRCELL:actCDrx=true
...    NRCELL:actAperCsi=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{NRCELL_3_NRREL}
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:nrDcAllowed=false
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-2:lcrId=2
...    NRCELL-3/NRREL-2:nrDcAllowed=false
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-11:gNbId=1
...    NRCELL-3/NRREL-11:gNbIdLength=22
...    NRCELL-3/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-11:lcrId=11
...    NRCELL-3/NRREL-11:nrDcAllowed=false
...    NRCELL-3/NRREL-11:removeNotAllowed=false
...    NRCELL-3/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-13:gNbId=1
...    NRCELL-3/NRREL-13:gNbIdLength=22
...    NRCELL-3/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-3/NRREL-13:lcrId=13
...    NRCELL-3/NRREL-13:nrDcAllowed=false
...    NRCELL-3/NRREL-13:removeNotAllowed=false
...    NRCELL-3/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-13:gnbPlmn:mncLength=3

@{NRCELL_11_NRREL}
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
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
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

@{scell_release}
...    SCellIndex 1 deactivated successfully
...    SCellIndex 2 deactivated successfully
...    overheatingAssistanceConfig release : NULL
...    sCellToReleaseList.*\{.*1.*\}\.
...    sCellToReleaseList.*\{.*2.*\}\.

@{PM_Counters_BA008}
...    NRCELL-3:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=2
...    NRCELL-3:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0

@{PM_Counters_BA009}
...    NRCELL-3:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=7
...    NRCELL-3:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=4

@{PM_Counters_BA010}
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=3
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
CB009059-ET-BA008_ICS_and_then_BF_monitoring_activation_only_for_FR1_CA_eligible_DRB_blind_BF_CA
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...      UE attaches to a cell during initial context setup (ICS) and at least one FR1 CA eligible DRB is established.
    ...      After ICS, DL buffer monitoring is activated.
    ...      UE attaches to a cell during initial context setup (ICS) and at least one FR1 CA eligible DRB is established.
    ...      After ICS, DL buffer monitoring for SCell Addition is activated. DL buffer monitoring for SCell Addition is
    ...      performed only on the FR1 CA eligible DRB.
    ...      At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...      NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...          UE81,UE82 5CC PCELL(cell-3) SCELLs(cell-1+cell-2+cell11+cell13)
    ...    2.Test Case Steps:
    ...         Step A. UE81 attaches to Cell-3 and DRB-1 is allocated in PDU session 1
    ...         Step B. Sufficient DL data to exceed the PCell throughput is initiated for DRB-1
    ...         Step C. UE82 attaches to Cell-3 and PDU session be established during the UE ICS. DRB-1,DRB-2 are allocated in PDU session 1
    ...         Step D. Sufficient DL data to exceed the PCell throughput is initiated for DRB-2
    ...         Step F. UE is released and check counters
    ...    3. Expected Results:
    ...         Step A: UE81 attaches and DRB setup successful,The gNB-CU sends a private unacknowledged F1AP message to
    ...                 the gNB-DU to activate DL data buffer monitoring
    ...         Step B: The gNB-DU sends private unacknowledged F1AP message to the gNB-CU to inform the gNB-CU of the DL
    ...                 buffer overflow condition,The gNB configures the UE with 5CC,DRB-1 non-GBR DL data is scheduled on
    ...                 the PCell and SCells
    ...         Step C: UE82 attaches and DRBs setup successful,The gNB-CU sends a private unacknowledged F1AP message to
    ...                 the gNB-DU to activate DL data buffer monitoring for DRB-1.
    ...         Step D. The gNB-DU NOT sends private unacknowledged F1AP message,NO CA configured for UE82
    ...         Step F. UEs is released and check counters successful
    [Tags]    QC_344361    CA_LABEL-TTTFF(100Mhz_TDD_n77+60Mhz_TDD_n41+60Mhz_TDD_n41+10Mhz_FDD_n71+10Mhz_FDD_n66)
    clear counter files    False
    Verify UE81 5CC when the traffic exceeds the PCELL with eligible DRB
    Verify UE82 NO CA when the traffic exceeds the PCELL with Not FR1 CA eligible DRB
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}A2A_BA008${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    check counters    pm_counters_expression=${PM_Counters_BA008}

CB009059-ET-BA009_DL_buffer_monitoring_handling_when_criteria_for_DRB_FR1_CA_eligibility_are_not_met
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...      UE is attached to the PCell and DL buffer monitoring for SCell Addition is activated. A PDU session setup/modification
    ...      occurs such that the UE is no longer FR1 CA eligible. A subsequent DL buffer monitoring trigger is ignored while the
    ...      UE is in such configuration.
    ...      At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...      NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...          UE81-UE86 5CC PCELL(cell-3) SCELLs(cell-1+cell-2+cell11+cell13)
    ...    2.Test Case Steps:
    ...         Step A. UE81 attaches to Cell-3 and DRB-1 Setup in PDU1 DRB-3 Setup in PDU2 then exceeded TP in PCELL
    ...         Step B. UE82 attaches to Cell-3 and DRB-2 Setup in PDU1,DRB-2 modification DRB-1 then exceeded TP in PCELL
    ...         Step C. UE83 attaches to Cell-3 and DRB-1 DRB-3 Setup in PDU1 then release DRB-3 exceeded TP in PCELL
    ...         Step D. UE84 attaches to Cell-3 and DRB-1 Setup in PDU1 meanwhile DRB-3 Setup in PDU2 then release PDU2 exceeded TP in PCELL
    ...         Step E. UE85 attaches to Cell-3 and DRB-1 Setup in PDU1,release DRB-1,DRB-2 Setup in PDU1 then exceeded TP in PCELL
    ...         Step F. UE86 attaches to Cell-3 and DRB-1 Setup in PDU1 DRB-2 Setup in PDU2, release PDU1 then exceeded TP in PCELL
    ...         Step G. UE is released and check counters
    ...    3. Expected Results:
    ...         Step A: UE81 attaches and DRB-1 setups successful,activate DL data buffer monitoring,DRB-3 setups successful
    ...                 but NO CA when exceeded TP in PCELL
    ...         Step B: UE82 attaches and DRB-2 setups successful,NO buffer monitoring activated
    ...                 modification successful then activate DL data buffer monitoring
    ...                 5CC when exceeded TP in PCELL
    ...         Step C: UE83 attaches and DRBs setup successful,NO buffer monitoring activated
    ...                 released DRB-3 successful,activate DL data buffer monitoring
    ...                 5CC when exceeded TP in PCELL
    ...         Step D: UE84 attaches and DRBs setup successful,NO buffer monitoring activated
    ...                 released PDU2 successful,activate DL data buffer monitoring
    ...                 5CC when exceeded TP in PCELL
    ...         Step E. UE85 attaches and DRB-1 setups successful,activate DL data buffer monitoring
    ...                 DRB-1 release successfully,DRB-2 Setup successfully
    ...                 but NO CA when exceeded TP in PCELL
    ...         Step F. UE86 attaches and DRBS setups successful,activate DL data buffer monitoring
    ...                 PDU1 release successfully
    ...                 but NO CA when exceeded TP in PCELL
    ...         Step G. UE is released and check counters successful
    [Tags]    QC_344357    CA_LABEL-TTTFF(100Mhz_TDD_n77+60Mhz_TDD_n41+60Mhz_TDD_n41+10Mhz_FDD_n71+10Mhz_FDD_n66)    AP_REG
    clear counter files
    UE81 register and PDU Session Setup with Qosflow
    UE82 register and PDU Session Setup with Qosflow
    UE83 register and PDU Session Setup with Qosflow
    UE84 register and PDU Session Setup with Qosflow
    UE85 register and PDU Session Setup with Qosflow
    UE86 register and PDU Session Setup with Qosflow
    Check Wireshark Log    ${CURDIR}${/}A2A_BA009${/}a2a.ini    wait_string=UEContextReleaseComplete::21
    check counters    pm_counters_expression=${PM_Counters_BA009}

CB009059-ET-BA010_CA_backoff_timer_for_UE_overheating_interaction_blind_SCell_Addition_method
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...      CB009059 NRBTS.caBackoffTimerUeOh interaction when the SCell Addition method is blind.
    ...      UE is in such configuration.
    ...      At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...      NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...          UE81-UE83 3CC PCELL(cell-11) SCELLs(cell-1+cell-2)
    ...    2.Test Case Steps:
    ...         Step A. UE81 attaches to Cell-11 and DRB-1 Setup in PDU1 then exceeded TP in PCELL
    ...         Step B. UE81 Overheating
    ...         Step C. Before caBackoffTimerUeOh timeout,DRB-1 is released and DRB-4 established.
    ...         Step D. UE82 attaches to Cell-11 and DRB-1 Setup in PDU1 then exceeded TP in PCELL
    ...         Step E. UE82 Overheating
    ...         Step F. Before caBackoffTimerUeOh timeout,DRB-1 is released and DRB-2 established.
    ...         Step G. UE83 attaches to Cell-11 and DRB-1 Setup in PDU1 then exceeded TP in PCELL
    ...         Step H. UE83 Overheating
    ...         Step I. Before caBackoffTimerUeOh timeout,DRB-1 is modification to DRB-3
    ...         Step J. UE is released and check counters
    ...    3. Expected Results:
    ...         Step A: UE81 attaches and DRB-1 setups successful,activate DL data buffer monitoring
    ...                 3CC when exceeded TP in PCELL
    ...         Step B: De-activating all UE81 configured SCells and SCell released after sCellInactivityReleaseTimer timeout
    ...         Step C: DRB-1 is released and DRB-4 established successful,after caBackoffTimerUeOh timeout activate DL data
    ...                 buffer monitoring,3CC when exceeded TP in PCELL
    ...         Step D: UE82 attaches and DRB-1 setups successful,activate DL data buffer monitoring
    ...                 3CC when exceeded TP in PCELL
    ...         Step E. De-activating all UE82 configured SCells and SCell released after sCellInactivityReleaseTimer timeout
    ...         Step F. DRB-1 is released and DRB-2 established successful,after caBackoffTimerUeOh timeout
    ...                 NO buffer monitoring activated,NO CA when exceeded TP in PCELL
    ...         Step G. UE83 attaches and DRB-1 setups successful,activate DL data buffer monitoring
    ...                 3CC when exceeded TP in PCELL
    ...         Step H. De-activating all UE83 configured SCells and SCell released after sCellInactivityReleaseTimer timeout
    ...         Step I. DRB-3 Setup successfully,NO buffer monitoring activated,NO CA when exceeded TP in PCELL
    ...         Step J. UE is released and check counters successful
    [Tags]    QC_344365    CA_LABEL-FTT(10Mhz_FDD_n71+60Mhz_TDD_n41+60Mhz_TDD_n41)
    clear counter files
    UE81 Overheating FR1 CA eligible DRB
    UE82 Overheating Not FR1 CA eligible DRB
    UE83 Overheating FR1 CA incompatible DRB
    Check Wireshark Log    ${CURDIR}${/}A2A_BA010${/}a2a.ini    wait_string=UEContextReleaseComplete::9
    check counters    pm_counters_expression=${PM_Counters_BA010}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/7cells_3T4F_8pipes

Modify Cfg
    Update Cfg    ue_param id=81,82,83,84,85,86 ue_nr_capabilities=${SA_Capa_3T3F_overheating} nr_usage_setting=voice_centric
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    Update Cfg    ue_nr_capabilities id=81,82,83,84,85,86 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosflow id=5 5qi=71 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3,4,5 qos_rules=1,2 default=on ue=81-86 amf=1

UE PDU Session Setup with Qosflow
    [Arguments]    ${ue_id}=81    ${cell_id}=3    ${qos_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify qos_flow=${qos_id} default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table
    Execute Egate Command    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=0
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=1 scell=0

Verify UE81 5CC when the traffic exceeds the PCELL with eligible DRB
    UE PDU Session Setup with Qosflow
    Sent Throughput
    Verify Throughput pcell and scells 5CC    Tput_dl=270

UE PDU Session Setup with multiple Qosflow
    [Arguments]    ${ue_id}=81    ${cell_id}=3    ${qos_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${qos_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=QoS Routing Table
    Execute Egate Command    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=0
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=1 scell=0

Verify UE82 NO CA when the traffic exceeds the PCELL with Not FR1 CA eligible DRB
    UE PDU Session Setup with multiple Qosflow    ue_id=82
    Sent Throughput    ue_id=82    qfi_id=2
    Verify no Scell    ue_id=82    qfi_id=2

Sent Throughput
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=30 trf_id=1    pass_regexp=Started Uplink

Verify Throughput pcell and scells 5CC
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=150    ${Tput_ul}=27    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${scell3_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Should Be True    ${scell3_tput}/1000 > 0
    ${scell4_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=4    type=pdsch    rate_type=ave
    Should Be True    ${scell4_tput}/1000 > 0

Verify Throughput pcell and scells 3CC
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=150    ${Tput_ul}=27    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0

Verify no Scell
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=120    ${Tput_ul}=27    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[1]
    Should Not Match Regexp    ${scell_tput}    CellIndex-[2]
    Should Not Match Regexp    ${scell_tput}    CellIndex-[3]
    Should Not Match Regexp    ${scell_tput}    CellIndex-[4]
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Make UE84 Exit From Idle To Connected And Check Expected Output
    Execute Egate Command    ue_im_entry id=84 by=ue    pass_regexp=Release Complete    timeout=100s
    ${ue_status}=    Execute Egate Command    ue_disp id=84    pass_regexp=state    timeout=20s
    Should Contain    ${ue_status}    IDLE
    ${ret1}    Execute Egate Command    ue_im_exit id=84 by=ue    pass_regexp=Setup QosFlow with QFI:1 5QI:6    timeout=100s
    Should Contain    ${ret1}    Setup QosFlow with QFI:1 5QI:8

UE81 register and PDU Session Setup with Qosflow
    [Arguments]    ${ue_id}=81
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    UE PDU Session Setup with Qosflow
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1    pass_regexp=QoS Routing Table
    Sent Throughput
    Sent Throughput    pdu_id=2
    Verify no Scell
    Release UEs    ue_type=all

UE82 register and PDU Session Setup with Qosflow
    [Arguments]    ${ue_id}=82
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    UE PDU Session Setup with Qosflow    ue_id=${ue_id}    qos_id=2
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1 qosflows_to_del=2 by=amf
    ...    pass_regexp=QoS Routing Table
    Sent Throughput    ue_id=${ue_id}    qfi_id=2
    Verify Throughput pcell and scells 5CC    ue_id=${ue_id}    qfi_id=2    Tput_dl=270
    Release UEs    ue_type=all

UE83 register and PDU Session Setup with Qosflow
    [Arguments]    ${ue_id}=83
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=3
    UE PDU Session Setup with Qosflow    ue_id=${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=3 by=amf    pass_regexp=QoS Routing Table
    Sent Throughput    ue_id=${ue_id}    qfi_id=1
    Verify Throughput pcell and scells 5CC    ue_id=${ue_id}    qfi_id=1    Tput_dl=270
    Release UEs    ue_type=all

UE84 register and PDU Session Setup with Qosflow
    [Arguments]    ${ue_id}=84
    Execute Egate Command    smf_param id=1 reset
    UE PDU Session Setup with Qosflow    ue_id=${ue_id}
    Execute Egate Command    qosflow_modify qos_flow=3 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1    pass_regexp=QoS Routing Table
    Make UE84 Exit From Idle To Connected And Check Expected Output
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=2 by=amf    pass_regexp=rrcReconfigurationComplete
    Sent Throughput    ue_id=${ue_id}
    Verify Throughput pcell and scells 5CC    ue_id=${ue_id}    Tput_dl=270
    Release UEs    ue_type=all

UE85 register and PDU Session Setup with Qosflow
    [Arguments]    ${ue_id}=85
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    UE PDU Session Setup with Qosflow    ue_id=${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 qosflows_to_del=1 by=amf
    ...    pass_regexp=QoS Routing Table
    Sent Throughput    ue_id=${ue_id}    qfi_id=2
    Verify no Scell    ue_id=${ue_id}    qfi_id=2    Tput_dl=120
    Release UEs    ue_type=all

UE86 register and PDU Session Setup with Qosflow
    [Arguments]    ${ue_id}=86
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    UE PDU Session Setup with Qosflow    ue_id=${ue_id}
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1    pass_regexp=QoS Routing Table
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1 by=amf    pass_regexp=rrcReconfigurationComplete
    Sent Throughput    ue_id=${ue_id}    pdu_id=2
    Verify no Scell    ue_id=${ue_id}    pdu_id=2    Tput_dl=120
    Release UEs    ue_type=all

UE81 Overheating FR1 CA eligible DRB
    [Arguments]    ${ue_id}=81    ${cell_id}=11
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    UE PDU Session Setup with Qosflow    ue_id=${ue_id}    cell_id=${cell_id}
    Sent Throughput    ue_id=${ue_id}
    Verify Throughput pcell and scells 3CC    ue_id=${ue_id}    Tput_dl=200
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsUL=0 reducedCCsDL=0
    ...    pass_regexp=${scell_release}
    Verify no Scell    ue_id=${ue_id}    Tput_dl=30
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=4 qosflows_to_del=1 by=amf
    ...    pass_regexp=QoS Routing Table
    Verify NO Scell add when caBackoffTimerUeOh is running
    sleep    10s    #after caBackoffTimerUeOh timeout
    Verify Throughput pcell and scells 3CC    ue_id=${ue_id}    qfi_id=2    Tput_dl=200
    Release UEs    ue_type=all

Verify NO Scell add when caBackoffTimerUeOh is running
    [Arguments]    ${ue_id}=81
    ${ret1}=    Sent Throughput    ue_id=${ue_id}    qfi_id=2
    should not contain    ${ret1}=    SCellIndex 1 activated successfully at airphone
    should not contain    ${ret1}=    SCellIndex 2 activated successfully at airphone

UE82 Overheating Not FR1 CA eligible DRB
    [Arguments]    ${ue_id}=82    ${cell_id}=11
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    UE PDU Session Setup with Qosflow    ue_id=${ue_id}    cell_id=${cell_id}
    Sent Throughput    ue_id=${ue_id}
    Verify Throughput pcell and scells 3CC    ue_id=${ue_id}    Tput_dl=200
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsUL=0 reducedCCsDL=0
    ...    pass_regexp=${scell_release}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 qosflows_to_del=1 by=amf
    ...    pass_regexp=QoS Routing Table
    sleep    10s    #after caBackoffTimerUeOh timeout
    Sent Throughput    ue_id=${ue_id}    qfi_id=2
    Verify no Scell    ue_id=${ue_id}    qfi_id=2    Tput_dl=30
    Release UEs    ue_type=all

UE83 Overheating FR1 CA incompatible DRB
    [Arguments]    ${ue_id}=83    ${cell_id}=11
    UE PDU Session Setup with Qosflow    ue_id=${ue_id}    cell_id=${cell_id}
    Sent Throughput    ue_id=${ue_id}
    Verify Throughput pcell and scells 3CC    ue_id=${ue_id}    Tput_dl=200
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsUL=0 reducedCCsDL=0
    ...    pass_regexp=${scell_release}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 qosflows_to_del=1 by=amf
    ...    pass_regexp=QoS Routing Table
    sleep    10s    #after caBackoffTimerUeOh timeout
    Sent Throughput    ue_id=${ue_id}    qfi_id=2
    Verify no Scell    ue_id=${ue_id}    qfi_id=2    Tput_dl=30
    Release UEs    ue_type=all
