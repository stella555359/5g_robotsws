*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia

Resource    ../5GC001167/feature_keywords.robot
Resource    ../CB008717/feature_keywords.robot

Variables   ../5GC001167/feature_variables.py
Variables    ../resources/custom_policy.py

Library      ta5g_testline_management

Suite Setup    Run Keywords
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         With Iphy Configuration         config=${iphy_xml}


Test Setup         Run Keywords              Run Setup
...    AND         Enable Tshark Verification

Suite Teardown    On failure    Deregister UE    ${UE_ID}

*** Variables ***
${LOGGING_POLICY}=       BASIC_POLICY
${iphy_xml}=             ${CURDIR}/config/iphy_6Cells_AHLOA_AEHC_AHFIB_AHCA_mixed_ABIO_FDD_TDD_20_40_MHz_dlmimomode70.xml
${scfc}=                 full_scfc_A_B8a.xml
${cfg}=                  ${CURDIR}/config/egate_A_B8a.cfg
${ON_FAILURE}=           IGNORE
${UE_ID}=                1
${GNB_ID}=               2
${DRX_CONFIG}=           nr-rrc.drx_Config == 1
${DRX_PROFILE_1}=        (nr-rrc.milliSeconds == 5)  && (nr-rrc.drx_onDurationTimer == 1) && (nr-rrc.drx_InactivityTimer == 8)
      ...                && (nr-rrc.drx_RetransmissionTimerDL == 0) && (nr-rrc.drx_RetransmissionTimerUL == 0)
      ...                && (nr-rrc.drx_LongCycleStartOffset == 3)
${SCELL_TO_ADD_MOD_LIST_FTF}=    nr-rrc.sCellToAddModList == 3 && nr-rrc.physCellId == 51 && nr-rrc.physCellId == 52
      ...                 && nr-rrc.physCellId == 54
@{SWCONFIG_FLAGS_LIST}=       ${rdMergedMeasGapSetupAndDrxRelease}

*** Test Cases ***

CB008533_A_B8a_Interworking_with_DRX
     Setup devices aliases
     Attach UE With PDU Session Setup And Verify DRX Profile1 Is Configured  ue_id=${UE_ID}
     Send Data Traffic    trf_id=1    mbps_dl=5    mbps_ul=3
     ${scell_addition}=    Send A1 Measurement With Capture  a1_meas_id=3    a1_rsrp=90
     Verify Successful 4CC SCell Addition    message_to_check=${scell_addition}    packet_filter=${SCELL_TO_ADD_MOD_LIST_FTF}
     Verify DRX Is Not Reconfigured    message_to_check=${scell_addition}
     Increase nonGBR Data Traffic In DL
     Verify All SCells Are Activated
     [Teardown]     Run Keywords    Deregister Ue    ue_id=1    AND    Stop Default Logging

*** Keywords ***
Send A1 Measurement With Capture
    [Arguments]   ${a1_meas_id}    ${a1_rsrp}
    Run Keyword And Return    With Message Capture    eth4   Send A1 Measurement    ue_id=${UE_ID}
    ...                       a1_meas_id=${a1_meas_id}    a1_rsrp=${a1_rsrp}

Attach UE With PDU Session Setup
    [Arguments]     ${ue_id}    ${gw_id}    ${pdu_id}
    Set Internal Traffic Type To UEs    ue_id=${UE_ID}
    Attach Ue                           ue_id=${UE_ID}
    Establish Pdu Session               ue_id=${UE_ID}    gw_id=${gw_id}    pdu_id=${pdu_id}    nwslice=1

Send A1 Measurement
    [Arguments]    ${ue_id}    ${a1_meas_id}    ${a1_rsrp}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a1_meas_id} srsrp_nr\=${a1_rsrp} event\=A1
    ...    pass_regexp=message c1 : rrcReconfigurationComplete

Attach UE With PDU Session Setup And Verify DRX Profile1 Is Configured
    [Arguments]   ${ue_id}    ${gw_id}=1    ${pdu_id}=1
    Perform Action And Wait For Given Tshark Message Number
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=${DRX_CONFIG} && ${UE}==${ue_id} && ${DRX_PROFILE_1}
    ...    action=Attach UE With PDU Session Setup   ue_id=${ue_id}    gw_id=${gw_id}    pdu_id=${pdu_id}
    ...    packet_number=1

Send Data Traffic
     [Arguments]      ${trf_id}    ${mbps_dl}    ${mbps_ul}    ${ue_id}=${UE_ID}    ${qfi}=1
     Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} trf_id=${trf_id} mbps=${mbps_dl} dir=dl
     Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} trf_id=${trf_id} mbps=${mbps_ul} dir=ul
     Sleep    5s

Verify Successful 4CC SCell Addition
   [Arguments]    ${message_to_check}    ${packet_filter}
    Verify Tshark For Single Message
    ...   alias=${message_to_check}
    ...   packet_filter= ${packet_filter}

Verify DRX is not Reconfigured
    [Arguments]    ${message_to_check}
    Verify Tshark For Given Number Of Messages
    ...    alias=${message_to_check}
    ...    packet_filter=${DRX_CONFIG}
    ...    number_of_messages=0

Increase nonGBR Data Traffic In DL
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=${UE_ID} qfi=1 trf_id=2 mbps=150 dir=dl
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=${UE_ID} qfi=1 trf_id=3 mbps=150 dir=dl

Verify All SCells Are Activated
     Sleep    10
     Execute Egate Command
     ...    cmd=ue_stats_nr id=1 scell=0-3
     ...    pass_regexp=(CellIndex-[0-4][\\s][\\s][1-9]\.*\\n){4}


