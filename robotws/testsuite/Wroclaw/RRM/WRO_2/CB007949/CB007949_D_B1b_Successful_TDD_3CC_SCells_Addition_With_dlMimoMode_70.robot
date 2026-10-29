*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    CB007949_keywords.robot
Resource    ../CB008717/feature_keywords.robot
Resource    ../keywords/messaging.robot

Variables   CB007949_messaging_filters.py
Variables    ../resources/custom_policy.py

Suite Setup    With Retry Context    1
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         With Iphy Configuration         config=${iphy_xml}
...    AND         Create SA Aliases    ue_id=${ue_id}    gNB_id=${gnb_id}

Test Setup         Run Keywords              Run Setup
...    AND         Enable Tshark Verification

Suite Teardown    On failure    Deregister UE    ${ue_id}

*** Variables ***
${LOGGING_POLICY}=       BASIC_POLICY
${iphy_xml}=             ${CURDIR}/config/iphy_D_B1b.xml
${scfc}=                 scfc_3TDD_100MHz_n77_2FDD.xml
${cfg}=                  ${CURDIR}/config/egate_DB1_case3.cfg
${ON_FAILURE}=           IGNORE
${ue_id}=           1
${pdu_id}=          1
${gw_id}=           1
${gnb_id}=          2
${a1_meas_id}=      1
${a1_rsrp}=         75
${a2_meas_id}=      3
${a2_rsrp}=         5
${scell}=           2

*** Test Cases ***
CB007949_D_B1b_Successful_TDD_3CC_SCells_Addition_With_dlMimoMode_70_And_All_3_TDD_Serving_Cells_Are_In_The_Same_Band_Alternative2_3
    Attach UE    ue_id=1
    ${pdu_session}=    Establish PDU Session Setup With Capture    ue_id=${ue_id}    pdu_id=${pdu_id}   gw_id=${gw_id}
    Set Test Variable    ${pdu_session}
    Verify Csi-IM and nzp-CSI-RS on RRC after PDU Session Setup
    Send A1 Measurement For SCell Addition And Verify CSI-RS And aCSI Allocation
    Send A2 Measurement For SCell Release And Verify CSI-RS And aCSI Allocation

*** Keywords ***
Send A1 Measurement For SCell Addition And Verify CSI-RS And aCSI Allocation
    Expect SCell Addition messages flow    ue_id=${ue_id}
    Execute Egate Command And Wait For Data
    ...     cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a1_meas_id} event\=A1 srsrp_nr\=${a1_rsrp}
    ...     pass_regexp=message c1 : rrcReconfigurationComplete
    Check if SCell Addition messages flow occured    ue_id=${ue_id}
    Verify Successful 3TT n77 SCell Addition
    Verify CSI-RS and ACSI after SCell Addition for PCell
    Verify CSI-RS and ACSI after SCell Addition for SCells

Verify CSI-RS and ACSI after SCell Addition for PCell
  Verify That Message Fulfills Query
    ...  ${PCell_csi_rs_and_aCSI_after_SCell_Addition}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify CSI-RS and ACSI after SCell Addition for SCells
   Verify That Message Fulfills Query
    ...  ${SCells_csi_rs_and_aCSI_after_SCell_Addition}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify Successful 3TT n77 SCell Addition
   Verify That Message Fulfills Query
    ...  ${added_SCells_for_TTT_CA_b77_in_RRC_Reconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Send A2 Measurement For SCell Release And Verify CSI-RS And aCSI Allocation
    Expect SCell Release messages flow    ue_id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a2_meas_id} event\=A2 srsrp_nr\=${a2_rsrp} scell\=${scell}
    ...    pass_regexp=message c1 : rrcReconfigurationComplete
    Check if SCell Release messages flow occured    ue_id=${ue_id}
    Verify Successful SCell Release and CSI-RS and aCSI Allocation

Verify Successful SCell Release and CSI-RS and aCSI Allocation
   Verify That Message Fulfills Query
    ...  ${PCell_and_SCell1_csi_rs_and_aCSI_after_SCell2_Release}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellRelease_UE${ue_id}



