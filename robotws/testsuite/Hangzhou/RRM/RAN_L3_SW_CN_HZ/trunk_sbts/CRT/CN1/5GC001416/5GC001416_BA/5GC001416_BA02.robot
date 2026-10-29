*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-DevHZ5_SG2
...  owner-Chen.yili  release-20B
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  MRBTS-1/NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true
...  MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=48
...  MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...  MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77
...  MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=636668
...  MRBTS-1/NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=7881

@{PARAMS_TO_MODIFY_NRCONNECTMODE_0_48}
...  MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=48

@{PARAMS_TO_MODIFY_NRCONNECTMODE_0_77}
...  MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77

@{PARAMS_TO_MODIFY_NRCONNECTMODE_0_48_77}
...  MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=48, 77

@{PARAMS_TO_MODIFY_NRCELL_nrConnectModeProfileDN}
...  MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1

@{PARAMS_TO_DELETE_NRCELL_nrConnectModeProfileDN}
...  delete:MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN

${UE31_NR_Capa}
...  SEPARATOR=
...  ED007000479A4BBF5FFFFEF8005BD409800CFDBFCB98AD7FFBF900001F53FFFFC000100880000
...  073BF79FFF9FFFF60000FBC00BFFF0000163C03F148200DFFF785FFF5E00F2A6A700015880000
...  0000023007CAA080E0

${UE31_eutra_nr_Capa}
...  SEPARATOR=
...  BD1BA083058380713000000018062B000060400C1001830030600E260000010300C160801C4C0000040601
...  82C000389800000C0C03058100713000002018060B0600E2600000503000100510000C0100282644000389178A03840004020100200
...  4A000201000080400020100008040002010080100210000804040080108000802020040084000401010020042000200808010021000
...  1008040080110000804020040080801002
${UE32_NR_Capa}
...  SEPARATOR=
...  ED007000479A4BBF5FFFFEF8001BD405E00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF
...  3FFF3FFFEC0001F78017FFE00002C7807E290401BFFEF0BFFEBC01E54D4E0002B100000000004600F954101C0

${UE32_eutra_nr_Capa}
...  SEPARATOR=
...  BD1BA08305838070BC00000018062B000060400C1001830030600E178000010300C160801C2F000004060
...  182C000385E00000C0C0305810070BC00002018060B0600E1780000503000100510000C01002817C4000389178A038400040201002
...  004A000201000080400020100008040002010080100210000804040080108000802020040084000401010020042000200808010021
...  0001008040080110000804020040080801002

${UE33_NR_Capa}
...  SEPARATOR=
...  ED007000479A4BBF5FFFFEF8001BD405E00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF
...  3FFF3FFFEC0001F78017FFE00002C7807E290401BFFEF0BFFEBC01E54D4E0002B100000000004600F954101C0

${UE33_eutra_nr_Capa}
...  SEPARATOR=
...  BD1BA08305838070BC00000018062B000060400C1001830030600E178000010300C160801C2F000004060
...  182C000385E00000C0C0305810070BC00002018060B0600E1780000503000100510000C01002817C4000389178A038400040201002
...  004A000201000080400020100008040002010080100210000804040080108000802020040084000401010020042000200808010021
...  0001008040080110000804020040080801002

*** Test Cases ***
5GC001416-ET-BA002_Verify_EN-DC_Configuration_Update_triggered_successfully_by_modification_additon_deletion_of_alternative_bands
    [Documentation]
    ...  The purpose of this test case is to
    ...  'UE_id': '31','NATIVE_BAND': '','ALTENATIVE_BAND': '77','RESULT': 'successful RA','Description': 'support band77'
    ...  'UE_id': '32','NATIVE_BAND': '','ALTENATIVE_BAND': '48','RESULT': 'successful RA','Description': 'support band48'
    ...  'UE_id': '33','NATIVE_BAND': '','ALTENATIVE_BAND': '48','RESULT': 'SgNBAdditionRequestReject',
    ...  'Description': 'support band48 not supported in gnb'
    [Tags]    QC_60785
    Modify Scf For mfbi nrconnectmode with 77 and check
    Modify Scf For mfbi nrconnectmode with 48_77 and check
    Modify Scf For mfbi nrconnectmode with 48 and check
    Modify Scf For mfbi nrconnectmode with 48_77 and UE register
    Modify Scf For mfbi nrconnectmode with 77 and UE register
    Modify Scf For CELL nrConnectModeProfileDN and check UE
    Modify Scf For CELL nrConnectModeProfileDN and check cell

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${cell_1}    catenate
    ...  set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...  nr_arfcn=636668:636668 gscn=7881 mandatory_for_activation=off
    ${UE31}    catenate
    ...  set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...  eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=311:489:21645400
    ${UE32}    catenate
    ...  set_ue simulated id=32 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...  eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=311:489:21645401
    ${UE33}    catenate
    ...  set_ue simulated id=33 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...  eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=311:489:21645402
    Update Cfg    ${cell_1}
    Update Cfg    ${UE31}
    Update Cfg    ${UE32}
    Update Cfg    ${UE33}
    Update Cfg    set_bearer id=2 ue=31 qci=9 pdn=1 ip=4.7.254.209 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=32 qci=9 pdn=1 ip=4.7.254.210 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=33 qci=9 pdn=1 ip=4.7.254.211 default=on trf_type=internal

Modify_Scf_For_mfbi_nrconnectmode_with_48
    Delta Commission Parameters    ${PARAMS_TO_MODIFY_NRCONNECTMODE_0_48}
Modify_Scf_For_mfbi_nrconnectmode_with_77
    Delta Commission Parameters    ${PARAMS_TO_MODIFY_NRCONNECTMODE_0_77}
Modify_Scf_For_mfbi_nrconnectmode_with_48_77
    Delta Commission Parameters    ${PARAMS_TO_MODIFY_NRCONNECTMODE_0_48_77}
Modify_Scf_For_CELL_nrConnectModeProfileDN
    Delta Commission Parameters    ${PARAMS_TO_MODIFY_NRCELL_nrConnectModeProfileDN}

Trigger X2 reset via egate command
    Execute Egate Command    link_drop link=x2 by=enb:1 to=gnb:2 msg_type=abort
    sleep    1s
    Execute Egate Command    enb_x2_link_up enb=1 target=2

Attach UE check the result and check
    [Arguments]   ${ue_id}    ${RESULT}    ${target_cells}=1
    Start To Capture Wireshark Log    pcap_UE${ue_id}
    BuiltIn.log    pcap_UE${ue_id}
    Execute Egate Command    ue_attach id=${ue_id} profile=1   UE IS ACTIVE    timeout=20s
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...  ${RESULT}    timeout=20s
    Check Wireshark Log    ${CURDIR}${/}a2a_BA02${/}a2a_${ue_id}.ini    name=pcap_UE${ue_id}

Modify Scf For mfbi nrconnectmode with 77 and check
    Start To Capture Wireshark Log    BA02_modify
    Modify_Scf_For_mfbi_nrconnectmode_with_77
    Trigger X2 reset via egate command
    Check Wireshark Log    ${CURDIR}${/}a2a_BA02${/}a2a_78_77.ini    name=BA02_modify

Modify Scf For mfbi nrconnectmode with 48_77 and check
    Start To Capture Wireshark Log    BA02_add
    Modify_Scf_For_mfbi_nrconnectmode_with_48_77
    Trigger X2 reset via egate command
    Check Wireshark Log    ${CURDIR}${/}a2a_BA02${/}a2a_78_77_48.ini    name=BA02_add

Modify Scf For mfbi nrconnectmode with 48 and check
    Start To Capture Wireshark Log    BA02_delete
    Modify_Scf_For_mfbi_nrconnectmode_with_48
    Trigger X2 reset via egate command
    Check Wireshark Log    ${CURDIR}${/}a2a_BA02${/}a2a_78_48.ini    name=BA02_delete
    Update UE capa    ue_id=32    SA_Capa_perUE_Full=${UE32_NR_Capa}    Capa_LTE=${UE32_eutra_nr_Capa}
    Attach UE check the result and check    ue_id=32    RESULT=successful RA

Modify Scf For mfbi nrconnectmode with 48_77 and UE register
    Modify_Scf_For_mfbi_nrconnectmode_with_48_77
    Update UE capa    ue_id=31    SA_Capa_perUE_Full=${UE31_NR_Capa}    Capa_LTE=${UE31_eutra_nr_Capa}
    Attach UE check the result and check    ue_id=31    RESULT=successful RA

Modify Scf For mfbi nrconnectmode with 77 and UE register
    Modify_Scf_For_mfbi_nrconnectmode_with_77
    Update UE capa    ue_id=33    SA_Capa_perUE_Full=${UE33_NR_Capa}    Capa_LTE=${UE33_eutra_nr_Capa}
    Execute Egate Command    ue_attach id=33 profile=1   UE IS ACTIVE    timeout=20s
    Execute Egate Command    ue_dc_enb_start ue=33 target_gnb=2 target_cells=1 bearer=2 type=split_scg SgNBAdditionRequestReject

Modify Scf For CELL nrConnectModeProfileDN and check UE
    Modify_Scf_For_CELL_nrConnectModeProfileDN
    Execute Egate Command    ue_detach id=31   UE-initiated NAS DETACH PROCEDURE IS COMPLETED    timeout=20s
    Update UE capa    ue_id=31    SA_Capa_perUE_Full=${UE31_NR_Capa}    Capa_LTE=${UE31_eutra_nr_Capa}
    Attach UE check the result and check    ue_id=31    RESULT=successful RA

Modify Scf For CELL nrConnectModeProfileDN and check cell
    Delta Commission Parameters    ${PARAMS_TO_DELETE_NRCELL_nrConnectModeProfileDN}
    Cells Should Be Onair

Update UE capa
    [Arguments]    ${ue_id}=31    ${SA_Capa_perUE_Full}=none    ${Capa_LTE}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Execute Egate Command    ${cmd}
