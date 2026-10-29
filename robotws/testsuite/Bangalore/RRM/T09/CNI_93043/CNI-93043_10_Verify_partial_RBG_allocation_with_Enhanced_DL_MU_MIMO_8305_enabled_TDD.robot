*** Settings ***
Force Tags       CLOUD_5G_I_LOO_AP_LOOO      SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
...             CRT    5G_RAN_TDD    SBTS00    RAN_5G    5G_RAN    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: prapulla
...              :contact: Prapulla Bt (Nokia) <prapulla.bt@nokia.com>
...   In this CNI for current slot, Partial RBG can be allocated only after the consumption of all
...   the rbg's.  VONR should not allocated with partial RGB only.
...   This user scenario is to verify when the feature 8305 feature is enabled. Partial RBG can be allocated only
...   after the consumption of all the rbg's. VONR should not allocated with partial RGB only
...   in some cases it can get when entire vonr packet can be fit in that.
...   Note that this scenario is for TDD only.  FDD does not support enhanced MU MIMO.


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         resources/resource_93043.resource
Resource         ../../../resources/robot/ConformanceTest_keywords.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../CB007112/resources/CB007112_keywords.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/BBpooling_MuMIMO.robot
Resource         ../../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Library          ../../../resources/python/avg_dl_data.py
Resource         ../5GC000937/resources/5GC000937_Keywords.robot

Library          OperatingSystem

Suite Setup         Run keywords     Suite setup from scratch
...                 AND       5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_TC10_TMO.json
...                 AND   Perform SCF Delta Commissioning with Delta_configuration_93043_BSR_Package.json
...                 AND     Get and Update BSR SW via gitlab   ${BSR_SW_FILE}
...                 AND    Add routes
...                 AND    Update GNB R&D Parameter
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD- to comeup
...                 AND    log to console   loading cfg file....
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND    Check gNB Bulid


Suite Teardown       Run keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                  AND     Run Keyword and Ignore Error    Get Snapshot

Test Teardown       Run Keywords    Run Keyword and Ignore Error    Get Sos Report
...                 AND     Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup_TMO_93043.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${ue_id}               11
${UE_ID_2}             12
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${qfi_id}              1
${Q_O_ADD}             1
${RTP_COD}             1
${epc_log_path}        /tmp/
${START_UE_SA}         1
${END_UE_SA}           2
${DL_RATE}             100
${UL_RATE}             100
${start_DL_trfids}     1
${end_DL_trfids}       16
${Trf_rate_SA}         mbps
${scell_id}            0
${TRF_ID}              1
${r&d_parameter}       0x580786=1
${BSR_SW_FILE}    BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
${SCFC}=        ${CURDIR}/config/SCF/CNI93043_TC10_scf_GMC.xml
${AP_XML}=      ${CURDIR}/config/SCF/CNI93043_TC10_iphy.xml
@{pysical_cell_ids}    51


*** Test Cases ***
[1]CNI-93043_10_Verify_partial_RBG_allocation_with_Enhanced_DL_MU_MIMO_8305_enabled_TDD
    sleep   10s
    Set SRS Beam Position for muMIMO for UE pairing
    VONR-2UEs Cell1 Registration and VoNR Call should be Successful
    NonVONR-2UEs Cell1 Registration and 5qi-6 traffic should be Successful
    Capture TTI trace and verify mimo    ${LOG_PATH}     initial
    MultiUE Deregister should be Successful    1   2
    MultiUE Deregister should be Successful    3   4
    Tput verification for SA should be successful    ${START_UE_SA}  ${END_UE_SA}  ${DL_RATE}  ${UL_RATE}
    ...  ${start_DL_trfids}  ${end_DL_trfids}  ${Pdu_session_ID}  ${qfi_id}  ${Trf_rate_SA}  ${scell_id}

*** Keywords ***
Update GNB R&D Parameter
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

VONR-2UEs Cell1 Registration and VoNR Call should be Successful
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   VONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list}=   MultiUE Register should be Successful   1   2
    set test variable   ${crnti_list}
    MultiUE PDU Addition should be Successful   1   2  nw_id=1   pdu_id=2
    MultiUE PDU Modfication should be Successful   1   2   pdu_id=2   qosflows_to_add=2
    sleep   5s
    MultiUE PDU Modfication should be Successful   1   1   pdu_id=2   qosflows_to_add=3
    sleep   5s
    MultiUE PDU Modfication should be Successful   2   2   pdu_id=2   qosflows_to_add=3
    sleep   5s
    Run Keyword And Ignore Error    Trigger MultiUE VoNR DL Traffic for SA   1   2   pdu_id=2   trf_id=1
    ...  qfi_id=3   rtp_codec=custom
    Sleep   30s

NonVONR-2UEs Cell1 Registration and 5qi-6 traffic should be Successful
    log to console   NonVONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list}=   MultiUE Register should be Successful   3   4
    MultiUE Trigger DL Traffic for SA   3   4   Traffic_rate=mbps   dl_rate=150   pdu_id=1   trf_id=3   qfi_id=1
    Sleep   30s

Set SRS Beam Position for muMIMO for UE pairing
    Set Srs beam position    profile_id=1     quad_pos=0    sub_quad_pos=0
    Activate MIMO profile    ue_id=1    profile_id=1
    Set Srs beam position    profile_id=2     quad_pos=1    sub_quad_pos=3
    Activate MIMO profile    ue_id=2    profile_id=2
    Set Srs beam position    profile_id=3     quad_pos=2    sub_quad_pos=1
    Activate MIMO profile    ue_id=3    profile_id=3
    Set Srs beam position    profile_id=4     quad_pos=3    sub_quad_pos=2
    Activate MIMO profile    ue_id=4    profile_id=4
