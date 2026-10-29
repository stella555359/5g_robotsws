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
# # #...    Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
# # #...                            ASKEY UE parameter setup
# # #
# # #Suite Teardown      Run Keyword And Ignore Error     Common Suite Teardown for COAM
# # #
# # #Resource       Resources/5GC002200_coam_common_keywords.robot
# # #Variables      Resources/variables.py
# # #
# # #*** Variables ***
# # #${TL362_disable}          TL362_GNB_2200_Disable_B004.xml
# # #${TL362_enable}           TL362_GNB_2200_Enable_B004.xml
# # #${TL365_disable}          TL365_GNB_2200_Disable_B004.xml
# # #${TL365_enable}           TL365_GNB_2200_Enable_B004.xml
# # #${swconfig}                 /opt/workspace/SCF/2200/swconfig/swconfig.txt
# # #${ASKEY_DL_PORT}              ${ue_param['data_transfer']['iperf_options']['qci'][5]}
# # #${ASKEY_UL_PORT}              ${ue_param['data_transfer']['iperf_options']['qci'][6]}
# # #${2200_B_nglog}           2200_B_wireshark_enable.pcap
# # #@{TL362_dl_enable}          900
# # #@{TL362_dl_disable}         900
# # #@{TL365_dl_enable}          700
# # #@{TL365_dl_disable}         700
# # #@{att_value_TL362}         25    70    90    127
# # #@{att_value_TL365}         5    70    90    127
# # #
# # #
# # #
# # ###20B test on TL363##
# # ###TRUNK test on TL365##
# # #
# # #*** Test Cases ***
# # #[1]5GC002200_B_004_max_DL_Tput_with_4_resources_and_beamset_6_good_condition_1208_frametype_SA
# # #    [Documentation]
# # #    ...    this test case is to verify 8TRX(1*4*2) RU can do DL data transfer successfully when 2200 feature enable
# # #    ...    in good air condition(around -60dbm). DL tput can achieve to peak throughput and compare with DL tput when
# # #    ...    1856 enabled, There should be a little more or equal for the cell throughput with the same radio condition
# # #    ...    (good radio condition), if there is a bler, it should be a little less or equal to the bler of 1856 enabled.
# # #    ...    It can be no need be better(better will be good), but it should be commit no aggravate.
# # #    [Tags]
# # #    [Timeout]    1 hour
# # #    [Setup]
# # #    Case variable set for 2200_B_004
# # #    Prepare testline to cell onair for SA    localFilePath=${swconfig}    tl_scf_filename=${${scf_disable2200}}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Modify the COAM parameter with admin API    parameters=${LOCK_GNB1_CELL1}
# # #    Lock Unlock Enb Cell    dist_name=${${enb_dist}}    parameter_name=${enbx2_para}    value=locked
# # #    Set nrcellid suit varaible    cellid=${${nrcellid}}
# # #    Power UE Precondition
# # #    MCS SET1    att_value=${@{${att_value}}[0]}     #good_point
# # #    Power UE Attach and Verify attach for askey     4g_check=False
# # #    Start DL date transfer on appserver     traffic=${dl_throughput}
# # #    ${disable2200_tp_B004}      Power UE check throughput with nrcellid    cellid=${${nrcellid}}    dlexpect=${@{${Expect_dl_disable}}[0]}
# # #    Set test variable       ${disable2200_tp_B004}
# # #    sleep    2s
# # #    Askey UE stop dl traffic on appserver and detach
# # #    Log to console    enable 2200 and reset bts
# # #    Prepare testline to cell onair for SA    localFilePath=${swconfig}    tl_scf_filename=${${scf_enable2200}}
# # #    MCS SET2    att_value=${@{${att_value}}[0]}
# # #    Start To Capture Wireshark Logs on ASIB    filename=${2200_B_nglog}
# # #    Power UE Attach and Verify attach for askey     4g_check=False
# # #    Start DL date transfer on appserver     traffic=${dl_throughput}
# # #    Stop And Download Wireshark Logs On ASIB    logname=${2200_B_nglog}
# # #    ${enable2200_tp_B004}=      Power UE check throughput with nrcellid    cellid=${${nrcellid}}    dlexpect=${@{${Expect_dl_enable}}[0]}
# # #    set test variable       ${enable2200_tp_B004}
# # #    sleep    2s
# # #    Askey UE stop dl traffic on appserver and detach
# # #    MCS teardown    mcs_alias=${mcs_alias}
# # #    Analysis 2200 enable
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL2}
# # #    ${tput_check} =    BuiltIn.Evaluate    float(${enable2200_tp_B004}/${disable2200_tp_B004})
# # #    should be true    0.9<=${tput_check}<=1.5
# # #    [Teardown]    Run Keyword And Ignore Error     Tests Recover
# # #
# # #
# # #*** Keywords ***
# # #MCS SET1
# # #    [Arguments]    ${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    TOPYONG MCS ON TL362     att_value=${att_value}
# # #    ...    ELSE    HAOJIN MCS ON TL365    att_value=${att_value}
# # #
# # #MCS SET2
# # #    [Arguments]    ${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    TOPYONG MCSSET ON TL362     att_value=${att_value}
# # #    ...    ELSE    HAOJIN MCSSET ON TL365    att_value=${att_value}
# # #
# # #TOPYONG MCS ON TL362
# # #    [Arguments]    ${att_value}
# # #    MCS Prepare and set frequency    ip=${topyoung_ip_362}
# # #    Set TOPYOUNG ATT TO LOCK AZQO
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${2}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${-6}    mcs_alias=TPY
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${3}    end_output_port=${4}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${-10}    mcs_alias=TPY
# # #    Set TOPYOUNG ATT    att_value=${att_value}
# # #
# # #TOPYONG MCSSET ON TL362
# # #    [Arguments]    ${att_value}
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${2}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${-6}    mcs_alias=TPY
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${3}    end_output_port=${4}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${-10}    mcs_alias=TPY
# # #    Set TOPYOUNG ATT    att_value=${att_value}
# # #
# # #HAOJIN MCS ON TL365
# # #    [Arguments]    ${att_value}
# # #    HAOJIN MCS Prepare    ip=${haojin_ip_365}
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${2}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${27}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep    5s
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${3}    end_output_port=${4}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${13}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep    5s
# # #    Set HAOJIN ATT    att_value=${att_value}
# # #
# # #HAOJIN MCSSET ON TL365
# # #    [Arguments]    ${att_value}
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${2}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${27}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep    5s
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${3}    end_output_port=${4}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${13}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep    5s
# # #    Set HAOJIN ATT    att_value=${att_value}
# # #
# # #Analysis 2200 enable
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${2200_B_nglog}    tshark_path=${tshark_path}
# # #    ...    command_template=${None}
# # #    ${filter_expression}=    Catenate    f1ap.procedureCode == 5
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
# # #    should contain X times    ${nrofPorts}    3    4
# # #    ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
# # #    should contain    ${cdm_Type}    2
# # #    ${density}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.density
# # #    should contain    ${density}    1
# # #    ${n1-n2}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.n1_n2
# # #    should contain    ${n1-n2}    1
# # #
# # #Tests Recover
# # #    Lock Unlock Enb Cell    dist_name=${${enb_dist}}    parameter_name=${enbx2_para}    value=unlocked
# # #    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
# # #    csn.send command    command=killall tcpdump     connection=gnb
# # #    Connect to TestPc    alias=ute
# # #    csn.send command    command=ps -ef | grep cli |grep ute_common_admin | grep -v grep |awk '{print $2}' |xargs kill -9    connection=ute
# # #    Run Keyword And Ignore Error    Askey UE stop dl traffic on appserver and detach
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000'    Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL1}
# # #    MCS teardown    mcs_alias=${mcs_alias}
# # #    clear cli process
# # #    disconect all connections
