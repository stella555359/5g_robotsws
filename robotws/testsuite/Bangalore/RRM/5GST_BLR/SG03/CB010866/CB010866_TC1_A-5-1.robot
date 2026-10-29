*** Settings ***
Resource    testsuite/Bangalore/RRM/T09/CB010866/CB010866_resource.robot

Library    Collections
Library    BuiltIn
Library    String

Library    taf.sbts.oam.coam.admin     WITH NAME    coam

#Below library is for Data call
#This [ta_ultracaller folder]path should be defined in 6134_resource.robot file
Library     testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Library     SSHLibrary
Library     Process
Library     taf.transport.ssh    WITH NAME    ssh
Library     OperatingSystem    WITH NAME    os
Library     taf.ue     WITH NAME    ue

Library    DateTime
Library           taf.collectors.pmcounters    WITH NAME    PM
Library           taf.analyzer.pmcounter    WITH NAME    analyser
Library           ta5g_pm_counters

#below Keyword is to mark the test cases in QC
Library    taf.sw.scout    WITH NAME    scout

#fAULT ALARMS FOR cb01866 AND CB013138 KEYWORD
Library    ta5g_enb


#Library keyword for reporting the Test *** test cases ***
Library    ute_reporting_portal
#below TAGs are required to mark the cases in QC
#Force Tags      QCD_MN_RAN    QCP_RAN_ST
Force Tags    CA_VRF_RRM    QCD_MN_RAN    QCP_RAN_VRF    QCTSN_CB013138

Suite Setup       common_suite_setup
Suite Teardown    common_suite_teardown
Test Teardown     Test teardown

Documentation
...   DESCRIPTION:
...   The purpose of this test case is to verify CB010866-A-5-1 Verification
...   Owner:  P Hari	Krishnan


*** Variables ***
${VM_IP}=  10.41.209.2

${UE_ID}            11
${duration}=  600s
${protocol}=  UDP
${packet_size}=  1200

${OUT_LOG_PATH}=     /home/ute/logs/
@{data_transfer_protocol}=    UDP
@{UE_alias}=    UE_2
${UE_alias2}=    UE_3
@{capabilities}=    Legacy_1
#To Make VOLT\VONR Calls on UE below variable to be defined
${dt_name_voice}=    VoLTE
${dt_name_dl}    iperf_dl_test_NG    #iperf_dl_test_2
${dt_name_ul}   TEST_FTP_UL
@{throughput_dl}=    68               //@ to be used before defining the variable to make the TPT validation work
@{throughput}=    50
@{throughput_ul}=    50
@{direction_dl}=    dl
@{direction_ul}=    ul
@{deviation_dl}=      100
@{deviation_ul}=      50
@{udpcalltype}=    UDP
#timeout value in ue_config.yml file should be same as the below value for timeout
@{timeout}=    520
#attenuation of the PVA in incremental order
${ATT_START_DB}=              2
${nextAtt}=                   2             #This is vlaue from which the pva ports it was start to increment
${eNB_source_CELL_1}=         ENB_1_CELL_1
#attenuation of the PVA in deccremental order
${decAtt}=                   40             #This is vlaue from which the pva ports it was start to decrement
${eNB_source_CELL_2}=         ENB_1_CELL_1

#Direct attenuation
${ulcompincrAtt}=              90
${ulcompdecrAtt}=              0

#Fading attenuation for updated *** keywords ***
@{values1}=    0db     0db    0db    0db
@{values2}=    5dB     5dB    5dB    5dB
@{values3}=    10dB    10dB    10dB    10dB
@{values4}=    15dB    15dB    15dB    15dB
@{values5}=    20dB    20dB    20dB    20dB
@{values6}=    25dB    25dB    25dB    25dB
@{values7}=    30dB    30dB    30dB    30dB
@{values8}=    35dB    35dB    35dB    35dB
@{ports}=    9    10    11    12
${ports1}=    ${9}
${port14}=    ${14}
${port16}=    ${16}
@{at_channel}=       9    10    11    12
${at_vendor}=        TOPYOUNG
${at_model}=         TAS_16T16_0_2G6_90_1S_DEJS
${attenuator_host}=  10.53.188.15
${attenuator_port}=  ${3001}

#Give yml path for "Reserve attenuator CELL Source keyword"
${ABSTRACT_LIB_CONFIG}=    /home/ute/Downloads/ta_ue_config.yaml
# for  counter validation output
#${OUTPUT_DIR}=  /home/ute/Counter_Output
${counter_json_file}    /home/ute/counters/counter_data.json
#${log_entry}=    admin.get_pm_counters    counter_ids=M8011C67,M8011C68,M8012C151,M8011C222
${host}=   192.168.255.129
${user}=   Nemuadmin
${password}=   nemuuser
${port}=    443

${Nokia_fault}=    61524
${fault-severity}=    minor

#Cases to be marked in QC definition
${testline}     10_2_TMO95_NR
&{[1]CB010866-A-5-1_Verification of RI}   QC_ID_SBTS25R2=108826

*** Test Cases ***
[1]CB010866-A-5-1_Verification of RI based DL mitigation with RIM framework-0 or framework-1 enabled,
	[Tags]    CA_VRF_RRM    QCD_MN_RAN    QCP_RAN_VRF    4GFDD    CRT    SBTS00    QC_108826    Mark
#    coam.Connect_to   bts_host=192.168.255.129   bts_port=443
    Log To Console    \n Verification of [1]CB010866-A-5-1_framework-1 enabled,TC1
     Check Onair State
     BTS SOFTWARE INFO
     BTS FAN CHECK
     BTS HW CHECK
	 Step1[CB010866][TC1]:Login_To_BTS_95_Check_for_Fault_7525_7535_7527
     Step2[CB010866][TC1]:Cancellation_of_Fault7525
     Step3[CB010866][TC1]:Generation_of_Fault7525

[1]CB010866-D-1-1_Verification of Activation of the related measurements to monitor the counters related to symbol level average RSSI
	[Tags]    CA_SRAN_Eng2_BLR1_LTE    4GFDD    CRT    SBTS00    QC_108815    Mark
	 coam.Connect_to   bts_host=192.168.255.129   bts_port=443
    Log To Console    \n Verification of Activation of the related measurements to monitor the counters related to symbol level average RSSI
    Check Onair State
	Step1[CB010866][TC2]:Login_To_BTS_95_Check_for_Fault_7525_7535_7527
    Step2[CB010866][TC2]:Cancellation_of_Fault7525
#   StepX:Data Transfer_DL&UL
    Step3[CB010866][TC2]:Generation_of_Fault7525
    Step4[CB010866][TC2]:Counter_Validation_TC2

[1]CB010866-D-2-1_Verification of Activation of the related measurements to monitor the counters related to number of RIM-RS detected per distance
	[Tags]    CA_SRAN_Eng2_BLR1_LTE    4GFDD    CRT    SBTS00    QC_108827    Mark
	    coam.Connect_to   bts_host=192.168.255.129   bts_port=443
    Log To Console    \n Verification of [1]CB010866-D-2-1_Verification of Activation of the RIM-RS detected per distance
     Check Onair State
     Step1[CB010866][TC2]:Login_To_BTS_95_Check_for_Fault_7525_7535_7527
     Step2[CB010866][TC2]:Cancellation_of_Fault7525
     Step3[CB010866][TC2]:Generation_of_Fault7525
     Step4[CB010866][TC3]:Counter_Validation_TC3


*** Keywords ***
common_suite_setup
    coam.teardown_all_aliases_for_admin
    log    suite
    ${rep_values}    Create Dictionary
    set suite variable     ${rep_values}

common_suite_teardown
    coam.setup admin    alias=rp
    ${sw_release}=    coam.get_sw_release_name    connection=rp
    ${build}=    coam.get_sw_version    connection=rp
    coam.teardown_all_aliases_for_admin

    Link SCOUT SCF to Configuration ID for Reporting
    FOR    ${I}   IN    @{rep_values.keys()}
        ute_reporting_portal.Report To Rp    name=${I}    result=${rep_values['${I}']}ED    ca=VRF_RRM
		...    testline=${testline}    build=${build}    qc_domain=MN_RAN    tc_execution_id=${TC_ID}
        ...    qc_project=RAN_VRF     qc_id=${${I}}[QC_ID_${sw_release}]
    END

Test teardown
	set to dictionary    ${rep_values}      ${TEST NAME}    ${TEST STATUS}

Check Onair State

    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    ${Status}=   coam.get_bts_statuses
    Should Be Equal  ${Status}[proceduralState]  OnAir

BTS SOFTWARE INFO
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.get_software_info   timeout=10

BTS FAN CHECK
    coam.check_fans   timeout=50

BTS HW CHECK
    coam.check_hw   timeout=50

Verify Fault Description
    [Arguments]    ${faultid}    ${faultname}    ${description}=None  ${cell}=NRCELL-302
    ${cellid}   Catenate    SEPARATOR=    MRBTS-55057/NRBTS-55057/${cell}
    ${result}    check_alarm.check_alarm_description     ${faultid}    ${faultname}    ${description}   ${cellid}
    run keyword and continue on failure   Run Keyword if   ${result}!=${True}   Fail   Alarm is not matching

Step2[CB010866][TC1]:Cancellation_of_Fault7525
     Log To Console    \n 7525 cancellation with parameter change
     coam.Connect_to   bts_host=192.168.255.129   bts_port=443      name=admin1
     Delta Comission for Fault 7525 to Disappear
     sleep    120s
     coam.assert_alarm_active     faultId!=7525    connection=admin1
     Log To Console    \n 7525 is not generated
     builtin.wait until keyword succeeds     2m    30s     coam.assert_alarm_active     faultId=7535    connection=admin1
     Log To Console    \n 7535 generation

Step3[CB010866][TC1]:Generation_of_Fault7525
     Log To Console    \n 7525 generation wtih parameter change
     coam.Connect_to   bts_host=192.168.255.129   bts_port=443      name=admin1
     Delta Comission for Fault 7525 to Re-appear
     sleep    120s
     Log To Console    \n 7525 generation
     builtin.wait until keyword succeeds     2m    30s     coam.assert_alarm_active     faultId=7525    connection=admin1
     Log To Console    \n 7535 generation
     builtin.wait until keyword succeeds     2m    30s     coam.assert_alarm_active     faultId=7535    connection=admin1
     Log To Console    \n 7527 generation
     builtin.wait until keyword succeeds     2m    30s     coam.assert_alarm_active     faultId=7527    connection=admin1
     Log To Console    \n Fault 7525 description verification
     Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
     Log To Console    \n Fault 7535 description verification
     Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
     ...    description=DL mitigation on PDCCH special slot plus PDSCH preceding slot

Step1[CB010866][TC1]:Login_To_BTS_95_Check_for_Fault_7525_7535_7527
     coam.Connect_to   bts_host=192.168.255.129   bts_port=443      name=admin1    #BTS-95 admin connection
     coam.Connect_to   bts_host=10.41.211.245    bts_port=443      name=admin2     #BTS-53 admin connection
     coam.get active alarms    timeout=10    connection=admin1        #BTS-95 active alarms list
     coam.get active alarms    timeout=10    connection=admin2        #BTS-53 active alarms list
     builtin.wait until keyword succeeds     2m    30s     coam.assert_alarm_active     faultId=7525    connection=admin1
     builtin.wait until keyword succeeds     2m    30s     coam.assert_alarm_active     faultId=7535    connection=admin1
     builtin.wait until keyword succeeds     2m    30s     coam.assert_alarm_active     faultId=7527    connection=admin1
     Log To Console    \n Fault 7525 description verification
     Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
     Log To Console    \n Fault 7535 description verification
     Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
     ...    description=DL mitigation on PDCCH special slot plus PDSCH preceding slot


Delta Comission for Fault 7525 to Disappear
    coam.Connect_to   bts_host=10.41.211.245    bts_port=443      name=admin2
    coam.Perform Parameter Recommissioning    MRBTS-1053/NRBTS-1022/NRCELL-500   targetTotalLoad    update    0  timeout=1200    connection=admin2
    sleep  120

Delta Comission for Fault 7525 to Re-appear
    coam.Connect_to   bts_host=10.41.211.245    bts_port=443      name=admin2
    coam.Perform Parameter Recommissioning    MRBTS-1053/NRBTS-1022/NRCELL-500   targetTotalLoad    update    50   timeout=1200    connection=admin2
    sleep  120

Step1[CB010866][TC2]:Login_To_BTS_95_Check_for_Fault_7525_7535_7527
     coam.Connect_to   bts_host=192.168.255.129   bts_port=443      name=admin1    #BTS-95 admin connection
     coam.Connect_to   bts_host=10.41.211.245    bts_port=443      name=admin2     #BTS-53 admin connection
     coam.get active alarms    timeout=10    connection=admin1        #BTS-95 active alarms list
     coam.get active alarms    timeout=10    connection=admin2        #BTS-53 active alarms list
     builtin.wait until keyword succeeds     2m    30s     coam.assert_alarm_active     faultId=7525    connection=admin1
     builtin.wait until keyword succeeds     2m    30s     coam.assert_alarm_active     faultId=7535    connection=admin1
     builtin.wait until keyword succeeds     2m    30s     coam.assert_alarm_active     faultId=7527    connection=admin1
     Log To Console    \n Fault 7525 description verification
     Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
     Log To Console    \n Fault 7535 description verification
     Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
	 ...    description=DL mitigation on PDCCH special slot plus PDSCH preceding slot

Step2[CB010866][TC2]:Cancellation_of_Fault7525
     Log To Console    \n 7525 cancellation with parameter change
     coam.Connect_to   bts_host=192.168.255.129   bts_port=443      name=admin1
     Delta Comission for Fault 7525 to Disappear
     sleep    120s
     coam.assert_alarm_active     faultId!=7525    connection=admin1
     Log To Console    \n 7525 is not generated
     builtin.wait until keyword succeeds     2m    30s     coam.assert_alarm_active     faultId=7535    connection=admin1
     Log To Console    \n 7535 generation

Step3[CB010866][TC2]:Generation_of_Fault7525
     Log To Console    \n 7525 generation wtih parameter change
     coam.Connect_to   bts_host=192.168.255.129   bts_port=443      name=admin1
     Delta Comission for Fault 7525 to Re-appear
     sleep    120s
     Log To Console    \n 7525 generation
     builtin.wait until keyword succeeds     2m    30s     coam.assert_alarm_active     faultId=7525    connection=admin1
     Log To Console    \n 7535 generation
     builtin.wait until keyword succeeds     2m    30s     coam.assert_alarm_active     faultId=7535    connection=admin1
     Log To Console    \n 7527 generation
     builtin.wait until keyword succeeds     2m    30s     coam.assert_alarm_active     faultId=7527    connection=admin1
     Log To Console    \n Fault 7525 description verification
     Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
     Log To Console    \n Fault 7535 description verification
     Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
	 ...    description=DL mitigation on PDCCH special slot plus PDSCH preceding slot
     sleep    300s

Step4[CB010866][TC2]:Counter_Validation_TC2
    Log To Console    \n Counter Validation check ongoing
    coam.Connect_to   bts_host=192.168.255.129   bts_port=443      name=admin1
    ${logentry} =      PM_Counter_Check_Validation_TC_CB010866_TC2
    log    ${logentry}
    @{counter_list}=    create List    M55194C00002  M55194C00001  M55194C00029  M55194C00028  M55194C00098  M55194C00009  M55194C00003
	Counter_validation_nonzero      ${counter_list}     ${logentry}

PM_Counter_Check_Validation_TC_CB010866_TC2
    @{counter_list}=    create List    M55194C00002  M55194C00001  M55194C00029  M55194C00028  M55194C00098  M55194C00009  M55194C00003
#    ${log_entry} =    admin.get_pm_counters    counter_ids=M55194C00029,M55194C00009,M55194C00028    timeout=100
    ${log_entry} =    coam.Get Pm Counters    counter_ids=M55194C00002,M55194C00001,M55194C00029,M55194C00028,M55194C00098,M55194C00009,M55194C00003
	...    timeout=300    connection=admin1
    log    ${log_entry}
    return from keyword    ${logentry}

Step4[CB010866][TC3]:Counter_Validation_TC3
    Log To Console    \n Counter Validation check ongoing
    coam.Connect_to   bts_host=192.168.255.129   bts_port=443      name=admin1
    ${logentry} =      PM_Counter_Check_Valid_TC_CB010866_TC3
    @{counter_list}=    create List    M55194C00235  M55194C00179  M55194C00005  M55194C00007  M55194C00008  M55194C00006
	Counter_validation_nonzero      ${counter_list}     ${logentry}

PM_Counter_Check_Valid_TC_CB010866_TC3
    @{counter_list}=    create List    M55194C00235  M55194C00179  M55194C00005  M55194C00007  M55194C00008  M55194C00006
#    ${log_entry} =    admin.get_pm_counters    counter_ids=M55194C00029,M55194C00009,M55194C00028    timeout=100
    ${log_entry} =    coam.Get Pm Counters    counter_ids=M55194C00235,M55194C00179,M55194C00005,M55194C00007,M55194C00008,M55194C00006
	...    timeout=300    connection=admin1
    log    ${log_entry}
    return from keyword     ${logentry}

PM_Counter_Check_Validation_TC_CB013138_TC1_Equal_To_Zero
    @{counter_list}=    create List    M55194C00005  M55194C00006
#    ${log_entry} =    admin.get_pm_counters    counter_ids=M55194C00029,M55194C00009,M55194C00028    timeout=100
    ${log_entry} =    coam.Get Pm Counters    counter_ids=M55194C00005,M55194C00006    timeout=180
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
        ${count}=    set variable    ${log_entry ['BTS']['MRBTS-55057']['NRBTS-55057']['NRCELL-302']['NRIM']['${pi_id}']}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        Log    ${pi_value}
        ${value}=    evaluate    ${pi_value}==0
	Run Keyword IF    '${value}' != '0'    Log    ${counter_List}    ELSE    Log    '${value}' is equal to 0
    END

PM_Counter_Check_Validation_TC_CB013138_TC1_NOT_Equal_To_Zero
    @{counter_list}=    create List    M55194C00005  M55194C00006
#    ${log_entry} =    admin.get_pm_counters    counter_ids=M55194C00029,M55194C00009,M55194C00028    timeout=100
    ${log_entry} =    coam.Get Pm Counters    counter_ids=M55194C00005,M55194C00006    timeout=180    connection=admin1
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
        ${count}=    set variable    ${log_entry ['BTS']['MRBTS-55057']['NRBTS-55057']['NRCELL-302']['NRIM']['${pi_id}']}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        Log    ${pi_value}
        ${value}=    evaluate    ${pi_value}!=0
	Run Keyword IF    '${value}' == '0'    Log    ${counter_List}    ELSE    Log    '${value}' is equal to 0
    END

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=10_2_TMO95_NR
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"    Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    Log To Console    ${\n}Node_id is : ${node_id}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ${external_scf_id}
    set suite variable   ${TC_ID}

Counter_validation_nonzero
    [Arguments]   ${counter_list}      ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
        ${count}=    set variable    ${log_entry ['BTS']['MRBTS-55057']['NRBTS-55057']['NRCELL-302']['NRIM']['${pi_id}']}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        Log    ${pi_value}
        ${value}=    evaluate    ${pi_value}!=0
	Run Keyword IF    '${value}' != '0'    Log    ${counter_List}    ELSE    Log    '${value}' is equal to 0
    END

Counter_validation_zero
    [Arguments]   ${counter_list}      ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
        ${count}=    set variable    ${log_entry ['BTS']['MRBTS-55057']['NRBTS-55057']['NRCELL-302']['NRIM']['${pi_id}']}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        Log    ${pi_value}
        ${value}=    evaluate    ${pi_value}==0
	Run Keyword IF    '${value}' == '0'    Log    ${counter_List}    ELSE    Log    '${value}' is equal to 0
    END
