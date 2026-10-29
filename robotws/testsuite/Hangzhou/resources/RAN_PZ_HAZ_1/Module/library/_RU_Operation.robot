*** Settings ***
Documentation
...    Author: Sheng Haoyun
...    Contact: haoyun-lyle.sheng@nokia-sbell.com
...    Common KWs related to RU Operation.

Library             taf.hw.pdu    WITH NAME    pdu
Library             taf.transport.ssh    WITH NAME    tafssh
Library             taf.sbts.oam.coam.admin     WITH NAME    coam
Library             ./_RU_Operation.py
Library             ./_fiber_switch.py
Library             ./module_utils/module_utils.py

*** Variables ***
&{RF_LEAD_VARIANT}    AZNA=AZNA
&{DEFAULT_PORT}       ssh=22    telnet=23    frmon=2000
*** Keywords ***
Trigger Ru Fault
   [Documentation]     The KW is related to RU operation.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | product_type     | yes  | str  | The type of bts product, e.g. enb; gnb; vdu; vcu |
    ...   | bts_index        | no   | int  | The index of the bts in tl's init.py |
    ...   | cudu_index       | no   | int  | The index of the bts du in tl's init.py |
    ...   | ru_index         | no   | int  | The index of the bts ru in tl's init.py |
    ...   | ru_sn            | no   | int  | The serial number of the ru |
    ...   | fault_id         | yes  | int  | The id of fault that need to be triggered |
    ...   | ru_user_password | no   | int  | The ssh username and password of the ru |
    [Arguments]    ${product_type}
    ...    ${bts_index}
    ...    ${cudu_index}
    ...    ${ru_index}
    ...    ${ru_sn}
    ...    ${fault_id}
    ...    ${ru_user_password}
    ...    ${timeout}
    ...    &{kwargs}
    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_type}    ${ru_pb_info}
    ...    _ru.init_module_variables    ${product_type}    ${bts_index}    ${cudu_index}    ${ru_index}    ${ru_sn}
    ${variable_exist}    Run Keyword And Return Status    Variable Should Exist    ${RF_LEAD_VARIANT["${${ru_type}}"]}
    ${ru_type}    Set Variable If    ${variable_exist}    ${RF_LEAD_VARIANT["${${ru_type}}"]}    ${ru_type}
    ${ru_user_password}   Run Keyword If    ${ru_user_password}!="None"    _ru.string_convert_to_dictionary
    ...    ${ru_user_password}    ELSE    Set Variable    ${ru_user_password}
    ${connection}    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_login_classical    ${product_type}    ${bts_index}    alias=${ru_type}_fault_${fault_id}
    ...    ELSE    FAIL    RU Fault Operation for Cloud is currently not supported!
    Run Keyword And Return    _ru.trigger_${ru_type}_fault_${fault_id}
    ...    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${connection}    ${timeout}    &{_kwargs}
    [Teardown]    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_logout_classical    connection=${ru_type}_fault_${fault_id}

Clear Ru Fault
   [Documentation]     The KW is related to RU operation.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | product_type     | yes  | str  | The type of bts product, e.g. enb; gnb; vdu; vcu |
    ...   | bts_index        | no   | int  | The index of the bts in tl's init.py |
    ...   | cudu_index       | no   | int  | The index of the bts du in tl's init.py |
    ...   | ru_index         | no   | int  | The index of the bts ru in tl's init.py |
    ...   | ru_sn            | no   | int  | The serial number of the ru |
    ...   | fault_id         | yes  | int  | The id of fault that need to be triggered |
    ...   | ru_user_password | no   | int  | The ssh username and password of the ru |
    [Arguments]    ${product_type}
    ...    ${bts_index}
    ...    ${cudu_index}
    ...    ${ru_index}
    ...    ${ru_sn}
    ...    ${fault_id}
    ...    ${ru_user_password}
    ...    ${timeout}
    ...    &{kwargs}
    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_type}    ${ru_pb_info}
    ...    _ru.init_module_variables    ${product_type}    ${bts_index}    ${cudu_index}    ${ru_index}    ${ru_sn}
    ${variable_exist}    Run Keyword And Return Status    Variable Should Exist    ${RF_LEAD_VARIANT["${${ru_type}}"]}
    ${ru_type}    Set Variable If    ${variable_exist}    ${RF_LEAD_VARIANT["${${ru_type}}"]}    ${ru_type}
    ${ru_user_password}   Run Keyword If    ${ru_user_password}!="None"    _ru.string_convert_to_dictionary
    ...    ${ru_user_password}    ELSE    Set Variable    ${ru_user_password}
    ${connection}    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_login_classical    ${product_type}    ${bts_index}    alias=${ru_type}_fault_${fault_id}
    ...    ELSE    FAIL    RU Fault Operation for Cloud is currently not supported!
    Run Keyword And Return    _ru.clear_${ru_type}_fault_${fault_id}
    ...    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}   ${connection}    ${timeout}    &{_kwargs}
    [Teardown]    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_logout_classical    connection=${ru_type}_fault_${fault_id}

Send Commands To Ru
   [Documentation]     The KW is related to RU operation.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | product_type     | yes  | str  | The type of bts product, e.g. enb; gnb; vdu; vcu |
    ...   | bts_index        | no   | int  | The index of the bts in tl's init.py |
    ...   | cudu_index       | no   | int  | The index of the bts du in tl's init.py |
    ...   | ru_index         | no   | int  | The index of the bts ru in tl's init.py |
    ...   | ru_sn            | no   | int  | The serial number of the ru |
    ...   | ru_user_password | no   | int  | The ssh username and password of the ru |
    ...   | ru_commands      | yes  | dict | The commands need be sent to ru |
    [Arguments]    ${product_type}
    ...    ${bts_index}
    ...    ${cudu_index}
    ...    ${ru_index}
    ...    ${ru_sn}
    ...    ${ru_user_password}
    ...    ${ru_commands}
    ...    ${timeout}
    ...    &{kwargs}
    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_type}    ${ru_pb_info}
    ...    _ru.init_module_variables    ${product_type}    ${bts_index}    ${cudu_index}    ${ru_index}    ${ru_sn}
    ${ru_user_password}   Run Keyword If    ${ru_user_password}!="None"    _ru.string_convert_to_dictionary
    ...    ${ru_user_password}    ELSE    Set Variable    ${ru_user_password}
    ${ru_commands}    _ru.string_convert_to_dictionary    ${ru_commands}
    ${connection}    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_login_classical    ${product_type}    ${bts_index}    alias=send_command
    ...    ELSE    FAIL    RU Fault Operation for Cloud is currently not supported!
    _ru.send_commands_to_ru    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${ru_commands["commands"]}
    ...    ${ru_commands["connect_type"]}    ${timeout}    connection=${connection}
    [Teardown]    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_logout_classical    connection=${connection}

Upload File To Ru
   [Documentation]     The KW is related to RU operation.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | product_type     | yes  | str  | The type of bts product, e.g. enb; gnb; vdu; vcu |
    ...   | bts_index        | no   | int  | The index of the bts in tl's init.py |
    ...   | cudu_index       | no   | int  | The index of the bts du in tl's init.py |
    ...   | ru_index         | no   | int  | The index of the bts ru in tl's init.py |
    ...   | ru_sn            | no   | int  | The serial number of the ru |
    ...   | ru_user_password | no   | int  | The ssh username and password of the ru |
    ...   | file_path_dict   | yes  | dict | The file_name, resource_path, target_path of operated file |
    [Arguments]    ${product_type}
    ...    ${bts_index}
    ...    ${cudu_index}
    ...    ${ru_index}
    ...    ${ru_sn}
    ...    ${ru_user_password}
    ...    ${file_path_dict}
    ...    ${timeout}
    ...    &{kwargs}
    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_type}    ${ru_pb_info}
    ...    _ru.init_module_variables    ${product_type}    ${bts_index}    ${cudu_index}    ${ru_index}    ${ru_sn}
    ${ru_user_password}   Run Keyword If    ${ru_user_password}!="None"    _ru.string_convert_to_dictionary
    ...    ${ru_user_password}    ELSE    Set Variable    ${ru_user_password}
    ${file_path_dict}    _ru.string_convert_to_dictionary    ${file_path_dict}
    ${connection}    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_login_classical    ${product_type}    ${bts_index}    alias=upload_file
    ...    ELSE    FAIL    RU Fault Operation for Cloud is currently not supported!
    _ru.upload_file_to_ru    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}
    ...    ${file_path_dict["file_name"]}    ${file_path_dict["source_path"]}    ${file_path_dict["target_path"]}
    ...    ${timeout}    connection=${connection}
    [Teardown]    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_logout_classical    connection=${connection}

Download File From Ru
   [Documentation]     The KW is related to RU operation.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | product_type     | yes  | str  | The type of bts product, e.g. enb; gnb; vdu; vcu |
    ...   | bts_index        | no   | int  | The index of the bts in tl's init.py |
    ...   | cudu_index       | no   | int  | The index of the bts du in tl's init.py |
    ...   | ru_index         | no   | int  | The index of the bts ru in tl's init.py |
    ...   | ru_sn            | no   | int  | The serial number of the ru |
    ...   | ru_user_password | no   | int  | The ssh username and password of the ru |
    ...   | file_path_dict   | yes  | dict | The file_name, resource_path, target_path of operated file |
    [Arguments]    ${product_type}
    ...    ${bts_index}
    ...    ${cudu_index}
    ...    ${ru_index}
    ...    ${ru_sn}
    ...    ${ru_user_password}
    ...    ${file_path_dict}
    ...    ${timeout}
    ...    &{kwargs}
    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_type}    ${ru_pb_info}
    ...    _ru.init_module_variables    ${product_type}    ${bts_index}    ${cudu_index}    ${ru_index}    ${ru_sn}
    ${ru_user_password}   Run Keyword If    ${ru_user_password}!="None"    _ru.string_convert_to_dictionary
    ...    ${ru_user_password}    ELSE    Set Variable    ${ru_user_password}
    ${file_path_dict}    _ru.string_convert_to_dictionary    ${file_path_dict}
    ${connection}    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_login_classical    ${product_type}    ${bts_index}    alias=download_file
    ...    ELSE    FAIL    RU Fault Operation for Cloud is currently not supported!
    _ru.download_file_from_ru    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}
    ...    ${file_path_dict["file_name"]}    ${file_path_dict["source_path"]}    ${file_path_dict["target_path"]}
    ...    ${timeout}    connection=${connection}
    [Teardown]    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_logout_classical    connection=${connection}

Get Calibration Data
   [Documentation]     The KW is related to RU operation.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | product_type     | yes  | str  | The type of bts product, e.g. enb; gnb; vdu; vcu |
    ...   | bts_index        | no   | int  | The index of the bts in tl's init.py |
    ...   | cudu_index       | no   | int  | The index of the bts du in tl's init.py |
    ...   | ru_index         | no   | int  | The index of the bts ru in tl's init.py |
    ...   | ru_sn            | no   | int  | The serial number of the ru |
    ...   | ru_user_password | yes  | int  | The ssh username and password of the ru |
    [Arguments]    ${product_type}
    ...    ${bts_index}
    ...    ${cudu_index}
    ...    ${ru_index}
    ...    ${ru_sn}
    ...    ${ru_user_password}
    ...    &{kwargs}
    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_type}    ${ru_pb_info}
    ...    _ru.init_module_variables    ${product_type}    ${bts_index}    ${cudu_index}    ${ru_index}    ${ru_sn}
    ${ru_user_password}   Run Keyword If    ${ru_user_password}!="None"    _ru.string_convert_to_dictionary
    ...    ${ru_user_password}    ELSE    Set Variable    ${ru_user_password}
    ${connection}    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_login_classical    ${product_type}    ${bts_index}    alias=get_calibration_data
    ...    ELSE    FAIL    RU Fault Operation for Cloud is currently not supported!
    ${calibration_data}    _ru.get_ru_calibration_data    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}
    ...    connection=${connection}
    [Return]    ${calibration_data}
    [Teardown]    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_logout_classical    connection=${connection}

Check Calibration Result
   [Documentation]     The KW is related to RU operation.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | product_type     | yes  | str  | The type of bts product, e.g. enb; gnb; vdu; vcu |
    ...   | bts_index        | no   | int  | The index of the bts in tl's init.py |
    ...   | cudu_index       | no   | int  | The index of the bts du in tl's init.py |
    ...   | ru_index         | no   | int  | The index of the bts ru in tl's init.py |
    ...   | ru_sn            | no   | int  | The serial number of the ru |
    ...   | check_point      | yes  | dict | The parameters for checking |
    [Arguments]    ${product_type}
    ...    ${bts_index}
    ...    ${cudu_index}
    ...    ${ru_index}
    ...    ${ru_sn}
    ...    ${check_point}
    ...    &{kwargs}
    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_type}    ${ru_pb_info}
    ...    _ru.init_module_variables    ${product_type}    ${bts_index}    ${cudu_index}    ${ru_index}    ${ru_sn}
    ${check_point}    _ru.string_convert_to_dictionary    ${check_point}
    ${cell_list}    _ru.get_cells_frequency    ${product_type}    ${bts_index}    ${ru_sn}
    ...    alias=check_calibration_${ru_sn}
    _ru.check_ru_calibration_result    ${ute_host}    ${bts_ip}    ${ru_sn}    ${check_point["calibration_data"]}
    ...    ${check_point["antenna_elements"]}    ${cell_list}

Upgrade Ru
   [Documentation]     The KW is related to RU operation.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | product_type     | yes  | str  | The type of bts product, e.g. enb; gnb; vdu; vcu |
    ...   | bts_index        | no   | int  | The index of the bts in tl's init.py |
    ...   | cudu_index       | no   | int  | The index of the bts du in tl's init.py |
    ...   | ru_index         | no   | int  | The index of the bts ru in tl's init.py |
    ...   | ru_sn            | no   | int  | The serial number of the ru |
    ...   | ru_user_password | yes  | int  | The ssh username and password of the ru |
    ...   | ru_sw_storage    | yes  | dict | The parameter dictionary of ru sw file |
    [Arguments]    ${product_type}
    ...    ${bts_index}
    ...    ${cudu_index}
    ...    ${ru_index}
    ...    ${ru_sn}
    ...    ${ru_user_password}
    ...    ${ru_sw_storage}
    ...    &{kwargs}
    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_type}    ${ru_pb_info}
    ...    _ru.init_module_variables    ${product_type}    ${bts_index}    ${cudu_index}    ${ru_index}    ${ru_sn}
    ${ru_user_password}   Run Keyword If    ${ru_user_password}!="None"    _ru.string_convert_to_dictionary
    ...    ${ru_user_password}    ELSE    Set Variable    ${ru_user_password}
    ${ru_sw_storage}    _ru.string_convert_to_dictionary    ${ru_sw_storage}
    ${connection}    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_login_classical    ${product_type}    ${bts_index}    alias=upgrade_ru
    ...    ELSE    FAIL    RU Fault Operation for Cloud is currently not supported!
    _ru.upgrade_ru    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${ru_sw_storage}
    ...    ${ru_pb_info}    connection=${connection}
    [Teardown]    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_logout_classical    connection=${connection}

Check RU Upgrade
    [Documentation]     The KW is related to RU operation.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | product_type     | yes  | str  | The type of bts product, e.g. enb; gnb; vdu; vcu |
    ...   | bts_index        | no   | int  | The index of the bts in tl's init.py |
    ...   | cudu_index       | no   | int  | The index of the bts du in tl's init.py |
    ...   | ru_index         | no   | int  | The index of the bts ru in tl's init.py |
    ...   | ru_sn            | no   | int  | The serial number of the ru |
    ...   | ru_user_password | yes  | int  | The ssh username and password of the ru |
    [Arguments]    ${product_type}
    ...    ${bts_index}
    ...    ${cudu_index}
    ...    ${ru_index}
    ...    ${ru_sn}
    ...    ${ru_sw_storage}
    ...    &{kwargs}
    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_type}    ${ru_pb_info}
    ...    _ru.init_module_variables    ${product_type}    ${bts_index}    ${cudu_index}    ${ru_index}    ${ru_sn}
    ${ru_sw_storage}    _ru.string_convert_to_dictionary    ${ru_sw_storage}
    ${connection}    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_login_classical    ${product_type}    ${bts_index}    alias=check_upgrade_${ru_sn}
    ...    ELSE    FAIL    Operation for Cloud is currently not supported!
    _ru.check_ru_upgrade_result    ${ru_sn}     ${ru_sw_storage}    connection=${connection}
    [Teardown]    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_logout_classical    connection=check_upgrade_${ru_sn}

Get Ru Log
   [Documentation]     The KW is related to RU operation.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | product_type     | yes  | str  | The type of bts product, e.g. enb; gnb; vdu; vcu |
    ...   | bts_index        | no   | int  | The index of the bts in tl's init.py |
    ...   | cudu_index       | no   | int  | The index of the bts du in tl's init.py |
    ...   | ru_index         | no   | int  | The index of the bts ru in tl's init.py |
    ...   | ru_sn            | no   | int  | The serial number of the ru |
    ...   | ru_user_password | no   | int  | The ssh username and password of the ru |
    ...   | ru_log_info      | yes  | dict  | The type and name of the ru log that needs to be obtained or checked |
    [Arguments]    ${product_type}
    ...    ${bts_index}
    ...    ${cudu_index}
    ...    ${ru_index}
    ...    ${ru_sn}
    ...    ${ru_user_password}
    ...    ${ru_log_info}
    ...    &{kwargs}
    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_type}    ${ru_pb_info}
    ...    _ru.init_module_variables    ${product_type}    ${bts_index}    ${cudu_index}    ${ru_index}    ${ru_sn}
    ${ru_user_password}   Run Keyword If    ${ru_user_password}!="None"    _ru.string_convert_to_dictionary
    ...    ${ru_user_password}    ELSE    Set Variable    ${ru_user_password}
    ${ru_log_info}    _ru.string_convert_to_dictionary    ${ru_log_info}
    ${connection}    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_login_classical    ${product_type}    ${bts_index}    alias=get_ru_log
    ...    ELSE    FAIL    Operation for Cloud is currently not supported!
    Run Keyword And Return    _ru.get_ru_${ru_log_info["log_type"]}_log    ${ute_host}    ${bts_ip}    ${ru_sn}
    ...    ${ru_user_password}    log_name=${ru_log_info["log_name"]}    target_path=${ru_log_info["target_path"]}
    ...    connection=${connection}
    [Teardown]    Run Keyword If    "${product_type}"=="gnb" or "${product_type}"=="enb"
    ...    _ru.bts_logout_classical    connection=${connection}

Check Ru Log
   [Documentation]     The KW is related to RU operation.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | product_type     | yes  | str  | The type of bts product, e.g. enb; gnb; vdu; vcu |
    ...   | bts_index        | no   | int  | The index of the bts in tl's init.py |
    ...   | cudu_index       | no   | int  | The index of the bts du in tl's init.py |
    ...   | ru_index         | no   | int  | The index of the bts ru in tl's init.py |
    ...   | ru_sn            | no   | int  | The serial number of the ru |
    ...   | ru_user_password | no   | int  | The ssh username and password of the ru |
    ...   | ru_log_info      | yes  | str  | The name of the ru log that needs to be obtained or checked |
    ...   | check_point      | no   | dict | reserved |
    [Arguments]    ${product_type}
    ...    ${bts_index}
    ...    ${cudu_index}
    ...    ${ru_index}
    ...    ${ru_sn}
    ...    ${ru_user_password}
    ...    ${ru_log_info}
    ...    ${check_point}
    ...    &{kwargs}
    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_type}    ${ru_pb_info}
    ...    _ru.init_module_variables    ${product_type}    ${bts_index}    ${cudu_index}    ${ru_index}    ${ru_sn}
    ${ru_user_password}   Run Keyword If    ${ru_user_password}!="None"    _ru.string_convert_to_dictionary
    ...    ${ru_user_password}    ELSE    Set Variable    ${ru_user_password}
    ${check_point}   Run Keyword If    "${check_point}"!="None"    _ru.string_convert_to_dictionary
    ...    ${check_point}    ELSE    Set Variable    ${check_point}
    ${ru_log_info}    _ru.string_convert_to_dictionary    ${ru_log_info}
    Run Keyword And Return    _ru.check_ru_${ru_log_info["log_type"]}_log
    ...    log_name=${ru_log_info["log_name"]}    target_path=${ru_log_info["target_path"]}
    ...    check_point=${check_point}

Get Ru IP
    [Documentation]     The KW is related to RU operation.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | product_type     | yes  | str  | The type of bts product, e.g. enb; gnb; vdu; vcu |
    ...   | bts_index        | no   | int  | The index of the bts in tl's init.py |
    ...   | cudu_index       | no   | int  | The index of the bts du in tl's init.py |
    ...   | ru_index         | no   | int  | The index of the bts ru in tl's init.py |
    ...   | ru_sn            | no   | int  | The serial number of the ru |
    [Arguments]    ${product_type}
    ...    ${bts_index}
    ...    ${cudu_index}
    ...    ${ru_index}
    ...    ${ru_sn}
    ...    &{kwargs}
    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_type}    ${ru_pb_info}
    ...    _ru.init_module_variables    ${product_type}    ${bts_index}    ${cudu_index}    ${ru_index}    ${ru_sn}
    ${ru_ip}    _ru.get_ru_ip_by_sn    ${ru_sn}    ${product_type}    bts_index=${bts_index}
    [Return]    ${ru_ip}

Get RU Measuments
    [Documentation]     The KW is related to RU operation.
    ...   Author: Wu Amy
    ...   Contact: amy.wu@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | product_type     | yes  | str  | The type of bts product, e.g. enb; gnb; vdu; vcu |
    ...   | bts_index        | no   | int  | The index of the bts in tl's init.py |
    ...   | cudu_index       | no   | int  | The index of the bts du in tl's init.py |
    ...   | ru_index         | no   | int  | The index of the bts ru in tl's init.py |
    ...   | ru_sn            | no   | int  | The serial number of the ru |
    [Arguments]    ${product_type}
    ...    ${bts_index}
    ...    ${cudu_index}
    ...    ${ru_index}
    ...    ${ru_sn}
    ...    &{kwargs}
    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_type}    ${ru_pb_info}
    ...    _ru.init_module_variables    ${product_type}    ${bts_index}    ${cudu_index}    ${ru_index}    ${ru_sn}
    ${rmod_real_time_measurements}    _ru.get_rmod_latest_realtime_measurement    ${ru_sn}
    ...    product_type=${product_type}    bts_index=${bts_index}
    ${rmod_measurements}    _ru.get_rmod_measurement_by_sn    ${ru_sn}    uptime    product_type=${product_type}
    ...    bts_index=${bts_index}
    ${ru_measurements}    Create Dictionary    uptime=${rmod_measurements}    &{rmod_real_time_measurements}
    [Return]    ${ru_measurements}

Remove Link
   [Documentation]     The KW is related to fiber switch operation for RU.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | fiber_switch_map | yes  | dict | The variables for fiber switch |
    [Arguments]    ${fiber_switch_map}
    ...    ${kwargs}
    Log To Console    ${kwargs}
    ${fiber_switch_map}    _ru.string_convert_to_dictionary    ${fiber_switch_map}
    _fiber_switch.remove_link    ip=${fiber_switch_map["ip"]}
    ...    user_name=${fiber_switch_map["user_name"]}
    ...    password=${fiber_switch_map["password"]}
    ...    link_ports=${fiber_switch_map["link_ports"]}
    ...    link_type=${fiber_switch_map["link_type"]}
    ...    fw_type=${fiber_switch_map["fw_type"]}

Create Link
   [Documentation]     The KW is related to fiber switch operation for RU.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | fiber_switch_map | yes  | dict | The variables for fiber switch |
    [Arguments]    ${fiber_switch_map}
    ...    ${kwargs}
    Log To Console    ${kwargs}
    ${fiber_switch_map}    _ru.string_convert_to_dictionary    ${fiber_switch_map}
    _fiber_switch.create_link    ip=${fiber_switch_map["ip"]}
    ...    user_name=${fiber_switch_map["user_name"]}
    ...    password=${fiber_switch_map["password"]}
    ...    link_ports=${fiber_switch_map["link_ports"]}
    ...    link_type=${fiber_switch_map["link_type"]}
    ...    fw_type=${fiber_switch_map["fw_type"]}

Set Link
   [Documentation]     The KW is related to fiber switch operation for RU.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | fiber_switch_map | yes  | dict | The variables for fiber switch |
    [Arguments]    ${fiber_switch_map}
    ...    ${kwargs}
    Log To Console    ${kwargs}
    ${fiber_switch_map}    _ru.string_convert_to_dictionary    ${fiber_switch_map}
    _fiber_switch.set_link    ip=${fiber_switch_map["ip"]}
    ...    user_name=${fiber_switch_map["user_name"]}
    ...    password=${fiber_switch_map["password"]}
    ...    link_ports=${fiber_switch_map["link_ports"]}
    ...    fw_type=${fiber_switch_map["fw_type"]}

Reset All Links
   [Documentation]     The KW is related to fiber switch operation for RU.
    ...   Author: Sheng Haoyun
    ...   Contact: haoyun-lyle.sheng@nokia-sbell.com
    ...   | Input Parameters | Man. | Type | Description |
    ...   | fiber_switch_map | yes  | dict | The variables for fiber switch |
    [Arguments]    ${fiber_switch_map}
    ...    ${kwargs}
    Log To Console    ${kwargs}
    ${fiber_switch_map}    _ru.string_convert_to_dictionary    ${fiber_switch_map}
    _fiber_switch.reset_all_links    ip=${fiber_switch_map["ip"]}
    ...    user_name=${fiber_switch_map["user_name"]}
    ...    password=${fiber_switch_map["password"]}
    ...    link_ports=${fiber_switch_map["link_ports"]}
    ...    fw_type=${fiber_switch_map["fw_type"]}

###################### Ru Operation Private Keywords #####################
_ru.send_commands_to_ru
    [Arguments]    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${ru_commands}    ${connect_type}=ssh
    ...    ${timeout}=30s    ${cmd_interval}=1s    ${connection}=${None}
    ${ru_commands}    _ru.string_convert_to_list    ${ru_commands}
    ${type}    Evaluate    type($ru_commands).__name__
    ${ru_commands}    Run Keyword If    "${type}"=="list"    Set Variable    ${ru_commands}
    ...    ELSE    Create List    ${ru_commands}
    ${port_exist}    Run Keyword And Return Status    Variable Should Exist    ${ru_commands["connect_port"]}
    ${port}    Set Variable If    ${port_exist}    ${ru_commands["connect_port"]}    ${DEFAULT_PORT["${connect_type}"]}
    ${alias_pc}    Set Variable    send_command_${ru_sn}
    ${alias_bbu}    Set Variable    ${alias_pc}_bbu
    ${channel_pc}    ${channel_bbu}    _ru.connect_to_ru_container
    ...    ${ute_host}    ${bts_ip}    ${alias_pc}    ${alias_bbu}
    ${ru_ip}    _ru.get_ru_ip_by_sn    ${ru_sn}    connection=${connection}
    ${prompt}    _ru.connect_to_ru    ${ru_ip}    ${ru_user_password}    ${channel_bbu}    ${connect_type}
    ${is_frmon}    Set Variable If    "${connect_type}"=="frmon"    ${True}    ${False}
    Run Keyword If    ${is_frmon}    Call Method    ${channel_bbu}    send
    ...    frmonShellClient localhost ${port}\n
    Run Keyword If    ${is_frmon}    _ru.call_method_recv    ${channel_bbu}
    ...    match=frmonShellClient starting on ip:localhost port:${port}
    ${prompt}    Set Variable If    "${connect_type}"!="ssh"    done ok    ${prompt}
    log to console    *********************** send commands to ru ***********************
    FOR    ${command}    IN    @{ru_commands}
        ${command}    Set Variable If    ${is_frmon}    ${command}\r\n   ${command}\n
        Call Method    ${channel_bbu}    send    ${command}
        ${out}    Wait Until Keyword Succeeds    ${timeout}  9s
        ...    _ru.call_method_recv    ${channel_bbu}    match=${prompt}    interval=${cmd_interval}
    END
    [Return]    ${out}
    [Teardown]    Run Keyword And Ignore Error    _ru.disconnect_to_ru_container
    ...    ${channel_bbu}    ${channel_pc}    ${alias_bbu}    ${alias_pc}

_ru.upload_file_to_ru
    [Arguments]    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}
    ...    ${file_name}    ${source_path}    ${target_path}    ${timeout}=30s    ${connection}=${None}
    ${alias_pc}    Set Variable    upload_file_${ru_sn}
    ${alias_bbu}    Set Variable    ${alias_pc}_bbu
    ${channel_pc}    ${channel_bbu}    _ru.connect_to_ru_container
    ...    ${ute_host}    ${bts_ip}    ${alias_pc}    ${alias_bbu}
    ${ru_ip}    _ru.get_ru_ip_by_sn    ${ru_sn}    connection=${connection}
    log to console    *********************** upload file to ru ***********************
    ${connection_pc}    tafssh.get_connection_by_alias    alias=${alias_pc}
    ${channel_pc}    Call Method    ${connection_pc}    invoke_shell
    Call Method    ${channel_pc}    settimeout    ${timeout}
    Call Method    ${channel_pc}    send
    ...    sshpass -p 'oZPS0POrRieRtu' scp ${source_path}/${file_name} toor4nsn@${bts_ip}:/user/toor4nsn\n
    _ru.call_method_recv    ${channel_pc}    $   interval=10s    timeout=${timeout}
    Call Method    ${channel_bbu}    send    ls /user/toor4nsn\n
    _ru.call_method_recv    ${channel_bbu}    match=${file_name}    interval=1s
#    tafssh.upload_file
#    ...    local_path=${source_path}/${file_name}    remote_path=/user/toor4nsn    connection=${alias_bbu}
    ${bbu_path}    Set Variable    /user/toor4nsn
    FOR    ${retry}    IN RANGE    ${3}
        Run Keyword If    "${ru_user_password}"!="None"    Call Method    ${channel_bbu}    send
        ...    scp ${bbu_path}/${file_name} ${ru_user_password["username"]}@${ru_ip}:${target_path}/${file_name}\n
        ...    ELSE    Call Method    ${channel_bbu}    send
        ...    scp -O -o StrictHostKeyChecking\=no ${bbu_path}/${file_name} root@${ru_ip}:${target_path}/${file_name}\n
        ${out}    Run Keyword If    "${ru_user_password}"!="None"    _ru.call_method_recv
        ...    ${channel_bbu}    interval=15s    timeout=${timeout}
        ${ret1}    Run Keyword And Return Status    Should Contain    ${out}    (yes/no/[fingerprint])?
        ${ret2}    Run Keyword And Return Status    Should Contain    ${out}    password
        Run Keyword If    ${ret1}    Call Method    ${channel_bbu}    send     yes\n
        ${ret3}    Run Keyword If    ${ret1}    Run Keyword And Return Status
        ...    _ru.call_method_recv    ${channel_bbu}    match=password    interval=3s    timeout=${timeout}
        Run Keyword If    ${ret2} or ${ret3}
        ...    Call Method    ${channel_bbu}    send     ${ru_user_password["password"]}\n
        ${status1}    run keyword and return status    wait until keyword succeeds    300s    5s
        ...    _ru.call_method_recv    ${channel_bbu}    100%    interval=10s    timeout=${timeout}
        Exit For Loop If    ${status1}
        ${retry}    Evaluate    ${retry}+1
    END
    Run Keyword If    "${retry}"=="3"    FAIL    Upload RU SW package failed!
    _ru.connect_to_ru    ${ru_ip}    ${ru_user_password}    ${channel_bbu}
    Call Method    ${channel_bbu}    send    ls ${target_path}\n
    _ru.call_method_recv    ${channel_bbu}    match=${file_name}    interval=1s
    [Teardown]    Run Keyword And Ignore Error    _ru.disconnect_to_ru_container
    ...    ${channel_bbu}    ${channel_pc}    ${alias_bbu}    ${alias_pc}

_ru.download_file_from_ru
    [Arguments]    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${file_name}    ${source_path}
    ...    ${target_path}    ${timeout}=60    ${connection}=${None}
    ${alias_pc}    Set Variable    download_file_${ru_sn}
    ${alias_bbu}    Set Variable    ${alias_pc}_bbu
    ${bbu_tmp_path}    Set Variable    /user/toor4nsn/download_files
    ${channel_pc}   ${channel_bbu}    _ru.connect_to_ru_container
    ...    ${ute_host}    ${bts_ip}    ${alias_pc}    ${alias_bbu}
    ${ru_ip}    _ru.get_ru_ip_by_sn    ${ru_sn}    connection=${connection}
    log to console    *********************** dowload file from ru ***********************
    ${out}    tafssh.execute    command=dir ${target_path}    connection=${alias_pc}
    ${path_not_exist}    Run Keyword And Return Status    Should Contain    ${out}    No such file or directory
    Run Keyword If    ${path_not_exist}    tafssh.execute    mkdir ${target_path}    connection=${alias_pc}
    ${out}    tafssh.execute    command=dir ${bbu_tmp_path}    connection=${alias_bbu}
    ${path_not_exist}    Run Keyword And Return Status    Should Contain    ${out}    No such file or directory
    Run Keyword If    ${path_not_exist}    tafssh.execute
    ...    mkdir ${bbu_tmp_path}    connection=${alias_bbu}
    ${out}    Run Keyword If    ${ru_user_password}!="None"    Call Method    ${channel_bbu}    send
    ...    scp ${ru_user_password["username"]}@${ru_ip}:${source_path}/${file_name} ${bbu_tmp_path}\n
    ...    ELSE    Call Method    ${channel_bbu}    send
    ...    scp -O -o StrictHostKeyChecking\=no root@${ru_ip}:${source_path}/${file_name} ${bbu_tmp_path}\n
    ${status}    Run Keyword And Return Status    Run Keyword If    ${ru_user_password}!="None"
    ...    _ru.call_method_recv    ${channel_bbu}    password    interval=3s    timeout=${timeout}
    Run Keyword If    ${ru_user_password}!="None" and ${status}
    ...    Call Method    ${channel_bbu}    send     ${ru_user_password["password"]}\n
    wait until keyword succeeds    120s    10s    _ru.call_method_recv
    ...    ${channel_bbu}    100%    interval=10s    timeout=${timeout}
    ${file_exist}    tafssh.file_exists    ${bbu_tmp_path}/${file_name}    connection=${alias_bbu}
    Should Be True    ${file_exist}
    ${connection_pc}    tafssh.get_connection_by_alias    alias=${alias_pc}
    ${channel_pc}    Call Method    ${connection_pc}    invoke_shell
    Call Method    ${channel_pc}    settimeout    ${30}
    ${out}    Call Method    ${channel_pc}    send
    ...   sshpass -p 'oZPS0POrRieRtu' scp -p -r toor4nsn@${bts_ip}:${bbu_tmp_path}/${file_name} ${target_path}\n
    Run Keyword And Ignore Error    wait until keyword succeeds    120s    10s
    ...    _ru.call_method_recv    ${channel_pc}    100%    interval=10s    timeout=${timeout}
    ${file_exist}    tafssh.file_exists    ${target_path}/${file_name}    connection=${alias_pc}
    Should Be True    ${file_exist}
    ${files}    tafssh.execute    command=ls ${target_path}    connection=${alias_pc}
    Should Not Be Empty    ${files}
    [Teardown]    Run Keyword And Ignore Error    _ru.disconnect_to_ru_container
    ...    ${channel_bbu}    ${channel_pc}    ${alias_bbu}    ${alias_pc}

_ru.upgrade_ru
    [Arguments]    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${ru_sw_storage}    ${ru_pb_info}
    ...    ${connection}=${None}
    ${server_user}    Set Variable    ${ru_sw_storage["sw_server_username"]}
    ${server_passwd}    Set Variable    ${ru_sw_storage["sw_server_password"]}
    ${server_ip}    Set Variable    ${ru_sw_storage["sw_server_ip"]}
    ${sw_path}    Set Variable    ${ru_sw_storage["sw_path"]}
    ${sw_file}    Set Variable    ${ru_sw_storage["sw_file"]}
    ${sw_checksum}    Set Variable    ${ru_sw_storage["sw_checksum"]}
    ${sw_version}    Set Variable    ${ru_sw_storage["sw_version"]}
    ${build_name}    Set Variable    ${ru_sw_storage["build_name"]}
    ${build_version}    Set Variable    ${ru_sw_storage["build_version"]}
    ${sw_type}    Set Variable    ${ru_sw_storage["sw_type"]}
    ${sw_correct}    Set Variable    ${ru_sw_storage["sw_correct"]}
    ${ru_sw_path}    Set Variable    /ram/
    ${local_path}    Set Variable    /home/ute/Downloads/ru_sw
    ${alias_pc}    Set Variable    upgrade_${ru_sn}
    ${alias_bbu}    Set Variable    ${alias_pc}_bbu
    ${alias_sw_server}    Set Variable    ${alias_pc}_sw_server
    ${channel_pc}    ${channel_bbu}    _ru.connect_to_ru_container
    ...    ${ute_host}    ${bts_ip}    ${alias_pc}    ${alias_bbu}
    tafssh.execute    mkdir -p ${local_path}    connection=${alias_pc}
    tafssh.connect_to    hostname=${server_ip}    username=${server_user}
    ...    password=${server_passwd}   proxy=${alias_pc}    alias=${alias_sw_server}
    Call Method    ${channel_pc}    send
    ...    sshpass -p '${server_passwd}' scp -p -r ${server_user}@${server_ip}:${sw_path}/${sw_file} ${local_path}\n
    _ru.call_method_recv    ${channel_pc}    match=$    interval=1s
    ${file_exist}    tafssh.file_exists    ${local_path}/${sw_file}    connection=${alias_pc}
    Should Be True    ${file_exist}    sw file doesn't exist!

    _ru.upload_file_to_ru    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}
    ...    file_name=${sw_file}    source_path=${local_path}    target_path=${ru_sw_path}    connection=${connection}

    ${ru_ip}    _ru.get_ru_ip_by_sn    ${ru_sn}    connection=${connection}
    ${channel_pc}    ${channel_bbu}    _ru.connect_to_ru_container
    ...    ${ute_host}    ${bts_ip}    ${alias_pc}    ${alias_bbu}
    ${prompt}    _ru.connect_to_ru    ${ru_ip}    ${ru_user_password}    ${channel_bbu}
    sleep    5s
    Call Method    ${channel_bbu}    send    stat /${ru_sw_path}/${sw_file}\n
    _ru.call_method_recv    ${channel_bbu}    match=regular file    interval=10s
    Run Keyword If    "${sw_type}"=="normal"    _ru._upgrade_ru_normal    ${channel_bbu}    ${ru_sw_path}    ${sw_file}
    ...    ${sw_checksum}    ${sw_version}    ${build_name}    ${build_version}    ${ru_user_password}    ${sw_correct}
    ...    ELSE IF    "${sw_type}"=="LRM"    _ru._upgrade_ru_lrm    ${channel_bbu}    ${ru_sw_path}    ${sw_file}
    ...    ${sw_checksum}    ${sw_version}    ${build_name}    ${build_version}    ${ru_user_password}    ${sw_correct}
    ...    ELSE IF    "${sw_type}"=="SRM"    _ru._upgrade_ru_srm    ${channel_bbu}    ${ru_sw_path}    ${sw_file}
    ...    ${sw_checksum}    ${sw_version}    ${build_name}    ${build_version}    ${ru_user_password}    ${sw_correct}
    ...    ELSE    FAIL    ${sw_type} is not supported!
    pdu.setup_pdu    model=${ru_pb_info["vendor"]}    host=${ru_pb_info["ip"]}    alias=${alias_pc}
    pdu.power_off    port=${ru_pb_info["port"]}    pdu_device=${alias_pc}
    sleep    10s
    pdu.power_on    port=${ru_pb_info["port"]}    pdu_device=${alias_pc}
    wait until keyword succeeds    2000s    10s
    ...    _ru.connect_to_ru    ${ru_ip}    ${ru_user_password}    ${channel_bbu}
    [Teardown]    Run Keyword And Ignore Error    Run Keywords    _ru.disconnect_to_ru_container
    ...    ${channel_bbu}    ${channel_pc}    ${alias_bbu}    ${alias_pc}
    ...    AND    tafssh.disconnect    connection=${alias_sw_server}

_ru.check_ru_upgrade_result
    [Arguments]    ${ru_sn}    ${ru_sw_storage}    ${connection}=default
    ${rmod_l_info_list}    coam.get_managed_objects    RMOD_L    connection=${connection}
    FOR    ${rmod_l_info}    IN    @{rmod_l_info_list}
        Exit For Loop If    "${rmod_l_info["parameters"]["serialNumber"]}" != "${ru_sn}"
    END
    Should Not Be Empty    ${rmod_l_info["parameters"]["stateInfo"]}
    Should Be Equal As Strings    ${rmod_l_info["parameters"]["stateInfo"]["availabilityStatus"]}     Online
    ${rmod_r_info_list}    coam.get_managed_objects    RMOD_R    connection=${connection}
    FOR    ${rmod_r_info}    IN    @{rmod_r_info_list}
        Exit For Loop If    "${rmod_r_info["parameters"]["serialNumber"]}" != "${ru_sn}"
    END
    Should Not Be Empty    ${rmod_r_info["distName"]}
    Run Keyword If    '${rmod_r_info["parameters"]["activeSwVersion"]}'!='${ru_sw_storage["build_version"]}'
    ...    FAIL    Upgrade RRU failed!
    ...    ELSE    Log To Console   Upgrade RF factory successfully!

_ru.upgrade_ru_normal
    [Arguments]    ${channel}    ${file_path}    ${file_name}    ${sw_checksum}    ${sw_version}    ${build_name}
    ...    ${build_version}    ${ru_user_password}=None    ${sw_correct}=${True}
    Log To Console    ${ru_user_password}
    ${match_status}    Set Variable If    "${sw_correct}"=="True"    OK    fail
    Call Method    ${channel}    send
    ...    SWmanShellCommand -s ${file_path}/${file_name} ${sw_checksum} ${sw_version} ""\n
    Run Keyword And Return Status    wait until keyword succeeds    120s    1s
    ...    _ru.call_method_recv    ${channel}    match=(?s).*status:\\s+${match_status}.*
    Run Keyword If    "${sw_correct}"=="True"    Call Method    ${channel}    send
    ...    SWmanShellCommand -a ${build_name} ${build_version} ${file_name} ${sw_version}\n
    Run Keyword If    "${sw_correct}"=="True"   wait until keyword succeeds    120s    1s
    ...    _ru.call_method_recv    ${channel}    match=(?s).*status:\\s+${match_status}.*

_ru.upgrade_ru_LRM
    [Arguments]    ${channel}    ${file_path}    ${file_name}    ${sw_checksum}    ${sw_version}    ${build_name}
    ...    ${build_version}    ${ru_user_password}=None    ${sw_correct}=${True}
    Log To Console    ${ru_user_password}
    ${match_status}    Set Variable If    "${sw_correct}"=="True"    OK    fail
    Call Method    ${channel}    send
    ...    SWmanShellCommand -s ${file_path}/${file_name} ${sw_checksum} ${sw_version} ""\n
    ${timeout}    Set Variable If    "${sw_correct}"=="True"    1800s    120s
    wait until keyword succeeds    ${timeout}    1s
    ...    _ru.call_method_recv    ${channel}    match=(?s).*status:\\s+${match_status}.*
    Run Keyword If    "${sw_correct}"=="True"    Call Method    ${channel}    send
    ...    SWmanShellCommand -a ${build_name} ${build_version} ${file_name} ${sw_version}\n
    Run Keyword If    "${sw_correct}"=="True"    wait until keyword succeeds    ${timeout}    1s
    ...    _ru.call_method_recv    ${channel}    match=(?s).*status:\\s+${match_status}.*

_ru.upgrade_ru_SRM
    [Arguments]    ${channel}    ${file_path}    ${file_name}    ${sw_checksum}    ${sw_version}    ${build_name}
    ...    ${build_version}    ${ru_user_password}=None    ${sw_correct}=${True}
    Log To Console    ${sw_checksum}
    Log To Console    ${ru_user_password}
    ${match_status}    Set Variable If    "${sw_correct}"=="True"    OK    fail
    Call Method    ${channel}    send
    ...    SWmanShellCommand -s ${file_path}/${file_name} ${sw_version} "${build_version}" "jekins"\n
    ${timeout}    Set Variable If    "${sw_correct}"=="True"    1800s    120s
    wait until keyword succeeds    ${timeout}    1s
    ...    _ru.call_method_recv    ${channel}    match=(?s).*status:\\s+${match_status}.*
    Run Keyword If    "${sw_correct}"=="True"    Call Method    ${channel}    send
    ...    SWmanShellCommand -a "${file_name}" "${build_name}" "${file_name}" "${build_version}"\n
    Run Keyword If    "${sw_correct}"=="True"    wait until keyword succeeds    ${timeout}    1s
    ...    _ru.call_method_recv    ${channel}    match=(?s).*status:\\s+${match_status}.*

_ru.get_ru_calibration_data
    [Arguments]    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${connection}=${None}
    ${alias_pc}    Set Variable    calibration_${ru_sn}
    ${alias_bbu}    Set Variable    ${alias_pc}_bbu
    ${channel_pc}    ${channel_bbu}    _ru.connect_to_ru_container
    ...    ${ute_host}    ${bts_ip}    ${alias_pc}    ${alias_bbu}
    ${ru_ip}    _ru.get_ru_ip_by_sn    ${ru_sn}    connection=${connection}
    _ru.connect_to_ru    ${ru_ip}    ${ru_user_password}    ${channel_bbu}
    Run Keyword If    ${ru_user_password}!="None"    Call Method    ${channel_bbu}    send    sudo bfcali -stat\n
    ...    ELSE    FAIL    Calibration doesn't support root!
    ${calibration_data}    _ru.call_method_recv    ${channel_bbu}    interval=300s
    Should Contain    ${calibration_data}    Latest calibration:
    ${calibration_data}    Replace String    ${calibration_data}   \r  ${EMPTY}
    ${calibration_data}    Replace String    ${calibration_data}   \n  ${EMPTY}
    [Return]    ${calibration_data}

_ru.get_ru_cells_for_calibration
    [Arguments]    ${ru_id}    ${cell_info}      ${cell_list}
    FOR    ${cell}    IN    @{cell_info}
        Run Keyword If    "${ru_id}" in "${cell}"    Append To List    ${cell_list}    ${cell}
    END
    [Return]    ${cell_list}

_ru.get_cells_frequency
    [Arguments]    ${product_type}    ${bts_index}    ${ru_sn}    ${alias}=default
    ${connection}     _ru.bts_login_classical
    ...    product_type=${product_type}    bts_index=${bts_index}    alias=${alias}
    ${ru_info_list}    coam.get_frm    connection=${connection}    timeout=60
    FOR    ${ru_info}    IN    @{ru_info_list}
        Exit For Loop If    "${ru_info["serialNumber"]}"=="${ru_sn}"
    END
    ${ru_id}    Split String    ${ru_info["id"]["runtime"]}    /
    ${out_info}    coam.get_cell_list    connection=${connection}    detailed_output=True
    ${cell_infos}    Get Dictionary Values    ${out_info["requestMessage"]["cells"]}
    ${cell_list}    Create List
    FOR    ${cell_info}    IN    @{cell_infos}
         ${cell_list}    _ru.get_ru_cells_for_calibration    ${ru_id[-1]}    ${cell_info}    ${cell_list}
    END
    [Return]    ${cell_list}
    [Teardown]    _ru.bts_logout_classical    ${connection}

_ru.check_calibration_info
    [Arguments]    ${cali_info}    ${out_frequency}    ${out_elements}
    FOR    ${info}    IN    @{cali_info}
        ${tx_status}    Run Keyword And Return Status    Should Match Regexp    ${info}
        ...    (?s).*Carrier name:.*TX_.*Carrier frequency: ${out_frequency}.*${out_elements}
        Exit For Loop If    ${tx_status}
    END
    FOR    ${info}    IN    @{cali_info}
        ${rx_status}    Run Keyword And Return Status    Should Match Regexp    ${info}
        ...    (?s).*Carrier name:.*RX_.*Carrier frequency: ${out_frequency}.*${out_elements}
        Exit For Loop If    ${rx_status}
    END
    Should Be True    ${tx_status} and ${rx_status}

_ru.check_ru_calibration_result
    [Arguments]    ${ute_host}    ${bts_ip}    ${ru_sn}    ${calibration_data}    ${antenna_elements}    ${cell_list}
    Log To Console    ${ute_host}
    Log To Console    ${bts_ip}
    Log To Console    ${ru_sn}
    ${calibration_data}    Split String     ${calibration_data}    Latest calibration:
    FOR    ${cell_info}    IN    @{cell_list}
        ${status}    Run Keyword And Return Status    Variable Should Exist    ${cell_info["earfcn"]}
        ${cell_fcn}    Set Variable If    ${status}    ${cell_info["earfcn"]}    ${cell_info["nrarfcn"]}
        ${cell_frequency}=    Run Keyword If    ${status}    change_earfcn_to_frequency    ${cell_fcn}
        ...    ELSE IF    600000<${cell_fcn}<2016666    Evaluate    3000+0.015*(${cell_fcn}-600000)
        ...    ELSE IF    0<${cell_fcn}<590000    Evaluate    0+(${cell_fcn}-0)/200
        ...    ELSE    Evaluate    24250.08+0.06*(${cell_fcn}-2016667)
        _ru.check_calibration_info    ${calibration_data}    ${cell_frequency}
        ...    Successfully calibrated antenna elements: ${antenna_elements}
    END

_ru.bts_login_classical
    [Arguments]    ${product_type}=gnb    ${bts_index}=${0}    ${alias}=default
    ${site_info}    get_site_info    product_type=${product_type}    info_type=oam    bts_index=${bts_index}
    coam.connect_to    bts_host=${site_info.addr}
    ...    username=${site_info.username}
    ...    password=${site_info.password}
    ...    admin_api_log_dir=${OUTPUT_DIR}
    ...    use_ssl=${True}
    ...    update_interval=${5000}
    ...    name=${alias}
    [Return]    ${alias}

_ru.bts_logout_classical
    [Arguments]    ${connection}=default
    coam.teardown    connection=${connection}
    [Return]    ${connection}

_ru.init_module_variables
    [Arguments]    ${product_type}
    ...    ${bts_index}
    ...    ${cudu_index}
    ...    ${ru_index}
    ...    ${ru_sn}
    ${ru_sn}    Run Keyword If    "${ru_sn}"!="None"    Set Variable    ${ru_sn}
    ...   ELSE IF   "${product_type}"=="gnb"   Set Variable
    ...   ${tl.gnbs[${bts_index}].dus[${cudu_index}].rus[${ru_index}].serial_number}
    ...   ELSE IF   "${product_type}"=="enb"   Set Variable   ${tl.enbs[${bts_index}].rms[${ru_index}].serial_number}
    ${sn_bts_index}    ${sn_cudu_index}    ${sn_ru_index}    get_ru_index_by_sn    ${product_type}    ${ru_sn}    ${tl}
    ${bts_index}    Set Variable If    "${ru_sn}"!="None"    ${sn_bts_index}    ${bts_index}
    ${cudu_index}    Set Variable If    "${ru_sn}"!="None"    ${sn_cudu_index}    ${cudu_index}
    ${ru_index}    Set Variable If    "${ru_sn}"!="None"    ${sn_ru_index}    ${ru_index}
    ${ute_host}    Set Variable    ${tl.test_pcs[${bts_index}].default_ssh_connection_details.addr}
    ${bts_ip}    Run Keyword If    "${product_type}"=="gnb"
    ...    Set Variable   ${tl.gnbs[${bts_index}].cu.backhaul_site_oam_ip}
    ...    ELSE IF   "${product_type}"=="enb"   Set Variable
    ...    ${tl.enbs[${bts_index}].system_module.common_units[0].lmp_connection.addr}
    ${ru_type}    Run Keyword If    "${product_type}"=="gnb"   Set Variable
    ...   ${tl.gnbs[${bts_index}].dus[${cudu_index}].rus[${ru_index}].radio_type}
    ...   ELSE IF   "${product_type}"=="enb"   Set Variable   ${tl.enbs[${bts_index}].rms[${ru_index}].radio_type}
    ${ru_pdu}    Run Keyword If    "${product_type}"=="gnb"   Set Variable
    ...   ${tl.gnbs[${bts_index}].dus[${cudu_index}].rus[${ru_index}].pdu_port}
    ...   ELSE IF   "${product_type}"=="enb"   Set Variable   ${tl.enbs[${bts_index}].rms[${ru_index}].pdu_port}
    ${ru_pb_info}    create dictionary    vendor=${ru_pdu.pdu.vendor}    ip=${ru_pdu.pdu.addr}    port=${ru_pdu.port_no}
#    ${init_variables}    create dictionary    ute_host=${ute_host}    bts_ip=${bts_ip}    ru_sn=${ru_sn}
#    ...    ru_tyoe=${ru_type}    ru_pb_info=${ru_pb_info}
    [Return]    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_type}    ${ru_pb_info}

_ru.init_keyword_variables
    [Arguments]    ${keys}    &{_kwargs}
    ${keys_list}    Split String    ${keys}    :
    FOR    ${key}    IN    @{keys_list}
        Set Test Variable    ${${key}}    ${_kwargs["_kwargs"]["${key}"]}
    END

_ru.get_ru_ip_by_sn
    [Arguments]    ${ru_sn}    ${product_type}=gnb    ${bts_index}=${0}    ${connection}=${None}
    ${conn}    Run Keyword If    "${connection}" == "${None}"    _ru.bts_login_classical    ${product_type}
    ...    ${bts_index}    alias=get_ru_ip
    ...    ELSE    Set Variable    ${connection}
    ${rmod_l_info_list}    coam.get_managed_objects    RMOD_L    connection=${conn}
    FOR    ${rmod_l_info}    IN    @{rmod_l_info_list}
        Continue For Loop If    "${rmod_l_info["parameters"]["serialNumber"]}" != "${ru_sn}"
        ${ip_addr}    Set Variable      ${rmod_l_info["parameters"]["ipAddress"]}
        Exit For Loop If    "${ip_addr}" != "0.0.0.0"
    END
    Should Be True    "${rmod_l_info["parameters"]["serialNumber"]}" == "${ru_sn}"    msg=Can not find radio(${ru_sn})
    Should Be True    "${ip_addr}" != "0.0.0.0"    msg=Can not find useful ru ip
    [Return]   ${ip_addr}
    [Teardown]    Run Keyword If    "${connection}" == "${None}"    _ru.bts_logout_classical    connection=${conn}

_ru.connect_to_bts
    [Arguments]    ${ute_host}    ${bts_ip}    ${alias_pc}    ${alias_bbu}
    tafssh.connect_to    hostname=${ute_host}    username=ute    key_path=/home/ute/.ssh/id_rsa    alias=${alias_pc}
    tafssh.connect_to    hostname=${bts_ip}    username=toor4nsn    password=oZPS0POrRieRtu    proxy=${alias_pc}
    ...    alias=${alias_bbu}

_ru.disconnect_to_bts
    [Arguments]    ${alias_bbu}    ${alias_pc}
    tafssh.disconnect    connection=${alias_bbu}
    tafssh.disconnect    connection=${alias_pc}

_ru.connect_to_ru_container
    [Arguments]    ${ute_host}    ${bts_ip}    ${alias_pc}    ${alias_bbu}
    _ru.connect_to_bts    ${ute_host}    ${bts_ip}    ${alias_pc}    ${alias_bbu}
    ${out}    tafssh.execute    command=lxc-ls --active    connection=${alias_bbu}
    ${match_info}    Should Match Regexp    ${out}    0x.?018
    ${connection_pc}    tafssh.get_connection_by_alias    alias=${alias_pc}
    ${connection_bbu}    tafssh.get_connection_by_alias    alias=${alias_bbu}
    ${channel_pc}    Call Method    ${connection_pc}    invoke_shell
    ${channel_bbu}    Call Method    ${connection_bbu}    invoke_shell
    Call Method    ${channel_pc}    settimeout    ${30}
    Call Method    ${channel_bbu}    settimeout    ${30}
    Call Method    ${channel_bbu}    send    lxc-attach -n ${match_info}\n
    _ru.call_method_recv    ${channel_bbu}    match=~ >    interval=1s
    [Return]    ${channel_pc}    ${channel_bbu}

_ru.get_rmod_measurement_by_sn
    [Arguments]    ${ru_sn}    ${filter}    ${product_type}=gnb    ${bts_index}=${0}    ${connection}=${None}
    ${conn}    Run Keyword If    "${connection}" == "${None}"    _ru.bts_login_classical    ${product_type}
    ...    ${bts_index}    alias=get_ru_ip
    ...    ELSE    Set Variable    ${connection}
    ${rmod_r_distname}    _ru.get_r_object_distname_by_sn    class_name=RMOD_R    sn=${ru_sn}    connection=${conn}
    ${rmod_measurement_response}    coam.get_rmod_measurements_by_id    ${rmod_r_distname}    filter=${filter}
    ...    connection=${conn}
    ${rmod_measurement}    Get From Dictionary    ${rmod_measurement_response}    ${filter}
    [Return]    ${rmod_measurement}
    [Teardown]    Run Keyword If    "${connection}" == "${None}"    _ru.bts_logout_classical    connection=${conn}

_ru.get_rmod_latest_realtime_measurement
    [Arguments]    ${ru_sn}    ${product_type}=gnb    ${bts_index}=${0}    ${connection}=${None}
    ${conn}    Run Keyword If    "${connection}" == "${None}"    _ru.bts_login_classical    ${product_type}
    ...    ${bts_index}    alias=get_ru_ip
    ...    ELSE    Set Variable    ${connection}
    ${rmod_r_distname}    _ru.get_r_object_distname_by_sn    class_name=RMOD_R    sn=${ru_sn}    connection=${conn}
    ${rmod_id}    Split String From Right    ${rmod_r_distname}    /    1
    ${lastest_measurements}    coam.get_measurements    connection=${conn}
    FOR    ${measurement}    IN    @{lastest_measurements}
        ${object}    Get Dictionary Keys   ${measurement}
        ${object}    Set Variable   ${object[0]}
        ${rmod_object}    Set Variable    ENERGY_EFFICIENCY/RMOD/${rmod_id[-1]}
        ${type}    Evaluate    type($measurement['${object}']).__name__
        ${default}    Create Dictionary    power=-    voltage=-
        ${measurement_value}    Set Variable If    '${type}' == 'dict'    ${measurement['${object}']}    ${default}
        Run Keyword If  '${object}' == '${rmod_object}' and '${type}' != 'dict' and "${measurement['${object}']}" == "Not enabled"
        ...    Log To Console    \nPower and voltage values are available only when parameter actPowerMeter is true!
        Return From Keyword If    '${object}' == '${rmod_object}'    ${measurement_value}
    END
    Fail
    [Teardown]    Run Keyword If    "${connection}" == "${None}"    _ru.bts_logout_classical    connection=${conn}


_ru.get_r_object_distname_by_sn
    [Arguments]    ${class_name}   ${sn}   ${connection}   ${timeout}=10
    ${require_objects}    coam.get_managed_objects   class_name=${class_name}
    ...    timeout=${timeout}    connection=${connection}

    FOR    ${object_info}   IN    @{require_objects}
        Return From Keyword If    '${object_info['parameters']['serialNumber']}'=='${sn}'    ${object_info['distName']}
    END
    Fail

_ru.disconnect_to_ru_container
    [Arguments]    ${channel_bbu}    ${channel_pc}    ${alias_bbu}    ${alias_pc}
    Call Method    ${channel_bbu}    close
    Call Method    ${channel_pc}    close
    _ru.disconnect_to_bts    ${alias_bbu}    ${alias_pc}

_ru.connect_to_ru
    [Arguments]    ${ru_ip}    ${ru_user_password}    ${channel}    ${connect_type}=ssh    ${connect_port}=22
    Run Keyword If    ${ru_user_password}!="None" and "${connect_type}"!="telnet"
    ...    Call Method    ${channel}
    ...    send    ssh -o StrictHostKeyChecking\=no ${ru_user_password["username"]}@${ru_ip} -p ${connect_port}\n
    ...    ELSE IF   "${connect_type}"!="telnet"
    ...    Call Method    ${channel}    send    ssh -o StrictHostKeyChecking\=no ${ru_ip} -p ${connect_port}\n
    ...    ELSE IF   "${connect_type}"=="telnet"    Call Method    ${channel}    send    telnet ${ru_ip} ${connect_port}
    Run Keyword If    ${ru_user_password}!="None"
    ...    _ru.call_method_recv    ${channel}    match=password    interval=3s
    Run Keyword If    ${ru_user_password}!="None" and "${connect_type}"!="telnet"
    ...    Call Method    ${channel}    send     ${ru_user_password["password"]}\n
    ${prompt}    Set Variable If    ${ru_user_password}=="None"    \#    \$
    _ru.call_method_recv    ${channel}    match=${prompt}    interval=3s
    [Return]    ${prompt}

_ru.call_method_recv
    [Arguments]     ${channel}    ${match}=${None}    ${interval}=0s    ${timeout}=10
    ${timeout}    Split String    ${timeout}    s
    sleep    ${interval}
    FOR    ${time}    IN RANGE    ${timeout[0]}
        ${status}    Call Method    ${channel}    recv_ready
        Exit For Loop If    ${status}
        sleep    1s
    END
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Run Keyword If    "${match}"!="None"    should match regexp    ${output}    ${match}
    [Return]    ${output}

_ru.string_convert_to_dictionary
    [Arguments]    ${string}
    ${type}    Evaluate    type($string).__name__
    ${is_string_dict}    Run Keyword If    "${type}"=="str"    Evaluate
    ...    "{" in $string and "}" in $string and ":" in $string
    ${dictionary}    Run Keyword If    "${type}"=="str" and ${is_string_dict}    Evaluate    dict(${string})
    ...    ELSE IF    "${type}"=="str" and not ${is_string_dict}    The String is not in dictionary format!
    ...    ELSE    Set Variable    ${string}
    [Return]    ${dictionary}

_ru.string_convert_to_list
    [Arguments]    ${string}
    ${type}    Evaluate    type($string).__name__
    ${is_string_list}    Run Keyword If    "${type}"=="str"    Evaluate    "[" in "$string" and "]" in "$string"
    ${dictionary}    Run Keyword If    "${type}"=="str" and ${is_string_list}    Evaluate    list(${string})
    ...    ELSE IF    "${type}"=="str" and not ${is_string_list}    The String is not in list format!
    ...    ELSE    Set Variable    ${string}
    [Return]    ${dictionary}

###################### Ru Fault Keywords #####################
_ru.check_ru_fault_active
    [Arguments]    ${fault_id}    ${severity}    ${connection}=default    ${timeout}=30s
    ${fault_info}    Set Variable    faultId=${fault_id},severity=${severity}
    coam.assert_alarm_active    parameters=${fault_info}    connection=${connection}    timeout=${timeout}

_ru.check_ru_fault_inactive
    [Arguments]    ${fault_id}    ${severity}    ${connection}=default    ${timeout}=30s
    ${fault_info}    Set Variable    faultId=${fault_id},severity=${severity}
    coam.assert_inalarm_active    parameters=${fault_info}    connection=${connection}    timeout=${timeout}

_ru.trigger_AZNA_fault_1901
    [Arguments]    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${connection}    ${timeout}
    ...    &{_kwargs}
    ${calibration_dlpathx_path}    Set Variable    /mnt/factory/configs/unit/calibration_dlpathx.bin
    ${calibration_dlpath1_path}    Set Variable    /mnt/factory/configs/unit/calibration_dlpath1.bin
    ${calibration_ulpathx_path}    Set Variable    /mnt/factory/configs/unit/calibration_ulpathx.bin
    ${calibration_ulpath1_path}    Set Variable    /mnt/factory/configs/unit/calibration_ulpath1.bin
    ${trigger_fault_1901_cmds}    Create List
    ...    rm -rf ${calibration_dlpathx_path};mv ${calibration_dlpath1_path} ${calibration_dlpathx_path}
    ...    rm -rf ${calibration_ulpathx_path};mv ${calibration_ulpath1_path} ${calibration_ulpathx_path}
    ${reboot_cmd}    Create List    reboot
    _ru.send_commands_to_ru    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${trigger_fault_1901_cmds}
    ...    connection=${connection}
    _ru.send_commands_to_ru    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${reboot_cmd}
    ...    connection=${connection}
    Wait Until Keyword Succeeds    300s    10s    _ru.check_ru_fault_active
    ...    fault_id=1901    severity=Critical    connection=${connection}    timeout=${timeout}

_ru.clear_AZNA_fault_1901
    [Arguments]    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${connection}    ${timeout}
    ...    &{_kwargs}
    Log To Console    ${timeout}
    ${calibration_dlpathx_path}    Set Variable    /mnt/factory/configs/unit/calibration_dlpathx.bin
    ${calibration_dlpath1_path}    Set Variable    /mnt/factory/configs/unit/calibration_dlpath1.bin
    ${calibration_ulpathx_path}    Set Variable    /mnt/factory/configs/unit/calibration_ulpathx.bin
    ${calibration_ulpath1_path}    Set Variable    /mnt/factory/configs/unit/calibration_ulpath1.bin
    ${clear_fault_1901_cmds}    Create List
    ...    mv ${calibration_dlpathx_path} ${calibration_dlpath1_path}
    ...    mv ${calibration_ulpathx_path} ${calibration_ulpath1_path}
    ${reboot_cmd}    Create List    reboot
    _ru.send_commands_to_ru    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${clear_fault_1901_cmds}
    ...    connection=${connection}
    _ru.send_commands_to_ru    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${reboot_cmd}
    ...    connection=${connection}
    Wait Until Keyword Succeeds    300s    10s    _ru.check_ru_fault_inactive
    ...    fault_id=1901    severity=Critical    connection=${connection}    timeout=30

###################### Ru Logs Keywords #####################
_ru.get_ru_aashell_log
    [Arguments]    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${log_name}    ${target_path}
    ...    ${connection}=${None}
    ${aashell_command}    Set Variable    mkdir /ram/tmp;sh /usr/bin/ccsShell.sh log -a -c full -z /ram/tmp/${log_name}
    _ru.send_commands_to_ru    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${aashell_command}
    ...    timeout=120s    connection=${connection}
    _ru.download_file_from_ru    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${log_name}
    ...    /ram/tmp    ${target_path}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    _ru.send_commands_to_ru    ${ute_host}    ${bts_ip}    ${ru_sn}
    ...    ${ru_user_password}    rm -f /ram/tmp/${log_name}    connection=${connection}

_ru.get_ru_soap_log
    [Arguments]    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}    ${log_name}    ${target_path}
    ...    ${connection}=${None}
    _ru.download_file_from_ru    ${ute_host}    ${bts_ip}    ${ru_sn}    ${ru_user_password}
    ...    ${log_name}    /ram/UnitOAM_SOAP_Runtime_Log    ${target_path}    connection=${connection}
