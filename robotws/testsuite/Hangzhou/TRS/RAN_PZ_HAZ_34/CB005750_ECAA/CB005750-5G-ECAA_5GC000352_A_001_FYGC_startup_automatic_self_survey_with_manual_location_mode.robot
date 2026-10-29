# *** Settings ***
# Force Tags    PY36
# Documentation
# ...   author: zheyuan.chen@nokia-sbell.com
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   Sync
# 
# Suite Setup        robot_common_operations.Common Suite Setup
# Suite Teardown     robot_common_operations.Common Suite Teardown
# 
# Resource         resources/ECAA_comm.robot
# Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource         ../CB005750_EA/Resources/CB005750_common_keyword.robot
# Library          ../CB005750_EA/Resources/5G000313_common_keywords.py
# Variables        ../CB005750_EA/Resources/CB005750_modify_para.py
# Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Variable ***
# @{gnss_mode}              GPS-GLONASS    GPS-Beidou    GPS only    GLONASS only    Beidou only
# ${CURDIR_path}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}
# ${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# 
# *** Test Cases ***
# [1]CB005750-5G-ECAA_5GC000352_A_001_FYGC startup_automatic_self_survey_with_manual_location_mode
#     [Documentation]
#     ...    The purpose of this test is to check the correct FYGC startup in automatic location mode.
#     ...    -03.02.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_TRUNK        CRT_22R2
#     [Setup]    case_setup
#     Change GNSS Operation Mode And Check Sync Stutas for Trunk
#     [Teardown]    case_teardown
# 
# *** Keywords ***
# Get BTS Version And Return Flag
#     [Arguments]     ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    _
#     ${if_21B_flag}    Set Variable if    '@{version_list}[0]'=='SBTS21B'    ${True}    ${False}
#     [Return]    ${if_21B_flag}
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections
# 
# Change GNSS Operation Mode And Check Sync Stutas for ECAA 21B
#     ECAA_comm.Check GNSS Product Name And status    expect_product_name=FYGM
#     ECAA_comm.Change Sync Input Type    DU_IP=${DU_OAM_IP}    BTS_ID=${BTS_ID}    synctype=1pps/ToD from external GNSS receiver
#     FOR    ${item}    IN    @{gnss_mode}
#         Change GNSS Operation Mode    Actual_value=${item}
#         wait until keyword succeeds     20min    1min    ECAA_comm.Check Sync Status    expect_syncInputType=1pps/ToD from external GNSS receiver
#     END
# 
# Change GNSS Operation Mode And Check Sync Stutas for Trunk
#     CB005750_common_keyword.Check GNSS Product Name And status    expect_product_name=FYGM
#     CB005750_common_keyword.Change Sync Input Type    DU_IP=${gnb_ip}    BTS_ID=${BTS_ID}    synctype=1pps/ToD from external GNSS receiver
#     CB005750_common_keyword.Change GNSS Operation Mode And Check Sync Stutas    gnss_mode=${gnss_mode_all}
# 
# case_setup
#     Setup Commission SCF
#     ECAA_comm.Delete TOPP And Change Sync Input Type To GPS    synctype=1pps/ToD from external GNSS receiver
# 
# case_teardown
# #    Change GNSS Operation Mode    Actual_value=GPS-GLONASS
#     Add And Change Sync Input Type To TOPP    synctype1=TOPP    synctype2=1pps/ToD from external GNSS receiver
#     CI_interface.Common Case Teardown
