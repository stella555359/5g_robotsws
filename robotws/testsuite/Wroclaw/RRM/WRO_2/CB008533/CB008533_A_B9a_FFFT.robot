*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/CB008533_A_B9_keywords.robot
Resource    ../5GC001167/feature_keywords.robot
Resource    ../keywords/L3_Call.robot
Variables   ../5GC001167/feature_variables.py
Library     taf.ul.ettf.logging
Library     ta5g_throughput
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Variables    ../resources/custom_policy.py

Test Setup    Run Keywords    Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
      ...     AND    Custom Prepare Test Environement And Reach Onair
      ...     iphy_xml=${CURDIR}/config/iphy_6Cells_AHLOA_AEHC_AHFIB_AHCA_mixed_ABIO_FDD_TDD_20_40_MHz_dlmimomode70.xml
      ...     scfc=scfc_6Cells_AHLOA_AEHC_AHFIB_AHCA_mixed_ABIO_FDD_TDD_20_40_MHz_dlmimomode70.xml
      ...     egate_cfg=${CURDIR}/config/config_A_B9a.cfg
      ...     flags=@{swconfig_flags_list}

Test Teardown        Run Keywords
      ...            Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
      ...     AND    Add Scout Scf Id To Test Data

*** Variables ***
${LOGGING_POLICY}=                        FULL_POLICY
@{swconfig_flags_list}=                   ${rdSupportSimultaneousHarqAckCsi}    ${rdMergedMeasGapSetupAndDrxRelease}
${rdSupportSimultaneousHarqAckCsi}=       0x59003E = 1
${rdMergedMeasGapSetupAndDrxRelease}=        0x890046=1 # rdMergedMeasGapSetupAndDrxRelease
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=       f1ap.SCell_ToBeSetupMod_List == 3
${F1AP_SCELL_TO_ADD_MOD_LIST_FFT}=        nr-rrc.sCellToAddModList == 3 && nr-rrc.physCellId == 51 &&
                                     ...  nr-rrc.physCellId == 54 && nr-rrc.physCellId == 55
${SCELL_TO_BE_RELEASED}=                  nr-rrc.sCellToReleaseList == 1
${DRX_CONFIG}=                            nr-rrc.milliSeconds == 7 && nr-rrc.drx_Config == 1
${DRX_PROFILE2_CONFIG}=                   nr-rrc.milliSeconds == 6 && nr-rrc.drx_Config == 1
${F1AP_A1_FOR_SCELL_CHANGE_SETUP_FTT}=    nr-rrc.measId == 10 && nr-rrc.measObjectId == 1
${F1AP_A1_FOR_SCELL_CHANGE_SETUP_FFT}=    nr-rrc.measId == 9 && nr-rrc.measObjectId == 1
${F1AP_5QI_5_ESTABLISHMENT}=              f1ap.fiveQI == 5
${F1AP_5QI_1_ESTABLISHMENT}=              f1ap.fiveQI == 1
${F1AP_A2_FOR_SCELL_RELEASE_SETUP}=       nr-rrc.measId == 5 && nr-rrc.measId == 6 && nr-rrc.measId == 7
@{FAULT_IDS}=                             6450    4383
*** Test Cases ***
CB008533_A_B9a_VoNR_call_added_before_SCellAddition_FDD_FDD_FDD_TDD_but_after_data_call
    Lock Cell And Check
    Attach UE With PDU Session Setup And Verify DRX Is Configured   ue_id=1
    Verify 5QI-5 Establishment
    Verify ICS On NGAP
    Start Data DL and UL Traffic    qfi=1
    Perform GBR Qosflow Establishment
    Verify 5QI-1 Establishment
    Verify DRX Is Reconfigured
    Start Vonr DL and UL Traffic    qfi=2
    ${scell_addition}=     Send A1 Measurement With Capture    ue_id=1    a1_meas_id=3    a1_rsrp=95
    Verify Successful 4CC SCell Addition     message_to_check=${scell_addition}
                                        ...  packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST_FFT}
    Verify DRX is not Reconfigured      message_to_check=${scell_addition}
    Verify A2 Measurement For SCell Release Setup     message_to_check=${scell_addition}
                                        ...  packet_filter=${F1AP_A2_FOR_SCELL_RELEASE_SETUP}
    ${tdd_scell_release}=    Send A2 Measurement With Capture    ue_id=1    a2_meas_id=7     scell_id=3
    Verify Successful 4CC SCell Release   message_to_check=${tdd_scell_release}
    Verify DRX Is Not Reconfigured    message_to_check=${tdd_scell_release}
    Verify A1 Measurement For SCell Change Setup    message_to_check=${tdd_scell_release}
                                               ...  packet_filter=${F1AP_A1_FOR_SCELL_CHANGE_SETUP_FFT}
    ${first_fdd_scell_release}=    Send A2 Measurement With Capture    ue_id=1    a2_meas_id=6     scell_id=2
    Verify Successful 4CC SCell Release   message_to_check=${first_fdd_scell_release}
    Verify DRX Is Not Reconfigured    message_to_check=${first_fdd_scell_release}
    ${second_fdd_scell_release}=    Send A2 Measurement With Capture    ue_id=1    a2_meas_id=5     scell_id=1
    Verify Successful 4CC SCell Release   message_to_check=${second_fdd_scell_release}
    Verify DRX Is Not Reconfigured    message_to_check=${second_fdd_scell_release}



