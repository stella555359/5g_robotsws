*** Settings ***
Documentation
    ...  This TC is created to get vDU info by the M2M interface.
    ...  Generate the token and log in.
    ...  In Step 1, the info for all vDUs is checked in both the curl command output and TAF library KW output.
    ...  In Step 2, the info for one vDU by distname is checked in both the curl command output and TAF library KW output.
    ...  In Step 3, the info for one vDU by ID is checked in both the curl command output and TAF library KW output.
    ...  All fields are checked to have the same syntax and same values.
    ...  Log out with the initial token.

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vcu_frame.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__Get_Info_About_vDU_State_Data_By_M2M_Interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25190
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  25.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25190 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com  MAINTAINER-cosmina.rebenciuc@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  FEATURE-CB009444

    Step1: Get VDU State Data
    Step2: Check State For One VDU By DistName
    Step3: Check State For One VDU By Id


Step1: Get VDU State Data
    Log  \nStep1: Get vDU state data.  console=true
    ${vdu_output_command}  Run M2M Command  GET  https://${VCU_OAM_IP}/api/licensed/v1/dus/diff  Bearer  ${TOKEN}
    ${vdu_parameters}  vcu.Get Dus Diff
    ${dist_name}  Set Variable  ${vdu_parameters}[created][0][dist_names][config]
    ${id_vdu}  Set Test Variable  ${VDU_PARAMETERS}[CREATED][0][ID]
    ${distname_vdu}  Replace String  ${dist_name}  /  %2F
    Set Test Variable  ${DIST_NAME_VDU}  ${distname_vdu}
    Check Fields In Command Output For VDU  ${vdu_output_command}  ${VDU_PARAMETERS}


Step2: Check State For One VDU By DistName
    Log  \nStep2: Check state for one vDU by distName.  console=true
    ${url}  Set Variable  https://${VCU_OAM_IP}:443/api/licensed/v1/dus?duId=${DIST_NAME_VDU}
    ${vdu_output_command}  Run M2M Command  GET  ${url}  Bearer  ${TOKEN}
    Check Fields In Command Output For VDU By DistName  ${vdu_output_command}


Step3: Check State For One VDU By Id
    Log  \nStep3: Check state for one vDU by id.  console=true
    ${url}  Set Variable  https://${VCU_OAM_IP}/api/licensed/v1/dus?duId=${ID_VDU}
    ${vdu_output_command}  Run M2M Command  GET  ${url}  Bearer  ${TOKEN}
    ${vdu_parameters}  vcu.Get Du  ${ID_VDU}
    Check Fields In Command Output For VDU By Id  ${vdu_output_command}  ${vdu_parameters}


Check Fields In Command Output For VDU
    [Arguments]  ${vdu_command}  ${vdu_state}

    ${status}  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${vdu_state}  created
    ${vdu_state}  Set Variable If  ${status}  ${vdu_state}[created]  ${vdu_state}
    ${status}  Evaluate  isinstance(${vdu_state},list)
    ${vdu_state}  Set Variable If  ${status}  ${vdu_state}[0]  ${vdu_state}
    ${value_of_alarms}  Set Variable  ${vdu_state}[alarms]
    ${value_of_cell_groups}  Set Variable  ${vdu_state}[cell_groups]
    ${value_cell_ids_list}  Set Variable  ${vdu_state}[cell_groups][0][cell_ids]
    ${value_cell_ids}  Set Variable  ${value_of_cell_groups}[0][id]
    ${regex}  Set Variable  [{("|')cell?_?(i|I)(ds)"|':\s?[("|')${value_cell_ids_list}](,)\s?("|')id("|'):\s?("|')${value_cell_ids}("|')}]
    ${value_locked}  Set Variable  ${vdu_state}[cells_summary][basic_cells_summary][administrative_state][locked]
    ${value_shutting_down}  Set Variable  ${vdu_state}[cells_summary][basic_cells_summary][administrative_state][shutting_down]
    ${value_unlocked}  Set Variable  ${vdu_state}[cells_summary][basic_cells_summary][administrative_state][unlocked]
    ${value_disabled}  Set Variable  ${vdu_state}[cells_summary][basic_cells_summary][operational_state][disabled]
    ${value_enabled}  Set Variable  ${vdu_state}[cells_summary][basic_cells_summary][operational_state][enabled]
    Check Value  ${vdu_command}  id  "id":"${vdu_state}[id]"
    Check Value  ${vdu_command}  name  "name":"${vdu_state}[name]"
    Check Value  ${vdu_command}  alarms  "alarms":\\${value_of_alarms}
    Check Value  ${vdu_command}  gnbDuId  "gnbDuId":"${vdu_state}[gnb_du_id]"
    Check Value  ${vdu_command}  gnbDuName  "gnbDuName":"${vdu_state}[gnb_du_name]"
    Check Value  ${vdu_command}  administrativeState  "administrativeState":"${vdu_state}[administrative_state]"
    Check Value  ${vdu_command}  f1LinkStatus  "f1LinkStatus":"${vdu_state}[f1_link_status]"
    Check Value  ${vdu_command}  cells_ids  ${regex}
    Check Value  ${vdu_command}  distNames  "distNames":({"config":)?"${vdu_state}[dist_names][config]"
    Check Value  ${vdu_command}  locked  ("|')locked("|'):\s?${value_locked}
    Check Value  ${vdu_command}  shutting_down  ("|')shutting(_|\\s)down("|'):(\s)?${value_shutting_down}
    Check Value  ${vdu_command}  unlocked  ("|')unlocked("|'):\s?${value_unlocked}
    Check Value  ${vdu_command}  disabled  ("|')disabled("|'):\s?${value_disabled}
    Check Value  ${vdu_command}  enabled  ("|')enabled("|'):\s?${value_enabled}


Check Fields In Command Output For VDU By Id
    [Arguments]  ${vdu_command}  ${vdu_state}

    ${status}  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${vdu_state}  created
    ${vdu_state}  Set Variable If  ${status}  ${vdu_state}[created]  ${vdu_state}
    ${status}  Evaluate  isinstance(${vdu_state},list)
    ${vdu_state}  Set Variable If  ${status}  ${vdu_state}[0]  ${vdu_state}
    ${value_dist_names}  Evaluate  ${vdu_state}[dist_names].get('config')
    ${value_cell_ids_list}  Evaluate  ${vdu_state}[cell_groups][0].get('cell_ids')
    ${value_cell_ids}  Evaluate  ${vdu_state}[cell_groups][0].get('id')
    ${regex}  Set Variable  [{("|')cell?_?(i|I)(ds)"|':\s?[("|')${value_cell_ids_list}](,)\s?("|')id("|'):\s?("|')${value_cell_ids}("|')}]
    ${value_cells_summary}  Evaluate  ${vdu_state}.get('cells_summary')
    ${value_locked}  Evaluate  ${value_cells_summary}[basic_cells_summary][administrative_state].get('locked')
    ${value_shutting_down}  Evaluate  ${value_cells_summary}[basic_cells_summary][administrative_state].get('shutting_down')
    ${value_unlocked}  Evaluate  ${value_cells_summary}[basic_cells_summary][administrative_state].get('unlocked')
    ${value_disabled}  Evaluate  ${value_cells_summary}[basic_cells_summary][operational_state].get('disabled')
    ${value_enabled}  Evaluate  ${value_cells_summary}[basic_cells_summary][operational_state].get('enabled')
    Check Value  ${vdu_command}  id  "id":"${vdu_state}[id]"
    Check Value  ${vdu_command}  name  "name":"${vdu_state}[name]"
    Check Value  ${vdu_command}  alarms  "alarms":\\${vdu_state}[alarms]
    Check Value  ${vdu_command}  gnbDuId  "gnbDuId":"${vdu_state}[gnb_du_id]"
    Check Value  ${vdu_command}  gnbDuName  "gnbDuName":"${vdu_state}[gnb_du_name]"
    Check Value  ${vdu_command}  administrativeState  "administrativeState":"${vdu_state}[administrative_state]"
    Check Value  ${vdu_command}  f1LinkStatus  "f1LinkStatus":"${vdu_state}[f1_link_status]"
    Check Value  ${vdu_command}  cells_ids  ${regex}
    Check Value  ${vdu_command}  distNames  "distNames":({"config":)?"${value_dist_names}"
    Check Value  ${vdu_command}  locked  ("|')locked("|'):\s?${value_locked}
    Check Value  ${vdu_command}  shutting_down  ("|')shutting(_|\\s)down("|'):(\s)?${value_shutting_down}
    Check Value  ${vdu_command}  unlocked  ("|')unlocked("|'):\s?${value_unlocked}
    Check Value  ${vdu_command}  disabled  ("|')disabled("|'):\s?${value_disabled}
    Check Value  ${vdu_command}  enabled  ("|')enabled("|'):\s?${value_enabled}


Check Fields In Command Output For VDU By DistName
    [Arguments]  ${vdu_command}

    Check Value  ${vdu_command}  id  "id":"[0-9]+"
    Check Value  ${vdu_command}  name  "name":"NRDU-[0-9]+"
    Check Value  ${vdu_command}  alarms  "alarms":\\[\\]
    Check Value  ${vdu_command}  gnbDuId  "gnbDuId":"[0-9]+"
    Check Value  ${vdu_command}  gnbDuName  "gnbDuName":"vDU[0-9]+"
    Check Value  ${vdu_command}  administrativeState  "administrativeState":"Unlocked"
    Check Value  ${vdu_command}  f1LinkStatus  "f1LinkStatus":"available"
    Check Value  ${vdu_command}  cells_ids  "cellIds":\\[(?:"[0-9]+",?)*\\]
    Check Value  ${vdu_command}  distNames  "distNames":\{"config":"MRBTS-[0-9]+\/NRBTS-[0-9]+\/NRDU-[0-9]+"\}
    Check Value  ${vdu_command}  locked  "locked":[0-9]+
    Check Value  ${vdu_command}  shutting_down  "shutting down":[0-9]+
    Check Value  ${vdu_command}  unlocked  "unlocked":[0-9]+
    Check Value  ${vdu_command}  disabled  "disabled":[0-9]+
    Check Value  ${vdu_command}  enabled  "enabled":[0-9]+


Check Value
    [Arguments]  ${command}  ${key}  ${value}

    Should Match Regexp  ${command}  ${value}  msg=In the command output ${key} field is not visible correctly! [NOK]
    Log  In the command output ${key} field is visible correctly! [OK]  console=true


TC Setup
    Common VCU Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__Get_Info_About_vDU_State_Data_By_M2M_Interface
    Login Using M2M Interface  ${VCU_OAM_IP}


TC Teardown
    Logout Using M2M Interface  ${VCU_OAM_IP}
    Common VDU Teardown
    Common VCU Teardown
