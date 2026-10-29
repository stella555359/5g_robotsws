# *** Settings ***
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1    SBTS22R4
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    owner_pennwang
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_case50_2AEQE_APLO.xml
# ${AIRPHONE_NAME}    IPHY_2AEQE_case50_LOAP.xml
# ${WTS_NAME}       WTS_2AEQE_case50_LOAP.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# *** Test Cases ***
# 5GC001729_Case2_A_1_feature_activation_and_deactivation_with_defined_CA_relation   
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach SA ue to 5g cell    TDD_APLO_SA_n78_n41    1
#     UE send A1 Event
#     SA send dl and ul data    1    number=17    dl_data=175M    ul_data=10M
#     SA send mutiple trf dl data    1    number=17    dl_data=175M
#     Check tput is peak
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'case4'
# 	Detach '1' UE
# 	Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_A_1_case2.json
#     Attach SA ue to 5g cell    TDD_APLO_SA_n78_n41    1
#     SA send dl and ul data    1    number=17    dl_data=175M    ul_data=10M 
#     Check only pcell tput and is peak
#     Stop capture gnb and ap syslog in 'after_onair' file
#     Detach '1' UE
#     
# 
# *** Keywords ***
# UE send A1 Event
#     Airphone Measurement Send Nr    id=1    meas_id=2    event=A1    rs_type=ssb    srsrp_nr=70
#     Wait '2s' for stabible
# 
# Check tput is peak
#     Wait '10s' for stabible
#     run keyword and continue on failure    Check SA ue '1' 'pcell' dl throught should '> 1000000'
#     run keyword and continue on failure    Check SA ue '1' 'scell' dl throught should '> 1000000'
# 
# Check only pcell tput and is peak
#     Wait '10s' for stabible
#     Check SA ue '1' 'pcell' dl throught should '> 1100000'
