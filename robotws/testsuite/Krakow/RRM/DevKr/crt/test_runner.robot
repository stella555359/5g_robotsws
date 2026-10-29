*** Settings ***
Force Tags    PY36    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Library     Process
Library     Collections
Library     parse_run_log.py
Library     sparse_checkout.py


*** Test Cases ***
Run All no run test on reserved testline
    [Timeout]       13h
    set logging path        ${OUTPUT_DIR}
    Run all tests

*** Keywords ***
Run all tests
    sparse_checkout_if_repo_dont_exist
    Run process              cd /home/ute/MN/UTE/robotlte/ && git pull origin master	   
    ...    shell=yes
    ...    timeout=20min
    ${user}                  get variable value      ${user}                               ${None}
    ${ca}                    get variable value      ${ca}                                 ${None}
    ${org}                   get variable value      ${org}                                ${None}
    ${condition}=       Evaluate
    ...                 '${user}' != 'None' or '${ca}' != 'None' or '${org}' != 'None'
    should be equal         ${condition}        ${TRUE}
    ...                     At least one variable must be provided: user or ca or org
    ${filter}                   get variable value      ${filter}                          ${None}
    ${branch}                   get variable value      ${branch}                          SBTS00
    ${tl_type}                  get variable value      ${tl-type}                         ${None}
    ${technology}               get variable value      ${technology}                      5G
    ${from-dir}                 get variable value      ${from-dir}                        ${None}
    ${on-build}                 get variable value      ${on-build}                        ${None}
    ${test-branch}              get variable value      ${test-branch}                     ${None}
    ${package-version}          get variable value      ${package-version}                 ${None}
    ${timeout}                  get variable value      ${timeout}                         770min
    ${failing-prs}              get variable value      ${failing-prs}                     ${None}
    ${variables}                get variable value      ${variables}                       ${None}
    ${swconfig-flags}           get variable value      ${swconfig-flags}                  ${None}
    ${test-object}              get variable value      ${test-object}                     ${None}
    ${test-options}             get variable value      ${test-options}                    ${None}
    ${test-entity}              get variable value      ${test-entity}                     ${None}
    ${hw-id}                    get variable value      ${hw-id}                           ${None}
    ${upgrade-to}               get variable value      ${upgrade-to}                      ${None}
    ${variant}                  get variable value      ${variant}                         ${None}
    ${param1}                   get variable value      ${param1}                          ${None}
    ${param2}                   get variable value      ${param2}                          ${None}
    ${param3}                   get variable value      ${param3}                          ${None}
    ${test-lab-path}            get variable value      ${test-lab-path}                   ${None}

    ${arguments}=       Create list
    ...                 --robot-log-dir     ${OUTPUT_DIR}
    ...                 --on-build          robot:${on-build}
    ...                 --user              robot:${user}
    ...                 --ca                robot:${ca}
    ...                 --org               robot:${org}
    ...                 --filter            robot:${filter}
    ...                 --branch            robot:${branch}
    ...                 --tl-type           robot:${tl_type}
    ...                 --from-dir          robot:${from-dir}
    ...                 --technology        robot:${technology}
    ...                 --failing-prs       robot:${failing-prs}
    ...                 --test-branch       robot:${test-branch}
    ...                 --package-version   robot:${package-version}
    ...                 --variables         robot:${variables}
    ...                 --swconfig-flags    robot:${swconfig-flags}
    ...                 --test-object       robot:${test-object}
    ...                 --test-options      robot:${test-options}
    ...                 --test-entity       robot:${test-entity}
    ...                 --hw-id             robot:${hw-id}
    ...                 --upgrade-to        robot:${upgrade-to}
    ...                 --variant           robot:${variant}
    ...                 --param1            robot:${param1}
    ...                 --param2            robot:${param2}
    ...                 --param3            robot:${param3}
    ...                 --test-lab-path     robot:${test-lab-path}




    ${no_value_arguments_names}=        Create list
    ...                                 no-run
    ...                                 blocked
    ...                                 closed-prs
    ...                                 skip-time-limit
    ...                                 cdrt-type
    ...                                 dry-run
    ...                                 no-run-from-last-sprint
    ...                                 suspended
    ...                                 not-suspended

    FOR     ${no_value_arg_name}        IN    @{no_value_arguments_names}
        ${var_value}            get variable value      ${${no_value_arg_name}}         ${EMPTY}
        Set test variable       ${${no_value_arg_name}}    ${var_value}
        ...
    END

    FOR     ${no_value_arg_name}        IN    @{no_value_arguments_names}
        append to list     ${arguments}     ${${no_value_arg_name}}
    END

    remove values from list         ${arguments}        ${EMPTY}

    run process         python    /home/ute/MN/UTE/robotlte/resources/DevKr/norun_exec.py
    ...                 @{arguments}
    ...                 timeout=${timeout}
    ...                 stdout=${OUTPUT_DIR}/norun_std.txt
    ...                 stderr=${OUTPUT_DIR}/norun_err.txt

    parse_run_log
