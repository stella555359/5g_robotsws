*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO_CUS    team-DEVHZ5_SG3    owner-yu.1.zhou    release-xL20A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  LNBTS:mcc=262
...  LNBTS:mnc=3
...  LNBTS:mncLength=2
...  LNBTS:actMultBearers=true
...  LNBTS/LNBTS_FDD-0:actConvVoice=true
...  LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...  LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...  LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...  LNCEL-1:harqMaxTrVoLteDl=4
...  LNCEL-2:harqMaxTrVoLteDl=4
...  LNCEL-3:harqMaxTrVoLteDl=4
...  LNCEL-1/LNCEL_FDD-0:maxNumQci1Drb=100
...  LNCEL-2/LNCEL_FDD-0:maxNumQci1Drb=100
...  LNCEL-3/LNCEL_FDD-0:maxNumQci1Drb=100
...  LNCEL-1:tac=33
...  LNCEL-2:tac=33
...  LNCEL-3:tac=33
...  LNCEL-1/LNHOIF-1:eutraCarrierInfo=1450
...  @{NRDCDPR}
...  @{pMaxOwnCell}
...  @{actDynTrigLteNrDualConnectivity}
...  @{NRDCPR}
...  @{LNADJGNB}
...  @{LNRELGNBCELL}
...  @{qciTab6}
...  @{qciTab8}
...  @{pdcpProfileId}
@{NRDCDPR}
...  LNBTS/NRDCDPR-0:tPeriodicPhr=1000sf
...  LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=531000
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=100
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrq=-87
...  LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...  LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...  LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=6
...  LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=7
...  LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...  LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...  LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
@{pMaxOwnCell}
...  LNCEL-1/SIB-0:pMaxOwnCell=-10
@{actDynTrigLteNrDualConnectivity}
...  LNBTS:tmpActFeat1=1
...  LNBTS:actDynTrigLteNrDualConnectivity=false
...  LNBTS:actLteNrDualConnectivity=true
...  LNBTS:tLteNrDualConnectPrep=500
...  LNCEL-1:defaultLnRelGnbCellId=1
...  LNBTS:imsEmerPlmnConfig:emerSessArpPrioLev=1
...  LNBTS/LNBTS_FDD-0:actIMSEmerSessR9=true
@{NRDCPR}
...  LNBTS/NRMEASPR-0:cellList=1
...  LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...  LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrp=256ms
...  LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrq=256ms
...  LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TriggerQuantity=RSRP
...  LNBTS/NRDCPR-0/ENDCMEASCONF-0:carrierFreqNrCell=531000
...  LNBTS/NRDCPR-0/ENDCMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...  LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrp=8
...  LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrq=8
...  LNBTS/NRDCPR-0/ENDCMEASCONF-0:quantityConfigId=0
...  LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbDuration=sf1
...  LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbOffset=2
...  LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbPeriodicity=sf5-r15
...  LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbSubcarrierSpacing=15kHz
...  LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...  LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
...  LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...  LNBTS/NRDCPR-0:enDCpMaxEUTRApowerOffset=4
...  LNBTS/NRDCPR-0:enDCpMaxNRpowerOffset=5
...  LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrp=100
...  LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrq=-87
${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}    0108040160401C06000000000400020101002004
@{SharedPlmnList}
...  262:03
@{PARAMS_IN_SWCONFIG}
...  0x00130060=1
#temporary workaround for LTE4193-B for supporting MeasTimingConf in X2SetupReponse for gNB
@{LNADJGNB}
...  LNBTS/LNADJGNB-1:administrativeState=unlocked
...  LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
@{LNRELGNBCELL}
...  LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...  LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...  LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...  LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...  LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...  LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
@{qciTab6}
...  LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC
...  LNBTS:qciTab6:nrPdcpProfIdx=1001
@{qciTab8}
...  LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC
...  LNBTS:qciTab8:nrPdcpProfIdx=1001
@{pdcpProfileId}
...  LNBTS:pdcpProf1001:pdcpProfileId=1001
...  LNBTS:pdcpProf1001:snSizeDl=18bit
...  LNBTS:pdcpProf1001:snSizeUl=18bit
...  LNBTS:pdcpProf1001:statusRepReq=0
...  LNBTS:pdcpProf1001:tDiscard=300ms
@{disable_QCI6}
...  LNBTS:qciTab6:lteNrDualConnectSupport=disabled
...  delete:LNBTS:qciTab6:nrPdcpProfIdx
@{select_statusRepReq}
...  LNBTS:pdcpProf1001:statusRepReq=2
${X2_hexstring_1_split_same_srb_drb}
...  SEPARATOR=
...  00000084DB000008000A00020006000540020000000B00080062F23000001010001700070062F230000103000E00848A02C3450000000000F9
...  4CD96A5CE3042938A0F8D5943798299E86E2B68D54C8BA83675407311D5A020402540BE4008002540BE400000004400E4500063C01F00A0001
...  010000000884410B3081EDDE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E80000000740
...  0000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000000740000
...  0003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000000740000000
...  3A00000001D00000001BFBFFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A00011800023800048
...  0000920001280002580004C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006
...  D0000FE003A7400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E
...  800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800
...  000007400000003A00000001D00000000E800000007400000003A0000000141000000F3A000000000000000000000000000000000000000000
...  00000000000000000202388425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C2800033C000001800000080514000000000101000
...  00000601005810070180000006140108040160401C06000000000400020101002004950085020C007FEE000000008015E19C042005AA670400
...  1C2018080828201C20103C20180819C101341811180004080C040610810844110C4420025009AD813FD9405C13FD9404175085E4E5141C0BCF
...  C31000544C030D2DA00002049880701411234667817F080820605BC83C80C9D8E37F260181B02444060008400905C568AA1BD88D2F218300B5
...  41240201015F616281E50BF5F8B47F01A01010140B8281E50BF5F8B47F01A01364C40B1C2045EB6380920F300000109C0400A481A60000102B
...  70000043F903DE3C000010FA00004CA80200480A5EFD3283138BC4BC3E02BE1804280206980C78F00004850040D3018F1E000110A0081A6031
...  E3C000321401034C063C78000601022881011BC1204D102023784410281E81011BC3208944F40808DE18000008208410418618F201C0000041
...  7800040000380203C801412000050000101F94CD96A5CE3042938A0F8D5943798299E86E2B68D54C8BA83675407311D5A0200000000102113A
...  FDA00A07312626CF1D02EDB6F9DCC7E2DDF0112D232D4E3090FCBE278B9800000000103029A88E63D5BD712B09E56F61E71AFBEF3300A7F57A
...  8D2885D74363D8BFCAE9100000000101F94CD96A5CE3042938A0F8D5943798299E86E2B68D54C8BA83675407311D5A0200000000102113AFDA
...  00A07312626CF1D02EDB6F9DCC7E2DDF0112D232D4E3090FCBE278B9800000000103029A88E63D5BD712B09E56F61E71AFBEF3300A7F57A8D2
...  885D74363D8BFCAE910000A040000F4014008062F230123466710000000000004D40020041002440010000F840050000000000
@{enable_multi_split}
...  LNBTS:actMultiSCGSplit=true
...  @{qciTab6}
${V_2}
...  SEPARATOR=
...  DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...  000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...  E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...  FFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...  C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...  00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...  00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...  01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...  8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C2800033C000001800000080

*** Test Cases ***
LTE4488-A-c_ET_01_01_X2 and S1 HO deltaConfig with 1_split_bearer with ENDC established when DRBs in drbToAddModList and sourceRB_ConfigSN_NR_r15
    [Tags]
    Set UE parameters before ENDC setup
    UE attach eNB2 cell1 and blind trigger ENDC    ue_id=11
    UE11 X2 handover to eNB1 Cell1 with 1 split bearer
    UE attach eNB2 cell1 and blind trigger ENDC    ue_id=13
    UE13 S1 handover to eNB1 Cell1 with 1 split bearer

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=4CELLs_FDD_2Band3_2Band7
    Create UE Alias    UE_11    ue_id=11    id_type=cus
    Create UE Alias    UE_12    ue_id=12    id_type=cus
    Create UE Alias    UE_13    ue_id=13   id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    # modify UE bearer
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 6, pdn: 1}
    
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/3    bearer: bearer_set_2
    FOR    ${ue_id}     IN RANGE    1    3
        Update Yaml    UEs/UE_sets/${ue_id}    bearer: bearer_set_2    release: '15'    category: '4'    rohc: '16'
        ...    eia: 'null'    eea: 'null'    sec_key: '0102030405060708090A0B0C0D0E1001'
    END
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...    gnb_id: '0x00007'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.11
    ...    x2_peers: none
    ...    cells:
    ...    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '507000:531000'}
    
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1: 10.0.1.3
    ...    cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1400:19400', bw: 20}
    ...        - {id: 22, technology: lte, tac: 33, pci: '3:1', earfcn: '5920:23920', bw: 20}
    ...        - {id: 23, technology: lte, tac: 33, pci: '3:2', earfcn: '8770:26770', bw: 20}

Set UE parameters before ENDC setup
    Execute Egate Command     trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command     trace_sim enb=7 protocol=x2 on
    Execute Egate Command     trace_sim enb=2 protocol=x2 on
    Execute Egate Command     ue_param id=11-15 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Egate Command     ue_param id=11-15 nr_supported_bands=7
    Execute Egate Command     gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command     enb_param id=2 endc_capable_qci=6,8
    Execute Egate Command     enb_x2_link_up enb=2 target=7    is up

UE attach eNB2 cell1 and blind trigger ENDC
    [Arguments]    ${ue_id}=1
    Execute Egate Command     ue_timer T300=2000
    ${attach_command}    Catenate
    ...    ue_attach id=${ue_id} ue_eutra_capabilities=${V_2} ue_nr_capabilities=${ue_nr_capabilities} \
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} cell=21
    Execute Uex Command    ${attach_command}
    sleep    3s    #wait ue attach enb2 to be active
    Execute Egate Command     enb_ue_dc_start target_gnb=7 target_cells=71 ue=${ue_id} bearer=1 type=split_scg
    ...    pass_regexp=Bearer-type change from MCG to SCG-split is successful
    
UE detach
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_detach id=${ue_id}
    
UE11 X2 handover to eNB1 Cell1 with 1 split bearer
    Execute Egate Command     ue_enb_param id=11 ue_config_release_r9=rel15
    Execute Egate Command     enb_endc_param keep_endc_on_ho=off id=2
    Execute Egate Command     enb_param id=2 ho_source=x2
    ${drb-ToAddModList}    catenate
    ...    drb-ToAddModList contains (eps-BearerIdentity eq 5)
    ${X2AP_SgNBAdditionRequestAcknowledge_query}    catenate
    ...    E-RABs-Admitted-ToBeAdded-SgNBAddReqAck-Item contains (e-RAB-ID eq 5) and
    ...    SgNBtoMeNBContainer contains (pdcp-Config contains (pdcp-SN-SizeUL eq 'len18bits' and pdcp-SN-SizeDL eq 'len18bits'))
    Expect Message Flow
    ...    ENB_1:X2AP_HandoverRequest (sourceRadioResourceConfig contains (${drb-ToAddModList}))
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge (${X2AP_SgNBAdditionRequestAcknowledge_query})
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=handover_ENDC    overall_timeout=20
    Expect Message Will Not Occur
    ...    ENB_1:X2AP_HandoverRequestAcknowledge (fullConfig-r9 eq 'true')
    ...    alias=not_expect  overall_timeout=10
    Execute Uex Command     ue_ho enb=1 cell=1 id=11
    Flow Occurred As Expected    alias=handover_ENDC
    Flow Not Occurred For Message    alias=not_expect

UE13 S1 handover to eNB1 Cell1 with 1 split bearer
    Execute Egate Command     ue_enb_param id=13 ue_config_release_r9=rel15
    Execute Egate Command     mme_timer T_S1HoSrcContextRelease=20
    Execute Egate Command     link_lock link=x2 at=enb:2 to=enb:1    is locked
    Execute Egate Command     enb_param id=2 ho_source=s1 specific_pdcp_sn_size_to_support=sn18
    ${drb-ToAddModList}    catenate
    ...    drb-ToAddModList contains (eps-BearerIdentity eq 5)
    ${X2AP_SgNBAdditionRequestAcknowledge_query}    catenate
    ...    E-RABs-Admitted-ToBeAdded-SgNBAddReqAck-Item contains (e-RAB-ID eq 5) and
    ...    SgNBtoMeNBContainer contains (pdcp-Config contains (pdcp-SN-SizeUL eq 'len18bits' and pdcp-SN-SizeDL eq 'len18bits'))
    Expect Message Flow
    ...    MME_1:S1AP_HandoverRequest (Source-ToTarget-TransparentContainer contains (${drb-ToAddModList}))
    ...    MME_1:S1AP_HandoverRequestAcknowledge
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge (${X2AP_SgNBAdditionRequestAcknowledge_query})
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=handover_ENDC    overall_timeout=20
    Expect Message Will Not Occur
    ...    MME_1:S1AP_HandoverRequestAcknowledge (fullConfig-r9 eq 'true')
    ...    alias=not_expect  overall_timeout=10
    Execute Uex Command     ue_ho id=13 enb=1 cell=1
    Flow Occurred As Expected    alias=handover_ENDC
    Flow Not Occurred For Message    alias=not_expect
    [Teardown]    Unlock X2 link

Unlock X2 link
    Execute Egate Command     link_unlock link=x2 at=enb:2 to=enb:1
    #    ...    not set check point due to no matter it lock or unlock,it used to ensure X2 link is active in next case
    UE detach    ue_id=11
    UE detach    ue_id=13
