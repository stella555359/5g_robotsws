*** Settings ***
Documentation
...   author: sheng liu
...   contact: sheng.liu@nokia-sbell.com
...   this is a robot case about 5GC002271.
Test Timeout   75h
Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../Resources/pet_all.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    STATE_SKIP_AGENT
...               CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG06_ST_RRM    TA_LEVEL_22
Suite Setup            common_suite_setup_for_pet
Suite Teardown         common_suite_teardown_for_pet
Test Setup             common_case_setup_for_pet
Test Teardown          common_case_teardown_for_pet


*** Variables ***
${scf_file_path_1}         ${CURDIR}/scf_1.xml
${scf_file_path_4}         ${CURDIR}/scf_4.xml
${scf_file_path_6}         ${CURDIR}/scf_6.xml
${scf_file_path_8}         ${CURDIR}/scf_8.xml
${scf_file_path_12}         ${CURDIR}/scf_12.xml
${swconfig_file_path}    ${CURDIR}/swconfig.txt

*** Test Cases ***

5GC002271_A_01_TDD_NSA_Monitoring_of_Scheduling_Resource_pools_size
    [Tags]    CRT    QC_32847
    [Documentation]
    ...    author: sheng.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    13.12.2021,sheng.liu@nokia-sbell.com,case template draft
     [Setup]           common_case_setup_for_pet     scf_file=${scf_file_path_1}    swconfig_file=${swconfig_file_path}    ignore_cell_check=True
    [Timeout]     1h
    Precondition counter
    Check counter for 5GC002271-A _01_TDD_NSA_Monitoring of Scheduling Resource pools size
    [Teardown]        common_case_teardown_for_pet


5GC002271_A_04_FDD_SA_Monitoring_of_Main_Pools_assignment_and_switching_between_pools
    [Tags]    CRT    QC_112207
    [Documentation]
    ...    author: sheng.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    13.12.2021,sheng.liu@nokia-sbell.com,case template draft
     [Setup]           common_case_setup_for_pet     scf_file=${scf_file_path_4}    swconfig_file=${swconfig_file_path}    ignore_cell_check=True
    [Timeout]     1h
    ${UE1}    ${ip1}=    Prepare and attach UE1
    #Pet Start Ping to UE    ue=${UE1}    in_backgroud=True    ueip=${ip1}
    sleep   120
    Wait Until Keyword Succeeds   8m     1m         Check counter for One UE scenario
    Pet Ue Deattach     ue=${UE1}    points=392,950;950,1220
    sleep   180
    Wait Until Keyword Succeeds   3m     1m         Check counter for UE release scenario
    [Teardown]        common_case_teardown_for_pet


5GC002271_A_06_FDD_SA_Monitoring_usage_of_each_Scheduling_Resource_pool
    [Tags]    CRT    QC_32848
    [Documentation]
    ...    author: sheng.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    13.12.2021,sheng.liu@nokia-sbell.com,case template draft
     [Setup]           common_case_setup_for_pet     scf_file=${scf_file_path_6}    swconfig_file=${swconfig_file_path}    ignore_cell_check=True
    [Timeout]     1h
    Precondition counter
    ${ue1}    ${ip1}=    Prepare and attach UE1
    Pet Start Ping to UE    ue=${ue1}    in_backgroud=True    ueip=${ip1}
    sleep   180
    Wait Until Keyword Succeeds    5m    1m    Check counter for 5GC002271_A_06
    Pet Stop Ping to UE    ue=${ue1}    ueip=${ip1}
    [Teardown]        common_case_teardown_for_pet



5GC002271_A_08_FDD_SA_Adaptive_SR_period_for_non_VoNR_UEs.robot
    [Tags]    CRT    QC_32849
    [Documentation]
    ...    author: sheng.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    13.12.2021,sheng.liu@nokia-sbell.com,case template draft
     [Setup]           common_case_setup_for_pet     scf_file=${scf_file_path_8}    swconfig_file=${swconfig_file_path}    ignore_cell_check=True
    [Timeout]     1h
    ${UE1}    ${ip1}=    Prepare and attach UE1
    #Pet Start Ping to UE    ue=${UE1}    in_backgroud=True    ueip=${ip1}
    sleep   120
    Wait Until Keyword Succeeds   8m     1m         Check counter for One UE scenario
    Pet Ue Deattach     ue=${UE1}    points=392,950;950,1220
    sleep   240
    Wait Until Keyword Succeeds   3m     1m         Check counter for UE release scenario
    [Teardown]        common_case_teardown_for_pet


5GC002271_A_12_FDD_SA_VoNR_establishment_during_UE_context_modification
    [Tags]    CRT    QC_32850
    [Documentation]
    ...    author: sheng.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    13.12.2021,sheng.liu@nokia-sbell.com,case template draft
     [Setup]           common_case_setup_for_pet     scf_file=${scf_file_path_12}    swconfig_file=${swconfig_file_path}    ignore_cell_check=True
    [Timeout]     1h
    Precondition counter
    ${ue1}    ${ip1}=    Prepare and attach UE1
    sleep    60
    Wait Until Keyword Succeeds   5m     1m      Check counter when no VoNR
    Precondition counter
    Pet Ue Make Voice Call   ue=${ue1}      number=+6688
    sleep    60
    Wait Until Keyword Succeeds   3m     1m      Check counter when VoNR
    Precondition counter
    Pet Ue Cancel Voice Call      ue=${ue1}
    sleep    60
    Wait Until Keyword Succeeds   3m     1m      Check counter when no VoNR
    [Teardown]        common_case_teardown_for_pet




*** Keywords ***


Precondition counter
    Wait For New Measurement Period
    sleep    60
    Delete before PM counter file

Check counter for 5GC002271-A _01_TDD_NSA_Monitoring of Scheduling Resource pools size
    Log to console    check counter
    Sleep    400
    ${pi_list}=  Create List    M55165C00001    M55165C00002      M55165C00003
    ${expect_value}    Set Variable    0
    ${counter_values_list_M55165C00001}    Check counter value without Judge    counter_ID=${pi_list[0]}
    ${counter_values_list_M55165C00002}    Check counter value without Judge    counter_ID=${pi_list[1]}
    ${counter_values_list_M55165C00003}    Check counter value without Judge    counter_ID=${pi_list[2]}
    ${counter_value_1}    Evaluate    ${counter_values_list_M55165C00002[-1]}/${counter_values_list_M55165C00001[-1]}
    ${counter_value_2}    Evaluate    ${counter_values_list_M55165C00003[-1]}/${counter_values_list_M55165C00002[-1]}
    should be true      ${counter_value_1}==2
    should be true      ${counter_value_2}==2


Check counter for One UE scenario
    Log to console    check counter
    ${pi_list}=  Create List    M55165C00007    M55165C00008
    ${counter_values_list_M55165C00007}    Check counter value without Judge    counter_ID=${pi_list[0]}
    ${counter_values_list_M55165C00008}    Check counter value without Judge    counter_ID=${pi_list[1]}
    run_keyword_and_ignore_error        should be true      ${counter_values_list_M55165C00007[-1]}==0
    run_keyword_and_ignore_error        should be true      ${counter_values_list_M55165C00008[-1]}==60


Check counter for UE release scenario
    Log to console    check counter
    ${pi_list}=  Create List        M55165C00007
    ${counter_values_list_M55165C00007}    Check counter value without Judge    counter_ID=${pi_list[0]}
    run_keyword_and_ignore_error        should be true      ${counter_values_list_M55165C00007[-1]}==60


Prepare and attach UE1
    ${UE1}=    Pet Ue Setup    ue_type=android     host=10.56.5.198    serialno=0123456789ABCDEF
    ...                        os=windows    username=csv5-tester     password=Nokia123!
    Pet Ue Deattach     ue=${UE1}    points=392,950;950,1220
    sleep    5
    Pet Ue Attach       ue=${UE1}    points=392,950;950,1220
    sleep    5
    ${ip1}=     Pet Ue Get Ueip    ue=${UE1}
    Log     ${ip1}
    [Return]    ${UE1}    ${ip1}



Check counter for 5GC002271_A_06
    Log to console    check counter
    ${pi_list}=  Create List    M55165C00020    M55165C00021
    ${expect_value}    Set Variable    0
    ${counter_values_list_M55165C00020}    Check counter value without Judge    counter_ID=${pi_list[0]}
    ${counter_values_list_M55165C00021}    Check counter value without Judge    counter_ID=${pi_list[1]}
    should be true      ${counter_values_list_M55165C00020[-1]}==1
    should be true      ${counter_values_list_M55165C00021[-1]}==60


Check counter when no VoNR
    Log to console    check counter
    ${pi_list}=  Create List    M55165C00020    M55165C00021
    ${expect_value}    Set Variable    0
    ${counter_values_list_M55165C00020}    Check counter value without Judge    counter_ID=${pi_list[0]}
    ${counter_values_list_M55165C00021}    Check counter value without Judge    counter_ID=${pi_list[1]}
    should be true      ${counter_values_list_M55165C00020[-1]}==1
    should be true      ${counter_values_list_M55165C00021[-1]}>0

Check counter when VoNR
    Log to console    check counter
    ${pi_list}=  Create List    M55165C00022    M55165C00023
    ${expect_value}    Set Variable    0
    ${counter_values_list_M55165C00022}    Check counter value without Judge    counter_ID=${pi_list[0]}
    ${counter_values_list_M55165C00023}    Check counter value without Judge    counter_ID=${pi_list[1]}
    should be true      ${counter_values_list_M55165C00022[-1]}==1
    should be true      ${counter_values_list_M55165C00023[-1]}>0
