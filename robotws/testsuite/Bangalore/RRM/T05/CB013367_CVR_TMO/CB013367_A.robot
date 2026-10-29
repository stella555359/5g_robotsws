*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Prajwali Joshi
...             :contact  : prajwali.milind_joshi@nokia.com
Resource        resources/Keywords/CB013367_KW.robot
Library         taf.wts.runner      WITH NAME   wtsrunner
Library         taf.sw.syslog       WITH NAME   slog

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***
${BLER_TESTMODE}      	    bler
${RI_VALUES}		    SEPARATOR=
...		-88,-93,-94,-97,-98,-103,-105,-106,-107,-110,-110,-110,-115,-115,-115,-115,-115,-115,-115,-115,-115,
...		-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115
${LUA_FILE}        ${CURDIR}/resources/Keywords/scripts.lua
${Log_Path1}        /home/ute/logs/CB013367_A2_59
${Log_Path2}        /home/ute/logs/CB013367_B3_20
*** Test Cases ***

[1][1.0] CB013367_A_ET_TC_59_Verification_of_Intra-gNB_HO_not_performed_to_cell_affected_by_RI_when_actBadUlRadioHoRej_is_configured_as_rimbased
    [tags]        QCD_MN_RAN      QCP_RAN_VRF   QC_176421
    [Documentation]    The purpose of this test case is to verify handover is not triggered and handover trigger with different RSRP values,
    ...        when there is MODERATE IMPACT as NRCELL.actBadUlRadioHoRej is set to rimBasedHoRej
    [Setup]    Prepare For Test Case CB013367_A2_59
	Log To Console      \nStep 1: Remote Interference Activation for cell 1\n
	Pass Lua File       ${LUA_FILE}
    Setup Remote Interfernce		1		0		32		${RI_VALUES}
	Activate Cell TestMode		2		1		remote_interference     activate        1
	Wait For 2 RI Monitoring Periods
    Check If RI Alarm Is Present
    Log To Console      \nRemote Interference Alarm 7525 is observed
	# Comment: To maintain Remote Interference alarm active for longer time 'nrRiMonitorWindow'updated maximum value
    GNB Delta Commission          ${CURDIR}/config/gnb_scf/RIM_window_modify.json
    Sleep   25s
    Register Multiple UEs       41       43
    Start data in Multiple UEs       41       43
    Initiate VoNR SA UEs    41       43
    Pass Lua File       ${LUA_FILE}
    Data validation before HO
    Wait For Next Full Pm Interval
    Pass Lua File       ${LUA_FILE}
    Trigger A2 meas     41       43
    Verify HO not triggered     41       43
    Pass Lua File       ${LUA_FILE}
    Verify HO triggered     41       43
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55145C00321   3     ATT_IF_INTRA_DU_HO_SA_PLMN
    ...     M55145C00322   3     SUCC_IF_INTRA_DU_HO_SA_PLMN
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4/MCC-310/MNC-260
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55177C00036   3     IAGNB_MR_DISCARD_BULRC_VONR
    ...     M55177C00037   3     IAGNB_MR_DISCARD_BULRC
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-4
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55124C00521   0     NR_RRC_REL_REDIR_RAD_NR
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    Data validation after HO
    [Teardown]   Teardown for CB013367_A2_59

[1][1.0] CB013367_B_ET_TC_20_Verification_Of_CIO_for_the_local_neighbour_cells_of_the_PCell_evaluated_as_having_MEDIUM_IMPACT
    [tags]        QCD_MN_RAN      QCP_RAN_VRF    QC_182866
    [Documentation]    The purpose of this test case is to check CIO is configured for physical cell id 51(NRCELL-1) as RIM alram is present,
    ...                for NRCELL-3 no CIO is there. Verification of new CIO counter as per the scenario.
    [Setup]    Prepare For Test Case CB013367_B3_20
	Log To Console      \nStep 1: Remote Interference Activation for cell 1\n
	Pass Lua File       ${LUA_FILE}
    Setup Remote Interfernce		1		0		32		${RI_VALUES}
	Activate Cell TestMode		2		1		remote_interference     activate        1
	Wait For 2 RI Monitoring Periods
    Check If RI Alarm Is Present
    Log To Console      \nRemote Interference Alarm 7525 is observed
	# Comment: To maintain Remote Interference alarm active for longer time 'nrRiMonitorWindow'updated maximum value
    GNB Delta Commission          ${CURDIR}/config/gnb_scf/RIM_window_modify.json
    Sleep   5s
    Register Multiple UEs       41       42
    Start data in Multiple UEs       41       42
    Initiate VoNR SA UEs    41       42
    Verify packet count in Multiple UEs in DL UL direction      41      42    1
    Verify packet count in Multiple UEs in DL UL direction      41      42    2
    Verify packet count in Multiple UEs in DL UL direction      41      42    3
    Wait For Next Full Pm Interval
    Pass Lua File       ${LUA_FILE}
    Trigger A2 meas for CIO     41
    Trigger A2 meas for NO CIO     42
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55142C00027   2     NR_MEAS_TH_RECONF_BULRC_SUCC
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-4
    ...     file_path=${pm_counter_file}
    [Teardown]   Teardown for CB013367_B3_20
