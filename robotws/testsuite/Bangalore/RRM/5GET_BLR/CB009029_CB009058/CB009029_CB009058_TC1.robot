*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LOOO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

Library          ./../CB007859/resources/python/lib.py
Library          ./../CB007859/resources/python/read_csv.py
Resource         CB009029_Resource.robot
Resource         ../CB007145/resources/common/CB007145_Resource.robot
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     BuiltIn.Log     ${SCFC}
...                 AND     Prepare TL with config files
...                 AND     Suite setup from scratch
...                 AND     Start Default Logging Gnb ASIL_ABIO
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO

Documentation    :copyright: Nokia
...              :authors: Ashutosh
...              :contact: ashutosh.k.jaiswal@nokia.com
...     	user creates the configuration plan (Refer US CB009058-B#1) and activate all cells.
...        Test is done on ABIO configured with 3 cells on one Loki deployed in 100MHz bandwidth and with  16 SA UEs per cell.
...        , Cell 1 should the maximum number of PDSCH/PUSCH UEs per slot per cell is 16




*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_multiue.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${1}
${end_ue_id1}      ${18}
${sa_ue_id2}      ${19}
${end_ue_id2}      ${36}
${sa_ue_id3}      ${37}
${end_ue_id3}      ${54}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC1

${SCFC}=                   ${CURDIR}/config/CB009029_TC1/SCF_9029_TC1.xml
${AP_XML}=                 ${CURDIR}/config/CB009029_TC1/IPHY_9029_TC1.xml


*** Test Cases ***
[1]CB009058_B_01_three_L2_Subpoll_each_L2_subpool_one_cell_on_half_ABIO
    set test variable      ${LOG_PATH}
    log to console   "UE attach trigerring now"

    MultiUE Register should be Successful    ${sa_ue_id1}    ${end_ue_id1}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}    ${end_ue_id1}   Traffic_rate=mbps     dl_rate=150
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${end_ue_id1}   Traffic_rate=mbps     ul_rate=50
    sleep     500s
    Verify fdm max ul and dl Counters   16   16
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${end_ue_id1}
    MultiUE Register should be Successful    ${sa_ue_id2}    ${end_ue_id2}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id2}    ${end_ue_id2}   Traffic_rate=mbps     dl_rate=150
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id2}    ${end_ue_id2}   Traffic_rate=mbps     ul_rate=50
    sleep     500s
    Verify fdm max ul and dl Counters   16   16
    MultiUE Deregister should be Successful   ${sa_ue_id2}    ${end_ue_id2}
    MultiUE Register should be Successful    ${sa_ue_id3}    ${end_ue_id3}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id3}    ${end_ue_id3}   Traffic_rate=mbps     dl_rate=150
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id3}    ${end_ue_id3}   Traffic_rate=mbps     ul_rate=50
    sleep     500s
    Verify fdm max ul and dl Counters   16   16
    MultiUE Deregister should be Successful   ${sa_ue_id3}    ${end_ue_id3}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

