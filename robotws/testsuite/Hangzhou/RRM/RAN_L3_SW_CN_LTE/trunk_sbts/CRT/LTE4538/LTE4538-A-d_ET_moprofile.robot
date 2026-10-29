*** Settings ***
Suite Setup    Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...    owner-Allen.Ge    owner-rebecca.zhong    release-xL18    team-DEVHZ5_FT3
Resource    ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS-1:actRLFbasedRCR=true
...    LNBTS-1:actIfHo=enabled
...    LNCEL:inactivityTimer=600
...    LNBTS-1/CATMPR-1:inactivityTimerCatM=170
...    LNBTS-1/CATMPR-1:raPreGrCSizeCatM=5
...    LNBTS-1/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=180
...    LNBTS-1/CATMPR-1:qciForVoLTECatM=255
...    LNBTS-1/CATMPR-1:catMVoLTETab:maxGbrDlQci1CatM=80
...    LNBTS-1/CATMPR-1:catMVoLTETab:maxGbrUlQci1CatM=80
...    LNCEL:iniMcsUl=4
...    LNCEL:threshold1=75
...    LNCEL:threshold2InterFreq=40
...    LNCEL:threshold2a=67
...    LNCEL:threshold2aQci1=67
...    LNCEL:hysThreshold2InterFreq=0
...    LNCEL:cellResourceGroupPrId=1
...    LNCEL:inactivityTimerPubSafety=600
...    LNCEL:iFServiceBasedHoRetryTimer=60
...    LNCEL:threshold2GERANQci1=25
...    LNCEL:threshold2InterFreqQci1=35
...    LNCEL:threshold2InterFreqHpue=40
...    LNCEL:a2TimeToTriggerActWcdmaMeas=0ms
...    LNCEL/SIB-0:siWindowLen=40ms
...    LNCEL:a2TimeToTriggerActInterFreqMeas=100ms
...    LNCEL:t301Guard=100
...    LNBTS-1/CATMODPR-0:autoAdaptCatM=enabled
...    LNBTS-1/CATMODPR-0:freqLayListCatM=1450
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=359
...    LNCEL/SIB-0:threshServingLowQR9=0
...    LNCEL/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrc=329
...    LNCEL/LNCEL_FDD-0:addNumDrbRadioReasHo=24
...    LNCEL/LNCEL_FDD-0:addNumDrbTimeCriticalHo=24
...    LNCEL-1/CATMCEL-0:actSelMobPrfCatM=disabled
...    LNCEL-1/CATMCEL-0:moProfileSelectCatM=spid
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1800
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19800
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1600
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=4000
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=1450
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-2/LNHOIF-2:eutraCarrierInfo=4000
...    LNCEL-2/LNHOIF-3:eutraCarrierInfo=1450
...    LNCEL-3/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-3/LNHOIF-2:eutraCarrierInfo=1600
...    LNCEL-3/LNHOIF-3:eutraCarrierInfo=1450
...    LNCEL/LNCEL_FDD-0:actCatM=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL/LNCEL_FDD-0:catMProfId=1
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=2
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=0
...    LNCEL/CATMCEL-0:threshold2CatM=42
...    LNCEL/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL/CATMCEL-0:actIntraFreqHoCatM=true
...    LNCEL/CATMCEL-0:actRLFbasedRCRCatM=true
...    LNCEL/CATMCEL-0:actConvVoiceCatM=true
...    delete:LNBTS-1/PSGRP-1
...    @{LNREL}
...    @{fix_relation_error}
@{LNREL}
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:ecgiLcrId=2
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-3:handoverAllowed=allowed
...    LNCEL-1/LNREL-3:ecgiLcrId=3
...    LNCEL-1/LNREL-3:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-2:handoverAllowed=allowed
...    LNCEL-2/LNREL-2:ecgiLcrId=1
...    LNCEL-2/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-3:handoverAllowed=allowed
...    LNCEL-2/LNREL-3:ecgiLcrId=3
...    LNCEL-2/LNREL-3:ecgiAdjEnbId=1
...    LNCEL-3/LNREL-2:handoverAllowed=allowed
...    LNCEL-3/LNREL-2:ecgiLcrId=1
...    LNCEL-3/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-3/LNREL-3:handoverAllowed=allowed
...    LNCEL-3/LNREL-3:ecgiLcrId=2
...    LNCEL-3/LNREL-3:ecgiAdjEnbId=1
@{fix_relation_error}
...    LNCEL-1/MBSFNCEL-0:mbsfnAreaInUseList=0
...    LNBTS/LNMCE-0:mceName=1
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0/MBSFN_FDD-0:mbsfnAreaId=0
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnEarfcn=1400
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=10 MHz

${UE_EUTRA_CAPABILITIES_CATM}    D628030300082100C1F83F07E0FFFC3062FF282008800886400C08216A7008047480003184000AEC04390A6A03AA14908000000100
# CATM FGI3,7,20 set as 1,enable ROHC
@{Online_change_ rlfBasedRCRsupported}
...    LNBTS-1/LNADJ-255:rlfBasedRCRsupported=true


*** Test Cases ***
LTE4538-A-d_ET_01_02_Success_RCR_in_X2_RLF_with_target_Freq_in_MODPR_and_LNHOIF
    [Tags]
    Online change rlfBasedRCRsupported
    CAT-M ModeA UE attached SIM-eNB2 cell21
    Set if RRC connect reconfiguration massage contain mobility control info
    Handover to eNB1 cell1

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    # add sim enb2
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      x2: 10.0.1.3
    ...      cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1450:19450', bw: 20}
    ...        - {id: 22, technology: lte, tac: 33, pci: '3:1', earfcn: '5920:23920', bw: 20}
    ...        - {id: 23, technology: lte, tac: 33, pci: '3:2', earfcn: '8770:26770', bw: 20}

Online change rlfBasedRCRsupported
    [Arguments]    ${Online_param}=@{Online_change_ rlfBasedRCRsupported}
    Delta Commission Parameters    ${Online_param}

CAT-M ModeA UE attached SIM-eNB2 cell21
    Execute Egate Command    enb_param id=2 sib1_br_period=1000 sib2_br_period=1000
    Execute Egate Command    enb_cell_param enb=2 scheduling_info_sib1_br=21
    Execute Egate Command    ue_enb_param id=1 ue_config_release_r9=rel13
    Execute Uex Command    ue_attach id=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} enb=2 cell=21


Set if RRC connect reconfiguration massage contain mobility control info
    Execute Uex Command
    ...    ue_rrc_reconf_param id=1 if_contains=mobilityControlInfo action=reestablish cause=handoverFailure cell=2 nth=1

Handover to eNB1 cell1
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReestablishmentRequest (ue-Identity contains (physCellId eq 9) and reestablishmentCause eq 'handoverFailure')
#    ...    ENB:RRC_RRCConnectionReestablishmentRequest (ce-Mode-r13 contains (setup eq 'ce-ModeA'))
    ...    alias=UE_RCR_flow    overall_timeout=20
    Execute Egate Command    enb_param id=2 ho_source=x2
    execute uex command and expect error    ue_ho id=1 enb=1 cell=1    sErrTransactionInProgress
    Flow Occurred As Expected    alias=UE_RCR_flow


