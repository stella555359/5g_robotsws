*** Settings ***
Documentation
    ...  First of all if the GTPU link doesn't exist, GTPU object is created. Then GTPU link break is performed by changing the IP address with
    ...  1.5.23.136 for serving gateway. GTPU link status must be Degraded, fault 6150 must be visible on WebEM and also in Netact and all cells
    ...  need to be onAir.
    ...  After that, GTPU link is reconnected and its status must be Online. Lastly TX/RX status are verified for some of LTE cells. These cells
    ...  are randomly chosen.

Resource  ../../common_resources/ca_FM_general.robot


*** Keywords ***
TC__FM__Link_break_GTPU
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21641
    ...
    ...  History of changes
    ...  ******************
    ...  - 23.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21641 - Initial TAT creation
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 26.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22518 - The object //GTPU_PATH-* not found and test FM__Link_break_GTPU fails.
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 25.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25417 - Use Admin Get LNBTS ID from sbts_admin
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS21

    Step0: Check If LTE Cells Exist
    Step1: Perform Delta Recommissioning And Check All Cells If Needed
    Step2: GTPU Link Break Is Performed And Fault 6150 Is Verified
    Step3: Check GTPU Link Status
    Step4: Check Cells On Other RATs
    Step5: GTPU Link Is Reconnected
    Step6: Check LTE Cells And GTPU Link Status
    Step7: Check LTE Services


Step0: Check If LTE Cells Exist
    Run Keyword If  ${SCF_COUNT_LTE} == 0
    ...  Fail  LTE cells don't exist and breaking GTPU link is not possible.
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}


Step1: Perform Delta Recommissioning And Check All Cells If Needed
    Log  Step1: Perform delta recommissioning and check all cells if needed  console=true
    ${status}  Run Keyword And Return Status
    ...  Verify If GTPU Link Exists
    Run Keyword If  ${status} == ${FALSE}
    ...  Run Keywords
    ...  Perform Delta Recommissioning With GTPU Object
    ...  AND
    ...  Check All Cells After Delta Recommissioning
    Set Initial Values For Serving Gateway
    Log  Initial ip address for serving gateway: ${INITIAL_IP_ADDRESS}.  console=true
    Log  Initial transport network ID for serving gateway: ${INITIAL_TRANSPORT_NW_ID}.  console=true


Step2: GTPU Link Break Is Performed And Fault 6150 Is Verified
    Log  \nStep2: GTPU link break is performed and fault 6150 is verified  console=true
    ${wrong_ip_address}  Set Variable  1.5.23.136
    Change Ip Address For Serving Gateway  ${wrong_ip_address}
    ${status}  Run Keyword And Return Status
    ...  Check Ip Address For Serving Gateway  ${wrong_ip_address}
    Run Keyword If  ${status}
    ...  Log  IP address for serving gateway changed to: ${wrong_ip_address} [OK].  console=true
    ...  ELSE
    ...  Set Test Failed  IP address for serving gateway did not change to ${wrong_ip_address} [NOK].  console=true

    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_6150}
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=60
    Log  Fault ${FAULT_6150}[fault_id] "${FAULT_6150}[fault_name]" is active in WebEM.  console=true

    Wait Until Keyword Succeeds  60  10
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_6150}  additional_fault_id=${FAULT_6150}[fault_id]
    Log  Fault ${FAULT_6150}[fault_id] "${FAULT_6150}[fault_name]" is active in NetAct.  console=true


Step3: Check GTPU Link Status
    Log  \nStep3: Check GTPU link status  console=true
    ${status}  Run Keyword And Return Status
    ...  Check GTPU Link Status  Degraded
    Run Keyword If  ${status}
    ...  Log  GTPU status is Degraded [OK].  console=true
    ...  ELSE
    ...  Set Test Failed  GTPU status is not Degraded [NOK].  console=true


Step4: Check Cells On Other RATs
    Log  \nStep4: Check cells on other RATs  console=true
    ${status}  Run Keyword And Return Status
    ...  Check Cells Except LTE Cells  ${UNBLOCKED}  ${ENABLED}
    Run Keyword If  ${status}
    ...  Log  2G, 3G and 5G cells are onAir [OK].  console=true
    ...  ELSE
    ...  Set Test Failed  2G, 3G and 5G cells are not onAir [NOK].  console=true


Step5: GTPU Link Is Reconnected
    Log  \nStep5: GTPU link is reconnected  console=true
    Change Ip Address For Serving Gateway  ${INITIAL_IP_ADDRESS}
    ${status}  Run Keyword And Return Status
    ...  Check Ip Address For Serving Gateway  ${INITIAL_IP_ADDRESS}
    Run Keyword If  ${status}
    ...  Log  IP address for serving gateway changed to initial value: ${INITIAL_IP_ADDRESS} [OK].  console=true
    ...  ELSE
    ...  Set Test Failed  IP address for serving gateway did not change to ${INITIAL_IP_ADDRESS} [NOK].  console=true

    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_6150}
    Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=60
    Log  Fault ${FAULT_6150}[fault_id] "${FAULT_6150}[fault_name]" is inactive in WebEM.  console=true
    Wait Until Keyword Succeeds  60  10
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_6150}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_6150}[fault_id]
    Log  Fault ${FAULT_6150}[fault_id] "${FAULT_6150}[fault_name]" is inactive in NetAct.  console=true


Step6: Check LTE Cells And GTPU Link Status
    Log  \nStep6: Check LTE cells and GTPU link status  console=true
    ${status}  Run Keyword And Return Status
    ...  Check LTE Cells  ${UNBLOCKED}  ${ENABLED}
    Run Keyword If  ${status}
    ...  Log  4G cells are onAir [OK].  console=true
    ...  ELSE
    ...  Set Test Failed  4G cells are not onAir [NOK].  console=true
    ${status}  Run Keyword And Return Status
    ...  Check GTPU Link Status  Online
    Run Keyword If  ${status}
    ...  Log  GTPU status is Online [OK].  console=true
    ...  ELSE
    ...  Set Test Failed  GTPU status is not Online [NOK].  console=true


Step7: Check LTE Services
    [Documentation]  Services on all cells are working. Services over different TX/RX are verified on random cells.

    Log  \nStep7: Check LTE services  console=true
    ${lte_cell_info_list}  Admin Get LTE CELL Info
    ${size}  Get Length  ${lte_cell_info_list}
    ${random_cells_list}  Create List
    Set Test Variable  ${RANDOM_CELLS_LIST}
    ${number_of_random_cells}  Evaluate  ${SCF_COUNT_LTE}/2+1
    Add Random LTE Cells  ${number_of_random_cells}  random_max_size=${size}
    FOR  ${index}  IN  @{RANDOM_CELLS_LIST}
        ${cell_info}  Get From List  ${lte_cell_info_list}  ${index}
        Check Rx/tx States For One Cell  ${cell_info}
    END


Verify If GTPU Link Exists
    ${gtpu_obj_status}  Query Infomodel  check //GTPU_A-*
    Should Be Equal  ${gtpu_obj_status}  ${TRUE}
    ${gtpu_a}  Query Infomodel  get object //GTPU_A-*
    Should Not Be Empty  ${gtpu_a.sgwIpAddressList[0]}[sgwIpAddress]


Perform Delta Recommissioning With GTPU Object
    Log  Delta with GTPU object recommisiong is performing.  console=true
    ${bts_id}  Admin Get BTS ID
    ${lnbts_id}  Admin Get LNBTS ID
    ${delta_id}  Set Variable  1
    ${new_values}  Create Dictionary  gtpuId=1  gtpuN3Reqs=5  gtpuPathSupint=60  gtpuT3Resp=2  sgwIpAddress=10.5.23.136  transportNwId=0
    ...  udpMaxDatagramSize=1385
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU  create  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU-1  gtpuN3Reqs  ${new_values}[gtpuN3Reqs]  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU-1  gtpuPathSupint  ${new_values}[gtpuPathSupint]  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU-1  gtpuT3Resp  ${new_values}[gtpuT3Resp]  ${delta_id}
    ${structure1}  Create Dictionary
    Set To Dictionary  ${structure1}  sgwIpAddress  ${new_values}[sgwIpAddress]
    Set To Dictionary  ${structure1}  transportNwId  ${new_values}[transportNwId]
    Append Complex Item To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU-1  list_name=sgwIpAddressList  &{structure1}  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU-1  udpMaxDatagramSize  ${new_values}[udpMaxDatagramSize]  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}


Check All Cells After Delta Recommissioning
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300s  10s
    ...  Check All Cells
    Run Keyword If  ${status}
    ...  Log  All cells are onAir.  console=true
    ...  ELSE
    ...  Set Test Failed  Not all cells are onAir after performing delta recommissioning.


Set Initial Values For Serving Gateway
    [Documentation]  This keyword will set 'serving gateway IPv4/v6 address' and 'transport network identifier' values.

    ${gtpu_path_object}  Query Infomodel  get object //GTPU_PATH-*
    Set Test Variable  ${INITIAL_IP_ADDRESS}  ${gtpu_path_object}[destIpAddress]
    Set Test Variable  ${INITIAL_TRANSPORT_NW_ID}  ${gtpu_path_object}[transportNetworkId]


Change Ip Address For Serving Gateway
    [Arguments]  ${ip_address}

    ${bts_id}  Admin Get BTS ID
    ${lnbts_id}  Admin Get LNBTS ID
    ${gtpu_id}  Get GTPU ID
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU-${gtpu_id}  update  ${delta_id}
    ${structure1}  Create Dictionary
    Set To Dictionary  ${structure1}  sgwIpAddress  ${ip_address}
    Set To Dictionary  ${structure1}  transportNwId  ${INITIAL_TRANSPORT_NW_ID}
    Append Complex Item To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU-${gtpu_id}  list_name=sgwIpAddressList  &{structure1}  delta_id=${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}


Check LTE Cells
    [Arguments]  ${blocking_state}  ${operational_state}

    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Assert Every  LNCEL  blockingState=${blocking_state}, operationalState=${operational_state}  timeout=60


Check Cells Except LTE Cells
    [Arguments]  ${blocking_state}  ${operational_state}

    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Assert Every  GNCEL  blockingState=${blocking_state}, operationalState=${operational_state}  timeout=60
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Assert Every  WNCEL  blockingState=${blocking_state}, operationalState=${operational_state}  timeout=60
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Assert Every  NRCEL  blockingState=${blocking_state}, operationalState=${operational_state}  timeout=60


Check GTPU Link Status
    [Arguments]  ${availability_status}

    ${gtpu_path_object}  Query Infomodel  get object //GTPU_PATH-*
    Should Be Equal  ${gtpu_path_object}[stateInfo][availabilityStatus]  ${availability_status}


Check Ip Address For Serving Gateway
    [Arguments]  ${ip_address}

    ${gtpu_path_object}  Query Infomodel  get object //GTPU_PATH-*
    Should Be Equal  ${gtpu_path_object}[destIpAddress]  ${ip_address}


Add Random LTE Cells
    [Arguments]  ${number_of_random_cells}  ${random_max_size}

    FOR  ${index}  IN RANGE  0  ${number_of_random_cells}
        Add Random Index  ${random_max_size}
    END


Add Random Index
    [Arguments]  ${max_number}

    FOR  ${index}  IN RANGE  0  ${max_number}
        ${status}  Run Keyword And Return Status
        ...  List Should Not Contain Value  ${RANDOM_CELLS_LIST}  ${index}
        Run Keyword If  ${status}
        ...  Append To List  ${RANDOM_CELLS_LIST}  ${index}
    END


Check Rx/tx States For One Cell
    [Arguments]  ${cell_info}

    ${cell_dn}  Get From List  ${cell_info}  0
    ${cell_id}  Fetch From Right  ${cell_dn}  -
    ${rx/tx_list}  Get From List  ${cell_info}  -1
    ${status}  Run Keyword And Return Status
    ...  Check Rx/tx  ${rx/tx_list}  Online
    Run Keyword If  ${status}
    ...  Log  Services over Rx/Tx for LTE cell ${cell_id} are Online [OK].  console=true
    ...  ELSE
    ...  Set Test Failed  Services over Rx/Tx for LTE cell ${cell_id} are not Online [NOK].  console=true


Check Rx/tx
    [Arguments]  ${rx/tx_list}  ${state}

    FOR  ${rx/tx_item}  IN  @{rx/tx_list}
        Should Be Equal  ${rx/tx_item}[-1]  ${state}
    END


Admin Get LTE CELL Info
    [Documentation]
    ...  Keyword providing LTE CELL information.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter     | Description               |
    ...  | LTE_CELL_info | List of LTE cells details |
    ...
    ...  *EXAMPLE*
    ...  | ${LTE_CELL_info}= | Admin Get LTE CELL info | Slave |
    [Arguments]  ${alias}=default

    ${lte_cell_parameters_list}  Admin Get LTE CELL Parameters Info List  alias=${alias}
    ${lte_cell_info}  Create List
    FOR  ${item}  IN  @{lte_cell_parameters_list}
        ${tx_total}
        ...  ${rx_total}
        ...  ${tx_online}
        ...  ${rx_online}
        ...  ${tx_failed}
        ...  ${rx_failed}
        ...  ${tx_degraded}
        ...  ${rx_degraded}
        ...  ${tx_dependency}
        ...  ${rx_dependency}
        ...  ${cell_tx_rx_state}
        ...  Get Cell TX RX State Info  carrier_list=${item[5]}  alias=${alias}
        @{temp}  Create List  ${item[0]}  ${item[1]}  ${item[2]}  ${item[3]}  ${item[4]}  ${tx_total}  ${rx_total}  ${tx_online}  ${rx_online}
        ...  ${tx_failed}  ${rx_failed}  ${tx_degraded}  ${rx_degraded}  ${tx_dependency}  ${rx_dependency}  ${cell_tx_rx_state}
        Append To List  ${lte_cell_info}  ${temp}
    END
    Sort List  ${lte_cell_info}

    [Return]  ${lte_cell_info}


Admin Get LTE CELL Parameters Info List
    [Documentation]
    ...  KW providing info of LTE cells configured on BTS
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                       |
    ...  | alias     | Yes   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                                      |
    ...  | LTE_CELL_param_list  | List of LTE cells parameters extracted via query |
    [Arguments]  ${alias}

    ${lte_cells_info_list}  coam.Get Cell List  alias=${alias}
    ${lte_cell_param_list}  Create List
    FOR  ${item}  IN  @{lte_cells_info_list['cells']['lte']}
        Continue For Loop If  '${item['technology']}' not in ['FDD','TDD']
        ${conf_ref_obj}  ute_admin_infomodel.Query Infomodel  get object ${item['id']['internal']}/CONF_REF-1  alias=${alias}
        ${lncel_a_param}  ute_admin_infomodel.Query Infomodel  query=get object ${conf_ref_obj.distName}  alias=${alias}
        ${lncel_techno_a_param}  ute_admin_infomodel.Query Infomodel
        ...  query=get object ${conf_ref_obj.distName}/LNCEL_${lncel_a_param['cellTechnology']}_A-0  alias=${alias}
        @{temp}  Create List  ${item['id']['internal']}  ${item['downlinkMimoMode']}  ${lncel_techno_a_param['syncSigTxMode']}
        ...  ${lncel_a_param['actOtdoa']}  ${lncel_a_param['actPrsTxDiv']}  ${item['carrierList']}
        Append To List  ${lte_cell_param_list}  ${temp}
    END
    Sort List  ${lte_cell_param_list}

    [Return]  ${lte_cell_param_list}


Get Cell TX RX State Info
    [Documentation]
    ...  Helper KW providing list of TX/RXs on each channel, separated by state
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter      | Man. | Description                                    |
    ...  | carrierList    | Yes  | list of cariers to be parsed                   |
    ...  | alias          | Yes  | Alias used via taf.sbts.oam.coam.admin library |
    ...
    ...  *RETURN*
    ...  | Number of TX/RXs on each channel and states |
    [Arguments]  ${carrier_list}  ${alias}=default

    ${cell_tx_rx_state}  Create List
    FOR  ${item}  IN  @{carrier_list}
        ${channel_m_param}  ute_admin_infomodel.Query Infomodel  query=get object ${item['id']['internal']}  alias=${alias}
        ${tx_total}  Evaluate Value  0  ${channel_m_param['direction']}  TX
        ${rx_total}  Evaluate Value  0  ${channel_m_param['direction']}  RX
        ${tx_online}  Evaluate Value  0  ${channel_m_param['direction']}  TX  ${channel_m_param['stateInfo']['availabilityStatus']}  Online
        ${rx_online}  Evaluate Value  0  ${channel_m_param['direction']}  RX  ${channel_m_param['stateInfo']['availabilityStatus']}  Online
        ${tx_failed}  Evaluate Value  0  ${channel_m_param['direction']}  TX  ${channel_m_param['stateInfo']['availabilityStatus']}  Failed
        ${rx_failed}  Evaluate Value  0  ${channel_m_param['direction']}  RX  ${channel_m_param['stateInfo']['availabilityStatus']}  Failed
        ${tx_degraded}  Evaluate Value  0  ${channel_m_param['direction']}  TX  ${channel_m_param['stateInfo']['availabilityStatus']}  Degraded
        ${rx_degraded}  Evaluate Value  0  ${channel_m_param['direction']}  RX  ${channel_m_param['stateInfo']['availabilityStatus']}  Degraded
        ${tx_dependency}  Evaluate Value  0  ${channel_m_param['direction']}  TX  ${channel_m_param['stateInfo']['availabilityStatus']}  Dependency
        ${rx_dependency}  Evaluate Value  0  ${channel_m_param['direction']}  RX  ${channel_m_param['stateInfo']['availabilityStatus']}  Dependency
        @{temp}  Create List  ${channel_m_param['direction']}  ${channel_m_param['stateInfo']['availabilityStatus']}
        Append To List  ${cell_tx_rx_state}  ${temp}
    END
    Sort List  ${cell_tx_rx_state}

    [Return]  ${tx_total}  ${rx_total}  ${tx_online}  ${rx_online}  ${tx_failed}  ${rx_failed}  ${tx_degraded}  ${rx_degraded}  ${tx_dependency}
    ...  ${rx_dependency}  ${cell_tx_rx_state}


Evaluate Value
    [Documentation]
    ...  Helper KW providing counting specifc parameter appearance based on multiple conditions
    ...
    ...  *AUTHOR*
    ...  adelina.branc@nokia.com
    ...
    ...  | Parameter          | Man. | Description                                 |
    ...  | param_to_evaluate  | Yes  | parameter to be evaluated                   |
    ...  | exp_value1         | Yes  | first expected value from first condition   |
    ...  | value_to_check1    | Yes  | first checked value from first condition    |
    ...  | exp_value2         | No   | second expected value from second condition |
    ...  | value_to_check12   | No   | second checked value from second conditio   |
    ...
    ...  *RETURN*
    ...  | Total parameter appearances |
    [Arguments]  ${param_to_evaluate}  ${exp_value1}  ${value_to_check1}  ${exp_value2}=${False}  ${value_to_check2}=${False}

    ${value}  Run Keyword If  '${value_to_check1}' == '${exp_value1}' and '${value_to_check2}' == '${exp_value2}'
    ...  Evaluate  ${param_to_evaluate} + 1
    ...  ELSE
    ...  Evaluate  ${param_to_evaluate} + 0

    [Return]  ${value}


TC Setup
    Common Test Setup  tc_name=FM__Link_break_GTPU
    Setup NetAct


TC Teardown
    Teardown NetAct
    Common Test Teardown
