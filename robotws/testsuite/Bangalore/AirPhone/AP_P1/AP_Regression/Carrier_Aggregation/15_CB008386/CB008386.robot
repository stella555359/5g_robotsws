*** Settings ***

Documentation     author: Rakshitha
...               contact: rakshitha.r@nokia.com
...               Description:

Resource    ./8386_Keywords.robot
Resource        ../../../Resources/robot/ue_operations.robot
Resource        ../../../Resources/robot/gnb.robot

Suite Setup       Suite Setup    feature_folder=CB008386

*** Variables ***
${dl_tput}                              10
${ul_tput_NonCA_NSA}                    10
@{Non_CA_NSA_UE_List1}                  21    22    23    24    25    26    27
@{Non_CA_NSA_UE_List2}                  31    32    33    34    35    36    37
@{Non_CA_NSA_UE_List}                   21    22    23    24    25    26    27    31    32    33    34    35    36    37
${ul_tput}                              100
@{Single_CA_NSA_UE_List}                11
@{MUE_CA_NSA_UE_List}                   11    12    13    14    15    16    17    18    19    20
@{MUE_dl_tput}                          50    40
@{Single_CA_NSA_2UE_List}               111
@{MultiUE_CA_NSA_UE_List}               11    111
@{dl_tput_list}                         150    150    150    150    150    150
@{dl_tput_list2}                        150    150    100    100
@{UL_Scell_index}                       8    9
@{8CC_NSA_cell_Index}                   8    9    10    11    12    13    14    15
@{8CC_NSA_cell_Index_Bn257}             8    9    10    11    12    13    14
@{NSA_Scell_Index}                      9    10    11    12    13    14    15
@{NSA_Scell_Index_Bn257}                9    10    11    12    13    14
${8cc_ue_configs_Contigious_BN261}      ${CURDIR}/../Config_Files/15_CB008386/Contigious/BN261/
${8cc_ue_configs_Contigious_BN260}      ${CURDIR}/../Config_Files/15_CB008386/Contigious/BN260/
${8cc_ue_configs_Contigious_BN257}      ${CURDIR}/../Config_Files/15_CB008386/Contigious/BN257/
${8cc_ue_configs_NonContigious}         ${CURDIR}/../Config_Files/15_CB008386/NonContigious/
${EDAEMON_PORT}                         50000
${CELL_LOCK_UNLOCK_REPETITIONS}         2
${CELL_BLOCK_UNBLOCK_REPETITIONS}       2
${RU_RESET_REPETITIONS}                 2
${SITE_RESET_REPETITIONS}               2
${BBMOD_RESET_REPETITIONS}              2
${RU_LOCK_UNLOCK_REPETITIONS}           2

*** Test Cases ***
CB008386_TC12_MUE 14 Non CA calls both cells with 10DL_10UL traffic
    [Documentation]    Verify MUE 14 Non CA calls both cells with 10DL_10UL traffic
    [Tags]    AP_REG    8386_TC12_MUE    P1_REG
    [Setup]    Test Setup for FR2    logical_cell_list=@{logical_cell_list}    ul_tput=${ul_tput_NonCA_NSA}
    ...    dl_tput=${dl_tput}    custom_config_folder=${8cc_ue_configs_Contigious_BN261}
    Attach For NSA UEs    ${Non_CA_NSA_UE_List1}    target_cells=1
    Attach For NSA UEs    ${Non_CA_NSA_UE_List2}
    Start Traffic for NSA Non CA UE    ${Non_CA_NSA_UE_List}
    Validate Pcell Throughput For NSA Non CA Capable UEs    ${ul_tput}    ${dl_tput}    ${Non_CA_NSA_UE_List}
    Stop Traffic and Detach NSA UEs    ${Non_CA_NSA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    [Teardown]    Test Teardown    nsa_ue_list=${Non_CA_NSA_UE_List}

CB008386_TC14_Verify Peak data rate for FR2 Intra band_Bn257 Contigious DL_8CC
    [Documentation]    Verify Peak data rate for FR2 Intra band[Bn257] Contigious DL_8CC Asymetric both the Cell_1 and Cell_2 CA Call
    ...                beam Forming enabled with beamset 32_A
    [Tags]    AP_REG    8386_TC14_BN257    P2_REG
    [Setup]    Test Setup for FR2    logical_cell_list=@{logical_cell_list}    dl_tput_list=@{dl_tput_list2}    UL_Scell_index=@{UL_Scell_index}
    ...    8CC_NSA_cell_Index=@{8CC_NSA_cell_Index}    scell_index=${NSA_Scell_index}    custom_config_folder=${8cc_ue_configs_Contigious_BN257}
    Perform NSA UE Attach and start traffic for Blind ScellAddition and Blind ScellActivation    ${Single_CA_NSA_UE_List}    ${scell_index}
    ...    target_cells=1
    Sleep    5s
    Perform NSA UE Attach and start traffic for Blind ScellAddition and Blind ScellActivation    ${Single_CA_NSA_2UE_List}    ${scell_index}
    ...    target_cells=2
    Sleep    5s
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list2}
    ...    expected_ul_tput=${ul_tput}    UE_List=${MultiUE_CA_NSA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${8CC_NSA_cell_Index}
    Perform Stop Traffic and Detach NSA UEs for Blind ScellAddition    ${MultiUE_CA_NSA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    [Teardown]    Test Teardown    nsa_ue_list=${MultiUE_CA_NSA_UE_List}

CB008386_TC15_Verify Peak data rate for MUE FR2 Intra band_Bn257 Contigious DL_8CC
    [Documentation]    Verify Peak data rate for MUE FR2 Intra band[Bn257] Contigious DL_8CC Asymetric on the Cell_1 with CA and
    ...                beam Forming enabled with beamset 32_A
    [Tags]    AP_REG    MUE_TC15_BN257    P2_REG
    [Setup]    Test Setup for FR2    logical_cell_list=@{logical_cell_list}    dl_tput_list=@{MUE_dl_tput}    UL_Scell_index=@{UL_Scell_index}
    ...    8CC_NSA_cell_Index=@{8CC_NSA_cell_Index}    scell_index=${NSA_Scell_index}    custom_config_folder=${8cc_ue_configs_Contigious_BN257}
	...    ul_tput=${dl_tput}
    Perform NSA UE Attach and start traffic for Blind ScellAddition and Blind ScellActivation    ${MUE_CA_NSA_UE_List}    ${scell_index}
    ...    target_cells=1
    Sleep    10s
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${MUE_dl_tput}
    ...    expected_ul_tput=${dl_tput}    UE_List=${MUE_CA_NSA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${8CC_NSA_cell_Index}
    Perform Stop Traffic and Detach NSA UEs for Blind ScellAddition    ${MUE_CA_NSA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    [Teardown]    Test Teardown    nsa_ue_list=${MUE_CA_NSA_UE_List}

CB008386_TC17_Verify Peak data rate for FR2 Intra band_Bn257 Non_Contigious DL_8CC
    [Documentation]    Verify Peak data rate for FR2 Intra band[Bn257] Non_Contigious DL_8CC Asymetric CA
    ...                beam Forming enabled with beamset 32_B
    [Tags]    AP_REG    8386_TC17_BN257    P2_REG
    [Setup]    Test Setup for FR2    logical_cell_list=@{logical_cell_list}    dl_tput_list=@{dl_tput_list}    UL_Scell_index=@{UL_Scell_index}
    ...    8CC_NSA_cell_Index=@{8CC_NSA_cell_Index_Bn257}    scell_index=${NSA_Scell_index_Bn257}
    ...    custom_config_folder=${8cc_ue_configs_NonContigious}
    Perform NSA UE Attach and start traffic for Blind ScellAddition and Blind ScellActivation    ${Single_CA_NSA_UE_List}    ${scell_index}
    ...    target_cells=2
    Sleep    90s
    ${ul_scell}    Evaluate    [${UL_Scell_index}[0]]
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${Single_CA_NSA_UE_List}    UL_Scell_Id=${ul_scell}    DL_Scell_Id=${8CC_NSA_cell_Index}
    Perform Stop Traffic and Detach NSA UEs for Blind ScellAddition    ${Single_CA_NSA_UE_List}
    Perform attach and detach    ${Single_CA_NSA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    [Teardown]    Test Teardown    nsa_ue_list=${Single_CA_NSA_UE_List}

CB008386_TC18_Verify Peak data rate for MUE FR2 Intra band_Bn257 Non_Contigious DL_8CC
    [Documentation]    Verify Peak data rate for FR2 Intra band[Bn257] Non_Contigious DL_8CC Asymetric CA
    ...                beam Forming enabled with beamset 32_B
    [Tags]    AP_REG    MUE_TC18_BN257    P2_REG
    [Setup]    Test Setup for FR2    logical_cell_list=@{logical_cell_list}    dl_tput_list=@{MUE_dl_tput}    UL_Scell_index=@{UL_Scell_index}
    ...    8CC_NSA_cell_Index=@{8CC_NSA_cell_Index_Bn257}    scell_index=${NSA_Scell_index_Bn257}    ul_tput=${dl_tput}
    ...    custom_config_folder=${8cc_ue_configs_NonContigious}
    Perform NSA UE Attach and start traffic for Blind ScellAddition and Blind ScellActivation    ${MUE_CA_NSA_UE_List}    ${scell_index}
    ...    target_cells=1
    Sleep    90s
    ${ul_scell}    Evaluate    [${UL_Scell_index}[0]]
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${MUE_dl_tput}
    ...    expected_ul_tput=${ul_tput}    UE_List=${MUE_CA_NSA_UE_List}    UL_Scell_Id=${ul_scell}    DL_Scell_Id=${8CC_NSA_cell_Index}
    Perform Stop Traffic and Detach NSA UEs for Blind ScellAddition    ${MUE_CA_NSA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    [Teardown]    Test Teardown    nsa_ue_list=${MUE_CA_NSA_UE_List}

CB008386_TC21_Verify Peak data rate for FR2 Intra band_Bn261 Contigious DL_8CC
    [Documentation]    Verify Peak data rate for FR2 Intra band[Bn261] Contigious DL_8CC Asymetric CABind and
    ...                beam Forming enabled with beamset 32_A
    [Tags]    AP_REG    8386_TC21_BN261    P1_REG
    [Setup]    Test Setup for FR2    logical_cell_list=@{logical_cell_list}    dl_tput_list=@{dl_tput_list}    UL_Scell_index=@{UL_Scell_index}
    ...    8CC_NSA_cell_Index=@{8CC_NSA_cell_Index}    scell_index=${NSA_Scell_index}    custom_config_folder=${8cc_ue_configs_Contigious_BN261}
    Perform NSA UE Attach and start traffic for Blind ScellAddition and Blind ScellActivation    ${Single_CA_NSA_UE_List}    ${scell_index}
    ...    target_cells=1
    Sleep    90s
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${Single_CA_NSA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${8CC_NSA_cell_Index}
    Perform Stop Traffic and Detach NSA UEs for Blind ScellAddition    ${Single_CA_NSA_UE_List}
    Perform attach and detach    ${Single_CA_NSA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    [Teardown]    Test Teardown    nsa_ue_list=${Single_CA_NSA_UE_List}

CB008386_TC22_Verify Peak data rate for FR2 Intra band_Bn260 Contigious DL_8CC
    [Documentation]    Verify Peak data rate for FR2 Intra band[Bn260] Contigious DL_8CC Asymetric CABind and
    ...                beam Forming enabled with beamset 32_A
    [Tags]    8386_TC22_BN260    P3_REG
    [Setup]    Test Setup for FR2    logical_cell_list=@{logical_cell_list}    dl_tput_list=@{dl_tput_list}    UL_Scell_index=@{UL_Scell_index}
    ...    8CC_NSA_cell_Index=@{8CC_NSA_cell_Index}    scell_index=${NSA_Scell_index}    custom_config_folder=${8cc_ue_configs_Contigious_BN260}
    Perform NSA UE Attach and start traffic for Blind ScellAddition and Blind ScellActivation    ${Single_CA_NSA_UE_List}    ${scell_index}
    ...    target_cells=1
    Sleep    5s
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${Single_CA_NSA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${8CC_NSA_cell_Index}
    Perform Stop Traffic and Detach NSA UEs for Blind ScellAddition    ${Single_CA_NSA_UE_List}
    Perform attach and detach    ${Single_CA_NSA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    [Teardown]    Test Teardown    nsa_ue_list=${Single_CA_NSA_UE_List}

CB008386_lock_unlock
    [Documentation]    Verify MUE 14 Non CA calls both cells with 10DL_10UL traffic
    [Tags]    AP_REG    8386_lock    OAM
    [Setup]    Test Setup for FR2    logical_cell_list=@{logical_cell_list}    ul_tput=${ul_tput_NonCA_NSA}
    ...    dl_tput=${dl_tput}    custom_config_folder=${8cc_ue_configs_Contigious_BN261}
    Attach For NSA UEs    ${Non_CA_NSA_UE_List1}    target_cells=1
    Attach For NSA UEs    ${Non_CA_NSA_UE_List2}
    Start Traffic for NSA Non CA UE    ${Non_CA_NSA_UE_List}
    Validate Pcell Throughput For NSA Non CA Capable UEs    ${ul_tput}    ${dl_tput}    ${Non_CA_NSA_UE_List}
    Stop Traffic and Detach NSA UEs    ${Non_CA_NSA_UE_List}
	FOR    ${index}    IN RANGE    ${CELL_LOCK_UNLOCK_REPETITIONS}
        Log to console    ***********CELL LOCK UNLOCK ITERATION ${index} STARTS **************
        Perform NR Cell Lock and Unlock
        Sleep    60s
        Attach For NSA UEs    ${Non_CA_NSA_UE_List1}    target_cells=1
        Attach For NSA UEs    ${Non_CA_NSA_UE_List2}
        Start Traffic for NSA Non CA UE    ${Non_CA_NSA_UE_List}
        Validate Pcell Throughput For NSA Non CA Capable UEs    ${ul_tput}    ${dl_tput}    ${Non_CA_NSA_UE_List}
        Stop Traffic and Detach NSA UEs    ${Non_CA_NSA_UE_List}
        Log to console    ***********CELL LOCK UNLOCK ITERATION ${index} ENDS **************
    END
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    [Teardown]    Test Teardown    nsa_ue_list=${Non_CA_NSA_UE_List}

CB008386_cell_block_unblock
    [Documentation]    Verify MUE 14 Non CA calls both cells with 10DL_10UL traffic
    [Tags]    AP_REG    8386_block    OAM
    [Setup]    Test Setup for FR2    logical_cell_list=@{logical_cell_list}    ul_tput=${ul_tput_NonCA_NSA}
    ...    dl_tput=${dl_tput}    custom_config_folder=${8cc_ue_configs_Contigious_BN261}
    Attach For NSA UEs    ${Non_CA_NSA_UE_List1}    target_cells=1
    Attach For NSA UEs    ${Non_CA_NSA_UE_List2}
    Start Traffic for NSA Non CA UE    ${Non_CA_NSA_UE_List}
    sleep    5
    Validate Pcell Throughput For NSA Non CA Capable UEs    ${ul_tput}    ${dl_tput}    ${Non_CA_NSA_UE_List}
    Stop Traffic and Detach NSA UEs    ${Non_CA_NSA_UE_List}
	FOR    ${index}    IN RANGE    ${CELL_BLOCK_UNBLOCK_REPETITIONS}
        Log to console    ***********CELL BLOCK UNBLOCK ITERATION ${index} STARTS **************
        Perform NR Cell Block and Unblock
        sleep    60
        Wait Until Keyword Succeeds    3min    30sec    Validate Cell Setup Pattern After oam operation    ${index}+1
        Attach For NSA UEs    ${Non_CA_NSA_UE_List1}    target_cells=1
        Attach For NSA UEs    ${Non_CA_NSA_UE_List2}
        Start Traffic for NSA Non CA UE    ${Non_CA_NSA_UE_List}
        Validate Pcell Throughput For NSA Non CA Capable UEs    ${ul_tput}    ${dl_tput}    ${Non_CA_NSA_UE_List}
        Stop Traffic and Detach NSA UEs    ${Non_CA_NSA_UE_List}
        sleep    30sec
        Log to console    ***********CELL BLOCK UNBLOCK ITERATION ${index} ENDS **************
    END
    [Teardown]    Test Teardown    nsa_ue_list=${Non_CA_NSA_UE_List}

CB008386_RU_reset
    [Documentation]    Verify MUE 14 Non CA calls both cells with 10DL_10UL traffic
    [Tags]    AP_REG    8386_ru_reset   OAM
    [Setup]    Test Setup for FR2    logical_cell_list=@{logical_cell_list}    ul_tput=${ul_tput_NonCA_NSA}
    ...    dl_tput=${dl_tput}    custom_config_folder=${8cc_ue_configs_Contigious_BN261}
    Attach For NSA UEs    ${Non_CA_NSA_UE_List1}    target_cells=1
    Attach For NSA UEs    ${Non_CA_NSA_UE_List2}
    Start Traffic for NSA Non CA UE    ${Non_CA_NSA_UE_List}
    sleep    5
    Validate Pcell Throughput For NSA Non CA Capable UEs    ${ul_tput}    ${dl_tput}    ${Non_CA_NSA_UE_List}
    Stop Traffic and Detach NSA UEs    ${Non_CA_NSA_UE_List}
    FOR    ${reset}    IN RANGE    ${RU_RESET_REPETITIONS}
        Log to console    ***********RU RESET ITERATION ${reset} STARTS **************
        RU reset via webgui
        Sleep    60s
        Attach For NSA UEs    ${Non_CA_NSA_UE_List1}    target_cells=1
        Attach For NSA UEs    ${Non_CA_NSA_UE_List2}
        Start Traffic for NSA Non CA UE    ${Non_CA_NSA_UE_List}
        Validate Pcell Throughput For NSA Non CA Capable UEs    ${ul_tput}    ${dl_tput}    ${Non_CA_NSA_UE_List}
        Stop Traffic and Detach NSA UEs    ${Non_CA_NSA_UE_List}
        Log to console    ***********RU RESET ITERATION ${reset} ENDS  **************
        sleep    30s
    END
    [Teardown]    Test Teardown    nsa_ue_list=${Non_CA_NSA_UE_List}

CB008386_Site_reset
    [Documentation]    Verify MUE 14 Non CA calls both cells with 10DL_10UL traffic
    [Tags]    AP_REG    8386_site_reset   OAM
    [Setup]    Test Setup for FR2    logical_cell_list=@{logical_cell_list}    ul_tput=${ul_tput_NonCA_NSA}
    ...    dl_tput=${dl_tput}    custom_config_folder=${8cc_ue_configs_Contigious_BN261}
    Attach For NSA UEs    ${Non_CA_NSA_UE_List1}    target_cells=1
    Attach For NSA UEs    ${Non_CA_NSA_UE_List2}
    Start Traffic for NSA Non CA UE    ${Non_CA_NSA_UE_List}
    sleep    5
    Validate Pcell Throughput For NSA Non CA Capable UEs    ${ul_tput}    ${dl_tput}    ${Non_CA_NSA_UE_List}
    Stop Traffic and Detach NSA UEs    ${Non_CA_NSA_UE_List}
    FOR    ${index}    IN RANGE    ${SITE_RESET_REPETITIONS}
        Log to console    ***********SITE RESET ITERATION ${index} STARTS **************
        Perform Reset Site and Check BTS Status
        Sleep    60s
        Attach For NSA UEs    ${Non_CA_NSA_UE_List1}    target_cells=1
        Attach For NSA UEs    ${Non_CA_NSA_UE_List2}
        Start Traffic for NSA Non CA UE    ${Non_CA_NSA_UE_List}
        Validate Pcell Throughput For NSA Non CA Capable UEs    ${ul_tput}    ${dl_tput}    ${Non_CA_NSA_UE_List}
        Stop Traffic and Detach NSA UEs    ${Non_CA_NSA_UE_List}
        Log to console    ***********SITE RESET ITERATION ${index} ENDS **************
        sleep    30s
    END
    [Teardown]    Test Teardown    nsa_ue_list=${Non_CA_NSA_UE_List}

CB008386_BBMOD_Reset
    [Documentation]    Verify MUE 14 Non CA calls both cells with 10DL_10UL traffic
    [Tags]    AP_REG    8386_bbmod_reset   OAM
    [Setup]    Test Setup for FR2    logical_cell_list=@{logical_cell_list}    ul_tput=${ul_tput_NonCA_NSA}
    ...    dl_tput=${dl_tput}    custom_config_folder=${8cc_ue_configs_Contigious_BN261}
    Attach For NSA UEs    ${Non_CA_NSA_UE_List1}    target_cells=1
    Attach For NSA UEs    ${Non_CA_NSA_UE_List2}
    Start Traffic for NSA Non CA UE    ${Non_CA_NSA_UE_List}
    sleep    5
    Validate Pcell Throughput For NSA Non CA Capable UEs    ${ul_tput}    ${dl_tput}    ${Non_CA_NSA_UE_List}
    Stop Traffic and Detach NSA UEs    ${Non_CA_NSA_UE_List}
    FOR    ${index}    IN RANGE    ${BBMOD_RESET_REPETITIONS}
        Log to console    ***********BBMOD RESET ITERATION ${index} STARTS **************
        Perform BBMOD Reset and Check BTS Status
        Sleep    60s
        Attach For NSA UEs    ${Non_CA_NSA_UE_List1}    target_cells=1
        Attach For NSA UEs    ${Non_CA_NSA_UE_List2}
        Start Traffic for NSA Non CA UE    ${Non_CA_NSA_UE_List}
        Validate Pcell Throughput For NSA Non CA Capable UEs    ${ul_tput}    ${dl_tput}    ${Non_CA_NSA_UE_List}
        Stop Traffic and Detach NSA UEs    ${Non_CA_NSA_UE_List}
        Log to console    ***********BBMOD RESET ITERATION ${index} ENDS **************
        sleep    30s
    END
    [Teardown]    Test Teardown    nsa_ue_list=${Non_CA_NSA_UE_List}

CB008386_RU_lock_unlock
    [Documentation]    This testcase verifies RU lock unlock
    [Tags]    AP_REG    8386_ru_lock_unlock   OAM
    [Setup]    Test Setup for FR2    logical_cell_list=@{logical_cell_list}    ul_tput=${ul_tput_NonCA_NSA}
    ...    dl_tput=${dl_tput}    custom_config_folder=${8cc_ue_configs_Contigious_BN261}
    Attach For NSA UEs    ${Non_CA_NSA_UE_List1}    target_cells=1
    Attach For NSA UEs    ${Non_CA_NSA_UE_List2}
    Start Traffic for NSA Non CA UE    ${Non_CA_NSA_UE_List}
    sleep    5
    Validate Pcell Throughput For NSA Non CA Capable UEs    ${ul_tput}    ${dl_tput}    ${Non_CA_NSA_UE_List}
    Stop Traffic and Detach NSA UEs    ${Non_CA_NSA_UE_List}
    FOR    ${ru_count}    IN RANGE    ${RU_LOCK_UNLOCK_REPETITIONS}
        Log to console    ***********RU LOCK UNLOCK ITERATION ${ru_count} STARTS **************
        Perform RMOD lock Unlock operation
        Sleep    60s
        Attach For NSA UEs    ${Non_CA_NSA_UE_List1}    target_cells=1
        Attach For NSA UEs    ${Non_CA_NSA_UE_List2}
        Start Traffic for NSA Non CA UE    ${Non_CA_NSA_UE_List}
        Validate Pcell Throughput For NSA Non CA Capable UEs    ${ul_tput}    ${dl_tput}    ${Non_CA_NSA_UE_List}
        Stop Traffic and Detach NSA UEs    ${Non_CA_NSA_UE_List}
        Log to console    ***********RU LOCK UNLOCK ITERATION ${ru_count} ENDS **************
        sleep    30s
    END
    [Teardown]    Test Teardown    nsa_ue_list=${Non_CA_NSA_UE_List}