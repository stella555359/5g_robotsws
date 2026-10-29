*** Settings ***
Documentation
...    Author: Chen Jiahao
...    Contact: jiahao.chen@nokia-sbell.com
...    this file is for CB012582_CR.
...    Please do not modify the file without notification to author


Resource           ../Resources/vran_resource.robot
Suite Setup       Common Suite Setup For AIC
Test Setup        Run keywords    Common Test Setup For AIC    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common Test Teardown For AIC
Suite Teardown    Common Suite Teardown For AIC
Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20?TA_LEVEL_21? TA_LEVEL_22]

Test Timeout    600 minutes

*** Variables ***
${PA_MaxValue}           ${120}
${PA_NormalValue}        ${1}
${PA_MinValue}           ${0}
${FLAG_USE_UE_MODULE}    ${True}
${host}              10.56.198.156
${username}          ute
${password}          Nokia123!
${file_path1}         ${CURDIR}/UE_AMBR.txt
${file_path2}         ${CURDIR}/PDU_AMBR.txt
${file_path3}         ${CURDIR}/UE_AMBR_decrease.txt
${file_path4}         ${CURDIR}/PDU_AMBR_decrease.txt

# ${DEBUG_MODE}         ${True}

*** Test Cases ***
# Upgrade
#     AIC Upgrade vCU And vDu by Kuafu For All

# USCB008234_counters_for_AMBR_value_distribution_with_newly_received_and_validated_AMBR_value

#     Load CB008234 SCF for vDU
#     Load CB008234 SCF for vCU
#     Sleep    1 minute
#     wait until keyword succeeds    10 min    30 sec    Check All Cells On Air In Multiple vCU
#     wait until keyword succeeds    20 min    30 sec    vDU Check All Cells Status Should Be Onair

#     Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}    ${file_path1}
#     Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}    ${file_path2}

#     AT.Prepare UE
#     AT.UE Detach
#     sleep    10s

#     Unblock TDD NRCell-2
#     Log To Console    sleep 12min
#     sleep    10min

#     Check CB008234 related counters origin and limit by UE AMBR DL_30M UL_10M
#     Stop DL and UL traffic
#     sleep    10s
#     #############################################
#     Check CB008234 related counters decrease and limit by UE AMBR DL_20M UL_5M
#     Stop DL and UL traffic
#     sleep    10s
#     ############################################
#     Check CB008234 related counters increase and limit by UE AMBR DL_30M UL_10M

CB012582_A_1_SA Intra-gNB Inter-DU Inter-Freq HO Interruption time Target Range

    # Load CB012582_A_1 SCF for vDU TDD
    # # Load CB012582_A_1 SCF for vDU FDD
    # Load CB012582_A_1 SCF for vCU
    # Sleep    1 minute
    # wait until keyword succeeds    30 min    30 sec    Check All Cells On Air In Multiple vCU
    # wait until keyword succeeds    30 min    30 sec    vDU Check All Cells Status Should Be Onair

    # Unblock FDD NRCell-1

    # AT Operation    detach
    # sleep    10s
    # Check CB012582_A_1 inter DU HO related counters
    set_testline_cell_status_onair

    recover_testline_cell_status_initial
CB012299_B_7_Triggering of transition from limited bandwidth to nominal bandwidth mode

    # Load CB012299 SCF for vDU TDD
    # Load CB012299 SCF for vCU
    # Sleep    1 minute
    # wait until keyword succeeds    30 min    30 sec    Check All Cells On Air In Multiple vCU
    # wait until keyword succeeds    30 min    30 sec    vDU Check All Cells Status Should Be Onair

    # Unblock AKNB NRCell-3


    # AT Operation    detach    ue_index=1
    # sleep    10s
    # AT Operation    attach    ue_index=1
    # sleep    20s

    # Start DL traffic for CB012299
    # Check CB012299 small Tput counter
    # # Stop DL and UL traffic

    # AT Operation    detach    ue_index=1
    # sleep    2min

    # Check CB012299 limited to nominal Tput and change counters

    # AT Operation    detach    ue_index=1
    # sleep    2min

    # Check CB012299 nominal to limited Tput and change counters

    Online modify parameter to nominal bandwidth on vDU
    sleep    15s
    Online modify parameter to limited bandwidth on vDU
    sleep    15s
    Online modify parameter to nominal bandwidth on vDU

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    # Log To Console    Set PA to max
    # Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Setup
    Run Keyword And Ignore Error    AT Operation    operation=stop_traffic    direction=dl
    Run Keyword And Ignore Error    AT Operation    operation=stop_traffic    direction=ul

# Load CB008234 SCF for vDU
#     Parameter Operation    operation=full_commission   product_type=vdu
#     ...    scf_path=${CURDIR}/vdu_CB008234_SCF_BTS37256.xml

# Load CB008234 SCF for vCU
#     Parameter Operation    operation=full_commission   product_type=vcu
#     ...    scf_path=${CURDIR}/vcu_CB008234_SCF_BTS37020.xml

Unblock TDD NRCell-2
    Log To Console    Unblock TDD NRCell-2
    ${source_pa_port_list}     Create List     1    34
    ${source_pa_value_list}    Create List     0    0
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...    step=${1}    pa_type=32*8
    PA Operation    source=&{source}    target=none

Unblock FDD NRCell-1
    Log To Console    Unblock FDD NRCell-1
    ${source_pa_port_list}     Create List     66    74    81    92
    ${source_pa_value_list}    Create List     0    0
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...    step=${1}    pa_type=32*8
    PA Operation    source=&{source}    target=none

Start DL and UL traffic
    Log To Console    Start DL and UL traffic
    AT Operation    operation=start_traffic    IperfOptions=-u -i 1 -t 1200 -b 100M -p 5001 -l 1024
    ...    remote_hostname=10.56.198.156    remote_username=ute    remote_password=UTE.debian12
    ...    direction=dl

    AT Operation    operation=start_traffic    IperfOptions=-u -i 1 -t 1200 -b 10M -p 5001 -l 1024
    ...    remote_hostname=10.56.198.156    remote_username=ute    remote_password=UTE.debian12
    ...    direction=ul

Stop DL and UL traffic
    AT Operation    operation=stop_traffic    direction=dl
    AT Operation    operation=stop_traffic    direction=ul

# Check CB008234 related counters origin and limit by UE AMBR DL_30M UL_10M
#     Log To Console    Check CB008234 related counters origin and limit by UE AMBR DL_30M UL_10M
#     # origin value:
#     # ${rule1}  SA_DL_UE_AMBR_AVG  M55125C13036  30 000 000
#     # ${rule2}  SA_UL_UE_AMBR_AVG  M55125C13037  10 000 000
#     # ${rule3}  SA_DL_PDU_AMBR_AVG  M55125C13038  1 138 592 704 000 = (2 277 065 408 000(5QI5) + 120 000 000(5QI7))/2
#     # ${rule4}  SA_UL_PDU_AMBR_AVG  M55125C13039  1 230 010 000 000 = (2 460 000 000 000(5QI5) + 20 000 000(5QI7))/2
#     # ${rule5}  SA_DL_AMBR_INCREASE  M55125C13040  NRCell-2    0
#     # ${rule6}  SA_UL_AMBR_INCREASE  M55125C13041  NRCell-2    0
#     # ${rule7}  SA_DL_AMBR_DECREASE  M55125C13042  NRCell-2    0
#     # ${rule8}  SA_UL_AMBR_DECREASE  M55125C13043  NRCell-2    0

#     ${rule1}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13036;
#     ...         Counter rule: max(M55125C13036)==30000000
#     ${rule2}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13037;
#     ...         Counter rule: max(M55125C13037)==10000000
#     ${rule3}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13038;
#     ...         Counter rule: max(M55125C13038)==1138592704000
#     ${rule4}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13039;
#     ...         Counter rule: max(M55125C13039)==1230010000000
#     ${rule5}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13040;
#     ...         Counter rule: max(M55125C13040)==0
#     ${rule6}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13041;
#     ...         Counter rule: max(M55125C13041)==0
#     ${rule7}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13042;
#     ...         Counter rule: max(M55125C13042)==0
#     ${rule8}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13043;
#     ...         Counter rule: max(M55125C13043)==0
#     ${rule9}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020;
#     ...         Counter: M55319C12007;
#     ...         Counter rule: max(M55319C12007)*8/300<31000
#     ${rule10}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020;
#     ...         Counter: M55319C16007;
#     ...         Counter rule: max(M55319C16007)*8/300<11000
#     ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
#     ...    ${rule5}    ${rule6}   ${rule7}    ${rule8}    ${rule9}    ${rule10}
#     Counter Operation    operation=start_collect_counter    product_type=vcu
#     ...                                                     cudu_index=0
#     ...                                                     counter_rule=${rule_list}

#     AT.UE Attach
#     Sleep    10s    reason=Wait For Attach

#     Start DL and UL traffic

#     Log To Console    sleep 10min
#     sleep    10min
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    cudu_index=0

# Check CB008234 related counters decrease and limit by UE AMBR DL_20M UL_5M
#     Log To Console    Check CB008234 related counters decrease and limit by UE AMBR DL_20M UL_5M
#     # decrease value:
#     # ${rule1}  SA_DL_UE_AMBR_AVG  M55125C13036  30 000 000
#     # ${rule2}  SA_UL_UE_AMBR_AVG  M55125C13037  10 000 000
#     # ${rule3}  SA_DL_PDU_AMBR_AVG  M55125C13038  1 138 592 704 000
#     # ${rule4}  SA_UL_PDU_AMBR_AVG  M55125C13039  1 230 015 000 000
#     # ${rule5}  SA_DL_AMBR_INCREASE  M55125C13040  NRCell-2    0
#     # ${rule6}  SA_UL_AMBR_INCREASE  M55125C13041  NRCell-2    0
#     # ${rule7}  SA_DL_AMBR_DECREASE  M55125C13042  NRCell-2    1
#     # ${rule8}  SA_UL_AMBR_DECREASE  M55125C13043  NRCell-2    1

#     ${rule1}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13036;
#     ...         Counter rule: max(M55125C13036)==20000000
#     ${rule2}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13037;
#     ...         Counter rule: max(M55125C13037)==5000000
#     ${rule3}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13038;
#     ...         Counter rule: max(M55125C13038)==100000000
#     ${rule4}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13039;
#     ...         Counter rule: max(M55125C13039)==10000000
#     ${rule5}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13040;
#     ...         Counter rule: max(M55125C13040)==0
#     ${rule6}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13041;
#     ...         Counter rule: max(M55125C13041)==0
#     ${rule7}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13042;
#     ...         Counter rule: max(M55125C13042)==1
#     ${rule8}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13043;
#     ...         Counter rule: max(M55125C13043)==1
#     ${rule9}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020;
#     ...         Counter: M55319C12007;
#     ...         Counter rule: min(M55319C12007)*8/300<21000
#     ${rule10}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020;
#     ...         Counter: M55319C16007;
#     ...         Counter rule: min(M55319C16007)*8/300<6000
#     ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
#     ...    ${rule5}    ${rule6}   ${rule7}    ${rule8}    ${rule9}    ${rule10}
#     Counter Operation    operation=start_collect_counter    product_type=vcu
#     ...                                                     cudu_index=0
#     ...                                                     counter_rule=${rule_list}

#     sleep    1min
#     Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}    ${file_path3}
#     Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}    ${file_path4}

#     Start DL and UL traffic
#     Log To Console    sleep 10min
#     sleep    10min
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    cudu_index=0

# Check CB008234 related counters increase and limit by UE AMBR DL_30M UL_10M
#     Log To Console    Check CB008234 related counters increase and limit by UE AMBR DL_30M UL_10M
#     # increase value:
#     # ${rule1}  SA_DL_UE_AMBR_AVG  M55125C13036  30 000 000
#     # ${rule2}  SA_UL_UE_AMBR_AVG  M55125C13037  10 000 000
#     # ${rule3}  SA_DL_PDU_AMBR_AVG  M55125C13038  1 138 592 704 000
#     # ${rule4}  SA_UL_PDU_AMBR_AVG  M55125C13039  1 230 015 000 000
#     # ${rule5}  SA_DL_AMBR_INCREASE  M55125C13040  NRCell-2    1
#     # ${rule6}  SA_UL_AMBR_INCREASE  M55125C13041  NRCell-2    1
#     # ${rule7}  SA_DL_AMBR_DECREASE  M55125C13042  NRCell-2    0
#     # ${rule8}  SA_UL_AMBR_DECREASE  M55125C13043  NRCell-2    0

#     ${rule1}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13036;
#     ...         Counter rule: max(M55125C13036)==30000000
#     ${rule2}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13037;
#     ...         Counter rule: max(M55125C13037)==10000000
#     ${rule3}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13038;
#     ...         Counter rule: max(M55125C13038)==120000000
#     ${rule4}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13039;
#     ...         Counter rule: max(M55125C13039)==20000000
#     ${rule5}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13040;
#     ...         Counter rule: max(M55125C13040)==1
#     ${rule6}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13041;
#     ...         Counter rule: max(M55125C13041)==1
#     ${rule7}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13042;
#     ...         Counter rule: max(M55125C13042)==0
#     ${rule8}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
#     ...         Counter: M55125C13043;
#     ...         Counter rule: max(M55125C13043)==0
#     ${rule9}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020;
#     ...         Counter: M55319C12007;
#     ...         Counter rule: max(M55319C12007)*8/300<31000
#     ${rule10}    Catenate
#     ...         Distname: MRBTS-37020/NRBTS-37020;
#     ...         Counter: M55319C16007;
#     ...         Counter rule: max(M55319C16007)*8/300<11000
#     ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
#     ...    ${rule5}    ${rule6}   ${rule7}    ${rule8}    ${rule9}    ${rule10}
#     Counter Operation    operation=start_collect_counter    product_type=vcu
#     ...                                                     cudu_index=0
#     ...                                                     counter_rule=${rule_list}

#     sleep    1min
#     Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}    ${file_path1}
#     Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}    ${file_path2}

#     Start DL and UL traffic

#     Log To Console    sleep 10min
#     sleep    10min
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    cudu_index=0

Load CB012582_A_1 SCF for vDU TDD
    Parameter Operation    operation=full_commission   product_type=vdu
    ...    scf_path=${CURDIR}/vdu_CB012582_A_1_DU_TDD_BTS37020.xml

Load CB012582_A_1 SCF for vDU FDD
    Parameter Operation    operation=full_commission   product_type=vdu    cudu_index=1
    ...    scf_path=${CURDIR}/vdu_CB012582_A_1_DU_FDD_BTS37020.xml

Load CB012582_A_1 SCF for vCU
    Parameter Operation    operation=full_commission   product_type=vcu
    ...    scf_path=${CURDIR}/vcu_CB012582_A_1_BTS37020.xml

HO from NRCell1_FDD to NRCell2_TDD
    Log To Console    HO from NRCell1_FDD to NRCell2_TDD
    ${source_pa_port_list}     Create List    66    74    81    92
    ${source_pa_value_list}    Create List    0    60
    ${target_pa_port_list}     Create List    1    34
    ${target_pa_value_list}    Create List    90    0
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}    pa_type=32*8
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${90}    pa_type=32*8
    PA Operation    source=&{source}    target=&{target}

HO from NRCell2_TDD to NRCell1_FDD
    Log To Console    HO from NRCell2_TDD to NRCell1_FDD
    ${source_pa_port_list}     Create List    1    34
    ${source_pa_value_list}    Create List    0    60
    ${target_pa_port_list}     Create List    66    74    81    92
    ${target_pa_value_list}    Create List    90    0
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}    pa_type=32*8
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${90}    pa_type=32*8
    PA Operation    source=&{source}    target=&{target}

Increase FDD NRCell-1
    Log To Console    Increase FDD NRCell-1
    ${source_pa_port_list}     Create List     66    74    81    92
    ${source_pa_value_list}    Create List     0    60
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...    step=${10}    pa_type=32*8
    PA Operation    source=&{source}    target=none

Start DL traffic for CB012582
    Log To Console    Start DL traffic for CB012582
    AT Operation    operation=start_traffic    IperfOptions=-u -i 1 -t 1200 -b 100M -p 5001 -l 1024
    ...    remote_hostname=10.56.198.156    remote_username=ute    remote_password=UTE.debian12
    ...    direction=dl

Check CB012582_A_1 inter DU HO related counters
    Log To Console    Check CB012582_A_1 inter DU HO related counters
    # increase value:
    # ${rule1}  UP_IRPT_T_ITRDU_IF_HO_SA      M55379C00009  3
    # ${rule2}  UP_IRPT_T_ITRDU_IF_HO_SA_PMQ  M55385C00009  2

    ${rule1}    Catenate
    ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2;
    ...         Counter: M55379C00009;
    ...         Counter rule: max(M55379C00009)==3
    ${rule2}    Catenate
    ...         Distname: MRBTS-37020/NRBTS-37020/NRCELL-2/NRPMQAP-1;
    ...         Counter: M55385C00009;
    ...         Counter rule: max(M55385C00009)==3
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${rule_list}

    sleep    10s
    AT Operation    attach
    sleep    20s
    AT Operation    operation=start_call    number=6688
    sleep    10s
    Start DL traffic for CB012582
    sleep    10s
    HO from NRCell1_FDD to NRCell2_TDD
    Log To Console    sleep 8min
    sleep    8min
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    cudu_index=0

Cloud Get Snapshot And Check Auditlog Data
    Login To vCU By Rest    gnb_index=${0}
    ${Snapshot_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}
    ...                 directory_name=vcu_snapshot
    cu.Get_Local_Snapshot    ${Snapshot_path}    compressed=${False}
    # ${snapshot_path}=    Save Local Snapshot In vCU With Judge    gnb_index=0    local_snapshot_location=my_snapshot_dir
    unzip all files    ${Snapshot_path}
    ${ret}    OperatingSystem.run    find ${Snapshot_path} -name auditlog_data
    Should Not Be Equal    ${ret}    ${EMPTY}
    [Teardown]    Run Keyword And Ignore Error    Logout To vCU By Rest

unzip all files
    [Arguments]    ${path}
    ${zip_files}=    OperatingSystem.List Files In Directory    ${path}    pattern=*.zip
    FOR    ${zip_file}    IN    @{zip_files}
        Run Process    unzip    -o    ${path}/${zip_file}    -d    ${path}
    END


Load CB012299 SCF for vDU TDD
    Parameter Operation    operation=full_commission   product_type=vdu
    ...    scf_path=${CURDIR}/vdu_CB012299_TDD_BTS37020.xml

Load CB012299 SCF for vCU
    Parameter Operation    operation=full_commission   product_type=vcu
    ...    scf_path=${CURDIR}/vcu_CB012299_BTS37020.xml

Unblock AKNB NRCell-3
    Log To Console    Unblock AKNB NRCell-3
    ${source_pa_port_list}     Create List     101    110
    ${source_pa_value_list}    Create List     10    10
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...    step=${1}    pa_type=32*8
    PA Operation    source=&{source}    target=none

Start DL traffic for CB012299
    Log To Console    Start DL traffic for CB012299
    AT Operation    operation=start_traffic    IperfOptions=-u -i 1 -t 1800 -b 600M -p 5001 -l 1024
    ...    remote_hostname=10.56.198.156    remote_username=ute    remote_password=UTE.debian12
    ...    direction=dl    ue_index=1


Check CB012299 small Tput counter
    Log To Console    Check CB012299 small Tput counter

    ${rule1}    Catenate
    ...         Distname: MRBTS-37256/NRBTS-37020/NRCELL-3;
    ...         Counter: M55310C02007;
    ...         Counter rule: max(M55310C02007)<5800000
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter    product_type=vdu
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${rule_list}

    Log To Console    sleep 8min
    sleep    8min

    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vdu    cudu_index=0

Online modify parameter to nominal bandwidth on vDU
    Log To Console    Online modify parameter to nominal bandwidth on vDU

    @{para_list}      Create List    semiDynamicBwSize
    @{mo_list}        Create List    MRBTS-37256/NRBTS-37020/NRCELL-3
    @{value_list}     Create List    nominalBandwidth
    ${out}            Parameter Operation    operation=parameter_update    product_type=vdu    cudu_index=0
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}


Check CB012299 limited to nominal Tput and change counters
    Log To Console    Check CB012299 limited to nominal Tput and change counters

    ${rule1}    Catenate
    ...         Distname: MRBTS-37256/NRBTS-37020/NRCELL-3;
    ...         Counter: M55310C02007;
    ...         Counter rule: max(M55310C02007)>10000000
    ${rule2}    Catenate
    ...         Distname: MRBTS-37256/NRBTS-37020/NRCELL-3;
    ...         Counter: M55166C00025;
    ...         Counter rule: max(M55166C00025)==1
    ${rule3}    Catenate
    ...         Distname: MRBTS-37256/NRBTS-37020/NRCELL-3;
    ...         Counter: M55166C00026;
    ...         Counter rule: max(M55166C00026)==0
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter    product_type=vdu
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${rule_list}


    Online modify parameter to nominal bandwidth on vDU
    sleep    30s
    AT Operation    attach    ue_index=1
    sleep    20s
    Start DL traffic for CB012299
    Log To Console    sleep 8min
    sleep    12min
    # Stop DL and UL traffic

    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vdu    cudu_index=0


Online modify parameter to limited bandwidth on vDU
    Log To Console    Online modify parameter to limited bandwidth on vDU

    @{para_list}      Create List    semiDynamicBwSize
    @{mo_list}        Create List    MRBTS-37256/NRBTS-37020/NRCELL-3
    @{value_list}     Create List    limitedBandwidth
    ${out}            Parameter Operation    operation=parameter_update    product_type=vdu    cudu_index=0
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

Check CB012299 nominal to limited Tput and change counters
    Log To Console    Check CB012299 nominal to limited Tput and change counters

    ${rule1}    Catenate
    ...         Distname: MRBTS-37256/NRBTS-37020/NRCELL-3;
    ...         Counter: M55310C02007;
    ...         Counter rule: max(M55310C02007)<5800000
    ${rule2}    Catenate
    ...         Distname: MRBTS-37256/NRBTS-37020/NRCELL-3;
    ...         Counter: M55166C00025;
    ...         Counter rule: max(M55166C00025)==1
    ${rule3}    Catenate
    ...         Distname: MRBTS-37256/NRBTS-37020/NRCELL-3;
    ...         Counter: M55166C00026;
    ...         Counter rule: max(M55166C00026)==0
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter    product_type=vdu
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${rule_list}

    Online modify parameter to limited bandwidth on vDU
    sleep    30s
    AT Operation    attach    ue_index=1
    sleep    20s
    Start DL traffic for CB012299
    Log To Console    sleep 8min
    sleep    12min
    # Stop DL and UL traffic

    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vdu    cudu_index=0

set_testline_cell_status_onair
    BTS Operation    operation=cell_block           product_type=vdu    bts_index=0    distname_id=NRCELL-2       need_verify=True

recover_testline_cell_status_initial
    BTS Operation    operation=cell_unblock           product_type=vdu    bts_index=0    distname_id=NRCELL-2       need_verify=True
