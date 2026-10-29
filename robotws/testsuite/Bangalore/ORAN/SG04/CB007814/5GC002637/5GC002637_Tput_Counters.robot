*** Settings ***

Documentation
...   author: SG8
...   contact: SG8
...   Description: Test Suite for 5Gc002637_Tput_Counters



Library     testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Resource    ./testsuite/Bangalore/ORAN/SG04/CB007814/resourcefile/CB007814_keywords.robot
Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem
Library     taf.config.scf   WITH NAME    scf
Library     taf.sbts.oam.coam.admin    WITH NAME    COAM
Resource           ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Library    taf.sw.scout    WITH NAME    scout
Force Tags       CRT    TRUNK_7814    FL00    2637    QCD_MN_RAN    QCP_RAN_VRF
Test Teardown     Test Teardown
Test Setup      Test Setup

*** Variables ***
@{UE_alias}=  UE3
@{capabilities}=    Legacy_3
@{throughput_dl}    250
#@{dt_name_dl_udp}=          iperf-DL-UDP-test
@{direction_dl}=      dl
@{deviation_dl}=      50
@{throughput_ul}     75
@{dt_name_ul}    iperf-UL-UDP-test
@{udpcalltype}=    UDP
@{direction_ul}=      ul
@{deviation_ul}=      90
@{Acceptable_Peak_tp_DL} =  230
@{Acceptable_Peak_tp_UL} =  60
@{dt_name_dl_udp} =  iperf-DL-UDP-test
@{dt_name_ul_udp} =  iperf-UL-UDP-test
${bts_ip}=     192.168.255.129
${testcase_name}=    5Gc002637_Tput_Counters
${OUT_LOG_PATH}    /home/ute/results
${CONFIGURATION}		    1_2_CLOUD970
&{CB007814_5GC002637 Throughput Counter validation for MAC layer in NSA configuration FR1 FDD 20 MHz cell}
...    QC_ID_FL00=QC_31650    QC_ID_SBTS24R1=QC_692727

*** Test Cases ***
CB007814_5GC002637 Throughput Counter validation for MAC layer in NSA configuration FR1 FDD 20 MHz cell
    step1: Paramter Update
    step2: Attach UE
    step3: Start DL & UL Throughput
    step4: Stop dcap & Validate logs
    RP Settings
    Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting
    Set QC_Tag


*** Keywords ***

Test Setup
    Log to console    \n--Test Setup--\n
    Admin Setup
    Admin Setup2
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}    attenuation_port_numbers=@{at_channel}
    ...  vendor=${at_vendor}  model=${at_model}

    at.set_ports_attenuation     ports=${ports}   values=${values1}

    at.set_ports_attenuation     ports=${ports_FJT_LTE}   values=${values1}

    Log to console    \n-unlocking and locking LTE cells---\n
    Lock cells  ${LTE_cell}
    Unlock cells  ${LTE_cells}
    Log to console    \n-Blocking LTE RAT---\n
    COAM.block_rat    rat=LTE    timeout=100    connection=${connection}
    Log to console    \n-NR cell lock operation---\n
    Lock NR cells  ${NR_cell}
    Dcap Start Trace SA

step1: Paramter Update
    Parameter value change	${dist_name}	actIpThpt	true
    Log to console    \n--Parameter updated--\n

step2: Attach UE

    Log to console    \n--Attach validation step--\n
     ta_ultracaller.Require UE    ${UE_alias}    ${capabilities}
	ta_ultracaller.Detach UE     ${UE_alias}
	ta_ultracaller.Attach UE     ${UE_alias}
    Log to console    \n--Attach validation completed--\n


step3: Start DL & UL Throughput

    Log to console    \n--DL_Data transfer --\n
    ta_ultracaller.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
    Log to console    \n-awaiting for data transfer to complete successfully---\n
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    direction=${direction_dl}
    Log to console    \n--DL_Data transfer completed and tput calculation started --\n
    Log to console    \n--Calculating DL throughput--\n
    ${Result_1}=    Run Keyword And Continue On Failure     ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}
    ...    direction=${direction_dl}    thrughtput=${throughput_dl}    deviation=${deviation_dl}
    ${Value_1}=    get from dictionary    ${Result_1['${UE_alias[0]}']}    maxtput
    ${Int_value}=   Convert To Integer    ${Value_1}
    ${status_1}=    Run keyword And Continue On Failure     BuiltIn.Evaluate      ${Int_value}>=${Acceptable_Peak_tp_DL}[0]
    Run keyword And Continue On Failure        Should Be True    ${status_1}
    Log to console    ${Int_value}
    Log to console    \n-- starting UL_Data transfer --\n
    ta_ultracaller.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_ul}
    sleep    1m
    Run keyword And Continue On Failure    Counter Verification
    Log to console    \n-awaiting for data transfer to complete successfully---\n
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    direction=${direction_ul}
    Log to console    \n--UL_Data transfer completed and max tput calculation in progress --\n
    ${Result_2}=    Run Keyword And Continue On Failure     ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}
    ...    direction=${direction_ul}    thrughtput=${throughput_ul}    deviation=${deviation_ul}
    ${Value_2}=    get from dictionary    ${Result_2['${UE_alias[0]}']}    maxtput
    ${Int_value_2}=   Convert To Integer    ${Value_2}
    ${status_2}=    Run keyword And Continue On Failure     BuiltIn.Evaluate      ${Value_2}>=${Acceptable_Peak_tp_UL}[0]
    Run keyword And Continue On Failure		Should Be True    ${status_2}
    Log to console    \n--${Result_2}--\n
    Log to console    \n--${Value_2}--\n
    Log to console    \n--UL max TPut calculation done--\n



step4: Stop dcap & Validate logs
    Log to console    \n--Stopping DCAP traces--\n
    Dcap Stop Trace and Get results SA
    Log to console    \n--Successfully stopped DCAP traces--\n

Counter Verification

    Log to console    \n--Tput counter validation step--\n
    @{counter_list}=    create List    'M55308C26001'    'M55308C26002'
    ${log_entry} =    COAM.get_pm_counters    counter_ids=M55308C26001,M55308C26002    timeout=180    connection=${connection}
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list}
        log    ${pi_id}
        ${count}=    Run Keyword If    9999 == ${SPLIT_SW}
        ...    set variable   ${log_entry['BTS']['MRBTS-970']['NRBTS-970']['NRCELL-3']['NCELA'][${pi_id}]}
        ...    ELSE    set variable    ${log_entry['BTS']['CELLS']['NRCELL-3']['NCELA'][${pi_id}]}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        Log    ${pi_value}
        Log to console    \n--${pi_value}--\n
        ${value}=    evaluate    ${pi_value}!=0
        Run keyword And Continue On Failure    should be true    ${value}
    END


Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=${CONFIGURATION}

    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line node_id: ${node_id}
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



Test Teardown

    Run Keyword And Ignore Error    rd.abort_trace    trace_id=${START_TRACE_ID}    timeout=180
    Parameter value change	${dist_name}	actIpThpt	false
    Run keyword And Continue On Failure    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Run keyword And Continue On Failure    Unblock LTERAT
    sleep    300s
    Run keyword And Continue On Failure    Unlock NR cells    ${NR_cell}
    Run keyword And Continue On Failure    Unlock cells    ${LTE_cell}
    COAM.teardown_admin    ${connection}
    COAM.teardown_admin    ${connection_enb}
    Log to console   \n--End  of  Test--\n

