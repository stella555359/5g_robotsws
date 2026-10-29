*** Settings ***
Force Tags    CRT    PY39    SBTS00    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD    TOOLS_PROFILE_TTI_LEGACY

Resource      resources/CB007219_resources.robot

Suite Setup     Setup suite environment
Suite Teardown  Clean suite environment

Documentation
...    author: Bartlomiej Kukla
...    contact: bartlomiej.kukla@nokia.com
...    Description: Suite description in QC

*** Variables ***
${scfc}=             SCFC_2.xml
${ap_xml}=           ${CURDIR}/config/iphy_2.xml
${lua_cfg_file}=     ${CURDIR}/config/wts_2.cfg
${swconfig_file}=    ${CURDIR}/config/gnb_swconfig.txt

${counters_CB13}=    SEPARATOR=
...    M55316C00042,M55114C00501,M55114C00502,M55115C01501,M55115C01502,M55118C02002,M55115C00009,M55115C00016,M55114C00022,
...    M55114C00029,M55118C04002,M55114C00016,M55114C00018
${counters_CB14}=    SEPARATOR=
...    M55316C00042,M55114C00501,M55114C00502,M55115C01501,M55115C01502,M55118C02002,M55115C00009,M55115C00016,M55114C00022,
...    M55114C00029,M55118C04002,M55114C00503,M55114C00504


*** Test Cases ***
CB007219-ET-CB13_successful_CA_setup_with_PScell_in_native_band_after_an_incoming_handover_when_the_candidate_PSCell_is_configured_with_MFBI
    [Tags]    CB13
    [Documentation]
    ...    1. This user scenario describes successful CA setup after an incoming handover when the candidate PSCell is
    ...       configured with MFBI.
    ...    Configuration:
    ...    SgNB is configured with Cell group containing candidate PSCell Cell0 and candidate SCells Cell1 and Cell2 with the below configuration.
    ...    F0, F1, F2 are contiguous.
    ...    5G-UE is attached to MeNB and is in EN-DC configuration with PSCell 1_1 on a different gNB.
    ...                        Cell1 Cell2 Cell3
    ...    frequency           F0 F1 F2
    ...    Bandwidth (MHz)     100 100 100
    ...    Native band         258 258 258
    ...    Alternative band    257 257 257
    ...    DL MIMO layers      4L 4L 4L
    ...    UL MIMO layers      2L 2L 2L
    ...    5G-UEs are statically positioned within the same gNB beam and with good radio condition
    ...    UE supports the following band configuration
    ...    BC#1
    ...    DL: n257H
    ...    UL: n257A
    ...    4 MIMO layers in DL and 2 MIMO layers in UL for each CC
    ...    BC#2
    ...    DL: n258H
    ...    UL: n258A
    ...    2 MIMO layers in DL and 2 MIMO layers in UL for each CC
    ...    2.Test Case Steps:
    ...        a. NSA UE11 attach to PScell and start traffic
    ...            ue_attach id=11
    ...            ue_dc_enb_start ue=11 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...            trf_data_start ue=11 id=2 dir=ul mbps=150 trf_id=1
    ...            trf_data_start ue=11 id=2 dir=dl mbps=150 trf_id=1
    ...        b. trigger A3 for intra-frequency HO from NR cell1 to gnb simulator.
    ...            ue_meas_cfg_disp id=11 meas_obj_type=nr
    ...            ue_measurement_send_nr id=11 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=48 nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=1
    ...                nrs_result=30:30:30
    ...        c. trigger A3 for intra-frequency HO from gnb simulator to NR cell1.
    ...            ue_measurement_send_nr id=12 meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=0
    ...                nrs_result=30:30:30
    ...        d. detach UE1
    ...            ue_detach id=11
    ...        e. NSA UE1 attach to PScell and start traffic
    ...            ue_attach id=11
    ...            ue_dc_enb_start ue=11 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...            trf_data_start ue=11 id=2 dir=ul mbps=150 trf_id=1
    ...            trf_data_start ue=11 id=2 dir=dl mbps=150 trf_id=1
    ...        f. trigger A2 A3 for inter-frequency HO from NR cell1 to gnb simulator.
    ...            ue_meas_cfg_disp id=11 meas_obj_type=nr
    ...            ue_measurement_send_nr id=11 meas_id=2 event=A2 srsrp_nr=11 srsrq_nr=11
    ...            ue_measurement_send_nr id=11 meas_id=4 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=49 nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=1
    ...                nrs_result=30:30:30
    ...        g. trigger A2 A3 for inter-frequency HO from gnb simulator to NR cell1.
    ...            ue_measurement_send_nr id=11 meas_id=5 event=A2 srsrp_nr=7 srsrq_nr=7
    ...            ue_measurement_send_nr id=11 meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=0
    ...                nrs_result=30:30:30
    ...        h. Check counters
    ...    3. Expected Results:
    ...        Step a: UE attach to cell1 with 2 SCells in DL with selected band combination CA_258H and CA_258A for DL and UL respectively.
    ...        Step b: HO successfully.
    ...        Step c: SgNB performs PSCell and SCell selection, choosing Cell1 as PSCell and Cell2 and Cell3 as SCells.
    ...        Step e: UE attach to cell1 with 2 SCells in DL with selected band combination CA_258H and CA_258A for DL and UL respectively.
    ...        Step f: HO successfully.
    ...        Step g: SgNB performs PSCell and SCell selection, choosing Cell1 as PSCell and Cell2 and Cell3 as SCells.

    [Setup]    Wait for next full pm interval
    UE attach to PScell with 2 SCells in DL with selected band combination and start traffic
    Trigger UE Intra-Frequency Inter-gNB HO NSA and verify traffic
    UE detach
    UE attach to PScell with 2 SCells in DL with selected band combination and start traffic
    Trigger UE Inter-Frequency Inter-gNB HO NSA and verify traffic
    Verify and report counters for CB13
    [Teardown]    Teardown_CB13

CB007219-ET-CB14_successful_CA_setup_with_PScell_in_alternative_band_after_an_incoming_handover_when_the_candidate_PSCell_is_configured_with_MFBI
    [Tags]    CB14
    [Documentation]
    ...    1. This user scenario describes successful CA setup after an incoming handover when the candidate PSCell is
    ...       configured with MFBI.
    ...    Configuration:
    ...    SgNB is configured with Cell group containing candidate PSCell Cell0 and candidate SCells Cell1 and Cell2 with the below configuration.
    ...    F0, F1, F2 are contiguous.
    ...    5G-UE is attached to MeNB and is in EN-DC configuration with PSCell 1_1 on a different gNB.
    ...                        Cell1 Cell2 Cell3
    ...    frequency           F0 F1 F2
    ...    Bandwidth (MHz)     100 100 100
    ...    Native band         258 258 258
    ...    Alternative band    257 257 257
    ...    DL MIMO layers      4L 4L 4L
    ...    UL MIMO layers      2L 2L 2L
    ...    5G-UEs are statically positioned within the same gNB beam and with good radio condition
    ...    UE supports the following band configuration
    ...    BC#1
    ...    DL: n257H
    ...    UL: n257A
    ...    4 MIMO layers in DL and 2 MIMO layers in UL for each CC
    ...    2.Test Case Steps:
    ...        a. NSA UE1 attach to PScell and start traffic
    ...            ue_attach id=12
    ...            ue_dc_enb_start ue=12 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...            trf_data_start ue=12 id=2 dir=ul mbps=150 trf_id=1
    ...            trf_data_start ue=12 id=2 dir=dl mbps=150 trf_id=1
    ...        b. trigger A3 for intra-frequency HO from NR cell1 to gnb simulator.
    ...            ue_meas_cfg_disp id=12 meas_obj_type=nr
    ...            ue_measurement_send_nr id=12 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=48 nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=1
    ...                nrs_result=30:30:30
    ...            ue_stats_nr id=12 type=pusch,pdsch scell=8-16
    ...        c. trigger A3 for intra-frequency HO from gnb simulator to NR cell1.
    ...            ue_measurement_send_nr id=12 meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=0
    ...                nrs_result=30:30:30
    ...            ue_stats_nr id=12 type=pusch,pdsch scell=8-16
    ...        d. detach UE1
    ...            ue_detach id=12
    ...        e. NSA UE1 attach to PScell and start traffic
    ...            ue_attach id=12
    ...            ue_dc_enb_start ue=12 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...            trf_data_start ue=12 id=2 dir=ul mbps=150 trf_id=1
    ...            trf_data_start ue=12 id=2 dir=dl mbps=150 trf_id=1
    ...        f. trigger A2 A3 for inter-frequency HO from NR cell1 to gnb simulator.
    ...            ue_meas_cfg_disp id=12 meas_obj_type=nr
    ...            ue_measurement_send_nr id=12 meas_id=2 event=A2 srsrp_nr=11 srsrq_nr=11
    ...            ue_measurement_send_nr id=12 meas_id=4 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=49 nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=1
    ...                nrs_result=30:30:30
    ...            ue_stats_nr id=12 type=pusch,pdsch scell=8-16
    ...        g. trigger A2 A3 for inter-frequency HO from gnb simulator to NR cell1.
    ...            ue_measurement_send_nr id=12 meas_id=5 event=A2 srsrp_nr=7 srsrq_nr=7
    ...            ue_measurement_send_nr id=12 meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=0
    ...                nrs_result=30:30:30
    ...            ue_stats_nr id=12 type=pusch,pdsch scell=8-16
    ...        h. Check counters
    ...    3. Expected Results:
    ...        Step a: UE attach to cell1 with 2 SCells in DL with selected band combination CA_257H and CA_257A for DL and UL respectively.
    ...        Step b: HO successfully.
    ...        Step c: SgNB performs PSCell and SCell selection, choosing Cell1 as PSCell and Cell2 and Cell3 as SCells.
    ...        Step e: UE attach to cell1 with 2 SCells in DL with selected band combination CA_257H and CA_257A for DL and UL respectively.
    ...        Step f: HO successfully.
    ...        Step g: SgNB performs PSCell and SCell selection, choosing Cell1 as PSCell and Cell2 and Cell3 as SCells.

    [Setup]    Setup_CB14
    UE attach to PScell with 2 SCells in DL with selected band combination and start traffic    ue_id=12
    Trigger UE Intra-Frequency Inter-gNB HO NSA and verify traffic    ue_id=12
    UE detach    ue_id=12
    UE attach to PScell with 2 SCells in DL with selected band combination and start traffic    ue_id=12
    Trigger UE Inter-Frequency Inter-gNB HO NSA and verify traffic    ue_id=12
    Verify and report counters for CB14
    [Teardown]    Teardown_CB14


*** Keywords ***
Setup suite environment
    Add required IP addresses
    Prepare suite environment
    ...    scfc=${scfc}
    ...    ap_xml=${ap_xml}
    ...    egate_config=${lua_cfg_file}
    ...    rad_params=${swconfig_file}
    ...    x2=False
    Create aliases

Add required IP addresses
    OperatingSystem.Run    sudo ip addr add 10.0.1.126/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.2.90/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.2.91/24 dev eth4

UE attach to PScell with 2 SCells in DL with selected band combination and start traffic
    [Arguments]    ${ue_id}=11
    Set up x2 links and ue and enb parameters    ue_id=${ue_id}
    UE Attach to target Cell    ue_id=${ue_id}
    Start traffic    ue_id=${ue_id}

Set up x2 links and ue and enb parameters
    [Arguments]    ${ue_id}=11
    Log to console    Setting up x2 links, ue and enb parameters
    #Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2    pass_regexp=ENB-1: X2AP Link with GNB-2
    #Execute Egate Command    cmd=enb_x2_link_up enb=1 target=3    pass_regexp=ENB-1: X2AP Link with GNB-3
    Sleep    1s
    Execute Egate Command    cmd=enb_endc_param id=1 allowed_bc_list_mrdc=1:1|2:1
    Execute Egate Command    cmd=ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered

Trigger UE Intra-Frequency Inter-gNB HO NSA and verify traffic
    [Arguments]    ${ue_id}=11
    Log to console    Triggering UE Intra-Frequency Inter-gNB HO NSA
    Send A3 measurment for intra-frequency HO from NR cell1 to gnb simulator    ue_id=${ue_id}
    Send A3 measurment for intra-frequency HO from gnb simulator to NR cell1    ue_id=${ue_id}
    Verify traffic    ue_id=${ue_id}    ul_scells=8    dl_scells=8,9,10

Send A3 measurment for intra-frequency HO from NR cell1 to gnb simulator
    [Arguments]    ${ue_id}=11    ${targetpci}=48    ${targetcell}=1
    Log to console    Sending A3 measurment for intra-frequency HO from NR cell1 to gnb simulator
    Execute Egate Command and wait for data    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${cmd_A3_1}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${targetpci}
    ...                        nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=1 nrs_result=30:30:30
    Execute egate command    cmd=${cmd_A3_1}    pass_regexp=(reported successful RA|eNB 3 cell ${targetcell})
    Sleep    1s

Send A3 measurment for intra-frequency HO from gnb simulator to NR cell1
    [Arguments]    ${ue_id}=11    ${sourcepci}=50    ${targetcell}=1
    Log to console    Sending A3 measurment for intra-frequency HO from gnb simulator to NR cell1
    ${cmd_A3_3}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${sourcepci}
    ...                        nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=0 nrs_result=30:30:30
    Execute egate command    cmd=${cmd_A3_3}    pass_regexp=(reported successful RA|eNB 2 cell ${targetcell})
    Sleep    1s

Trigger UE Inter-Frequency Inter-gNB HO NSA and verify traffic
    [Arguments]    ${ue_id}=11
    Log to console    Triggering UE Inter-Frequency Inter-gNB HO NSA
    Send A2 A3 measurments for inter-frequency HO from NR cell1 to gnb simulator    ue_id=${ue_id}
    Send A2 A3 measurments for inter-frequency HO from gnb simulator to NR cell1    ue_id=${ue_id}
    Verify traffic    ue_id=${ue_id}    ul_scells=8    dl_scells=8,9,10

Send A2 A3 measurments for inter-frequency HO from NR cell1 to gnb simulator
    [Arguments]    ${ue_id}=11    ${targetpci}=49    ${targetcell}=2
    Log to console    Sending A2 A3 measurments for inter-frequency HO from NR cell1 to gnb simulator
    Execute Egate Command and wait for data    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=(rrcReconfigurationComplete|eventId eventA3)
    Execute Egate Command    cmd=ue_enb_param id=${ue_id} measurement_gap=off
    ${cmd_A3_4}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=4 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${targetpci}
    ...                        nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=1 nrs_result=30:30:30
    Execute egate command    cmd=${cmd_A3_4}    pass_regexp=(reported successful RA|eNB 3 cell ${targetcell})
    Sleep    1s

Send A2 A3 measurments for inter-frequency HO from gnb simulator to NR cell1
    [Arguments]    ${ue_id}=11    ${sourcepci}=50    ${targetcell}=2
    Log to console    Sending A2 A3 measurments for inter-frequency HO from NR cell1 to gnb simulator
    Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=5 event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=(rrcReconfigurationComplete|eventId eventA3)
    ${cmd_A3_3}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${sourcepci}
    ...                        nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=0 nrs_result=30:30:30
    Execute egate command    cmd=${cmd_A3_3}    pass_regexp=(reported successful RA|eNB 2 cell ${targetcell})
    Sleep    1s

Verify and report counters for CB13
    Log to console    Verifying PM Counters
    Wait for next full pm interval
    ${pm_counters}=  get latest unpacked full pm counters file
    Set Test Variable  ${pm_counters}

    Verify last counters in file
    ...    M55316C00042     0    SCELL_CONF_ALT_BAND_NSA
    ...    M55114C00501     0    SGNB_NSA_ADMISSION_MFBI_REQ
    ...    M55114C00502     0    SGNB_NSA_ADMISSION_MFBI_SUCC
    ...    M55115C01501     0    SGNB_DU_NSA_ADMISS_MFBI_REQ
    ...    M55115C01502     0    SGNB_DU_NSA_ADMISS_MFBI_SUCC
    ...    M55118C02002     4    RRC_RECONF_2_SCELL_DL_ATT
    ...    M55115C00009     4    SGNB_DU_SCELL_2_ADMISSION_REQ
    ...    M55115C00016     4    SGNB_DU_SCELL_2_ADMISSION_SUCC
    ...    M55114C00022     4    SGNB_SCELL_2_ADMISSION_REQ
    ...    M55114C00029     4    SGNB_SCELL_2_ADMISSION_SUCC
    ...    M55118C04002    >0    UE_PSCELL_2_CONF_SCELL_DL
    ...    M55114C00016     2    SGNB_NSA_HO_ADMISSION_REQ
    ...    M55114C00018     2    SGNB_NSA_HO_ADMISSION_SUCC
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Get counters value and report to rp  counters=${counters_CB13}  filepath=${pm_counters}  localmoid=NRCELL-1

    Verify last counters in file
    ...    M55316C00042     0    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05002    >0    UE_SCELL_2_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     0    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05002    >0    UE_SCELL_2_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}

Verify and report counters for CB14
    Log to console    Verifying PM Counters
    Wait for next full pm interval
    ${pm_counters}=  get latest unpacked full pm counters file
    Set Test Variable  ${pm_counters}

    Verify last counters in file
    ...    M55316C00042     0    SCELL_CONF_ALT_BAND_NSA
    ...    M55114C00501     2    SGNB_NSA_ADMISSION_MFBI_REQ
    ...    M55114C00502     2    SGNB_NSA_ADMISSION_MFBI_SUCC
    ...    M55115C01501     4    SGNB_DU_NSA_ADMISS_MFBI_REQ
    ...    M55115C01502     4    SGNB_DU_NSA_ADMISS_MFBI_SUCC
    ...    M55118C02002     4    RRC_RECONF_2_SCELL_DL_ATT
    ...    M55115C00009     4    SGNB_DU_SCELL_2_ADMISSION_REQ
    ...    M55115C00016     4    SGNB_DU_SCELL_2_ADMISSION_SUCC
    ...    M55114C00022     4    SGNB_SCELL_2_ADMISSION_REQ
    ...    M55114C00029     4    SGNB_SCELL_2_ADMISSION_SUCC
    ...    M55118C04002    >0    UE_PSCELL_2_CONF_SCELL_DL
    ...    M55114C00503     2    SGNB_NSA_HO_ADMISS_MFBI_REQ
    ...    M55114C00504     2    SGNB_NSA_HO_ADMISS_MFBI_SUCC
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Get counters value and report to rp  counters=${counters_CB14}  filepath=${pm_counters}  localmoid=NRCELL-1

    Verify last counters in file
    ...    M55316C00042     4    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05002    >0    UE_SCELL_2_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     4    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05002    >0    UE_SCELL_2_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}

Setup_CB14
    Log to console    Configuring delta commissioning
    Configure    testsuite/Krakow/RRM/Airphone/CB007219/config/delta_CB14.yaml    name=delta_CB14    bts_id=1
    Wait for next full pm interval

Teardown_CB13
    UE detach
    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Teardown_CB14
    UE detach    ue_id=12
    Log to console    Deconfiguring delta commissioning
    Deconfigure    name=delta_CB14    bts_id=1
    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report
