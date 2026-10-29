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
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB006443/Resources/All_KW_Interface.robot
*** Variables ***
${REFERENCE_CONFIGURATION_ID}    CNF_5G_18b

*** Test Cases ***

[1]OAM_KPI_RESET_ALL_BBMOD
   [Documentation]    reset all BBMOD
   [Setup]    SetUp Case
   [Teardown]  Teardown case
   TC.reset_all_BBMOD_loop
   ...    KPI5_MAX=${480}
   ...    repeat_times=${200}
   ...    fail_loop_max=${20}
   ...    reset_type=PowerReset
