*** Settings ***
Documentation
...    Author: mateusz.gadek@nokia.com
...    Description: Suite prepared for ALD tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN3808 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRAN3808 testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG01/ALD/Testsuites/SBTS_3808_Martin/sbts_crt.robot


Resource        ../../Testcases/ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors/test.robot
Resource        ../../../resources/snapshot_collector.robot

Force Tags
...           SBTS00  SBTS23R1  SBTS22R4  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_ST  QCD_MN_RAN  ## QC project; QC domain for reporting
...           CA_RAN_PZ_WRO_3
...           PY39  ## force python3 UTE package
...           CLOUD_SRAN_NLWG_1ASIB_1ABIA_1ABIN_1ABIO_2FXDB_1AEHC_1AHLOA_1FXED  # label

Suite Setup       Test Suite Setup
Suite Teardown    Test Suite Teardown

*** Test Cases ***

[1][1.0] Automated__ALD__RAE_Reading_2D_beamforming_weight_factors
    [Setup]  common.Common Test Setup
    ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors
    [Teardown]  ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors.Test Case Teardown



