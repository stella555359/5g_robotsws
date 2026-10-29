*** Settings ***
Documentation
...        maintainer:   Karol Rybak, Patryk Wojcik
...        contact:      karol.rybak@nokia.com, patryk.wojcik@nokia.com
...        author:       Karol Rybak, Patryk Wojcik
...        description:  Test Cases for CB009267-D_NSA

Resource    ./resources/CB009267_KW.robot

Suite Setup     Prepare suite environment    egate_config=${lua_cfg_file}
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL

*** Variables ***
${lua_cfg_file}=             ${CURDIR}/config/egate_NSA_D.lua

*** Test Cases ***
CB009267_D_Number_of_UEs_supporting_various_CC_DL_and_UL_for_NSA
	[Setup]  Prepare test environment

	Set maxNumScellsUl to 3 and maxNumScellsDl to 7
    Attach UE NSA    ue_id_first=1  ue_id_last=13
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
    Detach UE NSA    ue_id_first=1  ue_id_last=13  step=2
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
    Detach UE NSA    ue_id_first=1  ue_id_last=13
    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report
