*** Settings ***
Documentation    common keywords for all BIP and Wireshark related features.

Library    BuiltIn
Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem
Library    ../libraries/RRM.py
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot

*** Variables ***
${LUASHARK_PATH}    /home/ute/luashark_script/generated_luashark/luashark.lua

*** Keywords ***
Get Rnti From BIP
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    ...                Get specific RNTI for single attached UE.
    ...                It satisfied crc=0 and dtx=0 in message UlData_PuschReceiveRespHarqU
    [Tags]    5GC000532
    [Arguments]    ${bip_log}    ${rnti_item}=7
    cap.Read Cap    cap_file=${bip_log}    display_filter=uldata_puschreceiverespharqu    X=lua_script:${LUASHARK_PATH}
    ${condition} =     Catenate     UlData_PuschReceiveRespHarqU.grants_item_${rnti_item}.crc == 0x00
    ...               and  UlData_PuschReceiveRespHarqU.grants_item_${rnti_item}.dtx == 0x00
    ${rnti_list} =    cap.Get Element Value    element_expression=UlData_PuschReceiveRespHarqU.grants_item_${rnti_item}.rnti
    ...    element_idx=${0}
    ...    default_value=True
    ...    condition_expression= ${condition}
    ${rnti_length}    Get Length    ${rnti_list}
    Should Be True    ${rnti_length}>${0}    msg=Get RNTI failed from BIP log.
    [Return]    ${rnti_list}[-1]

Check Multi IEs Of Wireshark Log
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    ...                :param IE_list:<List>,List include sub-list.
    ...                                      eg. [[element_expression,element_value,element_idx],[],...]
	[Arguments]    ${wireshark_log}    ${IE_list}    ${display_filter}=f1ap||nr-rrc||ngap    ${condition_expression}=${None}
    ...            ${tshark_path}=/usr/bin/tshark
    ...            ${command_template}={tshark_path} -r {pcap_file} -Y \"${display_filter}\" -T pdml
    ...            ${attribute_name}=show
	cap.load_pcap_file    pcap_file=${wireshark_log}    command_template=${command_template}    alias=parser
    FOR    ${item}    IN     @{IE_list}
        run keyword and continue on failure   cap.filter_packets_by_expression    filter_expression=${condition_expression}
        ...    pcap_parser=parser
        ${res}=    run keyword and continue on failure    cap.get_field_value_by_xpath
        ...    xpath=.//${item}[0]    attribute_name=${attribute_name}    pcap_parser=parser
        ${index}    Set Variable    ${item}[2]
        run keyword and continue on failure    should be equal    ${item}[1]    ${res}[${index}]
        ...                                    msg=Check IE ${item}[0] failed,expect value is ${item}[1],actual value is ${res}[${index}].
    END

Get DL MCS in DlData_PdschsendReq From BIP
    [Documentation]    Auther:jun.8.chen@nokia-sbell.com
    ...                get dl mcs value in message DlData_PdschsendReq
    [Tags]    5GC000517
    [Arguments]    ${bip_log}    ${rnti_item}=7
    ${rnti_value} =    Get Rnti From BIP    bip_log=${bip_log}    rnti_item=${rnti_item}
    cap.Read Cap    cap_file=${bip_log}    display_filter=DlData_PdschSendReq.PdschSendReq.rnti==${rnti_value}
    ...    X=lua_script:${LUASHARK_PATH}
    ${dl_mcs_list} =    cap.Get Element Value    element_expression=DlData_PdschSendReq.PdschSendReq.mcs
    ...    element_idx=${0}
    ...    default_value=True
    [Return]    ${dl_mcs_list}

Get UL MCS in UlData_PuschReceiveReq From BIP
    [Documentation]    Auther:jun.8.chen@nokia-sbell.com
    ...                get ul mcs value in message DlData_PdschsendReq
    [Tags]    5GC000517
    [Arguments]    ${bip_log}    ${rnti_item}=7
    ${rnti_value} =    Get Rnti From BIP    bip_log=${bip_log}    rnti_item=${rnti_item}
    cap.Read Cap    cap_file=${bip_log}    display_filter=UlData_PuschReceiveReq.grants_item_${rnti_item}.rnti==${rnti_value}
    ...    X=lua_script:${LUASHARK_PATH}
    ${ul_mcs_list} =    cap.Get Element Value    element_expression=UlData_PuschReceiveReq.grants_item_${rnti_item}.mcs
    ...    element_idx=${0}
    ...    default_value=True
    [Return]    ${ul_mcs_list}

Verify MCS From BIP
    [Documentation]    Auther:jun.8.chen@nokia-sbell.com
    ...               verify used mcs is used as expected mcs range.
    [Arguments]    ${mcs_list}    ${expect_mcs_list}
    ${mcs_list_latest}     Remove Duplicates    ${mcs_list}
    ${mcs_list_latest}    Evaluate    sorted(${mcs_list_latest})
    ${expect_mcs_list}    Evaluate    sorted(${expect_mcs_list})
    Lists Should Be Equal    ${mcs_list_latest}    ${expect_mcs_list}

Check IE List Value
    [Documentation]    Auther:li.su@nokia-sbell.com
    ...               get the value from the repeated list
    [Tags]    5GC000531
    [Arguments]   ${list}     ${value}
    ${new_list}      remove duplicates      ${list}
    log    ${new_list}
    ${num}=      get length     ${new_list}
    should be equal        ${num}           ${1}
#    should be equal     ${new_list}[0]      ${value}
    should be equal as integers      ${new_list}[0]      ${value}

Change Str List To Int List
    [Documentation]    Auther:li.su@nokia-sbell.com
    ...               change the string list to int list
    [Tags]    5GC000531
    [Arguments]    ${str_list}
    ${int_list} =    Create List
    FOR   ${str_list}    IN     @{str_list}
      ${new_list} =    convert_to_integer       ${str_list}
      Append to list    ${int_list}    ${new_list}
    END
    [Return]     ${int_list}


Verify IE of PdschSendReq Openloop Fixed Rank
    [Documentation]    Auther:li.su@nokia-sbell.com
    ...               verify the fixed rank from the psdch openloop mode
    [Tags]    5GC000531
    [Arguments]        ${bip_log}      ${checked_IE_content}    ${rank}    ${rnti_item}=7
    ${rnti}    Get Rnti From BIP    bip_log=${bip_log}    rnti_item=${rnti_item}
    cap.Read Cap      cap_file=${bip_log}     display_filter=DlData_PdschSendReq.PdschSendReq.rnti==${rnti}    X=lua_script:${LUASHARK_PATH}
    ${PdschSendReq_sfn_list}=    cap.Get Element Value    element_expression=DlData_PdschSendReq.PdschSendReq.sfn
    ...      element_idx=${0}    default_value=True
    ${num_of_sfn}=       get length       ${PdschSendReq_sfn_list}
    ${PdschSendReq_slot_list}=   cap.Get Element Value    element_expression=DlData_PdschSendReq.PdschSendReq.slot
    ...      element_idx=${0}    default_value=True
    ...      condition_expression=${checked_IE_content}
    ${num_of_slot}=      get length     ${PdschSendReq_slot_list}
    should be equal as integers         ${num_of_sfn}             ${num_of_slot}
    ${PdschSendReq_numOfLayers}=   cap.Get Element Value    element_expression=DlData_PdschSendReq.PdschSendReq.numOfLayers
    ...      element_idx=${0}    default_value=True
    Check IE list value       ${PdschSendReq_numOfLayers}           ${rank}
