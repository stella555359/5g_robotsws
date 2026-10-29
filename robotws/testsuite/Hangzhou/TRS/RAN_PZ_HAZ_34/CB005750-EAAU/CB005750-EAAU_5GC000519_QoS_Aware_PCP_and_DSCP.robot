# *** Settings ***
# Documentation
# ...    author: fangmin.wu
# ...    contact: fangmin.wu@nokia-sbell.com
# ...    squad group: SG_03
# ...    feature: CB5750-EAAU
# 
# Force Tags    CRT_21A    CRT_TRUNK      CRT_21B
# ...    PY36
# 
# Suite Setup       Suite setup
# Suite Teardown    Suite teardown
# 
# Resource    Resources/CB005750-EAAU_QoS_common_keywords.robot
# Resource    Resources/CB005750-EAAU_vlanAwareness_common_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${mrbtsId}    ${tl.gnbs[0].global_bts_id}
# ${UTE_addr}    ${tl.test_pc.default_ssh_connection_details.addr}
# ${UTE_username}    ${tl.test_pc.default_ssh_connection_details.username}
# ${UTE_password}    ${tl.test_pc.default_ssh_connection_details.password}
# ${case12_AF4_BE}    /home/ute/Spirent/Test_center_TA_script/case12_AF4_BE.tcl
# ${case12_weight_log}    case12_AF4_BE.pcap
# ${case12_AF4_EF}    /home/ute/Spirent/Test_center_TA_script/case12_AF4_EF.tcl
# ${case12_drop_log}    case12_AF4_EF.pcap
# ${case12_drop_pdml}    case12_AF4_EF.pdml
# ${epc_log_path}    /home/ute/Downloads/
# ${case10_AF4_EF}    /home/ute/Spirent/Test_center_TA_script/case10_AF4_EF.tcl
# ${case10_AF2_AF3}    /home/ute/Spirent/Test_center_TA_script/case10_AF2_AF3.tcl
# ${case10_weight_log}    case10_AF2_AF3.pcap
# ${case10_drop_log}    case10_AF4_EF.pcap
# ${case11_AF2_EF}    /home/ute/Spirent/Test_center_TA_script/case11_AF2_EF.tcl
# ${case11_AF2_AF3}    /home/ute/Spirent/Test_center_TA_script/case11_AF2_AF3.tcl
# ${case11_weight_log}    case11_AF2_AF3.pcap
# ${case11_drop_log}    case11_AF2_EF.pcap
# ${case13_AF2_EF}    /home/ute/Spirent/Test_center_TA_script/case13_AF2_EF.tcl
# ${case13_BE_AF1}    /home/ute/Spirent/Test_center_TA_script/case13_BE_AF1.tcl
# ${case13_weight_log}    case13_BE_AF1.pcap
# ${case13_drop_log}    case13_AF2_EF.pcap
# ${case15_SP1_SP2}    /home/ute/Spirent/Test_center_TA_script/case15_SP1_SP2.tcl
# ${case15_drop_log}    case15_SP1_SP2.pcap
# 
# 
# *** Test Cases ***
# [1]CB005750-EAAU_5GC000519_010_QoS_Aware_primary_classification_criteria_Vlan_PCP_for_VLAN_tagged_frame_in_vlan_aware_or_unaware
#     [Documentation]
#     ...    This case is used to verifyied the handling of VLAN tagged frames with VLAN-PCP classification mode in case of Vlan-aware and unaware,
#   	...    In this case, L2-priority-to-queue mapping is used for classified. two traffici is vlan tagged frame with different weight/priority.
#     [Tags]   CRT_21A    CRT_TRUNK      CRT_21B
#     [Setup]
#     Send case10 precondition SCF
#     Check cells onAir
#     Send traffics using testcenter and save logs    filename=${case10_AF2_AF3}
#     Analysis wireshark log and check the schedule weight of two tagged packages   filename=${case10_weight_log}
#     Sleep    20s
#     Send traffics using testcenter and save logs    filename=${case10_AF4_EF}
#     Analysis wireshark log and check these is only tagged packages with EF priority   filename=${case10_drop_log}
#     [Teardown]    CI_interface.Common Case Teardown
# 
# #
# [1]CB005750-EAAU_5GC000519_012_QoS_Aware_primary_classification_criteria_Vlan_PCP_for_untagged_frame_using_Port_Default_Priority_in_vlan_aware
#     [Documentation]
#     ...    This case is used to verifyied the handling of untagged frames with VLAN-PCP classification mode in case of Vlan-aware,
#     ...    In this case, L2-priority-to-queue mapping is used for classified. and a eNB is chained.
#     [Tags]   CRT_21A    CRT_TRUNK     CRT_21B
#     [Setup]
#     Send case12 precondition SCF
#     Check cells onAir
#     Send traffics using testcenter and save logs    filename=${case12_AF4_EF}
#     sleep    10s
#     Analysis wireshark log and check these is only EF untagged packages   filename=${case12_drop_log}    pdmlname=${case12_drop_pdml}
#     Change port default priority from EF to BF
#     Send traffics using testcenter and save logs    filename=${case12_AF4_BE}
#     Analysis wireshark log and check the schedule weight of tagged and untagged packages   filename=${case12_weight_log}
#     [Teardown]    CI_interface.Common Case Teardown
# 
# [1]CB005750-EAAU_5GC000519_013_QoS_Aware_primary_classification_criteria_Vlan_PCP_for_untagged_frame_using_DSCP_in_vlan_unaware
#     [Documentation]
#     ...    This case is used to verifyied the handling of untagged frames with VLAN-PCP classification mode in case of Vlan-aware,
#     ...    In this case, L2-priority-to-queue mapping is used for classified. and a eNB is chained.
#     [Tags]   CRT_21A    CRT_TRUNK      CRT_21B
#     [Setup]
#     Send case13 precondition SCF
#     Check cells onAir
#     Send traffics using testcenter and save logs    filename=${case13_AF2_EF}
#     Analysis wireshark log and check these is only DSCP EF packages   filename=${case13_drop_log}
#     Send traffics using testcenter and save logs    filename=${case13_BE_AF1}
#     Analysis wireshark log and check the schedule weight of DSCP packages   filename=${case13_weight_log}
#     [Teardown]    CI_interface.Common Case Teardown
# 
# [1]CB005750-EAAU_5GC000519_015_QoS_Aware_SP1_prior_to_SP2_IPv4_or_IPv6
#     [Documentation]
#     ...    This case is used to verify The first strict priority queue is scheduled prior to the second strict priority queue.
#     ...    The first strict priority queue is intended to aggregate link-specific L2 protocols
#     ...    (e.g. Link OAM, Synchronous Ethernet, RSTP, PTP/IP traffic)
#     ...    and is not operator configurable.
# 
#     [Tags]   CRT_21A    CRT_TRUNK       CRT_21B
#     [Setup]
#     Send case15 precondition SCF
#     config SP queues on ASIL
#     Check cells onAir
#     Send traffics using testcenter and save logs    filename=${case15_SP1_SP2}
#     Analysis wireshark log and veryfy sp1 queue is scheduled prior to sp2 quere   filename=${case15_drop_log}
#     [Teardown]    CI_interface.Common Case Teardown
# 
# #[1]CB005750-EAAU_5GC000519_011_QoS_Aware_primary_classification_criteria_Vlan_PCP_for_Priority_tagged_frame_in_vlan_aware_or_unaware
# #    [Documentation]
# #    ...    This case is used to verifyied the handling of priority-tagged frames with VLAN-PCP classification mode
# #    ...    in case of Vlan-aware and unaware, In this case, L2-priority-to-queue mapping is used for classified.
# #    [Tags]   CRT_21A    CRT_TRUNK      CRT_21B
# #    [Setup]
# #    Send case11 precondition SCF
# #    Check cells onAir
# #    Send traffics using testcenter and save logs    filename=${case11_AF2_AF3}
# #    Analysis wireshark log and check the schedule weight of two priority tagged packages   filename=${case11_weight_log}
# #    Sleep    20s
# #    Send traffics using testcenter and save logs    filename=${case11_AF2_EF}
# #    Analysis wireshark log and check these is only priority tagged packages with EF priority   filename=${case11_drop_log}
# #    [Teardown]    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# 
# Check cells onAir
#     Log To Console    Check cells onAir
#     COAM Check All Cells Onair    connection=default
# 
# Send case10 precondition SCF
#     Log To Console    PCP2MAP setting
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/PCP2QMAP-1
#     ...       parameter=queueForPcp2
#     ...       value=AF2
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/PCP2QMAP-1
#     ...       parameter=queueForPcp3
#     ...       value=AF3
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/PCP2QMAP-1
#     ...       parameter=queueForPcp4
#     ...       value=AF4
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/PCP2QMAP-1
#     ...       parameter=queueForPcp5
#     ...       value=EF
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     Log To Console    PCP classification
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...       parameter=qosClassificationCriteria
#     ...       value=PCP
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...       parameter=l2WeightAF2
#     ...       value=2
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...       parameter=l2WeightAF3
#     ...       value=4
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
# 
# Send case11 precondition SCF
#     Log To Console    PCP2MAP setting
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/PCP2QMAP-1
#     ...       parameter=queueForPcp2
#     ...       value=AF2
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/PCP2QMAP-1
#     ...       parameter=queueForPcp3
#     ...       value=AF3
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/PCP2QMAP-1
#     ...       parameter=queueForPcp5
#     ...       value=EF
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     Log To Console    PCP classification
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...       parameter=qosClassificationCriteria
#     ...       value=PCP
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...       parameter=l2WeightAF2
#     ...       value=2
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...       parameter=l2WeightAF3
#     ...       value=4
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1
#     ...       parameter=l2ShaperRate
#     ...       value=50000
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
# 
# Send case12 precondition SCF
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1
#     ...       parameter=portDefaultVlanPriority
#     ...       value=5
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-3
#     ...       parameter=portDefaultVlanPriority
#     ...       value=5
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     Log To Console    PCP2MAP setting
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/PCP2QMAP-1
#     ...       parameter=queueForPcp0
#     ...       value=BE
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/PCP2QMAP-1
#     ...       parameter=queueForPcp4
#     ...       value=AF4
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/PCP2QMAP-1
#     ...       parameter=queueForPcp5
#     ...       value=EF
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     Log To Console    PCP classification
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...       parameter=qosClassificationCriteria
#     ...       value=PCP
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...       parameter=l2WeightBE
#     ...       value=1
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...       parameter=l2WeightAF4
#     ...       value=2
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
# 
# Send case13 precondition SCF
#     Log To Console    DSCP classification
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...       parameter=qosClassificationCriteria
#     ...       value=DSCP
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     Log To Console    DSCP schedule and weight
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/DSCPTOQMAP-1
#     ...       parameter=queueForDscp20
#     ...       value=AF2
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/DSCPTOQMAP-1
#     ...       parameter=queueForDscp46
#     ...       value=EF
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/DSCPTOQMAP-1
#     ...       parameter=queueForDscp16
#     ...       value=BE
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/DSCPTOQMAP-1
#     ...       parameter=queueForDscp10
#     ...       value=AF1
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...       parameter=l2WeightBE
#     ...       value=1
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...       parameter=l2WeightAF1
#     ...       value=1
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
# 
# 
# Send case15 precondition SCF
#     Log To Console    DSCP classification
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...       parameter=qosClassificationCriteria
#     ...       value=DSCP
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#     Log To Console    DSCP schedule and weight
# 
# 
# Send traffics using testcenter and save logs
#     [Arguments]     ${filename}
#     csn.Connect To    hostname=${UTE_addr}
#     ...               username=${UTE_username}
#     ...               password=${UTE_password}
#     ...               alias=UTE
#     csn.send command    command=sudo tclsh ${filename}    connection=UTE
#     sleep    40s
#     csn.disconnect    connection=UTE
# 
# Analysis wireshark log and check these is only tagged packages with EF priority
#     [Arguments]    ${filename}
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${PCP5_packets}=      taf.analyzer.pcap.get_field_value    field_name=vlan.id
#     ...    filter=vlan.priority==5
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${PCP4_packets}=      taf.analyzer.pcap.get_field_value    field_name=vlan.id
#     ...    filter=vlan.priority==4
#     ${PCP5_number}=    get length    ${PCP5_packets}
#     ${PCP4_number}=    get length    ${PCP4_packets}
#     should be true   ${PCP4_number}==0
#     should be true   ${PCP5_number}!=0
#     should be equal    ${PCP5_packets[0]}[0]    555
# 
# Analysis wireshark log and check the schedule weight of two tagged packages
#     [Arguments]    ${filename}
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${PCP2_packets}=      taf.analyzer.pcap.get_field_value    field_name=ip.src
#     ...    filter=vlan.priority==2
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${PCP3_packets}=      taf.analyzer.pcap.get_field_value    field_name=ip.src
#     ...    filter=vlan.priority==3
#     ${PCP2_number}=    get length    ${PCP2_packets}
#     ${PCP3_number}=    get length    ${PCP3_packets}
#     should be true   2*${PCP2_number}*0.9<${PCP3_number}<2*${PCP2_number}*1.1
# 
# Analysis wireshark log and check these is only priority tagged packages with EF priority
#     [Arguments]    ${filename}
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${PCP5_packets}=      taf.analyzer.pcap.get_field_value    field_name=ip.src
#     ...    filter=ip.src==192.168.100.115
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${PCP2_packets}=      taf.analyzer.pcap.get_field_value    field_name=ip.src
#     ...    filter=ip.src==192.168.100.112
#     ${PCP5_number}=    get length    ${PCP5_packets}
#     ${PCP2_number}=    get length    ${PCP2_packets}
#     should be true   ${PCP2_number}==0
#     should be true   ${PCP5_number}!=0
# 
# Analysis wireshark log and check the schedule weight of two priority tagged packages
#     [Arguments]    ${filename}
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${PCP2_packets}=      taf.analyzer.pcap.get_field_value    field_name=ip.src
#     ...    filter=ip.src==192.168.100.112
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${PCP3_packets}=      taf.analyzer.pcap.get_field_value    field_name=ip.src
#     ...    filter=ip.src==192.168.100.113
#     ${PCP2_number}=    get length    ${PCP2_packets}
#     ${PCP3_number}=    get length    ${PCP3_packets}
#     should be true   2*${PCP2_number}*0.9<${PCP3_number}<2*${PCP2_number}*1.1
# 
# Analysis wireshark log and check these is only EF untagged packages
#     [Arguments]    ${filename}    ${pdmlname}
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
# #    should not contain    ${epc_log_path}${pdmlname}   192.168.101.120    ignore_case=True
#     ${tagged_packets}=     taf.analyzer.pcap.get_field_value    field_name=ip.dst
#     ...    filter=ip.src==192.168.101.120
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${untagged_packets}=     taf.analyzer.pcap.get_field_value    field_name=ip.dst
#     ...    filter=ip.src==192.168.100.105
#     ${tagged_number}=    get length    ${tagged_packets}
#     ${untagged_number}=    get length    ${untagged_packets}
#     should be true    ${tagged_number}==0
#     should be true    ${untagged_number}!=0
#     should be equal    ${untagged_packets[0]}[0]    192.168.100.110
# 
# Analysis wireshark log and check the schedule weight of tagged and untagged packages
#     [Arguments]    ${filename}
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${untagged_packages}=      taf.analyzer.pcap.get_field_value    field_name=ip.dst
#     ...    filter=ip.src==192.168.100.105
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${tagged_packages}=      taf.analyzer.pcap.get_field_value    field_name=vlan.id
#     ...    filter=ip.src==192.168.101.120
#     ${untagged_number}=    get length    ${untagged_packages}
#     ${tagged_number}=    get length    ${tagged_packages}
#     should be true   2*${untagged_number}*0.9<${tagged_number}<2*${untagged_number}*1.1
# 
# Change port default priority from EF to BF
#     admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1
#     ...       parameter=portDefaultVlanPriority
#     ...       value=0
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
#         admin_cli.Perform Parameter Recommissioning
#     ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-2
#     ...       parameter=portDefaultVlanPriority
#     ...       value=0
#     ...       operation=update
#     ...       skip_parameter_relation_errors=skip
#     ...       connection=default
# 
# Analysis wireshark log and check these is only DSCP EF packages
#     [Arguments]    ${filename}
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${DSCP20_packets}=      taf.analyzer.pcap.get_field_value    field_name=ip.src
#     ...    filter=ip.dsfield.dscp==20
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${DSCP46_packets}=      taf.analyzer.pcap.get_field_value    field_name=ip.src
#     ...    filter=ip.dsfield.dscp==46
#     ${DSCP20_number}=    get length    ${DSCP20_packets}
#     ${DSCP46_number}=    get length    ${DSCP46_packets}
#     should be true   ${DSCP20_number}==0
#     should be true   ${DSCP46_number}!=0
#     should be equal    ${DSCP46_packets[0]}[0]    192.168.100.105
# 
# Analysis wireshark log and check the schedule weight of DSCP packages
#     [Arguments]    ${filename}
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${BE_packets}=      taf.analyzer.pcap.get_field_value    field_name=ip.src
#     ...    filter=ip.dsfield.dscp==16
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${AF1_packets}=      taf.analyzer.pcap.get_field_value    field_name=ip.src
#     ...    filter=ip.dsfield.dscp==10
#     ${BE_number}=    get length    ${BE_packets}
#     ${AF1_number}=    get length    ${AF1_packets}
#     should be true   ${AF1_number}*0.9<${BE_number}<${AF1_number}*1.1
# 
# 
# config SP queues on ASIL
#     login on gNB DU
#     ${output}    csn.execute    dbgnac set mapping dscp profile 2 entriesN 2 46,6/48,7    connection=gnb DU
#     Should contain    ${output}    setting the mapping of table 2 done
# 
# Analysis wireshark log and veryfy sp1 queue is scheduled prior to sp2 quere
#     [Arguments]    ${filename}
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${DSCP46_packets}=      taf.analyzer.pcap.get_field_value    field_name=ip.src
#     ...    filter=ip.dsfield.dscp==46
#     taf.analyzer.pcap.load_pcap_file      pcap_file=${epc_log_path}${filename}
#     ${DSCP48_packets}=      taf.analyzer.pcap.get_field_value    field_name=ip.src
#     ...    filter=ip.dsfield.dscp==48
#     ${DSCP46_number}=    get length    ${DSCP46_packets}
#     ${DSCP48_number}=    get length    ${DSCP48_packets}
#     should be true   ${DSCP46_number}==0
#     should be true   ${DSCP48_number}!=0
#     should be equal    ${DSCP48_packets[0]}[0]    192.168.100.105
# 
# 
