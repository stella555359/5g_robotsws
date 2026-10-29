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
${scfc}=             SCFC_3.xml
${ap_xml}=           ${CURDIR}/config/iphy_3.xml
${lua_cfg_file}=     ${CURDIR}/config/wts_3.cfg
${swconfig_file}=    ${CURDIR}/config/gnb_swconfig.txt

${counters_CB01}=    SEPARATOR=
...    M55316C00042,M55114C00501,M55114C00502,M55115C01501,M55115C01502,M55118C02012,M55118C02005,M55115C00014,M55115C00021,
...    M55114C00027,M55114C00034,M55118C04005,M55118C04012
${counters_CB05}=    SEPARATOR=
...    M55316C00042,M55114C00501,M55114C00502,M55115C01501,M55115C01502,M55118C02012,M55118C02005,M55115C00014,M55115C00021,
...    M55114C00027,M55114C00034,M55118C04005,M55118C04012
${counters_CB11}=    M55114C00501,M55114C00502,M55115C01501,M55115C01502


*** Test Cases ***
CB007219-ET-CB01_verify_PSCell_and_SCells_both_can_in_alternative_or_native_band_when_FR2_FAF_enabled
    [Tags]    CB01
    [Documentation]
    ...    1. This user scenario describes the gNB behavior when CB007219 FR2 feature activation flag is enabled or disabled.
    ...    When CB007219 FR2 FAF is enabled, gNB will be able to support carrier aggregation with PSCell and/or SCells
    ...    in alternative and native band.
    ...    Cell 1 to Cell 8 are configured with contiguous frequencies in ascending order (F0 <F1 <...<F7) with frequency range between
    ...    26500-27500 MHz. On the SgNB, a Cellgroup with 8 FR2 TDD Cells, Cell 0 to Cell 7 are configured with the below configuration
    ...                        Cell1 to Cell4 Cell5 to Cell 8
    ...    frequency           F0 F1 to F7
    ...    Bandwidth (MHz)     100 100
    ...    Native band         257 257
    ...    Alternative band    258 258
    ...    DL MIMO layers      4L 4L
    ...    UL MIMO layers      2L 2L
    ...    UE12 supports the following band configuration
    ...    o    CA_n258M in DL
    ...    o    CA_n258I in UL
    ...    UE11 supports the following band configuration
    ...    o    CA_n257M in DL
    ...    o    CA_n257I in UL
    ...    2.Test Case Steps:
    ...        a. NSA UE12 and UE11 attach to PScell and start traffic
    ...        b. online modify Feature flag actMfbiNrCaSupportFr2 = 2 (NSA)
    ...        c. Detach UE12 and UE11 and attach UEs again to PScell
    ...        d. online modify Feature flag actMfbiNrCaSupportFr2 = 0 (none)
    ...        e. Detach UE12 and UE11 and attach UEs again to PScell
    ...        f. Check counters
    ...    3. Expected Results:
    ...        Step a: Feature flag actMfbiNrCaSupportFr2 = 0 (none)
    ...                UE12 attach to cell1 as PScell with band n258, no SCells added.
    ...                    ue_attach id=12
    ...                    ue_dc_enb_start ue=12 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...                UE11 attach to cell1 with 7 SCells in DL and 3 SCells in UL with selected band combination
    ...                CA_257M and CA_257I for DL and UL respectively.
    ...                    ue_attach id=11
    ...                    ue_dc_enb_start ue=11 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...        Step b: online modify successfully - actMfbiNrCaSupportFr2 = 2 (NSA)
    ...                No impact on UE12 and UE11.
    ...        Step c: UE12 detach successful and attach to cell1 with 7 SCells in DL and 3 SCells in UL with selected
    ...                band combination CA_258M and CA_258I for DL and UL respectively.
    ...                UE11 detach successful and attach to cell2 with 7 SCells in DL and 3 SCells in UL with selected
    ...                band combination CA_257M and CA_257I for DL and UL respectively.
    ...        Step d: online modify successfully - actMfbiNrCaSupportFr2 = 0 (none)
    ...                No impact on UE12 and UE11.
    ...        Step e: UE12 detach successful and attach to cell1 as PScell with band n258, no SCells added.
    ...                UE11 detach successful and attach to cell2 with 7 SCells in DL and 3 SCells in UL with selected
    ...                band combination CA_257M and CA_257I for DL and UL respectively.

    [Setup]    Wait for next full pm interval
    NSA UE12 and UE11 attach to PScell with FAF off and start traffic
    Perform delta commissioning of feature flag actMfbiNrCaSupportFr2=NSA
    UE12 and UE11 detach
    NSA UE12 and UE11 attach to PScell with FAF on and start traffic
    Perform delta commissioning of feature flag actMfbiNrCaSupportFr2=none
    UE12 and UE11 detach
    NSA UE12 and UE11 attach to PScell with FAF off and start traffic
    Verify and report counters for CB01
    [Teardown]    Teardown_CB01

CB007219-ET-CB05_verify_PSCell_in_alternative_band_and_one_Scell_in_native_band_when_FR2_FAF_enabled
    [Tags]    CB05
    [Documentation]
    ...    1. This user scenario describes the gNB behavior when CB007219 FR2 feature activation flag is enabled, gNB
    ...       will be able to support carrier aggregation with PSCell in alternative band and Scell in native band.
    ...    Cell 1 to Cell 8 are configured with contiguous frequencies in ascending order (F0 <F1 <...<F7) with frequency range between
    ...    26500-27500 MHz. On the SgNB, Cell 1 is configured with the below configuration
    ...    o    Native band: n257, alternative band: n258
    ...    o    BW: 100 MHz
    ...    UE supports the following band configuration
    ...    BC#1: n258A    N258
    ...    FSEI#1 DL:    DL MIMO layers 4L
    ...    DL ChBw (MHz)    100
    ...    FSEI#1 UL:    UL MIMO Layers 4L
    ...    UL ChBw (MHz)    100
    ...    BC#2: n257A    N257
    ...    FSEI#2 DL:    DL MIMO layers 2L
    ...    DL ChBw (MHz)    100
    ...    FSEI#2 UL:    UL MIMO layers 2L
    ...    2.Test Case Steps:
    ...        a. NSA UE1 attach to PScell and start traffic
    ...            ue_attach id=13
    ...            ue_dc_enb_start ue=13 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...        b. Check counters
    ...    3. Expected Results:
    ...        Step a: UE attach to cell1 with 7 SCells in DL and 3 SCells in UL with selected band combination CA_258M
    ...                and CA_258I for DL and UL respectively.

    [Setup]    Wait for next full pm interval
    Perform delta commissioning for CB05
    UE Attach to target Cell with 7 SCells in DL and 3 SCells in UL and start traffic with verification    ue_id=13
    Verify and report counters for CB05
    [Teardown]    Teardown_CB05

CB007219-ET-CB11_successfuf_EN-DC_setup_in_native_band_where_it_supports_both_the_native_and_alternative_bands_of_the_PSCell
    [Tags]    CB11
    [Documentation]
    ...    1. This user scenario describes the successful EN-DC setup for a UE in FR2 where it supports both the native
    ...       and alternative bands of the PSCell, if CB007219 for FR2 is enabled, then gNB will configure native band for PSCell always.
    ...    Cell 1 to Cell 8 are configured with contiguous frequencies in ascending order (F0 <F1 <...<F7) with frequency range between
    ...    26500-27500 MHz. On the SgNB, a Cellgroup with 8 FR2 TDD Cells, Cell 0 to Cell 7 are configured with the below configuration
    ...                        Cell1 to Cell4 Cell5 to Cell 8
    ...    frequency           F0 F1 to F7
    ...    Bandwidth (MHz)     100 100
    ...    Native band         257 257
    ...    Alternative band    258 258
    ...    DL MIMO layers      4L 4L
    ...    UL MIMO layers      2L 2L
    ...    UE supports the following band configuration
    ...    BC#1: n258A    N258
    ...    FSEI#1 DL:    DL MIMO layers 4L
    ...    DL ChBw (MHz)    100
    ...    FSEI#1 UL:    UL MIMO Layers 4L
    ...    UL ChBw (MHz)    100
    ...    BC#2: n257A    N257
    ...    FSEI#2 DL:    DL MIMO layers 2L
    ...    DL ChBw (MHz)    100
    ...    FSEI#2 UL:    UL MIMO layers 2L
    ...    2.Test Case Steps:
    ...        a. NSA UE1 attach to PScell and start traffic
    ...            ue_attach id=14
    ...            ue_dc_enb_start ue=14 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...        b. Check counters
    ...    3. Expected Results:
    ...        Step a: UE1 attach to cell1 as PScell with band n257.

    [Setup]    Wait for next full pm interval
    Perform delta commissioning of feature flag actMfbiNrCaSupportFr2=NSA
    UE Attach to PScell and start traffic with verification    ue_id=14
    Verify and report counters for CB11
    [Teardown]    Teardown_CB11


*** Keywords ***
Setup suite environment
    Prepare suite environment
    ...    scfc=${scfc}
    ...    ap_xml=${ap_xml}
    ...    egate_config=${lua_cfg_file}
    ...    rad_params=${swconfig_file}
    ...    x2=False
    Create aliases

Perform delta commissioning of feature flag actMfbiNrCaSupportFr2=none
    Log to console    Configuring delta commissioning actMfbiNrCaSupportFr2=none
    Configure    {'MOC': 'NRBTS', 'ID': '1', 'actMfbiNrCaSupportFr2': 'none'}

Perform delta commissioning of feature flag actMfbiNrCaSupportFr2=NSA
    Log to console    Configuring delta commissioning actMfbiNrCaSupportFr2=NSA
    Configure    {'MOC': 'NRBTS', 'ID': '1', 'actMfbiNrCaSupportFr2': 'NSA'}

Perform delta commissioning for CB05
    Log to console    Performing delta commissioning for CB05
    Configure    testsuite/Krakow/RRM/Airphone/CB007219/config/delta_CB05.yaml    name=delta_CB05    bts_id=1

NSA UE12 and UE11 attach to PScell with FAF off and start traffic
    UE Attach to PScell    ue_id=12
    UE Attach to target Cell with 7 SCells in DL and 3 SCells in UL    ue_id=11
    Log to console    Starting NSA traffic for multiple UEs
    Start NSA traffic for multiple UEs    ues=11-12    traffic_rate=150Mbps    dir=ul
    Sleep    1s
    Start NSA traffic for multiple UEs    ues=11-12    traffic_rate=150Mbps    dir=dl
    Sleep    1s
    Execute egate command and wait for data    cmd=ue_stats_nr id=11-12 type=pusch,pdsch scell=8-16

NSA UE12 and UE11 attach to PScell with FAF on and start traffic
    UE Attach to target Cell with 7 SCells in DL and 3 SCells in UL    ue_id=12
    UE Attach to target Cell with 7 SCells in DL and 3 SCells in UL    ue_id=11
    Log to console    Starting NSA traffic for multiple UEs
    Start NSA traffic for multiple UEs    ues=11-12    traffic_rate=150Mbps    dir=ul
    Sleep    1s
    Start NSA traffic for multiple UEs    ues=11-12    traffic_rate=150Mbps    dir=dl
    Sleep    1s
    Execute egate command and wait for data    cmd=ue_stats_nr id=11-12 type=pusch,pdsch scell=8-16

UE12 and UE11 detach
    UE detach    ue_id=12
    UE detach    ue_id=11

UE Attach to PScell and start traffic with verification
    [Arguments]    ${ue_id}=11
    UE Attach to target Cell    ue_id=${ue_id}
    Start traffic    ue_id=${ue_id}
    Verify traffic    ue_id=${ue_id}    ul_scells=8    dl_scells=8

UE Attach to target Cell with 7 SCells in DL and 3 SCells in UL and start traffic with verification
    [Arguments]    ${ue_id}=11
    UE Attach to target Cell    ue_id=${ue_id}
    Start traffic    ue_id=${ue_id}
    Verify traffic    ue_id=${ue_id}    ul_scells=8,9,10,11    dl_scells=8,9,10,11,12,13,14,15

UE Attach to PScell
    [Arguments]    ${ue_id}=11
    UE Attach to target Cell    ue_id=${ue_id}

UE Attach to target Cell with 7 SCells in DL and 3 SCells in UL
    [Arguments]    ${ue_id}=11
    UE Attach to target Cell    ue_id=${ue_id}

Verify and report counters for CB01
    Log to console    Verifying PM Counters
    Wait for next full pm interval
    ${pm_counters}=  get latest unpacked full pm counters file
    Set Test Variable  ${pm_counters}

    Verify last counters in file
    ...    M55316C00042     0    SCELL_CONF_ALT_BAND_NSA
    ...    M55114C00501     3    SGNB_NSA_ADMISSION_MFBI_REQ
    ...    M55114C00502     3    SGNB_NSA_ADMISSION_MFBI_SUCC
    ...    M55115C01501     3    SGNB_DU_NSA_ADMISS_MFBI_REQ
    ...    M55115C01502     3    SGNB_DU_NSA_ADMISS_MFBI_SUCC
    ...    M55118C02012     4    RRC_RECONF_7_SCELL_DL_ATT
    ...    M55118C02005     4    RRC_RECONF_3_SCELL_UL_ATT
    ...    M55115C00014     4    SGNB_DU_SCELL_7_ADMISSION_REQ
    ...    M55115C00021     4    SGNB_DU_SCELL_7_ADMISSION_SUCC
    ...    M55114C00027     4    SGNB_SCELL_7_ADMISSION_REQ
    ...    M55114C00034     4    SGNB_SCELL_7_ADMISSION_SUCC
    ...    M55118C04005    >0    UE_PSCELL_3_CONF_SCELL_UL
    ...    M55118C04012    >0    UE_PSCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Get counters value and report to rp  counters=${counters_CB01}  filepath=${pm_counters}  localmoid=NRCELL-1

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05005    >0    UE_SCELL_3_CONF_SCELL_UL
    ...    M55118C05012    >0    UE_SCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05005    >0    UE_SCELL_3_CONF_SCELL_UL
    ...    M55118C05012    >0    UE_SCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05005    >0    UE_SCELL_3_CONF_SCELL_UL
    ...    M55118C05012    >0    UE_SCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05012    >0    UE_SCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05012    >0    UE_SCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-6
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05012    >0    UE_SCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-7
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05012    >0    UE_SCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-8
    ...    file_path=${pm_counters}

Verify and report counters for CB05
    Log to console    Verifying PM Counters
    Wait for next full pm interval
    ${pm_counters}=  get latest unpacked full pm counters file
    Set Test Variable  ${pm_counters}

    Verify last counters in file
    ...    M55316C00042     0    SCELL_CONF_ALT_BAND_NSA
    ...    M55114C00501     1    SGNB_NSA_ADMISSION_MFBI_REQ
    ...    M55114C00502     1    SGNB_NSA_ADMISSION_MFBI_SUCC
    ...    M55115C01501     1    SGNB_DU_NSA_ADMISS_MFBI_REQ
    ...    M55115C01502     1    SGNB_DU_NSA_ADMISS_MFBI_SUCC
    ...    M55118C02012     1    RRC_RECONF_7_SCELL_DL_ATT
    ...    M55118C02005     1    RRC_RECONF_3_SCELL_UL_ATT
    ...    M55115C00014     1    SGNB_DU_SCELL_7_ADMISSION_REQ
    ...    M55115C00021     1    SGNB_DU_SCELL_7_ADMISSION_SUCC
    ...    M55114C00027     1    SGNB_SCELL_7_ADMISSION_REQ
    ...    M55114C00034     1    SGNB_SCELL_7_ADMISSION_SUCC
    ...    M55118C04005    >0    UE_PSCELL_3_CONF_SCELL_UL
    ...    M55118C04012    >0    UE_PSCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Get counters value and report to rp  counters=${counters_CB05}  filepath=${pm_counters}  localmoid=NRCELL-1

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05005    >0    UE_SCELL_3_CONF_SCELL_UL
    ...    M55118C05012    >0    UE_SCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05005    >0    UE_SCELL_3_CONF_SCELL_UL
    ...    M55118C05012    >0    UE_SCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05005    >0    UE_SCELL_3_CONF_SCELL_UL
    ...    M55118C05012    >0    UE_SCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05012    >0    UE_SCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05012    >0    UE_SCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-6
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05012    >0    UE_SCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-7
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     0    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05012    >0    UE_SCELL_7_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-8
    ...    file_path=${pm_counters}

Verify and report counters for CB11
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
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Get counters value and report to rp  counters=${counters_CB11}  filepath=${pm_counters}  localmoid=NRCELL-1

Teardown_CB01
    UE12 and UE11 detach
    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Teardown_CB05
    UE detach    ue_id=13
    Log to console    Deconfiguring delta commissioning
    Deconfigure    name=delta_CB05   bts_id=1
    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Teardown_CB11
    UE detach    ue_id=14
    Perform delta commissioning of feature flag actMfbiNrCaSupportFr2=none
    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report
