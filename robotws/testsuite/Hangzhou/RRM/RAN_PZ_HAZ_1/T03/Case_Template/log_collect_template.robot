*** Settings ***
Documentation
...   author: keli
...   contact: keli.weng@nokia-sbell.com
...   Description: this is one reference case template, purpose for unified style.

Resource           ../Resources/common_resource.robot
# Resource           ../../Resources/RRM_Custom_Config.robot
Resource          ../Resources/top50_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
# Suite Setup       Common Suite Setup For RRM
Test Setup        Common MultiBTS Test Setup For RRM
# Test Setup          Common Test Setup For RRM
Test Teardown     Common MultiBTS Test Teardown For RRM
# Test Teardown    Common Test Teardown For RRM
Suite Teardown    Common MutliBTS Suite Teardown For RRM
# Suite Teardown    Common Suite Teardown For RRM
Force Tags        CRT/CIT/CDRT     #Tag Item
# ...   PY27
...      RAN_5G                    #Product [RAN_5G]
# ...      CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
...      SBTS00/SBTS21B           # it is for auto trigger by ute cloud with the release
# ...      STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]


Test Timeout    60 minutes

*** Variables ***
#reduce global paramter as possilbe and automatically got from gNB or __init__
@{Ohter_Allow_Alarms}
${APC_Index}    -1
${PA_MinValue}           ${0}
${PA_MaxValue}           ${63}
${DEBUG_MODE}            ${TRUE}
# ${REMOTE_MODE}           ${TRUE}
&{dcap_info}    host=10.56.218.4    port=443    username=utfuser    password=utfadmin!
@{tti_condition_1}    dlLaAverageCqi.rrmAvgCqi    >    0
@{tti_condition_2}    dlLaAverageCqi.rrmInstCqi    >    0
@{tti_conditions_1}    or    ${tti_condition_1}    ${tti_condition_2}
&{tti_check_rules_1}         basic_rules=${tti_conditions_1}
&{tti_analysis_dict_1}       check_rules=${tti_check_rules_1}
@{tti_analysis_dict}     ${tti_analysis_dict_1}
${tti_path}      /home/ute/tti/BTS_20240625_184822_TTI.zip
# @{tti_condition_1}    lcrId    ==    1
# @{tti_condition_2}    numOfPrb    >    50
# @{tti_conditions_1}    or    ${tti_condition_1}    ${tti_condition_2}
# @{tti_stat_condition_1}     average    startSymbol    >    0
# @{tti_stat_condition_2}     max        numOfPrb       >    200
# @{tti_stat_conditions_1}    and        ${tti_stat_condition_1}    ${tti_stat_condition_2}
# &{tti_check_rules_1}         basic_rules=${tti_conditions_1}     statistics_rules=${tti_stat_conditions_1}
# &{tti_analysis_dict_1}       check_rules=${tti_check_rules_1}
*** Test Cases ***
Tti log trace
    [Documentation]    Tti log trace
    Capture Tti log with UTF
    Log To Console    \nStart Log Analysis
    ${result}=    Log Analysis    check    tti    ${tti_path}    ${tti_analysis_dict}
    Log To Console    \nAnalyze log: ${result}


*** Keywords ***
Capture Tti log with UTF
    [Arguments]    ${bts_index}=0
    Log To Console    start to capture tti
    ${nrcell_lst}    Create List    NRCELL_R-1    NRCELL_R-2
    ${dcap_argument}   Create Dictionary   nrCells=${nrcell_lst}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start    tti    product_type=gnb    bts_index=${bts_index}    cudu_index=${0}    dict_argument=${dict_argument}
    sleep    8s    reason=Waiting For TTI capture
    Log To Console    stopping tti and bip log with dcap_tool
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=gnb    bts_index=${0}    cudu_index=${0}
    Log To Console    stopped tti and bip log with dcap_tool
    Set Test Variable    ${tti_path}     ${local_file_path}
    Set Test Variable    ${log_path}     ${local_file_path}