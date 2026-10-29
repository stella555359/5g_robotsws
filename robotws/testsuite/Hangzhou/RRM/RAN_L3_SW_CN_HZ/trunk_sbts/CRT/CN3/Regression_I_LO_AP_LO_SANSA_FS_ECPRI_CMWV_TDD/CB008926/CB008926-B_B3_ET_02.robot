*** Settings ***
Suite Setup     Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup      Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT_no_cloud    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...        team-DevHZ5_SG1    owner-carol.an    release-SBTS23R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/3cells_ecpri
@{PARAMS_IN_SWCONFIG}
#...    ${rdEnableTrafficManager}
#...    ${rdEnableUeIdRangeAllocationViaSdl}
#...    ${rdEnableUeMappingRemovalFromCpIf}

${rdEnableTrafficManager}    0x89001C=1
${rdEnableUeIdRangeAllocationViaSdl}    0x89001D=1
${rdEnableUeMappingRemovalFromCpIf}    0x89001E=1

@{PARAMS_IN_SCF}
...    @{CB008962}
...    @{CB008926}

@{CB008962}
...    NRBTS:actNsaSlice=true
...    NRBTS/NRDRB_QCI-98:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-6
...    NRBTS/NRDRB_QCI-98:qciValueList=98
...    NRBTS/NRNWSLICE_NSA-1:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRNWSLICE_NSA-1:operatorSpecificQCIList=98
...    NRBTS/NRNWSLICE_NSA-1:s1Uplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

@{CB008926}
...    NRBTS:cuUeIdToLinkMappingUpdateDelay=500ms

*** Test Cases ***
CB008926-SR-B-B3_ET_01_02_SgNB release request without SgNB X2AP ID can be handled correctly in classical gNB
    [Tags]
    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=31    target_gnbCell=1
    SgNB release without SgNB X2AP ID
    Release Ues    ue_type=all
    Check WireShark Log    ${CURDIR}${/}a2a_CB008926-B_B3_02${/}a2a.ini    wait_string=UEContextReleaseCommand::2

*** Keywords ***
Common Suite Setup And Setup IPHY Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up

Modify Cfg
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=98
    Update Cfg    qci_set qci=98 gbr=no priority=9 delay=300    #get error KeyError: 'id' ,please add it manual
    Set Bear in WTS
    Set PDU Session in WTS
    Set Sim gNB
    Update Cfg    set_bearer id=2 ue=31 qci=98 pdn=1 ip=4.7.254.208 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    Update Cfg    set_bearer id=2 ue=32 qci=98 pdn=1 ip=4.7.254.232 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    Update Cfg    set_bearer id=2 ue=33 qci=98 pdn=1 ip=4.7.254.233 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    Update Cfg    set_bearer id=2 ue=34 qci=98 pdn=1 ip=4.7.254.234 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1-2 default=on qos_flows=3,2,1 qos_rules=1,2 ue=all
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc

Set Sim gNB
    ${cfg_cmd_1}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 s1u=10.0.1.124 ng=10.0.1.123
    ...    gnb_id=0x24:22 daemon=10.0.2.1:22222 x2=10.0.1.126:36422 x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1

    ${cfg_cmd_2}    catenate
    ...    gnb_param id=3 x2_listening_socket=1 measEvent=A3
    ${cfg_cmd_3}    catenate
    ...    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    ${cfg_cmd_4}    catenate
    ...    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666 gscn=7880
    Update Cfg    ${cfg_cmd_1}
    Update Cfg    ${cfg_cmd_3}
    Update Cfg    ${cfg_cmd_4}

Set Bear in WTS
    ${cfg_cmd_3}    catenate
    ...    ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    FOR    ${ue_id}    IN RANGE    32    56
        Update Cfg    set_bearer id=2 ue=${ue_id} qci=9 pdn=1 ip=4.7.254.2${ue_id} default=on ${cfg_cmd_3}
        Update Cfg    set_bearer id=3 ue=${ue_id} qci=8 default=off
    END

Set PDU Session in WTS
    ${cfg_cmd}    catenate
    ...    qos_flows=3,2,1 qos_rules=1,2 ue=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=6 default=off
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    qosrule_set id=1 proto=tcp qos_flow=1
    Update Cfg    qosrule_set id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ${cfg_cmd}
    FOR    ${ue_id}    IN RANGE    2    31
        Update Cfg    set_pdu_gateway id=${ue_id} ue_nat_ip=72.23.0.${ue_id} dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    END

NSA UE ICS and setup ENDC to TargetGnbCell
    [Arguments]    ${ue_id}    ${target_gnbCell}
    UE Attach To ENB    ${ue_id}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_gnbCell} bearer=2 type=split_scg
    ...    pass_regexp=reported successful RA
    Execute Egate Command    ue_disp

UE Attach To ENB
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE

SgNB release without SgNB X2AP ID
    Execute Egate Command    enb_ue_dc_release ue=31 by=enb cause=RN_load_balancing exclude_sgnb_ue_x2ap_id=true
    ...    pass_regexp=Bearer-type change from SCG-split to MCG is successful
