*** Settings ***
Documentation
...   Test Suite Author: Anna Maciejewska
...   Test Suite Owner: Anna Maciejewska



Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_Radio_Module_Reset_From_GUI.robot

Resource    taf/rfrl/procedures/SISO/setups_teardowns/SuiteSetupTeardown.robot
Resource    taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot

Force Tags    CLOUD_RF_AIBR_B4-B5_UTESRANSISO801
...           CRT   SBTS00   PY36

Suite Setup     Common Suite Setup
Suite Teardown  Common Suite Teardown

Test Setup      Common Test Setup
Test Teardown   Common Test Teardown


*** Test Cases ***
[1][1.0] General_SiSo_Auto_Radio_Module_Reset_From_GUI
    General_SiSo_Auto_Radio_Module_Reset_From_GUI
