*** Settings ***
Documentation
...   author: Adrianna Pienkowska, Jacek Kozmic, Agata Sidlo
...   contact: adrianna.pienkowska@nokia.com, jacek.kozmic@nokia.com, agata.sidlo@nokia.com
...   description: Krakow Verification Engineering team testcases for CB008746 feature

Resource    resources/common.robot
Resource    ../resources/common_configuration.robot

Variables   resources/variables.py
Variables   resources/delta_setups.py
Variables   resources/validation_dicts.py

Suite Setup      Suite Setup 8746
Test Teardown    Run Keywords    Send Configuration ID To Scout
    ...    AND    Test Teardown 8746

*** Test Cases ***
CB008746-A_B301_Quotas_online_modification_NSA_SA_TDD
    [Setup]    Test Setup 8746
    ...    tc=A_B301_NSA_SA_MODY_TDD
    ...    test_cell_tech=TDD
    counters__.Create Counter List
    ...    ${DL_PRB_COUNTERS}
    c_p.Prepare Resource Group Parameters Variable
    ...    ${DELTA_DYN_KEYS_A_B301_003_1_VALIDATION}
    common.Activate Feature And Start Basic Logs
    ...    delta=${DELTA_A_B301_003_TDD}
    ...    delta_setup=${DELTA_DYN_KEYS_A_B301_003_TDD}
    ...    wts=${WTS_8_NSA_UEs_6_SA_UEs_ACT_TDD}
    common.Attach Multiple Ues To Plmns And Start Traffic
    ...    nr_ues=3
    ...    spid=${UE_SPID_VALUES_A_B301_003}
    ...    plmn=${THREE_UES_PLMNS}
    ...    dl_mbps=${TPUT_301_003_NSA}
    ...    cell_id=${CELL_1_ID}
    attach__.Attach Many Sa Ues To Different Slices And Run Traffic
    ...    ues_id=${SA_4UE_IDS}
    ...    tput=${TPUT_301_003_SA}
    ...    ues_ip=${UE_IP_4_SA_A_B301}
    ...    cell=${CELL_1_ID}
    ...    slices=${SA_SLICES_1_2_3_4}
    common__.Wait For Counters To Update
    counters__.Collect Counters Values
    ${COUNTERS_PATH}    get_latest_file_with_counters
    ts_v.target_share_validation
    ...    quotas=${DELTA_DYN_KEYS_A_B301_003_TDD}
    ...    tputs=${TPUTS_7RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_7RG_TDD}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_7RG_TDD}
    ...    margin=${UTILIZATION_MARGIN}
    c_p.Prepare Resource Group Parameters Variable
    ...    ${DELTA_DYN_KEYS_A_B301_003_2_VALIDATION}
    common.Perform Delta Recomissioning
    ...    delta=${DELTA_A_B301_CHANGE_QUOTAS}
    ...    delta_setup=${DELTA_DYN_KEYS_A_B301_003_CHANGE_QUOTAS}
    common__.Wait For Counters To Update
    counters__.Collect Counters Values
    ${COUNTERS_PATH}    get_latest_file_with_counters
    ts_v.target_share_validation
    ...    quotas=${DELTA_DYN_KEYS_A_B301_003_CHANGE_QUOTAS}
    ...    tputs=${TPUTS_7RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_7RG_TDD}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_7RG_TDD}
    ...    margin=${UTILIZATION_MARGIN}
    wts__.Stop Data Traffic For Multiple Ues
    ...    number_of_ues=3
    ...    traffic_direction=dl
    ...    first_ue_id=11
    ...    net_arch=nsa
    ...    bearer=2
    wts__.Stop Data Traffic For Multiple Ues
    ...    number_of_ues=4
    ...    traffic_direction=dl
    common.LOG SYSLOG BIP Stop
    suite__.Set Tc Status To Passed
    ...    tc=A_B301_NSA_SA_MODY_TDD
