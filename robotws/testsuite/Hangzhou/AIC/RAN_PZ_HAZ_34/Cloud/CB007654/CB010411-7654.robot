*** Settings ***
Documentation
...   author: menghua.luo@nokia-sbell.com
...   contact: menghua.luo@nokia-sbell.com
...   Description:
...   This test case is used to check vCU & vDU M55601 PM counters
...   Removal unused cases by civen.chen


#Suite Setup    AiC Common Suite Setup
#Suite Teardown    AiC Common Suite Teardown
#Test Setup    AiC Common Case Setup
##Test Teardown    AiC Common Test Teardown
#
#Force Tags
#...    CLOUD_5G_AIC                               #TL_TYPE
#...    STATE_ON_AIR                               #gNB_STATE
#...    TA_LEVEL_22_FULL_AUTOMATED_CIT_CRT         #Detailed Automation Level
#
#Test Timeout    120 minutes
#
#Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB007654/Resources/CB007654_resources.robot
#Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB007654/Resources/CB007654_common.robot
#
#*** Variables ***
#${testline_id}    ${879}
#
#*** Test Cases ***
#[1]CB010411-H_001_Monitoring_of_the_cell_being_planned_unavailable_due_to_explicit_NR_cell_locking
#    [Documentation]    *****************
#    ...    check PM counter M55601C01001 & M55601C01002 update after parameter modification caused NRCELL down and up
#    ...    *****************
#    [Tags]  CRT_TRUNK
#    Check counters by object_locking at vDU
#    Check counters by object_locking at vCU
#
#[1]CB010411-H_007_Monitoring_of_the_cell_being_unplanned_unavailable_reset_RU
#    [Documentation]    *****************
#    ...    check PM counter M55601C01003 & M55601C01004 update after locking cell
#    ...    *****************
#    [Tags]  CRT_TRUNK
#    Check counters by locking cell at vDU
#    Check counters by locking cell at vCU
