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
[2]OAM_modify_parameter_with_5G_RAT_reset
   [Documentation]    OAM_modify_parameter_with_5G_RAT_reset
   [Setup]    SetUp Case
   [Teardown]  Teardown case
   TC.OAM_modify_parameter_with_5G_RAT_reset
    ...    WebUI_reset_times=${300}
    ...    KPI12_MAX=${369}
    ...    KPI12_AVG=${369}
    ...    min_duration=5       max_duration=15
