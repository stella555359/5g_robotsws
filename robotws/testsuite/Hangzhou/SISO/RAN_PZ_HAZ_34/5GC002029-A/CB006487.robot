# *** Settings ***
# Documentation     author: Chen Yin
# ...               contact: Yin.1.chen@nokia-sbell.com
# ...               squad group: SG_02
# Force Tags        5G_SISO
# ...    PY36
# Suite Setup       Setup enviornment with relevant configuration      scf_path=SCF_1ABIL_6487.xml    ru_list=2
# Suite Teardown    Run keyword and ignore error    Recover configuration with 3ABIL    scf_path=SCF_3ABIL_28.xml
# Resource          Resources/5GC002029_A_common_keywords.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ru_soap_log.robot
# Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot
# 
# 
# *** Variables ***
# ${SCF_1ABIL_36}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/SCF_1ABIL_36.xml
# ${SCF_1ABIL_28}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/SCF_1ABIL_28.xml
# ${SCF_3ABIL_28}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/SCF_3ABIL_28.xml
# ${SCF_1ABIL_35}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/SCF_1ABIL_35.xml
# ${SCF_1ABIL_6487}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/SCF_1ABIL_6487.xml
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
# [1][1.0] General_SiSo_Auto_gNB_Site_Reset_From_WebUI
#     [Tags]    COAM    CIT_22R3      CB006487       CIT_22R2
#     [Setup]    Test Case Setup
#     ${active_fault}    COAM Get active alarms
#     Perform BTS Site Reset
#     COAM Wait for gnb ready and cell setup    timeout=20min
#     Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
#     [Teardown]    Test Case Teardown
# 
# [1][1.0] General_SiSo_Auto_RF_module_reset_from_WebUI
#     [Tags]    COAM    CIT_22R3      CB006487    CIT_22R2
#     [Setup]    Test Case Setup
#     COAM Wait for gnb ready and cell setup
#     @{use_ru_list}    Create List    2     3
#     Reset RU and Check Status    allowed_faults=${allowed_faults}    ru_list=${use_ru_list}
#     [Teardown]    Test Case Teardown
# 
# [2][1.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Tags]    COAM    CIT_22R3      CB006487    CIT_22R2
#     [Setup]    Test Case Setup
#     Connect to Common Unit Master
#     Connect to RU With Allocated IP    ru_index=2     ru_alias=RU_2
#     Verify RFSW Log Include In Snapshot    ru_index=2     ru_alias=RU_2
#     Connect to RU With Allocated IP    ru_index=3     ru_alias=RU_3
#     Verify RFSW Log Include In Snapshot    ru_index=3     ru_alias=RU_3
#     [Teardown]    Test Case Teardown
# 
# [2][1.0] General_SiSo_Cell_lock_and_unlock
#     [Tags]    COAM    CIT_22R3      CB006487    CIT_22R2
#     [Setup]    Test Case Setup
#     @{use_cell_list}    Create List    2      3
#     Lock Cell and Check Status    cell_list=${use_cell_list}
#     Unlock Cell and Check Status    allowed_faults=${allowed_faults}    cell_list=${use_cell_list}
#     @{use_cell_group_list}    Create List    1      2
#     Lock Cell Group and Check Status    cell_group_list=${use_cell_group_list}
#     Unlock Cell Group and Check Status    allowed_faults=${allowed_faults}    cell_group_list=${use_cell_group_list}
#     [Teardown]    Test Case Teardown
# 
# [2][1.0] General_SiSo_RU_lock_unlock
#     [Tags]    COAM    CIT_22R3      CB006487    CIT_22R2
#     [Setup]    Test Case Setup
#     COAM Wait for gnb ready and cell setup
#     @{use_ru_list}    Create List    2      3
#     Lock RU and Check Status    ru_list=${use_ru_list}
#     Unlock RU and Check Status    allowed_faults=${allowed_faults}    ru_list=${use_ru_list}
#     [Teardown]    Test Case Teardown
# 
# [1]General_SiSo_Commissioning_BTS_Template_Commissioning
#     [Tags]    COAM    CIT_22R3      CB006487    CIT_22R2
#     [Setup]    Test Case Setup
#     ${current_scf}=    Get Current SCF file    dir=${log_path}
#     Run keyword and ignore error    COAM Commission with scf file    scf_file_path=${current_scf}    timeout=600
#     COAM Wait for gnb ready and cell setup    timeout=15min
#     [Teardown]    Test Case Teardown
# 
# 
# *** Keywords ***
# Recover configuration with 3ABIL
#     [Arguments]   ${scf_path}
#     ...    ${cur_relative_dir}=testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002029-A
#     robot_common_operations.Common Case Teardown
#     ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
#     @{all_ru_list}    Create List    1    2    3
#     FOR    ${r_list}    IN    @{all_ru_list}
#          Perform RU Power On    ru_index=${r_list}
#          ...    model=${tl.gnbs[${0}].dus[${0}].rus[${r_list}-1].pdu_port.pdu.__class__.__name__}
#     END
#     Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
#     Commissioning with Template Commission      scf_file=${scf_base_path}/${testline_name}/${scf_path}
# 
# Setup enviornment with relevant configuration
#     [Arguments]   ${scf_path}    ${ru_list}
#     ...    ${cur_relative_dir}=testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002029-A
#     robot_common_operations.Common Case Setup
#     Connect to gnb coam via ssl
#     ${exist_fault}    COAM Get active alarms
#     ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
#     @{all_ru_list}    Create List    1    2    3
#     FOR    ${r_list}    IN    @{all_ru_list}
#          Perform RU Power On    ru_index=${r_list}
#          ...    model=${tl.gnbs[${0}].dus[${0}].rus[${r_list}-1].pdu_port.pdu.__class__.__name__}
#     END
#     @{use_ru_list}    Run keyword If    ${ru_list}==1    Create List    2    3
#                      ...     ELSE     Create List    1
#     FOR    ${r_list}    IN    @{use_ru_list}
#          Perform RU Power Off    ru_index=${r_list}
#          ...    model=${tl.gnbs[${0}].dus[${0}].rus[${r_list}-1].pdu_port.pdu.__class__.__name__}
#     END
#     Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
#     Commissioning with Template Commission      scf_file=${scf_base_path}/${testline_name}/${scf_path}