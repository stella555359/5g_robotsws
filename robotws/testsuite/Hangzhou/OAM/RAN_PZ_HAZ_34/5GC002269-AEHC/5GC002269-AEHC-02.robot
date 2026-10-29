# *** Settings ***
# Force Tags    PY36
# Documentation     author: Na Li
# ...               contact: na.li@nokia-sbell.com
# ...               squad group: MMW_SG_04
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          ./Resource/5GC002269_common_keywords.robot
# 
# *** Variables ***
# ${default_scf}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/DU_SCF.xml
# 
# *** Test Cases ***
# [1] 5GC002269-AEQE_2_RMOD_Hot_swap_with_the_same_type_remove
#     [Tags]        5GC002269    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2
#     [Setup]
#     update default scf
#     Check BTS is in On Air
#     Lock Ru and check Status
#     FOR   ${n}    IN RANGE    ${2}
#         ${cross_port_setting}    Create Dictionary    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[${n}].switch_module.module_no}=0
#         Switch fiber channels and verify fiber channels status      cross_connection_setting=${cross_port_setting}
#     END
#     sleep    2min
#     get fault10
#     [Teardown]    Case Teardown
# 
# *** Keywords ***
# update default scf
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    scf_file_path=${default_scf}    is_pdl_checking_needed=${False}
#     [Teardown]    COAM Teardown gnb connections
# 
# Case Teardown
#     FOR   ${n}    IN RANGE    ${2}
#         ${enableport}    set variable    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[${n}].switch_module.module_no}
#         ${cross_port_setting}    Create Dictionary    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[${n}].switch_mo
# ...dule.module_no}=${enableport}
#         Switch fiber channels and verify fiber channels status      cross_connection_setting=${cross_port_setting}
#     END
#     sleep    10min
#     Connect to DU    alias=cOAM_admin
#     Wait Until Keyword Succeeds   3 min  30 sec    RU Should Be Locked    connection=cOAM_admin
#     Perform RU unlock via rest api    connection=cOAM_admin
#     Wait Until Keyword Succeeds   3 min  5 sec    ADMIN Wait Until BTS OnAir
#     Disconnect from DU    alias=cOAM_admin
#     CI_interface.Common Case Teardown
# 
# Lock Ru and check Status
#     [Arguments]      ${connection}=cOAM_admin
#     Connect to DU
#     Perform RU lock via rest api     connection=${connection}
#     RU Should Be Locked     connection=${connection}
#     Wait Until Keyword Succeeds   1 min  5 sec   check Cell status after Locked    connection=${connection}
#    # ...    cell_idx=0   cell_group_idx=0    operationalState=Disabled
#    # ...    availabilityStatus=Dependency   administrativeState=Unlocked   connection=${connection}
#     [Teardown]    Disconnect from DU
# 
# get fault10
#     Connect to DU
#     ${fault_name_list}     ${faultlist1}    Get Alarm Info     timeout=1
#     Run Keyword And Continue On Failure    list should contain value    ${faultlist1}    ${10}
#     [Teardown]    Disconnect from DU
# 
# Check BTS is in On Air
#     Connect to DU
#     ADMIN Wait Until BTS OnAir
#     [Teardown]    Disconnect from DU
# 
# check Cell status after Locked
#     [Arguments]    ${cells_info}=${0}    ${connection}=cOAM_admin
#     Log to console    Verify all cells are on air
#     ${sw_version}     coam.get_sw_version    connection=${connection}
#     ${result}    run keyword and return status    should contain any
#     ...    ${sw_version}
#     ...    12.400    14.400    22R1    22R2    21B
#     ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
#     ${disabled}    Set Variable If    ${result}    Disabled    disabled
#     ${cells_info}   coam.get_cells_info   timeout=20    connection=${connection}
#     FOR    ${cell}    IN    @{cells_info}
#         Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}     ${unlocked}
#         Run keyword and continue on failure    Should be equal as strings    ${cell['status']['operationalState']}    ${disabled}
#     END
