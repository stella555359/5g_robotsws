*** Settings ***
Documentation
...    author: Zhou Lingyan
...    contact: lingyan.zhou@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-CLOUD_5G_I_LO_AP_LO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=20    maxNumOfDRBL2Pool=30    maxNumOfGBRL2Pool=12    guaranteedResourceRatioPerCell=40

@{FAULTS_EXCLUDED_CHECKING}    7300

#UE CAPE
${ue_nr_capabilities}    SEPARATOR=
...    E1A03FA0474E7AEFFFFFAFC2200782E0203C127BE7FFFFF800F00C6FBE00050370101F8E0155DF0A3FE2F08762F82087F540A083D951D2206
...    24FAC41E420F081425BE7E57771DF001DDC77C000CC005000742AEF851FF17843B17C1043FAA05041ECA8E9103127D620F2107840A12DF3F3
...    3BB8EF800EEE3BE000660028003A1577C4DFF8BC21D8BE0821FD502820F65474881893EB1079083C205096F9F95DFC7FC0077F1FF00033001
...    4001D00650389A000000C40A83C4D000C2680004C40AC1C4D080004620540E268400033102B070A0200021881507850001828000298810090
...    0A2026C04605000C2508206811B649F0214285B24F810236C93E04085B24F810276C93E042853B649F000160C318C631BFFFE000138036002
...    800301C1401C0C4270070007000603E0488200000041000002208004000004100080000882001004001040020080220800402008410008040
...    188200100C021040020180601B072F2A2B072F2A28060800004B2CA82000032CB2A0800014B2CA02000072CB2801A83D5D2AAAA0F174AA283
...    839804F9BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C0
...    700001400600400C010020808020040200801001C0180180400300A00A01801001C0180380400700A01201802001C0380180800301200A028
...    01041C0080180100300400A0080103801001004002004004010001AB0602072125262728770000000361781C06000601A

${OOO_UE_Capabilities}    SEPARATOR=
...    E1A03000074E5A031E0003832001E09306400043C2400C4034026010180E01951B0A3582028680965944C2403D6C10101070EF1C39061C001
...    03278FAB80027800E0009E00151B133582028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B1375820286
...    80965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C2403D6C10101070EF1C39061C0010
...    3278FAA8000028000000841C4D000000002026878003804044F613003000281C1401C0C026007000683E0000000000000E54D000100000965
...    950034AAA84801C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA1288A0

#check msg
@{UE_in_RRC_CONNECTED_state}
...    RrcState: NR CONNECTED
...    UE now in NG RM Registered state
*** Test Cases ***
CB008195-B-31-Verify Unsucessful SA GBR DRB admission static cell limits check with maxNumOfGBRBearersSA reach maxquota IWK rrc resume
    [Documentation]
    ...    Precondition:
    ...     UE1: PLMN-1:311489_slice=2000
    ...     UE2: PLMN-1:311489_slice=2000
    ...     UE3: PLMN-1:311489_slice=2000
    ...     UE4: PLMN-1:311489_slice=2000
    ...    Test Steps:
    ...    Step 1: SA UE1 attach to NRCELL-1, PDU setup with 5QI-5(NonGBR), add 5QI-4(GBR)
    ...    Step 2: SA UE2 attach to NRCELL-1, PDU setup with 5QI-5(NonGBR), add 5QI-4(GBR)
    ...    Step 3: SA UE3 attach to NRCELL-1, PDU setup with 5QI-5(NonGBR), add 5QI-4(GBR) failed as radio resource not available.
    ...    Step 4: wait SA UE1 to RRC inactive state,
    ...    Step 5: SA UE4 attach to NRCELL-1, PDU setup with 5QI-5(NonGBR), add 5QI-4(GBR) successfully
    ...    Step 6/7: send traffic on UE2 and UE4 for GBR bearers successfully.
    ...    Step 8:UE1 RRC resume failed as no GBR resource
    ...    Step 9: Online change to disable 8195 GBR check
    ...    Step 10/11: UE1 RRC resume successfully and send traffic on UE1 for GBR bearer.
    [Tags]    B031   QC_123955
    Clear Counter Files    wait=${True}
	OnlineParamChange    ${OnlineParamChange_CB008195_GBRCheckOn}
	SA UE Register and ICS PDU    ue_id=1    nwslice=2000
	sleep    10s
    UE SA Attach To Target Cell And Start Traffic    ue_id=2    nwslice=2000
	UE SA Attach To Target Cell And Add GBR Failure with No Resource    ue_id=3    nwslice=2000
	Wait Until Keyword Succeeds    8s    1s    Execute Egate Command    ue_disp id=1    pass_regexp=UE1: Is INACTIVE
    UE SA Attach To Target Cell And Start Traffic    ue_id=4    nwslice=2000
    Send Traffic For UE On GBR    ue_id=2
	Send Traffic For UE On GBR    ue_id=4
	UE RRC Resume    ue_id=1    result=RRC Reject was received
	OnlineParamChange    ${OnlineParamChange_CB008195_GBRCheckOff}
	UE RRC Resume    ue_id=1    result=QoS Routing Table
	Send Traffic For UE On GBR    ue_id=1
    Check Counters    ${CELL_COUNTER}

*** Keywords ***
Modify Cfg
    Set PDU Session in WTS
    Set AMF config
    Set UE config
    Set QosFlow

Set AMF config
    Update Cfg    set_amf_region id=1 tac_list=100,200,300 plmn=311:489
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2 name=SimModeAMF1
    Update Cfg    amf_ng_setup_param id=1 relative_capacity=10 include_backup_amf_name=on ue_retention=on retention_time=indefinite
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a6 amf=1 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=3 snssai=0x01:0xd143a7 amf=1 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=4 snssai=0x01:0xd143a9 amf=1 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=2000 snssai=0x01:0xd143a8 amf=1 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all

Set PDU Session in WTS
    Update Cfg    qosrule_set id=1 proto=tcp qos_flow=1
    Update Cfg    qosrule_set id=2 proto=udp qos_flow=2

Set QosFlow
    Update Cfg    set_qosflow id=1 5qi=1 priority=1 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=2 5qi=2 priority=2 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=3 5qi=3 priority=3 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=4 5qi=4 priority=4 pci=shall_not_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg    set_qosflow id=5 5qi=5 default=on priority=5 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=6 5qi=6 priority=6 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=7 5qi=7 priority=7 pci=shall_not_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=8 5qi=8 priority=8 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=9 5qi=9 priority=9 pci=may_trigger_pre_emption pvi=not_pre_emptable
	Update Cfg    qosflow_modify qos_flow=4 gfbr_dl=280 gfbr_ul=280
	Update Cfg    qosflow_modify qos_flow=4 mfbr_dl=2800 mfbr_ul=2800
Set UE config
    Update Cfg    ue_nr_capabilities id=1-19 voice_over_nr=on:on:off
    Update Cfg    ue_param id=1-19 nr_usage_setting=voice_centric ue_nr_capabilities=${ue_nr_capabilities}
    Update Cfg    ue_param id=2,4 ue_nr_capabilities=${OOO_UE_Capabilities}


OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

SA UE Register and ICS PDU
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=1    ${nwslice}=1    ${qos_flow}=5
    ...    ${plmn}=489    ${pdu}=1
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:${plmn} tac_id=200
    Execute Egate Command    ${cmd}
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    UE Register To GNB    ue_id=${ue_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    UE PDU Session Setup    ue_id=${ue_id}    nwslice=${nwslice}    pdu=${pdu}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=4    QoS Routing Table

UE Register To GNB
    [Arguments]    ${ue_id}=1    ${nwslice}=1
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ue_register id=${ue_id} nwslice=${nwslice}    pass_regexp=${UE_in_RRC_CONNECTED_state}

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${pdu}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${ue_id}    QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi 5 qfi 1

UE SA Attach To Target Cell And Add GBR Failure with No Resource
    [Arguments]    ${cell_id}=1    ${ue_id}=1    ${nwslice}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=${nwslice}    QoS Routing Table
    Sleep    2s    # in order to make peak counter pegged
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=4
    Should Contain    ${ret1}    PDU SESSION RESOURCE MODIFY RESPONSE Modify Item with cause 22
    Release Ues    ue_id=3

UE RRC Resume
    [Arguments]    ${ue_id}=1    ${result}=UE performed resume procedure
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    ${result}

UE SA Attach To Target Cell And Start Traffic
    [Arguments]    ${cell_id}=1    ${ue_id}=81    ${nwslice}=1    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=${nwslice}    QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=4    QoS Routing Table

Send Traffic For UE On GBR
    [Arguments]    ${ue_id}=81    ${pcell_dl}=0.9
    Send Throuput    ue_id=${ue_id}    mbps=1
    Verify Throuput on Pcell    ue_id=${ue_id}    pcell_dl=${pcell_dl}

Send Throuput
    [Arguments]    ${ue_id}=81    ${qfi}=2    ${mbps}=10    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl mbps=${mbps} trf_id=2    UE ${ue_id}: UDP DL
    sleep    1s    #sleep for stable traffic

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=0.9
    sleep    10s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
