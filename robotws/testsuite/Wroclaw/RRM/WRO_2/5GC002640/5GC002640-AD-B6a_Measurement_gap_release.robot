*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource    ../5GC001167/feature_keywords.robot

Suite Setup     Run Keywords    Prepare Test Environement And Reach Onair
    ...                             iphy_xml=${CURDIR}/config/iphy_AC_B3b.xml
    ...                             scfc=scfc_ac_b3b.xml
    ...                             egate_cfg=${CURDIR}/config/config_AD_B6a.cfg
    ...                             cell_number=1
    ...          AND            Find Scfc and Send Delta Commissioning    scfc_filename=delta_AD_B6a.json

Test Setup        Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...                 AND       Attach Ue And Trigger Measurement Gap Configuration
Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${GAP_RELEASE}=    nr-rrc.gapUE == 0
${DRX_CONFIG}=    nr-rrc.drx_Config == 1

*** Test Cases ***
5GC002640-AD-B6a_Measurement_gap_release
    Trigger Measurement Gap Release
    Verify Measurement Gap Release
    Verify DRX Configuration

*** Keywords ***
Attach UE With PDU Session Setup
    Set Internal Traffic Type To UEs    ue_id=1
    Attach Ue                           ue_id=1
    Establish Pdu Session               ue_id=1   pdu_id=1    gw_id=1    nwslice=1

Attach Ue And Trigger Measurement Gap Configuration
    Attach UE With PDU Session Setup
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 srsrp_nr=40 event=A2
    Sleep    2s

Trigger Measurement Gap Release
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=4 srsrp_nr=40 event=A1
    Sleep    2s
    Stop Capturing    alias=${DEFAULT_UU_TSHARK_ALIAS}
    Sleep    2s

Verify Measurement Gap Release
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=${GAP_RELEASE}
    ...    number_of_messages=1

Verify DRX Configuration
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=${DRX_CONFIG}
    ...    number_of_messages=1

Wait For Airphone To Stabilize
    Sleep    240s
