# *** Settings ***
# Documentation
# 
# ...    This test suite is to cover SFP and QSFP monitoring that is mainly used for troubleshooting purposes or on new
# ...    instalation in case of SFP/QSFP optical interface problem between (a) Radio Units and BB capacity
# ...    (b) CU & DU (c) Radio Units. The diagnostics information gives a very good indication of the fibre link
# ...    quality between (a) radio and RAU (b) CU & DU. Supports all types of: SFP/SFP+/SFP28/QSFP used by Nokia.
# ...    Current version of test suite:
# ...    Author: Szymon Skorupski
# ...    Contact: szymon.skorupski@nokia.com
# ...    Original version of test cases:
# ...    Authors: Kamil Ostrzolek, Kinga Starczan, Aleksandra Radziejewska
# ...    Contact: kamil.ostrzolek@nokia.com, kinga.starczan@nokia.com, aleksandra.radziejewska@nokia.com
# 
# Library    BuiltIn
# Library    OperatingSystem
# Library    Collections
# Library    DateTime
# Library    XML    use_lxml=True
# Library    taf.sbts.oam.coam.admin   WITH NAME   admin
# Library    taf.transport.ssh    WITH NAME    ssh
# Library    taf.ul.oam.netact.cm    WITH NAME    netact_lib
# 
# Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC002550/resources/keywords.robot
# 
# 
# 
# 
# Force Tags    CRT_22R4    CRT_22R2    CRT_UTE    RAN_5G    RAN_5G_TDD
# ...    PY36
# ...    CLOUD_5G_CLASSICAL_ANDROID_ASILR_ABILB4_AEWD    STATE_SW_UPLOADED    SBTS00
# 
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    Run Keywords    Preconditions
# ...    AND     robot_common_operations.Common Suite Setup
# 
# 
# Suite Teardown  Run Keywords    Postconditions
# ...    AND      robot_common_operations.Common Suite Teardown
# Test Setup        Run Keywords    Start Btslog With Path Check
# ...    AND     robot_common_operations.Common Case Setup
# Test Teardown    robot_common_operations.Common Case Teardown
# 
# 
# 
# 
# *** Test Cases ***
# [1][1.0] 5GC002181-D-j-Retrieve_periodic_SFP_QSFP_Snapshot_data
#     [Teardown]    Run Keywords  Collect logs after test  5GC002181-D-j-Retrieve_periodic_SFP_QSFP_Snapshot_data
#     ...  AND  Run Keyword If Test Passed  Remove Directory    ${unzipped}    recursive=True
#     Wait Until Keyword Succeeds    40x    120s    keywords.Check quantity of RD files on BTS
#     ${parsed_files}=    keywords.Get snapshot and return parsed RD files
#     ${BBMOD_SFP_dict}=    Get BBMODs info
#     Set test variable    ${measurementType}    SFPBM
#     keywords.Check counters from SFP monitoring- file iteration    ${parsed_files}    ${BBMOD_SFP_dict}
#     ...    ${measurementType}
#     ${RMOD_SFP_dict}=    keywords.Get RMODs info
#     Set test variable    ${measurementType}    SFPRM
#     keywords.Check counters from SFP monitoring- file iteration    ${parsed_files}    ${RMOD_SFP_dict}
#     ...    ${measurementType}
# 
# 
# [1][1.0] 5GC002181-D-a-Initiate_SFP_Monitoring_from_WebEM_for_ASIx(dynamic_data)
#     [Teardown]     Collect logs after test    5GC002181-D-a-Initiate_SFP_Monitoring_from_WebEM_for_ASIx(dynamic_data)
#     Wait until keyword succeeds    3x    120s
#     ...    Initiate_SFP_QSFP_monitoring(invocation_of_the_diagnostic)_for_CPRI-N_SMOD(dynamic_data)
# 
# [1][1.0] 5GC002181-D-a-Initiate_SFP_Monitoring_from_WemEM_for_ASIx(static_data-Temperature_parameters)
#     [Teardown]  Collect logs after test
#     ...  5GC002181-D-a-Initiate_SFP_Monitoring_from_WemEM_for_ASIx(static_data-Temperature_parameters)
#     ${links}    ${SMOD}=    Get SMOD SFP links
#     Check if temperature parameters have a valid value for ports for SMOD   ${links}    ${SMOD}
# 
# [1][1.0] 5GC002181-D-a-Initiate_SFP_Monitoring_from_WemEM_for_ASIx(static_data-Tx_parameters)
#     [Teardown]    Collect logs after test
#     ...  5GC002181-D-a-Initiate_SFP_Monitoring_from_WemEM_for_ASIx(static_data-Tx_parameters)
#     ${links}    ${SMOD}=    Get SMOD SFP links
#     Check if Tx parameters have a valid value for ports for SMOD  ${links}    ${SMOD}
# 
# [1][1.0] 5GC002181-D-a-Initiate_SFP_Monitoring_from_WebEM_for_ASIx(static_data- Rx_parameters)
#     [Teardown]    Collect logs after test
#     ...  5GC002181-D-a-Initiate_SFP_Monitoring_from_WebEM_for_ASIx(static_data- Rx_parameters)
#     ${links}    ${SMOD}=    Get SMOD SFP links
#     Check if static parameters have a valid value for ports for SMOD   ${links}    ${SMOD}
# 
# [1][1.0] 5GC002181-D-a-Initiate_SFP_Monitoring_from_WemEM_for_ASIx(static_data-SFP_parameters)
#     [Teardown]    Collect logs after test
#     ...  5GC002181-D-a-Initiate_SFP_Monitoring_from_WemEM_for_ASIx(static_data-SFP_parameters)
#     ${links}    ${SMOD}=    Get SMOD SFP links
#     keywords.Check if static data SFP QSFP have a valid value for ports for SMOD   ${links}    ${SMOD}
