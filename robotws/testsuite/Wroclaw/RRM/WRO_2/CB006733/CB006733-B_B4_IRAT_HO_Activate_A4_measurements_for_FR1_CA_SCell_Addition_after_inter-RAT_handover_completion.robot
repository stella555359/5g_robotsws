*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Pawel Bicz
...              :contact: pawel.bicz@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     taf/ul/ettf/main.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ./verify_ta_messaging/verify_UEContextModification.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB006733.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_enb
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_pm_counters
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Library      ./verify_ta_messaging/CB006733.py

Suite Setup    Run Keywords    Remove And Replace File    new_file=${new_file}    target_path=${target_path}
...            AND             Backup And Modify Swconfig File    parameters_list=@{SWCONFIG_FLAGS_LIST}
...            AND             Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733_basic.xml
...            AND             With Gnb Configuration    commissioning=${SCFC}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             With Simulated Network Interface    name=eth3:GNB3_NG_ADDR    ip=10.0.1.3/24
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}

Test Teardown    Add Scout Data Info To Testcase

*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=      FULL_POLICY
${rd_WA_skip_freq_validation}=        0x600036=0
@{SWCONFIG_FLAGS_LIST}=        ${rd_WA_skip_freq_validation}
${BASIC_SETUP}=         ${CURDIR}/config/wts_6733_B_B4_sim_eNB.cfg
${SCFC}=                full_scfc_CB006733_B_B4.xml
${GNB_ID}=              2
${ENB_ID}=              13
${MEAS_ID}=             10
${PCELL_ID}=            4
${UE_ID}=               4
${PDU_4}=               4
${GW_ID_4}=             4
${PLMN}=                311:489
${COUNTER_ID}=          M55118C00030
${COUNTER_NAME}=        A4_MEASUR_ACT_SCELL_ADD_SA
${LOCAL_MOID}=          PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
${SUPERVISION_TIMER_FR1} =    9
${NRSRP_NR} =           19
${NRSRQ_NR}=            17
${new_file}=          ${CURDIR}/config/packet_iphy.lua
${target_path}=       /home/ute/.local/lib/wireshark/plugins/packet_iphy.lua


*** Test Cases ***
CB006733-B_B4_IRAT_HO_Activate_A4_measurements_for_FR1_CA_SCell_Addition_after_inter-RAT_handover_completion
    Attach UE And Verify Establishing PDU Session With Following A2 Measurement Trigger For HO    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_4}    gw_id=${GW_ID_4}    supervision_timer=${SUPERVISION_TIMER_FR1}
    Trigger B2 Measurement    ue_id=${UE_ID}    nrsrp_nr=${NRSRP_NR}    nrsrq_nr=${NRSRQ_NR}    cell_id=${ENB_ID}    meas_id=${MEAS_ID}
    Perform Inter RAT Handover    ue_id=${UE_ID}    targer_gnb=${GNB_ID}   target_cell=${PCELL_ID}    plmn=${PLMN}
    Verify PM Counter For Configuration With Simulated eNB
    ...    cell_id=${PCELL_ID}    counter_id=${COUNTER_ID}    counter_name=${COUNTER_NAME}    local_moid=${LOCAL_MOID}


*** Keywords ***
Remove And Replace File
    [Arguments]    ${new_file}    ${target_path}
    Log  \n==== Replace file to solve the problem with dissecting nr-rrc packets with ute-wireshark 4.4.7 ====  console=True
    # Ensure the new file exists
    File Should Exist    ${new_file}

    # Remove the target file if it exists
    Run Keyword And Ignore Error    Remove File    ${target_path}

    # Copy the new file to the target location
    Copy File    ${new_file}    ${target_path}
