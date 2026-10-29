*** Settings ***

Documentation
...
...     INTRODUCTION:  Verification of ANR XMesh Functionality
...
...     TEST SET NAME: ANR XMESH
...
...     TESTING SCOPE: CB007228 “Automatic Xn Mesh connectivity with Ipsec”
...                    CB007016 “Automatic X2 Mesh connectivity with IPSec in NSA Mode”
...
...     CONTACTS:      VRF_ULM_T01_02
...
...     REFERENCES:
...
...     HISTORY:
...                [09.01.2026] - Initial version with internal review

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library     Process
Library     OperatingSystem

Resource    ../../../../Ulm/resources/Common/ute_workarounds.robot
Resource    ../../../../Ulm/resources/Common/wts_ue.robot
Resource    ../../../../Ulm/resources/Common/gnb.robot
Resource    ../../../../Ulm/resources/Common/alarm_handling.robot
Library     ../../../../Ulm/resources/Common/python/alarm_handling.py      WITH NAME   alarm_py

Resource    ../../CSV/resources/commonKeywords.robot
Resource    ../../CSV/resources/tracing_keywords.robot
Resource    ../../CSV/resources/hybrid_testline.robot

Library     ../../CSV/libraries/common_tools.py

Resource    ANR_XMESH_Keywords.robot
Library     ANR_XMESH_verification.py

Variables   qc_mapping.yaml



Suite Setup     commonKeywords.Save Configs And Prepare For Testing And Logging
Suite Teardown  commonKeywords.Repare For Next Testing If Needed



*** Variables ***

${ETHERNET_IF_FOR_WTS}            eth4       # [INFO] 10.0.1.x   VM <-> gNB  (10.0.1.2 and 10.0.1.3)
${ETHERNET_IF_FOR_AP}             eth5       # [INFO] 10.0.2.x   VM <-> AP (10.0.2.80)

${WITH_PM_COUNTERS}               ${TRUE}    # [INFO] ${TRUE} or ${FALSE}
${PM_REPORTING_INTERVAL}          5min
${WITH_ALARMS}                    ${TRUE}    # [INFO] ${TRUE} or ${FALSE}
${WITH_SYSLOGS}                   ${TRUE}    # [INFO] ${TRUE} or ${FALSE}
${WITH_WTS_LOGS}                  ${TRUE}    # [INFO] ${TRUE} or ${FALSE}
${WITH_REPORTING}                 ${TRUE}    # [INFO] ${TRUE} or ${FALSE}

${QC_DOMAIN}                      MN_RAN
${RP_CA}                          VRF_RRM
${RP_ORGANIZATION}                VRF_ULM_T01
${RP_LOCATION}                    VRF_ULM



*** Test Cases ***

TC02_ANR_XMESH_Verification_of_Xn_tunnel_establishment_and_deletion_with_same_IPSEC_template
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION: This test case verifies the successful operation of Automatic Neighbor Relation (ANR) functionality between gNBs
    ...               in an Xn mesh topology, where all Xn interfaces are secured using IPSEC.
    ...               The primary objective is to confirm that ANR can correctly discover, add, and remove neighbor relations,
    ...               and that control plane over these ANR-managed Xn interfaces remains functional via IPSEC tunnels.
    ...  PRECONDITION:
    ...    - IPSEC is enabled
    ...    - IPSECC/xnTunnelAutoRemovalEnabled is true
    ...    - IPsec template (i.e. TNLSVC/IPSECTEMPLATE) for Xn IPsec tunnel is configured
    ...    - Sufficient IPsec resources available
    ...    - new Xn IPsec tunnels towards neighbor gNB do not exist already (manually configured)
    ...    - IPsec template conatins matching encryption and Authentication algorithm for IKE and ESP at source and neighbour gNB
    ...
    ...  TEST STEPS:
    ...    Step 1:
    ...       Description: register 50 SA UEs
    ...       Expected: all the UEs are successfully registered
    ...    Step 2:
    ...       Description: initiate Inter-gNB HO of each UE on a different neighbor gNB
    ...       Expected: all 50 neighbor gNBs are detected as ANR condidate
    ...
    ...  POSTCONDITION:
    ...    - No critical alarms or errors related to ANR or IPSEC are present in the system
    ...
    ...  TESTING TOOLS:
    ...    - SecGW
    ...
    ...  TEST ENVIRONMENT:
    ...      HARDWARE ID: gNB, Airphone, WTS 5G Core Simulator
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: TT_TTSEC.2361
    ...
    ...  REQUIRED LOGS:  Syslogs, PM Counters
    ...
    ...  CONTACTS:      Nikolay Shkulepov (Nokia) <nikolay.shkulepov@nokia.com>
    ...
    ...  REFERENCES:    CFAM CB007228: https://systeminsights.ext.net.nokia.com/speclens/view/00026127
    ...
    ...  HISTORY:       [09.01.2026] - Created TC
    ...                 [19.01.2026] - Internal review
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Tags]  ANR_XMESH  TC02
    [Setup]    Run Keywords
    ...            Save More Files In Configuration Directory                                                           AND
    ...            hybrid_testline.Modify IPHY XML For NEW SW Build                                                     AND
    ...            hybrid_testline.Bring Hybrid AP TL To onAir    basic_setup_cfg=basic_setup_ANR_XN_MESH.cfg           AND
    ...            Run In EGATE    TC02 START
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    IF    ${WITH_ALARMS}
        ${alarms_before_testrun}    Run Keyword And Continue On Failure    alarm_handling.Get All Alarms from Node
    END
    Run Keyword And Continue On Failure    Process.Run Process   sudo ipsec start   shell=True
    ${cell_on_gnb}    common_tools.Get_First_Cell_Id_For_External_Gnb    /opt/wts/latest/basic_setup.cfg
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    commonKeywords.Start Logging
        Run Keyword And Continue On Failure    ANR_XMESH_Keywords.Add IPs For Simulated gNBs If Needed
        Run Keyword And Continue On Failure    ANR_XMESH_Keywords.Update Basic Configuration File
        Save ANR XMESH Files and Sleep    1s    test_phase=before
            Log To Console    ${\n}INFO: Test Scenario Started${\n}
            Run In EGATE    enb_x2_link_up enb=1 target=2    sleep=1s
            ${list_of_ues}    Evaluate    list(range(1, 51))
            FOR    ${ue}    IN    @{list_of_ues}
                TRY
                    wts_ue.Send Egate Command And Verify Output    cmd=ue_register id=${ue} nwslice=1
                    ...                                            pass_regexp=UE${ue}: UE performed Registration
                    ...                                            fail_regexp=UE${ue}: T300 expiration
                    ...                                            timeout=10s
                    Log To Console    INFO: UE performed Registration - ${ue} - OK
                EXCEPT
                    Log To Console    INFO: UE performed Registration - ${ue} - NOK
                END
            END
            Run In EGATE    set_pdu_param ue=1-50 pdu=2 trf_type=internal log_traffic_stats=off
            FOR    ${ue}    IN    @{list_of_ues}
                TRY
                    wts_ue.Send Egate Command And Verify Output    cmd=ue_pdu_session_setup pdu=2 ue=${ue} nwslice=1 gw=1
                    ...                                            pass_regexp=UE${ue}: Established PDU session
                    ...                                            timeout=3s
                    Run In EGATE    trf_data_start ue=${ue} pdu=2 dir=dl kbps=10    sleep=100ms
                    Run In EGATE    trf_data_start ue=${ue} pdu=2 dir=dl kbps=10    sleep=100ms
                    Log To Console    INFO: Established PDU session - ${ue} - OK
                EXCEPT
                    Log To Console    INFO: Established PDU session - ${ue} - NOK
                END
            END
            ${list_of_cells}    Evaluate    list(range(30, 80))
            FOR    ${ue}    ${cell}    IN ZIP    ${list_of_ues}    ${list_of_cells}
                ${cmd1}    Set Variable    ue_measurement_send_nr id=${ue} meas_id=2 index=0 nrs_result=60:30:0 event=A5
                ${cmd2}    Set Variable    srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0 phycell_id=${cell} nrsrp_nr=60 nrsrq_nr=30 rs_type=ssb
                Run In EGATE    ${cmd1} ${cmd2}    sleep=800ms
                Log To Console    INFO: UE Measurement send - ${ue}
            END
            Sleep    90s
            Run In EGATE    ue_disp
            Run In EGATE    ue_deregister id=1-50 ue_deregister_type=switch_off
            Run In EGATE    ue_change_location id=1-50 enb=2 cell=${cell_on_gnb}
            Log To Console    ${\n}INFO: Test Scenario Finished${\n}
        Save ANR XMESH Files and Sleep    1s    test_phase=during
        Sleep    10s
        Save ANR XMESH Files and Sleep    1s    test_phase=after
        Run Keyword And Continue On Failure    Process.Run Process   sudo ipsec stop   shell=True
    commonKeywords.Stop Logging and Collect Traces
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    IF    not ${WITH_PM_COUNTERS}    Sleep    200      # time to remove IPsec MOs!!!
    IF    ${WITH_ALARMS}
        ${alarms_after_testrun}    Run Keyword And Continue On Failure    alarm_handling.Get All Alarms from Node
        Sleep    3s
    END
    Log To Console    ${\n}INFO: Test Verification Started${\n}
    Prepare Variables for Verification
        Run Keyword And Continue On Failure    ANR_XMESH_verification.Check_SCF_Files    test_scope=XN
        IF    ${WITH_PM_COUNTERS}
        ...    Run Keyword And Continue On Failure    ANR_XMESH_verification.Check_PM_Counters    test_scope=XN    number_of_measurementperiods=3
        Run Keyword And Continue On Failure    ANR_XMESH_verification.Check_IPSEC_Status    test_scope=XN
        Run Keyword And Continue On Failure    ANR_XMESH_verification.check_Resources
        Run Keyword And Continue On Failure    ANR_XMESH_verification.check_Backhaul_traces    test_scope=XN
        IF    ${WITH_SYSLOGS}    Run Keyword And Continue On Failure    ANR_XMESH_verification.Check_SYSLOGs
        IF    ${WITH_ALARMS}
            ${cleared_alarms}  ${active_alarms}    Run Keyword And Continue On Failure    alarm_py.Check For New Alarms    ${alarms_before_testrun}
            ...                                                                                                            ${alarms_after_testrun}
            ...                                                                                                            console_log=${P_console}
        END
    Log To Console    ${\n}INFO: Test Verification Finished${\n}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Teardown]    Run Keywords
    ...    Run In EGATE    TC02 STOP    AND
    ...    Perform Reporting to ReP If Needed


TC03_ANR_XMESH_Verification_of_X2_tunnel_establishment_and_deletion_with_same_IPSEC_template_NSA
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION: This test case verifies the automatic addition and establishment of an X2 IPsec tunnel for the X2 link between a source eNB
    ...               and a neighbor gNB in Non-Standalone (NSA) mode. The process is initiated after the neighbor gNB is detected as
    ...               an ANR candidate and the ANR procedure for EN-DC (E-UTRA-NR Dual Connectivity) is successfully completed.
    ...               The primary objective is to ensure that the X2 IPsec tunnel is established enabling SCTP link over IPsec tunnel.
    ...  PRECONDITION:
    ...    - IPSEC is enabled
    ...    - IPsec template (i.e. TNLSVC/IPSECTEMPLATE) for Xn IPsec tunnel is configured
    ...    - eNBs are not configured as neighbor on neighbor gNB
    ...    - Sufficient IPsec resources available on gNB (IPsec resource status allows to add another IPsec policy)
    ...
    ...  TEST STEPS:
    ...    Step 1:
    ...       Description: trigger ANR procedure from a simulated eNBs (200 eNBs)
    ...       Expected: all eNBs successfully configured
    ...
    ...  POSTCONDITION:
    ...    - No critical alarms or errors related to ANR or IPSEC are present in the system
    ...
    ...  TESTING TOOLS:
    ...    - SecGW
    ...
    ...  TEST ENVIRONMENT:
    ...      HARDWARE ID: gNB, Airphone, WTS 5G Core Simulator
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: TT_TTSEC.2270
    ...
    ...  REQUIRED LOGS:  Syslogs, PM Counters
    ...
    ...  CONTACTS:      Nikolay Shkulepov (Nokia) <nikolay.shkulepov@nokia.com>
    ...
    ...  REFERENCES:    CFAM CB007016: https://systeminsights.ext.net.nokia.com/speclens/view/00025be4
    ...
    ...  HISTORY:       [09.01.2026] - Created TC
    ...                 [19.01.2026] - Internal review
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Tags]  ANR_XMESH  TC03
    [Setup]    Run Keywords
    ...            Save More Files In Configuration Directory                                                           AND
    ...            hybrid_testline.Modify IPHY XML For NEW SW Build                                                     AND
    ...            hybrid_testline.Bring Hybrid AP TL To onAir     basic_setup_cfg=basic_setup_ANR_X2NSA_MESH.cfg       AND
    ...            Run In EGATE    TC03 START
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    IF    ${WITH_ALARMS}
        ${alarms_before_testrun}    Run Keyword And Continue On Failure    alarm_handling.Get All Alarms from Node
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Run Keyword And Continue On Failure    Process.Run Process   sudo ipsec start   shell=True
    commonKeywords.Start Logging
        Run Keyword And Continue On Failure    ANR_XMESH_Keywords.Add IPs For Simulated gNBs If Needed
        Run Keyword And Continue On Failure    ANR_XMESH_Keywords.Update Basic Configuration File
        Save ANR XMESH Files and Sleep    1s    test_phase=before
            Log To Console    ${\n}INFO: Test Scenario Started${\n}
            ${list_of_enbs}    Evaluate    list(range(3, 203))
            Sleep  100ms
            Run In EGATE    enb_x2_link_up enb=1 target=2    sleep=500ms
            Run In EGATE    enb_conf_update enb=1 mme=1 connected_en_gnb_to_add=2     sleep=100ms
            Sleep  100ms
            FOR    ${enb}    IN    @{list_of_enbs}
                Run In EGATE    enb_conf_transfer id=${enb} mme=1 tgt_gnb_id=2     sleep=1800ms
                Log To Console    INFO: eNB Conf Transfer - ${enb}
            END
            Sleep  1s
            Run Keyword And Continue On Failure    Process.Run Process   sudo ipsec restart   shell=True
            Sleep  1s
            FOR    ${enb}    IN    @{list_of_enbs}
                Run In EGATE    enb_x2_link_up enb=${enb} target=2    sleep=300ms
                Log To Console    INFO: eNB X2 Link UP - ${enb}
            END
            Sleep  1s
            Run In EGATE    link_x2_reset from=1 to=2     sleep=100ms
            FOR    ${enb}    IN    @{list_of_enbs}
                Run In EGATE    link_x2_reset from=${enb} to=2     sleep=100ms
                Log To Console    INFO: eNB X2 Link RESET - ${enb}
            END
            Sleep  100s
            Log To Console    ${\n}INFO: Test Scenario Fnished${\n}
        Save ANR XMESH Files and Sleep    1s    test_phase=during
        Log to console    Start WAIT for 60s
        Sleep    1s   # <--- 50s
        Save ANR XMESH Files and Sleep    1s    test_phase=after
    Run Keyword And Continue On Failure    Process.Run Process   sudo ipsec stop   shell=True    # <--- not all X2 connections dropped after RESET
    commonKeywords.Stop Logging and Collect Traces
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    IF    ${WITH_ALARMS}
        ${alarms_after_testrun}    Run Keyword And Continue On Failure    alarm_handling.Get All Alarms from Node
        Sleep    3s
    END
    Log To Console    ${\n}INFO: Test Verification Started${\n}
    Prepare Variables for Verification
        Run Keyword And Continue On Failure    ANR_XMESH_verification.Check_SCF_Files    test_scope=X2NSA
        IF    ${WITH_PM_COUNTERS}
        ...    Run Keyword And Continue On Failure    ANR_XMESH_verification.Check_PM_Counters    test_scope=X2NSA    number_of_measurementperiods=2
        Run Keyword And Continue On Failure    ANR_XMESH_verification.Check_IPSEC_Status    test_scope=X2NSA
        Run Keyword And Ignore Error           ANR_XMESH_verification.check_Resources
        Run Keyword And Continue On Failure    ANR_XMESH_verification.check_Backhaul_traces    test_scope=X2NSA
        IF    ${WITH_SYSLOGS}    Run Keyword And Continue On Failure    ANR_XMESH_verification.Check_SYSLOGs
        IF    ${WITH_ALARMS}
            ${cleared_alarms}  ${active_alarms}    Run Keyword And Continue On Failure    alarm_py.Check For New Alarms    ${alarms_before_testrun}
            ...                                                                                                            ${alarms_after_testrun}
            ...                                                                                                            console_log=${P_console}
        END
    Log To Console    ${\n}INFO: Test Verification Finished${\n}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Teardown]    Run Keywords
    ...    Run In EGATE    TC03 STOP    AND
    ...    Perform Reporting to ReP If Needed



*** Keywords ***

TC03_ANR_XMESH_Verification_of_X2_tunnel_establishment_and_deletion_with_same_IPSEC_template_NSA
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    ${result_base_dir}    Set Variable    /mnt/etfiles/users/Nikolay/robotws/ANR_XMESH_AP/SBTS00_ENB_9999_251029_000007/20251030_135840/
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    Prepare Variables for Verification
        Run Keyword And Continue On Failure    ANR_XMESH_verification.Check_SCF_Files    test_scope=X2NSA
        Run Keyword And Continue On Failure    ANR_XMESH_verification.Check_PM_Counters    test_scope=X2NSA    number_of_measurementperiods=2
        Run Keyword And Continue On Failure    ANR_XMESH_verification.Check_IPSEC_Status    test_scope=X2NSA
        Run Keyword And Continue On Failure    ANR_XMESH_verification.check_Backhaul_traces    test_scope=X2NSA
        Run Keyword And Continue On Failure    ANR_XMESH_verification.check_Resources
        Run Keyword And Continue On Failure    ANR_XMESH_verification.Check_SYSLOGs
        Run Keyword And Continue On Failure    ANR_XMESH_verification.Check_S1X2_Traces
        Run Keyword And Continue On Failure    ANR_XMESH_verification.Check_TTITraces


Perform Reporting to ReP If Needed
    IF    ${WITH_REPORTING} and '${TEST STATUS}' == 'PASS'    commonKeywords.CSV Online Reporting To ReP


Prepare Variables for Verification
    Set Test Variable    ${path_to_ttitrace_json}    ${ts_log_dir}/tti_trace_${TEST_NAME}/ttitrace_streaming.json
    Set Test Variable    ${path_to_ttitrace_pkl}     ${ts_log_dir}/tti_trace_${TEST_NAME}/ttitrace_streaming_dlharq.pkl
    Set Test Variable    ${path_to_syscom_pdml}      ${ts_log_dir}/syscom_${TEST_NAME}/l2_l3_tcpdump.pdml
    Set Test Variable    ${path_to_backhaul_tabs}    ${ts_log_dir}/s1x2_${TEST_NAME}/backhaul.tabs
    Set Test Variable    ${path_to_scf_xml}          ${configuration_directory}/scf_${TEST_NAME}.xml
    Set Test Variable    ${path_to_syslog_tgz}       ${ts_log_dir}/btslog_${TEST_NAME}/btslog_gnb0/syslog_files.tgz
    Set Test Variable    ${pm_counters_dir}          ${ts_log_dir}/pmc_${TEST_NAME}/gnb_pm_counters/
    Set Test Variable    ${resource_stats_dir}       ${ts_log_dir}/resource_stats_${TEST_NAME}


Run In EGATE
    [Arguments]  ${cmd}  ${sleep}=3s
    Run Keyword And Continue On Failure    wts_ue.Send Egate Command And Verify Output    cmd=${cmd}
    Sleep    ${sleep}


Sleep And Log To Console In Seconds
    [Arguments]  ${seconds}
    Log to console    ${\n}INFO: === SLEEP for ${seconds} STARTED ===
    ${total_seconds}    Convert To Number    ${seconds}
    ${interval}    Set Variable    10
    ${full_intervals}    Evaluate    int(${total_seconds} // ${interval})
    ${remainder}=    Evaluate    ${total_seconds} - (${full_intervals} * ${interval})
    FOR    ${i}    IN RANGE    ${full_intervals}
        Sleep    ${interval}
        Log To Console    ---> ${interval}s over
    END
    IF    ${remainder} > 0    Sleep    ${remainder}
    Log to console    ${\n}INFO: === SLEEP for ${seconds} STOPPED ===


Save ANR XMESH Files and Sleep
    [Arguments]  ${seconds}  ${test_phase}=${EMPTY}  ${postfix}=${EMPTY}
    Log to Console    Save ANR XMESH Files and Sleep for ${seconds} - ${test_phase} - ${postfix}
    ${test_phase}    Set Variable If    '${test_phase}'!='${EMPTY}'    ${test_phase}_    ${EMPTY}
    ${postfix}    Set Variable If    '${postfix}'!='${EMPTY}'    _${postfix}    ${EMPTY}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Run Keyword And Continue On Failure
    ...    gnb.Get SCF From gNB    target_dir=${ts_log_dir}    scf_name=SCFC_${test_phase}ANR_XMESH${postfix}.xml
    Run Keyword And Continue On Failure
    ...    gnb.Get SCF From gNB    target_dir=${ts_log_dir}    scf_name=SCFC_${test_phase}ANR_XMESH${postfix}_runtime.xml  export_type=runtimeObjects
    Run Keyword And Continue On Failure
    ...    Process.Run Process    sudo ipsec status    shell=True    stdout=${ts_log_dir}/IPSEC_${test_phase}ANR_XMESH${postfix}.txt
    Run Keyword And Continue On Failure
    ...    Process.Run Process    sudo ipsec statusall    shell=True    stdout=${ts_log_dir}/IPSEC_ALL_${test_phase}ANR_XMESH${postfix}.txt
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Sleep    ${seconds}


Save More Files in Configuration Directory
    Log To Console    ${\n}INFO: Save More Files in Configuration Directory
    Run Keyword And Continue On Failure    OperatingSystem.Copy File    /etc/ipsec.conf                    ${configuration_directory}
    Run Keyword And Continue On Failure    OperatingSystem.Copy File    ${SUITE SOURCE}                    ${configuration_directory}
    Run Keyword And Continue On Failure    OperatingSystem.Copy Files   /opt/wts/latest/basic_setup*cfg    ${configuration_directory}
