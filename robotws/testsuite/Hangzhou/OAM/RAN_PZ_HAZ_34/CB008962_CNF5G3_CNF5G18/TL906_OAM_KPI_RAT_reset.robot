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
[1]OAM_KPI_10_RAT_Reset
   [Documentation]    KPI51a
   [Setup]    SetUp Case
   [Teardown]  Teardown case
   TC.OAM_KPI_HA_01_OAM_RAT_reset
  ...    WebUI_reset_times=${600}
  ...    KPI10_MAX=${380}
  ...    KPI10_AVG=${380}
  ...    rat_type=NR     reset_typ=Hard
  #...    rat_type=LTE     reset_typ=Soft

