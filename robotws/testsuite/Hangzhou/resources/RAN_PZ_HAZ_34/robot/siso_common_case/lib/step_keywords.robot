*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: geyou fan
...              Contact: geyou.fan@nokia-sbell.com
...                       zhihao.shi@nokia-sbell.com
...                       tingting.zhong@nokia-sbell.com
...                       lanwen.cai@nokia-sbell.com
...              Squard: HZ SG4   HZ SG8

Library    XML   WITH NAME    ParseXML
Library    String
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.snapshot      WITH NAME    snapshot
Library    taf.config.scf    WITH NAME    scf
Library    ../../../python/parse_soap.py
Library    ./get_group_id.py
Library    ./dynamic_pdcch.py
Library    ./frame_structure_and_throughput.py
Library    ./obtain_information.py
Library    ./get_case_variables.py
Library    ./analyse_snapshot.py
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_parameter  WITH NAME  coam_parameter
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.bts.common.admin_operation
Resource   ../../coam_siso_common.robot
Resource   ../../coam_gnb_classical.robot
Resource   ../../ru_soap_log.robot
Resource   ../../power_ue/power_ue.robot
Resource   ../../Throughput_checking_from_GNB.robot
Resource   ../../gnb_classical_hangzhou.robot
Resource   ../../BIP_trace/BIP_trace_collector.robot
Resource   ../../BW_common_case/lib/BW_step_keywords.robot
Resource   ../step_keywords/5G/recommissioning_and_make_throughput.robot
Resource   ../step_keywords/5G/nrarfcn_and_gscn.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_csn.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/rf_diagnostic_test.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/soap.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/btsom_log.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot

*** Keywords ***

