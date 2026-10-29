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
# 
# 
# Force Tags
# 
# *** Variables ***
# # ${if_commissioning}    False
# ${loop_times}    2
# 
# *** Test Cases ***
# [1]Rjio_AQQJ_9_IQdata_Collection_CPRI_eCPRI
#     [Documentation]
#     ...    The purpose of this test is to selenium login and logout, 
#     ...    configuration not related to synchronization, transport and U-plane.
#     [Tags]
#     @{split_version}    string.split string    ${Active_SW_version}    separator=_
#     ${stream}    set variable     @{split_version}[0]
#     Selenium Login And Disable Screen Lock    version=${stream}
#     Close Start Up View    timeout=60
#     log to console   ***Get PCI ID***
#     Get PCI id
#     log to console   ***IQ capture config***
#     Run Keyword And Continue On Failure    IQ capture config
#     sleep    30s
#     FOR   ${index}   IN RANGE   ${loop_times}
#         log to console   ***start catch on WebEM***
#         Wait Until Keyword Succeeds    5min    5s    Save IQ capture data
#         sleep    90s
#     END
#     [Teardown]    run keywords    selenium logout and close browser    AND    SISO Coam Test Teardown
# 
# *** Keywords ***
# Dedicate_Suite_Setup
#     Import Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/TLData/${testline_name}/TLConfiguration.py
#     SISO Coam Suite Setup
# 
# IQ capture config
#     ${ul_subcell_index_list}=    Create List    [PCI: ${PCI_ID}][Cell1]NRCELL-1: Subcell 0
#     ${dl_subcell_index_list}=    Create List    [PCI: ${PCI_ID}][Cell1]NRCELL-1: Subcell 0
#     selenium_coam.configure_iq_capture
#     ...    bbmod=SMOD_R-1(ASOE)
#     ...    ul_subcell_index_list=${ul_subcell_index_list}
#     ...    dl_subcell_index_list=${dl_subcell_index_list}
#     ...    enable_capture_on_event=true
# 
# Save IQ capture data
#     selenium_coam.save_iq_capture
#     ...    bbmod=SMOD_R-1(ASOE)
#     ...    sfn_value=${0}
#     ...    slot_value=${1}
#     ...    capture_mode=Schedule synchronous stop of ongoing continuous capture
# 
# Get PCI id
#     ${PCI_ID}   selenium_coam.get_parameter_value   dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
#     ...   filter_param=Physical cell identifier
#     set suite variable    ${PCI_ID}
