# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation
# # #...    author: kk
# # #...    contact:kk.wang@nokia-sbell.com
# # #...    squad group: SG_03
# # #...    feature : 5GC002200
# # #
# # #
# # #Suite Setup    Run Keywords
# # #...    Run Keywords    Common Suite Setup for COAM
# # #...    AND    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    ASKEY UE parameter setup
# # #...    AND    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    ASKEY UE parameter setup
# # #
# # #Suite Teardown      Run Keyword And Ignore Error     Common Suite Teardown for COAM
# # #
# # #Resource       Resources/5GC002200_coam_common_keywords.robot
# # #Variables      Resources/variables.py
# # #
# # #*** Variables ***
# # #${TL362_scf_74278_A_03}            TL362_GNB_CNI74278_A03.xml
# # #${TL365_scf_74278_A_03}            TL365_GNB_CNI74278_A03.xml
# # #${TL370_scf_74278_A_03}            TL370_GNB_CNI74278_A03.xml
# # #${eNB_scf_file}                    TL370_ENB_SCF.xml
# # #${swconfig}                        /opt/workspace/SCF/2200/swconfig/swconfig.txt
# # #@{TL362_dl_enable}                 1000    600
# # #@{TL365_dl_enable}                 700    100
# # #@{TL370_dl_enable}                 200    20
# # #${74278_A03_NGlog}                 74278_A03_wireshark.pcap
# # #${ASKEY_DL_PORT}                   ${ue_param['data_transfer']['iperf_options']['qci'][5]}
# # #${ASKEY_UL_PORT}                   ${ue_param['data_transfer']['iperf_options']['qci'][6]}
# # #@{att_value_TL362}                 25    40    90    127
# # #@{att_value_TL365}                 0    50    90    127
# # #@{att_value_TL370}                 25    50    90    127
# # #${filter_pdschsendreq}     dldata_pdschsendreq
# # #${CMD_pdschsendreq}       {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y  \"${filter_pdschsendreq}\" -T pdml
# # #${ue_num}    1
# # #
# # ###21B test on TL362##
# # ###trunk test on TL365##
# # ###22R1 test on TL370##
# # #
# # #*** Test Cases ***
# # #[1]CNI74278_A_03_NSA_max_DL_Tput_with_4CSI-RS_4x1_#2#2_1_5_BW_100M_1070
# # #    [Documentation]
# # #    ...    The purpose of this test case is to verify cell on air after NIDD NRCELL.csirsResourceSetConfig4CRI set to 4x1_#2#2_1_5
# # #    ...    And DL can get peak tput with the right beamweight.
# # #    ...    n1-n2 shoud be 4x1; tmpParam9=1135;beamset= (4+2+1)x(4+16)=140;
# # #    ...    trunk csirsResourceSetConfig4CRI = 4x1-2-2_1_5;
# # #    [Tags]      classical    CRT_22R2    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
# # #    [Timeout]    1 hour
# # #    [Setup]
# # #    Case variable set for 74278_A_03
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Commission SCF to eNB
# # #    ...           eNB_asik_addr=${ENB_ADDRESS}    connection=eNB    scf_file=${eNB_scf_file}
# # #    Prepare testline to cell onair for NSA    localFilePath=${swconfig}    tl_scf_filename=${${scf_enable2200}}    enbx2_dist=${${enbx2_dist}}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Modify the COAM parameter with admin API    parameters=${LOCK_GNB1_CELL1}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Connect and Modify the parameter on enblte    dist_name=${TL362_enb_dist}
# # #    ...    parameter=${defaultgnbcell}    value=1
# # #    Set nrcellid suit varaible    cellid=${${nrcellid}}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Power UE Precondition
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Power UE Precondition
# # #    MCS SET    att_value=${@{${att_value}}[0]}
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    HBTE PA ON 22R1   ${PA_port_list}    ${PA_values4}
# # #    wait until keyword succeeds    2min    10s    Start To Capture Wireshark Logs on ASIB    filename=${74278_A03_NGlog}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    Multi-UEs attach    ue_num=${ue_num}    attach_mode=${NSA_attach_mode}
# # #    ...    ue_mode=${NSA_UE_MODE}    nettpye=${NSA_nettype}    apn_address=${NSA_apn_addr}
# # #    ...    ELSE    Power UE Attach and Verify attach for askey     4g_check=True
# # #    Stop and download wireshark Logs on ASIB    logname=${74278_A03_NGlog}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    power_ue.Start traffic    ue_index=${0}    direction=dl
# # #    ...    apn_address=${NSA_apn_addr}    throughput=${Multi_dl_throughput}    duration=1200    ue_type=${UE_TYPE}    ue_mode=${NSA_UE_MODE}
# # #    ...    ELSE    Start DL date transfer on appserver     traffic=${dl_throughput}
# # #    Power UE check throughput with nrcellid    cellid=${${nrcellid}}    dlexpect=${@{${Expect_dl_enable}}[0]}
# # #    sleep     5s
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'    Multi UE Detach And Stop Traffic
# # #    ...    ELSE    Askey UE stop dl traffic on appserver and detach
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    MCS teardown    mcs_alias=${mcs_alias}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    MCS teardown    mcs_alias=${mcs_alias}
# # #    Analysis 2200 enable
# # #    Check beamweight for CNI74278    beamweight_name=${${beamweight_name}}    connection=gnb    beamset_num=140
# # #    [Teardown]       Run Keyword And Ignore Error     Tests Recover
# # #
# # #*** Keywords ***
# # #MCS SET
# # #    [Arguments]    ${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'     TOPYONG MCS ON TL362     att_value=${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    HAOJIN MCS ON TL365    att_value=${att_value}
# # ##    run keyword if    '${release_info}' == '5G21A_GNB_0011'       HBTE MCS ON TL370        att_value=${att_value}
# # ##    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'       HBTE MCS ON TL370        att_value=${att_value}
# # #
# # #SET MCS ATT
# # #    [Arguments]    ${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'     Set TOPYOUNG ATT for RANK2    att_value=${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    Set HAOJIN Port13 to Port16 ATT    att_value=${att_value}
# # #    run keyword if    '${release_info}' == '5G21A_GNB_0011'       Set HBTE ATT for RANK2    att_value=${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'       Set HBTE ATT for RANK2    att_value=${att_value}
# # #
# # #Set TOPYOUNG ATT for RANK2
# # #    [Arguments]    ${att_value}
# # #    Set Odd ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=${att_value}    B_Odd=True
# # #    Set Even ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=90    B_Odd=True
# # #    Set Odd ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=90    B_Odd=False
# # #    Set Even ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=90    B_Odd=False
# # #    Set Odd ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=True
# # #    Set Even ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=True
# # #    Set Odd ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=False
# # #    Set Even ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=${att_value}    B_Odd=False
# # #
# # #Set HAOJIN ATT for RANK2
# # #    [Arguments]    ${att_value}
# # #    Set HAOJIN Odd ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=${att_value}    B_Odd=True
# # #    Set HAOJIN Even ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=90    B_Odd=True
# # #    Set HAOJIN Odd ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=90    B_Odd=False
# # #    Set HAOJIN Even ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=${att_value}    B_Odd=False
# # #    Set HAOJIN Odd ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=True
# # #    Set HAOJIN Even ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=True
# # #    Set HAOJIN Odd ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=False
# # #    Set HAOJIN Even ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=False
# # #
# # #Set HBTE ATT for RANK2
# # #    [Arguments]    ${att_value}
# # #    Set HBTE Odd ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=90    B_Odd=True
# # #    Set HBTE Even ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=90    B_Odd=True
# # #    Set HBTE Odd ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=90    B_Odd=False
# # #    Set HBTE Even ATT By Output_port    begin_output_port=1    end_output_port=2    attenuation=90    B_Odd=False
# # #    Set HBTE Odd ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=True
# # #    Set HBTE Even ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=${att_value}    B_Odd=True
# # #    Set HBTE Odd ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=${att_value}    B_Odd=False
# # #    Set HBTE Even ATT By Output_port    begin_output_port=3    end_output_port=4    attenuation=90    B_Odd=False
# # #
# # #TOPYONG MCS ON TL362
# # #    [Arguments]    ${att_value}
# # #    MCS Prepare and set frequency    ip=${topyoung_ip_362}
# # #    Set TOPYOUNG ATT TO LOCK AZQO
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${4}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${-6}    mcs_alias=TPY
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${2}    end_output_port=${3}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${6}    mcs_alias=TPY
# # #    Set TOPYOUNG ATT    att_value=${att_value}
# # #
# # #HAOJIN MCS ON TL365
# # #    [Arguments]    ${att_value}
# # #    HAOJIN MCS Prepare    ip=${haojin_ip_365}
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${13}    end_output_port=${14}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${6}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep    5s
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${15}    end_output_port=${16}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${-6}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
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
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${74278_A03_NGlog}    tshark_path=${tshark_path}
# # #    ...    command_template=${None}
# # #    ${filter_expression}=    Catenate    x2ap.procedureCode == 27
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
# # #    should contain x times    ${nrofPorts}    3    4
# # #    ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
# # #    should contain    ${cdm_Type}    2
# # #    ${density}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.density
# # #    should contain    ${density}    1
# # #    ${n1-n2}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.n1_n2
# # #    should contain    ${n1-n2}    2    # 4x1
# # #
# # #Analysis BIP
# # #    [Arguments]     ${BIP_log}     ${rank}     ${QAM}
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${BIP_log}    tshark_path=${tshark_path}
# # #    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${CMD_pdschsendreq}
# # #    ${filter_expression}=    Catenate    dldata_pdschsendreq
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${numOfLayers}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...    xpath=.//DlData_PdschSendReq.grants_item_15.numOfLayers
# # #    should contain    ${numOfLayers}    ${rank}
# # ##    ${modulationOrder}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # ##    ...    xpath=.//DlData_PdschSendReq.grants_item_15.modulationOrder
# # ##    should contain    ${modulationOrder}    ${QAM}
# # #
# # #Analysis BIP trunk
# # #    [Arguments]     ${BIP_log}     ${rank}     ${QAM}
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${BIP_log}    tshark_path=${tshark_path}
# # #    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${CMD_pdschsendreq}
# # #    ${filter_expression}=    Catenate    dldata_pdschsendreq
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${numOfLayers}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...    xpath=.//DlData_PdschSendReq.grants_item_0.numOfLayers
# # #    should contain    ${numOfLayers}    ${rank}
# # ##    ${modulationOrder}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # ##    ...    xpath=.//DlData_PdschSendReq.grants_item_0.modulationOrder
# # ##    should contain    ${modulationOrder}    ${QAM}
# # #
# # #Tests Recover
# # ##    run keyword if    '${release_info}' == 'SBTS21B'    Connect and Modify the parameter on enblte    dist_name=${TL362_enb_dist}
# # ##    ...    parameter=${defaultgnbcell}    value=0
# # ##    run keyword if    '${release_info}' == '5G20B'    Connect and Modify the parameter on enblte    dist_name=${TL362_enb_dist}
# # ##    ...    parameter=${defaultgnbcell}    value=0
# # #    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
# # #    csn.send command    command=killall tcpdump     connection=gnb
# # #    run keyword if    '${release_info}' == '5G21A_GNB_0011'    Askey UE stop dl traffic on appserver and detach
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Askey UE stop dl traffic on appserver and detach
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Askey UE stop dl traffic on appserver and detach
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL1}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    MCS teardown    mcs_alias=${mcs_alias}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    MCS teardown    mcs_alias=${mcs_alias}
# # #    clear cli process
# # #    disconect all connections
# # ##    Run keyword and continue on failure    CI_interface.Common Case Teardown
