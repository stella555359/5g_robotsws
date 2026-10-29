*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     testsuite.Wroclaw.RRM.VRF_WRO1_T04.resources.Tokens
Library     ta5g_pm_counters
Library     keywords_ROHC.py

Documentation
...    author: Pawel Konieczny
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_O_E_AP_LOOO
...    release: 22R3

Suite Setup      Run Keywords    Modify Config To 6 Cells
...            AND    Get and Update BSR File
...            AND    Prepare Sa Test Environement
...            AND    Reach Onair    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
...            AND    Enable Vonr And Rohc
...            AND    Enable Syslog Debug Prints For Rohc
...            AND    Enable Gathering Rohc Counters Every 5min

Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

Test Teardown    Send Configuration ID To Scout

*** Variables ***
${ARTIFACTORY_ROTTA}=      https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
${download_path}=          ${ARTIFACTORY_ROTTA}/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
${BSR_FILENAME}=           BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
${TRAFFIC_DURATION_SEC}=   20s
${ue_id}=                  255

*** Test Cases ***
5GC000774-A-B1_Successful_Setup_Of_Voice_Over_Nr_Call_With_Rohc_Profile_0x0001_Ipv4
    Attach One 5g Ue Capable Of Supporting Rohc    ${ue_id}
    Start Dl And Ul Data Traffic For Rtp Packet Stream
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Check That Amount Of Compressed And Decompressed Pdus For Profile 1 Is Incremented As Expected For This Traffic Time
    Check That Difference Between Compressed And Decompressed Bytes For Profile 1 Is In Expected Range For This Traffic Time
    Check If Expected Throughout Is Reached And There Are No Packets Lost
    Verify If Rohc Dl And Ul Header Pm Counters Are Incremented
    Verify Rohc Contexts Pm Counters Values
    Deregister Ue    ${ue_id}

*** Keywords ***
Modify Config To 6 Cells
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    wts.Modify    set_cell id=3 gnb=2           nr_arfcn=636666:636666 gscn=7880 eci=0x000021f nrci=0x3FFF tdd_cell=on
    wts.Modify    set_cell id=4 gnb=2           gscn=1956
    wts.Insert    set_cell id=5 gnb=2 nr_arfcn=135760:126380 gscn=1956 eci=0x000021f pci=18:0 tac=200    after    set_cell id=4 gnb=2
    wts.Modify    set_cell id=5                 proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nrci=0x04 tdd_cell=off mandatory_for_activation=off
    wts.Insert    set_cell id=6 gnb=2 nr_arfcn=135760:126380 gscn=1956 eci=0x000021f pci=18:1 tac=200    after    set_cell id=5 gnb=2
    wts.Modify    set_cell id=6                 proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nrci=0x04 tdd_cell=off mandatory_for_activation=off
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

Get and Update BSR File
     [Arguments]  ${download_path}=${download_path}     ${bsr_file_path}=${OUTPUTDIR}/${BSR_FILENAME}
     ${token}=   get_ca_ute_artifactory_token
     Run  sudo wget -d --header='Authorization:Bearer ${token}' ${download_path} -O ${bsr_file_path}
     admin.setup admin
     ${ret}     admin.Update Software      ${bsr_file_path}
     admin.teardown admin

Display Ue Statistics
    Display Qfi stats    ${ue_id}    qfi_id=3
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Start Dl And Ul Data Traffic For Rtp Packet Stream
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 dir=dl rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 dir=ul rtp_codec=amr_wb_23_85

Check That Amount Of Compressed And Decompressed Pdus For Profile 1 Is Incremented As Expected For This Traffic Time
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=530    enb_id=2    cell_id=1
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_1_pdus    mode=am    value=530    enb_id=2    cell_id=1

Check That Difference Between Compressed And Decompressed Bytes For Profile 1 Is In Expected Range For This Traffic Time
    Rohc Statistic Smaller Than Given Value    rohc_statistic_prefix=size_of_compressed_pdus    mode=am    value=35000    enb_id=2    cell_id=1
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_1_bytes    mode=am    value=54000    enb_id=2    cell_id=1

Check If Expected Throughout Is Reached And There Are No Packets Lost
    Expected Throughput For Qfi Should Be Reached    ue_id=${ue_id}    pdu_id=1    qfi_id=3
    ...    expected_throughput=20    unit=kbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=${ue_id}    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=bi

Verify If Rohc Dl And Ul Header Pm Counters Are Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_NUM_ROHC_COMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_ROHC_COMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_UL_NUM_ROHC_DECOMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_UL_VOL_ROHC_DECOMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify Rohc Contexts Pm Counters Values
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_REQ_SENT}
    ...    value=5    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_RESP_RECD}
    ...    value=5    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_REQ_SENT}
    ...    value=5    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_CMP_RECD}
    ...    value=5    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}

Enable Gathering Rohc Counters Every 5min
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_enabling_gathering_rohc_counters_every_5min.json
