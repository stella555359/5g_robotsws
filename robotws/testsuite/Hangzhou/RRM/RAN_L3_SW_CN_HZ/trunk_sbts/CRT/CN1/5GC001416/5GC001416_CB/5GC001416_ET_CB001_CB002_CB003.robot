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

@{MFBI_NRMULTIBANDINFO_PROFILE}
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=77|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
@{NRADJNRCELL}
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=36
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=524000
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=48
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=38
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=0
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1:actConflictConfiguration=true
...    MRBTS-1/NRBTS-1:actIncXn=true
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL

@{MFBI_NRNSPMAX_Profile}
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1

@{delta_para1}
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

*** Test Cases ***
5GC001416-ET-CB002-Check_Outgoing_Xn_Setup_Request_procedure_shoud_contain_correct_multiple-frequency_band_info
    [Documentation]    This case covers CB01, CB02 and CB03
    ...    CB02 is to verify outing Xn setup request Msg should contain native band and alternative band which set in NRCONNECTMODEPROFILEDN
    ...    CB01 is to verify Incoming Xn setup request Msg should contain native band and alternative band whcih set in basic.cfg mapped_MFBI
    ...    CB03 is to verify Incoming NGRANNodeConfigurationUpdate should cotain native band and alternative band whcih set in basic.cfg mapped_MFBI
    [Tags]    QC_60805
    # CB002
    Start To Capture Wireshark Log    CB02
    Delta Commission Parameters    ${delta_para1}
    Check WireShark Log    ${CURDIR}/a2a_CB002/Outgoing_Xn_setup_request_response.ini    name=CB02
    # CB001
    Start To Capture Wireshark Log    CB01
    Start Xn link from simulated gnb1 to real gnb2
    Check WireShark Log    ${CURDIR}/a2a_CB002/Incoming_Xn_setup_request_response.ini    name=CB01
    # CB003
    Start To Capture Wireshark Log    CB03
    Trigger sim gnb to send NGRAN Node Configuration Update
    Check WireShark Log    ${CURDIR}/a2a_CB002/Incoming_NGRANNodeConfigurationUpdate.ini    name=CB03

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${set_gnb51}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none 
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=2
    ${set_gnb52}    catenate    set_cell id=1 gnb=5 pci=16:0 tac=0 nrci=0x03 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=524000:524000
    ...    gscn=6544 mapped_MFBI=41
    ${set_gnb53}    catenate    set_cell id=2 gnb=5 pci=16:1 tac=0 nrci=0x04 tdd_cell=on proxy=10.0.2.93:9999 nr_arfcn=524000:524000
    ...    gscn=6544 mapped_MFBI=90
    ...    mandatory_for_activation=off
    ${set_gnb54}    catenate    gnb_param id=5 xn_listening_socket=1 send_xn_setup=false
    ${set_gnb55}    catenate    enb_timer T_ShutdownNoX2TrafficTimer=none
    Update Cfg    ${set_gnb51}
    Update Cfg    ${set_gnb52}
    Update Cfg    ${set_gnb53}
    Update Cfg    ${set_gnb54}
    Update Cfg    ${set_gnb55}
    Update Cfg    gnb_param id=2 xn_listening_socket=1 send_xn_setup=false

Start Xn link from simulated gnb1 to real gnb2
    Execute Egate Command    gnb_param id=5 send_xn_setup=true
    Execute Egate Command    gnb_xn_link_up gnb=5 target=2
    sleep    3s  #wait untile print finished

Trigger sim gnb to send NGRAN Node Configuration Update
    Execute Egate Command    gnb_ngran_conf_update id=5 target=2 served_nr_cells_to_add=2

	
