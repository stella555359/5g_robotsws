*** Settings ***
Force Tags      CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1    CONFIGURED    5G_RAN    RAN_5G    CRT
...             CONFIGS_Bangalore/RRM/ET/ABOO_2Cells_Configs/ABOO_2Cells_B1_4_Config.yml   PY36

Documentation    :copyright: Nokia
...              :authors: Sruthi Jacob
...              :contact: sruthi.jacob@nokia.com
...     INTRODUCTION: CB007873 - Spillover - carrier aggregation - remaining system items of 5GC001390 and 5GC002255
...     5GC001390-FB	CB007873-D	Spillover - carrier aggregation - Advanced flow control - NSA
...
...     RRM domain:
...     This feature introduces This user scenario describes the successful operations, deletion or addition of CA association between FDD cell
...     as PCell and FR1-TDD cell as SCell. The NR relation of the NR Cell can be updated online and UEs already connected to that NR cell as
...     PSCell prior to the change in EN-DC mode shall not be impacted by the change, change will be applied only upon this UE leaves the FDD
...     PSCell (SgNB release or outgoing PSCell change) and connects to the FDD Cell again. New UE connecting to the FDD cell of the gNB DU
...     (either as new EN-DC setup or as incoming PSCell change) shall follow the new configuration.
...
...    Only if the feature CB007873 is activated and CA association between FDD cell and Scell are configured, UE can be configured with
...    carrier aggregation. Otherwise, UE cannot be configured with carrier aggregation.

Library        taf.transport.ssh           WITH NAME    taf_ssh
#Library        taf.wts.runner              WITH NAME    wtsrunner
Library        taf.wts.runner              WITH NAME    wtsrunner
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       robot/CB007873_Keywords.robot
#Resource       robot/CB007873_Keywords_D.robot
Library        luashark_tools.analyzer       WITH NAME       analyzer
#Library        ute_admin                         WITH NAME   ute_adm
Library        taf.collectors.core   WITH NAME   core
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       ../resources/robot/Setup_Env.robot
Resource       ../resources/robot/Airphone.robot
Resource       ../resources/robot/WTS_Runner_Keywords.robot
Library        ../resources/python/BIP_Capture.py
Library        ../resources/python/CPRT_Capture.py
Resource       ../resources/robot/PM_Counters.robot
Resource       ../resources/NPS/SWENG/robot/Counters.robot
Resource        ../resources/NPS/SWENG/Pm/pmc.robot
Library         ./resources/Lib/pcell_csv_analyser.py
Library         SSHLibrary
# Bring up the testline with basic configuration
#Suite Setup         Run keywords     Suite Setup From Scratch
#...               AND     add routes
#...               AND     Get swconfig files for gNB
#...               AND     Get swconfig files for AP
#...               AND     Full Commission SCF   CB007873-D_B1_4.xml
#...               AND     Sleep    2min
#...               AND     CB007873_Keywords.Start WTS Using WTS_Runner      ${wts_cfg_file}
#...               AND     Setup X2 Link
#
#Suite Teardown     Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
Suite Setup       Custom Suite Setup
Suite Teardown    Custom Suite Teardown

*** Variables ***
@{FIELDS_CellSetupReq}     cellBwpList_item_0     cellBwpList_item_1
${AP_FCT_BOARD_TYPE}           ${EMPTY}
${AP_ASP_BOARD_TYPE}           ${EMPTY}
${gnb_swconfig}    ${CURDIR}/config/gnb_swconfig.txt
${ap_swconfig}    ${CURDIR}/config/ap_swconfig.txt
@{CAslNone}          none
@{CAslFddFr1Tdd}     ca_Fdd_Fr1Tdd_Sa   #branch 0.800.xxx  (trunk)
@{Activated}     true
&{B_18}          carrierAggregationSupportList=${CAslNone}
&{B_20}          actGrflShd=${Activated}
&{B_17}          carrierAggregationSupportList=${CAslFddFr1Tdd}
${CrntiOK}        false
${Crnti}        true
${wts_cfg_file}     ${CURDIR}/config/CB007873_SA_NSA_L1BP.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID3}     1
${gw_ID2}     2
${gw_ID1}     3
${gw_ID4}     4
${Pdu_session_ID3}       3
${Pdu_session_ID2}       2
${Pdu_session_ID1}       1
${Pdu_session_ID4}       4
${UE_ID3}        3
${UE_ID4}        4
${UE_ID2}        2
${UE_ID1}        1
${QFI_ID}    1
${TRF_ID1}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${TRF_ID5}    5
${TRF_ID6}    6
${TRF_ID7}    7
${TRF_ID8}    8
${TRF_ID9}    9
${TRF_ID10}    10
${TRF_ID11}    11
${TRF_ID12}    12
${TRF_ID13}    13
${TRF_ID14}    14
${TRF_ID15}    15
${TRF_ID16}    16
${TRF_ID17}    17
${TRF_ID18}    18
${TRF_ID19}    19
${TRF_ID20}    20
${path}     /opt/iphy/epc_latest/uec_1.log
${UE}       UE3
${UE1}       UE1
${IPHY_XML}                     ${CURDIR}/config/iphy.xml
${file_path}                     ${CURDIR}/config/iphy.xml
${scf_path}                      testsuite/Bangalore/RRM/5GET_BLR/CB007873-D/config/
*** Test Cases ***
[1][1.0] CB007873_D_B1_4_Single_UE_Call_with_dynamic_data_split_over_PSCell and_Scell_blind_Scell_Activation_in_UL_DL_NSA_mode
#    Start Collecting Syslog     NAME=syslog_pcell
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    Set bler for CA Capable UE
    Attach UE and perform data transfer_CB007873D_B1_4   16    11    12    13   14   30
    Sleep  300s
    CB007873 Counters validation
    Perform Bler Activation  5
    Sleep  300s
    CB007873 Counters validation for SCell
    Sleep  10s
    Get_Snapshot_gNB
    CB007873_Keywords.Stop Capture CPRT
#    Stop Collecting Syslog    NAME=syslog_pcell


*** Keywords ***
# Bring up the testline with basic configuration
Custom Suite Setup
  ...              Run keywords     Suite setup from scratch
  ...               AND    CB007873_Keywords.add routes
  ...               AND    Add GNB RadParam for PDU_Enabled and SchedDelay_Disabled
  ...               AND    Add AP RadParam
  ...               AND    Reboot gNB System Module from Console and check Airscale is ready
  ...               AND    Start Default Logging    output_dirpath=${LOG_PATH}
  ...               AND    Sleep    2min
  ...               AND    CB007873_Keywords.Start WTS Using WTS_Runner      ${wts_cfg_file}
  ...               AND     Setup X2 Link

Custom Suite Teardown
  ...                 Run Keywords    Revert GNB RadParam
  ...                 AND     Revert AP RadParam
  ...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
  ...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}



Add AP RadParam
    Log To Console  Adding AP RadParam to swconfig...
    SSHLibrary.open connection    ${AP_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    SSHLibrary.execute command    echo "0x70686=0" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    echo "0x70673=1" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection

Revert GNB RadParam
    Log To Console  Removing GNB RadParam from swconfig...
    SSHLibrary.open connection    ${GNB_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig_original.txt /ffs/run/swconfig.txt
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection

Revert AP RadParam
    Log To Console  Removing GNB RadParam from swconfig...
    SSHLibrary.open connection    ${AP_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig_original.txt /ffs/run/swconfig.txt
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection
