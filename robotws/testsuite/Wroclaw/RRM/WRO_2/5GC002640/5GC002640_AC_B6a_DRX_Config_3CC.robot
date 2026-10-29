*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia

Library      ta5g_delta
Library      ta5g_enb
Library      testsuite/Wroclaw/RRM/resources/scout_report.py

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource    ../5GC001167/feature_keywords.robot
Resource    ../CB008717/feature_keywords.robot
Resource     ../keywords/logging.robot

Variables   ../5GC001167/feature_variables.py
Variables    ../resources/custom_policy.py
Variables   ../5GC001167/feature_variables.py

Suite Setup      Run Keywords     Enable C-Plane Debug Logs       with_reboot=${false}
...   AND                         Update And Put Iphy Xml    input_filepath=${iphy_xml}
...   AND                         With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}
...   AND                         With Gnb Configuration    commissioning=${scfc}
...   AND                         Reach OnAir    lua_cfg=${cfg}

Test Setup                       Enable Tshark Verification


*** Variables ***
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=    f1ap.SCell_ToBeSetupMod_List == 2
${SCELL_TO_ADD_MOD_LIST_TF}=    nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 51 && nr-rrc.physCellId == 55
${SCELL_TO_ADD_MOD_LIST_TT}=     nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 52 && nr-rrc.physCellId == 55
${F1AP_RRC_RECONFIGURATION}=    f1ap.DLRRCMessageTransfer_element
${RRCRECONFIGURATIONCOMPLETE}=     nr-rrc.c1 == 1
${DRX_CONFIG}=      nr-rrc.drx_Config == 1
${SCELL_TO_BE_RELEASED}=    nr-rrc.sCellToReleaseList == 1
${LOGGING_POLICY}=       BASIC_POLICY
${iphy_xml}=             ${CURDIR}/config/iphy_AC_B6a.xml
${scfc}=                 scfc_AC_B6a.xml
${cfg}=                  ${CURDIR}/config/config_AC_B6a.cfg
${ue_id}=                1
@{SWCONFIG_FLAGS_LIST}=       ${rdMergedMeasGapSetupAndDrxRelease}

*** Test Cases ***
5GC002640_AC_B6a_DRX_Configuration_with_3CC_DL_CA_with_measurement_based_SCell_Addition_ICS_with_FDD_TDD_FDD
      Attach UE With PDU Session Setup And Verify DRX Is Configured   ue_id=1
      Send Data Traffic      ue_id=1    qfi=1    trf_id=1
      ${scell_addition}=    Send A1 Measurement With Capture  ue_id=1    a1_meas_id=3    a1_rsrp=90
      Verify Successful 3CC SCell Addition    message_to_check=${scell_addition}    packet_filter=${SCELL_TO_ADD_MOD_LIST_TF}
      Verify DRX Is Not Reconfigured    message_to_check=${scell_addition}
      ${tdd_scell_release}=    Send A2 Measurement With Capture    ue_id=1    a2_meas_id=5     scell_id=2
      Verify Successful 3CC SCell Release   message_to_check=${tdd_scell_release}
      Verify DRX Is Not Reconfigured    message_to_check=${tdd_scell_release}
      ${fdd_scell_release}=    Send A2 Measurement With Capture    ue_id=1    a2_meas_id=4     scell_id=1
      Verify Successful 3CC SCell Release   message_to_check=${fdd_scell_release}
      Verify DRX Is Not Reconfigured    message_to_check=${fdd_scell_release}
      [Teardown]    Run Keywords    Deregister Ue    ue_id=1
      ...    AND    Add Scout Scf Id To Test Data


5GC002640_AC_B6a_DRX_Configuration_with_3CC_DL_CA_with_measurement_based_SCell_Addition_ICS_with_FDD_TDD_TDD
      Find Scfc and Send Delta Commissioning    scfc_filename=delta_AC_B6a_case2.json
      Attach UE With PDU Session Setup And Verify DRX Is Configured   ue_id=2
      Send Data Traffic      ue_id=2    qfi=1    trf_id=1
      ${scell_addition}=    Send A1 Measurement With Capture  ue_id=2   a1_meas_id=3    a1_rsrp=75
      Verify Successful 3CC SCell Addition    message_to_check=${scell_addition}    packet_filter=${SCELL_TO_ADD_MOD_LIST_TT}
      Verify DRX Is Not Reconfigured    message_to_check=${scell_addition}
      ${tdd_scell2_release}=    Send A2 Measurement With Capture    ue_id=2    a2_meas_id=5     scell_id=2
      Verify Successful 3CC SCell Release   message_to_check=${tdd_scell2_release}
      Verify DRX Is Not Reconfigured    message_to_check=${tdd_scell2_release}
      ${tdd_scell1_release}=    Send A2 Measurement With Capture    ue_id=2    a2_meas_id=4    scell_id=1
      Verify Successful 3CC SCell Release   message_to_check=${tdd_scell1_release}
      Verify DRX Is Not Reconfigured    message_to_check=${tdd_scell1_release}
      [Teardown]    Run Keywords    Deregister Ue    ue_id=2
      ...    AND    Add Scout Scf Id To Test Data

*** Keywords ***

Attach UE With PDU Session Setup
    [Arguments]     ${ue_id}    ${gw_id}    ${pdu_id}
    Set Internal Traffic Type To UEs    ue_id=${ue_id}
    Attach Ue                           ue_id=${ue_id}
    Establish Pdu Session               ue_id=${ue_id}    gw_id=${gw_id}    pdu_id=${pdu_id}    nwslice=1

Send A1 Measurement
    [Arguments]    ${ue_id}    ${a1_meas_id}    ${a1_rsrp}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a1_meas_id} srsrp_nr\=${a1_rsrp} event\=A1
    ...    pass_regexp=message c1 : rrcReconfigurationComplete

Verify DRX Is Configured
    Verify Tshark For Single Message
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=${DRX_CONFIG}
    ...    number_of_messages=1

Send A2 Measurement
    [Arguments]    ${ue_id}    ${a2_meas_id}   ${scell}    ${a2_rsrp}=5
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a2_meas_id} scell\=${scell} srsrp_nr\=${a2_rsrp} event\=A2
    ...    pass_regexp=message c1 : rrcReconfigurationComplete

Send Data Traffic
     [Arguments]    ${ue_id}    ${qfi}    ${trf_id}
     Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} trf_id=${trf_id} mbps=150 dir=dl
     Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} trf_id=${trf_id} mbps=50 dir=ul
     Wait for Traffic to Stabilize

Verify DRX is not Reconfigured
    [Arguments]    ${message_to_check}
    Verify Tshark For Given Number Of Messages
   ...    alias=${message_to_check}
   ...    packet_filter=${DRX_CONFIG}
   ...    number_of_messages=0

Attach UE With PDU Session Setup And Verify DRX Is Configured
    [Arguments]   ${ue_id}    ${gw_id}=1    ${pdu_id}=1
    Perform Action And Wait For Given Tshark Message Number
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=${DRX_CONFIG} && ${UE}==${ue_id}
    ...    action=Attach UE With PDU Session Setup   ue_id=${ue_id}    gw_id=${gw_id}    pdu_id=${pdu_id}
    ...    packet_number=1

Send A1 Measurement With Capture
    [Arguments]   ${ue_id}    ${a1_meas_id}    ${a1_rsrp}
    Run Keyword And Return    With Message Capture    eth4   Send A1 Measurement    ue_id=${ue_id}    a1_meas_id=${a1_meas_id}    a1_rsrp=${a1_rsrp}

Verify Successful 3CC SCell Addition
   [Arguments]    ${message_to_check}    ${packet_filter}
    Verify Tshark For Single Message
    ...   alias=${message_to_check}
    ...   packet_filter= ${packet_filter}

Send A2 Measurement With Capture
    [Arguments]     ${ue_id}    ${a2_meas_id}    ${scell_id}
    Run Keyword And Return    With Message Capture    eth4   Send A2 Measurement    ue_id=${ue_id}    a2_meas_id=${a2_meas_id}    scell=${scell_id}

Verify Successful 3CC SCell Release
   [Arguments]    ${message_to_check}
    Verify Tshark For Single Message
    ...   alias=${message_to_check}
    ...   packet_filter= ${SCELL_TO_BE_RELEASED}

