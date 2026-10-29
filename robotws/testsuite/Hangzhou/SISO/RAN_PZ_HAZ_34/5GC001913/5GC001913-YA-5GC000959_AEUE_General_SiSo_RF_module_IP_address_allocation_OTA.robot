# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation    Suite description
# # #...   author: jiao.1.yang@nokia-sbell.com
# # #...   contact: jiao.1.yang@nokia-sbell.com
# # #...   squad group: MMW_SG_04
# # #
# # #Resource          resources/1913_commkeyword.robot
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # 
# # 
# # #*** Test Cases ***
# # #[1]5GC001913-YA-5GC000959_AEUE_General_SiSo_RF_module_IP_address_allocation_OTA
# # #    [Tags]    5GC001913    CRT_20B    CRT_TRUNK    5GC000856     5GC000959    5GC001591
# # #    [Documentation]
# # #    ...    history change, <date>,<who>,<what and how>
# # #    ...    -12.10.2020,jiao.1.yang@nokia-sbell.com,case draft
# # #    [Setup]
# # #    Step1: SSH RU
# # #    Step2: RU DU Ping
# # #    [Teardown]    CI_interface.Common Case Teardown
# # 
# # #*** Keywords ***
# # #Step1: SSH RU
# # #    [Arguments]      ${connection}=GNB_OAM
# # #    coam.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
# # #    ...      username=Nemuadmin
# # #    ...      password=nemuuser
# # #    ...      name=${connection}
# # #    Connect to Common Unit Master
# # #    Connect to RU With Allocated IP    ru_alias=RU    connection=${connection}
# # #
# # #Step2: RU DU Ping
# # #    Log To Console  Check connection between DU and RU OK
# # #    ${ping_ok_result}    RU Ping
# # #    should contain    ${ping_ok_result}    ttl=
