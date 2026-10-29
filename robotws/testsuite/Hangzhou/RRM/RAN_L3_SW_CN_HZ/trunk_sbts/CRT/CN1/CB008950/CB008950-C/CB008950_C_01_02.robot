*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_MP_AP_LOOO    team-CN1ET
...    owner-Delun.Li    release-SBTS24R3    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_STARTUP_RETRY}    2
${SYSCOM_FLAG}    ${True}
@{PARAMS_IN_IPHY_XML}
...    GeneralSettings:l3Timeout=30

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_other}
...    @{PARAMS_FOR_NRCELL1}
...    @{PARAMS_FOR_8950}
...    @{PARAMS_FOR_8290}

@{PARAMS_FOR_NRCELL1}
...    NRCELL-1/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-5:gNbId=1
...    NRCELL-1/NRREL-5:gNbIdLength=22
...    NRCELL-1/NRREL-5:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-5:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-5:lcrId=5
...    NRCELL-1/NRREL-5:nrDcAllowed=false
...    NRCELL-1/NRREL-5:removeNotAllowed=false
...    NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-5:isRplCellForPSCell=true
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:nrDcAllowed=false
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:isRplCellForPSCell=true
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=1
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:nrDcAllowed=false
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:isRplCellForPSCell=true
...    NRCELL-1/NRREL-15:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-15:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-15:gNbId=1
...    NRCELL-1/NRREL-15:gNbIdLength=22
...    NRCELL-1/NRREL-15:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-15:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-15:lcrId=15
...    NRCELL-1/NRREL-15:nrDcAllowed=false
...    NRCELL-1/NRREL-15:removeNotAllowed=false
...    NRCELL-1/NRREL-15:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-15:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-15:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-15:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-15:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-15:isRplCellForPSCell=true
...    NRCELL-15:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-19:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-19:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-19:gNbId=1
...    NRCELL-1/NRREL-19:gNbIdLength=22
...    NRCELL-1/NRREL-19:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-19:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-19:lcrId=19
...    NRCELL-1/NRREL-19:nrDcAllowed=false
...    NRCELL-1/NRREL-19:removeNotAllowed=false
...    NRCELL-1/NRREL-19:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-19:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-19:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-19:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-19:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-19:isRplCellForPSCell=true
...    NRCELL-1/NRREL-20:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-20:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-20:gNbId=1
...    NRCELL-1/NRREL-20:gNbIdLength=22
...    NRCELL-1/NRREL-20:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-20:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-20:lcrId=20
...    NRCELL-1/NRREL-20:nrDcAllowed=false
...    NRCELL-1/NRREL-20:removeNotAllowed=false
...    NRCELL-1/NRREL-20:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-20:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-20:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-20:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-20:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-20:isRplCellForPSCell=true
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-19:actK1Opt=intra-gNB
...    NRCELL-20:actK1Opt=intra-gNB
...    NRCELL-13:actK1Opt=intra-gNB
...    NRCELL-17:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-5:sCellPrio=1
...    NRCELL-1/NRREL-15:sCellPrio=15
...    NRCELL-1/NRREL-11:sCellPrio=11
...    NRCELL-1/NRREL-12:sCellPrio=12
...    NRCELL-1/NRREL-19:sCellPrio=2
...    NRCELL-1/NRREL-20:sCellPrio=2
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{PARAMS_FOR_other}
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRBTS:srbInactivityTimerSA=60
...    NRCELL:filterCoeffSsbRsrq=fc4
...    NRBTS/NRSCTP-1:sctpProfile:sctpRtoInit=30000
...    NRBTS/NRSCTP-1:sctpProfile:sctpRtoMin=30000

@{PARAMS_FOR_CA}
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{PARAMS_FOR_8950}
...    NRBTS:actFlexSCellSelectFr1=true
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:sCellActivationMethod=blind
...    NRCELL-1/NRREL-6:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-6:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-6:gNbId=1
...    NRCELL-1/NRREL-6:gNbIdLength=22
...    NRCELL-1/NRREL-6:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-6:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-6:lcrId=6
...    NRCELL-1/NRREL-6:nrDcAllowed=false
...    NRCELL-1/NRREL-6:removeNotAllowed=false
...    NRCELL-1/NRREL-6:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-6:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-6:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-6:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-6:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-6:isRplCellForPSCell=true
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-13:gNbId=1
...    NRCELL-1/NRREL-13:gNbIdLength=22
...    NRCELL-1/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-13:lcrId=13
...    NRCELL-1/NRREL-13:nrDcAllowed=false
...    NRCELL-1/NRREL-13:removeNotAllowed=false
...    NRCELL-1/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-13:isRplCellForPSCell=true
...    NRCELL-1/NRREL-17:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-17:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-17:gNbId=1
...    NRCELL-1/NRREL-17:gNbIdLength=22
...    NRCELL-1/NRREL-17:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-17:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-17:lcrId=17
...    NRCELL-1/NRREL-17:nrDcAllowed=false
...    NRCELL-1/NRREL-17:removeNotAllowed=false
...    NRCELL-1/NRREL-17:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-17:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-17:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-17:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-17:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-17:isRplCellForPSCell=true
...    NRCELL-1/NRREL-17:sCellPrio=2
...    NRCELL-1/NRREL-6:sCellPrio=7
...    NRCELL-1/NRREL-13:sCellPrio=13
...    @{PARAMS_FOR_CA}
...    @{cellDepType}

@{PARAMS_FOR_8290}
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0
...    NRCELL-1:maxNumScellsDlFr1=${EMPTY}
...    NRCELL-11:weightForSCellSelection=60
...    NRCELL-12:weightForSCellSelection=60
...    NRBTS/NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS:actAllowedBcListMrdcPrioBcSel=true
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actHighestEstNrTputBcSel=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:maxNumScellsDl=3
...    NRBTS:maxNumScellsUl=3

@{cellDepType}
...    NRCELL-17:cellDepType=NSA
...    NRCELL-17:trackingAreaDN=${EMPTY}
...    NRCELL-17:msg1FrequencyStart=15
...    NRCELL-17:configuredEpsTac=200
...    NRCELL-17:nrSysInfoProfileDN=${EMPTY}
...    NRCELL-19:cellDepType=NSA
...    NRCELL-19:trackingAreaDN=${EMPTY}
...    NRCELL-19:msg1FrequencyStart=15
...    NRCELL-19:configuredEpsTac=200
...    NRCELL-19:nrSysInfoProfileDN=${EMPTY}
...    NRCELL-20:cellDepType=NSA
...    NRCELL-20:trackingAreaDN=${EMPTY}
...    NRCELL-20:msg1FrequencyStart=15
...    NRCELL-20:configuredEpsTac=200
...    NRCELL-20:nrSysInfoProfileDN=${EMPTY}

@{C02_online_params}
...    NRBTS:actSCellSwapFr1=disabled
...    NRCELL-1/NRREL-17:sCellPrio=6
...    NRCELL-1/NRREL-19:sCellPrio=4
...    NRCELL-1/NRREL-20:sCellPrio=2

@{ScellUserCell19}
...    NRCELL-19:maxNumOfUsersPerCell=0
...    NRCELL-19:maxNumOfSCellAlloc=0

@{RecoverScellUserCell19}
...    NRCELL-19:maxNumOfUsersPerCell=275
...    NRCELL-19:maxNumOfSCellAlloc=275

${ue_eutra_nr_capabilities}    SEPARATOR=
...    A11FF83BC4C0C03850001C4C000000162205E260601C28000E230000010B1102F130300E26800710400000058881789818070A00038820000
...    002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C0
...    41809A2E800B907893A244D8E7C3893A244D8E7C3893A244D8E7C3893A244D8E7C3893A24498E7D1A7448912639F449D1224C73E01A0718C6
...    318C60C0208000201010040080401002100004020200801008010023000080404030060100C01804030061000040202004010080100400000
...    0000

@{expect_regexp_ue31}
...    pcid:50, scellIdx:8] configure_0_1
...    pcid:50, scellIdx:8] configure_1_1
...    pcid:66, scellIdx:9] configure_1_1
...    SCellIndex 9 activated successfully at airphone

@{expect_regexp_ue32}
...    pcid:50, scellIdx:8] configure_0_1
...    pcid:50, scellIdx:8] configure_1_1
...    pcid:68, scellIdx:9] configure_1_1
...    SCellIndex 9 activated successfully at airphone

@{expect_regexp_ue33}
...    pcid:50, scellIdx:8] configure_0_1
...    pcid:50, scellIdx:8] configure_1_1
...    pcid:69, scellIdx:9] configure_1_1
...    SCellIndex 9 activated successfully at airphone

@{expect_regexp_ue34}
...    pcid:50, scellIdx:8] configure_0_1
...    pcid:50, scellIdx:8] configure_1_1
...    pcid:69, scellIdx:9] configure_1_1
...    SCellIndex 9 activated successfully at airphone

@{expect_regexp_ue35}
...    pcid:50, scellIdx:8] configure_0_1
...    pcid:50, scellIdx:8] configure_1_1
...    pcid:66, scellIdx:9] configure_1_1
...    SCellIndex 9 activated successfully at airphone

@{expect_regexp_ue36}
...    pcid:50, scellIdx:8] configure_0_1
...    pcid:50, scellIdx:8] configure_1_1
...    pcid:68, scellIdx:9] configure_1_1
...    SCellIndex 9 activated successfully at airphone

@{expect_regexp_common}
...    pcid:50, scellIdx:8] configure_0_1
...    pcid:50, scellIdx:8] configure_1_1
...    pcid:69, scellIdx:9] configure_1_1
...    SCellIndex 9 activated successfully at airphone

@{expect_regexp_common}
...    pcid:50, scellIdx:8] configure_0_1
...    pcid:50, scellIdx:8] configure_1_1
...    pcid:69, scellIdx:9] configure_1_1
...    SCellIndex 9 activated successfully at airphone

@{expect_regexp_common}
...    pcid:50, scellIdx:8] configure_0_1
...    pcid:50, scellIdx:8] configure_1_1
...    pcid:69, scellIdx:9] configure_1_1
...    SCellIndex 9 activated successfully at airphone

*** Test Cases ***
CB008950-ET-C001-C002-scell_selection_during_A1_with_unique_Scellprio_for_NSA_then_online_scellswap_disable_intragNBCA
    [Documentation]
    ...    1. This user scenario validates the SCell selection for NSA UE among same frequency SCell candidates when
    ...    there are more than 2 SCell candidates on the same SCell carrier frequency, and A1 based SCell addition method
    ...    is applied. NSA UE is not configured with A6 measurement for SCell swap as SCell swap is not supported for NSA.
    ...    2. Configuration
    ...    gNBs host following cells:
    ...                   Cell-1    Cell-3    Cell-5    Cell-6    Cell-11    Cell-12      Cell-13      Cell-17    Cell-19    Cell-20
    ...    Technology      TDD      TDD      TDD         TDD         FDD         FDD         FDD         FDD         FDD      FDD
    ...          Band      n41      n77      n77         n77         n66         n66        n66          n71        n71       n71
    ...           Pci       50       52       54         55          60          61          62           66         68        69
    ...     Bandwidth      100      100       100        100         10          10          10           15         15        15
    ...         Arfcn     517800    656000    656000     424000      424000    424000      425100         126000    126000     126000
    ...    3. Test Case Steps:
    ...           a. online change cellDepType of cell17/19/20 from SA+NSA to NSA
    ...              UE31 attach to cell-1, setup PDU session.
    ...              UE31 start traffic and trigger A1 CA scell addition.
    ...              UE32 attach to cell-1, setup PDU session.
    ...              UE32 start traffic and trigger A1 CA scell addition.
    ...              UE33 attach to cell-1, setup PDU session.
    ...              UE33 start traffic and trigger A1 CA scell addition.
    ...           b. online change cell19 maxNumOfUsersPerCell=0 and lock cell17.
    ...              UE34 attach to cell-1, setup PDU session.
    ...              UE34 start traffic and trigger A1 CA scell addition.
    ...           c. online cell19 maxNumOfUsersPerCell=275 and unlock cell17
    ...              UE35 attach to cell-1, setup PDU session.
    ...              UE35 start traffic and trigger A1 CA scell addition.
    ...              UE36 attach to cell-1, setup PDU session.
    ...              UE36 start traffic and trigger A1 CA scell addition.
    ...           d.online change sellpriority to NRCELL-17 scellprioity=6, NRCELL-19 scellprioity=4, NRCELL-20 scellprioity=2
    ...              UE37 attach to cell-1, setup PDU session.
    ...              UE37 start traffic and trigger A1 CA scell addition.
    ...              UE38 attach to cell-1, setup PDU session.
    ...              UE38 start traffic and trigger A1 CA scell addition.
    ...              UE39 attach to cell-1, setup PDU session.
    ...              UE39 start traffic and trigger A1 CA scell addition.
    ...    4. Expected Results:
    ...           a. Pcell nrrel numbers(9) < rdMaxActiveOutgoingCaRelFlexSCellSelect(10), scellprioity NRCELL_17 PhysCellId_66\
    ...              NRCELL_19 PhysCellId_68\NRCELL_20 PhysCellId_69 equal scell selected with round robin.
    ...              UE31 attach to cell-1, setup PDU session successfully.
    ...              UE31 start traffic and trigger A1 CA scell(NRCELL_17) addition successfully.
    ...              UE32 attach to cell-1, setup PDU session successfully.
    ...              UE32 start traffic and trigger A1 CA scell(NRCELL_19) addition successfully.
    ...              UE33 attach to cell-1, setup PDU session successfully.
    ...              UE33 start traffic and trigger A1 CA scell(NRCELL_20) addition successfully.
    ...           g. Lock NRCELL-17 , 19 scell user=0 , so UE34 select scell(NRCELL_20 PhysCellId_69).
    ...              UE34 attach to cell-1, setup PDU session successfully.
    ...              UE34 start traffic and trigger A1 CA scell(NRCELL_20) addition successfully.
    ...           c. unLock NRCELL-17 , 19 scell user=275 , so UE35 select scell(NRCELL_17 PhysCellId_66) UE36 select
    ...              scell(NRCELL_19 PhysCellId_68).
    ...              UE35 attach to cell-1, setup PDU session successfully.
    ...              UE35 start traffic and trigger A1 CA scell(NRCELL_17) addition successfully.
    ...              UE36 attach to cell-1, setup PDU session successfully.
    ...              UE36 start traffic and trigger A1 CA scell(NRCELL_19) addition successfully.
    ...           d. online change sellpriority to NRCELL-17 scellprioity=6, NRCELL-19 scellprioity=4, NRCELL-20 scellprioity=2,
    ...              ue37/38/39 all selected highest scellprioity (NRCELL_20 PhysCellId_69)
    ...              UE37 attach to cell-1, setup PDU session successfully.
    ...              UE37 start traffic and trigger A1 CA scell(NRCELL_20) addition successfully.
    ...              UE38 attach to cell-1, setup PDU session successfully.
    ...              UE38 start traffic and trigger A1 CA scell(NRCELL_20) addition successfully.
    ...              UE39 attach to cell-1, setup PDU session successfully.
    ...              UE39 start traffic and trigger A1 CA scell(NRCELL_20) addition successfully.
    [Tags]    C001    CA_LABEL-TT(100M_TDD_n41+100M_TDD_n77)    QC_353184
    OnlineParamChange    ${PARAMS_FOR_8950}
    MultiUE trigger A1 add scell After cellDepType To NSA
    OnlineParamChange    ${ScellUserCell19}
    Lock Cell17
    MultiUE trigger A1 add scell After Cell17 Lock and maxNumOfUsersCell19
    Unlock Cell17
    OnlineParamChange    ${RecoverScellUserCell19}
    MultiUE trigger A1 add scell Recover Cell17 Lock and maxNumOfUsersCell19
    OnlineParamChange    ${C02_online_params}
    MultiUE trigger A1 add scell with diff priority After 8290 disable

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/18cells_6T12F

Modify Cfg
    ${V_1}    catenate
    ...    set_uec id=1 ip=$DAEMON_IP:$DAEMON_PORT pdn=1 devtype=tun addr=72.22.0.1/26
    ...    peer=$DAEMON_IP:2152 gtpu=off retries=unlimited ctrl_conn_timeout=150000
    Update Cfg    ${V_1}
    ${UE36}    catenate
    ...    set_ue simulated id=36 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g imsi=250:555:21645411
    ${UE37}    catenate
    ...    set_ue simulated id=37 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g imsi=250:555:21645412
    ${UE38}    catenate
    ...    set_ue simulated id=38 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g imsi=250:555:21645413
    ${UE39}    catenate
    ...    set_ue simulated id=39 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g imsi=250:555:21645414
    ${UE36_capa}    catenate
    ...    ue_param id=36 dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_nr_capabilities=${CB008950_Capa_5CC_n41_n66_n66_n71_n77}
    ${UE37_capa}    catenate
    ...    ue_param id=37 dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_nr_capabilities=${CB008950_Capa_5CC_n41_n66_n66_n71_n77}
    ${UE38_capa}    catenate
    ...    ue_param id=38 dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_nr_capabilities=${CB008950_Capa_5CC_n41_n66_n66_n71_n77}
    ${UE39_capa}    catenate
    ...    ue_param id=39 dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_nr_capabilities=${CB008950_Capa_5CC_n41_n66_n66_n71_n77}
    Update Cfg    ${UE36}
    Update Cfg    ${UE37}
    Update Cfg    ${UE38}
    Update Cfg    ${UE39}
    Update Cfg    ${UE36_capa}
    Update Cfg    ${UE37_capa}
    Update Cfg    ${UE38_capa}
    Update Cfg    ${UE39_capa}
    Update Cfg    set_bearer id=2 ue=36 qci=9 pdn=1 ip=4.7.254.221 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=37 qci=9 pdn=1 ip=4.7.254.236 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=38 qci=9 pdn=1 ip=4.7.254.237 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=39 qci=9 pdn=1 ip=4.7.254.238 default=on trf_type=internal
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    set_bearer id=2 ue=31 qci=9 pdn=1 ip=4.7.254.208 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=32 qci=9 pdn=1 ip=4.7.254.209 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=33 qci=9 pdn=1 ip=4.7.254.210 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=34 qci=9 pdn=1 ip=4.7.254.211 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=35 qci=9 pdn=1 ip=4.7.254.212 default=on trf_type=internal
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14


UE Attach And Set Allowed Band Combination List
    [Arguments]    ${ue_id}=31    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    Set UE Capability    ue_id=${ue_id}    SA_Capa_perUE_Full=${CB008950_Capa_5CC_n41_n66_n66_n71_n77}    eutra_nr_capa=${ue_eutra_nr_capabilities}
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=1:1|4:1|4:4|4:3|5:2|6:1|6:2|4:2|5:1|2:1|3:1|7:1|7:2
    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    Successfully reconfigured dual connectivity
    Send And Verify Nsa Throuput_nonCA    ue_id=${ue_id}

Verify Throuput
    [Arguments]    ${ue_id}=31
    sleep    10s    sleep for Tput stable
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    ${all_tput}    Evaluate    ${scell8_tput}+${scell9_tput}
    Should Be True    ${all_tput}/1000 > 18
    ${ul_throughput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>18

Verify Throuput_nonCA
    [Arguments]    ${ue_id}=31
    sleep    10s    sleep for Tput stable
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 9
    ${ul_throughput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=8    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>9


Send And Verify Nsa Throuput_nonCA
    [Arguments]    ${ue_id}=31
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=10 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    wait until keyword succeeds    60s    5s    Verify Throuput_nonCA    ue_id=${ue_id}

Send And Verify Nsa Throuput
    [Arguments]    ${ue_id}=31
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=10 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=3    UE ${ue_id}: UDP UL
    wait until keyword succeeds    60s    5s    Verify Throuput    ue_id=${ue_id}


Trigger A1 Event
    [Arguments]    ${ue_id}    ${carrierfreq}    ${expect_regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=80 #rsrq_nr=52
    Execute Egate Command    ${cmd}    pass_regexp=${expect_regexp}
    Send And Verify Nsa Throuput    ue_id=${ue_id}

Set UE Capability
    [Arguments]    ${ue_id}=1    ${SA_Capa_perUE_Full}=none    ${eutra_nr_capa}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} ue_eutra_nr_capabilities=${eutra_nr_capa}
    Execute Egate Command    ${cmd}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

NSA UE Detach
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: detached    timeout=10s

MultiUE trigger A1 add scell After cellDepType To NSA
    UE Attach And Set Allowed Band Combination List    ue_id=31    target_gnb=2    target_cells=1    bearer_id=2
    Trigger A1 Event    ue_id=31    carrierfreq=517710    expect_regexp=${expect_regexp_ue31}
    Check A6 Should Not Be Configured    ue_id=31
    UE Attach And Set Allowed Band Combination List    ue_id=32    target_gnb=2    target_cells=1    bearer_id=2
    Trigger A1 Event    ue_id=32    carrierfreq=517710    expect_regexp=${expect_regexp_ue32}
    Check A6 Should Not Be Configured    ue_id=32
    UE Attach And Set Allowed Band Combination List    ue_id=33    target_gnb=2    target_cells=1    bearer_id=2
    Trigger A1 Event    ue_id=33    carrierfreq=517710    expect_regexp=${expect_regexp_ue33}
    Check A6 Should Not Be Configured    ue_id=33
    UEs Release

MultiUE trigger A1 add scell After Cell17 Lock and maxNumOfUsersCell19
    UE Attach And Set Allowed Band Combination List    ue_id=34    target_gnb=2    target_cells=1    bearer_id=2
    Trigger A1 Event    ue_id=34    carrierfreq=517710    expect_regexp=${expect_regexp_ue34}
    Check A6 Should Not Be Configured    ue_id=34
    NSA UE Detach    ue_id=34

MultiUE trigger A1 add scell Recover Cell17 Lock and maxNumOfUsersCell19
    UE Attach And Set Allowed Band Combination List    ue_id=35    target_gnb=2    target_cells=1    bearer_id=2
    Trigger A1 Event    ue_id=35    carrierfreq=517710    expect_regexp=${expect_regexp_ue35}
    Check A6 Should Not Be Configured    ue_id=35
    UE Attach And Set Allowed Band Combination List    ue_id=36    target_gnb=2    target_cells=1    bearer_id=2
    Trigger A1 Event    ue_id=36    carrierfreq=517710    expect_regexp=${expect_regexp_ue36}
    Check A6 Should Not Be Configured    ue_id=36
    NSA UE Detach    ue_id=35
    NSA UE Detach    ue_id=36

MultiUE trigger A1 add scell with diff priority After 8290 disable
    UE Attach And Set Allowed Band Combination List    ue_id=37    target_gnb=2    target_cells=1    bearer_id=2
    Trigger A1 Event    ue_id=37    carrierfreq=517710    expect_regexp=${expect_regexp_common}
    UE Attach And Set Allowed Band Combination List    ue_id=38    target_gnb=2    target_cells=1    bearer_id=2
    Trigger A1 Event    ue_id=38    carrierfreq=517710    expect_regexp=${expect_regexp_common}
    UE Attach And Set Allowed Band Combination List    ue_id=39    target_gnb=2    target_cells=1    bearer_id=2
    Trigger A1 Event    ue_id=39    carrierfreq=517710    expect_regexp=${expect_regexp_common}
    NSA UE Detach    ue_id=37
    NSA UE Detach    ue_id=38
    NSA UE Detach    ue_id=39

Check A6 Should Not Be Configured
    [Arguments]    ${ue_id}=31
    ${cmd}    catenate    ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command    ${cmd}    fail_regexp=A6

UEs Release
    NSA UE Detach    ue_id=31
    NSA UE Detach    ue_id=32
    NSA UE Detach    ue_id=33
