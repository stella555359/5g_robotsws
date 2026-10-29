*** Settings ***
Documentation
...  author:        Andrzej Somkowski / Mikolaj Guszpit / Pawel Wisniewski
...  maintainer:    pawel.1.wisniewski@nokia.com
...  description:   Feature checks the number of layers for semi_closed_loop_4TX and semi_open_loop_4TX. Test case was
...                 moved from real hardware test line to Airphone topology.
...  topology:      CLOUD_5G_I_BOO_AP_LOO -> VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/5GC002139/resources/tests_2139.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/utils.py

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     taf/ul/ettf/main.robot
Library      ta5g_iphy
Library      ta5g_pm_counters
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups

Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
...            AND             With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy.xml
...            AND             With Gnb Configuration    commissioning=scf.xml
...            AND             Reach Onair      lua_cfg=${CURDIR}/config/tmous.cfg

Test Teardown  run keywords
...  Add Scout Data Info To Testcase
...  AND
...  Stop tput and detach ue

*** Variables ***
${rdComponentBitMapProfile}=   0x5808FF=2
@{SWCONFIG_FLAGS_LIST}=        ${rdComponentBitMapProfile}
${LOGS_COMPRESSION}=           ${True}
${UE_ID}=                      1

*** Test Cases ***
[1][1.0] 5GC002139-A_Func_1Call1S_MaxTput_FDD_Class_1S-4UL4DL_NSA_FDM_PDSCH_Dl_Closed_loop_4x4_rank4_in_GOOD_RC
    run_keyword_and_allow_retest
    ...    [1][1.0] 5GC002139-A_Func_1Call1S_MaxTput_FDD_Class_1S-4UL4DL_NSA_FDM_PDSCH_Dl_Closed_loop_4x4_rank4_in_GOOD_RC
