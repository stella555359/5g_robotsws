*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CIT    CDRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS23R1    SBTS23R2    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Prakhar
...              :contact: prakhar.rastogi@nokia.com

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
#Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008941_resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
#...                 AND     Download MCShark To UTE
...                 AND     Add RD Parameters To GNB Swconfig File     ${RD_PARAM_8124}
...                 AND    Perform SCF Delta Commissioning with tc20.json
...                 AND     sleep    180
...                 AND     Run     ssh toor4nsn@192.168.200.1 reboot
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    180
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report
#...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
#${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_APoABIO_32_UEs.cfg
${wts_cfg_file}     ${CURDIR}/config/wts/t20.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${Large_BWP}      bwp:.*1\\sfd
${PS_BWP}      bwp:.*2\\sfd
@{syslog_regex_bwp}     DCI11   DCI01
@{syslog_regex_csi}     CSI-RS sending   PER-CSI-PUCCH receiving
${TEST_NAME}        test_case
${IPHY_FILE}                    ${CURDIR}/config/wts/20_iphy.xml

*** Test Cases ***

[1][1.0]_CB008941_A16_1_UL_Fragmentaion_is_enabled_and_Successful_SA_call_with_multiple_UEs_in_TDD_FDBF_Frame_structure_semistatic_1_4_with_CB008124
    [Documentation]   This user scenario validates system behavior in case when UL UP dynamic fragmentation is
    ...         activated, the data transmission in eCPRI uplink contains the NR IQ of scheduled PRBs for TDD FR1
    ...         deployments, the NR carrier supports UL PRB dynamic fragmentation.If UP fragmentation can be supported
    ...         by only partial streams of a single RU, operator can try to configure more cells to verify the case
    ...         that configured streams more than the streams with UP fragmentation supported
    Increase Buffer Size for VM and IPHY
    Read Cellsetup msg      ${cprt_log}[cprt]/NODECPRT_GNB.pcap
    set test variable      ${LOG_PATH}
    UE Beamforming Profile And Association For 2 Beams SA    ${34}
    BuiltIn.Run Keyword And Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
    log to console   UE attach trigerring now...
#    Start Log    bip
    ${crnti_list_1}=      MultiUE Register should be Successful    1  15
#    ${scen1}     Stop Log     bip     test_scenario=attach_1_8
#
#    Start Log    bip
#    ${crnti_list_2}=      MultiUE Register should be Successful    9  15
#    ${scen2}     Stop Log     bip    test_scenario=attach_9_15

    MultiUE Trigger DL Traffic for SA    1  15    Traffic_rate=mbps     dl_rate=1          trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    1  15    Traffic_rate=mbps     ul_rate=1          trf_id=${TRF_ID}
    sleep   60s
    Validate UL Traffic For MultiUE for SA    1  15     1
    Validate DL Traffic For MultiUE for SA    1  15     1


    ${ue_rel}   Create List   2  4  6  8  10  12  14
    Selective UE Deregister should be Successful        ${ue_rel}

    ${crnti_list_1}=      MultiUE Register should be Successful    16   22
    MultiUE Trigger DL Traffic for SA    16   22    Traffic_rate=mbps     dl_rate=1          trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    16   22   Traffic_rate=mbps     ul_rate=1          trf_id=${TRF_ID}
    sleep   60s
    Validate UL Traffic For MultiUE for SA    16  22     1
    Validate DL Traffic For MultiUE for SA    16  22     1


    ${ue_rel}   Create List   16   18   20

#    Start Log    bip
#    Selective UE Deregister should be Successful        ${ue_rel}
#    ${scen1}     Stop Log     bip    test_scenario=attach_9_15
    ${crnti_list_2}=      MultiUE Register should be Successful    23  23
    MultiUE Trigger DL Traffic for SA    23   23    Traffic_rate=mbps      dl_rate=1          trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    23   23     Traffic_rate=mbps     ul_rate=1          trf_id=${TRF_ID}
    sleep   60s
    Validate UL Traffic For MultiUE for SA    23   23     1
    Validate DL Traffic For MultiUE for SA    23   23     1


    ${crnti_list_3}=      MultiUE Register should be Successful    24  34
    MultiUE Trigger DL Traffic for SA    24   34    Traffic_rate=mbps      dl_rate=1          trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    24   34     Traffic_rate=mbps     ul_rate=1          trf_id=${TRF_ID}
    sleep   60s
    Validate UL Traffic For MultiUE for SA    24   34     1
    Validate DL Traffic For MultiUE for SA    24   34     1





*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

