# *** Settings ***
# Force Tags    PY36
# Documentation     author: fengyi Liu
# ...               contact: feng.y.liu@nokia-sbell.com
# ...               squad group: mmw_SG_04
# 
# Library    String
# Library    OperatingSystem
# Library    ./resources/894_A_keywords.py
# Resource    ./resources/894_A_resource.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# Suite Teardown     CI_interface.Common Case Teardown
# 
# *** Variables ***
# ${MRBTS}             MRBTS-${tl.gnbs[0].instance_id}
# ${IPRT}              /TNLSVC-1/TNL-1/IPNO-1/IPRT-1
# ${ip_flag}           -4
# ${DEST_IPV4}          20.1.1.0
# 
# *** Test Cases ***
# [1]5GC001566-5GC000894_A_015_IP_rule_IP_routing_table_deletion_IPv4
#     [Documentation]    IPV4 routing table deletion
#     [Tags]    CRT_21B   CRT_22R2
#     [Setup]
#     Check cell on air
#     ${GATE_IPV4}    Get gateway
#     ${if_have_ipv4}    run keyword and return status    Check IPV4 route    dst_ip=${DEST_IPV4}    ip_flag=${ip_flag}
#     ...    DU_IP=${DU_IP}    gateway=${GATE_IPV4}
#     run keyword unless    ${if_have_ipv4}    add IPV4 and check    dst_ip=${DEST_IPV4}    ip_flag=${ip_flag}
#     ...    DU_IP=${DU_IP}    gateway=${GATE_IPV4}
#     Delete elements to list for ipv4
#     Check IPV4 not route    dst_ip=${DEST_IPV4}    ip_flag=${ip_flag}    DU_IP=${DU_IP}    gateway=${GATE_IPV4}
#     Reset gnb after delete ipve
#     Check IPV4 not route    dst_ip=${DEST_IPV4}    ip_flag=${ip_flag}    DU_IP=${DU_IP}    gateway=${GATE_IPV4}
#     [Teardown]       CI_interface.Common Case Teardown
# 
# 
# *** Keywords ***
# add IPV4 and check
#     [Arguments]    ${dst_ip}    ${ip_flag}    ${DU_IP}    ${gateway}
#     Add elements to list for ipv4
#     Check IPV4 route    dst_ip=${dst_ip}    ip_flag=${ip_flag}    DU_IP=${DU_IP}    gateway=${gateway}
# 
# Get gateway
#     ${conn}    Connect to DU
#     ${get_managed_objects}=    coam.get_managed_objects    class_name=IPRT_A    connection=${conn}
#     ${parameters}    get from dictionary    @{get_managed_objects}[0]    parameters
#     ${staticRoutes_list}    get from dictionary    ${parameters}     staticRoutes
#     ${gateway}    get from dictionary    @{staticRoutes_list}[0]    gateway
#     [Return]     ${gateway}
#     [Teardown]   Disconnect from DU
# 
# Check cell on air
#     BuiltIn.Log    \n Start to check Cell On Air \n    console=yes
#     Cloud DU connect to gnb coam via ssl
#     COAM Check GNB cell on air
#     [Teardown]   COAM Teardown gnb connections
# 
# Add elements to list for ipv4
#     [Arguments]    ${para_name}=staticRoutes
#     BuiltIn.Log    \n add elements to list for ipv4 \n    console=yes
#     ${conn}    Connect to DU
#     ${get_managed_objects}=    coam.get_managed_objects    class_name=IPRT_A    connection=${conn}
#     ${parameters}    set variable    ${None}
#     FOR    ${item}    IN    @{get_managed_objects}
#         ${parameters}    get from dictionary     ${item}    parameters
#         ${dist_name}    get from dictionary    ${item}    distName
#         ${flag}    run keyword and return status    should contain    ${dist_name}    TNLSVC
#         exit for loop if    ${flag}
#     END
#     ${staticRoutes_list}    get from dictionary    ${parameters}     staticRoutes
#     ${gateway}    get from dictionary    @{staticRoutes_list}[0]    gateway
#     FOR    ${staticRoute}    IN    @{staticRoutes_list}
#          ${items}     Get Dictionary Items    ${staticRoute}
#          Remove None value from Dictionary    items=${items}    staticRoute=${staticRoute}
#     END
#     ${new_dict}    create dictionary   destIpAddr=${DEST_IPV4}   destinationIpPrefixLength=${24}    gateway=${gateway}
#     ...    preference=${1}
#     append to list    ${staticRoutes_list}    ${new_dict}
#     coam.perform_parameter_recommissioning     dist_name=${MRBTS}${IPRT}
#     ...                                        parameter=staticRoutes
#     ...                                        operation=update
#     ...                                        value=${staticRoutes_list}
#     ...                                        skip_parameter_relation_errors=${True}
#     ...                                        should_activate=${True}
#     ...                                        connection=${conn}
#     [Teardown]    Disconnect from DU
# 
# Delete elements to list for ipv4
#     [Arguments]    ${para_name}=staticRoutes
#     BuiltIn.Log    \n delete elements to list for ipv4 \n    console=yes
#     ${conn}    Connect to DU
#     ${get_managed_objects}=    coam.get_managed_objects    class_name=IPRT_A    connection=${conn}
#     ${parameters}    get from dictionary    @{get_managed_objects}[0]    parameters
#     ${staticRoutes_list}    get from dictionary    ${parameters}     staticRoutes
#     FOR    ${staticRoute}    IN    @{staticRoutes_list}
#          ${items}     Get Dictionary Items    ${staticRoute}
#          Remove None value from Dictionary    items=${items}    staticRoute=${staticRoute}
#     END
#     FOR    ${item}    IN    @{staticRoutes_list}
#         ${ip_addr}    get from dictionary    ${item}    destIpAddr
#         run keyword if    '${DEST_IPV4}'=='${ip_addr}'    remove values from list    ${staticRoutes_list}    ${item}
#     END
# #    remove_from_list    ${staticRoutes_list}    index=1
#     coam.perform_parameter_recommissioning     dist_name=${MRBTS}${IPRT}
#     ...                                        parameter=staticRoutes
#     ...                                        operation=update
#     ...                                        value=${staticRoutes_list}
#     ...                                        skip_parameter_relation_errors=${True}
#     ...                                        should_activate=${True}
#     ...                                        connection=${conn}
#     [Teardown]    Disconnect from DU
# 
# Check IPV4 route
#     [Documentation]    Login gNB and check Route on gNB
#     [Arguments]    ${DU_IP}    ${ip_flag}    ${gateway}    ${dst_ip}   ${table}=main
#     ${rTable}=    getRTable    table=${table}
#     log    ${rTable}
#     ${result}=    Login and Send Command    commands=ip ${ip_flag} route list table ${rTable}
#     Log To Console    \n checking route on table 1${table}: ${result}
#     Should Match Regexp    ${result}    ${dst_ip}.*via.*${gateway} dev.*
#     [Return]      ${result}
# 
# Check IPV4 not route
#     [Documentation]    Login gNB and check Route on gNB
#     [Arguments]    ${DU_IP}    ${ip_flag}    ${gateway}    ${dst_ip}   ${table}=main
#     ${rTable}=    getRTable    table=${table}
#     log    ${rTable}
#     ${result}=    Login and Send Command    commands=ip ${ip_flag} route list table ${rTable}
#     Log To Console    \n checking route on table 1${table}: ${result}
#     Should Not Match Regexp     ${result}   ${dst_ip}.*via.*${gateway} dev.*metric 1
#     [Return]      ${result}
# 
# Login and Send Command
#     [Documentation]   Login gNB and execute commands on gNB
#     [Arguments]    ${commands}
#     ${connection}=    Connect to ASIK
#     ${result}=    csn.execute    command=${commands}    connection=${connection}
#     ${stdout}=    csn.Read Output    connection=${connection}
#     ${stderr}=    csn.Read Error    connection=${connection}
#     [Teardown]    csn.Disconnect    connection=${connection}
#     [Return]    ${result}
# 
# Reset gnb after delete ipve
#     [Timeout]  20 min
#     [Arguments]    ${timeout}=10 min
#     ${conn}    Connect to DU
#     coam.reset site    connection=${conn}
#     BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
#     wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${conn}
#     wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${conn}
#     [Teardown]    Disconnect from DU
