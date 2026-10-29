*** Settings ***

Documentation
...   author: Rubina Nath
...   contact: rubina.nath@nokia.com
...   Description: Bug Hunting Script

Library     SSHLibrary
Library     BuiltIn
Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem     WITH NAME    os
Library     taf.nms.netact    WITH NAME    netact
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     taf.collectors.core   WITH NAME   core
Library     taf.collectors.btslog  WITH NAME   btslog
Library     testsuite/Bangalore/ORAN/T02/resources/python/snapshotFileIdentifier.py
Suite Setup		   		Suite_Setup
Test Setup	       	    Test Setup
Test Teardown           Test_Teardown
Suite Teardown		    Suite Teardown
Resource                testsuite/Bangalore/ORAN/T02/resources/robot/OperationKeywords.robot

*** Variables ***

${BTS_ADDRESS} =           192.168.255.129
${BTS_path}=               /home/ute/logs
${loopNumberOfTimes}=      5
${MRBTSid}=               MRBTS-111111
${RMODid1}=               ${MRBTSid}/EQM-1/APEQM-1/RMOD-1
${RMODid2}=               ${MRBTSid}/EQM-1/APEQM-1/RMOD-2
${RMODid3}=               ${MRBTSid}/EQM-1/APEQM-1/RMOD-3
${RMODidruntime1}=               /${MRBTSid}/EQM_R-1/APEQM_R-1/RMOD_R-1
${RMODidruntime2}=               /${MRBTSid}/EQM_R-1/APEQM_R-1/RMOD_R-2
${RMODidruntime3}=               /${MRBTSid}/EQM_R-1/APEQM_R-1/RMOD_R-3
${servedAMFDistname}=      ${MRBTSid}/NRBTS-7084/SERVEDAMF-1
${BBMODd1distname}=        ${MRBTSid}/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1
${BBMODd2distname}=        ${MRBTSid}/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-2
${BBMODd3distname}=        ${MRBTSid}/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-3
${BBMODd4distname}=        ${MRBTSid}/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-4
${BBMODd5distname}=        ${MRBTSid}/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-5
${BBMODd6distname}=        ${MRBTSid}/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-6
@{list_of_expFaults}=      4655    4654    61649    61524
${tsn_port_details}=            1/4/C17
${tsn_login_IP}=                10.53.188.169
${tsn_login_name}=              cli123
${tsn_username}=                admin123
${tsn_password}=                Admin@1830

*** Test Cases ***

SiteResetTest
    [Documentation]    Robustness
    [Tags]    test

    FOR    ${count}    IN RANGE    1    ${loopNumberOfTimes}
        Set Global Variable    ${count}
        Log to Console    ----Iteration ${count}\n----
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${count}
        Start BTS logs
        Reset Site
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
		ResetAllBBmod
        Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
        Run Keyword and Continue On Failure    Check ActiveFaultandAlarmID    @{list_of_expFaults}
        Stop BTS logs    btslog_target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${count}
        IF    "${count}" == "1"
            Collect Snapshot    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${count}/SnapshotFileIteration${count}.zip
            collect_im_snapshot        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${count}/imSnapshotIteration${count}.ims2
            collect_raw_alarm_history_file        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${count}/alarmSnapshotIteration${count}.json
            collect_scf        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${count}/scfIteration${count}.xml
        END
        Run Keyword If    "${count}" != "1"    Remove Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${count}    recursive
    END

SimulationOfFID10_via_TSNswitch_ConfigPortStateToggling
    [Documentation]    Robustness
    [Tags]    test

	SSHLibrary.Open Connection    host=${tsn_login_IP}
    SSHLibrary.Login    ${tsn_login_name}   delay=2
    SSHLibrary.Write    ${tsn_username}
    SSHLibrary.read     delay=2s
    SSHLibrary.Write    ${tsn_password}
    SSHLibrary.read     delay=2s
    SSHLibrary.Write    Y
    SSHLibrary.read     delay=2s
	Start BTS logs
    FOR    ${count}    IN RANGE    1    ${loopNumberOfTimes}
        SSHLibrary.Write    config interface t24ps2 ${tsn_port_details} state down
        SSHLibrary.read     delay=1s
        SSHLibrary.Write    config interface t24ps2 ${tsn_port_details} state up
        SSHLibrary.read     delay=2s
    END
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    Run Keyword and Continue On Failure    Check ActiveFaultandAlarmID    @{list_of_expFaults}
    Stop BTS logs    btslog_target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
	SSHLibrary.Close All Connections
