*** Settings ***
Documentation
...    | [5G24R3]      | Data_Volumes_and_Throughput   |
...    | Test case:    | Simple Data Tranfer                                                             |
...    | UEs:          | Using QUALCOMM SDX75, SDX70, SDX60.                                    |
...    | Author:       | Michele                                                                |
...    | Team:         | Ulm SQD64                                                              |
...    | Contact:      | I_PZ_ULM_SQD_64@internal.nsn.com                                       |
...    | Description:  | Keywords for UEs                                                  |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.ue
Library    ute_tshark
Library    String
Library    Collections

Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    ../../resources/Common/git_handling.robot
Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/snapshot.robot
Resource    ../../resources/Common/tcpdump.robot

Resource    ../resources/syve_testline.robot
Resource    ../resources/attenuator.robot
Resource    ../resources/UEs_handler.robot

Resource    testsuite/Ulm/SyVe/CB010636/resources/CB010636_Workbench_KW.robot
Resource    testsuite/Ulm/SyVe/resources/scf_info.robot

Suite Setup     Prepare TL for Data Transfer Testing
Suite Teardown  Save all Logs and Teardown TL for Data Transfer Testing


*** Variables ***
${DT_DL}                  DT_DL
${DT_UL}                  DT_UL
${DL_RATE}                20
${UL_RATE}                10
${TCP_DL_RATE}            550
${TCP_UL_RATE}            155


*** Test Cases ***
E2E 5G SA Data Transfer
    [Documentation]
    ...  | Data Transfer Testing     |
    ...  | This test case is aimed at verifying the counters that are introduced as part of Data Transfer Testing |
    ...  | to monitor DL Per CC UE Throughput Counters and UL Per CC UE Throughput Counters in SA mode.             |
    [Tags]    3UEs    QCD_MN_RAN
    ...    Data_Transfer_Testing
    [Setup]    Setup Test Scenario for Data Transfer Testing
    Log To Console    ${\n}Data Transfer Testing Using Three UEs: SDX75, SDX70, SDX60

    Setup QCP_ for report    SBTS00=RAN_VRF    SBTS24R3=RAN_ST    SBTS24R2=RAN_ST
    Setup QC_ID for report    SBTS00=54628    SBTS24R3=859234   SBTS24R2=859250

    ${FirstUE}    Init UE with APN and Collect Trace then Start BGD TPut    UE_id=${1}
    Set Test Variable    ${FirstUE}

    Start iPerf3 Data Transfer UL DL    ue_alias=${FirstUE}    ue_DL_Rate=${DL_RATE}    ue_UL_Rate=${UL_RATE}

    Sleep    30sec

    taf.ue.Stop Data Transfer    ${DT_DL}_${FirstUE}
    taf.ue.Stop Data Transfer    ${DT_UL}_${FirstUE}

    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=${DT_UL}_${FirstUE}
    ...    tput=${UL_RATE} Mbits/sec
    ...    deviation=20%
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=${DT_DL}_${FirstUE}
    ...    tput=${DL_RATE} Mbits/sec
    ...    deviation=10%

    Start iPerf3 TCP Data Transfer UL DL    ue_alias=${FirstUE}

    # Sleep    30sec
    Await data transfer finish    TCP_${DT_DL}_${FirstUE}
    Await data transfer finish    TCP_${DT_UL}_${FirstUE}

    taf.ue.Stop Data Transfer    TCP_${DT_DL}_${FirstUE}
    taf.ue.Stop Data Transfer    TCP_${DT_UL}_${FirstUE}

    Get Data Transfer Statistics    TCP_${DT_DL}_${FirstUE}
    Get Data Transfer Statistics    TCP_${DT_UL}_${FirstUE}

    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=TCP_${DT_UL}_${FirstUE}
    ...    tput=${TCP_UL_RATE} Mbits/sec
    ...    deviation=20%
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=TCP_${DT_DL}_${FirstUE}
    ...    tput=${TCP_DL_RATE} Mbits/sec
    ...    deviation=10%

    [Teardown]    Run Keywords
    ...    Log To Console    ${\n}The End.
    ...    AND
    ...    taf.ue.Stop Data Transfers For All Ues
    ...    AND
    ...    Test Scenario Teardown


*** Keywords ***
Prepare TL for Data Transfer Testing
    Log Variables
    testline.Set Console Output
    testline.Create Test Suite Log Folders

    Log To Console    ${\n}Wait that gNBs are Onair...
    Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State   node_type=gnb    node_id=${0}    timeout=30s
    Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State   node_type=enb    node_id=${0}    timeout=30s

    ${gnb_sw_version}=    Get gNB SW version    gnb_id=${0}
    Log to console    ${\n}INFO: GNB SW Version is: ${gnb_sw_version}

    ${enb_sw_version}=    Get eNB SW version    enb_id=${0}
    Log to console    ${\n}INFO: eNB SW Version is: ${enb_sw_version}

    testline.Check TL Infos
    syve_testline.Save current loads
#    syve_testline.Testline Setup for CCRT
    IF    ('syslog' in ${ENABLED_LOGS})    Start Syslog Collection For CCRTS
    git_handling.Save Current Workspace Info
    ${capacityUnitType}=     testline.Get Capacity Unit Type    gnb_id=${0}
    Set Suite Variable    ${capacityUnitType}
    Log To Console    ${\n}Identified Capacity Unit Type: ${capacityUnitType}

    Collect and Validate the Current SCF file

    Store original config files
    Log Variables


Save all Logs and Teardown TL for Data Transfer Testing
    Sleep    3sec
    Log To Console    ${\n}Suite Teardown...
    ${target_dir}=    testline.Get test suite log directory
    Log To Console    ${\n}Stored files under: ${\n}${target_dir}

    taf.ue.Stop Data Transfers For All Ues

    IF    'syslog' in ${ENABLED_LOGS}    Stop Syslog Collection For CCRTS

    IF    'snapshot' in ${ENABLED_LOGS}
        Log To Console    ${\n}Snapshot files under: ${\n}${target_dir}
        snapshot.Get Snapshot For Node     node_type=gNB    node_id=${0}    target_dir=${target_dir}
    END

    admin.Teardown All Aliases For Admin


Setup Test Scenario for Data Transfer Testing
    [Documentation]
    ...  |  Setup the test scenario for all Data Transfer Testing TCs...  |

    Run Keyword And Warn On Failure    Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=SRAN

    gnb.Get Current Alarms From Node    node_type=gnb
    Run Keyword And Warn On Failure    gnb.Get Current Alarms From Node    node_type=enb

    ${Cell_phy_cell_id}    gnb.Get gNB Physical Cell ID
    Log To Console    ${\n}Cell ID Physical layer cell ID: ${Cell_phy_cell_id}

    Run Keyword And Warn On Failure    Correlate Cell ID to Physical Cell ID     node_id=0    node_type=gnb    Cell_ID=171

    gnb.Get Cell Radio Module Mapping    node_id=0    node_type=gnb
    gnb.Get Radio Module Cell Mapping    node_id=0    node_type=gnb

    Run Keyword And Warn On Failure    Correlate Cell ID to Radio Module ID    node_id=0    node_type=gnb    Cell_ID=173

#    Log To Console    ${\n}Block all LTE Cells. SA case...
#    ${oam_alias}    connect.Setup OAM http session    node_id=0    node_type=eNB
#    admin.block_all_cells    rat=LTE    detailed_output=True    connection=${oam_alias}

#    Log To Console    ${\n}Cell_info for LTE Cells...
#    Run Keyword And Warn On Failure    admin.get_cell_list    connection=${oam_alias}

#    Log To Console    ${\n}Attenuate all cells in testline,${\n}Please open one attenuator Cell before "Require UE"...
#    attenuator.Attenuate all cells in testline    off_value=${initial_off_value}

    Log To Console   ${\n}Setup Tshark on TestPc with "-s0 sctp or icmp" filters.(-c 9000001 is used as workaround to identify Traces.)
    setup tshark    eth3
    tcpdump.Start Tcpdump on TestPc    options=-i eth3 -s0 sctp or icmp    # option=-i eth3 -s0 -c 9000001 sctp or icmp
    ...    collector=Full_Trace

    Log To Console    ${\n}Kill all iPerf* processes...
    Kill all iperf processes on Appserver and UE PC


Test Scenario Teardown
    Log To Console    ${\n}Data Transfer Testing "Test TEARDOWN"!

    ${PathTo_Full_Trace_PCAPfile}=   tcpdump.Stop Tcpdump on TestPc    collector=Full_Trace
    Log To Console    ${\n}Full_Trace saved under: ${PathTo_Full_Trace_PCAPfile}
    teardown_all_aliases_for_tshark

    ${qc_project_to_Use}=    Setup QCP_ for report    SBTS00=RAN_VRF    SBTS24R3=RAN_ST    SBTS24R2=RAN_ST
    ${QC_ID_to_Use}=    Setup QC_ID for report    SBTS00=54628    SBTS24R3=859234   SBTS24R2=859250    SBTS24R1=856815
    Log To Console    ${\n}Report to Project: ${qc_project_to_Use} QC_ID: ${QC_ID_to_Use}.


Collect and Validate the Current SCF file
    [Documentation]
    ...  |  Get The Current SCF file of ${node_type}${node_id} and Validate it online.  |
    [Arguments]    ${node_id}=0    ${node_type}=gnb
    Log To Console    ${\n}Collect current SCF file.
    ${resultSuiteBaseDir}=    testline.Get test suite result base directory
    ${oam_alias}    connect.Setup OAM http session    node_id=${node_id}    node_type=${node_type}
    ${current_SCF_Location}    admin.get current scf file
    ...    local_dir_path=${resultSuiteBaseDir}
    ...    file_name=RunningSCF.xml
    ...    timeout=30
    ...    connection=${oam_alias}
    Log To Console    ${\n}Validate current SCF file.
    admin.validate_scf_online    scf_file=${current_SCF_Location}    detailed_output=True  connection=${oam_alias}


Store original config files
    [Documentation]
    ...  |  Store the Start SCFC and swconfig.txt files.  |
    ${gNB#1_Original_SCF_Path}=  Store Current SCF from gNB
    Set Suite Variable    ${gNB#1_Original_SCF_Path}
    Log To Console    ${\n}Path to gNB#1 Original SCF: ${\n}${gNB#1_Original_SCF_Path}
    ${gNB#1_Original_swconfig_Path}=  Store Current swconfig from gNB    gnb_id=${0}
    Set Suite Variable    ${gNB#1_Original_swconfig_Path}
    Log To Console    ${\n}Path to gNB#1 Original swconfig.txt: ${\n}${gNB#1_Original_swconfig_Path}
