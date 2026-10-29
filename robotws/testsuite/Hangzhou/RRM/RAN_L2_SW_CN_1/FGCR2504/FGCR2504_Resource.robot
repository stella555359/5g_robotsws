*** Settings ***
Documentation    Author :
...              Squad group : SG_06
Resource         ./../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${FILTER}                        dldata_csirssendreq||dldata_pdschpayloadtbsendreq||uldata_puschreceiveresplo
@{COLUMN_NAME}                   3gpp.sfn    3gpp.slot

*** Keywords ***
Set PDSCH Test Mode
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_decode_muxphychan decode_mux_phy_chan\=decode_PDSCH

Covert BIP To Csv   
    ${bip_name}    Set Variable    ${OUTPUT_DIR}/5GBipL2L1_filtering_off.pcap
    Convert BIP To CSV By MCShark    ${bip_name}    ${OUTPUT_DIR}/5GBipL2L1_filtering_off.csv    filter=${FILTER}    csv_title_list=${COLUMN_NAME}

