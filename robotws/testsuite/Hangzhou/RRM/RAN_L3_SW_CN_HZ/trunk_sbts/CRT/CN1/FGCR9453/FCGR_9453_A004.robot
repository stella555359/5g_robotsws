*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_FDD    SBTS00    team-SG02    owner-yige.g.zhang
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
...    @{parameters_related_to_Redirect_Freq}
...    @{parameters_related_to_ransharing_and_multi_AMFs}
...    @{parameters_related_to_Multi_PLMN}
...    @{parameters_related_to_Intra_freq_Inter_gNB}

@{FGCR9453_related_flags}
...    MRBTS-1/NRBTS-1:actRedirect=true

@{parameters_related_to_Redirect_Freq}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirFreqNr=633372
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirPrio=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirRat=eutra
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirFreqEutra=400
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirPrio=2
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirSsbScs
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:redirSsbScs
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:redirRat=eutra
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:redirFreqEutra=38100
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:redirPrio=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1

@{parameters_related_to_ransharing_and_multi_AMFs}
...    MRBTS-1/NRBTS-1:actRanSharing=true
...    MRBTS-1/NRBTS-1:actRanSharingEnh=max_10_PLMNs
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirPrioBadUlRadio=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirPrioBadUlRadio=2
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:redirPrioBadUlRadio=3

...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true
...    delete:NRCELL-1:trackingAreaDN
...    delete:NRCELL-1:configuredEpsTac
...    delete:NRCELL-2:trackingAreaDN
...    delete:NRCELL-2:configuredEpsTac
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_NSA-1:configuredEpsTac=100
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_NSA-1:configuredEpsTac=100
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=490
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-3:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-3:mnc=491
...    MRBTS-1/NRBTS-1/NRPLMN-3:mncLength=3
...    NRBTS-1/SNSSAI-1:sst=1
...    NRBTS-1/SNSSAI-1:sd=13714341
...    NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/SNSSAI-1:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-1:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1


@{parameters_related_to_Multi_PLMN}
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=5
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=5
...    MRBTS-1/NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-0

@{parameters_related_to_Intra_freq_Inter_gNB}
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=45
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=none
...    MRBTS-1/NRBTS-1/NRADJGNB-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-3:xnLinkRef=1
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=0
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=636666
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=381
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=-8dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=-10dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:removeNotAllowed=false
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.124
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min

*** Test Cases ***
FGCR-9453-5G21A-ET-A004_Redirection A2 meas Successfully configured in target gNB after Successfully Intra-freq Inter-gNB handover
    [Documentation]
    ...    1.Purpose
    ...      A005 is A2 measurement for redirection in target gNB after Successful Intra-frequency Inter-gNB handover based on A3 or A5 measurements
    ...    2. Test Case Steps:
    ...    Step 1: UE attach successful
    ...         2: UE HO from real gNB to sim gNB successful
    ...         3. UE HO from sim gNB to real gNB successful
    ...         4. UE send redirection A2 report successful
    [Tags]    QC_61816
    Add UE History Information List
    SA Attach UE
    UE HO from real gNB to sim gNB trigger by eventID    1    A3
    UE HO from sim gNB to real gNB trigger by eventID    1    A3
    UE Send Redirection A2 report successful    1    A2
    Release UEs    ue_type=all
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    match_string=GNB-3: XnAP Link with GNB-2

Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,100,200,788 plmn=311:489
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb3}
    ${sim_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666 gscn=7880
    ...    mandatory_for_activation=off
    Update Cfg    ${sim_gnb3_cell1}
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false
    Update Cfg    ue_param id=1 ue_nr_capabilities=${UE1_Capabilities}
    ${set_ue2}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:490:0000:0:0:021645401 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue2}

Add UE History Information List
    Execute Egate Command    ue_history_information_list id=1 action=reset
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=99
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=1 ue_history_list=1

SA Attach UE
    [Arguments]    ${ue}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1
    BuiltIn.Log    Trigger UE${ue} registration and PDU setup...     console=${True}
    ${cmd}    catenate    ue_register id=${ue}
    Execute Egate Command    ${cmd}    pass_regexp=NG RM Registered
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue} pdu=${pdu} nwslice=${nwslice} gw=${gw}
    Execute Egate Command    ${cmd}    pass_regexp=Initial Context Setup Successful

UE HO from real gNB to sim gNB trigger by eventID
    [Arguments]    ${ue}=1    ${event}=A3
    BuiltIn.Log    UE${ue} HO from real gNB to sim gNB$ trigger by ${event}...    console=${True}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=636576    event_type=${event}
    ${intra_freq_intra_A3}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${mea_id} event=${event} srsrp_nr=45 phycell_id=381 nrsrp_nr=85 nrsrq_nr=85
    execute egate command    ${intra_freq_intra_A3}    pass_regexp=Inter-eNB handover

UE HO from sim gNB to real gNB trigger by eventID
    [Arguments]    ${ue}=1    ${event}=A3
    BuiltIn.Log    UE${ue} HO from sim gNB to real gNB trigger by ${event}...    console=${True}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=636576    event_type=${event}
    ${intra_freq_intra_A3}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${mea_id} event=${event} srsrp_nr=45 phycell_id=50 nrsrp_nr=85
    execute egate command    ${intra_freq_intra_A3}    pass_regexp=Inter-eNB handover

UE Send Redirection A2 report successful
    [Arguments]    ${ue}=1    ${event}=A2
    BuiltIn.Log    Trigger UE${ue} send Redirection A2 report successful...    console=${True}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=636576    event_type=${event}
    ${A2}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${mea_id} event=${event} srsrp_nr=30 srsrq_nr=30
    ${ret1}=    execute egate command    ${A2}    pass_regexp=UE1: IS IDLE    timeout=20s
    Should Contain    ${ret1}    rrcRelease
    Should Contain    ${ret1}    carrierFreq 633372
    Should Contain    ${ret1}    ssbSubcarrierSpacing kHz30
