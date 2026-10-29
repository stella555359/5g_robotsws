*** Settings ***
Documentation    This is keywords for CB009576 cases
...              Please do not modify the file without notification to author
...              Author:yue.2.liu@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB008962_SG05/resource/CB008962_reource.robot

Library    snapshot_utilities.py   WITH NAME    snapshot_utilities
Library    CB009576_lib.py
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Variables    variables.py
*** Variables ***
${dcap_server_ip}      ${tl.gnbs[0].dcap.connection_details.addr}
${dcap_server_username}    ${tl.gnbs[0].dcap.connection_details.username}
${dcap_server_password}    ${tl.gnbs[0].dcap.connection_details.password}
${UPlane_port}    1234
*** Keywords ***

Capture 5G-L2-HI component trace
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.activate_internal_trace
    sleep    1min
    run keyword and ignore error    selenium_coam.configure_logging_agent
    ...    source_ip=${asik_addr}    dscp=0    uplane_destination=${dcap_server_ip}:${UPlane_port}
    sleep    10s
    selenium_coam.start_l2_hi_rlc_component_trace_and_return_result
    Check if pcap log exist
    run keyword and ignore error    selenium_coam.stop_component_trace    uplane_component_name=l2_ps
    selenium_coam.deactivate_internal_trace
    [Teardown]    selenium logout and close browser
Capture 5G-L2-LO component trace
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.activate_internal_trace
    sleep    1min
    run keyword and ignore error    selenium_coam.configure_logging_agent
    ...    source_ip=${asik_addr}    dscp=0    uplane_destination=${dcap_server_ip}:${UPlane_port}
    sleep    10s
    selenium_coam.start_l2_lo_component_trace_and_return_result
    Check if pcap log exist
    run keyword and ignore error    selenium_coam.stop_component_trace    uplane_component_name=l2_ps
    selenium_coam.deactivate_internal_trace
    [Teardown]    selenium logout and close browser
Capture 5G-L2-PS component trace
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.activate_internal_trace
    sleep    1min
    run keyword and ignore error    selenium_coam.configure_logging_agent
    ...    source_ip=${asik_addr}    dscp=0    uplane_destination=${dcap_server_ip}:${UPlane_port}
    sleep    10s
    selenium_coam.start_l2_ps_component_trace_and_return_result
    Check if pcap log exist
    run keyword and ignore error    selenium_coam.stop_component_trace    uplane_component_name=l2_ps
    selenium_coam.deactivate_internal_trace
    [Teardown]    selenium logout and close browser
Check if pcap log exist
    log to console    Check if pcap log exist
    csn.Connect To    hostname=${dcap_server_ip}
        ...    username=${dcap_server_username}
        ...    password=${dcap_server_password}
        ...    alias=dcap_server
    csn.send command    command=docker start udptracer    connection=dcap_server
    sleep    3min
    csn.send command    command=cd /sharedvolume/udptracer/_data/&&ls -l | grep pcap    connection=dcap_server
    ${pcap_file}=    csn.Read Output    connection=dcap_server
    ${len}    Get Length    ${pcap_file}
    should be true    ${len} > 0
    csn.send command    command=docker stop udptracer    connection=dcap_server
    csn.send command    command=rm -rf /sharedvolume/udptracer/_data/*    connection=dcap_server
    csn.disconnect     connection=dcap_server
CB009576-SR-L-CB010764_PRACH_noise_power_real_estimate_reported
    disable actPrachNoPreambleNoisePwrEst and check counters
    enable actPrachNoPreambleNoisePwrEst and check counters
disable actPrachNoPreambleNoisePwrEst and check counters
    Log to console    disable actPrachNoPreambleNoisePwrEst
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...   filter_param=Activate PRACH noise power estimate when no preamble
    ...   p_name=actPrachNoPreambleNoisePwrEst  value=false
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    ...   filter_param=NR UL Received Interference Power
    ...   p_name=miNrRip  value=5min
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...   filter_param=Activate NR UL Received Interference Power including thermal Noise measurement
    ...   p_name=actnrulripmeasurement  value=disabled
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
    sleep    15min
    Check UL Noise and Interference counter value with feature disable
    [Teardown]    selenium logout and close browser
enable actPrachNoPreambleNoisePwrEst and check counters
    Log to console    enable actPrachNoPreambleNoisePwrEst
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...   filter_param=Activate PRACH noise power estimate when no preamble
    ...   p_name=actPrachNoPreambleNoisePwrEst  value=true
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    ...   filter_param=NR UL Received Interference Power
    ...   p_name=miNrRip  value=5min
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...   filter_param=Activate NR UL Received Interference Power including thermal Noise measurement
    ...   p_name=actnrulripmeasurement  value=enabledWithPRACH_PUCCH_F1
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
    #sleep    15min
    Check UL Noise and Interference counter value with feature enable
    [Teardown]    selenium logout and close browser
Check UL Noise and Interference counter value with feature enable
    Log to console    Check UL Noise and Interference counter value with feature enable
    ${counter_time}    wait_for_quarters    num_quarters=1
    sleep    1min
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    &{dict_counter_values}    Create dictionary
    ${content}    Get PM Counter content via Webem    counter_id=M55360C01020
    ${time_list}    get dictionary keys   ${content}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
    ${counter_list}    create list
    ${M55360C01020}    Get PM Counter value via Webem with time    counter_id=M55360C01020    counter_time=${counter_time}
    ${M55360C01020}    Convert To Number    ${M55360C01020}
    append to list    ${counter_list}    ${M55360C01020}
    ${M55360C01021}    Get PM Counter value via Webem with time    counter_id=M55360C01021    counter_time=${counter_time}
    ${M55360C01021}    Convert To Number    ${M55360C01021}
    append to list    ${counter_list}    ${M55360C01021}
    ${M55360C01022}    Get PM Counter value via Webem with time    counter_id=M55360C01022    counter_time=${counter_time}
    ${M55360C01022}    Convert To Number    ${M55360C01022}
    append to list    ${counter_list}    ${M55360C01022}
    ${M55360C01023}    Get PM Counter value via Webem with time    counter_id=M55360C01023    counter_time=${counter_time}
    ${M55360C01024}    Get PM Counter value via Webem with time    counter_id=M55360C01024    counter_time=${counter_time}
    ${M55360C01024}    Convert To Number    ${M55360C01024}
    append to list    ${counter_list}    ${M55360C01024}
    ${M55360C01025}    Get PM Counter value via Webem with time    counter_id=M55360C01025    counter_time=${counter_time}
    ${M55360C01025}    Convert To Number    ${M55360C01025}
    append to list    ${counter_list}    ${M55360C01025}
    ${M55360C01026}    Get PM Counter value via Webem with time    counter_id=M55360C01026    counter_time=${counter_time}
    ${M55360C01026}    Convert To Number    ${M55360C01026}
    append to list    ${counter_list}    ${M55360C01026}
    ${M55360C01027}    Get PM Counter value via Webem with time    counter_id=M55360C01027    counter_time=${counter_time}
    ${M55360C01027}    Convert To Number    ${M55360C01027}
    append to list    ${counter_list}    ${M55360C01027}
    ${M55360C01028}    Get PM Counter value via Webem with time    counter_id=M55360C01028    counter_time=${counter_time}
    ${M55360C01028}    Convert To Number    ${M55360C01028}
    append to list    ${counter_list}    ${M55360C01028}
    ${M55360C01029}    Get PM Counter value via Webem with time    counter_id=M55360C01029    counter_time=${counter_time}
    ${M55360C01029}    Convert To Number    ${M55360C01029}
    append to list    ${counter_list}    ${M55360C01029}
    ${M55360C01030}    Get PM Counter value via Webem with time    counter_id=M55360C01030    counter_time=${counter_time}
    ${M55360C01030}    Convert To Number    ${M55360C01030}
    append to list    ${counter_list}    ${M55360C01030}
    ${M55360C01031}    Get PM Counter value via Webem with time    counter_id=M55360C01031    counter_time=${counter_time}
    ${M55360C01031}    Convert To Number    ${M55360C01031}
    append to list    ${counter_list}    ${M55360C01031}
    ${M55360C00020}    Get PM Counter value via Webem with time    counter_id=M55360C00020    counter_time=${counter_time}
    ${M55360C00020}    Convert To Number    ${M55360C00020}
    append to list    ${counter_list}    ${M55360C00020}
    ${M55360C00021}    Get PM Counter value via Webem with time    counter_id=M55360C00021    counter_time=${counter_time}
    ${M55360C00021}    Convert To Number    ${M55360C00021}
    append to list    ${counter_list}    ${M55360C00021}
    ${M55360C00022}    Get PM Counter value via Webem with time    counter_id=M55360C00022    counter_time=${counter_time}
    ${M55360C00022}    Convert To Number    ${M55360C00022}
    append to list    ${counter_list}    ${M55360C00022}
    ${M55360C00023}    Get PM Counter value via Webem with time    counter_id=M55360C00023    counter_time=${counter_time}
    ${M55360C00023}    Convert To Number    ${M55360C00023}
    append to list    ${counter_list}    ${M55360C00023}
    ${M55360C00024}    Get PM Counter value via Webem with time    counter_id=M55360C00024    counter_time=${counter_time}
    ${M55360C00024}    Convert To Number    ${M55360C00024}
    append to list    ${counter_list}    ${M55360C00024}
    ${M55360C00025}    Get PM Counter value via Webem with time    counter_id=M55360C00025    counter_time=${counter_time}
    ${M55360C00025}    Convert To Number    ${M55360C00025}
    append to list    ${counter_list}    ${M55360C00025}
    ${M55360C00026}    Get PM Counter value via Webem with time    counter_id=M55360C00026    counter_time=${counter_time}
    ${M55360C00026}    Convert To Number    ${M55360C00026}
    append to list    ${counter_list}    ${M55360C00026}
    ${M55360C00027}    Get PM Counter value via Webem with time    counter_id=M55360C00027    counter_time=${counter_time}
    ${M55360C00027}    Convert To Number    ${M55360C00027}
    append to list    ${counter_list}    ${M55360C00027}
    ${M55360C00028}    Get PM Counter value via Webem with time    counter_id=M55360C00028    counter_time=${counter_time}
    ${M55360C00028}    Convert To Number    ${M55360C00028}
    append to list    ${counter_list}    ${M55360C00028}
    ${M55360C00029}    Get PM Counter value via Webem with time    counter_id=M55360C00029    counter_time=${counter_time}
    ${M55360C00029}    Convert To Number    ${M55360C00029}
    append to list    ${counter_list}    ${M55360C00029}
    ${M55360C00030}    Get PM Counter value via Webem with time    counter_id=M55360C00030    counter_time=${counter_time}
    ${M55360C00030}    Convert To Number    ${M55360C00030}
    append to list    ${counter_list}    ${M55360C00030}
    ${M55360C00031}    Get PM Counter value via Webem with time    counter_id=M55360C00031    counter_time=${counter_time}
    ${M55360C00031}    Convert To Number    ${M55360C00031}
    append to list    ${counter_list}    ${M55360C00031}
    FOR    ${counter_value}    IN    @{counter_list}
        should be true    ${counter_value}>${-120}
        should be true    ${counter_value}<${-80}
    END
    [Teardown]    selenium logout and close browser
Check UL Noise and Interference counter value with feature disable
    Log to console    Check UL Noise and Interference counter value with feature disable
    ${counter_time}    wait_for_quarters    num_quarters=1
    sleep    1min
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${content_M55360C01020_old}=    Get PM Counter content via Webem    counter_id=M55360C01020
    ${len_M55360C01020_old}=    Get Length    ${content_M55360C01020_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C01020
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C01021_old}=    Get PM Counter content via Webem    counter_id=M55360C01021
    ${len_M55360C01021_old}=    Get Length    ${content_M55360C01021_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C01021
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C01022_old}=    Get PM Counter content via Webem    counter_id=M55360C01022
    ${len_M55360C01022_old}=    Get Length    ${content_M55360C01022_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C01022
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C01023_old}=    Get PM Counter content via Webem    counter_id=M55360C01023
    ${len_M55360C01023_old}=    Get Length    ${content_M55360C01023_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C01023
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C01024_old}=    Get PM Counter content via Webem    counter_id=M55360C01024
    ${len_M55360C01024_old}=    Get Length    ${content_M55360C01024_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C01024
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C01025_old}=    Get PM Counter content via Webem    counter_id=M55360C01025
    ${len_M55360C01025_old}=    Get Length    ${content_M55360C01025_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C01025
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C01026_old}=    Get PM Counter content via Webem    counter_id=M55360C01026
    ${len_M55360C01026_old}=    Get Length    ${content_M55360C01026_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C01026
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C01027_old}=    Get PM Counter content via Webem    counter_id=M55360C01027
    ${len_M55360C01027_old}=    Get Length    ${content_M55360C01027_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C01027
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C01028_old}=    Get PM Counter content via Webem    counter_id=M55360C01028
    ${len_M55360C01028_old}=    Get Length    ${content_M55360C01028_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C01028
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C01029_old}=    Get PM Counter content via Webem    counter_id=M55360C01029
    ${len_M55360C01029_old}=    Get Length    ${content_M55360C01029_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C01029
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C01030_old}=    Get PM Counter content via Webem    counter_id=M55360C01030
    ${len_M55360C01030_old}=    Get Length    ${content_M55360C01030_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C01030
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C01031_old}=    Get PM Counter content via Webem    counter_id=M55360C01031
    ${len_M55360C01031_old}=    Get Length    ${content_M55360C01031_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C01031
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C00020_old}=    Get PM Counter content via Webem    counter_id=M55360C00020
    ${len_M55360C00020_old}=    Get Length    ${content_M55360C00020_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C00020
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C00021_old}=    Get PM Counter content via Webem    counter_id=M55360C00021
    ${len_M55360C00021_old}=    Get Length    ${content_M55360C00021_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C00021
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C00022_old}=    Get PM Counter content via Webem    counter_id=M55360C00022
    ${len_M55360C00022_old}=    Get Length    ${content_M55360C00022_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C00022
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C00023_old}=    Get PM Counter content via Webem    counter_id=M55360C00023
    ${len_M55360C00023_old}=    Get Length    ${content_M55360C00023_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C00023
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C00024_old}=    Get PM Counter content via Webem    counter_id=M55360C00024
    ${len_M55360C00024_old}=    Get Length    ${content_M55360C00024_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C00024
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C00025_old}=    Get PM Counter content via Webem    counter_id=M55360C00025
    ${len_M55360C00025_old}=    Get Length    ${content_M55360C00025_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C00025
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C00026_old}=    Get PM Counter content via Webem    counter_id=M55360C00026
    ${len_M55360C00026_old}=    Get Length    ${content_M55360C00026_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C00026
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C00027_old}=    Get PM Counter content via Webem    counter_id=M55360C00027
    ${len_M55360C00027_old}=    Get Length    ${content_M55360C00027_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C00027
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C00028_old}=    Get PM Counter content via Webem    counter_id=M55360C00028
    ${len_M55360C00028_old}=    Get Length    ${content_M55360C00028_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C00028
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C00029_old}=    Get PM Counter content via Webem    counter_id=M55360C00029
    ${len_M55360C00029_old}=    Get Length    ${content_M55360C00029_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C00029
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C00030_old}=    Get PM Counter content via Webem    counter_id=M55360C00030
    ${len_M55360C00030_old}=    Get Length    ${content_M55360C00030_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C00030
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C00031_old}=    Get PM Counter content via Webem    counter_id=M55360C00031
    ${len_M55360C00031_old}=    Get Length    ${content_M55360C00031_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M55360C00031
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_M55360C01020_new}=    Get PM Counter content via Webem    counter_id=M55360C01020
    ${len_M55360C01020_new}=    Get Length    ${content_M55360C01020_new}
    Should Be True   ${len_M55360C01020_old}==${len_M55360C01020_new}
    ${content_M55360C01021_new}=    Get PM Counter content via Webem    counter_id=M55360C01021
    ${len_M55360C01021_new}=    Get Length    ${content_M55360C01021_new}
    Should Be True   ${len_M55360C01021_old}==${len_M55360C01021_new}
    ${content_M55360C01022_new}=    Get PM Counter content via Webem    counter_id=M55360C01022
    ${len_M55360C01022_new}=    Get Length    ${content_M55360C01022_new}
    Should Be True   ${len_M55360C01022_old}==${len_M55360C01022_new}
    ${content_M55360C01023_new}=    Get PM Counter content via Webem    counter_id=M55360C01023
    ${len_M55360C01023_new}=    Get Length    ${content_M55360C01023_new}
    Should Be True   ${len_M55360C01023_old}==${len_M55360C01023_new}
    ${content_M55360C01024_new}=    Get PM Counter content via Webem    counter_id=M55360C01024
    ${len_M55360C01024_new}=    Get Length    ${content_M55360C01024_new}
    Should Be True   ${len_M55360C01024_old}==${len_M55360C01024_new}
    ${content_M55360C01025_new}=    Get PM Counter content via Webem    counter_id=M55360C01025
    ${len_M55360C01025_new}=    Get Length    ${content_M55360C01025_new}
    Should Be True   ${len_M55360C01025_old}==${len_M55360C01025_new}
    ${content_M55360C01026_new}=    Get PM Counter content via Webem    counter_id=M55360C01026
    ${len_M55360C01026_new}=    Get Length    ${content_M55360C01026_new}
    Should Be True   ${len_M55360C01026_old}==${len_M55360C01026_new}
    ${content_M55360C01027_new}=    Get PM Counter content via Webem    counter_id=M55360C01027
    ${len_M55360C01027_new}=    Get Length    ${content_M55360C01027_new}
    Should Be True   ${len_M55360C01027_old}==${len_M55360C01027_new}
    ${content_M55360C01028_new}=    Get PM Counter content via Webem    counter_id=M55360C01028
    ${len_M55360C01028_new}=    Get Length    ${content_M55360C01028_new}
    Should Be True   ${len_M55360C01028_old}==${len_M55360C01028_new}
    ${content_M55360C01029_new}=    Get PM Counter content via Webem    counter_id=M55360C01029
    ${len_M55360C01029_new}=    Get Length    ${content_M55360C01029_new}
    Should Be True   ${len_M55360C01029_old}==${len_M55360C01029_new}
    ${content_M55360C01030_new}=    Get PM Counter content via Webem    counter_id=M55360C01030
    ${len_M55360C01030_new}=    Get Length    ${content_M55360C01030_new}
    Should Be True   ${len_M55360C01030_old}==${len_M55360C01030_new}
    ${content_M55360C01031_new}=    Get PM Counter content via Webem    counter_id=M55360C01031
    ${len_M55360C01031_new}=    Get Length    ${content_M55360C01031_new}
    Should Be True   ${len_M55360C01031_old}==${len_M55360C01031_new}
    ${content_M55360C00020_new}=    Get PM Counter content via Webem    counter_id=M55360C00020
    ${len_M55360C00020_new}=    Get Length    ${content_M55360C00020_new}
    Should Be True   ${len_M55360C00020_old}==${len_M55360C00020_new}
    ${content_M55360C00021_new}=    Get PM Counter content via Webem    counter_id=M55360C00021
    ${len_M55360C00021_new}=    Get Length    ${content_M55360C00021_new}
    Should Be True   ${len_M55360C00021_old}==${len_M55360C00021_new}
    ${content_M55360C00022_new}=    Get PM Counter content via Webem    counter_id=M55360C00022
    ${len_M55360C00022_new}=    Get Length    ${content_M55360C00022_new}
    Should Be True   ${len_M55360C00022_old}==${len_M55360C00022_new}
    ${content_M55360C00023_new}=    Get PM Counter content via Webem    counter_id=M55360C00023
    ${len_M55360C00023_new}=    Get Length    ${content_M55360C00023_new}
    Should Be True   ${len_M55360C00023_old}==${len_M55360C00023_new}
    ${content_M55360C00024_new}=    Get PM Counter content via Webem    counter_id=M55360C00024
    ${len_M55360C00024_new}=    Get Length    ${content_M55360C00024_new}
    Should Be True   ${len_M55360C00024_old}==${len_M55360C00024_new}
    ${content_M55360C00025_new}=    Get PM Counter content via Webem    counter_id=M55360C00025
    ${len_M55360C00025_new}=    Get Length    ${content_M55360C00025_new}
    Should Be True   ${len_M55360C00025_old}==${len_M55360C00025_new}
    ${content_M55360C00026_new}=    Get PM Counter content via Webem    counter_id=M55360C00026
    ${len_M55360C00026_new}=    Get Length    ${content_M55360C00026_new}
    Should Be True   ${len_M55360C00026_old}==${len_M55360C00026_new}
    ${content_M55360C00027_new}=    Get PM Counter content via Webem    counter_id=M55360C00027
    ${len_M55360C00027_new}=    Get Length    ${content_M55360C00027_new}
    Should Be True   ${len_M55360C00027_old}==${len_M55360C00027_new}
    ${content_M55360C00028_new}=    Get PM Counter content via Webem    counter_id=M55360C00028
    ${len_M55360C00028_new}=    Get Length    ${content_M55360C00028_new}
    Should Be True   ${len_M55360C00028_old}==${len_M55360C00028_new}
    ${content_M55360C00029_new}=    Get PM Counter content via Webem    counter_id=M55360C00029
    ${len_M55360C00029_new}=    Get Length    ${content_M55360C00029_new}
    Should Be True   ${len_M55360C00029_old}==${len_M55360C00029_new}
    ${content_M55360C00030_new}=    Get PM Counter content via Webem    counter_id=M55360C00030
    ${len_M55360C00030_new}=    Get Length    ${content_M55360C00030_new}
    Should Be True   ${len_M55360C00030_old}==${len_M55360C00030_new}
    ${content_M55360C00031_new}=    Get PM Counter content via Webem    counter_id=M55360C00031
    ${len_M55360C00031_new}=    Get Length    ${content_M55360C00031_new}
    Should Be True   ${len_M55360C00031_old}==${len_M55360C00031_new}
    [Teardown]    selenium logout and close browser
Check Snapshot Log Files
    log to console    start to capture snapshot
    coam.get_snapshot    target_file_name=${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/gnb_coam_snapshot/snapshot.zip
    ...    connection=GNB_OAM
    sleep    1min
    log to console    check L2_LO_PATTERN
    ${file_list}    snapshot_utilities.check_if_file_is_present_in_snapshot
    ...    pattern=${L2_LO_PATTERN}
    ...    file_name=${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/gnb_coam_snapshot/snapshot.zip
    ...    output_dir=/home/ute/TA/output
    ${file_num}    Get Length    ${file_list}
    Should be equal    ${file_num}    ${2}
    log to console    check L2_PS_PATTERN
    ${file_list}    snapshot_utilities.check_if_file_is_present_in_snapshot
    ...    pattern=${L2_PS_PATTERN}
    ...    file_name=${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/gnb_coam_snapshot/snapshot.zip
    ...    output_dir=/home/ute/TA/output
    ${file_num}    Get Length    ${file_list}
    Should be equal    ${file_num}    ${2}
    log to console    check L2_HI_DU_PATTERN
    ${file_list}    snapshot_utilities.check_if_file_is_present_in_snapshot
    ...    pattern=${L2_HI_DU_PATTERN}
    ...    file_name=${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/gnb_coam_snapshot/snapshot.zip
    ...    output_dir=/home/ute/TA/output
    ${file_num}    Get Length    ${file_list}
    Should be equal    ${file_num}    ${2}
    log to console    check L2_HI_CU_PATTERN
    ${file_list}    snapshot_utilities.check_if_file_is_present_in_snapshot
    ...    pattern=${L2_HI_CU_PATTERN}
    ...    file_name=${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/gnb_coam_snapshot/snapshot.zip
    ...    output_dir=/home/ute/TA/output
    ${file_num}    Get Length    ${file_list}
    Should be equal    ${file_num}    ${2}
Activation_of_Energy_Consumption_Measurement_collection_via_WebEM
    check Energy Consumption counter enable
    check Energy Consumption counter disable
    [Teardown]    Set Power meter    power_meter=true
check Energy Consumption counter enable
    log to console    check Energy Consumption counter enable
    Set Power meter    power_meter=true
    ${counter_time}    wait_for_quarters    num_quarters=1
    sleep    1min
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    log to console    start check M40002 counters
    ${content_2C0}=    Get PM Counter content via Webem    counter_id=M40002C0
    ${M40002C0_value}=    Get PM Counter value via Webem with time
    ...    counter_id=M40002C0
    ...    counter_time=${counter_time}
    ${content_2C1}=    Get PM Counter content via Webem    counter_id=M40002C1
    ${M40002C1_value}=    Get PM Counter value via Webem with time
    ...    counter_id=M40002C1
    ...    counter_time=${counter_time}
    ${content_2C2}=    Get PM Counter content via Webem    counter_id=M40002C2
    ${M40002C2_value}=    Get PM Counter value via Webem with time
    ...    counter_id=M40002C2
    ...    counter_time=${counter_time}
    Should Be True    ${M40002C0_value}>${0}
    Should Be True    ${M40002C1_value}>${0}
    Should Be True    ${M40002C2_value}>${0}
    log to console    start check M40003 counters
    ${content_3C0}=    Get PM Counter content via Webem    counter_id=M40003C0
    ${M40003C0_value}=    Get PM Counter value via Webem with time
    ...    counter_id=M40003C0
    ...    counter_time=${counter_time}
    ${content_3C1}=    Get PM Counter content via Webem    counter_id=M40003C1
    ${M40003C1_value}=    Get PM Counter value via Webem with time
    ...    counter_id=M40003C1
    ...    counter_time=${counter_time}
    ${content_3C2}=    Get PM Counter content via Webem    counter_id=M40003C2
    ${M40003C2_value}=    Get PM Counter value via Webem with time
    ...    counter_id=M40003C2
    ...    counter_time=${counter_time}
    ${content_3C3}=    Get PM Counter content via Webem    counter_id=M40003C3
    ${M40003C3_value}=    Get PM Counter value via Webem with time
    ...    counter_id=M40003C3
    ...    counter_time=${counter_time}
    ${content_3C4}=    Get PM Counter content via Webem    counter_id=M40003C4
    ${M40003C4_value}=    Get PM Counter value via Webem with time
    ...    counter_id=M40003C4
    ...    counter_time=${counter_time}
    ${content_3C5}=    Get PM Counter content via Webem    counter_id=M40003C5
    ${M40003C5_value}=    Get PM Counter value via Webem with time
    ...    counter_id=M40003C5
    ...    counter_time=${counter_time}
    Should Be True    ${M40003C0_value}>${0}
    Should Be True    ${M40003C1_value}>${0}
    Should Be True    ${M40003C2_value}>${0}
    Should Be True    ${M40003C3_value}>${0}
    Should Be True    ${M40003C4_value}>${0}
    Should Be True    ${M40003C5_value}>${0}
    log to console    start check M40004 counters
    ${content_4C0}=    Get PM Counter content via Webem    counter_id=M40004C0
    ${M40004C0_value}=    Get PM Counter value via Webem with time
    ...    counter_id=M40004C0
    ...    counter_time=${counter_time}
    ${content_4C1}=    Get PM Counter content via Webem    counter_id=M40004C1
    ${M40004C1_value}=    Get PM Counter value via Webem with time
    ...    counter_id=M40004C1
    ...    counter_time=${counter_time}
    ${content_4C2}=    Get PM Counter content via Webem    counter_id=M40004C2
    ${M40004C2_value}=    Get PM Counter value via Webem with time
    ...    counter_id=M40004C2
    ...    counter_time=${counter_time}
    ${content_4C3}=    Get PM Counter content via Webem    counter_id=M40004C3
    ${M40004C3_value}=    Get PM Counter value via Webem with time
    ...    counter_id=M40004C3
    ...    counter_time=${counter_time}
    ${content_4C4}=    Get PM Counter content via Webem    counter_id=M40004C4
    ${M40004C4_value}=    Get PM Counter value via Webem with time
    ...    counter_id=M40004C4
    ...    counter_time=${counter_time}
    ${content_4C5}=    Get PM Counter content via Webem    counter_id=M40004C5
    ${M40004C5_value}=    Get PM Counter value via Webem with time
    ...    counter_id=M40004C5
    ...    counter_time=${counter_time}
    Should Be True    ${M40004C0_value}>${0}
    Should Be True    ${M40004C1_value}>${0}
    Should Be True    ${M40004C2_value}>${0}
    Should Be True    ${M40004C3_value}>${0}
    Should Be True    ${M40004C4_value}>${0}
    Should Be True    ${M40004C5_value}>${0}
    [Teardown]    selenium logout and close browser
check Energy Consumption counter disable
    log to console    check Energy Consumption counter disable
    Set Power meter    power_meter=false
    ${counter_time}    wait_for_quarters    num_quarters=1
    sleep    1min
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    log to console    start check M40002 counters
    ${content_2C0_old}=    Get PM Counter content via Webem    counter_id=M40002C0
    ${len_2C0_old}=    Get Length    ${content_2C0_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M40002C0
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_2C1_old}=    Get PM Counter content via Webem    counter_id=M40002C1
    ${len_2C1_old}=    Get Length    ${content_2C1_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M40002C1
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_2C2_old}=    Get PM Counter content via Webem    counter_id=M40002C2
    ${len_2C2_old}=    Get Length    ${content_2C2_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M40002C2
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    log to console    start check M40003 counters
    ${content_3C0_old}=    Get PM Counter content via Webem    counter_id=M40003C0
    ${len_3C0_old}=    Get Length    ${content_3C0_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M40003C0
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_3C1_old}=    Get PM Counter content via Webem    counter_id=M40003C1
    ${len_3C1_old}=    Get Length    ${content_3C1_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M40003C1
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_3C2_old}=    Get PM Counter content via Webem    counter_id=M40003C2
    ${len_3C2_old}=    Get Length    ${content_3C2_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M40003C2
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_3C3_old}=    Get PM Counter content via Webem    counter_id=M40003C3
    ${len_3C3_old}=    Get Length    ${content_3C3_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M40003C3
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_3C4_old}=    Get PM Counter content via Webem    counter_id=M40003C4
    ${len_3C4_old}=    Get Length    ${content_3C4_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M40003C4
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_3C5_old}=    Get PM Counter content via Webem    counter_id=M40003C5
    ${len_3C5_old}=    Get Length    ${content_3C5_old}
    ${status}    run keyword and return status
    ...     Get PM Counter value via Webem with time
    ...    counter_id=M40003C5
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    log to console    start check M40004 counters
    ${content_4C0_old}=    Get PM Counter content via Webem    counter_id=M40004C0
    ${len_4C0_old}=    Get Length    ${content_4C0_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M40004C0
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_4C1_old}=    Get PM Counter content via Webem    counter_id=M40004C1
    ${len_4C1_old}=    Get Length    ${content_4C1_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M40004C1
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_4C2_old}=    Get PM Counter content via Webem    counter_id=M40004C2
    ${len_4C2_old}=    Get Length    ${content_4C2_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M40004C2
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_4C3_old}=    Get PM Counter content via Webem    counter_id=M40004C3
    ${len_4C3_old}=    Get Length    ${content_4C3_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M40004C3
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_4C4_old}=    Get PM Counter content via Webem    counter_id=M40004C4
    ${len_4C4_old}=    Get Length    ${content_4C4_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M40004C4
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    ${content_4C5_old}=    Get PM Counter content via Webem    counter_id=M40004C5
    ${len_4C5_old}=    Get Length    ${content_4C5_old}
    ${status}    run keyword and return status
    ...    Get PM Counter value via Webem with time
    ...    counter_id=M40004C5
    ...    counter_time=${counter_time}
    Should Be True   ${status}==${FALSE}
    sleep    15min
    log to console    start check M40002 counters
    ${content_2C0_new}=    Get PM Counter content via Webem    counter_id=M40002C0
    ${len_2C0_new}=    Get Length    ${content_2C0_new}
    Should Be True   ${len_2C0_old}==${len_2C0_new}
    ${content_2C1_new}=    Get PM Counter content via Webem    counter_id=M40002C1
    ${len_2C1_new}=    Get Length    ${content_2C1_new}
    Should Be True   ${len_2C1_new}==${len_2C1_old}
    ${content_2C2_new}=    Get PM Counter content via Webem    counter_id=M40002C2
    ${len_2C2_new}=    Get Length    ${content_2C2_new}
    Should Be True   ${len_2C2_new}==${len_2C2_old}
    log to console    start check M40003 counters
    ${content_3C0_new}=    Get PM Counter content via Webem    counter_id=M40003C0
    ${len_3C0_new}=    Get Length    ${content_3C0_new}
    Should Be True   ${len_3C0_new}==${len_3C0_old}
    ${content_3C1_new}=    Get PM Counter content via Webem    counter_id=M40003C1
    ${len_3C1_new}=    Get Length    ${content_3C1_new}
    Should Be True   ${len_3C1_new}==${len_3C1_old}
    ${content_3C2_new}=    Get PM Counter content via Webem    counter_id=M40003C2
    ${len_3C2_new}=    Get Length    ${content_3C2_new}
    Should Be True   ${len_3C2_new}==${len_3C2_old}
    ${content_3C3_new}=    Get PM Counter content via Webem    counter_id=M40003C3
    ${len_3C3_new}=    Get Length    ${content_3C3_new}
    Should Be True   ${len_3C3_new}==${len_3C3_old}
    ${content_3C4_new}=    Get PM Counter content via Webem    counter_id=M40003C4
    ${len_3C4_new}=    Get Length    ${content_3C4_new}
    Should Be True   ${len_3C4_new}==${len_3C4_old}
    ${content_3C5_new}=    Get PM Counter content via Webem    counter_id=M40003C5
    ${len_3C5_new}=    Get Length    ${content_3C5_new}
    Should Be True   ${len_3C5_new}==${len_3C5_old}
    log to console    start check M40004 counters
    ${content_4C0_new}=    Get PM Counter content via Webem    counter_id=M40004C0
    ${len_4C0_new}=    Get Length    ${content_4C0_new}
    Should Be True   ${len_4C0_new}==${len_4C0_old}
    ${content_4C1_new}=    Get PM Counter content via Webem    counter_id=M40004C1
    ${len_4C1_new}=    Get Length    ${content_4C1_new}
    Should Be True   ${len_4C1_new}==${len_4C1_old}
    ${content_4C2_new}=    Get PM Counter content via Webem    counter_id=M40004C2
    ${len_4C2_new}=    Get Length    ${content_4C2_new}
    Should Be True   ${len_4C2_new}==${len_4C2_old}
    ${content_4C3_new}=    Get PM Counter content via Webem    counter_id=M40004C3
    ${len_4C3_new}=    Get Length    ${content_4C3_new}
    Should Be True   ${len_4C3_new}==${len_4C3_old}
    ${content_4C4_new}=    Get PM Counter content via Webem    counter_id=M40004C4
    ${len_4C4_new}=    Get Length    ${content_4C4_new}
    Should Be True   ${len_4C4_new}==${len_4C4_old}
    ${content_4C5_new}=    Get PM Counter content via Webem    counter_id=M40004C5
    ${len_4C5_new}=    Get Length    ${content_4C5_new}
    Should Be True   ${len_4C5_new}==${len_4C5_old}
    [Teardown]    selenium logout and close browser
Get PM Counter value via Webem with time
    [Arguments]    ${counter_id}    ${counter_time}   ${dist_name}=${None}    ${counter_type}=BTS
    ...    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem    counter_id=${counter_id}   dist_name=${dist_name}
    ...     counter_type=${counter_type}    full_path=${full_path}
    ${STRING_VAR}    get_from_dictionary    ${content}    ${counter_time}
    ${INT_VAR}    Convert To Integer    ${STRING_VAR}
    [Return]    ${INT_VAR}
