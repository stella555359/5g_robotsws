*** Settings ***
Documentation
...   Test Suite for testing CB014677 feature
...   Author: Natalia Czech, Bartosz Odziomek
...   Contact: natalia.czech@nokia.com, bartosz.odziomek@nokia.com


Resource        testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB014677/resources/CB014677_kw.robot


Suite Setup          CB014677_kw.Test Suite Setup
Suite Teardown       Test Suite Teardown
Test Teardown        CB014677_kw.Test Teardown with TDS exit


*** Test Cases ***
[THOR] CB014677-A Operability of test model NR-FR2_TM2a for FR2 QAM is successfull
    [Setup]    keywords.Test Setup with TDS enter and BTS commissioning    prefix_tag=${7_7_T11SK056}
    General_SiSo_Auto_DL_Test_Model_Activation_Admin
    ...          cell_id=101
    ...          test_model=NR-FR2-TM2a
    ...          power_backoff=0
    ...          ru_mode=NR_Only
    ...          mimo_rank=2
    ...          codebook_2_antports=0
    ...          vswr_monitoring=False
    ...          beam_pattern_id=0
    ...          polarization=P_both
    ...          pmax=19
    ...          test_duration=30
    ...          admin_test_name=NR_DOWNLINK

[Loki] CB014677-A Operability of test model NR-FR2_TM3.1a for FR2 QAM is successfull
    [Setup]    keywords.Test Setup with TDS enter and BTS commissioning    prefix_tag=${7_7_UTE5GCLOUDT8SK111}
    General_SiSo_Auto_DL_Test_Model_Activation_Admin
    ...          cell_id=101
    ...          test_model=NR-FR2-TM3.1a
    ...          power_backoff=0
    ...          ru_mode=NR_Only
    ...          mimo_rank=2
    ...          codebook_2_antports=0
    ...          vswr_monitoring=False
    ...          beam_pattern_id=0
    ...          polarization=P_both
    ...          pmax=19
    ...          test_duration=30
    ...          admin_test_name=NR_DOWNLINK
