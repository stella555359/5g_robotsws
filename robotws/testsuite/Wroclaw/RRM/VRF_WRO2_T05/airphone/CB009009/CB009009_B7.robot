*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...           PY311    CONFIGURED    CRT    SBTS23R2    RAN_5G_TDD    RAN_5G    SBTS00
...           SBTS23R1    NoResUsage

Documentation    :copyright: Nokia
...              :author: Dominik Borkowski
...              :contact: dominik.borkowski@nokia.com

Resource     CB009009_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Multiple Vms Interfaces
...            AND             Get Iphy Xml File    output_filepath=${OUTPUT_DIR}/iphy.xml
...            AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/iphy.xml
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_CB009009_SA_inter_freq.json
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB009009_inter_freq.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Multiple Vms Interfaces
...               AND             Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${OUTPUT_DIR}/iphy.xml
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_CB009009_SA_inter_freq.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Trigger Site Reset

*** Test Cases ***
CB009009_B_B7_1_Intra_NR_Inter_Frequency_ANR_SA_Disable_UL_Proactive_Grant_Scheduling_To_Allow_Intra_NR_Inter_Frequency_NRCGI_Measurement_Reporting
    [Documentation]    This Test Case verifies that during the setup of the dedicated DRX (NR_CGI reporting),
    ...                the parameter skipUplinkTxDynamic has the value False.
    ...                Inter-Freq handover with events A2 and then A5 finished successfully.
    ...                Object NRREL should be created after ANR procedure.
    ...                For easier recognition, the default drx has the drx-retransmissionTimer set to 16 slots and the dedicated one to 0.
    ...                5G_RAN_USR_RRM_16189

    [Setup]    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}
    Attach Ue                        ue_id=1
    Establish PDU Session With Traffic    ue_id=1    pdu_id=1   gw_id=1
    Send Ue Measurement Nr Event A2 Handover With Aligned Meas Id    ue_id=1    pcell_id=1    cell_type=SA    srsrp_nr=30
    ...                              pass_regexp=ServingCellMO is not present in CellGroupConfig
    Sleep    5s    reason=Delay between sending measurements
    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=1    carrier_freq=637152   srsrp_nr=19    trigger_type=RSRP
    ...                              phycell_id=51    nrsrp_nr=68    timeout=5
    ...                              pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Verify Tcpdump Log               packet_filter=${DRX_DEFAULT_SETUP}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log               packet_filter=${DEDICATED_DRX_SETUP_AND_SKIP_UL_TX_DYNAMIC}   number_of_messages=1    relation_symbol= >=
    Verify Existing NRREL

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=1
    ...           AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_remove_NRREL.json
    ...           AND             Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
