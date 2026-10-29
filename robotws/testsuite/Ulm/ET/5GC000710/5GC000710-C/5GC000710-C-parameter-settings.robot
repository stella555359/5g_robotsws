*** Settings ***
Documentation   This is a keyword file for 5GC000710-C, part parameter settings
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

prepare counters and expected values t1
    [Documentation]    [PRIVATE]    set expected counter values for priority test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00036}    NRMOP_SA_PROFILE_SELECTED_04       2    ${cell_distName}   NRMOP
    set test variable    @{M55157C00064}    NRMOP_SA_PROFILE_SELECTED_32       1    ${cell_distName}   NRMOP
    set test variable    @{M55124C01501}    NRRCC_RRC_RELEASE_REDIR_NR         2    ${cell_distName}   NRRCC
    set test variable    @{M55124C02002}    NRRCC_MEAS_A2_REC                  2    ${cell_distName}   NRRCC
    set test variable    ${used_mnc}           489
    set test variable    ${actRfspIndex}       true


prepare counters and expected values t2
    [Documentation]    [PRIVATE]    set expected counter values for capabilities test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00037}    NRMOP_SA_PROFILE_SELECTED_05       2    ${cell_distName}   NRMOP
    set test variable    @{M55124C01501}    NRRCC_RRC_RELEASE_REDIR_NR         1    ${cell_distName}   NRRCC
    set test variable    @{M55124C02002}    NRRCC_MEAS_A2_REC                  1    ${cell_distName}   NRRCC
    set test variable    ${used_mnc}           388
    set test variable    ${actRfspIndex}       false


prepare counters and expected values t3
    [Documentation]    [PRIVATE]    set expected counter values for rsrpCombined test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00034}    NRMOP_SA_PROFILE_SELECTED_02       1    ${cell_distName}   NRMOP
    set test variable    @{M55124C01501}    NRRCC_RRC_RELEASE_REDIR_NR         1    ${cell_distName}   NRRCC
    set test variable    @{M55124C02002}    NRRCC_MEAS_A2_REC                  2    ${cell_distName}   NRRCC
    set test variable    ${used_mnc}           489
    set test variable    ${actRfspIndex}       false


prepare counters and expected values t4
    [Documentation]    [PRIVATE]    set expected counter values for handover test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00036}    NRMOP_SA_PROFILE_SELECTED_04       2    ${cell_distName}   NRMOP
    set test variable    @{M55124C01501}    NRRCC_RRC_RELEASE_REDIR_NR         1    ${cell_distName}   NRRCC
    set test variable    @{M55124C02002}    NRRCC_MEAS_A2_REC                  1    ${cell_distName}   NRRCC
    set test variable    ${used_mnc}           489
    set test variable    ${actRfspIndex}       true


prepare counters and expected values t5
    [Documentation]    [PRIVATE]    set expected counter values for redirect to LTE test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55124C01501}    NRRCC_RRC_RELEASE_REDIR_NR         0    ${cell_distName}   NRRCC
    set test variable    @{M55124C01502}    NRRCC_RRC_RELEASE_REDIR_LTE        1    ${cell_distName}   NRRCC
    set test variable    @{M55124C02002}    NRRCC_MEAS_A2_REC                  1    ${cell_distName}   NRRCC
    set test variable    @{M55157C00038}    NRMOP_SA_PROFILE_SELECTED_06       1    ${cell_distName}   NRMOP
    set test variable    ${used_mnc}           489
    set test variable    ${actRfspIndex}       true
