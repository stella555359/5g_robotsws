*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO    FR1    CRT    RAN_5G_FDD    Owner_fanjin
#...               SBTS00    RAN_5G
#Resource          ./CB007552_Resource.robot
#
#*** Variables ***
#${RD_PARAM}         0x590072=1    # CP Debug
#${SCF_PATH}         ${CURDIR}/resources/config
#${DELTA_FILE}       Delta_Conf_CB007552_C.json
#${LOCAL_WTS_DIR}    ${CURDIR}/resources/wts
#${WTS_CFG}          basic_setup-7552-C-NSA-FDD.cfg
#${UE_ID}            151
#${PROFILE_ID}       1
#${GNB_ID}           2
#${CELL_ID}          3
#${BEARER_ID}        2
#${DL_TRAFFIC}       100
#${UL_TRAFFIC}       100
#@{LOG_NAME_LIST}    btslog    snapshot
#
#*** Test Cases ***
#CB007552_ET_C003_Verify_ENDC_Setup_For_IntraBandNonContigugous_And_Small_BWP_With_FDD_FR1_NSA_Mode
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
##    NSA Verify If Attach Passed
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    ${DL_TRAFFIC}
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    ${UL_TRAFFIC}
#    Sleep    6s    reason=wait for traffic stable
#    Capture Ttitrace And Convert Format
#    Save Egate Log    ${output_dir}
#    Verify Samll BWP Flag From Egate
#    Verify Small BWP UE ACK Rate From Ttitrace
#
#*** Keywords ***
#Verify Samll BWP Flag From Egate
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007552_C${/}CB007552_C_SmallBWP.ini    p
#    ...    save_log_directory=${output_dir}
#
#Verify Small BWP UE ACK Rate From Ttitrace
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007552_C${/}CB007552_C_SmallBWP.ini    i
#    ...    save_log_directory=${output_dir}/ttitrace_streaming
#
