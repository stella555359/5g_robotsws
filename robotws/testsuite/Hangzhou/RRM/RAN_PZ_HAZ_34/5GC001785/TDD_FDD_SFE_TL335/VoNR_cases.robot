#*** Settings ***
#Documentation
#...    author: Ming Shi
#...    contact:ming.shi@nokia-sbell.com
#...    squad group: 5G_PZ_HZ_3_SG
#...    feature : TMO_VoNR
#
#Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup    AND
#...                            Common Suite Setup for COAM    AND
#...                            Setup for Env cell on-air for 2 gnb
#
#Suite Teardown    robot_common_operations.Common Suite Teardown
#
#
#Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/TMO_VoNR_common_keyword.robot
#Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/TMO_VoNR_variables.py
#
#
#*** Variables ***
#@{ues_phones_6688}    +6688    +6688    +6688    +6688
#@{ues_phones_911}    911    911    911    911
#@{ues_phones}    +86${tl.ues[0].sec_key}    +86${tl.ues[1].sec_key}    +86${tl.ues[2].sec_key}
#...    +86${tl.ues[3].sec_key}    +86${tl.ues[4].sec_key}    +86${tl.ues[5].sec_key}
#@{ues_num}    ${2}    ${3}    ${4}    ${5}
#@{video_ues_num}    ${2}    ${4}
#@{ues_num_006}    ${2}    ${3}
#@{ues_num_007}    ${2}    ${3}
#${multi_times}    30
#${atten_ip}    ${tl.attenuator[0].ip_addr}     #atten1
#${atten_ip2}    ${tl.attenuator[1].ip_addr}    #atten2
#${att_api_port}    ${tl.attenuator[0].port}
#${max_attenuation_value}    ${127}
#${vendor}    ${tl.attenuators[0].vendor}
#${interval}    9
#${pa_settime}    0.6
#${paerror_counter}    0
#${ho_times}    30
#@{kpi_ids}    NR_5241a    NR_600b    NR_5435    NR_985a    NR_986a    NR_990a    NR_1269a    NR_1435a    NR_1436a    NR_1476a
#@{video_num}    ${tl.ues[5].sec_key}    ${tl.ues[3].sec_key}
#@{voice_call_action}    make_MO_Voice    hang_up_MO_Voice    make_video_together    hang_up_video_call    enable_data    disable_data
#...    make_MO_Voice_failed
#
#*** Test Cases ***
#[1]SFE_case_002_5G_SA_vonr_call_epsfb_from_NR_to_LTE
#    [Documentation]
#    [Tags]    classical    CRT_22R3    CRT_23R2    CRT_21B    CRT_22R1    CRT_22R2    CRT_TRUNK    CRT_22R4    CRT_23R1
#    [Timeout]    10 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    ${ue_no}    Get Length    ${ues_num}
#    ${check_value}    Evaluate    ${multi_times}*${ue_no}
#    Lock cell online via coam    enb_index=${0}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#    Online modify parmeters    parameters_to_update=${PARAM_TMO_VoNR_EPSFB}
#    Online delete parmeters    parameters_to_update=${PARAM_DELETE_TMO_VoNR_EPSFB}
#    Prepare with PM counter time caculate    period=start
#    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
#    Wait Until Keyword Succeeds    3x    10s    make multi ues network with single pc    control_pc_ip=${tl.ues[2].ssh_connection_details.addr}
#    ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#    ...    pc_password=${tl.ues[2].ssh_connection_details.password}    action_index=${0}
#    set PA port on one cell    pa_name=${enb2_cell1_pa_info}    value=${enb2_cell1_pa_value}[setup][0]
#    multi UEs make and hang up voice call multi times
#    Prepare with PM counter time caculate    period=end
#    Set excel name
#    Get counters and write in excel    filename=${excel_name}    counter_info=${SFE_case_002}    timeout=300
#    ####NR_5241a  5G Number of UE redirections to E-UTRAN due to voice fallback to LTE
#    Sum([M55124C02501])  (Sum([NR_RRC_RELEASE_REDIR_VFB_LTE]))
#    M55124C02501   M55124C01502
#    ${kpi_value}    Calculate KPI to check    filename=${excel_name}    sheetname=${excel_name}    kpi_id=@{kpi_ids}[0]
#    Should Be True    ${kpi_value}[0] >= ${check_value}
#    Should Be True    ${kpi_value}[1] >= ${check_value}
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
#    ...    AND    Wait Until Keyword Succeeds    3x    10s    multi_ues_operations_voice_call_exe_with_threading
#    ...    operation=@{voice_call_action}[1]    num=@{ues_phones_6688}[0]
#    ...    pc_ip=${tl.ues[2].ssh_connection_details.addr}
#    ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#    ...    pc_password=${tl.ues[2].ssh_connection_details.password}
#    ...    AND    Wait Until Keyword Succeeds    3x    10s
#    ...    make multi ues network with single pc    control_pc_ip=${tl.ues[2].ssh_connection_details.addr}
#    ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#    ...    pc_password=${tl.ues[2].ssh_connection_details.password}    action_index=${1}
#    ...    AND    PA recover
#    ...    AND    Unlock cell online via coam    enb_index=${0}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#    ...    AND    Online modify parmeters    parameters_to_update=${PARAM_TMO_VoNR_EPSFB_recover}
#    ...    AND    Online add parmeters    parameters_to_update=${PARAM_ADD_TMO_VoNR_EPSFB}
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]SFE_case_003_5G_SA_Video_call
#    [Documentation]
#    [Tags]    classical    CRT_22R3    CRT_23R2    CRT_21B    CRT_22R1    CRT_22R2    CRT_TRUNK    CRT_22R4    CRT_23R1
#    [Timeout]    10 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    ${phone_nums}=    Catenate    ${tl.ues[5].sec_key}    ${tl.ues[3].sec_key}
#    Set Test Variable    ${phone_nums}
#    ${ue_no}    Get Length    ${ues_num}
#    ${check_value}    Evaluate    ${multi_times}*${ue_no}/2
#    Lock cell online via coam    enb_index=${0}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#    Online modify parmeters    parameters_to_update=${PARAM_TMO_Video}
#    Prepare with PM counter time caculate    period=start
#    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
#    Wait Until Keyword Succeeds    3x    10s    make multi ues network with single pc    control_pc_ip=${tl.ues[2].ssh_connection_details.addr}
#    ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#    ...    pc_password=${tl.ues[2].ssh_connection_details.password}    action_index=${0}
#    Wait Until Keyword Succeeds    3x    10s    multi_ues_operations_voice_call_exe_with_threading
#    ...    operation=@{voice_call_action}[5]    num=${phone_nums}
#    ...    pc_ip=${tl.ues[2].ssh_connection_details.addr}
#    ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#    ...    pc_password=${tl.ues[2].ssh_connection_details.password}
#    multi UEs make and hang up video call multi times
#    Prepare with PM counter time caculate    period=end
#    Set excel name
#    Get counters and write in excel    filename=${excel_name}    counter_info=${SFE_case_003}    timeout=300
#    ####NR_600b  5G SA Number of RRC connection establishment attempts for Mobile Originated Video Call
#    Sum(m55124c01017)   Sum(nrrcc_rrc_stpreq_mo_videocal)
#    M55124C01017
#    ${kpi_value}    Calculate KPI to check    filename=${excel_name}    sheetname=${excel_name}    kpi_id=@{kpi_ids}[1]
#    Should Be True    ${kpi_value}[0] >= ${check_value}
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    Wait Until Keyword Succeeds    3x    10s    multi_ues_operations_voice_call_exe_with_threading
#    ...    operation=@{voice_call_action}[3]    num=${phone_nums}
#    ...    pc_ip=${tl.ues[2].ssh_connection_details.addr}
#    ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#    ...    pc_password=${tl.ues[2].ssh_connection_details.password}    count_num=${4}
#    ...    AND    Wait Until Keyword Succeeds    3x    10s    multi_ues_operations_voice_call_exe_with_threading
#    ...    operation=@{voice_call_action}[4]    num=${phone_nums}
#    ...    pc_ip=${tl.ues[2].ssh_connection_details.addr}
#    ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#    ...    pc_password=${tl.ues[2].ssh_connection_details.password}
#    ...    AND    Wait Until Keyword Succeeds    3x    10s
#    ...    make multi ues network with single pc    control_pc_ip=${tl.ues[2].ssh_connection_details.addr}
#    ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#    ...    pc_password=${tl.ues[2].ssh_connection_details.password}    action_index=${1}
#    ...    AND    PA recover
#    ...    AND    Unlock cell online via coam    enb_index=${0}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#    ...    AND    Online modify parmeters    parameters_to_update=${PARAM_recover_TMO_Video}
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]SFE_case_005_Emergency_call_EPSFB
#    [Documentation]
#    [Tags]    classical    CRT_22R3    CRT_23R2    CRT_21B    CRT_22R1    CRT_22R2    CRT_TRUNK    CRT_22R4    CRT_23R1
#    [Timeout]    10 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    ${ue_no}    Get Length    ${ues_num}
#    ${check_value}    Evaluate    ${multi_times}*${ue_no}
#    Lock cell online via coam    enb_index=${0}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#    Online modify parmeters    parameters_to_update=${PARAM_TMO_EMC_EPSFB}
#    Prepare with PM counter time caculate    period=start
#    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
#    Wait Until Keyword Succeeds    3x    10s    make multi ues network with single pc    control_pc_ip=${tl.ues[2].ssh_connection_details.addr}
#    ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#    ...    pc_password=${tl.ues[2].ssh_connection_details.password}    action_index=${0}
#    set PA port on one cell    pa_name=${enb2_cell1_pa_info}    value=${enb2_cell1_pa_value}[setup][0]
#    Wait Until Keyword Succeeds    3x    10s    multi_ues_operations_voice_call_exe_with_threading
#    ...    operation=@{voice_call_action}[5]    num=@{ues_phones_911}[0]
#    ...    pc_ip=${tl.ues[2].ssh_connection_details.addr}
#    ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#    ...    pc_password=${tl.ues[2].ssh_connection_details.password}
#    Online modify parmeters    parameters_to_update=${PARAM_TMO_EMC_EPSFB_2}
#    multi UEs make and hang up EMC call multi times
#    Prepare with PM counter time caculate    period=end
#    Set excel name
#    Get counters and write in excel    filename=${excel_name}    counter_info=${SFE_case_005}    timeout=300
#    due to KPI NR_5435 and NR_1269a is in 784, other KPIs is in 1468, for this case, we follow the 2 KPIs(784) only after checked with Nora
#    ####NR_5435 5G Number of UE redirections to E-UTRAN due to IMS Emergency call voice fallback to LTE
#    Sum([M55124C04002]) (Sum([NR_RRC_RELEASE_REDIR_EC_LTE]))
#    NR_985a 5G SA Number of initial context setup requests for emergency fallback
#    Sum(m55125c03001) Sum(nngcc_ue_ctxt_stp_req_ef_recd)
#    NR_986a 5G SA Initial context setup success ratio for emergency fallback
#    100 * Sum(m55125c03002)/Sum(m55125c03001)    100 * Sum(nngcc_ue_ctxt_stp_resp_ef_sent)/Sum(nngcc_ue_ctxt_stp_req_ef_recd)
#    NR_990a 5G SA UE context modification success ratio for emergency fallback
#    100 * Sum(m55125c03008)/Sum(m55125c03007)    100 * Sum(nngcc_ue_ctxt_mod_resp_ef_sent)/Sum(nngcc_ue_ctxt_mod_req_ef_recd)
#    NR_1269a 5G SA Emergency voice call fallback to LTE ratio
#    100 * Sum(m55124c04002) / Sum(m55124c01004)  100 * Sum(nr_rrc_release_redir_ec_lte) / Sum(nrrcc_rrc_stpreq_emergency)
#    ${kpi_value}    Calculate KPI to check    filename=${excel_name}    sheetname=${excel_name}    kpi_id=@{kpi_ids}[2]
#    Should Be True    ${kpi_value}[0] >= ${check_value}
#    ${kpi_value}    Calculate KPI to check    filename=${excel_name}    sheetname=${excel_name}    kpi_id=@{kpi_ids}[6]
#    ${compare_result}    Convert To Integer    ${kpi_value}[0]
#    Should Not Be Equal    ${compare_result}    ${100}
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    Wait Until Keyword Succeeds    3x    10s    multi_ues_operations_voice_call_exe_with_threading
#    ...    operation=@{voice_call_action}[1]    num=@{ues_phones_911}[0]
#    ...    pc_ip=${tl.ues[2].ssh_connection_details.addr}
#    ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#    ...    pc_password=${tl.ues[2].ssh_connection_details.password}
#    ...    AND    Wait Until Keyword Succeeds    3x    10s    multi_ues_operations_voice_call_exe_with_threading
#    ...    operation=@{voice_call_action}[4]    num=@{ues_phones_911}[0]
#    ...    pc_ip=${tl.ues[2].ssh_connection_details.addr}
#    ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#    ...    pc_password=${tl.ues[2].ssh_connection_details.password}
#    ...    AND    Wait Until Keyword Succeeds    3x    10s
#    ...    make multi ues network with single pc    control_pc_ip=${tl.ues[2].ssh_connection_details.addr}
#    ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#    ...    pc_password=${tl.ues[2].ssh_connection_details.password}    action_index=${1}
#    ...    AND    PA recover
#    ...    AND    Unlock cell online via coam    enb_index=${0}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#    ...    AND    Online modify parmeters    parameters_to_update=${PARAM_recover_TMO_EMC_EPSFB_2}
#    ...    AND    Online modify parmeters    parameters_to_update=${PARAM_recover_TMO_EMC_EPSFB}
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
##[1]SFE_case_006_5G_SA_inter_gnb_HO_with_VORN_DATA_one_without_ROHC_one_with_ROHC
##   [Documentation]
##   [Tags]    classical    CRT_22R3    CRT_23R2    CRT_21B    CRT_22R1    CRT_22R2    CRT_TRUNK    CRT_22R4    CRT_23R1
##   [Timeout]    10 hour
##   [Setup]
##   robot_common_operations.Common Case Setup
##   ${ue_no}    Get Length    ${ues_num_006}
##   lock unused cell case 006
##   Online modify parmeters    parameters_to_update=${PARAM_ROHC}
##   Online modify parmeters    parameters_to_update=${PARAM_ROHC_2}    gnb_index=${1}
##   Prepare with PM counter time caculate    period=start
##   set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][6]
##   set PA port on one cell    pa_name=${gnb2_cell2_pa_info}    value=${gnb2_cell2_pa_value}[setup][6]
##   startup xcal app
##   UE attach via XCAL
##   sleep    10s
##   Wait Until Keyword Succeeds    3x    60s    start stop autocall and check mos value via xcal
##   sleep    15s
##   Wait Until Keyword Succeeds    3x    60s    start stop autocall and check mos value via xcal with ho
##   Prepare with PM counter time caculate    period=end
##   Set excel name
##   ${kpi_value}    Get counters and write in excel    filename=${excel_name}    counter_info=${SFE_case_006}    timeout=300
##   ####NR_1435a 5G SA RoHC compression configuration success ratio
##   100 * Sum(m55124c06002) / Sum(m55124c06001)  100 * Sum(nrrcc_rohc_drb_ctx_cmp_recd) / Sum(nrrcc_rohc_drb_ctx_req_sent)
##   ${kpi_value}    Calculate KPI to check    filename=${excel_name}    sheetname=${excel_name}    kpi_id=@{kpi_ids}[7]
##   Should Be Equal    ${kpi_value}[0]    ${100}
##   NR_1436a 5G SA Number of RoHC compression configuration requests
##   Sum(m55124c06001)  Sum(nrrcc_rohc_drb_ctx_req_sent)
##   ${kpi_value}    Calculate KPI to check    filename=${excel_name}    sheetname=${excel_name}    kpi_id=@{kpi_ids}[8]
##   Should Be True    ${kpi_value}[0] > ${0}
##   Should Be Equal    ${kpi_value}[1]    ${0}
##   NR_1476a  5G SA RoHC compression configuration success ratio (gNB perspective)
##   100 * Sum(m55135c01002)/Sum(m55135c01001)   100 * Sum(ne1cs_rohc_drb_ctx_resp_recd) / Sum(ne1cs_rohc_drb_ctx_req_sent)
##   ${kpi_value}    Calculate KPI to check    filename=${excel_name}    sheetname=${excel_name}    kpi_id=@{kpi_ids}[9]
##   Should Be Equal    ${kpi_value}[0]    ${100}
##   M55320C19004 M55319C16001
##   [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
##   ...    AND    stop autocall via xcal
##   ...    AND    UE detach via XCAL
##   ...    AND    close xcal app
##   ...    AND    PA recover
##   ...    AND    unlock unused cell case 006
##   ...    AND    Online modify parmeters    parameters_to_update=${PARAM_recover_ROHC}
##   ...    AND    Online modify parmeters    parameters_to_update=${PARAM_recover_ROHC_2}    gnb_index=${1}
##   ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
##
##[1]SFE_case_007_VONR_with_CA_and_without_CA_MOS_compare
##   [Documentation]
##   [Tags]    classical    CRT_22R3    CRT_23R2    CRT_21B    CRT_22R1    CRT_22R2    CRT_TRUNK    CRT_22R4    CRT_23R1
##   [Timeout]    10 hour
##   [Setup]
##   robot_common_operations.Common Case Setup
##   lock unused cell case 007
##   set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
##   startup xcal app
##   UE attach via XCAL
##   Unlock cell online via coam    gnb_index=${0}    cell_index=${2}    node_type=gnb
##   Wait Until Keyword Succeeds    3x    1m    start stop autocall and check mos value via xcal
##   UE detach via XCAL
##   ####CA is disabled: NRBTS/NRDU/carrierAggregationSupportList set to 'none'
##   Lock cell online via coam    gnb_index=${0}    cell_index=${2}    node_type=gnb
##   UE attach via XCAL
##   Wait Until Keyword Succeeds    3x    1m    start stop autocall and check mos value via xcal
##   [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
##   ...    AND    stop autocall via xcal
##   ...    AND    UE detach via XCAL
##   ...    AND    close xcal app
##   ...    AND    unlock unused cell case 007
##   ...    AND    PA recover
##   ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#
#*** Keywords ***
#Set excel name
#    ${test_name}=    set variable    ${TEST_NAME}
#    @{name}    String.split string    string=${test_name}    separator=]
#    Set Suite Variable    ${excel_name}    @{name}[1]
#
#multi UEs make and hang up voice call multi times
#    FOR    ${per_time}    IN RANGE    ${multi_times}
#        Wait Until Keyword Succeeds    3x    10s    multi_ues_operations_voice_call_exe_with_threading
#        ...    operation=@{voice_call_action}[0]    num=@{ues_phones_6688}[0]
#        ...    pc_ip=${tl.ues[2].ssh_connection_details.addr}
#        ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#        ...    pc_password=${tl.ues[2].ssh_connection_details.password}
#       make multi ues voice loop    UE_phone_numbers=@{ues_phones_6688}    status=${2}
#        sleep    60s
#        Wait Until Keyword Succeeds    3x    10s    multi_ues_operations_voice_call_exe_with_threading
#        ...    operation=@{voice_call_action}[1]    num=@{ues_phones_6688}[0]
#        ...    pc_ip=${tl.ues[2].ssh_connection_details.addr}
#        ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#        ...    pc_password=${tl.ues[2].ssh_connection_details.password}
#       hang up multi ues voice loop    UE_index_num=@{ues_num}    status=${0}
#        sleep    20s
#    END
#
#multi UEs make and hang up video call multi times
#   ${phone_nums}=    Catenate    ${tl.ues[4].sec_key}    ${tl.ues[2].sec_key}
#    FOR    ${per_time}    IN RANGE    ${multi_times}
#        sleep    10s
#        Wait Until Keyword Succeeds    3x    10s    multi_ues_operations_voice_call_exe_with_threading
#        ...    operation=@{voice_call_action}[2]    num=${phone_nums}
#        ...    pc_ip=${tl.ues[2].ssh_connection_details.addr}
#        ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#        ...    pc_password=${tl.ues[2].ssh_connection_details.password}    count_num=${2}
#       make multi ues VoNR and ViNR call together loop    UE_index_num=@{video_ues_num}    status=${3}
#        sleep    60s
#        Wait Until Keyword Succeeds    3x    10s    multi_ues_operations_voice_call_exe_with_threading
#        ...    operation=@{voice_call_action}[3]    num=${phone_nums}
#        ...    pc_ip=${tl.ues[2].ssh_connection_details.addr}
#        ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#        ...    pc_password=${tl.ues[2].ssh_connection_details.password}    count_num=${4}
#       hang up multi ues video loop    UE_index_num=@{video_ues_num}    status=${0}
#    END
#
#multi UEs make and hang up EMC call multi times
#    FOR    ${per_time}    IN RANGE    ${multi_times}
#        Wait Until Keyword Succeeds    3x    10s    multi_ues_operations_voice_call_exe_with_threading
#        ...    operation=@{voice_call_action}[6]    num=@{ues_phones_911}[0]
#        ...    pc_ip=${tl.ues[2].ssh_connection_details.addr}
#        ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#        ...    pc_password=${tl.ues[2].ssh_connection_details.password}
#       make multi ues EMC loop    UE_index_num=@{ues_num}    is_incallui=${True}
#       sleep    10s
#        Wait Until Keyword Succeeds    3x    10s    multi_ues_operations_voice_call_exe_with_threading
#        ...    operation=@{voice_call_action}[1]    num=@{ues_phones_911}[0]
#        ...    pc_ip=${tl.ues[2].ssh_connection_details.addr}
#        ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#        ...    pc_password=${tl.ues[2].ssh_connection_details.password}
#       hang up multi ues EMC loop    UE_index_num=@{ues_num}    is_incallui=${False}
#       Setup UE mobile data loop    UE_index_num=@{ues_num}    status=enable
#        Wait Until Keyword Succeeds    3x    10s    multi_ues_operations_voice_call_exe_with_threading
#        ...    operation=@{voice_call_action}[4]    num=@{ues_phones_911}[0]
#        ...    pc_ip=${tl.ues[2].ssh_connection_details.addr}
#        ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#        ...    pc_password=${tl.ues[2].ssh_connection_details.password}
#        Lock cell online via coam    enb_index=${0}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#        Online modify parmeters    parameters_to_update=${PARAM_recover_TMO_EMC_EPSFB_2}
#        Wait Until Keyword Succeeds    3x    10s    make multi ues network with single pc
#        ...    action_index=${1}    control_pc_ip=${tl.ues[2].ssh_connection_details.addr}
#        ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#        ...    pc_password=${tl.ues[2].ssh_connection_details.password}
#       UEs attach loop    UE_index_num=@{ues_num}    gnb_index=${0}
#        Wait Until Keyword Succeeds    3x    10s    make multi ues network with single pc
#        ...    action_index=${0}    control_pc_ip=${tl.ues[2].ssh_connection_details.addr}
#        ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#        ...    pc_password=${tl.ues[2].ssh_connection_details.password}
#        Unlock cell online via coam    enb_index=${0}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#       Setup UE mobile data loop    UE_index_num=@{ues_num}    status=disable
#        Wait Until Keyword Succeeds    3x    10s    multi_ues_operations_voice_call_exe_with_threading
#        ...    operation=@{voice_call_action}[5]    num=@{ues_phones_911}[0]
#        ...    pc_ip=${tl.ues[2].ssh_connection_details.addr}
#        ...    pc_username=${tl.ues[2].ssh_connection_details.username}
#        ...    pc_password=${tl.ues[2].ssh_connection_details.password}
#        Online modify parmeters    parameters_to_update=${PARAM_TMO_EMC_EPSFB_2}
#    END
#
#lock unused cell
#    Lock cell online via coam    gnb_index=${0}    cell_index=${2}    node_type=gnb
#    Lock cell online via coam    gnb_index=${1}    cell_index=${1}    node_type=gnb
#    Lock cell online via coam    gnb_index=${1}    cell_index=${2}    node_type=gnb
#    Lock cell online via coam    enb_index=${0}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#    Lock cell online via coam    enb_index=${0}    cell_index=${2}    node_type=enb    connection=ENB_OAM
#    Lock cell online via coam    enb_index=${1}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#
#unlock unused cell
#    Unlock cell online via coam    gnb_index=${0}    cell_index=${2}    node_type=gnb
#    Unlock cell online via coam    gnb_index=${1}    cell_index=${1}    node_type=gnb
#    Unlock cell online via coam    gnb_index=${1}    cell_index=${2}    node_type=gnb
#    Unlock cell online via coam    enb_index=${0}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#    Unlock cell online via coam    enb_index=${0}    cell_index=${2}    node_type=enb    connection=ENB_OAM
#    Unlock cell online via coam    enb_index=${1}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#
#lock unused cell case 006
#    Lock cell online via coam    gnb_index=${0}    cell_index=${2}    node_type=gnb
#    Lock cell online via coam    enb_index=${0}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#    Lock cell online via coam    enb_index=${0}    cell_index=${2}    node_type=enb    connection=ENB_OAM
#    Lock cell online via coam    enb_index=${1}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#
#unlock unused cell case 006
#    Unlock cell online via coam    gnb_index=${0}    cell_index=${2}    node_type=gnb
#    Unlock cell online via coam    enb_index=${0}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#    Unlock cell online via coam    enb_index=${0}    cell_index=${2}    node_type=enb    connection=ENB_OAM
#    Unlock cell online via coam    enb_index=${1}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#
#lock unused cell case 007
#    Lock cell online via coam    gnb_index=${0}    cell_index=${2}    node_type=gnb
#    Lock cell online via coam    gnb_index=${1}    cell_index=${1}    node_type=gnb
#    Lock cell online via coam    enb_index=${0}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#    Lock cell online via coam    enb_index=${0}    cell_index=${2}    node_type=enb    connection=ENB_OAM
#    Lock cell online via coam    enb_index=${1}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#
#unlock unused cell case 007
#    Unlock cell online via coam    gnb_index=${0}    cell_index=${2}    node_type=gnb
#    Unlock cell online via coam    gnb_index=${1}    cell_index=${1}    node_type=gnb
#    Unlock cell online via coam    enb_index=${0}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#    Unlock cell online via coam    enb_index=${0}    cell_index=${2}    node_type=enb    connection=ENB_OAM
#    Unlock cell online via coam    enb_index=${1}    cell_index=${1}    node_type=enb    connection=ENB_OAM
#
#start stop autocall and check mos value via xcal with ho
#    start autocall via xcal
#    Adjust_HBTE_PA with loop    pa_name=${gnb2_cell1_pa_info}    s_value=${gnb2_cell1_pa_value}[setup][6]
#    ...    e_value=${gnb2_cell1_pa_value}[setup][5]    step=${gnb2_cell1_pa_info}[step][0]    ho_times=${ho_times}
#    stop autocall via xcal
#    ${result}=    Run Keyword And Return Status    check mos value via xcal
#    Run Keyword If    '${result}' == 'False'    Run Keywords
#    ...    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][6]
#    ...    AND    set PA port on one cell    pa_name=${gnb2_cell2_pa_info}    value=${gnb2_cell2_pa_value}[setup][6]
#    ...    AND    UE attach via XCAL
#    ...    AND    start autocall via xcal
#    ...    AND    Adjust_HBTE_PA with loop    pa_name=${gnb2_cell1_pa_info}    s_value=${gnb2_cell1_pa_value}[setup][6]
#    ...    e_value=${gnb2_cell1_pa_value}[setup][5]    step=${gnb2_cell1_pa_info}[step][0]    ho_times=${ho_times}
#    ...    AND    stop autocall via xcal
#    ...    AND    check mos value via xcal
#    sleep    15s
#    [Teardown]    stop autocall via xcal