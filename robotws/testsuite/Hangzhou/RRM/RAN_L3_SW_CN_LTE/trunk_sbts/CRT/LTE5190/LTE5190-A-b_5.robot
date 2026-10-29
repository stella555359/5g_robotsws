*** Settings ***
Documentation     INTRODUCTION: LTE5190 delivers support in eNB for gNB initiated partial X2 reset procedure
...               3GPP 36.423 -f40-R15. gNB may trigger this procedure for example in context of
...               cell deletion/deactivation on gNB side. Support of this procedure then allows to
...               release EN-DC bearers only from the impacted NR cell instead of the whole gNB.
...               eNB for UEs in ENDC mode included in X2PartialResetRequired performs ERAB release
...               for all required bearers. for the client it would be better to change SCG split to MCG bearer,
...               so this E-RAB Release should be seen as limitation/drawback in EN-DC functionality, also when
...               the last non-GBR bearer is released this causes UE Context Release
...               TEST SET NAME: LTE5190-A-b: Sunny Day
...               TESTING SPLIT:
...               LTE5190-A-a: Feature Activation
...               LTE5190-A-b: Sunny Day
...               LTE5190-A-c: Failure cases
...               LTE5190-A-d: SgNB initiated X2 Partial Reset during SgNB procedures
...               LTE5190-A-e: PM Counters
...               CONTACTS: Konrad Krzyzak konrad.krzyzak@nokia.com
...               ETK8 team I_EXT_LTE_ETK8_GMS <I_EXT_LTE_ETK8@internal.nsn.com>
...
...               REFERENCES:CFAM LTE5190; LTE_Control_ Plane_requierments
...
...               HISTORY:
...               [08.08.2019] - initial AC version
...               [25.08.2019] - Approved by team members https://fisheye3.int.net.nokia.com/cru/ROBOTLTE-2677
...               [<date>] - Test finished at SVN revision <svn_revision>
...               [30.08.219] - Review closed

Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4BO9_CUS
...               NEW_HW_ABION    team-SG4    release-SBTS23R4    owner-Anna Pokrywka
Resource          ../../../resources/DevHZ5_resource.robot
Library           LTE5190_A_common_CUS.py

*** Variables ***
@{PARAMS_IN_SCF}
...    @{delta_LTE5190_ABION}

@{delta_LTE5190_ABION}
...    MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1:systemAcctPermEnable=false
...    MRBTS-1/LNBTS-1/LNADJGNB-1:administrativeState=unlocked
...    MRBTS-1/LNBTS-1/LNADJGNB-1:cPlaneIpAddr=10.0.1.25
...    MRBTS-1/LNBTS-1/LNADJGNB-2:administrativeState=unlocked
...    MRBTS-1/LNBTS-1/LNADJGNB-2:cPlaneIpAddr=10.0.1.26
...    MRBTS-1/LNBTS-1/LNADJGNB-3:administrativeState=unlocked
...    MRBTS-1/LNBTS-1/LNADJGNB-3:cPlaneIpAddr=10.0.1.28
...    LNBTS-1:act8EpsBearers=true
...    LNBTS-1:actEnDcX2PartialReset=gNB triggered
...    LNBTS-1:actEnhAcAndGbrServices=true
...    LNBTS-1:actFlexQCIARPPMProfiles=true
...    LNBTS-1:actLteNrDualConnectivity=true
...    LNBTS-1:actEndcSpidFwd=false
...    LNBTS-1:tS1eRABModInd=2000
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNBTS-1:actTransmittedBelowGap=false
...    LNBTS-1:nrRestrictionOverride=disabled
...    LNBTS-1:actMultBearers=true
...    LNBTS-1:actMultGbrBearers=true
...    LNBTS-1:actNonGbrServiceDiff=true
...    LNBTS-1:forcedPlanFileActivation=true
...    LNBTS-1:pdcpProf1001:pdcpProfileId=1001
...    LNBTS-1:pdcpProf1001:snSizeDl=18bit
...    LNBTS-1:pdcpProf1001:snSizeUl=18bit
...    LNBTS-1:pdcpProf1001:statusRepReq=0
...    LNBTS-1:pdcpProf1001:tDiscard=300ms
...    LNBTS-1:qciTab6:drxProfileIndex=3
...    LNBTS-1:qciTab6:dscp=18
...    LNBTS-1:qciTab6:enforceTtiBundling=false
...    LNBTS-1:qciTab6:lcgid=3
...    LNBTS-1:qciTab6:lteNrDualConnectSupport=EN-DC
...    LNBTS-1:qciTab6:nrPdcpProfIdx=1001
...    LNBTS-1:qciTab6:pdcpProfIdx=2
...    LNBTS-1:qciTab6:qciSupp=ENABLE
...    LNBTS-1:qciTab6:rlcProfIdx=2
...    LNBTS-1:qciTab6:rlcProfIdx3cc=6
...    LNBTS-1:qciTab6:rlcProfIdx4cc5cc=7	  
...    LNBTS-1:qciTab6:schedulBSD=300ms	  
...    LNBTS-1:qciTab6:schedulPrio=9
...    LNBTS-1:qciTab6:schedulWeight=20	  
...    LNBTS-1:tLteNrDualConnectPrep=10000
...    LNCEL-1:eTputInitMcs=20
...    LNCEL-1:eTputFilterConfig=51
...    LNCEL-2:eTputInitMcs=20
...    LNCEL-2:eTputFilterConfig=51
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1/LNRELGNBCELL-0:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-0:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-0:nrCellId=294913
...    LNCEL-1/LNRELGNBCELL-0:nrCgiPlmnId:mcc=250
...    LNCEL-1/LNRELGNBCELL-0:nrCgiPlmnId:mnc=555
...    LNCEL-1/LNRELGNBCELL-0:nrCgiPlmnId:mncLength=3
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=311297
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=250
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=555
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=3
...    LNCEL-1/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-2:nrCellId=344065
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mcc=250
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mnc=555
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=3
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS-1/PMRNL-1:mtERABPMQAPProfile=15min
...    LNBTS-1/PMRNL-1:mtUEQuantity=15min
...    LNCEL-1:defaultLnRelGnbCellId=0
...    LNCEL-1:harqMaxTrVoLteDl=4
...    LNCEL-2:harqMaxTrVoLteDl=4
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=300
...    LNCEL-2/LNCEL_FDD-0:maxNumActDrb=240
...    LNBTS-1/PMRNL-1/PMQAP-1:cfgPRI=20
...    LNBTS-1/PMRNL-1/PMQAP-1:cfgQCIRange=6
...    GTPU-1:gtpuN3Reqs=2
...    GTPU-1:gtpuPathSupint=10
...    GTPU-1:gtpuT3Resp=2
...    GTPU-1:sgwIpAddressList:transportNwId=0|sgwIpAddress=10.0.1.21

@{LTE5190_Ab5_SBTS20C}
...    LNBTS-1:actDynTrigLteNrDualConnectivity=true
...    LNBTS-1:actEnDcX2PartialReset=gNB triggered
...    LNBTS-1:actLteNrDualConnectivity=true
...    LNBTS-1:actMultBearers=true
...    LNBTS-1:actMultGbrBearers=true
...    LNBTS-1:rrcGuardTimer=300
...    LNBTS-1:tLteNrDualConnectPrep=10000
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased|lcrId=11
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased|lcrId=12
...    LNBTS-1/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS-1/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=86
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrq=-80
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=524704
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7|priority=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=2
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:nrCarPrio=1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf10-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=86
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrq=-80
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=185632
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=8|priority=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=2
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:nrCarPrio=1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf10-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=15kHz
...    LNCEL-1:inactivityTimer=300

${X2PR_INIT_SGNB_ATT}    M8074C2
${X2PR_INIT_SGNB_SUCC}    M8074C3
${SCG_ADD_PREP_ATT}    M8080C0
${SCG_ADD_PREP_FAIL_T}    M8080C2
${SCG_ADD_PREP_SUCC}    M8080C3
${SCG_ADD_COMPLETION_SUCC}    M8080C14
${SCG_TOT_REL_INIT_SGNB}    M8080C7
${SCG_TOT_REL_INIT_MENB}    M8080C9
${SGNB_ABN_REL_INIT_SGNB_X2PR}    M8080C51
${SCG_ABN_REL_INIT_SGNB_X2PR}    M8080C52

@{LTE5190_A_b_5_Counters}
...    LNBTS-1:${X2PR_INIT_SGNB_ATT}=1
...    LNBTS-1:${X2PR_INIT_SGNB_SUCC}=1
...    LNCEL-1:${SCG_ADD_PREP_ATT}=80
...    LNCEL-1:${SCG_ADD_PREP_FAIL_T}=0
...    LNCEL-1:${SCG_ADD_PREP_SUCC}=80
...    LNCEL-1:${SCG_ADD_COMPLETION_SUCC}=80
...    LNCEL-1:${SCG_TOT_REL_INIT_SGNB}=0
...    LNCEL-1:${SCG_TOT_REL_INIT_MENB}=0
...    LNCEL-1:${SGNB_ABN_REL_INIT_SGNB_X2PR}=50
...    LNCEL-1:${SCG_ABN_REL_INIT_SGNB_X2PR}=50

${ue_eutra_capabilities_1}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000
...    0007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFBFFEC80080
...    1C364000000017BA000000080952A2E31D0100000208000420000860001100002280004600008E0001200002480004A0000960001300002680005
...    00000A2000148000298000540000AA0001580002B8000580000B20001680002D80005D0000BC0001B40003F800E9D00000000E800000007400000
...    003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00
...    000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001
...    D00000000E80000000504000003CE800000000000000000000000000000000000000000000000000000000000808E21090002A800180229700002
...    0000104B1A0000CF00000060000002420008002100

${ue_eutra_capabilities_2}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000
...    0007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFBFFEC80080
...    1C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004C00009A00014
...    0000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A00000001D000000
...    00E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800
...    000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007
...    400000003A0000000141000000F3A00000000000000000000000000000000000000000000000000000000000202388425300C39FFFFFFFFFFFFFF
...    F42A0006008A5C000080000412C28040300E023C00000180000008

${ue_nr_capabilities}    000000000101004000004000003000001C040360401C04000E03000701C0000000

${ue_eutra_nr_capabilities}    0108040460201C04000E03000701C001818000000080001008080100202004008080100200010080

*** Test Cases ***
LTE5190_A_b_5_X2PartialReset_parallel_with_ENDC_for_other_UEs_with_the_same_gNB
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  == Info: ==
    ...    Test verifies X2PartialResetRequired for UEs with SCG split bearers on gNB does not block
    ...    other ENDC related procedure on the same link to gNB for other UEs.
    ...
    ...  == Precondition: ==
    ...    - LTE5190 is enabled (actEnDcX2PartialReset = true)
    ...    - LTE4088 is enabled (actLteNrDualConnectivity = true)
    ...    - LTE4193 is enabled (actDynTrigLteNrDualConnectivity = true)
    ...    - LTE4531 is disabled (actMultiSCGSplit = false)
    ...    - X2 link is established with gNB
    ...    - UEs connected to serving cell (RRC Connected state)
    ...    - UE_20-50 have been configured with one SCG split bearer on dedicated UE bearer and additional not splitted non-GBR bearer
    ...    - UE51-80 have been configured with 3ENDC eligable bearers and additional non-GBR bearer
    ...    - Set below timers to ensure parallel execution of UE/gNB procedures:
    ...             --- MME timer T_S1APInitialContextSetup set to 50000ms
    ...             --- eNB rrcGuardTimer set to 30000ms
    ...             --- eNB tLteNrDualConnectPrep set to 10000ms
    ...             --- UE51-80 set to delay RRCReconfiguration procedure by 8000ms
    ...  == Description: ==
    ...    UE_20-50 attach to cell_1
    ...    B1NR measurment installed on UE_20-50
    ...    UE_20-50 reported B1NR above configured thersholds
    ...    SCG split bearer for attached UE_20-50 configured
    ...    UE51-80 attach to cell_1
    ...    B1NR measurment installed on UE51-80
    ...    UE51-80 starts sending B1NR above configured thresholds and in parallel
    ...    gNB sends X2AP: PartialResetRequired to eNB with UE_20-50 IDs
    ...    eNB sends X2AP: PartialResetConfirm to gNB
    ...    SCG split bearers are released from UE_20-50
    ...    ERAB related to SCG split bearers is released from UE_20-50
    ...    SCG split bearer for UE51-80 configured sucessfully
    ...  == Postcondition: ==
    ...    LTE5190 is enabled
    ...    SCG Split bearers are removed from UE_20-50
    ...    SCG Split bearers added to UE51-80
    ...
    ...  TESTING TOOLS:
    ...                UTE_CLOUD - CLOUD_R4P; IPHY, EPCSIM, EMSSIM, UTE
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:  AHFB_AHIB_AZRA
    ...
    ...   *REQUIREMENTS COVERAGE: This is optional ONLY for EXPLORATORY or MANUAL test cases.
    ...                           In automated test cases this is mandatory.
    ...       *REQUIREMENTS IN SCOPE:  LTE_CP_98383
    ...       *BACKLOG ID: to identify the CA/Epic(the lowest backlog item) key issue ID from Fusion backlog
    ...                    (Field Values e.g.: FPB-328390) - this is MANDATORY for Features from release 20A onward
    ...
    ...  REQUIRED LOGS:  pcap UU and pcap S1AP/X2AP
    ...
    ...  CONTACTS:  Konrad krzyzak   konrad.krzyzak@nokia.com
    ...
    ...  REFERENCES:  CFAM LTE5190
    ...       HISTORY:
    ...          To be left in robot file:
    ...               [22.08.2019] -  initial AC version
    ...               [25.08.2019] - Approved by team members https://fisheye3.int.net.nokia.com/cru/ROBOTLTE-2677
    ...               [<date>] - Test finished at SVN revision <svn_revision>
    ...               [30.08.219] - Review closed 
    [Tags]    RAN_4G    RAN_4G_FDD    CRT    TC5    Author-Anna Pokrywka
	Prepare enviroment for test
    Start RTPM Counter
    Attach first group of 50UEs and trigger SCG split bearer configuration via B1NR measurement
    Attach second group of 30UEs
    Verify amount of UEs with SCG split bearer is equal to 50
	Configure param for second group of 30UEs to delay respose for RRCConnectionReconfiguration during SCG split addition
    Set observers for parrallel procedures
    Trigger SCG split bearer configuration towards second group of 30UEs via B1NR measurement
    Trigger X2AP: Partial Reset Required from SgNB to MeNB with cause unspecified towards first group of 50UE
    Verify number of ACTIVE UEs is equal to 80
    Verify amount of UEs with SCG split bearer is equal to 30
    Verify that SCG bearer addition and X2PartialReset was executed parrallel
    check rtpm counters    ${LTE5190_A_b_5_Counters}

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=LTE5190_2CELLs_FDD_B2_B4    ue_count=200
    Create Alias

Create Alias
    FOR    ${ue_id}    IN RANGE    1    130
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=130    id_type=cus
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus
    Create ENB alias    alias=MeNB    enb_id=1    id_type=wts
    Create ENB alias    alias=SgNB1    enb_id=2    id_type=wts
    Create ENB alias    alias=SgNB2    enb_id=3    id_type=wts

Modify Yaml
    FOR    ${ue_id}     IN RANGE    1    20
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_1
    END
	FOR    ${ue_id}     IN RANGE    20    40
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
    END
	FOR    ${ue_id}     IN RANGE    40    50
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_3
    END
	FOR    ${ue_id}     IN RANGE    50    100
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_4
    END
	FOR    ${ue_id}     IN RANGE    100    201
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_5
    END
	
Set test A_b_5 preconditions
    Delta Commission Parameters    ${LTE5190_Ab5_SBTS20C}
    log to console   \n\nTO BE CHECK WHY YAML IS NOT WORKING AS EXPECTED !\n\n
    Run WTS command    mme_timer    T_S1APInitialContextSetup=80s
	
Prepare enviroment for test
    Set GNB parameters for ENDC setup
    Set test A_b_5 preconditions

Set GNB parameters for ENDC setup
    Execute Egate Command    gnb_endc_param enable_dl_data_forwarding=1 enable_ul_data_forwarding=1 use_nr_ran_cont=true id=2
    Execute Egate Command    gnb_endc_param scg_dl_dist_percent=50 id=2
    Execute Egate Command    gnb_endc_param enable_dl_data_forwarding=1 enable_ul_data_forwarding=1 use_nr_ran_cont=true id=3
    Execute Egate Command    gnb_endc_param scg_dl_dist_percent=50 id=3
    Execute Egate Command    gnb_endc_param enable_dl_data_forwarding=1 enable_ul_data_forwarding=1 use_nr_ran_cont=true id=4
    Execute Egate Command    gnb_endc_param scg_dl_dist_percent=50 id=4
    Execute Egate Command    gnb_endc_param enable_dl_data_forwarding=1 enable_ul_data_forwarding=1 use_nr_ran_cont=true id=5
    Execute Egate Command    gnb_endc_param scg_dl_dist_percent=50 id=5              
    Execute Egate Command    gnb_param_endc id=2 include_reestablish_pdcp=on
    Execute Egate Command    gnb_param_endc id=3 include_reestablish_pdcp=on
    Execute Egate Command    gnb_param_endc id=4 include_reestablish_pdcp=on
    Execute Egate Command    gnb_param_endc id=5 include_reestablish_pdcp=on
    Execute Egate Command    mme_param id=1 s1_hb_interval=120
    Run UEx command    ue_param id=1..39 dl_256QAM_supported=on pdcp_sn_extension=on dual_conn=eutra_nr supported_bands_nr=7
    Run UEx command    ue_param id=40..49 ue_eutra_capabilities=${ue_eutra_capabilities_1}
    ...    ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    elcid=true
    Run UEx command    ue_param id=50..150 ue_eutra_capabilities=${ue_eutra_capabilities_2}
    ...    ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}

Attach first group of 50UEs and trigger SCG split bearer configuration via B1NR measurement
    [Arguments]    ${first_ue_id}=50   ${last_ue_id}=99
    Run UEx Command    ue_attach    id=${first_ue_id}..${last_ue_id}    cell=11
    Run UEx Command    ue_measurement_send    id=${first_ue_id}..${last_ue_id}    phycell_id=384    nrsrp=90    nrsrq=30
    ...    event=B1_NR
	
Attach Second Group Of 30UEs
    [Arguments]    ${first_ue_id}=100    ${last_ue_id}=130
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}    ${last_ue_id}
        Execute Uex Command    ue_attach id=${ue_id} enb=1 cell=11
    END

Configure param for second group of 30UEs to delay respose for RRCConnectionReconfiguration during SCG split addition
    Configure param for second group of 30UEs to delay respose for RRC during SCG split addition    first_ue_id=100   last_ue_id=130

Set observers for parrallel procedures
    Expect Message Flow
    ...                 UE_120:RRC_RRCConnectionReconfiguration as RRCReconfig
    ...                 UE_120:RRC_RRCConnectionReconfigurationComplete as RRCComplete
    ...                 alias=UE120_SCG_Add   overall_timeout=60
    Expect Message Flow
    ...                 SgNB2:X2AP_ENDCPartialResetRequired as ResetRequired
    ...                 MeNB:X2AP_ENDCPartialResetConfirm as ResetConfirm
    ...                 alias=PartialReset    overall_timeout=60

Trigger SCG split bearer configuration towards second group of 30UEs via B1NR measurement
    [Arguments]    ${first_ue_id}=100   ${last_ue_id}=129
    Run UEx command    ue_measurement_send    id=${first_ue_id}..${last_ue_id}    phycell_id=384    nrsrp=90    nrsrq=30
    ...    event=B1_NR

Trigger X2AP: Partial Reset Required from SgNB to MeNB with cause unspecified towards first group of 50UE
    Run WTS command    link_x2_reset    from=3 to=1 ue=50-99

Verify number of ACTIVE UEs is equal to 80
    [Arguments]    ${expected_ue_count}=80
    Sleep  5
    ${eNB_ACTIVE_ue_number}=  get_number_of_UE_in_ACTIVE_state_from_eNB
    should be equal as integers  ${eNB_ACTIVE_ue_number}   ${expected_ue_count}

Verify amount of UEs with SCG split bearer is equal to 50
    [Arguments]    ${ue_count}=50
    verify_num_of_ue_per_gNB  gnb_id=3   num_of_expected_ues=${ue_count}

Verify amount of UEs with SCG split bearer is equal to 30
    [Arguments]    ${ue_count}=30
    verify_num_of_ue_per_gNB  gnb_id=3   num_of_expected_ues=${ue_count}

Verify that SCG bearer addition and X2PartialReset was executed parrallel
    Flow occurred as expected   alias=UE120_SCG_Add
    Flow occurred as expected   alias=PartialReset
