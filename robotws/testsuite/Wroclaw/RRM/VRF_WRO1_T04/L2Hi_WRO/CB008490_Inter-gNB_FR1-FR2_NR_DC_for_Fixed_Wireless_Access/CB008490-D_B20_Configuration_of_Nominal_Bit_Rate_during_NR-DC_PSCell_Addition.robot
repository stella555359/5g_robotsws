*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    release: 25R1

*** Variables ***
${TRAFFIC_DURATION_SEC_D_B20}=   10m
${TRAFFIC_DURATION_BEFORE_PSCELL_SEC_D_B20}=   2m
${SA_DU_DRB_NBR_DL}=    M55139C03509
${SA_DU_DRB_NBR_UL}=    M55139C03510

*** Keywords ***
CB008490-D_B20_Configuration_of_Nominal_Bit_Rate_during_NR-DC_PSCell_Addition
    Register Nrdc Ue With Default Pdu Session
    Set UE UL Data Distribution    scg_ul_dist_percent=50
    Start Udp Traffic 300Mbps In DL And 110Mbps In UL
    Send A4 Measurement And Trigger Pscell Addition
    Start Traffic 450Mbps In DL
    Verify NBR Counters
    Check Data Traffic On Mcg And Scg Leg    ue_id=1   traffic_duration_sec=${TRAFFIC_DURATION_SEC_D_B20}    expected_throughput=450
    Check Number Of Pdcp Reorder Timeout On Mcg And Scg Leg

Start Udp Traffic 300Mbps In DL And 110Mbps In UL
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=110 trf_id=1
    Sleep    ${TRAFFIC_DURATION_BEFORE_PSCELL_SEC_D_B20}

Set NBR
    Send Delta Commissioning      input_filepath=${DELTA_FILES_PATH}/CB008490/delta_set_NominalBitRate.json

Verify NBR Counters
    Wait For Next Full Pm Interval      remote_host=${REMOTE_HOST_1_IP}
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File     remote_host=${REMOTE_HOST_1_IP}
    Verify If Latest Pm Counter Has Exact Value     counter_id=${SA_DU_DRB_NBR_DL}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-3/NRCELL-1   filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value     counter_id=${SA_DU_DRB_NBR_UL}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-3/NRCELL-1    filepath=${PM_COUNTERS}

    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value     counter_id=${SA_DU_DRB_NBR_DL}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value     counter_id=${SA_DU_DRB_NBR_UL}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1    filepath=${PM_COUNTERS}

Check Number Of Pdcp Reorder Timeout On Mcg And Scg Leg
    Check Number Of Pdcp Reorder Timeout
    Check Number Of Pdcp Reorder Timeout    enb_id=3    cell_id=3
