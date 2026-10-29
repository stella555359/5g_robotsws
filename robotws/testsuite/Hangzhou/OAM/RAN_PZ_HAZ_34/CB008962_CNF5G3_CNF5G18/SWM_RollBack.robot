# *** Settings ***
# Documentation    author:Liu Tiffany
# ...              contact: n5liu@nokia-sbell.com
# ...                History: Do some adaption for CB006443 by LiuNing
# ...                History: Do some adaption for CB008181 by LiuNing
# ...               feature : CB008181
# Suite Setup       KW.TestSuilt.Start     Stream_Master=${KPI_8962['Stream_Version']}
# ...    Original_Stream_list=${KPI_8962['CB008962_IA']['OriginalStream']}
# Suite Teardown    KW.TestSuilt.Stop
# Force Tags
# Resource            ../CB006443/Resources/All_KW_Interface.robot
# 
# *** Test Cases ***
# [1]20_OAM_KPI_2b_SWM_Outage_Duration_of_SW_activation_Inter_Release_with_SM_Firmware_Upgrade
#     [Documentation]
#     [Tags]     C&P
#     [Setup]    TestCase.Start_CB006443
#     [Teardown]  TestteardownforWebEM
#     RUN KEYWORD AND CONTINUE ON FAILURE
#     ...    KW.KPI13_rollback
#     ...    KPI13_Target=${840}
# 
# 
# 
