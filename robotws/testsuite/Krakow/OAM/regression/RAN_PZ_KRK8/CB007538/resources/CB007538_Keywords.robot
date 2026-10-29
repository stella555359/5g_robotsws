*** Settings ***
Documentation
...                 author/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 maintainer/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 Keywords for 7538 feature tests

Library             OperatingSystem
Library             DateTime
Library             taf.ue
Library             taf.rfrl.ue.logs.qxdm_logs.WindowsUePcUtil
Library             taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter    WITH NAME    gnbcounter
Library             taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    gnbscf
Library             taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library             on_air_tl_preparation.testline_preparation    WITH NAME    tl_prep
Library             CB007538_Keywords.py
Resource            taf/rfrl/ue/robot/REAL_UE.robot
Resource            taf/rfrl/bts/robot/gnb.robot
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource            testsuite/Krakow/OAM/resources/collect_logs.robot
Resource            testsuite/Krakow/resources/NJ_Resources/Resources/robot/DevNJ_UE_keywords.robot
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Keywords ***
Test Setup
    Log to console    \n--Test Setup started--\n
    Run keyword And Restart gNB On ASIR Timeout    Common preconditions
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
    #tl_prep.Power On All Pdu Ports
    Setup Suite Variables
    Log to console    \n--Performing Full Commissioning--\n
    Run Keyword And Restart gNB On ASIR Timeout
    ...    Perform Full Commissioning and Wait for onAir
    ...    prefix_tag=${None}
    ...    asir_hub=${True}
    Set environment config name    Unknown
    Log to console    \n--Current ENV configuration is: ${current_config}--\n
    Log to console    \n--Full Commissioning Finished--\n
    Wait For cells To Be OnAir
    Log to console    \n--Performing Common Suite Setup--\n
    Run keyword And Restart gNB On ASIR Timeout    Common Suite Setup
    Log to console    \n--Suite Setup done--\n

Suite Teardown
    Log to console    \n--Suite Teardown started--\n
    Common Suite Teardown
    Run Keyword and ignore error    Postconditions_ForUE
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
            Wait For cells To Be OnAir
        ELSE
            RETURN
        END
    END

Start DLUL Data Transfer And Verify Throughput
    [Arguments]    ${ue_index}    ${duration}    ${dl_throughput}    ${ul_throughput}    ${max_deviation}
    UE Attach And Start ADB Log    ue_index=${ue_index}
    Sleep    15s
    ${start_time}=    Get Current Date
    ${expected_end_time}=    Add Time To Date    ${start_time}    ${duration}
    Log    \n--Starting DLUL data transfer--\n    console=${True}
    Log    \n--Start Time: ${start_time}--\n    console=${True}
    Log    \n--Expected end time: ${expected_end_time}--\n    console=${True}
    Start DL Async Process    ${ue_index}    ${dl_throughput}    ${duration}
    Start UL Async Process    ${ue_index}    ${ul_throughput}    ${duration}
    Sleep    ${duration}
    Calculate and Verify DL Async Tput    ${ue_index}    ${dl_throughput}    ${max_deviation}    0s
    Calculate and Verify UL Async Tput    ${ue_index}    ${ul_throughput}    ${max_deviation}    0s
    ${end_time}=    Get Current Date
    Postconditions_ForUE
    Log    \n--Finished DLUL data transfer--\n    console=${True}
    Log    \n--End Time: ${end_time}--\n    console=${True}

Setup BTS specific variables
    Log    \n--Configuration value: ${CONFIGURATION}    console=${True}
    IF    ${{'T066' in '${CONFIGURATION}'}}
        Set Suite Variable    $config_directory    resources/configurations/T066
        Set Suite Variable    $dist_name    MRBTS-75066/NRBTS-75066
        Log to console    \n--Setting T066 Variables--\n
    END
    IF    ${{'T095' in '${CONFIGURATION}'}}
        Set Suite Variable    $config_directory    resources/configurations/T095
        Set Suite Variable    $dist_name    MRBTS-75095/NRBTS-75095
        Log to console    \n--Setting T095 Variables--\n
    END
    IF    ${{'T030' in '${CONFIGURATION}'}}
        Set Suite Variable    $config_directory    resources/configurations/T030
        Set Suite Variable    $dist_name    MRBTS-75030/NRBTS-75030
        Log to console    \n--Setting T030 Variables--\n
    END
    IF    ${{not '${config_directory}'}}
        FAIL    Couldn't match SCF files to current configuration: ${CONFIGURATION}
    END

    Set Suite Variable
    ...    $2T2R_gnb_scf
    ...    ${suite_directory}/${config_directory}/${build_branch}/2T2R_gnb_scf.xml

    Set Suite Variable
    ...    $2T2R_asir_scf
    ...    ${suite_directory}/${config_directory}/${build_branch}/2T2R_asir_scf.xml

    Set Suite Variable
    ...    $4T4R_gnb_scf
    ...    ${suite_directory}/${config_directory}/${build_branch}/4T4R_gnb_scf.xml

    Set Suite Variable
    ...    $4T4R_asir_scf
    ...    ${suite_directory}/${config_directory}/${build_branch}/4T4R_asir_scf.xml


Setup Suite Variables
    Setup build specific variables
    Setup BTS specific variables

Setup build specific variables
    Set Suite Variable    $build_branch    ${ENB_BUILD.split("_")[0]}
    Log to console    \n--Detected build branch: ${build_branch}--\n

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

Set environment config name
    [Arguments]    ${config_name}
    Set Suite Variable    $current_config    ${config_name}
    Log    \n--Current environment configuration name is: ${current_config}--\n    console=${True}

Mark environment as modified
    IF    ${{'_modified' not in '${current_config}'}}
        Set environment config name    ${current_config}_modified
        Log    \n--Environment marked as modified--\n    console=${True}
    END

Prepare environment configuration If needed
    [Arguments]    ${requested_config}
    Log    Prepariring environment configuration\n    console=${True}
    Log    Requested configuration: ${requested_config}\n    console=${True}
    Log    Current configuration: ${current_config}\n    console=${True}
    IF    ${{'${requested_config}' not in ["2T2R", "4T4R"]}}
        FAIL    Unkown environment version: ${requested_config}\n
    END
    IF    "${current_config}" != "2T2R" and "${requested_config}" == "2T2R"
        Log    SCF 2T2R upload required\n    console=${True}
        Upload GNB commisioning with specific config    ${2T2R_gnb_scf}
        Upload ASIR commisioning with specific config    ${2T2R_asir_scf}
        Wait For cells To Be OnAir
        Set Environment Config Name    2T2R
    ELSE IF    "${current_config}" != "4T4R" and "${requested_config}" == "4T4R"
        Log    SCF 4T4R upload required\n    console=${True}
        Upload GNB commisioning with specific config    ${4T4R_gnb_scf}
        Upload ASIR commisioning with specific config    ${4T4R_asir_scf}
        Wait For cells To Be OnAir
        Set Environment Config Name    4T4R
    ELSE
        Log    Environment is already set up as requested\n    console=${True}
    END

    # Sometimes OnAir might drop unexpectedly right after coming up post commissioning
    # Below code was made in expectation of it and waits for OnAir to appear again
    Sleep    60s
    Wait for cells to be OnAir

    Log    Requested: ${requested_config}, present: ${current_config}\n    console=${True}

Set 4x4 or 4x2 Open Loop Spatial Multiplexing
    # robocop: disable=0502
    gnbscf.perform_configuration_parameter_recommissioning    operation=update
    ...    dist_name=${dist_name}/NRCELL-0
    ...    parameter=dlMimoMode
    ...    value=4x4 or 4x2 Open Loop Spatial Multiplexing
    ...    timeout=300

    Mark environment as modified
    Wait for cells to be OnAir
    Sleep    30s

Wait for cells to be OnAir
    Log to console    \n--Wait for cells to be OnAir--\n
    gnbcell.Wait For All Cells To Be Onair    timeout=600
    Log to console    \n--Cells are OnAir--\n

Upload GNB commisioning with specific config
    [Arguments]    ${commisioning_path}
    Log to console    \n--Uploading commisioning with config: ${commisioning_path}--\n
    Perform Full commissioning on classical GNB    scf_path=${commisioning_path}
    Log to console    \n--Commisioning uploaded--\n
    Log to console    \n--BTS is ready--\n

Upload ASIR commisioning with specific config
    [Arguments]    ${commisioning_path}
    Log to console    \n--Uploading commisioning with config: ${commisioning_path}--\n
    Perform Full Commissioning On Gnb Asir Hub    scf_path=${commisioning_path}
    Log to console    \n--Commisioning uploaded--\n
    Log to console    \n--ASIR is ready--\n
