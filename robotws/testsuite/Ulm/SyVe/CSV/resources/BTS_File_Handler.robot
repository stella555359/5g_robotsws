*** Settings ***
Documentation
...    | Author:       | Martin and Michele                                                     |
...    | Team:         | CSV Ulm                                                             |
...    | Contact:      |   I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com                          |
...    | Description:  | Common Keywords used in CSV testcases                               |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource    ../../resources/syve_testline.robot


*** Keywords ***
Collect and Validate the Current SCF file
    [Documentation]
    ...  |  Get The Current SCF file of ${node_type}${node_id} and Validate it online.  |
    [Arguments]    ${node_id}=0    ${node_type}=gnb

    ${current_SCF_Location}    Collect the Current SCF file

    Log To Console    ${\n}Validate current SCF file.
    ${oam_alias}    connect.Setup OAM http session    node_id=${node_id}    node_type=${node_type}
    admin.validate_scf_online    scf_file=${current_SCF_Location}    detailed_output=True  connection=${oam_alias}


Collect the Current SCF file
    [Documentation]
    ...  |  Get The Current SCF file of ${node_type}${node_id} ...  |
    ...  |  Return: File (local_dir_path, file_name)
    [Arguments]    ${node_id}=0    ${node_type}=gnb  ${with_auto_configured_parameters}=${True}
    Log To Console    ${\n}Collect current SCF file.
    ${resultSuiteBaseDir}=    testline.Get test suite result base directory
    ${oam_alias}    connect.Setup OAM http session    node_id=${node_id}    node_type=${node_type}
    ${current_SCF_Location}    admin.get current scf file  local_dir_path=${resultSuiteBaseDir}
    ...                                                    file_name=RunningSCF.xml
    ...                                                    connection=${oam_alias}
    ...                                                    with_auto_configured_parameters=${with_auto_configured_parameters}
    RETURN    ${current_SCF_Location}


Store original config files
    [Documentation]
    ...  |  Store the Start SCFC and swconfig.txt files.  |
    ${gNB#1_Original_SCF_Path}=  Store Current SCF from gNB
    Set Suite Variable    ${gNB#1_Original_SCF_Path}
    Log To Console    ${\n}Path to gNB#1 Original SCF: ${\n}${gNB#1_Original_SCF_Path}
    ${gNB#1_Original_swconfig_Path}=  Store Current swconfig from gNB    gnb_id=${0}
    Set Suite Variable    ${gNB#1_Original_swconfig_Path}
    Log To Console    ${\n}Path to gNB#1 Original swconfig.txt: ${\n}${gNB#1_Original_swconfig_Path}
