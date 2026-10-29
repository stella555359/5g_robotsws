*** Settings ***
Documentation    author:Liu Tiffany
...              contact: n5liu@nokia-sbell.com
...                History: Do some adaption for CB006443 by LiuNing
...                History: Do some adaption for CB008181 by LiuNing
...               feature : CB008181
Suite Setup       KW.TestSuilt.Start     Stream_Master=${KPI_8962['Stream_Version']}
...    Original_Stream_list=${KPI_8962['CB008962_IA']['OriginalStream']}
Suite Teardown    KW.TestSuilt.Stop
Force Tags        CRT_22R3
Resource            ../CB006443/Resources/All_KW_Interface.robot

*** Variables ***
${REFERENCE_CONFIGURATION_ID}    CNF_5G_3

*** Test Cases ***
[1]Gen4_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
    [Documentation]     KPI1A
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.CB006443_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
    ...    WebUI_reset_times=${30}
    ...    KPI1a_MAX=${KPI_8962['CB008962_KPI1a']['CNF_5G_3']['KPI1a_MAX']}
    ...    KPI1a_AVG=${KPI_8962['CB008962_KPI1a']['CNF_5G_3']['KPI1a_AVG']}

[1]Gen4_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.CB006443_HA_04_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
    ...    Power_reset_times=${30}
    ...     KPI3_MAX=${KPI_8962['CB008962_KPI3']['CNF_5G_3']['KPI3_MAX']}
    ...    KPI3_AVG=${KPI_8962['CB008962_KPI3']['CNF_5G_3']['KPI3_AVG']}
    ...    fail_loop_max=${KPI_8962['CB008962_KPI3']['CNF_5G_3']['fail_loop_max']}

[1]Gen4_OAM_KPI_51a_RU_Reset_Time
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.CB006443_HA_03_OAM_KPI_51a_RU_Reset_Time
    ...    RF_reset_times=${30}
    ...    KPI51_MAX=${KPI_8962['CB008962_KPI51a']['KPI51a_MAX']}
    ...    KPI51_AVG=${KPI_8962['CB008962_KPI51a']['KPI51a_AVG']}

[1]Gen4_OAM_KPI_17_Cell_Block_Unblock_manually
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    [Teardown]  Run Keywords      run keyword and ignore error    Teardown case
               ...   AND    run keyword and ignore error  DisConnect to DU by ADMIN API
    TC.CB006443_HA_05_OAM_KPI_17_Cell_Block_Unblock_manually
	...    repeat_times=${30}





