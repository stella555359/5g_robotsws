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
[1]OAM_KPI_Block_Site
   [Documentation]    Block_Site
   [Setup]    SetUp Case
   [Teardown]  Teardown case
   TC.OAM_KPI_block_unblock_site
  ...    WebUI_reset_times=${414}
  ...    KPI_MAX=${360}
  ...    KPI_AVG=${300}
  ...    min_duration=15
  ...    max_duration=50

