*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com, Lukasz Wlosowicz, lukasz.wlosowicz@nokia.com
...    Maintainer: Lukasz Wlosowicz, lukasz.wlosowicz@nokia.com
...    CB014634

Library           Collections
Resource          taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource          testsuite/Krakow/SISO/regression/RAN_PZ_KRK2/CB014634/resources/keywords.robot


Suite Setup       Common suite setup with OnAir test line preparation
...               increase_time_for_checking_radios=2100
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common suite teardown

Test Setup        Common Preconditions
Test Teardown     Common Postconditions


*** Variables ***
${INTERVAL_MINUTES}=    ${6}


*** Test Cases ***
[1][1.0] CB014634_Firmware_version_logging_in_Blackbox
    Prepare Env
    Wait For All Cells To Be Operating Correctly
    FOR    ${ru_id}    IN    @{RU_IDS_TO_VERIFY_FIRMWARE}
        Log    Testing Firmware version for RU_ID: ${ru_id}    console=${True}
        ${firmware_version_1}    Download Blackbox And Validate Firmware Version
        ...    ${ru_id}
        ...    ${BLACKBOX_FILE_PATH}/firmware_version/1
    END

[1][1.0] CB014634_Power_Sequencer_firmware_version_reporting_at_startup
    Prepare Env
    Validate PowerSequencer Before RU Reboots
    Reset All RUs
    Reset All RUs
    Validate PowerSequencer After RU Reboots
    Compare Last Entries For Changes

[1][1.0] CB014634_Verification_of_IPsec_status_recording_in_Blackbox
    Prepare Env
    Validate IPSec Is Disabled In Blackbox
    Save Current Timestamp
    Enable IPSec
    Reset All RUs
    Reset All RUs
    Validate IPSec Is Enabled In Blackbox

[1][1.0] CB014634_90-days_voltage_current_histogram
    [Timeout]    2h
    Prepare Env
    Wait For All Cells To Be Operating Correctly
    FOR    ${ru_id}    IN    @{RU_IDS_TO_VERIFY_VOLTAGE_AND_CURRENT}
        Log    Testing Voltage and Current histograms for RU_ID: ${ru_id}    console=${True}
        ${timestamp_start}    python_keywords.Reset RU and wait until online with saving timestamp    ${ru_id}
        ${voltage_histograms_1}    ${current_histograms_1}    Download Blackbox And Validate Voltage And Current Fields
        ...    ${ru_id}    ${BLACKBOX_FILE_PATH}/voltage_and_current/1
        python_keywords.Wait time since reset    ${timestamp_start}    minutes=${INTERVAL_MINUTES}
        python_keywords.Reset RU and wait until online with saving timestamp    ${ru_id}
        ${voltage_histograms_2}    ${current_histograms_2}    Download Blackbox And Validate Voltage And Current Fields
        ...    ${ru_id}    ${BLACKBOX_FILE_PATH}/voltage_and_current/2
        Run Keyword And Continue On Failure    python_keywords.Verify number of samples appeared in voltage histograms
        ...    ${voltage_histograms_1}    ${voltage_histograms_2}    expected_min_number_new_samples=${INTERVAL_MINUTES-2}
        ...    expected_max_number_new_samples=${INTERVAL_MINUTES}
        Run Keyword And Continue On Failure    python_keywords.Verify number of samples appeared in current histograms
        ...    ${current_histograms_1}    ${current_histograms_2}    expected_min_number_new_samples=${INTERVAL_MINUTES-2}
        ...    expected_max_number_new_samples=${INTERVAL_MINUTES}
    END
