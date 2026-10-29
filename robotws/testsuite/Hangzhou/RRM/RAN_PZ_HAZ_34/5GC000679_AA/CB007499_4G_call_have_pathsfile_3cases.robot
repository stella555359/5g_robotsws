# *** Settings ***
# Documentation      author: Chen Xiaodong
# ...                contact: xiaodong.d.chen@nokia-sbell.com
# ...                Group: HGZ_SG2
# Force Tags         5G_RRM    PY36
# Suite Setup        SBTS Suite Setup
# Suite Teardown     SBTS Suite Teardown
# Library            OperatingSystem
# Library            BuiltIn
# Library            String
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/SBTS_Setup_And_Teardown.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/Auto_BTS_site_reset.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/RUfile_opearte_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${sbts_addr}        ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${http_username}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${http_password}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${MRBTS_ID}         ${tl.gnbs[0].instance_id}
# ${NRBTS_ID}         ${tl.gnbs[0].global_bts_id}
# @{cell_list}        1
# ${cell_type}        lte
# ${if_commissioning}    0
# ${site_reset_num}    3
# ${scf_relative_dir}    commissionings/HGZ
# ${if_pdl_check}     True
# @{btslog_dirs}      /tmp/btslog2/
# ${scf_path_trunk}    /home/ute/Downloads/SCF/trunk
# ${scf_path_23R3}    /home/ute/Downloads/SCF/SBTS23R3
# ${scf_path_23R4}    /home/ute/Downloads/SCF/SBTS23R4
# ${paths_file}       /mnt/factory/configs/unit/paths.txt
# 
# *** Test Cases ***
# [1][1.0]CB007499_SR_D_a_L3int_AQHA_01_L3call_1CC_TM3
#     [Tags]     samsung_S20    4G
#     [Setup]    Case Setup 7499
#     Commissioning SCF And Check On Air for Common    scf_path=${scf_path}/case1_scf.xml
#     Simple UE L3 Call And Throughput    dl_tp=130    ul_tp=9
#     [Teardown]    Case 7499 Teardown
# 
# [1][1.0]CB007499_SR_D_b_L3int_AQHA_02_L3call_2CC_TM8
#     [Tags]     samsung_S20    4G
#     [Setup]    Case Setup 7499
#     Commissioning SCF And Check On Air for Common    scf_path=${scf_path}/case2_scf.xml
#     Simple UE L3 Call And Throughput    dl_tp=190    ul_tp=9
#     [Teardown]    Case 7499 Teardown
# 
# [1][1.0]CB007499_SR_D_b_SISO_AQHA_04_Manual_SiSo_SM_BTS_Site_Reset
#     [Tags]     samsung_S20    4G
#     [Setup]    Case Setup 7499
#     Commissioning SCF And Check On Air for Common    scf_path=${scf_path}/case2_scf.xml
#     FOR    ${i}    IN RANGE    ${site_reset_num}
#         Auto_BTS_site_reset
#     END
#    [Teardown]    Case 7499 Teardown
# 
# *** Keywords ***
# Case Setup 7499
#     COAM Create log directory
#     Connect to gnb coam via ssl
#     ${build}    Coam Get Active SW Version
#     ${result}    String.split string    string=${build}    separator=_
#     Run keyword if    'SBTS24R1' in ${result}    set test variable    ${scf_path}    ${scf_path_trunk}
#     ...    ELSE IF    'SBTS23R3' in ${result}    set test variable    ${scf_path}    ${scf_path_23R3}
#     ...    ELSE IF    'SBTS23R4' in ${result}    set test variable    ${scf_path}    ${scf_path_23R4}
#     SBTS Test Setup
#     robot_common_operations.Common Case Setup
#     Add RU file on RU    file_path=${paths_file}   file_content=${PATHS_CONTENT}
#     
# Case 7499 Teardown
#     Delete RU file on RU    file_path=${paths_file}
#     SBTS Test Teardown
#     robot_common_operations.Common Case Teardown
