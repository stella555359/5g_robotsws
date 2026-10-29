# *** Settings ***
# Documentation
# ...    author: fangmin.wu
# ...    contact: fangmin.wu@nokia-sbell.com
# ...    squad group: MMW_SG_03
# ...    feature : CB5750-EAAU
# 
# Force Tags    CRT_21A    CRT_TRUNK     CRT_21B
# ...    PY36
# 
# Suite Setup
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library     taf.gnb.oam.commissioning   WITH NAME    comissioning
# Resource    ./Resources/CB005750-EAAU_vlanAwareness_common_keywords.robot
# Library     ./Resources/CB005750-EAAU_tshark_parser.py
# Library     CB005750-EAAU_tshark_parser.Parser     WITH NAME    tsk
# 
# *** Variables ***
# ${untagged_ip}   192.168.100.110
# ${priority_tagged_ip}   192.168.100.111
# ${vlan555_ip}    192.168.101.116    #vlan 555 is in the vlanlist
# ${vlan777_ip}    192.168.103.118    #vlan 777 is not in the vlan list and not same with pvid
# ${vlan888_ip}    192.168.104.119    #vlan 888 is not in the vlan list ,but same with pvid
# ${vlan666_ip}    192.168.102.130    #not configured ip
# ${TS_LOG_PATH_BASE}    /home/ute/Downloads/
# ${Testcenter_script_path}   /home/ute/TC_file
# ${log_name_KA006}    2377_KA006
# ${log_name_KA007}    2377_KA007
# ${log_name_KA008}    2377_KA008
# ${Testcenter_MAC}    00:10:94:00:00:02
# *** Test Cases ***
# [1]CB005750-EAAU_5GC000519_006_Configure_of_EIF1_for_backhaul_and_EIF2_locked_and_EIF3_for_chaining_of_VLAN_ingress_filtering
#     [Documentation]
#     ...    This case is used to verifyied that the egress filtering and processing.
#     [Tags]    CRT_21A    CRT_TRUNK      CRT_21B
#     [Setup]    Case setup
#     Du COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...    parameter=vlanAwarenessEnabled     value=true
#     Du COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-3
#     ...    parameter=acceptableFrameTypes   value=ADMIT_ALL
#     Send all type traffic and capture tcpdump from testcenter     testcenter_tclfile=${Testcenter_script_path}/2377_KA006.tcl
#     ...    Log_name=${log_name_KA006}
#     @{expected_accepted_ip}    create list    ${untagged_ip}    ${vlan555_ip}    ${vlan888_ip}
#     @{expected_dropped_ip}    create list    ${vlan777_ip}
#     Analysis log      log_path=${wireshark_log_path}   accepted_ip=${expected_accepted_ip}   dropped_ip=${expected_dropped_ip}
#    [Teardown]    Run Keyword And Ignore Error    Common Tests Recover
# 
# [1]CB005750-EAAU_5GC000519_007_Configure_of_EIF1_for_backhaul_and_EIF2_locked_and_EIF3__for_chaining_of_VLAN_aware_egress_port _lookup
#     [Documentation]
#     ...    This case is used to verifyied the egress port lookup function
#     [Tags]    CRT_21A    CRT_TRUNK     CRT_21B
#     [Setup]    Case setup
#     Du COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...    parameter=vlanAwarenessEnabled    value=false
#     Du COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...    parameter=vlanAwarenessEnabled    value=true
#     Send all type traffic and capture tcpdump from testcenter     testcenter_tclfile=${Testcenter_script_path}/2377_KA007.tcl
#     ...    Log_name=${log_name_KA007}
#     Check FDB mac address contain VLAN-ID and DST-MAC    VLAN_ID=555
#     Check FDB mac address contain VLAN-ID and DST-MAC   VLAN_ID=888
#     Check FDB mac address contain VLAN-ID and DST-MAC    VLAN_ID=666
#     Check FDB mac address not contain VLAN-ID and DST-MAC    VLAN_ID=777
#     [Teardown]    Run Keyword And Ignore Error    Common Tests Recover
# 
# [1]CB005750-EAAU_5GC000519_008_vlan_aware_ethernet_switch_of_EIF1_backhaul_EIF2_locked_EIF3_for_chaining_of_VLAN_egress_filtering_and_processing
#     [Documentation]
#     ...    This case is used to verifyied that the egress filtering and processing.
#     [Tags]    CRT_21A    CRT_TRUNK     CRT_21B
#     [Setup]    Case setup
#     Du COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...    parameter=vlanAwarenessEnabled     value=true
#     Du COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-3
#     ...    parameter=acceptableFrameTypes   value=ADMIT_TAGGED
#     Send all type traffic and capture tcpdump from testcenter     testcenter_tclfile=${Testcenter_script_path}/2377_KA008.tcl
#     ...    Log_name=${log_name_KA008}
#     @{expected_accepted_ip}    create list    ${vlan555_ip}    ${vlan888_ip}
#     @{expected_dropped_ip}    create list    ${vlan777_ip}    ${untagged_ip}    ${priority_tagged_ip}
#     Analysis log      log_path=${wireshark_log_path}   accepted_ip=${expected_accepted_ip}   dropped_ip=${expected_dropped_ip}
#     Du COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...    parameter=vlanAwarenessEnabled     value=false
#     Send all type traffic and capture tcpdump from testcenter     testcenter_tclfile=${Testcenter_script_path}/2377_KA008.tcl
#     ...    Log_name=${log_name_KA008}
#     @{expected_accepted_ip}    create list   ${untagged_ip}    ${priority_tagged_ip}   ${vlan555_ip}    ${vlan888_ip}    ${vlan777_ip}
#     @{expected_dropped_ip}    create list
#     Analysis log      log_path=${wireshark_log_path}  accepted_ip=${expected_accepted_ip}   dropped_ip=${expected_dropped_ip}
#     [Teardown]    Run Keyword And Ignore Error    Tests Recover for 008
# 
# *** Keywords ***
# 
# Case setup
#     COAM Create log directory
#     COAM Wait for gnb ready and cell setup
#     Check all EIF port status on DU should be up
# 
# Common Tests Recover
#      COAM Teardown gnb connections
#      CI_interface.Common Case Teardown
# 
# Tests Recover for 008
#     Du COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...    parameter=vlanAwarenessEnabled     value=true
#     Du COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-3
#     ...    parameter=acceptableFrameTypes   value=ADMIT_ALL
#     COAM Teardown gnb connections
#     CI_interface.Common Case Teardown
# 
# 
# 
