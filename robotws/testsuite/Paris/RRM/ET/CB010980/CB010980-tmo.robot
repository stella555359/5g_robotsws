*** Settings ***

Documentation     [SUITE PURPOSE]   feature CB010980 NR PM counters for integrity and utilization KPI
...               Prerequisite      : CB008746 and 5GC001008 for slicing and CB008933 NR PMQAP Profiles and Counters Extension
...               Scope             : Configure UEs and network (slicing, QCI, ...)
...                                   Test for TMO error case with VoNR
...                                   Launch traffic
...                                   Check counters
...               Configuration:    gNB LO_AP_LO for -B test - gNB MP_AP_LO for test -E
...               basic.cfg         Custom from scratch
...               scf               Updated via Json
...               Test Case Scenario author   : axel.gouilly-frossard@nokia.com
...               Creation Date               : 21-11-2025
...               Modified Date               : 21-11-2025
...               Last Modified by            : axel.gouilly-frossard@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2524    axel.gouilly-frossard@nokia.com             Creation

Resource          ./resources/robot/CB010980-tmo-Keywords.robot
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


${scf_delta_config_10980-tmo}    ${CURDIR}/Config/CustomCFG/Delta_scf_CB010980-tmo.json
${gnb_alias}                        gnb_under_test


# ---------------------------------------------------------------------------------------------------------------
*** Test Cases ***


[1][1.0] USCB010980-E-issue_related_to_case_05169667_TMO
    [Documentation]     This scenario aims to check the issue found with TMO and related to case 05169667.
    ...                 Actions: (a redefinir)
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
    CB010980_Modify_WTS_Cfg

    # Apply delta configuration to SCF for speculative DTX scenario
    CB010980_Configuration_SCF_Delta   ${scf_delta_config_10980-tmo}    gnb_alias=${gnb_alias}

    TC CB010980-tmo
    #[Teardown]
