*** Settings ***
Documentation
...     autor: Jakub Szymczakiewicz, Sebastian Lupkowski


Resource    taf/rfrl/procedures/SISO/setups_teardowns/SuiteSetupTeardown.robot
Resource    taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_Cell_Block_Unblock.robot

Variables    ue_tputs.py


Suite Setup       Common Suite Setup         commission=${False}
...                                          lmi_interface=${False}
...                                          stop_and_fix_gnb=${False}
...                                          stop_and_fix_enb=${False}
...                                          lte_snapshot=${False}

Suite Teardown    Common Suite Teardown      lock_rmods_after_execution=${False}

Test Setup        Common Test Setup          ues=${tl.ues}
Test Teardown     Common Test Teardown       report_tl_configuration=${False}
...                                          stop_and_fix_gnb=${False}
...                                          stop_and_fix_enb=${False}
...                                          lte_snapshot=${False}


*** Test Cases ***
[1]General_SiSo_Auto_Cell_Block_Unblock
      FOR    ${i}    IN RANGE    10
        General_SiSo_Auto_Cell_Block_Unblock          throughputs=${throughput_values}
      END
