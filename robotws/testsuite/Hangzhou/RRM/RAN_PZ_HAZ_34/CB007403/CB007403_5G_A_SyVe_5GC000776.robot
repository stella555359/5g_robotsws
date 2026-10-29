# # #*** Settings ***
# # #Suite Setup
# # #Suite Teardown
# # #Test Timeout    #5min
# # #
# # #Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
# # #Library    taf.ue  WITH NAME   ute_ue
# # #Resource    ./Resources/CB007403_5GC000776-keyword.robot
# # #
# # #
# # #Documentation
# # #...    author: fraxu
# # #...    contact: frank.1.xu@nokia-sbell.com
# # #...    squad group: 5G_PZ_MMW_HZ_3_SG
# # #
# # #Force Tags    CIT_22R1
# # #...    PY36
# # #
# # #
# # #*** Variables ***
# # #
# # #${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
# # #${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
# # #${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
# # #${file_name}    ue_attach.pcap
# # #${filter}    /usr/bin/tshark -r {input_file} -Y  "x2ap" -T pdml > {output_file}
# # #${full_path}    BTS/NRBTS-${nrbts_id}/NRDU-1/NF1UD
# # #${nrbts_id}    1900
# # #
# # #
# # #*** Test Cases ***
# # #[1]CB007403_5GC000776_1_Feature_Activation
# # #    [Documentation]    *****************
# # #    ...    CB007403_5GC000776 Feature_Activation
# # #    ...    ******************
# # #    ...    *******************
# # #    [Tags]    frank.1.xu@nokia-sbell.com
# # #    ##[Setup]
# # #    [Teardown]
# # #    Check GNB on air
# # #    Modify the parameter actNonGbrServiceDiff and actMultiDrbNSA to true
# # #
# # #[1]CB007403_5GC000776_3_DL_Sched_2UEs_1DRB_NGBR_UE1-QCI7_UE2-QCI9
# # #    [Documentation]    *****************
# # #    ...    this case is to verify Schedleweight of 2UEs 1DRB NGBR with UE1-QCI7 and UE2-QCI9
# # #    ...    ******************
# # #    ...    *******************
# # #    [Tags]    frank.1.xu@nokia-sbell.com
# # #    ##[Setup]
# # #    [Teardown]
# # #    Check GNB on air
# # #    Modify the parameter actNonGbrServiceDiff and actMultiDrbNSA to true
# # #    2 UE send full UDP UL data and full UDP DL data
# # #    Check the PDCP PM counters to verify the average DL and UL Rate Ratio of the 2 UE
# # #
# # #[1]CB007403_5GC000776_4_UL_Sched_2UEs_1DRB_NGBR_UE1-QCI7_UE2-QCI9
# # #    [Documentation]    *****************
# # #    ...    this case is to verify Schedleweight of 2UEs 1DRB NGBR with UE1-QCI7 and UE2-QCI9
# # #    ...    ******************
# # #    ...    *******************
# # #    [Tags]    frank.1.xu@nokia-sbell.com
# # #    ##[Setup]
# # #    [Teardown]
# # #    Check GNB on air
# # #    Modify the parameter actNonGbrServiceDiff and actMultiDrbNSA to true
# # #    2 UE send full UDP UL data and full UDP DL data
# # #    Check the PDCP PM counters to verify the average DL and UL Rate Ratio of the 2 UE
# # #
# # #
# # #[1]CB007403_5GC000776_5_DL_Sched_2UEs_1DRB_NGBR_UE1-QCI7_UE2-QCI9_UE1_VarTraffic
# # #    [Documentation]    *****************
# # #    ...    this case is to verify Schedleweight of 2UEs 1DRB NGBR with UE1-QCI7 and UE2-QCI9
# # #    ...    ******************
# # #    ...    *******************
# # #    [Tags]    frank.1.xu@nokia-sbell.com
# # #    ##[Setup]
# # #    [Teardown]
# # #    Check GNB on air
# # #    Modify the parameter actNonGbrServiceDiff and actMultiDrbNSA to true
# # #    2 UE send full UDP UL data and full UDP DL data
# # #    Check the PDCP PM counters to verify the average DL and UL Rate Ratio of the 2 UE
# # #
# # #[1]CB007403_5GC000776_6_DL_Sched_2UEs_1DRB_NGBR_confSchedWeights_UE1-QCI6_UE2-QCI7
# # #    [Documentation]    *****************
# # #    ...    this case is to verify Schedleweight of 2UEs 1DRB NGBR with UE1-QCI6 and UE2-QCI7
# # #    ...    ******************
# # #    ...    *******************
# # #    [Tags]    frank.1.xu@nokia-sbell.com
# # #    ##[Setup]
# # #    [Teardown]
# # #    Check GNB on air
# # #    Modify the parameter actNonGbrServiceDiff and actMultiDrbNSA to true
# # #    2 UE send full UDP UL data and full UDP DL data
# # #    Check the PDCP PM counters to verify the average DL and UL Rate Ratio of the 2 UE
# # #
# # #
# # #[1]CB007403_5GC000776_7_UL_Sched_2UEs_1DRB_NGBR_confSchedWeights_UE1-QCI6_UE2-QCI7
# # #    [Documentation]    *****************
# # #    ...    this case is to verify Schedleweight of 2UEs 1DRB NGBR with UE1-QCI6 and UE2-QCI7
# # #    ...    ******************
# # #    ...    *******************
# # #    [Tags]    frank.1.xu@nokia-sbell.com
# # #    ##[Setup]
# # #    [Teardown]
# # #    Check GNB on air
# # #    Modify the parameter actNonGbrServiceDiff and actMultiDrbNSA to true
# # #    2 UE send full UDP UL data and full UDP DL data
# # #    Check the PDCP PM counters to verify the average DL and UL Rate Ratio of the 2 UE
# # #
# # #[1]CB007403_5GC000776_8_DL_Sched_2UEs_1DRB_NGBR_confSchedWeights_UE1-QCI9_UE2-QCI8
# # #    [Documentation]    *****************
# # #    ...    this case is to verify Schedleweight of 2UEs 1DRB NGBR with UE1-QCI8 and UE2-QCI9
# # #    ...    ******************
# # #    ...    *******************
# # #    [Tags]    frank.1.xu@nokia-sbell.com
# # #    ##[Setup]
# # #    [Teardown]
# # #    Check GNB on air
# # #    Modify the parameter actNonGbrServiceDiff and actMultiDrbNSA to true
# # #    2 UE send full UDP UL data and full UDP DL data
# # #    Check the PDCP PM counters to verify the average DL and UL Rate Ratio of the 2 UE
# # #
# # #
# # #[1]CB007403_5GC000776_9_DL_Sched_2UEs_1DRB_NGBR_confSchedWeights_UE1-QCI9_UE2-QCI8
# # #    [Documentation]    *****************
# # #    ...    this case is to verify Schedleweight of 2UEs 1DRB NGBR with UE1-QCI8 and UE2-QCI9
# # #    ...    ******************
# # #    ...    *******************
# # #    [Tags]    frank.1.xu@nokia-sbell.com
# # #    ##[Setup]
# # #    [Teardown]
# # #    Check GNB on air
# # #    Modify the parameter actNonGbrServiceDiff and actMultiDrbNSA to true
# # #    2 UE send full UDP UL data and full UDP DL data
# # #    Check the PDCP PM counters to verify the average DL and UL Rate Ratio of the 2 UE
# # #