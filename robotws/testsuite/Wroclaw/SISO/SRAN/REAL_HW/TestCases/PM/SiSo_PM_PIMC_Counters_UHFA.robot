*** Settings ***
Documentation
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/3690698/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  Step 1: Preconditions
  ...  Checking if RMOD UHFA AB versiob in HW configuration, if not test fail.
  ...  Checking current actPimCancellation and pimCancellingEnabled values, if not set to false, setting to false.
  ...  Set global variables for RMOD UHFA and PIM parameters.
  ...
  ...  Step 2: Activate PIM Cancellation Feature
  ...  Setting actPimCancellation to true, setting mtPIMCancellation to ${INTERVAL}min.
  ...  Checking if all cells are onAir after recommissioning.
  ...  Waiting ${INTERVAL} minutes to get PM counters.
  ...  Checking if PM counters are collected.
  ...
  ...  Step 3: Activate PIM Cancelling Enabled
  ...  Setting pimCancellingEnabled to true, checking if set to true.
  ...  Setting pimCancellingEnabled to false, checking if set to false.
  ...  Waiting ${INTERVAL} minutes to get PM counters.
  ...  Checking if PM counters are collected.
  ...
  ...  Step 4: Deactivate PIM Cancellation Feature
  ...  Setting actPimCancellation to false, setting mtPIMCancellation to disabled.
  ...  Waiting ${INTERVAL} minutes to get PM counters.
  ...  Checking if PM counters are collected.
  ...  Compare PM counters length after step 3 and step 4.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 08.11.2024 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../../resources/common_kw.robot

*** Variables ***

${INTERVAL}  15  # for parameter: mtBtsEnergyMonitoring. Please enter only the number. Available intervals in minutes: 15,30,60,360,720,1440
${RMOD_SERIAL_NUMBER}  LBALLU-YD18040QX64

*** Keywords ***
TC__SiSo_PM_PIMC_Counters_UHFA
    Set Tags  AUTHOR-mateusz.kawka@nokia.com  MAINTAINER-mateusz.kawka@nokia.com
    Common Test Setup
    ${bts_id}  Get From Dictionary  ${CFG.RF_INFO['${RMOD_SERIAL_NUMBER}']}  scf_btsid_primary
    Step1: Preconditions For PIMC_UHFA  ${bts_id}
    Step2: Activate PIM Cancellation Feature  ${bts_id}
    Step3: Activate PIM Cancelling Enabled  ${bts_id}
    Step4: Deactivate PIM Cancellation Feature  ${bts_id}

    [Teardown]  Run Keywords
    ...  Restore Reference Configuration  ${bts_id}
    ...  AND  Common Test Teardown
Step1: Preconditions For PIMC_UHFA
    [Arguments]    ${bts_id}
    Logging With Timestamp
    ...  message=Step1: Preconditions For PIMC_UHFA
    ...  style=STEP
    ...  frame=${TRUE}

    ${pim_counters}  Create List
    FOR  ${counter}  IN RANGE  32
      ${counter_name}  Evaluate  'M8086C'+'${counter}'
      Append To list  ${pim_counters}  ${counter_name}
    END

    Set Test Variable  ${PIM_COUNTERS}
    Check Interval  ${INTERVAL}

    ${rmods_info}  admin.Get FRM  timeout=60  connection=${bts_id}
    FOR  ${rmod}  IN  @{rmods_info}
      IF  '${rmod['productName']}'=='UHFA'
          ${rmod_internal_distname}  Set Variable  ${rmod['id']['internal']}
          ${rmod_config_distname}  Set Variable  ${rmod['id']['configuration']}
          IF  'AB' not in '${rmod['productCode']}'
              Fail  RMOD UHFA found but no with product code AB ! Test set failed !
          END
      ELSE
          Continue For Loop
      END
    END

    IF  '${rmod_internal_distname}'=='${NONE}'
        Fail  RMOD UHFA not found in HW Configuration ! Test set failed !
    ELSE
        Logging With Timestamp  message=RMOD UHFA found in configuration!
        Set Test Variable  ${RMOD_CONFIG_DISTNAME}
    END

    ${rmod_number}  Evaluate  '${rmod_config_distname}'.rsplit('-',1)[1]
    ${pim_params_list}    Create List    actPimCancellation  pimCancellingEnabled

    Set Test Variable  ${PIM_PARAMS_LIST}
    Set Test Variable  ${OBJECT_MTPIMCANCELLATION}  MRBTS-${bts_id}/LNBTS-${bts_id}/PMRNL-1

    ${reference_params_dict}  admin.Get Parameter By Distname  ${rmod_config_distname}  ${PIM_PARAMS_LIST}  connection=${bts_id}
    Set Test Variable  ${REFERENCE_PARAMS_DICT}

    IF  ${reference_params_dict[0]['parameters']['actPimCancellation']}
        Logging With Timestamp  actPimCancellation is set to True, setting to false before TC run !
        admin.Perform Parameter Recommissioning  ${rmod_config_distname}  actPimCancellation  update  false
        ...  alias=${bts_id}
    ELSE
        Logging With Timestamp    message=actPimCancellation is set to false, no need to change !
    END

    IF  ${reference_params_dict[0]['parameters']['pimCancellingEnabled']}
        Logging With Timestamp  message=pimCancellingEnabled is set to true, setting to false before TC run !
        Perform Parameter Recommissioning  ${rmod_config_distname}  pimCancellingEnabled  update  false
        ...  alias=${bts_id}
    ELSE
        Logging With Timestamp  message=pimCancellingEnabled is set to false, no need to change !
    END

Step2: Activate PIM Cancellation feature
    [Arguments]    ${bts_id}
    Logging With Timestamp    message=Step2: Activate PIM Cancellation feature
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Updating actPimCancellation parameter to true ...
    ...  style=ONGOING
    admin.Perform Parameter Recommissioning  ${RMOD_CONFIG_DISTNAME}  actPimCancellation  update  true  alias=${bts_id}
    ...  skip_parameter_relation_errors=True

    Logging With Timestamp
    ...  message=Updating mtPIMCancellation parameter to ${INTERVAL}min ...
    ...  style=ONGOING
    admin.Perform Parameter Recommissioning  ${OBJECT_MTPIMCANCELLATION}  mtPIMCancellation  update  ${INTERVAL}min  alias=${bts_id}
    ...  skip_parameter_relation_errors=True

    Logging With Timestamp
    ...  message=Recommissioning done, checking cells state !
    ${onair_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  not ${onair_status}
        Perform Parameter Recommissioning  ${RMOD_CONFIG_DISTNAME}  actPimCancellation  update  false  alias=${bts_id}
        Fail  Cells are not onAir after recommissioning! Feature deactivated and set test fail !
    ELSE
        Logging With Timestamp  message=All cells are onAir !
    END

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Logging With Timestamp
    ...  message=Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !
    ...  style=ONGOING
    Sleep  ${time_to_sleep} minutes

    ${pim_counter_len}  Verify PIM Counters And Return Length  ${PIM_COUNTERS}  ${bts_id}

    Set Test Variable  ${PIM_COUNTER_FT_ENABLED}   ${pim_counter_len}

Step3: Activate PIM Cancelling Enabled
    [Arguments]    ${bts_id}
    Logging With Timestamp    message=Step3: Activate PIM Cancelling Enabled
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp    message=Updating pimCancellingEnabled parameter to true ...
    ...  style=ONGOING

    admin.Perform Parameter Recommissioning  ${RMOD_CONFIG_DISTNAME}  pimCancellingEnabled  update  true  alias=${bts_id}
    ...  skip_parameter_relation_errors=True
    ${current_params_dict}  admin.Get Parameter By Distname  ${RMOD_CONFIG_DISTNAME}  ${PIM_PARAMS_LIST}  connection=${bts_id}

    ${pim_can_enab}  Set Variable  ${current_params_dict[0]['parameters']['pimCancellingEnabled']}

    IF  ${pim_can_enab}
        Logging With Timestamp  message=pimCancellingEnabled setting to True!
    ELSE
        Logging With Timestamp  message=pimCancellingEnabled setting to true unsuccessful!
        Fail  pimCancellingEnabled setting to true unsuccessful ! values=False
    END

    Logging With Timestamp    pimCanellingEnabled set to true ! Now recommissioning to false !
    admin.Perform Parameter Recommissioning  ${RMOD_CONFIG_DISTNAME}  pimCancellingEnabled  update  false  alias=${bts_id}
    ...  skip_parameter_relation_errors=True

    ${current_params_dict}  admin.Get Parameter By Distname  ${RMOD_CONFIG_DISTNAME}  ${PIM_PARAMS_LIST}  connection=${bts_id}

    ${pim_can_enab}  Set Variable  ${current_params_dict[0]['parameters']['pimCancellingEnabled']}

    IF  ${pim_can_enab} == False
        Logging With Timestamp  message=pimCancellingEnabled setting to false successful!
    ELSE
        Logging With Timestamp  message=pimCancellingEnabled setting to false unsuccessful!
        Fail  pimCancellingEnabled setting to false unsuccessful !
    END

    Logging With Timestamp
    ...  message=Recommissioning done, checking cells state !
    ${onair_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  not ${onair_status}
        Fail  Cells are not onAir after recommissioning! Feature deactivated and set test fail !
    ELSE
        Logging With Timestamp  message=All cells are onAir !
    END

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Logging With Timestamp
    ...  message=Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !
    ...  style=ONGOING
    Sleep  ${time_to_sleep} minutes
    ${pim_counter_len_step3}  Verify PIM Counters And Return Length  ${PIM_COUNTERS}  ${bts_id}

    Set Test Variable  ${PIM_COUNTER_FT_ALG_ENABLED}   ${pim_counter_len_step3}

    ${len_status}  Evaluate  ${PIM_COUNTER_FT_ALG_ENABLED}>${PIM_COUNTER_FT_ENABLED}

    IF  ${len_status}
        Logging With Timestamp
        ...  message=After set pimCancellingEnabed to true counters are still collecting, going to next step !
    ELSE
        Logging With Timestamp
        ...  message=After set pimCancellingEnabed to true counters are not collected, set test fail!
        Fail  After set to true pimCancellingEnabed counters are not collected !
    END

Step4: Deactivate PIM Cancellation feature
    [Arguments]    ${bts_id}
    Logging With Timestamp    message=Step4: Deactivate PIM Cancellation feature
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp    message=Updating actPimCancellation parameter to false ...
    ...  style=ONGOING
    admin.Perform Parameter Recommissioning  ${RMOD_CONFIG_DISTNAME}  actPimCancellation  update  false  alias=${bts_id}
    ...  skip_parameter_relation_errors=True

    Logging With Timestamp    message=Updating mtPIMCancellation parameter to disabled ...
    ...  style=ONGOING
    admin.Perform Parameter Recommissioning  ${OBJECT_MTPIMCANCELLATION}  mtPIMCancellation  update  disabled  alias=${bts_id}
    ...  skip_parameter_relation_errors=True

    Logging With Timestamp    message=Recommissioning done, checking cells state !
    ${onair_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  not ${onair_status}
        Fail  Cells are not onAir after recommissioning! Feature deactivated and set test fail !
    ELSE
        Logging With Timestamp  message=All cells are onAir !
    END

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Logging With Timestamp
    ...  message=Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !
    ...  style=ONGOING
    Sleep  ${time_to_sleep} minutes
    ${pim_counter_len}  Verify PIM Counters And Return Length  ${PIM_COUNTERS}  ${bts_id}

    IF  ${pim_counter_len}==${PIM_COUNTER_FT_ALG_ENABLED}
        Logging With Timestamp    message=PIM Cancellation feature deactivation successfull !
        ...  style=DONE
    ELSE
        Logging With Timestamp    message=PIM Cancellation feature deactivation wasn't successfull !
        ...  style=FAIL
    END

Verify PIM Counters And Return Length
  [Arguments]  ${counters}  ${bts_id}

  ${counters_list_string}  Evaluate  ','.join(${counters})

  ${pm_counters}=  Get Pm Counters  ${counters_list_string}  alias=${bts_id}
  ${pm_counters_string}  Convert To String  ${pm_counters}

  ${status_list}  Create List
  FOR  ${counter}  IN  @{counters}
      ${counter_status}=  Run Keyword And Return Status  Should Contain  ${pm_counters_string}  ${counter}
      Append To list  ${status_list}  ${counter_status}
  END

    IF  'False' in '${status_list}'
        Fail  Collected PM Counters don't contain expected counters !
    ELSE
        Logging With Timestamp
        ...  message=PM Counters M8086CX (x=1:32) was successfull collected!
        ...  style=DONE
    END

    ${pm_length}=  Get Length  ${pm_counters_string}

    [Return]  ${pm_length}

Check Interval
    [Arguments]  ${int}

    @{available_intervals}=  Create List  15  30  60  360  720  1440
    IF  '${int}' in ${available_intervals}
        Logging With Timestamp    message=Given interval ${int} is correct.
    ELSE
        Fail  Given interval ${int} does't meet condition. Allowed values 15 30 60 360 720 1440.
    END

Restore Reference Configuration
    [Arguments]    ${bts_id}
    Logging With Timestamp
    ...  message=Restoring reference configuration, please wait!
    ...  style=ONGOING

    admin.Perform Parameter Recommissioning  ${RMOD_CONFIG_DISTNAME}  actPimCancellation  update
    ...  ${REFERENCE_PARAMS_DICT[0]['parameters']['actPimCancellation']}  alias=${bts_id}
    ...  skip_parameter_relation_errors=True
    admin.Perform Parameter Recommissioning  ${RMOD_CONFIG_DISTNAME}  pimCancellingEnabled  update
    ...  ${REFERENCE_PARAMS_DICT[0]['parameters']['pimCancellingEnabled']}  alias=${bts_id}
    ...  skip_parameter_relation_errors=True
    admin.Perform Parameter Recommissioning  ${OBJECT_MTPIMCANCELLATION}  mtPIMCancellation  update  disabled  alias=${bts_id}
    ...  skip_parameter_relation_errors=True
