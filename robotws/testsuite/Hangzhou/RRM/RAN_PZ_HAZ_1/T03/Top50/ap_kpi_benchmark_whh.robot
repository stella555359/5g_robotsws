*** Settings ***
Documentation
...   author: keli
...   contact: keli.weng@nokia-sbell.com
...   Description: this is one reference case template of AP test.
Resource          ../Resources/common_resource.robot
# Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
# Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/BTS_Operation.robot
# Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/Counter_Operation.robot
# Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/Log_Collection.robot
# Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/AT_Operation.robot
# Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/Airphone_Operation.robot
# Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/KPI_Operation.robot
# Library            ../../../../resources/RAN_PZ_HAZ_1/Module/Traffic_UEBox_Operation.py
# Resource           ../../../../resources/RAN_PZ_HAZ_1/Module/Log_Analysis.robot
Resource           ../../../../resources/RAN_PZ_HAZ_1/CERTA_Module/Traffic_Module_For_ET.robot
# Resource           ../../Resources/RRM_Custom_Config.robot
# Resource          ../Resources/top50_resource.robot
# Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Setup        Run keywords    Common MultiBTS Suite Setup For RRM
...                AND    Update bsr package
Suite Teardown      Common MutliBTS Suite Teardown For RRM
# Suite Setup       Common MultiBTS Suite Setup For RRM
# # Suite Setup       Common Suite Setup For RRM
# Test Setup        Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
# # Test Setup          Common Test Setup For RRM
# Test Teardown     Common MultiBTS Test Teardown For RRM
# # Test Teardown    Common Test Teardown For RRM
# Suite Teardown    Common MutliBTS Suite Teardown For RRM
# Suite Teardown    Common Suite Teardown For RRM

Force Tags        CRT/CIT/CDRT     #Tag Item
# ...   PY27
...      RAN_5G                    #Product [RAN_5G]
# ...      CLOUD_5G_I_MP_AP_LO   #TLtype, it is for auto trigger by ute cloud
...      SBTS00/SBTS21B           # it is for auto trigger by ute cloud with the release
# ...      STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]


Test Timeout    480 minutes

*** Variables ***
#reduce global paramter as possilbe and automatically got from gNB or __init__
&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_61616}           faultId=${61616}
&{fault_4459}            faultId=${4459}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_61616}
...    &{fault_4459}    &{fault_8000}    &{fault_7300}
# ${APC_Index}    -1
${PA_MinValue}           ${0}
${PA_MaxValue}           ${93}
${DEBUG_MODE}            ${TRUE}
# ${REMOTE_MODE}           ${TRUE}
${usr_email}             tacase_auto@nokia-sbell.com
${traffic_file}          traffic_model.json
${apconfig_tag}          SA_TDD_2c_1gNBSim_255UE
${customer_tag}          None
${env_tag}               sa
${lua_path}              ${CURDIR}/APCFG/wts_${apconfig_tag}.lua
&{ap_info}               CLOUD_5G_I_MP_AP_LO=SA_TDD_2c_1gNBSim_255UE
...                      CLOUD_5G_I_LOO_AP_LOOO=SANSA_TMO_255UE
...                      CLOUD_5G_O_E_AP_LOOO=SA_TDD_1gNBSim_RJO
&{customer_info}         CLOUD_5G_I_MP_AP_LO=None
...                      CLOUD_5G_I_LOO_AP_LOOO=TMO
...                      CLOUD_5G_O_E_AP_LOOO=None
&{env_info}              CLOUD_5G_I_MP_AP_LO=sa
...                      CLOUD_5G_I_LOO_AP_LOOO=sansa
...                      CLOUD_5G_O_E_AP_LOOO=sa
&{Upgrade_Case_Info}      Case_Path=${CURDIR}${/}..${/}AP_Case${/}upgrade.robot
...                       Case_Tag=Upgrade
&{Feature_File_INFO}
...    Upgrade=&{Upgrade_Case_Info}
${Ignore_Cell_Id_For_Sib}    5    6    9    12
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
*** Test Cases ***
#test case name should be same with qc case name without space and special characters


Airphone Kpi Test For Traffic Model For SW1
    [Documentation]   Airphone Kpi Test For Traffic Model For SW1
    [Setup]    Case Precondition
    Collect Syslog Start
    Collect Emil log Start
    Log To Console    Traffic with Airphone Start
    ${zip_path1}    RRM Traffic With Airphone    traffic_module_config_path=${CURDIR}/Traffic/${traffic_file}
    ...    timeout=10 minutes
    ...    lua_path=${lua_path}
    ...    email=${usr_email}
    ...    need_generate_report=False
    Set Suite Variable    ${zip_path1}    ${zip_path1}
    [Teardown]    Case Postcondition

Upgrade For Sw2
    [Documentation]   upgrade to -v SW2
    [Setup]    Upgrade Common Setup
    Log To Console    Upgrade For Sw2
    Update File Except Sw2
    Run Feature Case    feature_name=Upgrade    test_name=Upgrade
    [Teardown]    Case Postcondition


Airphone Kpi Test For Traffic Model For SW2
    [Documentation]   Airphone Kpi Test For Traffic Model For SW2
    [Setup]    Case Precondition
    Collect Syslog Start
    Collect Emil log Start
    Log To Console    Traffic with Airphone Start
    ${zip_path2}    RRM Traffic With Airphone    traffic_module_config_path=${CURDIR}/Traffic/${traffic_file}
    ...    timeout=10 minutes
    ...    lua_path=${lua_path}
    ...    email=${usr_email}
    ...    need_generate_report=False
    Set Suite Variable    ${zip_path2}    ${zip_path2}
    [Teardown]    Case Postcondition

Generate Benchmark Report
    [Documentation]   Generate KPI Benchmark Report
    KPI Operation    benchmark_report_generate    pmfile_zip_path1=${zip_path1}
    ...    pmfile_zip_path2=${zip_path2}
    ...    owner=${usr_email}


*** Keywords ***
Case Precondition
    [Documentation]
    ...    AP Preparation
    _Create Test Directory
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Get AP Config Tag From Ap User Config By Email
    Get Customer Config Tag
    Get Env Config Tag
    Get Traffic Model From Ap User Config By Email
    Get Lua Path
    Airphone Operation    operation=env_setup_${env_tag}
    ...    product_type=gnb
    ...    tag=${apconfig_tag}
    ...    customer=${customer_tag}

Case Postcondition
    Run Keyword And Ignore Error    Airphone Operation    operation=aplog
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Run Keyword And Ignore Error    Collect Syslog Stop
    Run Keyword And Ignore Error    Collect Emil log Stop
    Run Keyword And Ignore Error    Collect snapshot log
    Airphone Operation    operation=edaemon_egate_teardown
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Upgrade Common Setup
    Get Env Config Tag
    Get AP Config Tag
    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    ...    airphone_config_tag=${apconfig_tag}
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=${env_tag}


Update File Except Sw${i}
    ${sw}    Get Variable Value    ${SW${i}}    ${None}
    Set Suite Variable    ${SW${i}}    ${sw}
    Return From Keyword If    '${SW${i}}'=='${None}'
    Replace String In One File    file_path=${UTE_RESERVATION_JSON}
    ...    pattern=${Expect_Sw_Version}    replace_with=${SW${i}}
    Replace String In One File    file_path=${UTE_RESERVATION_CONTEXT_JSON}
    ...    pattern=${Expect_Sw_Version}    replace_with=${SW${i}}

Get AP Config Tag
    Log To Console    Get AP Config Tag
    Run Keyword If    '${Testline_type}' in &{ap_info}
    ...    Log To Console    Key ${Testline_type} exist in the dict
    ...    ELSE    Log To Console    Key ${Testline_type} does not exist in the dict
    ${apconfig_tag}    Get From Dictionary    ${ap_info}    ${Testline_type}
    Set Suite Variable    ${apconfig_tag}    ${apconfig_tag}
    Log To Console    Use Tag:${apconfig_tag}

Get Customer Config Tag
    Log To Console    Get Customer Config Tag
    Run Keyword If    '${Testline_type}' in &{customer_info}
    ...    Log To Console    Key ${Testline_type} exist in the dict
    ...    ELSE    Log To Console    Key ${Testline_type} does not exist in the dict
    ${customer_tag}    Get From Dictionary    ${customer_info}    ${Testline_type}
    Set Suite Variable    ${customer_tag}    ${customer_tag}
    Log To Console    customer:${customer_tag}

Get Env Config Tag
    Log To Console    Get Env Config Tag
    Run Keyword If    '${Testline_type}' in &{env_info}
    ...    Log To Console    Key ${Testline_type} exist in the dict
    ...    ELSE    Log To Console    Key ${Testline_type} does not exist in the dict
    ${env_tag}    Get From Dictionary    ${env_info}    ${Testline_type}
    Set Suite Variable    ${env_tag}    ${env_tag}
    Log To Console    Use Tag:${env_tag}

Get Lua Path
    [Documentation]   Print Lua file path
    Set Suite Variable    ${lua_path}    ${CURDIR}/APCFG/wts_${apconfig_tag}.lua
    Log To Console    Lua Path:${lua_path}

Get Ap User Config By Email
    [Arguments]    ${owner}=${usr_email}
    ${config}    get_content_from_json    ${CURDIR}/ap_user_config.json
    ${status}    Run Keyword And Return Status
    ...    Get From Dictionary    ${config}[users]    ${owner}
    ${apconfig}    Run Keyword If    '${status}'=='False'
    ...    Get From Dictionary    ${config}[users]    default
    ...    ELSE    Get From Dictionary    ${config}[users]    ${owner}
    [Return]    ${apconfig}

Get Traffic Model From Ap User Config By Email
    [Arguments]    ${owner}=${usr_email}
    ${apconfig}    Get Ap User Config By Email   ${owner}
    Log To Console    ${apconfig}
    ${tl_ap_config}    Get From Dictionary    ${apconfig}    ${Testline_type}
    Set Suite Variable    ${traffic_file}    ${tl_ap_config}[traffic_model]
    Log To Console    Set traffic file Path:${traffic_file}

Get AP Config Tag From Ap User Config By Email
    [Arguments]    ${owner}=${usr_email}
    ${apconfig}    Get Ap User Config By Email   ${owner}
    ${tl_ap_config}    Get From Dictionary    ${apconfig}    ${Testline_type}
    Set Suite Variable    ${apconfig_tag}      ${tl_ap_config}[AP_TAG]
    Log To Console    Set and Use AP_TAG:${apconfig_tag}

Collect snapshot log
    ${local_file_path}    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Log To Console    \nSnapshot log: ${local_file_path}

Update bsr package
    [Documentation]   Update bsr package
    Run Keyword If    '${Testline_type}' != 'CLOUD_5G_O_E_AP_LOOO'    Return From Keyword
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run     wget ${dllink}/${filename} -P /home/ute
    coam.setup admin
    ${ret}     coam.Update Software      /home/ute/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    coam.teardown admin

Collect Syslog Start
    [Arguments]    ${bts_index}=${0}
    [Documentation]   Collect syslog start
    Log Collection    start    syslog    product_type=gnb    bts_index=${bts_index}
    sleep    20s

Collect Syslog Stop
    [Arguments]    ${bts_index}=${0}
    [Documentation]   Collect syslog stop
    ${local_file_path}    Log Collection    stop_and_download    syslog    product_type=gnb    bts_index=${bts_index}
    Log To Console    \nSyslog log: ${local_file_path}
    [Return]    ${local_file_path}

Collect Emil log Start
    [Arguments]    ${bts_index}=${0}
    [Documentation]   Collect email log start
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti+emil+bip    product_type=gnb    bts_index=${bts_index}    dict_argument=${dict_argument}
    sleep    20s

Collect Emil log Stop
    [Arguments]    ${bts_index}=${0}
    [Documentation]   Collect emil log stop
    ${local_file_path}    Log Collection    stop_and_download    tti+emil+bip    product_type=gnb    bts_index=${bts_index}
    Log To Console    \nEmil log: ${local_file_path}



