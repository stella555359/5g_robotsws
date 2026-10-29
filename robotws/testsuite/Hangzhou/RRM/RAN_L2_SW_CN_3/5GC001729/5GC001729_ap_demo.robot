# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_pennwang    AP    SBTS22R2    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_KLL_AP_SA_L1B_ECPRI_CMWV
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
# ${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${UE_ID}                 1
# ${PDU_ID}           1
# ${GW_ID}            1
# ${SLICE_ID}          1
# ${SCFC_NAME}    SCFC_22.xml
# ${AIRPHONE_NAME}    IPHY_AEHC.xml
# ${WTS_NAME}    WTS_1729.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${TTITRACE_TAG}    tti
# 
# 
# *** Test Cases ***
# 5GC001729_scell_blind_addition_blind_activation
#     Prepare gnb onair
#     Online change to blind addition
#     Start capture gnb and ap syslog in 'after_onair' file
#     Start collect ttitrace
#     Set traffic type to internal
#     Attach ue with '2x2_2cc'capability and check scell added
#     Internal send mutiple trf '4' for each '175M' DL data
#     Wait for '2s' to stop ttitrace with name'${TTITRACE_TAG}'
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# 
# *** Keywords ***
# Online change to blind addition
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-2/NRCELL-1/NRREL-0    sCellAdditionMethod    blind    online
#     Perform online change value    MRBTS-1/NRBTS-2    sCellActivationMethod    blind    online
#     Perform online change value    MRBTS-1/NRBTS-2/NRCELL-1    sCellDeactivationTimerGNB     infinity    online
#     Perform online change value    MRBTS-1/NRBTS-2/NRCELL-2    sCellDeactivationTimerGNB     infinity    online
#     Perform online change value    MRBTS-1/NRBTS-2    actMeasBasedSCellAddition    false    online
#     Perform online change value    MRBTS-1/NRBTS-2    actMeasBasedSCellAdditionNsa    false    online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# Attach ue with '${pattern}'capability and check scell added
#     ${ue_ability}    Obtain Ue Capability    ${pattern}
#     Airphone SA Attach    ue_id=${UE_ID}    ue_capability=${ue_ability}
#     Airphone Pdu Session Setup    ue_id=${UE_ID}    pdu_id=${PDU_ID}    nwslice_id=${SLICE_ID}    gw_id=${GW_ID}    pass_regexp=sCellToAddModList
