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
# # #
# # #Suite Teardown     Run Keyword And Ignore Error       Common Suite Teardown for COAM
# # #
# # #Resource       Resources/5GC002200_coam_common_keywords.robot
# # #Variables      Resources/variables.py
# # #
# # #*** Variables ***
# # #${TL362_scf_74278_A_12}            TL362_GNB_CNI74278_A12.xml
# # #${TL365_scf_74278_A_12}            TL365_GNB_CNI74278_A12.xml
# # #${TL370_scf_74278_A_12}            TL370_GNB_CNI74278_A12.xml
# # #${swconfig}               /opt/workspace/SCF/2200/swconfig/swconfig.txt
# # #@{TL362_dl_enable}          1200    700    200
# # #@{TL362_dl_disable}         1200    700    200
# # #@{TL365_dl_enable}          750    350    150
# # #@{TL365_dl_disable}         750    350    150
# # #@{TL370_dl_enable}          1200    350    150
# # #@{TL370_dl_disable}         1200    350    150
# # #${74278_A12_nglog_01}             74278_A12_01_wireshark.pcap
# # #${74278_A12_nglog_02}             74278_A12_02_wireshark.pcap
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
# # ###22R1 test on TL370##
# # #
# # #*** Test Cases ***
# # #[1]CNI74278_A_12_SA_different_csirsResourceSetConfig2CRI_value_check_100M_1116
# # #    [Documentation]
# # #    ...    The purpose of this test case is to verify cell on air after NIDD NRCELL;
# # #    ...    tmppara9 set to different value (in the planne value list)
# # #    ...    tmppara9=4x1_#1#1_1_3/4x1_#1#1_1_5
# # #    ...    tmpParam9=2142;beamset=(2+1)x(4+16)=60; UE config with 2 CSI-RS, and n1-n2 is 4X1;
# # #    ...    UE can attach with the right beamweight. change to tmpParam9=2251;beamset=(2+1)x(4+16)=60;
# # #    ...    trunk csirsResourceSetConfig2CRI = 4x1-1-1_1_3;
# # #    [Tags]      classical    CRT_22R2    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CDRT_21A
# # #    [Timeout]    1 hour
# # #    [Setup]
# # #    Case variable set for 74278_A_12
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Modify the COAM parameter with admin API    parameters=${LOCK_GNB1_CELL1}
# # #    Lock Unlock Enb Cell    dist_name=${${enb_dist}}    parameter_name=${enbx2_para}    value=locked
# # #    Set nrcellid suit varaible    cellid=${${nrcellid}}
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Power UE Precondition
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Power UE Precondition
# # #    Log to console    enable 2200 and reset bts
# # #    Prepare testline to cell onair for SA    localFilePath=${swconfig}    tl_scf_filename=${${scf_enable2200}}
# # #    Log to console    enable 2200 good point
# # #    MCS SET    att_value=${@{${att_value}}[0]}    #good_point
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    HBTE PA ON 22R1   ${PA_port_list}    ${PA_values4}
# # #    Check UE attch with 2200 and right beamset num    74278_A12_nglog=${74278_A12_nglog_01}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'    Multi UE Detach And Stop Traffic
# # #    ...    ELSE    Askey UE stop dl traffic on appserver and detach
# # #    Modify temparameter9 and reset gnb
# # #    Check UE attch with 2200 and right beamset num    74278_A12_nglog=${74278_A12_nglog_02}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    MCS teardown    mcs_alias=${mcs_alias}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    MCS teardown    mcs_alias=${mcs_alias}
# # #    [Teardown]    Run Keyword And Ignore Error     Tests Recover
# # #
# # #*** Keywords ***
# # #MCS SET
# # #    [Arguments]    ${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    TOPYONG MCS ON 21B     att_value=${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    HAOJIN MCS ON Trunk    att_value=${att_value}
# # #
# # #SET PHASE
# # #    [Arguments]    ${horizontal_angle_1}    ${horizontal_angle_2}
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${4}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${horizontal_angle_1}    mcs_alias=TPY
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${2}    end_output_port=${3}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${horizontal_angle_2}    mcs_alias=TPY
# # #
# # #TOPYONG MCS ON 21B
# # #    [Arguments]    ${att_value}
# # #    MCS Prepare and set frequency    ip=${topyoung_ip_362}
# # #    Set TOPYOUNG ATT TO LOCK AZQO
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${4}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${0}    mcs_alias=TPY
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${2}    end_output_port=${3}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${-28}    mcs_alias=TPY
# # #    Set TOPYOUNG ATT    att_value=${att_value}
# # #
# # #HAOJIN MCS ON Trunk
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
# # #HBTE MCS ON 22R1
# # #    [Arguments]    ${att_value}
# # #    HBTE MCS Setup    ip=${HBTE_ip_370}
# # #    Set HBTE horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${2}    input_group_id=${None}
# # #    ...    vertical_angle=${96}    horizontal_angle=${-13}    vertical_distance=${1.4}    horizontal_distance=${0.5}    mcs_alias=FC
# # #    Set HBTE horizontal and vertical Phases by output_port    begin_output_port=${3}    end_output_port=${4}    input_group_id=${None}
# # #    ...    vertical_angle=${96}    horizontal_angle=${-3}    vertical_distance=${1.4}    horizontal_distance=${0.5}    mcs_alias=FC
# # #    Set HBTE ATT    att_value=${att_value}
# # #
# # #Analysis 2200 enable
# # #    [Arguments]    ${74278_A12_nglog}
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${74278_A12_nglog}    tshark_path=${tshark_path
# ...}    command_template=${None}
# # #    ${filter_expression}=    Catenate    f1ap.procedureCode == 5
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
# # #    should contain x times    ${nrofPorts}    3    2
# # #    ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
# # #    should contain    ${cdm_Type}    2
# # #    ${density}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.density
# # #    should contain    ${density}    1
# # #    ${n1-n2}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.n1_n2
# # #    should contain    ${n1-n2}    2              # 4x1
# # #
# # #Check UE attch with 2200 and right beamset num
# # #    [Arguments]    ${74278_A12_nglog}
# # #    Start To Capture Wireshark Logs on ASIB    filename=${74278_A12_nglog}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    Multi-UEs attach    ue_num=${ue_num}    attach_mode=${SA_attach_mode}
# # #    ...    ue_mode=${SA_UE_MODE}    nettpye=${SA_nettype}    apn_address=${SA_apn_addr}
# # #    ...    ELSE    Power UE Attach and Verify attach for askey     4g_check=False
# # #    Stop and download wireshark Logs on ASIB    logname=${74278_A12_nglog}
# # #    Analysis 2200 enable    74278_A12_nglog=${74278_A12_nglog}
# # #    Check beamweight for CNI74278    beamweight_name=${${beamweight_name}}    connection=gnb    beamset_num=60
# # #
# # #Tests Recover
# # #    Lock Unlock Enb Cell    dist_name=${${enb_dist}}    parameter_name=${enbx2_para}    value=unlocked
# # #    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
# # #    csn.send command    command=killall tcpdump     connection=gnb
# # #    Connect to TestPc    alias=ute
# # #    csn.send command    command=ps -ef | grep cli |grep ute_common_admin | grep -v grep |awk '{print $2}' |xargs kill -9    connection=ute
# # #    run keyword if    '${release_info}' == '5G21A_GNB_0011'    Askey UE stop dl traffic on appserver and detach
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Askey UE stop dl traffic on appserver and detach
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Askey UE stop dl traffic on appserver and detach
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL1}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    MCS teardown    mcs_alias=${mcs_alias}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    MCS teardown    mcs_alias=${mcs_alias}
# # #    clear cli process
# # #    disconect all connections
