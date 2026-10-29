*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-DevHZ5_SG2
...  owner-xianjiao.xie    release-5G19A    
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
...    NRADJGNB-1:administrativeState=Locked
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


*** Test Cases ***
5GC000637_ET_B001_Xn_Setup_Request_received_from_peer_gNB
	[Documentation]
    ...    [Purpose]: The purpose of this case is to verify whether the Xn Link can be setup successfully.
	[Tags]  QC_xxxxxx    B001
	Start To Capture Wireshark Log
	Unlock NRADJGNB1
	Xn link should be availabe
	Check Wireshark Logs  B001


5GC000637-ET-B002_Xn_Setup_Failure_received_with_no_served_cell
    [Documentation]
    ...    [Purpose]: The purpose of this case is to verify the Xn link will be unavailable when one cell is locked.
	[Tags]  QC_xxxxxx    B002
	Lock NRADJGNB1
	Set gNB3 simulator with no served cell
	Unlock NRADJGNB1
	Check Wireshark Logs  B002
	Recovery
	

5GC000637-ET-B004_Xn_Setup_Failure_received_with_gNB_is_in_locked_state
    [Documentation]
    ...    [Purpose]: The purpose of this case is to verify the Xn link will be unavailable when one gNB is locked.
	[Tags]  QC_xxxxxx    B004
	Lock NRADJGNB1
	Set gNB3 simulator in locked state
	Unlock NRADJGNB1
	Check Wireshark Logs  B004
	Recovery

	
*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

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