*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Case Teardown
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_R4LAPO_CUS
...               release-SBTS00    team-DevHZ5_SG1    owner-zijing.wu
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${NRARFCN657700}    656736
@{PARAMS_IN_VENDOR}
...    LNBTS:reportTimerEndcA5=5000ms
@{PARAMS_IN_SCF}
...    LNBTS:actUeCapEndcHo=true
...    LNBTS:actLteNrDualConnectivity=true
#4193 switch,B1 measurement,trigger blind when disable it
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS:actIfHo=enabled
...    LNBTS:actSelMobPrf=false
...    LNBTS/MODPR-0:autoAdapt=false
...    LNBTS:actMultBearers=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-2/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-3/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-2/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-3/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=5920
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=5920
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1700
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19700
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-1:threshold1=75
...    LNCEL-2:threshold1=76
...    LNCEL-3:threshold1=77
...    @{LTE5150_param}
...    @{ENDC_Setup}
...    @{Config_for_CAIMLBP}
...    @{Config_for_MFBI}
...    @{LTE4088}
...    @{LNADJGNB}
...    LNBTS:blockEndcHoRetryAtHoFromTrg=MR-DC based HO
...    @{CB006607}
...    @{enable9920}

@{CB007334}
...    LNBTS:actUeBasedAnrNr=true
...    LNBTS:maxNumAnrMoiAllowed=4000
...    LNBTS/ANR-0:anrNrNbrRelRemGuardTime=2
...    LNBTS/ANR-0:actAutoNrNeighRemoval=false
...    LNBTS/ANR-0:anrNrParamList:anrDefRelDcAllowed=true|paramPlmnId=0
...    LNBTS/ANR-0:anrNrParamList:carrierFreqNrCell=${NRARFCN657700}|paramPlmnId=0
...    LNBTS/ANR-0:anrNrParamList:gNBIdLength=22|paramPlmnId=0
...    LNBTS/ANR-0:anrNrParamList:frqNrCarSelect=All|paramPlmnId=0
...    LNBTS/ANR-0:anrNrParamList:paramMeasConfId=1|paramPlmnId=0
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=6|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-80|paramMeasConfId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/ANR-0:anrNrParamPlmnList:mcc=262|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mnc=3|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mncLength=2|paramPlmnId=1

${count_of_auto_remove}    0x1300E2
@{PARAMS_IN_SWCONFIG}
...    ${count_of_auto_remove}=1

@{ENDC_Setup}
...    LNBTS:tLteNrDualConnectPrep=2000
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=100sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=86
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrq=-20
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN657700}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=77
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-1/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-2:nrCellId=115972
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNCEL-1/LNRELGNBCELL-4:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-4:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-4:nrCellId=132353
...    LNCEL-1/LNRELGNBCELL-4:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-4:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-4:nrCgiPlmnId:mncLength=2
...    delete:LNCEL-2:defaultLnRelGnbCellId
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    delete:LNCEL-3:defaultLnRelGnbCellId
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    delete:LNCEL-1/LNRELGNBCELL-0
...    delete:LNCEL-2/LNRELGNBCELL-0
...    delete:LNCEL-3/LNRELGNBCELL-0

@{LTE5150_param}
...    LNBTS:actEndcHo=enabled
...    LNBTS/MODPR:freqLayEndcHoList:freqLayer=5920
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-2/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-2/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNBTS/MODPR-0:freqLayEndcHoList:freqLayer=5920
...    LNBTS/MOPR-1:freqLayEndcHoList:freqLayer=5920
...    LNCEL-1:moPrMappingList:moPrId=1|spid=1
...    LNCEL-2:moPrMappingList:moPrId=1|spid=1

@{Config_for_MFBI}
...    LNBTS:actMFBI=true
...    LNBTS/MFBIPR-0:addFreqBandInd=26
...    LNBTS/MFBIPR-0:eutraCarrierFreq=5920

@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:actEndcSpidFwd=true
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=FR1
...    LNBTS:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNBTS-1:qciTab8:nrPdcpProfIdx=1001
...    LNBTS-1:qciTab8:lteNrDualConnectSupport=EN-DC
...    LNBTS-1:pdcpProf1001:pdcpProfileId=1001
...    LNBTS-1:pdcpProf1001:snSizeDl=18bit
...    LNBTS-1:pdcpProf1001:snSizeUl=18bit
...    LNBTS-1:pdcpProf1001:statusRepReq=0
...    LNBTS-1:pdcpProf1001:tDiscard=300ms

@{LNADJGNB}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNBTS/LNADJGNB-1:x2ToGnbLinkStatus=available
...    LNBTS/LNADJGNB-2:administrativeState=unlocked
...    LNBTS/LNADJGNB-2:cPlaneIpAddr=10.0.1.12
...    LNBTS/LNADJGNB-2:x2ToGnbLinkStatus=available

${ue_eutra_capabilities}
...    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C1082080304
...    218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B082008284105182083841004142082061040
...    105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B
...    82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71E0002040
...    6080C0E162636383A83F7FC4B5A68190BFCD08750003006D9200004000020973C0600002404061304D0A1E01BFE00000500000030800440002

#modify supportedBandCombinationList from NR258 to NR77
${ue_MRDC_capabilities}
...    SEPARATOR=
...    C10060B71B02004040C18038980000000FD00000000081B8981002060E2680000103F400000000206E360400818103071340000101FA000000
...    0010370B0200E8080000303F400000000206E26040081838040000100FD0000000008100800803004809B00080418000402000100800040202
...    0040088000201000080404008011800040200010080004020200400840002010100200440001008000402020040080

#modify supportbandlist from 258 to 77
${ue_nr_capabilities}
...    SEPARATOR=
...    E1000000014F7E0302000001404807060E220C000609B00839F21078004120188004502C28D010CA1A044083A0C30260220B6480A01000C039
...    F2107800412070701101E407800013000009B89BC09024000000120000040900000400A00C0300C0300D802802010040118028030100401004
...    600A0040401180280001180280100C03600A0000360272A6F286F2A2B708DD200808000020C300200002830C00800011041082000064104208
...    000210410809A55334A262B9515DA8AEC4

@{Config_for_CAIMLBP}
...    LNBTS/CAGENB-0/CAIMLBP-2:pcellConfig:earfcnDL=1700
...    LNBTS/CAGENB-0/CAIMLBP-2/IMLBNR-0:nrcellConfigL:b1NrRequired=true
...    LNBTS/CAGENB-0/CAIMLBP-2/IMLBNR-0:nrcellConfigL:band=77

@{CB006607}
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1700
...    LNCEL-1/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true
...    LNBTS/MOPR-1:freqLayEndcHoList:freqLayer=1700
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true
...    LNBTS/MODPR-0:freqLayEndcHoList:freqLayer=1700

@{enable9920}
...    LNBTS:actCoordinated4g5gPowerSaving=cellDeactivation

@{case_6_lockgNB2}
...    LNADJGNB-2:administrativeState=locked

@{case_6_disable9920}
...    LNBTS:actCoordinated4g5gPowerSaving=disabled

@{case_6_unlockgNB2}
...    LNADJGNB-2:administrativeState=unlocked

@{PM_Counters}
...    ${SGNB_ADD_PREP_REJECT_CNA}=1
${SGNB_ADD_PREP_REJECT_CNA}    M8080C163

@{case_07}
...    @{CB007334}
...    LNBTS/ANR-0:actAutoNrNeighRemoval=true
...    LNBTS:endcAnrAutoRemDisallNrCellEss=true

@{case_10}
#7747 switch and relative configuration
...    LNBTS:actNrFreqFilterForEnDc=true
...    LNBTS/MODPR-0:allowEnDc=dedicated_freq_layers
...    LNBTS/MOPR-1:allowEnDc=dedicated_freq_layers
...    LNBTS/MODPR-0:freqLayListEnDc:carrierFreqNrCell=${NRARFCN657700}
...    LNBTS/MOPR-1:freqLayListEnDc:carrierFreqNrCell=${NRARFCN657700}

#9920
...    LNBTS:nrCellDeactStatIndEndcHo=true

@{case_10_02}
...    LNBTS:nrCellDeactStatIndEndcHo=false

*** Test Cases ***
CB009920-A-a_ET_01_06_eNB will ignore NR Deactivation Indication IE and do not change pwSavingDeactInd when CB009920 is disabled
    [Tags]
    Test normal function and lock X2link
    Disable 9920 and eNB ignore message and trigger sgnb addition fail

CB009920-A-a_ET_01_04_eNB should update NR cell status when the cell switch on and CB008951 is enabled
    [Tags]
    Test cells switch off and switch on
    Attach UE and trigger sgnb addition success

CB009920-A-a_ET_01_07_LNRELGNBCELL should not be removed even though anrNrNbrRelRemGuardTime is expired when endcAnrAutoRemDisallNRcell set to true
    [Documentation]    step1:deactive two lnrelgnbcells
    ...    step2:active 7334 and enable endcAnrAutoRemDisallNrCellEss, LNRELGNBCELLs are kept
    [Tags]
    Served NR cells to Modify with nrDeactivationIndication status deactivated of cell 71 and 72
    Online parameter change    ${case_07}
    Log To Console    wait 2 minutes to let remove counter add 2 and anrNrNbrRelRemGuardTime is expired
    sleep    125s    #wait 2 minutes to let remove counter add 2 and anrNrNbrRelRemGuardTime is expired
    Judge LNRELGNBCELL pwSavingDeactInd and nrStatus    Ind-1=true    status-1=unavailable    Ind-2=true
    ...    status-2=unavailable    Ind-4=false    status-4=available

CB009920-A-a_ET_01_10_eNB will active A5 measurement when LNRELGNBCELL become deactived
    [Documentation]    step1:active 7747 and enable nrCellDeactStatIndEndcHo
    ...    step2:deactive three lnrelgnbcells and check status
    ...    step3:attach UE and active A5 meas
    ...    step4:disable nrCellDeactStatIndEndcHo and attach UE, no A5 active
    [Tags]
    Online parameter change     ${case_10}
    Deactive three LNRELGNBCELLs and check status
    Attach UE and active A5 meas
    Execute Uex Command    ue_detach id=1
    Change nrCellDeactStatIndEndcHo to false and attach UE and expect NO A5 active

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts

Perform Steps After Onair
    @{LNADJGNB-judge}    Create List    LNADJGNB-1:cPlaneIpAddr=10.0.1.11    LNADJGNB-1:x2ToGnbLinkStatus=available
    ...    LNADJGNB-2:cPlaneIpAddr=10.0.1.12    LNADJGNB-2:x2ToGnbLinkStatus=available
    Object Should Exist    ${LNADJGNB-judge}
    Set UE parameters for ENDC capability

Modify Yaml
    Update Yaml    UEs/UE_sets/1    capability: ${ue_eutra_capabilities}    capability_nr: ${ue_nr_capabilities}
    ...    capability_mrdc: ${ue_MRDC_capabilities}
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1400:19400', bw: 20}
    ...        - {id: 22, technology: lte, tac: 33, pci: '3:1', earfcn: '5920:23920', bw: 20}
    ...        - {id: 23, technology: lte, tac: 33, pci: '3:2', earfcn: '8770:26770', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...    gnb_id: '0x00007'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.11
    ...    x2_peers: none
    ...    cells:
    ...    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '657700:657700',
    ...    tdd_cell: yes, suggested_band: 77, gscn: 8090}
    ...    - {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x0000504', nr_arfcn: '657700:657700',
    ...    tdd_cell: yes, suggested_band: 77, gscn: 8090}
    ...    - {id: 73, technology: nr , tac: 33, pci: '1:0', nrci: '0x0000507', nr_arfcn: '657700:657700',
    ...    tdd_cell: yes, suggested_band: 77, gscn: 8090}
    Add Yaml    BASE_STATIONS
    ...    - id: 4
    ...    gnb_id: '0x00008'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.12
    ...    x2_peers: none
    ...    cells:
    ...    - {id: 81, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '657700:657700',
    ...    tdd_cell: yes, suggested_band: 77, gscn: 8090}

Set UE parameters for ENDC capability
    Execute Uex Command    ue_param id=1 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=1 nr_supported_bands=77
    Execute Uex Command    ue_param id=3 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=3 nr_supported_bands=77
    Execute Egate Command    gnb_endc_param id=3 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=3 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=3 scg_dl_dist_percent=0
    Execute Egate Command    ue_mme_param id=1 spid=1
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms

Online parameter change
    [Arguments]    ${PARAM}
    Delta Commission Parameters    ${PARAM}
    Cells Should Be OnAir

Judge LNRELGNBCELL pwSavingDeactInd and nrStatus
    [Arguments]    ${Ind-1}=false    ${status-1}=available    ${Ind-2}=false    ${status-2}=available    ${Ind-4}=false    ${status-4}=available
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=${Ind-1}    LNCEL-1/LNRELGNBCELL-1:nrStatus=${status-1}
    ...    LNCEL-1/LNRELGNBCELL-2:pwSavingDeactInd=${Ind-2}    LNCEL-1/LNRELGNBCELL-2:nrStatus=${status-2}
    ...    LNCEL-1/LNRELGNBCELL-4:pwSavingDeactInd=${Ind-4}    LNCEL-1/LNRELGNBCELL-4:nrStatus=${status-4}
    Object Should Exist    ${LNRELGNBCELL-judge}

Disable 9920 and eNB ignore message and trigger sgnb addition fail
    Online parameter change     ${case_6_disable9920}
    Judge LNRELGNBCELL pwSavingDeactInd and nrStatus    Ind-1=false    status-1=available    Ind-2=false
    ...    status-2=available    Ind-4=false    status-4=unavailable
    Online parameter change     ${case_6_unlockgNB2}
    Judge LNRELGNBCELL pwSavingDeactInd and nrStatus    Ind-1=false    status-1=available    Ind-2=false
    ...    status-2=available    Ind-4=false    status-4=available
    Execute Egate Command    endc_conf_update id=3 target=1 served_nr_cells_to_modify=71:0,72:0,73:0
    Execute Egate Command    endc_conf_update id=4 target=1 served_nr_cells_to_modify=81:0
    Judge LNRELGNBCELL pwSavingDeactInd and nrStatus    Ind-1=false    status-1=available    Ind-2=false
    ...    status-2=available    Ind-4=false    status-4=available
    Attach UE and trigger SgNB addition fail and check counter

Attach UE and trigger SgNB addition fail and check counter
    ${sgnbaddreject-3}    catenate    link_x2_management_abnormal_cases id=3 partner=1 sgnb_addition_rsp=reject
    ...    sgnb_addition_failure_cause=RN_cell_not_available
    Execute Egate Command    ${sgnbaddreject-3}
    ${sgnbaddreject-4}    catenate    link_x2_management_abnormal_cases id=4 partner=1 sgnb_addition_rsp=reject
    ...    sgnb_addition_failure_cause=RN_cell_not_available
    Execute Egate Command    ${sgnbaddreject-4}
    ${attachUE1}    catenate    ue_attach id=1 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities}    ue_nr_capabilities=${ue_nr_capabilities}
    Execute Uex Command    ${attachUE1}
    Execute Uex Command    ue_measurement_send id=1 event=B1_NR phycell_id=1 nrsrp=100 nrsrq=66 narfcn=${NRARFCN657700}
    Check Counters    ${PM_Counters}

Test normal function and lock X2link
    Judge LNRELGNBCELL pwSavingDeactInd and nrStatus    Ind-1=false    status-1=available    Ind-2=false
    ...    status-2=available    Ind-4=false    status-4=available
    Execute Egate Command    endc_conf_update id=3 target=1 served_nr_cells_to_modify=71:0
    Judge LNRELGNBCELL pwSavingDeactInd and nrStatus    Ind-1=true    status-1=unavailable    Ind-2=false
    ...    status-2=available    Ind-4=false    status-4=available
    Online parameter change     ${case_6_lockgNB2}
    Judge LNRELGNBCELL pwSavingDeactInd and nrStatus    Ind-1=true    status-1=unavailable    Ind-2=false
    ...    status-2=available    Ind-4=false    status-4=unavailable

Test cells switch off and switch on
    Execute Egate Command    endc_conf_update id=3 target=1 served_nr_cells_to_modify=71:0,72:0,73:0
    Execute Egate Command    endc_conf_update id=4 target=1 served_nr_cells_to_modify=81:0
    Judge LNRELGNBCELL pwSavingDeactInd and nrStatus    Ind-1=true    status-1=unavailable    Ind-2=true
    ...    status-2=unavailable    Ind-4=true    status-4=unavailable
    Execute Egate Command    endc_conf_update id=3 target=1 served_nr_cells_to_modify=71,72,73
    Execute Egate Command    endc_conf_update id=4 target=1 served_nr_cells_to_modify=81
    Judge LNRELGNBCELL pwSavingDeactInd and nrStatus    Ind-1=false    status-1=available    Ind-2=false
    ...    status-2=available    Ind-4=false    status-4=available

Attach UE and trigger sgnb addition success
    ${attachUE1}    catenate    ue_attach id=1 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities}    ue_nr_capabilities=${ue_nr_capabilities}
    Execute Uex Command    ${attachUE1}
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    alias=addack    overall_timeout=5
    Execute Uex Command    ue_measurement_send id=1 event=B1_NR phycell_id=1 nrsrp=100 nrsrq=66 narfcn=${NRARFCN657700}
    Flow Occurred As Expected    alias=addack

Attach UE and active A5 meas
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(carrierFreq eq 1700) as a5_activate
    ...    alias=rrcreconfig    overall_timeout=15
    ${attachUE1}    catenate    ue_attach id=1 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities}    ue_nr_capabilities=${ue_nr_capabilities}
    Execute Uex Command    ${attachUE1}
    Flow Occurred As Expected    alias=rrcreconfig
    verify that message has fields
    ...    measObjectToAddModList..measObjectId eq 3
    ...    measObjectToAddModList..measObjectEUTRA..carrierFreq eq 1700
    ...    measIdToAddModList..measId eq 3
    ...    measIdToAddModList..measObjectId eq 3
    ...    carrierFreq eq 1700
    ...    eventA5..a5-Threshold1..threshold-RSRP eq 97
    ...    message_alias=a5_activate
    ...    flow_alias=rrcreconfig

Change nrCellDeactStatIndEndcHo to false and attach UE and expect NO A5 active
    Online parameter change     ${case_10_02}
    Expect Message Will Not Occur
    ...    UE_1:RRC_RRCConnectionReconfiguration(carrierFreq eq 1700)
    ...    alias=NOrrcreconfig    overall_timeout=5
    ${attachUE1}    catenate    ue_attach id=1 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities}    ue_nr_capabilities=${ue_nr_capabilities}
    Execute Uex Command    ${attachUE1}
    Flow Not Occurred For Message    alias=NOrrcreconfig

Served NR cells to Modify with nrDeactivationIndication status deactivated of cell 71 and 72
    Execute Egate Command    endc_conf_update id=3 target=1 served_nr_cells_to_modify=71:0,72:0

Served NR cells to Modify with nrDeactivationIndication status deactivated of cell 81
    Execute Egate Command    endc_conf_update id=4 target=1 served_nr_cells_to_modify=81:0

Deactive three LNRELGNBCELLs and check status
    Served NR cells to Modify with nrDeactivationIndication status deactivated of cell 71 and 72
    Served NR cells to Modify with nrDeactivationIndication status deactivated of cell 81
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable
    ...    LNCEL-1/LNRELGNBCELL-2:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-2:nrStatus=unavailable    LNBTS-1:nrCellDeactStatIndEndcHo=true
    ...    LNCEL-1/LNRELGNBCELL-4:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-4:nrStatus=unavailable
    Object Should Exist    ${LNRELGNBCELL-judge}

Case Teardown
    Clear conf and release UE
    Common Test Teardown And Stop Capture Logs

Clear conf and release UE
    Execute Egate Command    endc_conf_update id=3 target=1 served_nr_cells_to_modify=71,72,73
    Execute Egate Command    endc_conf_update id=4 target=1 served_nr_cells_to_modify=81
    Execute Egate Command    link_x2_management_abnormal_cases id=3 partner=1 reset
    Execute Egate Command    link_x2_management_abnormal_cases id=4 partner=1 reset
    Online parameter change     ${enable9920}
    Release All UEs
