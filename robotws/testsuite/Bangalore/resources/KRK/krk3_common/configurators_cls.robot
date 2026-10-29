*** Settings ***
Documentation
...            Keywords for modifying and uploading configuration files
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Library     Collections
Library     taf.sbts.oam.coam.admin     WITH NAME    coam_admin
Resource    configurators.robot
Resource    remote_cls.robot
Resource    cell_operations_cls.robot

*** Keywords ***
Testline Readiness Check
    [Documentation]    Runs suite of checks to determine TL readiness for running tests.
    Check GNB and AP Backhaul Links
    ${egate_running}    Check If Egate Is Running
    Should Not Be True    ${egate_running}
    ...    msg=Hanging egate process detected. Stop the process before running test suite.
    Check If MCShark Is Installed

Check GNB and AP Backhaul Links
    [Documentation]    Checks ping to GNB and AP Backhaul.
    ${gnb_bh_ip}    Set Variable    10.0.1.2
    ${ap_bh_ip}     Set Variable    10.0.2.80
    Log to Console    Waiting for GNB backhaul link...    no_newline=${True}
    Wait Until Process Succeeds    ping    -c    1    ${gnb_bh_ip}    timeout=120s
    ...    msg=Timeout waiting for ping to GNB backhaul (${gnb_bh_ip}).
    Log To Console    OK
    Log to Console    Waiting for AP backhaul link...    no_newline=${True}
    Wait Until Process Succeeds    ping    -c    1    ${ap_bh_ip}    timeout=120s
    ...    msg=Timeout waiting for ping to AP backhaul (${ap_bh_ip}).
    Log To Console    OK

Upload Configs
    [Documentation]    Uploads IPHY, SCF or Delta configuration files and adds RnD flags for CLASSICAL deployment
    ...                and reboots GNB/AP if required. Adds IP Addresses to local interfaces.
    ...                Supports user flag ``skip:config`` for skipping configuration upload.
    ...                - ``config``: Dictionary with paths to configuration files and IP address list.\
    ...                Valid items: iphy, scf, delta, rnd_gnb, ip_addr, skip_parameter_relation_errors, wait_for_state
    ...                - ``log_dir``: Path to log directory, Default: ``$\{OUTPUT DIR\}/Logs/``
    ...                - ``forced_reboot``: Forced reboot after config upload, Default: no
    ...                Example:
    ...                | robot -v skip:config test_suite.robot
    [Arguments]    ${config}    ${log_dir}=${OUTPUT DIR}/Logs/    ${forced_reboot}=no
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${config}) is dict    msg=Invalid KW parameter: config
    Should Contain Any    ${config}    iphy    scf    delta    rnd_gnb    ip_addr
    ...    msg=Config dictionary does not contain any valid item: iphy, scf, delta, rnd_gnb, ip_addr
    Should Be True    '${forced_reboot}' in ('yes','no')    msg=Invalid KW parameter: forced_reboot
    Should Be True    '${forced_reboot}' in ('yes','no')    msg=Invalid KW parameter: forced_reboot
    Run Keyword If    'wait_for_state' in ${config}    Should Be True
    ...    '${config.wait_for_state}' in ('Configured','Enabled','Locked')    msg=Invalid config parameter: wait_for_state
    #---------------------------------------------------------------------------------------------------------------
    ${local_skip}    Get Variable Value    ${skip}
    ${skip_config}    Set Variable If    'config' in '${local_skip}'    ${True}    ${False}
    ${skip_errors}    Get Variable Value    ${config.skip_parameter_relation_errors}    no
    Run Keyword If    ${skip_config}    Run Keywords
    ...    Log to Console    Skipping configuration upload
    ...    AND    Return From Keyword
    ${reboot_required}    Set Variable If
    ...    'iphy' in ${config} or 'rnd_gnb' in ${config} or '${forced_reboot}' == 'yes'    ${True}    ${False}
    Run Keyword If    'ip_addr' in ${config}    Add IP Addresses To Local Interfaces    @{config.ip_addr}
    Run Keyword If    'iphy' in ${config}    Fix and Upload iphy    iphy=${config.iphy}
    Run Keyword If    'rnd_gnb' in ${config}    Add RnD Flags to GNB Swconfig
    ...    local_path=${log_dir}/swconfig_updated.txt    &{config.rnd_gnb}
    Run Keyword If    'scf' in ${config}    Fix and Upload SCF    scf=${config.scf}    skip_errors=${skip_errors}
    Run Keyword If    'scf' in ${config} and 'wait_for_state' in ${config}
    ...    Wait for All Cells to be in Correct State    state=${config.wait_for_state}    timeout=600
    ${scf_uploaded}    Set Variable If    'scf' in ${config}    ${True}    ${False}
    ${result}    Run Keyword If    isinstance(${config}.get('delta'), list)
    ...    Combine Delta JSONs and Upload    @{config.delta}
    ...    local_path=${log_dir}/full_delta.json    skip_errors=${skip_errors}
    ...    ELSE IF    isinstance(${config}.get('delta'), str)
    ...    Upload Delta    delta=${config.delta}    skip_errors=${skip_errors}
    ${reboot_from_scf}    Set Variable If    'scf' in ${config}    ${True}    ${False}
    ${reboot_from_delta}    Set Variable If    'delta' in ${config}
    ...    ${result}[commissioningResult][isGoingToTriggerReset]    ${False}
    ${reboot_done}    Run Keyword If    ${reboot_required} and not ${reboot_from_scf} and not ${reboot_from_delta}
    ...    Reboot GNB and AP
    Run Keyword If    'wait_for_state' in ${config} and (${reboot_done} or 'delta' in ${config})
    ...    Wait for All Cells to be in Correct State    state=${config.wait_for_state}    timeout=600

Fix and Upload SCF
    [Documentation]    Aligns SCF file with correct VLAN ID and sends full commissioning to GNB in CLASSICAL deployment.
    ...                Returns commissioning result dictionary. Relation errors are printed to log.html
    ...                - ``scf``: Pathfile to scf.xml
    ...                - ``skip_errors``: Skip parameter relation errors, Default: no
    ...                - ``activate``: Activate plan after uploading SCF, Default: yes
    [Arguments]    ${scf}    ${skip_errors}=no    ${activate}=yes
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${skip_errors}' in ('yes','no')    msg=Invalid KW parameter: skip_errors
    Should Be True    '${activate}' in ('yes','no')    msg=Invalid KW parameter: activate
    #---------------------------------------------------------------------------------------------------------------
    ${skip_errors}    Set Variable If    '${skip_errors}' == 'yes'    ${True}    ${False}
    ${activate}    Set Variable If    '${activate}' == 'yes'    ${True}    ${False}
    File Should Exist    ${scf}
    Log to Console    Uploading new SCF: ${scf}
    ${scf_fixed_xml}    ta5g_commissioning.fix_vlan_id_in_scfc    input_filepath=${scf}
    ${connection}    coam_admin.setup_admin
    ${result}    coam_admin.perform_commissioning    bts_id=1    scf_file=${scf_fixed_xml}
    ...    connection=${connection}    skip_parameter_relation_errors=${skip_errors}    should_activate=${activate}
    ${test_name}    Get Variable Value    ${TEST NAME}
    ${prefix}    Set Variable If    '${test_name}' == 'None'    Suite Setup    ${test_name}
    ${relation_errors}    Set Variable    ${result}[validationResult][pdlValidationResult][logs][relationErrors]
    FOR    ${error}    IN    @{relation_errors}
      Log    ${prefix}: PDL validation relation error: ${error}    level=WARN
    END
    [Teardown]    coam_admin.teardown_admin    connection=${connection}
    [Return]    ${result}

Upload Delta
    [Documentation]    Sends JSON delta commissioning file to GNB in CLASSICAL deployment.
    ...                Returns commissioning result dictionary. Relation errors are printed to log.html
    ...                - ``delta``: Pathfile to delta.json
    ...                - ``skip_errors``: Skip parameter relation errors, Default: no
    ...                - ``activate``: Activate plan after uploading delta, Default: yes
    [Arguments]    ${delta}    ${skip_errors}=no    ${activate}=yes
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${skip_errors}' in ('yes','no')    msg=Invalid KW parameter: skip_errors
    Should Be True    '${activate}' in ('yes','no')    msg=Invalid KW parameter: activate
    #---------------------------------------------------------------------------------------------------------------
    ${skip_errors}    Set Variable If    '${skip_errors}' == 'yes'    ${True}    ${False}
    ${activate}    Set Variable If    '${activate}' == 'yes'    ${True}    ${False}
    File Should Exist    ${delta}
    Log to Console    Uploading new delta JSON: ${delta}
    ${connection}    coam_admin.setup_admin
    ${result}    coam_admin.perform_delta_recommissioning
    ...    delta_file=${delta}    connection=${connection}    skip_parameter_relation_errors=${skip_errors}
    ...    should_activate=${activate}
    ${test_name}    Get Variable Value    ${TEST NAME}
    ${prefix}    Set Variable If    '${test_name}' == 'None'    Suite Setup    ${test_name}
    ${relation_errors}    Set Variable    ${result}[validationResult][pdlValidationResult][logs][relationErrors]
    FOR    ${error}    IN    @{relation_errors}
      Log    ${prefix}: PDL validation relation error: ${error}    level=WARN
    END
    [Teardown]    coam_admin.teardown_admin    connection=${connection}
    [Return]    ${result}

Combine Delta JSONs and Upload
    [Documentation]    Combines multiple JSON files into one delta and uploads to GNB in CLASSICAL deployment.
    ...                Returns commissioning result dictionary. Relation errors are printed to log.html
    ...                - ``files``: List of JSON files
    ...                - ``local_path``: Path to new combined file, Default: /tmp/delta.json
    ...                - ``skip_errors``: Skip parameter relation errors, Default: no
    ...                - ``activate``: Activate plan after uploading delta, Default: yes
    [Arguments]    @{files}    ${local_path}=/tmp/delta.json    ${skip_errors}=no    ${activate}=yes
    #--------- Param check -----------------------------------------------------------------------------------------
    ${match}    ${dir}    ${file}    Should Match Regexp    ${local_path}    ^(.*/)([^/]+\\.json)$
    ...    msg=Invalid KW parameter: local_path
    Should Be True    '${skip_errors}' in ('yes','no')    msg=Invalid KW parameter: skip_errors
    Should Be True    '${activate}' in ('yes','no')    msg=Invalid KW parameter: activate
    #---------------------------------------------------------------------------------------------------------------
    Create Directory    ${dir}
    ${new}    Create List
    FOR    ${file}    IN    @{files}
      Log to Console    Combining delta file: ${file}
      ${json}    Get JSON File Content    filepath=${file}
      ${new}    Combine Lists    ${new}    ${json}
    END
    Save Data as JSON File    data=${new}    filepath=${local_path}
    ${result}    Upload Delta    delta=${local_path}    skip_errors=${skip_errors}    activate=${activate}
    [Return]    ${result}

Activate Uploaded Plan
    [Documentation]    Activates previously uploaded commissioning plan (SCF or Delta) if it's waiting for activation.
    ...                - ``plan_id``: ID of plan, Location: [commissioningResult][deltaDn] of upload result dictionary
    [Arguments]    ${plan_id}
    ${connection}    coam_admin.setup_admin
    ${result}    coam_admin.activate_plan    plan_id=${plan_id}
    [Teardown]    coam_admin.teardown_admin    connection=${connection}
    [Return]    ${result}

Reboot GNB and AP
    [Documentation]    Reboots GNB via COAM Reset Site operation triggering AP reboot in parallel.
    Log to Console    Rebooting GNB and AP via COAM
    ${connection}    coam_admin.setup_admin
    coam_admin.reset_site    connection=${connection}
    [Teardown]    coam_admin.teardown_admin    connection=${connection}
    [Return]    ${True}

Change NIDD Parameter Online
    [Documentation]    Updates NIDD parameter in GNB via COAM.
    ...                - ``dist``: NIDD object dist name
    ...                - ``param``: NIDD parameter name in the object
    ...                - ``value``: NIDD parameter value
    ...                Example:
    ...                | Change NIDD Parameter Online | dist=MRBTS-1/NRBTS-1/NRCELL-1 | param=maxNumOfRrcSA | value=5 |
    [Arguments]    ${dist}    ${param}    ${value}
    Log to Console    Changing parameter [${param}] at dist [${dist}] to value [${value}]
    ta5g_commissioning.perform_parameter_commissioning    parameter=${param}    value=${value}    dist_name=${dist}
    Sleep    3s    Wait for activation to complete to avoid starting procedures too early

Add RnD Flags to GNB Swconfig
    [Documentation]    Downloads swconfig.txt file from GNB, appends new flags, uploads it back to GNB
    ...                and crasigns it. GNB tolerates multiple declarations of the same flag but it will use
    ...                only the last value in the file.
    ...                - ``local_path``: Path where file will be downloaded and modified, Default: /tmp/swconfig.txt
    ...                - ``flags``: RnD flags as dictionary items
    ...                Example:
    ...                | Add RnD Flags to GNB Swconfig | 0x580001=1 | 0x450027=1 |
    [Arguments]    ${local_path}=/tmp/swconfig.txt    &{flags}
    #--------- Param check -----------------------------------------------------------------------------------------
    ${match}    ${dir}    ${file}    Should Match Regexp    ${local_path}    ^(.*/)([^/]+\\.txt)$
    ...    msg=Invalid KW parameter: local_path
    #---------------------------------------------------------------------------------------------------------------
    ${remote_path}    Set Variable    /ffs/run/swconfig.txt
    Create Directory    ${dir}
    Download File from GNB    remote_path=${remote_path}    local_path=${local_path}
    FOR    ${flag}    IN    @{flags}
      Should Match Regexp    ${flag}    ^0x[0-9A-Fa-f]+$    msg=Invalid format of RnD flag: ${flag}
      Log to Console    Appending RnD flag: ${flag}\=${flags}[${flag}]
      Append To File    ${local_path}    ${flag}\=${flags}[${flag}]${\n}
    END
    Upload File to GNB    remote_path=${remote_path}    local_path=${local_path}
    Log to Console    Performing crasign/craverify on swconfig.txt
    ${output}    Execute Command on GNB    command=crasign ${remote_path} && craverify ${remote_path} ${remote_path}.p7
    Should Contain    ${output}    good signature    msg=Failed to crasign/craverify ${remote_path}
