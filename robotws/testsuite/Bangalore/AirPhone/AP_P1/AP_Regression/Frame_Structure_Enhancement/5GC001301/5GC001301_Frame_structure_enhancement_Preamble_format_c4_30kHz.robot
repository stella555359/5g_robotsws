*** Settings ***
Documentation     author: Bhanu Vamsi
...               contact: vamsi.gundlur@nokia.com
...               Description:

Force Tags    P3_REG
Resource    ../../../Resources/robot/ue_operations.robot
Resource    ../../../Resources/robot/suite_common_keywords.robot
Resource    ../../../../gNB_P1/External_L3_Call_Common_Keywords.robot

Suite Setup       Common Suite Setup    feature_folder=5GC001301
Suite Teardown    Common Suite Teardown

*** Variables ***
@{SA_UE_List}                          1    2
@{NSA_UE_List}                         11   12
&{tdd_frameValue_prachindex_194}       chBw=100MHz    frameStructureType=tdLte    guardPeriodLength=4Symbols
...    lteToNrFrameShift=0ms    tdLteUlDlConfig=tdLteConfig2    ulDlDataSlotRatio=1/4    prachConfigurationIndex=194    reqMinNumPuschPrb=19
&{tdd_frameValue_prachindex_202}       chBw=80MHz    frameStructureType=semiStatic    guardPeriodLength=2Symbols
...    ulDlDataSlotRatio=3/7    prachConfigurationIndex=202    reqMinNumPuschPrb=19
${tdd_frame_listname}                  tddFrameStructure
@{nrcel_profile_id}                    1    2
${L3call_testsuite}                    ${CURDIR}/../../../../QT/L3call_Parallel.robot
@{Counter_List}                        M55306C06001    M55306C03001    M55306C00001
${variable_section}                    -v CONDITIONAL_LOGGING:True

*** Test Cases ***
5GC001301_A014_Verify_PRACH_format_C2_with_30kHz_scs_100MHz_bandwith_5GC001116_0ms_frame_structure_index194
    [Documentation]    Verify Frame Structure Enhancement with Prach Configuration Index194 with channel bandwidth 100MHz
    [Tags]    AP_REG    5GC001301_TC1
    [Setup]    Basic Test Setup    feature=5GC001301    scf_update=True    delta=&{tdd_frameValue_prachindex_194}
    ...    logical_cell_list=@{nrcel_profile_id}
    Perform L3 call and check status    ${TOPOLOGY}    2    ${L3call_testsuite}
    ...    variable_section=${variable_section}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${SA_UE_List}    ${NSA_UE_List}
    [Teardown]    Generic Test Teardown    feature=5GC001301    sa_ue_list=${SA_UE_List}
    ...    nsa_ue_list=${NSA_UE_List}

5GC001301_A025_Verify_PRACH_format_C2_with_30kHz_scs_80MHz_bandwith_5GC001070_frame_structure_index202
    [Documentation]    Verify Frame Structure Enhancement with Prach Configuration Index202 with channel bandwidth 80MHz
    [Tags]    AP_REG    5GC001301_TC2
    [Setup]    Basic Test Setup    feature=5GC001301    scf_update=True    delta=&{tdd_frameValue_prachindex_202}
    ...    logical_cell_list=@{nrcel_profile_id}
    Perform L3 call and check status    ${TOPOLOGY}    2    ${L3call_testsuite}
    ...    variable_section=${variable_section}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${SA_UE_List}    ${NSA_UE_List}
    [Teardown]    Generic Test Teardown    feature=5GC001301    sa_ue_list=${SA_UE_List}
    ...    nsa_ue_list=${NSA_UE_List}

*** Keywords ***
Get Delta for 5GC001301
    [Arguments]    &{kwargs}
    ${prachConfigurationIndex_val}    Pop From Dictionary    ${kwargs}    prachConfigurationIndex
    ${reqMinNumPuschPrb_val}    Pop From Dictionary    ${kwargs}    reqMinNumPuschPrb
    ${chBw_val}    Pop From Dictionary    ${kwargs}    chBw
    FOR    ${cell_id}    IN    @{NRCELL_distname_list}
        delta_store.update managed object and parameter to delta    dist_name=${cell_id}
        ...    prachConfigurationIndex=${prachConfigurationIndex_val}    chBw=${chBw_val}    reqMinNumPuschPrb=${reqMinNumPuschPrb_val}
        delta_store.add list parameters to delta
        ...    dist_name=${cell_id}    list_name=${tdd_frame_listname}    &{kwargs}
    END
