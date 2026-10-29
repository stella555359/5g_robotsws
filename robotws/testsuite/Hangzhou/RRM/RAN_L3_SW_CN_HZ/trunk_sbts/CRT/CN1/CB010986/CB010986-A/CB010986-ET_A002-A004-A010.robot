*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO
...    team-PZ3_6    owner-jing.ye    release-5G24R3     CB010986
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRCELL:actDl256Qam=true
...    @{enableCDrx}
...    @{enableBeamforming}
...    @{srsConfig}
...    @{ExtraConfig}
...    @{CB10986}

@{PARAMS_IN_IPHY_XML}
...    vcell:ulFeatures=advancedSRS|cell=2.1

@{CB10986}
...    NRCELL-1:actUlNrEcIdAoa=true
...    NRCELL-1:actUlNrEcIdPosMethod=true
...    NRCELL-1:ulAoaMonitorWindow=100
...    NRBTS:nrEcidMeasSupervisionTimer=3000
...    NRCELL-1:lcsToGcsTranslate:bearingAngle=0
...    NRCELL-1:lcsToGcsTranslate:downtiltAngle=0
...    NRCELL-1:lcsToGcsTranslate:slantAngle=0

@{enableBeamforming}
...    NRCELL:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-1:beamSet:basicBeamSet=beamSet_6
...    NRBTS-1:actCustomBsr=true
...    NRBTS-1/NRCELL-1:beamSet:customBeamSetName=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
...    NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:lowerEdgeAngle=120
...    NRBTS-1/NRCELL-1:beamSet:upperEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:beamsMuted=0
...    NRBTS-1/NRCELL-1:beamSet:tiltOffset=0
...    NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=true
...    NRBTS-1/NRCELLGRP-0:numberOfTransmittedSsBlocks=6 beams
...    NRBTS-1/NRCELLGRP-1:numberOfTransmittedSsBlocks=4 beams
...    NRBTS-1/NRCELL-2:beamSet:basicBeamSet=beamSet_4
...    NRBTS-1/NRCELL-2:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-2:beamSet:lowerEdgeAngle=135
...    NRBTS-1/NRCELL-2:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-2:beamSet:upperEdgeAngle=80
...    NRBTS-1/NRSYSINFO_PROFILE-1/NRIAFIM-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL:numberOfRxBeamforming=4Rx
...    NRCELL:actBeamforming=true
...    NRCELL:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-1:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL:nrCellType= 8DL4UL
...    NRCELL-1:prachConfigurationIndex=97

@{srsConfig}
...    NRCELL:dftBeamDiffThresholdH=15
...    NRCELL:dftBeamDiffThresholdV=15
...    NRCELL-1:actUlSrsBm=true
...    NRCELL-1:actDlSrsBm=false
...    NRCELL-1:srsForBeamMgmt:srsUePeriodicity=slots40
...    NRCELL-1:srsForBeamMgmt:cSRS=62
...    NRCELL-1:srsForBeamMgmt:bSRS=2
...    NRCELL-1:srsForBeamMgmt:comb=comb2
...    NRCELL:srsForBeamMgmt:srsPowerThresholdForDlBm=-1200
...    NRCELL:srsForBeamMgmt:srsPowerThresholdForUlBm=-1320
...    NRCELL-1:srsForBeamMgmt:srsTypeAllocForDlBm=antenna switching or codebook
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-1:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
#2226 Frame Structure disable
...    NRBTS:actCoverageNonCoherentUes=false

@{enableCDrx}
...    NRCELL:actCDrx=true

@{ExtraConfig}
...    NRCELL-2:freqBandIndicatorNR=41
...    NRCELL-2:gscnOrSsPbchArfcn=6351
...    NRCELL-2:nrarfcn=508020
...    NRCELL-2:chBw=80MHz
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS-1/NRSYSINFO_PROFILE-1:systemInformationTargetRate=0
...    NRBTS-1/NRCELL:type0SearchSpaceConfigurationIndex=5
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1

@{online_modify_A004}
...    NRCELL-1:actUlNrEcIdAoa=false
...    NRCELL-1:actUlNrEcIdTAdv=true
...    delete:NRCELL-1:lcsToGcsTranslate
...    delete:NRCELL-1:ulAoaMonitorWindow

@{online_modify_A010}
...    NRCELL-1:actUlNrEcIdAoa=true
...    NRCELL-1:actUlNrEcIdPosMethod=true
...    NRCELL-1:ulAoaMonitorWindow=100
...    NRBTS:nrEcidMeasSupervisionTimer=6500
...    NRCELL-1:lcsToGcsTranslate:bearingAngle=0
...    NRCELL-1:lcsToGcsTranslate:downtiltAngle=0
...    NRCELL-1:lcsToGcsTranslate:slantAngle=0
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS:timerRRCGuard=6000

${rdSrsCodebookAndTas}    0x590103
${rdPriorSrsForDlBm}    0x590104
@{PARAMS_IN_SWCONFIG}    ${rdSrsCodebookAndTas}=1    ${rdPriorSrsForDlBm}=0
@{PARAMS_IN_SWCONFIG_AP}    0x70690=1

${ReconfigurationFailure}     reconfigurationFailure

@{ECID_Measurement_Fail}
...    Received ECID Measurement Failure with NRPPATransactionID
...    rrcReestablishmentComplete
#70690: AP enable 1086 and 8247
#rdSrsCodebookAndTas : 0: FALSE[default], 1: TRUE;To control whether 'antennaSwitching' SRS can overlap with codebook SRS or not
#rdPriorSrsForDlBm: 0: TAS[default], 1: codebook;To control which kind of periodic SRS has higher priority for DL SRS based beamforming

#BAND78: t1r4-t2r4 maxNumberSRS-Ports-PerResource=n2
${ue_nr_cap_SA_UE1}    SEPARATOR=
...    6180000004608580300002300000A000009A0000410200385000000000E268000011D00001602013008C3C088000A0705006020090018078
...    000000000000D1508A0452027004100000012010400004048040302A42AA02902700400200400800400802

# Num of E-CID MEASUREMENT INITIATION REQUEST msgs sent over F1 Interface
${F1_ECID_MEASINIT_REQ}    M55113C00013

# Num of E-CID MEASUREMENT INITIATION RESPONSE msgs received over F1 interface
${F1_ECID_MEASINIT_RESP}    M55113C00014

# Num of E-CID MEASUREMENT INITIATION FAILURE msgs received over F1 interface due to protocol error
${F1_ECID_MEASINIT_FAIL_PRERR}    M55113C00015

# Num of TimerF1UeProcGuard timeouts in gNB-CU due to no response to E-CID MEASUREMENT INITIATION REQUEST msg from gND-DU over F1 interface
${F1_ECID_MEASINIT_TIMEOUT}    M55113C00018

# Num of E-CID MEASUREMENT INITIATION FAILURE msgs with cause "RNL: Measurement Temporarily not Available" received over F1 interface
${F1_ECID_MEASINIT_FAIL_TMPUNAV}    M55113C00016

# Num of E-CID MEASUREMENT INITIATION FAILURE msgs with cause "RNL: Measurement not Supported For The Object" received over F1 interface
${F1_ECID_MEASINIT_FAIL_NO_SUPP}    M55113C00017

# Number of UL UE-associated NRPPA transport messages with E-CID measurement initiation failure with cause "Requested Item Temporarily not 
#...    Available" for Reporting Type 'On-Demand' per NR Cell
${NRPPA_MEASINIT_FAIL_TMPUNAV_D}    M55125C00027

#Num of DL UE-associated NRPPA transport messages with E-CID measurement initiation requests for Reporting Type "On-Demand" per NR cell
${NRPPA_MEASINIT_REQ_D}    M55125C00024

#Num of UL UE-associated NRPPA transport messages with E-CID measurement initiation response for Reporting Type "On-Demand" per NR cell
${NRPPA_MEASINIT_RESP_D}    M55125C00025

@{PM_Counters_A002}
...    NRCELL-1:${NRPPA_MEASINIT_REQ_D}=4
...    NRCELL-1:${NRPPA_MEASINIT_RESP_D}=4
...    NRCELL-1:${F1_ECID_MEASINIT_REQ}=4
...    NRCELL-1:${F1_ECID_MEASINIT_RESP}=4
...    NRCELL-1:${F1_ECID_MEASINIT_FAIL_PRERR}=0
...    NRCELL-1:${F1_ECID_MEASINIT_TIMEOUT}=0
...    NRCELL-1:${F1_ECID_MEASINIT_FAIL_TMPUNAV}=0
...    NRCELL-1:${F1_ECID_MEASINIT_FAIL_NO_SUPP}=0
...    NRCELL-1:${NRPPA_MEASINIT_FAIL_TMPUNAV_D}=0

@{PM_Counters_A004}
...    NRCELL-1:${NRPPA_MEASINIT_REQ_D}=2
...    NRCELL-1:${NRPPA_MEASINIT_RESP_D}=2
...    NRCELL-1:${F1_ECID_MEASINIT_REQ}=2
...    NRCELL-1:${F1_ECID_MEASINIT_RESP}=2
...    NRCELL-1:${F1_ECID_MEASINIT_FAIL_PRERR}=0
...    NRCELL-1:${F1_ECID_MEASINIT_TIMEOUT}=0
...    NRCELL-1:${F1_ECID_MEASINIT_FAIL_TMPUNAV}=0
...    NRCELL-1:${F1_ECID_MEASINIT_FAIL_NO_SUPP}=0
...    NRCELL-1:${NRPPA_MEASINIT_FAIL_TMPUNAV_D}=0

@{PM_Counters_A010}
...    NRCELL-1:${F1_ECID_MEASINIT_REQ}=2
...    NRCELL-1:${F1_ECID_MEASINIT_RESP}=2
...    NRCELL-2:${F1_ECID_MEASINIT_REQ}=0
...    NRCELL-2:${F1_ECID_MEASINIT_RESP}=0
...    NRCELL-1:${F1_ECID_MEASINIT_FAIL_PRERR}=0
...    NRCELL-2:${F1_ECID_MEASINIT_FAIL_PRERR}=0
...    NRCELL-1:${F1_ECID_MEASINIT_TIMEOUT}=0
...    NRCELL-2:${F1_ECID_MEASINIT_TIMEOUT}=0
...    NRCELL-1:${F1_ECID_MEASINIT_FAIL_TMPUNAV}=0
...    NRCELL-2:${F1_ECID_MEASINIT_FAIL_TMPUNAV}=0
...    NRCELL-1:${F1_ECID_MEASINIT_FAIL_NO_SUPP}=0
...    NRCELL-2:${F1_ECID_MEASINIT_FAIL_NO_SUPP}=0
...    NRCELL-1:${NRPPA_MEASINIT_FAIL_TMPUNAV_D}=2
...    NRCELL-2:${NRPPA_MEASINIT_FAIL_TMPUNAV_D}=0
...    NRCELL-1:${NRPPA_MEASINIT_REQ_D}=3
...    NRCELL-2:${NRPPA_MEASINIT_REQ_D}=0
...    NRCELL-1:${NRPPA_MEASINIT_RESP_D}=1
...    NRCELL-2:${NRPPA_MEASINIT_RESP_D}=0

*** Test Cases ***
CB010986-ET-A002_UL_AoA_reporting_for_UL_NR_E-CID-UL_AoA_based_on_DFT_beam_with_variable_DFT_beams
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios: Successful E-CID Measurement Reporting for 'On-Demand' Request.
    ...    2. Test Case Steps:
    ...         a. SA UE1 attach to NR Cell 1.
    ...         b. Set UL mimo srs beam position.
    ...         c. LMF send E-CID MR.
    ...         d. Set UL mimo srs beam position.
    ...         e. LMF send E-CID MR.
    ...         f. Set UL mimo srs beam position.
    ...         g. LMF send E-CID MR.
    ...         h. Set UL mimo srs beam position with SRS DTX always
    ...         i. LMF send E-CID MR.
    ...         j. Check Counters.
    ...    4. Expected Results:
    ...         a. SA UE1 attach successfully.
    ...         b. Set successfully.
    ...         c. LMF send E-CID MR successfully, gnb send UPLINK UE ASSOCIATED NRPPA TRANSPORT message with AOA report via NGAP.
    ...         d. Set successfully.
    ...         e. LMF send E-CID MR successfully, gnb send UPLINK UE ASSOCIATED NRPPA TRANSPORT message with AOA report via NGAP.
    ...         f. Set successfully.
    ...         g. LMF send E-CID MR successfully, gnb send UPLINK UE ASSOCIATED NRPPA TRANSPORT message with AOA report via NGAP.
    ...         h. Set successfully.
    ...         i. LMF send E-CID MR successfully, gnb send UPLINK UE ASSOCIATED NRPPA TRANSPORT message without AOA report with cause
    ...            requested-item-temporarily-not-available.
    ...         j. Check Counters.
    [Tags]    QC_349041    A002
    Clear Counter Files    ${False}
    SA UE attach    ue_id=1
    Set UL MIMO SRS BEAM POS
    LMF sends E-CID MEASUREMENT Request
    Set UL MIMO SRS BEAM POS 2nd time
    LMF sends E-CID MEASUREMENT Request
    Set UL MIMO SRS BEAM POS 3rd time
    LMF sends E-CID MEASUREMENT Request
    Set UL MIMO SRS BEAM POS 4th time with SRS DTX always
    LMF sends E-CID MEASUREMENT Request
    Release ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}a2a_A002${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_Counters_A002}

CB10986-ET-A004_UL AoA reporting interworking with unsupported measurement
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios: Successful E-CID Measurement Reporting for 'On-Demand' Request.
    ...    2. Test Case Steps:
    ...         a. SA UE1 attach to NR Cell 1.
    ...         b. Set UL mimo srs beam position.
    ...         c. LMF send E-CID MR.
    ...         d. Set UL mimo srs beam position.
    ...         e. Online modify parameters
    ...         f. LMF send E-CID MR.
    ...         g. Check Counters.
    ...    4. Expected Results:
    ...         a. SA UE1 attach successfully.
    ...         b. Set successfully.
    ...         c. LMF send E-CID MR successfully, gnb send UPLINK UE ASSOCIATED NRPPA TRANSPORT message only with AOA report via NGAP.
    ...         d. Set successfully.
    ...         e. Online modified successfully and cell_1 is on air
    ...         f. LMF send E-CID MR successfully, gnb send UPLINK UE ASSOCIATED NRPPA TRANSPORT message only with Tadv report via NGAP.
    ...         g. Check Counters.
    [Tags]    QC_349035    A004
    Clear Counter Files
    SA UE attach    ue_id=1
    Set UL MIMO SRS BEAM POS
    LMF sends E-CID MEASUREMENT Request    meas_qty=NR_Angle_of_Arrival,NR_Timing_Advance
    Set UL MIMO SRS BEAM POS 2nd time
    Online Modify Parameters A004
    LMF sends E-CID MEASUREMENT Request    meas_qty=NR_Angle_of_Arrival,NR_Timing_Advance
    Release ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}a2a_A004${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_Counters_A004}

CB10986-ET-A010_UL AoA reporting failure due to UE RRCReestablishment
  [Tags]  QC_349678    A010
  [Documentation]
    ...    1.Purpose
    ...    The purpose of this test case is to check Successful E-CID Measurement Reporting for ‘On-Demand’ Request
    ...    2. Test Case Steps
    ...    Step a. setup SA call
    ...         b. LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE set to ‘On-Demand’ and
    ...            Measurement Quantity requested is “angleOfArrivalNR”, report characteristic is set to “on-demand”
    ...         c. before F1AP response,  gnb received  “RRCReestablishmentRequest” from the UE.
    ...         d. after RRCReestablish complete, LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE
    ...            set to ‘On-Demand’ and Measurement Quantity requested is “angleOfArrivalNR”, report characteristic is set to “on-demand”
    ...         e. gnb received  “RRCReestablishmentRequest” from the UE
    ...         f. before RRCReestablishment complete,  LMF sends E-CID MEASUREMENT INITIATION REQUEST with Report Characteristics IE set to
    ...            ‘On-Demand’ and Measurement Quantity requested is “angleOfArrivalNR”, report characteristic is set to “on-demand”
    ...         g. check counter and KPI
    ...   Expect A. SA call setup successfully
    ...          b. gNB-CU-CP initiates the F1AP: E-CID MEASUREMENT INITIATION REQUEST to DU. check LMF UE measurement ID,
    ...             “angleOfArrivalNR” is added to “E-CID Measurement quantities” ,  E-CID Report Characteristics set to “On-demand”
    ...          c. gNB-CU-CP identifies “E-CID MEASUREMENT INITIATION FAILURE (RNL Cause = "Requested Item Temporarily not Available")
    ...             and send it to the LMF. gNB-CU-CP follows the re-establishment of the Radio link, the behaviour defined in the
    ...             RRCReestablishment procedure as per the feature activation of 5GC000732. Recovery of the existing Radio Link
    ...             as part of RRCReestablishment, RRCReconfiguration
    ...              after successful RRCReestablishment includes the E-CID Measurement configured in measIdToRemoveList
    ...          d. gNB-DU sends the F1AP: E-CID MEASUREMENT INITIATION RESPONSE  to gNB-CU, gNB-CU generates a NGAP: UPLINK UE ASSOCIATED NRPPA
    ...             TRANSPORT message with the AMF-UE-NGAP-ID, RAN-UE-NGAP-ID & Routing ID IEs and NRPPa-PDU(only “timingAdvanceNR”) having
    ...             the NRPPA: E-CID MEASUREMENT INITIATION RESPONSE message.
    ...          e. Recovery of the existing Radio Link, RRCReestablishment ongoing
    ...          f. gNB-CU-CP identifies “E-CID MEASUREMENT INITIATION FAILURE (RNL Cause = "Requested Item Temporarily not Available")
    ...              and send it to the LMF
    ...          g. - NRPPA_MEASINIT_REQ_D=3
    ...             - NRPPA_MEASINIT_RESP_D=1
    ...               F1_ECID_MEASINIT_REQ
    ...               F1_ECID_MEASINIT_RESP
    ...               F1_ECID_MEASINIT_FAIL_PRERR
    ...               F1_ECID_MEASINIT_TIMEOUT
    ...               F1_ECID_MEASINIT_FAIL_TMPUNAV
    ...               F1_ECID_MEASINIT_FAIL_NO_SUPP

    Clear Counter Files
    Online Modify Parameters A010
    SA UE attach
    Set Ue position
    LMF send E-CID measurement request with rsrp
    Trigger RRC Reestablish with cause    ${ReconfigurationFailure}    1
    sleep    42    reason=wait finished
    Trigger RRC Reestablish with cause    ${ReconfigurationFailure}    1
    LMF sends E-CID MEASUREMENT Request
    sleep    42    reason=wait finished
    Set RRC Reestablish delay time    1
    Trigger RRC Reestablish with cause with delay    ${ReconfigurationFailure}    1
    LMF sends E-CID MEASUREMENT Request    1    NR_Angle_of_Arrival    ${ECID_Measurement_Fail}
    sleep    42    reason=wait finished
    Release ues    ue_type=all
    Check message and counter

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Install eNB Package via WEBEM
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=2

Install eNB Package via WEBEM
    [Arguments]    ${bsr_name}=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip    ${bsr_path}=/home/ute/bsr_package
    Execute Cmd On Pc    rm -rf ${bsr_path}
    Execute Cmd On Pc    mkdir ${bsr_path}
    Execute Cmd On Pc    git clone https://wrgitlab.ext.net.nokia.com/y165zhan/bsr_package ${bsr_path}
    update_software    sw_package=${bsr_path}/${bsr_name}    timeout=60

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    Initial Context Setup Successful

Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE1} reestablishing_state_timeout=6000

Set Ue position
    Set UL MIMO SRS BEAM POS
    ${cmd1}    catenate
    ...    ue_measurement_send_nr id=1 meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=5000 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command     ${cmd1}

LMF send E-CID measurement request with rsrp
    [Arguments]    ${ue_id}=1    ${cause}=saved periodic meas report will be sent after 5000 ms
    ${cmd}    catenate
    ...    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=1 lmf_ue_measurement_id=1
    ...    report_characteristics=OnDemand meas_qty=NR_Angle_of_Arrival,SS-RSRP
    Execute Egate Command    ${cmd}    ${cause}

Set UL MIMO SRS BEAM POS
    ${cmd}    catenate    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
    ...    multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
    Execute Egate Command    ${cmd}    
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1

LMF sends E-CID MEASUREMENT Request
    [Arguments]    ${ue_id}=1    ${meas_qty}=NR_Angle_of_Arrival    ${cause}=Received UplinkUEAssociatedNRPPaTransfer from GNB-2
    ${cmd}    catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=1 lmf_ue_measurement_id=1 report_characteristics=OnDemand
    ...    meas_qty=${meas_qty}
    Execute Egate Command    ${cmd}    ${cause}

Set UL MIMO SRS BEAM POS 2nd time
    ${cmd}    catenate    ul_mimo_srs_beam_pos_nr profile_id=1 init_quad_pos=1 init_sub_quad_pos=1 final_quad_pos=3 final_sub_quad_pos=3
    ...    step=200 dtx_start=100 num_dtx=50 trigger_puxch_update=100 mode=sweep test_type=SRS
    Execute Egate Command    ${cmd} 

Set UL MIMO SRS BEAM POS 3rd time
    ${cmd}    catenate    ul_mimo_srs_beam_pos_nr profile_id=1 init_quad_pos=0 init_sub_quad_pos=0 final_quad_pos=3 final_sub_quad_pos=3
    ...    step=200 mode=sweep test_type=SRS
    Execute Egate Command    ${cmd}

Set UL MIMO SRS BEAM POS 4th time with SRS DTX always
    ${cmd}    catenate    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 test_type=SRS multi_path_config=1
    ...    num_of_nlos_paths=1 azimuth=3 zenith=0 srs_transmit_power_per_port=-840,-840,-840,-840
    Execute Egate Command    ${cmd}   
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2

Online Modify Parameters A004
    Delta Commission Parameters    ${online_modify_A004}
    Cells Should Be OnAir

Online Modify Parameters A010
    Delta Commission Parameters    ${online_modify_A010}
    Cells Should Be OnAir

Set RRC Reestablish delay time
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_rrc_reestablish_param id=${ue_id} if_contains=any delay=5000

Trigger RRC Reestablish with cause with delay
    [Arguments]    ${cause}    ${cellid}
     ${cmd}    catenate
    ...    ue_rrc_reestablish id=1 gnb=2 cell=${cellid} cause=${cause}
    Execute Egate Command    ${cmd}    after 5000 ms and hence the NrRrcReestablishmentComplete will also be delayed

Trigger RRC Reestablish with cause
    [Arguments]    ${cause}    ${cellid}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=${cellid} cause=${cause}
    ...    rrcReconfigurationComplete    timeout=20s

Check message and counter
	Check Wireshark Log    ${CURDIR}${/}a2a_A010${/}A010.ini    wait_string=UEContextReleaseComplete::4
	Release Ues    ue_type=all
	Check Counters    ${PM_Counters_A010}
