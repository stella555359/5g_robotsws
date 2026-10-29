# *** Settings ***
# Suite Setup          Dedicate_Suite_Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# 
# #Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/Rjio_HAZ3_SG2/Resources/made_variable.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
# 
# Force Tags
# 
# *** Variables ***
# #${if_commissioning}    False
# ${loop_times}    2
# 
# *** Test Cases ***
# [1]Rjio_AQQJ_9_IQdata_Collection_CPRI_eCPRI
#     [Documentation]
#     ...    The purpose of this test is to selenium login and logout, 
#     ...    configuration not related to synchronization, transport and U-plane.
#     [Tags]
#     FOR   ${index}   IN RANGE   ${loop_times}
#         Rjjo_Catch_IQ_Data_ASOE
#     END
# 
# *** Keywords ***
# Dedicate_Suite_Setup
#     Import Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/TLData/${testline_name}/TLConfiguration.py
#     SISO Coam Suite Setup
# 
# Rjjo_Catch_IQ_Data_ASOE
#     log to console   ***Get PCI ID***
#     @{split_version}    string.split string    ${Active_SW_version}    separator=_
#     ${stream}    set variable     @{split_version}[0]
#     Selenium Login And Disable Screen Lock    version=${stream}
#     Close Start Up View    timeout=60
#     Get PCI id list and capture IQ data
#     log to console   ***start catch on WebEM***
#     [Teardown]    run keywords    Selenium Logout And Close Browser
# 
# Get PCI id list and capture IQ data
#     @{PCI_id_list}    Get All Cell Id
#     FOR    ${cell}    in    @{PCI_id_list}
#         ${PCI_ID}   selenium_coam.get_parameter_value   dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell}
#         ...   filter_param=Physical cell identifier
#         ${cell_remainder}    Evaluate    ${cell}%10
#         ${ul_subcell_index_list}=    Create List    [SMOD_R-1(ASOE)] [PCI: ${PCI_ID}][Cell${cell}]NRCELL-${cell}: Subcell ${cell_remainder}
#         ${dl_subcell_index_list}=    Create List    [SMOD_R-1(ASOE)] [PCI: ${PCI_ID}][Cell${cell}]NRCELL-${cell}: Subcell ${cell_remainder}
#         Run Keyword And Continue On Failure    selenium_coam.configure_iq_capture
# #        ...    bbmod=SMOD_R-1(ASOE)
#         ...    ul_subcell_index_list=${ul_subcell_index_list}
#         ...    dl_subcell_index_list=${dl_subcell_index_list}
#         ...    enable_capture_on_event=true
#         sleep    30s
#         Save IQ capture data
#         sleep    30s
#     END
# 
# Save IQ capture data
#     selenium_coam.save_iq_capture
# #    ...    bbmod=SMOD_R-1(ASOE)
#     ...    sfn_value=${65535}
#     ...    slot_value=${0}
#     ...    capture_mode=Schedule synchronous stop of ongoing continuous capture
# 
#  
