*** Settings ***
Documentation
    ...  This test case is verifying EthIfInFrames counter values for all TNL objects.
    ...  First, reportingIntervalPm and ethernetLinkInterval parameters are set to 5min.
    ...  Then, TC waits an entire 5 minutes time interval to check if the above counter has
    ...  the value grater then 0 for all TNL objects from NetAct response.
    ...  In the end, reportingIntervalPm and ethernetLinkInterval parameters are restored to
    ...  their initial values.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../resources/PM_general.robot


*** Variables ***
${NETACT_VM_IP_CMWAS}  ${EMPTY}  # Mandatory, IP from VM with CMWAS.


*** Keywords ***
TC__PM__vDU__File_Transfer_To_CNMS
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27946
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  13.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27946 - Initial TAT creation
    ...  ******************

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com
    ...  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf   PHASE-CRT
    ...  FEATURE-5GC001662

    Step1: Change reportingIntervalPm And ethernetLinkInterval Parameters To 5min
    Step2: Connect Vdu To NetAct
    Step3: Check PM Counters On NetAct


Step1: Change reportingIntervalPm And ethernetLinkInterval Parameters To 5min
    Log  \nStep1: Change reportingIntervalPm And ethernetLinkInterval Parameters To 5min  console=true
    ${rep_interval_value}  VDU Get Parameter Value  reportingIntervalPm  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    Run Keyword If  '${rep_interval_value}'!='5min'
    ...  Change Specific Parameter For VDU  reportingIntervalPm  5min  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1

    ${eth_link_interval_value}  VDU Get Parameter Value  ethernetLinkInterval  MRBTS-${VDU_MRBTS_ID}/TNLSVC-1/PMTNLINT-1
    Run Keyword If  '${eth_link_interval_value}'!='5min'
    ...  Change Specific Parameter For VDU  ethernetLinkInterval  5min  MRBTS-${VDU_MRBTS_ID}/TNLSVC-1/PMTNLINT-1

    Set Test Variable  ${REP_INTERVAL_INITIAL_VALUE}  ${rep_interval_value}
    Set Test Variable  ${ETH_LINK_INTERVAL_INITIAL_VALUE}  ${eth_link_interval_value}


Step2: Connect Vdu To NetAct
    Log  \nStep2: Connect Vdu To NetAct  console=true
    Run Keyword And Ignore Error  netact.Delete Node  cmwas

    netact.Add Node  cmwas  ${NETACT_VM_IP_CMWAS}  ${NETACT_USERNAME}  ${NETACT_PASSWORD}
    ${netact_web_url}  netact.Detect Web Url
    netact.Add Web Url  ${netact_web_url}  ${NETACT_USERNAME}  ${NETACT_PASSWORD}
    Set Test Variable  ${MRBTS_DN}  PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}


Step3: Check PM Counters On NetAct
    Log  \nStep3: Check PM Counters On NetAct  console=true

    Sleep Until New Cycle  5min
    Sleep Until New Cycle  5min
    Sleep  1min  TC will wait until PM report is loaded.

    ${netact_counters}  netact.Get Pm Counters  technology=SBTS-Nokia Multi Radio Transceiver Station  measurement=Ethernet Link Statistics
    ...  counters=EthIfInFrames  filter_by=MRBTS  mo_names=${MRBTS_DN}  object_aggregation=PLMN/MRBTS/TNLSVC/TNL/ETHSVC/ETHLK
    ...  time_aggregation=RAW  time_filter=today

    ${last_timestamp}  Set Variable  ${netact_counters}[-1][period_start_time]
    FOR  ${counter_dict}  IN  @{netact_counters}
        Continue For Loop If  '${counter_dict}[period_start_time]'!='${last_timestamp}'
        ${status}  Run Keyword And Return Status  Should Be True  ${counter_dict}[EthIfInFrames] > 0.0
        Run Keyword If  not ${status}
        ...  Fail  EthIfInFrames value for ${counter_dict}[dn] is not grater than 0.
    END

    [Teardown]  netact.Delete Node  cmwas


Restore Initial Values For Updated Parameters
    ${rep_interval_value}  VDU Get Parameter Value  reportingIntervalPm  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    Run Keyword If  '${rep_interval_value}'!='${REP_INTERVAL_INITIAL_VALUE}'
    ...  Change Specific Parameter For VDU  reportingIntervalPm  ${REP_INTERVAL_INITIAL_VALUE}
    ...  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    ${eth_link_interval_value}  VDU Get Parameter Value  ethernetLinkInterval  MRBTS-${VDU_MRBTS_ID}/TNLSVC-1/PMTNLINT-1
    Run Keyword If  '${eth_link_interval_value}'!='${ETH_LINK_INTERVAL_INITIAL_VALUE}'
    ...  Change Specific Parameter For VDU  ethernetLinkInterval  ${ETH_LINK_INTERVAL_INITIAL_VALUE}
    ...  MRBTS-${VDU_MRBTS_ID}/TNLSVC-1/PMTNLINT-1


TC Setup
    Common VDU Setup
    Modify Resource Search Order  PM__vDU__File_Transfer_To_CNMS


TC Teardown
    Restore Initial Values For Updated Parameters
    Common VDU Teardown