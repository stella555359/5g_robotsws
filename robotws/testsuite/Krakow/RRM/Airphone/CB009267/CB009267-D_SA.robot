*** Settings ***
Documentation
...        maintainer:   Karol Rybak, Patryk Wojcik
...        author:       Karol Rybak, Patryk Wojcik
...        contact:      karol.rybak@nokia.com, patryk.wojcik@nokia.com
...        description:  Test Cases for CB009267-D_SA

Resource    ./resources/CB009267_KW.robot

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
    Wait For Next Full Pm Interval
    Attach UE SA  ue_id_first=9  ue_id_last=11  pdu=1
    Sleep    60s
    Detach UE SA  ue_id_first=9  ue_id_last=11
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55118C00090    120-200       PCELL_DL_4_SCELL_CONFIG_DUR_SA
    ...    M55118C00091    0             PCELL_DL_5_SCELL_CONFIG_DUR_SA
    ...    M55118C00092    0             PCELL_DL_6_SCELL_CONFIG_DUR_SA
    ...    M55118C00093    0             PCELL_DL_7_SCELL_CONFIG_DUR_SA
    ...    M55118C00095    120-200       PCELL_UL_2_SCELL_CONFIG_DUR_SA
    ...    M55118C00096    0             PCELL_UL_3_SCELL_CONFIG_DUR_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Set maxNumScellsDlFr2SA to 5 and maxNumScellsUlFr2SA to 3
    Wait For Next Full Pm Interval
    Attach UE SA  ue_id_first=9  ue_id_last=11  pdu=1
    Sleep    60s
    Detach UE SA  ue_id_first=9  ue_id_last=11
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55118C00090    0             PCELL_DL_4_SCELL_CONFIG_DUR_SA
    ...    M55118C00091    120-200       PCELL_DL_5_SCELL_CONFIG_DUR_SA
    ...    M55118C00092    0             PCELL_DL_6_SCELL_CONFIG_DUR_SA
    ...    M55118C00093    0             PCELL_DL_7_SCELL_CONFIG_DUR_SA
    ...    M55118C00095    0             PCELL_UL_2_SCELL_CONFIG_DUR_SA
    ...    M55118C00096    120-200       PCELL_UL_3_SCELL_CONFIG_DUR_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Set maxNumScellsDlFr2SA to 6 and maxNumScellsUlFr2SA to 2
    Wait For Next Full Pm Interval
    Attach UE SA  ue_id_first=9  ue_id_last=11  pdu=1
    Sleep    60s
    Detach UE SA  ue_id_first=9  ue_id_last=11
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55118C00090    0             PCELL_DL_4_SCELL_CONFIG_DUR_SA
    ...    M55118C00091    0             PCELL_DL_5_SCELL_CONFIG_DUR_SA
    ...    M55118C00092    120-200       PCELL_DL_6_SCELL_CONFIG_DUR_SA
    ...    M55118C00093    0             PCELL_DL_7_SCELL_CONFIG_DUR_SA
    ...    M55118C00095    120-200       PCELL_UL_2_SCELL_CONFIG_DUR_SA
    ...    M55118C00096    0             PCELL_UL_3_SCELL_CONFIG_DUR_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Set maxNumScellsDlFr2SA to 7 and maxNumScellsUlFr2SA to 3
    Wait For Next Full Pm Interval
    Attach UE SA  ue_id_first=9  ue_id_last=11  pdu=1
    Sleep    60s
    Detach UE SA  ue_id_first=9  ue_id_last=11
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55118C00090    0             PCELL_DL_4_SCELL_CONFIG_DUR_SA
    ...    M55118C00091    0             PCELL_DL_5_SCELL_CONFIG_DUR_SA
    ...    M55118C00092    0             PCELL_DL_6_SCELL_CONFIG_DUR_SA
    ...    M55118C00093    120-200       PCELL_DL_7_SCELL_CONFIG_DUR_SA
    ...    M55118C00095    0             PCELL_UL_2_SCELL_CONFIG_DUR_SA
    ...    M55118C00096    120-200       PCELL_UL_3_SCELL_CONFIG_DUR_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report

CB009267_D_Number_of_Ues_supporting_various_CC_DL_and_UL_for_SA
	Set maxNumScellsDlFr2SA to 7 and maxNumScellsUlFr2SA to 3
    Attach UE SA  ue_id_first=1  ue_id_last=3  pdu=1
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
    Detach UE SA  ue_id_first=1  ue_id_last=2
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
    Detach UE SA  ue_id_first=2  ue_id_last=3

    Attach UE SA  ue_id_first=3  ue_id_last=5  pdu=1
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
    Detach UE SA  ue_id_first=3  ue_id_last=4
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
    Detach UE SA  ue_id_first=4  ue_id_last=5

    Attach UE SA  ue_id_first=5  ue_id_last=7  pdu=1
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
    Detach UE SA  ue_id_first=5  ue_id_last=6
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
    Detach UE SA  ue_id_first=6  ue_id_last=7

    Attach UE SA  ue_id_first=7  ue_id_last=9  pdu=1
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
    Detach UE SA  ue_id_first=7  ue_id_last=8
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
    Detach UE SA  ue_id_first=8  ue_id_last=9
    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report

