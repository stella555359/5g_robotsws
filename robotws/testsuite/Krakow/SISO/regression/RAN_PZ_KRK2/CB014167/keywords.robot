*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    Maintainer: Piotr Wajda, piotr.wajda@nokia.com
...    CB014167


Library    SSHLibrary
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME    gnb_ru
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    CellOp
Library    testsuite/Krakow/SISO/regression/RAN_PZ_KRK2/CB014167/resources.py    WITH NAME    BBox
Library      testsuite.Krakow.resources.RAN_VRF_KRK3.SFP.sfp_helper.SfpHelper               WITH NAME   sfp_helper
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    variables.py


*** Variables ***
${BTS_ADDRESS}=    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${BTS_PORT}=       ${tl.gnbs[0].cu.oam_http_connection_details.port}
${USE_SSL}=        True


*** Keywords ***
Set SFPs HW for test
    Run Keyword If  "${BTS_ID}"=="85088"    Set SFPs list for BTS-88

Set SFPs list for BTS-88
    Set Suite Variable      @{sfps_hw_BBMOD}    FR242407250
    Set Suite Variable      @{sfps_hw_RMOD}     FR223614355

Check SFP
     FOR    ${ru}    IN    @{RU_PASS}
        Gather IP Set Variables    ${ru}[id]    ${ru}[sn]    ${ru}[password]    ${ru}[user]
        ${sfp_webem}=    sfp_helper.get_SFP_data_for_RMOD
        ${sfp_webem_filtered}=    Bbox.filtering_sfp_info    ${sfp_webem}
        ${sfp_bbox}=    Get SFP From Blackbox    ${COMMAND_SFP}    ${ru}[console_prompt]
        ${sfp_bbox_filtered}=    Bbox.filtering_bbox_sfp_info    ${sfp_bbox}
        Bbox.sfp_webem_bbox_comparison  ${sfp_webem_filtered}    ${sfp_bbox_filtered}
    END

Get SFP From Blackbox
    [Arguments]    ${command}    ${ru_prompt}
    Log to Ru    ${ru_prompt}
    SSHLibrary.write    ${command}
    ${output}=    SSHLibrary.read_until    Item type: CommonList
    [Return]    ${output}

Wait For All Cells To Be Operating Correctly
    Wait Until Keyword Succeeds    5 min    15 sec    CellOp.verify_all_cells_are_onair

Get Version From Blackbox Log
    [Arguments]    ${command}    ${bts_release}    ${ru_prompt}
    Log to RU    ${ru_prompt}
    SSHLibrary.Write    ${command}
    ${output}=    SSHLibrary.read_until    ${BLACKBOX_VERSION}[${bts_release}]
    ${output}=    Bbox.last_line  ${output}
    [Return]    ${output}

Get Histogram From Blackbox Log
    [Arguments]    ${command}    ${ru_prompt}
    Log to RU    ${ru_prompt}
    SSHLibrary.Write    ${command}
    ${output}=    SSHLibrary.read_until   Item type: POST_results
    ${output}=    Bbox.histogram_check  ${output}
    [Return]    ${output}

Check Reset
    FOR    ${ru}    IN    @{RU_PASS}
        Gather IP Set Variables    ${ru}[id]    ${ru}[sn]    ${ru}[password]    ${ru}[user]
        ${actual}=    Get Last Reset From Blackbox    ${COMMAND_RESET}    ${ru}[console_prompt]
        SSHLibrary.close_all_connections
        gnb_ru.reset_radio_unit
        ...    radio_unit_id=${ru}[id]
        gnb_ru.wait_for_radio_unit_to_be_online
        ...    ru_id=${ru}[id]
        Sleep    600s
        ${actual2}=    Get Last Reset From Blackbox    ${COMMAND_RESET}    ${ru}[console_prompt]
        Should Not Be Equal    ${actual}  ${actual2}
    END
    Wait For All Cells To Be Operating Correctly

Get Last Reset From Blackbox
    [Arguments]    ${command}    ${ru_prompt}
    Log to Ru    ${ru_prompt}
    SSHLibrary.write    ${command}
    ${output}=    SSHLibrary.read_until    ---
    ${output}=    Bbox.reset_check  ${output}
    [Return]    ${output}


Check Histogram
    FOR    ${ru}    IN    @{RU_PASS}
        Gather IP Set Variables    ${ru}[id]    ${ru}[sn]    ${ru}[password]    ${ru}[user]
        ${actual}=    Get Histogram From Blackbox Log    ${COMMAND_HIST}    ${ru}[console_prompt]
        SSHLibrary.close_all_connections
        gnb_ru.reset_radio_unit
        ...    radio_unit_id=${ru}[id]
        gnb_ru.wait_for_radio_unit_to_be_online
        ...    ru_id=${ru}[id]
        ${actual2}=    Get Histogram From Blackbox Log    ${COMMAND_HIST}    ${ru}[console_prompt]
        Bbox.check_found_hist  ${actual}  ${actual2}
    END
    Wait For All Cells To Be Operating Correctly



Compare Version
    ${bts_release}=    Get BTS SW release
    FOR    ${ru}    IN    @{RU_PASS}
        Gather IP Set Variables    ${ru}[id]    ${ru}[sn]    ${ru}[password]    ${ru}[user]
        ${actual}=    Get Version From Blackbox Log   ${COMMAND_VERSION}    ${bts_release}    ${ru}[console_prompt]
	    Should Be Equal    ${actual}    ${BLACKBOX_VERSION}[${bts_release}]
	END

Get BTS SW release
    admin.Setup Admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=get_sw_release
    ${bts_software_info}=    admin.Get Software Info    connection=get_sw_release
    ${bts_release}=    Extract Release From BTS Software Info    ${bts_software_info}
    admin.Teardown Admin    connection=get_sw_release
    [Return]    ${bts_release}

Gather All RUs IP addresses
    [Arguments]    ${serial_number}
    ${found_ip}=    gnb_ru.get_rmod_ip_address       serial_number=${serial_number}
    Set Test Variable    ${ru_ip}  ${found_ip}
    [Return]    ${found_ip}

Gather IP Set Variables
    [Arguments]    ${id_ru}    ${sn_ru}    ${password_ru}    ${user_ru}
    gnb_ru.wait_for_radio_unit_to_be_online
    ...    ru_id= ${id_ru}
    Set Test Variable    ${serial_number}    ${sn_ru}
    Set Test Variable    ${password}    ${password_ru}
    Set Test Variable    ${user}    ${user_ru}
    ${ru_ip}=    Gather All RUs IP addresses    ${serial_number}


Log to RU
    [Arguments]    ${ru_prompt}=#
    Connect To BTS
    Connect To HUB    ru_prompt=${ru_prompt}


Connect To BTS
    SSHLibrary.open_connection
    ...    host=${gnb_ip}
    SSHLibrary.login
    ...    username=${user_gnb}
    ...    password=${password_gnb}


Connect To HUB
    [Arguments]
    ...              ${user}=${user}
    ...              ${password}=${password}
    ...              ${ru_ip}=${ru_ip}
    ...              ${ru_prompt}=#
    SSHLibrary.write    text=lxc-attach -n 0x1018
    SSHLibrary.read_until    expected=root@FHNET00:~ >
    SSHLibrary.write    text=ssh-keygen -f /user/toor4nsn/.ssh/known_hosts -R "${ru_ip}"
    SSHLibrary.write    text=ssh ${user}@${ru_ip}
    ${continue}=    Run keyword and return status
    ...    SSHLibrary.read_until    expected=(yes/no/[fingerprint])?
    IF    '${user}' == 'serviceuser'
        Run keyword if    ${continue}    SSHLibrary.Write    text=yes
        ...    ELSE          SSHLibrary.Write    text=wrong_password
        SSHLibrary.read_until    expected=password:
        SSHLibrary.write    text=${password}
    ELSE IF     '${user}' == 'root'
        Run keyword if    ${continue}    SSHLibrary.Write    text=yes
    END
    SSHLibrary.Read until    expected=${ru_prompt}

