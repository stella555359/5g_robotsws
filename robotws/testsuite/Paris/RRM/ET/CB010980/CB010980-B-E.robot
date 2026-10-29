*** Settings ***

Documentation     [SUITE PURPOSE]   feature CB010980 NR PM counters for integrity and utilization KPI
...               Prerequisite      : CB008746 and 5GC001008 for slicing and CB008933 NR PMQAP Profiles and Counters Extension
...               Scope             : Configure UEs and network (slicing, QCI, ...)
...                                   Launch traffic
...                                   Check counters
...               Configuration:    gNB LO_AP_LO for -B test - gNB MP_AP_LO for test -E
...               basic.cfg         Custom from scratch
...               scf               Updated via Json
...               Test Case Scenario author   : axel.gouilly-frossard@nokia.com
...               Creation Date               : 19-09-2025
...               Modified Date               : 19-09-2025
...               Last Modified by            : axel.gouilly-frossard@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2519    axel.gouilly-frossard@nokia.com             Creation

Resource          ./resources/robot/CB010980-B-E-Keywords.robot
# Resource          ../../../../../resources/SWENG/robot/Connect.robot
Resource          ../../../resources/SWENG/robot/GenericTest.robot
# Resource          ../../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../resources/SWENG/robot/KPIs.robot
Resource          ../../../resources/SWENG/robot/Tools.robot
Resource          ../../../resources/SWENG/robot/Setup.robot

Suite Setup       Suite Setup from scratch    keepAllUeDataInCfgFile=${True}    listBackupFiles=${FD_ALL}
Suite Teardown    Suite Teardown


*** Variables ***
# Custom Config ABIL LO_AP_LO with slicing and multi-PLMNs
${ABIL-B_SCF}       ${CURDIR}/Config/CustomCFG/SCF_PMQAS_MultiPlmnSlice.xml
${ABIL-B_CFG}       ${CURDIR}/Config/CustomCFG/basic_setup-PMQAS-MultiPlmnSlice.cfg

${ABIM-E_SCF}       ${CURDIR}/Config/CustomCFG/SCF_E_010_PDSCH_speculative_DTX.xml

${scf_delta_config_10980-DTXSpec}    ${CURDIR}/Config/CustomCFG/Delta_scf_CB010980-DTXSpec.json
${gnb_alias}                        gnb_under_test


# ---------------------------------------------------------------------------------------------------------------
*** Test Cases ***

[1]USCB010980-B_001_DL_and_UL_MAC_SDU_volume_per PMQAP_profile
    [Documentation]     CB010980 The purpose of this test case is to check that PM related to DL MAC SDU volume
    ...                 transmitted on DTCH and UL MAC SDU volume received on DTCH per PMQAP profile are well managed.
    ...                 Conditions:
    ...                     gNB with ASIL/ABIO
    ...                     1 TDD Cell (Cell1)
    ...                     2 slices defined on CN side
    ...                     2 PLMNs available
    ...                     5 UEs SA/NSA with the following configuration:
    ...                   	Type	Bearers	    PLMN	    Slice
    ...                     UE1	SA	5QI7, 6	    PLMN#1	    SLICE#1
    ...                     UE2	SA	5QI2, 5, 6	PLMN#2	    SLICE#2
    ...                     UE3	SA	5QI6	    PLMN#2	    SLICE#1
    ...                     UE4	NSA	QCI1, 5, 9	PLMN#1	    N/A
    ...                     UE5	NSA	QCI 6, 9	PLMN#2	    N/A
    ...                     NIDD NRBTS.NRPMRNL.miNrLowRlcCellNrpmqap = 5 mn
    ...                     The following PMQAP profile have been created:
    ...                                     Profile 1	Profile 2	Profile 3	Profile 4
    ...                     cfg5qiRange	    5QI2, 5		            5QI6	    5QI7
    ...                     cfgQciRange			                    QCI9
    ...                     cfgPlmnId		            PLMN#1		            PLMN#2
    ...                     cfgProfType	    SA	        NSA	        SA+NSA	    SA+NSA
    ...                     snssaiList	    SLICE#2
    ...                 Actions:
    ...                     1. Set NIDD actUPlaneGroup2Counters = true
    ...                     2. Set NIDD NRBTS.actNrpmqapProfiles= true
    ...                     3. Set NRBTS.NRPMRNL.NRPMQAP.actUPlaneGroup2Counters = true for all PMQAP profiles
    ...                     4. Attach all UEs.
    ...                     5. Create corresponding dedicated bearers
    ...                     6. Send same DL/UL traffic over all bearers (this step is to ease to forecast PMQAP values).
    ...                     7. Wait for GP expiration
    ...                 Postconditions
	...                     At the end of the PM period counters DL_MAC_SDU_VOL_DTCH_PMQAP, UL_MAC_SDU_VOL_DTCH_PMQAP
    ...                     are reported inside NMS per PMQAP profile.
	...                     DL_MAC_SDU_VOL_DTCH, UL_MAC_SDU_VOL_DTCH are reported inside NMS per cell.

    Dated Log New Line     ===> To setup with custom config files
    CB010980 Setup With Custom Config   SCF=${ABIL-B_SCF}
    ...                                 CFG=${ABIL-B_CFG}

    TC CB010980-PMQAP
    #[Teardown]


[1]USC010980-E_010_PDSCH_speculative_DTX
    [Documentation]     CB010980 This user scenario aims to verify the counters for PDSCH HARQ (re)transmission distribution.
    ...                 This also verifies the unsuccessful PDSCH transmissions and unsuccessful PDSCH transmissions due to DTX.
    ...                 This test case covers the speculative DTX case. If the speculative DTX algorithm is activated,
    ...                 it will treat DTX in HARQ feedback as ACK under good RF conditions, so gNB doesn’t perform HARQ retransmission.
    ...   PM Counters will also treat this as ACK.
    ...                 Actions:
    ...                     1. Set actSpeculativeDtx is set to true
    ...                     2. Set NRBTS.NRPMRNL.miNrDlHarq is set to 5min
    ...                     3. Set NRBTS.NRCELL.actNrPdschTxDistCounters is set to a value other than disabled (e.g. : all or just dllaBlerTarget ?)
    ...                     4. Set maxDlHarqTx=8
    ...                     5. Cell setup is achieved
    ...                 Postconditions
    ...                     At the end of the PM period counters Counters PDSCH_INI_TX is incremented and consistent with generated BLER
    ...                     PDSCH_2ND_TX, PDSCH_3RD_TX, PDSCH_4TH_TX, PDSCH_5TH _TX, PDSCH_6TH_TX, PDSCH_7TH_TX, PDSCH_8TH_TX,
    ...                     PDSCH_UNSUCC_LAST_RETX_DTX, PDSCH_UNSUCC_LAST_RETX should not be incremented because of speculative DTX algorithm.

    Dated Log New Line     ===> To setup with custom config files
    # Apply delta configuration to SCF for speculative DTX scenario
    CB010980_Configuration_SCF_Delta   ${scf_delta_config_10980-DTXSpec}    gnb_alias=${gnb_alias}

    TC CB010980-SpecDTX
    #[Teardown]
