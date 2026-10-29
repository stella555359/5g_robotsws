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
...            AND             Wait For Next Full Pm Interval


Test Teardown    Add Scout Data Info To Testcase


*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=      FULL_POLICY
${rd_WA_skip_freq_validation}=        0x600036=0
@{SWCONFIG_FLAGS_LIST}=        ${rd_WA_skip_freq_validation}
${BASIC_SETUP}=         ${CURDIR}/config/wts_6733_B_B4_sim_eNB.cfg
${SCFC}=                full_scfc_CB006733_B_B33.xml
${GNB_ID}=              2
${ENB_ID}=              13
${PCELL_ID}=            4
${UE_ID}=               4
${PDU_ID}=              3
${COUNTER_ID}=          M55118C00031
${COUNTER_NAME}=        A4_SCELL_ADDED_SA
${LOCAL_MOID}=          PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
${new_file}=          ${CURDIR}/config/packet_iphy.lua
${target_path}=       /home/ute/.local/lib/wireshark/plugins/packet_iphy.lua


*** Test Cases ***
CB006733-B_B33_MFBI_5GC001416_interaction_SCell_in_alternative_band_A4_measurement_for_FR1_SCell_Addition_not_configured_for_the_SCell_frequency_layer
    Attach UE And Verify Whether Alternative Band For Cell1 Is Not Configured
    ...   ue_id=${UE_ID}    cell_id=${PCELL_ID}    enb_id=${GNB_ID}    pdu_id=${PDU_ID}    gw_id=3

    Trigger A4 RSRP Measurement And Start Traffic For Establish 2CC For Cell2
    ...    ue_id=${UE_ID}    pci=52    meas_id=2    nrsrp_nr=95    pdu_id=${PDU_ID}

    Verify PM Counter A4_SCELL_ADDED_SA
    ...    cell_id=${PCELL_ID}    counter_id=${COUNTER_ID}    counter_name=${COUNTER_NAME}    local_moid=${LOCAL_MOID}    condition=1


*** Keywords ***
Attach UE And Verify Whether Alternative Band For Cell1 Is Not Configured
    [Arguments]    ${ue_id}    ${cell_id}    ${enb_id}    ${pdu_id}    ${gw_id}
    Create UE Alias    alias=UE_${UE_ID}    ue_id=${ue_id}    id_type=wts_5g
    ${A4_BANDS} =    Catenate
    ...    (measObjectToAddModList is present) and (length(measObjectToAddModList) eq 4) and
    ...    (reportConfigToAddModList is present) and (length(reportConfigToAddModList) eq 3) and (eventId contains (eventA4 is present)) and
    ...    (measIdToAddModList is present) and (length(measIdToAddModList) eq 5) and
    ...    (measGapConfig is present)
    Expect Message Flow
    ...    UE_${UE_ID}:NR-RRC_RRCReconfiguration
    ...    UE_${UE_ID}:NR-RRC_RRCReconfigurationComplete
    ...    UE_${UE_ID}:NR-RRC_RRCReconfiguration (${A4_BANDS})
    ...    UE_${UE_ID}:NR-RRC_RRCReconfigurationComplete
    ...    alias=A4_band_ver   overall_timeout=20

    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${enb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}

    Flow occurred as expected    alias=A4_band_ver


Trigger A4 RSRP Measurement And Start Traffic For Establish 2CC For Cell2
    [Arguments]    ${ue_id}    ${pci}    ${meas_id}    ${nrsrp_nr}    ${pdu_id}
    Trigger A4 RSRP Measurement    ue_id=${ue_id}    pci=${pci}    meas_id=${meas_id}    nrsrp_nr=${nrsrp_nr}
    Start Specific Data DL Traffic    ue_id=${UE_ID}   pdu_id=${PDU_ID}    mbps_per_trf_id=175    last_trf_id=6
    Stabilization Time
    Stop All Data Traffics    ue_id=${UE_ID}
    Deregister UE    ue_id=${UE_ID}

Deregister UE
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off

Verify PM Counter A4_SCELL_ADDED_SA
    [Arguments]    ${cell_id}    ${counter_id}    ${counter_name}    ${local_moid}    ${condition}
    Verify Pm Counters 6733
    ...    cell_id=${cell_id}    counter_id=${counter_id}    counter_name=${counter_name}    local_moid=${local_moid}    condition=${condition}

Remove And Replace File
    [Arguments]    ${new_file}    ${target_path}
    Log  \n==== Replace file to solve the problem with dissecting nr-rrc packets with ute-wireshark 4.4.7 ====  console=True
    # Ensure the new file exists
    File Should Exist    ${new_file}

    # Remove the target file if it exists
    Run Keyword And Ignore Error    Remove File    ${target_path}

    # Copy the new file to the target location
    Copy File    ${new_file}    ${target_path}

Start Specific Data DL Traffic
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi}=1    ${mbps_per_trf_id}=175    ${first_trf_id}=1    ${last_trf_id}=6
    FOR    ${INDEX}  IN RANGE    ${first_trf_id}   ${last_trf_id}+1
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=${INDEX} dir=dl mbps=${mbps_per_trf_id}
    END

