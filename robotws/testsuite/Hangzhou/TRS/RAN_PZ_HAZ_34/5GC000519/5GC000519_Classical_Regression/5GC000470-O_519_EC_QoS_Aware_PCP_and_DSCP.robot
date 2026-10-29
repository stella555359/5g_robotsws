# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    author: cris cai
# ...    contact:cris.cai@nokia-sbell.com
# ...    squad group: SG_03
# ...    feature : 5GC000470-O,5GC000519
# 
# 
# 
# Suite Setup       Common Suite Setup for COAM 519
# Suite Teardown    Suite Recover
# 
# Resource    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/5GC000519/Resources/collect_log.robot
# Library    taf.stc.config    WITH NAME    stc
# Resource    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/5GC000519/Resources/5GC000519_coam_common_keywords.robot
# Resource    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/5GC000519/Resources/5GC000519_CC_common_keywords.robot
# Library    taf.analyzer.pcap    WITH NAME    cap
# Library    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/5GC000519/Resources/tshark_parser.py
# Library    tshark_parser.Parser     WITH NAME    tsk
# Library    taf.analyzer.pcap
# Variables     testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/5GC000519/Resources/Stream_parameter_519.py
# 
# *** Variables ***
# #${tl_scf_dir_path}    /home/ute/SQ3project/regression/SCF/470_519/
# ${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
# ${test_path}         /opt/workspace/CRT/Master/SCF_file/
# #${test_path}    /home/ute/SQ3project/
# ${tl_scf_filename_dscp_vlantag_trunk}    Full_Configuration_scf_TL349_dscp.xml
# ${tl_scf_filename_pcp_vlantag_trunk}    Full_Configuration_scf_TL349_pcp_vlantag.xml
# ${tl_scf_filename_multi_vlan_trunk}     Full_Configuration_scf_TL349_multi_vlan.xml
# ${tl_scf_filename_multi_vlan_20B}       Full_Configuration_scf_TL359_multi_vlan.xml
# ${tl_scf_filename_dscp_vlantag_20B}    Full_Configuration_scf_TL359_dscp.xml
# ${tl_scf_filename_pcp_vlantag_20B}     Full_Configuration_SCF_1881_886_7657.xml
# ${testcase_status}    false
# ${testcenter_pcp_vlantag_file_trunk}    /home/ute/SQ3project/regression/519STC/470_519_E01.tcl
# ${testcenter_dscp_tag_and_untag_file_trunk}    /home/ute/SQ3project/regression/519STC/470_519_E07.tcl
# ${testcenter_pcp_vlantag_file_20B}       /opt/workspace/SCF/470_519/STC/PCP0_3_519E001.tcl
# ${testcenter_dscp_tag_and_untag_file_20B}     /opt/workspace/SCF/470_519/STC/DSCP43_56_519E007.tcl
# ${enblog_E07}    519_E_07.pcap
# ${enblog_E01}    519_E_01.pcap
# ${enb_path}    /user/toor4nsn/
# ${gnb_path}    /tmp/
# ${gnblog_E07}    519_E_07_port15.pcap
# ${gnblog_E01}    519_E_01_port15.pcap
# ${plain_ip}    ${ENB_ADDRESS}
# ${gNB_dist}    MRBTS-${tl.gnbs[0].instance_id}/TNLSVC-1/TNL-1/ETHSVC-1
# ${not priority ip_E01_trunk}    192.168.115.100,192.168.115.120
# ${priority ip_E01_trunk}      192.168.125.100,192.168.125.120
# ${not priority ip_E07_trunk}    192.168.115.100,192.168.115.120
# ${priority ip_E07_trunk}      192.168.125.100,192.168.125.120
# ${vlan100_ip}     192.168.115.100
# ${vlan1000_ip}    192.168.145.100
# ${vlan1500_ip}    192.168.125.100
# ${vlan2000_ip}    192.168.135.100
# ${vlan2500_ip}    192.168.155.100
# ${vlan100_id}     100
# ${vlan1000_id}    1000
# ${vlan1500_id}    1500
# ${vlan2000_id}    2000
# ${vlan2500_id}    2500
# ${not priority ip_E01_20B}    192.168.117.100,192.168.117.120
# ${priority ip_E01_20B}      192.168.127.100,192.168.127.120
# ${not priority ip_E07_20B}    192.168.117.100,192.168.117.120
# ${priority ip_E07_20B}      192.168.127.100,192.168.127.120
# ${vlan107_ip}     192.168.117.100
# ${vlan1007_ip}    192.168.147.100
# ${vlan1507_ip}    192.168.127.100
# ${vlan2007_ip}    192.168.137.100
# ${vlan2507_ip}    192.168.157.100
# ${vlan107_id}     107
# ${vlan1007_id}    1007
# ${vlan1507_id}    1507
# ${vlan2007_id}    2007
# ${vlan2507_id}    2507
# 
# 
# *** Test Cases ***
# [1][1.1]5GC000519_E_001_QoS_Aware_primary_classification_criteria_Vlan_PCP_for_VLAN_tagged_frame_in_vlan_aware_or_unaware
#     [Documentation]
#     ...    This case is used to verifyied the pcp classification for vlan tagged frames in vlan aware or unaware
#     [Tags]     classical    CRT_TRUNK    CRT_20B    CIT_22R2
#     [Setup]    Case variable set for 519_E001
#     Perform full commission for COAM gnb with scf file    scf_file=${tl_scf_dir_path}${${scf_file}}
#     Check gnb COAM classical start normally
#     wait until keyword succeeds    5X    10s    Tests send PCP vlan tag and analysis the enb logs
#     Backup wireshark Files     connection=TestPC    wireshark_log_path=${test_path}
#     [Teardown]    Run Keyword And Ignore Error    Tests Recover for 001
# 
# *** Keywords ***
# Tests Recover
#     run keyword and ignore error    csn.disconnect    connection=ENB
#     active Qos awareness tag    dist_name=${gNB_dist_l2sw}
#     active chaining feature tag
#     killall firefox progress
#     sleep    10s
# 
# Send DSCP vlan tag traffic from testcenter to enb
#     Send traffic from testcenter     connection=TestPC    testcenter_tclfile=${${testcenter_dscp}}
# 
# Send PCP vlan tag traffic from testcenter to enb
#     Send traffic from testcenter     connection=TestPC    testcenter_tclfile=${${testcenter_pcp}}
# 
# Analysis enblog E07
#     [Arguments]    ${Log_name}
#     tsk.read_cap    cap_file=${epc_log_path}${Log_name}
#     ${result}=    tsk.get_latest50_packages_startwith_192_168    field_expression=ip.src
#     Should not contain    container=${result}   item=${${not priority ip_E07}}
#     Should contain    container=${result}     item=${${priority ip_E07}}
# 
# Analysis enblog E01
#     [Arguments]    ${Log_name}
#     tsk.read_cap    cap_file=${epc_log_path}${Log_name}
#     ${result}=    tsk.get_latest50_packages_startwith_192_168     field_expression=ip.src
#     Should not contain   container=${result}     item=${${not priority ip_E01}}
#     Should contain    container=${result}   item=${${priority ip_E01}}
# 
# ping eNB with vlan interface should be success
#     ping eNB with vlan ID interface should be success     VLAN_ID=${${vlan_id_100}}     ip_address=${${vlan_ip_100}}
#     ping eNB with vlan ID interface should be success     VLAN_ID=${${vlan_id_1500}}    ip_address=${${vlan_ip_1500}}
#     ping eNB with vlan ID interface should be success     VLAN_ID=${${vlan_id_2000}}    ip_address=${${vlan_ip_2000}}
#     ping eNB with vlan ID interface should be success     VLAN_ID=${${vlan_id_1000}}    ip_address=${${vlan_ip_1000}}
#     ping eNB with vlan ID interface should be success     VLAN_ID=${${vlan_id_100}}     ip_address=${${vlan_ip_100}}
# 
# 
# Tests Recover for 009
#     change portDefaultVlanId with new vlan id    new_vlan=1
#     set acceptable frame type tag    dist_name=${gNB_dist_l2sw_brg}    tag_value=ADMIT_ALL
#     Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
#     active Qos awareness tag     dist_name=${gNB_dist_l2sw}
#     active chaining feature tag
#     disconect all connections
# 
# Tests Recover for 001
#     run keyword and ignore error    csn.disconnect    connection=ENB
#     killall firefox progress
#     disconect all connections
# 
# Tests send PCP vlan tag and analysis the enb logs
#     Start To Capture ENB Logs       filename=${enblog_E01}   connection=ENB
#     sleep    3s
#     Send PCP vlan tag traffic from testcenter to enb
#     sleep    40s
#     Stop and download ENB Logs       filename=${enblog_E01}   connection=ENB
#     Analysis enblog E01       Log_name=${enblog_E01}