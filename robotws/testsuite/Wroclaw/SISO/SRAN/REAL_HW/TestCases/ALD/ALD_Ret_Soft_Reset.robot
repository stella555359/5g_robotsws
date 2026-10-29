*** Settings ***
Documentation
...  AUTHOR-daniel.bartkowiak@nokia.com  MAINTAINER-daniel.bartkowiak@nokia.com
...
...  *****************
...  Basic information
...  *****************
...  TC Verifies correct behaviour of RET deviace during soft reset. Device should stay online during reset.
...  Soft RET reset is performed only on SW side so no impact on any BTS HW/cells should be noticed.
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
...  07.02.2025 - Initial creation in New Framework

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./ALD_Ret_Reset.resource

*** Variables ***
@{USER_ALD_SN_LIST}    ALL      #By default there are tested all RET devices under selected ALD.
                                #User can select option ALL, RANDOM, SELECT according to above documentation.

${TESTED_BTS_ID}=  ${EMPTY}     # In case of multinode config, test must be executed on one node at a time with specified 'TESTED_BTS_ID'
                                # If single node config, 'TESTED_BTS_ID' is not used.
*** Keywords ***
TC__ALD_Ret_Soft_Reset
    [Documentation]  TC__ALD_Ret_Soft_Reset
    Common Test Setup
    Step1: Ret Soft Reset Preconditions
    Step2: Ret Soft Reset
    Step3: Ret Soft Reset Postconditions
    [Teardown]  Common Test Teardown

Step3: Ret Soft Reset Postconditions
    [Documentation]  Checking RET states
    Logging With Timestamp
    ...  message=Step3: Ret Soft Reset Postconditions
    ...  style=STEP
    ...  frame=${TRUE}
    ${tested_ret_runtime_list}  ${all_ret_runtime_list}=  Get RET Runtime Distnames List
    ${ru_runtime_list}=  admin.Get Ids For All  class_name=RMOD  connection=${TESTED_BTS_ID}
    ${lte_runtime_list}=  admin.Get Ids For All  class_name=LNCEL  search_for_iot_cells=${True}  connection=${TESTED_BTS_ID}
    ${wcdma_runtime_list}=  admin.Get Ids For All  class_name=WNCEL  connection=${TESTED_BTS_ID}
    ${gsm_runtime_list}=  admin.Get Ids For All  class_name=GNCEL  connection=${TESTED_BTS_ID}
    ${nr_runtime_list}=  admin.Get Ids For All  class_name=NRCEL  connection=${TESTED_BTS_ID}
    ${ald_runtime_list}=  admin.Get Ids For All  class_name=ALD  connection=${TESTED_BTS_ID}
    ${complex_runtime_list}=  Combine Lists
    ...  ${all_ret_runtime_list}  ${ru_runtime_list}
    ...  ${lte_runtime_list}  ${wcdma_runtime_list}
    ...  ${gsm_runtime_list}  ${nr_runtime_list}
    ...  ${ald_runtime_list}
    Logging With Timestamp
    ...  message=Checking states during RET Soft reset.
    ...  style=ONGOING
    FOR  ${distname}  IN  @{complex_runtime_list}
      ${status}  ${msg}=  Run Keyword And Ignore Error  Find Parameter Change
      ...  file_path=${IMS_DIR}/TestFiles/${TESTED_BTS_ID}/InfoModel_For_ALD_Soft_reset.ims2
      ...  dist_name=${distname}
      ...  parameter=availabilityStatus
      Run Keyword If  "${status}"=="PASS"  Run Keywords  Logging With Timestamp
      ...  message=${distname} state check failed:${\n}${msg}
      ...  style=ERROR
      ...  AND  Fail  ${distname} state check failed:${\n}${msg}
      Logging With Timestamp
      ...  message=${distname} availabilityStatus was correct during RET Soft reset. OnAir remained unchanged.
      ...  style=DONE
    END
    Logging With Timestamp
    ...  message=Step3: Ret Soft Reset Postconditions
    ...  style=DONE
