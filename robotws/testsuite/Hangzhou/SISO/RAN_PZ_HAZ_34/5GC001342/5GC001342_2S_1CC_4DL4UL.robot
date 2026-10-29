# *** Settings ***
# Documentation     author: Chen Yin
# ...               contact: Yin.1.chen@nokia-sbell.com
# ...               squad group: SG_02
# ...               configuration: 2S_1CC_4DL4UL
# Force Tags        5G_SISO    COAM
# ...    PY36
# Suite Setup       Setup enviornment with relevant configuration    scf_path=2S_1CC_4DL4UL.xml     ru_list=0
# Suite Teardown    Run keyword and ignore error    Recover enviornment     scf_path=2S_1CC_2DL2UL.xml
# Resource          Resources/5GC001342_common_keywords.robot
# Resource          ../5GC002029-A/Resources/5GC002029_A_common_keywords.robot
# Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot
# 
# *** Variables ***
# &{fault_61524}             faultId=${61524}    #SSH enabled
# &{fault_61652}             faultId=${61652}    #R&D Service Port enabled
# &{fault_4654}              faultId=${4654}    #Ethernet port security is disabled
# &{fault_4655}              faultId=${4655}    #Service account root access is enabled
# @{allowed_faults}    &{fault_61524}    &{fault_61652}    &{fault_4654}    &{fault_4655}
# ${btslog_path}    /opt/btslog/btslog
# ${btslog_launcher_path}    /opt/btslog/btslog_launcher
# ${btslog_folder}    /tmp/btslog2
# 
# *** Test Cases ***
# [1]General_SiSo_RU_module_reset_from_GUI
#     [Tags]    5GC001342    CIT_22R4
#     [Setup]    Test Case Setup
#     @{use_ru_list}    Create List    1    2
#     Reset RU and Check Status    allowed_faults=${allowed_faults}    ru_list=${use_ru_list}
#     [Teardown]    Test Case Teardown
# 
# [1]General_SiSo_Auto_RF_lock_unlock
#     [Tags]    5GC001342    CIT_TRUNK    CIT_22R3    COAM
#     [Setup]    Test Case Setup
#     @{use_ru_list}    Create List    1    2
#     Lock RU and Check Status    ru_list=${use_ru_list}
#     Unlock RU and Check Status    allowed_faults=${allowed_faults}    ru_list=${use_ru_list}
#     [Teardown]    Test Case Teardown
# 
# [1]General_SiSo_KPI_Cell_lock_unlock_success_rate
#     [Tags]    5GC001342    CIT_TRUNK    CIT_22R3    COAM
#     [Setup]    Test Case Setup
#     @{use_cell_list}    Create List    1    2
#     Lock Cell and Check Status    cell_list=${use_cell_list}
#     Unlock Cell and Check Status    allowed_faults=${allowed_faults}    cell_list=${use_cell_list}
#     @{use_cell_group_list}    Create List    0    1
#     Lock Cell Group and Check Status    cell_group_list=${use_cell_group_list}
#     Unlock Cell Group and Check Status    allowed_faults=${allowed_faults}    cell_group_list=${use_cell_group_list}
#     [Teardown]    Test Case Teardown
# 
# [1][1.0] General_SiSo_CPRI_link_configuration
#     [Tags]    5GC002029-A    0.836    COAM    2    CIT_TRUNK
#     [Setup]    Test Case Setup
#     Perform BTS site reset
#     sleep    1min
#     Wait until keyword succeeds    15 min    20 sec    Connect to Common Unit Master
#     Wait until keyword succeeds    15 min    20 sec    Verify information in startup
#     ...    information=ecpri      verify_information=ecpri
#     COAM Wait for gnb ready and cell setup    timeout=15min
#     [Teardown]    Test Case teardown
# 
# 
# [1][1.0] General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
#     [Setup]    Test Case Setup
#     Connect to Common Unit Master
#     Connect to RU With Allocated IP      ru_index=1
#     COAM verify ru sw version    ru_resource_build_key=LTX_AHQK_E1
#     Connect to RU With Allocated IP      ru_index=2
#     COAM verify ru sw version    ru_resource_build_key=LTX_AHQK_E1
#     [Teardown]    Test Case teardown
# 
# [1][1.0] General_SiSo_LED_states_management_additional_scenarios
#     [Setup]    Test Case Setup
#     COAM Wait for gnb ready and cell setup    timeout=13 min
#     @{module_list}    Create List    SMOD-1    BBMOD-1    RMOD-1      RMOD-2
#     : FOR    ${module}    IN    @{module_list}
#     \    ${module_status}=    Get led status of unit    unit_name=${module}
#     \    Should be equal as strings    ${module_status}    Enabled   msg=${module} current status is ${module_status}    ignore_case=${True}
#     [Teardown]    Test Case Teardown
