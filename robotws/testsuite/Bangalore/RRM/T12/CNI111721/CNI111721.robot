*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Tom
...             :contact  : tom.toby@nokia.com
Library     XML
Library     ute_fsmaccess
Library     ta5g_tshark
Library     ta5g_enb
Library     ute_wtssim
Library     ta5g_pm_counters
Resource    ./resources/Keywords/CNI111721_KW.robot
Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***
${SCF}             ${CURDIR}/config/gnb_scf/CNI_111721_SCF.xml
${IPHY}            ${CURDIR}/config/ap_iphy/CNI_111721_iphy.xml
${LUA_FILE}        ${CURDIR}/resources/Keywords/scripts.lua

*** Test Cases ***
[1][1.0] CNI_111721_TC5_Verify_PUCCH_token_allocation_for_a_cell_when_pucchModeSelect_is_LongPUCCH
    [Documentation]     CNI_111721_PUCCH_Token
    ...       2. Test Case Steps:
    ...       Step 1: Register TDD, FDD SA UEs
    ...       Expected Results:
    ...       Multi UE registartion is successful
    ...       Step 2: ICS & UL,DL traffic
    ...       Expected Results:
    ...       Initial Context is Successful and downlink & uplink traffic is successful
    ...       Step 3: Validate Log results and confirm functionality
    ...       Expected Results:
    ...       Scheduling of UEs is as per expectation for both TDD and FDD cells
    ...       Step 4: Benchmarking test
    ...       Expected Results:
    ...       The DL and UL RLC PDU counts are as per benchmark values
	...       Verify PM counter to validate the results for step 3 and step 4
    [Tags]    QC_28345  QCD_MN_RAN    QCP_RAN_VRF
	[Setup]      Run Keywords     Create Basic Interface On UTE
    ...     AND     Link SCOUT SCF To Configuration ID For Reporting
    ...     AND     Full Commision Scf And Iphy      ${SCF}      ${IPHY}
    ...     AND     Sleep   360s
    ...     AND     Wait Coam Site To Be Ready
    ...     AND     Start UTE WTS      CNI_111721_basic_setup.cfg
    Basic Bring Up
    Sleep   30s
    Log To Console      Step 2:Register Datacall SA UEs \n
    Pass Lua File       ${LUA_FILE}
	Register Multiple SA UEs       1      10
    Pass Lua File       ${LUA_FILE}
	Register Multiple SA UEs       51      62
    Pass Lua File       ${LUA_FILE}
    Sleep   600s
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
#    Verify Last Counters In File
#    ...     M55308C17002   8     MAX_SCHED_UE_PDSCH
#    ...     M55308C18002   8     MAX_SCHED_UE_PUSCH
#    ...     M55310C02006   >1681285     DL_RLC_PDU_TX_L_QOS_GRP_06
#    ...     M55310C02006   <2324129     DL_RLC_PDU_TX_L_QOS_GRP_06
#    ...     M55310C04006   >5925080     UL_RLC_PDU_RX_L_QOS_GRP_06
#    ...     M55310C04006   <6548772     UL_RLC_PDU_RX_L_QOS_GRP_06
#    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#    ...     file_path=${pm_counter_file}
#	${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
#    Verify Last Counters In File
#    ...     M55308C17002   12     MAX_SCHED_UE_PDSCH
#    ...     M55308C18002   10     MAX_SCHED_UE_PUSCH
#    ...     M55310C02006   >506261      DL_RLC_PDU_TX_L_QOS_GRP_06
#    ...     M55310C02006   <5595905     DL_RLC_PDU_TX_L_QOS_GRP_06
#    ...     M55310C04006   >8264709     UL_RLC_PDU_RX_L_QOS_GRP_06
#    ...     M55310C04006   <9134679     UL_RLC_PDU_RX_L_QOS_GRP_06
#    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
#    ...     file_path=${pm_counter_file}
    Pass Lua File       ${LUA_FILE}
    Log To Console      \nStarting Tear Down for Test Case
