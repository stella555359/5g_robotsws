*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Recover Env
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    CRT    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-DevHZ5_SG2    owner-baijie.zhu    release-5G19B
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***

*** Test Cases ***
5GC001178-ET-A002 Verify common UE bulk release is triggered by CUCP initiated E1 Reset
    [Documentation]
    ...    [Purpose]: The purpose of this test case is to check: common UE bulk release is triggered by CU-CP initialed
    ...    E1 Reset for TDD or FDD SA.
    ...    [Configuration]: 1 classical cmWave gNB, 1 Airphone, 1 Cell , SA
    ...    [Cover Feature]: 5GC001178
    [Tags]    QC_89942
    Attach SA UE
    Trigger E1 Link Reset By Lock Cell
    Check WireShark Log    ${CURDIR}${/}a2a_A002${/}a2a.ini    wait_string=ENDCConfigurationUpdateAcknowledge::1
#    Check Cp If Log And Search The Relevant Infos
    Check Cp Nrt Log And Search The Relevant Infos
    Check Cp Rt Log And Search The Relevant Infos

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri

Common Test Teardown And Recover Env
    Unlock Cell And Wait gNB On Air And Release UE
    Common Test Teardown And Stop Capture Logs

Attach SA UE
    [Arguments]    ${ue}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1
    Execute Egate Command    ue_register id=${ue}    NG RM Registered
    Execute Egate Command    ue_pdu_session_setup ue=${ue} pdu=${pdu} nwslice=${nwslice} gw=${gw}    Initial Context Setup Successful

Trigger E1 Link Reset By Lock Cell
    Delta Commission Parameters    MRBTS-1/NRBTS-1/NRCELL-1:administrativeState=Locked
    Sleep    2s    # wait commission complete
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:administrativeState=Locked

Unlock Cell And Wait gNB On Air And Release UE
    Delta Commission Parameters    MRBTS-1/NRBTS-1/NRCELL-1:administrativeState=Unlocked
    Cells Should Be Onair    cell_id=1
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:administrativeState=Unlocked
    Run Keyword And Ignore Error    Execute Egate Command    ue_detach id=1
    Execute Egate Command    ue_disp id=1    state.*OFF

Check Cp If Log And Search The Relevant Infos
    ${ret}=    Execute Command On Enb    cat /tmp/node_CPIF00/tmp/startup_cp_if.log | grep "Reset"
    Should Contain    ${ret}    Initiated CuCp E1 Reset
    Should Contain    ${ret}    E1ResetAck
    Should Contain    ${ret}    Received E1ResetAck
    Should Contain    ${ret}    Complete F1 reset
    Should Contain    ${ret}    NgResetAck

Check Cp Rt Log And Search The Relevant Infos
    ${ret}=    Check CPRT Log From Snapshot    f1ap::Reset    WaitForInternalUeReleaseComplete
    Should Contain    ${ret[0]}    Recv f1ap::Reset from CU
    Should Contain    ${ret[0]}    f1ap::ResetAcknowledge to CU
    Should Contain    ${ret[1]}    Enter WaitForInternalUeReleaseComplete state
    Should Contain    ${ret[1]}    received WaitForInternalUeReleaseComplete message

Check Cp Nrt Log And Search The Relevant Infos
    ${ret}=    Execute Command On Enb    cat /tmp/node_CPNRT00/tmp/startup_cp_nrt.log | grep "E1Reset"
    Should Contain    ${ret}    E1Reset received
    Should Contain    ${ret}    E1ResetAck sent
    ${ret}=    Execute Command On Enb    cat /tmp/node_CPNRT00/tmp/startup_cp_nrt.log | grep "Pool and node ids"
    Should Contain    ${ret}    Released PDU session
    Should Contain    ${ret}    Released bearer

Check CPRT Log From Snapshot
    [Arguments]    @{filter}
    @{output}=    Create List
    ${time_stamp}=    Execute Cmd On Pc    date +%Y%m%d%H%M%S
    Execute Cmd On Pc    mkdir /tmp/${time_stamp}
    Collect Snapshot    /tmp/${time_stamp}/snapshot.zip
    Execute Cmd On Pc    unzip /tmp/${time_stamp}/snapshot.zip -d /tmp/${time_stamp}
    ${node_id}=    Execute Command On Enb    ls -al /tmp/node_CPRT00/tmp/vnode_0x* | awk '{print $9}'
    ${cmd1}=    Catenate    grep -zoE 'BTS[0-9]{1}_[0-9]{4}_part_[0-9]+\.zip:.*BTS[0-9]{1}_${node_id[-4:]}_runtime\.zip'
    ...    /tmp/${time_stamp}/snapshot_file_list.txt | grep -aE _part_ | tail -1
    ${cmd2}=    Catenate    grep -zoE 'BTS[0-9]{1}_[0-9]{4}_part_[0-9]+\.zip:.*BTS[0-9]{1}_${node_id[-4:]}_runtime\.zip'
    ...    /tmp/${time_stamp}/snapshot_file_list.txt | tail -1 | awk '{print $1}'
    ${zip1}=    Execute Cmd On Pc    ${cmd1}
    ${zip2}=    Execute Cmd On Pc    ${cmd2}
    Execute Cmd On Pc    unzip /tmp/${time_stamp}/${zip1[:-1]} -d /tmp/${time_stamp}
    Execute Cmd On Pc    unzip /tmp/${time_stamp}/${zip2} -d /tmp/${time_stamp}
    Execute Cmd On Pc    xz -d /tmp/${time_stamp}/runtime_cp_rt.log.xz
    FOR    ${f}    IN    @{filter}
        ${ret}=    Execute Cmd On Pc    cat /tmp/${time_stamp}/runtime_cp_rt.log | grep ${f}
        Append To List    ${output}    ${ret}
    END
    [Return]    ${output}
    [Teardown]    Execute Cmd On Pc    rm -rf /tmp/${time_stamp}
