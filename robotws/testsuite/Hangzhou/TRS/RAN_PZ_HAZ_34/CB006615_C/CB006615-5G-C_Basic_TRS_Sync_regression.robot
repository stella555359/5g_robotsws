# *** Settings ***
# Force Tags    PY36
# Documentation
# ...   author: zheyuan.chen@nokia-sbell.com
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   Dual Core TRS-Sync
# 
# Suite Setup    suite_setup
# 
# Resource    ../CB007310_C/resources/CB007310_common_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# 
# *** Variable ***
# @{expect_detail_list1}    37    True    True    False    False    10.97.126.186    True    1    100    20    True    21
# ...    6    00:B0:AE:01:FF:FE:90:E6    6400    00:B0:AE:01:FF:FE:90:E6    MASTER_CLOCK_OK    1    used    1    None
# @{expect_detail_list2}    37    None    None    None    None    10.97.126.186    None    None    None    None    None    None    None
# ...     None    None    None     MASTER_CLOCK_DISABLED    1   not used    None    None
# @{cell_info_6615}    ${0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}
# ${TOPMASTERIP_TT}    10.97.126.186
# ${TOP_DN_6615}
# ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/MNL_CONF_M-1/MNLENT_CONF_M-1/SYNC_CONF_M-1/CLOCK_CONF_M-1/TOP_CONF_M-1/TOPP_CONF_M-1/TOPP_R-1
# 
# *** Test Cases ***
# [1]CB006615-C_01-SyVe_FYGM_startup_automatic_self-survey_with_automatic_location_mode
#     [Documentation]
#     ...    The purpose of this test is to check the correct FYGM startup in automatic location mode.
#     ...    -13.08.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CB006615
#     [Setup]    case1_setup
#     Check BTS Should Be Normal    all_cell_info=@{cell_info_6615}
#     Check GNSS Product Name And status_trunk    expect_product_name=FYGM
#     Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype=1pps/ToD from external GNSS receiver
#     Change GNSS Operation Mode And Check Sync Stutas    beidou_value=true    glonass_value=false    gps_value=true
#     ...    expect_Beidou_usage=Yes    expect_Glonass_usage=No    expect_Gps_usage=Yes
#     Change GNSS Operation Mode And Check Sync Stutas   beidou_value=false    glonass_value=false    gps_value=true
#     ...    expect_Beidou_usage=No    expect_Glonass_usage=No    expect_Gps_usage=Yes
# #    Change GNSS Operation Mode And Check Sync Stutas    beidou_value=false    glonass_value=true    gps_value=false
# #    ...    expect_Beidou_usage=No    expect_Glonass_usage=Yes    expect_Gps_usage=No
# #    Change GNSS Operation Mode And Check Sync Stutas   beidou_value=true    glonass_value=false    gps_value=false
# #    ...    expect_Beidou_usage=Yes    expect_Glonass_usage=No    expect_Gps_usage=No
# #    Change GNSS Operation Mode And Check Sync Stutas   beidou_value=false    glonass_value=true    gps_value=true
# #    ...    expect_Beidou_usage=No    expect_Glonass_usage=Yes    expect_Gps_usage=Yes
# #    [Teardown]    case1_teardown
# 
# #[1]CB006615-C_03-SyVe -ToP_Phase_Sync_TOP_Detailed_Info
# #    [Documentation]
# #    ...    The purpose of this test case is to verify DU synchronization mode configuration and sync source switching function.
# #    ...    -13.08.2021,zheyuan.chen@nokia-sbell.com,case draft
# #    [Tags]    CRT_22R1    CB006615
# #    [Setup]    case2_setup
# #    Check BTS Should Be Normal    all_cell_info=@{cell_info_6615}
# #    run keyword and ignore error    Check Sync Status And Web Detail    expect_isActive=${True}
# #    ...    expect_availability=Available    expect_usability=Usable    expect_detail_list=@{expect_detail_list1}
# #    Change Top Domain Number    Domain_value=5
# #    wait until keyword succeeds    5min    15s    Check Alarm FaultID Contain Expect_alarm    expect_fault_id=${4298}
# #    run keyword and ignore error    Check Sync Status And Web Detail    expect_isActive=${False}
# #    ...    expect_availability=Unavailable    expect_usability=Unusable    expect_detail_list=@{expect_detail_list2}
# #    ...    expect_tuningMode=Adaptive holdover
# #    Change Top Domain Number    Domain_value=0
# #    wait until keyword succeeds    5min    15s    Check Alarm FaultID Not Contain Expect_alarm    expect_fault_id=${4298}
# #    run keyword and ignore error    Check Sync Status And Web Detail    expect_isActive=${True}
# #    ...    expect_availability=Available    expect_usability=Usable    expect_detail_list=@{expect_detail_list1}
# #    Change Secondary SMOD Sync    command=ddal -s ddal_clk_io_configure_output_signal 1 DDAL_CLK_IO_SIGNAL_GND DDAL_CLK_IO_PORT_BP_PPS
# #    wait until keyword succeeds    15min    20s    Check Alarm FaultID Contain Expect_alarm    expect_fault_id=${4385}
# #    Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${False}
# #    ...    expect_availability=Unavailable    expect_usability=Unusable    expect_tuningMode=Adaptive holdover
# #    Change Secondary SMOD Sync    command=ddal -s ddal_clk_io_configure_output_signal 1 DDAL_CLK_IO_SIGNAL_PPS_INTERNAL DDAL_CLK_IO_PORT_BP_PPS
# #    wait until keyword succeeds    15min    20s    Check Alarm FaultID Not Contain Expect_alarm    expect_fault_id=${4385}
# #    Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
# #    ...    expect_availability=Available    expect_usability=Usable
# #    [Teardown]    case2_teardown
# 
# [1]CB006615-C_04-Synchronization_Mode_ReferenceSource_Switching
#     [Documentation]
#     ...    The purpose of this test case is to verify DU synchronization mode configuration and sync source switching function.
#     ...    -13.08.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CB006615
#     [Setup]    case3_setup
#     Check BTS Should Be Normal    all_cell_info=@{cell_info_6615}
#     Start Catch BTS Log
#     Disconnect Sync Connector Less Than 5s    TOPMASTERIP=${TOPMASTERIP_TT}
#     Stop Catch BTS Log And Check Log
#     Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
#     ...    expect_availability=Available    expect_usability=Usable
#     Change Top Domain Number    Domain_value=5
#     Check Both Primary Sync Status    TOPP_isActive=${False}    TOPP_Availability=Unavailable    TOPP_Usability=Unusable
#     ...    GNSS_isActive=${True}
#     wait until keyword succeeds    10min    20s    Check Alarm FaultID Contain Expect_alarm    expect_fault_id=${4298}
#     Start Catch BTS Log And Check Log
#     Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
#     ...    expect_availability=Available    expect_usability=Usable
#     Change Top Domain Number    Domain_value=0
#     wait until keyword succeeds    10min    20s    Check Alarm FaultID Not Contain Expect_alarm    expect_fault_id=${4298}
#     Start Catch BTS Log
#     Check Both Primary Sync Status    TOPP_isActive=${True}    TOPP_Availability=Available    TOPP_Usability=Usable
#     ...    GNSS_isActive=${False}
#     Stop Catch BTS Log And Check Log
#     Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
#     ...    expect_availability=Available    expect_usability=Usable
#     [Teardown]    run keyword and ignore error    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Change GNSS Operation Mode And Check Sync Stutas
#     [Arguments]    ${beidou_value}=false    ${glonass_value}=true    ${gps_value}=true
#     ...    ${expect_Beidou_usage}=No    ${expect_Glonass_usage}=Yes    ${expect_Gps_usage}=Yes
#     Change_GNSS_Mode_TRUNK    beidou_value=${beidou_value}    glonass_value=${glonass_value}    gps_value=${gps_value}
#     wait until keyword succeeds     20min    1min    Check Sync Status    target=primary
#     ...    expect_syncInputType=1pps/ToD from external GNSS receiver     expect_isActive=${True}
#     Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane    expect_isActive=${True}
#     ...    expect_availability=Available    expect_usability=Usable
#     Check GNSS Mode_trunk    expect_Beidou_usage=${expect_Beidou_usage}    expect_Glonass_usage=${expect_Glonass_usage}
#     ...    expect_Gps_usage=${expect_Gps_usage}
# 
# Check Sync Status And Web Detail
#     [Arguments]    ${expect_isActive}    ${expect_availability}    ${expect_usability}    ${expect_detail_list}
#     ...    ${expect_tuningMode}=Normal tuning    ${expect_isActive2}=${True}
#     wait until keyword succeeds    5min    20s    Check Sync Status    target=primary    expect_syncInputType=TOPP
#     ...    expect_isActive=${expect_isActive}    expect_availability=${expect_availability}    expect_usability=${expect_usability}
#     ...    expect_tuningMode=${expect_tuningMode}
#     Check Web TOP Synchronization Detail    expect_detail_list=${expect_detail_list}    TOP_DN=${TOP_DN_6615}
#     run keyword and continue on failure    Check Top PortNumber    brnumber=br1    TOP_DN=${TOP_DN_6615}
#     Check Sync Status    target=secondary    expect_syncInputType=1pps/ToD from backplane
#     ...    expect_isActive=${expect_isActive2}    expect_availability=Available    expect_usability=Usable
# 
# Stop Catch BTS Log And Check Log
#     Stop and collect btslog on local machine
#     Check Phase Error
# 
# Start Catch BTS Log And Check Log
#     Start Catch BTS Log
#     sleep    40s
#     Stop and collect btslog on local machine
#     Check ESelectedClockSource Phase Error
# 
# Check Alarm FaultID Contain Expect_alarm
#     [Arguments]    ${expect_fault_id}
#     Log To Console    Check Alarm FaultID Contain Expect_alarm
#     ${fault_id_list}    Get BTS Alarm FaultID
#     list should contain value    ${fault_id_list}    ${expect_fault_id}
# 
# Check Alarm FaultID Not Contain Expect_alarm
#     [Arguments]    ${expect_fault_id}
#     Log To Console    Check Alarm FaultID Not Contain Expect_alarm
#     ${fault_id_list}    Get BTS Alarm FaultID
#     list should not contain value    ${fault_id_list}    ${expect_fault_id}
# 
# Check Both Primary Sync Status
#     [Arguments]    ${TOPP_isActive}    ${TOPP_Availability}    ${TOPP_Usability}    ${GNSS_isActive}
#     Check Sync Status    target=primary    expect_syncInputType=TOPP    expect_isActive=${TOPP_isActive}
#     ...    expect_availability=${TOPP_Availability}    expect_usability=${TOPP_Usability}
#     Check Sync Status    target=primary    expect_syncInputType=1pps/ToD from external GNSS receiver
#     ...    expect_isActive=${GNSS_isActive}    index=${1}
# 
# case1_setup
#     Delete Structure2 And Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype=1pps/ToD from external GNSS receiver
# 
# case1_teardown
#     Add Structure2 And Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype1=1pps/ToD from external GNSS receiver    synctype2=TOPP
#     run keyword and ignore error    CI_interface.Common Case Teardown
# 
# case2_setup
#     Delete Structure2 And Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype=TOPP
# 
# case2_teardown
#     Add Structure2 And Change Sync Input Type    expect_SMOD=SMOD_A-1    synctype1=1pps/ToD from external GNSS receiver    synctype2=TOPP
#     run keyword and ignore error    CI_interface.Common Case Teardown
# 
# case3_setup
#     Change Two Sync Input Type    expect_SMOD=SMOD_A-1    synctype1=TOPP    synctype2=1pps/ToD from external GNSS receiver
# 
# suite_setup
#     ${default_scf}    suite setup to prepare default scf    SBTS_scf_name=SCF_SBTS00_7876A.xml    22R1_scf_name=SCF_SBTS22R1_7876A.xml
#     ...    22R2_scf_name=SCF_SBTS22R2_7876A.xml
#     Commission Default SCF    default_scf=${default_scf}
#     Check BTS Should Be Normal    all_cell_info=@{cell_info_6615}
# 
# suite setup to prepare default scf
#     [Arguments]    ${SBTS_scf_name}    ${22R1_scf_name}    ${22R2_scf_name}
#     Log To Console    Set Default Scf
#     Connect to gnb coam via ssl
#     ${version}    coam.get_sw_version    connection=GNB_OAM
#     ${version_list}    split string    ${version}    _
#     ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
#     ${if_22R1_load}    run keyword and return status    should contain    ${version_list[0]}    SBTS22R1
#     ${if_22R2_load}    run keyword and return status    should contain    ${version_list[0]}    SBTS22R2
#     ${default_scf}    set variable if    ${if_common_load}    ${default_scf_path}${SBTS_scf_name}
#     ...    ${if_22R1_load}    ${default_scf_path}${22R1_scf_name}
#     ...    ${if_22R2_load}    ${default_scf_path}${22R2_scf_name}
#     log to console   ${default_scf}
#     [Teardown]    Run keyword and ignore error    coam.teardown      connection=GNB_OAM
#     [Return]    ${default_scf}
# 
# Commission Default SCF
#     [Arguments]    ${default_scf}
#     Log To Console    Commission Default SCF
#     ${connection}    Rest Login DU    ip_address=${DU_OAM_IP}
#     COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
#     [Teardown]    Rest Logout DU
