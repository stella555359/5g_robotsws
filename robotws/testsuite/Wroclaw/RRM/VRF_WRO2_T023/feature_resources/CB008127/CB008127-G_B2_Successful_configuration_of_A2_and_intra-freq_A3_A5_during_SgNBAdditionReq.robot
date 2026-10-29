*** Settings ***
Documentation
...  contact: Szymon Startek

Library     ute_ue


*** Variables ***
${NR_UE_CAPABILITY}                                         # Capability for UE used in test.
${CELL_ID_FOR_CALL}                                         # Global cell ID of NR cell used for call
${NR_DL_THROUGHPUT}                       50                # Throughput in Mbit/s generated on NR_UE during reestablishment procedure


*** Keywords ***
TC__CB008127-G_B2_Successful_configuration_of_A2_and_intra-freq_A3_A5_during_SgNBAdditionReq
    Set Tags    CA-INTER_RAT    AUTHOR-krzysztof.mirecki@nokia.com    OWNER-krzysztof.mirecki@nokia.com
    ...         MAINTAINER-szymon.startek@nokia.com    PHASE-CRT   SW-SBTS24R2    FEATURE-CB008127   GROUP_IN_CHARGE-Pz_2_WRO_2

    Preconditions
    Step 1: Start Wireshark Log And Attach UE
    Step 2: Stop Wireshark Logs
    Step 3: Tcpdump Verification


Preconditions
    ${nrbts_id}  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}
    Require UE  NR_UE  capabilities=${NR_UE_CAPABILITY}


Step 1: Start Wireshark Log And Attach UE
    Log  \n*** Step 1: Start Wireshark Log And Attach UE ***  console=True
    Set Test Variable  ${STARTED_TCPDUMP}  True
    Start Wireshark Log Collection For IWK Test  options=-i any port 38412 or port 38472 or port 36422 or port 29211
    ...                                          replace_enb=False  replace_gnb=False
    Prepare UE For Data Transfer  NR_UE  ${CELL_ID_FOR_CALL}  connection=gNB


Step 2: Stop Wireshark Logs
    Log  \n*** Step 2: Stop Wireshark Logs ***  console=True
    ${tcpdump_path}  Stop Wireshark Log Collection For IWK Test
    Set Test Variable  ${STARTED_TCPDUMP}  False
    Set Test Variable  ${TCPDUMP_PATH}  ${tcpdump_path}
    Log  \n*** UE Detached ***  console=True


Step 3: Tcpdump Verification
    Log  \n*** Step 3: Tcpdump Verification ***  console=True
    ${filter1}  Catenate  ((((((((((((((((f1ap.procedureCode == 5)&&(nr-rrc.eventId==2))&&(nr-rrc.hysteresis==6)) &&
    ...  (nr-rrc.timeToTrigger==7))&&(nr-rrc.measTriggerQuantityOffset.rsrp==10)) &&
    ...  (nr-rrc.eventId==4))&&(nr-rrc.measTriggerQuantity.rsrp==60)) &&
    ...  (nr-rrc.measTriggerQuantity.rsrp==65))&&(nr-rrc.hysteresis==10)) &&
    ...  (nr-rrc.timeToTrigger==6))&&(nr-rrc.eventId==1))&&(nr-rrc.measTriggerQuantity.rsrp==67)) &&
    ...  (nr-rrc.hysteresis == 4))&&(nr-rrc.timeToTrigger==11))&&(nr-rrc.hysteresis==2)) &&
    ...  (nr-rrc.timeToTrigger==12))&&(nr-rrc.measTriggerQuantity.rsrp==68)
    ${result} =  Run Process
    ...  command=tshark -r ${TCPDUMP_PATH} -Y '((x2ap.SubscriberProfileIDforRFP==20)&&(e212.mcc=="001"))&&(e212.mnc=="01")' |wc -l  shell=True
    Should Be Equal As Integers  ${result.rc}  0
    ...  msg=RC is not equal to 0. There were some errors during execution of tshark command.\nError message: ${result.stderr}.
    Should Be Equal As Strings  '${result.stderr}'  ''
    ...  msg=Errors appeared while executing command: tshark -r ${TCPDUMP_PATH} -Y "${filter1}" |wc -l.\nError message: ${result.stderr}
    Should Not Be True  ${result.stdout} == 0
    ...  msg=Expected SPID or PLMN was not present. Please check object NRMEASPR_MA_NSA-1 and values for SPID and PLMN.
    Log To Console  Number of filtered packets:${result.stdout}, which means SgNBAdditionRequest with proper SPID and PLMN was performed
    ${result} =  Run Process
    ...  command=tshark -r ${TCPDUMP_PATH} -Y "${filter1}" |wc -l  shell=True
    Should Be Equal As Integers  ${result.rc}  0
    ...  msg=RC is not equal to 0. There were some errors during execution of tshark command.\nError message: ${result.stderr}.
    Should Be Equal As Strings  '${result.stderr}'  ''
    ...  msg=Errors appeared while executing command: tshark -r ${TCPDUMP_PATH} -Y "${filter1}" |wc -l.\nError message: ${result.stderr}
    Should Not Be True  ${result.stdout} == 0
    ...  msg=Proper configuration for intra freq events a2,a3,a5 is not present.
    Log To Console  Number of filtered packets:${result.stdout}, which means proper a2,a3,a5 intra-frequency configs are avaliable


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True  start_wireshark=False


TC Teardown
    Log  \n=== TC Teardown ===  console=True
    Detach UE  NR_UE
    Run Keyword If  ${STARTED_TCPDUMP}  Stop Wireshark Log Collection For IWK Test
    IWK Test Teardown  local_enb_connection=False  single_bts=True  stop_wireshark=False
