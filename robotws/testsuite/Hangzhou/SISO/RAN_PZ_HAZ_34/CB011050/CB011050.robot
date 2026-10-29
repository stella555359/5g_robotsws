*** Settings ***
Suite Setup    Run keywords    SISO Coam Suite Setup    AND    Commission SCF Accorfing Feature Id    feature_id=11050    AND
...    Get lnbtsID via SCF    AND    Get scf name
Suite Teardown    SISO Coam Suite Teardown
Test Setup    SISO Coam Test Setup
Test Teardown    SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     Resources/CB011050_common_keyword.robot
Variables    TestData/11050_variables.py

Documentation
...    Author:linjiangjing
...    contact:jiangjing.lin@nokia-sbell.com
...    squad group:SG_08
...    Feature CB011050

Force Tags    SBTS00
...   PY36

*** Test Cases ***
[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    General_DATA_transfer_SG08_Config    mrbtsId=${mrbtsID}    nrbtsId=${nrbtsID}    lnBtsId=${lnBtsId}
    ...    tput_define_nr=${tput_nr}    tput_define_lte=${tput_lte}    pa_call_default=${0}    scf_name=${scf_name_11050}    process_num_ul=${5}
    ...    target_avg_percent_nr=${0.98}    min_percent_nr=${0.85}    target_avg_percent_lte=${0.98}    min_percent_lte=${0.85}    duration=${300}

[1][4.0] Manual_SiSo_SM_NR_RAT_reset
    General_RAT_RESET_SG08_Config    mrbtsId=${mrbtsID}    nrbtsId=${nrbtsID}    lnBtsId=${lnBtsId}
    ...    tput_define_nr=${tput_nr}    tput_define_lte=${tput_lte}    pa_call_default=${0}    scf_name=${scf_name_11050}    process_num_ul=${5}
    ...    target_avg_percent_nr=${0.8}    min_percent_nr=${0.5}    target_avg_percent_lte=${0.8}    min_percent_lte=${0.5}    duration=${60}

[1][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    General_SISO_RU_Lock_Unlock_SG08_Config    mrbtsId=${mrbtsID}    nrbtsId=${nrbtsID}    lnBtsId=${lnBtsId}
    ...    tput_define_nr=${tput_nr}    tput_define_lte=${tput_lte}    pa_call_default=${0}    scf_name=${scf_name_11050}    process_num_ul=${5}
    ...    target_avg_percent_nr=${0.8}    min_percent_nr=${0.5}    target_avg_percent_lte=${0.8}    min_percent_lte=${0.5}    duration=${60}

[1][3.0] General_SiSo_Cell_block_and_unblock
    General_SISO_Cell_Block_Unblock_SG08_Config    mrbtsId=${mrbtsID}    nrbtsId=${nrbtsID}    lnBtsId=${lnBtsId}
    ...    tput_define_nr=${tput_nr}    tput_define_lte=${tput_lte}    pa_call_default=${0}    scf_name=${scf_name_11050}    process_num_ul=${5}
    ...    target_avg_percent_nr=${0.8}    min_percent_nr=${0.5}    target_avg_percent_lte=${0.8}    min_percent_lte=${0.5}    duration=${60}
