*** Settings ***
Documentation
...                 DESCRIPTION:
...                 The purpose of this test case is to verify CB010866 Verification
...                 Owner:    P Hari    Krishnan

# The below resource file is to be added for Counter validation to PASS
Resource            testsuite/Bangalore/RRM/T03/TMO/CB010866/config/CB010866_resource.robot
Library             Collections
Library             BuiltIn
Library             String
Library             taf.sbts.oam.coam.admin    WITH NAME    coam
Library             SSHLibrary
Library             Process
Library             taf.transport.ssh    WITH NAME    ssh
Library             OperatingSystem    WITH NAME    os
Library             taf.ue    WITH NAME    ue
Library             DateTime
Library             taf.collectors.pmcounters    WITH NAME    PM
Library             taf.analyzer.pmcounter    WITH NAME    analyser
Library             ta5g_pm_counters
# below Keyword is to mark the test cases in QC
Library             taf.sw.scout    WITH NAME    scout
# fAULT ALARMS FOR cb01866 AND CB013138 KEYWORD
Library             ta5g_enb
# Library keyword for reporting the Test *** test cases ***
Library             ute_reporting_portal
Library             taf.sw.reporting_portal

Suite Setup         common_suite_setup
Suite Teardown      common_suite_teardown
Test Teardown       Test teardown

# below TAGs are required to mark the cases in QC
# Force Tags    QCD_MN_RAN    QCP_RAN_ST
Force Tags          ca_vrf_rrm    qcd_mn_ran    qcp_ran_vrf    qctsn_cb013138


*** Variables ***
${VM_IP}=  10.43.54.70
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
#${ABSTRACT_LIB_CONFIG}=    /home/ute/Downloads/ta_ue_config.yaml
# for  counter validation output
#${OUTPUT_DIR}=  /home/ute/Counter_Output
#${counter_json_file}    /home/ute/counters/counter_data.json
#${log_entry}=    admin.get_pm_counters    counter_ids=M8011C67,M8011C68,M8012C151,M8011C222
${host}=   192.168.255.129
${user}=   Nemuadmin
${password}=   nemuuser
${port}=    443

${Nokia_fault}=    61524
${fault-severity}=    minor

#Cases to be marked in QC definition
${testline}     10_2_TMO95_NR
&{[1]CB010866-D-1-1_Verification}    QC_ID_SBTS26R1=108815
&{[1]CB010866-D-2-1_Verification}    QC_ID_SBTS26R1=108827
&{[1]CB010866-A-5-1_Verification}    QC_ID_SBTS26R1=108826
&{[1]CB010866-B-3-1_Verification}    QC_ID_SBTS26R1=108828


${log_entry}     ${EMPTY}


*** Test Cases ***
[1]CB010866-B-3-1_Verification
    [Tags]    ca_vrf_rrm    qcd_mn_ran    qcp_ran_vrf    4gfdd    crt    sbts00    qc_108828    mark
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    Log To Console
    ...    \n Verification of [1]CB010866-A-5-1_framework-1 enabled, no RIM-RS is detected before RI disappears TC1
    Check Onair State
    BTS SOFTWARE INFO
    BTS FAN CHECK
    BTS HW CHECK
    Step1[CB010866][TC1]:Login_To_BTS_95_Check_for_Fault_7525_7535_7527

[1]CB010866-A-5-1_Verification
    [Tags]    ca_vrf_rrm    qcd_mn_ran    qcp_ran_vrf    4gfdd    crt    sbts00    qc_108826    mark
#    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    Log To Console
    ...    \n Verification of [1]CB010866-A-5-1_framework-1 enabled, no RIM-RS is detected before RI disappears TC1
    Check Onair State
    BTS SOFTWARE INFO
    BTS FAN CHECK
    BTS HW CHECK
    Step1[CB010866][TC1]:Login_To_BTS_95_Check_for_Fault_7525_7535_7527
    Step2[CB010866][TC1]:Cancellation_of_Fault7525
    Step3[CB010866][TC1]:Generation_of_Fault7525

[1]CB010866-D-1-1_Verification
    [Tags]    ca_sran_eng2_blr1_lte    4gfdd    crt    sbts00    qc_108815    mark
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    Log To Console
    ...    \n Verification of Activation of the related measurements to monitor the counters related to symbol level average RSSI
    Check Onair State
    Step1[CB010866][TC2]:Login_To_BTS_95_Check_for_Fault_7525_7535_7527
    Step2[CB010866][TC2]:Cancellation_of_Fault7525
    Step3[CB010866][TC2]:Generation_of_Fault7525
    Step4[CB010866][TC2]:Counter_Validation_TC2

[1]CB010866-D-2-1_Verification
    [Tags]    ca_sran_eng2_blr1_lte    4gfdd    crt    sbts00    qc_108827    mark
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    Check Onair State
    Step1[CB010866][TC2]:Login_To_BTS_95_Check_for_Fault_7525_7535_7527
    Step2[CB010866][TC2]:Cancellation_of_Fault7525
    Step3[CB010866][TC2]:Generation_of_Fault7525
    Step4[CB010866][TC3]:Counter_Validation_TC3


*** Keywords ***
common_suite_setup
    coam.teardown_all_aliases_for_admin
    log    suite
    ${rep_values}=    Create Dictionary
    set suite variable    ${rep_values}

common_suite_teardown
    coam.setup admin    alias=rp
    ${sw_release}=    coam.get_sw_release_name    connection=rp
    ${build}=    coam.get_sw_version    connection=rp
    coam.teardown_all_aliases_for_admin

    Link SCOUT SCF to Configuration ID for Reporting
    FOR    ${I}    IN    @{rep_values.keys()}
        taf.sw.reporting_portal.Report To Rp    name=${I}    result=${rep_values['${I}']}ED    ca=VRF_RRM
        ...    testline=${testline}    build=${build}    qc_domain=MN_RAN    tc_execution_id=${TC_ID}
        ...    qc_project=RAN_VRF    qc_id=${${I}}[QC_ID_${sw_release}]
    END

Test teardown
    set to dictionary    ${rep_values}    ${TEST NAME}    ${TEST STATUS}

Verify Fault Description
    [Arguments]    ${faultid}    ${faultname}    ${description}=None    ${cell}=NRCELL-302
    ${cellid}=    Catenate    SEPARATOR=    MRBTS-55057/NRBTS-55057/${cell}
    ${result}=    check_alarm.check_alarm_description    ${faultid}    ${faultname}    ${description}    ${cellid}
    run keyword and continue on failure    Run Keyword if    ${result}!=${True}    Fail    Alarm is not matching

PM_Counter_Check_Validation_TC_CB010866_TC3
    @{counter_list}=    create List
    ...    M55194C00235
    ...    M55194C00179
    ...    M55194C00005
    ...    M55194C00007
    ...    M55194C00008
    ...    M55194C00006
#    ${log_entry} =    admin.get_pm_counters    counter_ids=M55194C00029,M55194C00009,M55194C00028    timeout=100
    ${log_entry}=    coam.Get Pm Counters
    ...    counter_ids=M55194C00235,M55194C00179,M55194C00005,M55194C00007,M55194C00008,M55194C00006
    ...    timeout=180
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
        ${count}=    set variable
        ...    ${log_entry ['BTS']['MRBTS-55057']['NRBTS-55057']['NRCELL-302']['NRIM']['${pi_id}']}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        Log    ${pi_value}
        ${value}=    evaluate    ${pi_value}!=0
        IF    '${value}' != '0'
            Log    ${counter_List}
        ELSE
            Log    '${value}' is equal to 0
        END
    END

PM_Counter_Check_Validation_TC_CB013138_TC1_Equal_To_Zero
    @{counter_list}=    create List    M55194C00005    M55194C00006
#    ${log_entry} =    admin.get_pm_counters    counter_ids=M55194C00029,M55194C00009,M55194C00028    timeout=100
    ${log_entry}=    coam.Get Pm Counters    counter_ids=M55194C00005,M55194C00006    timeout=180
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
        ${count}=    set variable
        ...    ${log_entry ['BTS']['MRBTS-55057']['NRBTS-55057']['NRCELL-302']['NRIM']['${pi_id}']}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        Log    ${pi_value}
        ${value}=    evaluate    ${pi_value}==0
        IF    '${value}' != '0'
            Log    ${counter_List}
        ELSE
            Log    '${value}' is equal to 0
        END
    END

PM_Counter_Check_Validation_TC_CB013138_TC1_NOT_Equal_To_Zero
    @{counter_list}=    create List    M55194C00005    M55194C00006
#    ${log_entry} =    admin.get_pm_counters    counter_ids=M55194C00029,M55194C00009,M55194C00028    timeout=100
    ${log_entry}=    coam.Get Pm Counters    counter_ids=M55194C00005,M55194C00006    timeout=180    connection=admin1
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
        ${count}=    set variable
        ...    ${log_entry ['BTS']['MRBTS-55057']['NRBTS-55057']['NRCELL-302']['NRIM']['${pi_id}']}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        Log    ${pi_value}
        ${value}=    evaluate    ${pi_value}!=0
        IF    '${value}' == '0'
            Log    ${counter_List}
        ELSE
            Log    '${value}' is equal to 0
        END
    END

Start DL Data Transfer
    ta_ultracaller.require_ue    ${UE_alias}    ${capabilities}
    log to console    Detaching UE
    ta_ultracaller.Detach_UE    ue_alias=${UE_alias}
    log to console    Attaching UE
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
    sleep    10s
    ta_ultracaller.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
    log to console    Waiting data transfer to finish
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_dl}    ${timeout}

Perform DownLink Data Transfer
    ta_ultracaller.require_ue    ${UE_alias}    ${capabilities}
    log to console    Detaching UE
    ta_ultracaller.Detach_UE    ue_alias=${UE_alias}
    log to console    Attaching UE
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
    sleep    10s
    log to console    Data Transfer started
    ta_ultracaller.start_datatransfer
    ...    ue_alias=${UE_alias}
    ...    direction=${direction_dl}
    ...    protocoltype=${data_transfer_protocol}
    sleep    60s
    log to console    Waiting data transfer to finish
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_dl}    ${timeout}

Verify BTS PM counter Result
    # [Arguments]    ${log_entry}
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    @{counter_list}=    create List    'M55114C01505'    'M55114C01502'
    ${log_entry}=    coam.get_pm_counters    counter_ids=M55114C01505,M55114C01502    timeout=100    connection=None
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
#    ${count}=    set variable    ${log_entry['BTS_194']['CELLS']['NRCELL-4']['RACCU'][${pi_id}]}
        ${count}=    set variable    ${log_entry['BTS_194']['MRBTS-194]['NRBTS-194']['NRCELL-4']['RACCU'][${pi_id}]}
        # The above path of the counter fetched as per admin given
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}    # Validate latest updated counter
        # ${pi_value}=    Set Variable    ${log_entry.get_pi_value(pi_id="${pi_id}")}
        Log    ${pi_value}
        ${value}=    evaluate    ${pi_value}>=0
        should be true    ${value}
    END

Perform Voice call
    log to console    start Volte call
    ta_ultracaller.Require Ue    ${UE_alias}    ${capabilities}
    log to console    Detaching UE
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    log to console    Attaching UE
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
    sleep    10s
    ta_ultracaller.Start Voice call    ${UE_alias}    ${dt_name_voice}
    sleep    15s

POWER RESET
    Log to console    BTS POWER Reset Site
    coam.Connect to    bts_host=192.168.255.129    bts_port=443
    coam.power_reset    timeout=1200    detailed_output=False    connection=None
    sleep    600
    coam.teardown_admin

Perform BTS Site Reset
    Log to console    Reset Site
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.reset    timeout=2000
    sleep    600
    coam.teardown_admin

Site Block Unblock
    Log to console    Site Block and Unblock
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.block    timeout=2000
    sleep    240
    coam.unblock    timeout=2000
    sleep    240
    coam.teardown_admin

Logs Collection
    coam.Connect_to    192.168.255.129    443    use_ssl=True    timeout=100
    Run Keyword And Ignore Error    Remove Directory    /home/ute/new/${TEST_NAME}
    Run Keyword And Ignore Error    Create Directory    /home/ute/new/${TEST_NAME}
#    Run keyword and ignore error    Create Directory    /home/ute/syslogs/${TEST_NAME}/SYSLOGS
    coam.Get Active Alarms
    Collect Im Snapshot    /home/ute/new/${TEST_NAME}/ims.ims2
    Collect Snapshot    /home/ute/new/${TEST_NAME}/snapshot.zip
    coam.teardown_admin

Reserve UE for tests
    Require Ue    UE_1    capabilities=Legacy_1

Attach UE for test
    Attach Ue    UE_1

Start Call
    Prepare UE    UE_alias=${UE_alias}    capabilities=${capabilities}    timeout=${timeout}
    Attach ue and run throughput
    ...    ${UE_alias}
    ...    ${dt_name_ul}
    ...    ${direction_ul}
    ...    ${throughput_ul}
    ...    ${deviation_ul}
    ...    ${timeout}

Counter Validation
    Log To Console    \n Counter checking

    ${Counter_File}=    Wait Until Keyword Succeeds
    ...    5min
    ...    10s
    ...    download_latest_pmcounter
    ...    local_path=${OUT_LOG_PATH}
    ...    source_path=/tmp/
    ...    suffix=gz
    @{Counter_list}=    Create list    M55114C01502    M55114C01508    M55114C01505    M55308C10008    M55308C00019

    FOR    ${I}    IN RANGE    5
        log    ${Counter_list[${I}]}
        Check RTWP PM counters    ${Counter_list[${I}]}    ${Counter_File}
    END
    interface.common_step_trigger

Check RTWP PM counters
    [Arguments]    ${Id}    ${Counter_File}

    log    ${Id}
    FOR    ${I}    IN RANGE    4
        ${RTWP}=    run_keyword_and_ignore_error
        ...    ta_kiss_bts.get_counter_value_from_counter_file
        ...    ${Counter_File}
        ...    ${Id}
        IF    '${RTWP}'=='PASS'    BREAK
    END
    run_keyword_and_ignore_error    Log    ${RTWP}[1]
    Should Be True    ${RTWP}[1] >= 0

Fault_Admin
#    [Arguments]    ${FaultId}    @{Faults}
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    # Mplane Ip of the present testline to be given
    ${index}=    Set variable    0
    @{K2}=    Create List
    ...    4655
    ...    4654
    ...    2001
    ...    6327
    ...    1898
    ...    4467
    ...    49
    ...    7319
    ...    61649
    ...    61524
    ...    6150
    ...    4297
    ...    61652
    ...    4072
    ...    7459
    ...    10
    @{Alarms}=    coam.Get Active Alarms
    FOR    ${i}    IN    @{Alarms}
        ${v}=    Set Variable    ${Alarms[${index}]['faultId']}
        ${a}=    Convert To String    ${v}
        Log    ${v}
        List Should Contain Value    ${K2}    ${a}
        ${index}=    Evaluate    ${index}+1
    END
    coam.teardown_admin

Check Onair State
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    ${Status}=    coam.get_bts_statuses
    Should Be Equal    ${Status}[proceduralState]    OnAir

Check Onair State Neighbour BTS 53
    coam.Connect_to    bts_host=10.41.211.245    bts_port=443
    log to console    WEBADMIN BTS-53 is conneting
    ${Status}=    coam.get_bts_statuses
    Should Be Equal    ${Status}[proceduralState]    OnAir

# Delta Comission For BTS 53 For parameter TargetTotalLoad
#    log to console    \n Delta Comission For BTS 53 For parameter TargetTotalLoad
#    coam.Connect_to    bts_host=10.41.211.245    bts_port=443
#    log to console    \n targetTotalLoad for NRCELL-500 on BTS53 setting to value 0%
#    coam.Perform Parameter Recommissioning    MRBTS-1053/NRBTS-1022/NRCELL-500    targetTotalLoad    update    0    timeout=1200
#    sleep    120
#    log to console    \n targetTotalLoad for NRCELL-500 on BTS53 setting to value 100%
#    coam.Perform Parameter Recommissioning    MRBTS-1053/NRBTS-1022/NRCELL-500    targetTotalLoad    update    100    timeout=1200
#    sleep    120

Delta Comission for Fault 7525 to Disappear
    coam.Connect_to    bts_host=10.41.211.245    bts_port=443    name=admin2
#    coam.perform_delta_recommissioning    /home/ute/Desktop/HariRaj/Automation/CB010866/config
#    ...     /SBTS25R1/Delta_Configuration_NRCELL_500_gNB2_RI_disappear.json    skip_parameter_relation_errors=false    =1200    connection=admin1
    coam.Perform Parameter Recommissioning
    ...    MRBTS-1053/NRBTS-1022/NRCELL-500
    ...    targetTotalLoad
    ...    update
    ...    0
    ...    timeout=1200
    ...    connection=admin2
    sleep    120

Delta Comission for Fault 7525 to Re-appear
    coam.Connect_to    bts_host=10.41.211.245    bts_port=443    name=admin2
#    coam.perform_delta_recommissioning    /home/ute/Desktop/HariRaj/Automation/CB010866/config/SBTS25R1/
#    ...     Delta_Configuration_NRCELL_500_gNB2_RI_appear.json
#   ...  skip_parameter_relation_errors=false    =1200    connection=admin1
    coam.Perform Parameter Recommissioning
    ...    MRBTS-1053/NRBTS-1022/NRCELL-500
    ...    targetTotalLoad
    ...    update
    ...    100
    ...    timeout=1200
    ...    connection=admin2
    sleep    120

Delta Comission for Fault 7527 to Disappear
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1
    coam.perform_delta_recommissioning
    ...    testsuite/Bangalore/RRM/T03/TMO/CB010866/config/rsDistanceThreshold_Cancel.json
    ...    skip_parameter_relation_errors=false
    ...    =1200
    ...    connection=admin1
    sleep    120

Delta Comission for Fault 7527 to Appear
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1
    coam.perform_delta_recommissioning
    ...    testsuite/Bangalore/RRM/T03/TMO/CB010866/config/rsDistanceThreshold_Appear.json
    ...    skip_parameter_relation_errors=false
    ...    =1200
    ...    connection=admin1
    sleep    120

BTS SOFTWARE INFO
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.get_software_info    timeout=10

BTS FAN CHECK
    coam.check_fans    timeout=50

BTS HW CHECK
    coam.check_hw    timeout=50

post treatment
    [Documentation]    Add SKIP_REPORT to skip report to reporting portal of failed test if ${SKIP_REPORT_FAILED_TESTS}=1
    ...    get rrh infos before releasing infomodel context (add it to jenkins mail report)
    interface.Common step trigger
    # skip QC reporting
    ${is_skip_report_var}=    Run Keyword And Return Status    Variable Should Exist    ${SKIP_REPORT_FAILED_TESTS}
    # get rrh infos before releasing infomodel context
    ${status}    ${RRH_USED}=    run keyword and ignore error    get RF module name from cell    ${host_cell}
    IF    ${is_skip_report_var} == False
        Set test Variable    ${SKIP_REPORT_FAILED_TESTS}    0
    END
    # Run Keyword If Test Failed    Run keyword if    '${SKIP_REPORT_FAILED_TESTS}'=='1'    set tags    SKIP_REPORT
    # Run Keyword If Test Failed    Get eNodeB alarms
    # log to console    Test Status : ${TEST NAME} => ${TEST STATUS}
    Link SCOUT SCF to Configuration ID for Reporting

Request Scout SCF
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    [Arguments]    ${scout_testline_name}
    scout.setup_scout    scout_testline_name=${scout_testline_name}
    ${external_scf_id}=    scout.request_scf    use_scout_internal_id=True
    scout.teardown_scout_api
    RETURN    ${external_scf_id}

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...    |    Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...    |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...    |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=10_2_TMO95_NR
    IF    "${node_type}"=="gnb"
        ${node_type_Name}=    Set Variable    gNB
    ELSE IF    "${node_type}"=="enb"
        ${node_type_Name}=    Set Variable    eNB
    ELSE
        ${node_type_Name}=    Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    END
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    Log To Console    ${\n}Node_id is : ${node_id}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=    Request Scout SCF    ${scout_testline_name}
    ${TC_ID}=    Set Variable    ${external_scf_id}
    set suite variable    ${TC_ID}

UL Data with Attenuation for UE1
    ta_ultracaller.require_ue    ${UE_alias}    ${capabilities}
    log to console    Detaching UE
    ta_ultracaller.Detach_UE    ue_alias=${UE_alias}
    log to console    Attaching UE
    ta_ultracaller.Attach_UE    ue_alias=${UE_alias}
    sleep    10s
    log to console    Data Transfer started
    ta_ultracaller.start_datatransfer
    ...    ue_alias=${UE_alias}
    ...    direction=${direction_ul}
    ...    protocoltype=${data_transfer_protocol}
    sleep    20s
    setup_attenuator
    FOR    ${index}    IN RANGE    0    20
        ${out_signal_quality}=    ta_ultracaller.validate_ue_info    ${UE_alias}    SIGNAL_STRENGTH
        log    ${out_signal_quality}
        # Run Keyword If    ((${out_signal_quality}[UE_1] <= -115))    Exit For Loop
        Reserve attenuator CELL Source    ${eNB_source_CELL_1}
        sleep    2s
        log    ${nextAtt}
        log    ${out_signal_quality}
        # log    ${out_signal_quality2}
        ta_attenuator.Set attenuation    ${eNB_source_CELL_1}    ${nextAtt}dB
        ${nextAtt}=    nextattenuation    att=${nextAtt}    incr=${2}
        sleep    5s
    END
    sleep    20s
    FOR    ${index}    IN RANGE    0    20
        ${out_signal_quality}=    ta_ultracaller.validate_ue_info    ${UE_alias}    SIGNAL_STRENGTH
        log    ${out_signal_quality}
        # Run Keyword If    ((${out_signal_quality}[UE_1] <= -115))    Exit For Loop
        Reserve attenuator CELL Source1    ${eNB_source_CELL_2}
        sleep    2s
        log    ${decAtt}
        log    ${out_signal_quality}
        # log    ${out_signal_quality2}
        ta_attenuator.Set attenuation    ${eNB_source_CELL_2}    ${decAtt}dB
        ${decAtt}=    decattenuation    att=${decAtt}    decr=${2}
        sleep    5s
    END
    log to console    Waiting data transfer to finish
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_ul}    ${timeout}

Reserve attenuator CELL Source
    [Documentation]    Identify and reserve TL attenuator's CELLs SOURCE
    [Arguments]    ${eNB_source_CELL_1}
    Log To Console    \n Loading the TL attenuator SOURCE configuration...
    # if no param then read os.environ variable TA_ATTENUATOR_CONFIG
    Load Attenuation Config
    ...    ${ABSTRACT_LIB_CONFIG}
    Log To Console    \n Reserving the cell ${eNB_source_CELL_1} of the TL attenuator SOURCE...
    Require attenuator setup of    ${eNB_source_CELL_1}

Reserve attenuator CELL Source1
    [Documentation]    Identify and reserve TL attenuator's CELLs SOURCE
    [Arguments]    ${eNB_source_CELL_2}
    Log To Console    \n Loading the TL attenuator SOURCE configuration...
    # if no param then read os.environ variable TA_ATTENUATOR_CONFIG
    Load Attenuation Config
    ...    ${ABSTRACT_LIB_CONFIG}
    Log To Console    \n Reserving the cell ${eNB_source_CELL_2} of the TL attenuator SOURCE...
    Require attenuator setup of    ${eNB_source_CELL_2}

CB008955 Counter Validation
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    @{counter_list}=    create List    'M55308C10008'    'M55308C00019'
    ${log_entry}=    coam.get_pm_counters    counter_ids=M55308C10008,M55308C00019    timeout=100    connection=None
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
        ${count}=    set variable    ${log_entry['BTS']['CELLS']['NRCELL-1']['NCELA'][${pi_id}]}
        # The above path of the counter fetched as per admin given
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}    # Validate latest updated counter
        # ${pi_value}=    Set Variable    ${log_entry.get_pi_value(pi_id="${pi_id}")}
        Log    ${pi_value}
        ${value}=    evaluate    ${pi_value}>=0
        should be true    ${value}
    END

Direct attenuation
    log to console    90db set
    Reserve attenuator CELL Source    ${eNB_source_CELL_1}
    sleep    2s
    log    ${ulcompincrAtt}
    ta_attenuator.Set attenuation    ${eNB_source_CELL_1}    ${ulcompincrAtt}dB
    sleep    2s
    log to console    0db set
    Reserve attenuator CELL Source    ${eNB_source_CELL_1}
    sleep    5s
    log    ${ulcompdecrAtt}
    ta_attenuator.Set attenuation    ${eNB_source_CELL_1}    ${ulcompdecrAtt}dB

BB Operations
    Log to console    Baseband Lock
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.lock    dist_name=MRBTS-194/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1    timeout=2000
    sleep    60
    coam.teardown_admin

    Log to console    Baseband UnLock
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.unlock    dist_name=MRBTS-194/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1    timeout=2000
    sleep    60
    coam.teardown_admin

    Log to console    BBMOD RESET
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.reset_unit    dist_name=MRBTS-194/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1    reset_type=Hard    timeout=2000
    sleep    240
    coam.teardown_admin

NR RAT Operations
    Log to console    NR RAT RESET
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.rat_reset    NR    timeout=2000
    sleep    60
    coam.teardown_admin

    Log to console    NR RAT BLOCK
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.block_rat    NR    timeout=2000
    sleep    60
    coam.teardown_admin

    Log to console    NR RAT UNBLOCK
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.unblock_rat    NR    timeout=2000
    sleep    60
    coam.teardown_admin

RMOD Operations
    Log to console    RFM reset
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.reset_unit    dist_name=MRBTS-194/EQM-1/APEQM-1/RMOD-3    timeout=2000
    sleep    360
    coam.teardown_admin

    Log to console    RFM LOCK
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.lock    dist_name=MRBTS-194/EQM_R-1/APEQM_R-1/RMOD_R-3    timeout=2000
    sleep    360
    coam.teardown_admin

    Log to console    RFM UNLOCK
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.unlock    dist_name=MRBTS-194/EQM_R-1/APEQM_R-1/RMOD_R-3    timeout=2000
    sleep    360
    coam.teardown_admin

AMF Operations
    Log to console    AMF LOCK
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.lock_ng_link    MRBTS-194/NRBTS-194/SERVEDAMF-1    timeout=1200

    Log to console    AMF UNLOCK
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.unlock_ng_link    MRBTS-194/NRBTS-194/SERVEDAMF-1    timeout=1200

Step1[CB013138][TC2]:rimDlMutingMaxRange=DL+special slots[Serving] rimDLMitigationManualTrigger=disabled[Serving]manualframeoffset=607[Neighbour]
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    # BTS-95 admin connection
    Log To Console
    ...    \n rimDlMutingMaxRange=DL+special slots[Serving] rimDLMitigationManualTrigger=disabled is set on BTS-95
    Log To Console    \n manualframeoffset=607 is set on BTS-53
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7535    connection=admin1
    Log To Console    \n Fault 7535 generated
    Log To Console    \n Fault 7535 description verification
    Verify Fault Description
    ...    faultid=${7535}
    ...    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH and PDCCH special slot plus the PDSCH preceding slot
    Log To Console    \n All Counters to be incremented M55194C00281,M55194C00003,M55194C00001 but M55194C00282
    ${logentry}=    PM_Counter_Check_Validation_TC_CB013138_TC2_Step3
    @{counter_list}=    create List    M55194C00281    M55194C00003    M55194C00001
    Counter_validation_nonzero    ${counter_list}    ${logentry}
    @{counter_list}=    create List    M55194C00282
    Counter_validation_zero    ${counter_list}    ${logentry}

Step2[CB013138][TC2]:rimDlMutingMaxRange=2DL+special slots[Serving] rimDLMitigationManualTrigger=disabled[Serving]manualframeoffset=929[Neighbour]
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    # BTS-95 admin connection
    coam.perform_delta_recommissioning
    ...    testsuite/Bangalore/RRM/T03/TMO/CB010866/config/2DL_plus_Special_Slots__disabled.json
    ...    skip_parameter_relation_errors=false
    ...    =1200
    ...    connection=admin1
    Log To Console
    ...    \n rimDlMutingMaxRange=2DL+special slots[Serving] rimDLMitigationManualTrigger=disabled is set on BTS-95
    sleep    120
    coam.Connect_to    bts_host=10.41.211.245    bts_port=443    name=admin2    # BTS-53 admin connection
    coam.perform_delta_recommissioning
    ...    testsuite/Bangalore/RRM/T03/TMO/CB010866/config/manualframeoffset_929_CB013138.json
    ...    skip_parameter_relation_errors=false
    ...    =1200
    ...    connection=admin2
    Log To Console    \n manualframeoffset=929 is set on BTS-53
    sleep    400
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7535    connection=admin1
    Log To Console    \n Fault 7535 generated
    sleep    300
    Log To Console    \n All Counters to be incremented M55194C00282,M55194C00281,M55194C00003,M55194C00001
#    PM_Counter_Check_Validation_TC_CB013138_TC2_Step2    connection=admin1
    ${logentry}=    PM_Counter_Check_Validation_TC_CB013138_TC2_Step3
    @{counter_list}=    create List    M55194C00281    M55194C00003    M55194C00001    M55194C00282
    Counter_validation_nonzero    ${counter_list}    ${logentry}

Step3[CB013138][TC2]:rimDlMutingMaxRange=DL+special slots[Serving] rimDLMitigationManualTrigger=disabled[Serving]manualframeoffset=929[Neighbour]
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    # BTS-95 admin connection
    Log To Console    \n These Counters to be incremented M55194C00281,M55194C00003,M55194C00001 but not M55194C00282
#    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    ${logentry}=    PM_Counter_Check_Validation_TC_CB013138_TC2_Step3
    @{counter_list}=    create List    M55194C00281    M55194C00003    M55194C00001
    Counter_validation_nonzero    ${counter_list}    ${logentry}
    @{counter_list}=    create List    M55194C00282
    Counter_validation_zero    ${counter_list}    ${logentry}

Step4[CB013138][TC2]:rimDlMutingMaxRange=DL+special slots[Serving] rimDLMitigationManualTrigger
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    # BTS-95 admin connection
    Log To Console    \n manualframeoffset=929 is set on BTS-53
    coam.perform_delta_recommissioning
    ...    testsuite/Bangalore/RRM/T03/TMO/CB010866/config/
    ...    DL_plus_special_slots__2DL_plus_special_slots_muting.json
    ...    skip_parameter_relation_errors=false
    ...    =1200
    ...    connection=admin1
    Log To Console
    ...    \n rimDlMutingMaxRange=DL+special slots[Serving] rimDLMitigationManualTrigger=2DL+special slots muting[Serving] is set on BTS-95
    sleep    200
    coam.assert_alarm_active    faultId!=7535    connection=admin1
    Log To Console    \n Fault 7535 is cancelled
    sleep    300
    Log To Console    \n All Counters to be incremented M55194C00282,M55194C00281,M55194C00003,M55194C00001
#    PM_Counter_Check_Validation_TC_CB013138_TC2_Step4    connection=admin1
    ${logentry}=    PM_Counter_Check_Validation_TC_CB013138_TC2_Step3
    @{counter_list}=    create List    M55194C00281    M55194C00003    M55194C00001    M55194C00282
    Counter_validation_nonzero    ${counter_list}    ${logentry}

Step5[CB013138][TC2]:rimDlMutingMaxRange=DL+special slots[Serving] rimDLMitigationManualTrigger=disabled[Serving]manualframeoffset=929[Neighbour]
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    # BTS-95 admin connection
    coam.perform_delta_recommissioning
    ...    testsuite/Bangalore/RRM/T03/TMO/CB010866/config/DL_plus_special_slots__disabled_Step5_TC2.json
    ...    skip_parameter_relation_errors=false
    ...    =1200
    ...    connection=admin1
    sleep    180
    Log To Console    \n Manualframeoffset on BTS53 neighbour already set to 929
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7535    connection=admin1
    Log To Console    \n Fault 7535 generated
    Log To Console    \n Fault 7535 description verification
    Verify Fault Description
    ...    faultid=${7535}
    ...    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH and PDCCH special slot plus the PDSCH preceding slot
    sleep    300
    Log To Console    \n These Counters to be incremented M55194C00281,M55194C00003,M55194C00001 but not M55194C00282
#    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    ${logentry}=    PM_Counter_Check_Validation_TC_CB013138_TC2_Step3
    @{counter_list}=    create List    M55194C00281    M55194C00003    M55194C00001
    Counter_validation_nonzero    ${counter_list}    ${logentry}
    @{counter_list}=    create List    M55194C00282
    Counter_validation_zero    ${counter_list}    ${logentry}

Step6[CB013138][TC2]:rimDlMutingMaxRange=DL+special slots[Serving] rimDLMitigationManualTrigger=disabled[Serving]manualframeoffset=607[Neighbour]
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    # BTS-95 admin connection
    coam.perform_delta_recommissioning
    ...    testsuite/Bangalore/RRM/T03/TMO/CB010866/config/DL_plus_special_slots__disabled.json
    ...    skip_parameter_relation_errors=false
    ...    =1200
    ...    connection=admin1
    Log To Console
    ...    \n rimDlMutingMaxRange=DL+special slots[Serving] rimDLMitigationManualTrigger=disabled iset on BTS 95
    sleep    120
    coam.Connect_to    bts_host=10.41.211.245    bts_port=443    name=admin2    # BTS-53 admin connection
    coam.perform_delta_recommissioning
    ...    testsuite/Bangalore/RRM/T03/TMO/CB010866/config/manualframeoffset_607_CB013138.json
    ...    skip_parameter_relation_errors=false
    ...    =1200
    ...    connection=admin2
    Log To Console    \n Manualframeoffset on BTS53 neighbour already set to 607
    sleep    400
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7535    connection=admin1
    Log To Console    \n Fault 7535 generated
    Log To Console    \n Fault 7535 description verification
    Verify Fault Description
    ...    faultid=${7535}
    ...    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH and PDCCH special slot plus the PDSCH preceding slot
    sleep    300
    ${logentry}=    PM_Counter_Check_Validation_TC_CB013138_TC2_Step3
    @{counter_list}=    create List    M55194C00281    M55194C00003    M55194C00001
    Counter_validation_nonzero    ${counter_list}    ${logentry}
    @{counter_list}=    create List    M55194C00282
    Counter_validation_zero    ${counter_list}    ${logentry}

PM_Counter_Check_Validation_TC_CB013138_TC2_Step2
    @{counter_list}=    create List    M55194C00282    M55194C00281    M55194C00003    M55194C00001
#    ${log_entry} =    admin.get_pm_counters    counter_ids=M55194C00029,M55194C00009,M55194C00028    timeout=100
    ${log_entry}=    coam.Get Pm Counters
    ...    counter_ids=M55194C00282,M55194C00281,M55194C00003,M55194C00001
    ...    timeout=300
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
        ${count}=    set variable
        ...    ${log_entry ['BTS']['MRBTS-55057']['NRBTS-55057']['NRCELL-302']['NRIM']['${pi_id}']}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        Log    ${pi_value}
        ${value}=    evaluate    ${pi_value}!=0
        IF    '${value}' != '0'
            Log    ${counter_List}
        ELSE
            Log    '${value}' is equal to 0
        END
    END

PM_Counter_Check_Validation_TC_CB013138_TC2_Step3
    # connection=admin1
    @{counter_list}=    create List
    ...    M55194C00281
    ...    M55194C00003
    ...    M55194C00001
    ...    M55194C00282
#    ${log_entry} =    admin.get_pm_counters    counter_ids=M55194C00029,M55194C00009,M55194C00028    timeout=100
    ${log_entry}=    coam.Get Pm Counters
    ...    counter_ids=M55194C00281,M55194C00003,M55194C00001,M55194C00282
    ...    timeout=300
    ...    connection=admin1
    log    ${log_entry}
    RETURN    ${logentry}

Counter_validation_nonzero
    [Arguments]    ${counter_list}    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
        ${count}=    set variable
        ...    ${log_entry ['BTS']['MRBTS-55057']['NRBTS-55057']['NRCELL-302']['NRIM']['${pi_id}']}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        Log    ${pi_value}
        ${value}=    evaluate    ${pi_value}!=0
        IF    '${value}' != '0'
            Log    ${counter_List}
        ELSE
            Log    '${value}' is equal to 0
        END
    END

Counter_validation_zero
    [Arguments]    ${counter_list}    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
        ${count}=    set variable
        ...    ${log_entry ['BTS']['MRBTS-55057']['NRBTS-55057']['NRCELL-302']['NRIM']['${pi_id}']}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        Log    ${pi_value}
        ${value}=    evaluate    ${pi_value}==0
        IF    '${value}' == '0'
            Log    ${counter_List}
        ELSE
            Log    '${value}' is equal to 0
        END
    END

Step1[CB013138][TC3]:Fault 7525,7535,7527 generated and verified
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    # BTS-95 admin connection
    Log To Console    \n manualframeoffset is set to 607 and rstranstrigger set to constantlytrigger
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7525    connection=admin1
    Log To Console    \n Fault 7525 generated
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7535    connection=admin1
    Log To Console    \n Fault 7535 generated
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7527    connection=admin1
    Log To Console    \n Fault 7527 generated
    Log To Console    \n Fault 7525 description verification
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Log To Console    \n Fault 7535 description verification
    Verify Fault Description
    ...    faultid=${7535}
    ...    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH and PDCCH special slot plus the PDSCH preceding slot

Step2[CB013138][TC3]:actRiDetectTriggerDlMitigation=True[Serving]rsTransTrigger=RITrigger manualframeoffset=929[Neighbour]
    Log To Console    \n actRiDetectTriggerDlMitigation=True is already set
    coam.Connect_to    bts_host=10.41.211.245    bts_port=443    name=admin2    # BTS-53 admin connection
    coam.perform_delta_recommissioning
    ...    testsuite/Bangalore/RRM/T03/TMO/CB010866/config/CB013138_TC3_rstranstrigger_RITrigger_Manaulframeoffset_929.json
    ...    skip_parameter_relation_errors=false
    ...    timeout=1200
    ...    connection=admin2
    sleep    300
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    # BTS-95 admin connection
    coam.assert_alarm_active    faultId!=7527    connection=admin1
    Log To Console    \n Fault 7527 is cancelled
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    # BTS-95 admin connection
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7535    connection=admin1
    Log To Console    \n Fault 7535 is still reported even after fault 7527 cancellation

Step3[CB013138][TC3]:actRiDetectTriggerDlMitigation=False[Serving]rsTransTrigger=RITrigger manualframeoffset=929[Neighbour]
    Log To Console    \n rsTransTrigger=RITrigger manualframeoffset=929[Neighbour] is already set on BTS53 neighbour
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    # BTS-95 admin connection
    coam.perform_delta_recommissioning
    ...    testsuite/Bangalore/RRM/T03/TMO/CB010866/config/CB013138_TC3_actridetectTriggerDlmitigation_False.json
    ...    skip_parameter_relation_errors=false
    ...    =1200
    ...    connection=admin1
    sleep    200
#    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    #BTS-95 admin connection
    coam.assert_alarm_active    faultId!=7535    connection=admin1
    Log To Console    \n Fault 7535 is cancelled

Step4[CB013138][TC3]:actRiDetectTriggerDlMitigation=false[Serving]rsTransTrigger=constantlytrigger manualframeoffset=929[Neighbour]
    Log To Console    \n actRiDetectTriggerDlMitigation=false is already set
    coam.Connect_to    bts_host=10.41.211.245    bts_port=443    name=admin2    # BTS-53 admin connection
    coam.perform_delta_recommissioning
    ...    testsuite/Bangalore/RRM/T03/TMO/CB010866/config/CB013138_TC3_rstranstrigger_constanttrigger_Manaulframeoffset_929.json
    ...    skip_parameter_relation_errors=false
    ...    =1200
    ...    connection=admin2
    sleep    400
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    # BTS-95 admin connection
    coam.assert_alarm_active    faultId=7527    connection=admin1
    Log To Console    \n Fault 7527 is generated
    sleep    200
    # Fault 7535 is reported becuase of Fault 7527 generation
    coam.assert_alarm_active    faultId=7535    connection=admin1
    Log To Console    \n Fault 7535 is generated

Step5[CB013138][TC3]:actRiDetectTriggerDlMitigation=True[Serving]rsTransTrigger=constantlytrigger manualframeoffset=607[Neighbour]
    coam.Connect_to    bts_host=10.41.211.245    bts_port=443    name=admin2    # BTS-53 admin connection
    coam.perform_delta_recommissioning
    ...    testsuite/Bangalore/RRM/T03/TMO/CB010866/config/CB013138_TC3_rstranstrigger_constanttrigger_Manaulframeoffset_607.json
    ...    skip_parameter_relation_errors=false
    ...    =1200
    ...    connection=admin2
    sleep    300
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    # BTS-95 admin connection
    coam.perform_delta_recommissioning
    ...    testsuite/Bangalore/RRM/T03/TMO/CB010866/config/CB013138_TC3_actridetectTriggerDlmitigation_True.json
    ...    skip_parameter_relation_errors=false
    ...    =1200
    ...    connection=admin1
    sleep    200
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7525    connection=admin1
    Log To Console    \n Fault 7525 generated
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7535    connection=admin1
    Log To Console    \n Fault 7535 generated
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7527    connection=admin1
    Log To Console    \n Fault 7527 generated
    Log To Console    \n Fault 7525 description verification
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Log To Console    \n Fault 7535 description verification
    Verify Fault Description
    ...    faultid=${7535}
    ...    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH and PDCCH special slot plus the PDSCH preceding slot

Step1[CB013138][TC1]:Login_To_BTS_95_Check_for_Fault_7525_7535_7527
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    # BTS-95 admin connection
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7525    connection=admin1
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7535    connection=admin1
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7527    connection=admin1
    Log To Console    \n Fault 7525 description verification
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Log To Console    \n Fault 7535 description verification
    Verify Fault Description
    ...    faultid=${7535}
    ...    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH and PDCCH special slot plus the PDSCH preceding slot

Step2[CB013138][TC1]:Fault_7527_to_disappear
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1
    Log To Console    \n rsdistancethreshold set to 13 to cancel fault 7527
    Delta Comission for Fault 7527 to Disappear
    sleep    200
    Log To Console    \n Checking if Fault7527 is still reported on ADMIN
    coam.assert_alarm_active    faultId!=7527    connection=admin1
    sleep    300
    Log To Console    \n Counter Check for M55194C00005 & M55194C00006 Equal to zero
    ${logentry}=    PM_Counter_Check_Validation_TC_CB013138_TC1
    @{counter_list}=    create List    M55194C00005    M55194C00006
    Counter_validation_zero    ${counter_list}    ${logentry}

Step3[CB013138][TC1]:Fault_7527_to_Appear
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1
    Log To Console    \n rsdistancethreshold set to 1 to generate fault 7527
    Delta Comission for Fault 7527 to Appear
    sleep    300
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7527    connection=admin1
    Log To Console    \n Counter Check for M55194C00005 & M55194C00006 NOT Equal to zero
    sleep    200
    ${logentry}=    PM_Counter_Check_Validation_TC_CB013138_TC1
    @{counter_list}=    create List    M55194C00005    M55194C00006
    Counter_validation_nonzero    ${counter_list}    ${logentry}

PM_Counter_Check_Validation_TC_CB013138_TC1
    @{counter_list}=    create List    M55194C00005    M55194C00006    # connection=admin1
#    ${log_entry} =    admin.get_pm_counters    counter_ids=M55194C00029,M55194C00009,M55194C00028    timeout=100
    ${log_entry}=    coam.Get Pm Counters    counter_ids=M55194C00005,M55194C00006    timeout=300    connection=admin1
    log    ${log_entry}
    RETURN    ${logentry}

Step1[CB010866][TC1]:Login_To_BTS_95_Check_for_Fault_7525_7535_7527
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    # BTS-95 admin connection
    coam.Connect_to    bts_host=10.41.211.245    bts_port=443    name=admin2    # BTS-53 admin connection
    coam.get active alarms    timeout=10    connection=admin1    # BTS-95 active alarms list
    coam.get active alarms    timeout=10    connection=admin2    # BTS-53 active alarms list
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7525    connection=admin1
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7535    connection=admin1
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7527    connection=admin1
    Log To Console    \n Fault 7525 description verification
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Log To Console    \n Fault 7535 description verification
    Verify Fault Description
    ...    faultid=${7535}
    ...    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH and PDCCH special slot plus the PDSCH preceding slot

Step2[CB010866][TC1]:Cancellation_of_Fault7525
    Log To Console    \n 7525 cancellation with parameter change
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1
    Delta Comission for Fault 7525 to Disappear
    sleep    120s
    coam.assert_alarm_active    faultId!=7525    connection=admin1
    Log To Console    \n 7525 is not generated
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7535    connection=admin1
    Log To Console    \n 7535 generation

Step3[CB010866][TC1]:Generation_of_Fault7525
    Log To Console    \n 7525 generation wtih parameter change
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1
    Delta Comission for Fault 7525 to Re-appear
    sleep    120s
    Log To Console    \n 7525 generation
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7525    connection=admin1
    Log To Console    \n 7535 generation
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7535    connection=admin1
    Log To Console    \n 7527 generation
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7527    connection=admin1
    Log To Console    \n Fault 7525 description verification
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Log To Console    \n Fault 7535 description verification
    Verify Fault Description
    ...    faultid=${7535}
    ...    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH and PDCCH special slot plus the PDSCH preceding slot

StepX:Data Transfer_DL&UL
    Log To Console    \n DL Data started
    Start DL Data Transfer
    Log To Console    \n UL Data started
    Perform Uplink Data Transfer
    Log To Console    \n Counter Check

Step1[CB010866][TC2]:Login_To_BTS_95_Check_for_Fault_7525_7535_7527
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1    # BTS-95 admin connection
    coam.Connect_to    bts_host=10.41.211.245    bts_port=443    name=admin2    # BTS-53 admin connection
    coam.get active alarms    timeout=10    connection=admin1    # BTS-95 active alarms list
    coam.get active alarms    timeout=10    connection=admin2    # BTS-53 active alarms list
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7525    connection=admin1
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7535    connection=admin1
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7527    connection=admin1
    Log To Console    \n Fault 7525 description verification
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Log To Console    \n Fault 7535 description verification
    Verify Fault Description
    ...    faultid=${7535}
    ...    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH and PDCCH special slot plus the PDSCH preceding slot

Step2[CB010866][TC2]:Cancellation_of_Fault7525
    Log To Console    \n 7525 cancellation with parameter change
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1
    Delta Comission for Fault 7525 to Disappear
    sleep    120s
    coam.assert_alarm_active    faultId!=7525    connection=admin1
    Log To Console    \n 7525 is not generated
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7535    connection=admin1
    Log To Console    \n 7535 generation

Step3[CB010866][TC2]:Generation_of_Fault7525
    Log To Console    \n 7525 generation wtih parameter change
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1
    Delta Comission for Fault 7525 to Re-appear
    sleep    120s
    Log To Console    \n 7525 generation
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7525    connection=admin1
    Log To Console    \n 7535 generation
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7535    connection=admin1
    Log To Console    \n 7527 generation
    builtin.wait until keyword succeeds    2m    30s    coam.assert_alarm_active    faultId=7527    connection=admin1
    Log To Console    \n Fault 7525 description verification
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Log To Console    \n Fault 7535 description verification
    Verify Fault Description
    ...    faultid=${7535}
    ...    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH and PDCCH special slot plus the PDSCH preceding slot
    sleep    300s

Step4[CB010866][TC2]:Counter_Validation_TC2
    Log To Console    \n Counter Validation check ongoing
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1
    ${logentry}=    PM_Counter_Check_Validation_TC_CB010866_TC2
    log    ${logentry}
    @{counter_list}=    create List
    ...    M55194C00002
    ...    M55194C00001
    ...    M55194C00029
    ...    M55194C00028
    ...    M55194C00098
    ...    M55194C00009
    ...    M55194C00003
    Counter_validation_nonzero    ${counter_list}    ${logentry}

PM_Counter_Check_Validation_TC_CB010866_TC2
    # connection=admin1
    @{counter_list}=    create List
    ...    M55194C00002
    ...    M55194C00001
    ...    M55194C00029
    ...    M55194C00028
    ...    M55194C00098
    ...    M55194C00009
    ...    M55194C00003
#    ${log_entry} =    admin.get_pm_counters    counter_ids=M55194C00029,M55194C00009,M55194C00028    timeout=100
    ${log_entry}=    coam.Get Pm Counters
    ...    counter_ids=M55194C00002,M55194C00001,M55194C00029,M55194C00028,M55194C00098,M55194C00009,M55194C00003
    ...    timeout=300
    ...    connection=admin1
#    ${log_entry} =    coam.Get Pm Counters    counter_ids=M55194C00002    timeout=300    connection=admin1
    log    ${log_entry}
    RETURN    ${logentry}

Step4[CB010866][TC3]:Counter_Validation_TC3
    Log To Console    \n Counter Validation check ongoing
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443    name=admin1
    ${logentry}=    PM_Counter_Check_Valid_TC_CB010866_TC3
    @{counter_list}=    create List
    ...    M55194C00235
    ...    M55194C00179
    ...    M55194C00005
    ...    M55194C00007
    ...    M55194C00008
    ...    M55194C00006
    Counter_validation_nonzero    ${counter_list}    ${logentry}

PM_Counter_Check_Valid_TC_CB010866_TC3
    # connection=admin1
    @{counter_list}=    create List
    ...    M55194C00235
    ...    M55194C00179
    ...    M55194C00005
    ...    M55194C00007
    ...    M55194C00008
    ...    M55194C00006
#    ${log_entry} =    admin.get_pm_counters    counter_ids=M55194C00029,M55194C00009,M55194C00028    timeout=100
    ${log_entry}=    coam.Get Pm Counters
    ...    counter_ids=M55194C00235,M55194C00179,M55194C00005,M55194C00007,M55194C00008,M55194C00006
    ...    timeout=300
    ...    connection=admin1
    log    ${log_entry}
    RETURN    ${logentry}