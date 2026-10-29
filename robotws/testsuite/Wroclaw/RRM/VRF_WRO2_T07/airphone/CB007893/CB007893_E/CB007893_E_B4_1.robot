*** Settings ***
Force Tags    CONFIGS_5G_SW_WRO/3_CELLS_7893_E/intra_freq/iphy_and_scfc.yaml    SBTS00    SBTS23R1
...           RAN_5G    CONFIGURED    CRT    SBTS23R2    RAN_5G_TDD    CLOUD_5G_I_BOO_AP_LOO    PY310
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Anna Gibala-Wojtal, Jakub Wroblewski
...              :contact: anna.gibala-wojtal@nokia.com

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource     CB007893_E_keywords.robot
Library    ta5g_ue_measurements
Library      ta5g_testline_management
Variables    ta5g_tshark

Suite Setup    Run Keywords    Setup Intra Env
...            AND             Start Default Logging
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_3c_intra_fr_SRB3.lua
...			   AND			   Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-3    parameter=a1MeasSCellAddEnabled    value=none

Suite Teardown    Run Keywords    Detach Ue    ue_id=1
...			      AND			  Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-3    parameter=a1MeasSCellAddEnabled    value=rsrp
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${RRC_ADDITION_A1_EVENT}=    x2ap && nr-rrc.RRCReconfiguration_element && nr-rrc.eventA1_element
${RRC_REMOVAL_A1_EVENT}=     x2ap && nr-rrc.RRCReconfiguration_element && nr-rrc.MeasId == 2 && nr-rrc.measIdToRemoveList == 1

*** Test Cases ***
CB007893_E_B4_1_Remove_A1_Measurement_On_PSCell_For_SCell_Addition_During_PSCell_Change_Intra_Freq_without_SRB3
    [Documentation]    This test checks the SgNB behavior, when intra-gNB intra-frequency PSCell change is performed
    ...                when event A5 is sent- event A1 for Scell Addition should be removed

    Configure lowBound and upBound
    Attach Ue To Enb    ue_id=1
    Start Gnb Addition Procedure    ue=1    target_gnb=2    target_cells=2    bearer=2    dc_type=split_scg
    ...                             timeout=15    pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA
    Verify Ngap Messages       packet_filter=${SN_STATUS_TRANSFER}    continue_on_failure=${False}
    Send Ue Measurement Nr    ue_id=1    meas_id=1    event=A5    phycell_id=52    nrs_result=68:19:0    index=0
    ...                       nrsrp_nr=68    srsrp_nr=19    pass_regexp=Proxy \\(eNB 2 cell 3\\) reported successful RA
    Verify Tcpdump Log    packet_filter=${RRC_ADDITION_A1_EVENT}
    Verify Tcpdump Log    packet_filter=${RRC_REMOVAL_A1_EVENT}

*** Keywords ***
Configure lowBound and upBound
    Execute Egate Command    cmd=enb_endc_param id=1 serving_cell_index_range_scg=8:14
