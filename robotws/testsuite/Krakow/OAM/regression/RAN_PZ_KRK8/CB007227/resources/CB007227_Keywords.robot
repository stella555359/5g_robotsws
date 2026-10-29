*** Settings ***
Documentation
...                 author/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 maintainer/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 Keywords for 7227 feature tests

Library             OperatingSystem
Library             DateTime
Library             taf.ue
Library             taf.rfrl.ue.logs.qxdm_logs.WindowsUePcUtil
Library             taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter    WITH NAME    gnbcounter
Library             taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    gnbscf
Library             taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library             on_air_tl_preparation.testline_preparation    WITH NAME    tl_prep
Library             CB007227_Keywords.py
Resource            taf/rfrl/ue/robot/REAL_UE.robot
Resource            taf/rfrl/bts/robot/gnb.robot
Resource            testsuite/Krakow/OAM/resources/collect_logs.robot
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Keywords ***
Test Setup
    Log to console    \n--Test Setup started--\n
    Run keyword And Restart gNB On ASIR Timeout    Common preconditions
    Upload commisioning with pcmd enabled
    Log to console    \n--Test Setup done--\n
    create test log directory
    Log to console    \n--Starting test ${TEST_NAME}--\n

Test Teardown
    Log to console    \n--Finished test ${TEST_NAME}--\n
    Log to console    \n--Test Teardown started--\n
    Run keyword And Restart gNB On ASIR Timeout    Common postconditions
    Log to console    \n--Test Teardown done--\n

Suite Setup
    Log to console    \n--Suite Setup started--\n
    tl_prep.Power On All Pdu Ports
    Setup dynamic suite variables
    Check if uepc is operational
    Set global variable    $TEST_NAME    CB007227_A
    Run keyword And Restart gNB On ASIR Timeout
    ...    Perform Full Commissioning and Wait for onAir
    ...    prefix_tag=${None}
    ...    asir_hub=${True}
    Perform testline specific setup
    Wait For Site To Be Onair
    Common Suite Setup
    Log to console    \n--Suite Setup done--\n

Suite Teardown
    Log to console    \n--Suite Teardown started--\n
    Run keyword And Restart gNB On ASIR Timeout    Common Suite Teardown
    Run Keyword and ignore error    taf.ue.Detach UE    UE_1
    Log to console    \n--Suite Teardown done--\n

Run Keyword And Restart gNB On ASIR Timeout
    [Arguments]    ${keyword}    &{args}
    FOR    ${_}    IN RANGE    3
        TRY
            Run Keyword    ${keyword}    &{args}
        EXCEPT    .*AsirConnection.*    type=regexp
            Log    \n--AsirConnection exception occured--\n    console=${True}
            Log    \n--${keyword} timed out, restarting gNB--\n    console=${True}
            Reset gNB
            Wait For Site To Be Onair
        ELSE
            RETURN
        END
    END

Start Data Transfer and Monitor Troughput
    [Arguments]    &{args}
    TRY
        Run Keyword    Start Data Transfer and Verify Troughput    &{args}
    EXCEPT    .*DataTransferVerificationFailure.*    type=regexp    AS    ${error}
        Log    \n--Average troughput outside of expected range--\n    console=${True}
        Log    ${error}    console=${True}
    END

Set 2SK192 Variables
    Set Global Variable    ${config_directory}    resources/configurations/2SK192

    Set Global Variable
    ...    ${pcmd_enabled_scf_path}
    ...    ${suite_directory}/${config_directory}/${build_branch}/pcmd_enabled_base_config.xml

    # -F subfeature scf's
    Set Global Variable
    ...    ${pcmd_f_tc_activation_precondition_scf_path}
    ...    ${suite_directory}/${config_directory}/${build_branch}/F/activation_precondition.xml
    Set Global Variable
    ...    ${pcmd_f_tc_activation_runtime_scf_path}
    ...    ${suite_directory}/${config_directory}/${build_branch}/F/activation_runtime.xml

    # -B subfeature scf's
    Set Global Variable
    ...    ${pcmd_b_tc_activation_precondition_scf_path}
    ...    ${suite_directory}/${config_directory}/${build_branch}/B/activation_precondition.xml
    Set Global Variable
    ...    ${pcmd_b_tc_activation_runtime_scf_path}
    ...    ${suite_directory}/${config_directory}/${build_branch}/B/activation_runtime.xml

    Set Global Variable    ${pcmd_enable_path}    MRBTS-78192/NRBTS-78192
    Set Global Variable    ${expected_5g_state}    5G_NSA
    Log to console    \n--Set 2SK192 Variables--\n

Check if test case handles commisionings by itself
    ${subfeature_b_detected}=    Set Variable    ${{"CB007227-B" in $TEST_NAME}}
    ${subfeature_f_detected}=    Set Variable    ${{"CB007227-F" in $TEST_NAME}}

    IF    ${subfeature_b_detected}    RETURN    ${True}
    IF    ${subfeature_f_detected}    RETURN    ${True}

    RETURN    ${False}

Setup dynamic suite variables
    Setup build specific variables
    Setup BTS specific variables
    Setup UE specific variables

Setup build specific variables
    Set Global Variable    ${build_branch}    ${ENB_BUILD.split("_")[0]}
    Log to console    \n-- Detected build branch: ${build_branch} --\n

Setup BTS specific variables
    ${testline_name}=    taf.rfrl.utilities.tl_config.Get Testline Name
    IF    "${testline_name}" == "7_7_UTE5GCLOUDT2SK192"    Set 2SK192 Variables

Perform testline specific setup
    ${testline_name}=    taf.rfrl.utilities.tl_config.Get Testline Name
    Log to console    \n--Performing testline specific setup--\n
    IF    "${testline_name}" == "7_7_UTE5GCLOUDT2SK192"
        Perform 2SK192 specific setup
    END
    Log to console    \n--Finished testline specific setup--\n

Perform 2SK192 specific setup
    # robocop: disable=0502
    Perform Full Commissioning On Classical eNB    update_timeout=${1800}

Setup UE specific variables
    taf.ue.Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    ${primary_ue_id}=    Get Variable Value    ${primary_ue_id}    ${tl.ues[0].serial_number}
    Set Global Variable    ${primary_ue_id}    ${primary_ue_id}
    Log to console    \n--Set primary ue id: ${primary_ue_id} --\n

Start collecting logs with output path
    [Arguments]    ${output_path}
    Start tcpdump on CU    filename=${output_path}    protocol=tcp    interface=any
    Log To Console    \n--Started collecting logs--\n

Stop collecting logs with output path
    [Arguments]    ${output_path}
    Stop tcpdump on CU and Download Logs    filename=${output_path}
    Log To Console    \n--Stopped collecting logs--\n

Create test log directory
    Log to console    Test log path: ${LOG_PATH}
    create directory    ${LOG_PATH}

Attach Ue and check 5G state
    [Arguments]    ${ue_alias}    ${scg_fails}
    FOR    ${i}    IN RANGE    30
        Log To Console    \n\n==== Attach UE to 5G: attempt ${i} (SCG failures:${scg_fails}) ====\n
        Sleep    10s
        taf.ue.Attach Ue    ${ue_alias}
        Sleep    30s
        ${5G_STATE}=    taf.ue.Get Ue Info    ${ue_alias}    NR_STATE
        Log to console    \n--5G_STATE detected: ${5G_STATE}--\n
        sleep    10s
        Enable mobile data on UE
        sleep    10s
        ${ip_addr}=    taf.ue.Get Ue Info    ${ue_alias}    IP
        IF    $ip_addr is None    Log to console    Ue IP is none
        IF    '${5G_STATE}' == '${expected_5g_state}' and $ip_addr is not None
            BREAK
        END
        Log to console    ---- UE Attach to 5G failed. 5G_STATE incorrect ----\n
        Log To Console    ---- Detach and restart UE due to incorrect 5G_STATE ----\n
        taf.ue.Detach UE    ${ue_alias}
        Sleep    40s
    END
    IF    '${5G_STATE}' == '${expected_5g_state}'
        Log to console    \n\n======== UE Attach to 5G succeeds ========\n\n
    ELSE
        Fail    UE cannot attach to 5G
    END
    Sleep    30s

Enable mobile data on UE
    # robocop: disable=0502
    Execute ue pc cmd    ue_id=${0}    cmd=cmd.exe /c "adb -s ${primary_ue_id} shell svc data enable"

Check if uepc is operational
    Execute ue pc cmd    ue_id=${0}    cmd=whoami
    Log to console    \n--UEPC is operational--\n

Change pcmd reporting status in gnb configuration
    [Arguments]    ${status}
    # robocop: disable=0502
    gnbscf.perform_configuration_parameter_recommissioning    operation=update
    ...    dist_name=${pcmd_enable_path}
    ...    parameter=actPCMDReport    value=${status}    timeout=300

Upload commisioning with pcmd enabled
    ${should_not_upload}=    Check if test case handles commisionings by itself
    IF    ${should_not_upload}
        Log to console    \n--Skipping commisioning upload, commissioning is handled by the test case itself--\n
        RETURN
    END
    Log to console    \n--Uploading commisioning with enabled pcmd--\n
    gnbscf.Perform Bts Full Commissioning    scf_file=${pcmd_enabled_scf_path}    timeout=600
    Log to console    \n--Initial commisioning uploaded--\n
    Log to console    \n--Waiting for cells to be onair--\n
    Wait For Site To Be Onair
    Log to console    \n--All required cells are onair--\n
    Log to console    \n--BTS is ready--\n

Upload commisioning with specific config
    [Arguments]    ${commisioning_path}
    Log to console    \n--Uploading commisioning with config ${commisioning_path}--\n
    gnbscf.Perform Bts Full Commissioning    scf_file=${commisioning_path}    timeout=600
    Log to console    \n--Commisioning uploaded--\n
    Log to console    \n--Waiting for cells to be onair--\n
    Wait For Site To Be Onair
    Log to console    \n--All required cells are onair--\n
    Log to console    \n--BTS is ready--\n

Extract data from counter
    [Arguments]    ${counter_name}
    ${counter_output}=    gnbcounter.get_counter    counter_ids=${counter_name}
    ${parsed_output}=    gnbcounter.extract_counter_data_from_response    ${counter_output}    ${counter_name}
    ${extracted_counter_tput}=    convert_counter_values_to_tp_messages    ${parsed_output}
    RETURN    ${extracted_counter_tput}
