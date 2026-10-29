*** Settings ***
Documentation   This is a keyword file for 5GC000480-L, part parameter settings
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***
${text_M55114C00001}           The number of radio admission requests for NSA user
${text_M55114C00002}           The number of radio admitted UEs for NSA user
${text_M55114C00003}           The number of non-GBR DRB radio admission requests for NSA user
${text_M55114C00004}           The number of radio admitted non-GBR DRBs for NSA user
${text_M55114C00010}           Peak number of NSA users
${text_M55114C00021}           The number of radio admission requests for 1 Scell
${text_M55114C00022}           The number of radio admission requests for 2 Scells
${text_M55114C00023}           The number of radio admission requests for 3 Scells
${text_M55114C00028}           The number of successful radio admissions for 1 Scell addition
${text_M55114C00029}           The number of successful radio admissions for 2 Scell additions
${text_M55114C00030}           The number of successful radio admissions for 3 Scell additions
${text_M55114C00035}           The number of unsuccessful radio admissions for Scells additions
${text_M55114C00036}           Peak number of NSA users in the cell group

${text_M55115C00002}           The number of admission requests for NSA user
${text_M55115C00003}           The number of successful radio admitted NSA users
${text_M55115C00006}           The number of radio admission requests for the Scell
${text_M55115C00007}           The number of successful radio admissions for the Scell
${text_M55115C00008}           The number of radio admission requests for 1 Scell
${text_M55115C00009}           The number of radio admission requests for 2 Scells
${text_M55115C00010}           The number of radio admission requests for 3 Scells
${text_M55115C00015}           The number of successful radio admissions for 1 Scell additions
${text_M55115C00016}           The number of successful radio admissions for 2 Scell additions
${text_M55115C00017}           The number of successful radio admissions for 3 Scell additions


*** Keywords ***

Prepare Counters And Expected Values 4CC
    [Documentation]    [PRIVATE]    set expected values for evaluation_of_RAC_for_a_UE_with_carrier_aggregation_4CC_contiguous_carriers test
    ...                             set expected values for evaluation_of_RAC_for_a_UE_with_carrier_aggregation_4CC_non_contiguous_carriers test
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{M55114C00001_cell1}             ${text_M55114C00001}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00002_cell1}             ${text_M55114C00002}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00003_cell1}             ${text_M55114C00003}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00004_cell1}             ${text_M55114C00004}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00010_cell1}             ${text_M55114C00010}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00023_cell1}             ${text_M55114C00023}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00030_cell1}             ${text_M55114C00030}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00035_cell1}             ${text_M55114C00035}     0    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00036_cell1}             ${text_M55114C00036}     1    NRCELL-1   RACCU

    Set Test Variable    @{M55115C00002_cell1}             ${text_M55115C00002}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00003_cell1}             ${text_M55115C00003}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00010_cell1}             ${text_M55115C00010}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00017_cell1}             ${text_M55115C00017}     1    NRCELL-1   RACDU

    Set Test Variable    @{M55115C00006_cell2}             ${text_M55115C00006}     1    NRCELL-2   RACDU
    Set Test Variable    @{M55115C00007_cell2}             ${text_M55115C00007}     1    NRCELL-2   RACDU

    Set Test Variable    @{M55115C00006_cell3}             ${text_M55115C00006}     1    NRCELL-3   RACDU
    Set Test Variable    @{M55115C00007_cell3}             ${text_M55115C00007}     1    NRCELL-3   RACDU

    Set Test Variable    @{M55115C00006_cell4}             ${text_M55115C00006}     1    NRCELL-4   RACDU
    Set Test Variable    @{M55115C00007_cell4}             ${text_M55115C00007}     1    NRCELL-4   RACDU


    Set Test Variable    &{dict_pm_counter1}         M55114C00001=${M55114C00001_cell1}
    ...                                              M55114C00002=${M55114C00002_cell1}
    ...                                              M55114C00003=${M55114C00003_cell1}
    ...                                              M55114C00004=${M55114C00004_cell1}
    ...                                              M55114C00010=${M55114C00010_cell1}
    ...                                              M55114C00023=${M55114C00023_cell1}
    ...                                              M55114C00030=${M55114C00030_cell1}
    ...                                              M55114C00035=${M55114C00035_cell1}
    ...                                              M55114C00036=${M55114C00036_cell1}
    ...                                              M55115C00002=${M55115C00002_cell1}
    ...                                              M55115C00003=${M55115C00003_cell1}
    ...                                              M55115C00010=${M55115C00010_cell1}
    ...                                              M55115C00017=${M55115C00017_cell1}

    Set Test Variable    &{dict_pm_counter2}         M55115C00006=${M55115C00006_cell2}
    ...                                              M55115C00007=${M55115C00007_cell2}

    Set Test Variable    &{dict_pm_counter3}         M55115C00006=${M55115C00006_cell3}
    ...                                              M55115C00007=${M55115C00007_cell3}

    Set Test Variable    &{dict_pm_counter4}         M55115C00006=${M55115C00006_cell4}
    ...                                              M55115C00007=${M55115C00007_cell4}

    Set Test Variable    ${maxNumScellsDl}           3
    Set Test Variable    ${ccLoadThreshold}          30
    Set Test Variable    ${maxNumOfSCellAlloc_1}     106
    Set Test Variable    ${maxNumOfSCellAlloc_3}     106
    Set Test Variable    ${maxNumOfUsersPerCell}     106


Prepare Counters And Expected Values t2
    [Documentation]    [PRIVATE]    set expected values for evaluation_of_RAC_for_a_UE_with_carrier_aggregation_3CC_contiguous_carriers test
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{M55114C00001_cell1}             ${text_M55114C00001}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00002_cell1}             ${text_M55114C00002}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00003_cell1}             ${text_M55114C00003}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00004_cell1}             ${text_M55114C00004}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00010_cell1}             ${text_M55114C00010}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00022_cell1}             ${text_M55114C00022}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00029_cell1}             ${text_M55114C00029}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00035_cell1}             ${text_M55114C00035}     0    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00036_cell1}             ${text_M55114C00036}     1    NRCELL-1   RACCU

    Set Test Variable    @{M55115C00002_cell1}             ${text_M55115C00002}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00003_cell1}             ${text_M55115C00003}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00009_cell1}             ${text_M55115C00009}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00016_cell1}             ${text_M55115C00016}     1    NRCELL-1   RACDU

    Set Test Variable    @{M55115C00006_cell2}             ${text_M55115C00006}     1    NRCELL-2   RACDU
    Set Test Variable    @{M55115C00007_cell2}             ${text_M55115C00007}     1    NRCELL-2   RACDU

    Set Test Variable    @{M55115C00006_cell3}             ${text_M55115C00006}     1    NRCELL-3   RACDU
    Set Test Variable    @{M55115C00007_cell3}             ${text_M55115C00007}     1    NRCELL-3   RACDU

    Set Test Variable    @{M55115C00006_cell4}             ${text_M55115C00006}     0    NRCELL-4   RACDU
    Set Test Variable    @{M55115C00007_cell4}             ${text_M55115C00007}     0    NRCELL-4   RACDU


    Set Test Variable    &{dict_pm_counter1}         M55114C00001=${M55114C00001_cell1}
    ...                                              M55114C00002=${M55114C00002_cell1}
    ...                                              M55114C00003=${M55114C00003_cell1}
    ...                                              M55114C00004=${M55114C00004_cell1}
    ...                                              M55114C00010=${M55114C00010_cell1}
    ...                                              M55114C00022=${M55114C00022_cell1}
    ...                                              M55114C00029=${M55114C00029_cell1}
    ...                                              M55114C00035=${M55114C00035_cell1}
    ...                                              M55114C00036=${M55114C00036_cell1}
    ...                                              M55115C00002=${M55115C00002_cell1}
    ...                                              M55115C00003=${M55115C00003_cell1}
    ...                                              M55115C00009=${M55115C00009_cell1}
    ...                                              M55115C00016=${M55115C00016_cell1}

    Set Test Variable    &{dict_pm_counter2}         M55115C00006=${M55115C00006_cell2}
    ...                                              M55115C00007=${M55115C00007_cell2}

    Set Test Variable    &{dict_pm_counter3}         M55115C00006=${M55115C00006_cell3}
    ...                                              M55115C00007=${M55115C00007_cell3}

    Set Test Variable    &{dict_pm_counter4}         M55115C00006=${M55115C00006_cell4}
    ...                                              M55115C00007=${M55115C00007_cell4}

    Set Test Variable    ${maxNumScellsDl}           2
    Set Test Variable    ${ccLoadThreshold}          30
    Set Test Variable    ${maxNumOfSCellAlloc_1}     106
    Set Test Variable    ${maxNumOfSCellAlloc_3}     106
    Set Test Variable    ${maxNumOfUsersPerCell}     106




Prepare Counters And Expected Values 2CC
    [Documentation]    [PRIVATE]    set expected values for evaluation_of_RAC_for_a_UE_with_carrier_aggregation_2CC_contiguous_carriers test
    ...                             set expected values for evaluation_of_RAC_for_a_UE_with_carrier_aggregation_2CC_non_contiguous_carriers test
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{M55114C00001_cell1}             ${text_M55114C00001}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00002_cell1}             ${text_M55114C00002}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00003_cell1}             ${text_M55114C00003}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00004_cell1}             ${text_M55114C00004}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00010_cell1}             ${text_M55114C00010}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00021_cell1}             ${text_M55114C00021}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00028_cell1}             ${text_M55114C00028}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00035_cell1}             ${text_M55114C00035}     0    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00036_cell1}             ${text_M55114C00036}     1    NRCELL-1   RACCU

    Set Test Variable    @{M55115C00002_cell1}             ${text_M55115C00002}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00003_cell1}             ${text_M55115C00003}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00008_cell1}             ${text_M55115C00008}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00015_cell1}             ${text_M55115C00015}     1    NRCELL-1   RACDU

    Set Test Variable    @{M55115C00006_cell2}             ${text_M55115C00006}     1    NRCELL-2   RACDU
    Set Test Variable    @{M55115C00007_cell2}             ${text_M55115C00007}     1    NRCELL-2   RACDU

    Set Test Variable    @{M55115C00006_cell3}             ${text_M55115C00006}     0    NRCELL-3   RACDU
    Set Test Variable    @{M55115C00007_cell3}             ${text_M55115C00007}     0    NRCELL-3   RACDU

    Set Test Variable    @{M55115C00006_cell4}             ${text_M55115C00006}     0    NRCELL-4   RACDU
    Set Test Variable    @{M55115C00007_cell4}             ${text_M55115C00007}     0    NRCELL-4   RACDU


    Set Test Variable    &{dict_pm_counter1}         M55114C00001=${M55114C00001_cell1}
    ...                                              M55114C00002=${M55114C00002_cell1}
    ...                                              M55114C00003=${M55114C00003_cell1}
    ...                                              M55114C00004=${M55114C00004_cell1}
    ...                                              M55114C00010=${M55114C00010_cell1}
    ...                                              M55114C00021=${M55114C00021_cell1}
    ...                                              M55114C00028=${M55114C00028_cell1}
    ...                                              M55114C00035=${M55114C00035_cell1}
    ...                                              M55114C00036=${M55114C00036_cell1}
    ...                                              M55115C00002=${M55115C00002_cell1}
    ...                                              M55115C00003=${M55115C00003_cell1}
    ...                                              M55115C00008=${M55115C00008_cell1}
    ...                                              M55115C00015=${M55115C00015_cell1}

    Set Test Variable    &{dict_pm_counter2}         M55115C00006=${M55115C00006_cell2}
    ...                                              M55115C00007=${M55115C00007_cell2}

    Set Test Variable    &{dict_pm_counter3}         M55115C00006=${M55115C00006_cell3}
    ...                                              M55115C00007=${M55115C00007_cell3}

    Set Test Variable    &{dict_pm_counter4}         M55115C00006=${M55115C00006_cell4}
    ...                                              M55115C00007=${M55115C00007_cell4}

    Set Test Variable    ${maxNumScellsDl}           1
    Set Test Variable    ${ccLoadThreshold}          30
    Set Test Variable    ${maxNumOfSCellAlloc_1}     106
    Set Test Variable    ${maxNumOfSCellAlloc_3}     106
    Set Test Variable    ${maxNumOfUsersPerCell}     106



Prepare Counters And Expected Values t4
    [Documentation]    [PRIVATE]    set expected values for Unsuccessful_SCell_Addition_due_to_maxNumOfSCellAlloc_exceeded test
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{M55114C00001_cell1}             ${text_M55114C00001}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00002_cell1}             ${text_M55114C00002}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00003_cell1}             ${text_M55114C00003}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00004_cell1}             ${text_M55114C00004}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00010_cell1}             ${text_M55114C00010}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00023_cell1}             ${text_M55114C00023}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00028_cell1}             ${text_M55114C00028}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00030_cell1}             ${text_M55114C00030}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00035_cell1}             ${text_M55114C00035}     0    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00036_cell1}             ${text_M55114C00036}     2    NRCELL-1   RACCU

    Set Test Variable    @{M55115C00002_cell1}             ${text_M55115C00002}     2    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00003_cell1}             ${text_M55115C00003}     2    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00008_cell1}             ${text_M55115C00008}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00010_cell1}             ${text_M55115C00010}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00015_cell1}             ${text_M55115C00015}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00017_cell1}             ${text_M55115C00017}     1    NRCELL-1   RACDU

    Set Test Variable    @{M55115C00006_cell2}             ${text_M55115C00006}     2    NRCELL-2   RACDU
    Set Test Variable    @{M55115C00007_cell2}             ${text_M55115C00007}     2    NRCELL-2   RACDU

    Set Test Variable    @{M55115C00006_cell3}             ${text_M55115C00006}     1    NRCELL-3   RACDU
    Set Test Variable    @{M55115C00007_cell3}             ${text_M55115C00007}     1    NRCELL-3   RACDU

    Set Test Variable    @{M55115C00006_cell4}             ${text_M55115C00006}     1    NRCELL-4   RACDU
    Set Test Variable    @{M55115C00007_cell4}             ${text_M55115C00007}     1    NRCELL-4   RACDU


    Set Test Variable    &{dict_pm_counter1}         M55114C00001=${M55114C00001_cell1}
    ...                                              M55114C00002=${M55114C00002_cell1}
    ...                                              M55114C00003=${M55114C00003_cell1}
    ...                                              M55114C00004=${M55114C00004_cell1}
    ...                                              M55114C00010=${M55114C00010_cell1}
    ...                                              M55114C00023=${M55114C00023_cell1}
    ...                                              M55114C00028=${M55114C00028_cell1}
    ...                                              M55114C00030=${M55114C00030_cell1}
    ...                                              M55114C00035=${M55114C00035_cell1}
    ...                                              M55114C00036=${M55114C00036_cell1}
    ...                                              M55115C00002=${M55115C00002_cell1}
    ...                                              M55115C00003=${M55115C00003_cell1}
    ...                                              M55115C00008=${M55115C00008_cell1}
    ...                                              M55115C00010=${M55115C00010_cell1}
    ...                                              M55115C00015=${M55115C00015_cell1}
    ...                                              M55115C00017=${M55115C00017_cell1}

    Set Test Variable    &{dict_pm_counter2}         M55115C00006=${M55115C00006_cell2}
    ...                                              M55115C00007=${M55115C00007_cell2}

    Set Test Variable    &{dict_pm_counter3}         M55115C00006=${M55115C00006_cell3}
    ...                                              M55115C00007=${M55115C00007_cell3}

    Set Test Variable    &{dict_pm_counter4}         M55115C00006=${M55115C00006_cell4}
    ...                                              M55115C00007=${M55115C00007_cell4}

    Set Test Variable    ${maxNumScellsDl}           3
    Set Test Variable    ${ccLoadThreshold}          30
    Set Test Variable    ${maxNumOfSCellAlloc_1}     106
    Set Test Variable    ${maxNumOfSCellAlloc_3}     1
    Set Test Variable    ${maxNumOfUsersPerCell}     106


Prepare Counters And Expected Values t5
    [Documentation]    [PRIVATE]    set expected values for Unsuccessful_SCell_Addition_due_to_maxNumOfUsersPerCell_exceeded test
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{M55114C00001_cell1}             ${text_M55114C00001}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00002_cell1}             ${text_M55114C00002}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00003_cell1}             ${text_M55114C00003}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00004_cell1}             ${text_M55114C00004}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00010_cell1}             ${text_M55114C00010}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00023_cell1}             ${text_M55114C00023}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00030_cell1}             ${text_M55114C00030}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00035_cell1}             ${text_M55114C00035}     0    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00036_cell1}             ${text_M55114C00036}     3    NRCELL-1   RACCU

    Set Test Variable    @{M55115C00002_cell1}             ${text_M55115C00002}     2    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00003_cell1}             ${text_M55115C00003}     2    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00006_cell1}             ${text_M55115C00006}     0    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00007_cell1}             ${text_M55115C00007}     0    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00010_cell1}             ${text_M55115C00010}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00017_cell1}             ${text_M55115C00017}     1    NRCELL-1   RACDU

    Set Test Variable    @{M55114C00001_cell2}             ${text_M55114C00001}     1    NRCELL-2   RACCU
    Set Test Variable    @{M55114C00002_cell2}             ${text_M55114C00002}     1    NRCELL-2   RACCU
    Set Test Variable    @{M55114C00003_cell2}             ${text_M55114C00003}     1    NRCELL-2   RACCU
    Set Test Variable    @{M55114C00004_cell2}             ${text_M55114C00004}     1    NRCELL-2   RACCU
    Set Test Variable    @{M55114C00010_cell2}             ${text_M55114C00010}     1    NRCELL-2   RACCU
    Set Test Variable    @{M55114C00023_cell2}             ${text_M55114C00023}     1    NRCELL-2   RACCU
    Set Test Variable    @{M55114C00029_cell2}             ${text_M55114C00029}     1    NRCELL-2   RACCU
    Set Test Variable    @{M55114C00035_cell2}             ${text_M55114C00035}     0    NRCELL-2   RACCU

    Set Test Variable    @{M55115C00002_cell2}             ${text_M55115C00002}     1    NRCELL-2   RACDU
    Set Test Variable    @{M55115C00003_cell2}             ${text_M55115C00003}     1    NRCELL-2   RACDU
    Set Test Variable    @{M55115C00006_cell2}             ${text_M55115C00006}     1    NRCELL-2   RACDU
    Set Test Variable    @{M55115C00007_cell2}             ${text_M55115C00007}     1    NRCELL-2   RACDU
    Set Test Variable    @{M55115C00009_cell2}             ${text_M55115C00009}     1    NRCELL-2   RACDU
    Set Test Variable    @{M55115C00016_cell2}             ${text_M55115C00016}     1    NRCELL-2   RACDU

    Set Test Variable    @{M55115C00006_cell3}             ${text_M55115C00006}     2    NRCELL-3   RACDU
    Set Test Variable    @{M55115C00007_cell3}             ${text_M55115C00007}     2    NRCELL-3   RACDU

    Set Test Variable    @{M55115C00006_cell4}             ${text_M55115C00006}     2    NRCELL-4   RACDU
    Set Test Variable    @{M55115C00007_cell4}             ${text_M55115C00007}     2    NRCELL-4   RACDU


    Set Test Variable    &{dict_pm_counter1}         M55114C00001=${M55114C00001_cell1}
    ...                                              M55114C00002=${M55114C00002_cell1}
    ...                                              M55114C00003=${M55114C00003_cell1}
    ...                                              M55114C00004=${M55114C00004_cell1}
    ...                                              M55114C00010=${M55114C00010_cell1}
    ...                                              M55114C00023=${M55114C00023_cell1}
    ...                                              M55114C00030=${M55114C00030_cell1}
    ...                                              M55114C00035=${M55114C00035_cell1}
    ...                                              M55114C00036=${M55114C00036_cell1}
    ...                                              M55115C00002=${M55115C00002_cell1}
    ...                                              M55115C00003=${M55115C00003_cell1}
    ...                                              M55115C00006=${M55115C00006_cell1}
    ...                                              M55115C00007=${M55115C00007_cell1}
    ...                                              M55115C00010=${M55115C00010_cell1}
    ...                                              M55115C00017=${M55115C00017_cell1}

    Set Test Variable    &{dict_pm_counter2}         M55114C00001=${M55114C00001_cell2}
    ...                                              M55114C00002=${M55114C00002_cell2}
    ...                                              M55114C00003=${M55114C00003_cell2}
    ...                                              M55114C00004=${M55114C00004_cell2}
    ...                                              M55114C00010=${M55114C00010_cell2}
    ...                                              M55114C00023=${M55114C00023_cell2}
    ...                                              M55114C00029=${M55114C00029_cell2}
    ...                                              M55114C00035=${M55114C00035_cell1}
    ...                                              M55115C00002=${M55115C00002_cell2}
    ...                                              M55115C00003=${M55115C00003_cell2}
    ...                                              M55115C00006=${M55115C00006_cell2}
    ...                                              M55115C00007=${M55115C00007_cell2}
    ...                                              M55115C00009=${M55115C00009_cell2}
    ...                                              M55115C00016=${M55115C00016_cell2}

    Set Test Variable    &{dict_pm_counter3}         M55115C00006=${M55115C00006_cell3}
    ...                                              M55115C00007=${M55115C00007_cell3}

    Set Test Variable    &{dict_pm_counter4}         M55115C00006=${M55115C00006_cell4}
    ...                                              M55115C00007=${M55115C00007_cell4}

    Set Test Variable    ${maxNumScellsDl}           3
    Set Test Variable    ${ccLoadThreshold}          100
    Set Test Variable    ${maxNumOfSCellAlloc_1}     1
    Set Test Variable    ${maxNumOfSCellAlloc_3}     106
    Set Test Variable    ${maxNumOfUsersPerCell}     2


Prepare Counters And Expected Values t7
    [Documentation]    [PRIVATE]    set expected values for evaluation_of_RAC_for_a_UE_with_carrier_aggregation_3CC_non_contiguous_carriers test
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{M55114C00001_cell1}             ${text_M55114C00001}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00002_cell1}             ${text_M55114C00002}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00003_cell1}             ${text_M55114C00003}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00004_cell1}             ${text_M55114C00004}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00010_cell1}             ${text_M55114C00010}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00022_cell1}             ${text_M55114C00022}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00029_cell1}             ${text_M55114C00029}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00035_cell1}             ${text_M55114C00035}     0    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00036_cell1}             ${text_M55114C00036}     1    NRCELL-1   RACCU

    Set Test Variable    @{M55115C00002_cell1}             ${text_M55115C00002}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00003_cell1}             ${text_M55115C00003}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00009_cell1}             ${text_M55115C00009}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00016_cell1}             ${text_M55115C00016}     1    NRCELL-1   RACDU

    Set Test Variable    @{M55115C00006_cell2}             ${text_M55115C00006}     0    NRCELL-2   RACDU
    Set Test Variable    @{M55115C00007_cell2}             ${text_M55115C00007}     0    NRCELL-2   RACDU

    Set Test Variable    @{M55115C00006_cell3}             ${text_M55115C00006}     1    NRCELL-3   RACDU
    Set Test Variable    @{M55115C00007_cell3}             ${text_M55115C00007}     1    NRCELL-3   RACDU

    Set Test Variable    @{M55115C00006_cell4}             ${text_M55115C00006}     1    NRCELL-4   RACDU
    Set Test Variable    @{M55115C00007_cell4}             ${text_M55115C00007}     1    NRCELL-4   RACDU


    Set Test Variable    &{dict_pm_counter1}         M55114C00001=${M55114C00001_cell1}
    ...                                              M55114C00002=${M55114C00002_cell1}
    ...                                              M55114C00003=${M55114C00003_cell1}
    ...                                              M55114C00004=${M55114C00004_cell1}
    ...                                              M55114C00010=${M55114C00010_cell1}
    ...                                              M55114C00022=${M55114C00022_cell1}
    ...                                              M55114C00029=${M55114C00029_cell1}
    ...                                              M55114C00035=${M55114C00035_cell1}
    ...                                              M55114C00036=${M55114C00036_cell1}
    ...                                              M55115C00002=${M55115C00002_cell1}
    ...                                              M55115C00003=${M55115C00003_cell1}
    ...                                              M55115C00009=${M55115C00009_cell1}
    ...                                              M55115C00016=${M55115C00016_cell1}

    Set Test Variable    &{dict_pm_counter2}         M55115C00006=${M55115C00006_cell2}
    ...                                              M55115C00007=${M55115C00007_cell2}

    Set Test Variable    &{dict_pm_counter3}         M55115C00006=${M55115C00006_cell3}
    ...                                              M55115C00007=${M55115C00007_cell3}

    Set Test Variable    &{dict_pm_counter4}         M55115C00006=${M55115C00006_cell4}
    ...                                              M55115C00007=${M55115C00007_cell4}

    Set Test Variable    ${maxNumScellsDl}           2
    Set Test Variable    ${ccLoadThreshold}          30
    Set Test Variable    ${maxNumOfSCellAlloc_1}     106
    Set Test Variable    ${maxNumOfSCellAlloc_3}     106
    Set Test Variable    ${maxNumOfUsersPerCell}     106


Prepare Counters And Expected Values t9
    [Documentation]    [PRIVATE]    set expected values for Unsuccessful_SCell_Addition_due_to_contiguous_carriers_not_available test
    ...       :Autor: Sylvia Schneider

    Set Test Variable    @{M55114C00001_cell1}             ${text_M55114C00001}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00002_cell1}             ${text_M55114C00002}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00003_cell1}             ${text_M55114C00003}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00004_cell1}             ${text_M55114C00004}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00010_cell1}             ${text_M55114C00010}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00023_cell1}             ${text_M55114C00023}     2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00030_cell1}             ${text_M55114C00030}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00035_cell1}             ${text_M55114C00035}     1    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00036_cell1}             ${text_M55114C00036}     2    NRCELL-1   RACCU

    Set Test Variable    @{M55115C00002_cell1}             ${text_M55115C00002}     2    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00003_cell1}             ${text_M55115C00003}     2    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00010_cell1}             ${text_M55115C00010}     1    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00017_cell1}             ${text_M55115C00017}     1    NRCELL-1   RACDU

    Set Test Variable    @{M55115C00006_cell2}             ${text_M55115C00006}     1    NRCELL-2   RACDU
    Set Test Variable    @{M55115C00007_cell2}             ${text_M55115C00007}     1    NRCELL-2   RACDU

    Set Test Variable    @{M55115C00006_cell3}             ${text_M55115C00006}     1    NRCELL-3   RACDU
    Set Test Variable    @{M55115C00007_cell3}             ${text_M55115C00007}     1    NRCELL-3   RACDU

    Set Test Variable    @{M55115C00006_cell4}             ${text_M55115C00006}     1    NRCELL-4   RACDU
    Set Test Variable    @{M55115C00007_cell4}             ${text_M55115C00007}     1    NRCELL-4   RACDU


    Set Test Variable    &{dict_pm_counter1}         M55114C00001=${M55114C00001_cell1}
    ...                                              M55114C00002=${M55114C00002_cell1}
    ...                                              M55114C00003=${M55114C00003_cell1}
    ...                                              M55114C00004=${M55114C00004_cell1}
    ...                                              M55114C00010=${M55114C00010_cell1}
    ...                                              M55114C00023=${M55114C00023_cell1}
    ...                                              M55114C00030=${M55114C00030_cell1}
    ...                                              M55114C00035=${M55114C00035_cell1}
    ...                                              M55114C00036=${M55114C00036_cell1}
    ...                                              M55115C00002=${M55115C00002_cell1}
    ...                                              M55115C00003=${M55115C00003_cell1}
    ...                                              M55115C00010=${M55115C00010_cell1}
    ...                                              M55115C00017=${M55115C00017_cell1}

    Set Test Variable    &{dict_pm_counter2}         M55115C00006=${M55115C00006_cell2}
    ...                                              M55115C00007=${M55115C00007_cell2}

    Set Test Variable    &{dict_pm_counter3}         M55115C00006=${M55115C00006_cell3}
    ...                                              M55115C00007=${M55115C00007_cell3}

    Set Test Variable    &{dict_pm_counter4}         M55115C00006=${M55115C00006_cell4}
    ...                                              M55115C00007=${M55115C00007_cell4}

    Set Test Variable    ${maxNumScellsDl}           3
    Set Test Variable    ${ccLoadThreshold}          30
    Set Test Variable    ${maxNumOfSCellAlloc_1}     106
    Set Test Variable    ${maxNumOfSCellAlloc_3}     106
    Set Test Variable    ${maxNumOfUsersPerCell}     106
