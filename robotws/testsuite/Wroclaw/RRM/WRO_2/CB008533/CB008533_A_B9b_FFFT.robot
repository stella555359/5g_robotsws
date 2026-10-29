*** Settings ***
Force Tags    RAN_5G_FDD
    ...    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD

Documentation    :copyright: Nokia

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource    ../5GC001167/feature_keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/CB008533_A_B9_keywords.robot
Variables   ../5GC001167/feature_variables.py
Library     ta5g_throughput

Suite Setup    Run Keywords    Prepare Test Environement And Reach Onair
    ...		                     iphy_xml=${CURDIR}/config/iphy_A_B9.xml
    ...		      	             scfc=full_scfc_A_B9.xml
    ...                          egate_cfg=${CURDIR}/config/config_A_B9b.cfg
    ...                          cell_number=6
    ...        AND               Backup And Modify Swconfig File    parameters_list=@{swconfig_flags_list}
    ...        AND               Execute Egate Command    cmd=x2_link_up_enb enb=1 target=2
Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}
Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{swconfig_flags_list}=                   ${rdSupportSimultaneousHarqAckCsi}
${rdSupportSimultaneousHarqAckCsi}=       0x59003E = 1
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=       f1ap.SCell_ToBeSetupMod_List == 3
${F1AP_SCELL_TO_ADD_MOD_LIST_FFT}=        nr-rrc.sCellToAddModList == 3 && nr-rrc.physCellId == 51 &&
                                     ...  nr-rrc.physCellId == 54 && nr-rrc.physCellId == 55
${SCELL_TO_BE_RELEASED}=                  nr-rrc.sCellToReleaseList == 1
${DRX_CONFIG}=                            nr-rrc.milliSeconds == 6 && nr-rrc.drx_Config == 1
${F1AP_A1_FOR_SCELL_CHANGE_SETUP_FFT}=    nr-rrc.measId == 9 && nr-rrc.measObjectId == 1
${F1AP_5QI_1&5_ESTABLISHMENT}=            f1ap.fiveQI == 5 && f1ap.fiveQI == 1
${F1AP_A2_FOR_SCELL_RELEASE_SETUP}=       nr-rrc.measId == 5 && nr-rrc.measId == 6 && nr-rrc.measId == 7
*** Test Cases ***
CB008533_A_B9b_VoNR_call_added_along_data_call_setup_and_before_SCell_Addition_FDD_FDD_FDD_TDD
    Lock Cell And Check
    Attach UE With PDU Session Setup And Verify DRX Is Configured   ue_id=1
    Verify 5QI 1&5 Establishment
    Verify ICS On NGAP
    Start Data DL and UL Traffic    qfi=1
    Start Vonr DL and UL Traffic    qfi=2
    ${scell_addition}=     Send A1 Measurement With Capture    ue_id=1    a1_meas_id=3    a1_rsrp=95
    Verify Successful 4CC SCell Addition     message_to_check=${scell_addition}
                                        ...  packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST_FFT}
    Verify A2 Measurement For SCell Release Setup     message_to_check=${scell_addition}
                                        ...  packet_filter=${F1AP_A2_FOR_SCELL_RELEASE_SETUP}
    Verify DRX is not Reconfigured      message_to_check=${scell_addition}
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
    [Teardown]     Run Keywords    Deregister Ue    ue_id=1    AND    Stop Default Logging


