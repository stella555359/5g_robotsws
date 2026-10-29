*** Settings ***
Documentation
...    Author: Xu Yuyan   Li Amaand
...    Email address: yuyan.xu@nokia-sbell.com    amaand.li@nokia-sbell.com
...    Maintainer: Xu Yuyan;    Li Amaand
...    Email address: yuyan.xu@nokia-sbell.com;    amaand.li@nokia-sbell.com;
...    Common KWs related to some operation on NOM for AIC.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/09.+AIC+Common+Resource+Supporting+Mode+Improvement


*** Keywords ***
Setup NetAct
    [Arguments]     ${NETACT}
    [Documentation]    Keyword used for set up of NetAct and its cwwas node
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | NETACT    | yes | dictionary, netact info |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | Setup NetAct | NETACT=${NETACT_2002} |
    netact.Add Node    cmwas    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    netact.Add Node    fmwas    ${NETACT['fm_host']}    ${NETACT['user']}    ${NETACT['password']}
    ${web_url}=    netact.Detect Web Url
    netact.Add Web Url    ${web_url}    ${NETACT['user']}    ${NETACT['password']}

Teardown NetAct
    [Documentation]    Keyword used to tear down NetAct and its cwwas node
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | None    | NA | NA |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | Teardown NetAct |
    netact.Delete Node    cmwas
    netact.Delete Node    fmwas
    netact.Clean All

Get FHGW Id
    [Documentation]   Get FHGW Id
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | None    | NA | NA |
    ...
    ...   | Return Value | Description |
    ...   | FHGW_id | FHGW id |
    ...
    ...   Example
    ...  | FHGW_id| Get FHGW Id |
    ${status}    Run Keyword And Return Status    Import Variables    ${tl.gnbs[0].dus[0].fhgws[0].user_config_path}
    Run Keyword If    not ${status}    FAIL    Get FHGW user config file:${tl.gnbs[0].dus[0].fhgws[0].user_config_path} failed!
    ${status}    Run Keyword And Return Status    Set Test Variable     ${FHGW_id}    ${FHGW.fhgwId}
    Run Keyword If    ${status}    Log     FHGW Id is ${FHGW_id}   console=True
    ...    ELSE    FAIL    fhgwId does not existed in ${tl.gnbs[0].dus[0].fhgws[0].user_config_path}!
    [Return]  ${FHGW_id}


Integrate FHGW To NetAct
    [Arguments]     ${fhgw_addr}    ${dist_name}    ${release_version}=FHGW22R4    ${mr}=MRC-COMMON/MR-COMMON   ${security_mode}=no TLS
    [Documentation]   Integrate FHGW To NetAct
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | fhgw_addr    | yes | FHGW ip |
    ...   | dist_name    | yes | FHGW dist name on NetAct |
    ...   | release_version | no | FHGW release version, default is FHGW22R4 |
    ...   | mr  | no | FHGW MR, default is MRC-COMMON/MR-COMMON |
    ...   | security_mode  | no | security mode, default is no TLS |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | Integrate FHGW To NetAct | fhgw_addr=10.108.194.23 | dist_name=PLMN-PLMN/FHGW-11083 | release_version=FHGW22R4
    ...  | mr=MRC-COMMON/MR-COMMON | security_mode=no TLS |
    Run keyword and ignore error    Deintegrate NE From NetAct    ${dist_name}
    sleep    2s
    ${integration_status}    Run Keyword And Return Status    netact.Integrate fhgw with Netact
    ...    release=${release_version}    mr=${mr}     fhgw_address=${fhgw_addr}    dist_name=${dist_name}
    ...    security_mode=${security_mode}
    NetAct CM Upload    dist_names=${dist_name}
    Run Keyword If    ${integration_status}    log to console    FHGW is connected to expected NetAct
    ...    ELSE    FAIL   FHGW is not connected to expected NetAct

Integrate NE To NetAct
    [Arguments]     ${mrbts_addr}    ${dist_name}    ${release_version}=23R2VCU    ${mr}=MRC-CB006543/MR-vCU   ${security_mode}=no TLS
    [Documentation]   Integrate NE To NetAct
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | mrbts_addr    | yes | mrbts ip |
    ...   | dist_name    | yes | mrbts dist name on NetAct |
    ...   | release_version | no | mrbts release version, default is 23R2VCU |
    ...   | mr  | no | mrbts MR, default is MRC-CB006543/MR-vCU |
    ...   | security_mode  | no | security mode, default is no TLS |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | Integrate NE To NetAct | mrbts_addr=10.110.83.143 | dist_name=PLMN-PLMN/FHGW-11083 | release_version=23R2VCU
    ...  | mr=MRC-CB006543/MR-vCU | security_mode=no TLS |
    Run keyword and ignore error    Deintegrate NE From NetAct    ${dist_name}
    sleep    2s
    ${integration_status}    Run Keyword And Return Status    netact.Integrate MRBTS with Netact
    ...    release=${release_version}    mr=${mr}     mrbts_address=${mrbts_addr}    dist_name=${dist_name}
    ...    security_mode=${security_mode}
    NetAct CM Upload    dist_names=${dist_name}
    Run Keyword If    ${integration_status}    log to console    BTS is connected to expected NetAct
    ...    ELSE    FAIL   BTS is not connected to expected NetAct

Deintegrate NE From NetAct
    [Arguments]     ${dist_name}
    [Documentation]   Deintegrate NE From NetAct
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | dist_name    | yes | mrbts dist name on NetAct |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | Deintegrate NE From NetAct | dist_name=PLMN-PLMN/FHGW-11083 |
    ${deintegration_status}    Run Keyword And Return Status    netact.deintegrate mrbts from netact    dist_name=${dist_name}
    Run Keyword If    ${deintegration_status}    log to console    NE deintegrate from NetAct success
    ...    ELSE    FAIL   NE deintegrate from NetAct Failed

Generate Formatted Timestamp
    [Documentation]
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | None | NA |
    ...    | Return Value | Description |
    ...    | current_time | NA |
    ...
    ...   Example
    ...  | ${current_time} | Generate Formatted Timestamp |
    ${year}    ${month}    ${day}    ${hour}    ${min}    ${sec}=    Get Time    format=year,month,day,hour,min,sec
    ${current_time}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}-${sec}
    [Return]  ${current_time}

NetAct CM Upload
    [Arguments]    ${dist_names}    ${parameters}=None    ${check_feedback}=${False}
    [Documentation]   NetAct CM Upload
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | dist_name    | yes | mrbts dist name on NetAct |
    ...   | parameters    | no | addtion parameters like -sranBtsHwContentInUse, -lteHwContentInUse|
    ...   | check_feedback    | no | whether check detail message in upload feedback|
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | NetAct CM Upload | dist_name=PLMN-PLMN/FHGW-11083 |
    ${status}    ${feedback}    Run Keyword And Ignore Error    netact.Upload Configuration    dist_names=${dist_names}    parameters=${parameters}
    Run Keyword If    '${status}'=='PASS'    Log    CM Upload operation succesfully finished for ${dist_names}    console=True
    ...    ELSE    Run Keywords    Log    CM Upload operation failed for ${dist_names}    level=ERROR
    ...    AND    Fail    CM Upload operation failed for ${dist_names}
    Return From Keyword If    not ${check_feedback}
    ${feedback}    Replace String Using Regexp    ${feedback}    \\n\\t    ${EMPTY}
    ${feedback_list}    Split String    ${feedback}    \n
    Should Not Contain    ${feedback}     Content mismatch with metadata detected
    FOR    ${item}    IN     @{feedback_list}
    ${status}    Run Keyword And Return Status    Should Contain    ${item}    Feedback received:DN: ${dist_names}
    Run Keyword If    not ${status}    Remove Values From List    ${feedback_list}    ${item}
    END
    ${feedback}   Convert To String    ${feedback_list}
    Should Contain    ${feedback}    5G/LTE/SRAN upload finished
    Should Contain    ${feedback}    5G/LTE/SRAN HW upload finished
    Should Not Contain    ${feedback}    Error
    Should Not Contain    ${feedback}    Warning

NetAct Export Plan
    [Arguments]    ${local_dir}    ${file_name}    ${dist_names}    ${plan_name}    ${operation_type}=plan   ${ui_values}=None
    [Documentation]    Helper keyword used for export plan from NetAct to local_dir/file_name place
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...    | local_dir | Yes | Path to local directory where NetAct plan should be stored |
    ...    | file_name | Yes | File name for local stored plan |
    ...    | dist_names | Yes | MO distName |
    ...    | plan_name | Yes | Name of plan on NetAct |
    ...    | operation_type | No | Specifies the type of the export operation (plan/actual/reference/template/siteTemplate |
    ...    | ui_values | No | Specifies if the file should be exported with UI parameters' values. Default value is false. |
    ...
    ...   Example
    ...  | NetAct Export Plan | local_dir=${TEST_LOG_DIRECTORY} | file_name=actual_${export_timestamp}.xml
    ...  | dist_names=${distName} | plan_name=${plan_name} | operation_type=actual |
    ${status}=    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${local_dir}
    Run Keyword If    not ${status}    Create Directory    ${local_dir}
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${local_dir}    file_name=${file_name}
    ...    operation_type=${operation_type}    dist_names=${dist_names}    plan_name=${plan_name}    ui_values=${ui_values}
    ${status}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${local_dir}/${file_name}
    Run Keyword If    ${status}    Log    Plan ${plan_name} available at ${local_dir}/${file_name}    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} not available at ${local_dir}/${file_name}    level=ERROR
    ...    AND    Fail    Plan ${plan_name} not available at ${local_dir}/${file_name}

NetAct Import Plan
    [Arguments]    ${local_dir}    ${file_name}    ${plan_name}    ${ui_values}=false
    [Documentation]    Helper keyword used for Import plan to NetAct from local_dir/file_name place
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...    | local_dir | Yes | Path to local directory where NetAct plan should be stored |
    ...    | file_name | Yes | File name for local stored plan |
    ...    | plan_name | Yes | Name of plan on NetAct |
    ...
    ...   Example
    ...  | NetAct Import Plan | local_dir=${TEST_LOG_DIRECTORY} | file_name=${delta_plan_name_vDU}_${timestamp}.xml
    ...  | plan_name=${delta_plan_name_vDU}_${timestamp}
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${plan_name}    ${plan}
    OperatingSystem.File Should Exist    ${local_dir}/${file_name}
    ${status}=    Run Keyword And Return Status    netact.Import Configuration    local_dir=${local_dir}
    ...    file_name=${file_name}    plan_name=${plan_name}    ui_values=${ui_values}
    Run Keyword If    ${status}    Log    Plan ${plan_name} at ${local_dir}/${file_name} import success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} at ${local_dir}/${file_name} is fail.    level=ERROR
    ...    AND    Fail    Plan ${plan_name} at ${local_dir}/${file_name} is fail.

NetAct Provision Plan
    [Arguments]    ${plan_name}    ${dist_names}    ${backup_plan_name}    ${create_backup_plan}    ${provisioning_operation}
    [Documentation]    Helper keyword used for provision plan
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...    | plan_name | Yes | Plan Name |
    ...    | dist_names | Yes | MO distName |
    ...    | backup_plan_name | Yes | Backup plan name |
    ...    | create_backup_plan | Yes | Create backup plan; True or False |
    ...    | provisioning_operation| Yes | Specifies a provisioning operation (activate/preactivate) |
    ...
    ...   Example
    ...  | NetAct Provision Plan | plan_name=${delta_plan_name_vDU}_backup_${timestamp} | dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...  | backup_plan_name=None | create_backup_plan=False | provisioning_operation=activate
    ${status}=    Run Keyword And Return Status    netact.Provision Plan    plan_name=${plan_name}    dist_names=${dist_names}
    ...    backup_plan_name=${backup_plan_name}    create_backup_plan=${create_backup_plan}
    ...    provisioning_operation=${provisioning_operation}
    Run Keyword If    ${status}    Log    Provision plan ${plan_name} successfully done!    console=True
    ...    ELSE    Run Keywords    Log    Provision plan ${plan_name} failed!    level=ERROR
    ...    AND    Fail    netact.Provision Plan ${plan_name} failed!


NetAct Check Actual Configuration Parameters
    [Arguments]    ${ne}    ${dist_name}    ${ui_values}=false    &{parameter_dict}
    [Documentation]    Check Actual Configuration Parameters from netact
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...    | ne | Yes | Network Element |
    ...    | dist_names | Yes | MO distName |
    ...    | ui_values | No | UI Value |
    ...    | parameters_dict | Yes | dictionary of parameter info, like parameter name:parameter value |
    ...
    ...   Example
    ...  | NetAct Check Actual Configuration Parameters | ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...  | dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-1 | cellName=${cellName}
    ${status}=    Run Keyword And Return Status    Check Actual Configuration Parameters    ne=${ne}    dist_name=${dist_name}
    ...    ui_values=${ui_values}    &{parameter_dict}
    Run Keyword If    ${status}
    ...    Log    For ${dist_name}, parameters config has expected values in actual configuration!    console=True
    ...    ELSE    Run Keywords
    ...    Log    For ${dist_name}, parameters config has not expected values in actual configuration!    level=ERROR
    ...    AND    Fail    For ${dist_name}, parameters config has not expected values in actual configuration!


Check Actual Configuration Parameters
    [Arguments]    ${ne}    ${dist_name}    ${ui_values}=false    &{parameters_dict}
    [Documentation]    Check Actual Configuration Paramters
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...    | ne | Yes | Network Element |
    ...    | dist_name| distName of element |
    ...    | ui_values| default is false |
    ...    | parameters_dict| Parameters with expected values |
    ...
    ...   Example
    ...  | Check Actual Configuration Parameters | ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...  | dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-1 | cellName=${cellName}
    Log    Check Actual Configuration Parameters    console=True
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    netact.Export Configuration    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=check_netact_plan_${timestamp}.xml
    ...   operation_type=actual    dist_names=${ne}    ui_values=${ui_values}
    ${param_names}    Get Dictionary Keys    ${parameters_dict}
    ${param_values}    Get Dictionary Values    ${parameters_dict}
    ${param_count}    Get Length    ${param_names}
    ${scf_xml}=    L_XML.Parse Xml    ${TEST_LOG_DIRECTORY}/NetActLogs/check_netact_plan_${timestamp}.xml
    ${object}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${dist_name}"]
    ${obj_count}    Get Length    ${object}
    Should Be Equal As Integers    ${obj_count}    ${1}
    FOR    ${index}    IN RANGE    0    ${param_count}
        ${is_string}    Run Keyword And Return Status    Should Be String    ${param_values[${index}]}
        Run Keyword If    ${is_string}    AIC_NetAct.Compare String Value In XML    ${scf_xml}    ${ui_values}    ${dist_name}
        ...    ${param_names[${index}]}    ${param_values[${index}]}
        ...    ELSE    AIC_NetAct.Compare Unstring Value In XML    ${scf_xml}    ${ui_values}    ${dist_name}
        ...    ${param_names[${index}]}    ${param_values[${index}]}
    END

Compare String Value In XML
    [Arguments]     ${scf_xml}    ${ui_values}    ${dist_name}    ${param_name}    ${expected_value}
    [Documentation]    Compare String Value In XML
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | scf_xml | scf file |
    ...    | ui_values | yes is UI value, no is internal value |
    ...    | dist_name | dn of MO |
    ...    | param_name | parameter name |
    ...    | expected_value | expected parameter value |

    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | Compare String Value In XML |  scf_xml=scf_xml | ui_values=true | dist_name=FHGW-11085/MNL-1/PMMNL-1
    ...  | param_name=miCpuUsage | expected_value=0 |
    ${expected_value_formatted}    Run Keyword If    '${ui_values}'=='false'
    ...    Set Variable If      '${expected_value}'=='true'    1
    ...    '${expected_value}'=='false'    0
    ...    '${expected_value}'!='true'and '${expected_value}'!='false'    ${expected_value}
    ...    ELSE    Set Variable    ${expected_value}
    ${status}    ${value}    Run Keyword And Ignore Error    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="${dist_name}"]/p[@name="${param_name}"]
    ${actual_value}   Set Variable If   '${status}'=='PASS'    ${value}    ${EMPTY}
    Should Be Equal    ${actual_value}    ${expected_value_formatted}


Compare Unstring Value In XML
    [Arguments]     ${scf_xml}    ${ui_values}    ${dist_name}    ${param_name}    ${expected_value}
    [Documentation]    Compare Unstring Value In XML
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | scf_xml | scf file |
    ...    | ui_values | yes is UI value, no is internal value |
    ...    | dist_name | dn of MO |
    ...    | param_name | parameter name |
    ...    | expected_value | expected parameter value |

    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | Compare Unstring Value In XML |  scf_xml=scf_xml | ui_values=true | dist_name=FHGW-11085/MNL-1/PMMNL-1
    ...  | param_name=miCpuUsage | expected_value=0 |
    ## ${expected_value}=[LNCEL_FDD-actAutoPucchAlloc,LNCEL_FDD-mimoOlConfig,LNCEL_FDD-mimoOlConfig.mimoOlCqiThD]
    ## or ${exepcted_value}=["ulTransPrecodeOffSinrThresh":"20","ulTransPrecodeOnSinrThresh":"1.5",
    ## "ulTransPrecodePi2Bpsk":"true","ulTransPrePi2BpskPwrBoost":"false"]
    ${is_string}    Run Keyword If    len(${expected_value})>0
    ...    Run Keyword And Return Status    Should Be String    ${expected_value[0]}
    ...    ELSE    Set Variable    True
    ${actual_value}    Run Keyword If    ${is_string}
    ...    AIC_NetAct.Compare List Value In XML    ${scf_xml}    ${dist_name}    ${param_name}    ${expected_value}
    ...    ELSE    AIC_NetAct.Compare Structure Value In XML    ${scf_xml}    ${ui_values}    ${dist_name}
    ...    ${param_name}    ${expected_value}

Compare List Value In XML
    [Arguments]     ${scf_xml}    ${dist_name}    ${param_name}    ${expected_value}
    [Documentation]    Compare List Value In XML
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | scf_xml | scf file |
    ...    | dist_name | dn of MO |
    ...    | param_name | parameter name |
    ...    | expected_value | expected parameter value |

    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | Compare List Value In XML |  scf_xml=scf_xml | dist_name=FHGW-11085/MNL-1/PMMNL-1
    ...  | param_name=miCpuUsage | expected_value=0 |
    ${actual_value}    L_XML.Get Elements Texts    ${scf_xml}
    ...    .//managedObject[@distName="${dist_name}"]/list[@name="${param_name}"]/p
    ${actual_value}    Convert To List    ${actual_value}
    Lists Should Be Equal    ${actual_value}    ${expected_value}

Compare Structure Value In XML
    [Arguments]     ${scf_xml}    ${ui_values}    ${dist_name}    ${param_name}    ${expected_value}
    [Documentation]    Compare Structure Value In XM
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | scf_xml | scf file |
    ...    | ui_values | yes is UI value, no is internal value |
    ...    | dist_name | dn of MO |
    ...    | param_name | parameter name |
    ...    | expected_value | expected parameter value |

    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | Compare Structure Value In XML |  scf_xml=scf_xml | ui_values=true | dist_name=FHGW-11085/MNL-1/PMMNL-1
    ...  | param_name=miCpuUsage | expected_value=0 |
    ${element_dic}    Create Dictionary
    ${actual_items}    L_XML.Get Child Elements    ${scf_xml}
    ...    .//managedObject[@distName="${dist_name}"]/list[@name="${param_name}"]/item
    FOR    ${item}    IN    @{actual_items}
        ${p_name}    L_XML.Get Element Attribute    ${item}    name
        ${p_value}    L_XML.Get Element Text    ${item}
        Set To Dictionary    ${element_dic}    ${p_name}    ${p_value}
    END
    ${actual_value}    Create List    ${element_dic}
    ${actual_value}    Convert To List    ${actual_value}
    ${expected_value_formatted}    Create List
    FOR    ${item}    IN    @{expected_value}
    ${expected_item_formatted}    Run Keyword If    '${ui_values}'=='false'
    ...   AIC_NetAct.Convert Boolean Value From UI_Value To Internal_Value For Structure    ${item}
    ...    ELSE    Set Variable     ${item}
    Append To List    ${expected_value_formatted}    ${expected_item_formatted}
    END
    Lists Should Be Equal    ${actual_value}    ${expected_value_formatted}

Convert Boolean Value From UI_Value To Internal_Value For Structure
    [Arguments]    ${structure_values}
    [Documentation]    Convert Boolean Value From UI_Value To Internal_Value For Structure
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | structure_values | the formateed structure format values |
    ...    | Return Value | Description |
    ...    | structure_values| structure values |
    ...
    ...   Example
    ...  | Convert Boolean Value From UI_Value To Internal_Value For Structure |
    ${keys}     Get Dictionary Keys    ${structure_values}
    FOR    ${key}    IN    @{keys}
         ${value}    Get From Dictionary    ${structure_values}    ${key}
         ${convert_value}    Set Variable If
         ...    '${value}'=='true'    1
         ...    '${value}'=='false'    0
         ...    '${value}'!='true' and '${value}'!='false'    ${value}
         Set To Dictionary    ${structure_values}    ${key}    ${convert_value}
    END
    [Return]    ${structure_values}

NetAct Create And Edit Plan
    [Arguments]    ${BTS_scf_initial}    ${name}    ${description}    ${mo_id}    ${scf_distName}    &{parameters_dict}
    [Documentation]    Helper keyword used for create new plan and parameter edit
    ...
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | name | Yes | Plan Name |
    ...    | description | Yes | Plan description |
    ...    | mo_id | Yes | MO distName |
    ...    | scf_distName | Yes | SCF distName of MO for given parameter |
    ...    | parameters_dict | Yes | parameters_dict (dictionary format - key:value) |
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}=    NetAct Create Plan    ${name}    ${description}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${scf_distName}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${mo_id}    &{parameters_dict}
    [Return]    ${plan}

NetAct Create Plan
    [Arguments]    ${name}    ${description}
    [Documentation]    Helper keyword used for create new plan
    ...
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | name | Yes | Plan Name |
    ...    | description | Yes | Plan description |
    ${plan}=    netact.Create Plan Configuration    ${name}    ${description}
    ${status}=    Run Keyword And Return Status    netact.Get Plan Configuration    ${name}
    Run Keyword If    ${status}    Log    Plan successfully created: ${plan}    console=True
    ...    ELSE    Run Keywords    Log    Plan creation failed!    level=ERROR
    ...    AND    Fail    Plan creation failed!
    [Return]    ${plan}

NetAct Create Managed Object
    [Arguments]    ${plan}    ${meta_class}    ${meta_version}    ${mo_id}    ${operation}=UPDATE    &{parameters_dict}
    [Documentation]    Helper keyword used for create MO in existing plan
    ...
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | plan | Yes | Plan obj |
    ...    | meta_class | Yes | Meta class of mo |
    ...    | meta_version | Yes | nidd version of mo  |
    ...    | mo_id | Yes | MO distName |
    ...    | parameters_dict | Yes |  parameters_dict (dictionary format - key:value)  |
    ${managed_object}=    netact.Create Managed Object    plan=${plan}    meta_class=${meta_class}
    ...    meta_version=${meta_version}    mo_id=${mo_id}    operation=${operation}   &{parameters_dict}
    ${status}=    Run Keyword And Return Status    netact.Get Managed Object    configuration=${plan}    mo_id=${mo_id}
    Run Keyword If    ${status}    Run Keywords    Log    MO successfully created: ${managed_object}    console=True
    ...    AND    Log    Parameters were set with plan ${plan}    console=True
    ...    ELSE    Run Keywords    Log    MO creation failed!    level=ERROR
    ...    AND    Fail    MO creation failed!


Check If Netact Plan Is Deleted
    [Arguments]    ${plan_name}
    [Documentation]    Helper keyword for checking if netact plan is deleted.
    ...    If needed perform delete plan.
    ...
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | plan_name | Yes | Plan Name |
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    netact.Delete Plan    ${plan_name}

NetAct Delete Plan
    [Arguments]    ${name}    ${plan}
    netact.Delete Plan    ${name}
    ${status}=    Run Keyword And Return Status    netact.Get Plan Configuration    ${name}
    Run Keyword If    ${status}    Run Keywords    Log    Plan deletion failed!    level=ERROR
    ...    AND    Fail    Plan deletion failed!
    ...    ELSE    Log    Plan successfully deleted: ${plan}    console=True

Download vRAN SW Build
    [Arguments]    ${build_folder_name}    ${build_name}    ${target_path}    ${release_name}=vDUCNF00    ${clean_folder}=${True}
    [Documentation]    Helper keyword for downloading vRAN sw builds, such as vDU sw build and pvs plugin.
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | build_folder_name | Yes | e.g. vDUCNF00_0.300.11240|
    ...    | build_name | Yes | e.g. vDUCNF00_0.300.11240.zip;vDUCNF00_0.300.11240_pdl_validation_service_plugin.zip|
    ...    | target_path | Yes | the path you want to save in local vm |
    ...    | release_name | Yes | default is: vDUCNF00 |
    ${download_command}    Set Variable    wget    #sudo wget --progress=dot:giga -T 600 -t 2
    ${download_source_path}    Set Variable
    ...    https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/${release_name}
    ${remove_files_cmd}    Set Variable    sudo rm -rf ${target_path}/*
    Run Keyword If    ${clean_folder}    Run    ${remove_files_cmd}
    Log To Console    \nStart Download SW:${build_name}...........
    Wait Until Keyword Succeeds    10 minutes    5s
    ...    Run    ${download_command} ${download_source_path}/${build_folder_name}/${build_name}.zip -O ${target_path}/${build_name}.zip
    Log To Console    \nComplete Download SW:${build_name}...........

Import vRAN SW Build To NetAct
    [Arguments]    ${build_name}    ${source_path}   ${netact_swm_path}=/d/oss/global/swmanager/swm_temp
    [Documentation]    Helper keyword for importing vRAN sw builds to NetAct, such as vDU sw build and pvs plugin.
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | build_name | Yes | e.g. vDUCNF00_0.300.11240.zip;vDUCNF00_0.300.11240_pdl_validation_service_plugin.zip|
    ...    | source_path | Yes | the pkg saved in local vm path |
    ...    | netact_swm_path | Yes | pkg path in NetAct:/d/oss/global/swmanager/swm_temp|
    ${netactcon}    tafssh.Connect To    ${NETACT['was_host']}    root    arthur
    #Log To Console    \nStart Copy SW to NetAct...........
    #${cmdstr}    Set Variable    sudo sshpass -p arthur scp ${source_path}/${build_name}.zip root@10.41.146.134:${netact_swm_path}
    #${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmdstr}
    #Log To Console    \nFinish Copy SW to NetAct...........
    Log To Console    \nStart Copy SW to NetAct...........
    tafssh.Upload File    ${source_path}/${build_name}.zip    ${netact_swm_path}/${build_name}.zip
    Log To Console    \nFinish Copy SW to NetAct...........
    tafssh.Send Command     chmod 777 ${netact_swm_path}/${build_name}.zip
    tafssh.Disconnect    ${netactcon}
    Log To Console    \nStart Import SW:${build_name}...........
    netact.Import Build   ${netact_swm_path}/${build_name}.zip    clean_temp_storage=True
    Log To Console    \nComplete Import SW:${build_name}...........

NetAct Modify Mutiple Parameters
    [Arguments]    ${scf_initial}    ${plan_name}    ${description}=None    &{parameters_dict}
    [Documentation]    Helper keyword used for modify mutiple parameters(support mutiple MO) for one NE(vCU,vDU) on NetAct
    ...
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | scf_initial | Yes | NE scf file |
    ...    | plan_name | Yes | Plan Name |
    ...    | description | Yes | Plan description |
    ...    | parameters_dict | Yes | Format:{scf_DN1:{parameter1:value1,parameter2:value2},scf_DN2:{parameter3:value3} |
    ...    | e.g.&{parameters_dict}={MRBTS-11084:{btsName:5gvDU-11084-test},
    ...    | MRBTS-11084/NRBTS-11084/NRCELL-1:{actCDrx:true,actCsiMeasEthFlowControl:1}} |
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${plan_name}    ${plan}
    ${plan}=    NetAct Create Plan    ${plan_name}    ${description}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${scf_initial}
    ${scf_distNames}    Get Dictionary Keys    ${parameters_dict}
    ${MRBTS_id}    Fetch From Left    ${scf_distNames[0]}    /
    FOR    ${scf_DN}    IN    @{scf_distNames}
    ${params_dic}    Set Variable    ${parameters_dict["${scf_DN}"]}
    ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${scf_DN}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/${scf_DN}    &{params_dic}
    END
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${plan_name}.xml    dist_names=PLMN-PLMN/${MRBTS_id}
    ...    plan_name=${plan_name}    operation_type=plan
    NetAct Provision Plan    plan_name=${plan_name}    dist_names=PLMN-PLMN/${MRBTS_id}
    ...    backup_plan_name=${plan_name}_backup    create_backup_plan=True    provisioning_operation=activate

Integrate Cloud
    [Arguments]    ${cloud_id}    ${input_file}
    ...            ${alias}=None    ${file_format}=JSON    ${overwrite}=${False}
    [Documentation]    import kube config and integrate cloud
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | cloud_id | Yes | Instance identifier of CLOUD object for vDU/vCU |
    ...    | input_file | Yes | path to input kube config file |
    ...    | alias | No | NetAct instance name |
    ...    | file_format | No | Indicates the ``JSON`` or ``RAML2`` (RAML2.1) file format |
    ...    | overwrite | No | indicates if the operation overwrites the previous contents |
    ...   Example
    ...  | Integrate Cloud |  |
    ${output}=    Import SSD    ${input_file}    file_format=${file_format}    overwrite=${overwrite}
    ${Operation_output}=    netact.Integrate Cloud    ${cloud_id}    alias=${alias}
    [Return]    ${Operation_output}

Deintegrate Cloud
    [Arguments]    ${cloud_id}    ${root_id}=PLMN    ${force_deintegrate}=${False}    ${delete_related_cnfs}=${True}
    ...            ${ignore_errors}=${False}    ${timeout}=7200    ${alias}=None
    [Documentation]     This workflow operation deintegrates a single cloud object based on
    ...    the given Cloud ID for Nokia 5G Cloud RAN Cloud-Native Network Functions (CNFs). CLOUD and K8SAPI objects
    ...    with the Kubernetes configuration property are deleted from the NetAct System Data Access (NASDA) database
    ...    under the PLMN-PLMN root object. Kubernetes configuration (kubeconfig) content is deleted from
    ...    the Security Sensitive Data (SSD). If Force deintegrate is used, then CLOUD object is deleted
    ...    even if it is connected to any CNFs. If Delete related CNF objects is used, also CNFs connected to the
    ...    CLOUD object are deleted from the actual configuration.
    ...
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | plan_name | Yes | CNF RAML Plan name |
    ...   Example
    ...  | Deintegrate Cloud |  |
    ${Operation_output}=    netact.deintegrate cloud    ${cloud_id}    root_id=${root_id}   force_deintegrate=${force_deintegrate}
    ...    delete_related_cnfs=${delete_related_cnfs}    ignore_errors=${ignore_errors}
    ...    timeout=${timeout}    alias=${alias}
    [Return]    ${Operation_output}

Import SSD
    [Arguments]    ${input_file}    ${file_format}=JSON    ${overwrite}=${False}
    [Documentation]    Import SSD detail into NetAct by reading the data from a RAML2.1 or a JSON file
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | input_file | Yes | path to input data file |
    ...    | file_format | No | Indicates the ``JSON`` or ``RAML2`` (RAML2.1) file format |
    ...    | overwrite | No | indicates if the operation overwrites the previous contents, defaults to ``False`` |
    ...   Example
    ...  | Import SSD |  ${input_file} |
    ${output}=    netact.Import SSD    ${input_file}    file_format=${file_format}    overwrite=${overwrite}
    [Return]    ${output}

NetAct Create Cnf Upgrade Plan
    [Arguments]   ${plan_name}    ${dist_names}    ${cnf_sw_id}    ${verbose}=${True}
    ...           ${ignore_errors}=${False}    ${timeout}=${7200}    ${alias}=${None}
    [Documentation]    this kw is to Create Cnf Upgrade Plan
    ...    Author: Xiang Liang
    ...    Contact: Liang.xiang@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | ${plan_name}    | yes | nemed from create cnf upgrade plan |
    ...    | ${dist_names}   | yes | dist names of target ugprade CNF |
    ...    | ${cnf_sw_id}    | yes | sw build id of target upgrade CNF
    ...    | ${verbose}      | no  | If ``True``, returns more detailed output from executed operation |
    ...    | ${ignore_errors}| no  | If ``True``, shows warnings instead of raising errors when operation fails |
    ...    | ${timeout}      | no  | Timeout for executing operation |
    ...    | ${alias}        | no  | Netact instance name. Default value is ``default`` |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Create Cnf Upgrade Plan | 37015_CU_UPG_LIANG_TEST | PLMN-PLMN/CNF-37015 | vDUCNF23R3_19.300.291 |
    ...
    ${output}=    netact.create_cnf_upgrade_plan    plan_name=${plan_name}    dist_names=${dist_names}    cnf_sw_id=${cnf_sw_id}
    ...                        verbose=${verbose}    ignore_errors=${ignore_errors}
    ...                        timeout=${timeout}    alias=${alias}
    ${output}    Replace String Using Regexp    ${output}    \\n\\t    ${EMPTY}
    Should Contain    ${output}     CNF Create Upgrade Plan successful
    Should Contain    ${output}     CNF Create Upgrade Plan finished
    log to console    **** NetAct Create Cnf Upgrade Plan Successfull ****

NetAct Upgrade Cnf
    [Arguments]   ${plan_name}    ${helm_test}=${True}    ${rollback_plan_name}=${None}    ${ignore_errors}=${False}
    ...           ${timeout}=${7200}    ${alias}=${None}    ${verbose}=${True}   ${distribution}=${False}
    [Documentation]    this kw is to do Cnf Upgrade
    ...    Author: Xiang Liang
    ...    Contact: Liang.xiang@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | ${plan_name}    | yes | named from create cnf upgrade plan |
    ...    | ${helm_test}    | no | Specifies if run helm chart test |
    ...    | ${rollback_plan_name} | no | Name of rollback plan to generate and pass to sub-operation |
    ...    | ${ignore_errors}  | no | If ``True``, shows warnings instead of raising errors when operation fails |
    ...    | ${timeout} | no  | Timeout for executing operation |
    ...    | ${alias}   | no  | Netact instance name. Default value is ``default`` |
    ...    | ${verbose} | If ``True``, returns more detailed output from executed operation. |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | NetAct Upgrade Cnf | 37015_CU_UPG_LIANG_TEST |
    ...
    ${output}=    netact.upgrade_cnf    plan_name=${plan_name}    helm_test=${helm_test}    rollback_plan_name=${rollback_plan_name}
    ...            ignore_errors=${ignore_errors}    timeout=${timeout}    alias=${alias}    verbose=${verbose}
    ...            distribution=${distribution}
    ${output}    Replace String Using Regexp    ${output}    \\n\\t    ${EMPTY}
    Should Contain    ${output}    Install main chart success
    Should Contain    ${output}    CNF Create Rollback Plan successful
    Should Contain    ${output}    Validate chart success
    Should Contain    ${output}    CNF Upgrade successful
    log to console    **** NetAct Upgrade CNF Successfull ****

NecAct Cnf Rollback
    [Arguments]    ${plan_name}    ${dist_names}    ${helm_test}=True    ${verbose}=True    ${ignore_errors}=False
    ...            ${timeout}=7200    ${alias}=None
    [Documentation]    This Keyword to rollback cnf by NetACT.
    ...    Author: Jin Shunxin
    ...    Contact: shunxin.jin@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | ${plan_name}    | yes | plan name raised by cnf upgrade plan |
    ...    | ${helm_test}    | no | Specifies if run helm chart test |
    ...    | ${ignore_errors}  | no | If ``True``, shows warnings instead of raising errors when operation fails |
    ...    | ${timeout} | no  | Timeout for executing operation |
    ...    | ${alias}   | no  | Netact instance name. Default value is ``default`` |
    ...    | ${verbose} | If ``True``, returns more detailed output from executed operation. |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | NetAct Cnf Rollback | rollback plan name |
    ...
    ${output}=     netact.rollback_cnf    plan_name=${plan_name}    dist_names=${dist_names}    helm_test=${helm_test}
    ...    verbose=${verbose}    ignore_errors=${ignore_errors}    timeout=${timeout}    alias=${alias}
    ${output}    Replace String Using Regexp    ${output}    \\n\\t    ${EMPTY}
    Should Contain    ${output}    CNF Rollback started
    Should Contain    ${output}    CNF Rollback finished
    Should Contain    ${output}    CNF Rollback Instance started
    Should Contain    ${output}    CNF Rollback Instance finished
    Should Contain    ${output}    Helm release test success

NetAct Upload Alarms
    [Arguments]   ${dist_name}    ${alias}=${None}
    [Documentation]    this kw is to Upload Alarms to netact
    ...    Author: Xiang Liang
    ...    Contact: Liang.xiang@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | ${dist_name}   | yes | dist names of CNF |
    ...    | ${alias}        | no  | Netact instance name. Default value is ``default`` |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | NetAct Upload Alarms | PLMN-PLMN/MRBTS-37015 |
    ...
    ${output}=    netact.upload_alarms    dist_name=${dist_name}   alias=${alias}
    Should Contain    ${output}    Alarm Upload: SUCCESS

NetAct Get Alarms
    [Arguments]   ${dist_name}    ${alias}=${None}
    [Documentation]    this kw is to get all active alarms.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | ${dist_name}   | yes | dist names of CNF |
    ...    | ${alias}        | no  | Netact instance name. Default value is ``default`` |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | NetAct Get Alarms | PLMN-PLMN/MRBTS-37015 |
    ...
    ${alarms}=    netact.get_alarms    dist_name=${dist_name}   alias=${alias}
    [Return]    ${alarms}

NetAct Acknowledge Alarms
    [Arguments]   ${alarm_ids}    ${ignore_failure}=${False}    ${alias}=${None}
    [Documentation]    this kw is to acknowledge alarms.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | ${alarm_ids}   | yes | Alarm id(s) to be acknowledged. Please note that it is 'Consecutive Number'
    ...      in NetAct FM. It could be got from the kw NetAct Get Alarms. |
    ...    | ${ignore_failure}   | no | If True, returns the alarm id(s) for which the acknowledge operation failed.
    ...      Otherwise raises ``OperationFailed` exception. |
    ...    | ${alias}       | no  | NetAct instance name. Default value is ``default`` |
    ...    | Return Value | Description |
    ...    | ${acknowledge_failed_alarms} | Alarm id(s) for which the acknowledge operation failed |
    ...
    ...    Example
    ...    | NetAct acknowledge Alarms |  |
    ...
    ${acknowledge_failed_alarms}=    netact.Acknowledge Alarms    ${alarm_ids}
    ...    ignore_failure=${ignore_failure}    alias=${alias}
    [Return]    ${acknowledge_failed_alarms}

Encode Yaml File With Base64
    [Arguments]    ${input_file}
    [Documentation]    Encode a yaml file to string data. It can be used to encode aic vDU/vCU yaml files.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | input_file | Yes | path to input data file |
    ...   Example
    ...  | Encode Yaml File With Base64 | ${input_file} |
    ${encoded_string}=    OperatingSystem.Run    command=base64 -w 0 ${input_file}
    [Return]    ${encoded_string}

Prepare Yaml File
    [Arguments]    ${swversion}    ${clusteryaml}    ${prerequisiteyaml}    ${mainyaml}    ${conversion_toolpath}=/home/ute/Downloads
    [Documentation]    Helper keyword for download conversion tool, and conversion old version yaml file to current version yaml file
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | swversion | Yes | product package version, vcu/vdu version |
    ...    | clusteryaml | Yes | input old version clusteryaml file  |
    ...    | prerequisiteyaml | Yes | input old version prerequisiteyaml file |
    ...    | mainyaml | Yes | input old version mainyaml file |
    ...    | conversion_toolpath | No | conversion tool store path |
    ...
    ...   Example
    ...  | new_clusteryaml | new_prerequisiteyaml | new_mainyaml | Prepare Yaml File | swversion=vCUCNF00_0.250.13852
    ...  | clusteryaml=/home/ute/Downloads/chart/aic-vcu-cluster-preparation/values-override.yaml
    ...  | prerequisiteyaml=/home/ute/Downloads/chart/aic-vcu-prerequisite/values-override.yaml
    ...  | mainyaml=/home/ute/Downloads/chart/aic-vcu-cnf/values-override.yaml |
    ${product_name}    Get Substring    ${swversion}    0    3
    ${product_name}    Convert To Lowercase    ${product_name}
    ${tool_path}    na.get_conversion_tool    ${swversion}    ${conversion_toolpath}
    ${new_clusteryaml}    na.conversion_yaml_file    ${tool_path}    ${clusteryaml}    clust    ${product_name}
    ${new_prerequisiteyaml}    na.conversion_yaml_file    ${tool_path}    ${prerequisiteyaml}    prerequisite    ${product_name}
    ${new_mainyaml}    na.conversion_yaml_file    ${tool_path}    ${mainyaml}    " "    ${product_name}
    [Teardown]    delete_conversion_tool    ${tool_path}
    [Return]    ${new_clusteryaml}    ${new_prerequisiteyaml}    ${new_mainyaml}

Undeploy Aic from Netact by plan
    [Arguments]  ${plan_name}  ${distnames}=None  ${deintegrate_mrbts}=no  ${delete_k8s_objects}=secrets
    ...  ${ignore_errors}=False  ${timeout}=7200  ${alias}=None  ${verbose}=False
    [Documentation]  keyword for undeploying aic from Netact by plan
    ...
    ...  *AUTHOR* amaand.li@nokia-sbell.com
    ...
    ...    |Input Parameters| Man. | Description|
    ...    | plan_name | Yes | Specifies a name of plan.  |
    ...    | dist_names | No  | Specifies the scope of the operation. |
    ...    | deintegrate_mrbts  | No  | Specifies if related MRBTS should be deintegrated.|
    ...    | delete_k8s_objects | No | Specify K8S type should be deleted. Possible values: none, secrets or namespace |
    ...    | ignore_errors    | No |  If True, shows warnings instead of raising errors when operation fails. |
    ...    | timeout(int)    | No |  Timeout for executing operation. |
    ...    | verbose (bool)    | No | If True, returns more detailed output from executed operation.|
    ...    *RETURN VALUE*
    ...   undeploy result from netact, True or False
    ...   Example
    ...  | Undeploy from Netact by plan | ${PnPPlanfile} |
    ${result}=  Run keyword and return status
    ...  netact.terminate_cnf  plan_name=${plan_name}  dist_names=${distnames}
                          ...  deintegrate_mrbts=${deintegrate_mrbts}  delete_k8s_objects=${delete_k8s_objects}
                          ...  ignore_errors=${ignore_errors}  timeout=${timeout}  alias=${alias}  verbose=${verbose}
    Log to console  ${result}
    Should Be True   ${result}
    [Return]  ${result}

Deploy Pnp Configuration Plan from Netact
    [Arguments]    ${PnPPlanfile}  ${aic_id}  ${was_host}  ${netact_user}  ${netact_password}
    [Documentation]  This keyword is used to deploy pnp plan from Netact, equals manual operation by workflowengine.
    ...  *AUTHOR* amaand.li@nokia-sbell.com
    ...
    ...    |Input Parameters| Man. | Description|
    ...    | aic_id | Yes | the id of vcu/vdu  |
    ...    | PnPPlanfile   | Yes  | PNP plan file for netact deploy, full path in local vm. eg:/home/ute/xxx.xml |
    ...    | was_host | Yes | ip of netact  |
    ...    | netact_user   | Yes  | user name of netact |
    ...    | netact_password | Yes | password of netact  |
    ...    *RETURN VALUE*
    ...   deploy pnp plan result from netact, True or False
    ...   Example
    ...  | Deploy pnp plan from Netact | ${PnPPlanfile} | Vdu-XX | 10.82.47.15 | omc | Medsql!_1893 |
    Log to console    start Deploy pnp plan from Netact
    Set Test Variable    ${myPlanName}    planfilefor${aic_id}
    Run Keyword And Ignore Error    NetAct Delete Plan    ${myPlanName}    ${myPlanName}

    Sftp Upload    ${was_host}    ${netact_user}    ${netact_password}
    ...    ${PnPPlanfile}
    ...    /var/opt/oss/global/racops/import/tempPnPFileName.xml
    ...    Netact

    ${deploy_pnp_log}=  netact.prepare_unified_pnp_coam_site
                                ...  plan_name=${myPlanName}
                                ...  input_file=/d/oss/global/var/racops/import/tempPnPFileName.xml
                                ...  ui_values=True
                                ...  maintenance_region_dn=MRC-${aic_id}/MR-${aic_id}

    Log to console    ${deploy_pnp_log}
    ${deploy_pnp_result}  Should contain  ${deploy_pnp_log}  Status received: Finished

    [Return]  ${deploy_pnp_result}

Sftp Upload
    [Arguments]   ${hostname}  ${user}  ${password}  ${source_filepath}  ${desnation_filepath}  ${alias}=default
    [Documentation]  This keyword is used to upload local file to remote server
        ...
    ...  *AUTHOR* amaand.li@nokia-sbell.com
    ...
    ...    |Input Parameters| Man. | Description|
    ...    | hostname | Yes | the ip of destination server  |
    ...    | user   | Yes  | the username of destination server  |
    ...    | password | Yes | the password of destination server  |
    ...    | source_filepath   | Yes  | local file path |
    ...    | desnation_filepath | Yes | remote destination paht  |
    ...    | alias   | No  | default alias is used:"default" |
    ...   Example
    ...  | Sftp Upload | /etc/hosts | /home/TheUser/hosts_from_remote|
    tafssh.Connect To    ${hostname}    ${user}    ${password}   alias=${alias}
    tafssh.Upload File    ${source_filepath}  ${desnation_filepath}   connection=${alias}
    tafssh.Disconnect    connection=${alias}

Create Aic Pnp Configuration Plan With Scf From Netact
    [Documentation]
    ...    KW used to create pnp configuration plan and save it in ${TEST_LOG_DIRECTORY}${/}pnp_configuration_plan.xml.
    ...    It returns Pnp Configuration Plan full path.
    ...    Author: Amaand li
    ...    Contact: amaand.li@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | plan_sw_version  | Yes | version of VCU/VDU planned to install by pnp auto configuration.  |
    ...    | aic_id  | Yes | Id of VCU/VDU      |
    ...    | netact_cm_export_filename  | Yes | aic scf exported from netact, need full path like /home/ute/xx.xml.  |
    ...    | aic_namespace | Yes  | Tenants under CU/DU |
    ...    | secrets | Yes  | secrets info from netact |
    ...    | cluster_chart | Yes  | cluster sw version |
    ...    | prerequisite_chart | Yes | prerequisite  sw version |
    ...    | main_chart | Yes  | main sw version |
    ...    | cnfsw_id | Yes  |  sw version of cnf |
    ...    | cluster_base64  | Yes | value of  cluster chart,  long string |
    ...    | prerequisite_base64 | Yes | value of prerequisite chart, long string |
    ...    | main_base64 | Yes | value of main chart, long string |

    [Arguments]  ${plan_sw_version}
            ...  ${netact_cm_export_filename}
            ...  ${aic_id}=10763
            ...  ${cnfsw_id}=vCUCNF23R3_19.250.30
            ...  ${aic_namespace}=cran1
            ...  ${secrets}=11251vdu-hangzhou
            ...  ${cluster_chart}=aic-vdu-cluster-preparation-17.403.0.tgz
            ...  ${prerequisite_chart}=aic-vdu-prerequisite-19.575.2.tgz
            ...  ${main_chart}=aic-vdu-19.300.48.tgz
            ...  ${cluster_base64}=123
            ...  ${prerequisite_base64}=123
            ...  ${main_base64}=123
    Log To Console  Start to Create Pnp Configuration Plan With Scf From Netact.
    ${release}  Get Aic Release  ${plan_sw_version}  CNF
    ${cnf_mo}   Generate Cnf Mo   aic_id=${aic_id}  cnfSwId=${cnfsw_id}
                             ...  aic_namespace=${aic_namespace}  secrets=${secrets}  cluster_chart=${cluster_chart}
                             ...  prerequisite_chart=${prerequisite_chart}
                             ...  main_chart=${main_chart}  cluster_base64=${cluster_base64}
                             ...  prerequisite_base64=${prerequisite_base64}  main_base64=${main_base64}

    ${xml}    OperatingSystem.Get File    ${netact_cm_export_filename}
    Add Xml Element  ${xml}  ${TEST_LOG_DIRECTORY}${/}temp1.xml
    ...  <p name="AutoConnSiteID">MRBTS-${aic_id}</p>|//*[@class='MRBTS']
    Remove Xml Element  ${TEST_LOG_DIRECTORY}${/}temp1.xml  ${TEST_LOG_DIRECTORY}${/}temp2.xml
    ...  //*[@name='restoreConfigurationFrom']
    Remove Xml Element  ${TEST_LOG_DIRECTORY}${/}temp2.xml  ${TEST_LOG_DIRECTORY}${/}temp3.xml
    ...  //*[@name='autoConfPlanName']

    ${xml1}  OperatingSystem.Get File  ${TEST_LOG_DIRECTORY}${/}temp3.xml
    ${xml2}  Replace String Using Regexp   ${xml1}    BTS-${${vdu_id}}    BTS-${aic_id}
    ${xml3}  Replace String Using Regexp  ${xml2}    id="[0-9]*"    operation="create"

    ${paras_list}  Create list  ipVersion=IPv4  plannedSWReleaseVersion=${plan_sw_version}
    ...  securityMode=TLS  systemReleaseVersion=${release}
    ${file_integ}  set variable  ${TEST_LOG_DIRECTORY}/tmp_integ.xml
    Add Mo To Delta File  file=${file_integ}  distname=PLMN-PLMN/MRBTS-${aic_id}/INTEGRATE-1  operation=create
    ...   paralist=${paras_list}

    ${xml}  XML.Parse XML  ${file_integ}
    ${inte_mo}  Element To String  ${xml}  .
    Add Xml Element    ${xml3}    ${TEST_LOG_DIRECTORY}${/}temp3.xml
    ...  ${inte_mo}|//*[@distName='PLMN-PLMN/MRBTS-${aic_id}']/..
    Add xml Element   ${TEST_LOG_DIRECTORY}${/}temp3.xml
    ...  ${TEST_LOG_DIRECTORY}${/}pnp_configuration_plan.xml
    ...  ${cnf_mo}|//*[@distName='PLMN-PLMN/MRBTS-${aic_id}']/..

    log   ${TEST_LOG_DIRECTORY}${/}pnp_configuration_plan.xml
    [Return]  ${TEST_LOG_DIRECTORY}${/}pnp_configuration_plan.xml

Generate Cnf Mo
    [Documentation]
    ...    KW used to generate cnf manageobject and save it in '${TEST_LOG_DIRECTORY}/tmp_cnf.xml'
    ...    It returns string of generated object finnaly.
    ...    Author: Amaand li
    ...    Contact: amaand.li@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | aic_id | Yes  |  Id of VCU or VDU |
    ...    | aic_namespace | Yes  | Tenants under CU/DU |
    ...    | secrets | Yes  | secrets info from netact  |
    ...    | cluster_chart | Yes  | cluster sw version |
    ...    | prerequisite_chart | Yes | prerequisite  sw version |
    ...    | main_chart | Yes  | main sw version |
    ...    | cnfsw_id | Yes  |  sw version of cnf |
    ...    | cluster_base64  | Yes | value of  cluster chart,  long string |
    ...    | prerequisite_base64 | Yes | value of prerequisite chart, long string |
    ...    | main_base64 | Yes | value of main chart, long string |
    ...  .. code-block:: robotframework
    [Arguments]
            ...  ${aic_id}
            ...  ${cnfSwId}=vDUCNF23R3_19.300.48
            ...  ${aic_namespace}=cran1
            ...  ${secrets}=11251vdu-hangzhou
            ...  ${cluster_chart}=aic-vdu-cluster-preparation-17.403.0.tgz
            ...  ${prerequisite_chart}=aic-vdu-prerequisite-19.575.2.tgz
            ...  ${main_chart}=aic-vdu-19.300.48.tgz
            ...  ${cnfsw_id}=vCUCNF23R3_19.250.301
            ...  ${cluster_base64}=123
            ...  ${prerequisite_base64}=123
            ...  ${main_base64}=123
    set test variable  ${file}  ${TEST_LOG_DIRECTORY}/tmp_cnf.xml
    set test variable  ${cl}  com.nokia.cnf.lcm:CNF
    set test variable  ${dn}  PLMN-PLMN/CNF-${aic_id}
    Create File   ${file}
    Append To File    ${file}
    ...  <managedObject class=\"${cl}\" version=\"CNF1.0\" distName=\"${dn}\" id=\"${aic_id}\" operation=\"create\">\r\n
    Append To File  ${file}  \ \ \ \ \ <defaults name="System"/>\r\n
    ${paras1}  set variable  cloudId=PLMN-PLMN/CLOUD-${aic_id}
    ${paras2}  set variable    cnfSwId=${cnfSwId}
    ${paras3}  set variable    name=MRBTS-${aic_id}
    ${paras4}  set variable    aic_namespace=${aic_namespace}
    ${paras5}  set variable    neRelId=$PLMN-PLMN/MRBTS-${aic_id}
    ${paras_list1}  Create list  containerRegistries
    ...  none=image-registry.openshift-image-registry.svc:5000/${aic_namespace}
    ${paras_list2}  Create list  secrets  none=${secrets}

    ${item_list}  Create list  deploymentProfile
    ${item0}   Create list  chart=${cluster_chart}  order=0
                                 ...  releaseName=aic-vdu-cluster-preparation  values=${cluster_base64}
    Append to list  ${item_list}  ${item0}
    ${item1}   Create list  chart=${prerequisite_chart}  order=1
                                 ...  releaseName=aic-vdu-prerequisite  values=${prerequisite_base64}
    Append to list  ${item_list}  ${item1}
    ${item2}   Create list  chart=${main_chart}  order=2
                                 ...  releaseName=aic-vdu  values=${main_base64}
    Append to list  ${item_list}  ${item2}
    ${item_all}  Create list  ${paras1}  ${paras2}  ${paras_list1}  ${item_list}
                     ...  ${paras3}  ${paras4}  ${paras5}  ${paras_list2}

    FOR  ${item}  IN  @{item_all}
    Log  ${item}
    ${isList}  Is List   ${item}
    Run Keyword If    ${islist}    Add List To Mo    ${file}    ${item}
    Run Keyword If    not ${islist}    Add Para To Mo    ${file}    ${item}
    END
    Append To File    ${file}    </managedObject>\r\n
    ${xml}  XML.Parse XML  ${file}
    ${mo_content}  XML.Element To String  ${xml}  .
    [Return]  ${mo_content}

Add List To Mo
    [Documentation]
    ...    KW used to add element of list into manange object.
    ...    Author: Amaand li
    ...    Contact: amaand.li@nokia-sbell.com
    [Arguments]    ${file}    ${para_list}
    Append To File    ${file}    \ \ \ \<list name=\"${para_list[0]}\">\r\n
    ${leng}  evaluate  len(${para_list})
    Run keyword if  ${leng}>1  Remove From List    ${para_list}    0
    Log List    ${para_list}
    ${isItem}  Is Item  ${para_list}
    Run keyword if  ${isItem}   pack item to list  ${file}  ${para_list}
    Run Keyword If   not ${isItem}  Add Para To Mo  ${file}  ${para_list[0]}
    Append To File    ${file}    \ \ \ \ </list>\r\n

pack item to list
    [Documentation]
    ...    KW used to add multi items into list node in xml.
    ...    Author: Amaand li
    ...    Contact: amaand.li@nokia-sbell.com
    [Arguments]   ${file}  ${para_list}
    : FOR    ${item}    IN    @{para_list}
    \    log  ${item}
    \    ${isList}  Is List  ${item}
    \    Add Item To List    ${file}    ${item}

Is Item
    [Documentation]
    ...    Author: Amaand li
    ...    Contact: amaand.li@nokia-sbell.com
    [Arguments]    ${input}
    ${val}  evaluate  len(${input})>1
    ${result}    Run Keyword And Return Status    Should Be True    ${val}
    [Return]    ${result}

Add Item To List
    [Documentation]
    ...    KW used to add sub-item (eg: parameter node) into list node in xml.
    ...    Author: Amaand li
    ...    Contact: amaand.li@nokia-sbell.com
    [Arguments]    ${file}    ${item}
    Append To File    ${file}    \ \ \ \ <item>\r\n
    : FOR    ${p}    IN    @{item}
    \    ${name}    ${value}    Split String    ${p}    =
    \    Append To File    ${file}     \ \ \ \ \ \ <p name=\"${name}\">${value}</p>\r\n
    Append To File    ${file}    \ \ \ \ \ </item>\r\n

Add Para To Mo
    [Documentation]
    ...    KW used to add parameter node in xml.
    ...    Author: Amaand li
    ...    Contact: amaand.li@nokia-sbell.com
    [Arguments]    ${file}    ${para}
    ${para_name}    ${para_value}    Split String    ${para}    =
    Run keyword if   '${para_name}'=='none'  Append To File    ${file}
    ...    \ \ \ \ \ \ <p>${para_value}</p>\r\n
    Run Keyword If    not '${para_name}'=='none'  Append To File    ${file}
    ...    \ \ \ \ \ \ <p name=\"${para_name}\">${para_value}</p>\r\n

Is List
    [Arguments]    ${input}
    ${result}    Run Keyword And Return Status    Should Be True    isinstance(${input}, list)
    [Return]    ${result}

Get Aic Release
    [Documentation]
    ...    KW used to parse the release number of vcu/vdu
    ...    Author: Amaand li
    ...    Contact: amaand.li@nokia-sbell.com
    [Arguments]  ${sw}  ${separator}
    @{release_list}  Split String  ${sw}  _
    ${re1}  Fetch from right  @{release_list}[0]  ${separator}
    ${re2}  Fetch from left  @{release_list}[0]   ${separator}
    ${release}  Catenate  SEPARATOR=  ${re1}  ${re2.upper()}
    [Return]  ${release}

Add Mo To Delta File
    [Documentation]
    ...    KW used to generate managenet object and add into xml file.
    ...    Author: Amaand li
    ...    Contact: amaand.li@nokia-sbell.com
    [Arguments]    ${file}    ${distname}    ${operation}    ${paralist}
    ${rest}    ${mo}    Split String From Right    ${distname}    /    1
    ${mo}    ${rest}    Split String    ${mo}    -
    Append To File    ${file}
    ...  <managedObject class=\"${mo}\" distName=\"${distname}\" operation=\"${operation.lower()}\">\r\n
    Run Keyword If    '${operation}'=='delete'    Append To File    ${file}    </managedObject>\r\n
    Return From Keyword If    '${operation}'=='delete'
    Log List    ${paralist}
    FOR    ${item}    IN    @{paralist}
        Log    ${item}
        ${islist}    Is List    ${item}
        Run Keyword If    ${islist}    Add List To Mo    ${file}    ${item}
        Run Keyword If    not ${islist}    Add Para To Mo    ${file}    ${item}
    END
    Append To File    ${file}    </managedObject>\r\n

Download FCE Modules For Current SW
    [Arguments]    ${trunk_prefix}=vDUCNF23R4
    [Documentation]    Helper keyword for downloading fce and fct for current software build
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ${active_sw_version}    Get vDU Version
    ${current_prefix}    Set Variable    ${active_sw_version.split('_')[0].strip()}
    ${current_release}    Set Variable If    "${current_prefix}" == "${trunk_prefix}"    vDUCNF00    ${current_prefix}
    ${version_num}    Fetch From Right    ${active_sw_version}    _
    ${current_version}    Set Variable    ${current_release}_${version_num}
    ${fce_worker}    ${fct_files}    Download FCE And FCT    target_version=${current_version}    target_download_path=${TEST_LOG_DIRECTORY}
    ...    release_name=${current_release}    clean_folder=${FALSE}
    [Return]    ${fce_worker}    ${fct_files}

Download FCE And FCT
    [Arguments]    ${target_version}    ${target_download_path}=/home/ute/Downloads    ${release_name}=vDUCNF00    ${clean_folder}=${TRUE}
	[Documentation]    Helper keyword for downloading fce and fct
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | target_version | Yes | e.g. vDUCNF00_0.300.15074 |
    ...    | target_download_path | Yes | the path you want to save in local vm |
    ...    | release_name | Yes | default is: vDUCNF00 |
    ${download_command}    Set Variable    wget    #sudo wget --progress=dot:giga -T 600 -t 2
    ${download_source_path}    Set Variable
    ...    https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/${release_name}
    #...    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/${release_name}
    ${status}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${target_download_path}
    Run Keyword If    not ${status}    OperatingSystem.Create Directory    ${target_download_path}
    ${remove_files_cmd}    Set Variable    sudo rm -rf ${target_download_path}/*
    Run Keyword If    ${clean_folder}    OperatingSystem.Run    ${remove_files_cmd}
    ${fce_worker}    Set Variable    ${target_version}_fce-worker.zip
    ${fct_files}    Set Variable    ${target_version}_fct-files.zip
    Log To Console    \nStart Download FCE For ${target_version}...........
    ${output}    Wait Until Keyword Succeeds    5m    5s    OperatingSystem.Run
    ...    ${download_command} ${download_source_path}/${target_version}/${fce_worker} -O ${target_download_path}/${fce_worker}
    #Should Contain    ${output}    100%
    Log To Console    \nComplete Download FCE For ${target_version}...........
    Log To Console    \nStart Download FCT For ${target_version}...........
    ${output}    Wait Until Keyword Succeeds    5m    5s    OperatingSystem.Run
    ...    ${download_command} ${download_source_path}/${target_version}/${fct_files} -O ${target_download_path}/${fct_files}
    #Should Contain    ${output}    100%
    Log To Console    \nComplete Download FCT For ${target_version}...........
    OperatingSystem.File Should Exist    ${target_download_path}/${fce_worker}
    OperatingSystem.File Should Exist    ${target_download_path}/${fct_files}
    [Return]    ${fce_worker}    ${fct_files}

Get FCT Features On NetAct
    [Arguments]    ${filter}=${EMPTY}
	[Documentation]    Keyword used to Get FCT Features list On NetAct
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | filter | No | e.g. {'toolName': 'PDCCH', 'toolVersion': '4.8.0'}|
    ...
    ...    | Return Value | Description |
    ...    | FCT_features | NA |
    ...    Example
    ...    | ${FCT_features} | Get FCT Features On NetAct |
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command    racclimx.sh -op FCT_List -v    return_stderr=${True}    return_rc=${True}
    Should Be Equal As Integers    ${rc}    ${0}
    ${detail_line}    Should Match Regexp    ${stdout}    \\[.*\\]
    ${FCT_features}    Evaluate    ${detail_line}
    Return From Keyword If    "${filter}"==""    ${FCT_features}
    FOR    ${feature}    IN    @{FCT_features}
    ${is_match}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary    ${feature}    ${filter}
    Continue For Loop If    ${is_match}
    Remove Values From List    ${FCT_features}    ${feature}
    END
    [Teardown]     SSHLibrary.Close Connection
    [Return]    ${FCT_features}

Install FCT On NetAct
    [Arguments]    ${remote_fct_file}
	[Documentation]    Keyword used to Install FCT On NetAct
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | remote_fct_file | Yes | fct file path on netact|
    ...
    ...    | Return Value | Description |
    ...    | stdout | output info |
    ...    Example
    ...    | ${stdout} | Install FCT On NetAct | remote_fct_file=${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-F_001.xlsx |
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command
    ...    racclimx.sh -op FCT_Install -inputFile ${remote_fct_file} -v    return_stderr=${True}    return_rc=${True}
    Should Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}    Install FCT Operation finished.
    [Teardown]    SSHLibrary.Close Connection
    [Return]    ${stdout}

Get FCT Metadata On NetAct
    [Arguments]    ${adaptationVersions}    ${type}=additionalInputParameters    ${toolName}=PDCCH
	[Documentation]    Keyword used to Get FCT Metadata On NetAct
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | adaptationVersions | Yes | adaptation Version|
	...    | type | No | inputParameters,outputParameters,additionalInputParameters,additionalOutputParameters. default:additionalInputParameters |
	...    | toolName | No | default:PDCCH|
    ...
    ...    | Return Value | Description |
    ...    | ret_meta | return FCT metadata detail info |
    ...    Example
    ...    | ${ret_meta} | Get FCT Metadata On NetAct | adaptationVersions=com.nokia.srbts.nrbts:NRBTSVDU23R4 |
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command
    ...    racclimx.sh -op FCT_Get_Configuration_Help -toolName "${toolName}" -adaptationVersions "${adaptationVersions}" -v
    ...    return_stderr=${True}    return_rc=${True}
    Should Be Equal As Integers    ${rc}    ${0}
    ${detail_line}    Should Match Regexp    ${stdout}    \\{.*\\}
    ${FCT_meta_datas}    Evaluate    ${detail_line}
    ${ret_meta}    Set Variable If    "${type}"==""    ${FCT_meta_datas}    ${FCT_meta_datas["${type}"]}
    [Teardown]    SSHLibrary.Close Connection
    [Return]    ${ret_meta}

Audit On NetAct And Check Results
    [Arguments]     ${targetObjs}    ${addInputParameters}    ${adaptationVersions}    ${outputPlanName}    ${planName}=None
    ...    ${inputConfType}=actual   ${toolName}=PDCCH    ${compareFeedbackLevel}=parameterLevel
    ...    ${compareExportDifferenceReport}=AuditReportFromInputPlan
    [Documentation]    Configuration audit allow identifying, visualizing, and correcting differences between
    ...    selected BTSs configurations and recommended configuration for given feature after calculation of selected FCT tool
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...     | targetObjs  | Yes       | Specifies the scope of the operation (comma-separated Distinguished ames without spaces).
    ...                                 At least one of the arguments planName or targetObjects must be defined
    ...     | addInputParameters| Yes| Specifies the additional input parameters
    ...     | adaptationVersions | Yes | Specifies the adaptationVersions of the operation (comma-separated Distinguished Names without spaces).
    ...     | planName  | No      | Specifies a plan name. At least one of the arguments planName or targetObjects must be defined.
    ...     | outputPlanName | Yes | Specifies a plan name.
    ...     | inputConfType |  Yes | Specifies the type of input plan (plan or actual)
    ...     | toolName | Yes     | Specifies the name of FCT Tools
    ...     | compareFeedbackLevel  | No | Specifies the level of feedback (summaryLevel/objectLevel/parameterLevel).
    ...                                         Default value is summaryLevel.
    ...     | compareExportDifferenceReport | No | Specifies a file name or a path for the exported differences between the plan
    ...                                             and actual configuration.If the directory is not given, the file is written to
    ...                                             the default directory: $VARROOT/global/racops/export/. Supported file format is CSV.
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log To Console    Start Audit...
    ${tmpcmd1}    Set Variable    -targetObjects '${targetObjs}' -inputConfigurationType ${inputConfType} -toolName ${toolName}
    ${tmpcmd2}    Set Variable If    '${planName}'!='None'
    ...    -additionalInputParameters '${addInputParameters}' -adaptationVersions ${adaptationVersions} -planName ${planName}
    ...    -additionalInputParameters '${addInputParameters}' -adaptationVersions ${adaptationVersions}
    ${tmpcmd3}    Set Variable    -outputPlanName ${outputPlanName} -compareFeedbackLevel ${compareFeedbackLevel}
    ${tmpcmd4}    Set Variable    -compareExportDifferenceReport ${compareExportDifferenceReport} -v
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command
    ...    racclimx.sh -op FCT_Audit_Configuration ${tmpcmd1} ${tmpcmd2} ${tmpcmd3} ${tmpcmd4}
    ...    return_stderr=${True}
    ...    return_rc=${True}
    Should Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}    Status received: Finished
    Log To Console    Audit Finished Success...
    [Teardown]         SSHLibrary.Close Connection
    [Return]     ${stdout}

Get File From NetAct CMWAS Node
    [Arguments]     ${target_file_path}    ${destination_path}
	[Documentation]    Get file from NetAct cmwas node and put into local path
    ...    selected BTSs configurations and recommended configuration for given feature after calculation of selected FCT tool
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | target_file_path  | Yes | Specifies the path on NetAct
    ...    | destination_path| Yes| Specifies the path on local VM
    Run Keyword And Ignore Error    SSHLibrary.Close All Connections
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${file_exists}    Run Keyword And Return Status    SSHLibrary.File Should Exist    ${target_file_path}
    Run Keyword If    ${file_exists}    SSHLibrary.Get File    ${target_file_path}    ${destination_path}
    OperatingSystem.File Should Exist    ${destination_path}
    [Teardown]      SSHLibrary.Close Connection

Generate Random FCT ADDIN Params
    [Arguments]    ${additionalInputParameters}    ${ignore_params_list}=${EMPTY}
	[Documentation]    Keyword used to generate Random FCT ADDIN Params
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | additionalInputParameters | Yes | additionalInputParameters from KW:Get FCT Metadata On NetAct|
    ...
    ...    | Return Value | Description |
    ...    | parameters | return parameters dictionay. Parameter:Value |
    ...    Example
    ...    | ${parameters} | Generate Random FCT ADDIN Params | additionalInputParameters=${additionalInputParameters} |
    ${parameters}    Create Dictionary
    # 2025-08-15 Kang Lixin: specicial case on crt envs startCRBOfCoreset0 need select from 1 to 3
    ${startCRBOfCoreset0_values}    Create List    0    1    2    3
    # 2025-08-15 Kang Lixin: specicial case on crt envs fineTuneMode can not select mode1 on 11084
    ${fineTuneMode_values}    Create List    disabled    mode2    mode3
    FOR    ${p}    IN    @{additionalInputParameters}
    ${ignore}    Run Keyword And Return Status    List Should Contain Value    ${ignore_params_list}    ${p["fullName"]}:
    Continue For Loop If    ${ignore}
    ${has_tag}    ${tag}    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${p["fullName"]}
    ...    \\(rel \\>=\\w+\\)|\\(rel \\<=\\w+\\)|\\(rel \\<\\w+\\)|\\(rel \\>\\w+\\)|\\(rel \\=\\w+\\)
    ${compare_result}    Run Keyword If    '${has_tag}'=='PASS'
    ...    Compare Additional Param Support Version With Current SW From Tag     ${tag}
    Continue For Loop If    '${has_tag}'=='PASS' and '${compare_result}'!='True'
    ${allowdValues_list}    Set Variable If    '${p["fullName"]}' == 'startCRBOfCoreset0'
    ...    ${startCRBOfCoreset0_values}    ${p["allowedValues"]}
    ${allowdValues_list}    Set Variable If    '${p["fullName"]}' == 'fineTuneMode'
    ...    ${fineTuneMode_values}    ${allowdValues_list}
    ${val}    Evaluate    random.choice(${allowdValues_list})    modules=random, sys
    Set To Dictionary    ${parameters}    ${p["name"]}    ${val}
    END
    [Return]    ${parameters}

Generate Random FCT ADDIN Params For TargetDNs
    [Arguments]    ${list_target_DN}    ${additionalInputParameters}    ${ignore_param_list}=${EMPTY}
	[Documentation]    Keyword used to generate Random FCT ADDIN Params For TargetDNs
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | list_target_DN | Yes | list. e.g. ['MRBTS-11085/NRBTS-11085/NRCELL-2']|
	...    | additionalInputParameters | Yes | additionalInputParameters from KW:Get FCT Metadata On NetAct|
    ...
    ...    | Return Value | Description |
    ...    | list_ADDIN_params | return list parameters for each targetDN |
    ...    Example
    ...    | ${list_ADDIN_params} | Generate Random FCT ADDIN Params For TargetDNs | additionalInputParameters=${additionalInputParameters} |
    ${list_ADDIN_params}    Create List
    FOR    ${dn}    IN    @{list_target_DN}
    ${params_of_DN}    Create Dictionary
    ${parameters}    Generate Random FCT ADDIN Params    ${additionalInputParameters}    ${ignore_param_list}
    Set To Dictionary    ${params_of_DN}    distName=${dn}    parameters=${parameters}
    Append To List    ${list_ADDIN_params}    ${params_of_DN}
    END
    [Return]    ${list_ADDIN_params}

Compare Additional Param Support Version With Current SW From Tag
    [Arguments]     ${tag}
    [Documentation]    Keyword used to deal with specific parameter that has tag (rel<=xx) or (rel >=xx). Compare current software
    ...    version and the version in tag. Return the actual comparation result
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | tag | Yes | e.g. (rel<=24R1)|
    ...
    ...    | Return Value | Description |
    ...    | compare_result | return the comparation result for current sw release and tag|
    ...    Example
    ...    | ${compare_result} | Compare Additional Param Support Version With Current SW From Tag | ${tag} |
    ${active_sw_version}    Get vDU Version
    ${current_release}    Set Variable    ${active_sw_version.split('_')[0].strip().replace('vDUCNF','')}
    ${cur_rel_y_num}    Set Variable    ${current_release.split('R')[0]}
    ${cur_rel_q_num}    Set Variable    ${current_release.split('R')[1]}
    ${formatted_tag}    Set Variable    ${tag.replace('(rel','').replace(')','').strip()}
    ${tag_release}    Should Match Regexp     ${formatted_tag}    \\w+
    ${tag_symbol}    Remove String    ${formatted_tag}    ${tag_release}
    ${tag_rel_y_num}    Set Variable    ${tag_release.split('R')[0]}
    ${tag_rel_q_num}    Set Variable    ${tag_release.split('R')[1]}
    ${compare_result}     Run Keyword If    ${cur_rel_y_num}==${tag_rel_y_num}
    ...    Run Keyword And Return Status    Should Be True    ${cur_rel_q_num} ${tag_symbol} ${tag_rel_q_num}
    ...    ELSE    Run Keyword And Return Status    Should Be True    ${cur_rel_y_num} ${tag_symbol} ${tag_rel_y_num}
    [Return]     ${compare_result}

NetAct CMP Config
   [Arguments]    ${fqdn}    ${preSharedKey}    ${refNum}    ${NETACT}    ${serverType}=RSA
   [Documentation]    Certificate Management -> Automatic Management: CMP Server Settings
    ...   Author: yuyan xu
    ...   Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | fqdn          | yes | DN of NE on NetAct |
    ...   | preSharedKey  | yes | psk_key, e.g.:94cu-gGZp-2z8E-KWcu |
    ...   | refNum        | yes | ref_number, e.g.:37385 |
    ...   | NETACT        | yes | NetAct IPs |
    ...   | serverType    | no | (optional) introduced by Feature CB0005999 in 22R4, one of RSA or ECDSA. |
    ...
    ...   | Return Value | Description |
    ...   | output | operation output |
    ...
    ...   Example
    ...   | NetAct CMP Config | PLMN-PLMN/MRBTS-1816 | 94cu-gGZp-2z8E-KWcu | 37385 | ${NETACT} |
    ...
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${cert_cmd}    Set Variable   /opt/nokia/oss/bin/NECertMgmt.sh --operation cmpConfig --fqdnType NE
    SSHLibrary.Start Command    ${cert_cmd} --fqdn ${fqdn} --serverType ${serverType} --preSharedKey "${preSharedKey}" --refNum "${refNum}"
    ${output}    SSHLibrary.Read Command Output
    Should Contain    ${output}    Status: Success
    [Return]    ${output}
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

NetAct Management Certificates
    [Arguments]    ${operationType}    ${fqdn}    ${NETACT}    ${serverType}=RSA
    [Documentation]    Certificate Management -> Automatic Management
    ...   Author: yuyan xu
    ...   Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | operationType  | yes | e.g. cmpInit,updateNeCert |
    ...   | fqdn          | yes | DN of NE on NetAct |
    ...   | NETACT          | yes | NetAct IPs |
    ...   | serverType    | no | (optional) introduced by Feature CB0005999 in 22R4, one of RSA or ECDSA. |
    ...
    ...   | Return Value | Description |
    ...   | output | operation output |
    ...
    ...   Example
    ...   | NetAct Management Certificates | cmpInit | PLMN-PLMN/MRBTS-1816 | ${NETACT} |
    ...
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    SSHLibrary.Start Command    /opt/nokia/oss/bin/NECertMgmt.sh --operation ${operationType} --fqdnType NE --fqdn ${fqdn} --serverType ${serverType}
    ${output}    SSHLibrary.Read Command Output
    Should Contain    ${output}    Status: Success
    [Return]    ${output}
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Get Actual Configuration Parameters
    [Documentation]    Get and return the actual value of the given parameter
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | ne | Yes | Network Element |
    ...    | dist_name| distName of element
    ...    | param| Specifical parameter to check
    ...    | ui_values| default is false
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | actual_value | actual parameter value from NetAct |
    [Arguments]    ${ne}    ${dist_name}    ${param}    ${ui_values}=false
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    netact.Export Configuration    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=get_param_value_from_netact_plan.xml
    ...   operation_type=actual    dist_names=${ne}    ui_values=${ui_values}
    ${scf_xml}=    L_XML.Parse Xml    ${TEST_LOG_DIRECTORY}/NetActLogs/get_param_value_from_netact_plan.xml
    ${actual_value}   L_XML.Get Element Text   ${scf_xml}   .//managedObject[@distName="${dist_name}"]/p[@name="${param}"]
    [Return]      ${actual_value}

NetAct Provision Plan Failure
    [Arguments]    ${plan_name}    ${dist_names}    ${backup_plan_name}    ${create_backup_plan}    ${provisioning_operation}
    [Documentation]    Helper keyword used for provision plan
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...    | plan_name | Yes | Plan Name |
    ...    | dist_names | Yes | MO distName |
    ...    | backup_plan_name | Yes | Backup plan name |
    ...    | create_backup_plan | Yes | Create backup plan; True or False |
    ...    | provisioning_operation| Yes | Specifies a provisioning operation (activate/preactivate) |
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | err_message | actual error message from provision result |
    ...   Example
    ...  | NetAct Provision Plan Failure | plan_name=${delta_plan_name_vDU}_backup_${timestamp} | dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...  | backup_plan_name=None | create_backup_plan=False | provisioning_operation=activate
    ${status}    ${err_message}    Run Keyword And Ignore Error    netact.Provision Plan    plan_name=${plan_name}    dist_names=${dist_names}
    ...    backup_plan_name=${backup_plan_name}    create_backup_plan=${create_backup_plan}
    ...    provisioning_operation=${provisioning_operation}
    Should Be True    '${status}'=='FAIL'
    Should Contain     ${err_message}    5G/LTE/SRAN plan provision failed
    Run Keyword If    '${status}'=='FAIL'    Log    Provision plan ${plan_name} failed as expected!    console=True
    ...    ELSE    Run Keywords    Log    Provision plan ${plan_name} success but expected fail!   level=ERROR
    ...    AND    Fail    netact.Provision Plan ${plan_name} success but expected fail!
    [Return]    ${err_message}

Create Plan To Delete NRCELL Via NetAct
    [Arguments]    ${nrcell_DN}    ${backup_scf}    ${local_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    Create Plan To Delete NRCELL Via NetAct
    ...    Author: Kang Lixin
    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Set Test Variable    ${plan_name}    MRBTS-${vDU_id}_${timestamp}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${plan_name}    ${plan}
    ${plan}    NetAct Create Plan    ${plan_name}    Automation for ${TEST_NAME}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${backup_scf}
    ${elements_for_nrcell}    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@distName,"${nrcell_DN}")]
    ${selected_nrcell_lcrid}  L_XML.Get Element Text    ${scf_xml}   .//managedObject[@distName="${nrcell_DN}"]/p[@name="lcrId"]
    ${nrcell_cellmapping_str}    catenate    SEPARATOR=    LCELNR-    ${selected_nrcell_lcrid}
    ${elements_for_cellMapping}    L_XML.Get Elements    ${scf_xml}
    ...    .//managedObject[contains(@distName,"${nrcell_cellmapping_str}")]
    Set Test Variable    ${nrcell_cellmapping_str}
    ${elements_for_nrcellGroup}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]
    ${cellgroup_dns}    Create List
    FOR    ${cellgroup}    IN    @{elements_for_nrcellGroup}
        ${MO_items}    L_XML.Get Element Attributes    ${cellgroup}
        Append To List    ${cellgroup_dns}    ${MO_items}
    END
    ${selected_nrcell_id}    Fetch From Right    ${nrcell_DN}    -
    FOR    ${cellgroup}    IN    @{elements_for_nrcellGroup}
        ${MO_items}    L_XML.Get Element Attributes    ${cellgroup}
        ${nrCellList}    L_XML.Get Elements Texts    ${scf_xml}   .//managedObject[@distName="${MO_items['distName']}"]/list[@name="nrCellList"]
        ${formatedNRCellList}    Get Formatted NRCellList    ${nrCellList}
        ${isSlected_nrcell_cellgroup}    Run Keyword And Return Status    List Should Contain Value    ${formatedNRCellList}    ${selected_nrcell_id}
        Continue For Loop If    not ${isSlected_nrcell_cellgroup}
        Remove Values From List    ${formatedNRCellList}    ${selected_nrcell_id}
        Set Test Variable    ${formatedNRCellList}
        ${len}    Get Length    ${formatedNRCellList}
        ${nrcellgroup_operation}    Set Variable If    '${len}'=='0'   delete    update
        Set Test Variable    ${nrcellgroup_operation}
        Set Test Variable    ${selected_nrcellgroup}    ${MO_items}
        Exit For Loop
    END
    Remove Values From List    ${cellgroup_dns}    ${selected_nrcellgroup}
    ${other_cellgroup_ids}    Create List
    FOR    ${cellgroup}    IN    @{cellgroup_dns}
        ${distName}    Set Variable    ${cellgroup['distName']}
        ${grp_id}    Fetch From Right    ${distName}    -
        Append To List    ${other_cellgroup_ids}    ${grp_id}
    END
    ${elements_to_delete}    Combine Lists    ${elements_for_nrcell}    ${elements_for_cellMapping}
    FOR    ${element}    IN    @{elements_to_delete}
        ${MO_items}    L_XML.Get Element Attributes    ${element}
        ${managed_object}    netact.create_managed_object    plan=${plan}    meta_class=${MO_items['class']}
        ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/${MO_items["distName"]}
        ...    operation=DELETE
        ${status}    Run Keyword And Return Status    netact.Get Managed Object    configuration=${plan}
        ...    mo_id=PLMN-PLMN/${MO_items["distName"]}
        Run Keyword If    ${status}    Run Keywords    Log    MO successfully created: ${managed_object}    console=True
        ...    AND    Log    Parameters were set with plan ${plan}    console=True
        ...    ELSE    Run Keywords    Log    MO creation failed!    level=ERROR
        ...    AND    Fail    MO creation failed!
    END
    ${element_nrdu}    L_XML.Get Elements    ${scf_xml}     .//managedObject[contains(@distName,"MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRDU-1")]
    ${MO_NRDU}    L_XML.Get Element Attributes    ${element_nrdu[0]}
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_NRDU['class']}
    ...    meta_version=${MO_NRDU['version']}    mo_id=PLMN-PLMN/${MO_NRDU["distName"]}    refNrCellGroup=${other_cellgroup_ids}
    Run Keyword If    '${nrcellgroup_operation}'=='delete'    NetAct Create Managed Object    plan=${plan}
    ...    meta_class=${selected_nrcellgroup['class']}    meta_version=${selected_nrcellgroup['version']}
    ...    mo_id=PLMN-PLMN/${selected_nrcellgroup["distName"]}    operation=DELETE    &{EMPTY}
    ...    ELSE    NetAct Create Managed Object    plan=${plan}    meta_class=${selected_nrcellgroup['class']}
    ...    meta_version=${selected_nrcellgroup['version']}    mo_id=PLMN-PLMN/${selected_nrcellgroup["distName"]}   nrCellList=${formatedNRCellList}
    NetAct Export Plan    local_dir=${local_dir}  file_name=${plan_name}.csv    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    plan_name=${plan_name}    operation_type=plan
    [Return]   ${plan_name}


Get Formatted NRCellList
    [Arguments]     ${nrCellList}
    [Documentation]    Invoke by KW:Create Plan To Delete NRCELL Via NetAct
    ...    Author: Kang Lixin
    ${formatedNRCellList}    Create List
    FOR    ${item}    IN    @{nrCellList}
        ${cellid}    Set Variable    ${item.strip()}
        Append To List    ${formatedNRCellList}    ${cellid}
    END
    [Return]     ${formatedNRCellList}