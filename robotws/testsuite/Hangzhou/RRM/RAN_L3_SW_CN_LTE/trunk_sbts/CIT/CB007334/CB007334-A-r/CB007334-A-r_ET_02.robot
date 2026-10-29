*** Settings ***
Documentation
...    author: Geng lishuo
...    contact: lishuo.geng@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT    CLOUD_R4LAPO_CUS
...               team-DEVHZ5_SG1    release-SBTS21B    owner-lixia.zhou,ying.shang
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA}
...    @{x2link}
...    @{LTE4193}
...    @{LTE4549}
...    @{CB007334}
...    @{LTE5411}
...    @{Tput_parameter}
...    @{LTE4088}
...    @{FIX_RELATION_ERR}
...    @{LTE908}
...    @{LTE782}
...    @{LTE556}
...    @{LTE2652}
...    @{CB007333}
...    @{LTE5740}
...    @{LTE4490}
@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:tS1eRABModInd=50
...    LNBTS-1:actAmbrModCaTrigger=false
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=20
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL:actFlowCtrlEnh=false
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL:maxNumScells=2
...    LNBTS-1/CADPR-0:maxNumMimoLayerTdd=12
...    LNBTS-1:sCellDeactivationTimereNB=rf128
...    LNBTS-1:actAdvStepwiseScellAdd=buffer-based
...    LNBTS-1:actFlexCaMgmt=true
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
...    LNBTS-1/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS-1/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS-1/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS-1/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNCEL/LNCEL_FDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...    LNCEL/LNCEL_FDD-0:activatedMimoTM=TM4
...    LNCEL/LNCEL_FDD-0:actFastMimoSwitch=true
...    LNCEL/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:maxNumUeDl=14
...    LNCEL/LNCEL_FDD-0:maxNumUeUl=14
...    LNBTS-1/MODPR-0/MODRED-1:redirRAT=utraFDD
...    LNBTS-1/MODPR-1/MODRED-1:redirRAT=utraFDD
...    LNCEL:actDlPwBackoff=false
...    LNCEL/LNCEL_FDD-0:syncSigTxMode=SingleTx
...    LNCEL/SIB-0:siWindowLen=20ms
@{x2link}
...    LNBTS-1/LNADJGNB-1:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
@{LTE4490}
...    LNBTS-1:actX2gNB128=true
@{LTE4088}
...    LNBTS-1:actLteNrDualConnectivity=true
...    LNBTS-1:tLteNrDualConnectPrep=500
...    LNBTS-1:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
@{LTE4193}
...    LNBTS-1:actDynTrigLteNrDualConnectivity=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS-1/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS-1/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS-1/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS-1/NRDCDPR-0:tPeriodicPhr=50sf
...    LNBTS-1/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=66
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN2036667}
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=258
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=30kHz
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=66
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${NRARFCN2036667}
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=41
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=30kHz
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc1|quantityConfigId=1
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc1|quantityConfigId=1
@{LTE4549}
...    LNBTS-1:actCAggrLteNrDualConnectivity=disabled
...    LNBTS-1:enableBwCombCheck=true
...    LNBTS-1/NRDCDPR-0:cAggrLteNrDcCellList=-1
@{Tput_parameter}
...    LNCEL:actLdPdcch=true
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=3
...    LNCEL:adaptPdcchDwellTime=0
...    LNCEL:mbrSelector=ueCapability
...    LNBTS-1:pdcpProf2:snSize=15bit
...    LNBTS-1:rlcProf7:tReord=15ms
...    LNCEL:dlTargetBler=100
@{CB007334}
...    LNBTS-1:actUeBasedAnrNr=true
...    LNBTS-1/ANR-0:anrNrInactivityTimer=5
...    LNCEL:inactivityTimer=60
...    LNBTS-1/ANR-0:anrNrCoverageConfirmTimer=2500
...    LNCEL:drxProfile105:drxProfilePriority=30
...    LNBTS-1:nrRestrictionOverride=disabled
...    LNBTS-1/ANR-0:anrNrParamList:carrierFreqNrCell=${NRARFCN2036667}|anrDefRelDcAllowed=false
...    LNBTS-1/ANR-0:anrNrParamList:gNBIdLength=22|anrDefRelDcAllowed=false
...    LNBTS-1/ANR-0:anrNrParamList:frqNrCarSelect=Single Carrier|anrDefRelDcAllowed=false
...    LNBTS-1/ANR-0:anrNrParamList:paramPlmnId=1|anrDefRelDcAllowed=false
...    LNBTS-1/ANR-0:anrNrParamList:paramMeasConfId=1|anrDefRelDcAllowed=false
...    LNBTS-1/ANR-0:anrNrMeasConfList:thresholdNrRsrp=56|paramMeasConfId=1
...    LNBTS-1/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-10|paramMeasConfId=1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelAddThresh=5
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelRemThresh=300000
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelAddHyst=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:nrPciNbrRelAddThresh=5
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:nrPciNbrRelRemThresh=300000
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:nrPciNbrRelAddHyst=900
...    LNBTS-1/ANR-0:anrNrParamPlmnList:mcc=262|paramPlmnId=1
...    LNBTS-1/ANR-0:anrNrParamPlmnList:mnc=3|paramPlmnId=1
...    LNBTS-1/ANR-0:anrNrParamPlmnList:mncLength=2|paramPlmnId=1
...    LNBTS-1/ANR-0:anrNrParamPlmnList:mcc=262|paramPlmnId=2
...    LNBTS-1/ANR-0:anrNrParamPlmnList:mnc=4|paramPlmnId=2
...    LNBTS-1/ANR-0:anrNrParamPlmnList:mncLength=2|paramPlmnId=2
...    LNBTS-1:rrcGuardTimer=200
@{LTE5411}
...    LNBTS-1:actLteNrFastNbrRelAdd=false
@{CB007333}
...    LNBTS-1/ANR-0:actAutoNrNeighRemoval=true
@{LTE908}
...    LNBTS-1:actUeBasedAnrUtran=false
@{LTE782}
...    LNBTS-1:actUeBasedAnrIntraFreqLte=false
@{LTE556}
...    LNBTS-1:actUeBasedAnrInterFreqLte=false
@{LTE2652}
...    LNBTS-1:actAnrRtt=false
@{LTE5740}
...    LNCEL:actPeriodicB1NRMeas=disabled
@{FIX_RELATION_ERR}
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:actEndcSpidFwd=false
...    delete:LNCEL/LNCEL_FDD-0:csiRsConfigInfo
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=2870
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=20870
...    LNCEL:actFlowCtrlEnh=true
...    delete:LNBTS-1/LNCEL-1/MBSFNCEL-0
...    LNBTS-1:actTransmittedBelowGap=false
...    LNBTS-1:maxNumNrCellgNB=2
...    LNBTS-1:maxNumNrCell=2
${ue_nr_capabilities}
...    SEPARATOR=
...    E1000000014F7E0302000001404807060E220C000213601073E420F0008240310008A05851A0219434088107418604C04416C9014020018073
...    E420F0008240E0E02203C80F00002600001371378120480000002400000812000008014018060180601B005004020080230050060200802008
...    C0140080802300500002300500201806C01400006C04E54DE50DE5456E11BA40101000004186004000050618010000220821040000C8208410
...    0004208210134AA66944C572A2BB515D88
${ue_eutra_nr_capabilities}
...    SEPARATOR=
...    C10040760B0200E2680000000040806C08010102060E2680000100D8100206040C1C4D00000401040002010100200460001008000402000100
...    808010023000080400020100008040400801
${ue_eutra_capabilities}
...    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C1082080304
...    218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B082008284105182083841004142082061040
...    105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B
...    82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71E0002040
...    6080C0E162636383A83F7FC4B5A68190BFCD08750003006D9200004000020973C0800002010061304D0A000405E01BFE000005000000308004
...    400020
@{PARAMS_IN_EMIL}
...    0x400e
...    0x7509
...    0x75ce
@{del_LNRELGNBCELL255}
...    delete:LNCEL-1/LNRELGNBCELL-255
@{case2_precondition}
...    LNBTS-1/LNADJGNB-1:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNBTS-1/LNADJGNB-2:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-2:cPlaneIpAddr=10.0.1.12
...    LNBTS/ANR-0:anrNrParamList:anrDefRelDcAllowed=true|carrierFreqNrCell=629984
...    LNBTS/ANR-0:anrNrParamList:frqNrCarSelect=FR2|carrierFreqNrCell=629984
...    LNBTS/ANR-0:anrNrParamList:gNBIdLength=24|carrierFreqNrCell=629984
...    LNBTS/ANR-0:anrNrParamList:frqNrCarSelect=Single Carrier|carrierFreqNrCell=629980
...    LNBTS/ANR-0:anrNrParamList:gNBIdLength=24|carrierFreqNrCell=629980
@{LNRELGNBCELL255_CGI2}
...    LNCEL-1/LNRELGNBCELL-255:nrCellId=148743
...    LNCEL-1/LNRELGNBCELL-255:gnbIdLength=24
...    LNCEL-1/LNRELGNBCELL-255:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-255:nrStatus=unavailable
@{LNADJGNB127_CGI2}
...    LNBTS-1/LNADJGNB-127:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-127:adjGnbId=36
...    LNBTS-1/LNADJGNB-127:adjGnbIdLength=24
...    LNBTS-1/LNADJGNB-127:plmnId:mcc=262
...    LNBTS-1/LNADJGNB-127:plmnId:mnc=3
...    LNBTS-1/LNADJGNB-127:plmnId:mncLength=2
@{LNRELGNBCELL255_CGI1_case2}
...    LNCEL-1/LNRELGNBCELL-255:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-255:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-255:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-255:nrStatus=available
${PM_SPEED_UP_FLAG}    ${True}
${gnb7_cell1}    SEPARATOR=
    ...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes}
${gnb7_cell2}    SEPARATOR=
    ...    {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x0000502', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes}
${gnb7_cell3}    SEPARATOR=
    ...    {id: 73, technology: nr , tac: 33, pci: '1:0', nrci: '0x0000503', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes}
${gnb8_cell1}    SEPARATOR=
    ...    {id: 81, technology: nr , tac: 33, pci: '1:1', nrci: '0x0000504', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes}
${gnb8_cell2}    SEPARATOR=
    ...    {id: 82, technology: nr , tac: 33, pci: '1:2', nrci: '0x0000505', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes}
${gnb8_cell3}    SEPARATOR=
    ...    {id: 83, technology: nr , tac: 33, pci: '2:0', nrci: '0x0000506', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes}
${gnb9_cell1}    SEPARATOR=
    ...    {id: 91, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000507', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes}
${gnb9_cell2}    SEPARATOR=
    ...    {id: 92, technology: nr , tac: 33, pci: '0:2', nrci: '0x0000508', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes}
${gnb9_cell3}    SEPARATOR=
    ...    {id: 93, technology: nr , tac: 33, pci: '1:0', nrci: '0x0000509', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes}

*** Test Cases ***
CB007334-A-r_ET_02_01_Verification NR-PCI NR-carrier pair-ambiguity PCI
    [Tags]
    Delta Commission Parameters    ${case2_precondition}
    Trigger ANR by UE
    LNRELGNBCELL-255 is created successfully according to CGI1
    Delete LNRELGNBCELL-255
    Attach UE1-UE6 to CELL-1 with default QCI8
    Trigger UE1-UE6 to send B1-NR reports with PCI1 6-times cross add threshold then detach UE1-UE6
    Attach UE12 and check trigger RSC and reportCGI CGI2 for UE12 after ANR timer expire    12
    LNRELGNBCELL-255 and LNADJGNB-127 should be created    ${LNADJGNB127_CGI2}    ${LNRELGNBCELL255_CGI2}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Execute Cmd On Pc    sudo ifconfig eth4:1 add 10.0.2.11
    Setup CUS Env    tl_type=4CELLs_FDD_2Band3_2Band7
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Object Should Exist    LNBTS-1/LNADJGNB-1:x2ToGnbLinkStatus=available
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=31    id_type=cus
    Set ue parameters before attach

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1}
    ...     - {qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 7, pdn: 1}
    ...     - {qci: 9, pdn: 1}
    ...     - {qci: 8, default: on, pdn: 2, trf_type: external}
    ...     - {qci: 6, pdn: 2}
    ...     - {qci: 7, pdn: 2}
    ...     - {qci: 9, pdn: 2}
    FOR    ${ue_set_id}     IN RANGE    1    11
        Update Yaml    UEs/UE_sets/${ue_set_id}    bearer: 'bearer_set_1'
    END
    FOR    ${ue_set_id}     IN RANGE    11    21
        Update Yaml    UEs/UE_sets/${ue_set_id}    bearer: 'bearer_set_2'
    END
    Add Yaml    BASE_STATIONS
    ...      - id: 7
    ...        gnb_id: '0x00007'
    ...        type: simulated
    ...        plmn: '262:03'
    ...        s1u: 10.0.1.11
    ...        x2: 10.0.1.11
    ...        cells:
    ...          - ${gnb7_cell1}
    ...          - ${gnb7_cell2}
    ...          - ${gnb7_cell3}
    Add Yaml    BASE_STATIONS
    ...      - id: 8
    ...        gnb_id: '0x00008'
    ...        type: simulated
    ...        plmn: '262:03'
    ...        s1u: 10.0.1.12
    ...        x2: 10.0.1.12
    ...        cells:
    ...          - ${gnb8_cell1}
    ...          - ${gnb8_cell2}
    ...          - ${gnb8_cell3}
    Add Yaml    BASE_STATIONS
    ...      - id: 9
    ...        gnb_id: '0x00009'
    ...        type: simulated
    ...        plmn: '262:03'
    ...        s1u: 10.0.1.10
    ...        x2: 10.0.1.10
    ...        cells:
    ...          - ${gnb9_cell1}
    ...          - ${gnb9_cell2}
    ...          - ${gnb9_cell3}

Set ue parameters before attach
    [Arguments]    ${ue_id}=1-20
    FOR    ${gNB_id}    IN RANGE    7    9
        Execute Egate Command    gnb_endc_param id=${gNB_id} use_nr_ran_cont=true include_reestablish_pdcp=on scg_dl_dist_percent=0
    END
    Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=${ue_id} type=nr supported_bands=78,258
    Execute Uex Command    ue_cqi_param id=${ue_id} scell=0-3 rank=4 cell=both
    Execute Egate Command    gnb_param id=7 sib1_period=30000    #make gnb7 send sib1,0 means not_send
    Execute Egate Command    gnb_param id=8 sib1_period=0    #means not_send

Trigger ANR by UE
    Attach UE1-UE6 to CELL-1 with default QCI8
    Trigger UE1-UE6 to send B1-NR reports with PCI1 6-times cross add threshold then detach UE1-UE6
    Attach UE11 and reportCGI CGI1 for UE11 after ANR trigger    ue_id=11

Attach UE1-UE6 to CELL-1 with default QCI8
    FOR    ${ue_id}    IN RANGE    1    7
        ${V_1}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
        ...    ue_eutra_capabilities=${ue_eutra_capabilities} enb=1 cell=1
        Execute Uex Command    ${V_1}
    END

Trigger UE1-UE6 to send B1-NR reports with PCI1 6-times cross add threshold then detach UE1-UE6
    FOR    ${ue_id}    IN RANGE    1    7
        Expect message flow
        ...    UE_GROUP_${ue_id}:RRC_MeasurementReport(measResults contains (measId eq 17))
        ...    alias=UE_send_B1    overall_timeout=20
        Execute Uex Command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=1 nrsrp=97 nrsrq=34 narfcn=2036672 amount=1
        Flow Occurred As Expected    alias=UE_send_B1
    END
    Execute Uex Command    ue_detach id=1-6


Attach UE11 and reportCGI CGI1 for UE11 after ANR trigger
   [Arguments]    ${ue_id}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration(reportConfigToAddModList contains (purpose eq 'reportStrongestCells'))
    ...    UE_GROUP_${ue_id}:RRC_MeasurementReport(measResults contains (measId eq 32))
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration(reportConfigToAddModList contains (purpose eq 'reportCGI'))
    ...    UE_GROUP_${ue_id}:RRC_MeasurementReport((measResults contains (measId eq 32)) and (cgi-Info-r15 is present))
    ...    alias=RSC_and_CGI1    overall_timeout=20
    Set RSC report and CGI1 param with RSRP and RSRQ for UE    11
    attach UE    ue_id=${ue_id}
    Flow Occurred As Expected    alias=RSC_and_CGI1
    sleep    34s    #anrNrInactivityTimer 15s;anrNrCoverageConfirmTimer 2.5s;anrNrFr2ReportCgi is 16.2s
    Execute Uex Command    ue_detach id=11

Set RSC report and CGI1 param with RSRP and RSRQ for UE
    [Arguments]    ${ue_id}
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=1 narfcn=${NRARFCN2036667} nrsrp=56 nrsrq=78 strongest=nr5g
    ...    cgi_plmn_group cgi=262:03|0x1C501 rac=125 tac=33
    ...    cgi_plmn_group cgi=253:560,253:561,253:562|0x78D1B1AB rac=221 tac=491532
    Run Uex Command    ${cmd}

Set RSC report and CGI2 param with RSRP and RSRQ for UE
    [Arguments]    ${ue_id}
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=1 narfcn=${NRARFCN2036667} nrsrp=56 nrsrq=78 strongest=nr5g
    ...    cgi_plmn_group cgi=262:03|0x24507 rac=125 tac=33
    ...    cgi_plmn_group cgi=253:560,253:561,253:562|0x78D1B1AB rac=221 tac=491532
    Run Uex Command    ${cmd}

LNRELGNBCELL-255 and LNADJGNB-127 should be created
    [Arguments]    ${LNADJGNB}    ${LNRELGNBCELL}
    Object Should Exist    ${LNADJGNB}
    Object Should Exist    ${LNRELGNBCELL}

Delete LNRELGNBCELL-255
    Delta Commission Parameters    ${del_LNRELGNBCELL255}

LNRELGNBCELL-255 is created successfully according to CGI1
    Object Should Exist    ${LNRELGNBCELL255_CGI1_case2}

Attach UE12 and check trigger RSC and reportCGI CGI2 for UE12 after ANR timer expire
  [Arguments]    ${ue_id}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration(reportConfigToAddModList contains (purpose eq 'reportStrongestCells'))
    ...    UE_GROUP_${ue_id}:RRC_MeasurementReport(measResults contains (measId eq 32))
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration(reportConfigToAddModList contains (purpose eq 'reportCGI'))
    ...    UE_GROUP_${ue_id}:RRC_MeasurementReport((measResults contains (measId eq 32)) and (cgi-Info-r15 is present))
    ...    alias=RSC_and_CGI2    overall_timeout=20
    Set RSC report and CGI2 param with RSRP and RSRQ for UE    12
    attach UE    ue_id=${ue_id}
    Flow Occurred As Expected    alias=RSC_and_CGI1
    sleep    5s    #anrNrInactivityTimer set to 5s
    sleep    2500ms    #anrNrCoverageConfirmTimer default is 2.5s
    sleep    2s    #anrNrFr2ReportCgi is 2s


attach UE
    [Arguments]    ${ue_id}
    ${V_2}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} enb=1 cell=1
    Execute Uex Command    ${V_2}
