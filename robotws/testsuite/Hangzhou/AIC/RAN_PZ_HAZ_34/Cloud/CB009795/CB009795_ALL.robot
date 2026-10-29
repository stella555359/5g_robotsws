*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   ./Resource/common.robot


*** Variables ***
@{message_name_list}   NsetapX_StartRecordingSession   NsetapX_StopRecordingSession
${DEBUG}   ${False}


*** Test Cases ***
CB009795_CR_Resilient_tracing_in_vCU
    Run Keyword And Continue On Failure   CB009795_A_CPUE
    Run Keyword And Continue On Failure   CB009795_B_CPNRT
    Run Keyword And Continue On Failure   CB009795_C_TCC


*** Keywords ***
CB009795_A_CPUE
    Common Case Setup
    Step1: First Attach UE
    Step2: Kill CPUE
    Step3: Re Dettach Attach UE
    [Teardown]   Common Case Teardown


CB009795_B_CPNRT
    Common Case Setup
    Step1: First Attach UE
    Step2: Kill CPNRT
    Step3: Re Dettach Attach UE
    [Teardown]   Common Case Teardown


CB009795_C_TCC
    Common Case Setup
    Step1: First Attach UE
    Step2: Kill TCC
    Step3: Re Dettach Attach UE
    [Teardown]   Common Case Teardown


Common Case Setup
    Wait Until Keyword Succeeds   15m   1m   COAM CU Login

    Run Keyword If   not ${DEBUG}   COAM CU Reset
    Run Keyword If   not ${DEBUG}   Wait Until Keyword Succeeds   15m   1m   COAM CU Check All Cell Status

    Check CU Pod Status   pod_name=all   check_restarts=-1

    Log To Console   Prepare UE
    l3call.Simple UE Prepare

    Log To Console   Wait DCAP New File
    Run Keyword If   not ${DEBUG}   utils.wait_until_next_minutes   wait_minutes=${10}
    Run Keyword If   not ${DEBUG}   Sleep   30s

    ${LATEST_PCMD_FILE}   Get CU Latest Trace File Name
    Set Suite Variable   ${LATEST_PCMD_FILE}

    # OperatingSystem.Run   rm -rf ${OUTPUT_DIR}/Initial_UE
    # OperatingSystem.Run   rm -rf ${OUTPUT_DIR}/Attach_UE
    # OperatingSystem.Run   rm -rf ${OUTPUT_DIR}/First_Kill
    # OperatingSystem.Run   rm -rf ${OUTPUT_DIR}/Re_Attach_UE

    Log To Console   Get New PCMD File: Initial_UE
    ${initial_time}   DateTime.Get Current Date   result_format=epoch
    ${initial_log_dir}   Set Variable   ${OUTPUT_DIR}/Initial_UE_${initial_time}
    Get CU Newest Trace Files   latest_skip_file=${LATEST_PCMD_FILE}   latest_file_skipped=${False}   log_dir=${initial_log_dir}
    ${initial_pcmd_message}   Emil Decoding To JSON   message_name_list=${message_name_list}   emil_result_dir=${initial_log_dir}
    ${initial_pcmd}   Check PCMD Message After Time   all_pcmd_message=${initial_pcmd_message}   check_time=${initial_time}

    Log To Console   ${initial_pcmd}
    Should Be Empty   ${initial_pcmd}

    [Teardown]   Run Keyword And Ignore Error   COAM CU Logout


Common Case Teardown

    Run Keyword And Ignore Error   l3call.Simple UE Prepare

    Wait Until Keyword Succeeds   15m   1m   COAM CU Login

    ${status}   Get Variable Value   ${KEYWORD_STATUS}   ${TEST_STATUS}
    Run Keyword If   not ${DEBUG}   Run Keyword If   "${status}"=="FAIL"   COAM CU Save Local Snapshot
    Run Keyword If   not ${DEBUG}   COAM CU Reset
    Run Keyword If   not ${DEBUG}   Wait Until Keyword Succeeds   15m   1m   COAM CU Check All Cell Status

    Check CU Pod Status   pod_name=all   check_restarts=-1

    [Teardown]   Run Keyword And Ignore Error   COAM CU Logout


Step1: First Attach UE
    Log To Console   Attach UE
    ${first_attach_time}   DateTime.Get Current Date   result_format=epoch
    l3call.Simple UE Attach
    # Sleep   30s

    Log To Console   Get New PCMD File: Attach_UE
    ${first_attach_log_dir}   Set Variable   ${OUTPUT_DIR}/Attach_UE_${first_attach_time}
    Get CU Newest Trace Files   latest_skip_file=${LATEST_PCMD_FILE}   latest_file_skipped=${False}   log_dir=${first_attach_log_dir}
    ${first_attach_pcmd_message}   Emil Decoding To JSON   message_name_list=${message_name_list}   emil_result_dir=${first_attach_log_dir}
    ${first_attach_pcmd}   Check PCMD Message After Time   all_pcmd_message=${first_attach_pcmd_message}   check_time=${first_attach_time}
    Log To Console   ${first_attach_pcmd}
    Should Not Be Empty   ${first_attach_pcmd}


Step2: Kill CPUE
    ${first_kill_time}   DateTime.Get Current Date   result_format=epoch
    Kill CU Pod   pod_name=cpue   pod_index=${0}
    Wait Until Keyword Succeeds   2m   10s   Check CU Pod Status   pod_name=cpue   pod_index=${0}   check_restarts=-1
    Sleep   5s

    Kill CU Pod   pod_name=cpue   pod_index=${1}
    Wait Until Keyword Succeeds   2m   10s   Check CU Pod Status   pod_name=cpue   pod_index=${1}   check_restarts=-1
    Sleep   10s

    Log To Console   Get New PCMD File: First_Kill
    ${first_kill_log_dir}   Set Variable   ${OUTPUT_DIR}/First_Kill_${first_kill_time}
    Get CU Newest Trace Files   latest_skip_file=${LATEST_PCMD_FILE}   latest_file_skipped=${False}   log_dir=${first_kill_log_dir}
    ${first_kill_pcmd_message}   Emil Decoding To JSON   message_name_list=${message_name_list}   emil_result_dir=${first_kill_log_dir}
    ${first_kill_pcmd}   Check PCMD Message After Time   all_pcmd_message=${first_kill_pcmd_message}   check_time=${first_kill_time}
    Log To Console   ${first_kill_pcmd}
    Should Not Be Empty   ${first_kill_pcmd}


Step2: Kill CPNRT
    ${first_kill_time}   DateTime.Get Current Date   result_format=epoch
    Kill CU Pod   pod_name=cpnrt   pod_index=${0}
    Wait Until Keyword Succeeds   2m   10s   Check CU Pod Status   pod_name=cpnrt   pod_index=${0}   check_restarts=-1
    Sleep   5s

    Kill CU Pod   pod_name=cpnrt   pod_index=${1}
    Wait Until Keyword Succeeds   2m   10s   Check CU Pod Status   pod_name=cpnrt   pod_index=${1}   check_restarts=-1
    Sleep   10s

    Log To Console   Get New PCMD File: First_Kill
    ${first_kill_log_dir}   Set Variable   ${OUTPUT_DIR}/First_Kill_${first_kill_time}
    Get CU Newest Trace Files   latest_skip_file=${LATEST_PCMD_FILE}   latest_file_skipped=${False}   log_dir=${first_kill_log_dir}
    ${first_kill_pcmd_message}   Emil Decoding To JSON   message_name_list=${message_name_list}   emil_result_dir=${first_kill_log_dir}
    ${first_kill_pcmd}   Check PCMD Message After Time   all_pcmd_message=${first_kill_pcmd_message}   check_time=${first_kill_time}
    Log To Console   ${first_kill_pcmd}
    Should Not Be Empty   ${first_kill_pcmd}


Step2: Kill TCC
    ${first_kill_time}   DateTime.Get Current Date   result_format=epoch
    Kill CU TCC
    Wait Until Keyword Succeeds   2m   10s   Check CU Pod Status   pod_name=cpnrt   pod_index=${0}   check_restarts=-1
    Sleep   5s

    Log To Console   Get New PCMD File: First_Kill
    ${first_kill_log_dir}   Set Variable   ${OUTPUT_DIR}/First_Kill_${first_kill_time}
    Get CU Newest Trace Files   latest_skip_file=${LATEST_PCMD_FILE}   latest_file_skipped=${False}   log_dir=${first_kill_log_dir}
    ${first_kill_pcmd_message}   Emil Decoding To JSON   message_name_list=${message_name_list}   emil_result_dir=${first_kill_log_dir}
    ${first_kill_pcmd}   Check PCMD Message After Time   all_pcmd_message=${first_kill_pcmd_message}   check_time=${first_kill_time}
    Log To Console   ${first_kill_pcmd}
    # Should Not Be Empty   ${first_kill_pcmd}


Step3: Re Dettach Attach UE
    Log To Console   Re-Attach UE
    ${reattach_time}   DateTime.Get Current Date   result_format=epoch
    l3call.Simple UE Detach
    l3call.Simple UE Attach

    Log To Console   Get New PCMD File: Re_Attach_UE
    ${reattach_log_dir}   Set Variable   ${OUTPUT_DIR}/Re_Attach_UE_${reattach_time}
    Get CU Newest Trace Files   latest_skip_file=${LATEST_PCMD_FILE}   latest_file_skipped=${False}   log_dir=${reattach_log_dir}
    ${reattach_pcmd_message}   Emil Decoding To JSON   message_name_list=${message_name_list}   emil_result_dir=${reattach_log_dir}
    ${reattach_pcmd}   Check PCMD Message After Time   all_pcmd_message=${reattach_pcmd_message}   check_time=${reattach_time}
    Log To Console   ${reattach_pcmd}
    Should Not Be Empty   ${reattach_pcmd}
