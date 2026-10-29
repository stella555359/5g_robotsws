*** Settings ***
Documentation
...                 Author: Yue 2. Liu (NSB)
...                 Group: HGZ_SG5
...                 Contact: yue.2.liu@nokia-sbell.com

Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource            ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Library             taf/rfrl/csv4all/resources/utilities/utilities.py

*** Keywords ***
UUF4ALL Suite Setup
    [Arguments]    ${gnb_index}=0
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}

    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    ${stream}    get stream from version    ${Active_SW_version}
    ${Version_L}    String.Fetch From Left    string=${Active_SW_version}    marker=_
    ${active_sw}    Replace string using regexp
    ...    string=${Active_SW_version}    pattern=${Version_L}   replace_with=${stream}
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${source_sw}=    run keyword if    ${ute_env}    Get Source SW
    ...    ELSE    set variable    ${active_sw}
    ${target_sw}=    run keyword if  '${target_version}'=='${None}'  Get Target SW
    ...    ELSE  set variable  ${target_version}
    log to console    \nactive_sw: ${active_sw}
    log to console    \nsource_sw: ${source_sw}
    log to console    \ntarget_sw: ${target_sw}
    &{NODE1}    create dictionary    node_alias=gnb-0
    ...                              testline_object=${tl.gnbs[0]}
    ...                              source_sw=${source_sw}
    ...                              target_sw=${target_sw}
#    ...                              custom_allowed_alarms=${gnb0_CUSTOM_ALLOWED_ALARMS}
#    ...                              temporary_allowed_alarms=${gnb0_TEMPORARY_ALLOWED_ALARMS}
    @{NODES}    create list    ${NODE1}
    set suite variable    ${NODE1}
    set suite variable    ${NODES}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
