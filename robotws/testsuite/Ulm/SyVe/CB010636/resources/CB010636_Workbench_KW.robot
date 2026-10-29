*** Settings ***
Documentation
...    | Author:        | Michele, Ulm SQD64                          |
...    | Contact:       | I_PZ_ULM_SQD_64@internal.nsn.com            |
...    | Description:   | Keywords for CB010636                       |

Library    taf.ue
Library    ute_tshark
Library    String
Library    Collections

Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    ../../../resources/Common/git_handling.robot
Resource    ../../../resources/Common/testline.robot
Resource    ../../../resources/Common/gnb.robot
Resource    ../../../resources/Common/snapshot.robot
Resource    ../../../resources/Common/tcpdump.robot

Resource    ../../resources/syve_testline.robot
Resource    ../../resources/scf_info.robot
Resource    ../../resources/attenuator.robot

Resource    ../resources/CB010636_Commissioning.robot

*** Variables ***
${withPMcountersCheck}    true
${initial_off_value}      ${110}
${TRACE_FILE_INC}         0


*** Keywords ***
Prepare TL for CB010636 Testing
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
    IF    ('syslog' in ${ENABLED_LOGS})    Start syslog collection for CCRTS
    git_handling.Save Current Workspace Info
    ${capacityUnitType}=     testline.Get Capacity Unit Type    gnb_id=${0}
    Set Suite Variable    ${capacityUnitType}
    Log To Console    ${\n}Identified Capacity Unit Type: ${capacityUnitType}

    scf_info.Collect and Validate the Current SCF file

    scf_info.Store original config files
    Log Variables


Save all Logs and Teardown TL for CB010636
    Sleep    3sec
    Log To Console    ${\n}Suite Teardown...
    ${target_dir}=    testline.Get test suite log directory
    Log To Console    ${\n}Stored files under: ${\n}${target_dir}

    taf.ue.Stop Data Transfers For All Ues

    IF    ('syslog' in ${ENABLED_LOGS})    Stop syslog collection for CCRTS

    IF    ('snapshot' in ${ENABLED_LOGS})
        Log To Console    ${\n}Snapshot files under: ${\n}${target_dir}
        snapshot.Get snapshot for node     node_type=gNB    node_id=${0}    target_dir=${target_dir}
    END

    admin.Teardown All Aliases For Admin


Start Tcpdump on gNB trace
    [Arguments]   ${UE_id}   ${gnb_id}=0
    ${TRACE_FILE_INC}=    Evaluate    ${TRACE_FILE_INC} + 1
    Log To Console    ${\n}START "Tcpdump on gNB" traces in UE_${UE_id} (Part ${TRACE_FILE_INC}).
    tcpdump.Start Tcpdump on gNB Common Unit
    ...    gnb_id=${gnb_id}
    ...    collector=tcpdump_gNB${gnb_id}_UE${UE_id}_Part${TRACE_FILE_INC}
    ...    options=-i any port 38472 or port 38412 or port 38422 or port 38462 or port 36422

    Set Test Variable    ${TRACE_FILE_INC}


Stop Tcpdump on gNB trace
    [Arguments]     ${UE_id}   ${gnb_id}=0
    Log To Console    ${\n}Collect "Tcpdump on gNB" traces in UE_${UE_id} (Part ${TRACE_FILE_INC}).
    ${tcp_file_gnb}  tcpdump.Stop Tcpdump on gNB Common Unit
    ...  collector=tcpdump_gNB${gnb_id}_UE${UE_id}_Part${TRACE_FILE_INC}
    set test variable  ${tcp_file_gnb${gnb_id}_UE_${UE_id}}  ${tcp_file_gnb}


Setup Test Scenario for CB010636
    [Documentation]
    ...  |  Setup the test scenario for all CB010636 TCs...  |

    Run Keyword And Warn On Failure    Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=gnb

    gnb.Get Current Alarms From Node    node_type=gnb
    gnb.Get Current Alarms From Node    node_type=enb

    ${Cell_phy_cell_id}    gnb.Get gNB Physical Cell ID
    Log To Console    ${\n}Cell ID Physical layer cell ID: ${Cell_phy_cell_id}

    Correlate Cell ID to Physical Cell ID     node_id=0    node_type=gnb    Cell_ID=8

    gnb.Get Cell Radio Module Mapping    node_id=0    node_type=gnb
    gnb.Get Radio Module Cell Mapping    node_id=0    node_type=gnb

    gnb.Get Cell Radio Module Mapping    node_id=0    node_type=enb
    gnb.Get Radio Module Cell Mapping    node_id=0    node_type=enb

    Correlate Cell ID to Radio Module ID    node_id=0    node_type=gnb    Cell_ID=2
    Correlate Cell ID to Radio Module ID    node_id=0    node_type=eNB    Cell_ID=3

    Log To Console    ${\n}Block all LTE Cells. SA case...
    ${oam_alias}    connect.Setup OAM http session    node_id=0    node_type=eNB
    admin.block_all_cells    rat=LTE    detailed_output=True    connection=${oam_alias}

    Log To Console    ${\n}Cell_info for LTE Cells...
    Run Keyword And Warn On Failure    admin.get_cell_list    connection=${oam_alias}

    Log To Console    ${\n}Attenuate all cells in testline,${\n}Please open one attenuator Cell before "Require UE"...
    attenuator.Attenuate all cells in testline    off_value=${initial_off_value}

    Log To Console   ${\n}Setup Tshark on TestPc with "-s0 sctp or icmp" filters.(-c 9000001 is used as workaround to identify Traces.)
    setup tshark    eth3
    tcpdump.Start Tcpdump on TestPc    options=-i eth3 -s0 sctp or icmp    # option=-i eth3 -s0 -c 9000001 sctp or icmp
    ...    collector=Full_Trace

    Log To Console    ${\n}Kill all iPerf* processes...
    Kill all iperf processes on Appserver and UE PC


Cell Additional Info
    Run Keyword And Warn On Failure    gnb.Verify All Cells are Configured    node_type=gnb    connection=gnb-0-OAM-http-session
    Run Keyword And Warn On Failure    gnb.Verify All Cells are Configured    node_type=enb    connection=enb-0-OAM-http-session

    ${Cell_phy_cell_id}    gnb.Get gNB Physical Cell ID
    Log To Console    ${\n}Cell ID Physical layer cell ID: ${Cell_phy_cell_id}


Test Scenario Teardown
    Log To Console    ${\n}CB010636 "Test TEARDOWN"!

    ${PathTo_Full_Trace_PCAPfile}=   tcpdump.Stop Tcpdump on TestPc    collector=Full_Trace
    Log To Console    ${\n}Full_Trace saved under: ${PathTo_Full_Trace_PCAPfile}
    teardown_all_aliases_for_tshark

    Log To Console    ${\n}Stop Data Transfers For All UEs
    Run Keyword And Warn On Failure    taf.ue.stop_data_transfers_for_all_ues

    Run Keyword And Ignore Error    taf.ue.Detach UE    ${4CC_UE}
    Run Keyword And Ignore Error    taf.ue.Detach UE    ${3CC_UE}
    Run Keyword And Ignore Error    taf.ue.Detach UE    ${Without_Aggregated_Carrier}

    Log To Console    ${\n}UnBlock all LTE Cells.
    ${oam_alias}    connect.Setup OAM http session    node_id=0    node_type=eNB
    Run Keyword And Warn On Failure    admin.unblock_all_cells    rat=LTE    detailed_output=True    connection=${oam_alias}    timeout=120
    Log To Console    ${\n}UnBlock all 5G Cells.
    ${oam_alias}    connect.Setup OAM http session    node_id=0    node_type=gNB
    Run Keyword And Warn On Failure    admin.unblock_all_cells    rat=NR    detailed_output=True    connection=${oam_alias}    timeout=120
    gnb.Get Current Alarms From Node    node_type=gnb
    gnb.Get Current Alarms From Node    node_type=enb


Get Scell Physical ID
    [Documentation]
    ...    | Returns the Physical cell IDs of the scells                                             |
    ...    | ${scell_ID_list}  contains the cell IDs of the scells                                   |
    ...    | Returns the list of the physical cell IDs of the scells in ${physCellId_scell}          |
    [Arguments]    ${scell_list}=[]

    ${physCellId_scell} =    Create List
    ${is_empty}    Run Keyword And Return Status    Should Be Empty    ${scell_list}
    IF   ${is_empty}     RETURN   ${physCellId_scell}
    @{scell_ID_list}    split string  ${scell_list}  ,
    FOR    ${scell_id}    IN    @{scell_ID_list}
        ${physCell_Id}=   Correlate Cell ID to Physical Cell ID     node_id=0    node_type=gnb    Cell_ID=${scell_id}
        Append To List    ${physCellId_scell}    ${physCell_Id}
    END
    RETURN    ${physCellId_scell}


Start Data Transfer UL DL
    [Documentation]
    ...    | Start Data Transfer in UL and DL and STOP the DLBackground of 1 Mbits/sec.  |
    [Arguments]    ${ue_alias}=UE_1    ${ue_UL_Rate}=${UL_RATE}    ${ue_DL_Rate}=${DL_RATE}    ${port_value}=${None}
    ...    ${simultaneous_connections}=5
    Log To Console    ${\n}The number of simultaneous connections to make to the server is ${simultaneous_connections}.
    Log To Console    ${\n}iPerf3! Start Data Transfer in UL for ${ue_alias} with ${ue_UL_Rate} Mbits/sec

    ${ue_UL_Rate_per_process}=    Evaluate    str(int(${ue_UL_Rate}/${simultaneous_connections}))
    Log To Console    ${\n}UL TPut value per process is ${ue_UL_Rate_per_process}.

    taf.ue.Start Data Transfer    dt_name=${DT_UL}_${ue_alias}    ue_alias=${ue_alias}
    ...    direction=ul
    ...    throughput=${ue_UL_Rate_per_process} Mbits/sec
    ...    protocol=udp
    ...    packet=1330
    ...    bearer_alias=UeAutomatic
    ...    parallel=${simultaneous_connections}
    ...    port=${port_value}

    Log To Console    ${\n}iPerf3! Start Data Transfer in DL for ${ue_alias} with ${ue_DL_Rate} Mbits/sec
    ${ue_DL_Rate_per_process}=    Evaluate   str(int(${ue_DL_Rate}/${simultaneous_connections}))
    Log To Console    ${\n}DL TPut value per process is ${ue_DL_Rate_per_process}.

    taf.ue.Start Data Transfer    dt_name=${DT_DL}_${ue_alias}    ue_alias=${ue_alias}
    ...    direction=dl
    ...    throughput=${ue_DL_Rate_per_process} Mbits/sec
    ...    protocol=udp
    ...    packet=1330
    ...    bearer_alias=UeAutomatic
    ...    parallel=${simultaneous_connections}
    ...    port=${port_value}

    Log To Console    ${\n}Stop Background traffic.
    taf.ue.Stop Data Transfer    DL_Background_${ue_alias}


Set Test Case Variables for UEs HOs
    [Documentation]
    ...    |  Set the test case variables for Handovers. (used to set the attenuators and Block or Unblock Cells.  |
    ...    |  UE1 Have 4CC, UE2 Have 3CC, UE3 do not have Component Carrier.  |
    [Arguments]
    ...  ${UE_1_PCell}=${8}  ${UE_1_SCell1}=${4}  ${UE_1_SCell2}=${9}  ${UE_1_SCell3}=${13}
    ...  ${UE_2_PCell}=${9}  ${UE_2_SCell1}=${6}  ${UE_2_SCell2}=${7}
    ...  ${UE_3_Cell}=${13}

    Set Test Variable     ${UE_1_PCell}    ${UE_1_PCell}
    Set Test Variable     ${UE_1_SCell1}    ${UE_1_SCell1}
    Set Test Variable     ${UE_1_SCell2}    ${UE_1_SCell2}
    Set Test Variable     ${UE_1_SCell3}    ${UE_1_SCell3}

    Set Test Variable     ${UE_2_PCell}    ${UE_2_PCell}
    Set Test Variable     ${UE_2_SCell1}    ${UE_2_SCell1}
    Set Test Variable     ${UE_2_SCell2}    ${UE_2_SCell2}

    Set Test Variable     ${UE_3_Cell}    ${UE_3_Cell}


Set test case variables for NSA
    [Documentation]
    ...    | Set the test case varibales    |

    [Arguments]   ${PCELL_UE_1}=${1}  ${PCELL_UE_3}=${1}  ${S_PCELL_UE_1}=${1}  ${S_PCELL_UE_2}=${1}   ${S_PCELL_UE_3}=${1}   ${SCELL_UE_1}=${1}
    ...           ${SCELL_UE_2}=${1}   ${SCELL_UE_3}=${1}

    Set Test Variable     ${PCELL_UE_1}   ${PCELL_UE_1}
    Set Test Variable     ${PCELL_UE_3}   ${PCELL_UE_3}
    Set Test Variable     ${S_PCELL_UE_1}   ${S_PCELL_UE_1}
    Set Test Variable     ${S_PCELL_UE_2}   ${S_PCELL_UE_2}
    Set Test Variable     ${S_PCELL_UE_3}   ${S_PCELL_UE_3}
    Set Test Variable     ${SCELL_UE_1}   ${SCELL_UE_1}
    Set Test Variable     ${SCELL_UE_2}   ${SCELL_UE_2}
    Set Test Variable     ${SCELL_UE_3}   ${SCELL_UE_3}


Add Cells for the Aggregated Carrier
    [Documentation]
    ...  | Set the attenuator in order to perform Carrier Aggregation.  |
    ...  | use "Set Test Case Variables for SA". |
    Log To Console    ${\n}Add Cells for the Aggregated Carrier...
    ${ru_id_for_4CC_UE_1SCell}=    Correlate Cell ID to Radio Module ID    node_type=gNB    node_id=${0}    Cell_ID=${UE_1_SCell1}
    ${ru_id_for_4CC_UE_1SCell}   Evaluate    ${ru_id_for_4CC_UE_1SCell}[0]-${1}    #ru_id start from 0.
    attenuator.Set gNB all ports attenuation    value_in_db=15    ru_id=${ru_id_for_4CC_UE_1SCell}    # Cell_4 and Cell_3

    ${ru_id_for_4CC_UE_2SCell}=    Correlate Cell ID to Radio Module ID    node_type=gNB    node_id=${0}    Cell_ID=${UE_1_SCell2}
    ${ru_id_for_4CC_UE_2SCell}   Evaluate    ${ru_id_for_4CC_UE_2SCell}[0]-${1}    #ru_id start from 0.
    attenuator.Set gNB all ports attenuation    value_in_db=16    ru_id=${ru_id_for_4CC_UE_2SCell}    # Cell_9

    ${ru_id_for_4CC_UE_3SCell}=    Correlate Cell ID to Radio Module ID    node_type=gNB    node_id=${0}    Cell_ID=${UE_1_SCell3}
    ${ru_id_for_4CC_UE_3SCell}   Evaluate    ${ru_id_for_4CC_UE_3SCell}[0]-${1}    #ru_id start from 0.
    attenuator.Set gNB all ports attenuation    value_in_db=17    ru_id=${ru_id_for_4CC_UE_3SCell}    # Cell_13 and Cell_14

    ${ru_id_for_3CC_UE_1SCell}=    Correlate Cell ID to Radio Module ID    node_type=gNB    node_id=${0}    Cell_ID=${UE_2_SCell1}
    ${ru_id_for_3CC_UE_1SCell}   Evaluate    ${ru_id_for_3CC_UE_1SCell}[0]-${1}    #ru_id start from 0.
    attenuator.Set gNB all ports attenuation    value_in_db=18    ru_id=${ru_id_for_3CC_UE_1SCell}    # Cell_6 and Cell_5

    ${ru_id_for_3CC_UE_2SCell}=    Correlate Cell ID to Radio Module ID    node_type=gNB    node_id=${0}    Cell_ID=${UE_2_SCell2}
    ${ru_id_for_3CC_UE_2SCell}   Evaluate    ${ru_id_for_3CC_UE_2SCell}[0]-${1}    #ru_id start from 0.
    attenuator.Set gNB all ports attenuation    value_in_db=19    ru_id=${ru_id_for_3CC_UE_2SCell}    # Cell_7


Set all Suite Variables
    [Documentation]
    ...    | Set the test case varibales    |
    [Arguments]  ${gnb_id}=${0}
    ${GNB_SW_BRANCH}  Get gNB SW Branch
    Set suite variable  ${GNB_SW_BRANCH}
    ${TL_NAME}  testline.Get Testline Name
    Set suite variable  ${TL_NAME}
    ${MRBTS_ID_0}  scf_info.Get MRBTS-Id  ${0}
    Set test variable  ${MRBTS_ID_${0}}  ${MRBTS_ID_0}
    ${NRBTS_ID_0}=  scf_info.Get NRBTS-Id  gnb_id=${gnb_id}
    set suite variable  ${NRBTS_ID_0}
    Set Suite Variable  ${basic_scf_path}
    ...  /mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs/${GNB_SW_BRANCH}/${TL_NAME}/GNB-${0}/scf.xml

Block unBlock cells   # ToDo: remove duplicate KWs and move to syve_testline.robot. operated_cell should be a list of cells...
    [Documentation]
    ...    |  block or unblock cells for eNB or gNB  |
    [Arguments]    ${operated_cell_1}    ${operated_cell_2}=None    ${operated_extra_cell}=None
    ...    ${node_type}=gnb    ${cell_op}=block    ${node_id}=${0}
    Log To Console    ${\n}${cell_op} Cell(s) ${operated_cell_1} of: ${node_type}

    ${node_type}    Convert To Lower Case    ${node_type}

    ${MRBTS_ID}=    scf_info.Get MRBTS-Id    enb_id=${node_id}
    Log To Console    ${\n}LTE: The MRBTS_ID is ${MRBTS_ID}.

    ${NRBTS_ID}=    scf_info.Get NRBTS-Id    gnb_id=${node_id}
    Log To Console    ${\n}5G: The NRBTS_ID is ${NRBTS_ID}.

    ${dist_path}    Set Variable If
    ...    '${node_type}'=='gnb'   NRBTS-${NRBTS_ID}/NRCELL
    ...    '${node_type}'=='enb'   LNBTS-${MRBTS_ID}/LNCEL

    ${oam_alias}=   wait until keyword succeeds   3 min   20 sec   connect.Setup OAM http session  node_type=${node_type}  node_id=${node_id}

    ${bts_id}=    Set Variable if
    ...    '${node_type}'=='gnb'    ${NRBTS_ID}
    ...    '${node_type}'=='enb'    ${MRBTS_ID}    # NRBTS is the 5G id. Inside the SCF is called MRBTS.

    IF    '${operated_cell_1}'!='${None}'    Run keyword   admin.${cell_op}_cell
    ...    dist_name=MRBTS-${bts_id}/${dist_path}-${operated_cell_1}  connection=${oam_alias}
    IF    '${operated_cell_2}'!='${None}'    Run keyword   admin.${cell_op}_cell
    ...    dist_name=MRBTS-${bts_id}/${dist_path}-${operated_cell_2}  connection=${oam_alias}
    IF    '${operated_extra_cell}'!='${None}'    Run keyword   admin.${cell_op}_cell
    ...    dist_name=MRBTS-${bts_id}/${dist_path}-${operated_extra_cell}  connection=${oam_alias}
    Sleep    30s    reason=Wait for cells to block
