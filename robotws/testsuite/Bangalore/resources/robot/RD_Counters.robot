*** Settings ***
Documentation      Common Keyword to get RD counters

*** Keywords ***
#****************************** Keywords for RD counters ***************************************
Collect RD Counters
    [Arguments]   ${gnb_id}=0   ${log_path_rd}=/tmp
    ${alias_gnb}       BuiltIn.Wait Until Keyword Succeeds    30    5
    ...               ssh.connect to    ${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...                      ${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                      ${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    ...                      alias=OAM-local-conn
    ${RD_counter_dir}=  Extract gz file  file_pattern=/tmp/RD.BTS-*.gz  log_path_rd=${log_path_rd}  connection=${alias_gnb}
    [Return]    ${RD_counter_dir}

Extract gz file
    [Documentation]    :Author: Jing Liang
    ...
    [Arguments]    ${file_pattern}   ${log_path_rd}    ${connection}
    ${target_dir_rd_counters}=    Set variable    ${log_path_rd}
    Set Suite Variable    ${target_dir_rd_counters}
    Create directory    ${target_dir_rd_counters}

    ${file_path}=    RD_Counters.Get File Path on Target    file_pattern=${file_pattern}    connection=${connection}
    ${KINFE_PACKAGE.folder}    ${KINFE_PACKAGE.filename}=    Split String From Right    ${file_path}    separator=/   max_split=1
    Set Test Variable    ${source_file}    /tmp/${KINFE_PACKAGE.filename}
    ssh.execute    gunzip -c ${source_file} > /tmp/RD.BTS_counters.xml    connection=${connection}
    ssh.Download File   /tmp/RD.BTS_counters.xml   ${target_dir_rd_counters}/RD.BTS_counters.xml    connection=${connection}
    [Return]    ${target_dir_rd_counters}

Get File Path on Target
    [Documentation]    :Author: Jing Liang
    ...    copied from /ebs/ftourlon/FRT/robotws/testsuite/Ulm/resources/Common/util.robot
    ...
    ...    :param file_pattern:  file location and pattern, e.g. /ffs/run/swpool/OAM/psconfig_*.txz
    ...    :param connection:  alias name
    ...
    ...    :returns file_path:
    [Arguments]    ${file_pattern}    ${connection}
    ${output}=    ssh.execute    ls ${file_pattern}    connection=${connection}
    ${file_path}=    Strip String    ${output}
    [Return]    ${file_path}

Get RD counter value
    [Documentation]   adapted from Get PM counter value:Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...
    ...        :param pm_files_location is the path to RD files
    ...        :param pi_id is the RD Counter Name e.g. NR_CELL_RF_COOL_MODE0_SAMPLES
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=RD.BTS*
    ${last_report}    Get From List   ${PM_report_dict_list}     -1
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Contain  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log    ${pi_id} value: ${pi_value}   console=${P_console}
    [Return]    ${pi_value}

Check RD counter value equal
    [Documentation]   adapted from Check PM counter value equal:Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is equal to a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to RD files
    ...        :param pi_id is the RD Counter Name e.g. NR_CELL_RF_COOL_MODE0_SAMPLES
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get RD counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    should be equal  ${pi_value}   ${expected_value}     RD Counter ${pi_id} expected to be == ${expected_value} but is ${pi_value}

Check RD counter value not equal
    [Documentation]   :Author: Vasileios Papoutsis
    ...        checks that the value of a counter in the last reporting period is equal to a given value
    ...
    ...        :param not_expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to RD files
    ...        :param pi_id is the RD Counter Name e.g. NR_CELL_RF_COOL_MODE0_SAMPLES
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${not_expected_value}   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get RD counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${not_expected_value}=   convert to integer    ${not_expected_value}
    should not be equal  ${pi_value}   ${not_expected_value}     RD Counter ${pi_id} expected to be != ${not_expected_value} but is ${pi_value}

Check RD counter value bigger than
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is bigger than a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to RD files
    ...        :param pi_id is the RD Counter Name e.g. NR_CELL_RF_COOL_MODE0_SAMPLES
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}    ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get RD counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    should be true  ${pi_value} > ${expected_value}     RD Counter ${pi_id} expected to be > ${expected_value} but is ${pi_value}

Check RD counter value equal or bigger than
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is equal or bigger than a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to RD files
    ...        :param pi_id is the RD Counter Name e.g. NR_CELL_RF_COOL_MODE0_SAMPLES
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get RD counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    should be true  ${pi_value} >= ${expected_value}     RD Counter ${pi_id} expected to be >= ${expected_value} but is ${pi_value}

Check RD counter value smaller than
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is smaller than a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to RD files
    ...        :param pi_id is the RD Counter Name e.g. NR_CELL_RF_COOL_MODE0_SAMPLES
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get RD counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    should be true  ${pi_value} < ${expected_value}     RD Counter ${pi_id} expected to be < ${expected_value} but is ${pi_value}


Check RD counter value equal or smaller than
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is equal or smaller than a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to RD files
    ...        :param pi_id is the RD Counter Name e.g. NR_CELL_RF_COOL_MODE0_SAMPLES
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get RD counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    should be true  ${pi_value} <= ${expected_value}     RD Counter ${pi_id} expected to be <= ${expected_value} but is ${pi_value}

Check RD counter value in range
    [Documentation]   :Author: Vasileios Papoutsis
    ...        checks that the value of a counter in the last reporting period is in range defined by a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to RD files
    ...        :param pi_id is the RD Counter Name e.g. NR_CELL_RF_COOL_MODE0_SAMPLES
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    ...        :param rel_tolerance is the relative tolerance of the expected value
    ...        :param abs_tolerance is the absolute tolerance of the expected value
    [Arguments]    ${expected_value}   ${pm_files_location}   ${pi_id}    ${moc}    ${abs_tolerance}=0    ${rel_tolerance}=0.05
    ${pi_value}=   Get RD counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    ${upper_value}=    Evaluate    ${expected_value} + ${expected_value} * ${rel_tolerance} + ${abs_tolerance}
    ${lower_value}=    Evaluate    ${expected_value} - ${expected_value} * ${rel_tolerance} - ${abs_tolerance}
    should be true  ${lower_value} <= ${pi_value} <= ${upper_value}
