*** Settings ***
Documentation
...    Author:  Hou Yuguo
...    Contact: yuguo.hou@nokia-sbell.com
...    Feature: CNI99703
...    Release:

Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LOOO
...    SBTS00    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF

Resource    ../resources/Airphone/Airphone_resource.robot
Resource    ../resources/common_resource_bts.robot
Library     ../resources/python/KISS/ta_kiss_gnb/

*** Variables ***
&{GNB_ASIB}       ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
@{tp_target_cells_list1}    2
@{tp_target_cells_list2}    2
${dltp_threshold}          17000000000
${ultp_threshold}          7000000000

*** Test Cases ***
CNI99703_TC03_NR_FR1_TDD_eCPRI_ABIO_6Cells_8DL8UL_100MHz_MultiUE_L3Call_Stability
    [Documentation]
    ...    This case is to verify NR L3 call stability on ABIO with FR1 TDD eCPRI 6*8DL8UL cells.
    ...    And also verify 16 UEs per slot to be allocated.
    [Tags]    ABIO    CNI99703    6cells8D8U    CNI99703_US03    Trunk
    ${random_cell_id}    Generate Random Cell Id
    Ue Attach 1-100 To Cell-${random_cell_id} And Start L3 Call
    Verify Tput Every 600 Seconds Totally 5 Rounds
    [Teardown]    Run Keywords     traffic_data_stop    ue_id=1-100    AND    Ue Pdu Session Release    ue_id=1-100
    ...    AND    release ues    ue_id=1-100    AND    Collect Snapshot GNB1    AND    Common Test Teardown And Stop Capture Logs

CNI99703_TC04_NR_FR1_TDD_eCPRI_ABIO_6Cells_8DL8UL_100MHz_MultiUE_Block_Unblock
    [Documentation]
    ...    This case is to verify NR L3 call stability on ABIO with block/unblock cells.
    ...    And also verify 16 UEs per slot to be allocated.
    [Tags]    ABIO    CNI99703    6cells8D8U    CNI99703_US04    Trunk
    Repeat Keyword    3 times    Block And Unblock Cells then Attach Multi-UEs Start L3 Call

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=AP_LOOO/tdd_sansa_cmwv/FS/6cells_ecpri_8dl8ul    cfg=auto    ue_count=120    withCommission=True

Generate Random Cell Id
    ${target_cell}      Evaluate    random.choice([1, 2, 3, 4, 5, 6])    random
    ${target_cell_list}    Create List    ${target_cell}
    Set Test Variable    ${target_cell_list}
    [Return]    ${target_cell}

Ue Attach ${start_ue_id}-${stop_ue_id} To Cell-${cell_num} And Start L3 Call
    ${start_ue_id}    Convert To Integer    ${start_ue_id}
    ${stop_ue_id}     Convert To Integer    ${stop_ue_id}
    ${cell_num}       Convert To Integer    ${cell_num}
    Log To Console     \n[ INFO ]Start attach ${stop_ue_id} UEs to cell-${cell_num} ... ...
    multiple_ue_register_and_traffic_start    ue_num=${stop_ue_id}    start_ue=${start_ue_id}    cell_id=${cell_num}    dl_mbps=5   ul_mbps=5

Verify Tput Every ${sleep_time} Seconds Totally ${number} Rounds
    FOR    ${round}    IN RANGE    ${number}
        Log To Console    \n[ INFO ]Start to check tput every ${sleep_time} seconds ... [ ${round+1}/${number} rounds] ...
        Sleep    ${sleep_time}
        get_all_active_and_idle_ues
        Verify Tput By PMCounter    ${dltp_threshold}    ${ultp_threshold}    ${target_cell_list}
    END

Verify Tput By PMCounter
    [Arguments]    ${dltp_threshold}    ${ultp_threshold}    ${target_cells_list}
    ${pm_counter_file}=    Download Latest Pmcounter    ${SAVE LOG DIRECTORY}
    FOR    ${cell}    IN    @{target_cells_list}
        Log To Console     ------------------------------------------ Cell-${cell} ------------------------------------------
        ${DL_tput_cell}    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C01006    cell_id=${cell}
        ${UL_tput_cell}    get_counter_value_from_counter_file    ${pm_counter_file}    M55310C03006    cell_id=${cell}
        Log To Console     DL RLC data PDU volume transmitted by Low RLC - QoS Group 06 (M55310C01006) -- ${DL_tput_cell}
        Log To Console     UL RLC data PDU volume received by Low RLC - QoS Group 06 (M55310C03006) ----- ${UL_tput_cell}
        Run Keyword And Continue On Failure    Should Be True    ${DL_tput_cell}>=${dltp_threshold}
        ...    [ERROR]DL TP is NOT achieved on target: ${DL_tput_cell} >= ${dltp_threshold}
        Run Keyword And Continue On Failure    Should Be True    ${UL_tput_cell}>=${ultp_threshold}
        ...    [ERROR]UL TP is NOT achieved on target: ${UL_tput_cell} >= ${ultp_threshold}
    END

Block And Unblock Cells then Attach Multi-UEs Start L3 Call
    Log To Console    \n[ INFO ]Block then Unblock cells ... ...
    FOR    ${cell}    IN RANGE    6
        Perform 5G Cell block ${cell+1} via AdminCLI
        Perform 5G Cell unblock ${cell+1} via AdminCLI
    END
    Sleep    22s
    ${random_cell_id}    Generate Random Cell Id
    Ue Attach 1-100 To Cell-${random_cell_id} And Start L3 Call
    Sleep    300s
    Verify Tput By PMCounter    ${dltp_threshold}    ${ultp_threshold}    ${target_cell_list}
    [Teardown]    Run Keywords    traffic_data_stop    ue_id=1-100    AND    Ue Pdu Session Release    ue_id=1-100
    ...    AND    release ues    ue_id=1-100    AND    Collect Snapshot GNB1
