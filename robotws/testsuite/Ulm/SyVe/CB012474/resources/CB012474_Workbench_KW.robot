*** Settings ***
Documentation
...    | Author:       | Michele, Ulm SQD64                          |
...    | Team:         | MN RAN RD VRF ULM 3                         |
...    | Contact:      | I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com    |
...    | Description:  | Keywords for CB010636                       |

Library    String
Library    Collections

Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    ../../../resources/Common/git_handling.robot
Resource    ../../../resources/Common/testline.robot
Resource    ../../../resources/Common/gnb.robot
Resource    ../../../resources/Common/snapshot.robot

Resource    ../../resources/syve_testline.robot
Resource    ../../resources/scf_info.robot
Resource    testsuite/Ulm/SyVe/resources/SBTS.robot


*** Keywords ***
Prepare TL For CB012474 Testing
    Log Variables
    testline.Set Console Output
    testline.Create Test Suite Log Folders

    ${gnb_count}=   Set Variable If   ${tl.gnbs != None}   ${tl.gnbs.__len__()}   ${0}
    FOR    ${gNB}    IN RANGE    ${gnb_count}
        ${gnb_sw_version}=    testline.Get gNB SW Version    gnb_id=${gNB}
        Log To Console    ${\n}INFO: gNB-${gNB} SW Version is: ${gnb_sw_version}
        gnb.Get Current Alarms From Node    node_type=gnb    node_id=${gNB}
        Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State    node_type=gnb    node_id=${gNB}    timeout=30s
        Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State    node_type=enb    node_id=${gNB}    timeout=30s
    END

    Log To Console    ${\n}Wait that gNBs are Onair...
    Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State For All Cells With Different Technologies    timeout=30s
    Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State For All Cells With Different Technologies
    ...    node_type=gnb    node_id=${1}    timeout=30s

    testline.Check TL Infos
    syve_testline.Save current loads

    syve_testline.Testline Setup For CCRT    ignore_eNB=${True}

    git_handling.Save Current Workspace Info

    FOR    ${gNB}    IN RANGE    ${gnb_count}
        ${commonUnitType}=    testline.Get Common Unit Type    gnb_id=${gNB}    common_unit_id=${0}
        Log To Console    ${\n}Identified Common Unit Type for gnb_id=${gNB}: ${commonUnitType}
    END

    Log To Console    ${\n}Saved Common Unit Type: ${P_COMMON_UNIT_TYPE}

    ${capacityUnitType}=    testline.Get Capacity Unit Type    gnb_id=${0}
    Log To Console    ${\n}Identified Capacity Unit Type: ${capacityUnitType}

    ${oam_alias}    connect.Setup OAM http session    node_type=gNB    node_id=${0}
    admin.Get Detected HW Info    connection=${oam_alias}

    Get SystemModules ProductName

    Get BaseBandModules ProductName

    scf_info.Collect and Validate the Current SCF file

    scf_info.Store original config files
    Log Variables


Save All Logs And Teardown TL For CB012474
    Sleep    3sec
    Log To Console    ${\n}Suite Teardown...
    ${target_dir}=    testline.Get Test Suite Log Directory
    Log To Console    ${\n}Stored files under: ${\n}${target_dir}

#    #ToDo: this Testline Teardown for CCRT reload the base SCF all the time... not usable in TDD Test Case development.
#    syve_testline.Testline Teardown for CCRT    gnb_id=${0}    node_list=gnb_0 gnb_1    ignore_eNB=${True}

    IF    ('syslog' in ${ENABLED_LOGS})    syve_testline.Stop Syslog Collection For CCRTS

    IF    ('snapshot' in ${ENABLED_LOGS})
        Log To Console                     ${\n}Snapshot files under: ${\n}${target_dir}
        snapshot.Get Snapshot For Node     node_type=gNB    node_id=${0}    target_dir=${target_dir}
    END

    admin.Teardown All Aliases For Admin


Setup Test Scenario For CB012474
    [Documentation]
    ...  |  Setup the test scenario for all CB012474 TCs...  |

    Run Keyword And Warn On Failure    syve_testline.Link SCOUT SCF to Configuration ID for Reporting
    ...    node_id=${0}    node_type=SRAN

    ${gnb_count}=   Set Variable If   ${tl.gnbs != None}   ${tl.gnbs.__len__()}   ${0}
    FOR    ${gNB}    IN RANGE    ${gnb_count}
        gnb.Get Current Alarms From Node    node_type=gnb    node_id=${gNB}
    END

    ${Cell_phy_cell_id}    gnb.Get gNB Physical Cell ID
    Log To Console    ${\n}Cell ID Physical layer cell ID: ${Cell_phy_cell_id}

    ${sorted_Keys} =    Get Dictionary Keys    ${Cell_phy_cell_id}
    Log To Console    ${\n}Sorted_Keys: ${sorted_Keys}
    Log To Console    ${\n}First element of list (Sorted_Keys): ${sorted_Keys}[0]
    ${first_5G_Cell} =  Collections.Get From List   ${sorted_Keys}  0
    Log To Console    ${\n}First 5G cell: ${first_5G_Cell}

    ${first_5G_Cell_ID}    String.Fetch From Right    ${sorted_Keys}[0]    -
    Log To Console    ${\n}First 5G cell_ID: ${first_5G_Cell_ID}

    syve_testline.Correlate Cell ID to Physical Cell ID     node_id=0    node_type=gnb    Cell_ID=${first_5G_Cell_ID}

    gnb.Get Cell Radio Module Mapping    node_id=0    node_type=gnb
    gnb.Get Radio Module Cell Mapping    node_id=0    node_type=gnb

    gnb.Get Cell Radio Module Mapping    node_id=0    node_type=enb
    gnb.Get Radio Module Cell Mapping    node_id=0    node_type=enb

    syve_testline.Correlate Cell ID to Radio Module ID    node_id=0    node_type=gnb    Cell_ID=${first_5G_Cell_ID}

    Log To Console    ${\n}Cell_info for LTE Cells...
    ${oam_alias}    connect.Setup OAM http session    node_type=eNB    node_id=${0}
    Run Keyword And Warn On Failure    admin.get_cell_list    connection=${oam_alias}

    SBTS.Get Cell Dictionary
    SBTS.Log Cell RAN Types
    SBTS.Get globalCellId For RAN Type
    SBTS.Get Cells Parameters For RAN Type

    ${list_of_LTE_Cells_ID}    SBTS.Get globalCellId For RAN Type    RAN_type=lte
    SBTS.Get Cells Parameters For RAN Type    node_type=eNB

    # Set Test Variable    ${first_LTE_Cell_ID}    ${list_of_LTE_Cells_ID[0]}
    ${first_LTE_Cell_ID}    Get From List    ${list_of_LTE_Cells_ID}    0
    syve_testline.Correlate Cell ID to Radio Module ID    node_id=0    node_type=eNB    Cell_ID=${first_LTE_Cell_ID}

    SBTS.Get Physical Cell ID    node_type=eNB


Test Scenario Teardown
    Log To Console    ${\n}CB012474 "Test TEARDOWN"!
    Log Variables

    ${gnb_count}=   Set Variable If   ${tl.gnbs != None}   ${tl.gnbs.__len__()}   ${0}
    FOR    ${gNB}    IN RANGE    ${gnb_count}
        gnb.Get Current Alarms From Node    node_type=gnb    node_id=${gNB}
    END
