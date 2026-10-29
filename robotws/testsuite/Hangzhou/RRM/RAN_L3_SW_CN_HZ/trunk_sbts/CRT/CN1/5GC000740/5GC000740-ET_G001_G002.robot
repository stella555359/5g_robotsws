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
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=1500
@{AMF1_AMF2_Unlocked}
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:defaultAMF=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true
@{AMF2_Locked}
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Locked
@{AMF2_Unlocked}
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
${AMF_SELECTION_ATT}    M55155C00001
${AMF_SELECTION_FAIL}    M55155C00002
${AMF_SELECTION_SUCC}    M55155C00003
@{PM_Counters_G001_1st}
...    NRCELL-1:${AMF_SELECTION_ATT}==1
...    NRCELL-1:${AMF_SELECTION_FAIL}==0
...    NRCELL-1:${AMF_SELECTION_SUCC}==1
@{PM_Counters_G001_2nd}
...    NRCELL-1:${AMF_SELECTION_ATT}==1
...    NRCELL-1:${AMF_SELECTION_FAIL}==0
...    NRCELL-1:${AMF_SELECTION_SUCC}==1

*** Test Cases ***
5GC000740-ET-G001_Verify_Successful_AMF_re-allocation_after_old_AMF_be_selected_with_UE_provides_the_5G-S-TMSI
    [Tags]   QC_60782
	clear counter files
	Update AMF status
	Update AMF Parameters G001
	AMF2 Locked
	ue register to amf success    1    1    1    AMF-1: Initial Context Setup Successful
	AMF2 Unlocked
	check counters    ${PM_Counters_G001_1st}
	clear counter files
	UE Exit Idle after redirect    1
	check counters    ${PM_Counters_G001_2nd}
	UE Deregister    1

5GC000740-ET-G002_Verify_AMF_re-allocation_failed_due_to_new_AMF_send_message_with_old_AMF_IE_set_to_itself
    [Tags]    QC_60780
    Update AMF status
	Update AMF Parameters G002
	AMF2 redirect mesg to AMF1
    DL NAS message from AMF1 sent to GNB
	UE Register to Amf Failed    5    RRC Release
	Release Ues    ue_type=all
	Check Wireshark Log    ${CURDIR}${/}A2A_G002${/}a2a.ini    wait_string=UEContextRelease::2

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
	${match_string}    Create List    AMF-1: AMF - IP:10.0.1.2 NG link is Up    AMF-2: AMF - IP:10.0.1.2 NG link is Up
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    match_string=${match_string}
	#Debug Enter Into Egate

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

AMF2 Locked
    Delta Commission Parameters    ${AMF2_Locked}
    Cells Should Be Onair    check_sib=${False}
	Check ngLinkStatus Inactive

AMF2 Unlocked
    Delta Commission Parameters    ${AMF2_Unlocked}
    Cells Should Be Onair    check_sib=${False}
	Check ngLinkStatus Active

Check ngLinkStatus Active
    ${params}    create list    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active
    Wait Until Keyword Succeeds    2min    10sec    Object Should Exist    ${params}

Check ngLinkStatus Inactive
    ${params}    create list    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Inactive
	Wait Until Keyword Succeeds    2min    10sec    Object Should Exist    ${params}

Update AMF Parameters G001
	Execute Egate Command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=50 amfi=1:1:1
	...    Received AMF Configuration Acknowledge from GNB-2
	Execute Egate Command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=1:1:2
	...    Received AMF Configuration Acknowledge from GNB-2

Update AMF Parameters G002
	Execute Egate Command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1 relative_capacity=100 amfi=1:1:1
	...    Received AMF Configuration Acknowledge from GNB-2
	Execute Egate Command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=1:2:1
	...    Received AMF Configuration Acknowledge from GNB-2

ue register to amf success
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}    ${pass_regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
	Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
	Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${gw_id}    pass_regexp=${pass_regexp}

UE Exit Idle after redirect
    [Arguments]    ${ue_id}
	Execute Egate Command    ue_ng_ctx_release id=${ue_id} cause=NAS_normal_release    IS IDLE
	Execute Egate Command    amf_param id=1 if=rcvd_initial_ue_msg action=redirect:2
	${ret}    Execute Egate Command	   ue_im_exit id=${ue_id}    Initial UE Message Success for AMF Redirect
	Should Contain    ${ret}    Reauthentication procedure is starting
	sleep    5s    #wait idle mode exit procedure finish

AMF2 redirect mesg to AMF1
	Execute Egate Command    amf_param id=2 full_nas_auth=off if=rcvd_initial_ue_msg action=redirect:1

DL NAS message from AMF1 sent to GNB
	Execute Egate Command    amf_dl_nas_transport_param id=1 include_old_amf_name=eq_to_target
	Execute Egate Command    amf_ue_ics_param id=1 include_old_amf_name=eq_to_target

UE Register to Amf Failed
    [Arguments]    ${ue_id}    ${pass_regexp}
	Execute Egate Command    ue_register id=${ue_id} nwslice=1,2,3    pass_regexp=${pass_regexp}

