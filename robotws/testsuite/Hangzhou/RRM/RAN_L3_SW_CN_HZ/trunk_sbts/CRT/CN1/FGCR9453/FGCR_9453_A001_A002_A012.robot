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
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirPrio=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirRat=eutra
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirFreqEutra=400
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirPrio=2
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:redirRat=eutra
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:redirFreqEutra=38100
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:redirPrio=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirRat=nr
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirFreqNr=633372
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirPrio=1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:redirRat=eutra
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:redirFreqEutra=400
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:redirPrio=2
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-3:redirRat=eutra
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-3:redirFreqEutra=38100
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-3:redirPrio=3
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2

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

#paramters related to feature 708, A2 measurement
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=45
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=none

...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeasRedirectEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=45
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoEnabledSA=none

@{DELTA_PARAS1}
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1

${active}    Active


${GNB_BIP_FLAG}  ${True}
*** Test Cases ***
FGCR-9453-5G21A-ET-A001_Redirection to NR based on A2 measurements
    [Tags]    FGCR-9453   A001  A002    QC_61813
    [Documentation]
    ...    1.Purpose
    ...      A001 is test Redirection to NR based on redirection A2 measurements, test on the cell1
    ...      A002 is test Redirection to LTE based on redirection A2 measurements  test on the cell2
    ...      A012 is test freq supported plmn changed before redirection A2 measurement reported
    ...      all cases are related with legacy feature 5GC000708
    ...    2. Test Case Steps:
    ...    Step 1. UE1 and UE3 send A2 measurement for redirection
    ...         2. in rrcRelease message nr freq 1 is provided to UE1 for redirection
    ...         3. UE4 send A2 measurement for redirection
    ...         4. in rrcRelease message eutra freq 2 is provided to UE4 for redirection

    Check all NG links is up
    SA Attach UE     ue=4    gw=4
    UE4 Send Redirection A2 report with Meas_id1 succeed  #trigger coverage based redirction successfully
    SA Attach UE     ue=3    gw=3
    UE3 Send Redirection A2 report with Meas_id1 failed
    SA Attach UE     ue=1    gw=1
    Trigger UE1 Redirection To Eutra Freq Successfully In A002  #in case A002,UE send A2 report for redirction

FGCR-9453-5G21A-ET-A012_redirection freq supported plmn changed before redirection A2 measurement reported
    [Tags]    FGCR-9453   A012    QC_61821
    [Documentation]
    ...    1.Purpose
    ...      A012 is test freq supported plmn changed before redirection A2 measurement reported
    ...      all cases are related with legacy feature 5GC000708
    ...    2. Test Case Steps:
    ...    Step 1. UE4 send A2 measurement for redirection
    ...         2. in rrcRelease message eutra freq 2 is provided to UE4 for redirection

    Check all NG links is up
    Delta Commission Parameters    ${DELTA_PARAS1}
    SA Attach UE     ue=1    gw=1
    UE1 Send Redirection A2 report with Meas_id1 succeed

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
    ...    suci=0:311:490:0000:0:0:021645401 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue2}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE1_Capabilities}
    ${set_ue3}    catenate    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:491:0000:0:0:021645402 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue3}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${UE1_Capabilities}
    ${set_ue4}    catenate    set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645402 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue4}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${UE1_Capabilities}
    Update Cfg    set_qosflow id=1 5qi=5 default=on2
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

SA Attach UE
    [Arguments]    ${ue}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1
    BuiltIn.Log    Trigger UE${ue} registration and PDU setup...     console=${True}
    ${cmd}    catenate    ue_register id=${ue}
    Execute Egate Command    ${cmd}    pass_regexp=NG RM Registered
    ${cmd1}    catenate    ue_pdu_session_setup ue=${ue} pdu=${pdu} nwslice=${nwslice} gw=${gw}
    Execute Egate Command    ${cmd1}    pass_regexp=Initial Context Setup Successful


UE${ue} Send Redirection A2 report with Meas_id${meas_id} ${result}
    BuiltIn.Log    Trigger UE${ue} send Redirection A2 report with meas_id ${meas_id}...    console=${True}
    ${pass_regexp}    Run keyword if    '${result}'=='succeed'   set variable    UE${ue}: IS IDLE
    ...    ELSE    set variable    meas_id=1 not found     # failed
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ${ret1}=    Execute Egate Command    ${cmd}   ${pass_regexp}   timeout=20s
    Run keyword if    '${result}'=='succeed'     Run keywords    Should Contain    ${ret1}=    rrcRelease    AND    Should Contain    ${ret1}=
    ...    carrierFreq 633372    AND    Should Contain    ${ret1}=     ssbSubcarrierSpacing kHz30

Trigger UE${ue} Redirection To Eutra Freq Successfully In ${case}
    BuiltIn.Log    Trigger UE${ue} Redirection To Eutra Freq Successfully...    console=${True}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue} meas_id=1 event=A2 srsrp_nr=30 srsrq_nr=30
    ${ret1}=    Execute Egate Command    ${cmd}   IS IDLE   timeout=20s
    Should Contain    ${ret1}=    rrcRelease
    Should Contain    ${ret1}=    eutraFrequency 38100
