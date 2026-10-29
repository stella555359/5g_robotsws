*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO
...    team-PZ3_7    owner-cathy.mao    release-5G24R3     CB010986
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
#...    @{CB10986-B}

@{CB10986-B}
...    NRCELL-1:actUlNrEcIdNgRanApPosition=true
...    NRCELL-1:nGRanAccessPointPosition:altitude=97
...    NRCELL-1:nGRanAccessPointPosition:confidence=0
...    NRCELL-1:nGRanAccessPointPosition:degreesOfLatitude=6755405
...    NRCELL-1:nGRanAccessPointPosition:degreesOfLongitude=1253486
...    NRCELL-1:nGRanAccessPointPosition:directionOfAltitude=Height
...    NRCELL-1:nGRanAccessPointPosition:latitudeSign=North
...    NRCELL-1:nGRanAccessPointPosition:orientationOfMajorAxis=0
...    NRCELL-1:nGRanAccessPointPosition:uncertaintyAltitude=0
...    NRCELL-1:nGRanAccessPointPosition:uncertaintySemiMajor=0
...    NRCELL-1:nGRanAccessPointPosition:uncertaintySemiMinor=0


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


# Number of UL UE-associated NRPPA transport messages with E-CID measurement initiation failure with
# cause "Requested Item Temporarily not Available" for Reporting Type 'On-Demand' per NR Cell
${NRPPA_MEASINIT_FAIL_TMPUNAV_D}    M55125C00027



@{PM_Counters_A005}
...    NRCELL-1:${F1_ECID_MEASINIT_REQ}=3
...    NRCELL-1:${F1_ECID_MEASINIT_RESP}=3
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
...    NRCELL-1:${NRPPA_MEASINIT_FAIL_TMPUNAV_D}=0
...    NRCELL-2:${NRPPA_MEASINIT_FAIL_TMPUNAV_D}=0

*** Test Cases ***
CB010986-ET-A005_UL_AoA_reporting_interworking_with_CB8281
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         a.USCB010986-A#1 Successful E-CID measurement response for UL-AoA Measurement Quantity
    ...         in GCS derived from SRS based UL DFT beam
    ...    2. Test Case Steps:
    ...         a. SA UE1 attach to NR Cell-1
    ...         b. Config ul_mimo_srs_beam_pos_nr
    ...         c. LMF sends E-CID MEASUREMENT Request with NR_Angle_of_Arrival,SS-RSRP, and trigger
    ...         UE in variable beam to make UE move
    ...         d. LMF sends E-CID MEASUREMENT Request with NR_Angle_of_Arrival,SS-RSRP
    ...         e. Delay UE Report RSRP about 8s
    ...         f. LMF sends E-CID MEASUREMENT Request with NR_Angle_of_Arrival,SS-RSRP, and trigger
    ...         UE in variable beam to make UE move
    ...    4. Expected Results:
    ...         Step a: SA UE1 call setup successfully
    ...         Step b: Config ul_mimo_srs_beam_pos_nr successfully
    ...         Step c: LMF sends E-CID MEASUREMENT successfully with replied NR_Angle_of_Arrival,SS-RSRP
    ...         step d: LMF sends E-CID MEASUREMENT successfully with replied NR_Angle_of_Arrival,SS-RSRP
    ...         step e: Delay UE Report RSRP about 8s
    ...         step f: LMF receieve E-CID MEASUREMENT Report with only NR_Angle_of_Arrival
    ...         when reach condition nrEcidMeasSupervisionTimer=3000,wait about 8s, then UE report the MR with rsrp
    [Tags]    QC_XXXX    A005
    Clear Counter Files
    SA UE attach    ue_id=1
    Config ul_mimo_srs_beam_pos_nr
    LMF sends E-CID MEASUREMENT Request
    trigger UE in variable beam
    LMF sends E-CID MEASUREMENT Request
    Delay UE Report RSRP
    LMF sends E-CID MEASUREMENT Request    pass_reg=ECID Measurement Initiation Request
    trigger UE in variable beam
    Sleep    10s    #delay 10s to receive the MR with rsrp
    Check Counters    ${PM_Counters_A005}


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
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_cap_SA_UE1}

Config ul_mimo_srs_beam_pos_nr
    ${ul_mimo_srs_cmd}    Catenate    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=3
    ...    init_sub_quad_pos=0 test_type=SRS multi_path_config=1 num_of_nlos_paths=1 azimuth=3 zenith=0
    ...    srs_transmit_power_per_port=-400,-400,-500,-500
    Execute Egate Command    ${ul_mimo_srs_cmd}
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1

LMF sends E-CID MEASUREMENT Request
    [Arguments]    ${pass_reg}=Received ECID Measurement Response with NRPPATransactionID
    ${lmf_cmd}    Catenate    lmf_send_ecid_meas_req id=1 ue=1 nrppa_transaction_id=1 lmf_ue_measurement_id=1
    ...    report_characteristics=OnDemand meas_qty=NR_Angle_of_Arrival,SS-RSRP
    Execute Egate Command    ${lmf_cmd}    pass_regexp=${pass_reg}

trigger UE in variable beam
    ${variable_beam_cmd}    Catenate    ul_mimo_srs_beam_pos_nr profile_id=1 init_quad_pos=2 init_sub_quad_pos=1 final_quad_pos=2
    ...    final_sub_quad_pos=1 step=200 dtx_start=100 num_dtx=50 trigger_puxch_update=100 mode=sweep test_type=SRS
    Execute Egate Command    ${variable_beam_cmd}

Delay UE Report RSRP
    ${delay_cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=8000 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40 phycell_id=60 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${delay_cmd}

