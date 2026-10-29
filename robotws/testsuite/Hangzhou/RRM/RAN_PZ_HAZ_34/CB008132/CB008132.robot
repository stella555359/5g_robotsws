# # @Time    : 2023/4/5 14:08
# # @Author  : Jian.1.Chen
# # @Email   : jian.1.chen@nokia-sbell.com
# # @File    : CB008132.robot
# # @Software: PyCharm
# # @Doc     : Some Description
# *** Settings ***
# Documentation
# ...    author: Chen Jian
# ...    contact: jian.1.chen@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_3_SG05
# ...    Feature CB008132 Multi-UE Qos Test
# 
# #Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup
# #...    AND     Close Iperf On Appserver And Control PC
# Suite Setup    robot_common_operations.Common Suite Setup
# Suite Teardown       robot_common_operations.Common Suite Teardown
# Test Setup          Run Keywords    robot_common_operations.Common Case Setup
# ...    AND          Connect to gnb coam via ssl
# Test Teardown       Run Keywords    robot_common_operations.Common Case Teardown
# ...    AND          Run Keyword And Ignore Error    COAM Teardown gnb connections
# Force Tags          CRT_TRUNK    PY36
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
# 
# 
# *** Variables ***
# # ALL PORTS
# @{ALL_PORTS}    45350    45352    45353    45364    45365    45363    45360    45361    45362    45370
# # special set on SBTS1970
# @{4UE_NAMES}    UE01    UE02    UE06    UE07
# @{7UE_NAMES}    UE01    UE02    UE03    UE04    UE05    UE06    UE07
# @{MCC_LIST}    262    262    460    1    460
# @{MNC_LIST}    3    3    1    1    2
# @{SST_LIST}    1    128    129    255    1
# @{SD_LIST}    13714341    11259375    1    1    11259375
# ${TWO_SLICE_50_DELTA}    ${CURDIR}/two_slice_50.json
# ${TWO_SLICE_25_DELTA}    ${CURDIR}/two_slice_25.json
# ${FIVE_SLICE_25_DELTA}    ${CURDIR}/five_slice_25.json
# ${FIVE_SLICE_50_DELTA}    ${CURDIR}/five_slice_50.json
# ${FIVE_SLICE_75_DELTA}    ${CURDIR}/five_slice_75.json
# ${FIVE_SLICE_2_25_DELTA}    ${CURDIR}/five_slice_2_25.json
# 
# *** Test Cases ***
# CB008132-C_1_Two Slice With Minquota 50 percent
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c01
#     Close Iperf On Appserver And Control PC
#     coam.perform_delta_recommissioning    delta_file=${TWO_SLICE_50_DELTA}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# #    Reboot Multi-UE
#     Multi-UE Start DL TCP    ${4UE_NAMES}
#     Sleep    200s    # To wait counters update already
#     ${counters}    Verify Slice PRB Counters Update Normal    # get counters and verify normal
#     ${sum_counters}    Evaluate    ${counters[0]}+${counters[1]}+${counters[2]}+${counters[3]}+${counters[4]}
#     ${counter0_quotient}    Evaluate    ${counters[0]}/${sum_counters}
#     ${counter1_quotient}    Evaluate    ${counters[1]}/${sum_counters}
#     Should Be True    0.47<${counter0_quotient}<0.52
#     Should Be True    0.47<${counter1_quotient}<0.52
# 
# #    Should Be True    0.9<${counter_quotient}<1.1
# #    ${rrm_slice}    Capture TTITrace Via Gnb_logs On Control PC    # get min slice from ttitrace and verify normal
# #    Should Be True    0.47<${rrm_slice[0]}<0.52
# #    Should Be True    0.47<${rrm_slice[1]}<0.52
#     [Teardown]    Multi-UE Stop DL TCP    # stop all dl tcp on control pc
# 
# CB008132-C_2_Two Slice With Minquota 25 percent
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c02
#     coam.perform_delta_recommissioning    delta_file=${TWO_SLICE_25_DELTA}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# #    Reboot Multi-UE
#     Multi-UE Start DL TCP    ${4UE_NAMES}
#     Sleep    200s    # To wait counters update already
#     ${counters}    Verify Slice PRB Counters Update Normal    # get counters and verify normal
#     ${sum_counters}    Evaluate    ${counters[0]}+${counters[1]}+${counters[2]}+${counters[3]}+${counters[4]}
#     ${counter0_quotient}    Evaluate    ${counters[0]}/${sum_counters}
#     ${counter1_quotient}    Evaluate    ${counters[1]}/${sum_counters}
#     Should Be True    0.64<${counter0_quotient}<0.68
#     Should Be True    0.32<${counter1_quotient}<0.35
# 
# #    ${rrm_slice}    Capture TTITrace Via Gnb_logs On Control PC    # get min slice from ttitrace and verify normal
# #    Should Be True    0.61<${rrm_slice[0]}<0.65
# #    Should Be True    0.34<${rrm_slice[1]}<0.38
#     [Teardown]    Multi-UE Stop DL TCP    # stop all dl tcp on control pc
# 
# CB008132-C_3_Five Slice With Same Minquota 25 percent
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c03
#     coam.perform_delta_recommissioning    delta_file=${FIVE_SLICE_25_DELTA}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# #    Reboot Multi-UE
#     Multi-UE Start DL TCP    ${7UE_NAMES}
#     Sleep    200s    # To wait counters update already
#     ${counters}    Verify Slice PRB Counters Update Normal    # get counters and verify normal
#     ${sum_counters}    Evaluate    ${counters[0]}+${counters[1]}+${counters[2]}+${counters[3]}+${counters[4]}
#     ${counter0_quotient}    Evaluate    ${counters[0]}/${sum_counters}
#     ${counter1_quotient}    Evaluate    ${counters[1]}/${sum_counters}
#     ${counter2_quotient}    Evaluate    ${counters[2]}/${sum_counters}
#     ${counter3_quotient}    Evaluate    ${counters[3]}/${sum_counters}
#     ${counter4_quotient}    Evaluate    ${counters[4]}/${sum_counters}
#     Should Be True    0.18<${counter0_quotient}<0.21
#     Should Be True    0.18<${counter1_quotient}<0.21
#     Should Be True    0.18<${counter2_quotient}<0.21
#     Should Be True    0.18<${counter3_quotient}<0.21
#     Should Be True    0.18<${counter4_quotient}<0.21
# 
# #    ${rrm_slice}    Capture TTITrace Via Gnb_logs On Control PC    # get min slice from ttitrace and verify normal
# #    Should Be True    0.19<${rrm_slice[0]}<0.21
# #    Should Be True    0.19<${rrm_slice[1]}<0.21
# #    Should Be True    0.19<${rrm_slice[2]}<0.21
# #    Should Be True    0.19<${rrm_slice[3]}<0.21
# #    Should Be True    0.19<${rrm_slice[4]}<0.21
#     [Teardown]    Multi-UE Stop DL TCP    # stop all dl tcp on control pc
# 
# CB008132-C_4_Five Slice With One Slice Minquota 50 percent
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c04
#     coam.perform_delta_recommissioning    delta_file=${FIVE_SLICE_50_DELTA}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# #    Reboot Multi-UE
#     Multi-UE Start DL TCP    ${7UE_NAMES}
#     Sleep    200s    # To wait counters update already
#     ${counters}    Verify Slice PRB Counters Update Normal    # get counters and verify normal
#     ${sum_counters}    Evaluate    ${counters[0]}+${counters[1]}+${counters[2]}+${counters[3]}+${counters[4]}
#     ${counter0_quotient}    Evaluate    ${counters[0]}/${sum_counters}
#     ${counter1_quotient}    Evaluate    ${counters[1]}/${sum_counters}
#     ${counter2_quotient}    Evaluate    ${counters[2]}/${sum_counters}
#     ${counter3_quotient}    Evaluate    ${counters[3]}/${sum_counters}
#     ${counter4_quotient}    Evaluate    ${counters[4]}/${sum_counters}
#     Should Be True    0.57<${counter0_quotient}<0.61
#     Should Be True    0.03<${counter1_quotient}<0.06
#     Should Be True    0.03<${counter2_quotient}<0.06
#     Should Be True    0.15<${counter3_quotient}<0.18
#     Should Be True    0.15<${counter4_quotient}<0.18
# 
# #    ${rrm_slice}    Capture TTITrace Via Gnb_logs On Control PC    # get min slice from ttitrace and verify normal
# #    Should Be True    0.55<${rrm_slice[0]}<0.59
# #    Should Be True    0.03<${rrm_slice[1]}<0.06
# #    Should Be True    0.03<${rrm_slice[2]}<0.06
# #    Should Be True    0.15<${rrm_slice[3]}<0.18
# #    Should Be True    0.15<${rrm_slice[4]}<0.18
#     [Teardown]    Multi-UE Stop DL TCP    # stop all dl tcp on control pc
# 
# CB008132-C_5_Five Slice With One Slice Minquota 75 percent
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c05
#     coam.perform_delta_recommissioning    delta_file=${FIVE_SLICE_75_DELTA}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# #    Reboot Multi-UE
#     Multi-UE Start DL TCP    ${7UE_NAMES}
#     Sleep    200s    # To wait counters update already
#     ${counters}    Verify Slice PRB Counters Update Normal    # get counters and verify normal
#     ${sum_counters}    Evaluate    ${counters[0]}+${counters[1]}+${counters[2]}+${counters[3]}+${counters[4]}
#     ${counter0_quotient}    Evaluate    ${counters[0]}/${sum_counters}
#     ${counter1_quotient}    Evaluate    ${counters[1]}/${sum_counters}
#     ${counter2_quotient}    Evaluate    ${counters[2]}/${sum_counters}
#     ${counter3_quotient}    Evaluate    ${counters[3]}/${sum_counters}
#     ${counter4_quotient}    Evaluate    ${counters[4]}/${sum_counters}
#     Should Be True    0.68<${counter0_quotient}<0.71
#     Should Be True    0.09<${counter1_quotient}<0.11
#     Should Be True    0.09<${counter2_quotient}<0.11
#     Should Be True    0.04<${counter3_quotient}<0.06
#     Should Be True    0.04<${counter4_quotient}<0.06
# 
# #    ${rrm_slice}    Capture TTITrace Via Gnb_logs On Control PC    # get min slice from ttitrace and verify normal
# #    Should Be True    0.67<${rrm_slice[0]}<0.70
# #    Should Be True    0.08<${rrm_slice[1]}<0.12
# #    Should Be True    0.08<${rrm_slice[2]}<0.12
# #    Should Be True    0.04<${rrm_slice[3]}<0.06
# #    Should Be True    0.04<${rrm_slice[4]}<0.06
#     [Teardown]    Multi-UE Stop DL TCP    # stop all dl tcp on control pc
# 
# CB008132-C_6_Five Slice With Two Slice Minquota 25 percent
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c06
#     coam.perform_delta_recommissioning    delta_file=${FIVE_SLICE_2_25_DELTA}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# #    Reboot Multi-UE
#     Multi-UE Start DL TCP    ${7UE_NAMES}
#     Sleep    200s    # To wait counters update already
#     ${counters}    Verify Slice PRB Counters Update Normal    # get counters and verify normal
#     ${sum_counters}    Evaluate    ${counters[0]}+${counters[1]}+${counters[2]}+${counters[3]}+${counters[4]}
#     ${counter0_quotient}    Evaluate    ${counters[0]}/${sum_counters}
#     ${counter1_quotient}    Evaluate    ${counters[1]}/${sum_counters}
#     ${counter2_quotient}    Evaluate    ${counters[2]}/${sum_counters}
#     ${counter3_quotient}    Evaluate    ${counters[3]}/${sum_counters}
#     ${counter4_quotient}    Evaluate    ${counters[4]}/${sum_counters}
#     Should Be True    0.24<${counter0_quotient}<0.26
#     Should Be True    0.24<${counter1_quotient}<0.26
#     Should Be True    0.15<${counter2_quotient}<0.17
#     Should Be True    0.15<${counter3_quotient}<0.17
#     Should Be True    0.15<${counter4_quotient}<0.17
# 
# #    ${rrm_slice}    Capture TTITrace Via Gnb_logs On Control PC    # get min slice from ttitrace and verify normal
# #    Should Be True    0.24<${rrm_slice[0]}<0.26
# #    Should Be True    0.24<${rrm_slice[1]}<0.26
# #    Should Be True    0.15<${rrm_slice[2]}<0.17
# #    Should Be True    0.15<${rrm_slice[3]}<0.17
# #    Should Be True    0.15<${rrm_slice[4]}<0.17
#     [Teardown]    Multi-UE Stop DL TCP    # stop all dl tcp on control pc
# 
# *** Keywords ***
# Close Iperf On Appserver And Control PC
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Connect to APPserver
#     FOR    ${port}    IN    @{ALL_PORTS}
#         Close the iperf process on APPserver    port=${port}
#     END
#     Connect to control pc enhanced    ue_index=1    cpc_ip=10.71.203.68    cpc_usrname=root    cpc_passwd=123456
#     csn.send_command    command=ps -ef | grep iperf | grep -v grep | awk '{print $2}' | xargs kill -9
#     ...    connection=cpc_1
# #    Connect to control pc enhanced    ue_index=2    cpc_ip=10.71.203.119    cpc_usrname=root    cpc_passwd=123456
# #    csn.send_command    command=ps -ef | grep iperf | grep -v grep | awk '{print $2}' | xargs kill -9
# #    ...    connection=cpc_2
# 
# Capture TTITrace Via Gnb_logs On Control PC
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Arguments]    ${ttitrace_file_path}=/home/ute/MMW_SG5/tti_trace.zip
#     ...    ${gnb_log_version}=gnb_logs_2.48
#     ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
#     ...    ${capture_time}=3
#     Connect to control pc enhanced    # default alia is cpc_0
#     csn.send_command    command=cd /cygdrive/c/${gnb_log_version} && rm -rf *.zip
#     ...    connection=cpc_0
#     csn.send_command    command=cd /cygdrive/c/${gnb_log_version} && ./gnb_logs.exe ${bts_host} -t ${capture_time} &
#     ...    connection=cpc_0
#     ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cpc_0
#     csn.send_command    command=cd /cygdrive/c/${gnb_log_version} && ls *.zip
#     ...    connection=cpc_0
#     ${zip_name}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cpc_0
#     ${zip_name}    Remove String    ${zip_name}    \n
#     csn.download_file    remote_path=/cygdrive/c/${gnb_log_version}/${zip_name}
#     ...                  local_path=${ttitrace_file_path}
#     ...                  connection=cpc_0
#     Sleep    5s
#     ${rrm_slice}    get_rrmslice_from_ttitrace    ${ttitrace_file_path}
#     ...    ${MCC_LIST}    ${MNC_LIST}    ${SST_LIST}    ${SD_LIST}
#     [Return]    ${rrm_slice}
#     [Teardown]    csn.disconnect    connection=cpc_0
# 
# Verify Slice PRB Counters Update Normal
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    special to get five slice counters, not common
#     ${prb_counters}    coam.get_pm_counters    counter_ids=M55910C00001    timeout=300    connection=GNB_OAM
#     ${slice1_prb}    Set Variable
#     ...    ${prb_counters['BTS']['MRBTS-${MRBTSID}']['NRBTS-${NRBTSID}']['NRCELL-1']['NRRESOURCEGROUP-1']['NCUPNRG']['M55910C00001']}
#     ${slice2_prb}    Set Variable
#     ...    ${prb_counters['BTS']['MRBTS-${MRBTSID}']['NRBTS-${NRBTSID}']['NRCELL-1']['NRRESOURCEGROUP-2']['NCUPNRG']['M55910C00001']}
#     ${slice3_prb}    Set Variable
#     ...    ${prb_counters['BTS']['MRBTS-${MRBTSID}']['NRBTS-${NRBTSID}']['NRCELL-1']['NRRESOURCEGROUP-3']['NCUPNRG']['M55910C00001']}
#     ${slice4_prb}    Set Variable
#     ...    ${prb_counters['BTS']['MRBTS-${MRBTSID}']['NRBTS-${NRBTSID}']['NRCELL-1']['NRRESOURCEGROUP-4']['NCUPNRG']['M55910C00001']}
#     ${slice5_prb}    Set Variable
#     ...    ${prb_counters['BTS']['MRBTS-${MRBTSID}']['NRBTS-${NRBTSID}']['NRCELL-1']['NRRESOURCEGROUP-5']['NCUPNRG']['M55910C00001']}
#     ${value1}    Get Latest Slice PRB Counters Average Value    ${slice1_prb}
#     ${value2}    Get Latest Slice PRB Counters Average Value    ${slice2_prb}
#     ${value3}    Get Latest Slice PRB Counters Average Value    ${slice3_prb}
#     ${value4}    Get Latest Slice PRB Counters Average Value    ${slice4_prb}
#     ${value5}    Get Latest Slice PRB Counters Average Value    ${slice5_prb}
#     @{values}    Create List    ${value1}    ${value2}    ${value3}    ${value4}    ${value5}
#     [Return]    @{values}
# 
# Get Latest Slice PRB Counters Average Value
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Arguments]    ${slice_prb_counters}
#     ${time_list}    Get Dictionary Keys    ${slice_prb_counters}
#     ${slice_counter}    Set Variable    ${slice_prb_counters['${time_list[-1]}']}
#     [Return]    ${slice_counter}
# 
# Reboot Multi-UE
#     [Documentation]    Reboot UEs With ADB
#     [Arguments]    ${cpc_ip}=${tl.ues[0].ssh_connection_details.addr}
#     ...    ${cpc_usrname}=${tl.ues[0].ssh_connection_details.username}
#     ...    ${cpc_passwd}=${tl.ues[0].ssh_connection_details.password}
#     Log to console    \n*****Reboot UEs*****
#     Connect to control pc enhanced    cpc_ip=${cpc_ip}
#     ...    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
#     # get UE number in init file
#     ${numberOfUe}    Get Length    ${tl.ues}
#     FOR    ${idex_ue}    IN RANGE    ${numberOfUe}
#         Log to console    \n*****reboot ue${idex_ue+1}*****
#         csn.send_command    command=adb -s ${tl.ues[${idex_ue}].serial_number} reboot    connection=cpc_0
#         sleep    1s
#     END
#     sleep    90s
