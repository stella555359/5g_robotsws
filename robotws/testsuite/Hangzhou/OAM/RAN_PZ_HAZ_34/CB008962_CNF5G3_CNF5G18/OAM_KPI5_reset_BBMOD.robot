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
# 
# [1]CB006443_HA_06_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration
#    [Setup]    SetUp Case
#    [Teardown]  Teardown case
#     RUN KEYWORD AND CONTINUE ON FAILURE
#     ...    TC.CB006443_HA_06_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration
#     ...    KPI5_MAX=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['KPI5_MAX']}
#     #...    repeat_times=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['BBMOD_reset_times']}
#     ...    fail_loop_max=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['fail_loop_max']}
#     ...    repeat_times=${1}
# 
# 
# 
# 
