*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_FDD    SBTS00    team-SG2    owner-yige.g.zhang
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    release-SBTS22R1
...    STATE_CONFIGURED    RAN_5G

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${UE1_Capabilities}    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E1DE38720C3
...    8002064F1F570004F001C0013C002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36
...    26EB04050D012CB2898087AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB2898087AD8202020E
...    1DE38720C38002064F1F55000005000000108389A00000000404D0301C020227B058060005038080E0600B00E000D07C0000000000
...    001CA9A0002000012CB2A00695550103800580000002004008D58980008101820283038405880889098C909293139425389B40

@{PARAMS_IN_SCF}
...    @{FGCR9453_related_flags}
...    @{parameters_related_to_Voice_call}
...    @{parameters_related_to_Redirect_Freq}
...    @{parameters_related_to_ransharing_and_multi_AMFs}
...    @{parameters_related_to_Multi_PLMN}

@{FGCR9453_related_flags}
...    MRBTS-1/NRBTS-1:actRedirect=true
...    MRBTS-1/NRBTS-1/NRCELL-1:actVoNR=false
...    MRBTS-1/NRBTS-1:actEmergencyFallback=true
...    MRBTS-1/NRBTS-1/NRCELL-1:emergencyFBMode=redirection
...    MRBTS-1/NRBTS-1/NRCELL-2:emergencyFBMode=redirection

@{parameters_related_to_Voice_call}
...    MRBTS-1/NRBTS-1:cipherPrefL:nea0=9
...    MRBTS-1/NRBTS-1:cipherPrefL:nea1_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea2_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    MRBTS-1/NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    MRBTS-1/NRBTS-1/NRDRB-15:dscp=0
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    MRBTS-1/NRBTS-1/NRDRB-15:numSduDiscard=1
...    MRBTS-1/NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    MRBTS-1/NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    MRBTS-1/NRBTS-1/NRDRB-15:resType=GBR
...    MRBTS-1/NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    MRBTS-1/NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...    MRBTS-1/NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    MRBTS-1/NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    MRBTS-1/NRBTS-1/NRDRB_MAC-3:lcgid=4
...    MRBTS-1/NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:lcgid=0
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    MRBTS-1/NRBTS-1:gNbCuType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    MRBTS-1/NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    MRBTS-1/NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    MRBTS-1/NRBTS-1/NRDRB-15:schedulWeight=1


@{parameters_related_to_Redirect_Freq}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirFreqNr=633372
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirPrio=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirRat=eutra
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirFreqEutra=400
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirPrio=2
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:redirRat=eutra
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:redirFreqEutra=38100
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:redirPrio=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirFreqNr=633372
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirPrio=1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:redirRat=eutra
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:redirFreqEutra=400
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:redirPrio=2
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-3:redirRat=eutra
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-3:redirFreqEutra=38100
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-3:redirPrio=3
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1

@{parameters_related_to_ransharing_and_multi_AMFs}
...    MRBTS-1/NRBTS-1:actRanSharing=true

...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true
...    delete:NRCELL-1:trackingAreaDN
...    delete:NRCELL-1:configuredEpsTac
...    delete:NRCELL-2:trackingAreaDN
...    delete:NRCELL-2:configuredEpsTac
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_NSA-1:configuredEpsTac=100
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_NSA-1:configuredEpsTac=100
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=490
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-3:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-3:mnc=491
...    MRBTS-1/NRBTS-1/NRPLMN-3:mncLength=3
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:amfIPAddress=10.0.1.102
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:amfIPAddress=10.0.1.103

@{parameters_related_to_Multi_PLMN}
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    MRBTS-1/NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=5
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=5
...    MRBTS-1/NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-0

@{counters_dict_A005}
...    NRCELL-1:${NRRCC_RRC_RELEASE_REDIR_LTE}=1    #M55124C01502==1
...    NRCELL-1:${NR_RRC_RELEASE_REDIR_EF_LTE}=1    #M55124C03501==1
...    NRCELL-1:${NNGCC_UE_CTXT_STP_REQ_RECD}=1      #M55125C02501==1
...    NRCELL-1:${NNGCC_UE_CTXT_STP_REQ_EF_RECD}=1   #M55125C03001==1
...    NRCELL-1:${NNGCC_UE_CTXT_STP_RESP_SENT}=1     #M55125C02502==1
...    NRCELL-1:${NNGCC_UE_CTXT_STP_RESP_EF_SENT}=1        #M55125C03002==1
${NRRCC_RRC_RELEASE_REDIR_LTE}    M55124C01502    #Number of RRC Releases with LTE frequency redirection information
${NR_RRC_RELEASE_REDIR_EF_LTE}    M55124C03501    #Number of RRC Releases with LTE frequency redirection information for emergency fallback
${NNGCC_UE_CTXT_STP_REQ_RECD}    M55125C02501    #Number of INITIAL CONTEXT SETUP REQUEST received
${NNGCC_UE_CTXT_STP_REQ_EF_RECD}    M55125C03001    #Number of INITIAL CONTEXT SETUP REQUEST for emergency fallback received
${NNGCC_UE_CTXT_STP_RESP_SENT}    M55125C02502    #Number of INITIAL CONTEXT SETUP RESPONSE sent
${NNGCC_UE_CTXT_STP_RESP_EF_SENT}    M55125C03002    #Number of INITIAL CONTEXT SETUP RESPONSE for emergency fallback sent

@{DELTA_PARAS1}
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=600
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=600
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1

@{counters_dict_A006}
...    NRCELL-1:${NRRCC_RRC_RELEASE_REDIR_LTE}=1    #M55124C01502==1
...    NRCELL-1:${NR_RRC_RELEASE_REDIR_EF_LTE}=1    #M55124C03501==1
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_REQ_RECD}=2     #M55125C03004==2
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_RESP_SENT}=1    #M55125C03005==1
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_REQ_EF_RECD}=2    #M55125C03007==2
...    NRCELL-1:${NNGCC_UE_CTXT_MOD_RESP_EF_SENT}=1   #M55125C03008==1

${NRRCC_RRC_RELEASE_REDIR_LTE}    M55124C01502    #Number of RRC Releases with LTE frequency redirection information
${NR_RRC_RELEASE_REDIR_EF_LTE}    M55124C03501    #Number of RRC Releases with LTE frequency redirection information for emergency fallback
${NNGCC_UE_CTXT_MOD_REQ_RECD}    M55125C03004    #Number of  UE CONTEXT MODIFICATION REQUEST received
${NNGCC_UE_CTXT_MOD_REQ_EF_RECD}    M55125C03007    #Number of  UE CONTEXT MODIFICATION REQUEST for emergency fallback received
${NNGCC_UE_CTXT_MOD_RESP_EF_SENT}    M55125C03008   #Number of  UE CONTEXT MODIFICATION RESPONSE for emergency fallback sent
${NNGCC_UE_CTXT_MOD_RESP_SENT}    M55125C03005    #Number of  UE CONTEXT MODIFICATION RESPONSE sent

${active}    Active
*** Test Cases ***
FGCR-9453-5G21A-ET-A005_Verify EmergencyFallback with Redirection successful when UE in IDLE without PDUSession with UEcapa in ICSR
    [Tags]    FGCR-9453   A005    QC_61817
    [Documentation]
    ...    1.Purpose
    ...      A005 is test EmergencyFallback with Redirection would be successful when UE in IDLE without PDUSession with UEcapability in ICSR
    ...    2. Test Case Steps:
    ...    Step 1: ALL NG links is up
    ...         2. RRC message would be IDLE in 5s after UE registered
    ...         3. UE perform ServiceRequest with service_type =emergency call
    ...         4. IRAT emergency fallback would be successful
    ...          a.gNB-CU-CP receives NGAP: INITIAL CONTEXT SETUP REQUEST with Emergency FallbackIndicatorIE (and optionally
    ...            emergencyServiceTargetCN IE) and UERadioCapability without PDUSessionResourceSetupListCxtReq IE
    ...          b.gNB-CU-CP sends F1AP: DL RRC MESSAGE TRANSFER to gNB-DU
    ...          c.gNB-DU sends RRC: SECURITY MODE COMMAND to UE
    ...          d.gNB-DU receives RRC: SECURITY MODE COMPLETE from UE
    ...          e.gNB-CU-CP sends NGAP: INITIAL CONTEXT SETUP RESPONSE to AMF without PDUSessionResourceFailedToSetupListCxtRes
    ...         5. GNB-DU receives F1AP: Ue Context Release Command with cause "Normal Release"
    ...         6. GNB-DU sends RRC: RRC Release message to UE and eutra freq 1 <support PLMN1 , eutra>is selected as redirection target
    ...            indicated within RRC release message; cnType indicated in RRC Release message should be same with in
    ...            InitialContextSetupRequestIEs->EmergencyFallbackIndicator->EmgegencyServiceTargetCN
    ...         7. GNB sends NGAP: Ue Context Release Request with cause "Redirection"
    Check all NG links is up
    Start To Capture Wireshark Log    FGCR9453_A005
    A005 case to Access RRC IDLE without PDU with UECapbility 1
    Set RRC param with emergency
    Perform IDLE UE1 ServiceRequest
    Stop Capture Wireshark Log    FGCR9453_A005
    Check Counters    ${counters_dict_A005}
    Check WireShark Log    ${CURDIR}/a2a_A005_A006/a2a_FGCR9453_A005.ini    name=FGCR9453_A005    wait_string=UEContextReleaseComplete::4

FGCR-9453-5G21A-ET-A006_Verify EmergencyFallback with Redirection would be successful when UE in CONNECTED
    [Tags]    FGCR-9453   A006    QC_61818
    [Documentation]
    ...    1.Purpose
    ...      A006 is test Verify EmergencyFallback with Redirection would be successful when UE in CONNECTED
    ...      all cases are related with legacy feature 5GC001468-A006 & B001
    ...    2. Test Case Steps:
    ...    Step 1: UE1 and UE2 perform emergency service request
    ...         2: IRAT emergency fallback would be triggered in UE1 <selected PLMN= PLMN1>
    ...          a.gNB-CU-CP receives NGAP: UE CONTEXT MODIFICATION REQUEST with Emergency Fallback Indicator IE
    ...          b.gNB-CU-CP sends NGAP: UE CONTEXT MODIFICATION RESPONSE
    ...          c.gNB-CU-CP intiates RRC Connection release with redirection information (redirectedInfoCarrier IE)
    ...         3: The EUTRA target layer with eutra freq 1 is selected as redirection target indicated within RRC release message to UE1,
    ...              and no Freq is  selected for UE2 redirection
    ...         4: cnType indicated in RRC release message  should be same with in ueContextModificationRequestIEs__EmergencyFallbackIndicator
    ...             __EmgegencyServiceTargetCN
    ...         5: 5G-CP-UE shall start E1 Bearer Context release during Emergency Fallback with redirect and set the cause IE in E1AP:
    ...             BEARER CONTEXT RELEASE COMMAND as "Normal release"
    ...         6:  IRAT emergency fallback would be unsuccessful in UE3 <selected PLMN= PLMN3>
    ...          a.gNB-CU-CP receives NGAP: UE CONTEXT MODIFICATION REQUEST with Emergency Fallback Indicator IE included
    ...          b.gNB-CU-CP sends UE CONTEXT MODIFICATION FAILURE with Radio Network layer cause: Unspecified
    Check all NG links is up
    Delta Commission Parameters    ${DELTA_PARAS1}
    Clear Counter files
    Start To Capture Wireshark Log    FGCR9453_A006
    Perform connected UE1 and UE3 servicerquest
    Stop Capture Wireshark Log     FGCR9453_A006
    Check Counters    ${counters_dict_A006}
    Check WireShark Log    ${CURDIR}/a2a_A005_A006/a2a_FGCR9453_A006.ini    name=FGCR9453_A006    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,100,200,788 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=0,100,200,788 plmn=311:490
    Update Cfg    set_amf_region id=3 tac_list=0,100,200,788 plmn=311:491
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb3}
    ${sim_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666 gscn=7880
    ...    mandatory_for_activation=off
    Update Cfg    ${sim_gnb3_cell1}
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb5}
    ${sim_gnb5_cell1}    catenate     set_cell id=1 gnb=5 pci=16:0 tac=0 nrci=0x03 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666 gscn=7880
    ...    mandatory_for_activation=off
    Update Cfg    ${sim_gnb5_cell1}
    Update Cfg    gnb_param id=5 xn_listening_socket=1 send_xn_setup=false
    Update Cfg    ue_param id=1 ue_nr_capabilities=${UE1_Capabilities}
    ${set_ue2}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:490:0000:0:0:021645401 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue2}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE1_Capabilities}
    ${set_ue3}    catenate    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:491:0000:0:0:021645402 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue3}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${UE1_Capabilities}
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-6 qos_flows=1,2 qos_rules=1,2
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    ${set_amf1}    catenate    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    ...    emergency_service_fallback=on target_cn=epc
    Update Cfg    ${set_amf1}
    ${set_amf2}    catenate    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    ...    emergency_service_fallback=on target_cn=epc
    Update Cfg    ${set_amf2}
    ${set_amf3}    catenate    amf_param id=3 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    ...    emergency_service_fallback=on target_cn=epc
    Update Cfg    ${set_amf3}
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-6 qos_flows=1,2 qos_rules=1,2
    Update Cfg    ue_nr_capabilities id=1-6 voice_over_nr=on:on:off
    Update Cfg    amf_ue_ics_param id=1 include_ue_capabilities=on
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=3 voice_over_nr=on:on:off
    Update Cfg    amf_ue_ics_param id=2 include_ue_capabilities=on
    Update Cfg    amf_ue_ics_param id=3 include_ue_capabilities=on

Check all NG links is up
    ${params}    create list    SERVEDAMF-1:ngLinkStatus=${active}    SERVEDAMF-2:ngLinkStatus=${active}    SERVEDAMF-3:ngLinkStatus=${active}
    object should exist    ${params}


A005 case to Access RRC IDLE without PDU with UECapbility ${ue}
    Execute Egate Command    amf_ue_ics_param id=1 include_ue_capabilities=on ue=${ue}    timeout=20s
    Execute Egate Command    ue_register id=${ue}    UE1: IS IDLE    timeoute=20s

Set RRC param with emergency
    [Arguments]    ${ue_id}=1
    ${cmd}    catenate    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute Egate Command    ${cmd}

Perform IDLE UE${ue} ServiceRequest
    ${cmd}    catenate    ue_im_exit id=${ue} by=ue service_type=emergency_services_fallback
    ${ret1}=     Execute Egate Command    ${cmd}    RrcRelease is received for UE_NAS_5GS_MM_SERVICE_REQUEST_INITIATED
    ...    timeout=20s
    Run keywords    Should Contain    ${ret1}=    rrcRelease   AND    Should Contain    ${ret1}=    eutraFrequency 400
    Sleep    5s

SA Attach UE
    [Arguments]    ${ue}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1
    BuiltIn.Log    Trigger UE${ue} registration and PDU setup...     console=${True}
    ${cmd}    catenate    ue_register id=${ue}
    Execute Egate Command    ${cmd}    pass_regexp=NG RM Registered
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue} pdu=${pdu} nwslice=${nwslice} gw=${gw}
    Execute Egate Command    ${cmd}    pass_regexp=Initial Context Setup Successful

Perform CONNECTED UE${ue} ServiceRequest
    ${cmd}    Catenate    ue_conn_service_req id=${ue} service_type=emergency_services_fallback
    ${print}    Run keyword if    '${ue}'=='1'    set variable    IS IDLE
    ...    ELSE IF    '${ue}'=='3'     set variable    UE Context Modification Failure from GNB-2 with cause RAN unspecified
    ${ret1}=     Execute Egate Command    ${cmd}    ${print}    timeout=20s
    Run Keyword If    '${ue}'=='1'    Run keywords    Should Contain    ${ret1}=    rrcRelease
    ...   AND    Should Contain    ${ret1}=    eutraFrequency 400
    sleep    5s

Perform connected UE1 and UE3 servicerquest
    SA Attach UE
    Perform CONNECTED UE1 ServiceRequest
    SA Attach UE    ue=3   gw=3
    Perform CONNECTED UE3 ServiceRequest
    sleep    30s
