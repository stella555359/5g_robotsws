*** Settings ***
Force Tags       CLOUD_5G_I_LOO_AP_LOOO      SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
...             CRT    5G_RAN_FDD    SBTS00    RAN_5G    5G_RAN    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: prapulla
...              :contact: Prapulla Bt (Nokia) <prapulla.bt@nokia.com>
...   In this CNI for current slot, Partial RBG can be allocated only after the consumption of all
...   the rbg's.  VONR should not allocated with partial RGB only.
...   This user scenario is to verify partial RBG allocation behaviour with 8917 features enabled.
...   In current slot, at least one partial RBG must be allocated if assignment of any free partial
...   RBG is sufficient to satisfy any UE's remaining needs,
...   then L2 PS shall assign it to one such UE, irrespective of PRB allocation direction
...   or UE classification.otherwise, L2 PS shall assign partial RBG to UE with lowest priority
...   among UEs whose needs have not been satisfied by allocation made in this slot
...   Requirement ID - 5G_UP_ALG_16601


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         resources/resource_93043.resource
Resource         ../resources/robot/ConformanceTest_keywords.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../CB007112/resources/CB007112_keywords.robot
Resource         ../resources/robot/common_log_collection.robot


Library          OperatingSystem

Suite Setup         Run keywords     Suite setup from scratch
...                 AND       5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_TC8_TMO.json
...                 AND    Change IPHY File Value      AHLOA       5345
...                 AND    Add routes
...                 AND    Update GNB R&D Parameter
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD to comeup
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
${UE_ID}               11
${UE_ID_2}             12
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${Q_O_ADD}             1
${RTP_COD}             1
${START_UE_SA}         11
${END_UE_SA}           12
${DL_RATE}             100
${UL_RATE}             100
${start_DL_trfids}     1
${end_DL_trfids}       16
${QFI_ID}              1
${Trf_rate_SA}         mbps
${scell_id}            0
${TRF_ID}              1
${epc_log_path}        /tmp/
${r&d_parameter}       0x580786=1
${SCFC}=                   Bangalore/RRM/ET/CNI_93043/CNI93043_TC8_scf.xml
${AP_XML}=                 Bangalore/RRM/ET/CNI_93043/CNI93043_TC8_iphy.xml
@{pysical_cell_ids}    60


*** Test Cases ***
[1]CNI-93043_8_Verify_partial_RBG_allocation_with_8917_enabled_FDD
    VONR-2UEs Cell1 Registration and VoNR Call should be Successful
    NonVONR-2UEs Cell1 Registration and 5qi-6 traffic should be Successful
    Capture TTI trace and verify 8917    ${LOG_PATH}     initial
    sleep    5s
	MultiUE Deregister should be Successful    11   14
    Tput verification for SA should be successful    ${START_UE_SA}  ${END_UE_SA}  ${DL_RATE}  ${UL_RATE}
    ...  ${start_DL_trfids}  ${end_DL_trfids}  ${Pdu_session_ID}  ${QFI_ID}  ${Trf_rate_SA}  ${scell_id}

*** Keywords ***
Update GNB R&D Parameter
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

VONR-2UEs Cell1 Registration and VoNR Call should be Successful
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   VONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list}=   MultiUE Register should be Successful   13   14
    set test variable   ${crnti_list}
    MultiUE PDU Addition should be Successful   13   14  nw_id=1   pdu_id=2
    MultiUE PDU Modfication should be Successful   13   13   pdu_id=2   qosflows_to_add=1
    MultiUE PDU Modfication should be Successful   14   14   pdu_id=2   qosflows_to_add=1
    MultiUE PDU Modfication should be Successful   13   13   pdu_id=2   qosflows_to_add=2
    Sleep   5s
    MultiUE PDU Modfication should be Successful   14   14   pdu_id=2   qosflows_to_add=2
    sleep   5s
    MultiUE PDU Modfication should be Successful   13   13   pdu_id=2   qosflows_to_add=3
    sleep   5s
    MultiUE PDU Modfication should be Successful   14   14   pdu_id=2   qosflows_to_add=3
    Trigger MultiUE VoNR DL Traffic for SA   13   14   pdu_id=2   trf_id=1   qfi_id=3   rtp_codec=custom
    Sleep   30s
NonVONR-2UEs Cell1 Registration and 5qi-6 traffic should be Successful
    log to console   NonVONR-2UEs Cell1 Attach trigerring now...
    ${crnti_list}=   MultiUE Register should be Successful   11   12
    MultiUE Trigger DL Traffic for SA   11   12   Traffic_rate=mbps   dl_rate=50   pdu_id=1   trf_id=3   qfi_id=1

Attach UE
   [Arguments]    ${UE_ID}
    LTE Attach should be Successful    ${UE_ID}
    UE Attach should be Successful    ${UE_ID}

Change IPHY File Value
    [Arguments]    ${RU_TYPE}   ${GSCN}
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
        ${c1}    Set Variable    cat ${file_path}|grep -m 9 "card"|tail -n 3|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
    Run    ${c1}${c2}

    ${c1}    Set Variable    cat ${file_path}|grep -m 12 "GSCN"|tail -n 3|awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  120s
