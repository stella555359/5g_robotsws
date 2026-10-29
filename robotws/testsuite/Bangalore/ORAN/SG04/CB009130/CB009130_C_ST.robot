*** Settings ***

Documentation
...   author: RAKESH KUMAR
...   contact: rakesh.17.kumar@nokia.com
...   Description: Test Suite for CB009130

Library           Process
Library           String
Library           taf.collectors.core    WITH NAME    core
Library           taf.collectors.btslog  WITH NAME   btslog

Library           Collections
Library           DateTime
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.selenium.sbts    WITH NAME    sbts
Library           ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Library           taf.sw.scout    WITH NAME     scout
Library           taf.analyzer.netconf
Library           taf.collectors.simple    WITH NAME    simple
Library           OperatingSystem     WITH NAME    os

Library           taf.collectors.pmcounters    WITH NAME    PM
Library           ./testsuite/Bangalore/ORAN/SG04/resources/orualarm.py

Resource          taf/rfrl/common_resources/common_step/interface.robot
Resource          ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot


*** Variables ***

${netconf_file}=    /home/ute/results/RMOD_L-1_NetconfRpcMessageTrace.log
${host1}=     10.58.238.71
${user1}=     ute
${password1}=    BT5l@bus3rl0g1n
${host2}=     192.168.255.129
${user2}=    toor4nsn
${password2}=    oZPS0POrRieRtu
${UE_PC}=    10.45.150.167
${id}=    inbabtslabuser
${password}=    BT5l@bus3rl0g1n
${ru_ip}=     192.168.1.131
${ru_id}=    User1-vSFQEFw1
${ru_pass}=  Q+*!LD0sem
${cmnd1}=    ru -almtest 0009 1 101
${cmnd2}=    ru -almtest 0009 0 101
${cmnd13_1}=    ru -almtest 0013 1 101
${cmnd13_2}=    ru -almtest 0013 0 101
${cmnd14_1}=    ru -almtest 0014 1 101
${cmnd14_2}=    ru -almtest 0014 0 101
#${cmnd3}=    app_sh,mon -s,mon -g temp=120
#${cmnd4}=    app_sh,mon -s,mon -g temp=40,reboot
#${cmnd5}=    app_sh,mon -s,mon -g temp=-20
#${cmnd6}=    app_sh,mon -s,mon -g temp=10
#${cmnd7}=    app_sh,rf_mon -g  agc_level2=1
#${cmnd8}=    app_sh,rf_mon -g  agc_level2=0
${fault-text1}=     Transmission quality deteriorated
${fault-text2_1}=     Radio autonomous reset as recovery action
${fault-text2}=    TX out of order
${fault-text3}=    RX out of order
${fault-id1}=     9
${fault-severity1}=     Major
${fault-severity13_1}=     Warnings
${fault-severity2}=     Critical
${fault-severity3}=     Critical
${Nokia_faultid1}=     1921
${Nokia_faultid2_TX}=     1907
${Nokia_faultid3_RX}=     1911
${Nokia_faultid4}=     21101
${fault-severity4}=     Minor
${CONFIGURATION}		    1_2_CLOUD970

&{[1][1.0] TC05_CB009130_C- Fault Notification Handling for faults 20 RX out of order related to antenna lines}
...	QC_ID_FL00=QC_31658    QC_ID_SBTS24R3=QC_852885

&{[1][1.0] TC03_CB009130_C_Fault Notification Handling for faults 9 Transmission quality deteriorated related to antenna lines}
...	QC_ID_FL00=QC_31660

&{[1][1.0] TC04_CB009130_C_ Fault Notification Handling for faults 19 TX out of order related to antenna lines}
...	QC_ID_FL00=QC_31659

*** Test Cases ***
[1][1.0] TC05_CB009130_C- Fault Notification Handling for faults 20 RX out of order related to antenna lines
    [Tags]    TRUNK_SG04    9130C    9130C_1    QCD_MN_RAN    QCP_RAN_VRF

    coam.setup_admin	bts_host=192.168.255.129    timeout=300

    Step1: Login to ORU and using debug command,raise Fault ID-9 with Severity Major Transmission quality deteriorated
    Step2: Verify Netconf logs for the fault ID -9
    Step3: Cancel the fault 9 using the debug command

    Step4: Login to ORU and using debug command,raise Fault ID-13 with Severity Critical TX out of order
    Step5: Verify Netconf logs for the fault ID -13
    Step6: Cancel the fault 13 using the debug command

    Step7: Login to ORU and using debug command,raise Fault ID-14 with Severity Critical RX out of order
    Step8: Verify Netconf logs for the fault ID -14
    Step9: Cancel the fault 14 using the debug command
    RP Settings
    Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting
    Set QC_Tag
    coam.teardown_all_aliases_for_admin

[1][1.0] TC04_CB009130_C_ Fault Notification Handling for faults 19 TX out of order related to antenna lines
    [Tags]    TRUNK_SG04    9130C    QCD_MN_RAN    QCP_RAN_VRF
    RP Settings
    Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting
    Set QC_Tag

[1][1.0] TC03_CB009130_C_Fault Notification Handling for faults 9 Transmission quality deteriorated related to antenna lines
    [Tags]    TRUNK_SG04    9130C    QCD_MN_RAN    QCP_RAN_VRF
    RP Settings
    Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting
    Set QC_Tag

*** Keywords ***

Test Setup
    Log to console   --Test setup--

Test Teardown
    Log to console   --Test teardown--

Step1: Login to ORU and using debug command,raise Fault ID-9 with Severity Major Transmission quality deteriorated
    Log to Console    \n--Login to FJT and raising ${Nokia_faultid1} --

    coam.get_active_alarms
    RU_execute    ${UE_PC}    ${id}    ${password}    ${ru_ip}    ${ru_id}    ${ru_pass}    ${cmnd1}
    sleep     20

    coam.assert_alarm_active    faultId=${Nokia_faultid1}    severity=${fault-severity1}    timeout=150
    Log to Console    \n--Exepcted Fault ID generated--

Step2: Verify Netconf logs for the fault ID -9
    Log to Console    \n--Verify Netconf logs for the fault ID --
    ${executor}    Create Dictionary    host=${host2}      user=${user2}     password=${password2}

    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET80/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    sleep    30
    core.collect_collectors    names=coredump    target_dir=/home/ute/results
    core.teardown_collectors    names=coredump
    os.Run    tar -zxvf /home/ute/results/coredump/coredump1.log.tgz -C /home/ute/results/coredump
    os.Copy File    /home/ute/results/coredump/RMOD_L-2*
    ...    /home/ute/results/RMOD_L-1_NetconfRpcMessageTrace.log
    sleep    10
    ${a}=    netconf_get_value    ${netconf_file}    notification    alarm-notif    fault-text    ${fault-text1}
    run keyword and continue on failure   Should not be empty    ${a}
    ${b}=    netconf_get_value    ${netconf_file}    notification    alarm-notif    fault-id    ${fault-id1}
    log    ${b}
    ${c}=    netconf_get_value    ${netconf_file}    notification    alarm-notif    fault-severity    ${fault-severity1}
    run keyword and continue on failure   Should not be empty    ${c}
    coam.get_cells_info

Step3: Cancel the fault 9 using the debug command
    RU_execute    ${UE_PC}     ${id}    ${password}    ${ru_ip}    ${ru_id}     ${ru_pass}    ${cmnd2}
    sleep   20
    run keyword and continue on failure     coam.assert_alarm_inactive      faultId=${Nokia_faultid1}    severity=${fault-severity1}
    coam.get_cells_info
    coam.get_active_alarms

Step4: Login to ORU and using debug command,raise Fault ID-13 with Severity Critical TX out of order
    Log to Console    \n--Login to FJT and raising ${Nokia_faultid2_TX} --
    coam.get_active_alarms
    RU_execute    ${UE_PC}     ${id}    ${password}    ${ru_ip}    ${ru_id}     ${ru_pass}    ${cmnd13_1}
    sleep     20
    #coam.assert_alarm_active      faultId=${Nokia_faultid2_TX}    severity=${fault-severity13_1}    timeout=150
    Log to Console    \n--Exepcted Fault ID generated 1--

    RU_execute    ${UE_PC}     ${id}    ${password}    ${ru_ip}    ${ru_id}     ${ru_pass}    ${cmnd13_2}
    sleep   20
    run keyword and continue on failure     coam.assert_alarm_inactive      faultId=${Nokia_faultid2_TX}    severity=${fault-severity13_1}
    coam.get_cells_info
    Log to Console    \n--Exepcted Fault ID cancelled--

    RU_execute    ${UE_PC}     ${id}    ${password}    ${ru_ip}    ${ru_id}     ${ru_pass}    ${cmnd13_1}
    sleep     20
    #coam.assert_alarm_active      faultId=${Nokia_faultid2_TX}    severity=${fault-severity13_1}
    Log to Console    \n--Exepcted Fault ID generated 2--

    RU_execute    ${UE_PC}     ${id}    ${password}    ${ru_ip}    ${ru_id}     ${ru_pass}    ${cmnd13_2}
    sleep   20
    run keyword and continue on failure     coam.assert_alarm_inactive      faultId=${Nokia_faultid2_TX}    severity=${fault-severity13_1}
    coam.get_cells_info


    RU_execute    ${UE_PC}     ${id}    ${password}    ${ru_ip}    ${ru_id}     ${ru_pass}    ${cmnd13_1}
    sleep     20
    #coam.assert_alarm_active      faultId=${Nokia_faultid2_TX}    severity=${fault-severity13_1}
    Log to Console    \n--Exepcted Fault ID generated 3--

    RU_execute    ${UE_PC}     ${id}    ${password}    ${ru_ip}    ${ru_id}     ${ru_pass}    ${cmnd13_2}
    sleep   20
    run keyword and continue on failure     coam.assert_alarm_inactive      faultId=${Nokia_faultid2_TX}    severity=${fault-severity13_1}
    coam.get_cells_info


    RU_execute    ${UE_PC}     ${id}    ${password}    ${ru_ip}    ${ru_id}     ${ru_pass}    ${cmnd13_1}
    sleep     20
    coam.assert_alarm_active      faultId=${Nokia_faultid2_TX}    severity=${fault-severity2}    timeout=500
    Log to Console    \n--Exepcted Fault ID generated--

Step5: Verify Netconf logs for the fault ID -13
    Log to Console    \n--Verify Netconf logs for the fault ID --
    ${executor}    Create Dictionary    host=${host2}      user=${user2}     password=${password2}

    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET80/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    sleep    20
    core.collect_collectors    names=coredump    target_dir=/home/ute/results
    core.teardown_collectors    names=coredump
    os.Run    tar -zxvf /home/ute/results/coredump/coredump1.log.tgz -C /home/ute/results/coredump
    os.Copy File    /home/ute/results/coredump/RMOD_L*
    ...    /home/ute/results/RMOD_L-1_NetconfRpcMessageTrace.log
    sleep    10
    ${a}=    netconf_get_value      ${netconf_file}     notification     alarm-notif     fault-text    ${fault-text2}
    run keyword and continue on failure   Should not be empty    ${a}
    ${b}=    netconf_get_value      ${netconf_file}     notification     alarm-notif     fault-id    ${Nokia_faultid2_TX}
    log    ${b}
    ${c}=    netconf_get_value      ${netconf_file}     notification     alarm-notif     fault-severity    ${fault-severity2}
    run keyword and continue on failure   Should not be empty    ${c}
    coam.get_cells_info

Step6: Cancel the fault 13 using the debug command
    RU_execute    ${UE_PC}     ${id}    ${password}    ${ru_ip}    ${ru_id}     ${ru_pass}    ${cmnd13_2}
    sleep   20
    run keyword and continue on failure     coam.assert_alarm_inactive      faultId=${Nokia_faultid2_TX}    severity=${fault-severity2}
    coam.get_cells_info
    coam.get_active_alarms

Step7: Login to ORU and using debug command,raise Fault ID-14 with Severity Critical RX out of order
    Log to Console    \n--Login to FJT and raising ${Nokia_faultid3_RX} --
    RU_execute    ${UE_PC}     ${id}    ${password}    ${ru_ip}    ${ru_id}     ${ru_pass}    ${cmnd14_1}
    sleep     20
    coam.assert_alarm_active      faultId=${Nokia_faultid3_RX}    severity=${fault-severity3}    timeout=150
    Log to Console    \n--Exepcted Fault ID generated--
Step8: Verify Netconf logs for the fault ID -14
    Log to Console    \n--Verify Netconf logs for the fault ID --
    ${executor}    Create Dictionary    host=${host2}      user=${user2}     password=${password2}

    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET80/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    sleep    20
    core.collect_collectors    names=coredump    target_dir=/home/ute/results
    core.teardown_collectors    names=coredump
    os.Run    tar -zxvf /home/ute/results/coredump/coredump1.log.tgz -C /home/ute/results/coredump
    os.Copy File    /home/ute/results/coredump/RMOD_L*
    ...    /home/ute/results/RMOD_L-1_NetconfRpcMessageTrace.log
    sleep    10
    ${a}=    netconf_get_value      ${netconf_file}     notification     alarm-notif     fault-text    ${fault-text3}
    run keyword and continue on failure   Should not be empty    ${a}
    ${b}=    netconf_get_value      ${netconf_file}     notification     alarm-notif     fault-id    ${Nokia_faultid3_RX}
    log    ${b}
    ${c}=    netconf_get_value      ${netconf_file}     notification     alarm-notif     fault-severity    ${fault-severity3}
    run keyword and continue on failure   Should not be empty    ${c}
    coam.get_cells_info
Step9: Cancel the fault 14 using the debug command
    RU_execute    ${UE_PC}     ${id}    ${password}    ${ru_ip}    ${ru_id}     ${ru_pass}    ${cmnd14_2}
    sleep   20
    run keyword and continue on failure     coam.assert_alarm_inactive      faultId=${Nokia_faultid3_RX}    severity=${fault-severity3}
    coam.get_cells_info
    coam.get_active_alarms

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=${scout_id1}
	log     ${node_id}

    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb

    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Wait Until Keyword Succeeds    2min    10s    Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}


Request Scout SCF
    [Arguments]    ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

