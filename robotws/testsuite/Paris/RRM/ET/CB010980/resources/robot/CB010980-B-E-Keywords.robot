*** Settings ***
Documentation     [SUITE PURPOSE]  Keywords of CB010980-B-E
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : axel.gouilly-frossard@nokia.com
...               Creation Date               : 19-09-2025
...               Modified Date               : 19-09-2025
...               Last Modified by            : axel.gouilly-frossard@nokia.com
...               Version   Date      Author                                 Notes
...               0.1       FB2519    axel.gouilly-frossard@nokia.com             Creation


Library                 taf.sbts.oam.coam.admin        WITH NAME    sbts_coam
Library                 ../../../../../resources/SWENG/python/CoamParameter.py    WITH NAME    coam_parameter


*** Variables ***

${BLER_KPI}             ${CURDIR}/../../Config/CB010980_PMQAP.csv
${DTX_KPI}              ${CURDIR}/../../Config/CB010980_DTXSpec.csv
${egatelogoutput}       ${True}
${gp_duration}                       300





*** Keywords ***

CB010980 Setup With Custom Config
    [Documentation]
    ...     Actions:     Apply customized configuration then launch cell setup.
    ...     Parameters:  SCF: customized SCF
    ...                  CFG: customized basic CFG file
    ...                  IPHY: airphone iphy file
    ...                  rdParam: list of RAD parameters
    ...                  vendorParam: list of vendor parameters
    ...     Return:      None
    [Arguments]              ${SCF}    ${CFG}=${EMPTY}    ${IPHY}=${EMPTY}
    ...                      ${rdParam}=@{EMPTY}    ${vendorParam}=@{EMPTY}

    Apply Custom Config
    ...      scfc=${SCF}
    ...      cfg=${CFG}
    ...      iphy=${IPHY}
    ...      rad_params=@{rdParam}
    ...      vendor_params=@{vendorParam}



TC CB010980-PMQAP
    [Documentation]
    [Arguments]
    Init Sequence            "CB010980_B_PMQAP"
    Critical Step            CB010980 Cell Setup
    Critical Step            CB010980 LaunchTraffic
    Traced Sleep              duration=5s                      msg=DL traffic started ...

    # In order to have the same KPIs/counters for every run, it's needed to start test step at the
    # beginning of the next PM period. So, the script wait for the beginning of the next GP to before starting
    # the test. This should allow to have the same KPIs over every runs.
    ${zoi}                      ZOI Start                               gp=${gp_duration}
    ${zoi_end_remain}=          ZOI Remaining Sec                       ${zoi}
    ${start_loop_remaining}=    Evaluate                                ${zoi_end_remain} - ${gp_duration}
    Traced Sleep                ${start_loop_remaining} seconds         msg=Waiting ${start_loop_remaining} seconds before starting next step

    Dated Log                  === Waiting for end of ZOI
    ZOI Wait End               zoi=${zoi}

    # KPIs and counters checks
    ${pm_path}      Counters.Collect PM files from BTS    ${LOG_PATH}/PM
    Run Keyword And Continue On Failure
    ...                             KPI Evaluate    pmFile=${pm_path}
    ...                             constraintsFile=${BLER_KPI}
    ...                             failOnError=${True}
    ...                             usePMQAP=${True}

    Step                     Oam.OAM Get Snapshot
    # Step                     GenericTest.Display Diagnosis
    [Teardown]               CB010980 End Of TC


TC CB010980-SpecDTX
    [Documentation]
    [Arguments]
    Init Sequence            "CB010980_E_SpecDTX"
    Critical Step            CB010980 Cell Setup
    Critical Step            CB010980 LaunchTrafficDTX
    Traced Sleep              duration=5s                      msg=DL traffic started ...

    # In order to have the same KPIs/counters for every run, it's needed to start test step at the
    # beginning of the next PM period. So, the script wait for the beginning of the next GP to before starting
    # the test. This should allow to have the same KPIs over every runs.
    ${zoi}                      ZOI Start                               gp=${gp_duration}
    ${zoi_end_remain}=          ZOI Remaining Sec                       ${zoi}
    ${start_loop_remaining}=    Evaluate                                ${zoi_end_remain} - ${gp_duration}
    Traced Sleep                ${start_loop_remaining} seconds         msg=Waiting ${start_loop_remaining} seconds before starting next step

    Dated Log                  === Waiting for end of ZOI
    ZOI Wait End               zoi=${zoi}

    ${zoi}                      ZOI Start                               gp=${gp_duration}
    ${zoi_end_remain}=          ZOI Remaining Sec                       ${zoi}
    ${start_loop_remaining}=    Evaluate                                ${zoi_end_remain} - ${gp_duration}
    Traced Sleep                ${start_loop_remaining} seconds         msg=Waiting ${start_loop_remaining} seconds before starting next step

    Dated Log                  === Waiting for end of ZOI
    ZOI Wait End               zoi=${zoi}
    # KPIs and counters checks
    ${pm_path}      Counters.Collect PM files from BTS    ${LOG_PATH}/PM
    Step            Run Keyword And Continue On Failure
     ...                             KPI Evaluate    pmFile=${pm_path}
     ...                             constraintsFile=${DTX_KPI}
     ...                             failOnError=${True}


    Step                     Oam.OAM Get Snapshot
    # Step                     GenericTest.Display Diagnosis
    [Teardown]               CB010980 End Of TC





CB010980 Cell Setup
    [Documentation]
    ...         Actions : Launch basic setup file and X2 setup
    ...         Params :  none
    ...         Return :  none
    [Arguments]
    Setup Wtsemu SA          shouldUseLua=False
    sleep    10s
    WTS Set X2 Link
    sleep    5s

CB010980 LaunchTraffic
    [Documentation]
    ...         Actions : Launch basic traffic
    ...         Params :  none
    ...         Return :  none
    [Arguments]
    CB010980_run_script_once     ${CURDIR}/../../Config/CustomCFG/UE1.sce
    CB010980_run_script_once     ${CURDIR}/../../Config/CustomCFG/UE2.sce
    CB010980_run_script_once     ${CURDIR}/../../Config/CustomCFG/UE101.sce
    CB010980_run_script_once     ${CURDIR}/../../Config/CustomCFG/UE102.sce

CB010980 LaunchTrafficDTX
    [Documentation]
    ...         Actions : Launch basic traffic with DTX
    ...         Params :  none
    ...         Return :  none
    [Arguments]
    CB010980_run_script_once     ${CURDIR}/../../Config/CustomCFG/UE1-bler.sce


CB010980_run_script_once
    [Documentation]        This KW start on egate command a script file=<path><file.sce> to perform egate commande
    ...                    recorded on a .sce file

    [Arguments]                    ${script_path_name}
    Dated Log                      Script sce used: ${script_path_name}

    wtsemu.script                  file=${script_path_name}
    ${output}                      wtsemu.read_wtsemu_output_until    PROCESSING    20
    Run Keyword If                ${egatelogoutput}    Dated Log                  output:${output}
    ${output}                      wtsemu.read_wtsemu_output_until_prompt    5
    Run Keyword If                ${egatelogoutput}    Dated Log                  output:${output}
    ${script_status}               wait until keyword succeeds    12hours    1s    CB010980_is_script_finished
    ${error_in_status}=            Run Keyword And Return Status    Should Contain    ${script_status}    error
    Dated Log                      output:${error_in_status}


CB010980_is_script_finished
    [Documentation]        This KW is a part of CB010980_run_script_once

    wtsemu.script_status
    ${output}                      wtsemu.read_wtsemu_output_until    Status of script    5
    Run Keyword If                ${egatelogoutput}    Dated Log                  output:${output}
    ${script_status}               wtsemu.read_wtsemu_output_until_prompt    5
    # ${log_string}          remove string using regexp    ${script_status}    (=|-| {6,}|\n)
    # ${log_string}          replace string   ${log_string}    description    description${\n}${SPACE}
    # ${log_string}          catenate    Script status:${\n}    ${log_string}
    # Dated Log              ${log_string}    first=True
    should not match regexp        ${script_status}    ( active | paused )
    [Return]

CB010980_Configuration_SCF_Delta
    [Documentation]               Dedicated KW to add use a delta commissioning file
    ...                           to configure the 2 cells with canadian PLMN n77 extended and several BWP

    [Arguments]                   ${10980_delta_file}     ${gnb_alias}

    # Open connection towards cOAM
    sbts_coam.connect_to          name=${gnb_alias}

    Dated Log New Line            delta_file=${10980_delta_file}
    # Apply delta scf
    coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${10980_delta_file}
    ...                           connection=${gnb_alias}

    OAM wait available
    sbts_coam.teardown            connection=${gnb_alias}

CB010980 End Of TC
   [Documentation]        At the end of each TC :
   ...                      - show the Diagnosis of the TC steps
   ...                      - collect the gnb Snapshot
   ...                      - if TC failed, collect also AP sosReport

   Dated Log              End Of TC :  add produce scout data ...
   # Oam.OAM Get Snapshot
   # Run Keyword If Test Failed     Setup.Get Sos Report
   GenericTest.Display Diagnosis
   Setup.Produce Scout Data

