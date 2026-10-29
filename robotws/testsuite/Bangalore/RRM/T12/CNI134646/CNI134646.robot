*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Arun Velusamy
...             :contact  : arun.velusamy@nokia.com
...             :Feature  :The purpose of this test case is to verify the Counters
...                        for measuring the distribution of PUSCH RSSI value and
...                        of PUSCH SINR value for Rank 1 and Rank 2 calculated from
...                        the UE UL transmission to gNB for FR1
Library		Collections
Resource    resources/Keywords/CNI134646_KW.robot
Suite Setup        Updated Suite Setup
Suite Teardown     Common Suite Teardown


*** Variables ***
${TOPOLOGY}				CLOUD_5G_I_LOO_AP_LOOO
${status}				False
${UE_min}				1
${UE_max}				8
@{PMQAP_lt}				20	21	24	25
${NRCELL_TDD}			1
${NRCELL_FDD}			7
&{result_NRCELL_TDD}
&{result_NRCELL_FDD}


*** Test Cases ***
[1][1.0] CNI134646_27_Verify_reconfig_of_PUSCH_RSSI_SINR_BIN_2_PMQAP_Counters_on_5QI_multiUE
    [Setup]     Prepare for CNI134646
	Register UE and start bidirectional data	${UE_min}	${UE_max}
	Wait For Next Full Pm Interval
	${pm_counter_file}  	Apply Pathloss and collect PM Files 	dir_name=MP_1
	# NRCELL-1
	# RSSI BIN1-BIN3 Counters
    # RSSI BIN1-BIN3 Counters
    ${LEG_RSSI}       Sum PM Counter Values      ${pm_counter_file}     ${NRCELL_TDD}      @{RSSI_COUNTER_LEG}
    ${LEG_SIN_R2}     Sum PM Counter Values      ${pm_counter_file}     ${NRCELL_TDD}      @{LEG_SINR_R2_CNTR}
    &{RSSI}       Sum PM Counter Values Under PMQAP     ${pm_counter_file}     ${NRCELL_TDD}     @{PMQAP_RSSI}
    &{SINR2}      Sum PM Counter Values Under PMQAP     ${pm_counter_file}     ${NRCELL_TDD}     @{PMQAP_SINR_R2}
    Verify The Legacy Counter Value Sum To PMQAP Counter    ${LEG_RSSI}        &{RSSI}
    Verify The Legacy Counter Value Sum To PMQAP Counter    ${LEG_SIN_R2}      &{SINR2}
	#NRCELL-7
	# RSSI BIN3 Counter
    # RSSI BIN1-BIN3 Counters
    ${LEG_RSSI}       Sum PM Counter Values      ${pm_counter_file}     ${NRCELL_FDD}      @{RSSI_COUNTER_LEG}
    ${LEG_SIN_R1}     Sum PM Counter Values      ${pm_counter_file}     ${NRCELL_FDD}      @{LEG_SINR_R1_CNTR}
    &{RSSI}       Sum PM Counter Values Under PMQAP     ${pm_counter_file}     ${NRCELL_FDD}     @{PMQAP_RSSI}
    &{SINR1}      Sum PM Counter Values Under PMQAP     ${pm_counter_file}     ${NRCELL_FDD}     @{PMQAP_SINR_R1}
    Verify The Legacy Counter Value Sum To PMQAP Counter    ${LEG_RSSI}        &{RSSI}
    Verify The Legacy Counter Value Sum To PMQAP Counter    ${LEG_SIN_R1}      &{SINR1}
	GNB Delta Commission	${scf}/Delta_config_rssi_sinr_1.json
	Log		Verifying Counters post online modification of RSSI and SINR Thresholds
	Wait For Next Full Pm Interval
	${pm_counter_file}	    Apply Pathloss and collect PM Files	    dir_name=MP_2

	#NRCELL-1
	# RSSI BIN1-BIN3 Counters
    # RSSI BIN1-BIN3 Counters
    ${LEG_RSSI}       Sum PM Counter Values      ${pm_counter_file}     ${NRCELL_TDD}      @{RSSI_COUNTER_LEG}
    ${LEG_SIN_R2}     Sum PM Counter Values      ${pm_counter_file}     ${NRCELL_TDD}      @{LEG_SINR_R2_CNTR}
    &{RSSI}       Sum PM Counter Values Under PMQAP     ${pm_counter_file}     ${NRCELL_TDD}     @{PMQAP_RSSI}
    &{SINR2}      Sum PM Counter Values Under PMQAP     ${pm_counter_file}     ${NRCELL_TDD}     @{PMQAP_SINR_R2}
	# SINR R2 BIN1-BIN5 Counters
    Verify The Legacy Counter Value Sum To PMQAP Counter    ${LEG_RSSI}        &{RSSI}
    Verify The Legacy Counter Value Sum To PMQAP Counter    ${LEG_SIN_R2}      &{SINR2}
	#NRCELL-7
	# RSSI BIN4 Counter
    ${LEG_RSSI}       Sum PM Counter Values      ${pm_counter_file}     ${NRCELL_FDD}      @{RSSI_COUNTER_LEG}
    ${LEG_SIN_R1}     Sum PM Counter Values      ${pm_counter_file}     ${NRCELL_FDD}      @{LEG_SINR_R1_CNTR}
    &{RSSI}       Sum PM Counter Values Under PMQAP     ${pm_counter_file}     ${NRCELL_FDD}     @{PMQAP_RSSI}
    &{SINR1}      Sum PM Counter Values Under PMQAP     ${pm_counter_file}     ${NRCELL_FDD}     @{PMQAP_SINR_R1}
    Verify The Legacy Counter Value Sum To PMQAP Counter    ${LEG_RSSI}        &{RSSI}
    Verify The Legacy Counter Value Sum To PMQAP Counter    ${LEG_SIN_R1}      &{SINR1}
	Stop bidirectional data and Deregister UE	${UE_min}	${UE_max}
	[Teardown]	Cleanup for CNI134646	${status}
