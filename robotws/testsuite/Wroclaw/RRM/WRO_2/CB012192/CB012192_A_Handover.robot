*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...       CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Marcin Holowinski
...              :contact: Marcin.Holowinski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_tshark
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_pm_counters

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Remove And Replace File    new_file=${new_file}    target_path=${target_path}
...            AND             Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Backup And Modify Swconfig File    parameters_list=@{SWCONFIG_FLAGS_LIST}
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_lpq_AVQL.xml
...            AND             Find Scfc And Fix And Send Full Commissioning    scfc_filename=scfc_ho.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/basic.lua
...            AND             Get Next Unpacked Full Pm Counters File

Suite Teardown    Run Keywords    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${rdComponentBitMapProfile}=    0x5808FF=2
@{SWCONFIG_FLAGS_LIST}=         ${rdComponentBitMapProfile}
${LOGS_COMPRESSION}=            ${True}
${LOGGING_POLICY}=              FULL_POLICY
${UE_ID}=                       1
${NRCGI}=                       311:489|0x01
${new_file}=          ${CURDIR}/config/packet_iphy.lua
${target_path}=       /home/ute/.local/lib/wireshark/plugins/packet_iphy.lua

*** Test Cases ***
CB012192_A_Handover
    Prepare UE And Enviroment For Handover    ue_id=${UE_ID}
    Attach UE And Establish PDU Session    ue_id=${UE_ID}    cell_id=3    enb_id=3
    Perform UE Handover    ue_id=${UE_ID}    target_cell_pci=52    target_beam_id=1

    [Teardown]    Run Keywords    Get PM Counter File For Analysis
    ...    AND    Deregister UE    ue_id=1
    ...    AND    Add Scout Data Info To Testcase

*** Keywords ***
Attach UE And Establish PDU Session
    [Arguments]    ${ue_id}    ${cell_id}    ${enb_id}=1    ${pdu_id}=1    ${gw_id}=1    ${pdu_session_setup_timeout}=15
    ...    ${nwslice}=1
    Attach UE    ue_id=${ue_id}    cell=${cell_id}    enb=${enb_id}
    ...    pass_regexp=Received REGISTRATION COMPLETE from UE
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=${nwslice}
    ...    timeout=${pdu_session_setup_timeout}
    ...    pass_regexp=UE${ue_id}: Established PDU session ID=${pdu_id} using PDU Gateway ID=
	Sleep    2

Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Prepare UE And Enviroment For Handover
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Execute Egate Command    cmd=gnb_param id=3 measEvent=A3
    Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=3 cell=1
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    cmd=ue_history_information_list_add_ngran id=${ue_id} gnb_id=3 cell_type=medium nrcgi=${NRCGI} time_ue_stayed_in_cell=100
    Execute Egate Command    cmd=ue_history_information_list_add_ngran id=${ue_id} gnb_id=2 cell_type=medium nrcgi=${NRCGI} time_ue_stayed_in_cell=100
    Execute Egate Command    cmd=ue_history_information_list_add_ngran id=${ue_id} gnb_id=3 cell_type=medium nrcgi=${NRCGI} time_ue_stayed_in_cell=100
    Execute Egate Command    cmd=ue_history_information_list_add_ngran id=${ue_id} gnb_id=2 cell_type=medium nrcgi=${NRCGI} time_ue_stayed_in_cell=100
    Execute Egate Command    cmd=ue_history_information_list_add_ngran id=${ue_id} gnb_id=2 cell_type=medium nrcgi=${NRCGI} time_ue_stayed_in_cell=100
    Execute Egate Command    cmd=ue_history_information_list id=${ue_id} action=commit
    Execute Egate Command    cmd=ue_enb_param id=${ue_id} ue_history_list=1

Perform UE Handover
    [Arguments]    ${ue_id}    ${target_cell_pci}    ${target_beam_id}    ${event}=A3
    ${ue_meas_report}=  Catenate  SEPARATOR=
    ...                ue_measurement_send_nr id=${ue_id} meas_id=3 event=${event} srsrp_nr=19 srsrq_nr=10 phycell_id=${target_cell_pci} nrsrp_nr=85
    ...                \ nrsrq_nr=31 rs_type=ssb index=${target_beam_id} nrs_result=30:20:5
    Execute Egate Command And Wait For Data    cmd=${ue_meas_report}
    ...                                        pass_regexp=XN Handover Successfully completed at Source

Get PM Counter File For Analysis
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55306C02002    1      RA_ATT_DED_PRMBL_SSB_01
        ...    M55306C09014    1      RA_CFRA_MSG2_SENT
        ...    M55306C05001    1      RA_COMP_DED_PRMBL
        ...    M55305C00002    >1     DL_SERV_BEAM_ID_BEAM_01
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
        ...    file_path=${pm_counter_file}

Remove And Replace File
    [Arguments]    ${new_file}    ${target_path}
    Log  \n==== Replace file to solve the problem with dissecting nr-rrc packets with ute-wireshark 4.4.7 ====  console=True
    # Ensure the new file exists
    File Should Exist    ${new_file}

    # Remove the target file if it exists
    Run Keyword And Ignore Error    Remove File    ${target_path}

    # Copy the new file to the target location
    Copy File    ${new_file}    ${target_path}
