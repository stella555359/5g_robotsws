# *** Settings ***
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        SBTS23R1    owner_yuqq    AP     SBTS22R4    CRT    SBTS00    RAN_5G_TDD    RAN_5G    
# ...    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_NUM}         1
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_1729_case2.xml
# ${AIRPHONE_NAME}    IPHY_AEHC.xml
# ${WTS_NAME}       WTS_1729.cfg
# @{LOG_NAME_LIST}    egatelog
# 
# 
# 
# *** Test Cases ***
# 5GC001729_Case2_A_1_feature_activation_and_deactivation_with_defined_CA_relation    
# 	Add GNB swconfig    0x340000:15
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach ue with '2x2_2cc'capability to 5g cell
#     Internal send mutiple trf '6' for each '175M' DL data   
# 	sleep    30s
# 	Wait reach threshold   Check pm counter M55310C01006 in cell 1 is expected > 0
#     Wait reach threshold   Check pm counter M55310C01006 in cell 2 is expected > 0
# 	Detach UE
# 	Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_A_1_case2.json
# 	Attach ue with '2x2_2cc'capability to 5g cell
#     Internal send mutiple trf '6' for each '175M' DL data   
# 	Sleep     30s
# 	Wait reach threshold   Check pm counter M55310C01006 in cell 1 is expected > 0
#     Wait reach threshold   Check pm counter M55310C01006 in cell 2 is expected == 0
#     Stop capture gnb and ap syslog in 'after_onair' file
#     Detach UE
#     
# 
# *** Keywords ***
# Wait reach threshold
#     [Arguments]    ${check_point}
#     Wait Until Keyword Succeeds    400s    10s    ${check_point}
# 	
# Verify Pcell throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>180000
# 
# Verify Scell throughput=0
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_scell1}==0
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>180000
#     should_be_true    ${dl_throughput_scell1}>180000
# 	
# 
# Get and verify DL throughput average per ue
#     [Arguments]    ${num}
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>10000
#     should_be_true    ${dl_throughput_scell1}>10000
# 
# 
