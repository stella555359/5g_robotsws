*** Settings ***
Documentation
...   This is for logs keywords
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Library     ./lib/string_list.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/common_event_trace_log_analysis.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Resource    ../../../../resources/Macro/bts/common/gnb_cu.robot
#Resource    ../../../../resources/Macro/bts/common/gnb_bbu.robot
Resource    ./common_setup_teardown.robot
Resource    ./logs.robot
Resource    ./pm_counter.robot
Resource    ./mmw_coam_gnb_cloud.robot
Resource    ./0_Deprecated/gnb_board_type.robot
Resource    ./l3call.robot
Resource    ./throughput_checking_via_iperf.robot
Resource    ./data_process.robot
Resource    ./SISO_Pre.robot
Resource    ./common_other.robot
Library     ./lib/scf_process.py
Library     scf_process.SCFProcess    WITH NAME    scfpro
Library     ./lib/analyze_pdml.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common_New/Check_CA_via_tcpdump_log.robot
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Variables/bwp_id_mapping.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/online_nidd_process.py    WITH NAME    nidd_modify
