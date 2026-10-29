*** Settings ***
Documentation
...   Author: xiaokang.qu@nokia-sbell.com
...   Contact: xiaokang.qu@nokia-sbell.com
...   Description: This set of robot cases is used for CB007321
...    Deprecated case removed by civen.chen
#
#
##Suite Setup        Common Suite Setup For AIC For Any Testline
##Suite Teardown     Common Suite Teardown For AIC
#Suite Setup        Common Suite Setup For AIC
#Suite Teardown     Custom Suite Teardown For AIC
#
#Force Tags
#...   PY36
#...   RAN_5G
#...   RAN_PZ_HAZ_1
#
#Test Timeout       75h
#
#Resource           ../../../T01/Resources/Case_Common_Resource.robot
##Resource          ../../../Resources/Common/AIC_UE.robot
##Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
##Resource           ../../Resources/RRM2_Resource.robot
#Resource           ../../../Resources/Cloud/AIC_Common_Setup_Teardown.robot
#Resource           ../../../T01/Resources/SFE/SFE_UE.robot
#
#
#Resource    ../../../Resources/Cloud/AIC_Common_Resource.robot
##Resource    ../../../T01/Resources/RRM2_Resource.robot
#Resource    ../../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
#Library     ../../../Resources/Cloud/python/collect_wireshark_log.py    WITH NAME    wireshark
##import     ../../../Resources/Cloud/python/collect_wireshark_log.py
#
#*** Variables ***
##${nsetapx_plugin_addr}
##...   https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/nsetapx-1.12.3/nsetapx-4.0-0.6.1-1.12.3+buster.so
##${plugin_folder}   /usr/lib/x86_64-linux-gnu/wireshark/plugins
##${plugin_folder_utevm}   /home/ute/.local/lib/wireshark/plugins
#
#${sba_host}            10.69.4.50
#&{dcap_server_sba}           host=10.69.4.50    username=dcapuser     password=dcapuser
#...    key_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB008411/config/id_rsa_DCAP_50
#
#*** Test Cases ***
#Case 01
#    Download wireshark plugin
#
#CB007321_CR_Streaming UE associated Control Plane E1AP, F1AP messages from gNB-CU-CP in MBA Cell Trace session for SA UE calls
#    [Tags]    CB007321    QC_0001    QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: xiaokang.qu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    3.02.2024, xiaokang.qu@nokia-sbell.com, draft
#    [Setup]    Common Case Precondition
#    #vCU Load And Active SCF    ${DEFAULT_SCF_PATH}/vCU_SCF_${BRANCH_NAME}_5467.xml
#    #vDU Load And Active SCF    ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_5467.xml
#    #SBTS classical Load And Active SCF     ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_6207.xml
#    Set Test Variable  ${TL_NAME}  7_5_UTE5GAIC016T007
#    Online enable vCU Parameters For USCB007321-A-1
#    wait until keyword succeeds   60min  30s   Check All Cells On Air In vCU
#    Change RU1 PA Attenuation For TL5467    15
#    Log Collection    start    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
##    Start Tcpdump Log for OAM
#    Prepare UE0 And Attach UE0 With TL5467
#    Start DL Call For UE0
#    Sleep    30S    reason=Waiting For Voice Call
#    ${local_file_path}    Log Collection    stop_and_download    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
##     ${oamext_file_path}  Stop Tcpdump Log for OAM
#    Log To Console        \nWireshark log of VDU: ${local_file_path}
#
#    [Teardown]    Common Case Postcondition For USCB007321
#
#CB007321_CR_Streaming UE associated Control Plane E1AP, F1AP messages from gNB-CU-CP in SBA Trace session
#    [Tags]    CB007321    QC_0002           QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: xiaokang.qu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    3.02.2024, xiaokang.qu@nokia-sbell.com, draft
#    [Setup]    Common Case Precondition
#    #vCU Load And Active SCF    ${DEFAULT_SCF_PATH}/vCU_SCF_${BRANCH_NAME}_5467.xml
#    #vDU Load And Active SCF    ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_5467.xml
#    #SBTS classical Load And Active SCF     ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_6207.xml
#    Set Test Variable  ${TL_NAME}  7_5_UTE5GAIC016T007
#    Online enable vCU Parameters For USCB007321-A-2
#    wait until keyword succeeds   60min  30s   Check All Cells On Air In vCU
#    Change RU1 PA Attenuation For TL5467    15
#    Log Collection    start    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
##    Start Tcpdump Log for OAM
##    Trigger SBA Trace on initial   ue_id=1   tce_ip=${sba_host}     trace_depth=minimum    trace_rec_session_ref_id=1
#    Prepare UE0 And Attach UE0 With TL5467
#    Start DL Call For UE0
##    Trigger SBA Trace Start    ue_id=1    tce_ip=10.69.4.60
#    Sleep    10S    reason=Waiting For Voice Call
#    ${local_file_path}    Log Collection    stop_and_download    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
##	${oamext_file_path}  Stop Tcpdump Log for OAM
#    [Teardown]    Common Case Postcondition For USCB007321
#
#CB007321_CR_ Monitoring of Cell trace content related to CB007321 Call trace for E1 and F1
#    [Tags]    CB007321    QC_0003           QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: xiaokang.qu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    3.02.2024, xiaokang.qu@nokia-sbell.com, draft
#    [Setup]    Common Case Precondition
#    #vCU Load And Active SCF    ${DEFAULT_SCF_PATH}/vCU_SCF_${BRANCH_NAME}_5467.xml
#    #vDU Load And Active SCF    ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_5467.xml
#    #SBTS classical Load And Active SCF     ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_6207.xml
#    Set Test Variable  ${TL_NAME}  7_5_UTE5GAIC016T007
#    Online enable vCU Parameters For USCB007321-A-1
#    wait until keyword succeeds   60min  30s   Check All Cells On Air In vCU
#    Change RU1 PA Attenuation For TL5467    15
#    Log Collection    start    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
#    Prepare UE0 And Attach UE0 With TL5467
#    Start DL Call For UE0
#    Sleep    10S    reason=Waiting For Voice Call
#    Online disable vCU CellTrace For USCB007321
#    wait until keyword succeeds   60min  30s   Check All Cells On Air In vCU
#    Prepare UE0 And Attach UE0 With TL5467
#    Start DL Call For UE0
#    Sleep    10S    reason=Waiting For Voice Call
#    ${local_file_path}    Log Collection    stop_and_download    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
#    [Teardown]    Common Case Postcondition For USCB007321
#
#CB007321_CR_Monitoring of Subscriber trace content related to CB007321 Call trace for E1 and F1
#    [Tags]    CB007321    QC_0004           QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: xiaokang.qu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    3.02.2024, xiaokang.qu@nokia-sbell.com, draft
#    [Setup]    Common Case Precondition
#    #vCU Load And Active SCF    ${DEFAULT_SCF_PATH}/vCU_SCF_${BRANCH_NAME}_5467.xml
#    #vDU Load And Active SCF    ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_5467.xml
#    #SBTS classical Load And Active SCF     ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_6207.xml
#    Set Test Variable  ${TL_NAME}  7_5_UTE5GAIC016T007
#    Online enable vCU Parameters For USCB007321-A-2
#    wait until keyword succeeds   60min  30s   Check All Cells On Air In vCU
#    Change RU1 PA Attenuation For TL5467    15
#    Log Collection    start    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
#    Prepare UE0 And Attach UE0 With TL5467
#    Start DL Call For UE0
##    Trigger SBA Trace Start    ue_id=1    tce_ip=10.69.4.54
#    Sleep    10S    reason=Waiting For Voice Call
#    Online disable vCU SubscriberTrace For USCB007321
#    wait until keyword succeeds   60min  30s   Check All Cells On Air In vCU
#    Prepare UE0 And Attach UE0 With TL5467
#    Start DL Call For UE0
#    Sleep    10S    reason=Waiting For Voice Call
#    ${local_file_path}    Log Collection    stop_and_download    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
##    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=classical    bts_index=${0}    cudu_index=${0}
#    [Teardown]    Common Case Postcondition For USCB007321
#
#CB007321_SR_Streaming UE associated Control Plane Private XnAP messages from gNB-CU-CP in MBA Cell Trace session for SA UE calls
#    [Tags]    CB007321    QC_0005           QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: xiaokang.qu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    3.02.2024, xiaokang.qu@nokia-sbell.com, draft
#    [Setup]    Common Case Precondition
#    #vCU Load And Active SCF    ${DEFAULT_SCF_PATH}/vCU_SCF_${BRANCH_NAME}_5467.xml
#    #vDU Load And Active SCF    ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_5467.xml
#    #SBTS classical Load And Active SCF     ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_6207.xml
#    Set Test Variable  ${TL_NAME}  7_5_UTE5GAIC016T007
#    Online enable XnAP Parameters
#    wait until keyword succeeds   30min  30s   Check XnAP Counter Update For CB007321
#	Online enable vCU Parameters For USCB007321-A-1
#    wait until keyword succeeds   60min  30s   Check All Cells On Air In vCU
#    Change RU1 PA Attenuation For TL5467    15
#    Change RU2 PA Attenuation For TL5467    127
#    Log Collection    start    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
##    Log Collection    start    wireshark_cp    product_type=classical    bts_index=${0}    cudu_index=${0}
#    Prepare UE0 And Attach UE0 With TL5467
#    Start DL Call For UE0
#    Sleep    10S    reason=Waiting For Voice Call
#    Change RU1 PA Attenuation For TL5467    40
#    Change RU2 PA Attenuation For TL5467    5
#    Sleep    60S    reason=Waiting For HO and Voice Call
#    ${local_file_path}    Log Collection    stop_and_download    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
##    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=classical    bts_index=${0}    cudu_index=${0}
#    [Teardown]    Common Case Postcondition For USCB007321
#
#CB007321_SR_Streaming UE associated Control Plane Private XnAP messages from gNB-CU-CP in SBA Trace session
#    [Tags]    CB007321    QC_0006           QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: xiaokang.qu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    3.02.2024, xiaokang.qu@nokia-sbell.com, draft
#    [Setup]    Common Case Precondition
#    #vCU Load And Active SCF    ${DEFAULT_SCF_PATH}/vCU_SCF_${BRANCH_NAME}_5467.xml
#    #vDU Load And Active SCF    ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_5467.xml
#    #SBTS classical Load And Active SCF     ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_6207.xml
#    Set Test Variable  ${TL_NAME}  7_5_UTE5GAIC016T007
#    Online enable XnAP Parameters
#    wait until keyword succeeds   30min  30s   Check XnAP Counter Update For CB007321
#	Online enable vCU Parameters For USCB007321-A-2
#    wait until keyword succeeds   60min  30s   Check All Cells On Air In vCU
#    Change RU1 PA Attenuation For TL5467    15
#    Change RU2 PA Attenuation For TL5467    127
#    Log Collection    start    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
##    Log Collection    start    wireshark_cp    product_type=classical    bts_index=${0}    cudu_index=${0}
#    Prepare UE0 And Attach UE0 With TL5467
#    Start DL Call For UE0
##    Trigger SBA Trace Start    ue_id=1    tce_ip=10.69.4.54
#    Sleep    10S    reason=Waiting For Voice Call
#    Change RU1 PA Attenuation For TL5467    40
#    Change RU2 PA Attenuation For TL5467    5
#    Sleep    60S    reason=Waiting For HO and Voice Call
#    ${local_file_path}    Log Collection    stop_and_download    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
##    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=classical    bts_index=${0}    cudu_index=${0}
#    [Teardown]    Common Case Postcondition For USCB007321
#
#CB007321_SR_Monitoring of Cell trace content related to CB007321-B "Call trace for proprietary messages"
#    [Tags]    CB007321    QC_0007           QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: xiaokang.qu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    3.02.2024, xiaokang.qu@nokia-sbell.com, draft
#    [Setup]    Common Case Precondition
#    #vCU Load And Active SCF    ${DEFAULT_SCF_PATH}/vCU_SCF_${BRANCH_NAME}_5467.xml
#    #vDU Load And Active SCF    ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_5467.xml
#    #SBTS classical Load And Active SCF     ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_6207.xml
#    Set Test Variable  ${TL_NAME}  7_5_UTE5GAIC016T007
#    Online enable vCU Parameters For USCB007321-A-1
#    Online enable XnAP Parameters
#    wait until keyword succeeds   60min  30s   Check All Cells On Air In vCU
#    Change RU1 PA Attenuation For TL5467    15
#    Log Collection    start    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
##    Log Collection    start    wireshark_cp    product_type=classical    bts_index=${0}    cudu_index=${0}
#    Prepare UE0 And Attach UE0 With TL5467
#    Start DL Call For UE0
#    Sleep    10S    reason=Waiting For Voice Call
#    ${local_file_path}    Log Collection    stop_and_download    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
##    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=classical    bts_index=${0}    cudu_index=${0}
#    Online disable XnAP Parameters
#    wait until keyword succeeds   60min  30s   Check All Cells On Air In vCU
#    [Teardown]    Common Case Postcondition For USCB007321
#
#
#CB007321_SR_ Monitoring of Subscriber trace content related to CB007321-B "Call trace for proprietary messages"
#    [Tags]    CB007321    QC_0008           QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: xiaokang.qu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    3.02.2024, xiaokang.qu@nokia-sbell.com, draft
#    [Setup]    Common Case Precondition
#    #vCU Load And Active SCF    ${DEFAULT_SCF_PATH}/vCU_SCF_${BRANCH_NAME}_5467.xml
#    #vDU Load And Active SCF    ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_5467.xml
#    #SBTS classical Load And Active SCF     ${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}_6207.xml
#    Set Test Variable  ${TL_NAME}  7_5_UTE5GAIC016T007
#    Online enable vCU Parameters For USCB007321-A-2
#    Online enable XnAP Parameters
#    wait until keyword succeeds   60min  30s   Check All Cells On Air In vCU
#    Change RU1 PA Attenuation For TL5467    15
#    Log Collection    start    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
##    Log Collection    start    wireshark_cp    product_type=classical    bts_index=${0}    cudu_index=${0}
#    Prepare UE0 And Attach UE0 With TL5467
#    Start DL Call For UE0
##    Trigger SBA Trace Start    ue_id=1    tce_ip=10.69.4.54
#    Sleep    10S    reason=Waiting For Voice Call
#    ${local_file_path}    Log Collection    stop_and_download    wireshark_oam    product_type=vcu    bts_index=${0}    cudu_index=${0}
##    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=classical    bts_index=${0}    cudu_index=${0}
#    Online disable XnAP Parameters
#    wait until keyword succeeds   60min  30s   Check All Cells On Air In vCU
#    [Teardown]    Common Case Postcondition For USCB007321
#
#*** Keywords ***
#Online enable vCU Parameters For USCB007321-A-1
#	${mo_dn1}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#	${mo_dn2}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCTRLTS-1/NRMTRACECU-1
#    ${value}    Set Variable    true
#    ${value2}    Set Variable    all
#
#    &{param_dict}    create dictionary    operation_type=replace    parameter_path=/actCellTraceReport
#    ...                                                                         value=${value}
#    &{param_dict}    create dictionary    operation_type=replace    parameter_path=/traceE1Setting
#    ...                                                                         value=${value2}
#    &{param_dict}    create dictionary    operation_type=replace    parameter_path=/traceF1Setting
#    ...                                                                         value=${value2}
#    @{updated}    Create List    ${param_dict}
#
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=actCellTraceReport
#    ...                                                   updated_paras_dict=${updated}
#    ...                                                   compare_value=${value}
#    ...                                                   mo_dn=${mo_dn1}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=traceE1Setting
#    ...                                                   updated_paras_dict=${updated}
#    ...                                                   compare_value=${value2}
#    ...                                                   mo_dn=${mo_dn2}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=traceF1Setting
#    ...                                                   updated_paras_dict=${updated}
#    ...                                                   compare_value=${value2}
#    ...                                                   mo_dn=${mo_dn2}
#
#Online disable vCU CellTrace For USCB007321
#	${mo_dn1}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    ${value}    Set Variable    false
#
#    &{param_dict}    create dictionary    operation_type=replace    parameter_path=/actCellTraceReport
#    ...                                                                         value=${value}
#    @{updated}    Create List    ${param_dict}
#
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=actCellTraceReport
#    ...                                                   updated_paras_dict=${updated}
#    ...                                                   compare_value=${value}
#    ...                                                   mo_dn=${mo_dn1}
#
#Online disable vCU SubscriberTrace For USCB007321
#	${mo_dn1}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    ${value}    Set Variable    false
#
#    &{param_dict}    create dictionary    operation_type=replace    parameter_path=/actSubscriberTraceReport
#    ...                                                                         value=${value}
#    @{updated}    Create List    ${param_dict}
#
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=actSubscriberTraceReport
#    ...                                                   updated_paras_dict=${updated}
#    ...                                                   compare_value=${value}
#    ...                                                   mo_dn=${mo_dn1}
#
#Online enable vCU Parameters For USCB007321-A-2
#	${mo_dn1}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#	${mo_dn2}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCTRLTS-1/NRMTRACECU-1
#    ${value}    Set Variable    true
#    ${value2}    Set Variable    all
#
#    &{param_dict}    create dictionary    operation_type=replace    parameter_path=/actSubscriberTraceReport
#    ...                                                                         value=${value}
#    &{param_dict}    create dictionary    operation_type=replace    parameter_path=/traceE1Setting
#    ...                                                                         value=${value2}
#    &{param_dict}    create dictionary    operation_type=replace    parameter_path=/traceF1Setting
#    ...                                                                         value=${value2}
#    @{updated}    Create List    ${param_dict}
#
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=actSubscriberTraceReport
#    ...                                                   updated_paras_dict=${updated}
#    ...                                                   compare_value=${value}
#    ...                                                   mo_dn=${mo_dn1}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=traceE1Setting
#    ...                                                   updated_paras_dict=${updated}
#    ...                                                   compare_value=${value2}
#    ...                                                   mo_dn=${mo_dn2}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=traceF1Setting
#    ...                                                   updated_paras_dict=${updated}
#    ...                                                   compare_value=${value2}
#    ...                                                   mo_dn=${mo_dn2}
#
#Online enable XnAP Parameters
#    ${mo_dn1}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    ${value}    Set Variable    true
#    &{param_dict}    create dictionary    operation_type=replace    parameter_path=/actIncXn
#    ...                                                                         value=${value}
#    @{updated}    Create List    ${param_dict}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=actIncXn
#    ...                                                   updated_paras_dict=${updated}
#    ...                                                   compare_value=${value}
#    ...                                                   mo_dn=${mo_dn1}
#
#    &{param_dict}    create dictionary    operation_type=replace    parameter_path=/actConflictConfiguration
#    ...                                                                         value=${value}
#    @{updated}    Create List    ${param_dict}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=actConflictConfiguration
#    ...                                                   updated_paras_dict=${updated}
#    ...                                                   compare_value=${value}
#    ...                                                   mo_dn=${mo_dn1}
#
#Online disable XnAP Parameters
#    ${mo_dn1}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    ${value}    Set Variable    false
#    &{param_dict}    create dictionary    operation_type=replace    parameter_path=/actIncXn
#    ...                                                                         value=${value}
#    @{updated}    Create List    ${param_dict}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=actIncXn
#    ...                                                   updated_paras_dict=${updated}
#    ...                                                   compare_value=${value}
#    ...                                                   mo_dn=${mo_dn1}
#
#    &{param_dict}    create dictionary    operation_type=replace    parameter_path=/actConflictConfiguration
#    ...                                                                         value=${value}
#    @{updated}    Create List    ${param_dict}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=actConflictConfiguration
#    ...                                                   updated_paras_dict=${updated}
#    ...                                                   compare_value=${value}
#    ...                                                   mo_dn=${mo_dn1}
#
#Common Case Precondition
#    log to console    Case Precondition
#    Common Test Setup For AIC
#    ${NEW_PLAN_NAME}   Get Test Case Name
#    Set Test Variable  ${NEW_PLAN_NAME}
#
#Common Case Postcondition
#    log to console    Case Postcondition
#    Common Test Teardown For AIC
#    vDU Login By Rest
#    Run Keyword And Ignore Error  plan_name=${NEW_PLAN_NAME}
#    Run Keyword And Ignore Error  svdu.Delete Plan  plan_name=${NEW_PLAN_NAME}
#    Run Keyword And Ignore Error  vDU Logout By Rest
#    Run Keyword And Ignore Error    Detach UE0
#    Run Keyword And Ignore Error    wireshark.stop_wireshark_log    pod_name=${pod_name}    namespace=${ns}
#    ...                                                             conn=${conn}    timeout=${timeout}
#
#Common Case Postcondition For USCB007321
#    Run Keyword And Ignore Error    Stop DL Call For UE0
#    Run Keyword And Ignore Error    Change RU1 PA Attenuation For TL5467    15
#    Run Keyword And Ignore Error    Change RU2 PA Attenuation For TL5467    127
#    Common Case Postcondition
#
#Change RU1 PA Attenuation For TL5467
#    [Arguments]    ${PA_Value}=15
#    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=${PA_Value}
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    10s
#    Log to console    PA Attenuation Changed.
#
#Change RU2 PA Attenuation For TL5467
#    [Arguments]    ${PA_Value}=15
#    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary   ${attenuation_channels[1]}=${PA_Value}
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    10s
#    Log to console    PA Attenuation Changed.
#
#Check XnAP Counter Update For CB007321
#    ${value_16}=   Check Counter For vCU    counter_id=M55126C00005
#    ...                                              measurement_id=55126
#    ...                                              dimension_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    ...                                              expected_value=-1
#    ...                                              get_number=5
#    Should Be True    ${value_16}>0
#
#
#Prepare UE0 And Attach UE0 With TL5467
#    Run Keyword If    '${TL_NAME}' == '7_5_UTE5GAIC016T007'    Prepare UE0 And Attach UE0    MATE30PROUI1.0
#    ...               ELSE            Prepare UE0 And Attach UE0    MATE40PROUI1.0
#
#Trigger SBA Trace on initial
#    [Arguments]    ${ue_id}=1   ${tce_ip}=10.69.4.50    ${trace_depth}=maximum    ${trace_rec_session_ref_id}=1
#    ${command} =  catenate   SEPARATOR=
#    ...           amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=${trace_rec_session_ref_id}
#    ...           \ trace_activation=on trace_plmn=262:03
#    ...           \ trace_ref_id=${trace_rec_session_ref_id} trace_rec_session_ref_id=${trace_rec_session_ref_id}
#    ...           \ trace_depth=${trace_depth} ifaces_to_trace=Uu,NG-C,Xn-C tce_ip=${tce_ip}
#    Execute Egate Command    cmd=${command}
#    sleep  3s
#
#Trigger SBA Trace Start
#    [Arguments]    ${ue_id}=1    ${tce_ip}=0.0.0.0    ${trace_depth}=maximum
#    ${command} =  catenate   SEPARATOR=
#    ...           ng_ue_trace_start id=${ue_id} trace_plmn=262:03 trace_ref_id=2 trace_rec_session_ref_id=1
#    ...           \ ifaces_to_trace=Xn-C,NG-C,Uu trace_depth=${trace_depth} tce_ip=${tce_ip}
#    Execute Egate Command    cmd=${command}
#
#Start Tcpdump Log for OAM
#    [Arguments]      ${pod_name}=oamext
#    Log To Console    start tcpdump
#    Start Wireshark In vCU OAM    pod_name=${pod_name}
#
#Stop Tcpdump Log for OAM
#    [Arguments]      ${pod_name}=oamext
#    Log To Console    stop tcpdump
#    ${capture_file_path}   Stop Wireshark Log In vCU OAM
#    ...                         pod_name=${pod_name}
#    [Return]     ${capture_file_path}
#
#Start Wireshark In vCU OAM
#    [Arguments]    ${gnb_index}=${0}    ${container_name}=oamext    ${pod_name}=oamext
#    ...            ${timeout}=${10}    ${protocol}=sctp    ${interface}=any    ${alias}=vcu_master
#    ...            ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
#    ...            ${namespace}=${VCU_NAMESPACE}
#    Log To Console    ${gnb_index}
#    Log To Console    ${container_name}
#    Log To Console    ${protocol}
#    ${conn}=    basic.master_connect    hostname=${hostname}
#    ...                           username=${username}
#    ...                           password=${password}
#    ...                           alias=${alias}
#    Set Test Variable    ${conn}
#    wireshark.start_wireshark_log_for_vcu_oam    namespace=${namespace}
#    ...                      pod_name=${pod_name}
#    ...                      conn=${alias}
#    ...                      ip=${hostname}
#    ...                      cranuser_password=${password}
#    ...                      timeout=${timeout}
#    ...                      interface=${interface}
#
#Stop Wireshark Log In vCU OAM
#    [Arguments]    ${gnb_index}=${0}    ${container_name}=oamext    ${alias}=vcu_master
#    ...            ${pod_name}=oamext    ${timeout}=${10}    ${log_name}=wireshark    ${alias}=vcu_master
#    ...            ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
#    ...            ${namespace}=${VCU_NAMESPACE}
#    Log To Console    ${gnb_index}
#    Log To Console    ${container_name}
#    ${conn}=    basic.master_connect    hostname=${hostname}
#    ...                           username=${username}
#    ...                           password=${password}
#    ...                           alias=${alias}
#    Set Test Variable    ${conn}
#    wireshark.stop_wireshark_log_for_vcu_oam    namespace=${namespace}
#    ...                      pod_name=${pod_name}
#    ...                      conn=${alias}
#    ...                      ip=${hostname}
#    ...                      cranuser_password=${password}
#    ...                      timeout=${timeout}
#    ${remote_log_dir}   set variable    /var/home/${username}/${namespace}_${pod_name}_${log_name}.pcap
#    ${local_file_path}=    basic.create_a_file    ${TEST_LOG_DIRECTORY}/Wireshark    ${namespace}_${pod_name}_${log_name}.pcap
#    Set Test Variable    ${local_file_path}
#    tafssh.Download File    remote_path=${remote_log_dir}    local_path=${local_file_path}    connection=${alias}
#    [Return]    ${local_file_path}
#    [Teardown]    RUN KEYWORDS    run keyword and ignore error    basic.master_close    alias=${alias}    AND
#    ...                           run keyword and ignore error    issh.disconnect    alias=cu_master
#
#Download wireshark plugin
#    sleep    5s
#    ${ver}   Run   ls ${plugin_folder}/
#    ${exist}   Run   cd ${plugin_folder}/${ver}/epan;ls nsetapx*
#    ${exist_utevm}   Run   cd ${plugin_folder_utevm}/${ver}/epan;ls nsetapx*
#    Run Keyword If   ${exist.count('No such file or directory')}>0 and ${exist_utevm.count('No such file or directory')}>0   Run
#    ...   cd ${plugin_folder}/${ver}/epan;sudo wget ${nsetapx_plugin_addr}
#
