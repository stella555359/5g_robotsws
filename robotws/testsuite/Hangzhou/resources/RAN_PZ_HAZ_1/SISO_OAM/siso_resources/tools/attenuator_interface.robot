*** Settings ***
Documentation    This file is for  for siso cloud related cases
...              Please do not modify the file without notification to author
...              Author: Zhou Qiang
...              Contact: qiang.1.zhou@nokia-sbell.com
...              Squad: SRAN HZ SISO

Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Library   XML    use_lxml=${True}
Library  ./attenuator_analyzer.py



*** Keywords ***
Set Attenuation Value
    [Arguments]    ${vendor}    ${model}     ${ip}    ${port}    ${channels}   ${values}   ${min}    ${max}
    Log    ${min}
    ${device}   attenuator.setup_attenuator
    ...    ip_addr=${ip}
    ...    port=${port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=${vendor}
    ...    model=${model}
    ...    alias=${ip}
    #...    min_attenuation=${min}
    ...    max_attenuation=${max}
    ${channel_count}   Get Length    ${channels}

    FOR  ${channel_index}  IN RANGE    ${channel_count}
        ${port}   EVALUATE  int(${channels[${channel_index}]})
        ${value}    EVALUATE    ${values[${channel_index}]}
        attenuator.set_attenuation    port=${port}
        ...    value=${value}   attenuator_device=${device}
        Run Keyword And Ignore Error    attenuator.read_attenuation     port=${port}
        ...    attenuator_device=${device}
    END
    #\    should be equal as integers     ${new_value}    ${values[${channel_index}]}
    [Teardown]    attenuator.disconnect     ${device}

Get PA Info With Pipe Id
    [Arguments]     ${RF_serial_num}   ${pipes}
    ${pa_list}    Create List
    ${pa}
    FOR   ${pipe}    IN    ${pipes}
         ${port}=    XML.evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
         ...  //Unit[@Type="FR"][@SerialNumber="${RF_serial_num}"]/Attenuator[@PipeNumber="${pipe}"]/@Port
         ${pa_num}=     XML.evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
         ...  //Unit[@Type="FR"][@SerialNumber="${RF_serial_num}"]/Attenuator[@PipeNumber="${pipe}"]/@Number
         ${enable_value}=     XML.evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
         ...  //Unit[@Type="FR"][@SerialNumber="${RF_serial_num}"]/Attenuator[@PipeNumber="${pipe}"]/@Enable
         ${disable_value}=     XML.evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
         ...  //Unit[@Type="FR"][@SerialNumber="${RF_serial_num}"]/Attenuator[@PipeNumber="${pipe}"]/@Disable
         ${ip}=    XML.evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
         ...   //Unit[@Type="ATT"][@Number="${pipe}"]/Attenuator/@IP
    END
     [Return]     ${pa_id}    ${port}     ${enable_value}    ${disable_value}


Set PA Values
    [Arguments]   ${RF_list}    ${function}=enable
    ${out_is_define_testline_desc}    Run Keyword And Return Status
    ...    Variable Should Not Exist    ${GLO_TL_DESCRIPTOR_FILE_PATH}

    Return From Keyword If    ${out_is_define_testline_desc}
    FOR    ${RF_info}   IN    @{RF_list}
        ${RF_serial_num}    Set Variable   ${RF_info["serialNumber"]}
        @{pipe_num}    Set Variable    ${RF_info["antl"]}
        ${rf_pa}    ${PAs}    Get Att With RF    ${GLO_TL_DESCRIPTOR_FILE_PATH}   ${RF_serial_num}    ${pipe_num}
        ${len}   Get Length    ${PAs}
        Run Keyword If    '${len}'!='0'     Set Port List With RF     rf=${rf_pa}    function=${function}
    END

Get Related PA List
    [Arguments]   ${RF_list}
    ${out_is_define_testline_desc}    Run Keyword And Return Status
    ...    Variable Should Not Exist    ${GLO_TL_DESCRIPTOR_FILE_PATH}

    Return From Keyword If    ${out_is_define_testline_desc}    ${Empty}
    ${PA_list}    Create List
    FOR    ${RF_info}   IN    @{RF_list}
        ${RF_serial_num}    Set Variable   ${RF_info["serialNumber"]}
        @{pipe_num}    Set Variable    ${RF_info["antl"]}
        ${rf_pa}    ${PAs}    Get Att With RF    ${GLO_TL_DESCRIPTOR_FILE_PATH}   ${RF_serial_num}    ${pipe_num}
        ${PA_list}    Combine Lists    ${PA_list}   ${PAs}
    END
    Remove Duplicates    ${PA_list}
    [Return]    ${PA_list}

Disable All Ports
    [Arguments]    ${cell_list}
    FOR    ${cell_info}    IN    @{cell_list}
        ${rf_list}    Set Variable    ${cell_info['RF']}
        Set PA Values   ${rf_list}    disable
    END

Set Port List With RF
    [Arguments]    ${rf}    ${function}=enable
    ${has_att}    Run Keyword And Return Status    dictionary_should_not_contain_key    ${rf}     att
    return from keyword if  ${has_att}
    ${att_ids}     get_dictionary_keys    ${rf['att']}
    FOR  ${att_id}    IN      @{att_ids}
        Set Port List With ATT Id    ${rf}     ${att_id}    ${function}
    END

Set Port List With ATT Id
    [Arguments]    ${rf}    ${att_id}    ${function}=enable
    log list    ${rf}

    ${att_info}   Set Variable    ${rf['att']['${att_id}']}
    ${os_att_IP}=    XML.evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
    ...     //Unit[@Type="ATT"][@Number="${att_id}"]/Attenuator/@IP
    ${os_att_vendor}=    XML.evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
    ...     //Unit[@Type="ATT"][@Number="${att_id}"]/Attenuator/@Type

    ${os_att_model}=    XML.evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
    ...     //Unit[@Type="ATT"][@Number="${att_id}"]/Attenuator/@Model

    ${os_att_port}=    XML.evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
    ...     //Unit[@Type="ATT"][@Number="${att_id}"]/Attenuator/@Port
    ${os_att_min}=    XML.evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
    ...     //Unit[@Type="ATT"][@Number="${att_id}"]/Attenuator/@Min
    ${os_att_max}=    XML.evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
    ...     //Unit[@Type="ATT"][@Number="${att_id}"]/Attenuator/@Max
    #${att_port_info}=     Set Variable     ${att_info["ports"]}
    ${att_ports}    Set Variable    ${att_info["ports"]}
    ${channels}    Create List
    ${disable_value}    Create List
    ${enable_value}    Create List
    FOR    ${att_port_info}    IN    @{att_ports}
        ${port}   EVALUATE  int(${att_port_info['port']})
        append to list    ${channels}    ${port}
        append to list    ${disable_value}    ${att_port_info['disable']}
        append to list    ${enable_value}    ${att_port_info['enable']}
        ${setting_value}     Set Variable If        '${function}'=='disable'    ${disable_value}     ${enable_value}
    END
    ${min}   EVALUATE  int(${os_att_min[0]})
    ${max}   EVALUATE  int(${os_att_max[0]})

    ${len}     Get Length     ${os_att_model}
    ${model}     Set Variable If      '${len}'!='0'     ${os_att_model[0]}     DEFAULT

    attenuator_interface.Set Attenuation Value    vendor=${os_att_vendor[0]}    model=${model}
    ...      ip=${os_att_IP[0]}    port=${os_att_port[0]}
    ...      channels=${channels}    values=${setting_value}    min=${min}    max=${max}

