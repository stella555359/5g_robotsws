*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia

Resource    ../keywords/tshark_verifying.robot
Resource    ../5GC001167/feature_keywords.robot

Suite Setup     Prepare Test Environement And Reach Onair
    ...             iphy_xml=${CURDIR}/config/iphy_AC_B3b.xml
    ...             scfc=scfc_ac_b3b.xml
    ...             egate_cfg=${CURDIR}/config/config_AC_B3b.cfg
    ...             cell_number=1

Test Setup        Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...                 AND       Attach Ue And Trigger Scells Addition
Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${UU_SCELL_RELEASE}=    nr-rrc.SCellIndex == 2

*** Test Cases ***
5GC002640-AC-B3b-A2_SCell_triggered_SCell_release_in_3CC_with_measurement_activation_for_SCell_Change
    Trigger Scell Release
    Verify Scell Release

*** Keywords ***
Attach UE With PDU Session Setup
    Set Internal Traffic Type To UEs    ue_id=1
    Attach Ue                           ue_id=1
    Establish Pdu Session               ue_id=1   pdu_id=1    gw_id=1    nwslice=1

Attach Ue And Trigger Scells Addition
    Attach UE With PDU Session Setup
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A1 srsrp_nr=85
    Sleep    2s

Trigger Scell Release
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=5 event=A2 scell=2 scell_rsrp=5
    Sleep    2s
    Stop Capturing    alias=${DEFAULT_UU_TSHARK_ALIAS}
    Sleep    2s

Verify Scell Release
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=${UU_SCELL_RELEASE}
    ...    number_of_messages=1

Wait For Airphone To Stabilize
    Sleep    180s
