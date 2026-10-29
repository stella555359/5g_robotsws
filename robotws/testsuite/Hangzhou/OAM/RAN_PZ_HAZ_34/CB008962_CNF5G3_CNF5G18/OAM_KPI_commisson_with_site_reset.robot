*** Settings ***
Documentation    author:Liu Tiffany
...              contact: n5liu@nokia-sbell.com
...                History: Do some adaption for CB006443 by LiuNing
...                History: Do some adaption for CB008181 by LiuNing
...               feature : CB008181
Suite Setup       KW.TestSuilt.Start     Stream_Master=${KPI_8962['Stream_Version']}
...       Original_Stream_list=${KPI_8962['CB008962_IA']['OriginalStream']}
#...       do_commission=${True}
Suite Teardown    KW.TestSuilt.Stop
Force Tags        CRT_22R3
Resource            ../CB006443/Resources/All_KW_Interface.robot


*** Variables ***
${REFERENCE_CONFIGURATION_ID}    CNF_5G_18b

*** Test Cases ***
[1]OAM_KPI_12_Commission_with_Site_Reset
   [Documentation]    KPI12
   [Setup]    SetUp Case
   [Teardown]  Teardown case
   TC.OAM_KPI_12_Commission_with_Site_Reset
    ...    WebUI_reset_times=${500}
    ...    min_duration=3
    ...    max_duration=15
    ...    Snapshot=${True}
    #...    WebUI_reset_times=${KPI_8962['KPI12']['CNF_5G_18']['test_loops']}
    ...    fail_loops=${KPI_8962['KPI12']['CNF_5G_18']['fail_loops']}
    ...    KPI12_MAX=${KPI_8962['KPI12']['CNF_5G_18']['KPI12_MAX']}
    ...    KPI12_AVG=${KPI_8962['KPI12']['CNF_5G_18']['KPI12_AVG']}

