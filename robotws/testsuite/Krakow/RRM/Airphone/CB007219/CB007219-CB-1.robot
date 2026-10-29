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
${scfc}=             SCFC_1.xml
${ap_xml}=           ${CURDIR}/config/iphy_1.xml
${lua_cfg_file}=     ${CURDIR}/config/wts_1.cfg
${swconfig_file}=    ${CURDIR}/config/gnb_swconfig.txt

${counters}=         M55316C00042,M55118C04004,M55114C00501,M55114C00502,M55114C00023,M55114C00030,M55115C01501,M55115C01502,M55115C00010,M55115C00017


*** Test Cases ***
CB007219-ET-CB09_verify_PSCell_in_alternative_band_and_best_band_combination_selected_ue_supported
    [Tags]    CB09
    [Documentation]
    ...    Preconditions
    ...    FR2 CA feature is activated (NRBTS/actCarrierAggregation is set to “true”).
    ...    NRBTS/caConfigurationSupport is set to 3 (8CCDL_4CCUL).
    ...    Configure gNB with NRBTS.gNbCuType set to ‘NSA’, with 1 CELLGROUP contains 8 FR2 NSA Cells (NRBTS/NRCELL.cellDepType set to ‘NSA’).
    ...    NRBTS/maxNumScellsDl is set to 7 and NRBTS/maxNumScellsUl is set to 3
    ...    On the SgNB, a Cellgroup with 8 FR2 TDD Cells, Cell 0 to Cell 7 are configured with the below configuration
    ...                           Cell1 Cell2 to Cell4  Cell5 to Cell6
    ...    frequency               F0    F1 to F3       F4 to F5
    ...    Bandwidth (MHz)         100   100            100
    ...    Native band             258   261            258
    ...    Alternative band        257   257            257
    ...    DL MIMO layers          2L    2L             2L
    ...    UL MIMO layers          2L    2L             2L
    ...    Step 1: NSA UE11 attach to PScell and start traffic
    ...        ue_attach id=11
    ...        ue_dc_enb_start ue=11 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...        trf_data_start ue=11 id=2 dir=ul mbps=150 trf_id=1
    ...        trf_data_start ue=11 id=2 dir=dl mbps=150 trf_id=1
    ...        ue_stats_nr id=1 type=pusch,pdsch scell=8-16
    ...    Expected result:
    ...        UE attach to cell1 with 3 SCells in DL with selected band combination CA_n257A_n257H and CA_257A for DL and UL respectively.
    ...        Check below messages:
    ...        gNB-CU sends to gNB-DU the F1AP: UE Context Setup Request message containing:
    ...        -    Cell1 identity in SpCell ID IE,
    ...        -    Cell2, Cell3 and Cell4 identities in SCell-ToBeSetup-List IE,
    ...        -    BC#1 in CUtoDURRCInformation -> CG-ConfigInfo -> allowedBC-ListMRDC -> BandCombinationInfo IE.
    ...        gNB-DU replies to gNB-CU with the F1AP: UE Context Setup Response message containing:
    ...        -    The configuration for Cell1 as PSCell and Cell2, Cell3 and Cell4 as SCells with frequency band (n257) for each SCell in
    ...        DUtoCURRCInformation -> cellGroupConfig IE,
    ...        -    The selected band combination BC#1 in DUtoCURRCInformation -> selectedBandCombinationIndex IE
    ...        gNB-CU sends to MeNB the X2AP: SgNB Addition Request Acknowledge filled with:
    ...        -    CG-Config -> scg-CellGroupConfig containing Cell1, Cell2, Cell3 and Cell4 configuration.
    ...        -    CG-Config -> selectedBandCombination containing BC#2.
    ...    Step 2:  check counters
    ...    Expected result:
    ...        M55316C00042 SCELL_CONF_ALT_BAND_NSA
    ...        M55114C00501 SGNB_NSA_ADMISSION_MFBI_REQ
    ...        M55114C00502 SGNB_NSA_ADMISSION_MFBI_SUCC
    ...        M55115C01501 SGNB_DU_NSA_ADMISS_MFBI_REQ
    ...        M55115C01502 SGNB_DU_NSA_ADMISS_MFBI_SUCC

    [Setup]    Wait for next full pm interval
    UE attach to PSCell with 3 SCells in DL with selected band combination and start traffic with verification
    Verify and report counters
    [Teardown]    Teardown_CB09


*** Keywords ***
Setup suite environment
    Prepare suite environment
    ...    scfc=${scfc}
    ...    ap_xml=${ap_xml}
    ...    egate_config=${lua_cfg_file}
    ...    rad_params=${swconfig_file}
    ...    x2=False
    Create aliases

UE attach to PScell with 3 SCells in DL with selected band combination and start traffic with verification
    [Arguments]    ${ue_id}=11
    UE Attach to target Cell    ue_id=${ue_id}
    Start traffic    ue_id=${ue_id}
    Verify traffic    ue_id=${ue_id}    ul_scells=8    dl_scells=8,9,10,11

Verify and report counters
    Log to console    Verifying PM Counters
    Wait for next full pm interval
    ${pm_counters}=  get latest unpacked full pm counters file
    Set Test Variable  ${pm_counters}

    Verify last counters in file
    ...    M55316C00042     0    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C04004    >0    UE_PSCELL_3_CONF_SCELL_DL
    ...    M55114C00501     1    SGNB_NSA_ADMISSION_MFBI_REQ
    ...    M55114C00502     1    SGNB_NSA_ADMISSION_MFBI_SUCC
    ...    M55114C00023     1    SGNB_SCELL_3_ADMISSION_REQ
    ...    M55114C00030     1    SGNB_SCELL_3_ADMISSION_SUCC
    ...    M55115C01501     1    SGNB_DU_NSA_ADMISS_MFBI_REQ
    ...    M55115C01502     1    SGNB_DU_NSA_ADMISS_MFBI_SUCC
    ...    M55115C00010     1    SGNB_DU_SCELL_3_ADMISSION_REQ
    ...    M55115C00017     1    SGNB_DU_SCELL_3_ADMISSION_SUCC
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Get counters value and report to rp  counters=${counters}  filepath=${pm_counters}  localmoid=NRCELL-1

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05004    >0    UE_SCELL_3_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05004    >0    UE_SCELL_3_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     1    SCELL_CONF_ALT_BAND_NSA
    ...    M55118C05004    >0    UE_SCELL_3_CONF_SCELL_DL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     0    SCELL_CONF_ALT_BAND_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     0    SCELL_CONF_ALT_BAND_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-6
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     0    SCELL_CONF_ALT_BAND_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-7
    ...    file_path=${pm_counters}

    Verify last counters in file
    ...    M55316C00042     0    SCELL_CONF_ALT_BAND_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-8
    ...    file_path=${pm_counters}

Teardown_CB09
    UE detach
    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report
