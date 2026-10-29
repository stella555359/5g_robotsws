*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-DevHZ5_SG2
...    owner-xianjiao.xie    release-5G19A
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC000637}
...    @{NRADJGNB_1}
...    @{XNLINK_1}


@{5GC000637}
...    MRBTS-1/NRBTS-1:actIncXn=false
...    MRBTS-1/NRBTS-1:maxNumXnSetupRetry=3
...    MRBTS-1/NRBTS-1:retryXnSetupTmr=10
...    MRBTS-1/NRBTS-1:xnLinkReestabTmr=60
...    MRBTS-1/NRBTS-1:actConflictConfiguration=false


@{NRADJGNB_1}
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNodeBId=35
...    NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mcc=311
...    NRADJGNB-1:gnbPlmn:mnc=489
...    NRADJGNB-1:gnbPlmn:mncLength=3


@{XNLINK_1}
...    XNLINK-1:cPlaneIpAddr=10.0.1.122
...    XNLINK-1:cPlaneIpAddrCtrl=oamControlled

@{fault_7311}    fault_id=7311    fault_name=No Xn link available

${hex_wrongReponse_B007_1}    2011005F000004004B001000000000C80064F02000004020D143A5000E00090064F02050000007D70013002E0000000034
${hex_wrongReponse_B007_2}    0064F020000007D7100000C80064F020410007B5A60000002809C00C1030F891C5020081EC00680010000400050064F02002
${hex_wrongReponse}    ${hex_wrongReponse_B007_1}${hex_wrongReponse_B007_2}


*** Test Cases ***
5GC000637-ET-B001_Xn_Setup_Request_received_from_peer_gNB
    [Documentation]
    ...    [Purpose]: The purpose of this case is to verify whether the Xn Link can be setup successfully.
    ...    It also covered E002 to to verify whether Xn reset would be successful 
    [Tags]    QC_60619    B001
    Lock NRADJGNB1
    Unlock NRADJGNB1
    Xn link should be availabe
    Check Wireshark Logs    B001


5GC000637-ET-B002_Xn_Setup_Failure_received_with_no_served_cell
    [Documentation]
    ...    [Purpose]: The purpose of this case is to verify the Xn link will be unavailable when one cell is locked.
    ...               	
    [Tags]    QC_253378    B002
    Lock NRADJGNB1
    Set gNB3 simulator with no served cell
    Unlock NRADJGNB1
    Check Wireshark Logs    B002
    Recovery
    Lock NRADJGNB1
    Unlock NRADJGNB1
	
5GC000637-ET-B004_Xn_Setup_Failure_received_with_gNB_is_in_locked_state
    [Documentation]
    ...    [Purpose]: The purpose of this case is to verify the Xn link will be unavailable when one gNB is locked.
    [Tags]    QC_60609   B004
    Lock NRADJGNB1
    Set gNB3 simulator in locked state
    Unlock NRADJGNB1
    Check Wireshark Logs    B004
    Recovery
    Lock NRADJGNB1
    Unlock NRADJGNB1

5GC000637-ET-B005_SCTP_link_shutdown_due_to_shutdownNoXnTrafficTmr_Expiries
    [Documentation]
    ...    [Purpose]: The purpose of this case is to check if sctp shutdown after maxNumXnSetupRetry completed
    ...     and shutdownNoXnTrafficTmr expiries.
    [Tags]    QC_253371    B005
    Lock NRADJGNB1
    Set maxNumXnSetupRetry and shutdownNoXnTrafficTmr value
    gNB simulator command by setting the gNB sim with XnSetup failure
    Unlock NRADJGNB1
    Check Wireshark Logs    B005
    Recovery maxNumXnSetupRetry and shutdownNoXnTrafficTmr value
    Recovery
    Lock NRADJGNB1
    Unlock NRADJGNB1
	
5GC000637-ET-B006_Xn_Setup_but with_no_answer_received_from_peer_gNB
    [Documentation]
    ...    [Purpose]: The purpose of this case is to verify the Xn link will be unavailable when the peer gNB has no answer.
    ...    It also covered D002 to check whether the alarm will appear when Xn link is unavailable
    ...    It also covered D003 to check whether the alarm will disappear when Xn link is available
    ...    It also covered E003 to verify whether Xn reset would be successful when no answer from peer gNB.
    [Tags]    QC_60611    B006
    Set retryXnSetupTmr and xnSetupRespTmr value
    gNB simulator command by setting the peer gNB with no answer received
    Lock NRADJGNB1
    Unlock NRADJGNB1
    fm fault should be raised    ${fault_7311}
    Check Wireshark Logs    B006
    Recovery
    Lock NRADJGNB1
    Unlock NRADJGNB1
    fm fault should be cleared    ${fault_7311}	

5GC000637-ET-B007_Xn_Setup_but with_Xn_Setup_Reponse_is_not_accepted
    [Documentation]
    ...    [Purpose]: The purpose of this case is to receive a Xn Setup Response but can't accept it then
    ...     send an error indiction to peer gNB.
    [Tags]    QC_253370    B007
    Lock NRADJGNB1
    gNB simulator command by setting the gNB sim with an unacceptable response
    Unlock NRADJGNB1
    Check Wireshark Logs    B007
    Recovery
    Unlock NRADJGNB1
	
*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    #---------------------------------------------------------------------------------------------------
    # 5GCN CONFIGURATION
    #---------------------------------------------------------------------------------------------------
    Update Cfg    set_amf_region id=1 tac_list=7627107,100,788,200,258,0 plmn=311:489	
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    Update Cfg    set_upf id=1 daemon=10.0.2.1:22222 type=simulated addr=1.2.4.1/24 ngu=10.0.1.1
    Update Cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=off
    Update Cfg    set_backup_amf main=1 backup_amfs=2
    Update Cfg    set_nwslice id=1 snssai=0x01:13714341 default=on ue=1-6 amf=1-3
    #---------------------------------------------------------------------------------------------------
    # GNB CONFIGURATION
    #---------------------------------------------------------------------------------------------------
    ${cmd_1}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2
    ...    gnb_id=0x76C daemon=10.0.2.1:22222 xn=10.0.1.2 x2_peers=none amf=1-3 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${cmd_1}
    #sim gnb3
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb3}
    Update Cfg    ${set_gnb3_cell1}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false


Unlock NRADJGNB1
    BuiltIn.Log    Unlock NRADJGNB1...     console=${True}
    Delta Commission Parameters    NRADJGNB-1:administrativeState=Unlocked

Lock NRADJGNB1
    BuiltIn.Log    Lock NRADJGNB1...     console=${True}
    Delta Commission Parameters    NRADJGNB-1:administrativeState=Locked
	
Xn link should be availabe
    BuiltIn.Log    Xn link should be availabe...     console=${True}
    Object Should Exist    XNLINK-1:xnLinkStatus=available
	
Set gNB3 simulator with no served cell
    BuiltIn.Log    Set gNB3 simulator with no served cell...     console=${True}
    Execute Egate Command    gnb_xn_setup_param id=3 action=force_failure nth=1 time_to_wait=v10s cause=cell_not_available	

Set gNB3 simulator in locked state
    BuiltIn.Log    Set gNB3 simulator in locked state...     console=${True}
    Execute Egate Command    gnb_xn_setup_param id=3 action=force_failure nth=1 time_to_wait=v10s cause=o_and_M_intervention

Check Wireshark Logs
    BuiltIn.Log    Check Wireshark Logs...     console=${True}
    [Arguments]    ${case_id}=B001
    check wireshark log    ${CURDIR}${/}a2a_${case_id}${/}a2a.ini
	
Recovery
    BuiltIn.Log    Recovery...     console=${True}
    Execute Egate Command    gnb_xn_setup_param id=3 reset
	
Set maxNumXnSetupRetry and shutdownNoXnTrafficTmr value
    BuiltIn.Log    Set maxNumXnSetupRetry and shutdownNoXnTrafficTmr value...     console=${True}
    ${params}    create list    MRBTS-1/NRBTS-1:maxNumXnSetupRetry=1    MRBTS-1/NRBTS-1:shutdownNoXnTrafficTmr=0
    Delta Commission Parameters    ${params}  
	
gNB simulator command by setting the gNB sim with XnSetup failure
    BuiltIn.Log    gNB simulator command by setting the gNB sim with XnSetup failure...     console=${True}
    Execute Egate Command    gnb_xn_setup_param id=3 action=force_failure nth=1 ntimes=10 time_to_wait=v10s
	
Recovery maxNumXnSetupRetry and shutdownNoXnTrafficTmr value
    BuiltIn.Log    Recovery maxNumXnSetupRetry and shutdownNoXnTrafficTmr value...     console=${True}
    ${params}    create list    MRBTS-1/NRBTS-1:maxNumXnSetupRetry=3    MRBTS-1/NRBTS-1:shutdownNoXnTrafficTmr=1
    Delta Commission Parameters    ${params} 

Set retryXnSetupTmr and xnSetupRespTmr value
    BuiltIn.Log    Set retryXnSetupTmr and xnSetupRespTmr value...     console=${True}
    ${params}    create list    MRBTS-1/NRBTS-1:retryXnSetupTmr=5    MRBTS-1/NRBTS-1:xnSetupRespTmr=10
    Delta Commission Parameters    ${params}

gNB simulator command by setting the peer gNB with no answer received
    BuiltIn.Log    gNB simulator command by setting the peer gNB with no answer received for B006...     console=${True}
    Execute Egate Command    gnb_xn_setup_param id=3 action=drop nth=1 ntimes=12

gNB simulator command by setting the gNB sim with an unacceptable response
    BuiltIn.Log    gNB simulator command by setting the gNB sim with an unacceptable response for B007...     console=${True}
    Execute Egate Command    gnb_xn_setup_param id=3 action=override_resp hex=${hex_wrongReponse}