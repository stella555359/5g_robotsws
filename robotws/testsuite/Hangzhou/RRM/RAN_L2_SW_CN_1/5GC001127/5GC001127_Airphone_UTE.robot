*** Settings ***
Documentation    ...
#Library    taf.transport.ssh  WITH NAME  ssh
#Library    BuiltIn
#Library    String
#Library    ute_wtssim
#Library    taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
#Library    OperatingSystem
#Library    Process
#Library    Collections
#Library    ute_admin
#
#
#*** Variables ***
#&{AP}             hostname=10.57.146.215    username=toor4nsn    password=oZPS0POrRieRtu
#&{GNB}            hostname=10.57.146.216    username=toor4nsn    password=oZPS0POrRieRtu
#${WEBUI_HOST}     10.57.146.216
#${WEBUI_USER}     Nemuadmin
#${WEBUI_PWD}      nemuuser
#${WTS_DIR}        /opt/iphy/latest
#${WTS_CFG}        basic_l1bypass_nsa_call_tdd_mmwv.cfg
#${WTS_AP_XML}     AirPhoneConfig_l1bypass_tdd_nsa_mmwv.xml
#${UE_ID}          1
#${BEARER_ID}      2
#${PING_MATCH}     from\\s+[0-9,\.\:]+\\s+[a-z,\_\=]+\\d+\\s+[a-z,\=,0-9]+
#${GNB_HW_STATUS_CHECK}    export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s -n 0x1011 -p 15004
#${AP_HW_STATUS_CHECK}    export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s -n 0x5011 -p 15004
#
#*** Test Cases ***
#5GC001127_B_4003_Single_UE_scheduling_in_analog_BF_system_1beam_without_carrier_aggregation
#    [Tags]    Cloud    CRT_HNZ    5GC001127    FR2    IPV4    Owner_qianwu    PRI-Medium    CN1    trunk
#    ...   CRT    5G_RAN_TDD    Airphone    5G20B
#    [Setup]
#    Get and Set SCF Parameter For frame1127
#    Make Sure BTS Site Is Ready
#    Configure VM Interfaces
#    Start UTE WTS
#    Setup X2 Connection
#    Verify Cell Setup
#    LTE Attach
#    5G Attach
#    Delete PM BTS counter file
#    Start Traffic
#    Check PM counter
#
#*** Keywords ***
#
#Login Page Via WebUI
#    #selenium_coam.enable_virtual_display
#    selenium_coam.login    url=https://${WEBUI_HOST}    username=${WEBUI_USER}    password=${WEBUI_PWD}
#    selenium_coam.disable_message_box
#    selenium_coam.disable_screen_lock
#    selenium_coam.refresh_page
#    sleep    15sec
#
#Get and Set SCF Parameter For frame1127
#    Log To Console    Get and Set SCF Parameter For frame1127...
#    Login Page Via WebUI
#
#    ${frameStructureType}    selenium_coam.get parameter value    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    filter_param=Frame Structure Type
#    ...    abbr=frameStructureType
#    ${ulDlDataSlotRatio}    selenium_coam.get parameter value    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    filter_param=UL to DL logical data slot ratio
#    ...    abbr=ulDlDataSlotRatio
#    ${guardPeriodLength}    selenium_coam.get parameter value    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    filter_param=Guard Period length
#    ...    abbr=guardPeriodLength
#
#    run keyword if    '${frameStructureType}'=='semiStatic'    builtin.Log    current framestructure is semiStatic, no need to update
#    ...    ELSE    selenium_coam.set parameter value    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    filter_param=Frame Structure Type
#    ...    abbr=frameStructureType    new_value=semiStatic
#    run keyword if    '${ulDlDataSlotRatio}'=='1/4'    builtin.Log    current ulDlDataSlotRatio is 1/4, no need to update
#    ...    ELSE    selenium_coam.set parameter value    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    filter_param=UL to DL logical data slot ratio
#    ...    abbr=ulDlDataSlotRatio    new_value=1/4
#    run keyword if    '${guardPeriodLength}'=='2Symbols'    builtin.Log    current guardPeriodLength is 2symbols, no need to update
#    ...    ELSE    selenium_coam.set parameter value    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    filter_param=Guard Period length
#    ...    abbr=guardPeriodLength    new_value=2Symbols
#
#    Active New Parameter Value
#    [Teardown]    run keyword and ignore error    selenium_coam.logout
#
#Active New Parameter Value
#    selenium_coam.validate plan
#    ${activate_result}    selenium_coam.activate plan    activate_plan_despite_errors=True    timeout=10
#
#Make Sure BTS Site Is Ready
#    Log To Console    Make sure BTS site is ready at most 5 times...
#    FOR    ${index}    IN RANGE    ${5}
#         Log To Console    ===============Reboot Time: ${index}==============
#         Reboot Testline Via SSH
#         Ping GNB ip
#         ${res}    Run Keyword And Return Status    Wait Coam Site to be Ready
#         Exit For Loop If    '${res}'=='True'
#         Sleep    5s
#
#    END
#Reboot Testline Via SSH
#    Log To Console    Reboot testline via ssh...
#    OperatingSystem.Run And Return Rc And Output    sshpass -p ${AP.password} ssh ${AP.username}@${AP.hostname} 'reboot'
#    Sleep    2s
#    OperatingSystem.Run And Return Rc And Output    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.hostname} 'reboot'
#    Sleep    2s
#
#Check gNB HW Status is up
#    Log To Console    Check gNB HW Status is up...
#    ssh.connect to    ${GNB.hostname}    ${GNB.username}    ${GNB.password}
#    : FOR    ${var}    IN RANGE    60
#	\    ${result_list}    create list
#    \    ${match_HW_info}    ssh.execute    ${GNB_HW_STATUS_CHECK}
#    \    ${match_result}    ${match_info}    run keyword and ignore error    should match regexp    ${match_HW_info}    FSM1\_FCT\\s+([a-z]+)
#    \    ${contain_result}    ${error}    run keyword and ignore error    should contain    ${match_info[-1]}    ready
#    \    Append To List    ${result_list}    ${contain_result}
#    \    ${match_result}    ${match_info}    run keyword and ignore error    should match regexp    ${match_HW_info}    FSM1\_FSP1\\s+([a-z]+)
#    \    ${contain_result}    ${error}    run keyword and ignore error    should contain    ${match_info[-1]}    ready
#    \    Append To List    ${result_list}    ${contain_result}
#    \    ${HW_state_result}    ${error}    run keyword and ignore error    should not contain    ${result_list}    FAIL
#    \    exit for loop if    '${HW_state_result}'=='PASS'
#    \    sleep    10
#    should not contain    ${result_list}    FAIL
#    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect
#
#Check AP HW Status is up
#    Log To Console    Check AP HW Status is up...
#    ssh.connect to    ${AP.hostname}    ${AP.username}    ${AP.password}
#    : FOR    ${var}    IN RANGE    24
#	\    ${result_list}    create list
#    \    ${match_HW_info}    ssh.execute    ${AP_HW_STATUS_CHECK}
#    \    ${match_result}    ${match_info}    run keyword and ignore error    should match regexp    ${match_HW_info}    FSM5\_FCT\\s+([a-z]+)
#    \    ${contain_result}    ${error}    run keyword and ignore error    should contain    ${match_info[-1]}    ready
#    \    Append To List    ${result_list}    ${contain_result}
#    \    ${match_result}    ${match_info}    run keyword and ignore error    should match regexp    ${match_HW_info}    FSM5\_FSP1\\s+([a-z]+)
#    \    ${contain_result}    ${error}    run keyword and ignore error    should contain    ${match_info[-1]}    ready
#    \    Append To List    ${result_list}    ${contain_result}
#    \    ${HW_state_result}    ${error}    run keyword and ignore error    should not contain    ${result_list}    FAIL
#    \    exit for loop if    '${HW_state_result}'=='PASS'
#    \    sleep    10
#    should not contain    ${result_list}    FAIL
#    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect
#
#Ping GNB ip
#    Log To Console    Ping GNB ip...
#	sleep    30sec
#	: FOR    ${var}    IN RANGE    40
#    \    ${ping_info}    run    ping -c 5 ${GNB.hostname}
#    \    ${run_result}    ${error}    run keyword and ignore error    should match regexp    ${ping_info}    ${PING_MATCH}
#    \    exit for loop if    '${run_result}'=='PASS'
#    \    sleep    10
#
#Check gNB F1 State is Successfully
#    Log To Console    Check gNB F1 State is Successfully...
#    ssh.connect to    ${GNB.hostname}    ${GNB.username}    ${GNB.password}
#    FOR    ${var}    IN RANGE    60
#         ${match_f1_info}    ssh.execute    command=cat /tmp/node_CPRT00/tmp/startup_cp_rt.log | grep "F1 setup"
#         ${matchh_result}    ${error}    run keyword and ignore error    should contain    ${match_f1_info}    successfully
#         exit for loop if    '${matchh_result}'=='PASS'
#         sleep    10sec
#    END
#    should contain    ${match_f1_info}    successfully
#    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect
#
#Wait Coam Site to be Ready
#    Log To Console    verify bts site is ready...
#    Check gNB HW Status is up
#    Check AP HW Status is up
#    Check gNB F1 State is Successfully
#
#Configure VM Interfaces
#    Log To Console    configure VM interfaces...
#    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
#
#Clean edaemon and egate
#    OperatingSystem.Run    sudo rm *log*
#    ute_wtssim.Teardown Edaemon    alias=edaemon
#    ute_wtssim.Teardown Egate
#
#Start UTE WTS
#    Log To Console    Starting WTS...
#    Run Keyword And Ignore Error     Clean edaemon and egate
#    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_CFG}
#    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_AP_XML}
#    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
#    ute_wtssim.Start Edaemon Process    alias=edaemon
#    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}
#    ute_wtssim.Start Egate Process
#    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${WTS_CFG}    pass_regexp=(SimMode is ready now|UEC-1 is active)
#    Wait Until Keyword Succeeds    120s    15s
#    ...    ute_wtssim.Execute Egate Command    state_sim_disp    pass_regexp=The state is ACTIVE
#
#Setup X2 Connection
#    Log To Console    setup X2 connection...
#    ${pattern}    Set Variable    ENB-1: X2AP Link with GNB-2 .* is up
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_x2_link_up enb\=1 target\=2
#    ...    pass_regexp=${pattern}    timeout=5min
#    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#    Log To Console    \n${output}
#    Log    x2_is_ok
#
#Verify Cell Setup
#    Log To Console    verify cell setup...
#    Sleep    15s
#    Wait Until Keyword Succeeds    180s    15s    Check UTE ASIK AP Cell Setup
#    Log    cell_setup_is_ok
#
#Check UTE ASIK AP Cell Setup
#    Log To Console    check ute ASIK AP cell setup...
##    SSH.Connect To    ${AP.hostname}    ${AP.username}    ${AP.password}
##    ${result}    SSH.Execute    grep -i "Cell Setup Completed" /tmp/APL3.log
##    Should Contain    ${result}    Cell Setup Completed    ignore_case=True
##    Log To Console    ${result}
##    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect
#
#LTE Attach
#    Log To Console    LTE attach...
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ue_attach id\=1 profile\=1
#    ...    pass_regexp=UE IS ACTIVE    timeout=3min
#    ${output}    String.Get Lines Matching Regexp    ${output}    UE IS ACTIVE    partial_match=True
#    Log To Console    \n${output}
#    Log    lte_attach_is_ok
#
#5G Attach
#    Log To Console    5G attach...
#    ${pattern}    Set Variable    UEC-1: UE1: Proxy \\(eNB 2 cell 2\\) reported successful RA
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ue_dc_enb_start ue\=1 target_gnb\=2 target_cells\=2 bearer\=2 type\=split_scg
#    ...    pass_regexp=${pattern}    timeout=3min
#    ${attach_result}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#    Log To Console    \n${attach_result}
#    Log    ue_attach_is_ok
#    [Return]    ${output}
#
#Delete PM BTS counter file
#    Log To Console    Delete PM BTS counter file on SA
#    ssh.connect to    ${GNB.hostname}    ${GNB.username}    ${GNB.password}
#    ssh.execute    rm /tmp/PM.BTS*
#    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect
#
#Start Traffic
#    [Arguments]    ${dl_rate}=5    ${ul_rate}=2    ${duration}=2min
#    Log to Console    \nRunning DL + UL Traffic for ${duration}...
#    ${output}         Execute Egate Command and Wait for Data
#    ...               trf_data_start ue\=${UE_ID} id\=${BEARER_ID} dir\=dl trf_id\=2 mbps\=${dl_rate} size\=1350
#    ...               pass_regexp=TRF:
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
#    Log to Console    ${output}
#
#    ${output}         Execute Egate Command and Wait for Data
#    ...               trf_data_start ue\=${UE_ID} id\=${BEARER_ID} dir\=ul trf_id\=1 mbps\=${ul_rate}
#    ...               pass_regexp=TRF:
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
#    Log to Console    ${output}
#
#    Sleep             ${duration}
#
#    Log to Console    Stopping DL + UL Traffic...
#    ${output}         Execute Egate Command and Wait for Data
#    ...               trf_data_stop ue\=${UE_ID} id\=${BEARER_ID}    pass_regexp=Traffic was stopped
#    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
#    Log to Console    ${output}
#
#Check PM counter
#    wait until keyword succeeds    15min    1min    Get M55314C03009
#    wait until keyword succeeds    1min    10sec    Get M55314C05009
#    should be true    ${M55314C03009}>0
#    should be true    ${M55314C05009}>0
#
#Get M55314C03009
#    Log To Console    check M55314C03009...
#    ssh.connect to    ${GNB.hostname}    ${GNB.username}    ${GNB.password}
#    ssh.execute    gunzip /tmp/PM.BTS*.gz
#    ssh.execute    rm /tmp/PM.BTS*.xml
#    ${counter_info1}    ssh.execute    cat /tmp/PM.BTS* | grep M55314C03009
#    ${M55314C03009_list}    get regexp matches    ${counter_info1}    <M55314C03009>(\\d+)</M55314C03009>    1
#    BuiltIn.Log    ${M55314C03009_list}
#    ${M55314C03009}    get from list    ${M55314C03009_list}    0
#    set suite variable    ${M55314C03009}
#    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect
#
#Get M55314C05009
#    Log To Console    check M55314C05009...
#    ssh.connect to    ${GNB.hostname}    ${GNB.username}    ${GNB.password}
#    ${counter_info2}    ssh.execute    cat /tmp/PM.BTS* | grep M55314C05009
#    ${M55314C05009_list}    get regexp matches    ${counter_info2}    <M55314C05009>(\\d+)</M55314C05009>    1
#    BuiltIn.Log    ${M55314C05009_list}
#    ${M55314C05009}    get from list    ${M55314C05009_list}    0
#    set suite variable    ${M55314C05009}
#    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect
