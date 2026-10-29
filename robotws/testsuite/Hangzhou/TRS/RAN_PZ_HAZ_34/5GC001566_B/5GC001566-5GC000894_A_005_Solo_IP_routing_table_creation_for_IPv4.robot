# #*** Settings ***
# #Force Tags    PY36
# #Documentation     author: fengyi Liu
# #...               contact: feng.y.liu@nokia-sbell.com
# #...               squad group: mmw_SG_04
# #
# #Library    String
# #Library    OperatingSystem
# #Library    ./resources/894_A_keywords.py
# #Resource    ./resources/894_A_resource.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# #
# #
# #*** Variables ***
# #${MRBTS}             MRBTS-${tl.gnbs[0].instance_id}
# #${IPRT}              /TNLSVC-1/TNL-1/IPNO-1/IPRT-1
# #${ip_flag}           -4
# #${1566_default_scf}  ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_10.1100_DU.xml
# #${DEST_IPV4}          20.1.1.0
# #${CURDIR_path}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}
# #
# #*** Test Cases ***
# #[1]5GC001566-5GC000894_A_005_Solo IP routing table creation for IPv4
# #    [Tags]      CRT_21B    CRT_22R2
# #    [Setup]
# #    Check cell on air
# #    ${GATE_IPV4}    Get gateway
# #    Add elements to list for ipv4
# #    log    ${GATE_IPV4}
# #    Check IPV4 route    dst_ip=${DEST_IPV4}    ip_flag=${ip_flag}    DU_IP=${DU_IP}    gateway=${GATE_IPV4}
# #    [Teardown]    run keywords   Recover the test ENV      AND     CI_interface.Common Case Teardown
# 
# #
# #*** Keywords ***
# #Get gateway
# #    ${conn}    Connect to DU
# #    ${get_managed_objects}=    coam.get_managed_objects    class_name=IPRT_A    connection=${conn}
# #    ${parameters}    get from dictionary    @{get_managed_objects}[0]    parameters
# #    ${staticRoutes_list}    get from dictionary    ${parameters}     staticRoutes
# #    ${gateway}    get from dictionary    @{staticRoutes_list}[0]    gateway
# #    [Return]     ${gateway}
# #    [Teardown]   Disconnect from DU
# #
# #Check cell on air
# #    BuiltIn.Log    \n Start to check Cell On Air \n    console=yes
# #    Cloud DU connect to gnb coam via ssl
# #    COAM Check GNB cell on air
# #    [Teardown]   COAM Teardown gnb connections
# #
# #Add elements to list for ipv4
# #    [Arguments]    ${para_name}=staticRoutes
# #    BuiltIn.Log    \n add elements to list for ipv4 \n    console=yes
# #    ${conn}    Connect to DU
# #    ${get_managed_objects}=    coam.get_managed_objects    class_name=IPRT_A    connection=${conn}
# #    ${parameters}    get from dictionary    @{get_managed_objects}[0]    parameters
# #    ${staticRoutes_list}    get from dictionary    ${parameters}     staticRoutes
# #    ${gateway}    get from dictionary    @{staticRoutes_list}[0]    gateway
# #    FOR    ${staticRoute}    IN    @{staticRoutes_list}
# #         ${items}     Get Dictionary Items    ${staticRoute}
# #         Remove None value from Dictionary    items=${items}    staticRoute=${staticRoute}
# #    END
# #    ${new_dict}    create dictionary   destIpAddr=20.1.1.0   destinationIpPrefixLength=${24}    gateway=${gateway}
# #    ...    preference=${1}
# #    append to list    ${staticRoutes_list}    ${new_dict}
# #    set to dictionary    ${parameters}    staticRoutes=${staticRoutes_list}
# #    log    ${parameters}
# #    set to dictionary    @{get_managed_objects}[0]    parameters=${parameters}
# #    log    @{get_managed_objects}[0]
# #    log    ${staticRoutes_list}
# #    coam.perform_parameter_recommissioning     dist_name=${MRBTS}${IPRT}
# #    ...                                        parameter=staticRoutes
# #    ...                                        operation=update
# #    ...                                        value=${staticRoutes_list}
# #    ...                                        skip_parameter_relation_errors=${True}
# #    ...                                        should_activate=${True}
# #    ...                                        connection=${conn}
# #    [Teardown]    Disconnect from DU
# #
# #Check IPV4 route
# #    [Documentation]    Login gNB and check Route on gNB
# #    [Arguments]    ${DU_IP}    ${ip_flag}    ${gateway}    ${dst_ip}   ${table}=main
# #    ${rTable}=    getRTable    table=${table}
# #    log    ${rTable}
# #    ${result}=              Login and Send Command    commands=ip ${ip_flag} route list table ${rTable}
# #    Log To Console          \n checking route on table 1${table}: ${result}
# #    Should Match Regexp     ${result}   ${dst_ip}.*via.*${gateway} dev.*
# #    [Return]      ${result}
# #
# #Login and Send Command
# #    [Documentation]   Login gNB and execute commands on gNB
# #    [Arguments]    ${commands}
# #    ${connection}=      Connect to ASIK
# #    ${result}=          csn.execute         command=${commands}         connection=${connection}
# #    ${stdout}=          csn.Read Output     connection=${connection}
# #    ${stderr}=          csn.Read Error      connection=${connection}
# #    [Teardown]          csn.Disconnect      connection=${connection}
# #    [Return]    ${result}
# #
# #Recover the test ENV
# #    [Timeout]  20 min
# #    [Arguments]    ${timeout}=10 min
# #    ${conn}    Connect to DU
# #    BuiltIn.Log    \n recover the test env \n    console=yes
# #    ${default_scf}    Get BTS Version And Perare SCF    CURDIR_path=${CURDIR_path}
# #    Connect to gnb coam via ssl    bts_host=${DU_IP}
# #    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${conn}
# #    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
# #    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${conn}
# #    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${conn}
# #    [Teardown]    Disconnect from DU
# #
# #Get BTS Version And Perare SCF
# #    [Arguments]    ${CURDIR_path}
# #    ${connection}    coam.connect_to    bts_host=${DU_IP}     name=GNB_OAM
# #    ${version}    coam.get_sw_version    connection=${connection}
# #    ${scf_name}   894_A_keywords.Covert_BTS_Version    version=${version}
# #    ${default_scf}    set variable    ${CURDIR_path}/${scf_name}
# #    log to console   ${default_scf}
# #    [Return]  ${default_scf}
# #    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
