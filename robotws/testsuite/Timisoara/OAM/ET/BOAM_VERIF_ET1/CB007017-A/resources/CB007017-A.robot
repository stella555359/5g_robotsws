*** Settings ***

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        BuiltIn
Library        DateTime
Library        SSHLibrary
Library        taf.transport.ssh    WITH NAME    SSH

Resource    keywords.robot
Resource    measurements_list.robot
Resource    ../../resources/admin.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/emssim/emssim_setup.robot
Resource    ../../resources/emssim/emssim_variables.robot
Resource    ../../../BOAM_VERIF_ET2/SyVe_Left_Shift/resources/CommonKeywords/admin/BasicKeywords.robot


*** Variables ***

*** Keywords ***
Fault_4203_after_site_reset
    Log to console   Test case precondition: Enable RTPM on gNB and on EMSSIM
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_enable_RTPM}
    EMSSIM RTPM Activate
    Sleep   60s
    Run keyword and ignore error    EMSSIM Run Emssim Command   rtpm_parse

    Log to console   Step 1: Perform site reset
    ADMIN CLI connection
    gNB Site Reset

    Log to console   Step 2: crash EMSSIM
    EMSSIM Teardown Emssim

    Log to console   Step 3: Check if fault 4203 is visible in webEM after Site Reset
    ADMIN Check If Alarm Is Active With Timeout  fault_id=4203  timeout=180
    Wait Until Keyword Succeeds  360  20    ADMIN Check BTS onair
    [Teardown]  Run keywords  ADMIN Perform Delta Recommissioning    delta_file=${delta_file_disable_RTPM}
    ...         AND           EMSSIM Teardown Emssim

Enabling_of_PM_counters_real-time_monitoring_5G
    Log to console   Test case precondition: Prepare RTPM simulator
    EMSSIM RTPM Activate

    Log to console   Step 1: Enable RTPM on gNB
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_enable_RTPM}

    Log to console   Step 2: Check that BTS is able to establish TCP connection to RTPM-CE
    EMSSIM RTPM counters received
    EMSSIM RTPM Counters are available
#    EMSSIM RTPM Counter exists      M55112C10   NRCELL-1

    Log to console   Step 3: Modify parameter MRBTS-1/NRBTS-1/NRPMRNL-1/ nrRTPMMeasurements to value None selected
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_none_selected}

    Log to console   Step 4: Check there is no counter update sent towards RTPM-CE
    Run Keyword And Expect Error   RTPM files did not appear before timeout   EMSSIM RTPM counters are cleared

    Log to console   Step 5: Configure at least one measurement and then stop EMS simulator
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_one_selected}
    EMSSIM Teardown Emssim

    Log to console   Step 6: Check BTS reports FID 4203
    ADMIN Check If Alarm Is Active With Timeout  fault_id=4203  timeout=240

    Log to console   Step 7: Set parameter NRBTS/act5gRTPM to false
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_disable_RTPM}

    Log to console   Step 8: Check that FID 4203 is cleared
    ADMIN Check If Alarm Is Not Active With Timeout  fault_id=4203   timeout=180

    Log to console   Step 9: Set parameter NRBTS/act5gRTPM to "true" and then start EMS simulator(RTPM-CE)
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_enable_RTPM}
    EMSSIM Setup Emssim
    EMSSIM RTPM counters received

    Log to console   Step 10: Configure wrong ip address for the RTPM-CE in BTS and then do a site reset
    Start Capture Wireshark Logs on gNB    rtpmlogname=TC2_step12.dcap    interface=${interface}
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_wrong_IP}
    Stop Capture Wireshark Logs on gNB    rtpmlogname=TC2_step12.dcap
    Step 10 to step 13

    Log to console  Step 14: Repeat steps 10,11,12,13 but use a wrong RTPM-CE port number
    Log to console  Step 10: Configure wrong port number for the RTPM-CE in BTS and then do a site reset
    Start Capture Wireshark Logs on gNB    rtpmlogname=TC2_step12.dcap    interface=${interface}
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_wrong_port}
    Stop Capture Wireshark Logs on gNB    rtpmlogname=TC2_step12.dcap
    Step 10 to step 13

    [Teardown]  Run keywords  ADMIN Perform Delta Recommissioning    delta_file=${delta_file_disable_RTPM}
    ...         AND           EMSSIM Teardown Emssim

Disabling_of_PM_counters_real-time_monitoring_Case1

    Log to console  Test case precondition: RTPM is enabled on gNB and on EMMSIM
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_enable_RTPM}
    EMSSIM RTPM Activate

    Log to console  Step 1: Operator activates a delta plan file in which MNL/MNLENT/PMCADM::rTPmCollEntity is removed
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_disable_RTPM}

    Log to console  Step 2: BTS stops reporting counters to RTPM-CE
    Run Keyword And Expect Error   RTPM files did not appear before timeout   EMSSIM RTPM counters are cleared

    Log to console  Step 3: Restore initial configuration in which RTPM reporting is enabled and counters are sent to the RTPM-CE
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_enable_RTPM}
    EMSSIM RTPM counters received

    Log to console  Step 4: Stop RTPM-CE and verify that FID 4203 is visible
    EMSSIM Teardown Emssim
    ADMIN Check If Alarm Is Active With Timeout  fault_id=4203  timeout=240

    Log to console  Step 5: Activate the delta plan file used in step1
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_disable_RTPM}

    Log to console  Step 6: After activation, start RTPM-CE and check that FID 4203 is cleared from active alarms table
    EMSSIM RTPM Activate
    ADMIN Check If Alarm Is Not Active With Timeout  fault_id=4203  timeout=120

    Log to console  Step 7: Repeat step 3
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_enable_RTPM}
    EMSSIM RTPM counters received
    EMSSIM RTPM Counter exists      M55112C10   NRCELL-1

    Log to console  Step 8: Disable miNrEcpriUpFCp parameter
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_miNrEcpriUpFCp_disabled}

    Log to console  Step 9: Check if miNrEcpriUpFCp related measurements are still sent to RTPM-CE
    EMSSIM RTPM counters are cleared
    Wait until keyword succeeds   2min  30s   EMSSIM RTPM Counter exists      M55318C2   NRCELL-1

    [Teardown]  Run keywords  ADMIN Perform Delta Recommissioning    delta_file=${delta_file_disable_RTPM}
    ...         AND           ADMIN Perform Delta Recommissioning    delta_file=${delta_file_miNrEcpriUpFCp_enabled}
    ...         AND           EMSSIM Teardown Emssim

Changing_RTPM_related_configuration
    Log to console  Test case precondition: RTPM is enabled on gNB and EMSSIM
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_enable_RTPM}
    EMSSIM RTPM Activate

    Log to console  Step 1: Operator activates a delta plan file in which one or more parameters under MNL/MNLENT/PMCADM::rTPmCollEntity are changed
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_change_RTPM_step2}

    Log to console  Step 2: BTS terminates connection to RTPM-CE and try re-establish connection with new configuration
    ADMIN Check If Alarm Is Active With Timeout  fault_id=4203  timeout=240
    Run keyword and expect error  RTPM files did not appear before timeout    EMSSIM RTPM counters received

    Log to console  Step 3: Restore initial configuration
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_enable_RTPM}
    EMSSIM RTPM counters received

    Log to console  Step 4: Operator activates a plan file in which rTPmCollInterval, act5gRTPM and nrRTPMMeasurements are changed
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_change_RTPM_step4}

    Log to console  Step 5: The required reported content and reporting interval is updated according to new configuration
    ADMIN Check If Alarm Is Not Active With Timeout  fault_id=4203  timeout=120
    Run keyword and expect error  RTPM files did not appear before timeout    EMSSIM RTPM counters received

    Log to console  Step 6: Restore initial configuration
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_enable_RTPM}
    EMSSIM RTPM counters received

    Log to console  Step 7: Activate a plan in which one parameter from step 2 and one parameter from step 4 are changed
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_change_RTPM_step7}

    Log to console  Step 8: BTS terminates connection to RTPM-CE and try re-establish connection with new configuration
    ADMIN Check If Alarm Is Not Active With Timeout  fault_id=4203  timeout=120
    Run keyword and expect error  RTPM files did not appear before timeout    EMSSIM RTPM counters received
    [Teardown]  Run keywords  ADMIN Perform Delta Recommissioning    delta_file=${delta_file_disable_RTPM}
    ...         AND           EMSSIM Teardown Emssim

