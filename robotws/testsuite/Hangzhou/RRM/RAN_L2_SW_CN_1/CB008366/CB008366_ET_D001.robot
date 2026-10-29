*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_FILE}    iphy_file=${IPHY_2T4F_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Run Keywords    Common Suite Teardown
#Test Setup        Common Test Setup    delta_jason=${DELTA_FILE}
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    master_classicalbts_all    STATE_CONFIGURED    CRT    FR1
#...               Owner_LiLiang    CN1_SQ    SBTS00    RAN_5G    CRTANDmaster_classicalbts_all
#Resource          ./CB008366_Resource.robot
#
#*** Variables ***
#${FULL_FILE}         basic_2T4F_SCFC.xml
#${IPHY_2T4F_FILE}    ${CURDIR}/Resource/wts/iphy_2T4F.xml
#${DELTA_FILE}        CB008366_ET_D002.json
#${LOCAL_WTS_DIR}     ${CURDIR}/Resource/wts
#${WTS_CFG}           basic_2T4F.cfg
#${WTS_AP_XML}        basic_2T4F.xml
#${SCF_PATH}          ${CURDIR}/Resource/Config
#${UE_NUM}            8
#
#*** Test Cases ***
#CB008366_ET_D001_Verify_enhanced_FDM_12CA_UEs_per_cell_per_slot_on_ABIO
#    Multi UE Register    11    14
#    FOR    ${ue_id}    IN RANGE    11    14
#    SA Start DL Traffic EGate    ${ue_id}    ${pdu_id}    14
#    END
#    Sleep    5s    reason=Wait For Data Transmission
#    Start GNB TTI Trace    1    21
#    Sleep    0.8s    reason=get *L2TtiTrace_EventsSnapshot
#    Stop GNB TTI Trace
#    FOR    ${ue_id}    IN RANGE    11    14
#    SA Stop DL Traffic EGate    ${ue_id}    ${pdu_id}
#    SA 5G Detach    ${ue_id}
#    END
#
#    Decode TTI Trace And Send To Control PC One By One    ${TEST_LOG_DIRECTORY}
#    Check DL Per Slot Ue Numbers    ${test_log_directory}    ${UE_NUM}
