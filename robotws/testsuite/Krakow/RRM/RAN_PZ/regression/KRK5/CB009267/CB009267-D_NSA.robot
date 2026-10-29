*** Settings ***
Documentation
...        maintainer:   Karol Rybak, Patryk Wojcik
...        contact:      karol.rybak@nokia.com, patryk.wojcik@nokia.com
...        author:       Karol Rybak, Patryk Wojcik
...        description:  Test Cases for CB009267-D_NSA

Library     ute_wtssim
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     ta_emss
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK5/CB009267/resources_from_RRM_L2_KRK_1/traffic_handling.py
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK5/CB009267/resources_from_RRM_L2_KRK_1/ue_handling.py
Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK5/CB009267/resources_from_RRM_L2_KRK_1/common_keywords.robot


Suite Setup     Prepare suite environment    egate_config=${lua_cfg_file}
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL

*** Variables ***
${lua_cfg_file}=             ${CURDIR}/config/egate_NSA_D.lua
@{SWCONFIG_FLAGS_LIST}       0x340000=5   0x9D0000=5

*** Test Cases ***
CB009267_D_Number_of_UEs_supporting_various_CC_DL_and_UL_for_NSA
	[Setup]  Prepare test environment

	Set maxNumScellsUl to 3 and maxNumScellsDl to 7
    Multi UE NSA    cell_id_1=1  cell_id_2=13
    Wait for next full pm interval
	${pm_counters}=  Wait for next pm interval and get counters
	Run Keyword And Continue On Failure  Verify Last Counters In File
	...    M55114C01541    590-610       PSCELL_UE_CAP_3_CC_DL_NSA
    ...    M55114C01542    590-610       PSCELL_UE_CAP_4_CC_DL_NSA
    ...    M55114C01543    590-610       PSCELL_UE_CAP_5_CC_DL_NSA
    ...    M55114C01544    590-610	     PSCELL_UE_CAP_6_CC_DL_NSA
    ...    M55114C01545    590-610       PSCELL_UE_CAP_7_CC_DL_NSA
    ...    M55114C01546    590-610       PSCELL_UE_CAP_8_CC_DL_NSA
    ...    M55114C01548    1190-1210     PSCELL_UE_CAP_2_CC_UL_NSA
    ...    M55114C01549    1190-1210     PSCELL_UE_CAP_3_CC_UL_NSA
    ...    M55114C01550    1190-1210     PSCELL_UE_CAP_4_CC_UL_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Sleep    120s
    Detach UE NSA    cell_id_1=1  cell_id_2=13  step=2
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55114C01553    2             PSCELL_UE_CAP_3_CC_DL_MAX_NSA
    ...    M55114C01554    2             PSCELL_UE_CAP_4_CC_DL_MAX_NSA
    ...    M55114C01555    2             PSCELL_UE_CAP_5_CC_DL_MAX_NSA
    ...    M55114C01556    2	         PSCELL_UE_CAP_6_CC_DL_MAX_NSA
    ...    M55114C01557    2             PSCELL_UE_CAP_7_CC_DL_MAX_NSA
    ...    M55114C01558    2	         PSCELL_UE_CAP_8_CC_DL_MAX_NSA
    ...    M55114C01560    4             PSCELL_UE_CAP_2_CC_UL_MAX_NSA
    ...    M55114C01561    4	         PSCELL_UE_CAP_3_CC_UL_MAX_NSA
    ...    M55114C01562    4	         PSCELL_UE_CAP_4_CC_UL_MAX_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Detach UE NSA    cell_id_1=1  cell_id_2=13  step=1

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
    [Arguments]  ${cell_id_1}  ${cell_id_2}
    Execute egate command    cmd=enb_x2_link_up enb=1 target=2
    FOR    ${UE_ID}     IN RANGE    ${cell_id_1}       ${cell_id_2}
        Execute egate command    cmd=ue_attach id=${UE_ID}
        sleep    2s
        Execute egate command    cmd=ue_dc_enb_start ue=${UE_ID} target_gnb=2 target_cells=1 bearer=2 type=split_scg
        sleep    30s
    END

Detach UE NSA
	[Arguments]  ${cell_id_1}  ${cell_id_2}  ${step}
	FOR    ${UE_ID}     IN RANGE    ${cell_id_1}       ${cell_id_2}       ${step}
        Execute egate command
        ...    cmd=ue_detach id=${UE_ID}
    END

