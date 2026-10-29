# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CRT    SBTS00    RAN_5G_TDD    RAN_5G    AP   SBTS23R1
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   owner_zhang
#    
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_n78_Case4_LO.xml
# ${AIRPHONE_NAME}    IPHY_2AEQE_case4.xml
# ${WTS_NAME}       wts_case4_LO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# #${PCELL_THRESHOLD}    300000
# #${SCELL_THRESHOLD}    300000
# #${PCELL_THRESHOLD_NONCA}    500000
# ${UE_ID}    11
# @{Rdparameter}    0x340000:15
# *** Test Cases ***
# CB007922_case04_A_2_intraL2RT_Update_of_CA_association_mixBandWith_NSA
#     Modify Swconfig for GNB
#     Prepare gnb onair
# 
#     #Start collect ttitrace
#     #Wait for '2s' to stop ttitrace with name'tti'
#     #run keyword and continue on failure    Check ttitrace
#     Start capture gnb and ap syslog in 'after_onair' file
# 	
# #normal pscell+scell
#     Attach LTE UE'${UE_ID}'
#     Send DL data to UE'${UE_ID}' and check throughput
#     
#     check tti no bler
# #dellet scell ,UE drop, no data    
#     Log To Console   scell delete
#     delete sCellAdditionMethod    
#     #Wait '10s' for stabible
# 	Log To Console    ${\n}---Check pm counter M55310C01009 in cell 1 is expected == 0
#     Wait reach threshold   Check pm counter M55310C01009 in cell 1 is expected == 0
#     Log To Console    ${\n}---Check pm counter M55310C01009 in cell 2 is expected == 0
#     Wait reach threshold   Check pm counter M55310C01009 in cell 2 is expected == 0   
# 
#     Airphone NSA Detach    ue_id=11
#     Wait '3s' for stabible
# #reAdd scell ,pcell active, scell not active  
#     Attach LTE UE'${UE_ID}'
#     Send DL data to UE'${UE_ID}'   
#     update sCellAdditionMethod
#     Log To Console    ${\n}---Check pm counter M55310C01009 in cell 1 is expected > 0
#     Wait reach threshold   Check pm counter M55310C01009 in cell 1 is expected > 0
#     Log To Console    ${\n}---Check pm counter M55310C01009 in cell 2 is expected == 0
#     Wait reach threshold   Check pm counter M55310C01009 in cell 2 is expected == 0
#     run keyword and continue on failure    Wait Until Keyword Succeeds    120s    2s    check Pcell tp
#     
#     Airphone NSA Detach    ue_id=11
#     Wait '3s' for stabible
# 
# #repeat normal pcell+scell    
#     Attach LTE UE'${UE_ID}'
#     Send DL data to UE'${UE_ID}' and check throughput
#     Airphone NSA Detach    ue_id=11
#     Wait '2s' for stabible
#     
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# check tti no bler
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti'
# 	
# 	Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		tti_dl.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_dl_no_bler.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     
# Modify Swconfig for GNB
#     Add GNB swconfig    @{Rdparameter}
# 
# Attach LTE UE'${UE_ID}'
# 	Log To Console    ${\n}Attach NSA UE   
#     Airphone Nsa Attach     ${UE_ID}    profile_id=None
#     Wait '3s' for stabible
#     
# Send DL data to UE'${UE_ID}' and check throughput
#     NSA send ue '${UE_ID}' mutiple trf '16' for each '160M' DL data        
#     Wait '10s' for stabible
#     run keyword and continue on failure    Wait Until Keyword Succeeds    120s    2s    check UE'${UE_ID}'tp
# 
# Send DL data to UE'${UE_ID}'
#     NSA send ue '${UE_ID}' mutiple trf '16' for each '160M' DL data        
#     Wait '10s' for stabible
#     
# check UE'${UE_ID}'tp
# 	Set test Variable    ${P+S}    0
# 	${pcell_tp}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    8    type=pdsch    tput_type=ave
# 	${scell_tp}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    9    type=pdsch    tput_type=ave
# 	Log To Console   ${\n}---Pcell_tp_${pcell_tp}
# 	Log To Console   ---Scell_tp_${scell_tp}
# 	${P+S}    evaluate    (${pcell_tp}+${scell_tp})/1000
# 	Log To Console    ---P+S:${P+S}---
# 	should be true		${P+S}>1800
# 
# check Pcell tp
# 	${pcell_tp}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    8    type=pdsch    tput_type=ave
# 	${P}    evaluate    ${pcell_tp}/1000
# 	Log To Console   ${\n}---Pcell_tp_${P}
# 	should be true		${P}>800
# 	
# Wait reach threshold
#     [Arguments]    ${check_point}
#     run keyword and continue on failure    Wait Until Keyword Succeeds    300s    5s    ${check_point}
# 
# ${operation} sCellAdditionMethod
#     Log To Console    Del sCellAdditionMethod...
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-1/NRREL-2    parameter=sCellAdditionMethod
#     ...    operation=${operation}    value=blind    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
