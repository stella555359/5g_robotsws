*** Settings ***
Documentation
...    Maintainer:    piotr.korczynski@nokia.com

Resource  ./rf_alarms_keywords.robot


*** Keywords ***
Automated__SiSo__Alarm__RF_1837
  [Documentation]     Keyword is the complete test of fault 1837 for RF with given serial number.
  Common Test Setup  tools_to_setup=IM_ADMIN
  Start Taf Syslog Session  ${alias}  ${alias}  additional
  Set suite variable  ${FR_UNDER_TEST_SERIAL_NUMBER}  ${rf_serial_number}
  Setup variables  alias=${alias}
  ${fault_name_edition}=  Check Release Edition Relation
  ...  active_release=${cfg.NODES['${cfg.primary_node_bts_id}']['active_release']}
  ...  feature_activation_release=${1837_NEW_FAULT_NAME_RELEASE}

  ${fault1837_name}=  Set Variable If  ${fault_name_edition}  ${FAULT1837_ADMIN_NEW_NAME}  ${FAULT1837_ADMIN}
  IF  "${WAY_OF_GENERATION_FAULT}"=="SendFault"
    Run keyword and continue on failure
    ...  Generate fault on RF with command SendFault  ${FAULT1837_SF_CMD_CODE}
    ...    ${FR_UNDER_TEST_SERIAL_NUMBER}
    ...    fault_number=1837
    ...    time_to_wait_for_fault=190s
    ...    alias=${alias}
  END
  IF  "${WAY_OF_GENERATION_FAULT}"=="ard"
    Run keyword and continue on failure
    ...  Generate fault on RF via ARD0546 Message  ${FAULT1837_ARD_CMD_CODE}
    ...    ${FR_UNDER_TEST_SERIAL_NUMBER}
    ...    fault_number=1837
    ...    fault_count=${fault_count}
    ...    time_to_wait_for_fault=190s
  END
  Run Keyword And Continue On Failure
  ...  Admin Alarms Get And Check  allowed=${ALLOWED_ALARMS_TEST}  mandatory=${fault1837_name}  alias=${alias}
  ${LED_state}=  Set variable if  "${FR_UNDER_TEST_PRODUCT_TYPE}"=="CPRI"  ${F1837_S1_RF_IM_LED_STATE_CPRI}  ${F1837__S1_RF_IM_LED_STATE_OBSAI}
  Run keyword and continue on failure
  ...  Info Model Check Current FR State And Compare  fr_serial_number=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...    blocking_state=${F1837_S1_RF_IM_BLOCKING_STATE}
  ...    led_state=${LED_state}
  ...    reasoning_status=${FAULT1837_REASONING_INFO}
  ...    im_section=${FAULT1837_IM_OBJECT}
  ...    alias=${alias}
  Log To Console  Waiting 180 seconds to avoid fault 4309
  Sleep  180s  # <- to avoid 4309
  IF  "${WAY_OF_GENERATION_FAULT}"=="SendFault"
    Run keyword and continue on failure
    ...  Reset of Radio Module with Telnet  ${FR_UNDER_TEST_SERIAL_NUMBER}
  END
#  Run keyword If  "${WAY_OF_GENERATION_FAULT}"=="ard"
#  ...  Run keyword and continue on failure  Reset of Radio Module via ARD0546 Message  ${FR_UNDER_TEST_SERIAL_NUMBER}
  Log To Console  Waiting for RM ${rf_serial_number} to turn on after reset...
  Run keyword and continue on failure
  ...  Wait for infomodel event  event=change /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/RMOD_L-* [stateInfo.operationalState: Disabled -> Enabled]
  ...    timeout=210
  ...    alias=${alias}
  Log To Console  Validating inactive alarms
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=1837  timeout=90  alias=${alias}
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=4003  timeout=180  alias=${alias}
  Verify Multi BTS State
  Run keyword and continue on failure
  ...  Check If RF Status Is OK  ${FR_UNDER_TEST_SERIAL_NUMBER}  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=1837  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=4003  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=10  alias=${alias}

  [Teardown]  Run Keywords
  ...  Common Test Teardown
  ...  AND
  ...  Stop Taf Syslog Session  ${alias}  ${alias}

Automated__SiSo__Alarm__RF_1838
  [Documentation]     Keyword is the complete test of fault 1838 for RF with given serial number.
  Common Test Setup  tools_to_setup=IM_ADMIN
  Start Taf Syslog Session  ${alias}  ${alias}  additional
  Set suite variable  ${FR_UNDER_TEST_SERIAL_NUMBER}  ${rf_serial_number}
  Setup variables  alias=${alias}
  ${fault_name_edition}=  Check Release Edition Relation
  ...  active_release=${cfg.NODES['${cfg.primary_node_bts_id}']['active_release']}
  ...  feature_activation_release=${1838_NEW_FAULT_NAME_RELEASE}

  ${fault1838_name}=  Set Variable If  ${fault_name_edition}  ${FAULT1838_ADMIN_NEW_NAME}  ${FAULT1838_ADMIN}
  IF  "${WAY_OF_GENERATION_FAULT}"=="SendFault"
    Run keyword and continue on failure
    ...  Generate fault on RF with command SendFault  ${FAULT1838_SF_CMD_CODE}
    ...    ${FR_UNDER_TEST_SERIAL_NUMBER}
    ...    fault_number=1838
    ...    time_to_wait_for_fault=190s
    ...    alias=${alias}
  END
  IF  "${WAY_OF_GENERATION_FAULT}"=="ard"
    Run keyword and continue on failure
    ...  Generate fault on RF via ARD0546 Message  ${FAULT1838_ARD_CMD_CODE}
    ...    ${FR_UNDER_TEST_SERIAL_NUMBER}
    ...    fault_number=1838
    ...    fault_count=${fault_count}
    ...    time_to_wait_for_fault=190s
  END
  Run Keyword And Continue On Failure
  ...  Admin Alarms Get And Check  allowed=${ALLOWED_ALARMS_TEST}  mandatory=${fault1838_name}  alias=${alias}
  ${LED_state}=  Set variable if  "${FR_UNDER_TEST_PRODUCT_TYPE}"=="CPRI"  ${F1838_S1_RF_IM_LED_STATE_CPRI}  ${F1838__S1_RF_IM_LED_STATE_OBSAI}
  Run keyword and continue on failure
  ...  Info Model Check Current FR State And Compare  fr_serial_number=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...    blocking_state=${F1838_S1_RF_IM_BLOCKING_STATE}
  ...    led_state=${LED_state}
  ...    reasoning_status=${FAULT1838_REASONING_INFO}
  ...    im_section=${FAULT1838_IM_OBJECT}
  ...    alias=${alias}
  Run keyword and continue on failure
  ...  Admin Alarms Get And Check  allowed=${ALLOWED_ALARMS_TEST}  mandatory=${fault1838_name}  alias=${alias}
  Log To Console  Waiting 180 seconds to avoid fault 4309
  Sleep  180s  # <- to avoid 4309
  IF  "${WAY_OF_GENERATION_FAULT}"=="SendFault"
    Run keyword and continue on failure
    ...  Reset of Radio Module with Telnet  ${FR_UNDER_TEST_SERIAL_NUMBER}
  END
#  Run keyword If  "${WAY_OF_GENERATION_FAULT}"=="ard"
#  ...  Run keyword and continue on failure  Reset of Radio Module via ARD0546 Message  ${FR_UNDER_TEST_SERIAL_NUMBER}
  Log To Console  Waiting for RM ${rf_serial_number} to turn on after reset...
  Run keyword and continue on failure
  ...  Wait for infomodel event  event=change /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/RMOD_L-* [stateInfo.operationalState: Disabled -> Enabled]
  ...    timeout=210
  ...    alias=${alias}
  Log To Console  Validating inactive alarms
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=1838  timeout=90  alias=${alias}
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=4003  timeout=180  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=1838  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=4003  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=10  alias=${alias}
  Verify Multi BTS State
  Run keyword and continue on failure
  ...  Check If RF Status Is OK  ${FR_UNDER_TEST_SERIAL_NUMBER}  alias=${alias}
  [Teardown]  Run Keywords
  ...  Common Test Teardown
  ...  AND
  ...  Stop Taf Syslog Session  ${alias}  ${alias}

Automated__SiSo__Alarm__RF_1923
  [Documentation]     Keyword is the complete test of fault 1923 for RF with given serial number.
  ...                 Way of generation can be defined. Possible values: Normal, SendFault
  Common Test Setup  tools_to_setup=IM_ADMIN
  Start Taf Syslog Session  ${alias}  ${alias}  additional
  Set suite variable  ${FR_UNDER_TEST_SERIAL_NUMBER}  ${rf_serial_number}
  Setup variables  alias=${alias}
  IF  "${WAY_OF_GENERATION_FAULT}"=="SendFault"
    Run Keyword And Continue On Failure
    ...  Generate fault on RF with command SendFault  ${FAULT1923_SF_CMD_CODE}
    ...    ${FR_UNDER_TEST_SERIAL_NUMBER}
    ...    fault_number=1923
    ...    time_to_wait_for_fault=30s
    ...    alias=${alias}
  END
  IF  "${WAY_OF_GENERATION_FAULT}"=="Normal"
    Run Keyword And Continue On Failure
    ...  Generate fault 1923 on RF  time_to_wait_for_fault=60s  alias=${alias}
  END
  Run Keyword And Continue On Failure
  ...  Admin Alarms Get And Check  allowed=${ALLOWED_ALARMS_TEST}  mandatory=${FAULT1923_ADMIN}  alias=${alias}
  Run keyword and continue on failure
  ...  Info Model Check Current FR State And Compare  fr_serial_number=${FR_UNDER_TEST_SERIAL_NUMBER${SN_NAME_END}}
  ...    blocking_state=${F1923_S1_RF_IM_BLOCKING_STATE}
  ...    led_state=${F1923_S1_RF_IM_LED_STATE}
  ...    reasoning_status=${FAULT1923_REASONING_INFO}
  ...    im_section=${FAULT1923_IM_OBJECT}
  ...    alias=${alias}
  Log To Console  Waiting 180 seconds to avoid fault 4309
  Sleep  180s  # <- to avoid 4309
  IF  "${WAY_OF_GENERATION_FAULT}"=="Normal"
    Run keyword and continue on failure
    ...  Change serial number of radio module and check  current_rf_serial_number=${FR_UNDER_TEST_SERIAL_NUMBER_FAKE}
    ...    new_rf_serial_number=${FR_UNDER_TEST_SERIAL_NUMBER}
  END
  IF  "${WAY_OF_GENERATION_FAULT}"=="Normal"
    Run keyword and continue on failure  Reset of Radio Module with Telnet  ${FR_UNDER_TEST_SERIAL_NUMBER_FAKE}
  ELSE
    Run keyword and continue on failure  Reset of Radio Module with Telnet  ${FR_UNDER_TEST_SERIAL_NUMBER}
  END
  Run keyword and continue on failure
  ...  Wait for infomodel event  event=change /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/RMOD_L-* [stateInfo.operationalState: Disabled -> Enabled]
  ...    timeout=210
  ...    alias=${alias}
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=1923  timeout=90  alias=${alias}
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=4003  timeout=180  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=1923  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=4003  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=10  alias=${alias}
  Verify Multi BTS State
  Run keyword and continue on failure
  ...  Check If RF Status Is OK  ${FR_UNDER_TEST_SERIAL_NUMBER}  alias=${alias}
  [Teardown]  Run Keywords
  ...  Common Test Teardown
  ...  AND
  ...  Stop Taf Syslog Session  ${alias}  ${alias}

Automated__SiSo__Alarm__RF_1932
  [Documentation]     Keyword is the complete test of fault 1932 for RF with given serial number.
  Common Test Setup  tools_to_setup=IM_ADMIN
  Start Taf Syslog Session  ${alias}  ${alias}  additional
  Set suite variable  ${FR_UNDER_TEST_SERIAL_NUMBER}  ${rf_serial_number}
  Setup variables  alias=${alias}
  Run keyword and continue on failure
  ...  Generate fault on RF with command SendFault  ${FAULT1932_SF_CMD_CODE}
  ...    ${FR_UNDER_TEST_SERIAL_NUMBER}
  ...    fault_number=1932
  ...    time_to_wait_for_fault=300s
  ...    alias=${alias}
  Run keyword and continue on failure
  ...  Admin Alarms Get And Check  allowed=${ALLOWED_ALARMS_TEST}  mandatory=${FAULT1932_ADMIN}  alias=${alias}
  ${reasoning_status}=  Set variable if  "${FR_UNDER_TEST_PRODUCT_TYPE}"=="CPRI"  ${FAULT1932_REASONING_INFO_CPRI}  ${FAULT1932_REASONING_INFO_OBSAI}
  Run keyword and continue on failure
  ...  Info Model Check Current FR State And Compare  fr_serial_number=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...    blocking_state=${F1932_S1_RF_IM_BLOCKING_STATE}
  ...    led_state=${F1932_S1_RF_IM_LED_STATE}
  ...    reasoning_status=${reasoning_status}
  ...    im_section=/FAN_L-1
  ...    alias=${alias}
  Log To Console  Waiting 180 seconds to avoid fault 4309
  Sleep  180s  # <- to avoid 4309
  Run keyword and continue on failure
  ...  Reset of Radio Module with Telnet  ${FR_UNDER_TEST_SERIAL_NUMBER}
  Run keyword and continue on failure
  ...  Wait for infomodel event  event=change /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/RMOD_L-* [stateInfo.operationalState: Disabled -> Enabled]
  ...    timeout=210
  ...    alias=${alias}
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=1932  timeout=90  alias=${alias}
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=4003  timeout=180  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=1932  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=4003  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=10  alias=${alias}
  Verify Multi BTS State
  Run keyword and continue on failure
  ...  Check If RF Status Is OK  ${FR_UNDER_TEST_SERIAL_NUMBER}  alias=${alias}
  [Teardown]  Run Keywords
  ...  Common Test Teardown
  ...  AND
  ...  Stop Taf Syslog Session  ${alias}  ${alias}

Automated__SiSo__Alarm__RF_1933
  [Documentation]     Keyword is the complete test of fault 1933 for RF with given serial number.
  Common Test Setup  tools_to_setup=IM_ADMIN
  Start Taf Syslog Session  ${alias}  ${alias}  additional
  Set suite variable  ${FR_UNDER_TEST_SERIAL_NUMBER}  ${rf_serial_number}
  Setup variables  alias=${alias}
  Run keyword and continue on failure
  ...  Generate fault on RF with command SendFault  ${FAULT1933_SF_CMD_CODE}
  ...    ${FR_UNDER_TEST_SERIAL_NUMBER}
  ...    fault_number=1933
  ...    time_to_wait_for_fault=5s
  ...    alias=${alias}
  Run Keyword And Continue On Failure
  ...  Admin Alarms Get And Check  allowed=${ALLOWED_ALARMS_TEST}  mandatory=${FAULT1933_ADMIN}  alias=${alias}
  Run keyword and continue on failure
  ...  Info Model Check Current FR State And Compare  fr_serial_number=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...    blocking_state=${F1933_S1_RF_IM_BLOCKING_STATE}
  ...    led_state=${F1933_S1_RF_IM_LED_STATE}
  ...    reasoning_status=${FAULT1933_REASONING_INFO}
  ...    im_section=${FAULT1933_IM_OBJECT}
  ...    alias=${alias}
  Log To Console  Waiting 180 seconds to avoid fault 4309
  Sleep  180s  # <- to avoid 4309
  Run keyword and continue on failure
  ...  Reset of Radio Module with Telnet  ${FR_UNDER_TEST_SERIAL_NUMBER}
  Run keyword and continue on failure
  ...  Wait for infomodel event  event=change /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/RMOD_L-* [stateInfo.operationalState: Disabled -> Enabled]
  ...    timeout=210
  ...    alias=${alias}
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=1933  timeout=90  alias=${alias}
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=4003  timeout=180  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=1933  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=4003  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=10  alias=${alias}
  Verify Multi BTS State
  Run keyword and continue on failure
  ...  Check If RF Status Is OK  ${FR_UNDER_TEST_SERIAL_NUMBER}  alias=${alias}
  [Teardown]  Run Keywords
  ...  Common Test Teardown
  ...  AND
  ...  Stop Taf Syslog Session  ${alias}  ${alias}

Automated__SiSo__Alarm__RF_1934
  [Documentation]     Keyword is the complete test of fault 1934 for RF with given serial number.
  ...                 Way of generation can be defined. Possible values: Normal, SendFault
  Common Test Setup  tools_to_setup=IM_ADMIN
  Start Taf Syslog Session  ${alias}  ${alias}  additional
  Set suite variable  ${FR_UNDER_TEST_SERIAL_NUMBER}  ${rf_serial_number}
  Setup variables  alias=${alias}
  IF  "${WAY_OF_GENERATION_FAULT}"=="SendFault"
    Run keyword and continue on failure
    ...  Generate fault on RF with command SendFault  ${FAULT1934_SF_CMD_CODE}
    ...    ${FR_UNDER_TEST_SERIAL_NUMBER}
    ...    fault_number=1934
    ...    time_to_wait_for_fault=5s
    ...    alias=${alias}
  END
  IF  "${WAY_OF_GENERATION_FAULT}"=="Normal"
    Run keyword and continue on failure
    ...  Generate fault on RF with RF files modifications  1934  OMP  ${FR_UNDER_TEST_SERIAL_NUMBER}  time_to_wait_for_fault=1800s  alias=${alias}
  END
  Run keyword and continue on failure
  ...  Admin Alarms Get And Check  allowed=${ALLOWED_ALARMS_TEST}  mandatory=${FAULT1934_ADMIN}  alias=${alias}
  ${led_state}=  Set variable if  "${WAY_OF_GENERATION_FAULT}"=="SendFault"  ${F1934_S1_RF_IM_LED_STATE_SF}  ${F1934_S1_RF_IM_LED_STATE}
  Run keyword and continue on failure
  ...  Info Model Check Current FR State And Compare  fr_serial_number=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...    blocking_state=${F1934_S1_RF_IM_BLOCKING_STATE}
  ...    led_state=${led_state}
  ...    reasoning_status=${FAULT1934_REASONING_INFO}
  ...    im_section=${FAULT1934_IM_OBJECT}
  ...    alias=${alias}
  Log To Console  Waiting 180 seconds to avoid fault 4309
  Sleep  180s  # <- to avoid 4309
  IF  "${WAY_OF_GENERATION_FAULT}"=="Normal"
    Run keyword and continue on failure
    ...  Restore RF config files  ${FR_UNDER_TEST_SERIAL_NUMBER}
  END
  Run keyword and continue on failure
  ...  Reset Of Radio Module With Telnet  ${FR_UNDER_TEST_SERIAL_NUMBER}
  Run keyword and continue on failure
  ...  Wait for infomodel event  event=change /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/RMOD_L-* [stateInfo.operationalState: Disabled -> Enabled]
  ...    timeout=210
  ...    alias=${alias}
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=1934  timeout=90  alias=${alias}
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=4003  timeout=180  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=1934  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=4003  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=10  alias=${alias}
  Verify Multi BTS State
  Run keyword and continue on failure
  ...  Check If RF Status Is OK  ${FR_UNDER_TEST_SERIAL_NUMBER}  alias=${alias}
  [Teardown]  Run Keywords
  ...  Common Test Teardown
  ...  AND
  ...  Stop Taf Syslog Session  ${alias}  ${alias}

Automated__SiSo__Alarm__RF_1937
  [Documentation]     Keyword is the complete test of fault 1937 for RF with given serial number.
  ...                 Way of generation can be defined. Possible values: Normal, SendFault
  Common Test Setup  tools_to_setup=IM_ADMIN
  Start Taf Syslog Session  ${alias}  ${alias}  additional
  Set suite variable  ${FR_UNDER_TEST_SERIAL_NUMBER}  ${rf_serial_number}
  Setup variables  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=1937  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=4003  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=10  alias=${alias}
  IF  "${WAY_OF_GENERATION_FAULT}"=="SendFault"
    Run keyword and continue on failure
    ...  Generate fault on RF with command SendFault  ${FAULT1937_SF_CMD_CODE}
    ...    ${FR_UNDER_TEST_SERIAL_NUMBER}
    ...    fault_number=1937
    ...    time_to_wait_for_fault=5s
    ...    alias=${alias}
  END
  IF  "${WAY_OF_GENERATION_FAULT}"=="Normal"
    Run keyword and continue on failure
    ...  Generate fault on RF with RF files modifications  1937  OMP  ${FR_UNDER_TEST_SERIAL_NUMBER}  time_to_wait_for_fault=60s  alias=${alias}
  END
  IF  "${WAY_OF_GENERATION_FAULT}"=="ard"
    Run keyword and continue on failure
    ...  Generate fault on RF via ARD0546 Message  ${FAULT1937_ARD_CMD_CODE}
    ...    ${FR_UNDER_TEST_SERIAL_NUMBER}
    ...    fault_number=1937
    ...    fault_count=${fault_count}
    ...    time_to_wait_for_fault=60s
  END
  ${fault_admin}=  Set variable if  "${H_CONFIG}"=="True"  ${FAULT1937_ADMIN_H}  ${FAULT1937_ADMIN}
  Run Keyword And Continue On Failure
  ...  Admin Alarms Get And Check  allowed=${ALLOWED_ALARMS_FOR_1937}  mandatory=${fault_admin}  alias=${alias}
  ${LED_state}=  Set variable if  "${FR_UNDER_TEST_PRODUCT_TYPE}"=="CPRI"  ${F1937_S1_RF_IM_LED_STATE_CPRI}  ${F1937_S1_RF_IM_LED_STATE_OBSAI}
  Run keyword and continue on failure
  ...  Info Model Check Current FR State And Compare  fr_serial_number=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...    blocking_state=${F1937_S1_RF_IM_BLOCKING_STATE}
  ...    led_state=${LED_state}
  ...    reasoning_status=${FAULT1937_REASONING_INFO}
  ...    alias=${alias}
  Log To Console  Waiting 180 seconds to avoid fault 4309
  Sleep  180s  # <- to avoid 4309
  IF  "${WAY_OF_GENERATION_FAULT}"=="Normal"
    Run keyword and continue on failure
    ...  Restore RF config files  ${FR_UNDER_TEST_SERIAL_NUMBER}
  END
#  Run keyword If  "${WAY_OF_GENERATION_FAULT}"=="ard"
#  ...  Run keyword and continue on failure  Reset of Radio Module via ARD0546 Message  ${FR_UNDER_TEST_SERIAL_NUMBER}
#  ...  ELSE
  Run keyword and continue on failure
  ...  Reset Of Radio Module With Telnet  ${FR_UNDER_TEST_SERIAL_NUMBER}
  Run keyword and continue on failure
  ...  Wait for infomodel event  event=change /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/RMOD_L-* [stateInfo.operationalState: Disabled -> Enabled]
  ...    timeout=210
  ...    alias=${alias}
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=1937  timeout=90  alias=${alias}
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=4003  timeout=180  alias=${alias}

  Verify Multi BTS State
  Run keyword and continue on failure
  ...  Check If RF Status Is OK  ${FR_UNDER_TEST_SERIAL_NUMBER}  alias=${alias}
  [Teardown]  Run Keywords
  ...  Common Test Teardown
  ...  AND
  ...  Stop Taf Syslog Session  ${alias}  ${alias}

Automated__SiSo__Alarm__RF_1938
  [Documentation]     Keyword is the complete test of fault 1938 for RF with given serial number.
  Common Test Setup  tools_to_setup=IM_ADMIN
  Start Taf Syslog Session  ${alias}  ${alias}  additional
  Set suite variable  ${FR_UNDER_TEST_SERIAL_NUMBER}  ${rf_serial_number}
  Setup variables  alias=${alias}
  IF  "${WAY_OF_GENERATION_FAULT}"=="SendFault"
    Run keyword and continue on failure
    ...  Generate fault on RF with command SendFault  ${FAULT1938_SF_CMD_CODE}
    ...    ${FR_UNDER_TEST_SERIAL_NUMBER}
    ...    fault_number=1938
    ...    time_to_wait_for_fault=5s
    ...    alias=${alias}
  END
  IF  "${WAY_OF_GENERATION_FAULT}"=="Normal"
    Run keyword and continue on failure
    ...  Generate fault on RF with RF files modifications  1938  OMP  ${FR_UNDER_TEST_SERIAL_NUMBER}  time_to_wait_for_fault=60s
  END
  Sleep  60s
  ${fault_admin}=  Set variable if  "${H_CONFIG}"=="True"  ${FAULT1938_ADMIN_H}  ${FAULT1938_ADMIN}
  Run Keyword And Continue On Failure
  ...  Admin Alarms Get And Check  allowed=${ALLOWED_ALARMS_FOR_1938}  mandatory=${fault_admin}  alias=${alias}
  Run keyword and continue on failure
  ...  Info Model Check Current FR State And Compare  fr_serial_number=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...    blocking_state=${F1938_S1_RF_IM_BLOCKING_STATE}
  ...    led_state=${F1938_S1_RF_IM_LED_STATE}
  ...    reasoning_status=${FAULT1938_REASONING_INFO}
  ...    im_section=${FAULT1938_IM_OBJECT}
  ...    alias=${alias}
  Log To Console  Waiting 180 seconds to avoid fault 4309
  Sleep  180s  # <- to avoid 4309
  IF  "${WAY_OF_GENERATION_FAULT}"=="SendFault"
    Run keyword and continue on failure
    ...  Cancel fault on RF with command SendFault  ${FAULT1938_CANCEL_SF_CMD_CODE}  ${FR_UNDER_TEST_SERIAL_NUMBER}  alias=${alias}
  END
  IF  "${WAY_OF_GENERATION_FAULT}"=="Normal"
    Run keyword and continue on failure
    ...  Restore RF config files  ${FR_UNDER_TEST_SERIAL_NUMBER}
    Run keyword and continue on failure
    ...  Reset of Radio Module with Telnet  ${FR_UNDER_TEST_SERIAL_NUMBER}
    Run keyword and continue on failure
    ...  Wait for infomodel event  event=change /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/RMOD_L-* [stateInfo.operationalState: Disabled -> Enabled]
    ...    timeout=210
    ...    alias=${alias}
  END
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=1938  timeout=90  alias=${alias}
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=4003  timeout=180  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=1938  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=4003  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=10  alias=${alias}
  Verify Multi BTS State
  Run keyword and continue on failure
  ...  Check If RF Status Is OK  ${FR_UNDER_TEST_SERIAL_NUMBER}  alias=${alias}
  [Teardown]  Run Keywords
  ...  Common Test Teardown
  ...  AND
  ...  Stop Taf Syslog Session  ${alias}  ${alias}

Automated__SiSo__Alarm__RF_1957
  [Documentation]     Keyword is the complete test of fault 1957 for RF with given serial number.
  Common Test Setup  tools_to_setup=IM_ADMIN
  Start Taf Syslog Session  ${alias}  ${alias}  additional
  Set suite variable  ${FR_UNDER_TEST_SERIAL_NUMBER}  ${rf_serial_number}
  Setup variables  alias=${alias}
  Run keyword and continue on failure
  ...  Generate fault on RF with command SendFault  ${FAULT1957_SF_CMD_CODE}
  ...    ${FR_UNDER_TEST_SERIAL_NUMBER}
  ...    fault_number=1957
  ...    time_to_wait_for_fault=5s
  ...    alias=${alias}
  Run keyword and continue on failure
  ...  Info Model Check Current FR State And Compare  fr_serial_number=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...    blocking_state=${F1957_S1_RF_IM_BLOCKING_STATE}
  ...    led_state=${F1957_S1_RF_IM_LED_STATE}
  ...    reasoning_status=${FAULT1957_REASONING_INFO}
  ...    im_section=${FAULT1957_IM_OBJECT}
  ...    alias=${alias}
  Run Keyword And Continue On Failure
  ...  Admin Alarms Get And Check  allowed=${ALLOWED_ALARMS_TEST}  mandatory=${FAULT1957_ADMIN}  alias=${alias}
  Log To Console  Waiting 180 seconds to avoid fault 4309
  Sleep  180s  # <- to avoid 4309
  Run keyword and continue on failure
  ...  Reset of Radio Module with Telnet  ${FR_UNDER_TEST_SERIAL_NUMBER}
  Run keyword and continue on failure
  ...  Wait for infomodel event  event=change /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/RMOD_L-* [stateInfo.operationalState: Disabled -> Enabled]
  ...    timeout=210
  ...    alias=${alias}
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=1957  timeout=90  alias=${alias}
  Run Keyword And Continue On Failure
  ...  Assert Alarm Inactive  faultId=4003  timeout=180  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=1957  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=4003  alias=${alias}
  Run Keyword And Ignore Error
  ...  admin.Add Allowed Alarm  faultId=10  alias=${alias}
  Verify Multi BTS State
  Run keyword and continue on failure
  ...  Check If RF Status Is OK  ${FR_UNDER_TEST_SERIAL_NUMBER}  alias=${alias}
  [Teardown]  Run Keywords
  ...  Common Test Teardown
  ...  AND
  ...  Stop Taf Syslog Session  ${alias}  ${alias}
