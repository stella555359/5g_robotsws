# *** Settings ***
# Suite Setup       common suite setup
# Suite Teardown    common suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    LTE1467    CLOUD_R4A_CUS    CRT    wennan.deng@nokia-sbell.com
# #Resource          ${CURDIR}/../../../../../resource/ET/SG11/common_resource_ABIO.robot
# Resource          ${CURDIR}/../../resources/KISS/robot/common_resource_ABIO.robot
# Library     ta_kiss_enb_ttitrace
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config/
# ${scfc_name}    SCFC_1.xml
# ${cus_yaml}     cus.yaml
# @{earfcn}    text|40542|//*[contains(@distName, 'LNCEL-1')]/*[@name='earfcn']    text|40740|//*[contains(@distName, 'LNCEL-2')]/*[@name='earfcn']
# ...    text|40938|//*[contains(@distName, 'LNCEL-3')]/*[@name='earfcn']
# ${actDLCAggr}    text|true|//*[@name\="actDLCAggr"]
# @{modify_list}    ${actDLCAggr}    @{earfcn}
# ${category_professional}    CDBFF041034410381DF834624000A006830007A0000068010B210010
# 
# 
# *** Test Cases ***
# LTE1467-A_b 07 TDD SSP6 Thput verification TM4 20M 26
#     [Tags]    QC_22749
#     Step1:Set parameters as pre-condition
#     Step2:iphy attach and start traffic
#     Step3:Detach UE
#     Step4:dump uexgate log
#     Step5:Verify SSP
# 
# *** Keywords ***
# Step1:Set parameters as pre-condition
#     Start enb and cus syslog'1'
#     Establish cell with bandwidth 20M and frameconfigure 2 9
#     Stop and collect enb and cus syslog
#     collect procotol log '1' from egate
# 
# Establish cell with bandwidth 20M and frameconfigure 2 9
#     ${scfc_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}scfc.xml
#     ${cus_yaml_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}cus_1.yaml
#     copy_file    ${CONFIG_DIR_PATH}/${scfc_name}    ${scfc_path}
#     copy_file    ${CONFIG_DIR_PATH}/${cus_yaml}    ${cus_yaml_path}
#     Modify SCFC into 3cc CA       ${scfc_path}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Load CUS config Files And Wait BTS Onair    ${scfc_path}    ${cus_yaml_path}    enb_swconfig=${eNB_swconfig_path}
# 
# Step2:iphy attach and start traffic
#     Start enb and cus syslog'2'
#     #start_capture_ttitrace'2'
#     Run UEx command    ue_attach    id=1    ue_eutra_capabilities=CDBFF041034410381DF834624000A006830007A0000068010B210010    cell=1
#     Wait Throughput Timer    5s
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1    qci=8    kbps=150000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1    qci=8    kbps=150000    trf_id=2    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1    qci=8    kbps=20000    trf_id=1    dir=ul    protocol=udp
#     Wait Throughput Timer    20
#     ${ue1_dl_throughput}          cus_get_dl_throughput_ave           ue_id=1    type=dl_mac
#     should be true               ${ue1_dl_throughput}>9.89
#     #Save_and_Decode_ttitrace_'2'
#     Stop and collect enb and cus syslog
# 
# Step3:Detach UE
#     #start_capture_ttitrace'3'
#     Run UEx command    ue_detach    id=1
#     #Save_and_Decode_ttitrace_'3'
# 
# Step4:dump uexgate log
#     ${uex_log_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}uexgate_log
#     ${uexlog_dump_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}uexgate_dump
#     Copy Directory    /home/cus/logs/uex/latest/     ${uex_log_path}
#     cus_dump_cells_log      ${uexlog_dump_path}
# 
# Step5:Verify SSP
#     ${ssp_num}           Grep File        ${TEST LOG DIRECTORY()}/uexgate_dump/cell-1_dump.txt           specialSubframePatterns-v1130 ssp9  
#     ${ssp_Count}         Get Line Count       ${ssp_num}
#     should_be_true       ${ssp_Count}>1
# 
# Wait Throughput Timer
#     [Arguments]    ${time}
#     [Documentation]    This keyword is used to sleep several seconds after start data traffic.
#     ...    | Input Parameters | Man. | Description |
#     ...    | time | Yes | time, unit is second |
#     ...    Example:
#     ...    | Wait Throughput Timer | 15 |
#     Sleep    ${time}
