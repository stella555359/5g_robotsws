*** Settings ***
Documentation
...   contact: julia.luszcz@nokia.com
...   author: Agnieszka Bylica, Julia Luszcz

Library     taf.rfrl.utilities.test_config.DefaultFileLocation                        WITH NAME  def_file_location
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/SISO/setups_teardowns/SuiteSetupTeardown.robot
Resource    taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_KPI_PM_Counters_benchmarking.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    resources/benchmarking_keywords.robot

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/benchmarking_variables.py


Suite Setup       Run Keywords    Prepare Test Line    prefix_tag=${prefix_tag}
...                                                    scf_name=${scf_name}
...                                                    increase_timeout_for_update_sw=${1800}
...                                                    increase_time_for_checking_radios=${1800}
...                               AND
...                               SuiteSetupTeardown.Common Suite Setup    commission=${load_scf}
...                                        lmi_interface=${False}      lte_snapshot=${False}
...                                        stop_and_fix_gnb=${False}    stop_and_fix_enb=${False}
...                                        swconfig_upload=${swconfig_upload}
...                                        custom_swconfig_path_gnb=${5g_swconfig_path}
...                                        custom_scf_file_path_5g=${base_5g_scf}
...                                        additional_gnb_allowed_alarms=@{additional_gnb_allowed_alarms}

Suite Teardown      SuiteSetupTeardown.Common Suite Teardown

Test Setup          TestSetupTeardown.Common Test Setup       ues=${tl.ues}
Test Teardown       TestSetupTeardown.Common Test Teardown    report_tl_configuration=${False}    stop_and_fix_gnb=${False}
...                                         stop_and_fix_enb=${False}         lte_snapshot=${False}

*** Variables ***
${swconfig_upload}         ${False}
${load_scf}                ${True}
${generate_start_point}    ${False}
${prefix_tag}              benchmarking_DSS
@{additional_gnb_allowed_alarms}    6134
${5g_swconfig_path}        /home/ute/MN/UTE/robotws/commissionings/Krakow/swconfig/default_swconfig.txt
${scf_name}                benchmarking_DSS_GNB0_SCF.xml


*** Test Cases ***
[1][1.0] General_SiSo_KPI_PM_Counters_benchmarking
    [Timeout]                 24h
    General_SiSo_KPI_PM_Counters_benchmarking
    ...                       cell_id=29
    ...                       cell_type=nr
    ...                       scout_tl_name=7_7_T01PY029_1
    ...                       scout_template_id=984
    ...                       scf_file_path=${base_5g_scf}
    ...                       throughput=${throughput_KPI_benchmarking_AREC}
    ...                       start_point_generation=${generate_start_point}
    ...                       custom_base_scf_path=${base_5g_scf}
    ...                       alpha=0.001
    ...                       protocol=udp
    ...                       udp_buffer=4M
    ...                       tc_name=General_SiSo_KPI_PM_Counters_benchmarking_DSS