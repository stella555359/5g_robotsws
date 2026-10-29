*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...           SBTS00    CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    PY311
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska
...              :contact: katarzyna.wisniewska@nokia.com

Resource    5GC002645_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
...            AND             Reach Onair    lua_cfg=${CURDIR}/../../../resources/airphone/egate_2c_tdd_2c_fdd_sansa.lua    cell_type=tdd
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Wait For Next Full Pm Interval
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_CMAS_parameters.json
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Suite Teardown    Run Keywords    Roll Delta Back
...                                   initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                                   delta_scf_filename=delta_CMAS_parameters.json
...               AND             Unlock all cells

*** Test Cases ***
5GC002645_C_D_PWS_Restart_Indication_And_PWS_Cancel
    [Documentation]    For UE-1: Test case checks correct handling of PWS (Public Warning System) restart indication procedure
    ...                without CMAS ongoing (Commercial Mobile Alert Service for PWS). After UE attach, controlled CMAS
    ...                is triggered. It means SIB8 has to be received. After block and unblock cell PWS Failure Indication
    ...                and PWS restart procedure should be started. The purpose of the PWS Failure Indication procedure
    ...                is to inform the AMF that ongoing PWS operation for one or more cells has failed.
    ...                The purpose of the PWS restart procedure is to restart an already ongoing broadcast of message.
    ...                After block and unblock cell CMAS is triggered again and F1AP, NGAP messages with correct data collected.
    ...                Data like: Transaction ID, NR CGI List for Restart List, Global RAN Node ID, TAI List for Restart,
    ...                Emergency Area ID List for Restart. The last checks: WRITE_REPLACE_WARNING_REQUEST and
    ...                WRITE_REPLACE_WARNING_RESPONSE. This message ( WRITE_REPLACE_WARNING_REQUEST / Direction:
    ...                AMF to NG-RAN node) is sent by the AMF to request the start or overwrite of the broadcast
    ...                of a warning message. Two counters are checked:
    ...                M55119C02003 - Incremented when NGAP PWS FAILURE INDICATION message is sent by gNB.
    ...                M55119C02006 - Incremented when NGAP PWS RESTART INDICATION message is sent by gNB.
    ...                For UE-2: test case verifies the correctness of cancellation the specified number of CMAS broadcast
    ...                messages, and correct sending of the CMAS message immediately after cancellation.
    ...                33 WRITE_REPLACE_WARNING_REQUEST/RESPONSE messages should be received.

    [Setup]    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}
    Attach Ue    ue_id=1
    Trigger Concurrent CMAS    repetition=50
    Block Single Cell    cell_id=1
    Unblock Single Cell    cell_id=1
    Trigger Concurrent CMAS
    Verify F1AP Messages In Pcaps PWS Restart
    Verify NGAP Messages In Pcaps PWS Restart
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55119C02003    +1    NNGCB_PWS_FAIL_IND_SENT
    ...    M55119C02006    +1    NNGCB_PWS_REST_IND_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True

    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}
    Attach Ue    ue_id=2
    Trigger Concurrent CMAS    number_of_repetition=32    wait_time=4
    Stop CMAS Broadcast        message_code=0    update_number=1    wait_time=5
    ...                        pass_regexp=NGAP:PWSCancelResponse
    Trigger Infinite CMAS
    Verify NGAP Messages in Pcaps PWS Cancel
    Deregister Ue Without Confirmation    ue_id=1-2

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=2
        ...       AND             Add Scout External Execution ID To Reporting Portal
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

