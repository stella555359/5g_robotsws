*** Settings ***
Documentation
...    Author: Yang mengli
...    Email address: mengli.yang@nokia-sbell.com
...    Maintainer: Yang mengli
...    Email address: mengli.yang@nokia-sbell.com
...    Common KWs related to PA.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Guidelines for user: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/04.+Module+of+PA+Operation
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test

Library           Collections
Library           taf.hw.rf_attenuator       WITH NAME    attenuator
Library           String
Library           ./module_utils/module_utils.py

*** Keywords ***
Set PA Value For Source Cell Or Target Cell
    [Arguments]    ${source}    ${target}    ${wait_sleep}=1s
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The KW is related to PA operation.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${source} | No | This parameter defines PA information from the source cell |
    ...    | ${target} | No | This parameter defines PA information from the target cell |
    ...
    ...    | Return Value | Description |
    ...    | NA | No |
    ...
    ...    Example
    ...    | &{source}  Create Dictionary  product_type=cloud  att_index=0  pa_port=[1,2,3...]  pa_value=[0,50]  step=5 |
    ...    | &{target}  Create Dictionary  product_type=cloud  att_index=0  pa_port=[5,6,7...]  pa_value=[63,20]  step=5 |
    ...    | PA Operation | &{source} | &{target} |
    ...
    Log to console    Set PA value for specified port
    Run Keyword If     "${source}"!="none" and "${target}"=="none"         run keywords
    ...    set test variable    ${att_index}   ${source["att_index"]}    AND
    ...    set test variable    ${port_list}      ${source["pa_port"]}    AND
    ...    set test variable    ${pa_init_value}       ${source["pa_value"][0]}    AND
    ...    set test variable    ${pa_expected_value}      ${source["pa_value"][1]}    AND
    ...    set test variable    ${step}      ${source["step"]}
    ...    ELSE IF    "${source}"=="none" and "${target}"!="none"    run keywords
    ...    set test variable    ${att_index}   ${target["att_index"]}    AND
    ...    set test variable    ${port_list}      ${target["pa_port"]}    AND
    ...    set test variable    ${pa_init_value}       ${target["pa_value"][0]}    AND
    ...    set test variable    ${pa_expected_value}      ${target["pa_value"][1]}    AND
    ...    set test variable    ${step}      ${target["step"]}
    ${split_list}    Identify and Split Port Range Values    port_list=${port_list}
    set test variable    ${pa_port}    ${split_list}
    &{attenuator_info_dict}    Get Attenuation Info    att_index=${att_index}
    Set Test Variable    ${attenuation_vendor}    ${attenuator_info_dict["attenuator_vendor"]}
    Set Test Variable    ${attenuation_model}    ${attenuator_info_dict["attenuator_model"]}
    Judge Whether PA Value Belongs To Normal Scope For Corresponding PA Type    pa_init_value=${pa_init_value}
    ...                                                                         pa_expected_value=${pa_expected_value}
    ...                                                                         pa_model=${attenuation_model}
    Setup Attenuation    attenuation_addr=${attenuator_info_dict["attenuator_addr"]}
    ...                  attenuation_port=${attenuator_info_dict["attenuator_port"]}
    ...                  attenuation_vendor=${attenuator_info_dict["attenuator_vendor"]}
    ...                  pa_port=${pa_port}
    ...                  model=${attenuator_info_dict["attenuator_model"]}
    ${initial_att_values}    Get Attenuation Values    pa_port=${pa_port}
    ${if_source_att_value_equal}=   Run Keyword And Return Status   Should be equal as numbers   ${pa_init_value}
    ...                                                                                          ${initial_att_values[0]}
    Run Keyword If    "${if_source_att_value_equal}"=="False"    Set Attenuation Value    pa_port=${pa_port}
    ...                                                                                   pa_value=${pa_init_value}
    ...                                                                                   wait_sleep=${wait_sleep}
    ${length}    Evaluate    abs(${pa_expected_value} - ${pa_init_value})
    ${step}    Convert To Integer     ${step}
    Run Keyword If     "${step}" == "0"    fail    msg=step cannot be set to 0 value.
    ${length}    Evaluate    ${length}/${step}
    ${range_length}    Set Variable    ${length}
    ${pa_value}    Set Variable    ${pa_init_value}
    FOR    ${index}    IN RANGE    0    ${range_length}
        ${pa_value}    Run Keyword If    ${pa_init_value} < ${pa_expected_value}
        ...                                      Evaluate    ${pa_value}+${step}
        ...                  ELSE IF    ${pa_init_value} > ${pa_expected_value}
        ...                             Evaluate    ${pa_value}-${step}
        Run Keyword If    ${pa_init_value} <= ${pa_expected_value} and ${pa_value}<=${pa_expected_value}
        ...                                             Set Attenuation Value    pa_port=${pa_port}
        ...                                                                      pa_value=${pa_value}
        ...                                                                      wait_sleep=${wait_sleep}
        ...   ELSE IF   ${pa_init_value}<=${pa_expected_value} and ${pa_value}>${pa_expected_value} and abs(${pa_value}-${pa_expected_value})<${step}
        ...                                             Set Attenuation Value    pa_port=${pa_port}
        ...                                                                      pa_value=${pa_expected_value}
        ...                                                                      wait_sleep=${wait_sleep}
        Run Keyword If    ${pa_init_value}>${pa_expected_value} and ${pa_value}>=${pa_expected_value}
        ...                                             Set Attenuation Value    pa_port=${pa_port}
        ...                                                                      pa_value=${pa_value}
        ...                                                                      wait_sleep=${wait_sleep}
        ...   ELSE IF    ${pa_init_value}>${pa_expected_value} and ${pa_value}<${pa_expected_value} and abs(${pa_value}-${pa_expected_value})<${step}
        ...                                             Set Attenuation Value    pa_port=${pa_port}
        ...                                                                      pa_value=${pa_expected_value}
        ...                                                                      wait_sleep=${wait_sleep}
    END
    ${source_final_att_values}    Get Attenuation Values    pa_port=${pa_port}

Judge Whether PA Value Belongs To Normal Scope For Corresponding PA Type
    [Arguments]    ${pa_init_value}    ${pa_expected_value}    ${pa_model}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The KW is related to PA operation.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${source} | No | This parameter defines PA information from the source cell |
    ...    | ${target} | No | This parameter defines PA information from the target cell |
    ...
    ...    | Return Value | Description |
    ...    | NA | No |
    ...
    ...    Example
    ...    |Judge Whether PA Value Belongs To Normal Scope For Corresponding PA Type |
    Run Keyword If    "${pa_model}" == "TAS16T16-51-120-1S-DES"    Run Keywords
    ...                                                    Should Be True    0<=${pa_init_value}<=120    AND
    ...                                                    Should Be True    0<=${pa_expected_value}<=120
    ...             ELSE IF    "${pa_model}" == "PA-16-2-4-127-0.5" or "${pa_model}" == "PA-16-16-6-127-0.5-B-S"  Run Keywords
    ...                                                    Should Be True    0<=${pa_init_value}<=127    AND
    ...                                                    Should Be True    0<=${pa_expected_value}<=127
    ...             ELSE IF    "${pa_model}" == "PAM-16X16-6-63-0.5-S"     Run Keywords
    ...                                                    Should Be True    0<=${pa_init_value}<=63    AND
    ...                                                    Should Be True    0<=${pa_expected_value}<=63
    ...             ELSE IF    "${pa_model}" == "TAS16B16-51-90-0.5B-DES"     Run Keywords
    ...                                                    Should Be True    0<=${pa_init_value}<=90    AND
    ...                                                    Should Be True    0<=${pa_expected_value}<=90
    ...             ELSE IF    "${pa_model}" == "TAS_24T24_02G6_90_1C_EJS"     Run Keywords
    ...                                                    Should Be True    0<=${pa_init_value}<=90    AND
    ...                                                    Should Be True    0<=${pa_expected_value}<=90

Identify and Split Port Range Values
    [Arguments]    ${port_list}
    ${pa_port_list}=    Create List
    ${sum_pa_port_list}=    Create List
    FOR    ${item}    IN    @{port_list}
        ${range_values}=    Evaluate    str('${item}').split('-') if '-' in str('${item}') else ['${item}']
        ${start}    Set Variable    ${range_values[0]}
        ${end}    Run Keyword If    len(${range_values}) > 1     Set Variable     ${range_values[1]}
        ...       ELSE    Set Variable    ${range_values[0]}
        ${split_list}    Merge Every Value To One List    start=${start}    end=${end}    split_list=${pa_port_list}
        ${pa_port_list}    Set Variable    ${split_list}
    END
    Log    ${pa_port_list}
    [Return]    ${pa_port_list}

Merge Every Value To One List
    [Arguments]    ${start}    ${end}    ${split_list}
    ${end}    Evaluate    ${end}+${1}
    FOR    ${value}    IN RANGE    ${start}    ${end}
            Append To List    ${split_list}    ${value}
    END
    [Return]    ${split_list}


Set PA Value For Source And Target Cell
    [Arguments]    ${source}    ${target}    ${wait_sleep}=1s
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The KW is related to PA operation.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${source} | No | This parameter defines PA information from the source cell |
    ...    | ${target} | No | This parameter defines PA information from the target cell |
    ...
    ...    | Return Value | Description |
    ...    | NA | No |
    ...
    ...    Example
    ...    | &{source}  Create Dictionary  product_type=cloud  att_index=0  pa_port=[1,2,3...]  pa_value=[0,50]  step=5 |
    ...    | &{target}  Create Dictionary  product_type=cloud  att_index=0  pa_port=[5,6,7...]  pa_value=[63,20]  step=5 |
    ...    | PA Operation | &{source} | &{target} |
    ...
    Log to console    Set PA value for specified port
    ${source_split_list}    Identify and Split Port Range Values    port_list=${source["pa_port"]}
    Set Test Variable    ${source_pa_port}    ${source_split_list}

    &{source_attenuator_info_dict}    Get Attenuation Info    att_index=${source["att_index"]}
    &{target_attenuator_info_dict}    Get Attenuation Info    att_index=${target["att_index"]}
    Set Test Variable    ${source_attenuation_vendor}    ${source_attenuator_info_dict["attenuator_vendor"]}
    Set Test Variable    ${target_attenuation_vendor}    ${target_attenuator_info_dict["attenuator_vendor"]}
    set test variable    ${source_pa_model}   ${source_attenuator_info_dict["attenuator_model"]}
    set test variable    ${target_pa_model}   ${source_attenuator_info_dict["attenuator_model"]}
    Judge Whether PA Value Belongs To Normal Scope For Corresponding PA Type    pa_init_value=${source["pa_value"][0]}
    ...                                                                         pa_expected_value=${source["pa_value"][1]}
    ...                                                                         pa_model=${source_pa_model}
    Judge Whether PA Value Belongs To Normal Scope For Corresponding PA Type    pa_init_value=${target["pa_value"][0]}
    ...                                                                         pa_expected_value=${target["pa_value"][1]}
    ...                                                                         pa_model=${target_pa_model}
    Setup Attenuation    attenuation_addr=${source_attenuator_info_dict["attenuator_addr"]}
    ...                  attenuation_port=${source_attenuator_info_dict["attenuator_port"]}
    ...                  attenuation_vendor=${source_attenuator_info_dict["attenuator_vendor"]}
    ...                  pa_port=${source_pa_port}
    ...                  model=${source_attenuator_info_dict["attenuator_model"]}

    ${source_initial_att_values}    Get Attenuation Values    pa_port=${source_pa_port}

    ${if_source_att_value_equal}=   Run Keyword And Return Status   Should be equal as numbers   ${source["pa_value"][0]}
    ...                                                                                          ${source_initial_att_values[0]}
    Run Keyword If    "${if_source_att_value_equal}"=="False"    Set Attenuation Value    pa_port=${source_pa_port}
    ...                                                                                   pa_value=${source["pa_value"][0]}
    ...                                                                                   wait_sleep=${wait_sleep}
    ${target_split_list}    Identify and Split Port Range Values    port_list=${target["pa_port"]}
    Set Test Variable    ${target_pa_port}    ${target_split_list}
    Setup Attenuation    attenuation_addr=${target_attenuator_info_dict["attenuator_addr"]}
    ...                  attenuation_port=${target_attenuator_info_dict["attenuator_port"]}
    ...                  attenuation_vendor=${target_attenuator_info_dict["attenuator_vendor"]}
    ...                  pa_port=${target_pa_port}
    ...                  model=${target_attenuator_info_dict["attenuator_model"]}
    ${target_initial_att_values}    Get Attenuation Values    pa_port=${target_pa_port}
    ${if_target_att_value_equal}=   Run Keyword And Return Status   Should be equal as numbers   ${target["pa_value"][0]}
    ...                                                                                          ${target_initial_att_values[0]}
    Run Keyword If    "${if_target_att_value_equal}"=="False"    Set Attenuation Value    pa_port=${target_pa_port}
    ...                                                                                   pa_value=${target["pa_value"][0]}
    ...                                                                                   wait_sleep=${wait_sleep}
    ${source_length}    Evaluate    abs(${source["pa_value"][1]} - ${source["pa_value"][0]})
    ${target_length}    Evaluate    abs(${target["pa_value"][1]} - ${target["pa_value"][0]})
    Run Keyword If    '${source["step"]}' == '${None}' or '${source["step"]}' == '0'  fail    msg=step cannot be set to 0 or none value.
    Run Keyword If    '${target["step"]}' == '${None}' or '${target["step"]}' == '0'  fail    msg=step cannot be set to 0 or none value.
    ${source_length}    Evaluate    ${source_length}/${source["step"]}
    ${target_length}    Evaluate    ${target_length}/${target["step"]}
    ${range_length}    Run Keyword If    ${source_length} >= ${target_length}    Set Variable    ${source_length}
    ...                ELSE IF    ${source_length} < ${target_length}    Set Variable    ${target_length}
    ${sipvalue}    Set Variable    ${source["pa_value"][0]}
    ${tipvalue}    Set Variable    ${target["pa_value"][0]}
    ${spevalue}    Set Variable    ${source["pa_value"][1]}
    ${tpevalue}    Set Variable    ${target["pa_value"][1]}
    ${source_pa_value}    Set Variable    ${sipvalue}
    ${target_pa_value}    Set Variable    ${tipvalue}
    FOR    ${index}    IN RANGE    0    ${range_length}
         Setup Attenuation    attenuation_addr=${source_attenuator_info_dict["attenuator_addr"]}
         ...                  attenuation_port=${source_attenuator_info_dict["attenuator_port"]}
         ...                  attenuation_vendor=${source_attenuator_info_dict["attenuator_vendor"]}
         ...                  pa_port=${source_pa_port}
         ...                  model=${source_attenuator_info_dict["attenuator_model"]}
        ${source_pa_value}    Run Keyword If    ${sipvalue} < ${spevalue}
        ...                                      Evaluate    ${source_pa_value}+${source["step"]}
        ...                  ELSE IF    ${sipvalue} > ${spevalue}
        ...                             Evaluate    ${source_pa_value}-${source["step"]}
        Run Keyword If    ${sipvalue} <= ${spevalue} and ${source_pa_value}<=${spevalue}
        ...                                             Set Attenuation Value    pa_port=${source_pa_port}
        ...                                                                      pa_value=${source_pa_value}
        ...                                                                      wait_sleep=${wait_sleep}
        ...     ELSE IF    ${sipvalue}<=${spevalue} and ${source_pa_value}>${spevalue} and abs(${source_pa_value}-${spevalue})<${source["step"]}
        ...                                             Set Attenuation Value    pa_port=${source_pa_port}
        ...                                                                      pa_value=${spevalue}
        ...                                                                      wait_sleep=${wait_sleep}
        Run Keyword If    ${sipvalue} > ${spevalue} and ${source_pa_value} >= ${spevalue}
        ...                                             Set Attenuation Value    pa_port=${source_pa_port}
        ...                                                                      pa_value=${source_pa_value}
        ...                                                                      wait_sleep=${wait_sleep}
        ...     ELSE IF    ${sipvalue}>${spevalue} and ${source_pa_value} < ${spevalue} and abs(${source_pa_value}-${spevalue})<${source["step"]}
        ...                                             Set Attenuation Value    pa_port=${source_pa_port}
        ...                                                                      pa_value=${spevalue}
        ...                                                                      wait_sleep=${wait_sleep}
        Setup Attenuation    attenuation_addr=${target_attenuator_info_dict["attenuator_addr"]}
        ...                  attenuation_port=${target_attenuator_info_dict["attenuator_port"]}
        ...                  attenuation_vendor=${target_attenuator_info_dict["attenuator_vendor"]}
        ...                  pa_port=${target_pa_port}
        ...                  model=${target_attenuator_info_dict["attenuator_model"]}
        ${target_pa_value}    Run Keyword If    ${tipvalue} < ${tpevalue}
        ...                                      Evaluate    ${target_pa_value}+${target["step"]}
        ...                  ELSE IF    ${tipvalue} > ${tpevalue}
        ...                             Evaluate    ${target_pa_value}-${target["step"]}
        Run Keyword If    ${tipvalue} <= ${tpevalue} and ${target_pa_value}<=${tpevalue}
        ...                                             Set Attenuation Value    pa_port=${target_pa_port}
        ...                                                                      pa_value=${target_pa_value}
        ...                                                                      wait_sleep=${wait_sleep}
        ...     ELSE IF    ${tipvalue}<=${tpevalue} and ${target_pa_value}>${tpevalue} and abs(${target_pa_value}-${tpevalue})<${target["step"]}
        ...                                             Set Attenuation Value    pa_port=${target_pa_port}
        ...                                                                      pa_value=${tpevalue}
        ...                                                                      wait_sleep=${wait_sleep}
        Run Keyword If    ${tipvalue} > ${tpevalue} and ${target_pa_value} >= ${tpevalue}
        ...                                             Set Attenuation Value    pa_port=${target_pa_port}
        ...                                                                      pa_value=${target_pa_value}
        ...                                                                      wait_sleep=${wait_sleep}
        ...     ELSE IF    ${tipvalue}>${tpevalue} and ${target_pa_value} < ${tpevalue} and abs(${target_pa_value}-${tpevalue})<${target["step"]}
        ...                                             Set Attenuation Value    pa_port=${target_pa_port}
        ...                                                                      pa_value=${tpevalue}
        ...                                                                      wait_sleep=${wait_sleep}
    END
     Setup Attenuation    attenuation_addr=${source_attenuator_info_dict["attenuator_addr"]}
     ...                  attenuation_port=${source_attenuator_info_dict["attenuator_port"]}
     ...                  attenuation_vendor=${source_attenuator_info_dict["attenuator_vendor"]}
     ...                  pa_port=${source_pa_port}
     ...                  model=${source_attenuator_info_dict["attenuator_model"]}
    ${source_final_att_values}    Get Attenuation Values    pa_port=${source_pa_port}
    Setup Attenuation    attenuation_addr=${target_attenuator_info_dict["attenuator_addr"]}
    ...                  attenuation_port=${target_attenuator_info_dict["attenuator_port"]}
    ...                  attenuation_vendor=${target_attenuator_info_dict["attenuator_vendor"]}
    ...                  pa_port=${target_pa_port}
    ...                  model=${target_attenuator_info_dict["attenuator_model"]}
    ${target_final_att_values}    Get Attenuation Values    pa_port=${target_pa_port}

Get Attenuation Info
    [Arguments]    ${att_index}=0
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The KW is to get Attenuation information form testline config.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | NA | No |
    ...
    ...    | Return Value | Description |
    ...    | ${att_index} | attenuator information that include address, port,vendor,model were returned. |
    ...
    ...    Example
    ...    | ${attenuator_info_dict} | Get Attenuation Info |
    ...
    &{attenuator_info_dict}=    Create Dictionary
    ${single_attenuator_used}    Get Variable Value    ${tl.attenuator.vendor}
    ${ip_addr}    set variable if    '${single_attenuator_used}'!='${None}'    ${tl.attenuator.ip_addr}    ${tl.attenuators[${att_index}].ip_addr}
    Set to Dictionary    ${attenuator_info_dict}    attenuator_addr    ${ip_addr}
    ${vendor}    set variable if    '${single_attenuator_used}'!='${None}'    ${tl.attenuator.vendor}    ${tl.attenuators[${att_index}].vendor}
    Set to Dictionary    ${attenuator_info_dict}    attenuator_vendor    ${vendor}
    ${port}    set variable if    '${single_attenuator_used}'!='${None}'    ${tl.attenuator.port}    ${tl.attenuators[${att_index}].port}
    Set to Dictionary    ${attenuator_info_dict}    attenuator_port    ${port}
    ${model}    set variable if    '${single_attenuator_used}'!='${None}'    ${tl.attenuator.model}    ${tl.attenuators[${att_index}].model}
    Set to Dictionary    ${attenuator_info_dict}    attenuator_model    ${model}
    [Return]    &{attenuator_info_dict}

Setup Attenuation
    [Arguments]    ${attenuation_addr}    ${attenuation_port}    ${attenuation_vendor}    ${pa_port}    ${model}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The KW is to setup attenuation.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${attenuation_addr} | No | attenuation_addr id which is fetched from Testline Configuration |
    ...    | ${attenuation_port} | No | attenuation_port id which is fetched from Testline Configuration |
    ...    | ${attenuation_vendor} | No | The attenuation vendor name, default value is HBTE  |
    ...    | ${pa_port} | No | pa_port which is fetched from Testline Configuration |
    ...
    ...    Example
    ...    | Setup Attenuation | ${attenuation_addr} | ${attenuation_port} | ${attenuation_vendor} | ${pa_port} |
    ...
    attenuator.setup_attenuator
    ...    ip_addr=${attenuation_addr}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${pa_port}
    ...    vendor=${attenuation_vendor}
    ...    model=${model}

Get Attenuation Values
    [Arguments]      ${pa_port}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The KW is to get initial attenuation values based on channel port numbers get form testline config.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${pa_port} | No | RU id which is fetched from Testline Configuration, default value is 0 |
    ...
    ...    | Return Value | Description |
    ...    | ${initial_att_values} | The initial attenuation values are returned. |
    ...
    ...    Example
    ...    | ${initial_att_values} | Get Attenuation Values | ${pa_port} |
    ...
    ${port_length}    Get Length    ${pa_port}
    ${initial_att_values}    Create List
    FOR    ${index}    IN RANGE    ${port_length}
        ${port}    Convert To Integer     ${pa_port[${index}]}
        ${values}=    attenuator.read_attenuation    port=${port}
        Append To List    ${initial_att_values}    ${values}
    END
    [Return]    ${initial_att_values}


Set Attenuation Value
    [Arguments]    ${pa_port}    ${pa_value}    ${wait_sleep}=1s
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is to set values of attenuation which connect to RU.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${pa_port} | No | pa_port which is provided by user, which port you need to change |
    ...    | ${pa_value} | No | What value do you need to set |
    ...
    ...    | Return Value | Description |
    ...    | NA | NA |
    ...
    ...    Example
    ...    | Set Attenuation Value | ${pa_port} | ${pa_value} |
    ...
    ${port_length}    Get Length    ${pa_port}
    FOR    ${index}    IN RANGE    ${port_length}
        ${port}    Convert To Integer     ${pa_port[${index}]}
        ${pa_value}    Convert To Integer     ${pa_value}
        Wait Until Keyword Succeeds    5 min    5 sec    attenuator.set_attenuation
        ...    port=${port}    value=${pa_value}
        Run Keyword And Ignore Error    Check Attenuation Value is updated
        ...    port=${port}    value=${pa_value}
        Sleep    1s
    END
    Sleep    ${wait_sleep}

Set Attenuation Value With Multiple Times
    [Arguments]    ${pa_port}    ${pa_value}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is to set values of attenuation which connect to RU.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${pa_port} | No | pa_port which is provided by user, which port you need to change |
    ...    | ${pa_value} | No | What value do you need to set |
    ...
    ...    | Return Value | Description |
    ...    | NA | NA |
    ...
    ...    Example
    ...    | Set Attenuation Value | ${pa_port} | ${pa_value} |
    ...
    ${port_length}    Get Length    ${pa_port}
    FOR    ${index}    IN RANGE    ${port_length}
        ${port}    Convert To Integer     ${pa_port[${index}]}
        ${pa_value}    Convert To Integer     ${pa_value}
        Wait Until Keyword Succeeds    5 min    5 sec    attenuator.set_attenuation
        ...    port=${port}    value=${pa_value}
#        Sleep    1s
    END

Set PA Value For Source And Target Cell With Multiple Times
    [Arguments]    ${source}    ${target}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The KW is related to PA operation.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${source} | No | This parameter defines PA information from the source cell |
    ...    | ${target} | No | This parameter defines PA information from the target cell |
    ...
    ...    | Return Value | Description |
    ...    | NA | No |
    ...
    ...    Example
    ...    | &{source}  Create Dictionary  product_type=cloud  att_index=0  pa_port=[1,2,3...]  pa_value=[0,50]  step=5 |
    ...    | &{target}  Create Dictionary  product_type=cloud  att_index=0  pa_port=[5,6,7...]  pa_value=[63,20]  step=5 |
    ...    | PA Operation | &{source} | &{target} |
    ...
    Log to console    Set PA value for specified port
    ${source_split_list}    Identify and Split Port Range Values    port_list=${source["pa_port"]}
    Set Test Variable    ${source_pa_port}    ${source_split_list}
    &{source_attenuator_info_dict}    Get Attenuation Info    att_index=${source["att_index"]}
    &{target_attenuator_info_dict}    Get Attenuation Info    att_index=${target["att_index"]}
    Set Test Variable    ${source_attenuation_vendor}    ${source_attenuator_info_dict["attenuator_vendor"]}
    Set Test Variable    ${target_attenuation_vendor}    ${target_attenuator_info_dict["attenuator_vendor"]}
    set test variable    ${source_pa_model}   ${source_attenuator_info_dict["attenuator_model"]}
    set test variable    ${target_pa_model}   ${source_attenuator_info_dict["attenuator_model"]}
    Judge Whether PA Value Belongs To Normal Scope For Corresponding PA Type    pa_init_value=${source["pa_value"][0]}
    ...                                                                         pa_expected_value=${source["pa_value"][1]}
    ...                                                                         pa_model=${source_pa_model}
    Judge Whether PA Value Belongs To Normal Scope For Corresponding PA Type    pa_init_value=${target["pa_value"][0]}
    ...                                                                         pa_expected_value=${target["pa_value"][1]}
    ...                                                                         pa_model=${target_pa_model}
    Setup Attenuation    attenuation_addr=${source_attenuator_info_dict["attenuator_addr"]}
    ...                  attenuation_port=${source_attenuator_info_dict["attenuator_port"]}
    ...                  attenuation_vendor=${source_attenuator_info_dict["attenuator_vendor"]}
    ...                  pa_port=${source_pa_port}
    ...                  model=${source_attenuator_info_dict["attenuator_model"]}
    ${source_initial_att_values}    Get Attenuation Values    pa_port=${source_pa_port}

    ${if_source_att_value_equal}=   Run Keyword And Return Status   Should be equal as numbers   ${source["pa_value"][0]}
    ...                                                                                          ${source_initial_att_values[0]}
    Run Keyword If    "${if_source_att_value_equal}"=="False"    Set Attenuation Value With Multiple Times    pa_port=${source_pa_port}
    ...                                                                                   pa_value=${source["pa_value"][0]}
    ${target_split_list}    Identify and Split Port Range Values    port_list=${target["pa_port"]}
    Set Test Variable    ${target_pa_port}    ${target_split_list}
    Setup Attenuation    attenuation_addr=${target_attenuator_info_dict["attenuator_addr"]}
    ...                  attenuation_port=${target_attenuator_info_dict["attenuator_port"]}
    ...                  attenuation_vendor=${target_attenuator_info_dict["attenuator_vendor"]}
    ...                  pa_port=${target_pa_port}
    ...                  model=${target_attenuator_info_dict["attenuator_model"]}
    ${target_initial_att_values}    Get Attenuation Values    pa_port=${target_pa_port}
    ${if_target_att_value_equal}=   Run Keyword And Return Status   Should be equal as numbers   ${target["pa_value"][0]}
    ...                                                                                          ${target_initial_att_values[0]}
    Run Keyword If    "${if_target_att_value_equal}"=="False"    Set Attenuation Value With Multiple Times    pa_port=${target_pa_port}
    ...                                                                                   pa_value=${target["pa_value"][0]}
    ${source_length}    Evaluate    abs(${source["pa_value"][1]} - ${source["pa_value"][0]})
    ${target_length}    Evaluate    abs(${target["pa_value"][1]} - ${target["pa_value"][0]})
    Run Keyword If    '${source["step"]}' == '${None}' or '${source["step"]}' == '0'  fail    msg=step cannot be set to 0 or none value.
    Run Keyword If    '${target["step"]}' == '${None}' or '${target["step"]}' == '0'  fail    msg=step cannot be set to 0 or none value.
    ${source_length}    Evaluate    ${source_length}/${source["step"]}
    ${target_length}    Evaluate    ${target_length}/${target["step"]}
    ${range_length}    Run Keyword If    ${source_length} >= ${target_length}    Set Variable    ${source_length}
    ...                ELSE IF    ${source_length} < ${target_length}    Set Variable    ${target_length}
    ${sipvalue}    Set Variable    ${source["pa_value"][0]}
    ${tipvalue}    Set Variable    ${target["pa_value"][0]}
    ${spevalue}    Set Variable    ${source["pa_value"][1]}
    ${tpevalue}    Set Variable    ${target["pa_value"][1]}
    ${source_pa_value}    Set Variable    ${sipvalue}
    ${target_pa_value}    Set Variable    ${tipvalue}
    FOR    ${index}    IN RANGE    0    ${range_length}
         Setup Attenuation    attenuation_addr=${source_attenuator_info_dict["attenuator_addr"]}
         ...                  attenuation_port=${source_attenuator_info_dict["attenuator_port"]}
         ...                  attenuation_vendor=${source_attenuator_info_dict["attenuator_vendor"]}
         ...                  pa_port=${source_pa_port}
         ...                  model=${source_attenuator_info_dict["attenuator_model"]}
        ${source_pa_value}    Run Keyword If    ${sipvalue} < ${spevalue}
        ...                                      Evaluate    ${source_pa_value}+${source["step"]}
        ...                  ELSE IF    ${sipvalue} > ${spevalue}
        ...                             Evaluate    ${source_pa_value}-${source["step"]}
        Run Keyword If    ${sipvalue} <= ${spevalue} and ${source_pa_value}<=${spevalue}
        ...                                             Set Attenuation Value With Multiple Times    pa_port=${source_pa_port}
        ...                                                                      pa_value=${source_pa_value}
        ...     ELSE IF    ${sipvalue}<=${spevalue} and ${source_pa_value}>${spevalue} and abs(${source_pa_value}-${spevalue})<${source["step"]}
        ...                                             Set Attenuation Value With Multiple Times    pa_port=${source_pa_port}
        ...                                                                      pa_value=${spevalue}
        Run Keyword If    ${sipvalue} > ${spevalue} and ${source_pa_value} >= ${spevalue}
        ...                                             Set Attenuation Value With Multiple Times    pa_port=${source_pa_port}
        ...                                                                      pa_value=${source_pa_value}
        ...     ELSE IF    ${sipvalue}>${spevalue} and ${source_pa_value} < ${spevalue} and abs(${source_pa_value}-${spevalue})<${source["step"]}
        ...                                             Set Attenuation Value With Multiple Times    pa_port=${source_pa_port}
        ...                                                                      pa_value=${spevalue}
        Sleep    1s
        Setup Attenuation    attenuation_addr=${target_attenuator_info_dict["attenuator_addr"]}
        ...                  attenuation_port=${target_attenuator_info_dict["attenuator_port"]}
        ...                  attenuation_vendor=${target_attenuator_info_dict["attenuator_vendor"]}
        ...                  pa_port=${target_pa_port}
        ...                  model=${target_attenuator_info_dict["attenuator_model"]}
        ${target_pa_value}    Run Keyword If    ${tipvalue} < ${tpevalue}
        ...                                      Evaluate    ${target_pa_value}+${target["step"]}
        ...                  ELSE IF    ${tipvalue} > ${tpevalue}
        ...                             Evaluate    ${target_pa_value}-${target["step"]}
        Run Keyword If    ${tipvalue} <= ${tpevalue} and ${target_pa_value}<=${tpevalue}
        ...                                             Set Attenuation Value With Multiple Times    pa_port=${target_pa_port}
        ...                                                                      pa_value=${target_pa_value}
        ...     ELSE IF    ${tipvalue}<=${tpevalue} and ${target_pa_value}>${tpevalue} and abs(${target_pa_value}-${tpevalue})<${target["step"]}
        ...                                             Set Attenuation Value With Multiple Times    pa_port=${target_pa_port}
        ...                                                                      pa_value=${tpevalue}
        Run Keyword If    ${tipvalue} > ${tpevalue} and ${target_pa_value} >= ${tpevalue}
        ...                                             Set Attenuation Value With Multiple Times    pa_port=${target_pa_port}
        ...                                                                      pa_value=${target_pa_value}
        ...     ELSE IF    ${tipvalue}>${tpevalue} and ${target_pa_value} < ${tpevalue} and abs(${target_pa_value}-${tpevalue})<${target["step"]}
        ...                                             Set Attenuation Value With Multiple Times    pa_port=${target_pa_port}
        ...                                                                      pa_value=${tpevalue}
    Sleep    1s
    END
     Setup Attenuation    attenuation_addr=${source_attenuator_info_dict["attenuator_addr"]}
     ...                  attenuation_port=${source_attenuator_info_dict["attenuator_port"]}
     ...                  attenuation_vendor=${source_attenuator_info_dict["attenuator_vendor"]}
     ...                  pa_port=${source_pa_port}
     ...                  model=${source_attenuator_info_dict["attenuator_model"]}
    ${source_final_att_values}    Run Keyword And Ignore Error    Get Attenuation Values    pa_port=${source_pa_port}
    FOR    ${item}    IN    @{source_final_att_values[-1]}
        ${item_str}=    Run Keyword And Ignore Error    Convert To String    ${item}
        Run Keyword And Ignore Error    Should Be Equal    ${item_str[-1]}    ${spevalue}
    END
    Setup Attenuation    attenuation_addr=${target_attenuator_info_dict["attenuator_addr"]}
    ...                  attenuation_port=${target_attenuator_info_dict["attenuator_port"]}
    ...                  attenuation_vendor=${target_attenuator_info_dict["attenuator_vendor"]}
    ...                  pa_port=${target_pa_port}
    ...                  model=${target_attenuator_info_dict["attenuator_model"]}
    ${target_final_att_values}    Run Keyword And Ignore Error    Get Attenuation Values    pa_port=${target_pa_port}
    FOR    ${item}    IN    @{target_final_att_values[-1]}
        ${item_str}=    Run Keyword And Ignore Error    Convert To String    ${item}
        Run Keyword And Ignore Error    Should Be Equal    ${item_str[-1]}    ${tpevalue}
    END

Check Attenuation Value is updated
    [Arguments]    ${port}    ${value}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is to veirfy whether values of attenuation are updated successfully.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${port} | Yes | The attenuation port need to verify the value |
    ...    | ${value} | Yes | The value need expected |
    ...
    ...    | Return Value | Description |
    ...    | NA | NA |
    ...
    ...    Example
    ...    | Check Attenuation Value is updated | port=0 | value=0 |
    ...
    ${new_value}=    attenuator.read_attenuation    port=${port}
    should be equal as integers    ${new_value}    ${value}    msg=Attenuation set failed.
    log to console  change attenuation to ${value}

Get Attenuation Port From Init File
    [Arguments]    ${product_type}    ${bts_index}=${0}    ${du_index}=${0}    ${ru_index}=${0}    ${att_index}=${0}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is to get Attenuation Port based on init file.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${port} | Yes | The attenuation port need to verify the value |
    ...    | ${value} | Yes | The value need expected |
    ...
    ...    | Return Value | Description |
    ...    | NA | NA |
    ...
    ...    Example
    ...    | Get Attenuation Port From Init File |
    &{pa_dict}    Create Dictionary
    ${info}=    get_site_info        product_type=${product_type}
    ...                              info_type=rru
    ...                              bts_index=${bts_index}
    ...                              du_index=${du_index}
    ...                              ru_index=${ru_index}
    ${pa_port}    Set Variable   ${info.attenuation_ports}
    &{attenuator_info_dict}    Get Attenuation Info    att_index=${att_index}
    Setup Attenuation    attenuation_addr=${attenuator_info_dict["attenuator_addr"]}
    ...                  attenuation_port=${attenuator_info_dict["attenuator_port"]}
    ...                  attenuation_vendor=${attenuator_info_dict["attenuator_vendor"]}
    ...                  pa_port=${pa_port}
    ...                  model=${attenuator_info_dict["attenuator_model"]}
    ${pa_values}    Get Attenuation Values    pa_port=${pa_port}
    ${pa_port_lenth}    Get Length     ${pa_port}
    FOR    ${index}    IN RANGE    ${pa_port_lenth}
        Set to Dictionary    ${pa_dict}    ${pa_port[${index}]}    ${pa_values[${index}]}
    END
    [Return]    ${pa_dict}


Module Initialize PA Value
    [Arguments]    ${operation}    ${source}    ${timeout}=60
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The KW is related to PA operation.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${source} | No | This parameter defines PA information from the source cell |
    ...    | ${target} | No | This parameter defines PA information from the target cell |
    ...
    ...    | Return Value | Description |
    ...    | NA | No |
    ...
    ...    Example
    ...    | &{source}  Create Dictionary  product_type=cloud  att_index=0  pa_port=[1,2,3...]  pa_value=[0,50]  step=5 |
    ...    | &{target}  Create Dictionary  product_type=cloud  att_index=0  pa_port=[5,6,7...]  pa_value=[63,20]  step=5 |
    ...    | PA Operation | &{source} | &{target} |
    ...
    Log to console    ${operation} and ${timeout} is not used
    Log to console    Module Initialize PA Value
    Set Test Variable    ${pa_port}    ${source["pa_port"]}
    Set Test Variable    ${pa_value}    ${source["pa_value"]}
    &{attenuator_info_dict}    Get Attenuation Info    att_index=${source["att_index"]}
    Set Test Variable    ${attenuation_vendor}    ${attenuator_info_dict["attenuator_vendor"]}
    Set Test Variable    ${attenuation_model}    ${attenuator_info_dict["attenuator_model"]}
    Setup Attenuation    attenuation_addr=${attenuator_info_dict["attenuator_addr"]}
    ...                  attenuation_port=${attenuator_info_dict["attenuator_port"]}
    ...                  attenuation_vendor=${attenuator_info_dict["attenuator_vendor"]}
    ...                  pa_port=${pa_port}
    ...                  model=${attenuator_info_dict["attenuator_model"]}
    ${port_length}    Get Length    ${pa_port}
    ${initial_att_values}    Run Keyword And Ignore Error    Get Attenuation Values    pa_port=${pa_port}
    FOR    ${index}    IN RANGE    ${port_length}
        ${if_equal}=   Run Keyword And Return Status   Should be equal as numbers   ${pa_value[${index}]}
        ...                                                                         ${initial_att_values[${index}]}
        Run Keyword If    "${if_equal}"=="False"    _Initialize PA Value    pa_port=${pa_port[${index}]}
        ...                                                                  pa_value=${pa_value[${index}]}
    END
    ${source_final_att_values}    Get Attenuation Values    pa_port=${pa_port}

_Initialize PA Value
    [Arguments]    ${pa_port}    ${pa_value}
    ${pa_port}    Convert To Integer     ${pa_port}
    ${pa_value}    Convert To Integer     ${pa_value}
    Wait Until Keyword Succeeds    1 min    5 sec    attenuator.set_attenuation
    ...    port=${pa_port}    value=${pa_value}
    Run Keyword And Ignore Error    Check Attenuation Value is updated
    ...    port=${pa_port}    value=${pa_value}

Split And Expand PA Parameters
    [Arguments]    ${pa_port}    ${pa_value}
    ${pa_port_list}    Create List
    ${pa_value_list}   Create List
    ${pa_port_ranges}  Split String    ${pa_port}    ;
    ${pa_values}       Split String    ${pa_value}   ;
    ${value_index}     Set Variable    0
    ${port_lenth}    Get Length    ${pa_port_ranges}
    ${port_lenth}    Evaluate   ${port_lenth} - 1
    FOR    ${index}    IN RANGE    ${port_lenth}
        ${range_check}    Run Keyword And Return Status    Should Contain    ${pa_port_ranges[${index}]}    -
        ${range_check1}    Run Keyword And Return Status    Should Contain    ${pa_port_ranges[${index}]}    ,
        Run Keyword If    ${range_check}    _Expand Range    ${pa_port_ranges[${index}]}    ${pa_values[${value_index}]}
        ...                                                  ${pa_port_list}    ${pa_value_list}
        ...    ELSE IF    ${range_check1}    _Expand Range1    ${pa_port_ranges[${index}]}    ${pa_values[${value_index}]}
        ...                                                    ${pa_port_list}    ${pa_value_list}
        ...     ELSE    Insert To List    ${pa_port_list}    ${pa_value_list}
        ...                               expanded_port_list=${pa_port_ranges[${index}]}
        ...                               expanded_value_list=${pa_values[${value_index}]}
        ${value_index}    Evaluate   ${value_index} + 1
    END
    Log To Console    \nPA Port List: ${pa_port_list}
    Log To Console    \nPA Value List: ${pa_value_list}
    [Return]    ${pa_port_list}    ${pa_value_list}

Insert To List
    [Arguments]    ${pa_port_list}    ${pa_value_list}    ${expanded_port_list}    ${expanded_value_list}
    ${pa_port_index}    Convert To Integer     ${expanded_port_list}
    Append To List    ${pa_port_list}    ${pa_port_index}
    Append To List    ${pa_value_list}    ${expanded_value_list}

_Expand Range
    [Arguments]    ${range}    ${value}    ${expanded_port_list}    ${expanded_value_list}
    ${start}    Set Variable    ${range.split('-')[0]}
    ${end}      Set Variable    ${range.split('-')[1]}
    FOR    ${i}    IN RANGE    ${start}    ${end}+1
        ${i}    Convert To Integer     ${i}
        Append To List    ${expanded_port_list}    ${i}
        Append To List    ${expanded_value_list}    ${value}
    END

_Expand Range1
    [Arguments]    ${range}    ${value}    ${expanded_port_list}    ${expanded_value_list}
    ${pa_port}       Split String    ${range}   ,
    ${pa_lenth}    Get Length    ${pa_port}
    FOR    ${index}    IN RANGE    ${pa_lenth}
        ${pa_port_index}    Convert To Integer     ${pa_port[${index}]}
        Append To List    ${expanded_port_list}    ${pa_port_index}
        Append To List    ${expanded_value_list}    ${value}
    END