# robocop: off
*** Settings ***
Documentation
...  Author:  daria.wronska@nokia.com
...  Maintainer:  daniel.bartkowiak@nokia.com
...  TC is turning off power on all HW at the beggining.
...  Next in separated steps power is turning on for desired type of HW (states and alarms are checked)
...  TC is mainly checking if HW is behaving properly when power on/off is applied.
...  Note.1 Fault 4589 is set to allowed due to power rest of RMODs/FHS
...  Note.2 Fault 2002 is set to allowed due to power rest of RMODs/FHS which has influence on long optical signal missing.
...  While waiting for fault 10 after RMOD/FHS power off Fault 2002 can be often visible

Resource  ../tc_scenarios.robot
Resource  ./check_linkSpeed_FHS.robot
Resource  ./fh_reset.robot
Library  taf.sbts.oam.coam.admin  WITH NAME  admin

*** Variables ***

*** Keywords ***
FHS Power Break PDU
  [Documentation]
  ...  Description:
  ...  This test case checks whether SMOD,BBMOD,FHS,RMOD and cells have reached expected states and faults
  ...  for case of turning equipment OFF and ON on PDU.
  ...  |  **Author:**  daria.wronska@nokia.com
  ...  |  **Maintainer:**  daria.wronska@nokia.com
  Logging With Timestamp
  ...  message=FHS Power Break PDU: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Common Test Setup
  FOR  ${bts_id}  IN  @{cfg.NODES}
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Run Keyword If  ${cfg.NODES['${BTS_ID}']['scf_hw_fhs_list']}!=[]
    ...  Execute FHS Power Break PDU On Every Node  ${TEST_LOGS_DIR_PATH}
    Execute Check Link Speed Under FHS On Every Node
  END
  [Teardown]    Common Test Teardown

Execute FHS Power Break PDU On Every Node
  [Arguments]  ${test_logs_path}
  Logging With Timestamp
  ...  message=FHS Power Break PDU: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  step1:FHS Power Break PDU Preconditions  ${test_logs_path}
  step2:Switch Off Power On BTS
  step3:Switch On Power Only SMODs
  step4:States And Faults Check For FHS/RMOD
  step5:Switch On Power For FHS/RMOD
  [Teardown]  Run Keyword If  '${KEYWORD STATUS}'!='PASS'  Run Keywords
  ...  PDU Switch On Device Lists
  ...  serial_number_list=${cfg.NODES['${BTS_ID}']['scf_hw_sm_list']}
  ...  AND
  ...  PDU Switch On Device Lists
  ...  serial_number_list=${cfg.NODES['${BTS_ID}']['scf_hw_fr_list']}
  ...  AND
  ...  PDU Switch On Device Lists
  ...  serial_number_list=${cfg.NODES['${BTS_ID}']['scf_hw_fhs_list']}
  ...  AND  Verify Multi BTS State


step1:FHS Power Break PDU Preconditions
  [Arguments]  ${test_logs_path}
  Log  \nstep1: FHS Power Break PDU Preconditions${\n}--------------------${\n}  console=True
  Preconditions For CNI-127210
  ${release}  admin.Get Sw Release Name  connection=${BTS_ID}
  ${proper_sw}  Run Keyword If  "${release}"=="SBTS24R3" and ${PRECOND_FOR_CNI}
  ...  Check If Current Build Is Newer Than  SBTS24R3_ENB_0000_000536_000000  alias=${BTS_ID}
  ...  ELSE IF  ${PRECOND_FOR_CNI}  
  ...  Check If Current Build Is Newer Than  SBTS25R1_ENB_9999_240926_000004  alias=${BTS_ID}
  Run Keyword If   ${proper_sw}  Set Test Variable  ${PRECOND_FOR_CNI}  False
  ${fhs_dist_list}=  Get FHS List  timeout=1200  connection=${BTS_ID}
  Set Test Variable  ${FHS_DIST_LIST}  ${fhs_dist_list}
  Set Test Variable  ${BTS_FHS_LIST}  ${cfg.NODES['${BTS_ID}']['scf_hw_fhs_list']}
  Set Test Variable  ${RF_BTS_LIST}  ${CFG['NODES']['${BTS_ID}']['scf_hw_fr_list']}
  ${scf_path}=  admin.Get Current SCF File  ${cfg.test_logs_path}  SCF_current_BTS.xml  30  connection=${BTS_ID}
  ...  export_type=configurationAndRuntimeObjects
  Set Test Variable  ${SCF_PATH}  ${scf_path}
  Verify FAN For Rmod Power On
  admin.Add Allowed Alarm  faultId=2002  connection=${BTS_ID}
  admin.Add Allowed Alarm  faultId=4589  connection=${BTS_ID}
  admin.Add Allowed Alarm  faultId=10  connection=${BTS_ID}

step2:Switch Off Power On BTS
  Log  \nstep2:Switch Off Power On BTS${\n}--------------------${\n}  console=True
  Set Start Timestamp In IMS For CNI-127210
  PDU Switch OFF Device Lists
  ...  serial_number_list=${cfg.NODES['${BTS_ID}']['scf_hw_sm_list']}
  PDU Switch OFF Device Lists
  ...  serial_number_list=${cfg.NODES['${BTS_ID}']['scf_hw_fhs_list']}
  PDU Switch OFF Device Lists
  ...  serial_number_list=${cfg.NODES['${BTS_ID}']['scf_hw_fr_list']}
  Wait Until Keyword Succeeds  120 sec  30 sec  Verify SMOD State Off

step3:Switch On Power Only SMODs
  Log  \nstep3:Switch On Power Only SMODs${\n}--------------------${\n}  console=True
  PDU Switch On Device Lists
  ...  serial_number_list=${cfg.NODES['${BTS_ID}']['scf_hw_sm_list']}
  Wait Until Keyword Succeeds  120 sec  30 sec  Verify SMOD State On
  Wait Until Keyword Succeeds  120 sec  30 sec  Check BBMODs State

step4:States And Faults Check For FHS/RMOD
  Log  \nstep4:States And Faults Check For FHS/RMOD${\n}--------------------${\n}  console=True
  Log  ================FHS Check when power off=========================  console=True
  Wait Until Keyword Succeeds  900 sec  60 sec  Verify FHS Power Off
  Log  ================RMOD Check when power off=========================  console=True
  Run Keyword And Ignore Error  admin.Assert Alarm Active
  ...  parameters=faultId=10, severity=regex"(?i)Minor|Critical", alarmingObjectIds[0].internal=regex".*RMOD_R"
  ...  timeout=900
  ...  connection=${BTS_ID}
  Wait Until Keyword Succeeds  120 sec  30 sec  Verify RU Power Off
  Log  ================FAN Check when power off=========================  console=True
  Verify FAN For Rmod Power Off

step5:Switch On Power For FHS/RMOD
  Log  \nstep5:Switch On Power For FHS/RMOD${\n}--------------------${\n}  console=True
  Log  ================FHS Check when power on=========================  console=True
  PDU Switch On Device Lists
  ...  serial_number_list=${cfg.NODES['${BTS_ID}']['scf_hw_fhs_list']}
  Wait Until Keyword Succeeds  600 sec  30 sec  Verify FHS Power On
  Log  ================RMOD Check when power on=========================  console=True
  PDU Switch On Device Lists
  ...  serial_number_list=${cfg.NODES['${BTS_ID}']['scf_hw_fr_list']}
  Run Keyword And Ignore Error  admin.Assert Every
  ...  class_name=RMOD
  ...  parameters=operationalState=regex"(?i)Enabled"
  ...  timeout=360
  ...  connection=${BTS_ID}
  Wait Until Keyword Succeeds  120 sec  30 sec  Verify RU Power On
  Log  ================BBMOD Check when power on=========================  console=True
  Check BBMODs State
  Log  ================FAN Check when power on=========================  console=True
  Verify FAN For Rmod Power On

Verify SMOD State Off
  [Documentation]
  ...  Description:
  ...  Checking if SMOD is unavailable( not pingable  192.168.255.129), and if it is, test will be Fail.
  ...  |  **Author:**  daria.wronska@nokia.com
  ...  |  **Maintainer:**  daria.wronska@nokia.com
  ${status}=  Run Keyword And Return Status  BTS Address Is Pingable  192.168.255.129
  Run Keyword If  '${status}'=='False'  Log  node=${BTS_ID} is powered off  console=True
  ...  ELSE  Fail  msg=SMOD is already switched on, check why it is not switched off.

Verify SMOD State On
  [Documentation]
  ...  Description:
  ...  Checking if SMOD is available(pingable  192.168.255.129), and if it is not, test will be Fail.
  ...  |  **Author:**  daria.wronska@nokia.com
  ...  |  **Maintainer:**  daria.wronska@nokia.com
  ${status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  120 sec  30 sec
  ...  BTS Address Is Pingable  192.168.255.129
  Run Keyword If  '${status}'=='True'  Log  node=${BTS_ID} is powered on.  console=True
  ...  ELSE  Fail  msg= SMOD is already switched off, check why it is not switched on.

Check BBMODs State
  [Documentation]
  ...  Description:
  ...  Checking expected status for enabled BBMOD.
  ...  |  **Author:**  daria.wronska@nokia.com
  ...  |  **Maintainer:**  daria.wronska@nokia.com
  Run Keyword And Continue On Failure  admin.Assert Every
  ...  class_name=BBMOD
  ...  parameters=operationalState=regex"(?i)Enabled", administrativeState=regex"(?i)Unlocked"
  ...  timeout=200
  ...  connection=${BTS_ID}
  Run Keyword And Continue On Failure  admin.Assert No
  ...  class_name=BBMOD
  ...  parameters=availabilityStatus=regex"(?i)Degraded"
  ...  timeout=30
  ...  connection=${BTS_ID}

Verify RU Power Off
  [Documentation]
  ...  Description:
  ...  Checking expected status and faults for RMODs and cells with power off.
  ...  |  **Author:**  daria.wronska@nokia.com
  ...  |  **Maintainer:**  daria.wronska@nokia.com
  FOR  ${ru_sn_bts}  IN  @{RF_BTS_LIST}
    Log  \nVerify RU:${ru_sn_bts} Power Off  console=True
    ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${ru_sn_bts}
    site_operations.Verify RU Power Remove Insert State  ${BTS_ID}  ${ru_dist_name}  Remove  ${FAULT_10_TIMEOUT} sec
    site_operations.Verify RU Power Remove Insert State For Affected RUs
    ...  ${BTS_ID}
    ...  ${ru_sn_bts}
    ...  Remove
    ...  ${FAULT_10_TIMEOUT} sec
    Verify RU Power Remove Cells State
    ...  ${cfg}
    ...  ${BTS_ID}
    ...  ${ru_sn_bts}
    ...  ${cfg.RF_INFO['${ru_sn_bts}'].scf_dist_name_primary}
    ...  Remove
    ...  ${FAULT_10_TIMEOUT} sec
    ${cni_status_minor}  Run Keyword And Return Status  Check Active Fault In IMS For CNI-127210
    ...  fault_id=10  severity=Minor
      Run Keyword If  not ${cni_status_minor}  admin.Assert Alarm Active
      ...  faultId=10, severity=regex"(?i)Minor|Critical", alarmingObjectIds[0].internal=${ru_dist_name}  connection=${BTS_ID}
      Run Keyword If  not ${cni_status_minor}  admin.Add Allowed Alarm
      ...  faultId=10, severity=regex"(?i)Minor|Critical", alarmingObjectIds[0].internal=${ru_dist_name}  connection=${BTS_ID}
      ...  ELSE  admin.Add Allowed Alarm
      ...  faultId=10, severity=Minor, alarmingObjectIds[0].internal=${ru_dist_name}  connection=${BTS_ID}

  END

Verify RU Power On
  [Documentation]
  ...  Description:
  ...  Checking expected status and faults for RMODs and cells with power on.
  ...  |  **Author:**  daria.wronska@nokia.com
  ...  |  **Maintainer:**  daria.wronska@nokia.com
  FOR  ${ru_sn_bts}  IN  @{RF_BTS_LIST}
    ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${ru_sn_bts}
    site_operations.Verify RU Power Remove Insert State  ${BTS_ID}  ${ru_dist_name}  Insert  ${FAULT_10_TIMEOUT} sec
    site_operations.Verify RU Power Remove Insert State For Affected RUs
    ...  ${BTS_ID}
    ...  ${ru_sn_bts}
    ...  Insert
    ...  ${FAULT_10_TIMEOUT} sec
    Verify RU Power Remove Cells State
    ...  ${cfg}
    ...  ${BTS_ID}
    ...  ${ru_sn_bts}
    ...  ${cfg.RF_INFO['${ru_sn_bts}'].scf_dist_name_primary}
    ...  Insert
    ...  ${FAULT_10_TIMEOUT} sec
    site_operations.Verify RU Power Remove Insert Alarms
    ...  ${BTS_ID}
    ...  ${ru_sn_bts}
    ...  ${cfg.RF_INFO['${ru_sn_bts}'].scf_dist_name_primary}
    ...  Insert
    ...  ${FAULT_10_TIMEOUT} sec
  END

Verify RU Power Remove Cells State
  [Arguments]  ${cfg}  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  ${state}  ${timeout}
  Log  \nRU ${ru_sn}Related Cells State Check Admin procedure started  console=True
  ${ru_cell_dict}=  site_operations.Create Affected Cell List RF Hot Remove Insert  ${ru_sn}
  site_operations.Verify RU Affected Cells  ${ru_bts_id}  ${ru_cell_dict}  ${state}  ${timeout}

Verify FHS Power On
  [Documentation]
  ...  Description:
  ...  Checking expected status and faults for FHSs with power on.
  ...  |  **Author:**  daria.wronska@nokia.com
  ...  |  **Maintainer:**  daria.wronska@nokia.com
  FOR  ${fhs_dict}  IN  @{FHS_DIST_LIST}
    site_operations.Verify FHS Link Remove Insert State
    ...  ${BTS_ID}
    ...  ${fhs_dict['id']['internal']}
    ...  Insert
    ...  ${FAULT_10_TIMEOUT} sec
    admin.Assert No Unexpected Active Alarms  connection=${BTS_ID}
  END

Verify FHS Power Off
  [Documentation]
  ...  Description:
  ...  Checking expected status and faults for FHSs with power off.
  ...  |  **Author:**  daria.wronska@nokia.com
  ...  |  **Maintainer:**  daria.wronska@nokia.com
  FOR  ${fhs_dict}  IN  @{FHS_DIST_LIST}
    site_operations.Verify FHS Link Remove Insert State
    ...  ${BTS_ID}
    ...  ${fhs_dict['id']['internal']}
    ...  Remove
    ...  ${FAULT_10_TIMEOUT} sec
    ${cni_status_minor}  Run Keyword And Return Status  Check Active Fault In IMS For CNI-127210  fault_id=10  severity=Minor
    Run Keyword If  not ${cni_status_minor}  admin.Assert Alarm Active
    ...  faultId=10, severity=regex"(?i)Minor|Critical", alarmingObjectIds[0].internal=${fhs_dict['id']['internal']}
    ...  connection=${BTS_ID}
    Run Keyword If  not ${cni_status_minor}  admin.Add Allowed Alarm
    ...  faultId=10, severity=regex"(?i)Minor|Critical", alarmingObjectIds[0].internal=${fhs_dict['id']['internal']}
    ...  connection=${BTS_ID}
    ...  ELSE  admin.Add Allowed Alarm
    ...  faultId=10, severity=Minor, alarmingObjectIds[0].internal=${fhs_dict['id']['internal']}  connection=${BTS_ID}
  END

Verify FAN For Rmod Power Off
  [Documentation]
  ...  Description:
  ...  Checking expected status FAN for RMOD with power off.
  ...  |  **Author:**  daria.wronska@nokia.com
  ...  |  **Maintainer:**  daria.wronska@nokia.com
  ${fan_info_status_off_dict}  Get Rmod Fan Info  timeout=120  connection=${BTS_ID}
  FOR  ${rmod_key}  IN  @{fan_info_status_off_dict}
    Check FAN State Disable  ${rmod_key}  ${fan_info_status_off_dict['${rmod_key}']}
  END
  [Teardown]  Run Keyword If  "${KEYWORD_STATUS}"=="PASS"  Log  All RMODs Fans have expected statuses  console=True

Check FAN State Disable
  [Arguments]  ${rmod_key}  ${fans}
  FOR  ${fan_key}  IN  @{fans}
    Run keyword If  "${fans['${fan_key}']['operationalState']}"!="disabled"
    ...  Fail  msg=${rmod_key}/${fan_key} status is not correct.
  END
  [Teardown]  Run Keyword If  "${KEYWORD_STATUS}"=="FAIL"
  ...  Log  ${rmod_key}/${fan_key} has wrong states on RMOD power off  console=True

Verify FAN For Rmod Power On
  [Documentation]
  ...  Description:
  ...  Checking expected status FAN for RMOD with power on.
  ...  |  **Author:**  daria.wronska@nokia.com
  ...  |  **Maintainer:**  daria.wronska@nokia.com
  ${fan_info_dict}  Get Rmod Fan Info  timeout=120  connection=${BTS_ID}
  FOR  ${rmod_key}  IN  @{fan_info_dict}
    Check FAN State Power On  ${rmod_key}  ${fan_info_dict['${rmod_key}']}
  END
  [Teardown]  Run Keyword If  "${KEYWORD_STATUS}"=="PASS"  Log  All RMODs Fans have expected statuses  console=True

Check FAN State Power On
  [Arguments]  ${rmod_key}  ${fans}
  FOR  ${fan_key}  IN  @{fans}
    ${fan_dist}  Set Variable  '/${rmod_key}/${fan_key}'
    ${fanPresent_value}=  Evaluate Xpath
    ...  ${SCF_PATH}
    ...  string(.//managedObject[contains(@class, "FAN_R") and contains(@distName, "${fan_dist}")]/p[@name="fanPresent"])
    Run Keyword If  "${fanPresent_value}"=="false"
    ...  Should Be Equal  ${fans['${fan_key}']['availabilityStatus']}  not installed
    ...  ELSE IF  "${fanPresent_value}"=="true"
    ...  Variable Should Not Exist  ${fans['${fan_key}']['availabilityStatus']}
  END
  [Teardown]  Run Keyword If  "${KEYWORD_STATUS}"=="FAIL"
  ...  Log  ${fan_dist} has wrong states on RMOD power on: ${fans['${fan_key}']['availabilityStatus']}  console=True
