*** Settings ***
Documentation
...        maintainer:   Karol Rybak, Patryk Wojcik
...        contact:      karol.rybak@nokia.com, patryk.wojcik@nokia.com
...        author:       Karol Rybak, Patryk Wojcik
...        description:  Test Cases for CB009267-Ca

Library     ute_wtssim
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     ta_emss
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK5/CB009267/resources_from_RRM_L2_KRK_1/traffic_handling.py
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK5/CB009267/resources_from_RRM_L2_KRK_1/ue_handling.py
Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK5/CB009267/resources_from_RRM_L2_KRK_1/common_keywords.robot


Suite Setup     Prepare suite environment    egate_config=${lua_cfg_file}  scfc=${scfc}  ap_xml=${iphy}  rad_params=@{SWCONFIG_FLAGS_LIST}  x2=False

Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${lua_cfg_file}=             ${CURDIR}/config/egate_SA.cfg
@{SWCONFIG_FLAGS_LIST}       0x340000=5   0x9D0000=5
${scfc}=  ${CURDIR}/config/scfc_SA.xml
${iphy}=  ${CURDIR}/config/iphy_SA.xml

*** Test Cases ***
CB009267_Ca_SA_CA_counters_for_L2_during_scells_activation
    Set maxNumScellsDlFr2SA to 4 and maxNumScellsUlFr2SA to 2
    Multi UE
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
    Deregister multi ues  first_ue_id=1  last_ue_id=2

    Set maxNumScellsDlFr2SA to 5 and maxNumScellsUlFr2SA to 2
    Multi UE
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
    Deregister multi ues  first_ue_id=1  last_ue_id=2

    Set maxNumScellsDlFr2SA to 6 and maxNumScellsUlFr2SA to 2
    Multi UE
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
    Deregister multi ues  first_ue_id=1  last_ue_id=2

    Set maxNumScellsDlFr2SA to 7 and maxNumScellsUlFr2SA to 3
    Multi UE
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

    [Teardown]    Deregister multi ues  first_ue_id=1  last_ue_id=2

*** Keywords ***
Set parameter ${MOC}-${ID}/${parameter} to ${value}
    Log to console  Set feature flag ${MOC}-${ID}/${parameter} to ${value}
    Configure    {'MOC': '${MOC}', 'ID': '${ID}', '${parameter}': '${value}'}

Set maxNumScellsDlFr2SA to ${maxNumScellsDlFr2SA} and maxNumScellsUlFr2SA to ${maxNumScellsUlFr2SA}
    Log to console    Change maxNumScellsDlFr2SA to ${maxNumScellsDlFr2SA} and to maxNumScellsUlFr2SA to ${maxNumScellsUlFr2SA}
    Set enb parameter value    param_path=NRBTS.maxNumScellsDlFr2SA    value=${maxNumScellsDlFr2SA}    bts_id=1
    Set enb parameter value    param_path=NRBTS.maxNumScellsUlFr2SA    value=${maxNumScellsUlFr2SA}    bts_id=1
    Configure  ${CURDIR}/config/changing_maxNumScellsDlFr2SA_and_maxNumScellsUlFr2SA.yaml    node_id=1

Multi UE
    Execute egate command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute egate command    cmd=ue_register id=1
    sleep    2s
    Execute egate command    cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    sleep    30s
    Execute egate command    cmd=set_pdu_param ue=2 pdu=1 trf_type=internal
    Execute egate command    cmd=ue_register id=2
    sleep    2s
    Execute egate command    cmd=ue_pdu_session_setup pdu=1 ue=2 nwslice=1 gw=1
