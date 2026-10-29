*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_NL_10832_ASIL_ABIQ_2ABIN_FRHC_AHFB_AHLOA    SBTS24R3
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure.robot
Resource          ../../LOGS/LOGS_CB010545_AdminCLI_snapshot_Full_coverage.robot
Resource          ../../LOGS/LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01
${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10832_BMW/commissioning/SCF_01_SBTS24R3.xml

${NETACT_LAB}    &{srnclab1027}

*** Test Cases ***
[1]Automated__LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure
    [Setup]    Run Keywords    LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure
    ...    AND    Set Library Search Order    LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure
    [Timeout]    14400
    TC__LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure
    [Teardown]    Run Keywords    LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB010545_AdminCLI_snapshot_Full_coverage
    [Setup]    Run Keywords    LOGS_CB010545_AdminCLI_snapshot_Full_coverage.TC Setup
    ...    AND    Modify Resource Search Order    LOGS_CB010545_AdminCLI_snapshot_Full_coverage
    ...    AND    Set Library Search Order    LOGS_CB010545_AdminCLI_snapshot_Full_coverage
    [Timeout]    14400
    TC__LOGS_CB010545_AdminCLI_snapshot_Full_coverage
    [Teardown]    Run Keywords    LOGS_CB010545_AdminCLI_snapshot_Full_coverage.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification
    [Setup]    Run Keywords    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification
    ...    AND    Set Library Search Order    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification
    [Timeout]    14400
    TC__LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification
    [Teardown]    Run Keywords    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=TSR1VRF7
    ...    input_logs_dir=${NONE}
