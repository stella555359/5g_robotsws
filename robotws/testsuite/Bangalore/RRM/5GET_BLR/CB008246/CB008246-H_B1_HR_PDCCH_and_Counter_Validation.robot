*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 vaibhav.3.tyagi@nokia.com
...             maintainer:             vaibhav.3.tyagi@nokia.com
...
...             INTRODUCTION:      This user scenario is aimed at verifying HR PDCCH Aggregation level (AL) counters.
...             TEST SET NAME:     CB008246_HB5_TC1_IWK_with_PSBWP.robot
...             TESTING SPLIT:     See CB008246-H testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-H CFAM
...

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008246_resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Update GSCN in AP Iphy Xml     gscn=7867
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=J_31.xml
...                 AND     sleep    10s
...                 AND     gnb.Perform gNB reboot
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

*** Variables ***
${wts_cfg_file}    ${CURDIR}/config/wts/basic_cfg-HB1-PSBWP-TDD.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${TEST_NAME}        test_case
${st_ue_id}      1
${en_ue_id}      1
${pathloss_start_dB}        75
${pathloss_end_dB}      130
${PM_PCELL_COUNTER1}        M55365C06002
${PM_PCELL_COUNTER2}        M55365C06001
${PM_PCELL_COUNTER3}        M55365C06007
${PM_PCELL_COUNTER4}        M55365C06008
${PM_PCELL_COUNTER5}        M55365C03002
${PM_PCELL_COUNTER6}        M55365C03003
${PM_PCELL_COUNTER7}        M55365C03007
${PM_PCELL_COUNTER8}        M55365C03008
${PM_PCELL_COUNTER9}        M55308C19001
${PM_PCELL_COUNTER10}       M55308C19002
${PM_PCELL_COUNTER11}       M55308C19003
${PM_PCELL_COUNTER12}       M55335C04001
${PM_PCELL_COUNTER13}       M55335C04002
${PM_PCELL_COUNTER14}       M55335C04003
${PM_PCELL_COUNTER15}       M55335C04004
${PM_PCELL_COUNTER16}       M55335C04005
${PM_PCELL_COUNTER17}       M55335C04006
${PM_PCELL_COUNTER18}       M55335C02004
${PM_PCELL_COUNTER19}       M55335C02005
${PM_PCELL_COUNTER20}       M55335C02006
${PM_PCELL_COUNTER21}       M55365C03006
${PM_PCELL_COUNTER22}       M55308C19004
${PM_PCELL_COUNTER23}       M55335C02003
${PM_PCELL_COUNTER24}       M55365C03001

*** Test Cases ***
[1]CB008246-H High reliability support in PDCCH and Counter Validation
    set test variable   ${LOG_PATH}
    log to console   UE attach trigerring now...
    start log   btslog
    Wait until the next Measurement Period starts
    Simulate cqi   9   1   1
    ${crnti_list}    HR and BR UEs are attached to cell-1
    Low data rate DL_UL traffic started on both UEs for switching to PSBWP
    start log   cprt
    Change channel conditions when UEs are in PSBWP
    High data rate DL_UL traffic started on both UEs for switching from PSBWP
    Change channel conditions when UEs are in LBWP
    ${path_CPRT_1}    Stop log    cprt    test_scenario=CPRT1
    stop log   btslog
    Dettach both the UEs
    Wait until the current Measurement Period stops
    Verify PDCCH_Counters      1

*** Keywords ***
HR and BR UEs are attached to cell-1
    ${crnti_list}=      MultiUE Register should be Successful fixed    1    1     Initial Context Setup Successful
    MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps   dl_rate=1   trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps   ul_rate=1   trf_id=${TRF_ID}
    sleep    5s
    [return]    ${crnti_list}

Change channel conditions when UEs are in PSBWP
    Introduce pathloss   1   1
    Activate pathloss_for_UE   1   1
    Simulate cqi   1   1   1
    Simulate bler_testmode   1   1
    Vary pathloss       pathloss_start_dB=${pathloss_start_dB}+${1}     pathloss_end_dB=${pathloss_end_dB}     pathloss_step_dB=1
    Vary pathloss       pathloss_start_dB=${pathloss_end_dB}    pathloss_end_dB=${pathloss_start_dB}    pathloss_step_dB=-1
    sleep    2s
    Simulate cqi   13   1   1
    Vary pathloss       pathloss_start_dB=${pathloss_start_dB}+${1}     pathloss_end_dB=${pathloss_end_dB}     pathloss_step_dB=1
    Vary pathloss       pathloss_start_dB=${pathloss_end_dB}    pathloss_end_dB=${pathloss_start_dB}    pathloss_step_dB=-1
    sleep    2s
    Deactivate bler_testmode_for_UE   1   1
    sleep    3s

Change channel conditions when UEs are in LBWP
    Simulate cqi   1   1   1
    Simulate bler_testmode   1   1
    Vary pathloss       pathloss_start_dB=${pathloss_start_dB}+${1}     pathloss_end_dB=${pathloss_end_dB}     pathloss_step_dB=1
    Vary pathloss       pathloss_start_dB=${pathloss_end_dB}    pathloss_end_dB=${pathloss_start_dB}    pathloss_step_dB=-1
    sleep    2s
    Simulate cqi   13   1   1
    Vary pathloss       pathloss_start_dB=${pathloss_start_dB}+${1}     pathloss_end_dB=${pathloss_end_dB}     pathloss_step_dB=1
    Vary pathloss       pathloss_start_dB=${pathloss_end_dB}    pathloss_end_dB=${pathloss_start_dB}    pathloss_step_dB=-1
    sleep    2s
    Deactivate bler_testmode_for_UE   1   1
    sleep    3s

Low data rate DL_UL traffic started on both UEs for switching to PSBWP
    MultiUE Replace DL Traffic for SA    1    1    Traffic_rate=kbps   dl_rate=10   trf_id=${TRF_ID}
    MultiUE Replace UL Traffic for SA    1    1    Traffic_rate=kbps   ul_rate=10   trf_id=${TRF_ID}
    sleep    5s   reason=Wait for successful BWP switch

High data rate DL_UL traffic started on both UEs for switching from PSBWP
    MultiUE Replace DL Traffic for SA   1   1    Traffic_rate=mbps   dl_rate=1   trf_id=${TRF_ID}
    MultiUE Replace UL Traffic for SA   1   1    Traffic_rate=mbps   ul_rate=1   trf_id=${TRF_ID}
    sleep    5s   reason=Wait for successful BWP switch


Dettach both the UEs
    Stop MultiUE Data Traffic for SA     1   1
    MultiUE Deregister should be Successful     1   1

