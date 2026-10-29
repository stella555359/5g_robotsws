*** Settings ***
Force Tags    CONFIGS_5G_SW_WRO/3_CELLS_7893_E/inter_freq/iphy_and_scfc.yaml    SBTS00    SBTS23R1
...           RAN_5G    CONFIGURED    CRT    SBTS23R2    RAN_5G_TDD    CLOUD_5G_I_BOO_AP_LOO    PY310
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Anna Gibala-Wojtal, Jakub Wróblewski
...              :contact: anna.gibala-wojtal@nokia.com

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource     CB007893_E_keywords.robot
Library      ta5g_ue_measurements
Library      ta5g_testline_management
Variables    ta5g_tshark

Suite Setup       Run Keywords    Setup Inter Env
...               AND             Start Default Logging
...               AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_3c_inter_fr.lua


Suite Teardown    Run Keywords    Detach Ue    ue_id=1
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${RRC_CONFIGURATION_A3_A5_A1HO_EVENT}=    x2ap && nr-rrc.measIdToAddModList == 4 && nr-rrc.measId == 3 && nr-rrc.measId == 4 && nr-rrc.measId == 5
${RRC_REMOVAL_A2_EVENT}=    x2ap &&  nr-rrc.measIdToRemoveList == 1 && nr-rrc.MeasId == 1
${RRC_PRESENCE_A1_SCELL_ADD_EVENT}=   x2ap && nr-rrc.measId == 2
${RRC_REMOVAL_A3_A5_A1HO_EVENT}=    x2ap && nr-rrc.measIdToRemoveList == 3 && nr-rrc.MeasId == 3 && nr-rrc.MeasId == 4 && nr-rrc.MeasId == 5
${RRC_CONFIGURATION_A2_EVENT}=     x2ap && nr-rrc.measIdToAddModList == 2

*** Test Cases ***
CB007893_E_B2_1_A2_Measurement_For_Mobility_Configured_In_Parallel_With_A1_Measurement_On_PSCell_For SCell_Addition_For_NSA_Without_SRB3
    [Documentation]    This test checks the SgNB behavior, when inter-frequency PSCell change is performed with A2/A5 event

    Configure lowBound and upBound
    Attach Ue To Enb    ue_id=1
    Start Gnb Addition Procedure    ue=1    target_gnb=2    target_cells=3    bearer=2    dc_type=split_scg
    ...                             timeout=15    pass_regexp=Proxy \\(eNB 2 cell 3\\) reported successful RA
	Configure Measurement Gap


    Send Ue Measurement Nr    ue_id=1    meas_id=1    event=A2   phycell_id=51   nrs_result=31:0:0    index=0
    ...                       nrsrp_nr=31    srsrp_nr=30

	Verify Tcpdump Log    packet_filter=${RRC_CONFIGURATION_A3_A5_A1HO_EVENT}
    Verify Tcpdump Log    packet_filter=${RRC_REMOVAL_A2_EVENT}

    Send Ue Measurement Nr    ue_id=1    meas_id=3   event=A1    phycell_id=51  nrs_result=31:0:0    index=0
    ...                       nrsrp_nr=31    srsrp_nr=40

	Verify Tcpdump Log    packet_filter=${RRC_REMOVAL_A3_A5_A1HO_EVENT}
	Verify Tcpdump Log    packet_filter=${RRC_CONFIGURATION_A2_EVENT}    number_of_messages=2
	Verify Tcpdump Log    packet_filter=${RRC_PRESENCE_A1_SCELL_ADD_EVENT}    number_of_messages=3

*** Keywords ***
Configure lowBound and upBound
    Execute Egate Command    cmd=enb_endc_param id=1 serving_cell_index_range_scg=8:14
Configure Measurement Gap
	Execute Egate Command    cmd=ue_enb_param id=1 drx_config=off measurement_gap=gp0:0 gap_trigger=gnb_triggered

