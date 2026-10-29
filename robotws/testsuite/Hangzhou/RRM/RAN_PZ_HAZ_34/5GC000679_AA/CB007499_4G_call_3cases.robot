*** Settings ***
Documentation      author: Chen Xiaodong
...                contact: xiaodong.d.chen@nokia-sbell.com
...                Group: HGZ_SG2
Force Tags         5G_RRM    PY36
Suite Setup        SBTS Suite Setup
Suite Teardown     SBTS Suite Teardown
Library            OperatingSystem
Library            BuiltIn
Library            String
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/SBTS_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/Auto_BTS_site_reset.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
${sbts_addr}        ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${http_username}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${http_password}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${MRBTS_ID}         ${tl.gnbs[0].instance_id}
${NRBTS_ID}         ${tl.gnbs[0].global_bts_id}
@{cell_list}        1
${cell_type}        lte
${if_commissioning}    0
${site_reset_num}    50
${scf_relative_dir}    commissionings/HGZ
${if_pdl_check}     True
@{btslog_dirs}      /tmp/btslog2/
${scf_path}          /home/ute/Downloads/SCF
${apn}    dxdata2

*** Test Cases ***
[1]CB007499_SR_D_a_L3int_AQHA_01_L3call_1CC_TM3
    [Tags]     samsung_S20    4G
    [Setup]    Case Setup 7499
    Commissioning SCF And Check On Air for Common    scf_path=${scf_path}/${version}/case1_scf.xml
    Simple UE L3 Call And Throughput    dl_tp=130    ul_tp=9    apn=${apn}
    [Teardown]    Run Keyword And Ignore Error    case Teardown 7499

[1]CB007499_SR_D_b_L3int_AQHA_02_L3call_2CC_TM8
    [Tags]     samsung_S20    4G
    [Setup]    Case Setup 7499
    Commissioning SCF And Check On Air for Common    scf_path=${scf_path}/${version}/case2_scf.xml
    Run Keyword And Ignore Error    get theoretical throughput by NRdim
    Run Keyword And Ignore Error    Simple UE L3 Call And Throughput    dl_tp=250    ul_tp=10.8
    ...           target_avg_percent=0.98    duration=320    apn=${apn}
    [Teardown]    Run Keyword And Ignore Error    case Teardown 7499

[1]CB007499_SR_D_b_SISO_AQHA_04_Manual_SiSo_SM_BTS_Site_Reset
    [Tags]     samsung_S20    4G
    [Setup]    Case Setup 7499
    Commissioning SCF And Check On Air for Common    scf_path=${scf_path}/${version}/case2_scf.xml
    FOR    ${i}    IN RANGE    ${site_reset_num}
        Auto_BTS_site_reset
    END
   [Teardown]    Run Keyword And Ignore Error    case Teardown 7499

*** Keywords ***
Case Setup 7499
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Test Variable     ${version}     ${result}[0]
    SBTS Test Setup
    robot_common_operations.Common Case Setup    allowed_faults_ids=4420

get theoretical throughput by NRdim
    ${dl_target}    ${ul_target}    get_theoretical_throughput    scf_path=${scf_path}/${version}/case2_scf.xml    cell_id=${1}

case Teardown 7499
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown