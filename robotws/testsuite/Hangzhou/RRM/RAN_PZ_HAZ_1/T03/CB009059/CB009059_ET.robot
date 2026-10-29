*** Settings ***
Documentation
...   author: keli.weng
...   contact: keli.weng@nokia-sbell.com
...   this is a robot case about CB009059-SR
...   Default WTS cfg file is wts_SA_TDD_FDD_4c_1gNBSim
...   Default 5QI is 7
...   5QI-6 Not FR1 CA eligible
...   5QI-7 FR1 CA eligible
...   5QI-8 FR1 CA incompatible
...   5QI-9 FR1 CA eligible
...   Some cases have its own cfg file and scf file
Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Common/Airphone.robot
# Resource          ../Resources/top50_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
# Suite Setup       Common Suite Setup For RRM
Test Setup            Common MultiBTS Test Setup For RRM
# Test Setup          Common Test Setup For RRM
Test Teardown     Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
# Test Teardown    Common Test Teardown For RRM
Suite Teardown    Common MutliBTS Suite Teardown For RRM
# Suite Teardown    Common Suite Teardown For RRM
Force Tags        CRT/CIT/CDRT     #Tag Item
# ...   PY27
...      RAN_5G                    #Product [RAN_5G]
# ...      CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
...      SBTS00/SBTS21B           # it is for auto trigger by ute cloud with the release
# ...      STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]


Test Timeout    60 minutes

# Library           taf.ccs.aashell   WITH NAME    ccs_aashell
*** Variables ***
#reduce global paramter as possilbe and automatically got from gNB or __init__
&{fault_7300}             faultId=${7300}
@{Ohter_Allow_Alarms}     &{fault_7300}
${APC_Index}    -1
# ${DEBUG_MODE}            ${TRUE}
${total_throughput}    ${0}
${Feature_parameter}    actDrbProfileForCellAggrLevel
${parameter_8379}      actNonVoNRGbrService
${dist_name}           MRBTS-1/NRBTS-1
@{cellaggr_level}
...    FR1 CA eligible
...    Not FR1 CA eligible
...    FR1 CA incompatible
&{RAD_HEXs}                     rdOverloadHighThreshold=0x89006f
...                             rdFailDuAdmissionControl=0x590249


# ${REMOTE_MODE}           ${TRUE}
${PATH2}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T03/CB009059/Airphone

*** Test Cases ***
# CB009059-A_01 Feature deactivation of DRB profile based Carrier Aggregation interaction
#     [Documentation]    author:keli
#     ...   CB009059_A_01 ET Test
#     ...   5QI-8 FR1 CA incompatible
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_FDD_4c_1gNBSim
#     ...    base_path=${CURDIR}/Airphone
#     Start Multi Bts Log
#     Disable DRB Profile for CA Level
#     sleep    2s
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=1 trf_type=internal
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=2 trf_type=internal
#     ...    pass_regexp=${None}
#     sleep    1s
#     Start tcpdump in SBTS by command
#     sleep    1s
#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=4 default=on
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Attach is done. =============${\n}
#     Log To Console      ${\n}============= Setup PDU1 5qi8. =============${\n}

#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100 trf_id=4
#     sleep    10s
#     # check 5qi8 scell scheduled
#     Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1,2
#     ...    pass_regexp=3 cells
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=0
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=1
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=2
#     Log To Console      ${\n}============= scell Index checked. =============${\n}
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm

# CB009059-A_02 ICS with a Not FR1 CA eligible DRB and no FR1 CA incompatible DRB - blind SCell Addition method
#     [Documentation]    author:keli
#     ...   CB009059_A_02 ET Test
#     ...   5QI-6 Not FR1 CA eligible
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_FDD_4c_1gNBSim
#     ...    base_path=${CURDIR}/Airphone
#     ...    call_type=sansa
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55125C00040;
#     ...    Counter rule: max(M55125C00040)==0;
#     ${rule_list}    Create List    ${rule1}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Start Multi Bts Log
#     Activate DRB Profile for CA Level
#     sleep    2s
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=1 trf_type=internal
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=2 trf_type=internal
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=2 default=on
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Attach is done. =============${\n}
#     Log To Console      ${\n}============= Setup PDU1 5qi6. =============${\n}

#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100 trf_id=4
#     sleep    10s
#     # check 5qi8 scell scheduled
#     Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1,2
#     ...    pass_regexp=1 cell
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=0
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=1
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=2
#     ${scell_result}    ${output}    Run Keyword And Ignore Error
#     ...       Get Tput for scell    scellidx=1
#     Should Be True    '${scell_result}'=='FAIL'
#     Log To Console      ${\n}============= scell Index checked. =============${\n}
#     Sleep    8 min    reason=wait for counter ready
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}

# CB009059-A_03 CA addition when PDU session modification after FR1 CA eligible DRB has been established and no FR1 CA incompatible DRB is established
#     [Documentation]    author:keli
#     ...   CB009059_A_03 ET Test
#     ...   5QI-6 Not FR1 CA eligible
#     ...   5QI-7 FR1 CA eligible
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_FDD_4c_1gNBSim
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55125C00039;
#     ...    Counter rule: max(M55125C00039)>0;
#     ${rule_list}    Create List    ${rule1}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Start Multi Bts Log
#     Set Param maxNumOfSCellAlloc To Zero
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=1 trf_type=internal
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=2 trf_type=internal
#     ...    pass_regexp=${None}
#     sleep    1s

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=3 default=on
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Attach is done. =============${\n}
#     Log To Console      ${\n}============= Setup PDU1 5qi7. =============${\n}

#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100 trf_id=4
#     sleep    10s

#     Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1,2
#     ...    pass_regexp=1 cell
#     ${scell_result}    ${output}    Run Keyword And Ignore Error
#     ...       Get Tput for scell    scellidx=1
#     Should Be True    '${scell_result}'=='FAIL'
#     Log To Console      ${\n}============= scell Index checked. =============${\n}

#     ### step 3 change param  maxNumOfSCellAlloc
#     Set Param maxNumOfSCellAlloc To Default Value
#     Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=1
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Added 5QI5. =============${\n}

#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100 trf_id=4
#     sleep    10s
#     Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1,2
#     ...    pass_regexp=3 cells

#     Sleep    8 min    reason=wait for counter ready
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}

# CB009059-AB_02 CA release when incompatible DRB session adds via PDU Session Modification
#     [Documentation]    author:keli
#     ...    CB009059_AB_02 ET Test
#     ...    5QI-7 FR1 CA eligible
#     ...    5QI-8 FR1 CA incompatible
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_FDD_4c_1gNBSim
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55125C00040;
#     ...    Counter rule: max(M55125C00040)>0;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55118C00034,M55118C00035;
#     ...    Counter rule: M55118C00034==M55118C00035;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55118C00042,M55118C00043;
#     ...    Counter rule: M55118C00042==M55118C00043;
#     ${rule4}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55118C00034;
#     ...    Counter rule: max(M55118C00034)>0;
#     ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Start Multi Bts Log
#     Start tcpdump in SBTS by command
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=1 trf_type=internal
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=2 trf_type=internal
#     ...    pass_regexp=${None}
#     sleep    1s

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=3 default=on
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Attach is done. =============${\n}
#     Log To Console      ${\n}============= Setup PDU1 5qi7. =============${\n}
#     sleep    1s

#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100 trf_id=4
#     sleep    10s
#     # check 5qi7 scell scheduled
#     Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1,2
#     ...    pass_regexp=3 cells
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=0
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=1
#     Log To Console      ${\n}============= scell Index checked. =============${\n}
#     Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=4
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Added 5QI8. =============${\n}
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=100 trf_id=4
#     # check 5qi4 only pcell scheduled
#     sleep    10s
#     ${tput_dl1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${tput_dl2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=dl
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=0
#     ${scell_result}    ${output}    Run Keyword And Ignore Error
#     ...       Get Tput for scell    scellidx=1
#     Should Be True    '${scell_result}'=='FAIL'
#     sleep    10s
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm
#     Log To Console      wait for counter ready
#     Sleep    10 min    reason=wait for counter ready
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}


# CB009059-AB_04 CA not released after a Not FR1 CA eligible GBR DRB is setup via PDU session modify
#     [Documentation]    author:keli
#     ...    CB009059_AB_04 ET Test
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_FDD_4c_1gNBSim
#     ...    base_path=${CURDIR}/Airphone

#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C12004;
#     ...    Counter rule: max(M55319C12004)>0;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55118C00034,M55118C00035;
#     ...    Counter rule: M55118C00034==M55118C00035;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55118C00035;
#     ...    Counter rule: M55118C00035==0;

#     ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}

#     Start Multi Bts Log

#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=1 trf_type=internal
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=2 trf_type=internal
#     ...    pass_regexp=${None}
#     sleep    1s

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=3 default=on
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Attach is done. =============${\n}
#     Log To Console      ${\n}============= Setup PDU1 5qi7. =============${\n}
#     sleep    1s

#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100 trf_id=4
#     sleep    10s
#     # check 5qi7 scell scheduled
#     Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1,2
#     ...    pass_regexp=3 cells
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=0
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=1
#     Log To Console      ${\n}============= scell Index checked. =============${\n}
#     Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=7
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Added 5QI4. =============${\n}

#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=100 trf_id=4
#     # check 5qi4 only pcell scheduled
#     sleep    10s
#     ${tput_dl1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${tput_dl2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=dl
#     sleep    2s
#     Airphone Execute Egate Command     cmd=trf_data_stop ue=1 pdu=all
#     sleep    5s
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=100 trf_id=3
#     sleep    10s
#     ${tput_dl1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${tput_dl2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=dl
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=0
#     ${scell_result}    ${output}    Run Keyword And Ignore Error
#     ...       Get Tput for scell    scellidx=1
#     Should Be True    '${scell_result}'=='FAIL'
#     # #check pcell data scheduled

#     Sleep    10 min    reason=wait for counter ready
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}


# CB009059-AC_01 CA does not release when CA incompatible DRB established after online feature flag changing to disable
#     [Documentation]    author:keli
#     ...   CB009059_AC_01 ET Test
#     ...   5QI-8 FR1 CA incompatible
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_FDD_4c_1gNBSim
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C12007;
#     ...    Counter rule: max(M55319C12007)>0;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55118C00034,M55118C00035;
#     ...    Counter rule: M55118C00034==M55118C00035;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55118C00035;
#     ...    Counter rule: M55118C00035==0;
#     ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Start Multi Bts Log
#     sleep    2s
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=1 trf_type=internal
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=2 trf_type=internal
#     ...    pass_regexp=${None}
#     sleep    1s
#     Start tcpdump in SBTS by command
#     sleep    1s
#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=3 default=on
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Attach is done. =============${\n}
#     Log To Console      ${\n}============= Setup PDU1 5qi7. =============${\n}

#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100 trf_id=4
#     sleep    10s
#     # check scell scheduled
#     Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1,2
#     ...    pass_regexp=3 cells
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=0
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=1
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=2
#     Log To Console      ${\n}============= scell Index checked. =============${\n}
#     Disable DRB Profile for CA Level
#     sleep    2s
#     Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=4
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Added 5QI8. =============${\n}
#     sleep    5s
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=100 trf_id=4
#     Log To Console      ${\n}============= DL traffic is started. =============${\n}
#     sleep    10s
#     ${tput_dl1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${tput_dl2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=dl
#     Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1,2
#     ...    pass_regexp=3 cells
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=0
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=1
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=2
#     Sleep    10 min    reason=wait for counter ready
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}

# CB009059-BD_01 CA release when at least one CA incompatible DRB session is setup 4CC CA Case
#     [Documentation]    author:keli
#     ...    1. The purpose of this test case is to check following scenarios:
#     ...    CA release when at least one CA incompatible DRB session is setup (4CC CA)
#     ...    2. Test Case Steps:
#     ...         Step A. UE attach with FR1 CA eligible DRB1 and Not FR1 CA eligible DRB2
#     ...         Step B. Send DL traffic data to all DRBs
#     ...         Step C. setup with FR1 CA incompatible DRB3
#     ...    3. Expected Results:
#     ...         Step A: DL 4CC CA configured
#     ...         Step B: DRB-1, data traffic are scheduling on both Pcell and scells
#     ...                 DRB-2, data traffic are scheduling on Pcell only
#     ...         Step C: Scell released
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_FDD_4c_1gNBSim
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55125C00040;
#     ...    Counter rule: max(M55125C00040)>0;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55118C00034,M55118C00035;
#     ...    Counter rule: M55118C00034==M55118C00035;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55118C00035;
#     ...    Counter rule: max(M55118C00035)>0;
#     ${rule4}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55125C00039;
#     ...    Counter rule: max(M55125C00039)>0;
#     ${rule5}    Catenate
#     ...         Distname: MRBTS-1/NRBTS-1/NRCELL-3;
#     ...         Counter: M55310C02007;
#     ...         Counter rule: max(M55310C02007)>0
#     ${rule6}    Catenate
#     ...         Distname: MRBTS-1/NRBTS-1/NRCELL-3;
#     ...         Counter: M55310C02009;
#     ...         Counter rule: max(M55310C02009)==0
#     ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}    ${rule6}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Start Multi Bts Log
#     # Start tcpdump in SBTS by command
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
#     ...    pass_regexp=${None}
#     sleep    1s
#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=3 default=on
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Attach is done. =============${\n}
#     Log To Console      ${\n}============= Setup PDU1 5qi7. =============${\n}
#     sleep    1s

#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100 trf_id=4
#     sleep    10s
#     # check 5qi7 scell scheduled
#     Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1,2
#     ...    pass_regexp=3 cells
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=0
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=1
#     Log To Console      ${\n}============= scell Index checked. =============${\n}
#     Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=4
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Added 5QI8. =============${\n}
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=100 trf_id=4
#     sleep    10s
#     ${tput_dl1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${tput_dl2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=dl
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=0
#     ${scell_result}    ${output}    Run Keyword And Ignore Error
#     ...       Get Tput for scell    scellidx=1
#     Should Be True    '${scell_result}'=='FAIL'
#     sleep    10s
#     # stop tcpdump in sbts by command
#     # ${capture_file_path}    Download wireshark log to testvm
#     Log To Console      wait for counter ready
#     Sleep    10 min    reason=wait for counter ready
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}


# CB009059-AD_01 Interworking with HRDRB - CA eligible profile checking
#     [Documentation]    author:keli
#     ...    CB009059_AD_01 ET Test
#     ...    1. The purpose of this test case is to check following scenarios:
#     ...    UE
#     ...    When there is one Not CA eligible HRDRB established, All DL and UL scells will be released.
#     ...    2. Test Case Steps:
#     ...         Step A. UE attach to Cell1 with FR1 CA eligible HRDRB1
#     ...         Step B. Send DL/UL traffic data to all DRBs
#     ...         Step C. Change HRDRB to Not FR1 CA eligible/FR1 CA incompatible HRDRB1,
#     ...                 then UE reattach
#     ...    3. Expected Results:
#     ...         Step A: DL CA configured
#     ...         Step B: data traffic are scheduling in each DRB on both Pcell and scells
#     ...         Step C: No scell addition
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_FDD_4c_1gNBSim_HR
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55125C00040;
#     ...    Counter rule: max(M55125C00040)>0;
#     ${rule_list}    Create List    ${rule1}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Change Param cellAggrLevel of DRB    drb_index=12    val=${cellaggr_level}[0]
#     Start Multi Bts Log
#     sleep    2s
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=1 trf_type=internal
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=2 trf_type=internal
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=3 default=on
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Attach is done. =============${\n}
#     Log To Console      ${\n}============= Setup PDU1 5qi7. =============${\n}
#     sleep    1s
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=4
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100 trf_id=5
#     sleep    10s
#     # check 5qi7 scell scheduled
#     Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1,2
#     ...    pass_regexp=3 cells
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=0
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=1
#     Log To Console      ${\n}============= scell Index checked. =============${\n}

#     Change Param cellAggrLevel of DRB    drb_index=12    val=${cellaggr_level}[2]
#     Airphone Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Attach is done. =============${\n}
#     Log To Console      ${\n}============= Setup PDU1 5qi7. =============${\n}
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100 trf_id=4
#     sleep    10s
#     ${tput_dl1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     Run Keyword And Ignore Error       Get Tput for scell    scellidx=0
#     ${scell_result}    ${output}    Run Keyword And Ignore Error
#     ...       Get Tput for scell    scellidx=1
#     Should Be True    '${scell_result}'=='FAIL'
#     sleep    10s
#     Log To Console      wait for counter ready
#     Sleep    10 min    reason=wait for counter ready
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}

CB009059-AD_04 Interworking with HRDRB and UL CA HRDRB is Not FR1 CA eligible and DL UL SCell does not support high reliability
    [Documentation]    author:keli
    ...    CB009059_AD_04 ET Test
    ...    1. The purpose of this test case is to check following scenarios:
    ...    UE without Ich-ToSCellRestriction capability in UL CA and Scell is not high reliability supporting.
    ...    When there is one Not CA eligible HRDRB established, All DL and UL scells will be released.
    ...    2. Test Case Steps:
    ...         Step A. UE attach to Cell1 with FR1 CA eligible DRB1,
    ...                 then setup with Not FR1 CA eligible HRDRB2
    ...         Step B. Send DL/UL traffic data to all DRBs
    ...         Step C. Trigger scell addtion again
    ...    3. Expected Results:
    ...         Step A: Scell-2 DL, Scell-3 DL/UL
    ...         Step B: Scell relase, data traffic are scheduling in each DRB on Pcell only
    ...         Step C: Scell-2 DL/UL, Scell-3 DL
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_FDD_4c_1gNBSim_HR04
    ...    base_path=${CURDIR}/Airphone
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12006;
    ...    Counter rule: max(M55319C12006)>0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12007;
    ...    Counter rule: max(M55319C12007)>0;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-2;
    ...    Counter: M55310C20000;
    ...    Counter rule: max(M55310C20000)>0;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-3;
    ...    Counter: M55310C20000;
    ...    Counter rule: max(M55310C20000)>0;
    Disable actLAForHiReliab    cell_i=3
    Start Multi Bts Log
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Airphone Execute Egate Command    cmd=set_pdu_param ue=3 pdu=1 qfi=1 trf_type=internal
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=set_pdu_param ue=3 pdu=1 qfi=2 trf_type=internal
    ...    pass_regexp=${None}
    sleep    2s
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=3 default=on
    ...    pass_regexp=${None}
    Airphone Attach    ue_id=3    call_type=SA
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Log To Console      ${\n}============= Setup PDU1 5qi7 =============${\n}
    sleep    2s
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=175 trf_id=3
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=175 trf_id=4
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=100 trf_id=5
    Log To Console      ${\n}============= DL traffic 1 is started. =============${\n}
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=175 trf_id=1
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=175 trf_id=2
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=175 trf_id=3
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=100 trf_id=4
    Log To Console      ${\n}============= UL traffic 1 is started. =============${\n}
    sleep    10s
    # ${tput_dl1}    Airphone Get Average Throughput    ue_id=3    pdu_id=1    qfi=1    dir=dl
    # ${tput_ul1}    Airphone Get Average Throughput    ue_id=3    pdu_id=1    qfi=1    dir=ul
    Airphone Execute Egate Command    cmd=ue_stats_nr id=3 type=pdsch scell=0,1,2
    ...    pass_regexp=3 cells
    Airphone Execute Egate Command    cmd=ue_stats_nr id=3 type=pusch scell=0,1,2
    ...    pass_regexp=2 cells
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=2
    ...    pass_regexp=QoS Routing Table
    sleep    3s
    Log To Console      ${\n}============= Added 5QI6. =============${\n}
    sleep    5s
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=dl mbps=175 trf_id=1
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=dl mbps=175 trf_id=2
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=dl mbps=175 trf_id=3
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=dl mbps=100 trf_id=4
    Log To Console      ${\n}============= DL traffic 2 is started. =============${\n}
    sleep    10s
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=ul mbps=175 trf_id=1
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=ul mbps=175 trf_id=2
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=ul mbps=175 trf_id=3
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=ul mbps=100 trf_id=4
    Log To Console      ${\n}============= UL traffic 2 is started. =============${\n}
    sleep    10s
    ${tput_dl1}    Airphone Get Average Throughput    ue_id=3    pdu_id=1    qfi=1    dir=dl
    ${tput_dl2}    Airphone Get Average Throughput    ue_id=3    pdu_id=1    qfi=2    dir=dl
    ${tput_ul1}    Airphone Get Average Throughput    ue_id=3    pdu_id=1    qfi=1    dir=ul
    ${tput_ul2}    Airphone Get Average Throughput    ue_id=3    pdu_id=1    qfi=2    dir=ul
    sleep    10s
    Airphone Execute Egate Command    cmd=ue_stats_nr id=3 type=pdsch scell=0,1,2
    ...    pass_regexp=3 cells
    Airphone Execute Egate Command    cmd=ue_stats_nr id=3 type=pusch scell=0,1,2
    ...    pass_regexp=1 cell
    Run Keyword And Ignore Error       Get Tput for scell    ue_id=3    scellidx=0
    Sleep    8 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check throughput =============${\n}
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}


# CB009059_C_03_ULCA with UM RLC mode DRB when cellAggrLevel is FR1 CA eligible
#     [Documentation]    author:keli
#     ...    CB009059_C_03 ET Test
#     ...    5QI-7 FR1 CA eligible
#     ...    5QI-9 FR1 CA eligible UM
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_FDD_4c_1gNBSim_UM
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C16009;
#     ...    Counter rule: max(M55319C16009)>0;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55118C00034,M55118C00035;
#     ...    Counter rule: M55118C00034==M55118C00035;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55118C00035;
#     ...    Counter rule: M55118C00035==0;
#     ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Start Multi Bts Log
#     sleep    2s
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=1 trf_type=internal
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=2 trf_type=internal
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=3 default=on
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Attach is done. =============${\n}
#     Log To Console      ${\n}============= Setup PDU1 5qi7. =============${\n}
#     sleep    5s
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=100 trf_id=4
#     Log To Console      ${\n}============= UL traffic 1 is started. =============${\n}
#     sleep    10s
#     # Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1,2
#     # ...    pass_regexp=3 cells
#     Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pusch scell=0,1,2
#     ...    pass_regexp=2 cells
#     Log To Console      ${\n}============= scell Index checked. =============${\n}
#     sleep    2s
#     Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=5
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Added 5QI9. =============${\n}
#     sleep    5s
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=4
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100 trf_id=5
#     Log To Console      ${\n}============= DL traffic 1 is started. =============${\n}
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=100 trf_id=4
#     Log To Console      ${\n}============= DL traffic 2 is started. =============${\n}
#     sleep    10s
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=ul mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=ul mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=ul mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=ul mbps=100 trf_id=4

#     Log To Console      ${\n}============= UL traffic 2 is started. =============${\n}
#     ${tput_dl1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${tput_dl2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=dl
#     ${tput_ul1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=ul
#     ${tput_ul2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=ul
#     sleep    10s
#     Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1,2
#     ...    pass_regexp=3 cells
#     Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pusch scell=0,1,2
#     ...    pass_regexp=2 cells
#     Get Tput for scell    scellidx=0
#     Get Tput for scell    scellidx=1
#     Get Tput for scell    scellidx=2
#     Airphone Execute Egate Command     cmd=trf_data_stop ue=1 pdu=all dir=ul
#     Log To Console      ${\n}============= UL traffic is stopped. =============${\n}
#     sleep    5s
#     Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1,2
#     ...    pass_regexp=3 cells
#     Airphone Execute Egate Command     cmd=trf_data_stop ue=1 pdu=all dir=dl
#     sleep    10s
#     Log To Console      ${\n}============= DL traffic is stopped. =============${\n}
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=1
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=2
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=3
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=175 trf_id=4
#     Airphone Execute Egate Command     cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=100 trf_id=5
#     Log To Console      ${\n}============= DL traffic 2 is started. =============${\n}
#     sleep    10s
#     Airphone Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1,2
#     ...    pass_regexp=3 cells
#     Log To Console      wait for counter ready
#     Sleep    10 min    reason=wait for counter ready
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}

CB009059_C_05_ULCA with UM RLC mode DRB when cellAggrLevel is Not FR1 CA eligible UE does not support lch-ToSCellRestriction
    [Documentation]    author:keli
    ...    CB009059_C_05 ET Test
    ...    5QI-7 FR1 CA eligible
    ...    5QI-9 FR1 CA eligible UM
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_FDD_4c_1gNBSim_UM
    ...    base_path=${CURDIR}/Airphone
    Change Param cellAggrLevel of DRB    drb_index=14    val=${cellaggr_level}[1]
    Start Multi Bts Log
    sleep    2s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=3 pdu=1 qfi=1 trf_type=internal
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=set_pdu_param ue=3 pdu=1 qfi=2 trf_type=internal
    ...    pass_regexp=${None}
    sleep    2s
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=3 default=on
    ...    pass_regexp=${None}
    Airphone Attach    ue_id=3    call_type=SA
    Log To Console      ${\n}============= UE 3 Attach is done. =============${\n}
    Log To Console      ${\n}============= Setup PDU1 5qi7. =============${\n}
    sleep    5s
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=175 trf_id=1
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=175 trf_id=2
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=175 trf_id=3
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=100 trf_id=4
    Log To Console      ${\n}============= UL traffic 1 is started. =============${\n}
    sleep    10s
    Airphone Execute Egate Command    cmd=ue_stats_nr id=3 type=pusch scell=0,1,2
    ...    pass_regexp=2 cells
    Log To Console      ${\n}============= scell Index checked. =============${\n}
    sleep    2s
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=5
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Added 5QI9. =============${\n}
    sleep    5s
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=175 trf_id=3
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=175 trf_id=4
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=100 trf_id=5
    Log To Console      ${\n}============= DL traffic 1 is started. =============${\n}
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=dl mbps=175 trf_id=1
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=dl mbps=175 trf_id=2
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=dl mbps=175 trf_id=3
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=dl mbps=100 trf_id=4
    Log To Console      ${\n}============= DL traffic 2 is started. =============${\n}
    sleep    10s
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=ul mbps=175 trf_id=1
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=ul mbps=175 trf_id=2
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=ul mbps=175 trf_id=3
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=ul mbps=100 trf_id=4
    Log To Console      ${\n}============= UL traffic 2 is started. =============${\n}
    ${tput_dl1}    Airphone Get Average Throughput    ue_id=3    pdu_id=1    qfi=1    dir=dl
    ${tput_dl2}    Airphone Get Average Throughput    ue_id=3    pdu_id=1    qfi=2    dir=dl
    ${tput_ul1}    Airphone Get Average Throughput    ue_id=3    pdu_id=1    qfi=1    dir=ul
    ${tput_ul2}    Airphone Get Average Throughput    ue_id=3    pdu_id=1    qfi=2    dir=ul
    sleep    10s
    Airphone Execute Egate Command    cmd=ue_stats_nr id=3 type=pdsch scell=0,1,2
    ...    pass_regexp=3 cells
    Get Tput for scell    ue_id=3    scellidx=0
    Get Tput for scell    ue_id=3    scellidx=1
    Get Tput for scell    ue_id=3    scellidx=2
    Airphone Execute Egate Command    cmd=ue_stats_nr id=3 type=pusch scell=0,1,2
    ...    pass_regexp=2 cells
    Airphone Execute Egate Command     cmd=trf_data_stop ue=3 pdu=all dir=ul qfi=1
    Log To Console      ${\n}============= UL traffic 1 is stopped. =============${\n}
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_stats_nr id=3 type=pusch scell=0,1,2
    ...    pass_regexp=2 cells
    Airphone Execute Egate Command     cmd=trf_data_stop ue=3 pdu=all dir=dl
    sleep    10s
    Log To Console      ${\n}============= DL traffic is stopped. =============${\n}
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=dl mbps=175 trf_id=1
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=dl mbps=175 trf_id=2
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=dl mbps=175 trf_id=3
    Airphone Execute Egate Command     cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=dl mbps=100 trf_id=4
    Log To Console      ${\n}============= DL traffic 2 is started. =============${\n}
    sleep    10s
    Airphone Execute Egate Command    cmd=ue_stats_nr id=3 type=pdsch scell=0,1,2
    ...    pass_regexp=3 cells
    Run Keyword And Ignore Error       Get Tput for scell    scellidx=1
    Run Keyword And Ignore Error       Get Tput for scell    scellidx=2
    Log To Console      ${\n}============= checked Only Pcell scheduled. =============${\n}



*** Keywords ***
Check Ave Tput via bearer stats
    [Documentation]     check the average of two tput value
    [Arguments]    ${ue_id}=3    ${pdu_id}=1   ${qfi_id}=1
    ...    ${dir}=dl   ${expected_tput_max}=10000000    ${expected_tput_min}=0
    ${tput_v1}    Airphone Get Average Throughput    ue_id=${ue_id}
    ...    pdu_id=${pdu_id}    qfi=${qfi_id}    dir=${dir}
    sleep    2s
    ${tput_v2}    Airphone Get Average Throughput    ue_id=${ue_id}
    ...    pdu_id=${pdu_id}    qfi=${qfi_id}    dir=${dir}
    ${arg_tput}=    Evaluate    (${tput_v1} + ${tput_v2})/2
    Should be true    ${arg_tput}<=${expected_tput_max}
    Should be true    ${arg_tput}>=${expected_tput_min}
    [Return]    ${arg_tput}

Get Tput for scell
    [Documentation]    check Per cell DL tput
    [Arguments]    ${ue_id}=1    ${scellidx}=1
    ${min_tput}    ${max_tput}    ${avg_tput}
    ...    Airphone Get Detail Throughput For Per Scell    ue_id=${ue_id}    scell_index=${scellidx}

Disable DRB Profile for CA Level
    ${out}   Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...    delta_file_path=${CURDIR}/delta_plan_CB009059_ET_disable.json
    Log To Console    paramter update result: ${out}

Activate DRB Profile for CA Level
    ${out}   Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...    delta_file_path=${CURDIR}/delta_plan_CB009059_ET_enable.json
    Log To Console    paramter update result: ${out}

Disable actLAForHiReliab
    [Arguments]    ${cell_i}=1
    @{para_list}   Create List   actLAForHiReliab
    @{value_list}   Create List   false
    @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-${cell_i}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Change Param cellAggrLevel of DRB
    [Arguments]    ${drb_index}    ${val}
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    @{value_list}    Create List    ${val}
    ${dict}=    create dictionary    parameterName=cellAggrLevel
    ...                              operation=update
    ...                              value=@{value_list}
    @{parameter_list}    Create List    ${dict}
    coam_admin.perform_object_recommissioning
    ...    dist_name=MRBTS-1/NRBTS-1/NRDRB-${drb_index}
    ...    parameter_delta_list=${parameter_list}    operation=update    connection=commission
    [Teardown]    COAM_Admin.Logout    connection=commission

Set Param maxNumOfSCellAlloc To Zero
    @{cell_l}=    Create List    2    3    4
    Change Param maxNumOfSCellAlloc    @{cell_l}    target_value=${0}

Set Param maxNumOfSCellAlloc To Default Value
    @{cell_l}=    Create List    2    3    4
    Change Param maxNumOfSCellAlloc    @{cell_l}    target_value=${250}


Change Param maxNumOfSCellAlloc
    [Arguments]    @{cell_list}    ${target_value}
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${dict1}=    create dictionary    parameterName=maxNumOfSCellAlloc
    ...                              operation=update
    ...                              value=${target_value}
    ${parameter_list}    Create List    ${dict1}
    FOR   ${cell_i}    IN    @{cell_list}
        coam_admin.perform_object_recommissioning
        ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_i}
        ...    parameter_delta_list=${parameter_list}    operation=update    connection=commission
    END
    [Teardown]    COAM_Admin.Logout    connection=commission