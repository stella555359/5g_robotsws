*** Settings ***
Documentation
...
...             author       : padmashree.b@nokia.com
...             maintainer   : padmashree.b@nokia.com
...             Test Set Name: CB013396
...             Testing Split:   CB013396-B
...             Requirement ID  :5G_RAN_USR_RRM_28901

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb
Library		      OperatingSystem
Resource         ./resources/CB010369_resource.robot
Resource         ./resources/CB013396_resource.robot
Library          ./resources/admin_cli.py


#Suite Teardown      Run Keywords
#...                 Log To console    Suiteteardown
#...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt    #  sos
#...                 AND     Run Keyword and Ignore Error    Get Snapshot

*** Variables ***

${wts_cfg_file}    ${CURDIR}/config/wts/multi_upf_rjio.cfg
${wts_cfg_file1}     ${CURDIR}/config/wts/B_IWK4_TC1_rjio.cfg
${WTS_DIR}          /opt/iphy/latest
${epc_log_path}    /tmp/
${TEST_NAME}            Cell_setup
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts

*** Test Cases ***
[1]CB013396-B_IWK2_TC1_Alternative_1_SA_Cells_Disabled_on_NG-U_and_NG-C_Failure
    [Tags]  TC_01
    [Setup]         Run keywords    Suite setup from scratch
    ...                 AND     Perform SCF Delta Commissioning with delta_combined_rjio.json
    ...                 AND     Sleep   60
    ...                 AND     Perform SCF Delta Commissioning with Multi_AMF.json
    ...                 AND     sleep    10
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    300
    ...                 AND     Configure additional UTE ETH3 IPs
    ...                 AND     sleep    60
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.9/24 dev eth3
    ...                 AND     sleep    60
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.10/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.11/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.12/24 dev eth3
    ...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.13/24 dev eth3
    ...                 AND     Update bsr package
    ...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1   1
    [Documentation]     The purpose of this TC is to verify the behaviour when CB013396 is
    ...      enabled and SA cells are disabled due to NG-U and NG-C failure
    ...             author:     padmashree.b@nokia.com
    ...             maintainer: padmashree.b@nokia.com
    ...             TESTING SPLIT:CB013396_B101
    ...             CONTACTS:    VRF_BLR1
    ...             REFERENCES: CB013396 CFAM
    ...             Requirement ID: 5G_RAN_USR_RRM_29165
    Start Log      btslog
    Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
    Multi UE Register should be Successful with upfid And send traffic     1     3    1     1      1     1
    Multi UE Register should be Successful with upfid And send traffic     4     6    1     1      1     2
    Multi UE Register should be Successful with upfid And send traffic     7     9    1     1      1     3
    sleep       10s
    Trigger gtpu path failure for 6 paths multiamf
    sleep       20s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     120s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:all
    Check Availability and operational State of all cells        failed       disabled
    Comment         ............ B_IWK2_TC1 verify cell enable ...................
    Comment         Trigger NG-C path failure
    ${output}=     Run    sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.129 iptables -A INPUT -p sctp --dport 38412 -j DROP
    Sleep   60s
    Check Availability and operational State of all cells        failed       disabled
	${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Check if fault 7107 is not raised
    ${syslogpath}   Stop Log      btslog
    ${output}=     Run    sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.129 iptables -D INPUT -p sctp --dport 38412 -j DROP
    Sleep   60s
    Recover gtpu path failure for 6 paths multiamf
    Sleep   60s
    ${ue_dereg_cmd}    SET VARIABLE    ue_deregister id=1-9 ue_deregister_type=switch_off by=ue
    Execute Egate Command    ${ue_dereg_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    Sleep   30s
    Start Log      btslog
    Multi UE Register should be Successful with upfid And send traffic     10     10    1     1      1     1
    ${output}=     Run    sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.129 iptables -D INPUT -p sctp --dport 38412 -j DROP
    Sleep   60s
    ${status_7107}       Run keyword and Return Status       Check If fault not Appeared     7107        Critical
    ${status_7107}      Convert to string   ${status_7107}
    Should Match Regexp    ${status_7107}    False
    [Teardown]      Run Keywords
    ...                 Log To console  Testteardown
    ...                 AND     Run    sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.129 iptables -D INPUT -p sctp --dport 38412 -j DROP
    ...                 AND     Run Keyword and Ignore Error     Stop Log      btslog
    ...                 AND     Run Keyword and Ignore Error        Stop Log    Snapshot    sosreport
    ...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate


[1]CB013396-B_IWK4_TC1_Alternative_1_behaviour_when_SA_cells_in_one_powergroup_are_disabled_due_to_both_energysaving_and_NGU_path_failure
    [Tags]  TC_02
    [Setup]         Run keywords    Run Keyword and Ignore Error        Suite setup from scratch
    ...                 AND     Perform SCF Delta Commissioning with B_IWK4_TC1_rjio.json
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    300
    ...                 AND     Configure additional UTE ETH3 IPs
    ...                 AND     sleep    60
    ...                 AND     Update bsr package
    ...                 AND     Load CFG and verify cell status   ${wts_cfg_file1}   1   1
    [Documentation]     The purpose of this TC is to verify the behaviour when CB013396 is
    ...      enabled and SA cells are disabled due to energy saving and NG-U path failure
    ...             author:     padmashree.b@nokia.com
    ...             maintainer: padmashree.b@nokia.com
    ...             TESTING SPLIT:CB013396_B101
    ...             CONTACTS:    VRF_BLR1
    ...             REFERENCES: CB013396 CFAM
    ...             Requirement ID: 5G_RAN_USR_RRM_29165
    Start Log      btslog
    Wait 10s for [1,2,3,4,5,6] esState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Wait 310s for [1,2,3,4,5,6] esState change to [energySaving,notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Multi UE Register should be Successful with upfid And send traffic     71     73    1     1      1     1
    Multi UE Register should be Successful with upfid And send traffic     74     76    1     1      1     2
    Multi UE Register should be Successful with upfid And send traffic     77     79    1     1      1     3
    Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
    sleep       10s
    Trigger gtpu path failure for 6 paths
    sleep     102s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     62s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain      ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}  NR:all
    Check Availability and operational State of all cells        failed       disabled

    Wait 10s for [1,2,3,4,5,6] esState change to [notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Recover gtpu path failure for 6 paths
    ${ue_dereg_cmd}    SET VARIABLE    ue_deregister id=71-79 ue_deregister_type=switch_off by=ue
    ute_wtssim.Execute Egate Command    ${ue_dereg_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    sleep       100s
    Check operational State of all cells    enabled
#    Log To Console              sleeptimeto verify status    of cells.
#    sleep       600s
    Wait 1080s for [1,2,3,4,5,6] esState change to [energySaving,energySaving,energySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Multi UE Register should be Successful with upfid And send traffic     71     73    1     1      1     1
    Multi UE Register should be Successful with upfid And send traffic     74     76    1     1      1     2
    Multi UE Register should be Successful with upfid And send traffic     77     79    1     1      1     3
    sleep       10s
    Trigger gtpu path failure for 6 paths
    sleep     102s
    ${major_alarm_time}    ${major_alarm_info}   Check If fault 7706 Appeared and failed paths info      Major
    sleep     62s
    ${crit_alarm_time}  ${crit_alarm_info}      Check If fault 7706 Appeared and failed paths info      Critical
    Should Contain    ${crit_alarm_info['alarmAttribute'][0]['attributeValue']}    NR:4,5,6
    Check Only Cells 4 5 6 Are Disabled    failed    disabled
    Wait 10s for [1,2,3,4,5,6] esState change to [energySaving,energySaving,energySaving,notEnergySaving,notEnergySaving,notEnergySaving]
    Recover gtpu path failure for 6 paths
    ${ue_dereg_cmd}    SET VARIABLE    ue_deregister id=71-79 ue_deregister_type=switch_off by=ue
    ute_wtssim.Execute Egate Command    ${ue_dereg_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    Check Only Cells 4 5 6 Are Enabled   enabled
    Multi UE Register should be Successful with upfid And send traffic     71     73    1     1      1     1
    Multi UE Register should be Successful with upfid And send traffic     74     76    1     1      1     2
    Multi UE Register should be Successful with upfid And send traffic     77     79    1     1      1     3

#    Start traffic
    ${syslogpath}   Stop Log      btslog

    [Teardown]      Run Keywords
    ...                 Log To console  Testteardown
    ...                 AND     Run    sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.129 iptables -D INPUT -p sctp --dport 38412 -j DROP
    ...                 AND     Run Keyword and Ignore Error     Stop Log      btslog
    ...                 AND     Run Keyword and Ignore Error        Stop Log    Snapshot    sosreport
#    ...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate
*** Keywords ***
Check if fault 7107 is not raised
    ${status_7107}       Run keyword and Return Status       Check If fault not Appeared     7107        Critical
    ${status_7107}      Convert to string   ${status_7107}
    Should Match Regexp    ${status_7107}    False
Gnb Cell Should Be Onair
    coam.setup admin    bts_host=10.0.1.2
    ${status}    ${cell_info}=    Run Keyword And Ignore Error    coam.get_cells_info    cell_type=nr


    Run Keyword If    '${status}' == 'FAIL'    Fail    Keyword failed: ${cell_info}
    FOR    ${cell}    IN    @{cell_info}
        ${status_dict}=    Get From Dictionary    ${cell}    status
        ${operationalState}=    Get From Dictionary    ${status_dict}    operationalState
        Log To Console    Cell ${cell['id']['configuration']} Operational State: ${operationalState}
    END

    FOR    ${cell}    IN    @{cell_info}
        ${status_dict}=    Get From Dictionary    ${cell}    status
        ${blockingState}=    Get From Dictionary    ${status_dict}    blockingState
        Log To Console    Cell ${cell['id']['configuration']} Operational State: ${blockingState}
    END

Wait ${timeout}s for [${cells_ids}] esState change to ${expected_states}
    Wait Until Keyword Succeeds  ${timeout}s  5s
    ...  Check for cells [${cells_ids}] if energySavingState equals ${expected_states}

Verify Cell State
  [Arguments]  ${node}  ${cell}  ${dist_name}  ${state}  ${technology}  ${timeout}

  Run Keyword Unless  '${technology}' == 'NRCEL'  Return From Keyword

  ${rat_type}=  Set Variable  NR
  ${cell_id}=  admin.Get Cell Id By Configuration Id  ${rat_type}  ${cell}  ${timeout}  alias=${node}

  Log  \nChecking NR Cell Availability Status...  console=True

  Run Keyword If
  ...  "${state}" == "Blocked" or "${state}" == "Locked"
  ...  Run Keyword And Continue On Failure
  ...  admin.Assert
  ...  class_name=${technology}
  ...  id=${cell_id}
  ...  parameters=availabilityStatus=regex"(?i)degraded|dependency|failed|off\\s?line|None"
  ...  timeout=${timeout}
  ...  alias=${node}
  ...  ELSE
  ...  Run Keyword And Continue On Failure
  ...  admin.Assert No
  ...  class_name=${technology}
  ...  parameters=availabilityStatus=regex"(?i)degraded|dependency|failed|off\\s?line|None", id=${cell_id}
  ...  timeout=${timeout}
  ...  alias=${node}
  #log to console  ${dist_name}
    log to console  ${dist_name}
Stop gtpu path failure
    ute_wtssim.Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.2,0
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.4,10.0.1.2,0
    sleep    1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.2,0
    sleep    1s
	ute_wtssim.Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.40,0
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.4,10.0.1.40,0
    sleep   1s
    ute_wtssim.Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.5,10.0.1.40,0


Check operational State of all cells
    [Arguments]    ${expected_oper_state}
    coam.setup admin    bts_host=10.0.1.2

    @{all_cell_dn_list}   Create List
    ${nr_cells}   coam.get_cells_info
    FOR   ${nr_cell}   IN   @{nr_cells}
        ${nr_cell_dn}   Set Variable   ${nr_cell["id"]["configuration"]}
        Append To List   ${all_cell_dn_list}   ${nr_cell_dn}
        ${status_dict}=    Get From Dictionary    ${nr_cell}    status
        ${operationalState}=    Get From Dictionary    ${status_dict}    operationalState
        Should be True      '${operationalState}' == '${expected_oper_state}'
    END
    [Teardown]  coam.teardown admin

Wait Until Operation Is Successful
    [Arguments]    ${timeout}=300s    ${interval}=10s
    Wait Until Keyword Succeeds    ${timeout}    ${interval}    Check Operational Stat


Check Operational Stat
    ${result}=    Run Keyword And Return Status    Some Keyword That Checks Status
    Run Keyword If    not ${result}    Fail    Operational stat check failed

Trigger gtpu path failure for 6 paths multiamf
    Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.2,1500
    sleep    1s
    Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.9,10.0.1.2,1500
    sleep    1s
    Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.10,10.0.1.2,1500
    sleep    1s
    Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.40,1500
    sleep    1s
    Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.9,10.0.1.40,1500
    sleep    1s
    Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.10,10.0.1.40,1500


Recover gtpu path failure for 6 paths multiamf
    Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.2,0
    sleep    1s
    Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.9,10.0.1.2,0
    sleep    1s
    Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.10,10.0.1.2,0
    sleep    1s
    Execute Egate Command  cmd=upf_param id=1 skip_echo_req=10.0.1.1,10.0.1.40,0
    sleep    1s
    Execute Egate Command  cmd=upf_param id=2 skip_echo_req=10.0.1.9,10.0.1.40,0
    sleep    1s
    Execute Egate Command  cmd=upf_param id=3 skip_echo_req=10.0.1.10,10.0.1.40,0
