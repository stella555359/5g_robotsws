*** Settings ***
Documentation
...    Author: mateusz.kowalczyk@nokia.com
...    Maintainer: mateusz.kowalczyk@nokia.com; adam.superczynski@nokia.com; marek.lenartowicz@nokia.com;
...    jakub.pawlowski@nokia.com
...    Test Description: Troubleshooting logs keywords
...    Confluence link: link
...    Group in charge: I_MN_RAN_BOAM_PZ_OM_ET_1_GMS <I_MN_RAN_BOAM_PZ_OM_ET_1@internal.nsn.com>
...    References: -
...    QualityCenter: tds://ran_et.mn_ran.qc-prod.ext.net.nokia.com/qcbin/TestLabModule-000000003649890581?EntityType=ITestSet&EntityID=22375
...    Sample execution:-
...    AC/REQ:-

*** Keywords ***

Edit Flags For Netconf Traces
    [Arguments]    ${old_value_750000}=1
    ...            ${new_value_750000}=0
    ...            ${old_value_750002}=10000000
    ...            ${new_value_750002}=0
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write    sed -i 's;0x750000=${old_value_750000};0x750000=${new_value_750000};g' /ffs/run/swconfig.txt
    SSHLibrary.Read Until    root@
    SSHLibrary.Write    sed -i 's;0x750002=${old_value_750002};0x750002=${new_value_750002};g' /ffs/run/swconfig.txt
    SSHLibrary.Read Until    root@

Assert Password Is Not Visible In Netconf Traces
    ${status}    Check Message In Netconf Trace File    xran-password
    Should Not Contain    ${status}    xran-password

Assert Netconf Traces Are Not In Snapshot
    Run    unzip ${OUTPUT_DIR}/${TEST_NAME}/Snapshot.zip -d ${OUTPUT_DIR}/${TEST_NAME}/Snapshot
    ${snapshot_file_list}    Run     cat ${OUTPUT_DIR}/${TEST_NAME}/Snapshot/snapshot_file_list.txt | grep Netconf
    Should Not Contain
    ...    ${snapshot_file_list}
    ...    RMOD_L-1_NetconfRpcMessageTrace.log.xz
    Run    rm -R ${OUTPUT_DIR}/${TEST_NAME}/Snapshot

Assert Netconf Traces Are In Snapshot
    Run    unzip ${OUTPUT_DIR}/${TEST_NAME}/Snapshot.zip -d ${OUTPUT_DIR}/${TEST_NAME}/Snapshot
    ${snapshot_file_list}    Run    cat ${OUTPUT_DIR}/${TEST_NAME}/Snapshot/snapshot_file_list.txt | grep Netconf
    Should Contain
    ...    ${snapshot_file_list}
    ...    RMOD_L-1_NetconfRpcMessageTrace.log.xz
    Run    rm -R ${OUTPUT_DIR}/${TEST_NAME}/Snapshot

Check If Oru Replies With Rpc Reply For Troubleshooting Start
	${message}		Check Message In Logs On Oru    "/o-ran-troubleshooting:start-troubleshooting-logs" RECEIVED
	Should Contain		${message}		 "/o-ran-troubleshooting:start-troubleshooting-logs" RECEIVED
    ${start_troubleshooting}    Check Message Id In Oru    <start-troubleshooting-logs
    ${rpc_reply_status}    Check Message In Logs On Oru    ${start_troubleshooting}
    Should Contain    ${rpc_reply_status}    SUCCESS</status></rpc-reply>

Check If The Logs Contain Message For All Troubleshooting Files
    [Arguments]    ${message}
    ${troubleshooting_log_generated}    Check Message In Logs On Oru    ${message}
    FOR    ${item}    IN    @{ORU_LOGS_FILES}
        Should Contain    ${troubleshooting_log_generated}
        ...    ${item}
    END
    FOR    ${item}    IN    @{TROUBLESHOOTING_FILES}
        Should Contain     ${troubleshooting_log_generated}
        ...    ${item}
    END

Assert 1806 After Snapshot Collection
    ${alarms}    ADMIN Get Historical Warning Alarms
    ${string}    Convert To String    ${alarms}
    should contain    ${string}    'Radio autonomous reset as recovery action'
    should contain    ${string}    'faultId': 1806

Check If Snapshot Contain Rmod Logs
    Run    unzip ${OUTPUT_DIR}/${TEST_NAME}/Snapshot.zip -d ${OUTPUT_DIR}/${TEST_NAME}/Snapshot
    ${snapshot_content}    Run    unzip -l ${OUTPUT_DIR}/${TEST_NAME}/Snapshot/BTS_part1.zip
    ${status_snapshot_content}    Run Keyword And Return Status    Should Contain
    ...    ${snapshot_content}
    ...    BTS_00002490_RMOD_L_1_
    Run    rm -R ${OUTPUT_DIR}/${TEST_NAME}/Snapshot
    [Return]    ${status_snapshot_content}

Assert Rmod Logs Are In The Snapshot
    ${status}    Check If Snapshot Contain Rmod Logs
    Should Be Equal As Strings    ${status}    True

Assert Rmod Logs Are Not In The Snapshot
    ${status}    Check If Snapshot Contain Rmod Logs
    Should Be Equal As Strings    ${status}    False

Cancel Snapshot Collection
    taf.sbts.oam.coam.admin.Snapshot Cancel
    ...                           timeout=300
    ...                           alias=admin_1

Assert The Logs File Has Been Uploaded To Gnb
    Wait Until Keyword Succeeds    200
    ...                            5
    ...                            Check Logs From Oru In Gnb

Check Logs From Oru In Gnb
    SYSTEM Open SSH Connection To Enb
    ${logs_files_status}=    SSHLibrary.Execute Command    ls /ram | grep BTS | grep RMOD
    Should Contain    ${logs_files_status}    RMOD_L_1_data_
    [Teardown]    SYSTEM Close SSH Connection To Enb

Check If The Logs File Has Been Removed From Gnb
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write    ls /ram | grep BTS | grep RMOD
    ${logs_files_status}    SSHLibrary.Read Until    root@
    Should Not Contain    ${logs_files_status}    RMOD_L_1_data_
    [Teardown]    SYSTEM Close SSH Connection To Enb

Configure Invalid Parameter For The Sftp Server
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write    sed -i 's;AllowUsers sftp*;AllowUsers tftp*;g' /ram/node_FHNET00/tmp/ssh/sshd_config_oran
    SSHLibrary.Read Until    root@
    SSHLibrary.Write    ps aux | grep sshd_config_oran | grep -v grep | cut -c 9-17 | xargs kill -9
    SSHLibrary.Read Until    root@
    [Teardown]    SYSTEM Close SSH Connection To Enb

Check If Oru Has Tried To Upload Each File Three Times
    FOR    ${item}    IN    @{ORU_LOGS_FILES}
        ${oru_logs_upload}    Check Message In Logs On Oru
        ...    ${item}</local-logical-file-path><remote-file-path>
        Should Contain X Times     ${oru_logs_upload}
        ...    <status>FAILURE</status><reject-reason>File could not be uploaded. Operation returned
        ...    3
    END
    FOR    ${item}    IN    @{TROUBLESHOOTING_FILES}
        ${troubleshooting_logs_upload}    Check Message In Logs On Oru
        ...    <local-logical-file-path>/O-RAN/log/${item}
        Should Contain X Times     ${troubleshooting_logs_upload}
        ...    <status>FAILURE</status><reject-reason>File could not be uploaded. Operation returned
        ...    3
    END
