*** Settings ***
Documentation
...    author: Jiang Hongyu
...    contact: hongyu.jiang@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB009142

Resource    ./Resources/CB010600_common_keyword.robot
Library     ./Resources/CB010600_common_keyword.py
Variables   ./Resources/TLConfigration_10600.py


Suite Setup       CB010776 Suite Setup
Suite Teardown    CB010776 Suite Teardown


*** Test Cases ***
[1]CB010776_F_01_UL_UP_Dynamic_Fragmentation_Activation_loki_based
    [Tags]  CRT_TRUNK
    [Setup]  robot_common_operations.Common Case Setup    gnb_index=${1}    allowed_faults_ids=8000,7311
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    Check flag in swconfig    para=0x600012=0    bts_host=${gNB_ip1}
    Check ENDPOINT Parameter Value    Romd_list=${Romd_list2}    trans=RX    exp_value=${True}    bts_host=${gNB_ip1}
    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${False}    ul_bler=${1}    dl_bler=${1}    ul_tp=${10}
    ...    dl_tp=${50}    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}
    Modify swconfig And Reset BTS    para=0x600012=0    bts_host=${gNB_ip1}
    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${False}    ul_bler=${1}    dl_bler=${1}    ul_tp=${10}
    ...    dl_tp=${50}    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}
    [Teardown]    CB010600 Case Teardown    bts_host=${gNB_ip1}

[1]CB010776_F_03_UL_UP_Dynamic_Fragmentation_Activation_loki_based_with_actLongPucchPhase2_False
    [Tags]  CRT_TRUNK
    [Setup]  robot_common_operations.Common Case Setup    allowed_faults_ids=8000,7311
    Check flag in swconfig    para=0x600012=0    bts_host=${gNB_ip1}
    Modify Common parameter via Coam    input_list=${gnb_para5}    bts_host=${gNB_ip1}
    Check ENDPOINT Parameter Value    Romd_list=${Romd_list2}    trans=RX    exp_value=${True}    bts_host=${gNB_ip1}
    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${False}    ul_bler=${1}    dl_bler=${1}    ul_tp=${10}
    ...    dl_tp=${50}    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}
    [Teardown]  Case Teardown    input_list=${gnb_para6}    cell_id=None    block_flag=${False}    if_cell_opt=${False}    bts_host=${gNB_ip1}

[1]CB010776_F_11_DL_UL_UP_Dynamic_Fragmentation_Activation_loki_based
    [Tags]  CRT_TRUNK
    [Setup]  robot_common_operations.Common Case Setup    gnb_index=${1}    allowed_faults_ids=8000,7311
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    Check flag in swconfig    para=0x600012=0    bts_host=${gNB_ip1}
    Check ENDPOINT Parameter Value    Romd_list=${Romd_list2}    trans=RX    exp_value=${True}    bts_host=${gNB_ip1}
    Check ENDPOINT Parameter Value    Romd_list=${Romd_list2}    trans=TX    exp_value=${True}    bts_host=${gNB_ip1}
    ${ue_config}    Change_UL_And_DL_TP    ue_config=${TLCommonConfig}    ul_tp=10    dl_tp=100
#    ${last_period_time}    Get PM Counters Latest period time    NRCELL_id=NRCELL-2
    ${last_period_time}    Create Dictionary    start_time=now
    log to console    sleep 6 min to wait counter show in webem
    sleep    6min
    ${spark_result1}    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${True}    ul_bler=${1}    dl_bler=${1}
    ...    ul_tp=${10}    dl_tp=${100}    multiue_config_direction=${ue_config["MultiUECFG"]}
    log to console    sleep 6min wait for counters generating.
    sleep    6min
    ${c_dl_counters_dict}    Get All Counter from DU    before_counter_time=${last_period_time}    counter_id_dict=${C_DL_Counters}
    ${dl_legacy_check}    compare_percc_counter_with_legacy    web_counter_dict=${c_dl_counters_dict}    dlul=dl
    Run Keyword And Continue On Failure    Should be True    ${dl_legacy_check}    msg=CB010636_C_DL Counters mismatch with legacy
    ${c_ul_counters_dict}    Get All Counter from DU    before_counter_time=${last_period_time}    counter_id_dict=${C_UL_Counters}
    ${ul_legacy_check}    compare_percc_counter_with_legacy    web_counter_dict=${c_ul_counters_dict}    dlul=ul
    Run Keyword And Continue On Failure    Should be True    ${ul_legacy_check}    msg=CB010636_C_UL Counters mismatch with legacy
#    Modify swconfig And Reset BTS    para=0x600012=0    bts_host=${gNB_ip1}
#    ${spark_result2}    Start Traffic And Check TP    UL_Enable=${True}    DL_Enable=${True}    ul_bler=${1}    dl_bler=${1}
#    ...    ul_tp=${10}    dl_tp=${100}    multiue_config_direction=${ue_config["MultiUECFG"]}
    [Teardown]    CB010600 Case Teardown    bts_host=${gNB_ip1}






