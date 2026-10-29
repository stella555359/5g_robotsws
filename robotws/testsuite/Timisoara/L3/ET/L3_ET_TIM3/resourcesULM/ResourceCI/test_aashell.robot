*** Settings ***
Resource   ../aashell.robot
Library    Collections

*** Variables ***

*** Test Cases ***

test_aashell
    [TAGS]              AASHELL
    aashell.Setup aashell session  node_id=0
    ${resource_usage_1}  aashell.Get resource usage from node  node_id=0
    ${resource_usage_2}  Collections.copy dictionary  ${resource_usage_1}  deepcopy=${True}  
    aashell.compare resource usage   ${resource_usage_1}  ${resource_usage_2}
    aashell.store resource usage output  resourcefile_1.json  ${resource_usage_1}
    aashell.store deepdiff result  ${resource_usage_1}  ${resource_usage_2}
    Collections.set to dictionary  ${resource_usage_2}  maxNumOfBearerGroups  5
    Run keyword and expect error  *should be true.  aashell.compare resource usage   ${resource_usage_1}  ${resource_usage_2}  ignore=${False}
    aashell.store deepdiff result  ${resource_usage_1}  ${resource_usage_2}   
    aashell.Teardown aashell session  node_id=0
