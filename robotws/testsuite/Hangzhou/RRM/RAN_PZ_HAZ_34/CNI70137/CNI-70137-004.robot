# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation
# # #...    author: kk
# # #...    contact:kk.wang@nokia-sbell.com
# # #...    squad group: SG_03
# # #...    feature : CNI70137
# # #
# # #
# # #Suite Setup    Run Keyword And Ignore Error    Common Suite Setup for COAM
# # #
# # #Suite Teardown      Run Keyword And Ignore Error     Common Suite Teardown for COAM
# # #
# # #Resource       ../5GC002200/Resources/5GC002200_coam_common_keywords.robot
# # #Variables      ../5GC002200/Resources/variables.py
# # #
# # #*** Variables ***
# # #${tl_scf_dir_path}           /opt/workspace/SCF/70137/
# # #${TL362_scf_70137}           TL362_GNB_70137_004.xml
# # #${TL365_scf_70137}           TL365_GNB_70137_004.xml
# # #${TL370_scf_70137}           TL370_GNB_70137_004.xml
# # #${swconfig}                  /opt/workspace/SCF/2200/swconfig/swconfig.txt
# # #@{TL362_dl_enable}           1000
# # #@{TL365_dl_enable}            700
# # #@{TL370_dl_enable}            700
# # #${70137_nglog}               70137_wireshark_enable.pcap
# # #${ASKEY_DL_PORT}             ${ue_param['data_transfer']['iperf_options']['qci'][5]}
# # #${ASKEY_UL_PORT}             ${ue_param['data_transfer']['iperf_options']['qci'][6]}
# # #@{att_value_TL362}           25    55    75    127
# # #@{att_value_TL365}            5    55    75    127
# # #@{att_value_TL370}           20    50    70    127
# # #${ue_num}                    1
# # #
# # ###21B test on TL362##
# # ###TRUNK test on TL365##
# # ###22R1 test on TL370##
# # #
# # #*** Test Cases ***
# # #[1]CNI-70137_004_CSIRS_not_reconfiguration_when_maxCsirsNumber=1_with_long_PUCCH_DRX_activate_Qualcomm_UE
# # #    [Documentation]
# # #    ...    Purpose of this case is to validate the CSIRS number reconfigured to Qualcomm UE which support simultaneousCSI-ReportsPerC=4 when DRX
# # #    ...    on duration is long enough to allocate 4CSIRS
# # #    [Tags]      classical
# # #    [Timeout]    1 hour
# # #    [Setup]
# # #    Case variable set for 70137_004
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'    70137_004 on trunk
# # #    ...    ELSE    70137_004
# # #    [Teardown]    Run Keyword And Ignore Error     Tests Recover
# # #
# # #*** Keywords ***
# # #70137_004
# # #    ASKEY UE parameter setup
# # #    Trigger ASKEY UE reboot
# # #    Prepare testline to cell onair for SA 70137    localFilePath=${swconfig}    tl_scf_filename=${${scf_70137}}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Modify the COAM parameter with admin API    parameters=${LOCK_GNB1_CELL1}
# # #    Lock Unlock Enb Cell    dist_name=${${enb_dist}}    parameter_name=${enbx2_para}    value=locked
# # #    Set nrcellid suit varaible    cellid=${${nrcellid}}
# # #    Power UE Precondition
# # #    MCS SET    att_value=${@{${att_value}}[0]}
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    HBTE PA ON 22R1   ${PA_port_list}    ${PA_values4}
# # #    Start To Capture Wireshark Logs on ASIB    filename=${70137_nglog}
# # #    Power UE Attach and Verify attach for askey     4g_check=False
# # #    Start DL date transfer on appserver     traffic=${dl_throughput}
# # #    Stop and download wireshark Logs on ASIB    logname=${70137_nglog}
# # #    DL Tput check with nrcellid    cellid=${${nrcellid}}    dlexpect_tp=${@{${Expect_dl_enable}}[0]}
# # #    Askey UE stop dl traffic on appserver and detach
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'    MCS tea
# ...rdown    mcs_alias=${mcs_alia
# # s}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    MCS teardown    mcs_alias=${mcs_alias}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL2}
# # #    Analysis 70137
# # #
# # #70137_004 on trunk
# # ##    power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}
# # ##    run keyword and ignore error    Common UE Detach
# # #    Prepare testline to cell onair for SA 70137    localFilePath=${swconfig}    tl_scf_filename=${${scf_70137}}
# # #    Lock Unlock Enb Cell    dist_name=${${enb_dist}}    parameter_name=${enbx2_para}    value=locked
# # #    Set nrcellid suit varaible    cellid=${${nrcellid}}
# # #    MCS SET    att_value=${@{${att_value}}[0]}
# # #    Start To Capture Wireshark Logs on ASIB    filename=${70137_nglog}
# # #    Multi-UEs attach    ue_num=${ue_num}    attach_mode=${SA_attach_mode}    ue_mode=${SA_UE_MODE}    nettpye=${SA_nettype}
# # #    ...    apn_address=${SA_apn_addr}
# # #    power_ue.Start traffic    ue_index=${0}    direction=dl
# # #    ...    apn_address=${SA_apn_addr}    throughput=${Multi_dl_throughput}    duration=1200    ue_type=${UE_TYPE}    ue_mode=${SA_UE_MODE}
# # #    Stop and download wireshark Logs on ASIB    logname=${70137_nglog}
# # #    Power UE check throughput with nrcellid    cellid=${${nrcellid}}    dlexpect=${@{${Expect_dl_enable}}[0]}
# # #    Multi UE Detach And Stop Traffic
# # #    MCS teardown    mcs_alias=${mcs_alias}
# # #    Analysis 70137
# # #
# # #
# # #MCS SET
# # #    [Arguments]    ${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    TOPYONG MCS ON TL362     att_value=${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    HAOJIN MCS ON TL365    att_value=${att_value}
# # #
# # #TOPYONG MCS ON TL362
# # #    [Arguments]    ${att_value}
# # #    MCS Prepare and set frequency    ip=${topyoung_ip_362}
# # #    Set TOPYOUNG ATT TO LOCK AZQO
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${2}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${0}    mcs_alias=TPY
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${3}    end_output_port=${4}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${-28}    mcs_alias=TPY
# # #    Set TOPYOUNG ATT    att_value=${att_value}
# # #
# # #HAOJIN MCS ON TL365
# # #    [Arguments]    ${att_value}
# # #    HAOJIN MCS Prepare    ip=${haojin_ip_365}
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${13}    end_output_port=${14}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${-8}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep    3s
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${15}    end_output_port=${16}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${8}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep    3s
# # #    Set HAOJIN Port13 to Port16 ATT    att_value=${att_value}
# # #    MCS.get_phase    input_port=${1}     output_port=${1}     mcs_device=HJ
# # #
# # #HBTE MCS ON TL370
# # #    [Arguments]    ${att_value}
# # #    HBTE MCS Setup    ip=${HBTE_ip_370}
# # #    Set HBTE horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${2}    input_group_id=${None}
# # #    ...    vertical_angle=${96}    horizontal_angle=${-13}    vertical_distance=${1.4}    horizontal_distance=${0.5}    mcs_alias=FC
# # #    Set HBTE horizontal and vertical Phases by output_port    begin_output_port=${3}    end_output_port=${4}    input_group_id=${None}
# # #    ...    vertical_angle=${96}    horizontal_angle=${-3}    vertical_distance=${1.4}    horizontal_distance=${0.5}    mcs_alias=FC
# # #    Set HBTE ATT    att_value=${att_value}
# # #
# # #Analysis 70137
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${70137_nglog}    tshark_path=${tshark_path}    command_template=${None}
# # #    ${filter_expression}=    Catenate    f1ap.procedureCode == 5
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
# # #    should not contain    ${nrofPorts}    3
# # #    ${longpucch}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.format
# # #    should contain    ${longpucch}    1
# # #    should contain    ${longpucch}    3
# # #    ${filter_expression}=    Catenate    (f1ap.procedureCode == 12) && (nr-rrc.c1 == 1)
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${p8}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
# # #    should contain    ${p8}    3
# # #
# # #Tests Recover
# # #    Lock Unlock Enb Cell    dist_name=${${enb_dist}}    parameter_name=${enbx2_para}    value=unlocked
# # #    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
# # #    csn.send command    command=killall tcpdump     connection=gnb
# # #    Connect to TestPc    alias=ute
# # #    csn.send command    command=ps -ef | grep cli |grep ute_common_admin | grep -v grep |awk '{print $2}' |xargs kill -9    connection=ute
# # #    Run Keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...     Run Keyword And Ignore Error    Multi UE Detach And Stop Traffic
# # #    ...     ELSE     Run Keyword And Ignore Error    Askey UE stop dl traffic on appserver and detach
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL1}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'    MCS tea
# ...rdown    mcs_alias=${mcs_alia
# # s}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    MCS teardown    mcs_alias=${mcs_alias}
# # #    clear cli process
# # #    disconect all connections
# # #
# # #
