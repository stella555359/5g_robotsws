*** Settings ***
Documentation
...                 author: CIT T04, sudarshan.kanapuram@nokia.com
...                 contact: CIT T04, sudarshan.kanapuram@nokia.com
...                 Description: CIT basic TC, sudarshan.kanapuram@nokia.com

Library             taf.sw.dcap.rd    WITH NAME    dcap
Library             taf.gnb.oam.coam.vdu    WITH NAME    admindu
Library             taf.gnb.oam.coam.cu    WITH NAME    admincu
Library             OperatingSystem    WITH NAME    os
Library             String
Library             testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Resource            ./testsuite/Bangalore/ORAN/T04/resources/T04_CIT_common_resource.robot
Resource            ./testsuite/Bangalore/ORAN/T04/resources/reportingportal_Keywords.robot

Suite Setup         Suite Precondition
Suite Teardown      Suite Postcondition
Test Setup          Test setup
Test Teardown       test teardown

Force Tags          qcd_mn_ran    qcp_ran_vrf    cit


*** Variables ***
${BTS_ID}=                                                                  30613
${host_vCU}=                                                                10.58.230.178
${host_vDU}=                                                                10.58.230.179
${PORT}=                                                                    443
${USER}=                                                                    Nemuadmin
${PWD}=                                                                     Nokia@123

${dcaphost}=                                                                10.41.209.115
${Windows_user}                                                             inbabtslabuser    # Windows UE PC username
${Windows_pass}                                                             BT5l@bus3rl0g1n
${dcap_log_timeout}=                                                        800s
${BTS_path}=                                                                /home/ute/results
@{deviation_dl}=                                                            60
@{deviation_ul}=                                                            80
@{throughput_dl}=                                                           250
@{throughput_ul}=                                                           60
@{deviation2_dl}=                                                           60
@{deviation2_ul}=                                                           80
@{throughput2_dl}=                                                          800
@{throughput2_ul}=                                                          80
${wait_for_transfer}                                                        True
@{UE_alias}=                                                                UE3
@{capabilities}=                                                            Legacy_3
${dcapuser_name}                                                            utfuser
${dcap_password}                                                            utfadmin!
${PATH}                                                                     /home/ute/Documents/Automation_run
${testcase_name}=                                                           CIT_Basic
@{direction_dl}=                                                            dl
@{direction_ul}=                                                            ul
@{duration}=                                                                700s
@{timeout}                                                                  180
@{tcpcalltype}=                                                             TCP
@{udpcalltype}=                                                             UDP
${packet_size}=                                                             1400
${tput}=                                                                    100Mbits/sec
@{custom_profile}=                                                          controlPlane5gVcu

@{Cell_list1}=                                                              2    3    4    7    8    9
@{Cell_list2}=                                                              1    3    4    7    8    9

&{[1][1.0] Verify_L3_Call_and_Validate_TPUT_on_UL_and_DL_on_FDD_Cell}       QC_ID_VDU=QC_171479
&{[1][1.0] Verify_L3_Call_and_Validate_TPUT_on_UL_and_DL_on_TDD_Cell}       QC_ID_VDU=QC_171480


*** Test Cases ***
[1][1.0] Verify_L3_Call_and_Validate_TPUT_on_UL_and_DL_on_FDD_Cell
    [Tags]    qcd_mn_ran    qcp_ran_vrf    cit_fdd
    Log To Console    \n --Cloud_ORAN_CIT_SW_UGD_FDD_L3_Call test started-- \n
    Lock cells group    ${Cell_list1}
    Attach and Tput Test    ${throughput_dl}    ${throughput_ul}    ${deviation_dl}    ${deviation_ul}
    Unlock cells group    ${Cell_list1}
    [Teardown]    run keywords
    ...    Test teardown    AND    Set QC_Tag_vdu

[1][1.0] Verify_L3_Call_and_Validate_TPUT_on_UL_and_DL_on_TDD_Cell
    [Tags]    qcd_mn_ran    qcp_ran_vrf    cit_tdd
    Log To Console    \n --Cloud_ORAN_CIT_SW_UGD_TDD_L3_Call test started-- \n
    Lock cells group    ${Cell_list2}
    Attach and Tput Test    ${throughput2_dl}    ${throughput2_ul}    ${deviation2_dl}    ${deviation2_ul}
    Unlock cells group    ${Cell_list2}
    [Teardown]    run keywords
    ...    Test teardown    AND    Set QC_Tag_vdu


*** Keywords ***
Lock cells group
    [Arguments]    ${cell_list}
    Log To Console    \n --Locking Cells 2,3-- \n
    ${cell_ope_status}=    admindu.Lock Vdu Cell Groups    cell_groups_id_list=${cell_list}    vdu_connection=vDU
    Sleep    30s
    ${cell_status}=    admindu.get_operation_state_of_locking_vdu_cell_groups
    ...    operation_groups_id=${cell_ope_status['id']}
    ...    vdu_connection=vDU
    Run keyword And Continue On Failure    Should Be Equal    ${cell_status['status']}    success
    Log To Console    \n ${cell_status}-- \n
    Log To Console    \n --Locked Cells 2,3-- \n

Unlock cells group
    [Arguments]    ${cell_list}
    Log To Console    \n --Unlocking Cells 2,3-- \n
    ${cell_ope_status}=    admindu.Unlock Vdu Cell Groups    cell_groups_id_list=${cell_list}    vdu_connection=vDU
    Sleep    30s
    ${cell_status}=    admindu.get_operation_state_of_unlocking_vdu_cell_groups
    ...    operation_groups_id=${cell_ope_status['id']}
    ...    vdu_connection=vDU
    Run keyword And Continue On Failure    Should Be Equal    ${cell_status['status']}    success
    Log To Console    \n ${cell_status}-- \n
    Log To Console    \n --Unlocked Cells 2,3-- \n

Attach and Tput Test
    [Arguments]    ${throughput_dl}    ${throughput_ul}    ${deviation_dl}    ${deviation_ul}
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ${UE_alias}
    ta_ultracaller.Attach UE    ${UE_alias}
    Sleep    10s
    Log To Console    \nStarting data transfer
    ta_ultracaller.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
    IF    '${wait_for_transfer}'=='True'
        ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_dl}    ${timeout}
        Sleep    30
        Log to console    \nData transfer completed for DL
    END
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}
    ...    direction=${direction_dl}    thrughtput=${throughput_dl}    deviation=${deviation_dl}

    ta_ultracaller.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=@{direction_ul}
    IF    '${wait_for_transfer}'=='True'
        ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_ul}    ${timeout}
        Sleep    30
        Log to console    \nData transfer completed for UL
    END
    Run Keyword And Continue On Failure
    ...    ta_ultracaller.calculate_thrughtput
    ...    ue_alias=${UE_alias}
    ...    direction=${direction_ul}
    ...    thrughtput=${throughput_ul}
    ...    deviation=${deviation_ul}
    Log to console    \nData transfer Finished

    ta_ultracaller.Detach UE    ${UE_alias}
    Log to console    Detach successful
    Sleep    10s

Test setup
    Log To Console    \n --Connecting vDU-- \n
    Sleep    900s
    admindu.Connect To    host=${host_vDU}    port=${PORT}    connection_name=vDU    username=${USER}
    ...    password=${PWD}    secure=True    timeout=300
    Log To Console    \n --Connecting vCU-- \n
    admincu.Connect To    host=${host_vCU}    port=${PORT}    alias=vCU    username=${USER}    password=${PWD}
    ...    secure=True    alias=vCU    timeout=300
    Log To Console    \n --Waiting for vDU to come up-- \n
    FOR    ${a}    IN RANGE    1    20
        ${vDU_Cell_status}=    admindu.Get Vdu Cells Status    vdu_connection=vDU    timeout=300
        IF    '${vDU_Cell_status[0]['availability_status']}'=='on line'    BREAK
        Sleep    2m    reason=Wait for BTS status OnAir
    END

    Log To Console    ${vDU_Cell_status[0]['availability_status']}
    Log    ${vDU_Cell_status[0]['availability_status']}
    Log    All cell statuses: ${vDU_Cell_status}
    FOR    ${cell}    IN    @{vDU_Cell_status}
        Should Be Equal As Strings    ${cell['availability_status']}    on line
        Log    Cell ${cell['id']} procedural state is now: ${cell['availability_status']}
        ${offline_cells}=    Evaluate
        ...    [cell for cell in ${vDU_Cell_status} if cell['availability_status'] != 'on line']
        IF    len(${offline_cells})==0    Log    All cells are online
        Log To Console    Cell ${cell['id']} procedural state is now: ${cell['availability_status']}
    END
    ${vcu_alarms}=    admincu.Get Active Alarms    connection=vCU
    ${vdu_alarms}=    admindu.vdu_get_active_alarms    vdu_connection=vDU
    Log To Console    ${vcu_alarms}
    Log To Console    ${vdu_alarms}

test teardown
    Log To Console    \n----Teardown.....---\n
    admindu.Disconnect    vdu_connection=vDU
    Log To Console    \n--End of test--\n
