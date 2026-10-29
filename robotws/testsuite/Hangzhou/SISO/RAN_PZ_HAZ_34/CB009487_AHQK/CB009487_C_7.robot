# *** Settings ***
# Documentation     author: Chen Yin
# ...               contact: Yin.1.chen@nokia-sbell.com
# ...               squad group: SG_02
# Force Tags        5G_SISO
# ...    PY36
# Suite Setup       Setup enviornment with relevant configuration      scf_path=9487_C_07.xml
# Resource          Resources/CB009487_common_resource.robot
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
# [1][1.0] General_SiSo_Auto_RF_module_power_reset
#     [Setup]    Test Case Setup
#     @{ru_list}=       Get Current RU Number
#     Power reset RU and Check Status    ru_list=${ru_list}
# 
# [1][1.0] General_SiSo_RF_module_IP_address_allocation
#     [Setup]    Test Case Setup
#     @{use_ru_list}=        Get Current RU Number
#     Connect to Common Unit Master
#     FOR       ${ru_index}      IN      @{use_ru_list}
#         Connect to RU With Allocated IP    ru_index=${ru_index}     ru_alias=RU_${ru_index}
#     END
#     [Teardown]    Test Case Teardown
# 
# [1][1.0] General_SiSo_Cell_lock_and_unlock
#     [Setup]    Test Case Setup
#     ${alarms}    Get Allowed Faults
#     @{use_cell_list}    Create List    1
#     Lock Cell and Check Status    cell_list=${use_cell_list}      gnb_type=SA
#     Unlock Cell and Check Status    allowed_faults=${allowed_faults}    cell_list=${use_cell_list}
#     @{use_cell_group_list}    Create List    0
#     Lock Cell Group and Check Status    cell_group_list=${use_cell_group_list}      gnb_type=SA
#     Unlock Cell Group and Check Status    allowed_faults=${allowed_faults}    cell_group_list=${use_cell_group_list}
#     [Teardown]    Test Case Teardown
