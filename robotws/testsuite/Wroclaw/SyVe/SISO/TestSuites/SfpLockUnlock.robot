*** Settings ***
Documentation
...  author/contact: sebastian.lupkowski@nokia.com, jakub.szymczakiewicz@nokia.com

Library           testsuite.Wroclaw.SyVe.SISO.resources.CommonTests.SfpLockUnlockTest
Resource    taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
Resource    taf/rfrl/procedures/SISO/setups_teardowns/SuiteSetupTeardown.robot


Suite Setup      Common Suite Setup         commission=${False}
...                                         lmi_interface=${False}
...                                         stop_and_fix_gnb=${False}
...                                         stop_and_fix_enb=${False}
...                                         lte_snapshot=${False}

Suite Teardown   Common Suite Teardown      lock_rmods_after_execution=${False}

Test Setup       Common Test Setup

Test Teardown    Common Test Teardown       report_tl_configuration=${False}
...                                         stop_and_fix_gnb=${False}
...                                         stop_and_fix_enb=${False}
...                                         lte_snapshot=${False}

*** Variables ***
${bts_id}    ${tl.gnbs[0].global_bts_id}
@{sfps_bbmod1}     1    2
&{bbmods_sfps_map}    1=@{sfps_bbmod1}

*** Test Cases ***
[1]Auto_General_SiSo_SFP_lock_unlock_for_configuration_testing
    Perform sfp lock unlock test    bts_id=${bts_id}    bbmods_sfps_to_test=${bbmods_sfps_map}
