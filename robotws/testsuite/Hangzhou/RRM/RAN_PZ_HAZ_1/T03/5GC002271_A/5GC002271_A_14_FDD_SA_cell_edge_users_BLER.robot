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
${scf_file_path}         ${CURDIR}/scf_14.xml
${swconfig_file_path}    ${CURDIR}/swconfig.txt


*** Test Cases ***
5GC002271-A_14_FDD_SA_cell_edge_users_BLER
    [Tags]    CRT    QC_32846
    [Documentation]
    ...    author: sheng.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    13.12.2021,sheng.liu@nokia-sbell.com,case template draft
     [Setup]           common_case_setup_for_pet     scf_file=${scf_file_path}    swconfig_file=${swconfig_file_path}    ignore_cell_check=True
    [Timeout]     72h
    Precondition counter
    ${ue1}    ${ip1}=    Prepare and attach UE1
    Pet Start Ping to UE    ue=${ue1}    in_backgroud=True    ueip=${ip1}
    sleep   180
    Wait Until Keyword Succeeds    5m    1m    Check counter for 5GC002271_A_06
    Pet Stop Ping to UE    ue=${ue1}    ueip=${ip1}
    [Teardown]        common_case_teardown_for_pet


*** Keywords ***
Precondition counter
    Wait For New Measurement Period
    sleep    60
    Delete before PM counter file

Check counter for 5GC002271_A_06
    Log to console    check counter
    ${pi_list}=  Create List    M55165C00020    M55165C00021
    ${expect_value}    Set Variable    0
    ${counter_values_list_M55165C00020}    Check counter value without Judge    counter_ID=${pi_list[0]}
    ${counter_values_list_M55165C00021}    Check counter value without Judge    counter_ID=${pi_list[1]}
    should be true      ${counter_values_list_M55165C00020[-1]}==1
    should be true      ${counter_values_list_M55165C00021[-1]}==60

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
