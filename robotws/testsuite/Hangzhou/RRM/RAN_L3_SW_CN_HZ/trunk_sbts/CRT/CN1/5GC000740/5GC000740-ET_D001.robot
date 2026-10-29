*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Test Teardown with AMF Reset
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD   CRT
...    owner-yuhua.zhu    team-SG2    release-5G20A    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:amfIPAddress=10.0.1.102
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true
...    MRBTS-1/NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-2:sd=13714342
...    MRBTS-1/NRBTS-1/SNSSAI-2:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/SNSSAI-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-3:sd=13714343
...    MRBTS-1/NRBTS-1/SNSSAI-3:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:defaultAMF=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=15min
@{AMF1_AMF2_Unlocked}
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:defaultAMF=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true

*** Test Cases ***
5GC000740-ET-D001_Verify_NGAP_AMF_Configuration_update_successfully_with_multi_AMFs
    [Tags]    QC_60759
	Update AMF status
    Update AMF Parameters D001
    ue register to amf success    1    1    1    AMF-1: Initial Context Setup Successful
	ue register to amf success    2    2    2    AMF-1: Initial Context Setup Successful
	Update AMF Parameters D001_2
	ue register to amf success    3    3    3    AMF-2: Initial Context Setup Successful
	Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
	${match_string}    Create List    AMF-1: AMF - IP:10.0.1.2 NG link is Up    AMF-2: AMF - IP:10.0.1.2 NG link is Up
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    match_string=${match_string}
	#Debug Enter Into Egate

Modify Cfg
	Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2
	Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=2
	Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
	Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=1 set_id=2 pointer=2
	Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=1 set_id=1 pointer=2
	Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=1 set_id=1 pointer=1

Test Teardown with AMF Reset
    Execute Egate Command    amf_param id=1 reset
	Execute Egate Command    amf_param id=2 reset
    Common Test Teardown And Stop Capture Logs

UE Deregister
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=: detached    timeout=65s

Update AMF status
    Delta Commission Parameters    ${AMF1_AMF2_Unlocked}
    Cells Should Be Onair    check_sib=${False}
	Check ngLinkStatus Active

Check ngLinkStatus Active
    ${params}    create list    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active
    Wait Until Keyword Succeeds    2min    10sec    Object Should Exist    ${params}

Update AMF Parameters D001
    Execute Egate Command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1 relative_capacity=10 amfi=1:1:1,1:1:2
	...    Received AMF Configuration Acknowledge from GNB-2
	Execute Egate Command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1 relative_capacity=0 amfi=1:1:1,1:1:2
	...    Received AMF Configuration Acknowledge from GNB-2

Update AMF Parameters D001_2
    Execute Egate Command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2 relative_capacity=0 amfi=1:1:1,1:1:2,1:1:3
	...    Received AMF Configuration Acknowledge from GNB-2
	Execute Egate Command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2 relative_capacity=10 amfi=1:1:1,1:1:2,1:1:4
	...    Received AMF Configuration Acknowledge from GNB-2

ue register to amf success
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}    ${pass_regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
	Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
	Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${gw_id}    pass_regexp=${pass_regexp}


