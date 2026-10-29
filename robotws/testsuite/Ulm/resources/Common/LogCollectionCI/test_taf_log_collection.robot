*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real AP TL.
...   It verifies proper function of KWs in taf_log_collection.robot.

Library        OperatingSystem
Library        tshark_helper.py
Library        generate_randon_test_execution.py
Library        determine_ue_ids.py

Resource       ../testline.robot
Resource       ../dcap.robot
Resource       ../ute_workarounds.robot
Resource       ../wts_ue.robot
Resource       ../connect.robot
Resource       ../reporting.robot

Suite Setup     Run Keywords
...                  Install and Import taf.ul.Log Collection   AND
...                  Bring Airphone To On Air Status

*** Test Cases ***
Test_Taf_Ul_LogCollection
    [Tags]    CIT    SBTS22R4    SBTS23R1    RAN_5G_FDD   CLOUD_5G_I_LO_AP_LO   CLOUD_5G_I_MP_AP_LO   CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH

    ${config_string}=    Catenate    {"SyslogLog"     : {"type": "syslog"},
    ...                               "BipLog"        : {"type": "bip"},
    ...                               "TTITrace"      : {"type": "uplane_trace",
    ...                                                  "components": "L2Ps,L2Lo"},
    ...                               "ProtocolLog1"  : {"type": "protocols",
    ...                                                  "interfaces": "f1c,e1c"},
    ...                               "ProtocolLog2"  : {"type": "protocols",
    ...                                                  "interfaces": "ngc,xnc,x2c"},
    ...                               "EmilLog"       : {"type": "emil"},
    ...                               "LongTimeLogs"  : {"type": "group",
    ...                                                  "members": "SyslogLog, EmilLog"},
    ...                               "RealTimeLogs"  : {"type": "group",
    ...                                                  "members": "BipLog, ProtocolLog1, ProtocolLog2, TTITrace"},
    ...                               "SnapshotLogs"  : {"type": "snapshot"},
    ...                               "PmCounterLogs" : {"type": "pmcounters"},
    ...                               "CollectOnly"   : {"type": "group",
    ...                                                  "members": "SnapshotLogs, PmCounterLogs"}}

    ${log_configuration}=    Evaluate   ${config_string}

    Set SCOUT TC ID For Reporting

    Create Collectors Using Testline Information    names=LongTimeLogs, RealTimeLogs, CollectOnly
    ...                                             configuration=${log_configuration}
    ...                                             network_elements=gnb_0

    ${target_dir}   testline.Get Testcase Log Directory

    taf.ul.log_collection.Setup Collectors    names=LongTimeLogs
    taf.ul.log_collection.Start Collectors    names=LongTimeLogs

    Log      Preprocessing Steps    console=True
    Sleep    5s    reason=Placeholder for Test Case Preprocessing


    taf.ul.log_collection.Setup Collectors    names=RealTimeLogs
    taf.ul.log_collection.Start Collectors    names=RealTimeLogs

    Test Action   ${20}

    taf.ul.log_collection.Stop Collectors      names=RealTimeLogs
    taf.ul.log_collection.Collect Collectors   names=RealTimeLogs    target_dir=${target_dir}
    taf.ul.log_collection.Teardown Collectors  names=RealTimeLogs

    Log      Postprocessing Steps    console=True
    Sleep    5s    reason=Placeholder for Test Case Postprocessing

    taf.ul.log_collection.Stop Collectors      names=LongTimeLogs
    taf.ul.log_collection.Collect Collectors   names=LongTimeLogs    target_dir=${target_dir}
    taf.ul.log_collection.Teardown Collectors  names=LongTimeLogs

    taf.ul.log_collection.Setup Collectors     names=CollectOnly
    taf.ul.log_collection.Collect Collectors   names=CollectOnly     target_dir=${target_dir}
    taf.ul.log_collection.Teardown Collectors  names=CollectOnly

    ${syslog_files}=   taf.ul.log_collection.Get Log File    log_type=syslog         target_dir=${target_dir}   network_element=gnb_0
    ${bip_files}=      taf.ul.log_collection.Get Log File    log_type=bip            target_dir=${target_dir}   network_element=gnb_0
    ${emil_logs}=      taf.ul.log_collection.Get Log File    log_type=Emil           target_dir=${target_dir}   network_element=gnb_0
    ${uplane_logs}=    taf.ul.log_collection.Get Log File    log_type=uplane_trace   target_dir=${target_dir}   network_element=gnb_0

    Test Syslog Files    syslog_files=${syslog_files}
    Test Bip Files       bip_files=${bip_files}
    Test Emil Logs       emil_logs=${emil_logs}
    Test Uplane Logs     uplane_logs=${uplane_logs}

*** Keywords ***
Test Action
    [Arguments]    ${num_of_operations}

    Log To Console    ${CURDIR}

    ${ue_ids}    Get All Ue IDs

    Create Random UE Operations Resource     filename=${CURDIR}/MyGeneratedUeResource.robot
    ...                                      ue_ids=${ue_ids}
    ...                                      operations=${num_of_operations}

    ${target_dir}      testline.Get Testcase Log Directory
    Copy File          ${CURDIR}/MyGeneratedUeResource.robot   ${target_dir}
    Import Resource    ${CURDIR}/MyGeneratedUeResource.robot

    Test Execution With Multiple UEs


Install And Import Taf.Ul.Log Collection
    [Documentation]    Install a taf.ul.log_collection if not already installed

    ${library_installed}    Run And Return RC     python -c "import taf.ul.log_collection"

    Log To Console    Library is installed: ${library_installed}

    # install the latest version available
    Run And Return RC    pip install -U taf.ul.log_collection
    Evaluate             importlib.reload(pkg_resources)    importlib, pkg_resources

    ${result}=    Run And Return RC    python -c "import taf.ul.log_collection"

    Log To Console    Library is installed: ${result}
    Import Library     taf.ul.log_collection


Test Syslog Files
    [Arguments]    ${syslog_files}

    Should Not Be Empty    ${syslog_files}    No Syslog Files have been collected!!

    FOR     ${syslog_file}    IN    @{syslog_files}
        Log     file is ${syslog_file}
        File Should Exist           ${syslog_file}
    END


Test Bip Files
    [Arguments]    ${bip_files}

    Should Not Be Empty    ${bip_files}       No BIP Trace files have been collected!!

    FOR     ${pcap_file}    IN    @{bip_files}
        Log     file is ${pcap_file}
        File Should Exist           ${pcap_file}
        File Should Not Be Empty    ${pcap_file}
        ${message_count}=   tshark_helper.Get Pcap Message Count    ${pcap_file}
        Should Be True    ${message_count}>0

        ${uldata_prachreceivereq_count}=    tshark_helper.Get UlData PrachReceiveReq Message Count   ${pcap_file}
        IF     ${uldata_prachreceivereq_count}==0    Log    No valid dissector for bip trace available!    level=WARN   console=True
    END

Test Emil Logs
    [Arguments]   ${emil_logs}

    Should Not Be Empty   ${emil_logs}      No EMIL Logs have been collected!!

    FOR     ${emil_log}    IN    @{emil_logs}
        Log     file is ${emil_log}
        File Should Exist           ${emil_log}
        File Should Not Be Empty    ${emil_log}
    END

Test Uplane Logs
    [Arguments]   ${uplane_logs}

    Should Not Be Empty     ${uplane_logs}

    FOR    ${logfile}    IN   @{uplane_logs}
        File Should Exist           ${logfile}
        File Should Not Be Empty    ${logfile}

        ${capinfo_result}=    Run   LC_ALL=C capinfos -Mc "${logfile}"
        ${_}   ${_}   ${packet_count}    Split String   ${capinfo_result}   separator=:
        ${packet_count}=    Convert To Integer    ${packet_count}
        IF    ${packet_count} == 0    Log    There was no tti trace packet recorded!   WARN
    END

Bring Airphone To On Air Status
    ${dcap_alias}   connect.Connect To Test Pc Proxy For Node   node_id=0   node_type=gnb
    Check For Needed Hotfix Installations    ${dcap_alias}

    UTE Cloud Workaround

    ${connected}=   Connect To Running Egate   ap_egate
    IF   ${connected}   RETURN
    ${wts_status}=    Run Keyword And Return Status    Bring Airphone TL To On Air Status Without Reboot
    IF    ${wts_status} == False             Bring Airphone TL To On Air Status

