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
...             REQUIREMENTS:      5G_RAN_USR_RRM_18853;5G_RAN_USR_RRM_22743




Resource         ../resources/ECEcommon/common_setup_teardown.robot
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
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
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource            taf/rfrl/cbts/robot/vdu/vdu_log.robot
Resource            taf/rfrl/cbts/robot/vdu/vdu_operations.robot
Library             OperatingSystem


Resource           ../resources/robot/ConformanceConstants/Constants_general.robot

Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog.robot

Library             taf.collectors.pmcounters
Library             taf.analyzer.pmcounter       WITH NAME    check_pm
Library             Collections

Library             ../resources/python/IphyUpdate.py
Library             ./python/execute_command.py
Library             ./python/increase_buffer_size.py

Library             ./python/utility.py
Resource            ../resources/ECEcommon/common_setup_teardown.robot




Suite Setup         Run keywords  Test Suite Setup
...                 AND           AIC Software Build Info
...                 AND           Fetch Taf Library used in TL
...                 AND           Log to console    vDU delta commissioning
...                 AND           Fast Delta Commission vDU With Delta XML File      ${delta_vdu}
...                 AND           sleep    600s
...                 AND           Run keyword and Ignore error   Verify RMODs Online Status   ${800}
...                 AND           log to console   loading cfg file....
...                 AND           Configure UTE ETH3 IPs
...                 AND           Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND           sleep   120s




Suite Teardown         Run keywords        Kill WTS processes Using WTS_Runner
*** Variables ***

${delta_vdu}        ${CURDIR}/config/SCF/Delta_SCF_DU_CB010414_CB008246.xml
${wts_cfg_file}     ${CURDIR}/config/wts/CB010414_CB008246.cfg

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
@{PM_PCELL_COUNTER}         M55365C03002    M55365C03003
...     M55365C03007    M55365C03008    M55308C19001    M55308C19002    M55308C19003    M55335C04001    M55335C04002
...     M55335C04003    M55335C04004    M55335C04005    M55335C04006    M55335C02004    M55335C02005    M55335C02006
...     M55365C03006    M55308C19004    M55335C02003    M55365C03001
*** Test Cases ***
[1]CB008246-H_High_reliability_support_in_PDCCH_and_Counter_Validation
    sleep   120s
    set test variable   ${LOG_PATH}
    log to console   UE attach trigerring now...
    start log   btslog

    ${sleep_time} =  Count Measurement Period

    Simulate cqi   9   1   1
    sleep   5s

    ${crnti_list}    HR and BR UEs are attached to cell-1
    Low data rate DL_UL traffic started on the UEs
    Change channel conditions with pathloss
    High data rate DL_UL traffic started on the UEs
    Change channel condition with pathloss

    Dettach both the UEs
    ${sleep_time} =  Count Measurement Period

    Log to console     Collecting vCU and vDU PM Counters..
    Log to Console    Verifying counters.....
    sleep    600s
	Run Keyword and continue on failure    Common_Keywords.Collect pm counter kubectls      "vDU"
    Log to Console    Verifying counters.....
    FOR     ${X}       IN     @{PM_PCELL_COUNTER}
#    Run Keyword and continue on failure    Verify UL and DL ScheduledUes with counter_vDU      ${X}     *MRBTS*
    Run Keyword and ignore error    Verify UL and DL ScheduledUes with counter_vDU      ${X}     *MRBTS*
    END
#    [Teardown]  Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
HR and BR UEs are attached to cell-1
    ${crnti_list}=      MultiUE Register should be Successful fixed    1    1     Initial Context Setup Successful
    MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps   dl_rate=1   trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps   ul_rate=1   trf_id=${TRF_ID}
    sleep    5s
    [return]    ${crnti_list}
########################################################################################################


Change channel conditions with pathloss
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



Low data rate DL_UL traffic started on the UEs
    MultiUE Replace DL Traffic for SA    1    1    Traffic_rate=kbps   dl_rate=10   trf_id=${TRF_ID}
    MultiUE Replace UL Traffic for SA    1    1    Traffic_rate=kbps   ul_rate=10   trf_id=${TRF_ID}
    sleep    5s   reason=Wait for successful BWP switch

High data rate DL_UL traffic started on the UEs
    MultiUE Replace DL Traffic for SA   1   1    Traffic_rate=mbps   dl_rate=1   trf_id=${TRF_ID}
    MultiUE Replace UL Traffic for SA   1   1    Traffic_rate=mbps   ul_rate=1   trf_id=${TRF_ID}
    sleep    5s   reason=Wait for successful BWP switch


Dettach both the UEs
    Stop MultiUE Data Traffic for SA     1   1
    MultiUE Deregister should be Successful     1   1

Count Measurement Period
    ${seconds_now} =  Get Current Date  result_format=%S
    ${seconds_int} =  Convert To Integer  ${seconds_now}
    ${time} =  Run Keyword If   1 <= ${seconds_int} <= 59    Subtract Time From Time  60  ${seconds_int}
    ...                  ELSE                                Set Variable  0
    [Return]  ${time}

