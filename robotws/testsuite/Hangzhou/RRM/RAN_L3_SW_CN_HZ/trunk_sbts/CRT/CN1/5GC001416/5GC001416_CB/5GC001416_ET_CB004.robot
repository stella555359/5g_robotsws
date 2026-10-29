*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-DevHZ5_SG2
...  owner-yili.chen@nokia-sbell.com  release-20B
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{MFBI_activation}
...    @{MFBI_NRCONNECTEDMODE_Profile}
...    @{MFBI_NRCELL}
...    @{MFBI_NRMULTIBANDINFO_PROFILE}
...    @{NRADJNRCELL}
...    @{MFBI_NRNSPMAX_Profile}

@{MFBI_activation}
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true
@{MFBI_NRCONNECTEDMODE_Profile}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
@{MFBI_NRCELL}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRSACU=15min
@{MFBI_NRMULTIBANDINFO_PROFILE}
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=77|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
@{NRADJNRCELL}
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=524000
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=381
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=38
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=48
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=0
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1:actConflictConfiguration=true
...    MRBTS-1/NRBTS-1:actIncXn=true
@{MFBI_NRNSPMAX_Profile}
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
#DELAT parameters
@{add_NRADJGNB_and_XNLINK}
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJGNB-1:xnLinkRef=1
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.124
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddrCtrl=oamControlled
@{DELTA_PARAS1}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
@{DELTA_PARAS2}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=48, 77
@{DELTA_PARAS3}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=77
*** Test Cases ***
5GC001416-ET-CB004-Check_Outgoing_NGRAN_Node_Configuration_Update_procedure_shoud_contain_correct_multiple-frequency_band_info
    [Documentation]    This case is to verify Outgoing NGRANNodeConfigurationUpdate Msg should contain native band and alternative which is set in
    ...    NRCONNECTMODEPROFILEDN
    [Tags]    QC_60804
    Online modify nrConnectModeProfileDN of NRCELL from 0 to 2
    Modify_Scf_For_mfbi_nrconnectmode_with_48_77
    Modify_Scf_For_mfbi_nrconnectmode_with_77

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${set_gnb31}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1
    ${set_gnb32}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    ${cmd_1}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.2 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x1:22 daemon=10.0.2.1:22222
    ...    xn=10.0.1.2 x2_peers=none amf=1-3
    ${set_gnb33}    catenate    set_cell id=2 gnb=3 pci=127:1 tac=0 nrci=0x02 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${cmd_1}
    Update Cfg    ${set_gnb31}
    Update Cfg    ${set_gnb32}
    Update Cfg    ${set_gnb33}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false

Online modify nrConnectModeProfileDN of NRCELL from 0 to 2
    Delta Commission Parameters    ${add_NRADJGNB_and_XNLINK}
    Start To Capture Wireshark Log    CB04_modify
    Delta Commission Parameters    ${DELTA_PARAS1}
    Cells Should Be Onair    check_sib=${False}
    Trigger XN reset via egate command
    Check WireShark Log    ${CURDIR}/a2a_CB004/CB04_modify.ini    name=CB04_modify

Trigger XN reset via egate command
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2

Modify_Scf_For_mfbi_nrconnectmode_with_48_77
    Start To Capture Wireshark Log    CB04_add
    Delta Commission Parameters    ${DELTA_PARAS2}
    Cells Should Be Onair    check_sib=${False}
    Trigger XN reset via egate command
    Check WireShark Log    ${CURDIR}/a2a_CB004/CB04_add.ini    name=CB04_add

Modify_Scf_For_mfbi_nrconnectmode_with_77
    Start To Capture Wireshark Log    CB04_delete
    Delta Commission Parameters    ${DELTA_PARAS3}
    Cells Should Be Onair    check_sib=${False}
    Trigger XN reset via egate command
    Check WireShark Log    ${CURDIR}/a2a_CB004/CB04_delete.ini    name=CB04_delete
