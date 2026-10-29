*** Settings ***
Suite Setup     Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup      Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...        team-DevHZ5_SG1    owner-carol.an    release-SBTS23R1
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/3cells_ecpri
${uplane_6878}    0x5901AB=1
@{PARAMS_IN_SWCONFIG}
...    ${rdPCsiPoolHkfPeriod_min}
...    ${rdHkfMinPCsiResPerSlot}
...    ${rdHkfMinPCsiRepPeriod}
...    ${rdHkfPCsiPoolMaxRCUsFactor}
...    ${uplane_6878}
...    ${rdPCsiPoolHkfRate_millisec}
#...    ${rdEnableTrafficManager}
#...    ${rdEnableUeIdRangeAllocationViaSdl}
#...    ${rdEnableUeMappingRemovalFromCpIf}
...    @{l2psRD}

@{l2psRD}
...    0x58057b=16842887
...    0x58057c=278396928
...    0x58057d=606077441
...    0x58057e=2

${rdPCsiPoolHkfRate_millisec}    0x5901B2=3000
${rdPCsiPoolHkfPeriod_min}    0x5901A6=2
${rdHkfMinPCsiResPerSlot}    0x5901A7=8
${rdHkfMinPCsiRepPeriod}    0x5901A8=40
${rdHkfPCsiPoolMaxRCUsFactor}    0x5901A9=6
${rdEnableTrafficManager}    0x89001C=0
${rdEnableUeIdRangeAllocationViaSdl}    0x89001D=0
${rdEnableUeMappingRemovalFromCpIf}    0x89001E=1

@{PARAMS_IN_SCF}
...    @{ueInactivityTimer}
...    @{CB008962}
...    @{PMcounter}

@{CB008962}    NRBTS:actNsaSlice=true
...    NRBTS/NRDRB_QCI-98:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-6
...    NRBTS/NRDRB_QCI-98:qciValueList=98
...    NRBTS/NRNWSLICE_NSA-1:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRNWSLICE_NSA-1:operatorSpecificQCIList=98
...    NRBTS/NRNWSLICE_NSA-1:s1Uplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

@{ueInactivityTimer}
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=600

@{PMcounter}
...    NRPMRNL-1:miNrX2CB=15min

@{Counters_A_B3_1}
...    ${X2_UEREL_INC_PARTIAL_RESET}=1
...    ${X2_PARTIAL_RESET_CONFIRM_SENT}=1

${X2_UEREL_INC_PARTIAL_RESET}    M55110C00027
${X2_PARTIAL_RESET_CONFIRM_SENT}    M55110C00030

*** Test Cases ***
CB008926-SR-A-B3_ET_01_06_X2 link reset with invalid X2AP ID can be handled correctly in clssical Gnb
    [Tags]    AB3-6
    [Documentation]    Trigger X2 Link reset with below:
    ...    1st 1st UE: invalid MeNB X2APID + valid SgNB X2APID of UE1
    ...    2nd UE: valid MeNB X2APID of UE2 + invalid SgNB X2APID(invalid X2AP ID in the Range of CPUE)
    ...    3rd UE: invalid MeNB X2APID + invalid SgNB X2APID(invalid X2AP ID out the range of CPUE)
    ${invalid_ue31_MeNB_X2APID}    ${ue31_sgNB_X2APID}    NSA UE1 X2 reset with invalid X2AP ID
    ${ue32_MeNB_X2APID}    ${invalid_ue32_sgNB_X2APID}    ${ue32_sgNB_X2APID}    NSA UE2 X2 reset with invalid X2AP ID
    ${inv_ue33_MeNB_X2APID}    ${invalid_ue33_sgNB_X2APID}    NSA UE3 X2 reset with invalid X2AP ID
    Set Test Variable    ${invalid_ue31_MeNB_X2APID}    ${invalid_ue31_MeNB_X2APID}
    Set Test Variable    ${ue31_sgNB_X2APID}    ${ue31_sgNB_X2APID}
    Set Test Variable    ${ue32_MeNB_X2APID}    ${ue32_MeNB_X2APID}
    Set Test Variable    ${invalid_ue32_sgNB_X2APID}    ${invalid_ue32_sgNB_X2APID}
    Set Test Variable    ${inv_ue33_MeNB_X2APID}    ${inv_ue33_MeNB_X2APID}
    Check WireShark Log    ${CURDIR}${/}a2a_CB008926-A_B3_06${/}a2a.ini    wait_string=ENDCPartialResetConfirm::4
    Check RRc Log    ${CURDIR}${/}a2a_CB008926-A_B3_06${/}a2a.ini
    Release Ues    ue_type=all

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

UE Register To GNB
    [Arguments]    ${ue_id}    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg

PDU session setup on UE
    [Arguments]    ${ue}=1    ${pdu}=1    ${gw}=1    ${nwslice}=1    ${cmd_pdu_regexp}=QoS Routing Table    #
    ${gw}    Evaluate    ${ue}+${pdu}-1
    ${cmd_pdu_param}    Catenate    set_pdu_param ue=${ue} pdu=${pdu} trf_type=internal
    ${cmd_pdu_session}    Catenate    ue_pdu_session_setup ue=${ue} pdu=${pdu} nwslice=${nwslice} gw=${gw}
    Execute Egate Command    ${cmd_pdu_param}
    ${ret1}=    Execute Egate Command    ${cmd_pdu_session}    pass_regexp=${cmd_pdu_regexp}
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi 5 qfi 1

NSA UE setup and X2 partial reset
    [Return]    ${ue31_MeNB_X2APID}    ${ue31_sgNB_X2APID}
    ${ue31_MeNB_X2APID}    ${ue31_sgNB_X2APID}    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=31    target_gnbCell=1
    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=32    target_gnbCell=1
    ${Preset}=    Execute Egate Command    link_x2_reset from=1 to=2 ue=31    pass_regexp=ENDCPartialResetConfirm
    Should Contain    ${Preset}    Bearer-type change from SCG-split to MCG is successful
    Should Not Contain    ${Preset}    detached

NSA UE ICS and setup ENDC to TargetGnbCell
    [Arguments]    ${ue_id}    ${target_gnbCell}
    [Return]    ${MeNB_x2apIDList[0]}    ${sgNB_x2apIDList[0]}
    UE Attach To ENB    ${ue_id}
    ${output}    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_gnbCell} bearer=2 type=split_scg
    ...    pass_regexp=reported successful RA
    ${MeNB_x2apIDList}    Get Regexp Matches    ${output}    value UE-X2AP-ID : (\\d+)    1
    ${sgNB_x2apIDList}    Get Regexp Matches    ${output}    value SgNB-UE-X2AP-ID : (\\d+)    1
    Execute Egate Command    ue_disp

UE Attach To ENB
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE

NSA UE1 X2 reset with invalid X2AP ID
    [Return]    ${invalid_ue31_MeNB_X2APID}    ${ue31_sgNB_X2APID}
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up
    ${ue31_MeNB_X2APID}    ${ue31_sgNB_X2APID}    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=31    target_gnbCell=1
    ${invalid_ue31_MeNB_X2APID}    Evaluate     ${ue31_MeNB_X2APID}+50
    Execute Egate Command    ue_disp
    ${ue1reset}=    Execute Egate Command    link_x2_reset from=1 to=2 include_ues_to_be_reset=${invalid_ue31_MeNB_X2APID}:${ue31_sgNB_X2APID}
    ...    pass_regexp=ENDCPartialResetConfirm
    Should Contain    ${ue1reset}    meNB-ID ${invalid_ue31_MeNB_X2APID}
    sleep    5s    wait for endc partial reset finished UE1.
    Execute Egate Command    ue_disp
    Set Test Variable    ${invalid_ue31_MeNB_X2APID}    ${invalid_ue31_MeNB_X2APID}
    Set Test Variable    ${ue31_sgNB_X2APID}    ${ue31_sgNB_X2APID}

NSA UE2 X2 reset with invalid X2AP ID
    [Return]    ${ue32_MeNB_X2APID}    ${invalid_ue32_sgNB_X2APID}    ${ue32_sgNB_X2APID}
    ${ue32_MeNB_X2APID}    ${ue32_sgNB_X2APID}    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=32    target_gnbCell=1
    ${invalid_ue32_sgNB_X2APID}    Evaluate     ${ue32_sgNB_X2APID}+100
    ${ue2reset}=    Execute Egate Command    link_x2_reset from=1 to=2 include_ues_to_be_reset=${ue32_MeNB_X2APID}:${invalid_ue32_sgNB_X2APID}
    ...    pass_regexp=ENDCPartialResetConfirm
    Should Contain    ${ue2reset}    sgNB-ID ${invalid_ue32_sgNB_X2APID}
    sleep    5s    wait for endc partial reset finished UE2.
    Execute Egate Command    ue_disp
    Set Test Variable    ${ue32_MeNB_X2APID}    ${ue32_MeNB_X2APID}
    Set Test Variable    ${invalid_ue32_sgNB_X2APID}    ${invalid_ue32_sgNB_X2APID}

NSA UE3 X2 reset with invalid X2AP ID
    [Return]    ${inv_ue33_MeNB_X2APID}    ${invalid_ue33_sgNB_X2APID}
    ${ue33_MeNB_X2APID}    ${ue33_sgNB_X2APID}    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=33    target_gnbCell=1
    ${inv_ue33_MeNB_X2APID}    Evaluate     ${ue33_MeNB_X2APID}+100
    ${invalid_ue33_sgNB_X2APID}    Evaluate     ${ue33_sgNB_X2APID}+4294000000
    ${ue3reset}=    Execute Egate Command    link_x2_reset from=1 to=2 include_ues_to_be_reset=${inv_ue33_MeNB_X2APID}:${invalid_ue33_sgNB_X2APID}
    ...    pass_regexp=ENDCPartialResetConfirm
    Should Contain    ${ue3reset}    sgNB-ID ${invalid_ue33_sgNB_X2APID}
    sleep    5s    # RLF waite for enb send ErrorIndication
    Execute Egate Command    ue_disp
    Set Test Variable    ${inv_ue33_MeNB_X2APID}    ${inv_ue33_MeNB_X2APID}
    Set Test Variable    ${invalid_ue33_sgNB_X2APID}    ${invalid_ue33_sgNB_X2APID}
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up
