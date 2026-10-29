*** Settings ***
Documentation
...   Test suite for regression testing of feature CB011179
...   author:  Marcin Bereznicki
...   contact: marcin.bereznicki@nokia.com

Library         taf.rfrl.common_resources.ee_kpi.interface
Library         ./resources/resources.py
Resource        taf/rfrl/procedures/SISO/test_models/5g/Downlink/General_SiSo_Auto_DL_Test_Model_Activation.robot
Resource        taf/rfrl/procedures/resources/robot/TestModels/Common.robot
Resource        testsuite/Krakow/resources/pm_counters/pm_counters_keywords.robot
Resource        ./resources/resources.robot
Variables       testsuite/Krakow/SISO/regression/RAN_PZ_KRK1/CB011179/resources/variables.py

Suite Setup     Common Suite Setup With OnAir Test Line Preparation
...             prefix_tag=CB011179
...             swconfig_from_path=testsuite/Krakow/SISO/regression/RAN_PZ_KRK1/CB011179/resources/swconfig_rnd.txt
...             increase_timeout_for_update_sw=${1800}
Suite Teardown  Common Suite Teardown

Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Test Model Postcondition

*** Variables ***
${BTS_ADMIN_ALIAS}          REST_GNB0_DU0
${INTERVAL}                 15min
${test_model_duration}      4500

*** Test Cases ***
[1]CB011179_A_NR_TDD_FR1_Slot-wise_varying_Test_Model-load_70_percent
    Set Test Variable                                   ${logs_path}    ${LOG_PATH}
    Set Admin Connection
    Enter Test Dedicated State
    Validate Defined Counters Interval                  interval=${INTERVAL}
    ...                                                 counters=${counters_to_verify}

    ${counters_before}      Get EE Counters             connection=${BTS_ADMIN_ALIAS}
    ${detailed_bts_info}    Get Detailed BTS info       connection=${BTS_ADMIN_ALIAS}
    ${cell_id}              Evaluate    "${test_model_params_load70[0]['dist_name']}".split('-')[1]

    General SiSo Auto DL Test Model Activation          test_model=${test_model_params_load70[0]['test_model']}
    ...                                                 cell_id=${cell_id}
    ...                                                 pmax=${test_model_params_load70[0]['p_max']}
    ...                                                 type_of_load=${test_model_params_load70[0]['load_type']}
    ...                                                 level_of_load_slot_wise=${test_model_params_load70[0]['load_level']}
    ...                                                 result_collection_time=${test_model_duration}


    ...                                                 spec_ssb_beam_pattern=1,2,3,4
    Verify Counters Values Increased                    interval=${INTERVAL}
    ...                                                 counters=${counters_to_verify}

    ${counters_after}    Get EE Counters                connection=${BTS_ADMIN_ALIAS}

    Run Keyword And Ignore Error    Report EE KPI       ee_counters_before=${counters_before}
    ...                                                 ee_counters_after=${counters_after}
    ...                                                 test_model_params=${test_model_params_load70}
    ...                                                 detailed_bts_info=${detailed_bts_info}

[1]CB011179_E_Slot-wise_NR_Test_Model-Idle_active_AWPNB
    Set Test Variable                                   ${logs_path}    ${LOG_PATH}
    Set Admin Connection
    Enter Test Dedicated State
    Validate Defined Counters Interval                  interval=${INTERVAL}
    ...                                                 counters=${counters_to_verify}

    ${cell_id}              Evaluate    "${test_model_params_idle[0]['dist_name']}".split('-')[1]

    General SiSo Auto DL Test Model Activation          test_model=${test_model_params_idle[0]['test_model']}
    ...                                                 cell_id=${cell_id}
    ...                                                 pmax=${test_model_params_idle[0]['p_max']}

    Verify Counters Values Increased                    interval=${INTERVAL}
    ...                                                 counters=${counters_to_verify}
    ...                                                 wait_for_next_pm_period=${True}
