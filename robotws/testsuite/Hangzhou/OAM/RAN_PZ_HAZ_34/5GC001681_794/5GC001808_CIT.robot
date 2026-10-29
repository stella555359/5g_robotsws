# *** Settings ***
# Documentation
# ...    author: Han Ruiyu
# ...    contact: ruiyu.han@nokia-sbell.com
# ...    squad group: NSB MN 5G&SC 5G Pz Verf CN 07 SG
# Library    OperatingSystem
# Library   Collections
# Library   String
# Library     libraries${/}snapshot_files.py
# Variables          libraries${/}dcap_server_1.py
# Variables          libraries${/}sherpa_server_1.py
# Library   taf.transport.ssh   WITH NAME   csn
# Resource           resources${/}emil${/}emil.robot
# Resource           resources${/}dcap.robot
# Resource           resources${/}test_port.robot
# Resource  .${/}resources${/}case_steps.robot
# Variables   .${/}..${/}libraries${/}global_vars.py
# Resource   .${/}resources${/}decode.robot
# Resource   .${/}resources${/}tshark.robot
# Resource   .${/}resources${/}sherpa.robot
# Resource   .${/}resources${/}emil${/}emil.robot
# Resource   .${/}resources${/}emil${/}test_emil.robot
# Resource   resources${/}snapshot.robot
# Resource   resources${/}coam.robot
# Resource   resources${/}call.robot
# Resource   resources${/}call.robot
# Variables   libraries${/}parameter_info.py
# Resource   ..${/}common${/}taf_coam.robot
# Library   libraries${/}ui_operation.py
# Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/common.robot
# 
# Force Tags   SG_07   CA_5G_OAM    CIT_TRUNK   master_classicalbts_all   5G_RAN
# ...    PY36
# ...   5G_RAN_TDD   STATE_SW_UPLOADED
# ...   AUTHOR_johnny.1.jiang@nokia-sbell.com   RAN_5G   RAN_5G_TDD   SBTS00
# 
# Suite Setup    Run Keywords   common.Common Setup    AND
# ...  run keyword and ignore error    Load SCF by Feature    2035-G   AND
# ...  run keyword and ignore error    Cplane log Setup    gnb_custom_profile=${gnb_custom_type}
# #Suite Setup      Cplane log Setup
# Suite Teardown    Cplane and Uplane log Teardown
# 
# *** Variables ***
# @{gnb_custom_type}    cp_5g
# 
# *** Test Cases ***
# [1.0] 5GC001808_C_ CP-RT Syscom messages can be activated and deactivated via Emil for Classical_SA BTS
#     [Timeout]    60min
#     [Setup]
#     Check CP-RT Syscom messages    log_path=${output_txt_path}
#     [Teardown]
# 
# [1]5GC001808_E_ L2_Hi_DU share common ID with L2_Hi_CU for Sherpa log
#     [Tags]      AUTHOR_ruiyu.han@nokia-sbell.com
#     [Timeout]    120 min
#     [Setup]
# #        wait until keyword succeeds     3x    20s    Check L2_Hi Ueidcu in Sherpa log    csvname=ControlFlows
#         log to console    pass
#     [Teardown]
# 
# 
# *** Keywords ***
# Check L2_Hi Ueidcu in Sherpa log
#     [Arguments]    ${csvname}
# #    Download Earlist CSV File in TAF    ${csvname}
#     ${row}    wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
#     ...    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str=BearerSetupParam(0x60)
#     ${row_value}   split string from right  ${row}    ;
#     ${ueidcu}    set variable   ${row_value[-7]}
#     ${row_list}    split_rows_as_defined_str    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str1=BearerSetupParam(0x60)
#     ...   str2=(0x83)
#     :FOR   ${row}   IN   @{row_list}
#         ${row_value}   split string from right  ${row}    ;
#         ${passed}  run keyword and return status   should be equal    ${row_value[-7]}    ${ueidcu}
#         Exit For Loop If  ${passed}
#     END
