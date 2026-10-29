# *** Settings ***
# Test Timeout      120 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS22R2    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    owner_pennwang
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_case43_MP_AP_LO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_2CELL_MP_AP_LO_case43.xml
# ${WTS_NAME}      WTS_MP_AP_LO_SANSA_n78_2Cell_case43.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# 
# 
# *** Test Cases ***
# CB007922_case43_C_1b_intraL2RT_Single_UE_DL_UL_peak_SA_with_5GC001070_guardSy_2_mixBandWith  
#     Prepare gnb onair
#     #Set ue srs sinr
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach SA UE    UE_ID=1     PDU_ID=1   SLICE_ID=1    GW_ID=1
#     UE send A1 Event
#     SA send dl and ul data    1    number=10    dl_data=175M    ul_data=10M
#     Check tput is peak
# #    run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti_case43'
#     Check ttitrace no bler
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
#     
# 
# *** Keywords ***
# UE send A1 Event
#     Airphone Measurement Send Nr    id=1    meas_id=2    event=A1    rs_type=ssb    srsrp_nr=62
#     Wait '2s' for stabible
# 
# Check tput is peak
#     Wait '15s' for stabible
#     Check SA ue '1' 'pcell' dl throught should '> 800000'
#     Check SA ue '1' 'scell' dl throught should '> 700000'
# 
# Set ue srs sinr
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 sinr_target_srs\=35 sinr_target_pucch\=-300 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1
# 
# Check ttitrace no bler
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_no_bler_case43.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST LOG DIRECTORY()}/All
# 
# Attach SA UE
#     [Arguments]    ${UE_ID}=1     ${PDU_ID}=1    ${SLICE_ID}=1   ${GW_ID}=1
#     Airphone Setup X2 Connection
#     Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Wait '5s' for stable
