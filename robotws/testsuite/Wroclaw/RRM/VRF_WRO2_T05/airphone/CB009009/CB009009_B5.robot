*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    PY311
...           CONFIGURED    CRT    SBTS23R2    RAN_5G_TDD    RAN_5G    SBTS00
...           SBTS23R1    NoResUsage

Documentation    :copyright: Nokia
...              :author:Joachim Otto
...              :contact:joachim.otto@nokia.com

Resource     CB009009_Keywords_And_Variables.robot

Suite Setup    Run Keywords       Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND                Start Multiple Vms Interfaces
...            AND                Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND                Find Scfc and Send Delta Commissioning    scfc_filename=delta_CB009009_B_intra_freq_SA.json
...            AND                Reach Onair    lua_cfg=${CURDIR}/config/egate_CB009009_intra_freq.lua
...            AND                Setup X2 Link    initiator_device=1     complementary_device=3
...            AND                Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs


Suite Teardown    Run Keywords    Stop Multiple Vms Interfaces
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_CB009009_B_intra_freq_SA.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB009009_B_B5_IntraNR_IntraFrequency_ANR_SA_Disable_UL_Proactive_Grant_Scheduling_For_The_UE_To_Allow_IntraNR_IntraFrequency_NR_CGI_Reporting

    [Documentation]    This Test Case verifies the gNB behaviour when actUlTxSkip and actDisableUlProactGrantAnr flags are
    ...                enabled in SCF to investigate SkipUplinkTxDynamic IE during dedicated DRX setup using ANR DRX profile
    ...                for intra-NR ANR NR-CGI reporting.
    ...                Checks are based on F1AP interface. The message UE Context Modification Response with NRCGI report has IE
    ...                skipUplinkTxDynamic value FALSE
    ...                Used configuration is Stand Alone mode and required intra frequency A5 handover, no SRB3 enabled
    ...	               5G_RAN_USR_RRM_16139

    [Setup]             Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}

    Attach Ue                        ue_id=1
    Establish PDU Session With Traffic            ue_id=1    pdu_id=1   gw_id=1
    Send UE Measurement NR Event A5 With Aligned Meas ID    ue_id=1    carrier_freq=636576    srsrp_nr=19
    ...                                                     phycell_id=51    nrsrp_nr=68    pass_regexp=None
    Verify Tcpdump Log               packet_filter=${DRX_DEFAULT_SETUP}         number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log               packet_filter=${DEDICATED_DRX_SETUP_AND_SKIP_UL_TX_DYNAMIC}        relation_symbol= >=
    Verify Existing NRREL

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=1
    ...           AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_remove_NRREL.json
    ...           AND             Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
