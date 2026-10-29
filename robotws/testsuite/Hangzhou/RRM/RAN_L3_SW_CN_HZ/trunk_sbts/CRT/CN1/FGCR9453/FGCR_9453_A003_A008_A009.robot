*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
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
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    MRBTS-1/NRBTS-1:gNbCuType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    MRBTS-1/NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    MRBTS-1/NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    MRBTS-1/NRBTS-1/NRDRB-15:schedulWeight=1


#emergency call parameter
...    MRBTS-1/NRBTS-1/NRCELL-1:actEnhancedVoNR=false
...    MRBTS-1/NRBTS-1/NRCELL-1:maxNumOfGBRBearersSA=10
...    MRBTS-1/NRBTS-1/NRCELL-1:actGBRAdmissionControl=off
...    MRBTS-1/NRBTS-1/NRCELL-2:emergencyFBMode=disabled
...    MRBTS-1/NRBTS-1/NRCELL-2:actEnhancedVoNR=true
...    MRBTS-1/NRBTS-1/NRCELL-2:actGBRAdmissionControl=EnhancedVoNR
...    MRBTS-1/NRBTS-1/NRCELL-2:maxNumOfGBRBearersSA=1
...    MRBTS-1/NRBTS-1/NRCELL-2:n310VoNR=n10
...    MRBTS-1/NRBTS-1/NRCELL-2:t310VoNR=2000ms

#voNR call parameter
...    MRBTS-1/NRBTS-1:actNormVCFallback=true
...    MRBTS-1/NRBTS-1/NRCELL-1:actVoNR=false
...    MRBTS-1/NRBTS-1/NRCELL-1:voiceFBMode=redirection
...    MRBTS-1/NRBTS-1/NRCELL-2:voiceFBMode=redirection
...    MRBTS-1/NRBTS-1/NRCELL-2:actVoNR=true

@{parameters_related_to_Redirect_Freq}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirFreqNr=633372
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirPrio=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirRat=eutra
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirFreqEutra=400
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirPrio=2
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:nrPlmnDNList
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:redirRat=eutra
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:redirFreqEutra=38100
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:redirPrio=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirFreqNr=633372
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirPrio=1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:redirRat=eutra
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:redirFreqEutra=400
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:redirPrio=2
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-3:redirRat=eutra
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-3:redirFreqEutra=38100
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-3:redirPrio=3
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirSsbScs
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:redirSsbScs
...    delete:MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:redirSsbScs
...    delete:MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-3:redirSsbScs

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
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=600
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=5
...    MRBTS-1/NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-0

@{DELTA_PARAS1}
...    MRBTS-1/NRBTS-1/NRDRB-10:resType=nonGBR_Signaling
...    MRBTS-1/NRBTS-1:actNormVCFallback=true
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:lcgid=0

@{DELTA_PARAS2}
...    MRBTS-1/NRBTS-1/NRDRB-10:resType=nonGBR_Signaling
...    MRBTS-1/NRBTS-1:actNormVCFallback=true
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:lcgid=0
...    MRBTS-1/NRBTS-1/NRCELL-2:actEmergencyCall=true
...    MRBTS-1/NRBTS-1/NRCELL-2:emergencyCallFails=true
...    MRBTS-1/NRBTS-1/NRCELL-2:maxNumOfNonGBRBearersSA=1
...    MRBTS-1/NRBTS-1/NRDU-1:numOfDrbsReservForEmergency=1
...    MRBTS-1/NRBTS-1/NRCELL-2:numOfRadioResReservForEmergency=0
...    MRBTS-1/NRBTS-1/NRCELL-2:arpPrioEmergencyCall=1
...    MRBTS-1/NRBTS-1/NRCELL-2:emergencyCallRestrictions:emergencyCallMrListIgnore=false
...    MRBTS-1/NRBTS-1/NRCELL-2:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=false
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    delete:MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:nrPlmnDNList
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2

${active}    Active

@{counters_dict_A009}
...    NRCELL-2:${NRRCC_RRC_RELEASE_REDIR_LTE}=1    #M55124C04002==1

${NRRCC_RRC_RELEASE_REDIR_LTE}    M55124C04002    # Number of IMS Emergency Call attempts redirected to LTE
#
#${GNB_BIP_FLAG}  ${True}
${RECREATE_WIRESHARK_FLAG}    ${false}
*** Test Cases ***
FGCR-9453-5G21A-ET-A003_Fallback via redirection success with no voice supported in gNB
    [Tags]   A003    QC_61815
    [Documentation]
    ...    1.Purpose
    ...       A003 is test Fallback via redirection <add plmn restriction> success with no voice supported in gNB
    ...       related with legacy feature 5GC000749
    ...       A008  Verify fallback to LTE when VoNR fail setup due to max number of GBR bearers_TDD_SA
    ...       related with legacy feature 5GC000786-B008
    ...    2. Test Case Steps:
    ...    Step 1. Three NG links up
    ...         2. UE4 trigger no VoNR call
    ...         3. UE4 trigger redirection to Eutra successful
    ...         4. Set fallback on nidd paramter 
    ...         5. UE1 setup 5QI1, but failed due to gNB not supported
    ...         6. UE2 send A2 measurement for redirection successful
    ...         7. UE3 send A2 measurement for redirection fail

    Check all NG links is up
    Trigger UE MO VoNR call with PDU    ue=4    gw=4
    Trigger UE4 Redirection To Eutra Freq Successfully In A003  #in case A002,UE send A2 report for redirction
    Delta Commission Parameters    ${DELTA_PARAS1}
    Trigger UE1 5QI1 setup successfully for A008
    SA Attach UE    ue=2   gw=2
    Trigger UE2 Redirection To Eutra Freq Successfully In A008
    SA Attach UE    ue=3   gw=3
    Trigger UE3 Redirection To Eutra Freq Failed In A008
    Release ues    ue_type=all
    Check WireShark Log    ${CURDIR}/a2a_A003_A008_A009/a2a_FGCR9453_A003.ini    wait_string=UEContextReleaseComplete::24

FGCR-9453-5G21A-ET-A009_Verify_emergency_call_redirect_to_LTE_due_to_ICS_with_5QI5_and_5QI1_CU_RAC_failed
    [Tags]   A009    QC_61820
    [Documentation]
    ...    1.Purpose
    ...     verify emergency call would be redirected to LTE when 5QI5&5QI1 RAC failed in ICSR when set GBR/NonGBR DRB to 1.
    ...     and related counters should be increased accordingly.
    ...    2. Test Case Steps:
    ...         a. UE-1 setup an emergency call with 5QI-5 and 5QI-1
    ...         b. UE-2 setup an emergency call with 5QI-5 and 5QI-1, UE-2 emergency call failed in ICS due to 5QI-5 RAC failed,
    ...            and RRC released<add PLMN restriction> with redirection info, related counters increased.
    ...    cover requirement in legacy 5GC000784-A017

    Check all NG links is up
    Delta Commission Parameters    ${DELTA_PARAS2}
    Clear Counter Files
    Start To Capture Wireshark Log    FGCR9453_A009
    Set RRC param with emergency and qosflow priority and scf parame    ue_id=1    smf_param=1
    Trigger UE MO VoNR call with PDU    request_type=initial-emergency-request
    Set RRC param with emergency and qosflow priority and scf parame    ue_id=2    smf_param=2
    Trigger 5QI5 setup failure in ICSR and Redirected    ue_id=2    gw=2    request_type=initial-emergency-request
    Stop Capture Wireshark Log    FGCR9453_A009
    Check Counters    ${counters_dict_A009}
    Check WireShark Log    ${CURDIR}/a2a_A003_A008_A009/a2a_FGCR9453_A009.ini    name=FGCR9453_A009    wait_string=establishment request::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,100,200,788 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=0,100,200,788 plmn=311:490
    Update Cfg    set_amf_region id=3 tac_list=0,100,200,788 plmn=311:491
    ${set_ue1}    catenate    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=2
    Update Cfg    ${set_ue1}
    Update Cfg    ue_param id=1 ue_nr_capabilities=${UE1_Capabilities}

    ${set_ue2}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:490:0000:0:0:021645401 mode=nr enb=2 cell=2
    Update Cfg    ${set_ue2}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE1_Capabilities}
    ${set_ue3}    catenate    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:491:0000:0:0:021645402 mode=nr enb=2 cell=2
    Update Cfg    ${set_ue3}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${UE1_Capabilities}
    ${set_ue4}    catenate    set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645402 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue4}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${UE1_Capabilities}
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-6 qos_flows=1,2 qos_rules=1,2
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    ${set_amf1}    catenate    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    ...   voice_fallback=on
    Update Cfg    ${set_amf1}
    ${set_amf2}    catenate    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    ...    voice_fallback=on
    Update Cfg    ${set_amf2}
    ${set_amf3}    catenate    amf_param id=3 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    ...    voice_fallback=on
    Update Cfg    ${set_amf3}
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-6 qos_flows=1,2 qos_rules=1,2
    Update Cfg    ue_nr_capabilities id=1-6 voice_over_nr=on:on:off
    Update Cfg    amf_ue_ics_param id=1 include_ue_capabilities=on
    Update Cfg    amf_ue_ics_param id=2 include_ue_capabilities=on
    Update Cfg    amf_ue_ics_param id=3 include_ue_capabilities=on

Check all NG links is up
    ${params}    create list    SERVEDAMF-1:ngLinkStatus=${active}    SERVEDAMF-2:ngLinkStatus=${active}    SERVEDAMF-3:ngLinkStatus=${active}
    object should exist    ${params}

SA Attach UE
    [Arguments]    ${ue}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1
    BuiltIn.Log    Trigger UE${ue} registration and PDU setup...     console=${True}
    ${cmd}    catenate    ue_register id=${ue}
    Execute Egate Command    ${cmd}    pass_regexp=NG RM Registered
    ${cmd1}    catenate    ue_pdu_session_setup ue=${ue} pdu=${pdu} nwslice=${nwslice} gw=${gw}
    Execute Egate Command    ${cmd1}    pass_regexp=Initial Context Setup Successful


Trigger UE MO VoNR call with PDU
    [Arguments]    ${ue}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1    ${request_type}=initial-request    ${fiveQI}=5
    ...    ${additional_qosflows_to_activate}=2
    BuiltIn.Log    Trigger UE MO VoNR call with PDU...    console=${True}
    Execute Egate Command    ue_register id=${ue}    NG RM Registered    timeout=20s
    ${cmd}    Catenate    ue_pdu_session_setup ue=${ue} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ${ret1}=    Execute Egate Command    ${cmd}    QoS Routing Table   timeout=20s
    Should Contain    ${ret1}    securityModeCommand
    Should Contain    ${ret1}    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret1}    Setup QosFlow with QFI:1 5QI:5



Trigger UE${ue} Redirection To Eutra Freq Successfully In ${case}
    BuiltIn.Log    Trigger UE${ue} Redirection To Eutra Freq Successfully...    console=${True}
    ${cmd1}    Catenate    ue_pdu_session_modify ue=${ue} pdu=1 qosflows_to_add=2 by=amf
    ${ret1}=    Execute Egate Command    ${cmd1}   IS IDLE   timeout=20s
    Run Keyword If    '${case}'=='A003'    Run keywords
    ...    Should Contain    ${ret1}    rrcRelease    AND
    ...    Should Contain    ${ret1}    eutraFrequency 400
    Run Keyword If    '${case}'=='A008'    Run keywords
    ...    Should Contain    ${ret1}    rrcRelease    AND
    ...    Should Contain    ${ret1}    eutraFrequency 38100


Trigger UE1 5QI1 setup successfully for A008
    SA Attach UE    ue=1   gw=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf    QoS Routing Table    timeout=20s
    Should Contain    ${ret1}    rrcReconfiguration
    Should Contain    ${ret1}    pdcp-SN-SizeUL len18bits  # UE_capa not support shortSN PDCP, so 18bits here configured
    Should Contain    ${ret1}    pdcp-SN-SizeDL len18bits
    Should Contain    ${ret1}    ul-UM-RLC
    Should Contain    ${ret1}    sn-FieldLength size12
    Should Contain    ${ret1}    dl-UM-RLC
    Should Contain    ${ret1}    sn-FieldLength size12
    Should Contain    ${ret1}    t-Reassembly ms40
    Should Contain    ${ret1}    logicalChannelGroup 4
    Should Contain    ${ret1}    schedulingRequestID 0

Trigger UE3 Redirection To Eutra Freq Failed In A008
    BuiltIn.Log    Trigger UE3 Redirection To Eutra Freq Faield...    console=${True}
    ${cmd}    Catenate    ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=2 by=amf
    ${ret1}    Execute Egate Command    ${cmd}   Deleted Unsuccessful QosFlow QFI:2    timeout=20s

Set RRC param with emergency and qosflow priority and scf parame
    [Arguments]    ${ue_id}=1    ${smf_param}=1
    ${cmd}    Catenate    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute Egate Command    ${cmd}
    Set qosflow priority and smf param    smf_param=${smf_param}

Set qosflow priority and smf param
    [Arguments]    ${priority}=1    ${smf_param}=1
    BuiltIn.Log    Set qosflow priority and smf param...    console=${True}
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    smf_param id=${smf_param} additional_qosflows_to_activate=2


Trigger 5QI5 setup failure in ICSR and Redirected
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=1    ${gw}=1   ${request_type}=initial-emergency-request    ${priorityLevelARP}=1
    BuiltIn.Log    Trigger 5QI5 setup failure in ICSR and Redirected...    console=${True}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered    timeout=20s
    ${ret1}    Execute Egate Command
    ...    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    Received RRC Release while in FIVE-GS-MM-REGISTERED state    timeout=20s
    Should Contain    ${ret1}    Received Initial Context Setup Failure from GNB-2 with cause RAN redirection
    Should Contain    ${ret1}    Redirected carrier info is present in RRC Release
    Should Contain    ${ret1}    E-UTRA redirectedCarrierInfo=400

