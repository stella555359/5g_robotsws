*** Settings ***
Documentation
...   This is for 2169 TA common keywords
...   squad group: MMW_SG1

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    ./5GC002169_Variables.robot
Variables   ../TestData/5GC002169_scf_modify.py

*** Variables ***
${TSHARK_PATH}            /usr/bin/tshark
${PDML_CONVERT_X2AP_TEMPLATE}      {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml

*** Keywords ***
Verify ul and dl scell number
    [Arguments]    ${file_path}   ${expected_ul_scell_number}    ${expected_dl_scell_number}
    [Documentation]    Author: Wang Yixiang
    ${expected_ul_scell_list}    string_list.string2list    ${expected_ul_scell_number}
    ${expected_dl_scell_list}    string_list.string2list    ${expected_dl_scell_number}

    ${SgNB_add_req_ack_packets}    ${list_ue_id}    Get ue id list    file_path=${file_path}
    log to console    ${list_ue_id}
    FOR    ${ue_id}   IN    @{list_ue_id}
        Verify expected dl scell    ue_id=${ue_id}    expected_dl_scell_list=${expected_dl_scell_list}
        ...    SgNB_add_req_ack_packets=${SgNB_add_req_ack_packets}
        Verify expected ul scell    ue_id=${ue_id}    expected_ul_scell_list=${expected_ul_scell_list}
        ...    SgNB_add_req_ack_packets=${SgNB_add_req_ack_packets}
    END

Verify expected dl scell
    [Arguments]    ${ue_id}    ${expected_dl_scell_list}    ${SgNB_add_req_ack_packets}
    [Documentation]    Author: Wang Yixiang
    ${dl_scell_len}    get length    ${expected_dl_scell_list}
    ${actual_dl_number}    Count element in pdml file    pdml_format_file=${SgNB_add_req_ack_packets}
    ...    element_filter=.//nr-rrc.sCellConfigCommon_element/nr-rrc.downlinkConfigCommon_element
    ...    filter_expression=nr-rrc.newUE_Identity == ${ue_id}
    run keyword and continue on failure    should be equal as integers   ${actual_dl_number}    ${dl_scell_len}
    ...    The dl scell number in pcap file is ${actual_dl_number}, while expect value is ${dl_scell_len}.

Verify expected ul scell
    [Arguments]    ${ue_id}    ${expected_ul_scell_list}    ${SgNB_add_req_ack_packets}
    [Documentation]    Author: Wang Yixiang
    ${ul_scell_len}    get length    ${expected_ul_scell_list}
    ${actual_ul_number}    Count element in pdml file    pdml_format_file=${SgNB_add_req_ack_packets}
    ...    element_filter=.//nr-rrc.sCellConfigCommon_element/nr-rrc.uplinkConfigCommon_element
    ...    filter_expression=nr-rrc.newUE_Identity == ${ue_id}
    run keyword and continue on failure    should be equal as integers   ${actual_ul_number}    ${ul_scell_len}
    ...    The ul scell number in pcap file is ${actual_ul_number}, while expect value is ${ul_scell_len}.

Get ue id list
    [Documentation]   Author: Ren Biyao
    ...               This keyword is to get all ue ids from x2 log.
    [Arguments]    ${file_path}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${file_path}    tshark_path=${TSHARK_PATH}    command_template=${PDML_CONVERT_X2AP_TEMPLATE}
    ${SgNB_add_req_ack_packets}    cap.filter_packets_by_expression
    ...    filter_expression=x2ap.SgNBAdditionRequestAcknowledge_element
    ${list_ue_id}    cap.get_field_value_by_xpath    pdml_list=${SgNB_add_req_ack_packets}    xpath=.//nr-rrc.newUE_Identity
    [Return]    ${SgNB_add_req_ack_packets}    ${list_ue_id}

Count element in pdml file
    [Arguments]    ${pdml_format_file}    ${element_filter}    ${filter_expression}    ${element_attribute}=showname
    [Documentation]    Author: Ren Biyao
    ...                This keyword is used to verify the value in pcap file match the value set in bts.
    ...                ${pdml_format_file} is converted from pcap file.
    ...                ${filter_expression} is legal expression which can be applied in origial pcap file, eg, x2ap ...
    ...                ${element_filter} is the expression of the information element, eg .//nr-rrc.sCellToAddModList
    ...                ${element_attribute} is attribute of packet field, value can be "show", "value", or "showname",
    ${filtered_packets}    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${content}    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=${element_filter}    attribute_name=${element_attribute}
    ${content_number}    get length    ${content}
    [Return]    ${content_number}
