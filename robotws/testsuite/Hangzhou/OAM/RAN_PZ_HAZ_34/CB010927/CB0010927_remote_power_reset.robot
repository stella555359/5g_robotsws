*** Settings ***
Documentation    author:Liu Tiffany
...              contact: n5liu@nokia-sbell.com
...                History: Do some adaption for CB006443 by LiuNing
...                History: Do some adaption for CB008181 by LiuNing
...               feature : CB008181
Suite Setup       KW.TestSuilt.Start     Stream_Master=${KPI_8962['Stream_Version']}
...       Original_Stream_list=${KPI_8962['CB008962_IA']['OriginalStream']}
...       do_commission=${True}
#Suite Setup       log to console    1111111
Suite Teardown    KW.TestSuilt.Stop
#Suite Teardown    log to console    22222
Force Tags        CRT
Resource            ../CB006443/Resources/All_KW_Interface.robot


*** Variables ***
${REFERENCE_CONFIGURATION_ID}    CNF_5G_18b

*** Test Cases ***
[1][1.0] General_SiSo_Auto_Startup_BTS_power_reset_with_L3call
   [Documentation]    CB010927 regression
   [Setup]    SetUp Case
   [Teardown]  Teardown case
   #[Setup]    log to console    1111111
   #[Teardown]  log to console    333333
   Run keyword and continue on failure     TC.KPI11_remote_power_reset
   ...    WebUI_reset_times=${1}
   ...    fail_loops=${10}
   ...    KPI11_MAX=${500}
   ...    KPI11_AVG=${500}
   #Run keyword and continue on failure    Making call and check TP for one UE



