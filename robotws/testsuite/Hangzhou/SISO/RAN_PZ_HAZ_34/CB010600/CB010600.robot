*** Settings ***
Documentation
...    author: Jiang Hongyu
...    contact: hongyu.jiang@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB009142

Resource    ./Resources/CB010600_common_keyword.robot
Library     ./Resources/CB010600_common_keyword.py
Variables   ./Resources/TLConfigration_10600.py


Suite Setup       CB010600 Suite Setup
Suite Teardown    CB010600 Suite Teardown


*** Test Cases ***
[1]CB010600_01_UL_UP_Dynamic_Fragmentation_Activation_loki_based
    [Tags]  CRT_TRUNK
    [Setup]  robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Check flag in swconfig    para=0x600012=0
    Block Cell And Check Status    cell_id=1    block_flag=${True}
    Check ENDPOINT Parameter Value    Romd_list=${Romd_list}    trans=RX    exp_value=${True}
    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${False}    ul_bler=${1}    dl_bler=${1}    ul_tp=${10}
    ...    dl_tp=${50}    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}
    Modify swconfig And Reset BTS    para=0x600012=0
    Block Cell And Check Status    cell_id=1    block_flag=${True}
    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${False}    ul_bler=${1}    dl_bler=${1}    ul_tp=${10}
    ...    dl_tp=${50}    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}
    [Teardown]    Run keywords    Modify swconfig And Reset BTS    para=#0x600012=0
    ...    AND    robot_common_operations.Common Case Teardown

[1]CB010600_02_UL_UP_Dynamic_Fragmentation_Activation_non_loki_based
    [Tags]  CRT_TRUNK
    [Setup]  robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Check flag in swconfig    para=0x600012=0
    Block Cell And Check Status    cell_id=3    block_flag=${True}
    Check ENDPOINT Parameter Value    Romd_list=${Romd_list2}    trans=RX    exp_value=${False}
    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${False}    ul_bler=${1}    dl_bler=${1}    ul_tp=${10}
    ...    dl_tp=${50}    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}
    [Teardown]  Run keywords    Block Cell And Check Status    cell_id=3    block_flag=${False}
    ...    AND    robot_common_operations.Common Case Teardown


[1]CB010600_03_UL_UP_Dynamic_Fragmentation_Activation_loki_based_with_actLongPucchPhase2_False
    [Tags]  CRT_TRUNK
    [Setup]  robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Check flag in swconfig    para=0x600012=0
    Block Cell And Check Status    cell_id=1    block_flag=${True}
    Modify Common parameter via Coam    input_list=${gnb_para1}
    Check ENDPOINT Parameter Value    Romd_list=${Romd_list}    trans=RX    exp_value=${True}
    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${False}    ul_bler=${1}    dl_bler=${1}    ul_tp=${10}
    ...    dl_tp=${50}    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}
    [Teardown]  Case Teardown    input_list=${gnb_para2}    cell_id=1    block_flag=${False}

[1]CB010600_05_DL_UP_Dynamic_Fragmentation_Activation_loki_based
    [Tags]  CRT_TRUNK
    [Setup]  robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    Check flag in swconfig    para=0x600012=0
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Block Cell And Check Status    cell_id=1    block_flag=${True}
    Check ENDPOINT Parameter Value    Romd_list=${Romd_list}    trans=TX    exp_value=${True}
    Start Traffic And Check TP    UL_Enable=${False}    DL_Enable=${True}    ul_bler=${1}    dl_bler=${1}    ul_tp=${10}
    ...    dl_tp=${50}    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}
    Modify swconfig And Reset BTS    para=0x600012=0
    Block Cell And Check Status    cell_id=1    block_flag=${True}
    Start Traffic And Check TP    UL_Enable=${False}    DL_Enable=${True}    ul_bler=${1}    dl_bler=${1}    ul_tp=${10}
    ...    dl_tp=${50}    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}
    [Teardown]    CB010600 Case Teardown


[1]CB010600_08_UL_UP_Dynamic_Fragmentation_Activation_loki_based_with_short_PUCCH
    [Tags]  CRT_TRUNK
    [Setup]  robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Check flag in swconfig    para=0x600012=0
    ${short_pucch_para}    set variable if    '${version_scf}' == 'SBTS00'    ${gnb_para3}    ${gnb_para7}
    ${long_pucch_para}    set variable if    '${version_scf}' == 'SBTS00'    ${gnb_para4}    ${gnb_para8}
    Modify Parameters with json    input_list=${short_pucch_para}
    Block Cell And Check Status    cell_id=1    block_flag=${True}
    Check ENDPOINT Parameter Value    Romd_list=${Romd_list}    trans=RX    exp_value=${False}
    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${False}    ul_bler=${1}    dl_bler=${1}    ul_tp=${10}
    ...    dl_tp=${50}    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}
    [Teardown]  Run keywords    Modify Parameters with json    input_list=${long_pucch_para}
    ...    AND    robot_common_operations.Common Case Teardown

[1]CB010600_11_DL_UL_UP_Dynamic_Fragmentation_Activation_loki_based
    [Tags]  CRT_TRUNK
    [Setup]  robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Check flag in swconfig    para=0x600012=0
    Block Cell And Check Status    cell_id=4    block_flag=${True}
    Check ENDPOINT Parameter Value    Romd_list=${Romd_list}    trans=RX    exp_value=${True}
    Check ENDPOINT Parameter Value    Romd_list=${Romd_list}    trans=TX    exp_value=${True}
    ${ue_config}    Change_UL_And_DL_TP    ue_config=${TLCommonConfig}    ul_tp=30    dl_tp=200
    ${spark_result1}    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${True}    ul_bler=${1}    dl_bler=${1}
    ...    ul_tp=${0}    dl_tp=${0}    multiue_config_direction=${ue_config["MultiUECFG"]}
    ${result1}    ${total_ul_tp1}    ${total_dl_tp1}    Total_TP_From_Spark_Log    spark_list=${spark_result1}    exp_ul=${160}    exp_dl=${1400}
    run keyword and continue on failure    should be equal    ${result1}    ${True}
    Modify swconfig And Reset BTS    para=0x600012=0
    Block Cell And Check Status    cell_id=4    block_flag=${True}
    ${spark_result2}    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${True}    ul_bler=${1}    dl_bler=${1}
    ...    ul_tp=${0}    dl_tp=${0}    multiue_config_direction=${ue_config["MultiUECFG"]}
    ${result2}    ${total_ul_tp2}    ${total_dl_tp2}    Total_TP_From_Spark_Log    spark_list=${spark_result2}    exp_ul=${160}    exp_dl=${1400}
    run keyword and continue on failure    should be equal    ${result2}    ${True}
    ${result3}    Comparison_of_Front_and_Rear_Traffic    Front_ul_value=${total_ul_tp1}    Front_dl_value=${total_dl_tp1}
    ...    Rear_ul_value=${total_ul_tp2}    Rear_dl_value=${total_dl_tp2}    proportion=${0.05}
    run keyword and continue on failure    should be equal    ${result3}    ${True}
    [Teardown]  Run keywords    Modify swconfig And Reset BTS    para=#0x600012=0
    ...    AND    robot_common_operations.Common Case Teardown

[1]CB010600_15_BTS_snapshot_collection_and_sleeping_cell_check
    [Tags]  CRT_TRUNK
    [Setup]  robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Check flag in swconfig    para=0x600012=0
    ${expect_item_status_dic}    Block Cell And Check Status    cell_id=4    block_flag=${True}
    ${ue_config}    Change_UL_And_DL_TP    ue_config=${TLCommonConfig}    ul_tp=30    dl_tp=200
    Prepare MultiUE And Attach    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}    restart_ue=${True}    restart_network=${True}
    FOR  ${item}  IN RANGE    ${20}
        ${spark_result}    ${attach_status}    Start Traffic And Capture Snapshot   expect_item_status_dic=${expect_item_status_dic}
        ...    multiue_config_direction=${ue_config["MultiUECFG"]}
        Exit For Loop If    ${attach_status} == ${False}
    END
    [Teardown]  Run keywords    Block Cell And Check Status    cell_id=4    block_flag=${False}
    ...    AND    robot_common_operations.Common Case Teardown

[1]CB010600_16_UL_UP_Dynamic_Fragmentation_Activation_loki_based_with_lteToNrFrameShift_3ms
    [Tags]  CRT_TRUNK
    [Setup]  robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Check flag in swconfig    para=0x600012=0
#    Run keyword and ignore error    Change MultiUE Model To SA or NSA    if_SA=${False}
    Modify Parameters with json    input_list=${gnb_para9}
    Check GNB on air
    ${ue_config}    Change_UL_And_DL_TP    ue_config=${TLCommonConfig}    ul_tp=5    dl_tp=200
    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${False}    ul_bler=${1}    dl_bler=${1}
    ...    ul_tp=${5}    dl_tp=${0}    multiue_config_direction=${ue_config["MultiUECFG"]}
    [Teardown]  robot_common_operations.Common Case Teardown






