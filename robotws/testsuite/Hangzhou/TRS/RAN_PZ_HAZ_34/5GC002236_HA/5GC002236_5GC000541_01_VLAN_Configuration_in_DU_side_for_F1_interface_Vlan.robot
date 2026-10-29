# *** Settings ***
# Force Tags    PY36
# Documentation
# ...   author: zheyuan.chen@nokia-sbell.com
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   Ethernet termination
# 
# Suite Setup       Suite Setup
# Suite Teardown    Suite Teardown
# 
# Resource          resources/trans_comm.robot
# Library           resources/HAkeywords.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variable ***
# ${File_Name}    541_01login.tcl
# 
# *** Test Cases ***
# [1]5GC002236_5GC000541_01_VLAN_Configuration_in_DU_side_for_F1_interface_Vlan
#     [Documentation]
#     ...   Test will check possibility to Vlan creation by VLAN Configuration in DU side for F1 interface for VLAN ID=1 and IPv4.
#     ...    -16.10.2020,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_21B    CRT_22R2
#     [Setup]    case setup
#     Check BTS Should Be Normal
#     Check add vlan ID like 0 or 4095 fail
#     Check add vlan Success
#     Send data packets through vlan
#     Check delete vlan Success
#     Send data packets
#     Check add vlan Success
#     Reset DU and wait until BTS be normal
#     Resend data packets through vlan
#     [Teardown]    case teardown
# 
# *** Keywords ***
# Check add vlan Success
#     Add vlan in WEB success
#     Add vlan IP
# 
# Send data packets through vlan
#     Log To Console    Send data packets through vlan
#     ${ping_result}    Ping    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
#     ...    password=${DU_OAM_SSH_PASSWORD}    desIP=${TESTCENTER_IP}    time=3s
#     should contain    ${ping_result}    ttl=
#     Wireshark contain vlan tag
# 
# Check delete vlan Success
#     Log To Console   delete vlan success
#     Rest Login DU
#     Delete vlan    BTS_ID=${BTS_ID}    VLANIF_ID=${VLANIF_ID}
#     [Teardown]    Rest Logout DU
# 
# Send data packets
#     Log To Console   Send data packets
#     ${ping_result}    Ping    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
#     ...    password=${DU_OAM_SSH_PASSWORD}    desIP=${CU_OAM_IP}    time=3s
#     should contain    ${ping_result}    ttl=
#     Wireshark contain no vlan tag
# 
# Resend data packets through vlan
#     Log To Console   Send data packets through vlan
#    ${ping_result}    Ping    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
#     ...    password=${DU_OAM_SSH_PASSWORD}    desIP=${TESTCENTER_IP}    time=3s
#     Wireshark contain vlan tag again
# 
# case setup
#     Log To Console    case setup
#     Login Testcenter    File_Name=${File_Name}
#     Rest Login DU
#     Delete vlan    BTS_ID=${BTS_ID}    VLANIF_ID=${VLANIF_ID}
#     [Teardown]    Rest Logout DU
# 
# case teardown
#     Log To Console    case teardown
#     Logout Testcenter
#     CI_interface.Common Case Teardown
# 
# Suite Setup
#     Setup Commission SCF
#     TRANS Common Setup
# 
# Suite Teardown
#     TRANS Common Teardown