*** Settings ***
Documentation
...             author: Thomas Vieille
...             contact: thomas.vieille@nokia.com
...             5GC000371: 5G Node B Unit Recovery log collecting and 5G NodeB supportablity study

Library         ArchiveLibrary
Library         taf.collectors.btslog   WITH NAME  btslog
Library         taf.collectors.core	    WITH NAME  core
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Library         taf.transport.ssh       WITH NAME  ssh
Library         OperatingSystem
Library         Collections
Library         DateTime
Library         String


Resource        keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Force Tags    RAN_5G    RAN_5G_TDD    CRT_UTE    CRT_21B    CRT_TRUNK    CRT_22R1
...    PY36
...    CLOUD_5G_CLASSICAL_ANDROID_ASIKR_ABILB4_AZHA_ENB_NETACT    STATE_SW_UPLOADED    SBTS00 


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Suite Setup    Run Keywords    CI_interface.Common Suite Setup
...    AND     robot_common_operations.Common Suite Setup
...     AND    5GC000371_CLASSICAL Setup

Suite Teardown   Run Keywords     5GC000371_CLASSICAL Teardown   AND   robot_common_operations.Common Suite Teardown
Test Setup       robot_common_operations.Common Case Setup
Test Teardown    robot_common_operations.Common Case Teardown





*** Variables ***
${qc_test_set_name}    5GC000371_5GNB_Unit_Recovery_Log_Collection
${qc_test_set_path}    Root\\Test_Sets\\5G20B_MP\\Regression\\SRAN_ENG2_PZ_HZ\\SRAN_ENG2_PZ_HZ_2
${PATH_Storage}    /home/ute/robot_temporary/
${ASIK_IP_LMP}				${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP_OAM}				${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_username}			${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username} 
${ASIK_password}			${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${COAM_ADMIN_PORT}			${tl.gnbs[0].cu.oam_http_connection_details.port}
${COAM_ADMIN_username}			${tl.gnbs[0].cu.oam_http_connection_details.username}
${COAM_ADMIN_password}			${tl.gnbs[0].cu.oam_http_connection_details.password}
@{ALLOWED_ALARMS}=
...                                4592
...                                61524
...                                61649
...								   61652
...                                4334
...                                4655
...                                4654
...                                4681
...                                4798
${BBMOD0_IP_XEONA}			${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[1].addr}
${BBMOD1_IP_XEONA}			${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[5].addr}
${BBMOD2_IP_XEONA}      ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[9].addr}
${BBMOD0_IP_XEONB}			${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[2].addr}
${BBMOD1_IP_XEONB}			${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[6].addr}
${BBMOD2_IP_XEONB}      ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[10].addr}
${BBMOD0_IP_LONER}			${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[3].addr}
${BBMOD1_IP_LONER}			${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[7].addr}
${BBMOD2_IP_LONER}      ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[11].addr}
${BBMOD}                ${tl.tl_cloud_topology.split('_')[5]}
*** Test Cases ***
[1]5GC000371-B_TC#4_Check RU restart indication is sent to OAM(4527 BTS fault )
  [Tags]    CDRT_TRUNK    CRT_21A
  Check RU restart indication is sent to OAM
  
[1]5GC000371-A_TC#1_Check RU logs availibility_case auto reset
  [Tags]    CRT_21A
  Check RU logs availibility_case auto reset

[1]5GC000371-C_TC#5_RAU collection of its own RAU logs
  RAU collection of its own RAU logs
  
[1]5GC000371-C_TC#6_L1 crash Log collection by RAU
  L1 crash Log collection by RAU


  

