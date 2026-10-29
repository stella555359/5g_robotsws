*** Settings ***
Documentation
...        maintainer:   Karol Rybak, Patryk Wojcik
...        contact:      karol.rybak@nokia.com, patryk.wojcik@nokia.com
...        author:       Karol Rybak, Patryk Wojcik
...        description:  Test Cases for CB009267-Cb

Resource    ./resources/CB009267_KW.robot

Suite Setup     Prepare suite environment    egate_config=${lua_cfg_file}  x2=True
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_PRIVATE_MMWV_NSA_CA_8CC_DL_4CC_UL

*** Variables ***
${lua_cfg_file}=             ${CURDIR}/config/egate_NSA.lua


*** Test Cases ***
CB009267_Cb_NSA_CA_counters_for_L2_during_scells_activation
    [Setup]  Prepare test environment

    Wait for next full pm interval
    Attach UE NSA  ue_id_first=1  ue_id_last=3
    Sleep    120s
    Detach UE NSA  ue_id_first=1  ue_id_last=3

    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15070    250-260        PSCELL_UE_7_ACT_SCELL_DL_NSA
    ...    M55316C15074    250-260        PSCELL_UE_3_ACT_SCELL_UL_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Set maxNumScellsUl to 3 and maxNumScellsDl to 6
    Attach UE NSA  ue_id_first=1  ue_id_last=3
    Sleep    120s
    Detach UE NSA  ue_id_first=1  ue_id_last=3

    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15069    250-260        PSCELL_UE_6_ACT_SCELL_DL_NSA
    ...    M55316C15074    250-260        PSCELL_UE_3_ACT_SCELL_UL_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Set maxNumScellsUl to 3 and maxNumScellsDl to 5
    Attach UE NSA  ue_id_first=1  ue_id_last=3
    Sleep    120s
    Detach UE NSA  ue_id_first=1  ue_id_last=3

    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15068    250-260        PSCELL_UE_5_ACT_SCELL_DL_NSA
    ...    M55316C15074    250-260       PSCELL_UE_3_ACT_SCELL_UL_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Set maxNumScellsUl to 3 and maxNumScellsDl to 4
    Attach UE NSA  ue_id_first=1  ue_id_last=3
    Sleep    120s
    Detach UE NSA  ue_id_first=1  ue_id_last=3

    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15067    250-260        PSCELL_UE_4_ACT_SCELL_DL_NSA
    ...    M55316C15074    250-260        PSCELL_UE_3_ACT_SCELL_UL_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Set maxNumScellsUl to 3 and maxNumScellsDl to 3
    Attach UE NSA  ue_id_first=1  ue_id_last=3
    Sleep    120s
    Detach UE NSA  ue_id_first=1  ue_id_last=3

    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15066    250-260        PSCELL_UE_3_ACT_SCELL_DL_NSA
    ...    M55316C15074    250-260        PSCELL_UE_3_ACT_SCELL_UL_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Set maxNumScellsUl to 2 and maxNumScellsDl to 2
    Attach UE NSA  ue_id_first=1  ue_id_last=3
    Sleep    120s
    Detach UE NSA  ue_id_first=1  ue_id_last=3

    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15065    250-260        PSCELL_UE_2_ACT_SCELL_DL_NSA
    ...    M55316C15073    250-260        PSCELL_UE_2_ACT_SCELL_UL_NSA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report
