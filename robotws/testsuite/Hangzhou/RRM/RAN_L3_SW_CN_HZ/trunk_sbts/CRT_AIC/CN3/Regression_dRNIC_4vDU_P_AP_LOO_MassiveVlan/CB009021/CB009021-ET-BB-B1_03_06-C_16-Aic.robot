*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 4Du
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    vDUCNF00    RAN_Aic    RAN_5G    CRT    CLOUD_5GC_dRNIC_4vDU_P_AP_LOO_DC_MassiveVlan
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_4CPIF_HA    team-CN3ET    owner-xiujuan.sun    release-SBTS24R2
Resource    ../../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/4du/2cells
${REDUNDANT_MODE_CU_FLAG}    True
@{PARAMS_IN_SCF_CU}    @{Three_ServedAMF}
${GNB_BIP_FLAG}    True
${SOS_REPORT_FLAG}    pass:False,fail:True
${SNAPSHOT_FLAG}    pass:False,fail:True
${AP_BIP_FLAG}    True
${TTITRACE_FLAG}    True

@{PARAMS_IN_SCF_DU1}
...    MRBTS-1/NRBTS-1/NRDU-1:remotef1CplaneIpAddr=172.16.1.101

@{PARAMS_IN_SCF_DU2}
...    MRBTS-1/NRBTS-1/NRDU-2:remotef1CplaneIpAddr=172.16.1.102

@{PARAMS_IN_SCF_DU3}
...    MRBTS-1/NRBTS-1/NRDU-3:remotef1CplaneIpAddr=172.16.1.103

@{PARAMS_IN_SCF_DU4}
...    MRBTS-1/NRBTS-1/NRDU-4:remotef1CplaneIpAddr=172.16.1.104
${MULTI_CPIF_FLAG}    True
@{rrcReestabTypeSAEqualSameGNB}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tRLFindForDUSA=300ms
@{Three_ServedAMF}
...    NRBTS/SERVEDAMF-2:amfIPAddress=10.0.11.2
...    NRBTS/SERVEDAMF-3:amfIPAddress=10.0.11.3
...    NRBTS/SERVEDAMF-4:amfIPAddress=10.0.11.4
...    MRBTS-1/NRBTS-1:actIncXn=True
${fault7313}    fault_id=7313
${NG_CU_SETUP_REQUEST_SENT}    M55119C00001
${NG_SHUTDOWN_LOCKED}    M55119C00501
${NG_CU_SETUP_RESPONSE_RCV}    M55119C00002

@{C-16_Counter}
...    NRBTS-1:${NG_CU_SETUP_REQUEST_SENT}>=6
...    NRBTS-1:${NG_CU_SETUP_REQUEST_SENT}<=9
...    NRBTS-1:${NG_SHUTDOWN_LOCKED}=5
...    NRBTS-1:${NG_CU_SETUP_RESPONSE_RCV}=4

${NG_CU_RESET_REQ_SENT}    M55119C00011
${NG_CU_RESET_ACK_RCV}    M55119C00014
${E1_RESET_SENT_CUCP}    M55121C00501
${E1_RESET_ACK_RECD_CUCP}    M55121C00502
${X2_UEREL_OUT_PARTIAL_RESET}    M55110C00028
${X2_PARTIAL_RESET_REQUIRED_SENT}    M55110C00031
${X2_PARTIAL_RESET_CONF_RCVD}    M55110C00032
${F1_CU_P_RESET_MSG_ATT}    M55150C00008
${F1_CU_P_RESET_MSG_SUCC}    M55150C00009

@{BB-B1-03_Counter}
...    NRBTS-1:${NG_CU_RESET_REQ_SENT}=4
...    NRBTS-1:${NG_CU_RESET_ACK_RCV}=4
...    NRBTS-1:${E1_RESET_SENT_CUCP}=4
...    NRBTS-1:${E1_RESET_ACK_RECD_CUCP}=4
...    NRBTS-1:${X2_UEREL_OUT_PARTIAL_RESET} =4
...    NRBTS-1:${X2_PARTIAL_RESET_REQUIRED_SENT} =4
...    NRBTS-1:${X2_PARTIAL_RESET_CONF_RCVD}=4
...    NRDU-1:${F1_CU_P_RESET_MSG_ATT} =1
...    NRDU-1:${F1_CU_P_RESET_MSG_SUCC} =1
...    NRDU-2:${F1_CU_P_RESET_MSG_ATT} =1
...    NRDU-2:${F1_CU_P_RESET_MSG_SUCC}=1
...    NRDU-3:${F1_CU_P_RESET_MSG_ATT} =1
...    NRDU-3:${F1_CU_P_RESET_MSG_SUCC}=1
...    NRDU-4:${F1_CU_P_RESET_MSG_ATT} =1
...    NRDU-4:${F1_CU_P_RESET_MSG_SUCC}=1

@{3NG_Link_active_but_AMF4_Inactive}
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:ngLinkStatus=Active
...    MRBTS-1/NRBTS-1/SERVEDAMF-4:ngLinkStatus=Inactive

*** Test Cases ***
CB009021-CR-BB-B1_ET_03_CPCL triggered partial reset in multi-CP-IF scenario
    [Tags]    BB-B1_03
    [Documentation]    This test case is to verify CU triggered F1 reset can be handled correctly in multi CPIF case.
    Clear Counter Files Cu Aic
    Create SAs and NSAs on each CElls
    Lock 4 Cells
    Check no active SA UEs
    Check Counters Cu Aic    ${BB-B1-03_Counter}
    Check WireShark Log Aic for 4 CPIFs
    [Teardown]    Unlock NRCELL and do Common Case teardown

CB009021-CR-BB-B1_ET_06_UE RRC reestablishment to inter-DU different cell
    [Tags]    BB-B1_06
    [Documentation]    This test case is to verify UE RRE to different cell inside gNB can be handled correctly in multi CPIF case.
    Clear Counter Files Cu Aic
    Delta Commission Parameters Cu    ${rrcReestabTypeSAEqualSameGNB}
    Create 6 SAs to each Cells
    SAs do RRE fallback to differet CPIFs Should be successfully
    Release Ues    ue_type=all
    [Teardown]    Wait RLF timeout and do Common Case teardown

CB009021-CR-C_ET_16_M55119C00001_and_M55119C00501_and_M55119C00002 shall be handled correctly in multi-cpif scenario
    [Tags]    C016
    [Documentation]    M55119C00501: NG_SHUTDOWN_LOCKED
    ...    M55119C00001: NG_CU_SETUP_REQUEST_SENT
    ...    M55119C00002: NG_CU_SETUP_RESPONSE_RCV
    ...    M55119C00501: NG_SHUTDOWN_LOCKED
    Clear Counter Files Cu Aic
    Set AMF4 not Response NG SetupRequest
    Lock 4 NG links
    Unlock 4 NG links
    Check All NG links are available except AMF4
    # fault 7318 will raise after ngSetupRespTmr=60s
    ${fault7318}    Create List    fault_id=7318    fault_name=NG Setup no response
    fm fault should be raised cu    ${fault7318}
    # lock ng link, fault 7318 will not cleared
    Disable NG Link4
    sleep    60s
    fm fault should be cleared cu    fault_id=7318
    Unlock 4 NG links
    fm fault should be raised cu    ${fault7318}
    # set AMF4 response NG setuprequest and unlock ng link
    Execute Egate Command    amf_ng_setup_param id=22 reset
    Enable NG Link4
    fm fault should be cleared cu    fault_id=7318
    Check Counters Cu Aic    ${C-16_Counter}

*** Keywords ***
Modify Cfg Aic
    ${v1}    catenate    set_enb id=100 plmn=311:489 s1=10.0.1.150 enb_id_macro=0x00013 daemon=$SERVER_IP:$EDAEMON_PORT
    ...    x2=10.0.1.150 x2u=10.0.1.150 type=simulated x2_peers=none
    ${v2}    catenate    set_cell id=1 enb=100 eci=0x0001301 pci=3:2 tac=222 proxy=10.0.2.90:12219|10.0.2.90:8889
    ...    earfcn=2000:20000 mapped_earfcn=4200:22200
    Update Cfg Aic    ${v1}
    Update Cfg Aic    enb_param id=100 drb_id_begin=3 endc_capable_qci=all
    Update Cfg Aic    ${v2}
    Update Cfg Aic    enb_endc_param id=100 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7

    ${v3}    catenate    set_enb id=101 plmn=311:489 s1=10.0.1.149 enb_id_macro=0x00014 daemon=$SERVER_IP:$EDAEMON_PORT x2=10.0.1.149
    ...    x2u=10.0.1.149 type=simulated x2_peers=none
    ${v4}    catenate    set_cell id=1 enb=101 eci=0x0001401 pci=3:2 tac=222 proxy=10.0.2.91:12219|10.0.2.91:8889
    ...    earfcn=2000:20000 mapped_earfcn=4200:22200
    Update Cfg Aic    ${v3}
    Update Cfg Aic    enb_param id=101 drb_id_begin=3 endc_capable_qci=all
    Update Cfg Aic    ${v4}
    Update Cfg Aic    enb_endc_param id=101 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7

    ${v5}    catenate    set_enb id=102 plmn=311:489 s1=10.0.1.148 enb_id_macro=0x00015 daemon=$SERVER_IP:$EDAEMON_PORT
    ...    x2=10.0.1.148 x2u=10.0.1.148 type=simulated x2_peers=none
    ${v6}    catenate    set_cell id=1 enb=102 eci=0x0001501 pci=3:2 tac=222 proxy=10.0.2.92:12219|10.0.2.92:8889
    ...    earfcn=2000:20000 mapped_earfcn=4200:22200
    Update Cfg Aic    ${v5}
    Update Cfg Aic    enb_param id=102 drb_id_begin=3 endc_capable_qci=all
    Update Cfg Aic    ${v6}
    Update Cfg Aic    enb_endc_param id=102 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7

    ${v7}    catenate    set_gnb id=2 type=external plmn=311:489 ng=10.0.11.10,10.0.11.11,10.0.11.12,10.0.11.13 gnb_id=0x01:22
    ...    daemon=$SERVER_IP:$EDAEMON_PORT xn=10.0.12.10,10.0.12.11,10.0.12.12,10.0.12.13 s1u=$GNB_S1U_ADDR
    ...    x2=10.0.1.10,10.0.1.11,10.0.1.12,10.0.1.13 x2u=$GNB_X2U_ADDR x2_peers=none amf=1,20,21,22
    Update Cfg Aic    ${v7}

    ${v8}    catenate    amf_param id=20 reg_procedure_sequence=parallel_init_ctx_setup_req_and_reg_accept
    ...    full_nas_auth=on nia=null+zuc+aes+snow3g nea=null
    ${v9}    catenate    set_upf id=20 daemon=$SERVER_IP:$EDAEMON_PORT ngu=10.0.11.2 dnn=wap2.nokia.com
    ...    devtype=tun devname=tunUPF7 addr=10.12.8.1/24
    Update Cfg Aic    set_amf_region id=20 tac_list=200,280,300,400,500,600 plmn=311:489
    Update Cfg Aic    set_amf id=20 daemon=$SERVER_IP:$EDAEMON_PORT ng=10.0.11.2:38412 region=20 set_id=20 pointer=1
    Update Cfg Aic    ${v8}
    Update Cfg Aic    ${v9}

    ${v10}    catenate    amf_param id=21 reg_procedure_sequence=parallel_init_ctx_setup_req_and_reg_accept
    ...    full_nas_auth=on nia=null+zuc+aes+snow3g nea=null
    ${v11}    catenate    set_upf id=21 daemon=$SERVER_IP:$EDAEMON_PORT ngu=10.0.11.3 dnn=wap2.nokia.com
    ...    devtype=tun devname=tunUPF8 addr=10.12.9.1/24

    Update Cfg Aic    set_amf_region id=21 tac_list=200,280,300,400,500,600 plmn=311:489
    Update Cfg Aic    set_amf id=21 daemon=$SERVER_IP:$EDAEMON_PORT ng=10.0.11.3:38412 region=21 set_id=21 pointer=1
    Update Cfg Aic    ${v10}
    Update Cfg Aic    ${v11}

    ${v12}    catenate    amf_param id=22 reg_procedure_sequence=parallel_init_ctx_setup_req_and_reg_accept
    ...    full_nas_auth=on nia=null+zuc+aes+snow3g nea=null
    ${v13}    catenate    set_upf id=22 daemon=$SERVER_IP:$EDAEMON_PORT ngu=10.0.11.4 dnn=wap2.nokia.com
    ...    devtype=tun devname=tunUPF9 addr=10.12.10.1/24
    Update Cfg Aic    set_amf_region id=22 tac_list=200,280,300,400,500,600 plmn=311:489
    Update Cfg Aic    set_amf id=22 daemon=$SERVER_IP:$EDAEMON_PORT ng=10.0.11.4:38412 region=22 set_id=22 pointer=1
    Update Cfg Aic    ${v12}
    Update Cfg Aic    ${v13}

    Update Cfg Aic    sim_trace enb=1 protocol=x2 on
    Update Cfg Aic    sim_trace enb=100 protocol=x2 on
    Update Cfg Aic    sim_trace enb=101 protocol=x2 on
    Update Cfg Aic    sim_trace enb=102 protocol=x2 on

    Update Cfg Aic    set_nwslice id=1 snssai=0x01:13714341 amf=1,20,21,22 default=on ue=all

Set AMF4 not Response NG SetupRequest
    Execute Egate Command    amf_ng_setup_param id=22 gnb=2 request_ignore=on action=ignore nth=1 ntimes=32

Create 6 SAs to each Cells
    Set AMF Configuration Update before UE register
    ${amf1_index}    ${sa1_ueID}    ${amf1_ngap_id}    Register For Normal Call and create PDU Successfully to Specific AMF
    ...    ue_id=25    cell_id=1    specified_amfstr=311:489|1:1:1
    ${amf1_index}    ${sa1_ueID}    ${amf1_ngap_id}    Register For Normal Call and create PDU Successfully to Specific AMF
    ...    ue_id=26    cell_id=2    specified_amfstr=311:489|20:20:1
    ${amf1_index}    ${sa1_ueID}    ${amf1_ngap_id}    Register For Normal Call and create PDU Successfully to Specific AMF
    ...    ue_id=27    cell_id=3    specified_amfstr=311:489|21:21:1
    ${amf1_index}    ${sa1_ueID}    ${amf1_ngap_id}    Register For Normal Call and create PDU Successfully to Specific AMF
    ...    ue_id=28    cell_id=4    specified_amfstr=311:489|22:22:1
    ${amf1_index}    ${sa1_ueID}    ${amf1_ngap_id}    Register For Normal Call and create PDU Successfully to Specific AMF
    ...    ue_id=29    cell_id=1    specified_amfstr=311:489|1:1:1
    ${amf1_index}    ${sa1_ueID}    ${amf1_ngap_id}    Register For Normal Call and create PDU Successfully to Specific AMF
    ...    ue_id=30    cell_id=4    specified_amfstr=311:489|22:22:1


SAs do RRE fallback to differet CPIFs Should be successfully
    Execute Egate Command    ue_rrc_reestablish id=25 gnb=2 cell=2 cause=otherFailure
    ...    pass_regexp=Initial Context Setup Successful for UE
    Execute Egate Command    ue_rrc_reestablish id=26 gnb=2 cell=3 cause=otherFailure
    ...    pass_regexp=Initial Context Setup Successful for UE
    Execute Egate Command    ue_rrc_reestablish id=27 gnb=2 cell=4 cause=otherFailure
    ...    pass_regexp=Initial Context Setup Successful for UE
    Execute Egate Command    ue_rrc_reestablish id=28 gnb=2 cell=1 cause=otherFailure
    ...    pass_regexp=Initial Context Setup Successful for UE

    Execute Egate Command    ue_rrc_reestablish id=29 gnb=2 cell=3 cause=otherFailure action=invalid_short_mac_i
    ...    pass_regexp=Initial Context Setup Successful for UE
    Execute Egate Command    ue_rrc_reestablish id=30 gnb=2 cell=1 cause=otherFailure action=invalid_crnti
    ...    pass_regexp=Initial Context Setup Successful for UE

Check WireShark Log Aic for 4 CPIFs
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}${/}A2A_BB1-03${/}a2a.ini    wait_string=procedureCode: id-Reset::10
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}${/}A2A_BB1-03${/}a2a1.ini    wait_string=procedureCode: id-Reset::2    pod_name_cu=cpifa1
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}${/}A2A_BB1-03${/}a2a2.ini    wait_string=procedureCode: id-Reset::2    pod_name_cu=cpifa2
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}${/}A2A_BB1-03${/}a2a3.ini    wait_string=procedureCode: id-Reset::2    pod_name_cu=cpifa3

Lock 4 Cells
    Lock Cell1
    Lock Cell2
    Lock Cell3
    Lock Cell4

Create SAs and NSAs on each CElls
    set_4_x2_link_up
    Set AMF Configuration Update before UE register
    Create 4 SAs with F1 and NG are handled by each CPIFs
    Create 4 NSAs with X2 link are handled by each CPIFs

Create 4 SAs with F1 and NG are handled by each CPIFs
    ${amf1_index}    ${sa1_ueID}    ${amf1_ngap_id}    Register For Normal Call and create PDU Successfully to Specific AMF
    ...    ue_id=1    cell_id=4    specified_amfstr=311:489|1:1:1
    ${amf2_index}    ${sa2_ueID}    ${amf2_ngap_id}    Register For Normal Call and create PDU Successfully to Specific AMF
    ...    ue_id=20    cell_id=3    specified_amfstr=311:489|20:20:1
    ${amf3_index}    ${sa3_ueID}    ${amf3_ngap_id}    Register For Normal Call and create PDU Successfully to Specific AMF
    ...    ue_id=21    cell_id=2    specified_amfstr=311:489|21:21:1
    ${amf4_index}    ${sa4_ueID}    ${amf4_ngap_id}    Register For Normal Call and create PDU Successfully to Specific AMF
    ...    ue_id=22    cell_id=1    specified_amfstr=311:489|22:22:1
    Set Test Variable for SA calls    ${sa1_ueID}    ${amf1_ngap_id}    ${sa2_ueID}    ${amf2_ngap_id}    ${sa3_ueID}
    ...    ${amf3_ngap_id}    ${sa4_ueID}    ${amf4_ngap_id}

Set Test Variable for SA calls
    [Arguments]    ${sa1_ueID}    ${amf1_ngap_id}    ${sa2_ueID}    ${amf2_ngap_id}    ${sa3_ueID}    ${amf3_ngap_id}
    ...    ${sa4_ueID}    ${amf4_ngap_id}
    Set Test Variable    ${sa1_ueID}    ${sa1_ueID}
    Set Test Variable    ${amf1_ngap_id}    ${amf1_ngap_id}
    Set Test Variable    ${sa2_ueID}    ${sa2_ueID}
    Set Test Variable    ${amf2_ngap_id}    ${amf2_ngap_id}
    Set Test Variable    ${sa3_ueID}    ${sa3_ueID}
    Set Test Variable    ${amf3_ngap_id}    ${amf3_ngap_id}
    Set Test Variable    ${sa4_ueID}    ${sa4_ueID}
    Set Test Variable    ${amf4_ngap_id}    ${amf4_ngap_id}

Create 4 NSAs with X2 link are handled by each CPIFs
    ${ue32_MeNB_X2APID}    ${ue32_sgNB_X2APID}    Attach And Set ENDC For UE and Return X2APID    ue_id=32    target_gnbCell=1    enb_id=1
    ${ue33_MeNB_X2APID}    ${ue33_sgNB_X2APID}    Attach And Set ENDC For UE and Return X2APID    ue_id=33    target_gnbCell=2    enb_id=100
    ${ue34_MeNB_X2APID}    ${ue34_sgNB_X2APID}    Attach And Set ENDC For UE and Return X2APID    ue_id=34    target_gnbCell=3    enb_id=101
    ${ue35_MeNB_X2APID}    ${ue35_sgNB_X2APID}    Attach And Set ENDC For UE and Return X2APID    ue_id=35    target_gnbCell=4    enb_id=102
    Set Test Variable    ${ue32_sgNB_X2APID}    ${ue32_sgNB_X2APID}
    Set Test Variable    ${ue33_sgNB_X2APID}    ${ue33_sgNB_X2APID}
    Set Test Variable    ${ue34_sgNB_X2APID}    ${ue34_sgNB_X2APID}
    Set Test Variable    ${ue35_sgNB_X2APID}    ${ue35_sgNB_X2APID}

Set AMF Configuration Update before UE register
    Execute Egate Command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1 relative_capacity=50 amfi=1:1:1
#    ...    pass_regexp=Received AMF Configuration Acknowledge
    Execute Egate Command    amf_config_update id=20 name=SimModeAMF20 plmn=311:489 nwslice=1 relative_capacity=100 amfi=20:20:1
#    ...    pass_regexp=Received AMF Configuration Acknowledge
    Execute Egate Command    amf_config_update id=21 name=SimModeAMF21 plmn=311:489 nwslice=1 relative_capacity=50 amfi=21:21:1
#    ...    pass_regexp=Received AMF Configuration Acknowledge
    Execute Egate Command    amf_config_update id=22 name=SimModeAMF22 plmn=311:489 nwslice=1 relative_capacity=100 amfi=22:22:1
#    ...    pass_regexp=Received AMF Configuration Acknowledge

set_4_x2_link_up
    Execute Egate Command    enb_x2_link_up enb=1 target=2 x2_link_addr=10.0.1.10    pass_regexp=is up    timeout=120
    Execute Egate Command    enb_x2_link_up enb=100 target=2 x2_link_addr=10.0.1.11    pass_regexp=is up    timeout=120
    Execute Egate Command    enb_x2_link_up enb=101 target=2 x2_link_addr=10.0.1.12    pass_regexp=is up    timeout=120
    Execute Egate Command    enb_x2_link_up enb=102 target=2 x2_link_addr=10.0.1.13    pass_regexp=is up    timeout=120

Lock 4 NG links
    Disable NG Link1
    Disable NG Link2
    Disable NG Link3
    Disable NG Link4

Unlock 4 NG links
    ${unlock_nglinks_param}    Create List    SERVEDAMF-4:administrativeState=Unlocked    SERVEDAMF-3:administrativeState=Unlocked
    ...    SERVEDAMF-2:administrativeState=Unlocked    SERVEDAMF-1:administrativeState=Unlocked
    Delta Commission Parameters Cu    ${unlock_nglinks_param}

Check All NG links are available except AMF4
    Object Should Exist In Cu    ${3NG_Link_active_but_AMF4_Inactive}

Register For Normal Call and create PDU Successfully to Specific AMF
    [Arguments]    ${ue_id}    ${cell_id}    ${specified_amfstr}
    [return]    ${amf_index}    ${sa_ueID}    ${amf_ngap_id}
    Set Registered AMF To Ue    ue_id=${ue_id}    registered_amf=${specified_amfstr}
    ${amf_index}    ${sa_ueID}    ${amf_ngap_id}    Register For Normal Call Successfully without modify Establishemnt cause    ${ue_id}    ${cell_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    UE PDU Session Setup    ${ue_id}    ${ue_id}

Register For Normal Call Successfully without modify Establishemnt cause
    [Arguments]    ${ue_id}    ${cell_id}    ${enb_id}=2
    [Return]    ${amf_index}    ${sa_ueID}    ${amf_ngap_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    ${amf_index}    ${sa_ueID}    ${amf_ngap_id}    UE Register To GNB    ${ue_id}

Attach And Set ENDC For UE and Return X2APID
    [Arguments]    ${ue_id}    ${target_gnbCell}    ${enb_id}
    [Return]    ${MeNB_x2apIDList[0]}    ${sgNB_x2apIDList[0]}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=1
    UE Attach To ENB    ${ue_id}
    ${command}    Set Variable    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_gnbCell} bearer=2 type=split_scg
    ${output}    Execute Egate Command    ${command}    pass_regexp=reported successful RA
    ${MeNB_x2apIDList}    Get Regexp Matches    ${output}    value UE-X2AP-ID : (\\d+)    1
    ${sgNB_x2apIDList}    Get Regexp Matches    ${output}    value SgNB-UE-X2AP-ID : (\\d+)    1

Set Registered AMF To Ue
    [Arguments]    ${ue_id}=1    ${registered_amf}=${EMPTY}
    execute egate command    ue_nr_rrc_param_setup id=${ue_id} registered_amf=${registered_amf}

UE Register To GNB
    [Arguments]    ${ue_id}
    [Return]    ${matchecd_groups}[0][0]    ${matchecd_groups}[0][1]    ${matchecd_groups}[0][2]
    ${output}    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg
    ${filter_string}    catenate
    ...    AMF-(\\d+): UE with RAN UE NGAP ID (\\d+) and AMF UE NGAP ID (\\d+) is now Registered
    ${matchecd_groups}    Get Regexp Matches    ${output}    ${filter_string}    1    2    3

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${gw_id}=1
    [return]    ${AMF_UE_NGAP_ID_UE[0]}    ${RAN_UE_NGAP_ID_UE[0]}
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table
    ${AMF_UE_NGAP_ID_UE}    Get Regexp Matches    ${ret1}    AMF_UE_NGAP_ID=(\\d+)    1
    ${RAN_UE_NGAP_ID_UE}    Get Regexp Matches    ${ret1}    RAN_UE_NGAP_ID=(\\d+)    1

UE Attach To ENB
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE

Unlock NRCELL and do Common Case teardown
    Unlock Four NRCELLs
    Set Test Variable    ${FAULTS_EXCLUDED_CHECKING}    7313
    Common Test Teardown And Stop Capture Logs Aic

Wait RLF timeout and do Common Case teardown
    sleep    30s    wait for RLF timeout and origin UEs is released
    Common Test Teardown And Stop Capture Logs Aic

Unlock Four NRCELLs
    Unlock Cell1
    Unlock Cell2
    Unlock Cell3
    Unlock Cell4

Check no active SA UEs
    ${active_ue_list}    Get Active Ue
    List Should Not Contain Value    ${active_ue_list}    1
    List Should Not Contain Value    ${active_ue_list}    20
    List Should Not Contain Value    ${active_ue_list}    21
    List Should Not Contain Value    ${active_ue_list}    22

