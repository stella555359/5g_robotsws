*** Settings ***
Library    taf.ul.hanging_resources

*** Test Cases ***
Test Resources And Resource Checks
    [TAGS]              HANGRES
    Log   Prepare the testline
    Log   Execute Commissioning
    
    ${resources_before}=   Get Resources Usage   node_id=0   node_type=gnb

    Log   Attach UE
    Log   Execute Traffic
    Log   Detach UE

    ${resources_after}=   Get Resources Usage   node_id=0   node_type=gnb
    
    Resources Should Be Equal   ${resources_before}   ${resources_after}

Test Resources And Resource Checks With No Excludes
    [TAGS]              HANGRES
    Log   Prepare the testline
    Log   Execute Commissioning
    
    ${resources_before}=   Get Resources Usage   node_id=0   node_type=gnb

    Log   Attach UE
    Log   Execute Traffic
    Log   Detach UE

    ${resources_after}=   Get Resources Usage   node_id=0   node_type=gnb
    
    Resources Should Be Equal   ${resources_before}   ${resources_after}    exclude=${None}

Test modification of Default Excludes Add cellState
    [TAGS]              HANGRES
    Configure Default Excluding Resource Paths   add=//cellState

Test modification of Default Excludes Remove cellState
    [TAGS]              HANGRES
    Configure Default Excluding Resource Paths   remove=//cellState
