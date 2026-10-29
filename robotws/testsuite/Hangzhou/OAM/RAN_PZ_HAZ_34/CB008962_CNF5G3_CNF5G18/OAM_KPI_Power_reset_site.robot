*** Settings ***
Documentation    author:Liu Tiffany
...              contact: n5liu@nokia-sbell.com
...                History: Do some adaption for CB006443 by LiuNing
...                History: Do some adaption for CB008181 by LiuNing
...               feature : CB008181
Suite Setup       KW.TestSuilt.Start     Stream_Master=${KPI_8962['Stream_Version']}
...       Original_Stream_list=${KPI_8962['CB008962_IA']['OriginalStream']}
...       do_commission=${True}
Suite Teardown    KW.TestSuilt.Stop
Force Tags        CRT_22R3
Resource            ../CB006443/Resources/All_KW_Interface.robot

*** Variables ***
${REFERENCE_CONFIGURATION_ID}    CNF_5G_18b

*** Test Cases ***

[1]Gen5_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
    [Documentation]
    [Tags]     CDRT_TRUNK
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.CB006443_HA_04_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
    ...    Power_reset_times=${500}
    ...     KPI3_MAX=${KPI_8962['CB008962_KPI3']['CNF_5G_18']['KPI3_MAX']}
    ...    KPI3_AVG=${KPI_8962['CB008962_KPI3']['CNF_5G_18']['KPI3_AVG']}
    ...    fail_loop_max=${8}

