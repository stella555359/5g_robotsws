*** Settings ***
Documentation     author: Gopiram
...               contact: gattu.gopi_ram@nokia.com

Resource    ../../../Resources/robot/ue_operations.robot
Resource    ../../../Resources/robot/suite_common_keywords.robot
Resource    ../../../../gNB_P1/External_L3_Call_Common_Keywords.robot

Suite Setup       Common Suite Setup    feature_folder=5GC001349

*** Variables ***
${dl_tput}                             80
${ul_tput}                             20
@{SA_UE_List}                          1    2
@{NSA_UE_List}                         101   102
&{tdd_frameValue_prachindex_9}         frameStructureType=tdLte    guardPeriodLength=4Symbols
...    lteToNrFrameShift=0ms    tdLteUlDlConfig=tdLteConfig2    ulDlDataSlotRatio=1/4    prachConfigurationIndex=9
&{tdd_frameValue_prachindex_12}        frameStructureType=tdLte    guardPeriodLength=4Symbols
...    lteToNrFrameShift=3ms    tdLteUlDlConfig=tdLteConfig2    ulDlDataSlotRatio=1/4
...    prachConfigurationIndex=12
&{tdd_frameValue_prachindex_7}         frameStructureType=semiStatic    guardPeriodLength=2Symbols
...    ulDlDataSlotRatio=3/7    prachConfigurationIndex=7
${tdd_frame_listname}                  tddFrameStructure
@{nrcel_profile_id}                    1    2
${L3call_testsuite}                    ${CURDIR}/../../../../QT/L3call_Parallel.robot
@{Counter_List}                        M55306C06001    M55306C03001    M55306C00001
${variable_section}                    -v CONDITIONAL_LOGGING:True

*** Test Cases ***
5GC001349_TC1_AUT_Configuration_index_7_100MHz_SANSA_ContentionBasedRandomAccess
    [Documentation]    Verify Frame Structure Enhancement with Prach Configuration Index7
    [Tags]    5GC001349_TC1    P3_REG
    [Setup]    Basic Test Setup    feature=5GC001349    scf_update=True    delta=&{tdd_frameValue_prachindex_7}
    ...    logical_cell_list=@{nrcel_profile_id}    BTS_log_needed=False
    Perform L3 call and check status    ${TOPOLOGY}    2    ${L3call_testsuite}
    ...    variable_section=${variable_section}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${SA_UE_List}    ${NSA_UE_List}
    [Teardown]    Generic Test Teardown    feature=5GC001349    sa_ue_list=${SA_UE_List}
    ...    nsa_ue_list=${NSA_UE_List}

5GC001349_TC2_AUT_0ms_Configuration_index_9_100MHz_SANSA_ContentionBasedRandomAccess
    [Documentation]    Verify Frame Structure Enhancement with Prach Configuration Index9
    [Tags]    AP_REG    P1_REG    5GC001349_TC2
    [Setup]    Basic Test Setup    feature=5GC001349    scf_update=True    delta=&{tdd_frameValue_prachindex_9}
    ...    logical_cell_list=@{nrcel_profile_id}    BTS_log_needed=False
    Perform L3 call and check status    ${TOPOLOGY}    2    ${L3call_testsuite}
    ...    variable_section=${variable_section}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${SA_UE_List}    ${NSA_UE_List}
    [Teardown]    Generic Test Teardown    feature=5GC001349    sa_ue_list=${SA_UE_List}
    ...    nsa_ue_list=${NSA_UE_List}

5GC001349_TC3_AUT_3ms_Configuration_index_12_100MHz_NSA_ContentionBasedRandomAccess
    [Documentation]    Verify Frame Structure Enhancement with Prach Configuration Index12
    [Tags]    AP_REG    P2_REG    5GC001349_TC3
    [Setup]    Basic Test Setup    feature=5GC001349    scf_update=True    delta=&{tdd_frameValue_prachindex_12}
    ...    logical_cell_list=@{nrcel_profile_id}    BTS_log_needed=False
    Perform L3 call and check status    ${TOPOLOGY}    2    ${L3call_testsuite}
    ...    variable_section=${variable_section}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${SA_UE_List}    ${NSA_UE_List}
    [Teardown]    Generic Test Teardown    feature=5GC001349    sa_ue_list=${SA_UE_List}
    ...    nsa_ue_list=${NSA_UE_List}

*** Keywords ***
Get Delta for 5GC001349
    [Arguments]    &{kwargs}
    ${prachConfigurationIndex_val}    Pop From Dictionary    ${kwargs}    prachConfigurationIndex
    FOR    ${cell_id}    IN    @{NRCELL_distname_list}
        delta_store.update managed object and parameter to delta    dist_name=${cell_id}
        ...    prachConfigurationIndex=${prachConfigurationIndex_val}
        delta_store.add list parameters to delta
        ...    dist_name=${cell_id}    list_name=${tdd_frame_listname}    &{kwargs}
    END