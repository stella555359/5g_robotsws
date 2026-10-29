*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    PY311
...           CONFIGURED    CRT    SBTS23R2    RAN_5G_TDD    RAN_5G    SBTS00
...           SBTS23R1    NoResUsage

Documentation    :copyright: Nokia
...              :author:Piotr Pinderak, Katarzyna Wisniewska
...              :contact:piotr.pinderak@nokia.com, katarzyna.wisniewska@nokia.com

Resource     CB009009_Keywords_And_Variables.robot

Suite Setup    Run Keywords       Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND                Start Multiple Vms Interfaces
...            AND                Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND                Find Scfc and Send Delta Commissioning    scfc_filename=delta_CB009009_intra_freq.json
...            AND                Trigger Site Reset
...            AND                Check Radios Availability
...            AND                Reach Onair    lua_cfg=${CURDIR}/config/egate_CB009009_intra_freq.lua
...            AND                Setup X2 Link    initiator_device=1     complementary_device=3
...            AND                Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Multiple Vms Interfaces
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_CB009009_intra_freq.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB009009_A_EC12_4_Intra_NR_Intra_Frequency_ANR_NSA_Failure_DRX_Release_No_UE_Response_On_RRC_Reconfiguration_Without_MeNB_SRB3
    [Documentation]    This Test Case verifies the gNB behaviour when UE  does not respond with RRC Reconfiguration
    ...                Complete (timerRRCGuard expires) during dedicated DRX setup using ANR DRX profile for intra-NR ANR
    ...                NR-CGI reporting. HO fails and existing default DRX configuration needs to be released.
    ...		           Checks are based on F1AP interface where UeContextModificationRequest and UeContextModificationResponse
    ...		           messages with IE drxConfigurationIndicatior/drx-Config got the value release after unsuccessful inter-freq HO.
    ...                Used configuration is SA mode, SRB3 is enabled. The procedure requires intra-frequency A5 handover
    ...                5G_RAN_USR_RRM_16032

    [Setup]    Run Keywords    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}
    ...        AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_CB009009_SRB3_Enabled.json

    Attach Ue To Enb                 ue_id=11
    Start Gnb Addition Procedure     ue=11    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                              pass_regexp=${SUCCESSFUL_GNB_ADD}
    Set Ue NR RRC Reconf Param       ue_id=11    contains=drx_release    value=drop
    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=11    carrier_freq=636576    srsrp_nr=19    phycell_id=51    nrsrp_nr=68
    ...                              pass_regexp=${FAILED_HO_REGEXP}
    Verify Tcpdump Log               packet_filter=${MODIFICATION_REQ_DRX_RELEASE}
    Verify Tcpdump Log               packet_filter=${MODIFICATION_RESP_DRX_RELEASE}

    [Teardown]    Run Keywords    Detach Ue    ue_id=11
    ...           AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_CB009009_SRB3_Disabled.json
    ...           AND             Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB009009_A_EC14_1_Intra_NR_Intra_Freq_ANR_NSA_Dedicated_ANR_DRX_Profile_Setup_In_UE_No_UE_Response_Without_SRB3
    [Documentation]    This Test Case verifies the gNB behaviour when UE does not respond  with RRC Reconfiguration
    ...                Complete (timerRRCGuard expires) during dedicated DRX setup using ANR DRX profile for intra-NR ANR
    ...		           NR-CGI reporting. HO fails and existing DRX configuration needs to be released.
    ...		           Checks are based on F1AP and X2AP interfaces.
    ...		           F1AP:UeContextModificationRequest and F1AP:UeContextModificationResponse messages with IE
    ...		           drxConfigurationIndicatior/drx-Config got the value release after unsuccessful inter freq HO.
    ...		           Rest of the checkpoints are on X2AP where we are expecting DRX releases in
    ...		           X2AP:SgNBModificationRequired message and X2AP:SgNBModificationRequired with NRCGI report IE.
    ...                Used configuration is NSA mode, SRB3 is not enabled. The procedure requires intra-frequency A5 handover.
    ...                5G_RAN_USR_RRM_16050

    [Setup]    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}

    Attach Ue To Enb                 ue_id=12
    Start Gnb Addition Procedure     ue=12    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                              pass_regexp=${SUCCESSFUL_GNB_ADD}
    Set Ue RRC Reconf Param          ue_id=12    contains=report_cgi    value=drop
    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=12    carrier_freq=636576    srsrp_nr=19    phycell_id=51    nrsrp_nr=68
    ...                              timeout=20
    ...                              pass_regexp=${FAILED_HO_REGEXP}
    Verify Tcpdump Log               packet_filter=${MODIFICATION_REQ_DRX_RELEASE}
    Verify Tcpdump Log               packet_filter=${MODIFICATION_RESP_DRX_RELEASE}
    Verify Tcpdump Log               packet_filter=${X2AP_SGNB_MODIFICATION_REQUIRED} && ${DRX_RELEASE}
    Verify Tcpdump Log               packet_filter=${X2AP_SGNB_MODIFICATION_CONFIRM_RRC_RECONFIG_COMPLETE}    number_of_messages=2
    Verify Tcpdump Log               packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST} && ${REPORT_CGI_FOR_CELL}
    Verify Tcpdump Log               packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && ${DRX_CONFIG_SETUP}    number_of_messages=1
    ...                              relation_symbol= >=
    Verify Tcpdump Log               packet_filter=${X2AP_SGNB_MODIFICATION_REQUIRED} && ${NRCGI_REPORT_MEASUREMENT_OBJECT_CONFIGURATION}


    [Teardown]    Run Keywords    Detach Ue    ue_id=12
    ...           AND             Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB009009_A_EC15_2_Intra_NR_Intra_Frequency_ANR_NSA_Dedicated_ANR_DRX_Profile_Setup_In_UE_PCI_Resolution_Failed_CGI_InfoNR_Without_SRB3
    [Documentation]    This Test Case verifies the gNB behaviour when UE sends Measurement Report with NoSIB1 IE in CGI Info
    ...                during dedicated DRX setup. After invalid Measurement Report gNB is obligated to rollback to default
    ...		           configuration - in this case release of dedicated DRX is required and setup of default DRX.
    ...		           Checks are based on X2AP interface where we are expecting default/dedicated drx setup and release twice
    ...		           (first at the beginning and second to restore configuration) – SgNBModificationRequired message
    ...		           with IE drx_Config with values Setup and Release.
    ...		           Also X2AP: Measurement Report with IE cgi-Info including value noSIB1 needs to be checked.
    ...                Used configuration: NSA mode, SRB3 not enabled. Intra-frequency A5 handover is required during the procedure.
    ...                5G_RAN_USR_RRM_16108

    [Setup]    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}

    Set Ue RRC Reconf Param          ue_id=13    contains=report_cgi    value=report_noSIB1
    Attach Ue To Enb                 ue_id=13
    Start Gnb Addition Procedure     ue=13    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                              pass_regexp=${SUCCESSFUL_GNB_ADD}    wait_time=2
    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=13    carrier_freq=636576    srsrp_nr=19    phycell_id=51    nrsrp_nr=68
    ...                              pass_regexp=UE13: Hit on RRC Reconfiguration Rule presence=report_cgi delay=0 action=report_noSIB1
    Verify Ngap Messages             packet_filter=${DEFAULT_DRX_SETUP}    number_of_messages=2
    Verify Ngap Messages             packet_filter=${DEDICATED_DRX_SETUP}
    Verify Ngap Messages             packet_filter=${DRX_RELEASE}    number_of_messages=2
    Verify Ngap Messages             packet_filter=${NR_RRC_MEASUREMENT_REPORT_WITH_NOSIB1_IE}

    [Teardown]    Run Keywords    Detach Ue    ue_id=13
    ...           AND             Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB009009_A_B107_1_Inter_Gnb_Mobility_For_NSA_Opt_3x_Failure_After_Successful_Dedicated_DRX_Profile_Setup_X2AP_SgNB_Change_Refuse
    [Documentation]    This Test verifies gNB behaviour when Inter gNB Intra-Frequency handover failed due to SgNB Change Refuse
    ...                during dedicated DRX setup.
    ...                gNB should relese dedicated DRX profile and rollback to default configuratuion - in this case
    ...		           it requires setup default DRX configuration.
    ...		           Checks are based on X2AP interface – triggerd fault X2AP:SgnBChangeRefuse, default/dedicated drx
    ...		           setup and release twice (first at the beginning and second to restore legacy configuration)
    ...		           SgNBModificationRequired message with IE drx_Config with values Setup and Release.
    ...		           Used configuration: NSA mode, SRB3 not enabled. Procedure requires intra-frequency A5 handover.
    ...                N/A, No 5G_RAN_USR_RRM_X requirement

    [Setup]    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}

    Attach Ue To Enb                 ue_id=14
    Start Gnb Addition Procedure     ue=14    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                              pass_regexp=${SUCCESSFUL_GNB_ADD}    wait_time=2
    Trigger SgNB Change Refuse
    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=14    carrier_freq=636576    srsrp_nr=19    phycell_id=52    nrsrp_nr=68
    Verify Ngap Messages             packet_filter=${DEFAULT_DRX_SETUP}    number_of_messages=2
    Verify Ngap Messages             packet_filter=${DEDICATED_DRX_SETUP}
    Verify Ngap Messages             packet_filter=${DRX_RELEASE}    number_of_messages=2
    Verify Ngap Messages             packet_filter=${X2AP_SGNB_CHANGE_REFUSE}

    [Teardown]    Run Keywords    Detach Ue    ue_id=14
    ...           AND             Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB009009_B_B3_2_IntraNR_IntraFrequency_ANR_NSA_Disable_UL_Proactive_Grant_Scheduling_For_The_UE_To_Allow_NRCGI_Reporting_Without_SRB3
    [Documentation]    This Test Case verifies the gNB behaviour when actUlTxSkip and actDisableUlProactGrantAnr flags are activated
    ...                during dedicated DRX setup using ANR DRX profile for intra-NR ANR NR-CGI reporting.
    ...		           Except for common default and dedicated drx setup on X2AP:SgNBModificationRequired message checks are based on
    ...		           F1AP interface where message UE Context Modification Response has IE skipUplinkTxDynamic including expected
    ...		           value FALSE during NRCGI report with dedicated DRX.
    ...		           Used configuration: NSA mode, no SRB3 enabled. Procedure requires intra-frequency A5 handover.
    ...                5G_RAN_USR_RRM_15990;5G_RAN_USR_RRM_16111

    [Setup]    Run Keywords    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}
    ...        AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_skipULTXDynamic.json

    Attach Ue To Enb                 ue_id=15
    Start Gnb Addition Procedure     ue=15    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                              pass_regexp=${SUCCESSFUL_GNB_ADD}    wait_time=2
    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=15    carrier_freq=636576    srsrp_nr=19    phycell_id=51    nrsrp_nr=68
    ...                              pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA
    Verify Ngap Messages             packet_filter=${DEFAULT_DRX_SETUP}    number_of_messages=2
    Verify Ngap Messages             packet_filter=${DEDICATED_DRX_SETUP} && ${SKIP_UL_TX_DYNAMIC}
    Verify Tcpdump Log               packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && ${SKIP_UL_TX_DYNAMIC}    number_of_messages=2
    Verify Existing NRREL

    [Teardown]    Run Keywords    Detach Ue    ue_id=15
    ...           AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_remove_NRREL.json
    ...           AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_skipULTXDynamic_revert.json
    ...           AND             Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
