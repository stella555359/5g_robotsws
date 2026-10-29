*** Settings ***

Documentation    O-RAN Robustness Script for CNI-145039.
...   author: krishna.murthy_m@nokia.com
...   contact: I_MN_RAN_RD_VRF_BLR1_T08@internal.nsn.com
...   Description: This script is written for CNI-145039,includes a range of test scenarios designed to evaluate Robustness of the BTS.Tests include:
...   Validation of Repetitive BTS Power Reset - Ensuring BTS boots up correctly after each power reset (traffic + alarm check)
...   Validation of Repetitive RMOD Reset - Ensuring RMOD Returns to Operational State After Each Reset (traffic + counter + alarm check)
...   Validation of Repetitive Site block and unblock - After each unblock, site returns to operational state (traffic + counter+ alarm check).
...   Validation of Repetitive Cell block and unblock - After each unblock, site returns to operational state (traffic + counter + alarm check).
...   Validation of Repetitive RAT Reset - Ensuring repeated RAT resets do not cause functional degradation (traffic + alarm check).
...   Validation of Repetitive Site Reset - Ensuring system stability under stress conditions (traffic + counter + alarm check).
...   Validation of Repetitive BBMOD Reset - BBMOD recovers to full operational status each reset cycles (traffic + alarm check).
...   Validation of Netconf Mandatory Parameter - For each user provided YANG model parameters, check if it appears in the device's capability list.
...   Validation of Unsupported value configuration - Ensure that no crash or unstable behavior occurs in the system due to unsupported parameter.
...   Validation of Crash and Memory leakage via snapshot parser - Ensure no crashes or memory leaks after repeated O&M operations via Jenkins.
...   Autonomous Reset Recovery After C-Plane Crash - Ensure system automatically detects a crash and recovers to operational state.
...   Validation Checkpoints:Log analysis including snapshots, counters, alarm checks, L3 call verifications, Crash dump analysis, Memory checks.

...   Key Notes & Limitations:
...   The firewall must allow access from the local VM to the server at 10.33.5.213/32 (see reference ticket for details).
...   All dependency packages must be installed prior to execution.
...   Test failures may result from intentional negative test scenarios; therefore, manual inspection of snapshots logs is required to determine
...   if failures indicate an actual software defect.
...   Disable (comment out) counter check when when site is commissioned with ORAN and non-ORAN RUs.
...   Script will be further enhanced to support this configuration scenario.

...   Exe cmd:robot -V /home/ute/testline_configuration  --outputdir
...   -L TRACE -b debug.log -d ~/logs/CNI-145039_$(date +%y%m%d_%H%M%S) CNI-145039.robot

Resource          CNI-145039_resource.robot

Suite setup        Suite Setup
Suite Teardown     Suite Teardown

Force Tags        SBTS00         CNI-145039      Predicted_Robustness

*** Variables ***
${TC_01_No.of.RMOD_Reset_Iteration}     2
${TC_02_No.of.Site_Block_Iteration}     2
${TC_03_No.of.Cell_Block_Iteration}     2
${TC_04_No.of.RAT_Reset_Iteration}      2
${TC_05_No.of.Site_Reset_Iteration}     2
${TC_06_No.of.Power_Reset_Iteration}    2
${TC_07_No.of.BBMOD_Reset_Iteration}    2
${Verify_L3Call}                        NO      #YES or NO for Ultracaller L3 Call verification

*** Test Cases ***
TC_01_Validation of Repetitive BTS Power Reset
    Validation of Repetitive BTS Power Reset

TC_02_Validation of Repetitive RMOD Reset
    Validation of Repetitive RMOD Reset

TC_03_Validation of Repetitive Site block and unblock
    Validation of Repetitive Site block and unblock

TC_04_Validation of Repetitive Cell block and unblock
    Validation of Repetitive Cell block and unblock

TC_05_Validation of Repetitive RAT Reset
    Validation of Repetitive RAT Reset

TC_06_Validation of Repetitive Site Reset
    Validation of Repetitive Site Reset

TC_07_Validation of Repetitive BBMOD Reset
    Validation of Repetitive BBMOD Reset

TC_08_Validation of Netconf Mandatory Parameter
    Validation of Netconf Mandatory Parameter

TC_09_Validation of Negative_scenarios_Changing_parameter_values
    Validation of Negative_scenarios

#TC_10_Validation of Crash and Memory leakage via snapshot parser
#    Validation of Crash and Memory leakage via snapshot parser

#TC_11_Autonomus Reset Recovery after C-Plane Crash
#    Autonomous Reset Recovery After C-Plane Crash

***Keywords***
Test Status
    Log to console  \n--Test is in-progress--\n
