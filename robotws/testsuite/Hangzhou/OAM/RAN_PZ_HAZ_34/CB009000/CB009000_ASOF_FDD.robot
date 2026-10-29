*** Settings ***
Force Tags    PY36
Documentation     author: Wang Lei
...               contact: lei.24.wang@nokia-sbell.com
...               squad group: SG_07
...               feature : CB009469 CB009799 CB009800 CB009801

Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009000/Resources/CB009000_common_keyword.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009000/Resources/variables.py

Suite Setup    Common Suite Setup for COAM for ASOF FDD
Suite Teardown   COAM Suite Teardown for COAM for ASOF FDD

*** Variables ***
@{ALL_TEST_STATUS}
${NEW_Askey_NRcall}   No

*** Test Cases ***
[1]CB009XXX_ASOF_FDD_CRT
    [Tags]    CRT_TRUNK    CRT_24R1
    [Timeout]    4h
    [Setup]     robot_common_operations.Common Case Setup
    Run Keyword And Continue On Failure  CB009469_5GC001227_PRB_pooling_enabled_with_right_numMinPRBAlloc_and_maxNumXXXPrb_for_ASOF_FDD
    #Run Keyword And Continue On Failure  CB009469_5GC001227_DL_PRB_shared_by_cells_in_same_subpool_for_ASOF_FDD
    Run Keyword And Continue On Failure  CB009469_5GC001167_CA_Configuration_can_be_Modified_without_BTS_restart_for_ASOF_FDD
    [Teardown]    robot_common_operations.Common Case Teardown


*** Keywords ***
CB009469_5GC001227_PRB_pooling_enabled_with_right_numMinPRBAlloc_and_maxNumXXXPrb_for_ASOF_FDD
     [Timeout]    120 min
     Case Setup for ASOF FDD
     #syslog start
     Syslog Capture Start
     #env setup
     Modify 1227 Venfor for ASOF FDD
     #MTU X65 attach to cell1 2 3 then detach
     Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
     sleep    3s
     Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
     #syslog stop
     Syslog Capture Stop and Collect
     #syslog print
     ${message0}   Print BTSlog    message_name=slowPrbPoolingAllowed
     ${message1}   Print BTSlog    message_name=bbPoolingInfoCell
     ${message2}   Print BTSlog    message_name=current number of NR Users
     ${message3}   Print BTSlog    message_name=drb_count
     #check 1227
     Should Contain    ${message0}   slowPrbPoolingAllowed: boolean = true
     Should Contain    ${message1}   NumMinPrbAllocDl:48 , NumMinPrbAllocUl:36
     [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover for ASOF FDD


CB009469_5GC001227_DL_PRB_shared_by_cells_in_same_subpool_for_ASOF_FDD
     [Timeout]    120 min
     Case Setup for ASOF FDD
     #env setup
     #cell1/2/3 chbw=20M(PRB=106) ; cell1/3 on L1subpool-1, cell2 on L1subpool-2
     #cell1/3 on same L1subpool-1 ; gua PrbDl for cell1/3 = 48 ; share PrbDl for L1subpool-1 = 636/4-48-48=63
     #Total min{212,48(cell1 gua)+48(cell3 gua)+63(share)} = 159 PRB can be scheduled to CA UE for cell1/3
     #cell2 on another L1subpool-2 ; gua PrbDl for cell2 = 48 ; share PrbDl for L1subpool-2 = 636/4-48=111
     #Total min{106,48(cell3 gua)+111(share)} =106 PRB can be scheduled to CA UE for cell2
     #<p name="maxNumLayerPrbDlL1Sp">1</p> //no impact to FDD
     #<p name="maxNumLayerPrbUlL1Sp">1</p> //no impact to FDD
     #<p name="maxNumStreamPrbDlL1Sp">636</p>
     #<p name="maxNumStreamPrbUlL1Sp">636</p>
     Syslog Capture Start
     Modify 1227 Venfor for ASOF FDD     rPrbDlL1Sp=1    rPrbUlL1Sp=1    mPrbDlL1Sp=636    mPrbUlL1Sp=636

#Test1 : cell 1/2/3 onair, CA UE on cell 1/2/3 with "dl", "PrbAllocated" = 79.5/106/79.5 +-4 for cell1/2/3
     #ue_index=${0} attach on cell 1/2/3 (DL CA) and start full buffer "dl" tput
     Set L3 CALL param CB009469   runame=AHFB    framestruct=CA_3_20M_mtk_nopeak
     PEAK L3 CALL Process CB009469    traffic_stop=${False}    actCarrierAggregation=${True}
     #start sherpa
     Sherpa log Start Collect
     sleep    5s
     #stop sherpa
     Sherpa log Stop Collect and Convert CSV
     #ue_index=${0} stop iperf dl stream on FTP server
     power_ue.Stop traffic   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   direction=dl
     power_ue.Stop traffic   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   direction=ul
     #ue_index=${0} detach
     power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
     #check PrbAllocated in Sherpa_l1l2Trace.csv
     #input for keywords: ${direction}=dl @{Global cell ID}=1 2 3 ${filter}=PrbAllocated @{avg}=79.5 106 79.5
     Check Cell List Value from L1L2trace    direction=DL   filter=PrbAllocated   cell_value_dic=${CB009469_PrbValue}
     ...   range_value=${CB009469_Prb_rangevalue}
     Syslog Capture Stop and Collect
     [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover for ASOF FDD


CB009469_5GC001167_CA_Configuration_can_be_Modified_without_BTS_restart_for_ASOF_FDD
     [Timeout]    120 min
     Case Setup for ASOF FDD
     #env setup
     Syslog Capture Start
     Use Default Vendor for ASOF FDD

#Test1 : CA to nonCA , then check Peak Tput
     #online modification from 3CC CA to nonCA
     COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_TO_MODIFY_non_CA}
     #run keyword and contiune on failure "BTS not restart"
     run keyword and continue on failure    check mplane during 1min
     #check cell onair
     Wait Until Keyword Succeeds   20m   30s   COAM Check All Cells Onair
     #wireshark start
     Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
     #run keyword and contiune on failure "MTK M80 L3call and reach Peak Tput for nonCA"
     #block other cells except L3CALL
     Block other cells except L3CALL     l3call_cell_list=${LIST_CB009469_nonCA_CELLS}
     Set L3 CALL param CB009469   runame=AHFB    framestruct=single_20M_mtk
     run keyword and continue on failure    PEAK L3 CALL Process CB009469
     #wireshark stop
     Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
     #unblock other cells except L3CALL
     UnBlock other cells except L3CALL     l3call_cell_list=${LIST_CB009469_nonCA_CELLS}
     #tcpdump check, nonCA used for MTK M80
     Check Wireshark have no Scell in DU   nglogname=asix.pcap
     log to console  \n  ****Test1 passed!****

#Test2 : nonCA to CA , then check Peak Tput
     #online modification from nonCA to 3CC CA
     COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_TO_MODIFY_CA}
     #run keyword and contiune on failure "BTS not restart"
     run keyword and continue on failure    check mplane during 1min
     #check cell onair
     Wait Until Keyword Succeeds   20m   30s   COAM Check All Cells Onair
     #wireshark start
     Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
     #run keyword and contiune on failure "MTK M80 L3call and reach Peak Tput for 3CC CA"
     Set L3 CALL param CB009469   runame=AHFB    framestruct=CA_3_20M_mtk
     run keyword and continue on failure    PEAK L3 CALL Process CB009469    actCarrierAggregation=${True}
     #wireshark stop
     Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
     #tcpdump check, 3CC CA used for MTK M80
     Check Wireshark have 2 Scell in DU   nglogname=asix2.pcap
     log to console  \n  ****Test2 passed!****
     Syslog Capture Stop and Collect
     [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover for ASOF FDD
