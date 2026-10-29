*** Settings ***
Force Tags    CLOUD_5G_I_LOO_AP_LOOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65    CONFIGURED    CRT
...           SBTS00

Documentation    :copyright: Nokia
...              :authors: Dariusz Maciocha
...              :contact: dariusz.maciocha@nokia.com

Resource    testsuite/Wroclaw/RRM/resources/airphone/scripts/libraries_instances.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/CB008490/resources/feature_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/iphy/wireshark_plugin.robot
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Library     ta5g_syslog
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/airphone/resources/keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/DeltaFixer.py
Library     testsuite/Wroclaw/RRM/resources/syslog_checker.py
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/airphone/CB012439/resources/test_variables.py

Suite Setup    Run Keywords     Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...    AND     Send Delta Commissioning With Fixer    ${CURDIR}/config/delta_feature_activation.json
...    AND     Upload Fixed Iphy Plug
Test Teardown    Run Keywords     Add Scout Scf Id To Test Data
...         AND                   Stop Default Processes And Gather Logs    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...         AND                   Run Keyword If Test Passed    Find Suspicious Logs

*** Variables ***
@{mplane_cells}=    5    6    9    12

*** Test Cases ***
CB012439_A_B12_5QI_Criteria_Based_Measurement_Profile_Reconfiguration_Triggered_By_PDU_Session_Resource_Release
    [Setup]    Run Keywords    Reach Onair    lua_cfg=${CURDIR}/config/ab12.cfg    mplane_cells=${mplane_cells}
    ...    AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach UE    ue_id=51
    Establish PDU Session    ue_id=51    pdu_id=1    gw_id=51
    Execute Egate Command    cmd=ue_measurement_send_nr id=51 meas_id=1 event=A2 phycell_id=55 srsrp_nr=100 scell=1 scell_rsrp=20
    Sleep    2s
    Establish PDU Session    ue_id=51    pdu_id=2    gw_id=52
    Modify Pdu Session    ue_id=51    pdu_id=2    qos_to_add=6
    Release Pdu Session    ue_id=51    pdu_id=2
    Verify Msg Flow    ${A_B12}

CB012439_A_B12_ALT1_Unsuccesful_5QI_Criteria_Based_Meas_Profile_Reconfig_Triggered_By_PDU_Session_Release_And_Legacy_Cell_Parameter_Meas_Config
    [Setup]    Run Keywords    Send Delta Commissioning With Fixer    ${CURDIR}/config/delta_change_meas.json
    ...    AND    Trigger Site Reset
    ...    AND    Check Radios Availability
    ...    AND    Reach Onair    lua_cfg=${CURDIR}/config/ab12_alt1.cfg    mplane_cells=${mplane_cells}
    ...    AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Execute Egate Command    cmd=set_pdu_param ue=51 pdu=2 trf_type=internal
    Attach UE    ue_id=51
    Establish PDU Session    ue_id=51    pdu_id=1    gw_id=51
    Establish PDU Session    ue_id=51    pdu_id=2    gw_id=52
    Execute Egate Command    cmd=trf_data_start ue=51 pdu=2 qfi=1 dir=dl kbps=64
    Sleep    3s
    Modify Pdu Session    ue_id=51    pdu_id=1    qos_to_add=6
    Modify Pdu Session    ue_id=51    pdu_id=1    qos_to_del=5
    Release Pdu Session    ue_id=51    pdu_id=1
    Verify Msg Flow    ${A_B12_ALT}

CB012439_C_B3_ICS_A2_Configuration_For_Redirection_And_Handover_With_Default_Mobility_Profile_5QI_Mismatch
    [Setup]    Run Keywords    Send Delta Commissioning With Fixer    ${CURDIR}/config/delta_mobility_profile.json
    ...    AND    Trigger Site Reset
    ...    AND    Check Radios Availability
    ...    AND    Reach Onair    lua_cfg=${CURDIR}/config/ab12.cfg    mplane_cells=${mplane_cells}
    ...    AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach UE    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Sleep    2s
    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Verify Syslog For Correct Prints    ${OUTPUT_DIR}/${TEST_NAME}    ${SYSLOG_MOBILITY_PROFILE}
    Wait For Next Full PM Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55157C00033  1  NRMOP_SA_PROFILE_SELECTED_01
    ...    M55157C00034  0  NRMOP_SA_PROFILE_SELECTED_02
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}

*** Keywords ***
Verify Msg Flow
    [Arguments]    ${MSGS}
    FOR    ${msg}    IN    @{MSGS}
        ${length}=    Get Length    ${msg}
        IF    ${length} != 2    Verify Tcpdump Log    packet_filter=${msg}
        ...    ELSE    Verify Tcpdump Log    packet_filter=${msg}[0]    number_of_messages=${msg}[1]
    END

Tshark Verification
    [Arguments]     ${packet_filter}   ${alias}    ${number_of_messages}=1    ${relation_symbol}= ==
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=default
