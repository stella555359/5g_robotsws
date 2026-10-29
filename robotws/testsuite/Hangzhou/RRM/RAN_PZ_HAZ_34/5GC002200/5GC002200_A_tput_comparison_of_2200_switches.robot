# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation
# # #...    author: kk
# # #...    contact:kk.wang@nokia-sbell.com
# # #...    squad group: SG_03
# # #...    feature : 5GC002200
# # #
# # #Suite Setup         Run Keywords
# # #...    Run Keywords    Common Suite Setup for COAM
# # #...    AND    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    ASKEY UE parameter setup
# # #...    AND    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    ASKEY UE parameter setup
# # #...    AND    run keyword if    '${release_info}' == 'SBTS22R2_ENB_0000'    ASKEY UE parameter setup
# # #
# # #Suite Teardown     Run Keyword And Ignore Error       Common Suite Teardown for COAM
# # #
# # #Resource       Resources/5GC002200_coam_common_keywords.robot
# # #Variables      Resources/variables.py
# # #
# # #*** Variables ***
# # #${TL362_disable}          TL362_GNB_2200_A_Disable.xml
# # #${TL362_enable}           TL362_GNB_2200_A_Enable.xml
# # #${TL362_enable_22R2}           TL362_GNB_2200_A_Enable_22R2.xml
# # #${TL365_disable}          TL365_GNB_2200_A_Disable.xml
# # #${TL365_enable}           TL365_GNB_2200_A_Enable.xml
# # #${TL370_disable}          TL370_GNB_2200_A_Disable.xml
# # #${TL370_enable}           TL370_GNB_2200_A_Enable.xml
# # #${swconfig}               /opt/workspace/SCF/2200/swconfig/swconfig.txt
# # #@{TL362_dl_enable}          1200    700    200
# # #@{TL362_dl_disable}         1200    700    200
# # #@{TL365_dl_enable}          750    350    150
# # #@{TL365_dl_disable}         750    350    150
# # #@{TL370_dl_enable}          1200    350    150
# # #@{TL370_dl_disable}         1200    350    150
# # #${2200_A_nglog}             2200_A_wireshark_enable.pcap
# # #${ASKEY_DL_PORT}              ${ue_param['data_transfer']['iperf_options']['qci'][5]}
# # #${ASKEY_UL_PORT}              ${ue_param['data_transfer']['iperf_options']['qci'][6]}
# # #@{att_value_TL362}         25    40    55    60
# # #@{att_value_TL365}         0    30    55    10
# # #@{att_value_TL370}         25    50    70    10
# # #${ue_num}    1
# # #@{disable2200_tp_A003}    1300    1200    780
# # #
# # ###21B test on TL362##
# # ###TRUNK test on TL365##
# # ###21A test on TL370##
# # #
# # #*** Test Cases ***
# # #[1]5GC002200_A_003_max_DL_Tput_when_feature_enable_with_beamset_6_ideal_condition_1116_frametype
# # #    [Documentation]
# # #    ...     this test case is to verify 64TRX(4*8*2) or 32TRX（2*8*2） RU can do DL data transfer successfully
# # #    ...     when 2200 feature enable in ideal air condition(around -60dbm)
# # #    ...     add CNI74278_A_06_SA_Beamweight_check_with_1CSI-RS_4x1_#1wT_BW_60M_1116 case check points
# # #    ...     keep origin bandwidth 100M;
# # #    ...     tmpParam9=2045; UE config with 1 CSI-RS, and n1-n2 is 4X1;
# # #    ...     UE can get peak with the right beamweight. beamset=1x(4+16)=20;
# # #    ...     n1:n2 will use extend 4x1, PA port 3and5, 4and6, 7and9, 8and10.
# # #    ...    Trunk csirsResourceSetConfig1CRI = 4x1-1wT;
# # #    [Tags]      classical    CRT_22R2    CRT_TRUNK    CRT_21A    CRT_21B    CDRT_21A
# # #    [Timeout]    1 hour
# # #    [Setup]
# # #    Case variable set for 2200_A_003
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    Modify the COAM parameter with admin API    parameters=${LOCK_GNB1_CELL1}
# # #    Lock Unlock Enb Cell    dist_name=${${enb_dist}}    parameter_name=${enbx2_para}    value=locked
# # #    Set nrcellid suit varaible    cellid=${${nrcellid}}
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Power UE Precondition
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000' or '${release_info}' == 'SBTS22R2_ENB_0000'    Power UE Precondition
# # #    Log to console    enable 2200 and reset bts
# # #    Prepare testline to cell onair for SA    localFilePath=${swconfig}    tl_scf_filename=${${scf_enable2200}}
# # #    Log to console    enable 2200 good point
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Modify the COAM parameter with admin API
# # #    ...    parameters=${PARAM_Change_tmpParam9_A003}  # golden
# # #    run keyword if    '${release_info}' == 'SBTS22R2_ENB_0000'    Modify the COAM parameter with admin API
# # #    ...    parameters=${PARAM_Change_tmpParam9_A003_T362}  # golden
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Prepare gnb parameters for test_case    parameters=${A003_2200}
# # #    run keyword if    '${release_info}' == 'SBTS22R2_ENB_0000'    Prepare gnb parameters for test_case    parameters=${A003_2200_T362}
# # #    MCS SET    att_value=${@{${att_value}}[0]}    #good_point
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    HBTE PA ON 22R1   ${PA_port_list}    ${PA_values4}
# # #    Start To Capture Wireshark Logs on ASIB    filename=${2200_A_nglog}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999'
# # #    ...    Multi-UEs attach    ue_num=${ue_num}    attach_mode=${SA_attach_mode}
# # #    ...    ue_mode=${SA_UE_MODE}    nettpye=${SA_nettype}    apn_address=${SA_apn_addr}
# # #    ...    ELSE    Power UE Attach and Verify attach for askey     4g_check=False
# # #    Stop and download wireshark Logs on ASIB    logname=${2200_A_nglog}
# # #    Analysis 2200 enable
# # #    Check beamweight for CNI74278    beamweight_name=${${beamweight_name}}    connection=gnb    beamset_num=20
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999'
# # #    ...    power_ue.Start traffic    ue_index=${0}    direction=dl
# # #    ...    apn_address=${SA_apn_addr}    throughput=${Multi_dl_throughput}    duration=1200    ue_type=${UE_TYPE}    ue_mode=${SA_UE_MODE}
# # #    ...    ELSE     Start DL date transfer on appserver     traffic=${dl_throughput}
# # #    ${enable2200_tp_A003}=      DL Tput check with nrcellid    cellid=${${nrcellid}}    dlexpect_tp=${@{${Expect_dl_enable}}[0]}    duration=5m
# # #    set suite variable       ${enable2200_tp_A003}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999'    Multi UE Detach And Stop Traffic
# # #    ...    ELSE    Askey UE stop dl traffic on appserver and detach
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999'    MCS teardown    mcs_alias=${mcs_alias}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000' or '${release_info}' == 'SBTS22R2_ENB_0000'    MCS tear
# ...down    mcs_alias=${mcs_alias
# # }
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL2}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999'    read trunk compare tput
# # #    ...    ELSE     read 22R1 compare tput
# # #    should be true    0.9<=${tput_check}<=1.5
# # #    [Teardown]    Run Keyword And Ignore Error     Tests Recover
# # #
# # #*** Keywords ***
# # #MCS SET
# # #    [Arguments]    ${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    TOPYONG MCS ON TL362     att_value=${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999'
# # #    ...    HAOJIN MCS ON TL365    att_value=${att_value}
# # #
# # #SET MCS ATT
# # #    [Arguments]    ${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    Set TOPYOUNG ATT    att_value=${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999'
# # #    ...    Set HAOJIN ATT    att_value=${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Set HBTE ATT      att_value=${att_value}
# # #
# # #SET PHASE
# # #    [Arguments]    ${horizontal_angle_1}    ${horizontal_angle_2}
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${4}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${horizontal_angle_1}    mcs_alias=TPY
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${2}    end_output_port=${3}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${horizontal_angle_2}    mcs_alias=TPY
# # #
# # #Set TOPYOUNG ATT for RANK2
# # #    [Arguments]    ${att_value}    ${horizontal_angle_1}=${0}    ${horizontal_angle_2}=${3}
# # #    SET PHASE    horizontal_angle_1=${horizontal_angle_1}    horizontal_angle_2=${horizontal_angle_2}
# # #    Set Odd ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=${att_value}    B_Odd=True
# # #    Set Even ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=90    B_Odd=True
# # #    Set Odd ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=90    B_Odd=False
# # #    Set Even ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=90    B_Odd=False
# # #    Set Odd ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=True
# # #    Set Even ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=True
# # #    Set Odd ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=${att_value}    B_Odd=False
# # #    Set Even ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=False
# # #
# # #Online modify gnb parameters for test_case
# # #   [Arguments]     ${dist_id}
# # #    selenium_coam.enable_virtual_display
# # #    selenium_coam.login    url=${WEBUI_COAM}
# # #    ...                    username=${WEBUI_NAME}
# # #    ...                    password=${WEBUI_PWD}
# # #    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
# # #    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
# # #    selenium_coam.disable_message_box
# # #    selenium_coam.set_parameter_value    dist_name=${dist_id}
# # #    ...    filter_param=Number of CSI-RS resource period in one CSI report period
# # #    ...    new_value=1
# # #    selenium_coam.set_parameter_value    dist_name=${dist_id}
# # #    ...    filter_param=Maximum CSI-RS number
# # #    ...    new_value=1
# # #    sleep    3s
# # #    selenium_coam.validate_plan
# # #    sleep    3s
# # #    selenium_coam.activate_plan    activate_plan_despite_errors=True    # not to clict the button for reboot gnb
# # #    selenium_coam.logout
# # #    sleep    5s
# # #
# # #Set HAOJIN ATT for RANK2
# # #    [Arguments]    ${att_value}
# # #    Set HAOJIN Odd ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=${att_value}    B_Odd=True
# # #    sleep    3s
# # #    Set HAOJIN Even ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=90    B_Odd=True
# # #    sleep    3s
# # #    Set HAOJIN Odd ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=90    B_Odd=False
# # #    sleep    3s
# # #    Set HAOJIN Even ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=${att_value}    B_Odd=False
# # #    sleep    3s
# # #    Set HAOJIN Odd ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=True
# # #    sleep    3s
# # #    Set HAOJIN Even ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=True
# # #    sleep    3s
# # #    Set HAOJIN Odd ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=False
# # #    sleep    3s
# # #    Set HAOJIN Even ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=False
# # #    sleep    3s
# # #
# # #TOPYONG MCS ON TL362
# # #    [Arguments]    ${att_value}
# # #    MCS Prepare and set frequency    ip=${topyoung_ip_362}
# # #    Set TOPYOUNG ATT TO LOCK AZQO
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${4}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${0}    mcs_alias=TPY
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${2}    end_output_port=${3}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${-28}    mcs_alias=TPY
# # #    Set TOPYOUNG ATT    att_value=${att_value}
# # #
# # #HAOJIN MCS ON TL365
# # #    [Arguments]    ${att_value}
# # #    HAOJIN MCS Prepare    ip=${haojin_ip_365}
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${13}    end_output_port=${14}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${-8}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep    5s
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${15}    end_output_port=${16}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${8}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep    5s
# # #    Set HAOJIN Port13 to Port16 ATT    att_value=${att_value}
# # #    sleep    3s
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
# # #Analysis 2200 enable
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${2200_A_nglog}    tshark_path=${tshark_path}    command_template=${None}
# # #    ${filter_expression}=    Catenate    f1ap.procedureCode == 7
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
# # #    should contain    ${nrofPorts}    3
# # #    ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
# # #    should contain    ${cdm_Type}    2
# # #    ${n1-n2}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.n1_n2
# # #    should contain    ${n1-n2}    2
# # #    ${filter_expression}=    Catenate    f1ap.procedureCode == 5        # CNI-70137_004 checkpoints
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
# # #read trunk compare tput
# # #    ${tput_check}=    BuiltIn.Evaluate    float(${enable2200_tp_A003}/${${Expect_dl_disable}}[0])
# # #    set suite variable      ${tput_check}
# # #
# # #read 22R1 compare tput
# # #    ${tput_check}=    BuiltIn.Evaluate    float(${enable2200_tp_A003[0]["average"]}/${${Expect_dl_disable}}[0])
# # #    set suite variable      ${tput_check}
# # #
# # #Tests Recover
# # #    Lock Unlock Enb Cell    dist_name=${${enb_dist}}    parameter_name=${enbx2_para}    value=unlocked
# # #    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
# # #    csn.send command    command=killall tcpdump     connection=gnb
# # #    Connect to TestPc    alias=ute
# # #    csn.send command    command=ps -ef | grep cli |grep ute_common_admin | grep -v grep |awk '{print $2}' |xargs kill -9    connection=ute
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Askey UE stop dl traffic on appserver and detach
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    Askey UE stop dl traffic on appserver and detach
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL1}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999'    MCS teardown    mcs_alias=${mcs_alias}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    MCS teardown    mcs_alias=${mcs_alias}
# # #    clear cli process
# # #    disconect all connections
# # ##    Run keyword and continue on failure    CI_interface.Common Case Teardown
