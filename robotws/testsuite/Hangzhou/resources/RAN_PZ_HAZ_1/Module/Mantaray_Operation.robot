*** Settings ***
Documentation
...    Author: Dante?He
...    Email address: Dante.1.he@nokia-sbell.com
...    Maintainer: Dante?He
...    Email address:  Dante.1.he@nokia-sbell.com
...    Common KWs use Mantaray to operate the bts
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guidelines for user: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/11.+Module+of+Mantaray+Operation
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test


Resource    ./library/_Mantaray_Operation.robot



*** Keywords ***
Mantaray Operation
    [Arguments]    ${operation}
    ...    ${product_type}=${None}
    ...    ${bts_index}=${0}
    ...    ${cudu_index}=${0}
    ...    ${mantaray_name}=${None}
    ...    ${alias_name}=netact_oper
    #swm
    ...    ${software_build}=${None}
 #cm
    ...    ${file_path}=${None}
    #...    ${delta_plan}=${None}
    ...    ${plan_name}=${None}   #default= btsid+date
    ...    ${editor_operation}=${None}
    ...    ${editor_distname}=${None}
    ...    ${editor_parameters}=${None}
    #cmd
    ...    ${command}=${None}
    ...    ${timeout}=5000
    ...    &{kwargs}
    [Documentation]     this keyword contain the Mantaray operation
    ...    operation can support from common,SWM,CM,FM,PM,PNP,chec with both VNF and classical BTS:
    ...    COMMON:integration.deintegration,login_to_mantaray,cmd_execute_command,cmd_execute_command,login_out_mantaray_commander
    ...    SWM:swm_download, swm_provision,swm_import,swm_activation,swm_download,swm_rollback,swm_precheck,swm_postcheck,swm_upload
    ...    CM:TBD
    ...    FM:TBD
    ...    PM:TBD
    ...    Checker:get_provision_status
    ...   Otherwise some common operation also support: intergration,deintegration and ssh access to mantaray and checker for mantaray status checking
    ...   Author: Dante He
    ...   Contact: dante.1.he@nokia-sbell.com
    ...   | Input Parameters | Man. | Description | Parameter for Sub-Ca
    ...   | operation  | yes | operation can support. Notice: for swm operation,  module will not import the build to mantaray lab
    ...     if you are not call swm_import |
    ...   | product_type  | yes | The type of bts product, e.g. enb; gnb; vdu; vcu   | Common
    ...   | mantaray_name  | yes | name of the operating mantaray lab,e.g. Mantaray_1027,Mantaray_chen4, Caps is not sensitive  | Common
    ...   | alias | No | you can input an existed connection or the alias name you want|Common
    ...   |            |    | kw will generate a connection and destroy it after operation done |Common
    ...   | gnb_index | yes | the index of the bts in tl's init.py, ${tl.gnbs[gnb_index]} |Common
    ...   | vdu_vcu_index | No |  the index of the bts du in tl's init.py, ${tl.gnbs[gnb_index].dus[vdu_vcu_index]} |Common
    ...   | timeout | No | Mostly you no need to change this value, most of operation have their own default time |Common
    ...   | software_build | Yes for SWM | supported the SBTS,RUSW,vCUCNF,vDUCNF, please gives full local path for software_build
    ...    for SBTS build you can also gives build name e.g. SBTS00_FSM3_9999_240618_000001  |SWM
    ...   | output_dir | No  | default just supported the classical |SWM
    # if operation contains "cm" then cm_
    #if not cm fm pm then lead to common will only validate common
    #Log to console         Parse Variable from user product
    ${Operation}=      Convert To Lower Case     ${operation}
    ${result} =    Evaluate    '${product_type}'=='enb' or '${product_type}'=='gnb' or'${product_type}'=='vcu' or '${product_type}'=='vdu'
    Run Keyword If    ${result}==${FALSE}      FAIL        product type invalid
    Parse Variable from user product    mantaray_name=${mantaray_name}    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    Log to console         start operation ${operation}........................
    ${Operation_devider}=      Fetch From Left       ${operation}      _
    Run Keyword If     'swm' in '${Operation_devider}'
    ...    SWM Mantaray Operation     operation=${operation}     mantaray_name=${mantaray_name}
    ...    alias_name=${alias_name}    software_build=${software_build}    timeout=${timeout}
    ...    kwargs=&{kwargs}
    ...    ELSE IF    'cm' in '${Operation_devider}' or 'editor' in '${Operation_devider}'
    ...    Configuration Mantaray Operation    operation=${operation}
    ...    product_type=${product_type}        bts_index=${bts_index}         cudu_index=${cudu_index}
    ...     file_path=${file_path}             plan_name=${plan_name}     mantaray_name=${mantaray_name}    #default= btsid+date
	...    editor_operation=${editor_operation}
    ...    editor_distname=${editor_distname}
    ...    editor_parameters=${editor_parameters}
	...     timeout=${timeout}       kwargs=&{kwargs}
    ...    ELSE IF      'get' in '${Operation_devider}'      Mantaray Get Operation       operation=${operation}
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    cudu_index=${cudu_index}
    ...    mantaray_name=${mantaray_name}
    ...    alias_name=${alias_name}
    ...    timeout=${timeout}
    ...    kwargs=&{kwargs}
    ...    ELSE   Common Mantaray Operation    operation=${operation}
    ...    product_type=${product_type}      bts_index=${bts_index}      cudu_index=${cudu_index}
    ...    mantaray_name=${mantaray_name}      alias_name=${alias_name}
	...    command=${command}      timeout=${timeout}       kwargs=&{kwargs}
