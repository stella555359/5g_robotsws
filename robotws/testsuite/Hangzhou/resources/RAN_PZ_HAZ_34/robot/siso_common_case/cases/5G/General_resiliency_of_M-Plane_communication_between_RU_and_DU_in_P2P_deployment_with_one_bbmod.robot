*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

*** Keywords ***
General_resiliency_of_M-Plane_communication_between_RU_and_DU_in_P2P_deployment_with_one_bbmod
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of the case is to on only one capacity card ENV,
    ...    one interface between CC1 and RU is down,M-plane communication is still alive,
    ...    resiliency can be worked rightly for M-plane and changed the link to CC1 another interface and RU
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 18.07.2019 - - Created
    ...    - 18.10.2024 - -https://jiradc.ext.net.nokia.com/browse/LEOPARD-2220
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]    ${ru_index}=1
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${bfd_1_interface}    get bfd interface via bfd id    ru_index=${ru_index}    bfd_id=TNL-2/IPAPP-1/BFD-1
    ${bfd_2_interface}    get bfd interface via bfd id    ru_index=${ru_index}    bfd_id=TNL-2/IPAPP-1/BFD-2
    ${default_gateway}    get ru gateway interface    ru_index=${ru_index}
    ${main_interface}    Set Variable If    '${default_gateway}'=='${bfd_1_interface}'
    ...    ${bfd_1_interface}    ${bfd_2_interface}
    ${bak_interface}    Set Variable If    '${default_gateway}'=='${bfd_1_interface}'
    ...    ${bfd_2_interface}    ${bfd_1_interface}
    ${mian_bfd_fault_id}    Set Variable If    '${default_gateway}'=='${bfd_1_interface}'    BFD-1    BFD-2
    ${bak_bfd_fault_id}    Set Variable If    '${default_gateway}'=='${bfd_1_interface}'    BFD-2    BFD-1
    operate interface and check Fault    ru_index=${ru_index}    default_gateway=${default_gateway}
    ...    main_interface=${main_interface}    bak_interface=${bak_interface}    bfd_id=${mian_bfd_fault_id}
    operate interface and check Fault    ru_index=${ru_index}    default_gateway=${default_gateway}
    ...    main_interface=${bak_interface}    bak_interface=${main_interface}    bfd_id=${bak_bfd_fault_id}
    # [Teardown]    Run keywords    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    # ...    AND   Commissioning SCF And Check On Air      scf_path=${Case_SCF_Path}
    # ...    AND   Selenium Logout And Close Browser

get bfd interface via bfd id
    [Arguments]    ${ru_index}=1    ${bfd_id}=TNL-2/IPAPP-1/BFD-1
    ${bfdDestIpAddr_bfd}    Get Single Parameter Value on WebUI    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/${bfd_id}
    ...    filter_param=Destination IP address for the BFD session
    @{split_bfd}    string.split string    ${bfdDestIpAddr_bfd}    separator=.
    ${bfd_interface}    get ru gateway interface    ru_index=${ru_index}
    ...    grep=${split_bfd}[0].${split_bfd}[1].${split_bfd}[2]
    [Return]    ${bfd_interface}

operate interface and check Fault
    [Arguments]    ${ru_index}=1    ${default_gateway}=eth2.s0.m0.1    ${main_interface}=eth2.s0.m0.1
    ...    ${bak_interface}=eth2.s1.m0.2    ${bfd_id}=BFD-1
    log to console    \n default interface: [${default_gateway}]
    log to console    \n down interface [${main_interface}] and Present fault ${bfd_id}
    operate interface in ru    ru_index=${ru_index}    interface=${main_interface}    operate=down
    ${ru_gateway_interface}    get ru gateway interface    ru_index=${ru_index}
    Should Contain    ${ru_gateway_interface}    ${bak_interface}
    Wait until keyword succeeds    3min    30s    Expect Fault Should Present    faultId=61605
    ...    configObjectName=${bfd_id}
    operate interface in ru    ru_index=${ru_index}    interface=${main_interface}    operate=up
    log to console    \n up interface [${main_interface}] and Absent fault ${bfd_id}
    ${ru_gateway_interface}    get ru gateway interface    ru_index=${ru_index}
    Should Contain    ${ru_gateway_interface}    ${default_gateway}
    Wait until keyword succeeds    3min    30s    Expect Fault Should Absent    faultId=61605
