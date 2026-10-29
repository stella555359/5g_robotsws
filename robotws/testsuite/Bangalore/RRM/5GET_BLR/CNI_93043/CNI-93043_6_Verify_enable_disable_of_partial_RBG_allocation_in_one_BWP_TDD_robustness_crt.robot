*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    5G_RAN_TDD    SBTS00    RAN_5G    5G_RAN    CONFIGURED


Documentation    :copyright: Nokia
...              :authors: Chaithanya
...              :contact: chaithanya.h_s@nokia.com
...   In this CNI for current slot, Partial RBG can be allocated only after the consumption of all
...   the rbg's.  VONR should not allocated with partial RGB only.
...   This user scenario is to verify partial RBG allocation behaviour  by  enabling  and disabling
...   9426 with CB008955 feature enabled.In current slot, Partial RBG can be allocated only after
...   the consumption of all the rbg's.  VONR should not allocated with partial RGB only.
...   Requirement: 5G_UP_ALG_21521

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         resources/resource_9426_8955.resource
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         resources/resource_93043.resource
Resource         ../resources/robot/ConformanceTest_keywords.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../CB007112/resources/CB007112_keywords.robot
Resource         ../resources/robot/common_log_collection.robot


Suite Setup         Run keywords    Suite setup from scratch
...                 AND    Add routes
...                 AND    Update GNB R&D Parameter
...                 AND    resource_9426_8955.Perform SCF Delta Commissioning with Delta_Configuration_high2low_9426_8955.json
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD to comeup
...                 AND    Start Default Logging  output_dirpath=${LOG_PATH}
...                 AND    log to console   loading cfg file....
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND    Check gNB Bulid

Suite Teardown       Run keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                  AND     Run Keyword and Ignore Error    Get Snapshot

Test Teardown    Run Keywords    Run Keyword and Ignore Error    Get Sos Report
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup_80mhz_tc06_TMO.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}               11
${UE_ID_2}             12
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${qfi_id}              1
${Q_O_ADD}             1
${RTP_COD}             1
${epc_log_path}        /tmp/
${START_UE_SA_sbwp}    3
${END_UE_SA_sbwp}      4
${DL_RATE}             100
${UL_RATE}             100
${start_DL_trfids}     1
${end_DL_trfids}       16
#${QFI_ID}              1
${Trf_rate_SA}         mbps
${scell_id}            0
${TRF_ID}              1
${r&d_parameter}       0x580786=1
@{pysical_cell_ids}    51


*** Test Cases ***
[1]CNI-93043_6_Verify_enable_disable_of_partial_RBG_allocation_in_one_BWP_TDD_robustness
   VONR-2UEs Cell1 Registration and VoNR Call should be Successful
   NonVONR-2UEs Cell1 Registration and 5qi-6 traffic should be Successful
   Capture TTI trace and verify BufferedBytessize with tbSize    ${LOG_PATH}    initial

   MultiUE Deregister should be Successful    1    2
   MultiUE Deregister should be Successful    3    5
   resource_9426_8955.Perform SCF Delta Commissioning with Delta_Conf_Enable_Random.json
   Sleep   10s

   VONR-2UEs Cell1 Registration and VoNR Call should be Successful
   NonVONR-2UEs Cell1 Registration and 5qi-6 traffic should be Successful
   Capture TTI trace and verify BufferedBytessize with tbSize    ${LOG_PATH}     initia

   Capture TTI trace and verify RBG Randomization    ${LOG_PATH}     initial    ${crnti_list_vonr}

   MultiUE Deregister should be Successful    1   2
   MultiUE Deregister should be Successful    3   5

   resource_9426_8955.Perform SCF Delta Commissioning with Delta_Conf_disable_Random.json
   Sleep   10s
   VONR-2UEs Cell1 Registration and VoNR Call should be Successful
   NonVONR-2UEs Cell1 Registration and 5qi-6 traffic should be Successful
   Capture TTI trace and verify BufferedBytessize with tbSize    ${LOG_PATH}     initia

   MultiUE Deregister should be Successful    1   2
   MultiUE Deregister should be Successful    3   5
   resource_9426_8955.Perform SCF Delta Commissioning with Delta_Conf_Enable_Random.json
   Sleep   10s
   VONR-2UEs Cell1 Registration and VoNR Call should be Successful
   NonVONR-2UEs Cell1 Registration and 5qi-6 traffic should be Successful
   Capture TTI trace and verify BufferedBytessize with tbSize    ${LOG_PATH}     initia

   Capture TTI trace and verify RBG Randomization    ${LOG_PATH}     initial    ${crnti_list_vonr}

   MultiUE Deregister should be Successful    1   2
   MultiUE Deregister should be Successful    3   5
   Tput verification for SA should be successful    ${START_UE_SA_sbwp}  ${END_UE_SA_sbwp}  ${DL_RATE}  ${UL_RATE}
   ...  ${start_DL_trfids}  ${end_DL_trfids}  ${Pdu_session_ID}  ${QFI_ID}  ${Trf_rate_SA}  ${scell_id}

*** Keywords ***
Update GNB R&D Parameter
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt


VONR-2UEs Cell1 Registration and VoNR Call should be Successful
    log to console   VONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list_vonr}=   MultiUE Register should be Successful   1   2
    set test variable   ${crnti_list_vonr}
    MultiUE PDU Addition should be Successful   1   2  nw_id=1   pdu_id=2
    MultiUE PDU Modfication should be Successful   1   2   pdu_id=2   qosflows_to_add=1
    MultiUE PDU Modfication should be Successful   1   2   pdu_id=2   qosflows_to_add=2
    Sleep   5s
    MultiUE PDU Modfication should be Successful   1   1   pdu_id=2   qosflows_to_add=3
    Sleep   5s
    MultiUE PDU Modfication should be Successful   2    2   pdu_id=2   qosflows_to_add=3
    Sleep   5s
    Trigger MultiUE VoNR DL Traffic for SA   1   2   pdu_id=2   trf_id=1   qfi_id=3   rtp_codec=custom
    Sleep   30s

NonVONR-2UEs Cell1 Registration and 5qi-6 traffic should be Successful
    log to console   NonVONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list}=   MultiUE Register should be Successful   3   5
    set test variable   ${crnti_list}
    MultiUE Trigger DL Traffic for SA   3   5   Traffic_rate=mbps   dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
    Sleep   30s


