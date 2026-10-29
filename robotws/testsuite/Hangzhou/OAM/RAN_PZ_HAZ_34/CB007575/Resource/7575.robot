*** Settings ***
Documentation
...  author: Lin Zhe
...  contact: zhe.1.lin@nokia-sbell.com

Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Resource    ../../UUF/Resource/common.robot
Library     ../../libraries/nms_vars.py
Resource    ../../5GI000114/Resource/NetAct_common.robot
Resource    ../../5GC001756/Resource/NetAct.robot

*** Variables ***
${NA_EXPORT_DIR}=           /var/opt/oss/global/racops/export
${NA_IMPORT_DIR}=           /var/opt/oss/global/racops/import
${LOCAL_TMP_DIR}=           /tmp
${VALIDATION}=              True

*** Keywords ***
Modify ClimateControlProfiling
    [Arguments]    ${new_profile}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...    filter_param=Climate control profiling    new_value=${new_profile}
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=${true}   execute=${true}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-2
    ...    filter_param=Climate control profiling    new_value=${new_profile}
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=${true}   execute=${true}

Fan Speed Calculation
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK
    ${LFan_Speed}   csn.Execute   command=tail /dev/ddal/fan/0/rpm    connection=ASIK
    ${LFan_value}    Strip String    ${LFan_Speed}    characters=\r\n
    Log to console    Optimized Cooling mode Left fan speed is ${LFan_value}
    ${RFan_Speed}   csn.Execute   command=tail /dev/ddal/fan/1/rpm    connection=ASIK
    ${RFan_value}    Strip String    ${RFan_Speed}    characters=\r\n
    Log to console    Optimized Cooling mode Reft fan speed is ${RFan_value}
    Modify ClimateControlProfiling    new_profile=Low Noise
    Sleep   3min
    ${LFan_LowSpeed}   csn.Execute   command=tail /dev/ddal/fan/0/rpm    connection=ASIK
    ${LFan_Lvalue}    Strip String    ${LFan_LowSpeed}    characters=\r\n
    Log to console    Low Noise mode Left fan low speed is ${LFan_Lvalue}
    ${RFan_LowSpeed}   csn.Execute   command=tail /dev/ddal/fan/1/rpm    connection=ASIK
    ${RFan_Lvalue}    Strip String    ${RFan_LowSpeed}    characters=\r\n
    Log to console    Low Noise mode Reft fan low speed is ${RFan_Lvalue}
    ${LFan}    Evaluate    ${LFan_value} - ${LFan_Lvalue}
    Log to console    Left fan difference is ${LFan}
    ${RFan}    Evaluate    ${RFan_value} - ${RFan_Lvalue}
    Log to console    Right fan difference is ${RFan}
    Should be true    ${LFan} > 0
    Should be true    ${RFan} > 0
    Modify ClimateControlProfiling    new_profile=Optimized Cooling


Expand Actual Configuration And Click Tree Node for Subrack
    Select Main Window
    ${TREE_PATH}    CM Get Tree Path For 1756   tree_name=navigationTree   tree_path_header=Actual Configuration|PLMN-PLMN
    Set Test Variable   ${TREE_PATH}
    Log To Console   ${TREE_PATH}
    # Set Test Variable   ${TREE_PATH}   Actual Configuration|PLMN-PLMN|${MO_NAME} ${MO_NAME}
    ${MO_NAME}    set variable    MRBTS-801
    Expand Tree Node and Select node in CM application
    ...   tree_name=navigationTree
    ...   node_path=${TREE_PATH}|${MO_NAME} ${MO_NAME}|EQM_R-1/APEQM_R-1/CABINET_R-1
    ...   component_name=${table_name}

CM Get Tree Path
    [Arguments]   ${tree_name}   ${tree_path_header}
    Expand Tree Node and Select node in CM application
    ...   tree_name=navigationTree
    ...   node_path=${tree_path_header}
    ...   component_name=${tree_name}
    Sleep   5s
    @{child_list}   Get Tree Node Child Names   identifier=${tree_name}   nodeIdentifier=${tree_path_header}
    Return From Keyword If   '${MO_NAME} ${MO_NAME}' in ${child_list}   ${tree_path_header}|${MO_NAME} ${MO_NAME}
    FOR   ${folder_name}   IN   @{child_list}
       Continue For Loop If   "${folder_name.find('MRBTS')}"=="-1"
       ${folder_name}   Strip String   ${folder_name}
       @{range}   Split String   ${folder_name}   -
       @{range}   Split String   ${range[-1]}   ...
       Return From Keyword If   ${MRBTS_ID} >=${range[0]} and ${MRBTS_ID} <=${range[1]}   ${tree_path_header}|${folder_name}
    END