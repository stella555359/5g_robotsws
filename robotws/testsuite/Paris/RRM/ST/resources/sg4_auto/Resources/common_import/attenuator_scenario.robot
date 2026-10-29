*** Settings ***
Documentation
...         TODO


Library           OperatingSystem
Library           XML    lxml=TRUE
Library           String
Library           Collections
Library           ./python/attenuator_scenario.py

*** Keywords ***

run attenuator scenario
    [Arguments]    ${att}    ${att_file}    ${scenario}    ${wait_time}=500ms
    [Documentation]
    ...    Input Parameters:
    ...    - ${att}: Attenuator name as defined in hosts file or ip address
    ...    - ${att_file}: File in which the attenuator scenarios are defined
    ...    - ${scenario}: specifies the scenario to un
    ...    - ${wait_time}: wait time between instances (optional)
    ...    implementation of pegasus functionality:
    ...    takes a attenuator file with syntax:
    ...    SECTION test
    ...    CH1  = (1,0) (10,30) (20,30) (40,50)
    ...    CH2  = (1,0) (10,100)
    ...    (same syntax as used with pegasus)
    ${result}=    read_att_section    ${att_file}    ${scenario}
    ${number_of_blocks}=    Get Length    ${result}
    FOR    ${step_index}    IN RANGE    0    ${number_of_blocks}    1
        set_physical_blocks    ${att}  @{result}[${step_index}]    ${wait_time}
    END

set physical blocks
    [Arguments]    ${att}  ${step}    ${wait_time}
    [Documentation]
    ...    sets all Attenuator channels on channel-list for given step
    ...    necessary keyword for 'run attenuator scenario'
    ...    for each step set all defined attenuator blocks
    ${block_length}=    Get length    ${step}
    FOR    ${index}    IN RANGE    0    ${block_length}    1
        @{elements}=    Split string    @{step}[${index}]    :
        ${channel}=    Get from list    ${elements}    0
        ${channel_nbr}=    Get Substring    ${channel}    2
        ${channel_nbr}=  Convert to integer  ${channel_nbr}
        ${value}=    Get from list    ${elements}    1
        ${value}=  Convert to integer  ${value}
        ${result}=   attenuator.set_attenuation  port=${channel_nbr}  value=${value}  attenuator_device=${att}
    END
    Sleep    ${wait_time}
