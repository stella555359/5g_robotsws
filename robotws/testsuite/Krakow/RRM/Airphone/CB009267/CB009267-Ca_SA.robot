*** Settings ***
Documentation
...        maintainer:   Karol Rybak, Patryk Wojcik
...        contact:      karol.rybak@nokia.com, patryk.wojcik@nokia.com
...        author:       Karol Rybak, Patryk Wojcik
...        description:  Test Cases for CB009267-Ca

Resource    ./resources/CB009267_KW.robot

Suite Setup  Prepare suite environment  egate_config=${lua_cfg_file}  rad_params=@{SWCONFIG_FLAGS_LIST}  x2=False
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${lua_cfg_file}=  ${CURDIR}/config/egate_SA.cfg
@{SWCONFIG_FLAGS_LIST}       0x340000=5   0x9D0000=5

*** Test Cases ***
CB009267_Ca_SA_CA_counters_for_L2_during_scells_activation
    Set maxNumScellsDlFr2SA to 4 and maxNumScellsUlFr2SA to 2
    Attach UE SA  ue_id_first=1  ue_id_last=3  pdu=1
    Sleep    120s
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15034    110-130      PCELL_UE_4_ACT_SCELL_DL_SA
    ...    M55316C15035    0            PCELL_UE_5_ACT_SCELL_DL_SA
    ...    M55316C15036    0            PCELL_UE_6_ACT_SCELL_DL_SA
    ...    M55316C15037    0            PCELL_UE_7_ACT_SCELL_DL_SA
    ...    M55316C15040    110-130      PCELL_UE_2_ACT_SCELL_UL_SA
    ...    M55316C15041    0            PCELL_UE_3_ACT_SCELL_UL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Detach UE SA  ue_id_first=1  ue_id_last=3

    Set maxNumScellsDlFr2SA to 5 and maxNumScellsUlFr2SA to 2
    Attach UE SA  ue_id_first=1  ue_id_last=3  pdu=1
    Sleep    120s
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15034    0            PCELL_UE_4_ACT_SCELL_DL_SA
    ...    M55316C15035    110-130      PCELL_UE_5_ACT_SCELL_DL_SA
    ...    M55316C15036    0            PCELL_UE_6_ACT_SCELL_DL_SA
    ...    M55316C15037    0            PCELL_UE_7_ACT_SCELL_DL_SA
    ...    M55316C15040    110-130      PCELL_UE_2_ACT_SCELL_UL_SA
    ...    M55316C15041    0            PCELL_UE_3_ACT_SCELL_UL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Detach UE SA  ue_id_first=1  ue_id_last=3

    Set maxNumScellsDlFr2SA to 6 and maxNumScellsUlFr2SA to 2
    Attach UE SA  ue_id_first=1  ue_id_last=3  pdu=1
    Sleep    120s
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15034    0            PCELL_UE_4_ACT_SCELL_DL_SA
    ...    M55316C15035    0            PCELL_UE_5_ACT_SCELL_DL_SA
    ...    M55316C15036    110-130      PCELL_UE_6_ACT_SCELL_DL_SA
    ...    M55316C15037    0            PCELL_UE_7_ACT_SCELL_DL_SA
    ...    M55316C15040    110-130      PCELL_UE_2_ACT_SCELL_UL_SA
    ...    M55316C15041    0            PCELL_UE_3_ACT_SCELL_UL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Detach UE SA  ue_id_first=1  ue_id_last=3

    Set maxNumScellsDlFr2SA to 7 and maxNumScellsUlFr2SA to 3
    Attach UE SA  ue_id_first=1  ue_id_last=3  pdu=1
    Sleep    120s
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C15034    0            PCELL_UE_4_ACT_SCELL_DL_SA
    ...    M55316C15035    0            PCELL_UE_5_ACT_SCELL_DL_SA
    ...    M55316C15036    0            PCELL_UE_6_ACT_SCELL_DL_SA
    ...    M55316C15037    110-130      PCELL_UE_7_ACT_SCELL_DL_SA
    ...    M55316C15040    0            PCELL_UE_2_ACT_SCELL_UL_SA
    ...    M55316C15041    110-130      PCELL_UE_3_ACT_SCELL_UL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Detach UE SA  ue_id_first=1  ue_id_last=3
    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report





