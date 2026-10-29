*** Settings ***
Force Tags    CONFIGS_5G_SW_WRO/3_CELLS_7893_E/intra_freq/iphy_and_scfc.yaml    SBTS00    SBTS23R1
...           RAN_5G    CONFIGURED    CRT    SBTS23R2    RAN_5G_TDD    CLOUD_5G_I_BOO_AP_LOO    PY310
...           NoResUsage    RF50    SANSA_FS_ECPRI_CMWV_FDD+TDD_GMC

Documentation    :copyright: Nokia
...              :authors: Jakub Wroblewski
...              :contact: jakub.1.wroblewski@nokia.com

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource     CB007893_E_keywords.robot
Library    ta5g_ue_measurements
Library      ta5g_testline_management
Variables    ta5g_tshark

Suite Setup    Run Keywords    Setup Intra Env
...            AND             Start Default Logging
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_3c_intra_fr_SRB3.lua
...			   AND			   Perform Parameter Commissioning    parameter=srb3SupportEnabled    value=true

Suite Teardown    Run Keywords    Detach Ue    ue_id=1
...			   	  AND			  Perform Parameter Commissioning    parameter=srb3SupportEnabled    value=false
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${RRC_RECONFIGURATION_A1_EVENT}=    nr-rrc.eventA1_element && nr-rrc.RRCReconfiguration_element && f1ap

*** Test Cases ***
CB007893_E_B3_1_Configuration_Of_A1_Measurement_On_Target_PSCell_For_SCell_Addition_During_Intra_gNB_Intra_Freq_PSCell_Change_For_NSA_With_SRB3
    [Documentation]    This test checks the SgNB behavior, when intra-gNB intra-frequency PSCell change is performed
    ...                and the target PSCell is configured with A1 measurement for SCell addition.

    Configure lowBound and upBound
    Attach Ue To Enb    ue_id=1
    Start Gnb Addition Procedure    ue=1    target_gnb=2    target_cells=2    bearer=2    dc_type=split_scg
    ...                             timeout=15    pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA
    Verify Ngap Messages       packet_filter=${SN_STATUS_TRANSFER}    continue_on_failure=${False}
    Send Ue Measurement Nr    ue_id=1    meas_id=1    event=A5    phycell_id=52    nrs_result=31:19:0    index=0
    ...                       nrsrp_nr=31    srsrp_nr=19    pass_regexp=Proxy \\(eNB 2 cell 3\\) reported successful RA
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATION_A1_EVENT}
    Add Scout External Execution ID To Reporting Portal

*** Keywords ***
Configure lowBound and upBound
    Execute Egate Command    cmd=enb_endc_param id=1 serving_cell_index_range_scg=8:14
