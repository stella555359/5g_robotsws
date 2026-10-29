*** Settings ***
Documentation
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CIT    CDRT    team-DevHZ5_SG2
...    owner-xianjiao.xie    release-5G20A    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC002478_case001}
...    @{amf2}
...    @{xn_gnbcontroll}
...    @{NRADJGNB_0}
...    @{XNLINK_0}
...    @{params_Update_maxNumOfNgRanConfigUpdRetries_and_ngSetupRespTmr}
...    MRBTS-1/NRBTS-1:actEnhancedNgRanSupport=true

#7101 alarm: gNB CpCell configuration update failure, when Ran Conf Update By AMF is ignore,
#...    the fault will raised, not test point here,so excluded it
#@{FAULTS_EXCLUDED_CHECKING}    7101    7523

@{5GC002478_case001}
...    @{feature740flag_enable}
...    @{Ue_retention_enable}
...    @{RecovBeforeBarringTimer}
...    @{NGCellDeactDelayTimer}

@{amf2}
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:amfIPAddress=10.0.1.9
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true

@{xn_gnbcontroll}
...    MRBTS-1/NRBTS-1:actIncXn=true
...    MRBTS-1/NRBTS-1:actConflictConfiguration=true

@{NRADJGNB_0}
...    NRADJGNB-10:administrativeState=Unlocked
...    NRADJGNB-10:gNodeBId=35
...    NRADJGNB-10:gNbIdLength=22
...    NRADJGNB-10:xnLinkRef=10
...    NRADJGNB-10:gnbPlmn:mcc=311
...    NRADJGNB-10:gnbPlmn:mnc=489
...    NRADJGNB-10:gnbPlmn:mncLength=3

@{XNLINK_0}
...    XNLINK-10:cPlaneIpAddr=10.0.1.122


@{feature740flag_enable}
...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true

@{Ue_retention_enable}
...    MRBTS-1/NRBTS-1:ngUeRetentionEnabled=true
@{RecovBeforeBarringTimer}
...    MRBTS-1/NRBTS-1:waitForRecovBeforeCellBarringTimer=30
@{NGCellDeactDelayTimer}
...    MRBTS-1/NRBTS-1:ngInducedCellDeactDelayTimer=60


@{params_lock_cells}
...    NRCELL-1:administrativeState=Locked
...    NRCELL-2:administrativeState=Locked

@{params_unlock_cells}
...    NRCELL-1:administrativeState=Unlocked
...    NRCELL-2:administrativeState=Unlocked

${ue_id}    1
${ue_id2}    31

${maxNumOfNgRanConfigUpdRetries}    7
${ngSetupRespTmr}    1
${TIME_OF_SENDING_RAN_CONF_UPD_MESSAGES}    8

@{params_Update_maxNumOfNgRanConfigUpdRetries_and_ngSetupRespTmr}
...    MRBTS-1/NRBTS-1:maxNumOfNgRanConfigUpdRetries=${maxNumOfNgRanConfigUpdRetries}
...    MRBTS-1/NRBTS-1:ngSetupRespTmr=${ngSetupRespTmr}


@{PM_Counters_CIT001}
...    MRBTS-1/NRBTS-1:NNGCB:${NG_CU_RAN_CONFIG_UPD_NO_RSP}=8

${NG_CU_RAN_CONFIG_UPD_NO_RSP}    M55119C00024     #The number of No RSP for RAN configuration Update

*** Test Cases ***
5GSW-CP-Regression_For_Fault7101
    [Documentation]
    ...    This case is to verify Fault 7101 will not raise when all of the cells locked/unlock
    ...    when actEnhancedNgRanSupport=true
    [Tags]    QC_50595
    FOR    ${index}    IN RANGE    0    10
        Delta Commission Parameters    ${params_lock_cells}
        Delta Commission Parameters    ${params_unlock_cells}
        Sleep    10s    #maxNumOfNgRanConfigUpdRetries * ngSetupRespTmr
        Fm Fault Should Not Exist    fault_id=7101
        SA and NSA call should be successful
    END

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    #---------------------------------------------------------------------------------------------------
    # 5GCN CONFIGURATION
    #---------------------------------------------------------------------------------------------------
    Update Cfg    set_amf_region id=1 tac_list=7627107,100,788,200,258,0 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=7627107,100,788,200,258,0 plmn=311:489
    Update Cfg    set_amf_region id=3 tac_list=7627107,100,788,200,258,0 plmn=311:489
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2 name=SimModeAMF1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.9:38412 region=2 set_id=2 pointer=2 name=SimModeAMF2
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.10:38412 region=3 set_id=2 pointer=2 name=SimModeAMF3
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    Update Cfg    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    Update Cfg    amf_param id=3 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    Update Cfg    set_upf id=1 daemon=10.0.2.1:22222 type=simulated addr=1.2.4.1/24 ngu=10.0.1.1
    Update Cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=off
    Update Cfg    amf_ng_setup_param id=2 relative_capacity=100
    Update Cfg    amf_ng_setup_param id=3 relative_capacity=100
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
    #sim gnb5
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=16:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb5}
    Update Cfg    ${set_gnb5_cell1}
    Update Cfg    gnb_param id=5 xn_listening_socket=on send_xn_setup=true
    #---------------------------------------------------------------------------------------------------
    # add CIT005
    #---------------------------------------------------------------------------------------------------
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.0.3 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.0.4 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.0.5 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.0.6 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

Lock Unlock Cells and Xn link
    All link avaiable and Cells on air
    SA and NSA call should be successful
    Lock Cells and Xn Link then Unlock Xn and Cells
    All link avaiable and Cells on air
    SA and NSA call should be successful
    Remove Xn and Add Xn by GNB controll
    All link avaiable and Cells on air
    #SA and NSA call should be successful
    Trigger NSA Call and SA Call by Five Times

Setup Xn and all links and Cells On Air
    Execute Egate Command    enb_x2_link_up enb=1 target=2    GNB-3: XnAP Link with GNB-2
    Wait Until Keyword Succeeds    20 min    10 sec    All link avaiable and Cells on air

All link avaiable and Cells on air
    Object Should Exist    SERVEDAMF-1:ngLinkStatus=Active
    Object Should Exist    SERVEDAMF-2:ngLinkStatus=Active
    Object Should Exist    XNLINK:xnLinkStatus=available
    Object Should Exist    LTEENB:x2LinkStatus=available

Remove Xn and Add Xn by GNB controll
    ${params_delete_Xn}    create list    delete:NRADJGNB-10    delete:XNLINK-10
    Delta Commission Parameters    ${params_delete_Xn}
    Execute Egate Command    gnb_xn_link_up gnb=5 target=2    GNB-5: XnAP Link with GNB-2

Remove Xn and Add Xn by OAM controll
    ${params_delete_Xn}    create list    delete:NRADJGNB-10    delete:XNLINK-10
    Delta Commission Parameters    ${params_delete_Xn}
    ${params_add_Xn}    create list    ${NRADJGNB_0}    ${XNLINK_0}
    Delta Commission Parameters    ${params_add_Xn}

Lock Cells and Xn Link then Unlock Xn and Cells
    Delta Commission Parameters    ${params_lock_cells}
    Delta Commission Parameters    NRADJGNB-10:administrativeState=Locked
    Delta Commission Parameters    NRADJGNB-10:administrativeState=Unlocked
    Delta Commission Parameters    ${params_unlock_cells}

Setup X2 and all links and Cells On Air
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
    Wait Until Keyword Succeeds    20 min    10 sec    All link avaiable and Cells on air

Lock Unlock Cells and NG link
    Lock Cells and Lock NG Link SERVEDAMF2 then Remove SERVEDAMF2
    Add SERVEDAMF2 with locked state and new ip
    Unlock NG Link SERVEDAMF2 and Unlock Cells
    SA and NSA call should be successful
    Lock Cells and Lock NG Link SERVEDAMF2 then Remove SERVEDAMF2
    Add SERVEDAMF2 with locked state and old ip
    Unlock NG Link SERVEDAMF2 and Unlock Cells
    SA and NSA call should be successful

Lock Cells and Lock NG Link SERVEDAMF2 then Remove SERVEDAMF2
    Delta Commission Parameters    ${params_lock_cells}
    Delta Commission Parameters    SERVEDAMF-2:administrativeState=Locked
    Delta Commission Parameters    delete:SERVEDAMF-2

Add SERVEDAMF2 with locked state and new ip
    Delta Commission Parameters    SERVEDAMF-2:amfIPAddress=10.0.1.10

Unlock NG Link SERVEDAMF2 and Unlock Cells
    Delta Commission Parameters    SERVEDAMF-2:administrativeState=Unlocked
    Delta Commission Parameters    ${params_unlock_cells}
    Sleep    300s    #EDA has this step
    Setup X2 and all links and Cells On Air

Add SERVEDAMF2 with locked state and old ip
    Delta Commission Parameters    SERVEDAMF-2:amfIPAddress=10.0.1.9

SA and NSA call should be successful
    sa ue register and pdu setup    ue_id=1
    Traffic Should Be OK    ue_id=1    type=sa
    nsa ue register    ue_id=31
    Traffic Should Be OK    ue_id=31    type=nsa
    release ues    ue_type=all

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    QoS Routing Table

nsa ue register
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    reported successful RA

LOOP Five Times
    FOR    ${index}    IN RANGE    0    5
        ${ue1}    Evaluate    ${ue_id}+${index}
        sa ue register and pdu setup    ${ue1}
        traffic should be ok    ue_id=${ue1}    type=SA
        ${ue2}    Evaluate    ${ue_id2}+${index}
        nsa ue attach successful    ${ue2}
        traffic should be ok    ${ue2}    type=NSA
        Detach UEs    ${ue2}    ${ue1}
    END

Trigger NSA Call and SA Call by Five Times
    FOR    ${num}    IN RANGE    0    5
       LOOP Five Times
    END

nsa ue attach successful
    [Arguments]    ${id}    ${target_cells}=1    ${cmd_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    ${cmd_regexp}

Detach UEs
    [Arguments]    ${id2}    ${id}
    Execute Egate Command    ue_deregister id=${id} ue_deregister_type=switch_off    Received UE Context Release Complete
    Execute Egate Command    ue_detach id=${id2}    UE IS OFF
    sleep    5s

Delete AMF-2
    BuiltIn.Log    Delete AMF2...     console=${True}
    Delta Commission Parameters    delete:SERVEDAMF-2

Update maxNumOfNgRanConfigUpdRetries and ngSetupRespTmr
    BuiltIn.Log    Update maxNumOfNgRanConfigUpdRetries=7 and ngSetupRespTmr=1...     console=${True}
    Delta Commission Parameters    ${params_Update_maxNumOfNgRanConfigUpdRetries_and_ngSetupRespTmr}

Ignore Ran Conf Update By AMF
    BuiltIn.Log    Ignore Ran Conf Update By AMF...    console=${True}
    Execute Egate Command    amf_ran_config_update_param id=1 action=ignore ntimes=indefinite

