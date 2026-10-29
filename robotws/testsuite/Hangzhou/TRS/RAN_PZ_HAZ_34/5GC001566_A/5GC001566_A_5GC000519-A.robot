# *** Settings ***
# Force Tags    PY36
# Documentation    author：Hongyu Jiang
# ...              contact: hongyu.jiang@nokia-sbell.com
# ...              squad group: mmw_SG_04
# 
# Resource          ./Resources/common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# 
# *** Variables ***
# ${CURDIR_path}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}
# ${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${LOG_PATH}               ${output_dir}
# ${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
# ${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
# ${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
# ${CU_ip}                  ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${luashark_path}          /opt/ute/luashark/luashark_script/generated_luashark
# ${tl_name}                ${tl.gnbs[0].global_bts_id}
# ${gNB_ssh_username}       ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
# ${gNB_ssh_password}       ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
# #${Download_file}          /home/ute/Downloads/519_A
# ${case11_01}              519_A/Tagged-DSCP20-DSCP46/Tagged-DSCP20-DSCP46.tcl
# ${case11_02}              519_A/Tagged-DSCP20-DSCP38/Tagged-DSCP20-DSCP38.tcl
# ${case07}                 519_A/tagged-vlan_pcp_p1_p7/tagged_vlan_pcp_p1_p7.tcl
# ${case09}                 519_A/tagged_vlan_p1_untagged_portDeaultPoriority/tagged_vlan_p1_untagged_portDeaultPoriority.tcl
# 
# 
# *** Test Cases ***
# #[1]5GC001566-5GC000519-A_011_QoS_Aware_primary_criteria_DSCP_based_on_DCSP_of_IP_header_IPv4_or_IPv6
# #    [Tags]    5GC001566_519    CRT_20B
# #    [Documentation]   QoS Aware primary criteria DSCP based on DCSP of IP header IPv4 or IPv6
# #    [Setup]    Modify SCF And Commission SCF   save_path=${LOG_PATH}/modify_scf.xml  input_list=${Modify_DU_l2ShaperRate}
# #    Create TestCenter Packet And Check    tcl_file=${case11_01}   drop_package=98
# #    ...    pcap_file=tmp_capture.pcap    filter_list=${filter_list1}    txt_list=${txt_list1}    different_package_ratio=99
# #    Modify Value On DU     structure_modify_list=${Modify_011case_step5_1}   common_modify_list=${Modify_011case_step5_2}
# #    ...    class_name=BRGPRT_A    keywords_list=${keywords_list1}
# #    Create TestCenter Packet And Check    tcl_file=${case11_01}   drop_package=98
# #    ...    pcap_file=tmp_capture.pcap    filter_list=${filter_list1}    txt_list=${txt_list1}    different_package_ratio=99
# #    Modify Value On DU     structure_modify_list=${Modify_011case_step7_1}   common_modify_list=${Modify_011case_step7_2}
# #    ...    class_name=BRGPRT_A    keywords_list=${keywords_list1}
# #    Create TestCenter Packet And Check    tcl_file=${case11_01}   drop_package=98
# #    ...    pcap_file=tmp_capture.pcap    filter_list=${filter_list1}    txt_list=${txt_list1}    different_package_ratio=99
# #    Modify Value On DU    common_modify_list=${Modify_011case_step9_1}   is_structure=${False}
# #    Create TestCenter Packet And Check    tcl_file=${case11_01}   drop_package=98
# #    ...    pcap_file=tmp_capture.pcap    filter_list=${filter_list1}    txt_list=${txt_list1}    different_package_ratio=99
# #    Create TestCenter Packet And Check    tcl_file=${case11_02}   drop_package=98
# #    ...    pcap_file=tmp_capture.pcap    filter_list=${filter_list2}    txt_list=${txt_list2}    different_package_ratio=88
# #    [Teardown]    CI_interface.Common Case Teardown
# 
# [1]5GC001566-5GC000519-A_007_QoS_Aware_primary_criteria_Vlan_PCP_for_VLAN_tagged_frame_in_vlan_aware_or_unaware_cloud_NSA
#     [Tags]    5GC001566_519    CRT_22R2    CRT_TRUNK    CRT_21B
#     [Documentation]   QoS Aware primary criteria Vlan PCP for VLAN tagged frame in vlan aware or unaware cloud NSA
#     [Setup]    Modify SCF And Commission SCF   save_path=${LOG_PATH}/modify_scf.xml  input_list=${Modify_DU_SCF_Case7}
#     Create TestCenter Packet And Check     tcl_file=${case07}   drop_package=98
#     ...    pcap_file=tmp_capture.pcap    filter_list=${filter_list_case7}   txt_list=${txt_list3}   different_package_ratio=99
#     Modify Value On DU    common_modify_list=${Modify_007case_step5_1}   is_structure=${False}
#     Create TestCenter Packet And Check     tcl_file=${case07}   drop_package=98
#     ...    pcap_file=tmp_capture.pcap    filter_list=${filter_list_case7}   txt_list=${txt_list3}   different_package_ratio=99
#     Modify Value On DU    common_modify_list=${Modify_007case_step7_1}   is_structure=${False}
#     Create TestCenter Packet And Check     tcl_file=${case07}   drop_package=98
#     ...    pcap_file=tmp_capture.pcap    filter_list=${filter_list_case7}   txt_list=${txt_list3}   different_package_ratio=88
#     [Teardown]    CI_interface.Common Case Teardown
# 
# [1]5GC001566-5GC000519-A_009_QoS_Aware_primary_classification_criteria_Vlan_PCP_for_untagged_frame_using_DSCP_in_vlan_unaware
#     [Tags]    5GC001566_519    CRT_22R2    CRT_TRUNK   CRT_21B
#     [Documentation]    QoS Aware primary criteria Vlan PCP for untagged frame using DSCP in vlan unaware
#     [Setup]    Modify SCF And Commission SCF   save_path=${LOG_PATH}/modify_scf.xml  input_list=${Modify_DU_SCF_Case9}
#     Create TestCenter Packet And Check   tcl_file=${case09}
#     ...    drop_package=98    pcap_file=tmp_capture.pcap    filter_list=${filter_list_case9}   txt_list=${txt_list4}   different_package_ratio=99
#     Modify Value On DU    common_modify_list=${Modify_009case_step5_1}   is_structure=${False}
#     Create TestCenter Packet And Check   tcl_file=${case09}
#     ...    drop_package=98    pcap_file=tmp_capture.pcap    filter_list=${filter_list_case9}   txt_list=${txt_list4}   different_package_ratio=88
#     [Teardown]    CI_interface.Common Case Teardown
# 
# 
# *** Keywords ***
# Modify SCF And Commission SCF
#     [Arguments]   ${save_path}    ${input_list}
#     ${default_scf}    Get BTS Version And Perare SCF    CURDIR_path=${CURDIR_path}
#     Modify_GNB_SCF    file_path=${default_scf}  save_path=${save_path}   input_list=${input_list}
#     Setup Commission SCF    default_path=${save_path}
# 
# Create TestCenter Packet And Check
#     [Arguments]    ${tcl_file}   ${drop_package}   ${pcap_file}    ${filter_list}   ${txt_list}   ${different_package_ratio}   ${time}=50s
#     ${before_counter}    Get TRS Counters List via Api
#     ${drop_package_number}    Creat TestCenter Packet    file_name=${tcl_file}    time=${time}
#     ${file_list}    Convert pcap to text By filter   pcap_file=${pcap_file}    filter_list=${filter_list}    txt_list=${txt_list}
#     Run Keyword And Continue On Failure     Get Different Package Number And Calculation Ratio
#     ...     file_path_list=${file_list}    value=${different_package_ratio}
#     ${after_list}    Get TRS Counter Change List    input_counter=${before_counter}
#     Juge TRS BRGPRT-2 Counter Is Right    max=${drop_package}    drop_number=${drop_package_number}    counter_info=${after_list}
#     Clear Log On Ute    file_path=${LOG_PATH}
# 
# 
# 
# 
# 
# 
