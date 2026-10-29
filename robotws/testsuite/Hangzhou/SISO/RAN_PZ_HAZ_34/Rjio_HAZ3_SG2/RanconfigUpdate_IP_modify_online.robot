# *** Settings ***
# Suite Setup          Dedicate_Suite_Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# #Test Timeout         100 min
# 
# #Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/Rjio_HAZ3_SG2/Resources/made_variable.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Library    taf.analyzer.pcap     WITH NAME    pcap
# 
# Force Tags
# 
# *** Variables ***
# # ${if_commissioning}    False
# # daos${pcap_file}    /home/ute/dtt/ranConfig.pcap
# ${ranConfig_filter}    ngap.procedureCode == 35
# 
# *** Test Cases ***
# [1]Rjio_AQQJ_15_Ng_Handling_RAN_Configuration_Update
#     [Documentation]    To check Rjio_AQQJ_15_Ng_Handling_RAN_Configuration_Update
#     [Tags]
#     [Timeout]    2h
#     @{cell_id_list}    Create List
#     ${cell_id_list}  Get All Cell Id
#     Set Test variable    ${cell_id_list}
#     Start to collect NGlogs on gNB
#     Set_all_Cells_online_to_Locked
#     Wait Until Keyword Succeeds    5 min    5 sec    Check_all_Cells_online_should_be_Locked
#     Set_all_Cells_online_to_Unlocked
#     Wait Until Keyword Succeeds    15 min    5 sec    Check_all_Cells_online_should_be_Unlocked
#     Stop and get NGlogs on gNB
#     sleep    5s
#     Check_RAN_Configuration_Update
# 
# [1]Rjio_AQQJ_8_Online_IP_Modification
#     [Documentation]    To check Rjio_AQQJ_8_Online_IP_Modification via 192.168.255.129
#     [Tags]
#     [Timeout]    2h
#     Rjio_AQQJ_8_Online_IP_Modification
# # when scf confiured topp, this case may trigger faults, so ignore it:
# # Unexpect Active Alarm : 4298 ToP reference missing
# # Unexpect History Alarm : 7313 NgGnbInitPartialReset
# # normal faults:
# # 7305 NG SCTP setup fail
# # 7304 NG SCTP endpoint broken
# #    [Teardown]    SISO Coam Test Teardown
# 
# *** Keywords ***
# Dedicate_Suite_Setup
#     Import Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/TLData/${testline_name}/TLConfiguration.py
#     SISO Coam Suite Setup
# 
# Check_all_Cells_online_should_be_${value}
#     [Documentation]
#     ...    ********************************
#     ...    value:e.g.:Locked,Unlocked;
#     ...    ********************************
#     log to console    \n***Check_all_Cells_online_should_be_${value}
# #    ${connection}    set variable    GNB_OAM
# #    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# #    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#     FOR    ${cell_id}    IN    @{cell_id_list}
#         ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_id}    connection=GNB_OAM
#         Run Keyword If  '${value}'=='Locked'
#     ...    Cell Should Be Locked  cell_idx=${cell_id}  cell_group_idx=${cellgrp_id}  connection=GNB_OAM
#     ...    ELSE
#     ...    Cell Should Be Unlocked  cell_idx=${cell_id}  cell_group_idx=${cellgrp_id}  connection=GNB_OAM
#     END
# 
# Set_all_Cells_online_to_${value}
#     [Documentation]
#     ...    ********************************
#     ...    value:e.g.:Locked,Unlocked;
#     ...    ********************************
#     log to console    \n***Set_all_Cells_online_to_${value}
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     FOR    ${GCI}    IN    @{cell_id_list}
#         selenium_coam.set_parameter_value
#         ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${GCI}
#         ...    filter_param=Administrative state
#         ...    abbr=administrativeState
#         ...    new_value=${value}
#     END
#     selenium_coam.validate_plan
#     ${defErrs_dic}    selenium_coam.get_definition_errors
#     ${list_num}   Get Length   ${defErrs_dic}
#     Should be true    ${list_num}==${0}
#     selenium_coam.activate_plan
#     [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser
# 
# Check_RAN_Configuration_Update
#     [Arguments]    ${pcap_file}=${logPath}${/}ng_1.pcap
#     pcap.setup    infile=${pcap_file}    display_filter=${ranConfig_filter}     alias=test0
#     ${check_result1}=    pcap.get_field_value    field_name=ngap.RANConfigurationUpdate_element   fmt=showname    pcap_parser=test0
#     log to console    @{check_result1}[0]
#     log to console    @{check_result1}[0][0]
#     ${length1}    Get Length    ${check_result1}
#     Should Be Equal As Integers    ${length1}     1
#     ${check_result2}=    pcap.get_field_value    field_name=ngap.RANConfigurationUpdateAcknowledge_element   fmt=showname    pcap_parser=test0
#     ${length2}    Get Length    ${check_result2}
#     Should Be Equal As Integers    ${length2}     1
# 
# Start to collect NGlogs on gNB
#     [Arguments]    ${log_name}=ng_1.pcap    ${alias}=gNB_ssh
#     ssh.Reset Cache
#     wait until keyword succeeds    5 min    10 sec    Connect to Common Unit Master   alias=${alias}
#     ssh.send command    command=tcpdump -i br0 -w /tmp/${log_name}   connection=${alias}
# 
# Stop and get NGlogs on gNB
#     [Arguments]     ${log_name}=ng_1.pcap    ${alias}=gNB_ssh
#     ssh.Reset Cache
#     wait until keyword succeeds    5 min    10 sec    Connect to Common Unit Master   alias=${alias}
#     sleep    5s
#     ssh.send command    command=killall tcpdump     connection=${alias}
#     sleep    5s
#     ssh.download_file   remote_path=/tmp${/}${log_name}    local_path=${logPath}${/}${log_name}   connection=${alias}
#     sleep    5s
# 
# Rjio_AQQJ_8_Online_IP_Modification
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     ${currect_value}    selenium_coam.Get Parameter Value
#     ...    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1
#     ...    filter_param=Destination IP prefix length
#     log to console    \n***current Destination IP prefix length: ${currect_value}
#     run keyword and ignore error    Selenium Logout And Close Browser
#     Run Keyword If    '${currect_value}'!='8'    Modify_ip_to_8_Parameters_via_WebEM
#     ...    ELSE    Modify_ip_to_16_Parameters_via_WebEM
#     sleep    5s
#     Modify_ip_to_${currect_value}_Parameters_via_WebEM
#     sleep    5s
#     Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair
#     [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser
# 
# Modify_ip_to_${value}_Parameters_via_WebEM
#     [Documentation]
#     ...    ********************************
#     ...    value:e.g.:0,24;original value is 0
#     log to console  \n***Modify_ip_to_${value}_Parameters_via_WebEM***\n
#     Selenium Login And Disable Screen Lock    url=https://192.168.255.129
#     Close Start Up View    timeout=60
# #    Destination IP prefix length
# #    MRBTS-166/TNLSVC-1/TNL-1/IPNO-1/IPRT-1
#     Check and Modify Single Parameter on WebUI
#     ...    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1
#     ...    filter_param=Destination IP prefix length
#     ...    abbr=destinationIpPrefixLength
#     ...    new_value=${value}
#     [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser
