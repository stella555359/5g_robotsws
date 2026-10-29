*** Settings ***
Library  taf.nms.netact  WITH NAME  netact
Library  XML  use_lxml=true
Library  ../resources/python_lib/tool_ping.py
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
...  26.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-566 - FIX KW to Workaround for failed Netact Integration
...  24.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-585 - Rework KW "Check Cells State In Netact" to include LTE energySavingState
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
    [Documentation]  Keyword sets value cl1028 (or cl1025 in case of CB005891 and CB006830 suite)
    ...  for ${NETACT_ID} when variable is not defined by operator
    ...  (as workaround in zero touch regression activities).

    ${status}  Run Keyword And Return Status  Variable Should Exist  ${NETACT_ID}
    ${lab1025}  Run Keyword And Return Status  Should Contain Any  ${TEST NAME}  CB005891  CB006830
    IF  ${lab1025}
        ${NETACT_ID}  Set Variable If  not ${status}  cl1025  ${NETACT_ID}
    ELSE
        ${NETACT_ID}  Set Variable If  not ${status}  cl1028  ${NETACT_ID}
    END
    Set Suite Variable  ${NETACT_ID}


Automatic Netact Integration
    [Arguments]    ${mr}=MRC-COMMON/MR-COMMON

    Run Keyword And Ignore Error    netact.Deintegrate MRBTS from NetAct    dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ${1st_try_status}    Run Keyword And Return Status    netact.Integrate MRBTS with NetAct
    ...    release=${SW_TYPE}
    ...    mr=${mr}
    ...    mrbts_address=${ENB_MPLANE_IP}
    ...    dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ...    security_mode=no TLS
    IF  ${1st_try_status}
        Log   NetAct Integration completed
    ELSE
        Log    NetAct Integration failed
        Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
	    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
        Remove All ne3sadapt Files
        Restoring BTS to OnAir
        Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
	    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
	END

   ${2nd_try_status}  IF  not ${1st_try_status}  Run Keyword And Return Status  netact.Integrate MRBTS with NetAct
    ...    release=${SW_TYPE}
    ...    mr=${mr}
    ...    mrbts_address=${ENB_MPLANE_IP}
    ...    dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ...    security_mode=no TLS
    IF  ${1st_try_status} or ${2nd_try_status}
        Log To Console    NetAct integration completed
    ELSE
        Log    NetAct integration failed    WARN
        BuiltIn.fail    Integration not done, possible troubleshooting:  srnclab NIDD, oamTLS, wsuser password
    END


Restoring BTS to OnAir
    Log To Console  Wait for target to be reachable after reset
    ${status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=${MSM_IP}
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir


Remove All ne3sadapt Files
    Log To Console    BTS will be rebooted
    ssh.Connect to    ${MSM_IP}    ${ENB_ROOT_USER}    ${ENB_ROOT_PASS}
    ssh.Execute    rm ../ne3sadapt/configs/ne3sadaptdata.db
    ssh.Disconnect
    Log To Console  BTS Reset site...
	admin.reset site  timeout=700


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


Set Parameter Under ALD Via NA
    [Documentation]  Keyword changing parameter value via NA under ALD object
    ...  Example of usage:
    ...  Set Parameter Under ALD Via NA  telemetryUpdateInterval  ${ID}  1
    [Arguments]  ${parameter}  ${ID}  ${value}

    ${current_date}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${SCF_PATH}  Set Variable  ${RESULTS}/SCF_BACKUP.xml
    ${FEATLADM_DN}  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-${ID}
    ${meta_ver}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${FEATLADM_DN}  version
    ${meta_class}  Get Meta Version Or Class From SCFC  ${SCF_PATH}  ${FEATLADM_DN}  class
    Set Test Variable  ${meta_ver}
    Set Test Variable  ${meta_class}
    Set Test Variable  ${delta}  MRBTS-${MRBTS_ID}_Plan_${parameter}
    Run Keyword And Ignore Error  netact.delete plan  ${delta}
    ${plan}  netact.create plan configuration  name=${delta}  description=Automation WRO1 for MRBTS-${MRBTS_ID}_Plan_${parameter}
    ${managed_objects}  netact.create managed object  plan=${plan}  meta_class=${meta_class}
    ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-${ID}  ${parameter}=${value}
    Log To Console  Plan provisioning via NetAct ${parameter} changing to ${value}
    netact.provision plan  MRBTS-${MRBTS_ID}_Plan_${parameter}  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}  create_backup_plan=true
    ...  backup_plan_name=${MRBTS_ID}_${current_date}_backup
