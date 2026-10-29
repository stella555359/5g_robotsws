*** Settings ***
Documentation
...  AUTHOR-daniel.bartkowiak@nokia.com  MAINTAINER-daniel.bartkowiak@nokia.com
...
...  *****************
...  Basic information
...  *****************
...  TC Verifies correct behaviour of RET deviace during hard reset. Device should loose connection during reset and reconnect.
...  Hard RET reset is performed as full HW reset, so requested ALD and associated RETs change its availability status.
...  NOTE. Take under consideration that user provides SN for ALD that can have associated several RETs.
...
...  User can select an option defining which RET modules will be reset: ALL, RANDOM, SELECT
...  'ALL' option resets all radio modules:
...  Example: ${USER_ALD_SN_LIST}=  ALL
...  'RANDOM' option resets randomly selected RET modules.
...  The number after 'RANDOM' determines the number of randomly selected RET modules.
...  Example: ${USER_ALD_SN_LIST}=  RANDOM  2
...  'SELECT' option resets the radio modules given in the list ${USER_ALD_SN_LIST}.
...  The serial numbers after 'SELECT' identify the selected radio modules.
...  Example: ${USER_ALD_SN_LIST}=  SELECT  123001001C7  324001003C7  4440010008C7
...  Remeber to put double SPACE before each value in 'USER_ALD_SN_LIST'
...
...  ******************
...  History of changes
...  ******************
...  - 07.02.2025 - Initial creation in New Framework

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./ALD_Ret_Reset.resource

*** Variables ***
@{USER_ALD_SN_LIST}    ALL      #By default there are tested all RET devices under selected ALD.
                                #User can select option ALL, RANDOM, SELECT according to above documentation.

${TESTED_BTS_ID}=  ${EMPTY}     # In case of multinode config, test must be executed on one node at a time with specified 'TESTED_BTS_ID'
                                # If single node config, 'TESTED_BTS_ID' is not used.
*** Keywords ***
TC__ALD_Ret_Hard_Reset
    [Documentation]  TC__ALD_Ret_Hard_Reset
    Common Test Setup
    Step1: Ret Hard Reset Preconditions
    Step2: Ret Hard Reset
    Step3: Ret Hard Reset Postconditions
    [Teardown]  Common Test Teardown

Step3: Ret Hard Reset Postconditions
    [Documentation]  Checking RET states
    Logging With Timestamp
    ...  message=Step3: Ret Hard Reset Postconditions
    ...  style=STEP
    ...  frame=${TRUE}
    ${tested_ret_runtime_list}  ${all_ret_runtime_list}=  Get RET Runtime Distnames List
    ${not_impacted_rets}=  Copy List  ${all_ret_runtime_list}
    Remove Values From List  ${not_impacted_rets}  @{tested_ret_runtime_list}
    ${not_impacted_alds}=  admin.Get Ids For All  class_name=ALD  connection=${TESTED_BTS_ID}
    Remove Values From List  ${not_impacted_alds}  @{TESTED_ALD_DISTNAMES}
    ${ru_runtime_list}=  admin.Get Ids For All  class_name=RMOD  connection=${TESTED_BTS_ID}
    ${lte_runtime_list}=  admin.Get Ids For All  class_name=LNCEL  search_for_iot_cells=${True}  connection=${TESTED_BTS_ID}
    ${wcdma_runtime_list}=  admin.Get Ids For All  class_name=WNCEL  connection=${TESTED_BTS_ID}
    ${gsm_runtime_list}=  admin.Get Ids For All  class_name=GNCEL  connection=${TESTED_BTS_ID}
    ${nr_runtime_list}=  admin.Get Ids For All  class_name=NRCEL  connection=${TESTED_BTS_ID}
    ${impacted_runtime_list}=  Combine Lists
    ...  ${tested_ret_runtime_list}  ${TESTED_ALD_DISTNAMES}
    ${not_impacted_runtime_list}=  Combine Lists
    ...  ${not_impacted_rets}  ${not_impacted_alds}
    ...  ${ru_runtime_list}  ${lte_runtime_list}
    ...  ${wcdma_runtime_list}  ${gsm_runtime_list}
    ...  ${nr_runtime_list}
    Logging With Timestamp
    ...  message=Checking states for user selected ALD/RET HW during RET Hard reset.
    ...  style=ONGOING
    FOR  ${distname}  IN  @{impacted_runtime_list}
      ${status_availa}  ${msg}=  Run Keyword And Ignore Error  Find Parameter Change
      ...  file_path=${IMS_DIR}/TestFiles/${TESTED_BTS_ID}/InfoModel_For_ALD_Hard_reset.ims2
      ...  dist_name=${distname}
      ...  parameter=availabilityStatus
      ...  value=Regex"(?i)off line"
      Run Keyword If  "${status_availa}"=="FAIL"  Run Keywords  Logging With Timestamp
      ...  message=${distname} availability state check failed:${\n}${msg}
      ...  style=ERROR
      ...  AND  Fail  ${distname} availability state check failed:${\n}${msg}
      ${status_oper}  ${msg}=  Run Keyword And Ignore Error  Find Parameter Change
      ...  file_path=${IMS_DIR}/TestFiles/${TESTED_BTS_ID}/InfoModel_For_ALD_Hard_reset.ims2
      ...  dist_name=${distname}
      ...  parameter=operationalState
      ...  value=Regex"(?i)disabled"
      Run Keyword If  "${status_oper}"=="FAIL"  Run Keywords  Logging With Timestamp
      ...  message=${distname} operational state check failed:${\n}${msg}
      ...  style=ERROR
      ...  AND  Fail  ${distname} operational state check failed:${\n}${msg}
      Logging With Timestamp
      ...  message=${distname} availabilityStatus and operationalState were correct during RET Hard reset. Reconnection detected.
      ...  style=DONE
    END
    Logging With Timestamp
    ...  message=Checking states for not impacted HW during RET Hard reset.
    ...  style=ONGOING
    FOR  ${distname}  IN  @{not_impacted_runtime_list}
      ${status}  ${msg}=  Run Keyword And Ignore Error  Find Parameter Change
      ...  file_path=${IMS_DIR}/TestFiles/${TESTED_BTS_ID}/InfoModel_For_ALD_Hard_reset.ims2
      ...  dist_name=${distname}
      ...  parameter=availabilityStatus
      Run Keyword If  "${status}"=="PASS"  Run Keywords  Logging With Timestamp
      ...  message=${distname} state check failed:${\n}${msg}
      ...  style=ERROR
      ...  AND  Fail  ${distname} state check failed:${\n}${msg}
      Logging With Timestamp
      ...  message=${distname} availabilityStatus was correct during RET Hard reset. OnAir remained unchanged.
      ...  style=DONE
    END
    Logging With Timestamp
    ...  message=Step3: Ret Hard Reset Postconditions
    ...  style=DONE
