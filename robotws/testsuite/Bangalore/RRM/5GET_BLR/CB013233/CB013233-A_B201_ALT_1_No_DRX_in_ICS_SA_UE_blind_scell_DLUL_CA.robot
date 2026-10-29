*** Settings ***
Force Tags      CLOUD_5G_I_BOO_AP_LOO    CRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN

Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:     The user scenario targets the skipping DRX configuration in ICS for SA UE
...                               that is a candidate for blind Scell addition
...             TEST SET NAME:    CB013233
...             TESTING SPLIT:    Refer CB013233
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB013233 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_26394,CB_FIM_49170,CB_FIM_49158



Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         CB013233_Resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/configuration_id.robot
Library          SSHLibrary


Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
#...                 AND     Add GNB RadParam for ICS_DRX feature
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=CB013233_blind_DL4CC_UL2CC.xml   skip_relation_errors=True
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces    ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Stop Log   snapshot
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

#Suite Teardown      Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts_4cells_4FDD_n25_30_15MHz_n66_40MHz_n71_20MHz.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${sa_ue_id1}      1
${sa_ue_id2}      2
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${QFI_ID2}    2
${QFI_ID3}    3
${QFI_ID4}    4
${Q_O_ADD2}    2
${Q_O_ADD3}    3
${Q_O_ADD4}    4
${no_of_cells}    4
${CELL_ID}    1
${dl_traffic}   170
${ul_traffic}   80
${epc_log_path}    /tmp/
${TEST_NAME}        A_B201_ALT_1
${IPHY_FILE}                    ${CURDIR}/config/iphy_AP_LOO_AHFII_AHFIB_AHFII_gnb_ABIO_4FDD.xml
${GNB_IP}     192.168.255.129
${NOKIA_LOGIN}    toor4nsn
${NOKIA_PASS}     oZPS0POrRieRtu

*** Test Cases ***

CB013233-A#B201_ALT1 No DRX setup during ICS for UE in SA UE blind Scell addition DL UL CA F+T
    [Documentation]   The user scenario targets the skipping DRX configuration in ICS for SA UE
     ...              that is a candidate for blind Scell addition
    Wait until the next Measurement Period starts
    Start Log    btslog   cprt
    Attach non-CA UE${sa_ue_id1} and CA UE${sa_ue_id2}
    sleep   10s
    Verify Traffic on 4CC UE   ${sa_ue_id2}
    Deregister UE${sa_ue_id1} and UE${sa_ue_id2}
    ${path1}    Stop Log    cprt   test_scenario=no_DRX_ICS
    Stop Log   btslog
    Verify DRXcycle not present in F1AP_UEContextSetupRequest   ${path1}   ${crnti_1}
    Verify DRXcycle not present in F1AP_UEContextSetupRequest   ${path1}   ${crnti_2}
    Wait until the current Measurement Period stops
    ${pm_counter_file}=     Get Latest Unpacked Full Pm Counters File Classical  output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55308C11001  >1000   SLOTS_UE_DRX_ACTIVE
    ...  M55308C11002  >100   SLOTS_UE_DRX_SLEEP
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Attach multiple CA UEs to cell1
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

***keywords****
Add GNB RadParam for ICS_DRX feature
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    ${GNB_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    SSHLibrary.execute command    echo "0x890091=1" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection

Verify Traffic on 4CC UE
    [Arguments]   ${ue_id}
    ${dl_pcell_tput}=   Get CA Cell Average Throughput   ue_id=${ue_id}   dir=dl   scell_index=0
    ${dl_scell_tput}=   Get CA Cell Average Throughput   ue_id=${ue_id}   dir=dl   scell_index=1
    ${dl_scell_tput}=   Get CA Cell Average Throughput   ue_id=${ue_id}   dir=dl   scell_index=2
    ${dl_scell_tput}=   Get CA Cell Average Throughput   ue_id=${ue_id}   dir=dl   scell_index=3
    ${ul_pcell_tput}=   Get CA Cell Average Throughput   ue_id=${ue_id}   dir=ul   scell_index=0
    ${ul_scell_tput}=   Get CA Cell Average Throughput   ue_id=${ue_id}   dir=ul   scell_index=2

Get CA Cell Average Throughput
    [Arguments]    ${ue_id}    ${dir}    ${scell_index}
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
     wtsrunner.ue_stats_nr     id=${ue_id} type=${type} scell=${scell_index} format=long
    ${output}    wtsrunner.read_wtsemu_output_until    expected=Number of received DL TBs dropped for error simulation
    ...                     timeout=30
#     ${output}    Read WTS Output Until Pattern Matches    CellIndex-0    40
#    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    ${cell_tp}=    Evaluate    sum(map(float,${avg_tp_list}))
    ${cell_tp}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
    ${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
    ${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
    Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
    ${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
    ${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
    ...                                     '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
    ...                                     ${cell_tp}
    [Return]    ${cell_tput_Mbps}

Attach non-CA UE${sa_ue_id1} and CA UE${sa_ue_id2}
    Register non-CA UE${sa_ue_id1} with default bearer traffic
    sleep     1s
    Register CA UE${sa_ue_id2} with default bearer traffic
    sleep     1s

Attach multiple CA UEs to cell1
    FOR    ${ca_ue}    IN RANGE    2    6
         Register CA UE${ca_ue} with default bearer traffic
    END
    sleep   10s
    FOR    ${ca_ue}    IN RANGE    2    6
         ${dl_pcell_tput}=   Get CA Cell Average Throughput   ue_id=${ca_ue}   dir=dl   scell_index=0
    	${dl_scell_tput}=   Get CA Cell Average Throughput   ue_id=${ca_ue}   dir=dl   scell_index=1
    	${dl_scell_tput}=   Get CA Cell Average Throughput   ue_id=${ca_ue}   dir=dl   scell_index=2
    	${dl_scell_tput}=   Get CA Cell Average Throughput   ue_id=${ca_ue}   dir=dl   scell_index=3
    	${ul_pcell_tput}=   Get CA Cell Average Throughput   ue_id=${ca_ue}   dir=ul   scell_index=0
    END

Register non-CA UE${sa_ue_id} with default bearer traffic
    log to console   non-CA UE${sa_ue_id} attach trigerring now...
    ${crnti_1}   UE Register should be Successful And Fetch RNTI   ${sa_ue_id}   ${Pdu_session_ID}    ${nwslice_ID}   ${gw_ID}
    Sleep    2s    reason=wait command finish
    FOR    ${TRFID}    IN RANGE    1    3
        Trigger DL Traffic SA    ${sa_ue_id}   ${dl_traffic}    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
        Trigger UL Traffic SA    ${sa_ue_id}   ${ul_traffic}    ${Pdu_session_ID}   ${TRF_ID}    ${QFI_ID}
        sleep  1s
    END
    set suite variable   ${crnti_1}

Register CA UE${sa_ue_id} with default bearer traffic
    log to console   CA UE${sa_ue_id} attach trigerring now...
    ${crnti_2}   UE Register should be Successful And Fetch RNTI    ${sa_ue_id}   ${Pdu_session_ID}    ${nwslice_ID}   ${gw_ID}
    Sleep    2s    reason=wait command finish
   FOR    ${TRFID}    IN RANGE    1    2
        Trigger DL Traffic SA     ${sa_ue_id}   ${dl_traffic}    ${Pdu_session_ID}   ${TRFID}    ${QFI_ID}
        Trigger UL Traffic SA     ${sa_ue_id}   ${ul_traffic}    ${Pdu_session_ID}   ${TRFID}    ${QFI_ID}
        sleep  1s
    END
    set suite variable   ${crnti_2}

Deregister UE${sa_ue_id1} and UE${sa_ue_id2}
    FOR    ${ueid}    IN RANGE    ${sa_ue_id1}    ${sa_ue_id2}+${1}
        Stop Data Traffic for SA     ue_id=${ueid}
        UE Deregister should be Successful   ue_id=${ueid}
    END

