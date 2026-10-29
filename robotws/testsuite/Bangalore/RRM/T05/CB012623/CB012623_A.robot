*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Vicky Raina
...             :contact  : vicky.raina@nokia.com
Resource        resources/Keywords/CB012623_KW.robot
Library         taf.wts.runner      WITH NAME   wtsrunner
Library         taf.sw.syslog       WITH NAME   slog

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***

${LUA_FILE}        ${CURDIR}/resources/Keywords/scripts.lua
${Log_Path1}        /home/ute/logs/

*** Test Cases ***

CB012623_B_05_Verification Of SSB interference mitigation interworking with CB008927 DL Resource Allocation Type 1
    [tags]        QCD_MN_RAN      QCP_RAN_VRF   QC_294758
    [Documentation]    The purpose of this test case is to verify SSB interference Mitigation
    [Setup]    Prepare For Test Case CB012623_B
    Sleep   25s
    Register Multiple UEs       1       2
    Start data in Multiple UEs       1       2
	Sleep   25s
	Add UE BLER Testmode And Activate       1       2
	Sleep	900s
    Wait For Next Full Pm Interval
    Pass Lua File       ${LUA_FILE}
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55165C00044   900000     NUM_PRB_PDSCH_MUTE_SSB_INT_MIT
    ...     M55308C10003   129225000     PRB_AVAIL_PDSCH
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]   Teardown for CB012623_B
[1.0] CB012623_A_01_Verification of Feature Activation for SSB Interference Mitigation
    [tags]        QCD_MN_RAN      QCP_RAN_VRF   QC_280513
    [Documentation]    The purpose of this test case is to verify SSB interference Mitigation
    [Setup]    Prepare For Test Case CB012623_A
    Sleep   25s
    Register Multiple UEs       1       2
    Start data in Multiple UEs       1       2
	Sleep   25s
	Add UE BLER Testmode And Activate       1       2
	Sleep	900s
    Wait For Next Full Pm Interval
    Pass Lua File       ${LUA_FILE}
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55165C00044   1320000     NUM_PRB_PDSCH_MUTE_SSB_INT_MIT
    ...     M55308C10003   129000000     PRB_AVAIL_PDSCH
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]   Teardown for CB012623_A