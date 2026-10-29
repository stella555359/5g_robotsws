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
    [Arguments]     ${was_host}    ${netact_user}    ${netact_password}
    [Documentation]    Keyword used for set up of NetAct and its cwwas node
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | was_host    | yes | FHGW ip |
    ...   | netact_user    | yes | FHGW dist name on NetAct |
    ...   | netact_password | no | FHGW release version, default is FHGW22R4 |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | Setup NetAct | was_host=10.53.80.134 | netact_user=omc | netact_password=Medsql!_1893 |
    Add Node    cmwas    ${was_host}    ${netact_user}    ${netact_password}    #${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    #Add Node    fmwas    ${NETACT['fm_host']}    ${NETACT['user']}    ${NETACT['password']}
    ${web_url}=    Detect WEB URL
    Add WEB URL    ${web_url}    ${netact_user}    ${netact_password}    #${NETACT['user']}    ${NETACT['password']}

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
    Delete Node    cmwas
    #Delete Node    fmwas
    Clean All

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
    run keyword if  not ${status}    FAIL    Get FHGW user config file:${tl.gnbs[0].dus[0].fhgws[0].user_config_path} failed!
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
    [Arguments]    ${local_dir}    ${file_name}    ${dist_names}    ${plan_name}    ${operation_type}=plan
    [Documentation]    Helper keyword used for export plan from NetAct to local_dir/file_name place
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...    | local_dir | Yes | Path to local directory where NetAct plan should be stored |
    ...    | file_name | Yes | File name for local stored plan |
    ...    | dist_names | Yes | MO distName |
    ...    | plan_name | Yes | Name of plan on NetAct |
    ...    | operation_type | No | Specifies the type of the export operation (plan/actual/reference/template/siteTemplate |
    ...
    ...   Example
    ...  | NetAct Export Plan | local_dir=${TEST_LOG_DIRECTORY} | file_name=actual_${export_timestamp}.xml
    ...  | dist_names=${distName} | plan_name=${plan_name} | operation_type=actual |
    ${status}=    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${local_dir}
    run keyword if  not ${status}    Create Directory    ${local_dir}
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${local_dir}    file_name=${file_name}
    ...    operation_type=${operation_type}    dist_names=${dist_names}    plan_name=${plan_name}
    ${status}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${local_dir}/${file_name}
    Run Keyword If    ${status}    Log    Plan ${plan_name} available at ${local_dir}/${file_name}    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} not available at ${local_dir}/${file_name}    level=ERROR
    ...    AND    Fail    Plan ${plan_name} not available at ${local_dir}/${file_name}

NetAct Import Plan
    [Arguments]    ${local_dir}    ${file_name}    ${plan_name}
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
    ${status}    ${plan}=    Run Keyword And Ignore Error    Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${plan_name}    ${plan}
    OperatingSystem.File Should Exist    ${local_dir}/${file_name}
    ${status}=    Run Keyword And Return Status    netact.Import Configuration    local_dir=${local_dir}
    ...    file_name=${file_name}    plan_name=${plan_name}
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
    ...    AND    Fail    Provision plan ${plan_name} failed!


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
    netact.Export Configuration    local_dir=${TEST_LOG_DIRECTORY}    file_name=check_netact_plan_${timestamp}.xml
    ...   operation_type=actual    dist_names=${ne}
    ${param_names}    Get Dictionary Keys    ${parameters_dict}
    ${param_values}    Get Dictionary Values    ${parameters_dict}
    ${param_count}    Get Length    ${param_names}
    ${scf_xml}=    L_XML.Parse Xml    ${TEST_LOG_DIRECTORY}/check_netact_plan_${timestamp}.xml
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
    ${status}    ${plan}=    Run Keyword And Ignore Error    Get Plan Configuration    ${name}
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
    ${plan}=    Create Plan Configuration    ${name}    ${description}
    ${status}=    Run Keyword And Return Status    Get Plan Configuration    ${name}
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
    ${managed_object}=    Create Managed Object    plan=${plan}    meta_class=${meta_class}
    ...    meta_version=${meta_version}    mo_id=${mo_id}    operation=${operation}   &{parameters_dict}
    ${status}=    Run Keyword And Return Status    Get Managed Object    configuration=${plan}    mo_id=${mo_id}
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
    ${status}    ${plan}=    Run Keyword And Ignore Error    Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    netact.Delete Plan    ${plan_name}

NetAct Delete Plan
    [Arguments]    ${name}    ${plan}
    netact.Delete Plan    ${name}
    ${status}=    Run Keyword And Return Status    Get Plan Configuration    ${name}
    Run Keyword If    ${status}    Run Keywords    Log    Plan deletion failed!    level=ERROR
    ...    AND    Fail    Plan deletion failed!
    ...    ELSE    Log    Plan successfully deleted: ${plan}    console=True

Download vRAN SW Build
    [Arguments]    ${build_folder_name}    ${build_name}    ${target_path}    ${release_name}=vDUCNF00
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
    ${download_command}    Set Variable    sudo wget --progress=dot:giga -T 600 -t 2
    ${download_source_path}    Set Variable
    ...    https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/${release_name}
    ${remove_files_cmd}    Set Variable    sudo rm -rf ${target_path}/*
    Run    ${remove_files_cmd}
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
    Log To Console    \nStart Copy SW to NetAct...........
    tafssh.Upload File    ${source_path}/${build_name}.zip    ${netact_swm_path}/${build_name}.zip
    Log To Console    \nFinish Copy SW to NetAct...........
    tafssh.Send Command     chmod 777 ${netact_swm_path}/${build_name}.zip
    tafssh.Disconnect    ${netactcon}
    Log To Console    \nStart Import Plugin:${build_name}...........
    netact.Import Build   ${netact_swm_path}/${build_name}.zip    clean_temp_storage=True
    Log To Console    \nComplete Import Plugin:${build_name}...........
	
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
    ${status}    ${plan}=    Run Keyword And Ignore Error    Get Plan Configuration    ${plan_name}
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
    ...           ${timeout}=${7200}    ${alias}=${None}    ${verbose}=${True}
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
    ${output}    Replace String Using Regexp    ${output}    \\n\\t    ${EMPTY}
    Should Contain    ${output}    Install main chart success
    Should Contain    ${output}    CNF Create Rollback Plan successful
    Should Contain    ${output}    Validate chart success
    Should Contain    ${output}    CNF Upgrade successful
    log to console    **** NetAct Upgrade CNF Successfull ****

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
