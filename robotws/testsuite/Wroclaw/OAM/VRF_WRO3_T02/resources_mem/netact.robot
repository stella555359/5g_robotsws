*** Settings ***
Library         taf.nms.netact  WITH NAME  netact
Library         XML  use_lxml=true
Resource        ../resources_mem/alarms.robot

Documentation
...  AUTHORS:       artur.lebek@nokia.com, tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  20.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-372 - update KW "Workaround For Empty NETACT_ID" for CB005891 and CB006830
...  19.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-449 - update KW "Automatic Netact Integration" -variable mr=MRC-COMMON/MR-COMMON
...  21.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-428 - New KW due to TC PS.46 creation
...  21.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-462 - Update KW "Automatic Netact Integration"
...  28.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-462 - New KW to Workaround for failed Netact Integration
...  26.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-566 - FIX KW to Workaround for failed Netact Integration
...  24.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-585 - Rework KW "Check Cells State In Netact" to include LTE energySavingState
...  07.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAW-621 - Rework KW "Workaround For Empty NETACT_ID"; add new KWs: "Get Valid Netact Lab",
...                  "Set NetAct Related Variables To None", "Check If Services Are Running On Lab", "Get NIDD From AIRSCALE", "Get NIDD From FSMF",
...                  "Check If SSH Login Is Possible" and "Check For NIDD Baseline On Netact Lab"
...  11.02.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-15603 - improvements for automatic NetAct integration
...  06.08.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-23345 and FCA_VRF_OAM-24304 - Modify keywords: "Check Cells State In Netact",
...               "Setup TAF Netact", "Automatic Netact Integration", "Get Valid Netact Lab", "Check If Services Are Running On Lab" and
...               "Check If Actions Are Supported On Lab"; Add keywords: "Get Formatted Date From NetAct Lab", "Check For MRC-/MR- On Lab",
...               "Create Dictionary For Operation Group", "Get Latest Failed Operation Group ID", "Get Reasons List For Failed Operation Group" and
...               "Change Web Service User Credentials"
...  21.11.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-30810 - Add expected faults related to CBRS after site reset
...  xx.xx..2022 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
Setup TAF Netact
    ${is_in_test}  Run Keyword And Return Status  Set Test Variable  ${INTEGRATED_TO_NETACT}  ${FALSE}
    Run Keyword If  not ${is_in_test}  Set Suite Variable  ${INTEGRATED_TO_NETACT}  ${FALSE}
    netact.Add Web URL  ${LBWAS_NODE}  ${NA_USER}  ${NA_PASS}
    netact.Add Node  cmwas  ${NA_HOST}  ${NA_USER}  ${NA_PASS}
    netact.Add Node  fmwas  ${NA_HOST}  ${NA_USER}  ${NA_PASS}
    ${INTEGRATED_TO_NETACT}  Run Keyword And Return Status  Automatic Netact Integration
    ${NA_ID}  Get Substring  ${LBWAS_NODE}  0  -26
    Run Keyword If  ${INTEGRATED_TO_NETACT}  Run Keywords  Log  Integrated to NetAct ID ${NA_ID}  WARN
    ...                                               AND  Log  NetAct: <a href="https://${LBWAS_NODE}">${NA_ID}</a>  WARN  html=True
    [Teardown]  Run Keyword If  ${is_in_test}  Set Test Variable   ${INTEGRATED_TO_NETACT}
    ...                                  ELSE  Set Suite Variable  ${INTEGRATED_TO_NETACT}

Teardown TAF Netact
    Run Keyword And Ignore Error  netact.Deintegrate MRBTS from NetAct  dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
    netact.Delete Node  fmwas
    netact.Delete Node  cmwas
    netact.Clean All

Workaround For Empty NETACT_ID
    [Documentation]  Keyword checks if NetAct lab given in ${NETACT_ID} variable supports active SW NIDD.
    ...  If ${NETACT_ID} variable does not exist or given NetAct lab is currently invalid, then other labs are checked and new ${NETACT_ID} is set.
    ...  If no lab is found then ${NETACT_ID} is set to 'None'.
    ...  (as workaround in zero touch regression activities).
    ${NETACT_ID}  Get Variable Value  ${NETACT_ID}    # returns None if variable doesn't exist
    ${is_fsmf}  Run Keyword And Return Status  Should Match Regexp  '${SMOD_COMPOSITION}'  'FSMF(\\+FSMF)?'
    ${detected_smod}  Set Variable If  ${is_fsmf}  FSMF  AIRSCALE
    ${selected_netact}  Get Valid Netact Lab  smod_type=${detected_smod}  preferred_lab=${NETACT_ID}
    ${selected_netact}  Run Keyword If  '${selected_netact}'=='None'
    ...                                  Get Valid Netact Lab  smod_type=${detected_smod}  preferred_lab=${NETACT_ID}
    ...                           ELSE   Set Variable  ${selected_netact}
    Set Suite Variable  ${NETACT_ID}  ${selected_netact}
    Run Keyword If  '${NETACT_ID}'=='None'  Log  Variable NETACT_ID is set to 'None'.  WARN

Check If Alarms From ENB And NetAct Are The Same
    [Documentation]  Gather alarms from eNB and NetAct and check if they are the same.
    ${admin_alarms}=  Get Active FaultIDs
    Sort List  ${admin_alarms}
    ${netact_alarms}=  Get NetAct Active FaultIDs
    Sort List  ${netact_alarms}
    ${status}  Run Keyword And Return Status  Lists Should Be Equal  ${admin_alarms}  ${netact_alarms}
    Run Keyword If  not ${status}  Log  Some alarms in NetAct are missing  console=${True}

Automatic Netact Integration
    [Arguments]  ${mr}=MRC-COMMON/MR-COMMON
    Wait Until Keyword Succeeds  6x  5s  admin.Setup Admin  admin_api_log_dir=/home/ute/test_results/admin_api/
    ...                                                                      update_interval=500
    ...                                                                      alias=netact_admin
    ${nms_state}  admin.Get NMS State  connection=netact_admin
    Run Keyword And Ignore Error  netact.Deintegrate MRBTS from NetAct  dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
    Set Parameter To Expected Value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                              parameter=oamTls
    ...                              expected_value=off
    ${lab_date}  Get Formatted Date From NetAct Lab  ${NA_HOST}  ${NA_USER}  ${NA_PASS}
    ${1st_try_status}  Run Keyword And Return Status  netact.Integrate MRBTS with NetAct  release=${SW_TYPE}
    ...                                                                                   mr=${mr}
    ...                                                                                   mrbts_address=${ENB_MPLANE_IP}
    ...                                                                                   dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ...                                                                                   security_mode=no TLS
    Run Keyword If  not ${1st_try_status}
    ...             Run Keywords  Log To Console  \nNetAct Integration failed
    ...                      AND  Change Web Service User Credentials
    ...                      AND  Remove All ne3sadapt Files
    ...                      AND  Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    ...                      AND  Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ...                      AND  Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...                      AND  Allow Fault In Watchdog  faultID=6150  #fault_name: GTP-U Path failure can be visible during startup
    ...                      AND  Log To Console  Resetting BTS...
    ...                      AND  admin.Reset Site  connection=netact_admin  timeout=700
    ...                      AND  Log To Console  Checking BTS after reset...
    ...                      AND  Full Check After Start-up
    ...                      AND  Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    ...                      AND  Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ...                      AND  Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...                      AND  Disallow Fault In Watchdog  faultID=6150  #fault_name: GTP-U Path failure
    ...                      AND  Log To Console  \nRetrying NetAct Integration...
    ${2nd_try_status}  Run Keyword If  not ${1st_try_status}  Run Keyword And Return Status
    ...                                                    netact.Integrate MRBTS with NetAct  release=${SW_TYPE}
    ...                                                                                        mr=${mr}
    ...                                                                                        mrbts_address=${ENB_MPLANE_IP}
    ...                                                                                        dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ...                                                                                        security_mode=no TLS
    ${group_id}  Get Latest Failed Operation Group ID  ${lab_date}
    ${reason_list}  Run Keyword If  "${group_id}"!="None"  Get Reasons List For Failed Operation Group  ${group_id}
    Run Keyword If  ${1st_try_status} or ${2nd_try_status}
    ...             Log To Console  NetAct Integration completed
    ...       ELSE  Run Keywords  Log  NetAct Integration failed    WARN
    ...                      AND  Fail  msg=Integration not done, possible troubleshooting: ${reason_list}
    ${nms_state_after_integration}  admin.Get NMS State  connection=netact_admin
    Run Keyword If  ${nms_state[0]['managerInfo']}  Log  NMS managerInfo before integration: ${nms_state[0]['managerInfo']}  WARN
    [Teardown]  Run Keyword And Ignore Error  admin.Teardown Admin  alias=netact_admin

Remove All ne3sadapt Files
    Log To Console  Removing ne3sadaptdata.db file...
    common.Execute SSH Command On BTS  command=rm ../ne3sadapt/configs/ne3sadaptdata.db
    Log To Console  BTS needs to be rebooted.

Get NetAct Active FaultIDs
    [Documentation]  Keyword returns list of active faultIds visible on NetAct.
    ${na_alarms}  netact.Get Alarms  dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ${netact_alarms}  Create List
    ${regex}=  Set Variable  additionalFaultID=(?P<faultId>\\d+)
    FOR  ${alarm}  IN  @{na_alarms}
        ${faultId}  Get Regexp Matches  ${alarm['additionalText3']}  ${regex}  faultId
        ${fault}=  Convert To Integer  ${faultId[0]}
        Append To List  ${netact_alarms}  ${fault}
    END
    [Return]  ${netact_alarms}

Set Feature Under LNBTS/NRBTS Via NA
    [Documentation]  Keyword setting indicated valuse for chosen feature under LNBTS/NRBTS objects Via NA
    ...  Example of usage:
    ...  Set Feature Under LNBTS/NRBTS Via NA  enableGrflShdn  1  LNBTS
    [Arguments]  ${feature}  ${value}  ${object}
    ${current_date}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${SCF_PATH}=  Set Variable  ${RESULTS}/SCF_BACKUP.xml
    ${meta_ver}=  Run Keyword If  '${object}'=='LNBTS'  Get Meta Version Or Class From SCFC  ${SCF_PATH}
    ...  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}  version
    ...  ELSE IF  '${object}'=='NRBTS'  Get Meta Version Or Class From SCFC  ${SCF_PATH}
    ...  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  version
    ${meta_class}=  Run Keyword If  '${object}'=='LNBTS'  Get Meta Version Or Class From SCFC  ${SCF_PATH}
    ...  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}  class
    ...  ELSE IF  '${object}'=='NRBTS'  Get Meta Version Or Class From SCFC  ${SCF_PATH}
    ...  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  class
    Set Test Variable  ${meta_ver}
    Set Test Variable  ${meta_class}
    Set Test Variable  ${delta}  MRBTS-${MRBTS_ID}_Plan_${feature}
    Run Keyword And Ignore Error  netact.delete plan  ${delta}
    ${plan}=  netact.create plan configuration  name=${delta}  description=Automation WRO1 for MRBTS-${MRBTS_ID}_Plan_${feature}
    ${managed_objects}=  Run Keyword If  '${object}'=='LNBTS'  netact.create managed object  plan=${plan}  meta_class=${meta_class}
    ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}  ${feature}=${value}
    ...  ELSE IF  '${object}'=='NRBTS'  netact.create managed object  plan=${plan}  meta_class=${meta_class}
    ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  ${feature}=${value}
    Log To Console  Plan provisioning via NetAct ${feature} changing to ${value}
    netact.provision plan  MRBTS-${MRBTS_ID}_Plan_${feature}  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}  create_backup_plan=true
    ...  backup_plan_name=${MRBTS_ID}_${current_date}_backup

Set Feature Under FEATLADM Via NA
    [Documentation]  Keyword setting indicated valuse for chosen feature under FEATLADM object Via NA
    ...  Example of usage:
    ...  Set Feature Under FEATLADM Via NA  actLBBbPowerSaving  true
    [Arguments]  ${feature}  ${value}
    ${current_date}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${SCF_PATH}=  Set Variable  ${RESULTS}/SCF_BACKUP.xml
    ${FEATLADM_DN}=  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1
    ${LNBTS_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
    ${meta_ver}=  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${FEATLADM_DN}  version
    ${meta_class}=  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${FEATLADM_DN}  class
    Set Test Variable  ${meta_ver}
    Set Test Variable  ${meta_class}
    Set Test Variable  ${delta}  MRBTS-${MRBTS_ID}_Plan_${feature}
    Run Keyword And Ignore Error  netact.delete plan  ${delta}
    ${plan}=  netact.create plan configuration  name=${delta}  description=Automation WRO1 for MRBTS-${MRBTS_ID}_Plan_${feature}
    ${managed_objects}=  netact.create managed object  plan=${plan}  meta_class=${meta_class}
    ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1  ${feature}=${value}
    Log To Console  Plan provisioning via NetAct ${feature} changing to ${value}
    netact.provision plan  MRBTS-${MRBTS_ID}_Plan_${feature}  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}  create_backup_plan=true
    ...  backup_plan_name=${MRBTS_ID}_${current_date}_backup

Set Feature Under FEATCADM Via NA
    [Documentation]  Keyword setting indicated valuse for chosen feature under FEATCADM object Via NA
    ...  Example of usage:
    ...  Set Feature Under FEATCADM Via NA  actRadioDeepSleepTimeSchedule  true
    [Arguments]  ${feature}  ${value}
    ${current_date}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${SCF_PATH}=  Set Variable  ${RESULTS}/SCF_BACKUP.xml
    ${FEATCADM_DN}=  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${LNBTS_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
    ${meta_ver}=  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${FEATCADM_DN}  version
    ${meta_class}=  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${FEATCADM_DN}  class
    Set Test Variable  ${meta_ver}
    Set Test Variable  ${meta_class}
    Set Test Variable  ${delta}  MRBTS-${MRBTS_ID}_Plan_${feature}
    Run Keyword And Ignore Error  netact.delete plan  ${delta}
    ${plan}=  netact.create plan configuration  name=${delta}  description=Automation WRO1 for MRBTS-${MRBTS_ID}_Plan_${feature}
    ${managed_objects}=  netact.create managed object  plan=${plan}  meta_class=${meta_class}
    ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  ${feature}=${value}
    Log To Console  Plan provisioning via NetAct ${feature} changing to ${value}
    netact.provision plan  MRBTS-${MRBTS_ID}_Plan_${feature}  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}  create_backup_plan=true
    ...  backup_plan_name=${MRBTS_ID}_${current_date}_backup

Change Administrative State For LNCELL/NRCELL Via NA
    [Documentation]  Keyword setting indicated administrative state for chosen cell via NA
    ...  Example of usage:
    ...  Change Administrative State For LNCELL/NRCELL Via NA  LNCEL  administrativeState  2  ${1st_cell_id}  LNBTS
    [Arguments]  ${type}  ${parameter}  ${value}  ${cell}  ${object}
    ${current_date}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${SCF_PATH}=  Set Variable  ${RESULTS}/SCF_BACKUP.xml
    ${meta_ver}=  Run Keyword If  '${object}'=='LNBTS'  Get Meta Version Or Class From SCFC  ${SCF_PATH}
    ...  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${type}-${cell}  version
    ...  ELSE IF  '${object}'=='NRBTS'  Get Meta Version Or Class From SCFC  ${SCF_PATH}
    ...  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${type}-${cell}  version
    ${meta_class}=  Run Keyword If  '${object}'=='LNBTS'  Get Meta Version Or Class From SCFC  ${SCF_PATH}
    ...  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${type}-${cell}  class
    ...  ELSE IF  '${object}'=='NRBTS'  Get Meta Version Or Class From SCFC  ${SCF_PATH}
    ...  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${type}-${cell}  class
    Set Test Variable  ${meta_ver}
    Set Test Variable  ${meta_class}
    Set Test Variable  ${delta}  MRBTS-${MRBTS_ID}_Plan_${parameter}
    Run Keyword And Ignore Error  netact.delete plan  ${delta}
    ${plan}=  netact.create plan configuration  name=${delta}  description=Automation WRO1 for MRBTS-${MRBTS_ID}_Plan_${parameter}
    ${managed_objects}=  Run Keyword If  '${object}'=='LNBTS'  netact.create managed object  plan=${plan}  meta_class=${meta_class}
    ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${type}-${cell}  ${parameter}=${value}
    ...  ELSE IF  '${object}'=='NRBTS'  netact.create managed object  plan=${plan}  meta_class=${meta_class}
    ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${type}-${cell}  ${parameter}=${value}
    Log  Plan provisioning via NetAct for ${type}_R-${cell} ${parameter} change -> ${value}  console=${true}
    netact.provision plan  MRBTS-${MRBTS_ID}_Plan_${parameter}  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}  create_backup_plan=true
    ...  backup_plan_name=${MRBTS_ID}_${current_date}_backup

Get Meta Version Or Class From SCFC
    [Documentation]  Keyword return meta version or class from SCFC, depending on received value.
    ...   Author: tomasz.marchewka@nokia.com
    ...   <managedObject class="NOKLTE:LNBTS" distName="MRBTS-123/LNBTS-123" version="xL22R2_2113_100" operation="create">
    ...    ...
    ...   </managedObject>
    ...
    ...   Example of usage:
    ...   ${meta}=  Get Meta Version Or Class From SCFC  SCFC.xml  MRBTS-123/LNBTS-123  version
    ...
    [Arguments]  ${scf_path}  ${distName}  ${version_or_class}
    ${meta}=  Run Keyword If  '${version_or_class}'=='version'
    ...  Evaluate Xpath  ${scf_path}  string((//managedObject[contains(@distName,"${distName}")]/@version)[1])
    ...  ELSE IF  '${version_or_class}'=='class'
    ...  Evaluate Xpath  ${scf_path}  string((//managedObject[contains(@distName,"${distName}")]/@class)[1])
    [Return]  ${meta}

Set Parameter Under ALD Via NA
    [Documentation]  Keyword changing parameter value via NA under ALD object
    ...  Example of usage:
    ...  Set Parameter Under ALD Via NA  telemetryUpdateInterval  ${ID}  1
    [Arguments]  ${parameter}  ${ID}  ${value}
    ${current_date}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${SCF_PATH}=  Set Variable  ${RESULTS}/SCF_BACKUP.xml
    ${FEATLADM_DN}=  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-${ID}
    ${meta_ver}=  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${FEATLADM_DN}  version
    ${meta_class}=  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${FEATLADM_DN}  class
    Set Test Variable  ${meta_ver}
    Set Test Variable  ${meta_class}
    Set Test Variable  ${delta}  MRBTS-${MRBTS_ID}_Plan_${parameter}
    Run Keyword And Ignore Error  netact.delete plan  ${delta}
    ${plan}=  netact.create plan configuration  name=${delta}  description=Automation WRO1 for MRBTS-${MRBTS_ID}_Plan_${parameter}
    ${managed_objects}=  netact.create managed object  plan=${plan}  meta_class=${meta_class}
    ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-${ID}  ${parameter}=${value}
    Log To Console  Plan provisioning via NetAct ${parameter} changing to ${value}
    netact.provision plan  MRBTS-${MRBTS_ID}_Plan_${parameter}  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}  create_backup_plan=true
    ...  backup_plan_name=${MRBTS_ID}_${current_date}_backup

Remove Objects Via NA
    [Documentation]
    [Arguments]  ${object_dns}
    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${SCF_PATH}  Set Variable  ${RESULTS}/SCF_BACKUP.xml
    ${plan}  netact.create_plan_configuration  name=MRBTS-${MRBTS_ID}_Remove_Object_${timestamp}
                                          ...  description=Automation WRO1 for MRBTS-${MRBTS_ID}_Remove_Object_${timestamp}
    FOR  ${object_dn}  IN  @{object_dns}
        ${meta_version}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${object_dn}  version
        ${meta_class}    Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${object_dn}  class
        netact.create managed object  plan=${plan}  meta_class=${meta_class}  meta_version=${meta_version}
        ...  mo_id=PLMN-PLMN/${object_dn}  operation=DELETE
        Log To Console  ${object_dn} will be deleted via NetAct
    END
    netact.provision plan  plan_name=MRBTS-${MRBTS_ID}_Remove_Object_${timestamp}  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ...  create_backup_plan=true  backup_plan_name=${MRBTS_ID}_${timestamp}_backup
    Log To Console  Provision plan - done

Create HWRESETREQ Object Via NA
    [Arguments]  ${targetHwResetUDN}
    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${SCF_PATH}  Set Variable  ${RESULTS}/SCF_BACKUP.xml
    ${ID}  Evaluate  random.randint(1, 65535)  modules=random    #hwResetReqId range 1-65535
    ${HWRESETREQ_dn}  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/CMD-1/HWRESETREQ-${ID}
    ${plan}  netact.create_plan_configuration  name=MRBTS-${MRBTS_ID}_HWRESETREQ_Object_${timestamp}
                                          ...  description=Automation WRO1 for MRBTS-${MRBTS_ID}_HWRESETREQ_Object_${timestamp}
    ${meta_version}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  MRBTS-${MRBTS_ID}/MNL-1/CMD-1  version
    ${meta_class}    Set Variable  com.nokia.srbts.mnl:HWRESETREQ
    netact.create managed object  plan=${plan}  meta_class=${meta_class}  meta_version=${meta_version}
    ...  mo_id=PLMN-PLMN/${HWRESETREQ_dn}  operation=CREATE  targetHwResetUDN=${targetHwResetUDN}
    Log To Console  ${HWRESETREQ_dn} will be created via NetAct
    netact.provision plan  plan_name=MRBTS-${MRBTS_ID}_HWRESETREQ_Object_${timestamp}  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ...  create_backup_plan=true  backup_plan_name=${MRBTS_ID}_${timestamp}_backup
    Log To Console  Provision plan - done

Check Cells State In Netact
    [Arguments]  ${state_to_check}=operationalState  ${expected_state}=Enabled  ${print_cell_state}=False
    ${actual_conf}    netact.get actual configuration
    ${cells_list}  admin.get cell list
    ${all_cells}  Combine Lists  ${cells_list['cells']['lte']}  ${cells_list['cells']['nr']}  ${cells_list['cells']['wcdma']}
    Log To Console    Checking cell ${state_to_check} via NetAct:
    FOR  ${cell}  IN  @{all_cells}
        ${cell_DN}              Evaluate  '${cell}[id][configuration]'
        ${is_lte_or_nr}         Evaluate   bool(re.search(r'(?i)(LN|NR)CEL', $cell_DN))  re
        ${cell_from_actual_conf}    Get Managed Object   ${actual_conf}  PLMN-PLMN/${cell_DN}
        ${state_from_actual_conf}   Get From Dictionary  ${cell_from_actual_conf.parameters}  ${state_to_check}
        ${energysaving_from_actual_conf}  Run Keyword If  ${is_lte_or_nr}
        ...  Get From Dictionary  ${cell_from_actual_conf.parameters}  energySavingState
        ${state_converted}     Set Variable If  '${state_from_actual_conf}'=='0'  Disabled  Enabled
        ${expected_state_es}   Set Variable If  "${energysaving_from_actual_conf}"=="1"  Disabled  ${expected_state}
        ${message_to_print}    Set Variable If  "${energysaving_from_actual_conf}"=="1"
        ...                                     ${cell_DN} ${state_to_check}:${state_converted} (energy saving)
        ...                                     ${cell_DN} ${state_to_check}:${state_converted}
        Run Keyword If  ${print_cell_state}  Log To Console  ${message_to_print}
        Should Be Equal As Strings  ${state_converted}  ${expected_state_es}  ignore_case=True
    END
    Log To Console  All cells have expected state in NetAct.

Get Valid Netact Lab
    [Arguments]  ${smod_type}  ${preferred_lab}=None
    Log To Console  \nChecking for valid NetAct lab...
    ${valid_lab}  Set Variable  None
    ${nidd_baseline}  Run Keyword  Get NIDD From ${smod_type}
    ${nidd_baseline}  Run Keyword If  '${smod_type}'!='AIRSCALE'
    ...                                Remove String  ${nidd_baseline}  _NIDD
    ...                         ELSE   Set Variable   ${nidd_baseline}
    @{labs_files_list}  OperatingSystem.List Files In Directory  path=${CURDIR}/config/netact  pattern=cl*.py
    @{randomized_list}  Evaluate  random.sample(${labs_files_list}, len(${labs_files_list}))  modules=random
    ${index}  Get Index From List  ${randomized_list}  ${preferred_lab}.py    # returns -1 if value is not found
    Run Keyword If  ${index}>=0  Run Keywords  Set List Value  ${randomized_list}  ${index}  ${randomized_list[0]}
    ...                                   AND  Set List Value  ${randomized_list}  0         ${preferred_lab}.py
    FOR  ${lab_file}  IN  @{randomized_list}
        Exit For Loop If  '${nidd_baseline}'=='None'
        Run Keyword And Ignore Error  Import Variables  ${CURDIR}/config/netact/${lab_file}  # imports variables ${NA_HOST}, ${NA_USER} and ${NA_PASS}
        ${lab_info}  Set Variable  Lab ${lab_file[0:-3]} (${NA_HOST})
        ${lab_pingable}  Run Keyword And Return Status  Wait Until Keyword Succeeds  10s  5s  Check If Host Is Reachable  IP=${NA_HOST}
        ${login_possible}     Run Keyword If  ${lab_pingable}
        ...                                   Check If SSH Login Is Possible  ${NA_HOST}  ${NA_USER}  ${NA_PASS}
        ...                             ELSE  Run Keywords  Log To Console  ${lab_info} is not pingable.
        ...                                            AND  Continue For Loop
        ${nidd_on_lab}        Run Keyword If  ${login_possible}
        ...                                   Check For NIDD Baseline On Netact Lab  ${nidd_baseline}  ${NA_HOST}  ${NA_USER}  ${NA_PASS}
        ...                             ELSE  Run Keywords  Log To Console  ${lab_info}: can't login with given credentials.
        ...                                            AND  Continue For Loop
        ${mrc_and_mr_valid}   Run Keyword If  ${nidd_on_lab}
        ...                                   Check For MRC-/MR- On Lab  ${NA_HOST}  ${NA_USER}  ${NA_PASS}
        ...                             ELSE  Run Keywords  Log To Console  ${lab_info}: no fastpass for ${nidd_baseline}.
        ...                                            AND  Continue For Loop
        ${services_running}   Run Keyword If  ${mrc_and_mr_valid}
        ...                                   Check If Services Are Running On Lab  cmwas,fmwas  ${NA_HOST}  ${NA_USER}  ${NA_PASS}
        ...                             ELSE  Run Keywords  Log To Console  ${lab_info}: there is no MRC-COMMON/MR-COMMON.
        ...                                            AND  Continue For Loop
        ${actions_supported}  Run Keyword If  ${services_running}
        ...                                   Check If Actions Are Supported On Lab  ${NA_HOST}  ${NA_USER}  ${NA_PASS}
        ...                             ELSE  Run Keywords  Log To Console  ${lab_info}: required services are not running.
        ...                                            AND  Continue For Loop
        ${valid_lab}          Run Keyword If  ${actions_supported}  Set Variable  ${lab_file[0:-3]}
        ...                             ELSE  Log To Console  ${lab_info}: no support for ACTIONS.
        Exit For Loop If  '${valid_lab}'!='None'
    END
    Run Keyword If  '${preferred_lab}'!='None' and '${preferred_lab}'!='${valid_lab}'
    ...              Log To Console  Preferred NetAct lab (${preferred_lab}) does not meet required criteria.
    Run Keyword If  '${valid_lab}'!='None'
    ...              Log To Console  Lab ${valid_lab} (${NA_HOST}) is valid for ${nidd_baseline}
    ...       ELSE   Run Keywords  Log To Console  There is no cloud lab in resources that meets required criteria.
    ...                       AND  Set NetAct Related Variables To None
    [Return]  ${valid_lab}

Set NetAct Related Variables To None
    Set Suite Variable  ${LBWAS_NODE}  None
    Set Suite Variable  ${NA_HOST}     None
    Set Suite Variable  ${NA_USER}     None
    Set Suite Variable  ${NA_PASS}     None

Check If Services Are Running On Lab
    [Documentation]  Keyword returns False if any of the requested services is not started.
    [Arguments]  ${services}  ${host}  ${user}  ${password}
    ${services_list}  Split String  ${services}  separator=,
    ${connection}  ssh.Connect To  ${host}  ${user}  ${password}
    FOR  ${service}  IN  @{services_list}
        ${command}  Set Variable
        ...         /opt/cpf/sbin/netact_status.sh status service ${service} 2>/dev/null | grep $(hostname) | awk -F":" '{print $3}' | tr -d '\r\n'
        ${output}  ssh.Execute  command=${command}  connection=${connection}
        ssh.Await Execution End  connection=${connection}  timeout=60s
        Return From Keyword If  "${output}" != "started"  ${FALSE}
    END
    Return From Keyword  ${TRUE}
    [Teardown]  ssh.Disconnect  ${connection}

Get NIDD From AIRSCALE
    ${MNL_R_info}  admin.Get Managed Objects  MNL_R
    FOR  ${item}  IN  @{MNL_R_info}
        ${nidd_baseline}  Set Variable  ${item['parameters']['infoModelVersion']}
    END
    [Return]  ${nidd_baseline}

Get NIDD From FSMF
    ${output}  Execute SSH Command On BTS  command=grep _NIDD_ /ffs/run/vendor*.xml
    ${nidd_baseline}  Set Variable  None
    ${output_split}  Split String  ${output}  separator=${SPACE}
    FOR  ${line}  IN  @{output_split}
        Continue For Loop If  '_NIDD_' not in $line
        ${nidd_baseline}  ${ignore}  Split String From Right  ${line}  separator=_  max_split=1
        Exit For Loop
    END
    [Return]  ${nidd_baseline}

Check If SSH Login Is Possible
    [Arguments]  ${host}  ${user}  ${password}
    ${connection_attempt}  ${connection_result}  Run Keyword And Ignore Error  ssh.Connect To  ${host}  ${user}  ${password}
    Run Keyword If  '${connection_attempt}'=='PASS'  ssh.Disconnect  ${connection_result}
    ...                                       ELSE   Log To Console  ${connection_result}
    ${return_result}  Set Variable If  '${connection_attempt}'=='PASS'  ${TRUE}  ${FALSE}
    [Return]  ${return_result}

Check For NIDD Baseline On Netact Lab
    [Arguments]  ${baseline}  ${host}  ${user}  ${password}
    ${command}  Set Variable  grep -R ${baseline} /d/oss/global/var/fastpass/BOM/FastPass
    ${connection}  ssh.Connect To  ${host}  ${user}  ${password}
    ${output}  ssh.Execute  command=${command}  connection=${connection}
    ssh.Await Execution End  connection=${connection}  timeout=60s
    ssh.Disconnect  ${connection}
    ${match}  Run Keyword And Return Status  Should Contain  ${output}  ${baseline}
    [Return]  ${match}

Check If Actions Are Supported On Lab
    [Arguments]  ${host}  ${user}  ${password}
    ${command}  Set Variable  grep -P '(?!24R1)(2[4-9]|[3-9][0-9])R[1-9]|Trunk|PP1314' /etc/netact-release
    ${connection}  ssh.Connect To  ${host}  ${user}  ${password}
    ${output}  ssh.Execute  command=${command}  connection=${connection}
    ssh.Await Execution End  connection=${connection}  timeout=60s
    ssh.Disconnect  ${connection}
    ${match}  Run Keyword And Return Status  Should Not Be Empty  ${output}
    [Return]  ${match}

Get Formatted Date From NetAct Lab
    [Arguments]  ${host}  ${user}  ${password}  ${date_format}=%D %r
    ${command}  Set Variable  date +"${date_format}" | tr -d '\r\n'
    ${connection}  ssh.Connect To  ${host}  ${user}  ${password}
    ${output}  ssh.Execute  command=${command}  connection=${connection}
    ssh.Await Execution End  connection=${connection}  timeout=60s
    ssh.Disconnect  ${connection}
    [Return]  ${output}

Get Latest Failed Operation Group ID
    [Arguments]  ${operation_date}
    [Documentation]    Provide date in a format of 7/31/25 3:07:30 PM (%m/%d/%y %I:%M:%S %p)
    ${latest_group_id}  Set Variable  None
    ${operation_groups}  netact.Fetch Operation Groups  group_count=10
    ${operation_groups_list}  Split String  ${operation_groups}  separator=\n\n
    ${groups_to_check}  Create List
    FOR  ${group}  IN  @{operation_groups_list}
      IF  'MRBTS-${MRBTS_ID}' not in $group  CONTINUE
      IF  'Failed' not in $group             CONTINUE
      ${group_list}  Split String  ${group}  separator=\n
      ${group_dict}  Create Dictionary For Operation Group  ${group_list}
      Append To List  ${groups_to_check}  ${group_dict}
    END
    FOR  ${group}  IN  @{groups_to_check}
      ${time_to_check}  Set Variable  ${group['Start time']}
      ${time_diff}  Subtract Date From Date  ${time_to_check}  ${operation_date}  exclude_millis=True
      ...                                                                         date1_format=%m/%d/%y %I:%M:%S %p
      ...                                                                         date2_format=%m/%d/%y %I:%M:%S %p
      Return From Keyword If  ${time_diff}>0  ${group['Group ID']}
    END
    [Return]  ${latest_group_id}

Create Dictionary For Operation Group
    [Arguments]  ${group_list}
    ${group_dict}  Create Dictionary
    FOR  ${item}  IN  @{group_list}
      ${key}  ${value}  Split String From Right  ${item}  separator=:${SPACE}  max_split=1
      Set To Dictionary  ${group_dict}  ${key}  ${value}
    END
    [Return]  ${group_dict}

Get Reasons List For Failed Operation Group
    [Arguments]  ${group_id}
    ${group_feedback}  netact.Fetch Feedback  ${group_id}
    ${operations_raw_list}  Split String  ${group_feedback}  separator=\n\n
    ${failed_operations_list}  Create List
    FOR  ${chunk}  IN  @{operations_raw_list}
      IF  'failed' not in $chunk  CONTINUE
      ${chunk_cleaned}  Remove String  ${chunk}  \n\t
      Append To List  ${failed_operations_list}  ${chunk_cleaned}
    END
    [Return]  ${failed_operations_list}

Check For MRC-/MR- On Lab
    [Arguments]  ${host}  ${user}  ${password}  ${mrc}=COMMON  ${mr}=COMMON
    ${command}  Set Variable  nasdaclimx.sh -objmgr -list MRC-%/MR-% | grep -w MRC-${mrc}/MR-${mr} 2>/dev/null
    ${connection}  ssh.Connect To  ${host}  ${user}  ${password}
    ${output}  ssh.Execute  command=${command}  connection=${connection}
    ssh.Await Execution End  connection=${connection}  timeout=60s
    ssh.Disconnect  ${connection}
    ${match}  Run Keyword And Return Status  Should Not Be Empty  ${output}
    [Return]  ${match}

Change Web Service User Credentials
    [Arguments]  ${username}=wsuser  ${new_password}=A0zY~rP#8Mx@  ${old_password}=A0zY~rP8Mx@
    Log To Console  Trying to change '${username}' password...
    ${change_result}  ${change_output}  Run Keyword And Ignore Error  admin.Modify Web Service User  username=${username}
    ...                                                                                              password=${new_password}
    ...                                                                                              old_username=${username}
    ...                                                                                              old_password=${old_password}
    Run Keyword If  'PASS' in $change_result  Log  Password for '${username}' changed from '${old_password}' to '${new_password}'  WARN
    ...       ELSE  Log To Console  Password for '${username}' was not changed -- it may already be set as desired or it failed due to other reason.
