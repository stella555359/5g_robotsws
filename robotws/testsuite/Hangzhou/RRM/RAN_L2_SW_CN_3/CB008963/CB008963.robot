# @Time    : 2024/12/6 10:41
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB008963.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: NSB MN RAN RD VRF HAZ3 5
...    Feature CB008963-SR GBR Services for SA - Enhancements

Suite Setup         AiC Common Suite Setup
Suite Teardown      Run Keyword And Ignore Error    AiC Common Suite Teardown

Resource          ../resources/KISS/robot/common_resource.robot
Resource          ../resources/sg10/internal_resource/internal_resource.robot
Library           ../CB009235/Airphone/py_check/power_boosting_check.py
Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library    analysis_emil.py
#Library             taf.gnb.oam.coam.vdu      WITH NAME    vdu
#Library             taf.gnb.oam.coam.cu        WITH NAME    cu
Library    taf.sw.dcap.rd    WITH NAME    rd
Variables   assert_emil_value.py


*** Variables ***
${COMMON_CU_SCF}        ${CURDIR}/config/common_cu.xml
${COMMON_VDU1_SCF}      ${CURDIR}/config/common_vdu1.xml
${COMMON_VDU2_SCF}      ${CURDIR}/config/common_vdu2.xml
${COMMON_WTS_CFG}       ${CURDIR}/config/common_wts.cfg
${COMMON_IPHY_SCF}      ${CURDIR}/config/common_iphy.xml
${a5_ho1}    ue_ho_nr ue_id\=22 meas_type\=A3 tgt_phycell_id\=52 tgt_cell_ssb_frequency\=423850 src_rsrp_nr\=46
${a5_ho2}    ue_ho_nr ue_id\=22 meas_type\=A5 tgt_phycell_id\=50 tgt_cell_ssb_frequency\=653280 src_rsrp_nr\=46

@{AP_CMD_LIST_A1_STEP1}
...    ue_register id\=1
...    set_pdu_param ue\=1 pdu\=1 trf_type\=internal
...    set_pdu_param ue\=1 pdu\=2 trf_type\=internal default_qos_flow\=3
...    ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
...    ue_pdu_session_release ue\=1 pdu\=1 by\=amf
...    ue_pdu_session_setup pdu\=2 ue\=1 nwslice\=1 gw\=1
...    trf_data_start ue\=1 pdu\=2 qfi\=1 dir\=dl mbps\=1
...    trf_data_start ue\=1 pdu\=2 qfi\=1 dir\=ul mbps\=1
#...    ue_pdu_session_setup pdu\=1 ue\=22 nwslice\=1 gw\=1
...    ue_pdu_session_modify ue\=1 pdu\=2 qosflows_to_add\=2,4,6,7,8,9,10 by\=amf
...    trf_data_start ue\=1 pdu\=2 qfi\=2 dir\=dl mbps\=2
...    trf_data_start ue\=1 pdu\=2 qfi\=2 dir\=ul mbps\=2
...    trf_data_start ue\=1 pdu\=2 qfi\=3 dir\=dl mbps\=10
...    trf_data_start ue\=1 pdu\=2 qfi\=3 dir\=ul mbps\=10
...    trf_data_start ue\=1 pdu\=2 qfi\=4 dir\=dl mbps\=20
...    trf_data_start ue\=1 pdu\=2 qfi\=4 dir\=ul mbps\=20
...    trf_data_start ue\=1 pdu\=2 qfi\=5 dir\=dl mbps\=30
...    trf_data_start ue\=1 pdu\=2 qfi\=5 dir\=ul mbps\=30
...    trf_data_start ue\=1 pdu\=2 qfi\=6 dir\=dl mbps\=5
...    trf_data_start ue\=1 pdu\=2 qfi\=6 dir\=ul mbps\=5
...    trf_data_start ue\=1 pdu\=2 qfi\=7 dir\=dl mbps\=50
...    trf_data_start ue\=1 pdu\=2 qfi\=7 dir\=ul mbps\=50
...    trf_data_start ue\=1 pdu\=2 qfi\=8 dir\=dl mbps\=100
...    trf_data_start ue\=1 pdu\=2 qfi\=8 dir\=ul mbps\=60
...    trf_data_stop ue\=1 pdu\=2 qfi\=1
...    trf_data_stop ue\=1 pdu\=2 qfi\=2
...    trf_data_stop ue\=1 pdu\=2 qfi\=3
...    trf_data_stop ue\=1 pdu\=2 qfi\=4
...    trf_data_stop ue\=1 pdu\=2 qfi\=5
...    trf_data_stop ue\=1 pdu\=2 qfi\=6
...    trf_data_stop ue\=1 pdu\=2 qfi\=7
...    trf_data_stop ue\=1 pdu\=2 qfi\=8
...    ue_pdu_session_release ue\=1 pdu\=2 by\=amf
...    ue_deregister id\=1 ue_deregister_type\=switch_off
@{AP_CMD_LIST_A5_STEP1}
...    amf_ue_ics_param id\=1 ue\=22 include_ue_capabilities\=off
...    smf_ue_pdu_param id\=1 ue\=22 pdu\=1 session_ambr_ul\=50:Mbps session_ambr_dl\=100:Mbps
...    ue_register id\=22
...    set_pdu_param ue\=22 pdu\=1 trf_type\=internal default_qos_flow\=3
...    ue_pdu_session_setup pdu\=1 ue\=22 nwslice\=1 gw\=1
...    ue_pdu_session_release ue\=22 pdu\=1 by\=amf
...    smf_param id\=1 additional_qosflows_to_activate\=2,7,8,9,12,18
...    ue_pdu_session_setup pdu\=1 ue\=22 nwslice\=1 gw\=1
...    trf_data_start ue\=22 pdu\=1 qfi\=1 dir\=dl mbps\=50 trf_id\=1
...    trf_data_start ue\=22 pdu\=1 qfi\=1 dir\=ul mbps\=10 trf_id\=1
...    trf_data_start ue\=22 pdu\=1 qfi\=2 dir\=dl mbps\=2 trf_id\=1
...    trf_data_start ue\=22 pdu\=1 qfi\=2 dir\=ul mbps\=2 trf_id\=1
...    trf_data_start ue\=22 pdu\=1 qfi\=3 dir\=dl mbps\=20 trf_id\=1
...    trf_data_start ue\=22 pdu\=1 qfi\=3 dir\=ul mbps\=5 trf_id\=1
...    trf_data_start ue\=22 pdu\=1 qfi\=4 dir\=dl mbps\=20 trf_id\=1
...    trf_data_start ue\=22 pdu\=1 qfi\=4 dir\=ul mbps\=5 trf_id\=1
...    trf_data_start ue\=22 pdu\=1 qfi\=5 dir\=dl mbps\=20 trf_id\=1
...    trf_data_start ue\=22 pdu\=1 qfi\=5 dir\=ul mbps\=5 trf_id\=1
...    trf_data_start ue\=22 pdu\=1 qfi\=6 dir\=dl mbps\=20 trf_id\=1
...    trf_data_start ue\=22 pdu\=1 qfi\=6 dir\=ul mbps\=5 trf_id\=1
...    trf_data_start ue\=22 pdu\=1 qfi\=7 dir\=dl mbps\=50 trf_id\=1
...    trf_data_start ue\=22 pdu\=1 qfi\=7 dir\=ul mbps\=100 trf_id\=1
@{AP_CMD_LIST_B9_STEP1}
#...    ue_register id\=91
#...    set_pdu_param ue\=91 pdu\=1 trf_type\=internal
#...    ue_pdu_session_setup pdu\=1 ue\=91 nwslice\=1 gw\=1
...    trf_data_start ue\=91 pdu\=1 qfi\=1 dir\=dl mbps\=45 trf_id\=1
...    trf_data_start ue\=91 pdu\=1 qfi\=1 dir\=ul mbps\=50 trf_id\=1
@{AP_CMD_LIST_B9_STEP2}
#...    ue_register id\=92
#...    set_pdu_param ue\=92 pdu\=1 trf_type\=internal
#...    ue_pdu_session_setup pdu\=1 ue\=92 nwslice\=1 gw\=1
...    trf_data_start ue\=92 pdu\=1 qfi\=1 dir\=dl mbps\=45 trf_id\=1
...    trf_data_start ue\=92 pdu\=1 qfi\=1 dir\=ul mbps\=50 trf_id\=1
@{AP_CMD_LIST_B9_STEP3}
...    ue_register id\=93
...    ue_register id\=94
...    set_pdu_param ue\=93 pdu\=1 trf_type\=internal default_qos_flow\=3
...    qosflow_modify qos_flow\=3 gfbr_ul\=10000 gfbr_dl\=10000 mfbr_ul\=40000 mfbr_dl\=40000
...    ue_pdu_session_setup pdu\=1 ue\=93 nwslice\=1 gw\=1
...    set_pdu_param ue\=94 pdu\=1 trf_type\=internal default_qos_flow\=1
...    qosflow_modify qos_flow\=1 gfbr_ul\=50 gfbr_dl\=50
...    ue_pdu_session_setup pdu\=1 ue\=94 nwslice\=1 gw\=1
...    trf_data_start ue\=93 pdu\=1 qfi\=1 dir\=dl mbps\=40 trf_id\=1
...    trf_data_start ue\=93 pdu\=1 qfi\=1 dir\=ul mbps\=40 trf_id\=1
...    trf_data_start ue\=94 pdu\=1 qfi\=1 dir\=dl kbps\=50 trf_id\=1
...    trf_data_start ue\=94 pdu\=1 qfi\=1 dir\=ul kbps\=50 trf_id\=1
@{AP_CMD_LIST_B9_STEP4}
...    trf_data_stop ue\=91 pdu\=1 qfi\=1
...    trf_data_stop ue\=92 pdu\=1 qfi\=1
...    trf_data_stop ue\=93 pdu\=1 qfi\=1
...    trf_data_stop ue\=94 pdu\=1 qfi\=1
...    ue_pdu_session_release ue\=91 pdu\=1 by\=amf
...    ue_pdu_session_release ue\=92 pdu\=1 by\=amf
...    ue_pdu_session_release ue\=93 pdu\=1 by\=amf
...    ue_pdu_session_release ue\=94 pdu\=1 by\=amf
...    ue_deregister id\=91 ue_deregister_type\=switch_off
...    ue_deregister id\=92 ue_deregister_type\=switch_off
...    ue_deregister id\=93 ue_deregister_type\=switch_off
...    ue_deregister id\=94 ue_deregister_type\=switch_off

*** Test Cases ***
CB008963-A_1_B1_multi-GBR DRBs setup via PDU Session Resource Setup Request
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/12/19 14:23
    [Tags]    a1
    AIC AP Setup    iphy_xml=${COMMON_IPHY_SCF}
    AIC Perform Full Commission And Reach Onair    cu_scf=${COMMON_CU_SCF}    vdu1_scf=${COMMON_VDU1_SCF}
    ...    vdu2_scf=${COMMON_VDU2_SCF}    wts_cfg=${COMMON_WTS_CFG}

    Dcap Start Trace Via Custom Profile    nr_cells=NRCELL-3
    Batch Execute AP CMDS    ${AP_CMD_LIST_A1_STEP1}
    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID

    Dcap Verify Trace Status Ready After Stop Trace    trace_id=${NOW_TRACE_ID}
    ${dcap_zip}    get_results    result_id=${NOW_TRACE_ID}    connection=M5_DCAP
    ${dcap_folder}    my_unzip    zip_file=${dcap_zip}
    ${emil_files}    find_special_file_from_folder    ${dcap_folder}    .5gm
    ${upload_result}    rd.upload_encoded_file    file_name=${emil_files[-1]}    connection=M5_DCAP
    ${session_id}    Set Variable    ${upload_result['session_id']}
    ${data_source_id}    Set Variable    ${upload_result['grid_ids'][0]}

    # Step1: check REGISTRATION COMPLETE in NGAP: UplinkNASTransport
    ${filter}    Create List    ZMQ/SCTP name==NGAP: UplinkNASTransport
    ...    User data==NAS: REGISTRATION COMPLETE
    ${docoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=0    filter=${filter}    connection=M5_DCAP
    Verify Target Key Value In Emil Json    ${docoded_content}    User_data    NAS: REGISTRATION COMPLETE

    # Step2: check NGAP:PDUSessionResourceSetupRequest Establish 5qi-3
    ${filter}    Create List    ZMQ/SCTP name==NGAP: PDUSessionResourceSetupRequest
    ${docoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=0    filter=${filter}    connection=M5_DCAP
    ${values}    find_target_key_values    ${docoded_content}    QosFlowSetupRequestList
    Should Be Equal    ${values[0]}    ${QosFlowSetupRequestList}

    # Step3: check Default DRB selection from F1AP:UEContextModificationRequest and NR-RRC:rrcReconfiguration
    ${filter}    Create List    ZMQ/SCTP name==F1AP: UEContextModificationRequest
    ${docoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=0    filter=${filter}    connection=M5_DCAP
    ${values}    find_target_key_values    ${docoded_content}    DRBs-ToBeSetupMod-Item
    Should Be Equal    ${values["dRBID"]}    ${5}
    ${5qi_values}    find_target_key_values    ${values}    fiveQI
    Should Be Equal    ${5qi_values}    ${3}

    # Step4: check NR-RRC:rrcReconfiguration(DL RRC: rrcReconfiguration)
    ${filter}    Create List    ZMQ/SCTP name==SrbSendReq    Mapping==cpSbAddress    Peer component==5G-CP-UE
    ${docoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=0    filter=${filter}    connection=M5_DCAP
    ${values}    get_target_key_value_in_emil_json    ${docoded_content}    drb-ToAddModList
    Should Be Equal    ${values[1][0]["cnAssociation"]["sdap-Config"]["defaultDRB"]}    ${True}
    Should Be Equal    ${values[1][0]["drb-Identity"]}    ${5}
    Should Be Equal    ${values[1][0]["pdcp-Config"]["drb"]["pdcp-SN-SizeDL"]}    len18bits
    Should Be Equal    ${values[1][0]["pdcp-Config"]["drb"]["pdcp-SN-SizeUL"]}    len18bits

    # Step5: check NGAP:PDUSessionResourceModifyRequest
    # Multiple GBR DRB establish via PDU session resource modify 2,4,6,7,8,9,10
    ${filter}    Create List    ZMQ/SCTP name==NGAP: PDUSessionResourceModifyRequest
    ${docoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=0    filter=${filter}    connection=M5_DCAP
    ${values}    get_target_key_value_in_emil_json    ${docoded_content}    fiveQI
    Should Be Equal    ${values}    ${FIVE_QI_LIST}

    # Step6: check E1AP:BearerContextModificationRequest PDCP SN Length 18bits
    ${filter}    Create List    ZMQ/SCTP name==E1AP: BearerContextModificationRequest
    ${docoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=0    filter=${filter}    connection=M5_DCAP
    Verify Target Key Value In Emil Json    ${docoded_content}    pDCP-SN-Size-DL    s-18
    Verify Target Key Value In Emil Json    ${docoded_content}    pDCP-SN-Size-UL    s-18

    ${filter}    Create List    ZMQ/SCTP name==NGAP: PDUSessionResourceReleaseCommand
    ${docoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=0    filter=${filter}    connection=M5_DCAP
    Verify Target Key Value In Emil Json    ${docoded_content}    nas    normal-release


CB008963-A_5_B6_inter-DU intra-gNB handover with multi-GBR DRBs
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/12/19 13:59
    [Tags]    A5
    Wait Until Keyword Succeeds    3x    1min     A5 Step1_2    ${a5_ho1}    ${52}
    Wait Until Keyword Succeeds    5x    1min     A5 Step1_2    ${a5_ho2}    ${50}

CB008963-B_9_B7_Verify scheduling priority lowered when GBR UE exceeds GFBR data rate causing packet discards
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/12/24 10:42
    [Tags]    B9
    AIC AP Setup    iphy_xml=${COMMON_IPHY_SCF}
    AIC Perform Full Commission And Reach Onair    cu_scf=${COMMON_CU_SCF}    vdu1_scf=${COMMON_VDU1_SCF}
    ...    vdu2_scf=${COMMON_VDU2_SCF}    wts_cfg=${COMMON_WTS_CFG}

    wait_until_next_5_min
    UE from '91' to '91' SA Register
    Batch Execute AP CMDS    ${AP_CMD_LIST_B9_STEP1}
    UE from '92' to '92' SA Register
    Batch Execute AP CMDS    ${AP_CMD_LIST_B9_STEP2}
    Sleep    10s
    ${sum_dl_tp}    Verify B9 UE12 DL TP Normal
    Batch Execute AP CMDS    ${AP_CMD_LIST_B9_STEP3}
    Sleep    10s
    Verify B9 UE1234 DL TP Normal    sum_dl_tp=${sum_dl_tp}
    Batch Execute AP CMDS    ${AP_CMD_LIST_B9_STEP4}

    wait_until_next_5_min
    Verify B9 Counter Update Normal

*** Keywords ***
Batch Execute AP CMDS
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/20 14:22
    [Arguments]    ${cmd_list}    ${wait_time}=1s
    FOR    ${cmd}    IN    @{cmd_list}
        airphone_execute_egate_command    ${cmd}
        Sleep    ${wait_time}
    END

Verify B9 UE12 DL TP Normal
     [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/20 14:38
    [Arguments]    ${sum_tp}=91    ${accuracy}=0.05
    ${dl_tp1}    airphone_sa_get_throughput    ue_id=91    direction=dl    pass_regexp=Average packet rate
    ${dl_tp2}    airphone_sa_get_throughput    ue_id=92    direction=dl    pass_regexp=Average packet rate
    Log To Console    ${dl_tp1}
    Log To Console    ${dl_tp2}
    ${cur_accuracy}    Evaluate    abs(${dl_tp1}+${dl_tp2})/(${sum_tp}*1000)
    Should Be True    1-${accuracy}<${cur_accuracy}<1+${accuracy}
    ${sum_dl_tp}    Evaluate    ${dl_tp1}+${dl_tp2}
    [Return]    ${sum_dl_tp}

Verify B9 UE1234 DL TP Normal
     [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/20 14:38
    [Arguments]    ${sum_dl_tp}    ${target_ue3_tp}=10    ${ue4_tp}=0.05    ${accuracy}=0.05
    ${dl_tp1}    airphone_sa_get_throughput    ue_id=91    direction=dl    pass_regexp=Average packet rate
    ${dl_tp2}    airphone_sa_get_throughput    ue_id=92    direction=dl    pass_regexp=Average packet rate
    ${dl_tp3}    airphone_sa_get_throughput    ue_id=93    direction=dl    pass_regexp=Average packet rate
    ${dl_tp4}    airphone_sa_get_throughput    ue_id=94    direction=dl    pass_regexp=Average packet rate
    Log To Console    ${dl_tp1}
    Log To Console    ${dl_tp2}
    Log To Console    ${dl_tp3}
    Log To Console    ${dl_tp4}
    ${cur_sum_dl_tp}    Evaluate    ${dl_tp1}+${dl_tp2}
    Should Be True    ${sum_dl_tp}>${cur_sum_dl_tp}
    Should Be True    ${dl_tp3}>${target_ue3_tp}
    ${ue4_accuracy}    Evaluate    abs(${dl_tp4})/(${ue4_tp}*1000)
    Should Be True    1-${accuracy}<${ue4_accuracy}<1+${accuracy}

Verify B9 Counter Update Normal
     [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/20 16:17
    [Arguments]    ${dimension_dist_name}=MRBTS-1/NRBTS-1    ${counter_id}=M55320C20003
    CU OAM Login    CU
    ${counter_values}    CU.get_counter    measurement_id=${None}    dimension_dist_name=${dimension_dist_name}
    ...    counter_id=${counter_id}    connection=cu_admin
    Log To Console    ${counter_values["values"][-1]["value"]}
    Should Be True    ${counter_values["values"][-1]["value"]}>0
    [Teardown]    CU OAM Logout    CU

A5 Step1_2
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/14 16:50
    [Arguments]    ${ho_cmd}    ${ho_cell}
    AIC AP Setup    iphy_xml=${COMMON_IPHY_SCF}
    AIC Perform Full Commission And Reach Onair    cu_scf=${COMMON_CU_SCF}    vdu1_scf=${COMMON_VDU1_SCF}
    ...    vdu2_scf=${COMMON_VDU2_SCF}    wts_cfg=${COMMON_WTS_CFG}

    Sleep  60s
    Dcap Start Trace Via Custom Profile    nr_cells=NRCELL-2
    Batch Execute AP CMDS    ${AP_CMD_LIST_A5_STEP1}
    Sleep    10s
    ${dl_tp1}    airphone_sa_get_throughput    ue_id=22    direction=dl    pass_regexp=Average packet rate
    airphone_execute_egate_command    ${ho_cmd}
    Sleep    5s
    ${dl_tp2}    airphone_sa_get_throughput    ue_id=22    direction=dl    pass_regexp=Average packet rate
    ${tp_diff}    Evaluate	${dl_tp1}/${dl_tp2}
    Should Be True    0.9<${tp_diff}<1.1
    airphone_execute_egate_command    ue_pdu_session_release ue\=22 pdu\=1 by\=amf
    airphone_execute_egate_command    ue_deregister id\=22 ue_deregister_type\=switch_off

    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID
    Dcap Verify Trace Status Ready After Stop Trace    trace_id=${NOW_TRACE_ID}
    ${dcap_zip}    get_results    result_id=${NOW_TRACE_ID}    connection=M5_DCAP
    ${dcap_folder}    my_unzip    zip_file=${dcap_zip}
    ${emil_files}    find_special_file_from_folder    ${dcap_folder}    .5gm
    ${upload_result}    rd.upload_encoded_file    file_name=${emil_files[-1]}    connection=M5_DCAP
    ${session_id}    Set Variable    ${upload_result['session_id']}
    ${data_source_id}    Set Variable    ${upload_result['grid_ids'][0]}

    # Step1: check E1AP:BearerContextModificationRequest PDCP SN Length 18bits, 5QI-8 as default
    ${filter}    Create List    ZMQ/SCTP name==E1AP: BearerContextSetupRequest
    ${docoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=0    filter=${filter}    connection=M5_DCAP
    ${values}    get_target_key_value_in_emil_json    ${docoded_content}    dRB-To-Setup-List-NG-RAN
    Should Be Equal    ${values[1][0]}    ${dRB_To_Setup_List_NG_RAN}

    ${filter}    Create List    ZMQ/SCTP name==UlSduReceiveInd
    ${docoded_content}    Get Decoded File Contents In Json    session_id=${session_id}    data_source_id=${data_source_id}
    ...    what=0    filter=${filter}    connection=M5_DCAP
    ${values}    get_target_key_value_in_emil_json    ${docoded_content}    measResultNeighCells
    Log To Console    ${values}
    Should Be Equal    ${values[0]["measResultListNR"][0]["physCellId"]}    ${ho_cell}

    [Teardown]    Airphone Teardown

AIC Perform Full Commission And Reach Onair
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/12/26 15:54
    [Arguments]    ${cu_scf}=${EMPTY}    ${vdu1_scf}=${EMPTY}    ${vdu2_scf}=${EMPTY}    ${wts_cfg}=${EMPTY}
    Activate CU and VDU SCF    cu_scf=${cu_scf}    vdu1_scf=${vdu1_scf}    vdu2_scf=${vdu2_scf}
    Airphone Start Wtssim With Cfg File    ${wts_cfg}    true
    _wait_until_sib1_received_and_setup_x2_connection    timeout=600
    #Wait Until Keyword Succeeds    3min    10s    _sim_state_is_active
    #Sleep    10s
    #Airphone Setup X2 Connection

Activate CU and VDU SCF
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/12/26 15:59
    [Arguments]    ${cu_scf}=${EMPTY}    ${vdu1_scf}=${EMPTY}    ${vdu2_scf}=${EMPTY}
    CU OAM Login    CU
    CU.perform_commissioning    scf_file=${cu_scf}    wait_for_completion=False    connection=cu_admin
    CU OAM Logout    CU
    vDU Login    vdu_index=0    connection=VDU1_OAM
    VDU.perform_commissioning    scf_file=${vdu1_scf}    wait_for_completion=False    vdu_connection=VDU1_OAM
    vDU Logout    connection=VDU1_OAM
    vDU Login    vdu_index=1    connection=VDU2_OAM
    VDU.perform_commissioning    scf_file=${vdu2_scf}    wait_for_completion=False    vdu_connection=VDU2_OAM
    vDU Logout    connection=VDU2_OAM
    Sleep    300s
    Wait Until Keyword Succeeds    15min    1min     Verify VDU RUs status online    vdu_index=0    connection=VDU1_OAM
    Wait Until Keyword Succeeds    15min    1min     Verify VDU RUs status online    vdu_index=1    connection=VDU2_OAM

Verify VDU RUs status online
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/1/20 10:27
    [Arguments]    ${vdu_index}=0    ${connection}=VDU1_OAM
    vDU Login    vdu_index=${vdu_index}    connection=${connection}
    ${rmods_statuses}    VDU.Get RMODs status    vdu_connection=${connection}
    FOR  ${status}  IN  @{rmods_statuses}
        Dictionary should contain item  ${status}  availability_status  on line  msg=RMOD status is not \'on line\':${\n}${status}
    END
    [Teardown]    vDU Logout    connection=${connection}

AiC Common Suite Setup
    [Documentation]    This keyword is aic common Suite Setup.
    ...    Examples:
    ...    | AIC Common Suite Setup |
    Get Host IP
    Get Host Name
    Get TL config
    Get CU SW version
    Get VDU SW version

Get TL Config
    ${variables}=    Get variables
    Set suite variable    ${VLAN_IDS}    ${tl.gnbs[0].dus[0].fhuc_vlans}
    Set suite variable    ${NAMESPACE_CU}    ${tl.cloud_hostings[0].namespace}
    Set suite variable    ${NAMESPACE_VDU}    ${tl.cloud_hostings[1].namespace}
    Set Suite Variable    &{MASTER_CU}
    ...    hostname=${tl.cloud_hostings[0].master_node.ssh_connection_details.addr}
    ...    username=${tl.cloud_hostings[0].master_node.ssh_connection_details.username}
    ...    password=${tl.cloud_hostings[0].master_node.ssh_connection_details.password}
    ...    alias=cu_master
    Set Suite Variable    &{MASTER_VDU}
    ...    hostname=${tl.cloud_hostings[1].master_node.ssh_connection_details.addr}
    ...    username=${tl.cloud_hostings[1].master_node.ssh_connection_details.username}
    ...    password=${tl.cloud_hostings[1].master_node.ssh_connection_details.password}
    ...    alias=vdu_master
    Set Suite Variable    &{OAM_CU}
    ...    host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    port=${tl.gnbs[0].cu.oam_http_connection_details.port}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ...    alias=cu_admin
    Set Suite Variable  &{OAM_VDU}
    ...    host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...    port=${tl.gnbs[0].dus[0].oam_http_connection_details.port}
    ...    username=${tl.gnbs[0].dus[0].oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].dus[0].oam_http_connection_details.password}
    ...    secure=${True}
    ...    connection_name=vdu_admin
	set suite variable    ${VDU_RANNIC1_SERIAL_NUMBER}  ${tl.gnbs[${0}].dus[${0}].rannics[${0}].serial_number}
    set suite variable    ${VDU_RANNIC1_PRODUCT_CODE}  ${tl.gnbs[${0}].dus[${0}].rannics[${0}].product_code}

AIC AP Setup
    [Arguments]    ${iphy_xml}=${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${AIRPHONE_NAME}
    Airphone Setup
    Get Airphone Software Version
    Get WTS Version
    log to console    ${iphy_xml}

vDU Login
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0    ${connection}=VDU_OAM
    ${vdu_connection}    VDU.connect_to
    ...  host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  port=${EMPTY}
    ...  secure=${True}
    ...  connection_name=${connection}
    [Return]    ${vdu_connection}

vDU Logout
    [Arguments]    ${connection}=VDU_OAM
    VDU.disconnect    vdu_connection=${connection}

vCU Login
    [Arguments]    ${vcu_index}=0    ${gnb_index}=0    ${connection}=VCU_OAM
    ${vcu_connection}    CU.connect_to
    ...  host=${tl.gnbs[${gnb_index}].dus[${vcu_index}].oam_http_connection_details.addr}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vcu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vcu_index}].oam_http_connection_details.password}
    ...  port=${EMPTY}
    ...  secure=${True}
    ...  alias=${connection}
    [Return]    ${vcu_connection}

vCU Logout
    [Arguments]    ${connection}=VCU_OAM
    CU.disconnect    connection=${connection}

Connect To Dcap With Alia M5_DCAP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/25 16:11
    ...    testline_configuration: class testline not support dcap now
    [Arguments]   ${host}=10.57.195.96   ${username}=utfuser   ${password}=utfadmin!   ${port}=443   ${alias}=M5_DCAP
    rd.connect_to   host=${host}   port=${port}   username=${username}   password=${password}
    ...   rd_version=dcapv3   secure=${True}   alias=${alias}

Dcap Start Trace Via Custom Profile
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/25 17:03
    [Arguments]    ${nr_cells}=${EMPTY}    ${port}=443    ${connection}=M5_DCAP
    Connect To Dcap With Alia M5_DCAP    port=${port}    alias=${connection}

    &{bts}    Create Dictionary
    ...  host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...  port=${port}
    ...  username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}

    Run Keyword If    '${nr_cells}'!='${EMPTY}'
    ...    Set To Dictionary    ${bts}    nrCells    ${nr_cells}

    @{custom_profile_list}    Create List    controlPlane5gVcu
    ${trace_id}    rd.start_trace    bts=${bts}    vcu_custom_profile=${custom_profile_list}    connection=${connection}
    Set Suite Variable    ${NOW_TRACE_ID}    ${trace_id["tracer_id"]}

    Wait Until Keyword Succeeds    2min    10s     Dcap Verify Trace Status Running After Start Trace
    ...    trace_id=${NOW_TRACE_ID}

    Sleep    10s
    Log to console    \n*****trace has been started in DCAP*****

Dcap Verify Trace Status Ready After Stop Trace
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/05/20 14:58
    [Arguments]    ${trace_id}    ${connection}=M5_DCAP
    ${trace_status}    rd.get_trace_info_by_id    trace_id=${trace_id}    connection=${connection}
    Should Be True    '${trace_status['status']}'=='ready'

Dcap Verify Trace Status Running After Start Trace
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/05/20 14:58
    [Arguments]    ${trace_id}    ${connection}=M5_DCAP
    ${trace_status}    rd.get_trace_info_by_id    trace_id=${trace_id}    connection=${connection}
    Should Be True    '${trace_status['status']}'=='running'

Dcap Stop Trace Via Trace ID
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/25 17:25
    [Arguments]    ${connection}=M5_DCAP    ${download_trace}=false
    rd.stop_trace    trace_id=${NOW_TRACE_ID}    connection=${connection}
    Wait Until Keyword Succeeds    10min    10s    Dcap Verify Trace Status Ready After Stop Trace
    ...    trace_id=${NOW_TRACE_ID}    connection=${connection}
    ${dcap_file}  Run Keyword If    '${download_trace}' == 'true'    rd.get_results    result_id=${NOW_TRACE_ID}
    ...    target_dir=${TS_CASE_LOG_PATH}    connection=${connection}    timeout=600
    [Return]    ${dcap_file}

UE from '${lo}' to '${hi}' SA Register
    FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
        Log To Console   ${\n}-----register UE ${num} ------
        Airphone SA Attach    ue_id=${num}
        Airphone Set Traffic Type    ${num}    1    internal
        Airphone Pdu Session Setup    ${num}    1    1    1
        Wait '0.5s' for stabible
    END
