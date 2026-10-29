# *** Settings ***
# Force Tags    PY36
# Documentation
# ...   author: zheyuan.chen@nokia-sbell.com
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   Security for Ethernet Ports On RAU
# 
# Suite Setup       Suite Setup
# Suite Teardown    Suite Teardown
# 
# Resource   ./resources/trans_comm.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# 
# *** Test Cases ***
# [1]5GC002236_5GC000268_Security for Ethernet Ports on RAU
#     [Documentation]
#     ...    history change, <date>,<who>,<what and how>
#     ...    -28.09.2020,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_20B    CRT_TRUNK    5GC002236_268    CRT_21B
#     [Setup]
#     Check BTS Should Be Normal
#     Check connection between UTE and DU LMP OK
#     Change Ethernet port security enabled to true
#     Check connection between UTE and DU LMP NO
#     Check SSH connect success
#     Change Activate service account SSH to false
#     Check SSH connect fail
#     [Teardown]    case teardown
# 
# *** Keywords ***
# Check connection between UTE and DU LMP OK
#     Log To Console  Check connection between UTE and DU LMP OK
#     ${ping_ok_result}    Ping
#     should match regexp    ${ping_ok_result}    ttl=
# 
# Check connection between UTE and DU LMP NO
#     Log To Console  Check connection between UTE and DU LMP NO
#     ${ping_no_result}    Ping
#     should contain    ${ping_no_result}    100% packet loss
# 
# Check SSH connect success
#     Log To Console    Check SSH connect success
#     SSH connect sucess
# 
# Check SSH connect fail
#     Log To Console    Check SSH connect fail
#     SSH connect fail
# 
# case teardown
#     WEBUI Login
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
#     ...    filter_param=Ethernet port security enabled    abbr=ethernetPortSecurityEnabled    new_value=false
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
#     ...    filter_param=Activate service account SSH    abbr=actServiceAccountSsh    new_value=true
#     selenium_coam.validate_plan    timeout=30
#     selenium_coam.activate_plan    activate_plan_despite_errors=true
#     Du Check cell on air via WebUI without login
#     WEBUI Logout
#     CI_interface.Common Case Teardown
# 
# Suite Setup
#     TRANS Common Setup
# 
# Suite Teardown
#     TRANS Common Teardown
