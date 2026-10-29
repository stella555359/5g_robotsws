*** Settings ***
Force Tags    PY39
Documentation
...    Author:mengyan
...    Contact:meng.yan@nokia-sbell.com
...    Group: RAN_PZ_HAZ_3
...    Feature: CB010474

Suite Setup         Setup Suite For Cloud
Test Setup          Setup Test For Cloud
Test Teardown       Teardown Test For Cloud
Suite Teardown      Teardown Suite For Cloud
Resource          Resource/CB010474_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Common.robot

*** Variables ***
${scf_path_cu}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/cu
${scf_path_du}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/dus_0
${ru_dn1}    MRBTS-11272/EQM_R-1/APEQM_R-1/RMOD_R-2
${signal1}    RX_CARRIER
${antennaCarrier1}    MRBTS-11272/NRBTS-175/NRCELL-2
${antennaPanel1}    Full_Array
${ru_dn2}    MRBTS-11272/EQM_R-1/APEQM_R-1/RMOD_R-2
${signal2}    RX_COMBINED
${antennaPanel2}    Full_Array

*** Test Cases ***
[1][1.0] CB010474-A_15_RF_scan_test_online_mode
    Start RF Scanning test with FIR9    ru_dn=${ru_dn1}    signal=${signal1}    antenna_carrier=${antennaCarrier1}
    ...    antenna_panel=${antennaPanel1}
    Start RF Scanning test with HBF0    ru_dn=${ru_dn2}    signal=${signal2}    antenna_panel=${antennaPanel2}

[1][1.0] CB010474-C_7_start_stop_RF_scan_test_with_cli
    Start RF Scanning test with FIR9    ru_dn=${ru_dn1}    signal=${signal1}    antenna_carrier=${antennaCarrier1}
    ...    antenna_panel=${antennaPanel1}
    Start RF Scanning test with HBF0    ru_dn=${ru_dn2}    signal=${signal2}    antenna_panel=${antennaPanel2}

