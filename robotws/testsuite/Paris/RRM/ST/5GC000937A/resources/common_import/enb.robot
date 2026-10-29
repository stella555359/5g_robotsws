*** Settings ***

Documentation     Keywords related to gNB handling
...               author: Vasileios Papoutsis
...               email: vasileios.papoutsis@nokia.com

Library    ta_attenuator
Library    OperatingSystem
Library    String
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    ./python/enb.py           WITH NAME   enb
Resource   ./connect.robot

*** Variables ***
${P_console}         ${False}

*** Keywords ***

Reset all eNBs and wait for state
    [Documentation]    :Author: Vasileios Papoutsis
    ...     Reset eNB via OAM intraface and waits until eNB airscale is in state configured||commissioned again
    ...
    ...     :param state: (default=configured||commissioned) State which is needed to be reached
    ...     :param timeout: (default=10 min) Time until state must be reached
    ...
    [Arguments]    ${state}=configured||commissioned    ${timeout}=10 min
    ${enb_num}=    Get length    ${tl.enbs}
    FOR    ${enb_id}    IN RANGE    ${enb_num}
        Perform eNB reboot    enb_id=${enb_id}
        Wait for eNB state    target_proceduralState=${state}    enb_id=${enb_id}   timeout=${timeout}
    END

Perform eNB reboot
    [Documentation]    :Author: Vasileios Papoutsis
    ...     Reboot of eNB via OAM
    ...
    ...     :param enb_id: (default=0) Id/Number of eNB to be reboot
    ...
    [Arguments]    ${enb_id}=${0}
    BuiltIn.Log    Reboot of eNB${enb_id} triggered    console=${P_console}
    ${enb_ssh_alias}=    Set variable    enb${enb_id}
    admin.connect_to    bts_host=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr}
    ...    name=${enb_ssh_alias}
    admin.reset_site    wait_for_reconnection=${True}    connection=${enb_ssh_alias}
    ${rc}=    Run and return rc    ping ${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr} -w 10
    Should be equal as numbers    first=${0}    second=${rc}
    BuiltIn.Log    Reboot of eNB${enb_id} finished!    console=${P_console}
    [TearDown]  admin.teardown    connection=${enb_ssh_alias}


Wait for all eNB states
    [Documentation]    :Author: Soenke Kullberg
    ...     Waits until all eNB airscale are in state (configured||commissioned)
    ...
    ...     :param state: (default=configured||commissioned) State which is needed to be reached
    ...     :param timeout: (default=10 min) Time until state must be reached
    ...
    [Arguments]    ${target_proceduralState}=configured||commissioned   ${timeout}=10 min
    ${enb_num}=    Get length    ${tl.enb}
    FOR    ${enb}    IN RANGE    ${enb_num}
        Wait for eNB state     enb_id=${enb}     target_proceduralState=${target_proceduralState}     timeout=${timeout}
    END

Wait for eNB state
    [Documentation]    :Author: Vasileios Papoutsis
    ...     Waits until eNB airscale is in state (configured||commissioned)
    ...
    ...     :param state: (default=configured||commissioned) State which is needed to be reached
    ...     :param enb_id: (default=0)  Id/Number of eNB
    ...     :param timeout: (default=10 min) Time until state must be reached
    ...
    [Arguments]    ${target_proceduralState}=configured||commissioned    ${enb_id}=${0}    ${timeout}=10 min
    BuiltIn.Log    Wait for eNB${enb_id} state ${target_proceduralState}    console=${P_console}
    ${enb_ssh_alias}=    Set variable    enb${enb_id}
    admin.connect_to    bts_host=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr}    name=${enb_ssh_alias}
    Wait until keyword succeeds     ${timeout}  5 sec    Check matching pattern in eNB state
    ...    enb_ssh_alias=${enb_ssh_alias}
    ...    target_proceduralState=${target_proceduralState}
    BuiltIn.Log    eNB${enb_id} state is ${target_proceduralState}!    console=${P_console}
    [TearDown]  admin.teardown    connection=${enb_ssh_alias}


Get SCF from eNB
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...     :param enb_id: (default=0) Id/Number of eNB
    ...
    ...     :return:   scf path for further usage
    ...
    [Arguments]    ${enb_id}=${0}    ${resultDir}=${EMPTY}
    ${enbScfName}=    Set variable    SCFC_eNB${enb_id}.xml
    Set Suite Variable    ${private_enbScfName${enb_id}}    ${enbScfName}
    ${resultConfigDir}=    Run keyword if    '${resultDir}'=='${EMPTY}'    Get Test Suite Config Directory
    ...    ELSE    Set Variable    ${resultDir}
    ${enb_ssh_alias}=    Set variable    enb${enb_id}
    admin.connect_to    bts_host=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr}
    ...    name=${enb_ssh_alias}
    admin.get_current_scf_file    ${resultConfigDir}    ${enbScfName}    timeout=${10}    connection=${enb_ssh_alias}
    admin.teardown    connection=${enb_ssh_alias}
    [Return]    ${resultConfigDir}/${enbScfName}


Get MNC length from eNB SCF
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${enb_id}=${0}
    ${enb_ssh_alias}=    Set variable    enb${enb_id}
    admin.connect_to    bts_host=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr}
    ...    name=${enb_ssh_alias}
    ${scf_content}=    admin.get_scf  parameters_save_variant=actualValues    timeout=${60}    connection=${enb_ssh_alias}
    ${mnc_length}=    enb.get_mnc_length_from_scf    scf_content=${scf_content}
    admin.teardown    connection=${enb_ssh_alias}
    [Return]    ${mnc_length}


Verify on board SW Version
    [Documentation]    :Author: Amr Aboushehata
    ...    [PRIVATE]    Check if eNB is updated to expected version
    [Arguments]    ${exp_version}    ${enb_id}=0    ${du_id}=0    ${comu_id}=0
    ${asik_alias}=    connect.Connect to eNB Common Unit    enb_id=${enb_id}    du_id=${du_id}    comu_id=${comu_id}
    ${xml_element}=    Set Variable If    'SBTS' in '${exp_version}'    softwareReleaseVersionFlexiRel3    cbtsSoftwareReleaseVersion
    ${enb_version}=    testline.Get Common Unit SW Version    alias=${asik_alias}    xml_element=${xml_element}
    Should Contain    ${enb_version}    ${exp_version}    msg=SW update Failed!


### Private ###
Check matching pattern in eNB state
    [Documentation]    [PRIVATE]
    ...     :Author: Vasileios Papoutsis
    [Arguments]    ${enb_ssh_alias}    ${target_proceduralState}
    ${enbBtsInfo}=    admin.get_bts_info    connection=${enb_ssh_alias}
    ${current_proceduralState}=    Set Variable    ${enbBtsInfo['status']['proceduralState']}
    ${matches}=    Get regexp matches    ${current_proceduralState}    ${target_proceduralState}
    ${length}=    Get length    ${matches}
    Should be True    '${length}'!='${0}'    Fail
