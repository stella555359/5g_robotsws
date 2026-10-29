*** Settings ***
Documentation
...   Author: zhuo.1.gao@nokia-sbell.com
...   Contact: zhuo.1.gao@nokia-sbell.com
...   Description: CB012299-D

Resource           ../../../resources/RAN_PZ_HAZ_34/lines/SG6/Module_And_KW/common_resource.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Alarm/Alarm_common_keywords.robot
#Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/mobility_and_ca_common.robot
#Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Common_setup_and_teardown.robot

Suite Setup    Run Keywords    Common MultiBTS Suite Setup For RRM    AND    robot_common_operations.Common Suite Setup
Suite Teardown    Common Suite Teardown For RRM
Test Setup        CB012299_Case_SetUp
Test Teardown     CB012299_Case_Teardown
Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1    VRF_HAZ_T06
...    CLOUD_5G_CLASSICAL_ANDROIDX2_CA_ASIA_ABIAL_AZNC_FXEB
Test Timeout      120 minutes

# Suite Setup     TMO_Common_Suite_Setup   is_commission=${False}   ute_space=10    whether_do_prepare_ue=${False}
# # ...    gnb_scf_name=CB013205
# Suite Teardown   Run Keyword And Ignore Error    COAM Teardown gnb connections
# Force Tags   SG_06




*** Variables ***
${SERIALS}      RFCWA0G52XE
${COUNTER_TIME}    120s
${DL_IPERF_SERVER}    10.68.254.195
${IPERF_OPTION}    -b 200M -t 1800 -u -i 1 -l 1024 -p 5504
${PA_MaxValue}           ${120}
${PA_NormalValue}        ${35}
${PA_MinValue}           ${0}

*** Test Cases ***
[1]CB012299_D_01_Scell addition scenario in nominal bandwidth mode
    [Documentation]
    ...    n3(AHEH) is PCELL,N40(AKNB) is scell
    # [Setup]    Case Precondition
    # sleep      60s
    # BTS Operation    operation=cell_block           product_type=gnb    bts_index=0    distname_id=NRCELL-1001     need_verify=True
    #Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    #...                  counter_rule=${CURDIR}/counter_rule12299_D.txt
    Initialize PA
    sleep    3s
    Counter Check for CA
    sleep    3s
    detach_QC8450
    sleep    3s
    Change AKNB to nominalBandwidth
    sleep    10s
    attach_QC8450
    sleep    3s
    # BTS Operation    operation=cell_unblock           product_type=gnb    bts_index=0    distname_id=NRCELL-1001     need_verify=True
    # sleep    3s
    8450_DLstart
    sleep    300s
    8450_DLstop
    sleep    3s
    #Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    Counter Check End
    sleep      3s

[1]CB012299_D_16_Scell addition scenario in transition from limited bandwidth to nominal bandwidth mode
    [Documentation]
    ...    n3(AHEH) is PCELL,N40(AKNB) is scell
    # [Setup]    Case Precondition
    # sleep      60s
    # BTS Operation    operation=cell_block           product_type=gnb    bts_index=0    distname_id=NRCELL-1001     need_verify=True
    #Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    #...                  counter_rule=${CURDIR}/counter_rule12299_D.txt
    Initialize PA
    sleep    3s
    detach_QC8450
    sleep    3s
    Change AKNB to nominalBandwidth
    sleep    300s
    Counter Check for CA and bandwidth change
    sleep    3s
    attach_QC8450
    Change AKNB to limitedBandwidth
    sleep    3s
    # BTS Operation    operation=cell_unblock           product_type=gnb    bts_index=0    distname_id=NRCELL-1001     need_verify=True
    #sleep    3s
    8450_DLstart
    sleep    240s
    8450_DLstop
    sleep    360s
    Counter Check End
    sleep    10s
    detach_QC8450
    sleep    3s
    Counter Check for CA and bandwidth change
    sleep    3s
    attach_QC8450
    sleep    3s
    8450_DLstart
    sleep    5s
    Change AKNB to nominalBandwidth
    sleep    180s
    8450_DLstop
    sleep    120s
    #Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    Counter Check End
    sleep      3s

*** Keywords ***

Initialize PA
    ${pa_port_list}    ${pa_value_list}    Split And Expand PA Parameters    pa_port=1,9;3,4,11,12;2,10;5-8;13-16;    pa_value=0;30;120;120;120;
    &{source}    Create Dictionary    att_index=${0}    pa_port=${pa_port_list}    pa_value=${pa_value_list}
    PA Operation    operation=Initialize PA Value    source=&{source}

detach_QC8450
    AT Operation    detach    ue_index=${1}

attach_QC8450
    AT Operation    attach    ue_index=${1}

8450_DLstart
    AT Operation    start_traffic    ue_index=${1}    ueip=172.252.76.91    IperfOptions=-u -t 240 -l 1400B -i 1 -b 200M -p 5504    direction=dl
    ...  remote_hostname=10.71.207.141    remote_username=vrf3_sg8    remote_password=vrf3@sg8
8450_DLstop
    AT Operation    stop_traffic    ue_index=${1}    direction=dl
    ...  remote_hostname=10.71.207.141    remote_username=vrf3_sg8    remote_password=vrf3@sg8

Change AKNB to nominalBandwidth
    [Arguments]    ${skip_parameter_relation_errors}=False
#    @{para_list}      Create List    semiDynamicBwSize
#    @{mo_list}        Create List    MRBTS-37853/NRBTS-37853/NRCELL-1001
#    @{value_list}     Create List    nominalBandwidth
#    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
#    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
#    Log To Console    paramter update result: ${out}

    ${update_param}    catenate
    ...               {'dist_name':'MRBTS-37853/NRBTS-37853/NRCELL-1001','parameter':'semiDynamicBwSize','value':'nominalBandwidth'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    ...                                          skip_parameter_relation_errors=${skip_parameter_relation_errors}


Change AKNB to limitedBandwidth
    [Arguments]    ${skip_parameter_relation_errors}=False
#    @{para_list}      Create List    semiDynamicBwSize
#    @{mo_list}        Create List    MRBTS-37853/NRBTS-37853/NRCELL-1001
#    @{value_list}     Create List    limitedBandwidth
#    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
#    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
#    Log To Console    paramter update result: ${out}
    ${update_param}    catenate
    ...               {'dist_name':'MRBTS-37853/NRBTS-37853/NRCELL-1001','parameter':'semiDynamicBwSize','value':'limitedBandwidth'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    ...                                          skip_parameter_relation_errors=${skip_parameter_relation_errors}

Counter Check for CA
    ${rule1}    Catenate
    ...    Distname: MRBTS-37853/NRBTS-37853/NRCELL-1001;
    ...    Counter: M55139C04511;
    ...    Counter rule: sum(M55139C04511) > 0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-37853/NRBTS-37853/NRCELL-1001;
    ...    Counter: M55139C04512;
    ...    Counter rule:  max(M55139C04512)==0;
    ${rule_list}    Create List     ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
#    ...    wait_for_next_counter_generate=${TRUE}
    ...    counter_rule=${rule_list}

Counter Check for CA and bandwidth change
    ${rule1}    Catenate
    ...    Distname: MRBTS-37853/NRBTS-37853/NRCELL-1001;
    ...    Counter: M55139C04511;
    ...    Counter rule: sum(M55139C04511) > 0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-37853/NRBTS-37853/NRCELL-1001;
    ...    Counter: M55139C04512;
    ...    Counter rule:  max(M55139C04512)==0;
    ${rule3}    Catenate
    ...    Distname: MRBTS-37853/NRBTS-37853/NRCELL-1001;
    ...    Counter: M55166C00025;
    ...    Counter rule: sum(M55166C00025)==1;
    ${rule4}    Catenate
    ...    Distname: MRBTS-37853/NRBTS-37853/NRCELL-1001;
    ...    Counter: M55166C00026;
    ...    Counter rule: sum(M55166C00026)==1;
    ${rule_list}    Create List     ${rule1}    ${rule2}    ${rule3}    ${rule4}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
#    ...    wait_for_next_counter_generate=${TRUE}
    ...    counter_rule=${rule_list}


Counter Check End
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

CB012299_Case_SetUp
    [Documentation]  Author: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${scf_file_name}=SCF_12299_D_26R1.xml
    ...            ${is_pdl_checking_needed}=${True}
    Log To Console    \n***start to case setup***
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${gnb_allowed_fault_Before_Commission}   Create List    2002    4655    4701    4681    4655    4592
    ...                                                     4654    61649    61524    61652
    ...                                                     4203    1838    4741       7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    Create Case Log Path
    ${SCF_Path}    ${result}    Split String From Right    ${CURDIR}    testsuite     1
    ${scf_full_Path}    Set Variable    ${SCF_PATH}commissionings/HGZ/${testline_name}/${scf_file_name}
    Perform Commission    scf_file_path=${scf_full_Path}
    ...                   timeout_for_commission=900
    ...                   wait_gnb_up_timeout=30 min
    ...                   is_pdl_checking_needed=${is_pdl_checking_needed}
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
    ${allowed_faults_list}    Combine Current Active Alarm With White List Alarm List
    Set Test Variable    ${ALLOWED_FAULTS_LIST}    ${allowed_faults_list}

Perform Commission
    [Documentation]   xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${scf_file_path}    ${gnb_index}=0    ${timeout_for_commission}=900
    ...            ${wait_gnb_up_timeout}=20 min    ${is_pdl_checking_needed}=${True}
    Connect to gnb coam via ssl    connection=GNB_OAM${gnb_index}   gnb_index=${gnb_index}
    coam_gnb_classical.COAM Commission with scf file    scf_file_path=${scf_file_path}
    ...                              connection=GNB_OAM${gnb_index}
    ...                              timeout=${timeout_for_commission}
    ...                              is_pdl_checking_needed=${is_pdl_checking_needed}
    Common_setup_and_teardown.Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}    timeout=${wait_gnb_up_timeout}
    ...                                                         connection=GNB_OAM${gnb_index}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM${gnb_index}

CB012299_Case_Teardown
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    Run Keyword And Continue On Failure    Check Whether New Alarm Happened During Running Case    alarm_info_before=${summary_alarm_info}
    Run Keyword And Ignore Error    Capture Snapshot If Case Failed