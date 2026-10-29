*** Settings ***
Library     XML
Library     ../python/parse_soap.py
Library     parse_soap.SOAPParser    WITH NAME    soap

*** Keywords ***
Enable capture soap msg flag on RU
    [Documentation]    Author: Xu Huamin.1
    [Arguments]    ${ru_alias}=RU
    ${cmd_enable_capture_soap_flag}    set variable    /usr/bin/ccsShell.sh rad -pw 0x2c 1
    csn.execute    command=${cmd_enable_capture_soap_flag}    connection=${ru_alias}

Download soap msg from RU
    [Documentation]    Author: Xu Huamin.1
    [Arguments]    ${soap_log}=UnitOAM_SOAP_Log.xml    ${log_path}=${TS_CASE_LOG_PATH}    ${ru_alias}=RU
    csn.Download File    remote_path=/ram/${soap_log}    local_path=${log_path}/${soap_log}    connection=${ru_alias}
    ${cmd_delete_soap_log}    set variable    rm /ram/${soap_log}
    csn.execute    command=${cmd_delete_soap_log}    connection=${ru_alias}
    OperatingSystem.Run    mv '${log_path}/${soap_log}' '${log_path}/${ru_alias}_${soap_log}'
    ${local_path}    set variable    ${log_path}/${ru_alias}_${soap_log}
    [Return]    ${local_path}

Download soap msg from RU Reg
    [Documentation]    Author:Wang Yixiang
    ...            Download soap log with regular expression.
    [Arguments]    ${soap_log}=UnitOAM_SOAP_Log*.xml    ${log_path}=${TS_CASE_LOG_PATH}    ${ru_alias}=RU
    ${soap_log_fullpath}    csn.execute    command=ls /ram/${soap_log}    connection=${ru_alias}
    ${soap_log_fullpath}    Strip String    string=${soap_log_fullpath}
    ${soap_log_path}    ${soap_log_name}    split path    ${soap_log_fullpath}
    ${local_path}    Download soap msg from RU    soap_log=${soap_log_name}    log_path=${log_path}    ru_alias=${ru_alias}
    [Return]    ${local_path}

Get Detail Info In SOAP Message
    [Documentation]    Author: Xu Huamin.1
    ...                Return Dict, Key are productCode,serialNum,moduleType,interfaceType,bldName,bldVersion
    [Arguments]    ${Soap_log_path}
    ${soap_log}    Run    cat "${Soap_log_path}"
    @{msg_list}    Split To Lines    ${soap_log}
    ${productCode}    set variable
    FOR     ${msg}    IN    @{msg_list}
        Continue For Loop If    '${msg}' == ''
        ${msg}    Replace String Using Regexp    ${msg}    <timestamp(.*)Z/>    ${EMPTY}
        ${flag}    Run Keyword And Return Status    xml.parse xml    ${msg}
        ${xml}    Run keyword If    '${flag}'=='False'    Continue For Loop
                    ...     ELSE    xml.parse xml    ${msg}
        ${msg_type}    Get Soap Msg type    ${xml}
        Continue For Loop If    '${msg_type}' == 'UNKNOW'
        ${Status}=    Run Keyword And Return Status     xml.Element Should Not Exist    ${xml}    .//moduleReadyInd/productCode
        Run Keyword If    '${Status}'=='True'     Continue For Loop
        ${productCode}    Run Keyword If    '${msg_type}' == 'MCI'    xml.Get Element Text    ${xml}    Body/moduleReadyInd/productCode
        ${serialNum}    Run Keyword If    '${msg_type}' == 'MCI'    xml.Get Element Text    ${xml}    Body/moduleReadyInd/serialNum
        ${moduleType}    Run Keyword If    '${msg_type}' == 'MCI'    xml.Get Element Text    ${xml}    Body/moduleReadyInd/moduleType
        ${interfaceType}    Run Keyword If    '${msg_type}' == 'MCI'    xml.Get Element Text    ${xml}    Body/moduleReadyInd/interfaceType
        Exit For Loop
    END
    FOR     ${msg}    IN    @{msg_list}
        Continue For Loop If    '${msg}' == ''
        ${msg}    Replace String Using Regexp    ${msg}    <timestamp(.*)Z/>    ${EMPTY}
        ${flag}    Run Keyword And Return Status    xml.parse xml    ${msg}
        ${xml}    Run keyword If    '${flag}'=='False'    Continue For Loop
                    ...     ELSE    xml.parse xml    ${msg}
        ${msg_type}    Get Soap Msg type    ${xml}
        Continue For Loop If    '${msg_type}' == 'UNKNOW' or '${msg_type}' == 'MCI'
        ${Status}=    Run Keyword And Return Status     xml.Element Should Not Exist    ${xml}    .//swInventoryRsp/bldData/bldName
        Run Keyword If    '${Status}'=='True'     Continue For Loop
        ${bldName}    Run Keyword If    '${msg_type}' == 'SIRSP'    xml.Get Element Text    ${xml}    Body/swInventoryRsp/bldData/bldName
        ${bldVersion}    Run Keyword If    '${msg_type}' == 'SIRSP'    xml.Get Element Text    ${xml}    Body/swInventoryRsp/bldData/bldVersion
        Exit For Loop
    END
    &{soap_info}     Create Dictionary   productCode=${productCode}
    ...                                  serialNum=${serialNum}
    ...                                  moduleType=${moduleType}
    ...                                  interfaceType=${interfaceType}
    ...                                  bldName=${bldName}
    ...                                  bldVersion=${bldVersion}
    [Return]    &{soap_info}

Get Soap Msg type
    [Documentation]    Author: Xu Huamin.1
    ...    [PRIVATE]
    [Arguments]    ${xml_content}
    ${MRI}    xml.Get Element Count    ${xml_content}    Body/moduleReadyInd
    ${SIRSP}   xml.Get Element Count    ${xml_content}    Body/swInventoryRsp
    ${type}    Run Keyword If    ${MRI} == 1    set variable    MCI
    ...        ELSE IF    ${SIRSP} == 1    set variable    SIRSP
    ...        ELSE    set variable    UNKNOW
    [Return]    ${type}

Verify SOAP Modify Parameter Req
    [Documentation]  Author: Wang Yixiang
    ...              Description: Verify SOAP log modifyParameterReq to check if value change success

    ...               :param distName_value<str>: attribute(distName) of managedObject, and it will get newValue text of the item
    ...               :param expected_value<str>: the value your expected
    ...               :param log_path<str>: log_path=path+soaplogName, the value can get like following
    ...                     ${log_path}    Download soap msg from RU
    ...               example:
    ...                   Verify SOAP Modify Parameter Req    distName_value=TxArrayCarrier1_1    expected_value=TRUE    log_path=${log_path}
    [Arguments]    ${distName_value}    ${expected_value}    ${log_path}

    ${log_value}    soap.get_soap_msg_modify_parameter_req    log_path=${log_path}    distName_value=${distName_value}
    Should Be Equal As Strings    ${log_value}    ${expected_value}
                                  ...    Verify modifyParameterReq failed,value not matched, name:${distName_value},
                                  ...    log value:${log_value}, expected_value:${expected_value}
    Log To Console    Verify SOAP Modify Parameter Req ${distName_value} success!

Verify SOAP Parameter Change Ind
    [Documentation]  Author: Wang Yixiang
    ...              Description: Verify SOAP log parValueChangeInd to check if value change success
    ...               :param distName_value<str>: attribute(distName) of managedObject, and it will get newValue text of the item
    ...               :param expected_value<str>: the value your expected
    ...               :param log_path<str>: log_path=path+soaplogName, the value can get like following
    ...                     ${log_path}    Download soap msg from RU
    ...               example:
    ...                   Verify SOAP Parameter Change Ind    distName_value=TxArrayCarrier1_1    expected_value=TRUE    log_path=${log_path}
    [Arguments]    ${distName_value}    ${expected_value}    ${log_path}    ${parameter_name}=${None}
    ${log_value}    soap.get_soap_msg_par_value_change_ind    log_path=${log_path}    distName_value=${distName_value}
    ...    parameter_name=${parameter_name}
    Should Be Equal As Strings    ${log_value}    ${expected_value}
                                  ...    Verify parValueChangeInd failed, value not matched, name:${distName_value},
                                  ...    log value:${log_value}, expected_value:${expected_value}
    Log To Console    Verify SOAP Parameter Change Ind ${distName_value} success!

Verify SOAP Supported Feature
    [Documentation]  Author: Lin Zhe
    ...              Description: Verify if SOAP log including Supported Feature
    ...               :param distName_value<str>: attribute(distName) of managedObject, and it will get newValue text of the item
    ...               :param expected_value<str>: the value your expected
    ...               :param log_path<str>: log_path=path+soaplogName, the value can get like following
    ...                     ${log_path}    Download soap msg from RU
    ...               example:
    ...               Verify SOAP Supported Feature    distName_value=supportedFeature20    expected_value=ECPRI_TIMING_CAPABILITY
    ...               log_path=${log_path}
    [Arguments]    ${distName_value}    ${expected_value}    ${log_path}

    ${log_value}    soap.get_soap_msg_supported_feature    log_path=${log_path}    distName_value=${distName_value}
    Should Be Equal As Strings    ${log_value}    ${expected_value}
                                  ...    Verify modifyParameterReq failed,value not matched, name:${distName_value},
                                  ...    log value:${log_value}, expected_value:${expected_value}
    Log To Console    Verify SOAP log including Supported Feature ${distName_value} success!

Get SOAP Message Sw Inventory Rsp
    [Documentation]  Author: Wang Yixiang
    ...              Description: Get detailed SOAP log message of swInventoryRsp and return sw_inventory_rsp_dict
    ...              Return Dict:
    ...              {'fileVersion': 'TRM69.07.R01K', 'bldName': 'TRM69.07.R01K', 'fileName': 'TRM-rfsw-image-install-aeqb_0x26F829D5.tar',
    ...               'usageStatus': 'active', 'fileIntegrity': 'OK', 'bldVersion': 'TRM69.07.R01K'}
    ...               :param log_path<str>: log_path=path+soaplogName, the value can get like following
    ...                     ${log_path}    Download soap msg from RU
    ...               example:
    ...                   ${sw_inventory_rsp_dict}    Get SOAP Message Sw Inventory Rsp    log_path=${log_path}
    [Arguments]    ${log_path}
    ${sw_inventory_rsp_dict}    get_soap_msg_sw_inventory_rsp    log_path=${log_path}
    [Return]    ${sw_inventory_rsp_dict}

Get SOAP Message Module Ready Ack
    [Documentation]  Author: Wang Yixiang
    ...              Description: Get detailed SOAP log message of moduleReadyAck and return module_ready_act_dict
    ...              Return Dict:
    ...              {'timerValue': '20', 'nodeLabelType': '0', 'serialNum': '6Q192613851', 'nodeLabel': '3ac0e77b00fd0000', 'moduleType': 'RRH',
    ...               'moduleId': '/RMOD_L_1/RU_L_1'}
    ...               :param log_path<str>: log_path=path+soaplogName, the value can get like following
    ...                     ${log_path}    Download soap msg from RU
    ...               example:
    ...                   ${module_ready_act_dict}    Get SOAP Message Module Ready Ack    log_path=${log_path}
    [Arguments]    ${log_path}
    ${module_ready_act_dict}    get_soap_msg_module_ready_ack    log_path=${log_path}
    [Return]    ${module_ready_act_dict}

Get SOAP Message Module Ready Ind
    [Documentation]  Author: Wang Yixiang
    ...              Description: Get detailed SOAP log message of moduleReadyInd and return module_ready_ind_dict
    ...              Return Dict:
    ...              {'productCode': '474413A.X14', 'nodeLabelType': '0', 'vendor': 'Nokia', 'hwSwId': '0', 'nodeAddress': '192.168.254.58:13100',
    ...               'restartCause': 'power_on', 'internalEthernetPorts': None, 'interfaceType': 'CPRI', 'serialNum': '6Q192613851',
    ...               'nodeLabel': '3ac0e77b00fd0000', 'moduleType': 'RRH', 'cpriPorts': None, 'bldVersion': 'TRM69.07.R01K',
    ...               'interfaceVersion': '1.87'}
    ...               :param log_path<str>: log_path=path+soaplogName, the value can get like following
    ...                     ${log_path}    Download soap msg from RU
    ...               example:
    ...                   ${module_ready_ind_dict}    Get SOAP Message Module Ready Ind    log_path=${log_path}
    [Arguments]    ${log_path}
    ${module_ready_ind_dict}    get_soap_msg_module_ready_ind    log_path=${log_path}
    [Return]    ${module_ready_ind_dict}

Get SOAP Message Carrier Info
    [Documentation]  Author: Wang Yixiang
    ...              Description: Get detailed SOAP log message of carrier info and return carrier_info_dict
    ...              Return Dict:
    ...              {'power': '34', 'state': 'DISABLED', 'subscribe': 'TRUE', 'bandwidth': '100000000', 'carrier': None,
    ...               'frequency': '3500340000', 'active': 'TRUE', 'array': 'txArray1', 'type': '5G_NR'}
    ...               :param log_path<str>: log_path=path+soaplogName, the value can get like following
    ...                     ${log_path}    Download soap msg from RU
    ...               example:Download soap msg from RU Download soap msg from RU
    ...                   ${carrier_info_dict}    Get SOAP Message Carrier Info    log_path=${log_path}    distName_value=TxArrayCarrier1_1
    [Arguments]    ${log_path}    ${distName_value}
    ${carrier_info_dict}    get_carrier_info    log_path=${log_path}    distName_value=${distName_value}
    [Return]    ${carrier_info_dict}

Get And Convert SOAP Carrier Info to webUI Format
    [Documentation]  Author: Wang Yixiang
    ...              Description: Values of channel bandwidth, frequency unit not match with webUI, convert to same unit
    ...              Return Dict:
    ...              {'power': '34', 'state': 'DISABLED', 'subscribe': 'TRUE', 'bandwidth': '100', 'carrier': None,
    ...               'frequency': '633356', 'active': 'TRUE', 'array': 'txArray1', 'type': '5G_NR'}
    ...               :param log_path<str>: log_path=path+soaplogName, the value can get like following
    ...                     ${log_path}    Download soap msg from RU
    ...               example:
    ...                     ${carrier_info_dict}    Get And Convert SOAP Carrier Info to webUI Format
    ...                                             log_path=${log_path}    distName_value=TxArrayCarrier1_1
    [Arguments]    ${log_path}    ${distName_value}
    ${carrier_info_dict}    get_carrier_info    log_path=${log_path}    distName_value=${distName_value}
    ${convert_carrier_info_dict}    tansfer_carrier_info_to_webUI_format    carrier_info_dict=${carrier_info_dict}
    [Return]    ${convert_carrier_info_dict}

Get SOAP Message Item Count
    [Documentation]  Author: Wang Yixiang
    ...              Description: Get item number, you can use it to check if message send periodically
    ...                 for example check moduleReadyInd and moduleReadyAck
    ...               :param log_path<str>: log_path=path+soaplogName, the value can get like following
    ...                     ${log_path}    Download soap msg from RU
    ...               example:
    ...                     ${count}    Get SOAP Message Item Count    log_path=${log_path}    tag_name=moduleReadyInd
    [Arguments]    ${log_path}    ${tag_name}
    ${count}    get_number_of_item    log_path=${log_path}    tag_name=${tag_name}
    [Return]    ${count}
