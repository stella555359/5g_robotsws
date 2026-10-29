*** Settings ***
Documentation    This is common keywords for siso related case steps used in team
...              Please do not modify the file without notification to author

Library    Collections
Library    OperatingSystem
Library    DateTime
Library    String
Library    taf.hw.rf_attenuator    WITH NAME    att

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_csn.robot

*** Variables ***
${value_new}      16.0
${value_org}      15.0

*** Keywords ***
Modify AUTONOMOUS Value In Json File AQQL
    [Arguments]    ${init_value}    ${target_value}    ${file_cmd}    ${ru_index}=1
    log to console    \n Modify AUTONOMOUS Value In Json File
    csn.connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${cmd}   Set Variable  echo "/ action create ConfigAccess /ca /module"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable
    ...    echo '/ca action fetch DECODED "hw_capabilities.bin" "/tmp/hw_capabilities.json"'|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable  sed -i '139{s/"defaultValue": ${init_value},/"defaultValue": ${target_value},/g}' /tmp/hw_capabilities.json
    csn.send_command    command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${output}  csn.execute  command=cat /tmp/hw_capabilities.json| head -n 139 | tail -n +138   connection=RU_${ru_index}
    sleep    2s
    log to console    \n ${output}
    csn.Send command    command=${file_cmd} /mnt/runtime/runtime_config.txt    connection=RU_${ru_index}
    sleep    2s
    ${output}  csn.execute  command=ls -l /mnt/runtime/runtime_config.txt   connection=RU_${ru_index}
    sleep    2s
    log to console    \n ${output}
    ${cmd}   Set Variable
    ...    echo '/ca action store PERMANENT DECODED "hw_capabilities.bin" "/tmp/hw_capabilities.json"'|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable  echo "/ca action update"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    csn.disconnect    connection=RU_${ru_index}
    csn.disconnect    connection=ASIK Master
    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
    sleep    120s
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'

## PA keyword


Setup The attenuator
    [Documentation]
    ...    2022/5/17 Liu Shasha: add documentation.
    ...    Example:
    ...    HBTE_Attenuator_test
    ...    Setup The attenuator    atten_vendor=HBTE
    ...    ${lines}    Get dictionary keys     ${tl.attenuator.attenuator_ports}
    ...    FOR    ${line}    IN    @{lines}
    ...         Read The attenuation    line=${line}
    ...         Sleep   1s
    ...    END
    ...    Set The attenuation    lines=${lines}    value=${value_new}
    ...    Sleep   1s
    ...    FOR    ${line}    IN    @{lines}
    ...         Read The attenuation    line=${line}
    ...         Sleep   1s
    ...    END
    ...    Set The attenuation    lines=${lines}    value=${value_org}
    ...    Sleep   1s
    ...    FOR    ${line}    IN    @{lines}
    ...         Read The attenuation    line=${line}
    ...         Sleep   1s
    ...    END#
    [Arguments]    ${atten_ip}=${tl.attenuator.ip_addr}
    ...            ${att_api_port}=${tl.attenuator.port}
    ...            ${atten_ports}=${tl.attenuator.attenuator_ports}
    ...            ${max_attenuation_value}=${127}
    ...            ${atten_vendor}=${tl.attenuator.__class__.__name__}
    ...            ${atten_model}=${tl.attenuator.model}
    att.Setup attenuator
    ...    ip_addr=${atten_ip}
    ...    port=${att_api_port}
    ...    attenuation_port_numbers=${atten_ports}
    ...    max_attenuation=${max_attenuation_value}
    ...    vendor=${atten_vendor}
    ...    model=${atten_model}

Read The attenuation
    [Arguments]      ${line}
    ${value_port}    att.Read attenuation    port=${${line}}
    [Return]   ${value_port}

Set The attenuation
    [Arguments]      ${lines}    ${value}
    FOR    ${line}    IN    @{lines}
        att.Set attenuation     port=${${line}}     value=${${value}}
    END

Set the attenuation and check
    [Arguments]      ${lines}    ${value}
    FOR    ${line}    IN    @{lines}
        att.Set attenuation     port=${${line}}     value=${${value}}
        ${value_port}    att.Read attenuation    port=${${line}}
        Should be equal    ${value_port}    ${${value}}
    END

Interval the attenuation
    [Arguments]      ${lines}    ${attenuation}=strengthen    ${min}=0    ${max}=90
    ...              ${alias}=TopYoung      ${interval_time}=0.2
    ${add_or_sub}    Set variable if    '${attenuation}'=='strengthen'    1    -1
    ${value}    Set variable if    '${attenuation}'=='strengthen'    ${min}    ${max}
    FOR    ${iteration}    IN RANGE    ${min}    ${max}
        ${value}    Evaluate    ${value}+${add_or_sub}
        Set The attenuation     lines=${lines}    value=${${value}}
        Sleep    ${interval_time}
    END

Turn off the attenuation
    ${lines}    Get dictionary keys     ${tl.attenuator.attenuator_ports}
    Set the attenuation and check    lines=${lines}    value=${0}
