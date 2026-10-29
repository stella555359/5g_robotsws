*** Settings ***
Resource    DevHZ5_startup_aic.robot

*** Variables ***
${pm_pod_full_name_cu}  ${EMPTY}
${pm_container_full_name_cu}  ${EMPTY}
${pm_pod_full_name_du}  ${EMPTY}
${pm_container_full_name_du}  ${EMPTY}
${pm_pod_full_name_du2}  ${EMPTY}
${pm_container_full_name_du2}  ${EMPTY}
${pm_pod_full_name_du3}  ${EMPTY}
${pm_container_full_name_du3}  ${EMPTY}
${pm_pod_full_name_du4}  ${EMPTY}
${pm_container_full_name_du4}  ${EMPTY}

*** Keywords ***
Get Pm Pod And Container Full Name Cu
  ${pm_pod_full_name_cu}=  Find Pod Fullname In Aic vCU  pod_name=oampm
  Set Suite Variable  ${pm_pod_full_name_cu}
  ${pm_container_full_name_cu}=  Find Container Fullname In Aic vCU  pod_name=oampm  container_name=pmdataserver
  Set Suite Variable  ${pm_container_full_name_cu}

Check Pm Pod And Container Full Name Cu
  Run Keyword If  '${pm_pod_full_name_cu}'=='${EMPTY}' or '${pm_container_full_name_cu}'=='${EMPTY}'  Get Pm Pod And Container Full Name Cu

Get Pm Pod And Container Full Name Du
  ${pm_pod_full_name_du}=  Find Pod Fullname In Aic vDU  pod_name=oampm
  Set Suite Variable  ${pm_pod_full_name_du}
  ${pm_container_full_name_du}=  Find Container Fullname In Aic vDU  pod_name=oampm  container_name=pmdataserver
  Set Suite Variable  ${pm_container_full_name_du}

Check Pm Pod And Container Full Name Du
  Run Keyword If  '${pm_pod_full_name_du}'=='${EMPTY}' or '${pm_container_full_name_du}'=='${EMPTY}'  Get Pm Pod And Container Full Name Du

Get Pm Pod And Container Full Name Du2
  ${pm_pod_full_name_du2}=  Find Pod Fullname In Aic vDU2  pod_name=oampm
  Set Suite Variable  ${pm_pod_full_name_du2}
  ${pm_container_full_name_du2}=  Find Container Fullname In Aic vDU2  pod_name=oampm  container_name=pmdataserver
  Set Suite Variable  ${pm_container_full_name_du2}

Get Pm Pod And Container Full Name Du3
  ${pm_pod_full_name_du3}=  Find Pod Fullname In Aic vDU3  pod_name=oampm
  Set Suite Variable  ${pm_pod_full_name_du3}
  ${pm_container_full_name_du3}=  Find Container Fullname In Aic vDU3  pod_name=oampm  container_name=pmdataserver
  Set Suite Variable  ${pm_container_full_name_du3}

Get Pm Pod And Container Full Name Du4
  ${pm_pod_full_name_du4}=  Find Pod Fullname In Aic vDU4  pod_name=oampm
  Set Suite Variable  ${pm_pod_full_name_du4}
  ${pm_container_full_name_du4}=  Find Container Fullname In Aic vDU4  pod_name=oampm  container_name=pmdataserver
  Set Suite Variable  ${pm_container_full_name_du4}

Check Pm Pod And Container Full Name Du2
  Run Keyword If  '${pm_pod_full_name_du2}'=='${EMPTY}' or '${pm_container_full_name_du2}'=='${EMPTY}'  Get Pm Pod And Container Full Name Du2

Check Pm Pod And Container Full Name Du3
  Run Keyword If  '${pm_pod_full_name_du3}'=='${EMPTY}' or '${pm_container_full_name_du3}'=='${EMPTY}'  Get Pm Pod And Container Full Name Du3

Check Pm Pod And Container Full Name Du4
  Run Keyword If  '${pm_pod_full_name_du4}'=='${EMPTY}' or '${pm_container_full_name_du4}'=='${EMPTY}'  Get Pm Pod And Container Full Name Du4

Check Counters Cu Aic
  [Arguments]  ${pm_counters_expression}=${EMPTY}  ${rd_counters_expression}=${EMPTY}  ${wait}=${True}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to check PM counter and R&D counter
  ...  \ \ \ \ \ \ | step1 | wait counter file produced at next pm counter interval |
  ...  \ \ \ \ \ | step2 | download all counter files |
  ...  \ \ \ \ | step3 | unzip all counter files and parse and calculate the total number, and return check list. |
  ...  \ \ \ \ \ | Input Parameters | Man. | Description |
  ...  \ | pm_counters_expression \ | No \ \ | pm counters expression list |
  ...  | rd_counters_expression | No | rd counters expression list |
  ...  | wait | No | wait for pm counter interval. for cu,du,du2 case, only need to wait for one time |
  ...
  ...  format of pm_counters_expression:
  ...  | 1) | [mo:][counter_type]:counter_id=counter_value | check counter equal to some value |
  ...  | 2) | [mo:][counter_type]:counter_id>=counter_value | check counter more than or equal to some value |
  ...  | 3) | [mo:][counter_type]:counter_id<=counter_value | check counter less than or equal to some value |
  ...  | 4) | [mo:][counter_type]:counter_id>counter_value | check counter more than some value |
  ...  | 5) | [mo:][counter_type]:counter_id<counter_value | check counter less than some value |
  ...  | 6) | [mo:][counter_type]:counter_id=existing | check counter existing |
  ...  | 7) | [mo:][counter_type]:counter_id=not_existing | check counter not existing |
  ...  | 8) | "last " before the expression listed in 1)~7)  | check counter satisfying the expression
  ...        in last pm counter interval. |
  ...
  ...  format of rd_counters_expression: almost same as pm_counters_expression,
  ...  the difference is that it uses counter_name not counter_id.
  ...
  ...
  ...  Example:
  ...  1)
  ...  | ${pm_counters} | Create List | M8017C11=existing | M8017C12<=1 | M8017C13>=2 | M8008C13=1 |
  ...  | LNCEL-100:M8008C12>1 | LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C5=0 | every M8061C214<=900 |
  ...  | Check Counters | ${pm_counters} |
  ...  2)
  ...  | ${rd_counters} | Create List | REPORT_RSCFS_ATT_UTRAN>=2 |
  ...  | Check Counters | \ rd_counters_expression=${rd_counters} |
  ...  3)
  ...  | Check Counters | \ ${pm_counters} | ${rd_counters} |
  Check Pm Pod And Container Full Name Cu
  @{result_list}=  Check Counters And Return Result Cu  ${pm_counters_expression}  ${rd_counters_expression}  ${wait}
  FOR  ${counter_result}  IN  @{result_list}
    ${check_result}  Set Variable  ${counter_result[2]}
    Run Keyword If  '${check_result.lower()}'== 'failed'  Fail
    ...  check counter failed, pls check keyword "check counters and return result cu"
  END

Check Counters Du Aic
  [Arguments]  ${pm_counters_expression}=${EMPTY}  ${rd_counters_expression}=${EMPTY}  ${wait}=${True}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to check PM counter and R&D counter
  ...  \ \ \ \ \ \ | step1 | wait counter file produced at next pm interval |
  ...  \ \ \ \ \ | step2 | download all counter files |
  ...  \ \ \ \ | step3 | unzip all counter files and parse and calculate the total number, and return check list. |
  ...  \ \ \ \ \ | Input Parameters | Man. | Description |
  ...  \ | pm_counters_expression \ | No \ \ | pm counters expression list |
  ...  | rd_counters_expression | No | rd counters expression list |
  ...  | wait | No | wait for pm counter interval. for cu,du,du2 case, only need to wait for one time |
  ...
  ...  format of pm_counters_expression:
  ...  | 1) | [mo:][counter_type]:counter_id=counter_value | check counter equal to some value |
  ...  | 2) | [mo:][counter_type]:counter_id>=counter_value | check counter more than or equal to some value |
  ...  | 3) | [mo:][counter_type]:counter_id<=counter_value | check counter less than or equal to some value |
  ...  | 4) | [mo:][counter_type]:counter_id>counter_value | check counter more than some value |
  ...  | 5) | [mo:][counter_type]:counter_id<counter_value | check counter less than some value |
  ...  | 6) | [mo:][counter_type]:counter_id=existing | check counter existing |
  ...  | 7) | [mo:][counter_type]:counter_id=not_existing | check counter not existing |
  ...  | 8) | "last " before the expression listed in 1)~7)  | check counter satisfying the expression
  ...        in last pm counter interval. |
  ...
  ...  format of rd_counters_expression: almost same as pm_counters_expression,
  ...  the difference is that it uses counter_name not counter_id.
  ...
  ...
  ...  Example:
  ...  1)
  ...  | ${pm_counters} | Create List | M8017C11=existing | M8017C12<=1 | M8017C13>=2 | M8008C13=1 |
  ...  | LNCEL-100:M8008C12>1 | LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C5=0 | every M8061C214<=900 |
  ...  | Check Counters | ${pm_counters} |
  ...  2)
  ...  | ${rd_counters} | Create List | REPORT_RSCFS_ATT_UTRAN>=2 |
  ...  | Check Counters | \ rd_counters_expression=${rd_counters} |
  ...  3)
  ...  | Check Counters | \ ${pm_counters} | ${rd_counters} |
  Check Pm Pod And Container Full Name Du
  @{result_list}=  Check Counters And Return Result Du  ${pm_counters_expression}  ${rd_counters_expression}  ${wait}
  FOR  ${counter_result}  IN  @{result_list}
    ${check_result}  Set Variable  ${counter_result[2]}
    Run Keyword If  '${check_result.lower()}'== 'failed'  Fail
    ...  check counter failed, pls check keyword "check counters and return result du"
  END

Check Counters Du2 Aic
  [Arguments]  ${pm_counters_expression}=${EMPTY}  ${rd_counters_expression}=${EMPTY}  ${wait}=${True}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to check PM counter and R&D counter
  ...  \ \ \ \ \ \ | step1 | wait counter file produced at next pm interval |
  ...  \ \ \ \ \ | step2 | download all counter files |
  ...  \ \ \ \ | step3 | unzip all counter files and parse and calculate the total number, and return check list. |
  ...  \ \ \ \ \ | Input Parameters | Man. | Description |
  ...  \ | pm_counters_expression \ | No \ \ | pm counters expression list |
  ...  | rd_counters_expression | No | rd counters expression list |
  ...  | wait | No | wait for pm counter interval. for cu,du,du2 case, only need to wait for one time |
  ...
  ...  format of pm_counters_expression:
  ...  | 1) | [mo:][counter_type]:counter_id=counter_value | check counter equal to some value |
  ...  | 2) | [mo:][counter_type]:counter_id>=counter_value | check counter more than or equal to some value |
  ...  | 3) | [mo:][counter_type]:counter_id<=counter_value | check counter less than or equal to some value |
  ...  | 4) | [mo:][counter_type]:counter_id>counter_value | check counter more than some value |
  ...  | 5) | [mo:][counter_type]:counter_id<counter_value | check counter less than some value |
  ...  | 6) | [mo:][counter_type]:counter_id=existing | check counter existing |
  ...  | 7) | [mo:][counter_type]:counter_id=not_existing | check counter not existing |
  ...  | 8) | "last " before the expression listed in 1)~7)  | check counter satisfying the expression
  ...        in last pm counter interval. |
  ...
  ...  format of rd_counters_expression: almost same as pm_counters_expression,
  ...  the difference is that it uses counter_name not counter_id.
  ...
  ...
  ...  Example:
  ...  1)
  ...  | ${pm_counters} | Create List | M8017C11=existing | M8017C12<=1 | M8017C13>=2 | M8008C13=1 |
  ...  | LNCEL-100:M8008C12>1 | LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C5=0 | every M8061C214<=900 |
  ...  | Check Counters | ${pm_counters} |
  ...  2)
  ...  | ${rd_counters} | Create List | REPORT_RSCFS_ATT_UTRAN>=2 |
  ...  | Check Counters | \ rd_counters_expression=${rd_counters} |
  ...  3)
  ...  | Check Counters | \ ${pm_counters} | ${rd_counters} |
  Check Pm Pod And Container Full Name Du2
  @{result_list}=  Check Counters And Return Result Du2  ${pm_counters_expression}  ${rd_counters_expression}  ${wait}
  FOR  ${counter_result}  IN  @{result_list}
    ${check_result}  Set Variable  ${counter_result[2]}
    Run Keyword If  '${check_result.lower()}'== 'failed'  Fail
    ...  check counter failed, pls check keyword "check counters and return result du2"
  END

Check Counters Du3 Aic
  [Arguments]  ${pm_counters_expression}=${EMPTY}  ${rd_counters_expression}=${EMPTY}  ${wait}=${True}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to check PM counter and R&D counter
  ...  \ \ \ \ \ \ | step1 | wait counter file produced at next pm interval |
  ...  \ \ \ \ \ | step2 | download all counter files |
  ...  \ \ \ \ | step3 | unzip all counter files and parse and calculate the total number, and return check list. |
  ...  \ \ \ \ \ | Input Parameters | Man. | Description |
  ...  \ | pm_counters_expression \ | No \ \ | pm counters expression list |
  ...  | rd_counters_expression | No | rd counters expression list |
  ...  | wait | No | wait for pm counter interval. for cu,du,du2 case, only need to wait for one time |
  ...
  ...  format of pm_counters_expression:
  ...  | 1) | [mo:][counter_type]:counter_id=counter_value | check counter equal to some value |
  ...  | 2) | [mo:][counter_type]:counter_id>=counter_value | check counter more than or equal to some value |
  ...  | 3) | [mo:][counter_type]:counter_id<=counter_value | check counter less than or equal to some value |
  ...  | 4) | [mo:][counter_type]:counter_id>counter_value | check counter more than some value |
  ...  | 5) | [mo:][counter_type]:counter_id<counter_value | check counter less than some value |
  ...  | 6) | [mo:][counter_type]:counter_id=existing | check counter existing |
  ...  | 7) | [mo:][counter_type]:counter_id=not_existing | check counter not existing |
  ...  | 8) | "last " before the expression listed in 1)~7)  | check counter satisfying the expression
  ...        in last pm counter interval. |
  ...
  ...  format of rd_counters_expression: almost same as pm_counters_expression,
  ...  the difference is that it uses counter_name not counter_id.
  ...
  ...
  ...  Example:
  ...  1)
  ...  | ${pm_counters} | Create List | M8017C11=existing | M8017C12<=1 | M8017C13>=2 | M8008C13=1 |
  ...  | LNCEL-100:M8008C12>1 | LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C5=0 | every M8061C214<=900 |
  ...  | Check Counters | ${pm_counters} |
  ...  2)
  ...  | ${rd_counters} | Create List | REPORT_RSCFS_ATT_UTRAN>=2 |
  ...  | Check Counters | \ rd_counters_expression=${rd_counters} |
  ...  3)
  ...  | Check Counters | \ ${pm_counters} | ${rd_counters} |
  Check Pm Pod And Container Full Name Du3
  @{result_list}=  Check Counters And Return Result Du3  ${pm_counters_expression}  ${rd_counters_expression}  ${wait}
  FOR  ${counter_result}  IN  @{result_list}
    ${check_result}  Set Variable  ${counter_result[2]}
    Run Keyword If  '${check_result.lower()}'== 'failed'  Fail
    ...  check counter failed, pls check keyword "check counters and return result du3"
  END

Check Counters Du4 Aic
  [Arguments]  ${pm_counters_expression}=${EMPTY}  ${rd_counters_expression}=${EMPTY}  ${wait}=${True}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to check PM counter and R&D counter
  ...  \ \ \ \ \ \ | step1 | wait counter file produced at next pm interval |
  ...  \ \ \ \ \ | step2 | download all counter files |
  ...  \ \ \ \ | step3 | unzip all counter files and parse and calculate the total number, and return check list. |
  ...  \ \ \ \ \ | Input Parameters | Man. | Description |
  ...  \ | pm_counters_expression \ | No \ \ | pm counters expression list |
  ...  | rd_counters_expression | No | rd counters expression list |
  ...  | wait | No | wait for pm counter interval. for cu,du,du2 case, only need to wait for one time |
  ...
  ...  format of pm_counters_expression:
  ...  | 1) | [mo:][counter_type]:counter_id=counter_value | check counter equal to some value |
  ...  | 2) | [mo:][counter_type]:counter_id>=counter_value | check counter more than or equal to some value |
  ...  | 3) | [mo:][counter_type]:counter_id<=counter_value | check counter less than or equal to some value |
  ...  | 4) | [mo:][counter_type]:counter_id>counter_value | check counter more than some value |
  ...  | 5) | [mo:][counter_type]:counter_id<counter_value | check counter less than some value |
  ...  | 6) | [mo:][counter_type]:counter_id=existing | check counter existing |
  ...  | 7) | [mo:][counter_type]:counter_id=not_existing | check counter not existing |
  ...  | 8) | "last " before the expression listed in 1)~7)  | check counter satisfying the expression
  ...        in last pm counter interval. |
  ...
  ...  format of rd_counters_expression: almost same as pm_counters_expression,
  ...  the difference is that it uses counter_name not counter_id.
  ...
  ...
  ...  Example:
  ...  1)
  ...  | ${pm_counters} | Create List | M8017C11=existing | M8017C12<=1 | M8017C13>=2 | M8008C13=1 |
  ...  | LNCEL-100:M8008C12>1 | LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C5=0 | every M8061C214<=900 |
  ...  | Check Counters | ${pm_counters} |
  ...  2)
  ...  | ${rd_counters} | Create List | REPORT_RSCFS_ATT_UTRAN>=2 |
  ...  | Check Counters | \ rd_counters_expression=${rd_counters} |
  ...  3)
  ...  | Check Counters | \ ${pm_counters} | ${rd_counters} |
  Check Pm Pod And Container Full Name Du4
  @{result_list}=  Check Counters And Return Result Du4  ${pm_counters_expression}  ${rd_counters_expression}  ${wait}
  FOR  ${counter_result}  IN  @{result_list}
    ${check_result}  Set Variable  ${counter_result[2]}
    Run Keyword If  '${check_result.lower()}'== 'failed'  Fail
    ...  check counter failed, pls check keyword "check counters and return result du4"
  END

Clear Counter files Cu Aic
  [Arguments]  ${wait}=${True}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to clear PM counter and R&D counter
  ...    | Arguments   | Man. | Default | Description |
  ...    |    wait     | No   | ${True} | wait for pm counter interval before checking counters value or not |
  Check Pm Pod And Container Full Name Cu
  Clear Counter files Cu  wait=${wait}

Clear Counter files Du Aic
  [Arguments]  ${wait}=${True}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to clear PM counter and R&D counter
  ...    | Arguments   | Man. | Default | Description |
  ...    |    wait     | No   | ${True} | wait for pm counter interval before checking counters value or not |
  Check Pm Pod And Container Full Name Du
  Clear Counter files Du  wait=${wait}

Clear Counter files Du2 Aic
  [Arguments]  ${wait}=${True}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to clear PM counter and R&D counter
  ...    | Arguments   | Man. | Default | Description |
  ...    |    wait     | No   | ${True} | wait for pm counter interval before checking counters value or not |
  Check Pm Pod And Container Full Name Du2
  Clear Counter files Du2  wait=${wait}

Clear Counter files Du3 Aic
  [Arguments]  ${wait}=${True}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to clear PM counter and R&D counter
  ...    | Arguments   | Man. | Default | Description |
  ...    |    wait     | No   | ${True} | wait for pm counter interval before checking counters value or not |
  Check Pm Pod And Container Full Name Du3
  Clear Counter files Du3  wait=${wait}

Clear Counter files Du4 Aic
  [Arguments]  ${wait}=${True}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to clear PM counter and R&D counter
  ...    | Arguments   | Man. | Default | Description |
  ...    |    wait     | No   | ${True} | wait for pm counter interval before checking counters value or not |
  Check Pm Pod And Container Full Name Du4
  Clear Counter files Du4  wait=${wait}

Fm Fault Should Be Raised Cu Aic
  [Arguments]  ${fault}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to check alarm
  ...  severity=transient means history alarm type
  ...  for example:
  ...  ${fault6356} | create list | Severity=minor | fault_id=6356 |
  ...  | fault_name=Automatic access class barring is active |  alarm_id=7655| alarm_name=CELL NOTIFICATION|
  ...  | Fm Fault Should Be Raised Cu Aic | ${fault6356}
  Fm Fault Should Be Raised Cu  conditions=${fault}

Fm Fault Should Be Raised Du Aic
  [Arguments]  ${fault}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to check alarm
  ...  severity=transient means history alarm type
  ...  for example:
  ...  ${fault6356} | create list | Severity=minor | fault_id=6356 |
  ...  | fault_name=Automatic access class barring is active |  alarm_id=7655| alarm_name=CELL NOTIFICATION|
  ...  | Fm Fault Should Be Raised Du Aic | ${fault6356}
  Fm Fault Should Be Raised Du  conditions=${fault}

Fm Fault Should Be Raised Du2 Aic
  [Arguments]  ${fault}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to check alarm
  ...  severity=transient means history alarm type
  ...  for example:
  ...  ${fault6356} | create list | Severity=minor | fault_id=6356 |
  ...  | fault_name=Automatic access class barring is active |  alarm_id=7655| alarm_name=CELL NOTIFICATION|
  ...  | Fm Fault Should Be Raised Du2 Aic | ${fault6356}
  Fm Fault Should Be Raised Du2  conditions=${fault}

Fm Fault Should Be Raised Du3 Aic
  [Arguments]  ${fault}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to check alarm
  ...  severity=transient means history alarm type
  ...  for example:
  ...  ${fault6356} | create list | Severity=minor | fault_id=6356 |
  ...  | fault_name=Automatic access class barring is active |  alarm_id=7655| alarm_name=CELL NOTIFICATION|
  ...  | Fm Fault Should Be Raised Du3 Aic | ${fault6356}
  Fm Fault Should Be Raised Du3  conditions=${fault}

Fm Fault Should Be Raised Du4 Aic
  [Arguments]  ${fault}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to check alarm
  ...  severity=transient means history alarm type
  ...  for example:
  ...  ${fault6356} | create list | Severity=minor | fault_id=6356 |
  ...  | fault_name=Automatic access class barring is active |  alarm_id=7655| alarm_name=CELL NOTIFICATION|
  ...  | Fm Fault Should Be Raised Du4 Aic | ${fault6356}
  Fm Fault Should Be Raised Du4  conditions=${fault}

Fm Fault Should Be Cleared Cu Aic
  [Arguments]  ${fault}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to check alarm
  ...  severity=transient means history alarm type
  ...  for example:
  ...  ${fault6356} | create list | Severity=minor | fault_id=6356 |
  ...  | fault_name=Automatic access class barring is active |  alarm_id=7655| alarm_name=CELL NOTIFICATION|
  ...  | Fm Fault Should Be Cleared Cu Aic | ${fault6356}
  Fm Fault Should Be Cleared Cu  conditions=${fault}

Fm Fault Should Be Cleared Du Aic
  [Arguments]  ${fault}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to check alarm
  ...  severity=transient means history alarm type
  ...  for example:
  ...  ${fault6356} | create list | Severity=minor | fault_id=6356 |
  ...  | fault_name=Automatic access class barring is active |  alarm_id=7655| alarm_name=CELL NOTIFICATION|
  ...  | Fm Fault Should Be Cleared Du Aic | ${fault6356}
  Fm Fault Should Be Cleared Du  conditions=${fault}

Fm Fault Should Be Cleared Du2 Aic
  [Arguments]  ${fault}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to check alarm
  ...  severity=transient means history alarm type
  ...  for example:
  ...  ${fault6356} | create list | Severity=minor | fault_id=6356 |
  ...  | fault_name=Automatic access class barring is active |  alarm_id=7655| alarm_name=CELL NOTIFICATION|
  ...  | Fm Fault Should Be Cleared Du2 Aic | ${fault6356}
  Fm Fault Should Be Cleared Du2  conditions=${fault}

Fm Fault Should Be Cleared Du3 Aic
  [Arguments]  ${fault}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to check alarm
  ...  severity=transient means history alarm type
  ...  for example:
  ...  ${fault6356} | create list | Severity=minor | fault_id=6356 |
  ...  | fault_name=Automatic access class barring is active |  alarm_id=7655| alarm_name=CELL NOTIFICATION|
  ...  | Fm Fault Should Be Cleared Du3 Aic | ${fault6356}
  Fm Fault Should Be Cleared Du3  conditions=${fault}

Fm Fault Should Be Cleared Du4 Aic
  [Arguments]  ${fault}
  [Documentation]  \ \ \ \ \ \ \ This keyword is to check alarm
  ...  severity=transient means history alarm type
  ...  for example:
  ...  ${fault6356} | create list | Severity=minor | fault_id=6356 |
  ...  | fault_name=Automatic access class barring is active |  alarm_id=7655| alarm_name=CELL NOTIFICATION|
  ...  | Fm Fault Should Be Cleared Du4 Aic | ${fault6356}
  Fm Fault Should Be Cleared Du4  conditions=${fault}

_Archive_a2a_successful_logs
    Return From Keyword If  '${KEYWORD STATUS}'=='FAIL'
    Create Directory  ${SAVE LOG DIRECTORY}/a2a_logs_succeed
    Execute Cmd On PC  mv ${SAVE LOG DIRECTORY}/*.ini ${SAVE LOG DIRECTORY}/a2a_logs_succeed
    Execute Cmd On PC  mv ${SAVE LOG DIRECTORY}/*.pdm ${SAVE LOG DIRECTORY}/a2a_logs_succeed
    Execute Cmd On PC  mv ${SAVE LOG DIRECTORY}/*-p.log ${SAVE LOG DIRECTORY}/a2a_logs_succeed
    Execute Cmd On PC  mv ${SAVE LOG DIRECTORY}/*-w.log ${SAVE LOG DIRECTORY}/a2a_logs_succeed
    Execute Cmd On PC  mv ${SAVE LOG DIRECTORY}/*.a2a_decode ${SAVE LOG DIRECTORY}/a2a_logs_succeed

Check Logs With Au2anlysis Aic
  [Arguments]  ${ini_path}  ${log_need_to_check}
  Check Log With Au2anlysis  ${ini_path}  ${log_need_to_check}  save_log_directory=${SAVE LOG DIRECTORY}

Check RRC log Aic
  [Arguments]  ${a2a_ini_file}
  Get RRC Log
  Check Logs With Au2anlysis Aic  ${a2a_ini_file}  p
  [Teardown]  Run Keyword And Ignore Error  _Archive_a2a_successful_logs

Check WireShark Log Aic
  [Arguments]  ${a2a_ini_file}  ${name}=${empty}  ${wait_string}=UEContextReleaseComplete::2  ${decode_option}=${EMPTY}
  ...  ${productVariant}=cu  ${download_du_log}=${True}  ${pod_name_cu}=cpif  ${pod_name_du}=cprt
  [Documentation]
  ...  This keyword is used to check wireshark log via a2a tool
  ...  | step1 | wait expected string occurred with specified times in wireshark log and stop it |
  ...  | step2 | check the log with a2a tool |
  ...
  ...  | Input Parameters | Man. | Default  | Description |
  ...  | a2a_ini_file     | YES  | NA       | a2a ini file  |
  ...  | name             | NO   | ${empty} | used to specify which wireshark log to be checked |
  ...  | wait_string      | NO   | UEContextReleaseComplete::1  | retry until this string appears \
  ...  for the dedicated times in wireshark log before download the log |
  ...  | decode_option    | NO   | ${empty} | used to specify extra options when transform wireshark pcap to txt |
  ...  | productVariant   | No   | cu |  specify productVariant is cu, du or du2 |
  ...
  ...  Format of wait_string:<expected_string>[::<times>]
  ...
  ...  Examples:
  ...  1) use default wait sting
  ...  | Check WireShark Log | ${CURDIR}/a2a_01/a2a.ini |
  ...
  ...  2) use other string and it appeared more than/equal to one time
  ...  | Check WireShark Log | ${CURDIR}/a2a_01/a2a.ini | wait_string=UEContextReleaseComplete |
  ...
  ...  3) use other string and it appeared more than/equal to specified times
  ...  | Check WireShark Log Aic | ${CURDIR}/a2a_01/a2a.ini | wait_string=Detach request::3 |
  ${wireshark_name_cu}=  Run Keyword If  "${productVariant.lower()}"=="cu"  Set Variable If  ${name.__len__()}==0  cu_${pod_name_cu}_wireshark
  ...  cu_${pod_name_cu}_wireshark_${name}
  ${wireshark_name_du}=  Run Keyword If  "${productVariant.lower()}"=="du"  Set Variable If  ${name.__len__()}==0  du_${pod_name_du}_wireshark
  ...  du_${pod_name_du}_wireshark_${name}
  ${wireshark_name_du2}=  Run Keyword If  "${productVariant.lower()}"=="du2"  Set Variable If  ${name.__len__()}==0  du2_${pod_name_du}_wireshark
  ...  du2_${pod_name_du2}_wireshark_${name}
  ${wireshark_name_du3}=  Run Keyword If  "${productVariant.lower()}"=="du3"  Set Variable If  ${name.__len__()}==0  du3_${pod_name_du}_wireshark
  ...  du3_${pod_name_du3}_wireshark_${name}
  ${wireshark_name_du4}=  Run Keyword If  "${productVariant.lower()}"=="du4"  Set Variable If  ${name.__len__()}==0  du4_${pod_name_du}_wireshark
  ...  du4_${pod_name_du4}_wireshark_${name}
  ${name_in_master_cu}=  Set Variable If  ${name.__len__()}==0  ${pod_name_cu}_wireshark  ${pod_name_cu}_wireshark_${name}
  ${name_in_master_du}=  Set Variable If  ${name.__len__()}==0  ${pod_name_du}_wireshark  ${pod_name_du}_wireshark_${name}
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="cu"  Stop Aic tcpdump After String Found  ${wireshark_name_cu}
  ...  ${name_in_master_cu}  ${wait_string}  ${decode_option}  ${productVariant}  ${pod_name_cu}
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du"  Stop Aic tcpdump After String Found  ${wireshark_name_du}
  ...  ${name_in_master_du}  ${wait_string}  ${decode_option}  ${productVariant}  pod_name_du=${pod_name_du}
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du2"  Stop Aic tcpdump After String Found  ${wireshark_name_du2}
  ...  ${name_in_master_du}  ${wait_string}  ${decode_option}  ${productVariant}  pod_name_du=${pod_name_du}
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du3"  Stop Aic tcpdump After String Found  ${wireshark_name_du3}
  ...  ${name_in_master_du}  ${wait_string}  ${decode_option}  ${productVariant}  pod_name_du=${pod_name_du}
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du4"  Stop Aic tcpdump After String Found  ${wireshark_name_du4}
  ...  ${name_in_master_du}  ${wait_string}  ${decode_option}  ${productVariant}  pod_name_du=${pod_name_du}
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="cu" and "${download_du_log}"=="True"
  ...  Stop To Capture Wireshark Log Vdu  tag=${name}
  Run Keyword And Ignore Error  Run Keyword If
  ...  "${productVariant.lower()}"=="cu" and "${download_du_log}"=="True" and '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='2du'
  ...  Stop To Capture Wireshark Log Vdu2  tag=${name}
  Run Keyword And Ignore Error  Run Keyword If
  ...  "${productVariant.lower()}"=="cu" and "${download_du_log}"=="True" and '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='3du'
  ...  Stop To Capture Wireshark Log Vdu3  tag=${name}
  Run Keyword And Ignore Error  Run Keyword If
  ...  "${productVariant.lower()}"=="cu" and "${download_du_log}"=="True" and '${DU_NUMBER}'!='du' and '${DU_NUMBER}'>='4du'
  ...  Stop To Capture Wireshark Log Vdu4  tag=${name}
#  Run Keyword If  '${BTS_NUMBER}'=='2'  Stop Capture Wireshark Log eNB2  ${name}
  recreate_wireshark_txt_files  ${a2a_ini_file}
  Check Logs With Au2anlysis Aic  ${a2a_ini_file}  w
  [Teardown]  Run Keyword And Ignore Error  _Archive_a2a_successful_logs

Stop Aic tcpdump After String Found
  [Arguments]  ${name}  ${name_in_master}  ${string}  ${decode_option}=${EMPTY}  ${productVariant}=cu  ${pod_name_cu}=cpif  ${pod_name_du}=cprt
  [Documentation]  This keyword start tshark
  ...
  ...  Step:
  ...  | 1 | switch to vCU/vDU |
  ...  | 2 | Stop tcpdump |
  ...  | 3 | ftp download log file |
  ...  | 4 | in aic pc connection, tshark change .pcap file to .txt file |
  ...
  ...  \ \ \ | Input Parameters | Man. | Description \ \ \ \ \ \ |
  ...  \ \ \ | name | Yes \ | name without .pcap same with start aic tcpdump name \ \ \ \ \ |
  ...
  ...  Example:
  ...  | 1 | Stop FCTB tcpdump | fctb |
  ${status}  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  2min  5s
  ...  Download Wireshark Log And Check String Aic  ${name}  ${name_in_master}  ${string}  ${decode_option}  ${productVariant}
  ...    ${pod_name_cu}  ${pod_name_du}
  Run Keyword And Ignore Error  Run Keyword If  "${status}[0]"  Check String Compare Result  ${name}  ${string}  log_lvl=WARN  log_to_console=True
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="cu"  Execute Cmd On Vcu
  ...  ls -ltr /tmp/${VCU_NAMESPACE}/tmp_wireshark/*.pcap
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du"  Execute Cmd On Vdu
  ...  ls -ltr /tmp/${VDU_NAMESPACE}/tmp_wireshark/*.pcap
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du2"  Execute Cmd On Vdu2
  ...  ls -ltr /tmp/${VDU2_NAMESPACE}/tmp_wireshark/*.pcap
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du3"  Execute Cmd On Vdu3
  ...  ls -ltr /tmp/${VDU3_NAMESPACE}/tmp_wireshark/*.pcap
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du4"  Execute Cmd On Vdu4
  ...  ls -ltr /tmp/${VDU4_NAMESPACE}/tmp_wireshark/*.pcap
#  Run Keyword And Ignore Error  Execute Command On Enb  ps -ef | grep 'tcpdump' | grep -v -w grep
  Run Keyword If  "${productVariant.lower()}"=="cu"  Stop Wireshark Capture Aic Vcu  pod_name=${pod_name_cu}  container_name=nwmgmt
  ...  namespace=${VCU_NAMESPACE}
  Run Keyword If  "${productVariant.lower()}"=="du"  Stop Wireshark Capture Aic Vdu  pod_name=${pod_name_du}  container_name=nwmgmt
  ...  namespace=${VDU_NAMESPACE}
  Run Keyword If  "${productVariant.lower()}"=="du2"  Stop Wireshark Capture Aic Vdu2  pod_name=${pod_name_du}  container_name=nwmgmt
  ...  namespace=${VDU2_NAMESPACE}
  Run Keyword If  "${productVariant.lower()}"=="du3"  Stop Wireshark Capture Aic Vdu3  pod_name=${pod_name_du}  container_name=nwmgmt
  ...  namespace=${VDU3_NAMESPACE}
  Run Keyword If  "${productVariant.lower()}"=="du4"  Stop Wireshark Capture Aic Vdu4  pod_name=${pod_name_du}  container_name=nwmgmt
  ...  namespace=${VDU4_NAMESPACE}
#  ${wireshark_pid}  Execute Command On Enb
#  ...  ps -ef | grep 'tcpdump -n -X -tt -i any -w' | grep -v -w grep | grep '${name}' | awk '{print $2}'
#  Run Keyword And Ignore Error  Execute Command On Enb  kill -9 ${wireshark_pid}
#  Run Keyword And Ignore Error  Execute Command On Enb  ps -ef | grep 'tcpdump'
#  Run Keyword And Ignore Error  Execute Command On Enb  echo $?

Download Wireshark Log And Check String Aic
  [Arguments]  ${name}  ${name_in_master}  ${string}=Detach request::1  ${decode_option}=${EMPTY}  ${productVariant}=cu
  ...  ${pod_name_cu}=cpif  ${pod_name_du}=cprt
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="cu"  Execute Cmd On Vcu
  ...  mkdir -p /tmp/${VCU_NAMESPACE}/tmp_wireshark/
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="cu"  Execute Cmd On Vcu
  ...  ls -ltr /tmp/${VCU_NAMESPACE}/tmp_wireshark/*.pcap
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du"  Execute Cmd On Vdu
  ...  mkdir -p /tmp/${VDU_NAMESPACE}/tmp_wireshark/
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du"  Execute Cmd On Vdu
  ...  ls -ltr /tmp/${VDU_NAMESPACE}/tmp_wireshark/*.pcap
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du2"  Execute Cmd On Vdu2
  ...  mkdir -p /tmp/${VDU2_NAMESPACE}/tmp_wireshark/
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du2"  Execute Cmd On Vdu2
  ...  ls -ltr /tmp/${VDU2_NAMESPACE}/tmp_wireshark/*.pcap
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du3"  Execute Cmd On Vdu3
  ...  mkdir -p /tmp/${VDU3_NAMESPACE}/tmp_wireshark/
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du3"  Execute Cmd On Vdu3
  ...  ls -ltr /tmp/${VDU3_NAMESPACE}/tmp_wireshark/*.pcap
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du4"  Execute Cmd On Vdu4
  ...  mkdir -p /tmp/${VDU4_NAMESPACE}/tmp_wireshark/
  Run Keyword And Ignore Error  Run Keyword If  "${productVariant.lower()}"=="du4"  Execute Cmd On Vdu4
  ...  ls -ltr /tmp/${VDU4_NAMESPACE}/tmp_wireshark/*.pcap
  Run Keyword If  "${productVariant.lower()}"=="cu"  Pure Download Wireshark Log To Master Vcu  pod_name=${pod_name_cu}  container_name=nwmgmt
  ...  namespace=${VCU_NAMESPACE}  wireshark_name=${name_in_master}.pcap  log_dir_in_master=/tmp/${VCU_NAMESPACE}/tmp_wireshark
  Run Keyword If  "${productVariant.lower()}"=="du"  Pure Download Wireshark Log To Master Vdu  pod_name=${pod_name_du}  container_name=nwmgmt
  ...  namespace=${VDU_NAMESPACE}  wireshark_name=${name_in_master}.pcap  log_dir_in_master=/tmp/${VDU_NAMESPACE}/tmp_wireshark
  Run Keyword If  "${productVariant.lower()}"=="du2"  Pure Download Wireshark Log To Master Vdu2  pod_name=${pod_name_du}  container_name=nwmgmt
  ...  namespace=${VDU2_NAMESPACE}  wireshark_name=${name_in_master}.pcap  log_dir_in_master=/tmp/${VDU2_NAMESPACE}/tmp_wireshark
  Run Keyword If  "${productVariant.lower()}"=="du3"  Pure Download Wireshark Log To Master Vdu3  pod_name=${pod_name_du}  container_name=nwmgmt
  ...  namespace=${VDU3_NAMESPACE}  wireshark_name=${name_in_master}.pcap  log_dir_in_master=/tmp/${VDU3_NAMESPACE}/tmp_wireshark
  Run Keyword If  "${productVariant.lower()}"=="du4"  Pure Download Wireshark Log To Master Vdu4  pod_name=${pod_name_du}  container_name=nwmgmt
  ...  namespace=${VDU4_NAMESPACE}  wireshark_name=${name_in_master}.pcap  log_dir_in_master=/tmp/${VDU4_NAMESPACE}/tmp_wireshark
  Run Keyword If  "${productVariant.lower()}"=="cu"  Get Wireshark From Vcu  /tmp/${VCU_NAMESPACE}/tmp_wireshark/${name_in_master}.pcap
  ...  ${SAVE LOG DIRECTORY}${/}${name}.pcap
  Run Keyword If  "${productVariant.lower()}"=="du"  Get Wireshark From Vdu  /tmp/${VDU_NAMESPACE}/tmp_wireshark/${name_in_master}.pcap
  ...  ${SAVE LOG DIRECTORY}${/}${name}.pcap
  Run Keyword If  "${productVariant.lower()}"=="du2"  Get Wireshark From Vdu2  /tmp/${VDU2_NAMESPACE}/tmp_wireshark/${name_in_master}.pcap
  ...  ${SAVE LOG DIRECTORY}${/}${name}.pcap
  Run Keyword If  "${productVariant.lower()}"=="du3"  Get Wireshark From Vdu3  /tmp/${VDU3_NAMESPACE}/tmp_wireshark/${name_in_master}.pcap
  ...  ${SAVE LOG DIRECTORY}${/}${name}.pcap
  Run Keyword If  "${productVariant.lower()}"=="du4"  Get Wireshark From Vdu4  /tmp/${VDU4_NAMESPACE}/tmp_wireshark/${name_in_master}.pcap
  ...  ${SAVE LOG DIRECTORY}${/}${name}.pcap
  ${tshark_comd}  catenate
  ...  tshark -r ${SAVE LOG DIRECTORY}${/}${name}.pcap -o ntrstr.defragment:TRUE ${decode_option}
  ...  -d tcp.port==${TCE_PORT},ntrstr -d tcp.port==${OMS_PORT},ntrstr -V >${SAVE LOG DIRECTORY}${/}${name}.txt
  Execute Cmd On Pc  ${tshark_comd}  timeout=120
  Execute Cmd On Pc  ls -ltr ${SAVE LOG DIRECTORY}
  ${expect_string}  ${times}  Check String Compare Result  ${name}  ${string}
  File Contain String No Less Than  ${SAVE LOG DIRECTORY}${/}${name}.txt  ${expect_string}  ${times}

Check String Compare Result
  [Arguments]  ${name}  ${string}=Detach request::1  ${log_lvl}=INFO  ${log_to_console}=False
  ${string}  Set Variable If  ${string.count("::")}  ${string}  ${string}::1
  ${expect_string}  Set Variable  ${string.split("::")[0]}
  ${times}  Set Variable  ${string.split("::")[-1]}
  ${actual_times}  Count String In File  ${SAVE LOG DIRECTORY}${/}${name}.txt  ${expect_string}
  Run Keyword If  "${times}" != "${actual_times}"  Log
  ...  ${name}.txt contains ${expect_string} for ${actual_times}, not equal to expected times: ${times}
  ...  level=${log_lvl}  console=${log_to_console}
  [Return]  ${expect_string}  ${times}

