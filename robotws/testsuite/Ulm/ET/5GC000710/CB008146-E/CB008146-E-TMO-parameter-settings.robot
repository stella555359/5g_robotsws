*** Settings ***
Documentation   This is a keyword file for CB008146-E, part parameter settings
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
*** Variables ***

${cell_distName}                      NRCELL-10

*** Keywords ***

Prepare Counters And Expected Values t1
    [Documentation]    [PRIVATE]    set expected counter values for A2 redirect and HO test
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{M55157C00035}    NRMOP_SA_PROFILE_SELECTED_03       2    ${cell_distName}   NRMOP
    Set Test Variable    ${actRfspIndex}    true


Prepare Counters And Expected Values t2
    [Documentation]    [PRIVATE]    set expected counter values for A2 with measurement gap test
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{M55157C00035}    NRMOP_SA_PROFILE_SELECTED_03       1    ${cell_distName}   NRMOP
    Set Test Variable    ${actRfspIndex}    true


Prepare Counters And Expected Values t3
    [Documentation]    [PRIVATE]    set expected counter values for A1 without measurement gap test
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{M55157C00035}    NRMOP_SA_PROFILE_SELECTED_03       1    ${cell_distName}   NRMOP
    Set Test Variable    ${actRfspIndex}    true


Prepare Counters And Expected Values t4
    [Documentation]    [PRIVATE]    set expected counter values for A1 voice test
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{M55157C00035}    NRMOP_SA_PROFILE_SELECTED_03       1    ${cell_distName}   NRMOP
    Set Test Variable    ${actRfspIndex}    true


Prepare Counters And Expected Values t5
    [Documentation]    [PRIVATE]    set expected counter values for interGnb interFreq HO test
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{M55157C00036}    NRMOP_SA_PROFILE_SELECTED_04       2    ${cell_distName}   NRMOP
    Set Test Variable    ${actRfspIndex}    true


Prepare Counters And Expected Values t6
    [Documentation]    [PRIVATE]    set expected counter values for A2 after interGnb intraFreq HO test
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{M55157C00037}    NRMOP_SA_PROFILE_SELECTED_05       2    ${cell_distName}   NRMOP
    Set Test Variable    ${actRfspIndex}    false
