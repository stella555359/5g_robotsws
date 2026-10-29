*** Settings ***
Documentation  Maintainer: daniel.bartkowiak@nokia.com
...  Resource with specific KWs for following tests:
...  ALD_Ret_Soft_Reset.robot
...  ALD_Ret_Hard_Reset.robot

*** Keywords ***
Step1: Ret ${type} Reset Preconditions
    [Documentation]  Ret ${type} Reset Preconditions
    Logging With Timestamp
    ...  message=Step1: Ret ${type} Reset Preconditions
    ...  style=STEP
    ...  frame=${TRUE}
    ${ims_dir}=  Run Keyword If  ${ITERATION}==0  Set Variable  ${CFG.test_logs_path}
    ...  ELSE  Set Variable  ${CFG.test_logs_path}/Loop_${ITERATION}
    IF  "${TESTED_BTS_ID}"=="${EMPTY}" and len(${CFG['active_bts_list']})>1
      Run Keywords
      ...  Logging With Timestamp
      ...  message=Multinode config detected. Please specify 'TESTED_BTS_ID' for testing.
      ...  style=ERROR
      ...  AND  Fail  Multinode config detected. Please specify 'TESTED_BTS_ID' for testing.
    ELSE IF  "${TESTED_BTS_ID}"=="${EMPTY}"
      Set Test Variable  ${TESTED_BTS_ID}  ${CFG['active_bts_list'][0]}
    END
    ${all_ald_to_ret_dict}=  Get ALD With RET Dict
    ${all_ald_sn_list}=  Get Dictionary Keys  ${all_ald_to_ret_dict}
    ${tested_ald_sn_list}=  Run Keyword If  'ALL' in @{USER_ALD_SN_LIST}
    ...  Create List  @{all_ald_sn_list}
    ...  ELSE IF  'RANDOM' in ${USER_ALD_SN_LIST}
    ...  Get Random List Based On Input List  list=${all_ald_sn_list}  length=${USER_ALD_SN_LIST[1]}
    ...  ELSE IF  'SELECT' in ${USER_ALD_SN_LIST}
    ...  Create List  @{USER_ALD_SN_LIST[1:None]}
    IF  "${tested_ald_sn_list}"=="@{EMPTY}" or "${tested_ald_sn_list}"=="${NONE}"
      Fail  'USER_ALD_SN_LIST' has wrong values. Please double check documentation and correct.
    END
    Set Test Variable  ${ALL_ALD_TO_RET_DICT}  ${all_ald_to_ret_dict}
    Set Test Variable  ${TESTED_ALD_SN_LIST}  ${tested_ald_sn_list}
    Set Test Variable  ${IMS_DIR}  ${ims_dir}
    Logging With Timestamp
    ...  message=Step1: Ret ${type} Reset Preconditions. Tested ALD serial numbers: ${tested_ald_sn_list}
    ...  style=DONE

Step2: Ret ${type} Reset
    [Documentation]  Ret ${type} Reset
    Logging With Timestamp
    ...  message=Step2: Ret ${type} Reset
    ...  style=STEP
    ...  frame=${TRUE}
    ${tested_ald_distnames}=  Create List
    FOR  ${ald_sn}  IN  @{TESTED_ALD_SN_LIST}
      Dictionary Should Contain Key  ${ALL_ALD_TO_RET_DICT}  ${ald_sn}  ALD ${ald_sn} doesn't contain RET
      Logging With Timestamp
      ...  message=Ret ${type} Reset on ${ald_sn} started.
      ...  style=ONGOING
      admin.Reset Unit  dist_name=${ALL_ALD_TO_RET_DICT['${ald_sn}']['id']}  reset_type=${type}  connection=${TESTED_BTS_ID}
      STATE Verify Multi Node State  scf_check=${FALSE}  timeout=120
      Logging With Timestamp
      ...  message=Ret ${type} Reset on ${ald_sn} finished.
      ...  style=DONE
      Append To List  ${tested_ald_distnames}  ${ALL_ALD_TO_RET_DICT['${ald_sn}']['id']}
    END
    admin.Collect Infomodel Log From Current Session
    ...  target_file_name=${IMS_DIR}/TestFiles/${TESTED_BTS_ID}/InfoModel_For_ALD_${type}_reset.ims2
    ...  connection=${TESTED_BTS_ID}
    Set Test Variable  ${TESTED_ALD_DISTNAMES}  ${tested_ald_distnames}
    Logging With Timestamp
    ...  message=Step2: Ret ${type} Reset
    ...  style=DONE

Get RET Runtime Distnames List
    [Documentation]  KW gets all RET distnames from tested BTS and selected user RET distnames,
    ...  based on SNs provided in 'USER_ALD_SN_LIST'
    ...
    ...  Return:
    ...  +--------------------------+--------------------------------------------------------------------+
    ...  | Return Value             | Description                                                        |
    ...  +==========================+====================================================================+
    ...  | ret_tested_dist_list     | tested ret distnames                                               |
    ...  +--------------------------+--------------------------------------------------------------------+
    ...  | all_ret_dist_list        | all ret distnames from tested BTS                                  |
    ...  +--------------------------+--------------------------------------------------------------------+
    ...
    ...  AUTHOR-daniel.bartkowiak@nokia.com  MAINTAINER-daniel.bartkowiak@nokia.com
    ${tmp_ret_tested_dist_list}=  Create List
    ${tmp_all_ret_dist_list}=  Create List
    FOR  ${ald_sn}  IN  @{ALL_ALD_TO_RET_DICT.keys()}
      Append To List  ${tmp_all_ret_dist_list}  ${ALL_ALD_TO_RET_DICT['${ald_sn}']['rets']}
      IF  '${ald_sn}' in ${TESTED_ALD_SN_LIST}
        Append To List  ${tmp_ret_tested_dist_list}  ${ALL_ALD_TO_RET_DICT['${ald_sn}']['rets']}
      END
    END
    ${ret_tested_dist_list}=  Combine Lists  @{tmp_ret_tested_dist_list}
    ${all_ret_dist_list}=  Combine Lists  @{tmp_all_ret_dist_list}
    [Return]  ${ret_tested_dist_list}  ${all_ret_dist_list}

Get ALD With RET Dict
    [Documentation]  KW prepares nested dictionary of all ALDs hosting RET.
    ...  Return:
    ...  +--------------------------+--------------------------------------------------------------------+
    ...  | Return Value             | Description                                                        |
    ...  +==========================+====================================================================+
    ...  | ald_with_ret_dict        | Nested dictionary of all ALD/RET                                   |
    ...  +--------------------------+--------------------------------------------------------------------+
    ${ald_with_ret_dict}=  Create Dictionary
    ${ru_runtime_list}=  admin.Get Ids For All  class_name=RMOD  connection=${TESTED_BTS_ID}
    FOR  ${ru}  IN  @{ru_runtime_list}
      ${ald_stat}  ${alds_msg}=  Run Keyword And Ignore Error  admin.Get Ald Id By Module Connector
      ...  module_id=${ru}
      ...  connection=${TESTED_BTS_ID}
      IF  '${ald_stat}'=='PASS'
        FOR  ${ald}  IN  @{alds_msg}
          IF  '${ald['mhaType']}'=='None'
            ${ret_list}=  Create List
            Set To Dictionary  ${ald_with_ret_dict}  ${ald['serialNumber']}=&{EMPTY}
            Set To Dictionary  ${ald_with_ret_dict['${ald['serialNumber']}']}  id=${ald['id']['internal']}
            FOR  ${ret}  IN  @{ald['RETUs']}
              Append To List  ${ret_list}  ${ret['id']['internal']}
            END
          END
          Set To Dictionary   ${ald_with_ret_dict['${ald['serialNumber']}']}  rets=${ret_list}
        END
      END
    END
    [Return]  ${ald_with_ret_dict}
