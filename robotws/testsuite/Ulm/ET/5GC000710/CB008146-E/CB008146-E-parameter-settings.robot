*** Settings ***
Documentation   This is a keyword file for CB008146-E, part parameter settings
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
*** Variables ***

${cell_distName}                      NRCELL-3

*** Keywords ***

prepare counters and expected values t1
    [Documentation]    [PRIVATE]    set expected counter values for A2 redirect and HO test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00035}    NRMOP_SA_PROFILE_SELECTED_03       2    ${cell_distName}   NRMOP
    set test variable    ${used_mnc}        489
    set test variable    ${actRfspIndex}    true


prepare counters and expected values t2
    [Documentation]    [PRIVATE]    set expected counter values for A2 with measurement gap test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00035}    NRMOP_SA_PROFILE_SELECTED_03       1    ${cell_distName}   NRMOP
    set test variable    ${used_mnc}        489
    set test variable    ${actRfspIndex}    true


prepare counters and expected values t3
    [Documentation]    [PRIVATE]    set expected counter values for A1 without measurement gap test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00035}    NRMOP_SA_PROFILE_SELECTED_03       1    ${cell_distName}   NRMOP
    set test variable    ${used_mnc}       489
    set test variable    ${actRfspIndex}   true


prepare counters and expected values t4
    [Documentation]    [PRIVATE]    set expected counter values for A1 voice test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00035}    NRMOP_SA_PROFILE_SELECTED_03       1    ${cell_distName}   NRMOP
    set test variable    ${used_mnc}        489
    set test variable    ${actRfspIndex}    true


prepare counters and expected values t5
    [Documentation]    [PRIVATE]    set expected counter values for interGnb interFreq HO test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00036}    NRMOP_SA_PROFILE_SELECTED_04       2    ${cell_distName}   NRMOP
    set test variable    ${used_mnc}        489
    set test variable    ${actRfspIndex}    true


prepare counters and expected values t6
    [Documentation]    [PRIVATE]    set expected counter values for A2 after interGnb intraFreq HO test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00037}    NRMOP_SA_PROFILE_SELECTED_05       2    ${cell_distName}   NRMOP
    set test variable    ${used_mnc}        388
    set test variable    ${actRfspIndex}    false



prepare counters and expected values 2 cell config
    [Documentation]    [PRIVATE]    set expected counter values for 2 cell config test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00034}    NRMOP_SA_PROFILE_SELECTED_02       1    NRCELL-1   NRMOP
    set test variable    @{M55157C00035}    NRMOP_SA_PROFILE_SELECTED_03       1    NRCELL-1   NRMOP
    set test variable    @{M55157C00036}    NRMOP_SA_PROFILE_SELECTED_04       1    NRCELL-2   NRMOP
