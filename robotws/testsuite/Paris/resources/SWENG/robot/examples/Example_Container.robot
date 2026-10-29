*** Settings ***
Documentation        just an exemple about how to use the container tool

Resource                            ../Tools.robot
Resource                            ../Setup.robot
Resource                            ../Container.robot

Suite Setup                         Suite Setup

*** Test Cases ***
Test Get Log
    Search Log                      name=CPUE           cardIndex=0     capacityIndex=0
    Search Log                      name=CPUE           cardIndex=0     capacityIndex=1
    Search Log                      name=CPUE           cardIndex=1     capacityIndex=0
    Search Log                      name=CPUE           cardIndex=1     capacityIndex=1
    Search Log                      name=CPUE           capacityIndex=0
    Search Log                      name=CPUE           capacityIndex=1
    Search Log                      name=CPUE
    Search Log                      name=CPUE           cardIndex=0
    Search Log                      name=CPUE           cardIndex=1
    Search Log                      CPUE
    Search Log                      name=CPUE           cardIndex=2     capacityIndex=0


Test Get Node
    Search Node                     name=CPUE           cardIndex=0     capacityIndex=0
    Search Node                     name=CPUE           cardIndex=0     capacityIndex=1
    Search Node                     name=CPUE           cardIndex=1     capacityIndex=0
    Search Node                     name=CPUE           cardIndex=1     capacityIndex=1
    Search Node                     name=CPUE           capacityIndex=0
    Search Node                     name=CPUE           capacityIndex=1
    Search Node                     name=CPUE
    Search Node                     name=CPUE           cardIndex=0
    Search Node                     name=CPUE           cardIndex=1
    Search Node                     name=CPUE           cardIndex=2     capacityIndex=0

*** Keywords ***
Search Log
    [Arguments]                     ${name}             ${cardIndex}=0          ${capacityIndex}=0
    ${log}                          Get Log
    ...                             name=${name}    cardIndex=${cardIndex}
    ...                             capacityIndex=${capacityIndex}
    Dated log                       SEARCH:NODE=${name} Card=${cardIndex} CapacityIndex=${capacityIndex} : LOG=${log}

Search Node
    [Arguments]                     ${name}             ${cardIndex}=0          ${capacityIndex}=0
    ${node}                         Get Node
    ...                             name=${name}    cardIndex=${cardIndex}
    ...                             capacityIndex=${capacityIndex}
    Dated log                       SEARCH:NODE=${name} Card=${cardIndex} CapacityIndex=${capacityIndex} : NODE=${node}