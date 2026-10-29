*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1    AP_REG
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ../keywords/L3_Call.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      ta5g_iphy
Library      taf.ul.ettf.setups

Library      ta5g_ue_measurements
Library      ta5g_testline_management


Suite Setup       Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_H_B2a.xml
...               AND             With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}
...               AND             With Gnb Configuration    commissioning=${scfc}
...               AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}
...               AND             Reach Onair    lua_cfg=${CURDIR}/config/config_H_B2a.cfg
Test Teardown     Deregister UE   ue_id=${UE_ID}
Suite Teardown    Run Keywords    Stop Default Logging
...               AND             Reset Egate
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${RRC_RECONF_SCELL_ADD_2_FDD_SCELLS}=             nr-rrc.c1 == 0 && nr-rrc.sCellToAddModList == 2 &&
                                             ...  nr-rrc.physCellId == 51 && nr-rrc.physCellId == 54
${RRC_RECONF_A1_MEAS_FOR_SCELL_CHANGE_TDD}=       nr-rrc.c1 == 0 && nr-rrc.measObjectId == 1 &&
                                             ...  nr-rrc.eventId == 0 && nr-rrc.measId == 6
${F1AP_SCELL_CHANGE_TO_FTT}=         f1ap.UEContextModificationRequest_element && f1ap.SCell_ToBeSetupMod_List == 2 &&
                                ...  f1ap.nRCellIdentity == 00:00:04:00:30 && f1ap.nRCellIdentity == 00:00:04:00:60 &&
                                ...  nr-rrc.bandCombinationIndex == 3 && f1ap.SCell_ToBeRemoved_List == 2
${RRC_RECONF_SCELL_CHANGE_TO_FTT}=   nr-rrc.c1 == 0 && nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 52 &&
                                ...  nr-rrc.physCellId == 55 && nr-rrc.sCellToReleaseList == 2 &&
                                ...  nr-rrc.SCellIndex == 1 && nr-rrc.SCellIndex == 2

${UE_ID}=                      1
${PCELL_ID}=                   1
${GNB_ID}=                     2
${SCELL_ADD_A1_MEAS_ID}=       3
${SCELL_CHANGE_A1_MEAS_ID}=    6
${scfc}=                       scfc_H_B2a.xml
${rdMergedMeasGapSetupAndDrxRelease}=        0x890046=1 # rdMergedMeasGapSetupAndDrxRelease
@{SWCONFIG_FLAGS_LIST}=       ${rdMergedMeasGapSetupAndDrxRelease}

*** Test Cases ***
5GC002640-H-B2a_Successful_SCell_Change_From_3CC_F-F-F_To_3CC_F-T-T
    Attach UE With 3CC FFF    ue_id=${UE_ID}    pcell_id=${PCELL_ID}    enb_id=${GNB_ID}
    Verify A1 Measurement Configuration For SCell Change Purpose
    Trigger And Verify SCell Change To 3CC FTT At UE    ue_id=${UE_ID}

*** Keywords ***
Attach UE With 3CC FFF
    [Arguments]    ${ue_id}    ${pcell_id}    ${enb_id}=1
    Attach UE And Establish PDU Session    ue_id=${ue_id}   cell_id=${pcell_id}    enb_id=${enb_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${SCELL_ADD_A1_MEAS_ID} event=A1 srsrp_nr=75
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_SCELL_ADD_2_FDD_SCELLS}

Verify A1 Measurement Configuration For SCell Change Purpose
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_A1_MEAS_FOR_SCELL_CHANGE_TDD}

Trigger And Verify SCell Change To 3CC FTT At UE
    [Arguments]    ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${SCELL_CHANGE_A1_MEAS_ID} event=A1 srsrp_nr=85
    Verify Tcpdump Log    packet_filter=${F1AP_SCELL_CHANGE_TO_FTT}
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_SCELL_CHANGE_TO_FTT}

Reset Egate
    Execute Egate Command    cmd=sim_reset
