*** Settings ***
Documentation
...        maintainer:   Karol Rybak, Patryk Wojcik
...        author:       Karol Rybak, Patryk Wojcik
...        contact:      karol.rybak@nokia.com, patryk.wojcik@nokia.com
...        description:  Test Cases for CB009267-D_SA

Library     ute_wtssim
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     ta_emss
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK5/CB009267/resources_from_RRM_L2_KRK_1/traffic_handling.py
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK5/CB009267/resources_from_RRM_L2_KRK_1/ue_handling.py
Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK5/CB009267/resources_from_RRM_L2_KRK_1/common_keywords.robot


Suite Setup     Prepare suite environment    egate_config=${lua_cfg_file}  x2=False
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO
	...    VARIANT_PRIVATE_MMWV_SA_CA

*** Variables ***
${lua_cfg_file}=             ${CURDIR}/config/egate_SA_D.cfg
@{SWCONFIG_FLAGS_LIST}       0x340000=5   0x9D0000=5

*** Test Cases ***
CB009267_D_Time_of_usability_of_each_DL_and_UL_CC_in_SA
    Set maxNumScellsDlFr2SA to 4 and maxNumScellsUlFr2SA to 2
    Multi UE    cell_id_1=9  cell_id_2=10
    Sleep    60s
    Deregister multi ues  first_ue_id=9  last_ue_id=10
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55118C00090    140-1199      PCELL_DL_4_SCELL_CONFIG_DUR_SA
    ...    M55118C00091    0             PCELL_DL_5_SCELL_CONFIG_DUR_SA
    ...    M55118C00092    0             PCELL_DL_6_SCELL_CONFIG_DUR_SA
    ...    M55118C00093    0             PCELL_DL_7_SCELL_CONFIG_DUR_SA
    ...    M55118C00095    140-2399      PCELL_UL_2_SCELL_CONFIG_DUR_SA
    ...    M55118C00096    0             PCELL_UL_3_SCELL_CONFIG_DUR_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Set maxNumScellsDlFr2SA to 5 and maxNumScellsUlFr2SA to 3
    Multi UE    cell_id_1=9  cell_id_2=10
    Sleep    60s
    Deregister multi ues  first_ue_id=9  last_ue_id=10
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55118C00090    0             PCELL_DL_4_SCELL_CONFIG_DUR_SA
    ...    M55118C00091    140-1199      PCELL_DL_5_SCELL_CONFIG_DUR_SA
    ...    M55118C00092    0             PCELL_DL_6_SCELL_CONFIG_DUR_SA
    ...    M55118C00093    0             PCELL_DL_7_SCELL_CONFIG_DUR_SA
    ...    M55118C00095    0             PCELL_UL_2_SCELL_CONFIG_DUR_SA
    ...    M55118C00096    140-1199      PCELL_UL_3_SCELL_CONFIG_DUR_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Set maxNumScellsDlFr2SA to 6 and maxNumScellsUlFr2SA to 2
    Multi UE    cell_id_1=9  cell_id_2=10
    Sleep    60s
    Deregister multi ues  first_ue_id=9  last_ue_id=10
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55118C00090    0             PCELL_DL_4_SCELL_CONFIG_DUR_SA
    ...    M55118C00091    0             PCELL_DL_5_SCELL_CONFIG_DUR_SA
    ...    M55118C00092    140-1199      PCELL_DL_6_SCELL_CONFIG_DUR_SA
    ...    M55118C00093    0             PCELL_DL_7_SCELL_CONFIG_DUR_SA
    ...    M55118C00095    140-2399      PCELL_UL_2_SCELL_CONFIG_DUR_SA
    ...    M55118C00096    0             PCELL_UL_3_SCELL_CONFIG_DUR_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Set maxNumScellsDlFr2SA to 7 and maxNumScellsUlFr2SA to 3
    Multi UE    cell_id_1=9  cell_id_2=10
    Sleep    60s
    Deregister multi ues  first_ue_id=9  last_ue_id=10
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55118C00090    0             PCELL_DL_4_SCELL_CONFIG_DUR_SA
    ...    M55118C00091    0             PCELL_DL_5_SCELL_CONFIG_DUR_SA
    ...    M55118C00092    0             PCELL_DL_6_SCELL_CONFIG_DUR_SA
    ...    M55118C00093    140-1199      PCELL_DL_7_SCELL_CONFIG_DUR_SA
    ...    M55118C00095    0             PCELL_UL_2_SCELL_CONFIG_DUR_SA
    ...    M55118C00096    140-1199      PCELL_UL_3_SCELL_CONFIG_DUR_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

CB009267_D_Number_of_Ues_supporting_various_CC_DL_and_UL_for_SA
	Set maxNumScellsDlFr2SA to 7 and maxNumScellsUlFr2SA to 3
    Multi UE    cell_id_1=1  cell_id_2=2
    Wait for next full pm interval
	${pm_counters}=  Wait for next pm interval and get counters
	Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55114C01567    590-610       PCELL_UE_CAP_5_CC_DL_SA
    ...    M55114C01568    0             PCELL_UE_CAP_6_CC_DL_SA
    ...    M55114C01569    0             PCELL_UE_CAP_7_CC_DL_SA
    ...    M55114C01570    0             PCELL_UE_CAP_8_CC_DL_SA
    ...    M55114C01573    590-610       PCELL_UE_CAP_3_CC_UL_SA
    ...    M55114C01574    0             PCELL_UE_CAP_4_CC_UL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Sleep    120s
    Detach UE    cell_id=1
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55114C01579    2             PCELL_UE_CAP_5_CC_DL_MAX_SA
    ...    M55114C01580    0             PCELL_UE_CAP_6_CC_DL_MAX_SA
    ...    M55114C01581    0             PCELL_UE_CAP_7_CC_DL_MAX_SA
    ...    M55114C01582    0	         PCELL_UE_CAP_8_CC_DL_MAX_SA
    ...    M55114C01585    2             PCELL_UE_CAP_3_CC_UL_MAX_SA
    ...    M55114C01586    0	         PCELL_UE_CAP_4_CC_UL_MAX_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
	Detach UE    cell_id=2

    Multi UE    cell_id_1=3  cell_id_2=4
    Wait for next full pm interval
	${pm_counters}=  Wait for next pm interval and get counters
	Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55114C01567    0	         PCELL_UE_CAP_5_CC_DL_SA
    ...    M55114C01568    590-610       PCELL_UE_CAP_6_CC_DL_SA
    ...    M55114C01569    0             PCELL_UE_CAP_7_CC_DL_SA
    ...    M55114C01570    0             PCELL_UE_CAP_8_CC_DL_SA
    ...    M55114C01573    0	         PCELL_UE_CAP_3_CC_UL_SA
    ...    M55114C01574    590-610       PCELL_UE_CAP_4_CC_UL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Sleep    120s
    Detach UE    cell_id=3
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55114C01579    0             PCELL_UE_CAP_5_CC_DL_MAX_SA
    ...    M55114C01580    2             PCELL_UE_CAP_6_CC_DL_MAX_SA
    ...    M55114C01581    0             PCELL_UE_CAP_7_CC_DL_MAX_SA
    ...    M55114C01582    0	         PCELL_UE_CAP_8_CC_DL_MAX_SA
    ...    M55114C01585    0             PCELL_UE_CAP_3_CC_UL_MAX_SA
    ...    M55114C01586    2	         PCELL_UE_CAP_4_CC_UL_MAX_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
	Detach UE    cell_id=4

    Multi UE    cell_id_1=5  cell_id_2=6
    Wait for next full pm interval
	${pm_counters}=  Wait for next pm interval and get counters
	Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55114C01567    0	         PCELL_UE_CAP_5_CC_DL_SA
    ...    M55114C01568    0	         PCELL_UE_CAP_6_CC_DL_SA
    ...    M55114C01569    590-610       PCELL_UE_CAP_7_CC_DL_SA
    ...    M55114C01570    0             PCELL_UE_CAP_8_CC_DL_SA
    ...    M55114C01573    590-610	     PCELL_UE_CAP_3_CC_UL_SA
    ...    M55114C01574    0	         PCELL_UE_CAP_4_CC_UL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Sleep    120s
    Detach UE    cell_id=5
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55114C01579    0             PCELL_UE_CAP_5_CC_DL_MAX_SA
    ...    M55114C01580    0             PCELL_UE_CAP_6_CC_DL_MAX_SA
    ...    M55114C01581    2             PCELL_UE_CAP_7_CC_DL_MAX_SA
    ...    M55114C01582    0	         PCELL_UE_CAP_8_CC_DL_MAX_SA
    ...    M55114C01585    2             PCELL_UE_CAP_3_CC_UL_MAX_SA
    ...    M55114C01586    0	         PCELL_UE_CAP_4_CC_UL_MAX_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
	Detach UE    cell_id=6

	Multi UE    cell_id_1=7  cell_id_2=8
    Wait for next full pm interval
	${pm_counters}=  Wait for next pm interval and get counters
	Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55114C01567    0	         PCELL_UE_CAP_5_CC_DL_SA
    ...    M55114C01568    0	         PCELL_UE_CAP_6_CC_DL_SA
    ...    M55114C01569    0	         PCELL_UE_CAP_7_CC_DL_SA
    ...    M55114C01570    590-610       PCELL_UE_CAP_8_CC_DL_SA
    ...    M55114C01573    0		     PCELL_UE_CAP_3_CC_UL_SA
    ...    M55114C01574    590-610       PCELL_UE_CAP_4_CC_UL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Sleep    120s
    Detach UE    cell_id=7
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55114C01579    0             PCELL_UE_CAP_5_CC_DL_MAX_SA
    ...    M55114C01580    0             PCELL_UE_CAP_6_CC_DL_MAX_SA
    ...    M55114C01581    0             PCELL_UE_CAP_7_CC_DL_MAX_SA
    ...    M55114C01582    2	         PCELL_UE_CAP_8_CC_DL_MAX_SA
    ...    M55114C01585    0             PCELL_UE_CAP_3_CC_UL_MAX_SA
    ...    M55114C01586    2	         PCELL_UE_CAP_4_CC_UL_MAX_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
	Detach UE    cell_id=8

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
	[Arguments]  ${cell_id_1}  ${cell_id_2}
    Execute egate command    cmd=set_pdu_param ue=${cell_id_1} pdu=1 trf_type=internal
    Execute egate command    cmd=ue_register id=${cell_id_1}
    sleep    2s
    Execute egate command    cmd=ue_pdu_session_setup pdu=1 ue=${cell_id_1} nwslice=1 gw=1
    sleep    30s
    Execute egate command    cmd=set_pdu_param ue=${cell_id_2} pdu=1 trf_type=internal
    Execute egate command    cmd=ue_register id=${cell_id_2}
    sleep    2s
    Execute egate command    cmd=ue_pdu_session_setup pdu=1 ue=${cell_id_2} nwslice=1 gw=1

Detach UE
	[Arguments]  ${cell_id}
    Execute egate command
    ...    cmd=ue_deregister id=${cell_id} ue_deregister_type=switch_off

