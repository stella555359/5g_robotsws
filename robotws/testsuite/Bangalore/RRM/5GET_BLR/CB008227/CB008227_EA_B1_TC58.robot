*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

Resource         CB008227_Resource.robot
Resource         ../CB008285/CB008285_Resource.robot
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     Suite setup from scratch
...                 AND     Configure UTE ETH3 IPs
...                 AND     Prepare TL with SCF change
...                 AND     Start Default Logging Gnb ASIL_ABIO
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep   2s

Suite Teardown      Run keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO

Documentation
...
...             author:           Madhukara M V
...             maintainer:       madhukara.m_v@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behavior that slice aware scheduler
...                               works fine with NBR Congestion control. It depriotize the bearer at slice
...								  Level qutoa that at the cell level with maxnbrtraffilimit=10
...                               	 	SLICE       MINquota	Maxquota	PLMN
...                               UE1	SNSSAI-1	10	        20	        311,489
...                               UE2	SNSSAI-2	20	        20	        311,490
...                               UE3	SNSSAI-3	5	        10	        311,491
...
...                               Bearer1: 5QI-6 : NRDRB_MAC-5 : NBR Bearer, nbrdl: 200 , nbrul: 40, PLMN1: 311,489
...                               Bearer2: 5QI-7 : NRDRB_MAC-2 : nonGBR Bearer, PLMN2: 311,490
...                               Bearer2: 5QI-8 : NRDRB_MAC-2 : nonGBR Bearer, PLMN3: 311,491
...
...                               NRDRB-1 ---> NRDRB_MAC-1 : nbrdl: 100 , nbrul: 40
...
...                               UE1 with 5QI-6 and 5QI-7
...                               UE2 with 5QI-6 and 5QI-7
...                               UE3 with 5QI-6 and 5QI-7
...
...                               NRDRB-1 ---> NRDRB_MAC-1 : nbrdl: 100 , nbrul: 40
...                               UE1
...                               5QI-6 ---> nrDrbDN:NRDRB-11 --> nrDrbMacDN: NRDRB_MAC-5(with nbr configuration)
...                               5QI-7 ---> use default: NRDRB-1 due to cannot find nrDrb5Qi for 5QI: 7
...
...                               UE2
...                               5QI-6 ---> use default: NRDRB-1 due to cannot find nrDrb5Qi for 5QI: 6
...                               5QI-7 ---> nrDrbDN:NRDRB-12 --> nrDrbMacDN: NRDRB_MAC-2 (without nbr cofiguration)
...
...                               UE3
...                               5QI-6 ---> use default: NRDRB-1 due to cannot find nrDrb5Qi for 5QI: 6
...                               5Qi-7 ---> use default: NRDRB-1 due to cannot find nrDrb5Qi for 5QI: 7
...
...
...
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20732



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/TC42_basic_setup_3PLMN.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${1}
${sa_ue_id2}      ${2}
${sa_ue_id3}      ${3}
${sa_ue_id4}      ${4}
${nwslice_ID}   1

${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${QFI_ID1}     2
${QFI_ID2}     3
${QFI_ID3}     4

${TEST_NAME}     TC58
${CELL_ID}    3

${SCFC}=                        ${CURDIR}/config/TC42_SCFC_SLICE_NBR_CONG.xml
#${AP_XML}=                      ${CURDIR}/config/TC45_IPHY.xml



*** Test Cases ***
[1]CB008227-EA#B1_TC58_NBR_interworking_with_slice_Aware_Scheduler_and_NBR_congestion
    [Tags]     QC_xxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts
    log to console   "SA UE attach with NBR Bearers are trigerring now"
#Step 1. Attach SA UE's with 1 default Bearer and 3 NBR Beareres
    Link SCOUT SCF to Configuration ID for Reporting
    Start Log    cprt
    MultiUE Register should be Successful with diff slice    ${sa_ue_id1}     ${sa_ue_id3}
    sleep     2s
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id3}    ${Pdu_session_ID}    ${QFI_ID1}
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    MultiUE Trigger DL Traffic for SA   ${sa_ue_id1}    ${sa_ue_id3}    Traffic_rate=mbps   dl_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA   ${sa_ue_id1}    ${sa_ue_id3}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    sleep   10s
    Validate DL Traffic For all UEs   43   43   22
    Validate UL Traffic For all UEs   77   52    76
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
#Update counter values according to testing
    Verify Any Counters In File
    ...  M55139C03509  1500  SA_DU_DRB_NBR_DL
    ...  M55139C03510  1500  SA_DU_DRB_NBR_UL
    ...  M55300C12010  < 1000  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    MultiUE Deregister should be Successful    ${sa_ue_id1}    ${sa_ue_id3}

*** Keywords ***
MultiUE Register should be Successful with diff slice
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    FOR     ${ue_id}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
       UE Register should be Successful   ue_id=${ue_id}     pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}      gw_id=${gw_ID}
       ${nwslice_ID}=      Evaluate       ${nwslice_ID}+1
       ${gw_ID}=      Evaluate       ${gw_ID}+1
    END

Validate DL Traffic For all UEs
    [Arguments]    ${ue1_tput}    ${ue2_tput}    ${ue3_tput}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id1}     dl_rate=${ue1_tput}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id2}     dl_rate=${ue2_tput}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id3}     dl_rate=${ue3_tput}   pdu_id=1    qfi_id=${QFI_ID}

Validate UL Traffic For all UEs
    [Arguments]    ${ue1_tput}    ${ue2_tput}    ${ue3_tput}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=${ue1_tput}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id2}     ul_rate=${ue2_tput}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id3}     ul_rate=${ue3_tput}   pdu_id=1    qfi_id=${QFI_ID}

Add new Bearer for Multiple SA UE
     [Arguments]    ${first_ue_id}    ${last_ue_id}    ${pdu_id}      ${qos_id}
     FOR   ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        UE PDU Modfication should be Successful   ${ue_id}      pdu_id=${pdu_id}      qosflows_to_add=${qos_id}
        sleep   5s
     END


