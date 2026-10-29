*** Settings ***
Documentation
...   author: Tong Chen
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

Library     String
Library     taf.pdu
Library     Collections
Library     OperatingSystem
Library     spark_license.py
Library     enable_ssh_to_ru.py
Library     taf.collectors.core   WITH NAME   core
Library     taf.collectors.btslog  WITH NAME   btslog
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
#Resource    taf/rfrl/common_resources/robot/coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ru_soap_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library     taf.analyzer.pcap    WITH NAME   cap
Library     taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ALD_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/gnb_logs_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/csv_log_analysis.py    WITH NAME    handle_csv_pandas

*** Variables ***
${testline_name}      null
${CONFIGURATION}      null
${SCFNAME}      null
${if_pdl_check}       True
${if_update_swconfig}      False

#bts id
${MRBTS_ID}           ${tl.gnbs[0].instance_id}
${NRBTS_ID}           ${tl.gnbs[0].global_bts_id}



