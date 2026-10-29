*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-DevHZ5_SG2
...  owner-yili.chen@nokia-sbell.com  release-20B
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{encrypt}
...    @{MFBI_activation}
...    @{MFBI_NRCONNECTEDMODE_Profile}
...    @{MFBI_NRCELL}
...    @{MFBI_NRMULTIBANDINFO_PROFILE}
...    @{NRADJNRCELL}
...    @{MFBI_NRNSPMAX_Profile}
...    @{NRADJGNB}
...    @{NRREL}
...    @{HO}

@{encrypt}
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
@{MFBI_activation}
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true
@{MFBI_NRCONNECTEDMODE_Profile}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
@{MFBI_NRCELL}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
@{MFBI_NRMULTIBANDINFO_PROFILE}
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78|nrBandPriority=0
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=77|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=77|nrBandPriority=1
@{NRADJNRCELL}
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=36
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=636666
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=48
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=48
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=0
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1:actConflictConfiguration=true
...    MRBTS-1/NRBTS-1:actIncXn=true
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL
@{NRREL}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:gNbId=36
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:lcrId=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
@{MFBI_NRNSPMAX_Profile}
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalPmax=4
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=5
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=6
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2:nrNsPmaxList:additionalPmax=0
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2:nrNsPmaxList:additionalSpectrumEmission=6
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2:nrNsPmaxList:nrNsPmaxPriority=7
@{NRADJGNB}
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBId=36
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJGNB-1:xnLinkRef=1
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.122
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddrCtrl=oamControlled
@{HO}
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=250
...    MRBTS-1/NRBTS-1/NRCELL-1:absThreshSsbRsrpConsolidation=1
...    MRBTS-1/NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=1

@{DELTA_PARAS_CB07}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=48, 77

@{DELTA_nrConnectModeProfileDN}
...    delete:MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrConnectModeProfileDN

${UE1_NR_Capa}  #CB05_06_07_08
...    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C101010
...    70EF1C39061C00103278FAB80027800E0009E00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E001
...    51B0BF582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C043D6C10101070EF1C
...    39061C00103278FAA8000028000001041C4C0000001070BC00000000809A0A02C0402201107B058060005038180703005807000683E0000000
...    000000E54D000100000965950034AAA8081C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA1280
${UE1_RESULT}    Initial Context Setup Successful
#Description': 'supportedBandListNR:n77,n48,supportedBandCombinationList:n77,n48'},

${UE2_NR_Capa}
...    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C39061C00
...    103278FAB80027800E0009E00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B137582
...    028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C043D6C10101070EF1C3906
...    1C00103278FAA8000028000001041C4C00000010713400000800809A0A02C0402201107B058060005038180703005807000683E00A000
...    0000140000000800F2A6F2A680308000032CB2B08000092CB2A00E9555D2AAA0207000B00008004008010008020043162600020406080
...    A0C0E10162022242632424A4C4E5094
${UE2_RESULT}    Initial Context Setup Successful
#Description': 'supportedBandListNR:n77

${UE3_NR_Capa}
...    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C39061C00
...    103278FAB80027800E0009E00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B137582
...    028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C043D6C10101070EF1C3906
...    1C00103278FAA8000028000001041C4C00000010713400000800809A0A02C0402201107B058060005038180703005807000683E00A000
...    0000040000000A00F2A6F2A680308000012CB2B080000B2CB2A00E9555D2AAA0207000B00008004008010008020043162600020406080
...    A0C0E10162022242632424A4C4E5094
${UE3_RESULT}    Initial Context Setup Successful
#Description': 'supportedBandListNR:n78

${SGNB_SA_ADMISSION_REQ}    M55138C00001
${SGNB_SA_ADMISSION_SUCC}    M55138C00002
${GNB_SA_ADMISSION_MFBI_REQ}    M55138C00501
${GNB_SA_ADMISSION_MFBI_SUCC}    M55138C00502
${GNB_SA_HO_ADMISSION_MFBI_REQ}    M55138C00503
${GNB_SA_HO_ADMISSION_MFBI_SUCC}    M55138C00504

@{PM_Counters_Check_1}
...    NRCELL-1:${GNB_SA_HO_ADMISSION_MFBI_REQ}=0
...    NRCELL-1:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=0
@{PM_Counters_Check_2}
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_REQ}==1
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_SUCC}==1
...    NRCELL-1:${SGNB_SA_ADMISSION_REQ}==1
...    NRCELL-1:${SGNB_SA_ADMISSION_SUCC}==1
@{PM_Counters_Check_3}
...    NRCELL-1:${GNB_SA_HO_ADMISSION_MFBI_REQ}==1
...    NRCELL-1:${GNB_SA_HO_ADMISSION_MFBI_SUCC}==1
@{PM_Counters_Check_4}
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_REQ}==0
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_SUCC}==0
...    NRCELL-1:${SGNB_SA_ADMISSION_REQ}==1
...    NRCELL-1:${SGNB_SA_ADMISSION_SUCC}==1
@{PM_Counters_Check_5}
...    NRCELL-1:${GNB_SA_HO_ADMISSION_MFBI_REQ}==0
...    NRCELL-1:${GNB_SA_HO_ADMISSION_MFBI_SUCC}==0

@{PARAMS_IN_SWCONFIG}
...  0x59004D=1    #set now in the QT swconfig file, till we have verified that the UE side is aligned in term of capabilities

*** Test Cases ***
5GC001416-ET-CB008-Check_Inter-gNB_Handover_should_be_failed_when_different_alternative_bands_configured_for_source_and_target_cell
    [Documentation]   This case is to verify inter-gnb ho should be failed when different alterband bands are configured in source and target cell.
    ...    UE supports n77 and n48, not n78.
    [Tags]    QC_47227
    register ue with ue_cap for CB    ue_id=1
    Clear Counter files
    HO from real gNB to RANSim for CB08 and no HO triggered
    Check Counters    ${PM_Counters_Check_1}

5GC001416-ET-CB007-Check_Inter-gNB_Handover_should_be_successful_using_alternative_bands
    [Documentation]    This case is verify inter-gnb ho should be successful when alternative band n77 is configured in both source and target cells.
    ...    UE supports n77, not n78.
    [Tags]    QC_60806
    online add band 77 of NRCONNECTMODE_PROFILE-1
    PRY register ue on band77
    PRY register ue on band78
    Delete NRADJNRCELL nrConnectModeProfileDN

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${set_gnb51}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    ${set_gnb52}    catenate    set_cell id=1 gnb=5 pci=16:0 tac=0 nrci=0x03 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mapped_MFBI=77 mandatory_for_activation=off
    ${cmd_1}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x01:22
    ...    xn=10.0.1.2 daemon=10.0.2.1:22222 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${cmd_1}
    Update Cfg    ${set_gnb51}
    Update Cfg    ${set_gnb52}
    Update Cfg    gnb_param id=5 xn_listening_socket=1 send_xn_setup=false

register ue with ue_cap for CB
    [Arguments]   ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE${ue_id}_NR_Capa}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
	Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...    pass_regexp=${UE${ue_id}_RESULT}
    traffic should be ok    ue_id=${ue_id}    type=sa

HO from real gNB to RANSim for CB08 and no HO triggered
    ${a3_rsrp_cmd}    Set Variable
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=48 nrsrp_nr=31 nrsrq_nr=31
    ${result}    Execute Egate Command    ${a3_rsrp_cmd}    pass_regexp=measResultNeighCells measResultListNR
    should not contain    ${result}    Inter-eNB handover

online add band 77 of NRCONNECTMODE_PROFILE-1
    Execute Egate Command    gnb_param id=5 send_xn_setup=true
    Execute Egate Command    gnb_xn_link_up gnb=5 target=2
    Delta Commission Parameters    ${DELTA_PARAS_CB07}

Add ue history list
    [Arguments]    ${ue_id}=2
    ${cmd1}    set variable    ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    ${cmd2}    set variable    ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x03 gnb_id=5 time_ue_stayed_in_cell=98
    ${cmd3}    set variable    ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=99
    Execute Egate Command    ${cmd1}
    Execute Egate Command    ${cmd2}
    Execute Egate Command    ${cmd3}
    Execute Egate Command    ue_history_information_list id=${ue_id} action=commit
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=1

HO from real gNB to RANSim
    [Arguments]    ${ue_id}=2
    ${a3_rsrp_cmd}    Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=48 nrsrp_nr=31 nrsrq_nr=31
    Execute Egate Command    ${a3_rsrp_cmd}    pass_regexp=Inter-eNB handover

HO from RANSim to real gNB
    [Arguments]    ${ue_id}=2
    ${a3_rsrp_cmd1}    Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=31 nrsrq_nr=31
    Execute Egate Command    ${a3_rsrp_cmd1}    pass_regexp=Inter-eNB handover

PRY register ue on band77
    Start To Capture Wireshark Log    real_to_sim_n77
    Add ue history list    ue_id=2
    Clear Counter files
    register ue with ue_cap for CB    ue_id=2
    Check Counters    ${PM_Counters_Check_2}
    HO from real gNB to RANSim    ue_id=2
    Check WireShark Log    ${CURDIR}/a2a_CB007/real_to_sim_n77.ini    name=real_to_sim_n77    wait_string=SNStatusTransfer::2
    Start To Capture Wireshark Log    sim_to_real_n77
    HO from RANSim to real gNB    ue_id=2
    Check WireShark Log    ${CURDIR}/a2a_CB007/sim_to_real_n77.ini    name=sim_to_real_n77    wait_string=SNStatusTransfer::2
    Check Counters     ${PM_Counters_Check_3}          # should report on target cell

PRY register ue on band78
    Start To Capture Wireshark Log    real_to_sim_n78
    Add ue history list    ue_id=3
    Clear Counter files
    register ue with ue_cap for CB    ue_id=3
    Check Counters    ${PM_Counters_Check_4}
    HO from real gNB to RANSim    ue_id=3
    Check WireShark Log    ${CURDIR}/a2a_CB007/real_to_sim_n78.ini    name=real_to_sim_n78    wait_string=SNStatusTransfer::2
    Start To Capture Wireshark Log    sim_to_real_n78
    HO from RANSim to real gNB    ue_id=3
    Check WireShark Log    ${CURDIR}/a2a_CB007/sim_to_real_n78.ini    name=sim_to_real_n78    wait_string=SNStatusTransfer::2
    Check Counters    ${PM_Counters_Check_5}

Delete NRADJNRCELL nrConnectModeProfileDN
    Delta Commission Parameters    ${DELTA_nrConnectModeProfileDN}
    Cells Should Be Onair    check_sib=${True}
