*** Settings ***
Documentation   Resources file for feature 'CB009267'
...             Team: 'MN 5G&SC PZ ULM 4'
...             Email: 'I_MN_5GSC_PZ_ULM_SQD_62@nokia.com'
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.sbts.oam.coam.admin                              WITH NAME   admin
Library    taf.config.scf                                       WITH NAME   scf
Library    ute_tshark
Library    ../../resources/Common/python/MCSharkDissectors.py
Library    ../../resources/Common/python/alarm_handling.py      WITH NAME   alarm

Resource    ../../resources/Common/alarm_handling.robot
Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/tcpdump.robot
Resource    ../resources/attenuator.robot
Resource    ../resources/attenuator_scenario.robot
Resource    ../resources/syve_testline.robot
Resource    ../resources/bts_log_analysis.robot
Resource    ../resources/enb.robot
Resource    ../resources/scf_info.robot

Resource    resources/CB009267_Verification.robot
Resource    resources/CB009267_Commissioning.robot


*** Keywords ***

Prepare TL for Testing
    [Documentation]     in Test [Suite Setup] run the following keywords
    testline.Create Test Suite Log Folders
    Set correct protocol name for wireshark check

Setup Test for CB009267
    [Documentation]     in Test Case [Setup] run the following keywords
    #  Start syslogs for all nodes depending on param ENABLED_LOGS (default=syslog)
    syve_testline.Testline Setup for CCRT
    testline.Create testcase log directory

    ${gnb_sw_version}=    Get GNB SW Version    gnb_id=${0}
    Log To Console    ${\n}INFO: GNB SW Version is: ${gnb_sw_version}

    attenuator.Set Attenuator To Max Value
    ute_tshark.Setup Tshark    eth1

    ${alarms_1}  alarm_handling.Get All Alarms From Node
    Set Suite Variable  ${ALARMLIST_1}  ${alarms_1}

Set correct protocol name for wireshark check
    [Documentation]     checks the wireshark plugins and sets the protocol name
    ...                 for the verification of the wireshark file depending of the installed plugins
    ${ft1ap_filter}  MCSharkDissectors.get_f1ap_tshark_filter_string
    Set Suite Variable  $PROTOCOL_NAME   ${ft1ap_filter}


Set Test Case Variables For SA
    [Documentation]    Set the variables needed in the scope of SA test cases
    ...   The cell PCELL_UE_1_P2S is the source primary cell and gets a target scell
    ...
    [Arguments]   ${TC_NUMBER}
    ...           ${gnb_id}=0   ${enb_id}=0
    ...           ${capabilities}=REAL_ANDROID_UE
    ...           ${PCELL_UE_1_P2S}=${0}   ${S_CELL_UE_1_S2P}=${0}   ${S_CELL_UE_1_SOURCE}=${0}
    ...           ${S_CELL_UE_1_TARGET}=${0}
    ...           ${ADJ_CELLS_GNB0}=${0}

    Set Test Variable     ${TC_NUMBER}
    Set Test Variable     ${gnb_id}
    Set Test Variable     ${enb_id}
    Set Test Variable     ${capabilities}

    Set Test Variable     ${PCELL_UE_1_P2S}
    Set Test Variable     ${S_CELL_UE_1_S2P}
    Set Test Variable     ${S_CELL_UE_1_SOURCE}
    Set Test Variable     ${S_CELL_UE_1_TARGET}
    Set Test Variable     ${ADJ_CELLS_GNB0}

Set Test Case Variables For NSA
    [Documentation]    Set the variables needed in the scope of NSA test cases
    [Arguments]   ${TC_NUMBER}
    ...           ${gnb_id}=0   ${enb_id}=0
    ...           ${capabilities}=REAL_ANDROID_UE
    ...           ${PCELL_UE_1}=${0}   ${S_PCELL_UE_1}=${0}   ${SCELL_UE_1}=${0}
    ...                                ${S_PCELL_UE_2}=${0}   ${SCELL_UE_2}=${0}
    ...           ${PCELL_UE_3}=${0}   ${S_PCELL_UE_3}=${0}   ${SCELL_UE_3}=${0}
    ...           ${ADJ_CELLS_GNB0}=${0}

    Set Test Variable     ${TC_NUMBER}
    Set Test Variable     ${gnb_id}
    Set Test Variable     ${enb_id}
    Set Test Variable     ${capabilities}

    Set Test Variable     ${PCELL_UE_1}
    Set Test Variable     ${S_PCELL_UE_1}
    Set Test Variable     ${SCELL_UE_1}

    Set Test Variable     ${S_PCELL_UE_2}
    Set Test Variable     ${SCELL_UE_2}

    Set Test Variable     ${PCELL_UE_3}
    Set Test Variable     ${S_PCELL_UE_3}
    Set Test Variable     ${SCELL_UE_3}
    Set Test Variable     ${ADJ_CELLS_GNB0}


Perform Preconditions of Test Scenario
   [Documentation]    common TC part:
   ...   get SCFs, register attenuator, check UE, block all LTE cells, do commissioning
   [Arguments]  ${gnb_id}=${0}  ${enb_id}=${0}  ${capabilities}=UE_1

    Log To Console   Get SCF from gNB-${gnb_id} and eNB-${enb_id}
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}

    ${configSuiteDir}=    testline.Get test suite config directory
    ${configDir}=         testline.Get Testcase Log Directory

    Log To Console   and store it in target_dir ${configDir}
    gnb.Store Current SCF from gNB  gnb_id=${gnb_id}  target_dir=${configDir}
    enb.Get SCF from eNB  enb_id=${enb_id}    resultDir=${configDir}

    attenuator_scenario.register all attenuators
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${gnb_id}  node_type=gnb
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${enb_id}  node_type=enb

    taf.ue.Require Ue  ${UE_ALIAS_1}  capabilities=${capabilities}

    #  Block all eNB LTE/4G cells as default
    IF  $BLOCK_ENB
        ${enb_alias}  Setup OAM http session  node_type=enb  node_id=${enb_id}
        admin.block_all_cells  rat=LTE  timeout=${20}  connection=${enb_alias}
        Log to Console  ALL LTE cells on eNB-${enb_id} are BLOCKED as default - unblock, in NSA case, is done in commissioning part
    END

    #  TC specific commissioning part
    IF  $WITH_TC_COMMISSIONING
        CB009267_Commissioning.Commissioning gNB  test_name=${TEST_NAME}
    END

    IF  $BLOCK_GNB_ADJACENT_CELLS
        CB009267_Commissioning.Block Adjacent Cells On GNB
        ...    gnb_id=${gnb_id}    adjacentCellsToBeBlocked=${ADJ_CELLS_GNB0}
    END


Start Necessary Traces
    [Arguments]  ${gnb_id}=0
    tcpdump.Start Tcpdump on gNB Common Unit
    ...    gnb_id=${gnb_id}
    ...    collector=tcpdump_gnb_${gnb_id}
    ...    options=-i any port 38472 or port 38412 or port 38422 or port 38462 or port 36422
    tcpdump.Start Tcpdump on TestPc  options=-i eth2 sctp  collector=tcpdump_testpc

Stop All Traces
    [Arguments]  ${gnb_id}=0   ${tcpdump_filename}=Xn_traces_gnb.pcap
    ${tcp_file_gnb}  tcpdump.Stop TCP Dump on gNB Common Unit
    ...  collector=tcpdump_gnb_${gnb_id}  tcpdump_filename=${tcpdump_filename}
    Set Test Variable  ${tcp_file_gnb${gnb_id}}  ${tcp_file_gnb}
    ${tcp_file}  tcpdump.Stop Tcpdump on TestPc  collector=tcpdump_testpc
    Set Test Variable  ${tcp_file}  ${tcp_file_gnb}


Revert gNB Delta Commissioning
    [Documentation]    Commissioning of gnb, create new updated SCF with delta changes.
    ...                Only one file is required for updating gnb with delta changes.
    [Arguments]        ${gnb_id}

    Log to Console  Start - Revert delta commissioning
    ${configDir}=    testline.Get Testcase Log Directory
    OperatingSystem.Create Directory  ${configDir}/revert_scf
    gnb.Store Current SCF from gNB  gnb_id=${gnb_id}  target_dir=${configDir}/revert_scf
    scf.Calculate Delta Scf
    ...    target_scf_path=${configDir}/SCFC_gNB${gnb_id}_DU.xml.orig
    ...    actual_scf_path=${configDir}/revert_scf/SCFC_gNB${gnb_id}_DU.xml
    ...    delta_scf_path=${configDir}/revert_scf/SCFC_gNB${gnb_id}_revert_${TC_NUMBER}.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${revert_scf_has_content}=  OperatingSystem.Get File  ${configDir}/revert_scf/SCFC_gNB${gnb_id}_revert_${TC_NUMBER}.xml

    IF   ${revert_scf_has_content} != []
        admin.Perform_Delta_Recommissioning
        ...    delta_file=${configDir}/revert_scf/SCFC_gNB${gnb_id}_revert_${TC_NUMBER}.xml
        ...    skip_parameter_relation_errors=${True}
        ...    connection=${oam_alias}
    END

    Run Keyword And Ignore Error  admin.unblock_all_cells  rat=NR  timeout=${20}  connection=${oam_alias}
    Log To Console  Stopp - Revert delta commissioning and UNBLOCK all 5G cells on gNB-${gnb_id}

Perform Postconditions of Test Scenario
    [Documentation]    used in Test Case [Teardown]
    ...   shutdown tshark - unblock all LTE cells - get UE NUC PC proxy logs
    ...   Put all attenuator ports to maximum value
    ...   revert the gNB delta commissioning to original SCF
    ...   check alarms
    [Arguments]     ${gnb_id}=0   ${enb_id}=0

    ute_tshark.teardown tshark

    ${enb_alias}  connect.Setup OAM http session  node_type=enb  node_id=${enb_id}
    Run Keyword And Ignore Error  admin.unblock_all_cells  rat=LTE  timeout=${10}  connection=${enb_alias}
    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    Run Keyword And Ignore Error  admin.unblock_all_cells  rat=NR  timeout=${10}  connection=${oam_alias}
    #  Save name of eNB and gNB load to file for reporting after test end
    syve_testline.Save current loads

    ${tc_log_directory}=  Get testcase log directory
    ${ue_pc_alias}=  Run Keyword And Ignore Error  connect.Connect to UE PC   ${ue_id}=${1}
    Run Keyword And Ignore Error  ssh.execute  mv /cygdrive/c/taf_ue_proxy/logs/proxy.log ${tc_log_directory}  connection=${ue_pc_alias}

    Log To Console    Put all attenuator ports to maximum value
    attenuator.Set Attenuator to Max Value

    #  TC specific revert delta commissioning part
    IF  $WITH_TC_COMMISSIONING
        Revert gNB Delta Commissioning  gnb_id=${gnb_id}
    END

    ${alarms_2}  alarm_handling.Get All Alarms From Node
    Set Suite Variable  ${alarmlist_2}  ${alarms_2}
    ${cleared_alarms}  ${active_alarms}  alarm.Check For New Alarms  ${alarmlist_1}  ${alarmlist_2}
    alarm_handling.Log Alarm List  ${cleared_alarms}
    alarm_handling.Log Alarm List  ${active_alarms}

Save all Logs and Teardown TL
    [Documentation]
    ...     in Test [Suite Teardown]
    ${suiteBaseDirectory}=  testline.Get test suite result base directory
    Log To Console    Initial SCF File Activation is set to ${INITIAL_SCF_FILE_ACTIVATION}
    IF   $INITIAL_SCF_FILE_ACTIVATION
        syve_testline.Testline Teardown for CCRT
        syve_testline.Load initial gnb scf for CCRT        ${gnb_id}
    END
    Run Keyword And Ignore Error  filter logs for all gNBs  btslogpath=${suiteBaseDirectory}

    bts_log_analysis.print filtered btslog in log file
