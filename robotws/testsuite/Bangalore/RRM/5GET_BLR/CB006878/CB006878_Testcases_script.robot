*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO   CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Madhu
...                        Lavanya P
...              :contact: mohanavel.p@nokia.com/ madhusudhan.y@nokia.com
...         The aim of the 5GC000937 feature is to allow power savings for UE with small throughput traffic.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         The strategy for UE power savings is based on the possibility of dynamic switch between a BWP with large bandwidth size
...         (often configured with full carrier
...         bandwidth size) and a "power saving BWP" with a narrow bandwidth size.
...         The feature is considered as being efficient when the power saving BWP bandwidth size is a small
...         fraction of the large BWP bandwidth size.
...         A typical example is for carrier bandwidth size 100Mhz, the large BWP covers the full carrier Bw and the
...         power saving BWP bandwidth size is 20Mhz.
...         The dynamic decision for which BWP to use is based on some configurable criteria including UL/DL data rate and
...         UL/DL buffer length.
...         Some mechanism prevents ping-pong effect.
...         A NIDD parameter limits the number of UEs simultaneously in the power saving BWP.
...         The use case is verified with CB006878 enable and verify the pCSI, SR, HARQ A/N resource allocation
...             TESTING SPLIT:     See CB0076878 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB006878 CFAM
...             Requirement ID:     5G_RAN_USR_RRM_16315

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/CB006878_Keywords.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ../resources/python/avg_dl_data.py
Resource         ../resources/robot/configuration_id.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ./resources/CB006878_Resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/256qam_config.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${epc_log_path}    /tmp/
${IPHY_FILE}                    ${CURDIR}/config/iphy_256qam.xml
${sa_ue_id}      1
${sa_trf_id}    1
${TRF_ID}       1
${TRF_ID_1}       1
${TRF_ID_2}       2
${sa_qfi_id}    1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TEST_NAME}     256qam
${delta_file_name}   CB006878_Disable.json

*** Test Cases ***

[1]CB006878_A#1_09_LongPUCCH_for_FR1_TDD_two_Cell_with_and_without_CB06878_UL256QAM

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Link SCOUT SCF to Configuration ID for Reporting
    Perform SCF Delta Commissioning with ${delta_file_name}
    sleep   30s
	Trigger multiple UEs with the 256qam capable with CB006878 disabled
	Trigger multiple UEs with the 256qam capable with CB006878 enabled


CB006878_B#1_04_LongPucch_SA_multiBWP_PSBWP_and_largeBWP_switching_with_CA_T_T_2CC_1UE_eCPRI
    [Documentation]  CB008541_A_B201_4_SA_UEsupporting_Pcell_LBWP_SCell_SBWP_UEReestablish_for_TDD_FDD_2CC_CA
    [Setup]      Testcase Setup   ${IPHY_FILE_TC04}   ${scf_TC04}   ${wts_cfg_file_TC04}   ${no_of_cells_TC04}
    ${TEST_NAME}    Set Variable   B1_TC04
    set suite variable     ${TEST_NAME}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Regiter UE And Verify Scell Addition On High Data Traffic
    Verify RRC Reestablishment is Successfull
    Run keyword and continue on failure     Verify Counters incrementing RRE     300    200    1     25000    1
    Verify Scell Deactivation On Low Data Traffic
    Run keyword and continue on failure     Verify Counters decrementing RRE    300     0    0     0     0
    [Teardown]    Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...           AND   common Teardown


