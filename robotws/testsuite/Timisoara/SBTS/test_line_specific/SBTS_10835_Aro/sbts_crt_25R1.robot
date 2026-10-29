*** Settings ***
Force Tags   QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NLWG_10835_2ASIL_2ABIA_2ABIL_1ABIO_1ABIN_FXED_AHGB_AHBCC_3AHIB_AHIB_AEHC_AZHN   SBTS00
Library      XML  use_lxml=True
Resource     taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource     ../../LOGS/LOGS__CB012611_ABION_crash_site_reset.robot
Resource     ../../LOGS/LOGS__CB012611_ABION_crash_bbmod_reset.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01
${COMMISSIONING_PATH}
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10835_Aro/commissioning/SCF_01_TRUNK.xml

*** Test Cases ***
[1]CB012611_A2_BTS_startup_with_ABIO_with_single_failed_Loki_basic_configuration2
    [Setup]    Run Keywords    LOGS__CB012611_ABION_crash_site_reset.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB012611_ABION_crash_site_reset
    ...    AND    Modify Resource Search Order    LOGS__CB012611_ABION_crash_site_reset
    [Timeout]    14400
    TC__LOGS__CB012611_ABION_crash_site_reset
    [Teardown]    Run Keywords    LOGS__CB012611_ABION_crash_site_reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB012611_B4_ABIO_reset_with_single_failed_Loki_cells_shared_between_Lokis_configuration
    [Setup]    Run Keywords    LOGS__CB012611_ABION_crash_bbmod_reset.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB012611_ABION_crash_bbmod_reset
    ...    AND    Modify Resource Search Order    LOGS__CB012611_ABION_crash_bbmod_reset
    [Timeout]    14400
    TC__LOGS__CB012611_ABION_crash_site_reset
    [Teardown]    Run Keywords    LOGS__CB012611_ABION_crash_bbmod_reset.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
