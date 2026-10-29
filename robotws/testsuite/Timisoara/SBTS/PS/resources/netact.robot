*** Settings ***
Library  taf.nms.netact  WITH NAME  netact
Library  XML  use_lxml=true
Resource  ../resources/alarms.robot

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
...  xx.xx..2022 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
Setup TAF Netact
    netact.Add Web URL  ${LBWAS_NODE}  ${NA_USER}  ${NA_PASS}
    netact.Add Node  cmwas  ${NA_HOST}  ${NA_USER}  ${NA_PASS}
    netact.Add Node  fmwas  ${NA_HOST}  ${NA_USER}  ${NA_PASS}
    ${skip_NA_integration}  Run Keyword And Return Status  Variable Should Exist  ${SKIP_INTEGRATION}
    IF  not ${skip_NA_integration}  Automatic Netact Integration
    ${NA_ID}  Get Substring  ${LBWAS_NODE}  0  -26
    Log  Integrated to NetAct ID ${NA_ID}  WARN
    Log  NetAct: <a href="https://${LBWAS_NODE}">${NA_ID}</a>  WARN  html=True


Teardown TAF Netact
    Run Keyword And Ignore Error  netact.Deintegrate MRBTS from NetAct  dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
    netact.Delete Node  fmwas
    netact.Delete Node  cmwas
    netact.Clean All


Workaround For Empty NETACT_ID
    [Documentation]  Keyword sets value cl1019 (or cl1025 in case of CB005891 and CB006830 suite)
    ...  for ${NETACT_ID} when variable is not defined by operator
    ...  (as workaround in zero touch regression activities).

    ${status}  Run Keyword And Return Status  Variable Should Exist  ${NETACT_ID}
    ${lab1025}  Run Keyword And Return Status  Should Contain Any  ${TEST NAME}  CB005891  CB006830
    ${NETACT_ID}  IF  ${lab1025}  Set Variable If  not ${status}  cl1025  ${NETACT_ID}
    ...  ELSE  Set Variable If  not ${status}  cl3006  ${NETACT_ID}    #changed after cl1016 decommission
    ${rfs_env_status}  Run Keyword And Return Status  Variable Should Exist  ${IS_RFS_ENV}
    IF  ${rfs_env_status}
        ${NETACT_ID}  IF  ${IS_RFS_ENV}  Set Variable If  not ${status}  cl2024  ${NETACT_ID}
        ...  ELSE  Set Variable  ${NETACT_ID}
    END
    Set Suite Variable  ${NETACT_ID}


Automatic Netact Integration
    [Arguments]  ${mr}=MRC-COMMON/MR-COMMON
    Run Keyword And Ignore Error  netact.Deintegrate MRBTS from NetAct  dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ${integration_status}  Run Keyword And Return Status  netact.Integrate MRBTS with NetAct
    ...  release=${SW_TYPE}
    ...  mr=${mr}
    ...  mrbts_address=${ENB_MPLANE_IP}
    ...  dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ...  security_mode=no TLS

    IF  ${integration_status} == False
      ${mr}  Set Variable  MRC-Common/MR-Common
      ${integration_status}  Run Keyword And Return Status  netact.Integrate MRBTS with NetAct
      ...  release=${SW_TYPE}
      ...  mr=${mr}
      ...  mrbts_address=${ENB_MPLANE_IP}
      ...  dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
      ...  security_mode=no TLS
    END

    IF  ${integration_status} == False
      ${mr}  Set Variable  MRC-COMMON/MR-SRAN
      ${integration_status}  Run Keyword And Return Status  netact.Integrate MRBTS with NetAct
      ...  release=${SW_TYPE}
      ...  mr=${mr}
      ...  mrbts_address=${ENB_MPLANE_IP}
      ...  dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
      ...  security_mode=no TLS
    END

    IF  ${integration_status}
        Log To Console  NetAct integration completed
    ELSE
        Log  NetAct integration failed  WARN
    END


Set Feature Under LNBTS/NRBTS Via NA
    [Documentation]  Keyword setting indicated valuse for chosen feature under LNBTS/NRBTS objects Via NA
    ...  Example of usage:
    ...  Set Feature Under LNBTS/NRBTS Via NA  enableGrflShdn  1  LNBTS
    [Arguments]  ${feature}  ${value}  ${object}

    ${current_date}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${SCF_PATH}  Set Variable  ${RESULTS}/SCF_BACKUP.xml
    IF  '${object}'=='LNBTS'
        ${meta_ver}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}  version
    ELSE IF  '${object}'=='NRBTS'
        ${meta_ver}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  version
    END
    IF  '${object}'=='LNBTS'
        ${meta_class}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}  class
    ELSE IF  '${object}'=='NRBTS'
        ${meta_class}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  class
    END
    Set Test Variable  ${meta_ver}
    Set Test Variable  ${meta_class}
    Set Test Variable  ${delta}  MRBTS-${MRBTS_ID}_Plan_${feature}
    Run Keyword And Ignore Error  netact.delete plan  ${delta}
    ${plan}  netact.create plan configuration  name=${delta}  description=Automation WRO1 for MRBTS-${MRBTS_ID}_Plan_${feature}
    IF  '${object}'=='LNBTS'
        ${managed_objects}  netact.create managed object  plan=${plan}  meta_class=${meta_class}
        ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}  ${feature}=${value}
    ELSE IF  '${object}'=='NRBTS'
        ${managed_objects}  netact.create managed object  plan=${plan}  meta_class=${meta_class}
        ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  ${feature}=${value}
    END
    Log To Console  Plan provisioning via NetAct ${feature} changing to ${value}
    netact.provision plan  MRBTS-${MRBTS_ID}_Plan_${feature}  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}  create_backup_plan=true
    ...  backup_plan_name=${MRBTS_ID}_${current_date}_backup


Set Feature Under FEATLADM Via NA
    [Documentation]  Keyword setting indicated valuse for chosen feature under FEATLADM object Via NA
    ...  Example of usage:
    ...  Set Feature Under FEATLADM Via NA  actLBBbPowerSaving  true
    [Arguments]  ${feature}  ${value}

    ${current_date}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${SCF_PATH}  Set Variable  ${RESULTS}/SCF_BACKUP.xml
    ${FEATLADM_DN}  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1
    ${LNBTS_DN}  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
    ${meta_ver}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${FEATLADM_DN}  version
    ${meta_class}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${FEATLADM_DN}  class
    Set Test Variable  ${meta_ver}
    Set Test Variable  ${meta_class}
    Set Test Variable  ${delta}  MRBTS-${MRBTS_ID}_Plan_${feature}
    Run Keyword And Ignore Error  netact.delete plan  ${delta}
    ${plan}  netact.create plan configuration  name=${delta}  description=Automation WRO1 for MRBTS-${MRBTS_ID}_Plan_${feature}
    ${managed_objects}  netact.create managed object  plan=${plan}  meta_class=${meta_class}
    ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1  ${feature}=${value}
    Log To Console  Plan provisioning via NetAct ${feature} changing to ${value}
    netact.provision plan  MRBTS-${MRBTS_ID}_Plan_${feature}  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}  create_backup_plan=true
    ...  backup_plan_name=${MRBTS_ID}_${current_date}_backup


Set Feature Under FEATCADM Via NA
    [Documentation]  Keyword setting indicated valuse for chosen feature under FEATCADM object Via NA
    ...  Example of usage:
    ...  Set Feature Under FEATCADM Via NA  actRadioDeepSleepTimeSchedule  true
    [Arguments]  ${feature}  ${value}

    ${current_date}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${SCF_PATH}  Set Variable  ${RESULTS}/SCF_BACKUP.xml
    ${FEATCADM_DN}  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${LNBTS_DN}  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
    ${meta_ver}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${FEATCADM_DN}  version
    ${meta_class}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${FEATCADM_DN}  class
    Set Test Variable  ${meta_ver}
    Set Test Variable  ${meta_class}
    Set Test Variable  ${delta}  MRBTS-${MRBTS_ID}_Plan_${feature}
    Run Keyword And Ignore Error  netact.Delete Plan  ${delta}
    ${plan}  netact.Create Plan Configuration  name=${delta}  description=Automation WRO1 for MRBTS-${MRBTS_ID}_Plan_${feature}
    ${managed_objects}  netact.Create Managed Object  plan=${plan}  meta_class=${meta_class}
    ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  ${feature}=${value}
    Log To Console  Plan provisioning via NetAct ${feature} changing to ${value}
    netact.Provision Plan  MRBTS-${MRBTS_ID}_Plan_${feature}  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}  create_backup_plan=true
    ...  backup_plan_name=${MRBTS_ID}_${current_date}_backup


Change Administrative State For LNCELL/NRCELL Via NA
    [Documentation]  Keyword setting indicated administrative state for chosen cell via NA
    ...  Example of usage:
    ...  Change Administrative State For LNCELL/NRCELL Via NA  LNCEL  administrativeState  2  ${1st_cell_id}  LNBTS
    [Arguments]  ${type}  ${parameter}  ${value}  ${cell}  ${object}

    ${current_date}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${SCF_PATH}  Set Variable  ${RESULTS}/SCF_BACKUP.xml
    IF  '${object}'=='LNBTS'
        ${meta_ver}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${type}-${cell}  version
    ELSE IF  '${object}'=='NRBTS'
        ${meta_ver}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${type}-${cell}  version
    END
    IF  '${object}'=='LNBTS'
        ${meta_class}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${type}-${cell}  class
    ELSE IF  '${object}'=='NRBTS'
        ${meta_class}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${type}-${cell}  class
    END
    Set Test Variable  ${meta_ver}
    Set Test Variable  ${meta_class}
    Set Test Variable  ${delta}  MRBTS-${MRBTS_ID}_Plan_${parameter}
    Run Keyword And Ignore Error  netact.delete plan  ${delta}
    ${plan}  netact.create plan configuration  name=${delta}  description=Automation WRO1 for MRBTS-${MRBTS_ID}_Plan_${parameter}
    IF  '${object}'=='LNBTS'
        ${managed_objects}  netact.create managed object  plan=${plan}  meta_class=${meta_class}
        ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/${type}-${cell}  ${parameter}=${value}
    ELSE IF  '${object}'=='NRBTS'
        ${managed_objects}  netact.create managed object  plan=${plan}  meta_class=${meta_class}
        ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${type}-${cell}  ${parameter}=${value}
    END
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

    IF  '${version_or_class}'=='version'
        ${meta}  Evaluate Xpath  ${scf_path}  string((//managedObject[contains(@distName,"${distName}")]/@version)[1])
    ELSE IF  '${version_or_class}'=='class'
        ${meta}  Evaluate Xpath  ${scf_path}  string((//managedObject[contains(@distName,"${distName}")]/@class)[1])
    END

    RETURN  ${meta}
