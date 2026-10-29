*** Settings ***
Force Tags    PY36
Documentation     author: fengyi Liu
...               contact: feng.y.liu@nokia-sbell.com
...               squad group: mmw_SG_04

Library    String
Library    OperatingSystem
Resource    ./resources/894_A_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot


*** Variables ***
${MRBTS}           MRBTS-${tl.gnbs[0].instance_id}
${IPRT}            /TNLSVC-1/TNL-1/IPNO-1/IPRT-1
${IPADDRESS_ID}    2
${gateway}         192.85.1.17
${destIpAddr}      192.85.1.16
${dest_leng}       24
${errorMsg1}       It is required that there exist MOs IPADDRESSV4
${errorMsg2}       IPADDRESSV4.localIpPrefixLength

*** Test Case ***
[1]5GC001566-5GC000894_A_007_IP main routing table update failure (Interface route) for IPv4
    [Documentation]    Add a direct route to the main table for IPv4 and validation and activation should be failed
    [Tags]   CRT_21B   CRT_22R2
    [Setup]
    Check cell on air
    Create IPADDRESSV4-2 Table   gateway=${gateway}    dest_leng=${dest_leng}    IPADDRESS_ID=${IPADDRESS_ID}
    [Teardown]       CI_interface.Common Case Teardown

*** Keywords ***
Create IPADDRESSV4-2 Table
    [Arguments]    ${gateway}   ${dest_leng}    ${IPADDRESS_ID}    ${para_name}=staticRoutes
    ${conn}    Connect to DU
    BuiltIn.Log    \n Create IPADDRESSV4-2 Table \n    console=yes
    ${list_para}    Create IPADDRESSV4-2 parameters
    ...    gateway=${gateway}    dest_leng=${dest_leng}    IPADDRESS_ID=${IPADDRESS_ID}
    coam.perform_object_recommissioning
    ...    dist_name=${MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-${IPADDRESS_ID}
    ...    parameter=${list_para}    operation=create     skip_parameter_relation_errors=${True}
    ...    should_activate=${False}    connection=${conn}
    BuiltIn.Log    \n add route to list for ipv4 \n    console=yes
    ${get_managed_objects}=    coam.get_managed_objects    class_name=IPRT_A    connection=${conn}
    ${parameters}    get from dictionary    ${get_managed_objects}[0]    parameters
    ${staticRoutes_list}    get from dictionary    ${parameters}     staticRoutes
    FOR    ${staticRoute}    IN    @{staticRoutes_list}
         ${items}     Get Dictionary Items    ${staticRoute}
         Remove None value from Dictionary    items=${items}    staticRoute=${staticRoute}
    END
    ${new_dict}    create dictionary   destIpAddr=${destIpAddr}    destinationIpPrefixLength=${dest_leng}
    ...    gateway=${gateway}    preference=${1}
    append to list    ${staticRoutes_list}    ${new_dict}
    ${output}    coam.perform_parameter_recommissioning     dist_name=${MRBTS}${IPRT}
    ...                                        parameter=staticRoutes
    ...                                        operation=update
    ...                                        value=${staticRoutes_list}
    ...                                        skip_parameter_relation_errors=${TRUE}
    ...                                        should_activate=${False}
    ...                                        connection=${conn}
    Check error after add IPADDRESSV4-2    output=${output}
    [Teardown]    Disconnect from DU

Check cell on air
    BuiltIn.Log    \n Start to check Cell On Air \n    console=yes
    Cloud DU connect to gnb coam via ssl
    COAM Check GNB cell on air
    [Teardown]   COAM Teardown gnb connections

Create IPADDRESSV4-2 parameters
    [Arguments]    ${IPADDRESS_ID}    ${gateway}    ${dest_leng}
    ${dict_Method}    create dictionary    parameterName=ipAddressAllocationMethod    operation=update    value=MANUAL
    ${dict_IPV4id}    create dictionary    parameterName=ipAddressV4Id    operation=update    value=${IPADDRESS_ID}
    ${dict_Addr}    create dictionary    parameterName=localIpAddr    operation=update    value=${gateway}
    ${dict_PreLen}    create dictionary    parameterName=localIpPrefixLength    operation=update    value=${dest_leng}
    ${list_para}    create list    ${dict_Method}    ${dict_IPV4id}    ${dict_Addr}    ${dict_PreLen}
    [Return]    ${list_para}

Check error after add IPADDRESSV4-2
    [Arguments]    ${output}
    ${activate_result}    get from dictionary    ${output}    validationResult
    ${activate_result1}    get from dictionary    ${activate_result}    pdlValidationResult
    ${activate_result2}    get from dictionary    ${activate_result1}    logs
    ${activate_result3}    get from dictionary    ${activate_result2}    relationErrors
    ${activate_result4}    get from dictionary    ${activate_result3}[0]    feedback
    should contain    ${activate_result4}    ${errorMsg1}
    should contain    ${activate_result4}    ${errorMsg2}
