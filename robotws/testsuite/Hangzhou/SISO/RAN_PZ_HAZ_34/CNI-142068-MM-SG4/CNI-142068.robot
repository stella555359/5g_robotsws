*** Settings ***
Documentation
...   author: zhichao.shu@nokia-sbell.com
...   contact: zhichao.shu@nokia-sbell.com

Suite Setup          Common Suit Setup

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CNI-142068-MM-SG4/Resource/CNI-142068_keywords.robot
*** Variables ***
${BTS_ID}                     ${tl.gnbs[0].instance_id}
${gnb_ip}                     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
@{cablink_list}    2    3
@{speed_values_list}    eCpri10    eCpri25
@{ru_serial_list}    EB2232R0689    EB2232R0703    EB2232R0707
*** Test Cases ***
[1]CNI-142068_01_BTS_shall_support_SFP_rate_selection_on_fronthaul_and_linkspeed_changed_in_loops
    [Setup]    Common Case Setup
    Online_Changing_cablink_linkspeed_in_loops    MAX_LOOP=${3}
    [Teardown]    Case Teardown
