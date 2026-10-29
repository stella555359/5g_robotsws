*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/tshark_verifying.robot
Resource    CB008533_A_B9_keywords.robot
Resource    feature_keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/L3_Call.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot
Variables   feature_variables.py
Library     ta5g_file_system
Library     ta5g_throughput
Library     ta5g_setups_and_teardowns
Library     testsuite/Wroclaw/RRM/resources/scout_report.py

Suite Teardown    Compress Test Logs

Test Setup    Run Keywords    Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
      ...     AND    Custom Prepare Test Environement And Reach Onair
      ...     iphy_xml=${CURDIR}/config/iphy_6Cells_AHLOA_AEHC_AHFIB_AHCA_mixed_ABIO_FDD_TDD_20_40_MHz_dlmimomode70.xml
      ...     scfc=scfc_6Cells_AHLOA_AEHC_AHFIB_AHCA_mixed_ABIO_FDD_TDD_20_40_MHz_dlmimomode70.xml
      ...     egate_cfg=${CURDIR}/config/config_A_B9b.cfg
      ...     flags=@{swconfig_flags_list}
      ...     AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown        Run Keywords
      ...            Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
      ...     AND    Find Errors
      ...     AND    Add Scout Scf Id To Test Data
      ...     AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
      ...     AND    Collect Selected Debug Files
      ...            output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
      ...            omit_collectors=sos_report

*** Variables ***
@{swconfig_flags_list}=                   ${rdSupportSimultaneousHarqAckCsi}    ${rdMergedMeasGapSetupAndDrxRelease}
${rdMergedMeasGapSetupAndDrxRelease}=     0x890046=1 # rdMergedMeasGapSetupAndDrxRelease
${rdSupportSimultaneousHarqAckCsi}=       0x59003E = 1
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=       f1ap.SCell_ToBeSetupMod_List == 3
${F1AP_SCELL_TO_ADD_MOD_LIST_FTT}=        nr-rrc.sCellToAddModList == 3 && nr-rrc.physCellId == 51 &&
                                     ...  nr-rrc.physCellId == 52 && nr-rrc.physCellId == 55
${SCELL_TO_BE_RELEASED}=                  nr-rrc.sCellToReleaseList == 1
${DRX_CONFIG}=                            nr-rrc.milliSeconds == 6 && nr-rrc.drx_Config == 1
${F1AP_A1_FOR_SCELL_CHANGE_SETUP_FTT}=    nr-rrc.measId == 10 && nr-rrc.measObjectId == 1
${F1AP_5QI_1&5_ESTABLISHMENT}=            f1ap.fiveQI == 5 && f1ap.fiveQI == 1
${F1AP_A2_FOR_SCELL_RELEASE_SETUP}=       nr-rrc.measId == 5 && nr-rrc.measId == 6 && nr-rrc.measId == 7
@{FAULT_IDS}=                             6450    4383
*** Test Cases ***
CB008533_A_B9b_VoNR_call_added_along_data_call_setup_and_before_SCell_Addition_FDD_FDD_TDD_TDD
    Attach UE With PDU Session Setup And Verify DRX Is Configured   ue_id=1
    Verify 5QI 1&5 Establishment
    Verify ICS On NGAP
    Start Data DL and UL Traffic    qfi=1
    Start Vonr DL and UL Traffic    qfi=2
    ${scell_addition}=     Send A1 Measurement With Capture    ue_id=1    a1_meas_id=3    a1_rsrp=95
    Verify Successful 4CC SCell Addition     message_to_check=${scell_addition}
                                        ...  packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST_FTT}
    Verify DRX is not Reconfigured      message_to_check=${scell_addition}
    Verify A2 Measurement For SCell Release Setup     message_to_check=${scell_addition}
                                        ...  packet_filter=${F1AP_A2_FOR_SCELL_RELEASE_SETUP}
    ${first_tdd_scell_release}=    Send A2 Measurement With Capture    ue_id=1    a2_meas_id=7     scell_id=3
    Verify Successful 4CC SCell Release   message_to_check=${first_tdd_scell_release}
    Verify DRX Is Not Reconfigured    message_to_check=${first_tdd_scell_release}
    ${second_tdd_scell_release}=    Send A2 Measurement With Capture    ue_id=1    a2_meas_id=6     scell_id=2
    Verify Successful 4CC SCell Release   message_to_check=${second_tdd_scell_release}
    Verify DRX Is Not Reconfigured    message_to_check=${second_tdd_scell_release}
    Verify A1 Measurement For SCell Change Setup    message_to_check=${second_tdd_scell_release}
                                               ...  packet_filter=${F1AP_A1_FOR_SCELL_CHANGE_SETUP_FTT}
    ${fdd_scell_release}=    Send A2 Measurement With Capture    ue_id=1    a2_meas_id=5     scell_id=1
    Verify Successful 4CC SCell Release   message_to_check=${fdd_scell_release}
    Verify DRX Is Not Reconfigured    message_to_check=${fdd_scell_release}




