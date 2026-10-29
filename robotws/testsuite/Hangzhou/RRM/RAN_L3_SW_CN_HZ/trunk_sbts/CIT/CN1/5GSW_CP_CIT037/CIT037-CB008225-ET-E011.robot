*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-liupei.fang
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CIT    release-SBTS24R1    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{actCDrx}
...    @{RANsharing}
...    @{CA}
...    @{UEAssistanceInformation_para}
...    @{8225_parameters}

@{8225_parameters}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRCELL:freqBandIndicatorNR=77
...    NRCELL-1:gscnOrSsPbchArfcn=7949
...    NRCELL-1:nrarfcn=644742
...    NRCELL-1:chBw=80MHz
...    NRBTS:drbInactivityTimerSA=60
...    NRBTS:maxUeRrcInactTime=4     # ue will release after UE in inactive timeout
...    NRBTS:outOfConnectedPreference=idle
...    NRBTS:srbInactivityTimerSA=30
...    NRBTS:t380=10min
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:freqBandIndicatorNR=77
...    NRBTS:act3gppBL23R1=true

@{actCDrx}
...    NRCELL:actCDrx=false
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL-2:pucchModeSelect=longPucch
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:allowUnsuppBcOrBcs=accept unknown band combinations

@{RANsharing}
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=max_10_PLMNs
...    NRBTS:actTrsSepaSARanSharing=true
...    NRBTS:ngCplane:ngTnlId=1
...    NRBTS:ngUplane:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS:xnCplane:xnTnlId=1
...    NRBTS:xnUplane:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-1:configuredEpsTac=${EMPTY}
...    NRCELL-1:ranAC=${EMPTY}
...    NRCELL-1:trackingAreaDN=${EMPTY}
...    NRCELL-1/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL-1/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-1/NRPLMNSET_SA-1:ranAC=0
...    NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-1/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-1/NRPLMNSET_SA-2:ranAC=1
...    NRCELL-1/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
...    NRCELL-2:configuredEpsTac=${EMPTY}
...    NRCELL-2:ranAC=${EMPTY}
...    NRCELL-2:trackingAreaDN=${EMPTY}
...    NRCELL-2/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL-2/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-2/NRPLMNSET_SA-1:ranAC=0
...    NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-2/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-2/NRPLMNSET_SA-2:ranAC=2
...    NRCELL-2/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
...    NRBTS/NRPLMN-2:mnc=500
...    NRBTS/SERVEDAMF-1:ngTnlId=1
...    NRBTS/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/SNSSAI-1:sd=${EMPTY}
...    NRBTS/SNSSAI-2:sd=13714341
...    NRBTS/SNSSAI-2:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    NRBTS/TRACKINGAREA-300:fiveGsTac=300
...    NRBTS/TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

@{CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRBTS:ranPagingCycle=v32
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:dlSCellConfigLevel=10
...    NRCELL-1:dlSCellConfigLevelNum=3
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-2:dlSCellConfigLevel=10
...    NRCELL-2:dlSCellConfigLevelNum=3
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp

@{UEAssistanceInformation_para}
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:tRanPagingGuard=4
...    NRBTS:timerReleasePreferenceProhibit=s5

@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    nextHopChainingCount
...    t380
...    NR_RRC_INACTIVE
...    Is INACTIVE

@{Resume_with_scell_regexp}
...    rrcResumeRequest1
...    rrcResumeComplete
...    PhysCellId: 51] SCellIndex 1 activated successfully

@{Resume_regexp_with_mo_Data}
...    rrcResumeRequest1
...    resumeCause mo-Data
...    rrcResume
...    rrcResumeComplete
...    rrcReconfigurationComplete
...    pcid:50, scellIdx:0

@{resume_fallback}
...    rrcResumeRequest1
...    rrcSetup
...    rrcReconfiguration
...    rrcReconfigurationComplete
...    pcid:51, scellIdx:0
...    UE-2 PDU SESSION ID-2 setup/reestablishment complete

@{scell_add_success}
...    rrcReconfigurationComplete
...    PhysCellId: 51] SCellIndex 1 activated successfully

@{releasePreference_check}
...     QoS Routing Table
...     releasePreference-r16 supported

@{PM_Counters_Check_E011}
...    NRCELL-1:${RRC_REL_WITH_SUSP}=2
...    NRCELL-1:${RRC_RESUME_REQ}=1
...    NRCELL-1:${RRC_RESUME_SUCC}=1
...    NRCELL-1:${SCELL_ADMI_REQ}=3
...    NRCELL-1:${SCELL_ADMI_SUCC}=3
...    NRCELL-1:${DU_SCELL_1_ADMI_REQ}=3
...    NRCELL-1:${DU_SCELL_1_ADMI_SUCC}=3
...    NRCELL-2:${DU_SCELL_ADMI_REQ}=3
...    NRCELL-2:${DU_SCELL_ADMI_SUCC}=3
...    NRCELL-2:${SCELL_ACTIVATIONS}=3
...    NRCELL-2:${RRC_RESUME_FALLBACK_ATT}=1
...    NRCELL-2:${RRC_RESUME_FALLBACK_SUCC}=1
...    NRCELL-2:${SCELL_ADMI_REQ}=1
...    NRCELL-2:${SCELL_ADMI_SUCC}=1
...    NRCELL-1:${DU_SCELL_ADMI_REQ}=1
...    NRCELL-1:${DU_SCELL_ADMI_SUCC}=1
...    NRCELL-2:${DU_SCELL_1_ADMI_REQ}=1
...    NRCELL-2:${DU_SCELL_1_ADMI_SUCC}=1
...    NRCELL-1:${SCELL_ACTIVATIONS}=1

${RRC_REL_WITH_SUSP}    M55124C00006    #NRRCC_RRC_REL_WITH_SUSP_NRNAU increment for Cell1
${RRC_RESUME_REQ}    M55124C00007    #NRRCC_RRC_RESUME_REQUEST1 increment for Cell1
${RRC_RESUME_SUCC}    M55124C00010    #NRRCC_RRC_RESUME_SUCC increment for Cell1
${SCELL_ADMI_REQ}    M55138C01501    #GNB_SCELL_1_ADMI_REQ_SA increment 2 for Cell1
${SCELL_ADMI_SUCC}    M55138C01502    #GNB_SCELL_1_ADMI_SUCC_SA increment 2 for Cell1
${DU_SCELL_ADMI_REQ}    M55139C01001    #GNB_DU_SCELL_ADMI_REQ_SA increment 2 for Cell2
${DU_SCELL_ADMI_SUCC}    M55139C01002     #GNB_DU_SCELL_ADMI_SUCC_SA increment 2 for Cell2
${DU_SCELL_1_ADMI_REQ}     M55139C01003     #GNB_DU_SCELL_1_ADMI_REQ_SA increment 2 for Cell1
${DU_SCELL_1_ADMI_SUCC}    M55139C01004    #GNB_DU_SCELL_1_ADMI_SUCC_SA increment 2 for Cell1
${SCELL_ACTIVATIONS}    M55316C09000    #SCELL_ACTIVATIONS increment 2 for Cell2
${RRC_RESUME_FALLBACK_ATT}    M55124C00013    #NRRCC_RRC_RESUME_FALLBACK_ATT increment for Cell2
${RRC_RESUME_FALLBACK_SUCC}    M55124C00014    #NRRCC_RRC_RESUME_FALLBACK_SUCC increment for Cell2

#supported UE Power Saving's releasePreference-r16
${SA_Capa_UAI_Inactive}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D033
...    EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D805AC1184341020F10480CAD931562439F604F88E3C62471E439F51CF9
...    863CA1607038784FFC000003FF000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC0
...    07003FF0004C000381506C1BD608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000130000E007B
...    C3C4C000E010000010B0102A07130200038581587836001C02000006160561E140007008000008581587898001C1B000002160562E0D80070080038040
...    000142C0AC3C4C000E260000060B02B17130003804001C28000008160562E26000706C0038360000082C0AC5C28000E01000706C00001058158B850001
...    C02000E010000020B02B17130003804001C1B000004160562E14000706C0038360000082C0AC5C4C000E0D80070A0000020581587836001C1B00000616
...    0401C01B8051013200107A05C83E14489B1CF870226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E0448
...    10206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E0428103639F000B878C6318C6318C6318C630F413003C002
...    81C1401C0C02500700060240040603E0900200000001000800000020000000100000200800002004000018020000100100000A008004010040100000C0
...    080000700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958215833582B594B5933580B581B58
...    095811583B40D040000259494100001965260400006594901000039652404000125949010000596526040001A594901000079652404000225949010000
...    996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28480BC
...    04A8140A05028140A05028140A05028140A05028140A000E10100C018040080108080100402018030804008010100C018040300608080600C020180308
...    04008010100C018040080110080600C02018030080600C10100200804008020008020043543E00020406080C0E1416181A2022242628303236383A3E42
...    4A4C4E5052545A5E828325A94400009C

*** Test Cases ***
CB008225-ET-E011_Successful_transition_of_Suspended_UE_in_RRC_INACTIVE_to_RRC_CONNECTED_resume_to_Cell_with_intra_gNB_BFBased_MeasBased_CA_config
    [Documentation]
    ...    The gNB behavior for UE in RRC_CONNECTED state and configured with CA state that is successfully transitioned to RRC_INACTIVE state
    ...    based on the UE inactivity. Successful suspend procedure. CA resources allocated for the UE at gNB are released during suspend procedure.
    ...    Cell with BufferBased Blind CA config.Triggers UE release to RRC_INACTIVE state by UE Assistance Information.
    ...    2. Configuration
    ...       a.SA+NSA,TDD+TDD, CA(band 77+band 77)
    ...       b.configured ransharing
    ...    3. Test Case Steps:
    ...       a.Set UE1/2 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request.
    ...         And trigger UE1/2 register to Cell1.
    ...       Expected result:UE1/2 registers successfully to Cell1.
    ...       b.setup PDU 1 and PDU 2 on both UE1 and UE2
    ...       Expected result:both PDU 1 and 2 setup successfully,A1 measurement is configured for SCell addition with reportOnLeave
    ...       c.UE1/2 sends A1 MR for scell addition.
    ...       Expected result:send A1 MR successfully without scell addtion until traffic startup
    ...       d.UE1/2 PDU session 1 start low DL traffic, PDU session 2 start high DL traffic, trigger buffer overflow happens at gNB-DU.
    ...       Expected result:
    ...       1.A1 scell added successfully with RRC
    ...       2.A2 measurement for SCell release is configured.
    ...       e.Trigger UE1/2 send UEAssistanceInformation with ReleasePreference-r16=inactive
    ...       Expected result:
    ...       1.UE1/2 is released to RRC_INACTIVE state.
    ...       2.gNB-DU context is internally released
    ...       f.Check there is no resources leakage and counters
    ...       g.Trigger resume and fallback UE1 and UE2
    ...       Expected result: resume and fallback should successfully for UE1 and UE2
    ...       h.Trigger A1 MR and scell addtion after high traffic for UE1 and UE2
    ...       Expected result: scell addtion should be successfully
    ...       i.UEs Deregister and check counter
    ...       Expected result:deregister should successfully and counter all correct
    [Tags]    QC_47234    owner-liufang    E011    CA_LABEL-TT(80MHz_TDD_n77+100MHz_TDD_n77)
    Clear Counter Files    wait=${False}
    UE1 and UE2 Attach To Target Cell with UAI
    Trigger A1 MR and scell addtion after high traffic for UE1 and UE2
    Trigger UE1 and UE2 send UEAssistanceInformation
    Check Resources Leakage    cpcl cprt
    Trigger resume and fallback UE1 and UE2
    Trigger A1 MR and scell addtion after high traffic for UE1 and UE2     carrierfreq1=643200     carrierfreq2=636576
    UEs Deregister and check counter

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=20

Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,100,200,300 plmn=311:489,311:500
    Update Cfg    set_amf_region id=2 tac_list=0,100,200 plmn=311:489
    Update Cfg    set_nwslice id=1 snssai=0x01:0xFFFFFF default=on ue=all amf_region_id=1 plmn_list=311:489,311:500
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a5 default=off ue=all amf_region_id=2 plmn_list=311:489
    ${set_ue1}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:500:0000:0:0:021645401
    ...    mode=nr enb=2 cell=1
    Update Cfg    ${set_ue1}
    ${gNB2_cell1_configuration}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...     nr_arfcn=644742:644742 gscn=7949 mandatory_for_activation=off
    update Cfg    ${gNB2_cell1_configuration}

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE1 and UE2 Attach To Target Cell with UAI
    UE attach with UAI    ue_id=1    gw1=1    gw2=2    nwslice1=1    nwslice2=2    plmn=489    tac=200
    UE attach with UAI    ue_id=2    gw1=3    gw2=4    nwslice1=1    nwslice2=1    plmn=500    tac=300
    Send Low Throuput on PDU1

UE attach with UAI
    [Arguments]    ${ue_id}=1    ${gw1}=1    ${gw2}=2    ${nwslice1}=1    ${nwslice2}=2    ${plmn}=489    ${tac}=200
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_UAI_Inactive}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    ${set_ics_param}    catenate     amf_ue_ics_param id=${ue_id} core_network_assistance_info=on ue_identity_index_value=${ue_id}
    ...     ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:${plmn} tac_id=${tac}
    Execute Egate Command    ${set_ics_param}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw1} nwslice=${nwslice1}    pass_regexp=${releasePreference_check}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=${gw2} nwslice=${nwslice2}    pass_regexp=QoS Routing Table

Start and verify traffic for UE1 and UE2
    Send High Throuput on PDU2    ue_id=1
    Send High Throuput on PDU2    ue_id=2
    Wait Until Keyword Succeeds    30s    5s    Verify Throuput on Pscell and Scell    ue_id=1    CC_num=2    dl=270    ul=16
    Wait Until Keyword Succeeds    30s    5s    Verify Throuput on Pscell and Scell    ue_id=2    CC_num=2    dl=270    ul=16

Send High Throuput on PDU2
    [Arguments]    ${ue_id}=1    ${pdu}=2    ${mbps_dl}=150    ${mbps_ul}=30
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=ul mbps=${mbps_ul} trf_id=11    pass_regexp=Started Uplink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl mbps=${mbps_dl} trf_id=12    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl mbps=${mbps_dl} trf_id=13    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl mbps=${mbps_dl} trf_id=14    pass_regexp=Started Downlink

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=1    ${CC_num}=2    ${dl}=400    ${ul}=16
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-1 type=pdsch    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${sid}    convert to string    ${id}
        ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${sid}    type=pdsch    rate_type=ave
        Should Be True    ${scell_tput}/1000 > 0
        ${all_tput}    Evaluate    ${all_tput}+${scell_tput}
    END
    Should Be True    ${all_tput}/1000 > ${dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Stop traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu}    pass_regexp=Traffic was stopped    sleep_time=5

Trigger A1 MR
    [Arguments]    ${ue_id}=1    ${carrierfreq}=643200    ${event}=A1
    Execute Egate Command     ue_meas_cfg_disp id=${ue_id}
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event}
    Execute Egate Command     ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=measurementReport    fail_regexp=sCellIndex 1    timeout=5s

Trigger A1 MR and scell addtion after high traffic for UE1 and UE2
    [Arguments]    ${carrierfreq1}=643200    ${carrierfreq2}=643200
    Trigger A1 MR    ue_id=1    carrierfreq=${carrierfreq1}
    Trigger A1 MR    ue_id=2    carrierfreq=${carrierfreq2}
    Wait Until Keyword Succeeds    30s    5s    Start and verify traffic for UE1 and UE2

Trigger UE1 and UE2 send UEAssistanceInformation
    Stop traffic    ue_id=1     pdu=1
    Stop traffic    ue_id=1     pdu=2
    Trigger UE assitance inactive    ue_id=1
    Stop traffic    ue_id=2     pdu=1
    Stop traffic    ue_id=2     pdu=2
    Trigger UE assitance inactive    ue_id=2

Trigger UE assitance inactive
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=inactive
    ...    pass_regexp=${INACTIVE_check}
    Execute Egate Command    ue_disp

Trigger resume and fallback UE1 and UE2
    Trigger UE resume    ue_id=1    cell_id=1    cause=mo_Data    pass_regexp=${Resume_regexp_with_mo_Data}
    Trigger UE resume with action    ue_id=2    cell_id=2    cause=mt_Access
    ...    action=invalid_short_mac_i    pass_regexp=${resume_fallback}
    Send Low Throuput on PDU1
    Sleep    60s    #Sleep time in this case is for UE resources clear

Trigger UE resume
   [Arguments]    ${ue_id}=1    ${cell_id}=1    ${cause}=mo_Data    ${pass_regexp}=${Resume_regexp_with_mo_Data}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}     pass_regexp=${pass_regexp}

Trigger UE resume with action
   [Arguments]    ${ue_id}=1    ${cell_id}=1    ${cause}=mo_Data
   ...    ${action}=invalid_short_mac_i    ${pass_regexp}=${resume_fallback}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=${cause} action=${action}
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}     pass_regexp=${pass_regexp}

Send Low Throuput on PDU1
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink
    Execute Egate Command    trf_data_start ue=2 pdu=1 qfi=1 dir=dl mbps=10 trf_id=2    pass_regexp=Started Downlink

UE Release PDU Session
    [Arguments]    ${ue_id}=1
    Stop traffic    ue_id=${ue_id}     pdu=2
    Stop traffic    ue_id=${ue_id}     pdu=1
    Execute Egate Command    ue_pdu_session_release pdu=1 ue=${ue_id} by=ue    Successfully released PDU Session with ID    sleep_time=5
    Execute Egate Command    ue_pdu_session_release pdu=2 ue=${ue_id} by=ue    Successfully released PDU Session with ID    sleep_time=5

UEs Deregister and check counter
    UE Release PDU Session    ue_id=1
    UE Release PDU Session    ue_id=2
    UE Deregister From gNB    ue_id=1
    UE Deregister From gNB    ue_id=2
    Check Counters    ${PM_Counters_Check_E011}
