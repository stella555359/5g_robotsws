# *** Settings ***
# Documentation
# ...  author: Chen Yin 4
# ...  contact: yin.4.chen@nokia-sbell.com
# Library     BuiltIn
# Library     String
# Library     DateTime
# Library     XML    True
# Library     Collections
# Library     OperatingSystem
# Library     Process
# Library     taf.transport.ssh    WITH NAME   csn
# 
# Resource    ../common/taf_coam.robot
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Variables   ../libraries/global_vars.py
# 
# 
# Force Tags   SG_07   CA_5G_OAM   STATE_SW_UPDATED   RAN_5G   RAN_5G_TDD
# ...    PY36
# ...   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIKL_ABILB1_AEQN_NETACT    CRT_UTE   SBTS00
# ...   AUTHOR_yin.4.chen@nokia-sbell.com
# 
# Suite Setup    Common Setup
# Suite Teardown    Common Teardown
# Test Setup   Run Keywords
# ...   robot_common_operations.Common Case Setup   AND
# ...   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# Test Teardown   robot_common_operations.Common Case Teardown
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# # @{cell_list}   MRBTS-10117/NRBTS-10117/NRCELL-1   MRBTS-10117/NRBTS-10117/NRCELL-2   MRBTS-10117/NRBTS-10117/NRCELL-3
# # @{rmod_list}   MRBTS-10117/EQM-1/APEQM-1/RMOD-1   MRBTS-10117/EQM-1/APEQM-1/RMOD-2   MRBTS-10117/EQM-1/APEQM-1/RMOD-3
# 
# *** Test Cases ***
# CB007042-SR-B_03_RF_IQ_data_capture
#     ${file_list}   Launched Script And Check
#     ...   launch_script=RU_Common_capture_IQ_data
#     ...   output_file_name=${OUTPUT_DIR}/RU_Common_capture_IQ_data.zip
#     ...   target_file=SCRIPT_RESULT_IQ_data
#     Should Contain   ${file_list}   IQ_data
# 
# CB007042-SR-B_04_Register_dump_capture
#     ${file_list}   Launched Script And Check
#     ...   launch_script=RU_Common_capture_register_dump
#     ...   output_file_name=${OUTPUT_DIR}/RU_Common_capture_register_dump.zip
#     ...   target_file=SCRIPT_RESULT_register_dump
#     Should Contain   ${file_list}   register_dump
# 
# CB007042-SR-B_05_L1low_dump_capture
#     ${file_list}   Launched Script And Check
#     ...   launch_script=RU_Common_capture_L1low_data
#     ...   output_file_name=${OUTPUT_DIR}/RU_Common_capture_L1low_data.zip
#     ...   target_file=SCRIPT_RESULT_L1low_data
#     Should Contain   ${file_list}   L1low_data
# 
# CB007042-SR-B_01_Running_the_troubleshoting_scripts_via_WebEM
#     Log To Console   Pass This case.
# 
# # CB007042-SR-B_Running_Radio_Module_Troubleshooting_scripts_via_OAM_interface_AEQN
# #     List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
# 
# *** Keywords ***
# Common Setup
#     Log To Console   ${EMPTY}
#     robot_common_operations.Common Suite Setup
#     Set Suite Variable   ${MRBTS_ID}   ${tl.gnbs[0].instance_id}
#     Set Suite Variable   ${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
#     Set Suite Variable   ${MRBTS}   MRBTS-${MRBTS_ID}
#     Set Suite Variable   ${NRBTS}   NRBTS-${NRBTS_ID}
#     Set Suite Variable   ${INSID}   ${MRBTS}/${NRBTS}
#     COAM Login
#     COAM Check BTS OnAir
#     COAM Backup Full SCF
#     Get ALL Suite Variables
# 
# Common Teardown
#     Run Keyword And Ignore Error   COAM Logout
#     robot_common_operations.Common Suite Teardown
# 
# Get ALL Suite Variables
#     Log To Console   Get ALL Suite Variables
#     ${local_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission.xml
#     @{RMOD_LIST}   Create List
#     ${rmods_eles}   Get Elements   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:RMOD"]
#     :FOR   ${rmod_ele}   IN   @{rmods_eles}
#         ${rmod}   Get Element Attribute   ${rmod_ele}   distName
#         Append To List   ${RMOD_LIST}   ${rmod}
#     END
#     Set Suite Variable   ${RMOD_LIST}
# 
#     @{CELL_LIST}   Create List
#     ${cells_eles}   Get Elements   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
#     :FOR   ${cell_ele}   IN   @{cells_eles}
#         ${cell}   Get Element Attribute   ${cell_ele}   distName
#         Append To List   ${CELL_LIST}   ${cell}
#     END
#     Set Suite Variable   ${CELL_LIST}
# 
# Launched Script And Check
#     [Arguments]   ${launch_script}   ${output_file_name}   ${target_file}
#     ...   ${cell_list}=${CELL_LIST}   ${rmod_list}=${RMOD_LIST}   ${free_parameters}=${EMPTY}   ${connection}=COAM   ${timeout}=${1200}
#     ${launch_result}   coam.launch_troubleshooting_script
#     ...   script_name=${launch_script}
#     ...   output_file_name=${output_file_name}
#     ...   cell_list=${cell_list}
#     ...   rmod_list=${rmod_list}
#     ...   free_parameters=${free_parameters}
#     ...   timeout=${timeout}
#     ...   connection=${connection}
#     Should Be Equal   ${launch_result}   Launching succeeded. Snapshot has been successfully created.
#     File Should Exist   ${output_file_name}
#     ${unzip_folder}   Remove String   ${output_file_name}   .zip
#     Run Keyword And Ignore Error   Empty Directory   ${unzip_folder}
#     Run Keyword And Ignore Error   Remove Directory   ${unzip_folder}
#     OperatingSystem.Run   command=unzip ${output_file_name} -d ${unzip_folder}
#     ${file_list}   OperatingSystem.Run   command=cat ${unzip_folder}/snapshot_file_list.txt
#     # Run Process   unzip ${output_file_name} -d ${unzip_folder}   shell=True
#     # ${files}   List Files In Directory   ${unzip_folder}
#     # Should Contain   '${files}'   ${target_file}
#     [Return]   ${file_list}
