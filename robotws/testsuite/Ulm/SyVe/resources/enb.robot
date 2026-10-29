*** Settings ***

Documentation     Keywords related to gNB handling
...               author: Vasileios Papoutsis
...               email: vasileios.papoutsis@nokia.com

Library    ta_attenuator
Library    OperatingSystem
Library    String
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    python_libs/enb.py         WITH NAME    enb

Resource  ../../resources/Common/connect.robot
Resource  ../../resources/Common/gnb.robot

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
        Wait for Node state    target_proceduralState=${state}    node_type=enb   node_id=${enb_id}   timeout=${timeout}
    END

Perform eNB reboot
    [Documentation]    :Author: Vasileios Papoutsis
    ...     Reboot of eNB via OAM
    ...
    ...     :param enb_id: (default=0) Id/Number of eNB to be reboot
    ...
    [Arguments]    ${enb_id}=${0}
    Log    Reboot of eNB${enb_id} triggered    console=${P_console}
    ${enb_ssh_alias}=    Set variable    enb${enb_id}
    admin.connect_to    bts_host=${tl.enbs[${enb_id}].oam_ip.v4}

    ${wait_for_reconnection}=    Set Variable If
    ...   ${tl.enbs != None} and ${{ "${tl.enbs[${enb_id}].system_module.common_units[0].hardware_type}" in ['FSMF'] }}
    ...   ${False}   ${True}
    admin.reset_site    wait_for_reconnection=${wait_for_reconnection}    connection=${enb_ssh_alias}
    IF   ${wait_for_reconnection} == ${False}
        Sleep   60 sec    reason=waiting time after reboot trigger before checking for ping reply
        Wait Until Keyword succeeds    4 min    30 sec    Pass if Host is Pingable And Fail Otherwise
        ...   ${tl.enbs[${enb_id}].system_module.common_units[0].lmp_connection.addr}
    END

    Log    Reboot of eNB${enb_id} finished!    console=${P_console}
    [TearDown]  admin.teardown    connection=${enb_ssh_alias}


Pass if Host is Pingable And Fail Otherwise
    [Documentation]  This keyword returns 'pass' if given host is pingable and fails otherwise.
    ...     :param host_ip: ip of the host to be pinged
    ...   | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]    ${host_ip}
    ${rc}=    Run and return rc    ping ${host_ip} -w 1
    IF    ${rc} != ${0}    Fail    Host IP ${host_ip} is not pingable


Wait for all eNB states
    [Documentation]    :Author: Soenke Kullberg
    ...     Waits until all eNB airscale are in state (configured||commissioned||OnAir)
    ...
    ...     :param state: (default=configured||commissioned||OnAir) State which is needed to be reached
    ...     :param timeout: (default=10 min) Time until state must be reached
    ...
    [Arguments]    ${target_proceduralState}=configured||commissioned||onair   ${timeout}=10 min
    ${enb_num}=    Get length    ${tl.enbs}
    FOR    ${enb}    IN RANGE    ${enb_num}
        Wait for Node state     node_type=enb  node_id=${enb}  target_proceduralState=${target_proceduralState}  timeout=${timeout}
    END


Get SCF from eNB
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...     :param enb_id: (default=0) Id/Number of eNB
    ...
    ...     :return:   scf path for further usage
    ...
    [Arguments]    ${enb_id}=${0}    ${resultDir}=${EMPTY}  ${with_auto_configured_parameters}=${True}
    ${enbScfName}=    Set variable    SCFC_eNB${enb_id}.xml
    Set Suite Variable    ${private_enbScfName${enb_id}}    ${enbScfName}
    ${resultConfigDir}=    IF    '${resultDir}'=='${EMPTY}'    Get Test Suite Config Directory
    ...    ELSE    Set Variable    ${resultDir}
    ${enb_ssh_alias}=    Set variable    enb${enb_id}
    ${enb_ssh_alias}   connect.Setup OAM Http session   node_type=enb   node_id=${enb_id}
    admin.get_current_scf_file    ${resultConfigDir}
    ...                           ${enbScfName}
    ...                           timeout=${20}
    ...                           connection=${enb_ssh_alias}
    ...                           with_auto_configured_parameters=${with_auto_configured_parameters}

    admin.teardown    connection=${enb_ssh_alias}
    RETURN    ${resultConfigDir}/${enbScfName}


Get MNC length from eNB SCF
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${enb_id}=${0}
    ${enb_ssh_alias}=    Set variable    enb${enb_id}
    admin.connect_to    bts_host=${tl.enbs[${enb_id}].system_module.common_units[0].lmp_connection.addr}
    ...    name=${enb_ssh_alias}
    ${scf_content}=    admin.get_scf    parameters_save_variant=actualValues
    ...                                 timeout=${60}
    ...                                 connection=${enb_ssh_alias}
    ...                                 with_auto_configured_parameters=${True}

    ${mnc_length}=    enb.get_mnc_length_from_scf    scf_content=${scf_content}
    admin.teardown    connection=${enb_ssh_alias}
    RETURN    ${mnc_length}


Verify on board SW Version
    [Documentation]    :Author: Amr Aboushehata
    ...    [PRIVATE]    Check if eNB is updated to expected version
    [Arguments]    ${exp_version}    ${enb_id}=0    ${comu_id}=0
    ${ssh_alias}=    connect.Connect to Node Common Unit   node_type=enb    node_id=${enb_id}    comu_id=${comu_id}
    ${xml_element}=    Set Variable If    'SBTS' in '${exp_version}'    softwareReleaseVersionFlexiRel3    cbtsSoftwareReleaseVersion
    ${enb_version}=    testline.Get Common Unit SW Version    alias=${ssh_alias}    xml_element=${xml_element}
    Should Contain    ${enb_version}    ${exp_version}    msg=SW update Failed!


### Private ###
