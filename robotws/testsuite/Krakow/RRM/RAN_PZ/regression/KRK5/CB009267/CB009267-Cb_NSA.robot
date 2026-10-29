*** Settings ***
Documentation
...        maintainer:   Karol Rybak, Patryk Wojcik
...        contact:      karol.rybak@nokia.com, patryk.wojcik@nokia.com
...        author:       Karol Rybak, Patryk Wojcik
...        description:  Test Cases for CB009267-Cb

Library     ute_wtssim
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     ta_emss
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK5/CB009267/resources_from_RRM_L2_KRK_1/traffic_handling.py
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK5/CB009267/resources_from_RRM_L2_KRK_1/ue_handling.py
Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK5/CB009267/resources_from_RRM_L2_KRK_1/common_keywords.robot


Suite Setup     Prepare suite environment    egate_config=${lua_cfg_file}  rad_params=@{SWCONFIG_FLAGS_LIST}
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL

*** Variables ***
${lua_cfg_file}=             ${CURDIR}/config/egate_NSA.lua
@{SWCONFIG_FLAGS_LIST}       0x340000=5   0x9D0000=5

*** Test Cases ***
CB009267_Cb_NSA_CA_counters_for_L2_during_scells_activation
    [Setup]  Prepare test environment

	Multi UE NSA
	Sleep    120s
    Wait for next full pm interval
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15070    110-130        PSCELL_UE_7_ACT_SCELL_DL_NSA
    ...    M55316C15074    110-130        PSCELL_UE_3_ACT_SCELL_UL_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Detach multi ues  first_ue_id=1  last_ue_id=2

    Set maxNumScellsUl to 3 and maxNumScellsDl to 6
	Multi UE NSA
	Sleep    120s
    Wait for next full pm interval
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15069    110-130        PSCELL_UE_6_ACT_SCELL_DL_NSA
    ...    M55316C15074    110-130        PSCELL_UE_3_ACT_SCELL_UL_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Detach multi ues  first_ue_id=1  last_ue_id=2

    Set maxNumScellsUl to 3 and maxNumScellsDl to 5
	Multi UE NSA
	Sleep    120s
    Wait for next full pm interval
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15068    110-130        PSCELL_UE_5_ACT_SCELL_DL_NSA
    ...    M55316C15074    110-130        PSCELL_UE_3_ACT_SCELL_UL_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Detach multi ues  first_ue_id=1  last_ue_id=2

    Set maxNumScellsUl to 3 and maxNumScellsDl to 4
	Multi UE NSA
	Sleep    120s
    Wait for next full pm interval
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15067    110-130        PSCELL_UE_4_ACT_SCELL_DL_NSA
    ...    M55316C15074    110-130        PSCELL_UE_3_ACT_SCELL_UL_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Detach multi ues  first_ue_id=1  last_ue_id=2

    Set maxNumScellsUl to 3 and maxNumScellsDl to 3
	Multi UE NSA
	Sleep    120s
    Wait for next full pm interval
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15066    110-130        PSCELL_UE_3_ACT_SCELL_DL_NSA
    ...    M55316C15074    110-130        PSCELL_UE_3_ACT_SCELL_UL_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Detach multi ues  first_ue_id=1  last_ue_id=2

    Set maxNumScellsUl to 2 and maxNumScellsDl to 2
	Multi UE NSA
	Sleep    120s
    Wait for next full pm interval
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15065    110-130        PSCELL_UE_2_ACT_SCELL_DL_NSA
    ...    M55316C15073    110-130        PSCELL_UE_2_ACT_SCELL_UL_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    [Teardown]    Detach multi ues  first_ue_id=1  last_ue_id=2

*** Keywords ***
Prepare test environment
    Configure  ${CURDIR}/config/enabling_actCarAgPmCount.yaml

Set parameter ${MOC}-${ID}/${parameter} to ${value}
    Log to console  Set feature flag ${MOC}-${ID}/${parameter} to ${value}
    Configure    {'MOC': '${MOC}', 'ID': '${ID}', '${parameter}': '${value}'}

Set maxNumScellsUl to ${maxNumScellsUl} and maxNumScellsDl to ${maxNumScellsDl}
    Log to console    Change maxNumScellsUl to ${maxNumScellsUl} and to maxNumScellsDl to ${maxNumScellsDl}
    Set enb parameter value    param_path=NRBTS.maxNumScellsDl    value=${maxNumScellsDl}    bts_id=1
    Set enb parameter value    param_path=NRBTS.maxNumScellsUl    value=${maxNumScellsUl}    bts_id=1
    Configure  ${CURDIR}/config/changing_maxNumScellsDl_and_maxNumScellsUl.yaml    node_id=1

Multi UE NSA
    Execute egate command    cmd=enb_x2_link_up enb=1 target=2
    Execute egate command    cmd=ue_attach id=1
    sleep    2s
    Execute egate command    cmd=ue_dc_enb_start ue=1 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    sleep    30s
    Execute egate command    cmd=set_pdu_param ue=2 pdu=1 trf_type=internal
    Execute egate command    cmd=ue_attach id=2
    sleep    2s
    Execute egate command    cmd=ue_dc_enb_start ue=2 target_gnb=2 target_cells=1 bearer=2 type=split_scg
