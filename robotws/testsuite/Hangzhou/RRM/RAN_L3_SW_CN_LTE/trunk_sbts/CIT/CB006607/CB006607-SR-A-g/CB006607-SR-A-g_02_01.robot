*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CIT    CLOUD_R4LAPO_CUS
...               release-SBTS21B    team-DevHZ5_SG1    owner-taotao.hu    owner-yin.zhang
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_VENDOR}
...    LNBTS:reportTimerEndcA5=5000ms
@{PARAMS_IN_SCF}
...    LNBTS:actUeCapEndcHo=true
...    LNBTS:actLteNrDualConnectivity=false
...    LNBTS:actDynTrigLteNrDualConnectivity=false
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
@{ENDC_Setup}
...    LNBTS:actLteNrDualConnectivity=false
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNBTS:tLteNrDualConnectPrep=2000
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=100sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=2
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=86
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrq=-20
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN531000}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
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
...    delete:LNCEL-1:defaultLnRelGnbCellId
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    delete:LNCEL-2:defaultLnRelGnbCellId
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    delete:LNCEL-3:defaultLnRelGnbCellId
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
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
${eutra_cap_wo_gap}
...    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB529D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFED800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C28040300E803C00000180000008
${nr_cap}         0000000001010000000060100581007018000000
${eutra_nr_cap}    01080C0160401C0600000000B1100E030000000059280740000000000100008040400801
${eutra_nr_cap_ENDC}    0108100160401C0600000000B0200E03800000005888074000000000000000000100008040400801
@{delta_for_case_02}
...    LNBTS:actSelMobPrf=true
...    LNBTS:moProfileSelect=spid
...    LNBTS/MODPR-0:freqLayEndcHoList:freqLayer=5920
...    LNBTS/MOPR-1:freqLayEndcHoList:freqLayer=1800
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    delete:LNCEL-1/LNHOIF-1:thresholdRsrqEndcFilt
@{Config_for_CAIMLBP}
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=5920
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=true
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=7
...    LNBTS/CAGENB-0/CAIMLBP-1:pcellConfig:earfcnDL=42890
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:b1NrRequired=true
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:band=78
...    LNBTS/CAGENB-0/CAIMLBP-2:pcellConfig:earfcnDL=5920
...    LNBTS/CAGENB-0/CAIMLBP-2/IMLBNR-0:nrcellConfigL:b1NrRequired=true
...    LNBTS/CAGENB-0/CAIMLBP-2/IMLBNR-0:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-3:pcellConfig:earfcnDL=42890
...    LNBTS/CAGENB-0/CAIMLBP-3/IMLBNR-0:nrcellConfigL:b1NrRequired=true
...    LNBTS/CAGENB-0/CAIMLBP-3/IMLBNR-0:nrcellConfigL:band=257
...    LNBTS/CAGENB-0/CAIMLBP-4:pcellConfig:earfcnDL=38000
...    LNBTS/CAGENB-0/CAIMLBP-4/IMLBNR-0:nrcellConfigL:b1NrRequired=true
...    LNBTS/CAGENB-0/CAIMLBP-4/IMLBNR-0:nrcellConfigL:band=257
@{Config_for_MFBI}
...    LNBTS:actMFBI=true
...    LNBTS/MFBIPR-0:addFreqBandInd=26
...    LNBTS/MFBIPR-0:eutraCarrierFreq=5920
${MRDC_cap_for_native}    010C0C0160401C0600000000B1100E030000000058C8070180000000360400C44018C807C0600000000800040202004008
${eutra_nr_cap_not_anchor_for_serving_cell}
...    SEPARATOR=
...    010C140160401C0900000000B0000E030000000058880740000000002C0803A000000000160401C1100000000D81003110063201F018000000
...    0200010080801002
@{SharedPlmnList}
...    262:03

*** Test Cases ***
CB006607-SR-A-g_02_01_X2HO Into MRDC Non Anchor Cell From MRDC Non Anchor LTE Source Cell
    [Documentation]    This case verifies X2HO into EN-DC in-capable cell from EN-DC in-capable LTE source cell
    ...    Preconditions
    ...    CB006607 feature flag (i.e. LNBTS: actUeCapEndcHo) is enabled in the eNB.
    ...    non-empty freqLayEndcHoList is configured in the MODPR/MOPR instance that UE is mapped to.
    ...    Postconditions
    ...    UE handover from LTE source cell (i.e. EN-DC in-capable) to reported LTE frequency layer (i.e. EN-DC capable) successfully.
    [Tags]    QC_193590
    [Setup]    Delta Commission And Test Setup    ${delta_for_case_02}
    Check Capabilities Enquiry Band Combination
    Attach to SimeNB2 Cell21    ue_id=3
    Handover to enb1 cell1 And Report ENDC A5 To Handover to SimeNB2 Cell22    ue_id=3
    Attach to SimeNB2 Cell21 With QCI1    ue_id=4
    Handover to enb1 cell1 And Report ENDC A5 To Handover to SimeNB2 Cell22    ue_id=4

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    Create UE Alias    UE_99    ue_id=99    id_type=cus
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts

Perform Steps After Onair
    @{lnadj}    Create List    LNADJ:cPlaneIpAddr=10.0.1.3    LNADJ:x2LinkStatus=available
    Object Should Exist    ${lnadj}

Modify Yaml
    # update UE3,4,99 capability
    Update Yaml    UEs/UE_sets/3    capability: ${eutra_cap_wo_gap}    capability_nr: ${nr_cap}    capability_mrdc: ${MRDC_cap_for_native}
    Update Yaml    UEs/UE_sets/4    capability: ${eutra_cap_wo_gap}    capability_nr: ${nr_cap}    capability_mrdc: ${MRDC_cap_for_native}
    Update Yaml    UEs/UE_sets/99    capability: ${eutra_cap_wo_gap}    capability_nr: ${nr_cap}    capability_mrdc: ${eutra_nr_cap_ENDC}
    # modify UE4 bearer
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 4, precedence: 4}
    Update Yaml    UEs/UE_sets/4     bearer: bearer_set_2
    # add sim enb2
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1400:19400', bw: 20}
    ...        - {id: 22, technology: lte, tac: 33, pci: '3:1', earfcn: '5920:23920', bw: 20}
    ...        - {id: 23, technology: lte, tac: 33, pci: '3:2', earfcn: '8770:26770', bw: 20}

Attach to SimeNB2 Cell21
    [Arguments]    ${ue_id}=3
    Execute Uex Command    ue_attach id=${ue_id} cell=21

Attach to SimeNB2 Cell21 With QCI1
    [Arguments]    ${ue_id}=4
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (drb-ToAddModList contains (eps-BearerIdentity eq 5, eps-BearerIdentity eq 6))
    ...    alias=attach_qci1_flow  overall_timeout=30
    Execute Uex Command    ue_attach id=${ue_id} cell=21
    Flow Occurred As Expected    alias=attach_qci1_flow

Set UE parameters for ENDC capability
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Uex Command    ue_param id=1 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=1 nr_supported_bands=7
    Execute Egate Command    ue_enb_param id=3,4 spid=34


Handover to enb1 cell1 And Report ENDC A5 To Handover to SimeNB2 Cell22
    [Arguments]    ${ue_id}=3
    Expect Message Flow
    ...    ENB_2:X2AP_HandoverRequest (Cause contains (radioNetwork eq "handover-desirable-for-radio-reasons"))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 1))
    ...    UE_${ue_id}:RRC_UECapabilityEnquiry (ue-CapabilityRequest contains ("eutra"))
    ...    UE_${ue_id}:RRC_UECapabilityEnquiry (ue-CapabilityRequest contains ("nr", "eutra-nr")) as cap_enquiry_2nd
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration as a5_activate
    ...    alias=ho_flow1  overall_timeout=30
    Expect Message Flow
    ...    UE_${ue_id}:RRC_MeasurementReport (measId eq 3)
    ...    ENB_2:X2AP_HandoverRequest (Cause contains (radioNetwork eq "resource-optimisation-handover"))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 10))
    ...    ENB_2:X2AP_UEContextRelease
    ...    alias=ho_flow2  overall_timeout=30
    Execute Uex Command    ue_ho id=${ue_id} enb=1 cell=1
    sleep    2s    # wait A5 reconfig
    Execute Uex Command
    ...    ue_measurement_send event=A5 earfcn=5920 id=${ue_id} srsrp=60 srsrq=15 phycell_id=10 nrsrp=43 nrsrq=16
    Flow Occurred As Expected    alias=ho_flow1
#    verify that message has fields
#    ...    requestedFreqBandsNR-MRDC-r15 eq '0x00C0080881904A0A60034100'
#    ...    message_alias=cap_enquiry_2nd
#    ...    flow_alias=ho_flow1
    verify that message has fields
    ...    measObjectToAddModList..measObjectId eq 4
    ...    measObjectToAddModList..measObjectEUTRA..carrierFreq eq 5920
    ...    measIdToAddModList..measId eq 3
    ...    measIdToAddModList..measObjectId eq 4
    ...    s-Measure eq 0
    ...    gapOffset-gp0 is not present
    ...    message_alias=a5_activate
    ...    flow_alias=ho_flow1
    Flow Occurred As Expected    alias=ho_flow2
    [Teardown]  Execute Uex Command    ue_detach id=${ue_id}

Delta Commission And Test Setup
    [Arguments]    ${setup_case_param}
    Set UE parameters for ENDC capability
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${setup_case_param}

Check Capabilities Enquiry Band Combination
    Expect Message Flow
    ...    UE_99:RRC_UECapabilityEnquiry (ue-CapabilityRequest contains ("eutra"))
    ...    UE_99:RRC_UECapabilityEnquiry (ue-CapabilityRequest contains ("nr", "eutra-nr"))
    ...    alias=rrc_enquiry  overall_timeout=30
    Execute Uex Command    ue_attach id=99 cell=1
    Flow Occurred As Expected    alias=rrc_enquiry
