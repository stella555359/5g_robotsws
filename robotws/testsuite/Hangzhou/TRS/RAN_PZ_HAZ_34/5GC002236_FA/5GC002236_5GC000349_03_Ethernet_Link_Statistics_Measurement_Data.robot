# *** Settings ***
# Force Tags    PY36
# Documentation
# ...   author: zheyuan.chen@nokia-sbell.com
# ...   contact: zheyuan.chen@nokia-sbell.com
# 
# Suite Setup       Suite Setup
# Suite Teardown    Suite Teardown
# 
# Resource    resources/trans_comm.robot
# Resource    resources/trans_pm.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library     taf.sbts.oam.coam.admin       WITH NAME    coam
# 
# *** Variable ***
# @{Normal_counter_id}    M51301C0     M51301C1     M51301C2    M51301C3
# ${File_Name}    M51301C4.tcl
# ${gNB_ip}            ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# 
# *** Test Cases ***
# [1]5GC002236_5GC000349_03_Ethernet_Link_Statistics_Measurement_Data
#     [Documentation]
#     ...    This test case is used to test product shall support TCP_UDP statistics
#     ...    -27.10.2020,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]     CRT_21B   CRT_22R2
#     [Setup]
#     Step1: Check BTS Should Be Normal
#     Check Normal Counters
#     Check EthIfInFrameError Counters       File_Name=${File_Name}
#     [Teardown]    CI_interface.Common Case Teardown
# 
# 
# *** Keywords ***
# Check Normal Counters
#     Log To Console    Check Normal Couneters
#     coam.connect_to    bts_host=${gNB_ip}     name=GNB_OAM
#     FOR    ${item}    IN    @{Normal_counter_id}
#          ${counter_dict}    coam.get_PM_counters       couter_ids=${item}       connection=GNB_OAM
#          ${values1}    get dictionary values    ${counter_dict}
#          ${values2}    get dictionary values    ${values1}[0]
#          ${values3}    get dictionary values    ${values2}[0]
#          ${values4}    get dictionary values    ${values3}[0]
#          ${values5}    get dictionary values    ${values4}[0]
#          ${values6}    get dictionary values    ${values5}[0]
#          ${values7}    get dictionary values    ${values6}[0]
# 
#          ${values9}    get dictionary values    ${values4}[1]
#          ${values0}    get dictionary values    ${values9}[0]
#          ${values11}    get dictionary values    ${values0}[0]
#          Run Keyword And Continue On Failure     should not be empty    int(@{values7}[-1]
#          Run Keyword And Continue On Failure     should not be empty    int(@{values11}[-1]
#     END
#     [Teardown]    Rest Logout DU           alias=GNB_OAM
# 
# Check EthIfInFrameError Counters
#     [Arguments]    ${File_Name}
#     Log To Console    Check EthIfInFrameError Counters
#     ${connection}    Connect to UTE
#     csn.Send Command  command=sudo tclsh ${CURDIR}/resources/${File_Name}    connection=${connection}
#     sleep    3min
#     Log To Console    Check counters
#     wait until keyword succeeds    2x   15min    check Error counters
#     [Teardown]    csn.disconnect   connection=${connection}
# 
# Connect to UTE
#     [Arguments]  ${hostname}=${UTE_ADDRESS}    ${username}=${UTE_USERNAME}    ${password}=${UTE_PASSWORD}
#     ${connection}    csn.Connect to     hostname=${hostname}    username=${username}    password=${password}  alias=UTE
#     [Return]   ${connection}
# 
# #check Error counters
# #    selenium_coam.Login    url=${DU_725_ip}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
# #    Log To Console  Login successfully...
# #    Run Keyword And Ignore Error      selenium_coam.Disable_Message_Box
# #    ${counter_dict}    selenium_coam.get_transport_counters    counter_id=M51301C4    full_path=TNL-1/ETHLK/ETHLK-3/ETHLK_stats/EthIfInFrameError
# #    ${values}    get dictionary values    ${counter_dict}
# #    should be true    int(@{values}[-1]) > 0
# #    [Teardown]    WEBUI Logout
# 
# check Error counters
#     coam.connect_to    bts_host=${gNB_ip}       name=GNB_OAM
#     ${counter_dict}    coam.get_PM_counters       couter_ids=M51301C4      connection=GNB_OAM
#     ${values1}    get dictionary values    ${counter_dict}
#     ${values2}    get dictionary values    ${values1}[0]
#     ${values3}    get dictionary values    ${values2}[0]
#     ${values4}    get dictionary values    ${values3}[0]
#     ${values5}    get dictionary values    ${values4}[1]
#     ${values6}    get dictionary values    ${values5}[0]
#     ${values7}    get dictionary values    ${values6}[0]
#     should be true    int(@{values7}[-1]) > 0
#     [Teardown]    Rest Logout DU           alias=GNB_OAM
# 
# Suite Setup
#     TRANS Common Setup
#     ${PM_FILE_LOCATION}   Set Variable  ${DU_PM_FILE_LOCATION}
#     Set Suite Variable  ${PM_FILE_LOCATION}
#     ${PM_FILE_PATTERN}   Set Variable  ${DU_PM_FILE_PATTERN}
#     Set Suite Variable  ${PM_FILE_PATTERN}
# 
# Suite Teardown
#     TRANS Common Teardown
