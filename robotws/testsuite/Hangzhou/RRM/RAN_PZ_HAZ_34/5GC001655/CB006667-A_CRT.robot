*** Settings ***
Documentation     author: Bijiajian
...               contact: Jiajian.bi@nokia-sbell.com
...               squad group: SG_02
Force Tags        5G_RRM
...    PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Resource          Resources/1347_common_keyword.robot
Variables         Resources/2537_variables.py
Library    taf.analyzer.pcap        WITH NAME    pcap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/gnb_ru.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${scf_path}       /home/ute/Downloads/SCF
${scf_file_path}    ${scf_path}/common.xml
@{beam_set_6_horizontal}    -35    -35    -20    -20    -7    -7    7    7    20    20    35    35    -35    -35    -20    -20
@{Beamset3_1_horizontal}    -26    -26    0    0    26    26    0    0    -26    -26    0    0    26    26    0    0
@{beam_set_6_vertical}    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96
@{Beamset3_1_vertical}    96    96    96    96    96    96    102    102    96    96    96    96    96    96    102    102
${6667_20m_1subcell}    ${scf_path}/CB006667_20M_1subcell.xml
${6667_20m_2subcell}    ${scf_path}/CB006667_20M_2subcell.xml
${6667_100m_1subcell}    ${scf_path}/CB006667_100M_1subcell.xml
${6667_100m_2subcell}    ${scf_path}/CB006667_100M_2subcell.xml
${tshark_path}    /usr/bin/tshark
${luashark_path_21A}    /home/ute/Downloads/Lua/generated_luashark/luashark.lua
${luashark_path_TRUNK}    /home/ute/Downloads/Lua/generated_luashark_SBTS22R2/luashark.lua
${expression_cmas_ul}    \"uldata_puschreceivereq\"
${command_template_ul_21A}    {tshark_path} -r {input_file} -X lua_script:${luashark_path_21A} -Y ${expression_cmas_ul} -T pdml > {output_file}
${command_template_ul_TRUNK}    {tshark_path} -r {input_file} -X lua_script:${luashark_path_TRUNK} -Y ${expression_cmas_ul} -T pdml > {output_file}
${expression_cmas_dl}    \"dldata_pdschsendreq\"
${command_template_dl_21A}    {tshark_path} -r {input_file} -X lua_script:${luashark_path_21A} -Y ${expression_cmas_dl} -T pdml > {output_file}
${command_template_dl_TRUNK}    {tshark_path} -r {input_file} -X lua_script:${luashark_path_TRUNK} -Y ${expression_cmas_dl} -T pdml > {output_file}
${pdsch_sfn_filed_name}    DlData_PdschSendReq.PdschSendReq.sfn
${pdsch_slot_filed_name}    DlData_PdschSendReq.PdschSendReq.slot
${pdsch_rnti_filed_name_21A}    DlData_PdschSendReq.grants_item_15.rnti
${pdsch_rnti_filed_name_TRUNK}    DlData_PdschSendReq.grants_item_0.rnti
${pdsch_pid_filed_name}    DlData_PdschSendReq.patternId.patternId_item_0
${pusch_sfn_filed_name_xpath}    UlData_PuschReceiveReq.PuschReceiveReq.sfn
${pusch_slot_filed_name_xpath}    UlData_PuschReceiveReq.PuschReceiveReq.slot
${pusch_rnti_filed_name_xpath_21A}    .//UlData_PuschReceiveReq.grants_item_15.rnti
${pusch_rnti_filed_name_xpath_TRUNK}    .//UlData_PuschReceiveReq.grants_item_0.rnti
${pusch_pid_filed_name_xpath}    .//UlData_PuschReceiveReq.patternId.patternId_item_0

*** Test Cases ***
CB006667_20M_1SUBCELL
    [Tags]    5GC006667
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${beam_set_6_horizontal}    vertical_set=${beam_set_6_vertical}
    Set Test Variable    ${ue_num}    ${16}
    Reload Case SCF and Commission    scf_file=${6667_20m_1subcell}
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Common Capture BIP log and download
    Check DL UL Throughput On Site
    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=15    num=${ue_num}
    sleep    15min
    ${counter1}    Check BTS Counters via webUI    counter_id=M55308C17002
    ${counter2}    Check BTS Counters via webUI    counter_id=M55308C18002
    Should Contain    ${counter1}    8
    Should Contain    ${counter2}    8
    Check Value for 2537-H    number=8
    [Teardown]    Case Teardown

CB006667_20M_2SUBCELL
    [Tags]    5GC006667
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${beam_set_6_horizontal}    vertical_set=${beam_set_6_vertical}
    Set Test Variable    ${ue_num}    ${16}
    Reload Case SCF and Commission    scf_file=${6667_20m_2subcell}
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Common Capture BIP log and download
    Check DL UL Throughput On Site
    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=15    num=${ue_num}
    sleep    15min
    ${counter1}    Check BTS Counters via webUI    counter_id=M55308C17002
    ${counter2}    Check BTS Counters via webUI    counter_id=M55308C18002
    Should Contain    ${counter1}    8
    Should Contain    ${counter2}    8
    [Teardown]    Case Teardown

CB006667_100M_1SUBCELL
    [Tags]    5GC006667
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${beam_set_6_horizontal}    vertical_set=${beam_set_6_vertical}
    Set Test Variable    ${ue_num}    ${16}
    Reload Case SCF and Commission    scf_file=${6667_100m_1subcell}
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Common Capture BIP log and download
    Check DL UL Throughput On Site
    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=50    num=${ue_num}
    sleep    15min
    ${counter1}    Check BTS Counters via webUI    counter_id=M55308C17002
    ${counter2}    Check BTS Counters via webUI    counter_id=M55308C18002
    Should Contain    ${counter1}    16
    Should Contain    ${counter2}    16
    Check Value for 2537-H
    [Teardown]    Case Teardown

CB006667_100M_2SUBCELL
    [Tags]    5GC006667
    [Setup]    Case Setup
    MCS Set angle    horizontal_set=${beam_set_6_horizontal}    vertical_set=${beam_set_6_vertical}
    Set Test Variable    ${ue_num}    ${16}
    Reload Case SCF and Commission    scf_file=${6667_100m_2subcell}
    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    5s
    Common Capture BIP log and download
    Check DL UL Throughput On Site
    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=50    num=${ue_num}
    sleep    15min
    ${counter1}    Check BTS Counters via webUI    counter_id=M55308C17002
    ${counter2}    Check BTS Counters via webUI    counter_id=M55308C18002
    Should Contain    ${counter1}    16
    Should Contain    ${counter2}    16
    [Teardown]    Case Teardown

*** Keywords ***
Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Run keyword if    'SBTS22R2' in ${result}    set test variable    ${command_template_ul}    ${command_template_ul_TRUNK}
    ...    ELSE    set test variable    ${command_template_ul}    ${command_template_ul_21A}
    Run keyword if    'SBTS22R2' in ${result}    set test variable    ${command_template_dl}    ${command_template_dl_TRUNK}
    ...    ELSE    set test variable    ${command_template_dl}    ${command_template_dl_21A}
    Run keyword if    'SBTS22R2' in ${result}    set test variable    ${pdsch_rnti_filed_name}    ${pdsch_rnti_filed_name_TRUNK}
    ...    ELSE    set test variable    ${pdsch_rnti_filed_name}    ${pdsch_rnti_filed_name_21A}
    Run keyword if    'SBTS22R2' in ${result}    set test variable    ${pusch_rnti_filed_name_xpath}    ${pusch_rnti_filed_name_xpath_TRUNK}
    ...    ELSE    set test variable    ${pusch_rnti_filed_name_xpath}    ${pusch_rnti_filed_name_xpath_21A}
    robot_common_operations.Common Suite Setup

Case Teardown
    Run keyword and ignore error    Multi UE Detach And Stop Traffic
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown
    robot_common_operations.Common Suite Teardown

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Multi UE Detach And Stop Traffic
    FOR    ${ue_no}    IN RANGE    ${ue_num}
        Run Keyword And Continue On Failure    Common Stop traffic    direction=dl    ue_index=${ue_no}    ue_mode=NSA
        Run Keyword And Continue On Failure    Common Stop traffic    direction=ul    ue_index=${ue_no}    ue_mode=NSA
        Run Keyword And Continue On Failure    Common UE Detach    ue_index=${ue_no}
    END

Multi UE Attach And Send DL Traffic
    [Arguments]    ${send_traffic_dl}=200MKbits/sec    ${send_duration}=3600    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        Common UE Attach    ue_index=${ue_no}    attach_mode=5G_NSA
        sleep    3s
        Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_dl}
        ...    send_duration=${send_duration}    ue_mode=NSA
    END

Multi UE Attach And Send Traffic
    [Arguments]    ${send_traffic_ul}=20MKbits/sec    ${send_traffic_dl}=200MKbits/sec    ${send_duration}=3600    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        Run Keyword And Continue On Failure    Common UE Attach    ue_index=${ue_no}    attach_mode=5G_NSA
        sleep    3s
        Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_ul}
        ...    send_duration=${send_duration}    ue_mode=NSA
        Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_dl}
        ...    send_duration=${send_duration}    ue_mode=NSA
    END

Check DL UL Throughput On Site
    [Arguments]
    run keyword and ignore error    power_ue.Check throughput    ue_type=huawei    direction=ul    throughput=0
    run keyword and ignore error    power_ue.Check throughput    ue_type=huawei    direction=dl    throughput=0

Multi UE Check DL Tput
    [Arguments]    ${check_traffic_dl}=100    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        Run Keyword And Continue On Failure    Common UE Check DL Tput    ue_index=${ue_no}
        ...    check_traffic=${check_traffic_dl}    ue_mode=NSA
    END

Multi UE Check Tput
    [Arguments]    ${check_traffic_ul}=5    ${check_traffic_dl}=50    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        Run Keyword And Continue On Failure    Common UE Check UL And DL Tput    ue_index=${ue_no}
        ...    check_traffic_ul=${check_traffic_ul}    check_traffic_dl=${check_traffic_dl}
    END

Check Value for 2537-H
    [Arguments]    ${pcap_file}=${bip_log_path}    ${number}=16
    ${packets}    Load BIP Log with Template Command    pcap_file=${pcap_file}    command_template=${command_template_dl}
    Check Item Num Per Slot    field_name_sfn=${pdsch_sfn_filed_name}    field_name_slot=${pdsch_slot_filed_name}
    ...    item_name=${pdsch_rnti_filed_name}    target_item_num=${number}
    ${packets}    Load BIP Log with Template Command    pcap_file=${pcap_file}    command_template=${command_template_ul}
    Check Item Num Per Slot   field_name_sfn=${pusch_sfn_filed_name_xpath}   field_name_slot=${pusch_slot_filed_name_xpath}
    ...    item_name=${pusch_rnti_filed_name_xpath}    target_item_num=${number}
