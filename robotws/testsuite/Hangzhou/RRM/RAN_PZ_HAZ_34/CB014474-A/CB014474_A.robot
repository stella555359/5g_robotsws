*** Settings ***
Documentation     author: Chen Helen
...               contact: helen.1.chen@nokia-sbell.com
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource          ./resources/CB014474_A_common_keywords.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB013945/resources/CB013945_common_keywords.robot

*** Variables ***
${ul_2ues_throughput}    400
${dl_2ues_throughput}    2800
${dl_2ues_throughput_bler}    2100
${if_commissioning}    False
@{cpe_cell92_ues_index}    0    1
@{nrcell_id}    185663489
@{diff_dl_throughput}    1200    500
${diff_dl_2ues_throughput}    1700
@{spark_ue_list}    5
${spark_ul_tp}    10Mbits/sec
${spark_dl_tp}    10Mbits/sec
${ul_2ues_tput_80M}    300
${dl_2ues_tput_80M}    2200
${apn}    dxdata1
${single_cpe_ue_index}    0
${MTP_ue_index}    9
${MTP_ul_tp}     10
${MTP_dl_tp}    400

*** Test Cases ***
[1]CB014474-SR-A_1_Switching 2 MU-MIMO paired users to dynamically RAT0 as init-TX tansmission with 100MHz BW
    [Documentation]
    [Tags]
    [Setup]    Case_Setup
    ${SCF_CB014474-A}    Replace String    ${Golden_SCF_Path}    .xml    _CB014474-A.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB014474-A}
    Muti_CPE_UEs_UL_DL_Traffic    ue_index=${1}    cpe_ue_index=${cpe_cell92_ues_index}
    Retry Check UEs Pair With Rat0    check_type=init-Tx
    Multi_UEs_Check_Tput_CAdisable    cell_ids=${nrcell_id}    ultarget_throughput=${ul_2ues_throughput}
    ...    dltarget_throughput=${dl_2ues_throughput}
    Multi CPE stop dl ul traffic    ue_index=1    cpe_ue_index=${cpe_cell92_ues_index}
    [Teardown]    Case_Teardown

[1]CB014474-SR-A_8_Switching 2 MU-MIMO paired users to dynamically RAT0 as init-TX tansmission with multiple BWPs
    [Documentation]
    [Tags]
    [Setup]    Case_Setup
    ${SCF_CB014474-A}    Replace String    ${Golden_SCF_Path}    .xml    _CB014474-A_4bwps.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB014474-A}
    Muti_CPE_UEs_UL_DL_Traffic    ue_index=${1}    cpe_ue_index=${cpe_cell92_ues_index}
    Retry Check UEs Pair With Rat0    check_type=init-Tx
    Multi_UEs_Check_Tput_CAdisable    cell_ids=${nrcell_id}    ultarget_throughput=${ul_2ues_throughput}
    ...    dltarget_throughput=${dl_2ues_throughput}
    Multi CPE stop dl ul traffic    ue_index=1    cpe_ue_index=${cpe_cell92_ues_index}
    [Teardown]    Case_Teardown

[1]CB014474-SR-A_66_Switching 2 MU-MIMO paired users to dynamically RAT0 as re-TX tansmission with 4 dedicated BWPs
    [Documentation]
    [Tags]
    [Setup]    Case_Setup
    MCS_Add_Att_Value
    ${SCF_CB014474-A}    Replace String    ${Golden_SCF_Path}    .xml    _CB014474-A_4bwps.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB014474-A}
    Muti_CPE_UEs_UL_DL_Traffic    ue_index=${1}    cpe_ue_index=${cpe_cell92_ues_index}
    Retry Check UEs Pair With Rat0    check_type=re-Tx
    Multi_UEs_Check_Tput_CAdisable    cell_ids=${nrcell_id}    ultarget_throughput=${ul_2ues_throughput}
    ...    dltarget_throughput=${dl_2ues_throughput_bler}
    Multi CPE stop dl ul traffic    ue_index=1    cpe_ue_index=${cpe_cell92_ues_index}
    [Teardown]    Run Keywords    MCS_Recover_Att_Value    AND    Case_Teardown

[1]CB014474-SR-A_13_Switching 2 MU-MIMO paired users to dynamically RAT0 as init-TX and retx tansmissions IWK CB014861 with multiple BWPs
    [Documentation]
    [Tags]
    [Setup]    Case_Setup
    MCS_Add_Att_Value
    ${SCF_CB014474-A}    Replace String    ${Golden_SCF_Path}    .xml    _CB014474-A_3bwps.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB014474-A}
    Muti_CPE_UEs_Different_DL_Traffic    ue_index=${1}    cpe_ue_index=${cpe_cell92_ues_index}    dl_tp=${diff_dl_throughput}
    Retry Check UEs Pair With Rat0    check_type=both
    Multi_UEs_Check_Tput_CAdisable    cell_ids=${nrcell_id}    ultarget_throughput=${0}
    ...    dltarget_throughput=${diff_dl_2ues_throughput}
    Sleep    5min
    ${NR_5192e_wo_14861}    Get Latest NR_5192e KPI Value    nrcell_index=1
    ${NR_5114b_wo_14861}    Get Latest NR_5114b KPI Value    nrcell_index=1
    #Multi CPE stop dl ul traffic    ue_index=1    cpe_ue_index=${cpe_cell92_ues_index}
    #Multi CPE Call Teardown    ue_index=${1}    cpe_ue_index=${cpe_cell92_ues_index}
    Enable or Disable 14861   status=enable    nrcell_index=1
    #Muti_CPE_UEs_Different_DL_Traffic   ue_index=${1}    cpe_ue_index=${cpe_cell92_ues_index}    dl_tp=${diff_dl_throughput}
    Retry Check UEs Pair With Rat0    check_type=both
    Multi_UEs_Check_Tput_CAdisable    cell_ids=${nrcell_id}    ultarget_throughput=${0}
    ...    dltarget_throughput=${diff_dl_2ues_throughput}
    Sleep    5min
    ${NR_5192e_with_14861}    Get Latest NR_5192e KPI Value    nrcell_index=1
    ${NR_5114b_with_14861}    Get Latest NR_5114b KPI Value    nrcell_index=1
    Should Be True    ${NR_5192e_with_14861} <= 1.1 * ${NR_5192e_wo_14861}
    Should Be True    ${NR_5114b_with_14861} >= 0.98 * ${NR_5114b_wo_14861}
    Multi CPE stop dl ul traffic    ue_index=1    cpe_ue_index=${cpe_cell92_ues_index}
    [Teardown]    Run Keywords    MCS_Recover_Att_Value
    ...    AND    Enable or Disable 14861   status=disable    nrcell_index=1
    ...    AND    Case_Teardown

[1]CB014474-SR-A_40_Check KPI NR_5100c improved with customer configuration with good air condition
    [Documentation]
    [Tags]
    [Setup]    Case_Setup
    ${SCF_CB014474-A}    Replace String    ${Golden_SCF_Path}    .xml    _CB014474-A_3bwps.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB014474-A}
    Sleep    3min
    Muti_CPE_UEs_UL_DL_Traffic    ue_index=${1}    cpe_ue_index=${cpe_cell92_ues_index}
    Spark_MultiUE Prepare    ue_list=${spark_ue_list}
    Spark_MultiUE Attach    ue_list=${spark_ue_list}
        FOR    ${ue_index}    IN    @{spark_ue_list}
        power_ue.Start traffic    ue_type=huawei_sigspark    direction=ul    ue_index=${ue_index}
        ...    throughput=${spark_ul_tp}     protocol=udp    duration=1200    apn_address=${apn}    ue_mode=MultiUE_SA
        power_ue.Start traffic    ue_type=huawei_sigspark    direction=dl    ue_index=${ue_index}
        ...    throughput=${spark_dl_tp}     protocol=udp    duration=1200    apn_address=${apn}    ue_mode=MultiUE_SA
    END
    Sleep    10min
    ${kpi_5100c}    Get Latest NR_5100c KPI Value    nrcell_index=1
    Set Suite Variable    ${NR_5100c_VALUE_14474}    ${kpi_5100c}
    ${kpi_5114b}    Get Latest NR_5114b KPI Value    nrcell_index=1
    Set Suite Variable    ${NR_5114b_VALUE_14474}    ${kpi_5114b}
    ${kpi_5244e}    Get Latest NR_5244e KPI Value    nrcell_index=1
    Set Suite Variable    ${NR_5244e_VALUE_14474}    ${kpi_5244e}

    Enable or Disable 14474   status=disable    nrcell_index=1

    Sleep    10min
    ${kpi_5100c}    Get Latest NR_5100c KPI Value    nrcell_index=1
    Set Suite Variable    ${NR_5100c_VALUE_8927}    ${kpi_5100c}
    ${kpi_5114b}    Get Latest NR_5114b KPI Value    nrcell_index=1
    Set Suite Variable    ${NR_5114b_VALUE_8927}    ${kpi_5114b}
    ${kpi_5244e}    Get Latest NR_5244e KPI Value    nrcell_index=1
    Set Suite Variable    ${NR_5244e_VALUE_8927}    ${kpi_5244e}
    FOR    ${ue_index}    IN    @{spark_ue_list}
        power_ue.Stop traffic    ue_type=huawei_sigspark    direction=ul    ue_index=${ue_index}    apn_address=${apn}
        power_ue.Stop traffic    ue_type=huawei_sigspark    direction=dl    ue_index=${ue_index}    apn_address=${apn}
    END
    Multi CPE stop dl ul traffic    ue_index=1    cpe_ue_index=${cpe_cell92_ues_index}

    Spark_MultiUE Detach    ue_list=${spark_ue_list}
    Multi CPE Call Teardown    ue_index=${1}    cpe_ue_index=${cpe_cell92_ues_index}
    Should Be True    ${NR_5100c_VALUE_14474} >= ${NR_5100c_VALUE_8927}

    [Teardown]    Run Keywords    Enable or Disable 14474   status=enable    nrcell_index=1
    ...    AND    Case_Teardown

[1]CB014474-SR-A_41_Check KPI NR_5114b improved with customer configuration with good air condition
    [Documentation]
    [Tags]
    [Setup]    Case_Setup
    Should Be True    ${NR_5114b_VALUE_14474} >= 0.98 * ${NR_5114b_VALUE_8927}
    [Teardown]    Case_Teardown

[1]CB014474-SR-A_42_Check KPI NR_5244e improved with customer configuration with good air condition
    [Documentation]
    [Tags]
    [Setup]    Case_Setup
    Should Be True    ${NR_5244e_VALUE_14474} >= ${NR_5244e_VALUE_8927}
    [Teardown]    Case_Teardown

[1]CB014474-SR-A_3_Switching 2 MU-MIMO paired users to dynamically RAT0 as init-TX and retx tansmissions with 80MHz BW
    [Documentation]
    [Tags]
    [Setup]    Case_Setup
    MCS_Add_Att_Value
    ${SCF_CB014474-A}    Replace String    ${Golden_SCF_Path}    .xml    _CB014474-A_80M.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB014474-A}
    Muti_CPE_UEs_UL_DL_Traffic    ue_index=${1}    cpe_ue_index=${cpe_cell92_ues_index}
    Retry Check UEs Pair With Rat0    check_type=both
    Multi CPE stop dl ul traffic    ue_index=1    cpe_ue_index=${cpe_cell92_ues_index}
    [Teardown]    Run Keywords    MCS_Recover_Att_Value    AND    Case_Teardown

[1]CB014474-SR-A_46_Check different BWP dynamic Ues with full buffer load status with multiple dedicated BWPs TDD
    [Documentation]
    [Tags]
    [Setup]    Case_Setup
    ${SCF_CB014474-A}    Replace String    ${Golden_SCF_Path}    .xml    _CB014474-A_3bwps.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB014474-A}
    Single CPE DL Traffic    ue_index=${single_cpe_ue_index}
    log to console    BWP1 CPE UE start dl traffic
    MTP Attach And Start Traffic    MTP_ue_index=${MTP_ue_index}    MTP_ul_tp=${MTP_ul_tp}    MTP_dl_tp=${MTP_dl_tp}
    log to console   BWP3 MTP UE start dl traffic
    Spark_MultiUE Prepare    ue_list=${spark_ue_list}
    Spark_MultiUE Attach    ue_list=${spark_ue_list}
        FOR    ${ue_index}    IN    @{spark_ue_list}
        power_ue.Start traffic    ue_type=huawei_sigspark    direction=ul    ue_index=${ue_index}
        ...    throughput=${spark_ul_tp}     protocol=udp    duration=1200    apn_address=${apn}    ue_mode=MultiUE_SA
        power_ue.Start traffic    ue_type=huawei_sigspark    direction=dl    ue_index=${ue_index}
        ...    throughput=${spark_dl_tp}     protocol=udp    duration=1200    apn_address=${apn}    ue_mode=MultiUE_SA
    END
    log to console    BWP1 Spark legacy UE start dl traffic
    Retry Check BWP1 BWP3 UE Switched To Rat0    check_type=init-Tx
    FOR    ${ue_index}    IN    @{spark_ue_list}
        power_ue.Stop traffic    ue_type=huawei_sigspark    direction=ul    ue_index=${ue_index}    apn_address=${apn}
        power_ue.Stop traffic    ue_type=huawei_sigspark    direction=dl    ue_index=${ue_index}    apn_address=${apn}
    END
    CPE stop dl traffic    ue_index=${single_cpe_ue_index}
    MTP Detach   MTP_ue_index=${MTP_ue_index}
    [Teardown]    Case_Teardown
