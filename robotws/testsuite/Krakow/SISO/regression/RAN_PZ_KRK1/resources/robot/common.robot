*** Settings ***
Documentation
...   Resource file implemented for the feature RJIO CB012524 and CNI-130230 - contains common keywords
...   maintainer: Agnieszka Bylica
...   contact: agnieszka.bylica@nokia.com


Library     ../python/common.py
Library     ../python/ru_matrix.py
Library     ../python/tput_table_generator.py
Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK1.resources.python.sfp.SFP    WITH NAME    sfp


*** Keywords ***
Reset RU and wait for Online
    [Arguments]    ${ru}
    gnbru.Reset Radio Unit From GUI    radio_unit_id=${ru}
    ${start_time}    Save Current Time
    gnbru.wait_for_radio_unit_statuses    ru_id=${ru}
    ...                                   availability_status=offline
    ...                                   operational_state=disabled
    ...                                   interval=${5}
    Wait Until Keyword Succeeds    360    60    gnbru.verify_all_radio_units_are_online
    Sleep    60s    reason=Waiting for uptime info update
    Verify Ru Uptime               ru_id=${ru}    start_time=${start_time}

Lock Unlock RU and Verify Statuses
    [Arguments]    ${ru_id}
    gnb_rus.Lock Radio Unit From GUI      radio_unit_id=${ru_id}
    Wait Until Keyword Succeeds    60    10    gnb_rus.Verify Radio Unit Is Locked    radio_unit_id=${ru_id}    radio_type=rmod
    Wait Until Keyword Succeeds    60    10    Verify All Cells Statuses From Given Locked RU    ru_id=${ru_id}
    gnb_rus.Unlock Radio Unit From GUI    radio_unit_id=${ru_id}
    Wait Until Keyword Succeeds    60    10    gnb_rus.Verify Radio Unit Is Unlocked  radio_unit_id=${ru_id}    radio_type=rmod
    Wait Until Keyword Succeeds    60    10    gnbcell.Verify All Cells Are onAir

Verify the HW is in correct state
    gnbbbu.verify_statuses_on_fsm

Lock Unlock All Lanes One by One
    [Documentation]    author: Julia Luszcz
    ...                contact: julia.luszcz@nokia.com
    [Arguments]    ${lanes_dict}
    FOR  ${key}    IN    @{lanes_dict.keys()}
        gnbscf.Change Parameter                     dist_name=${lanes_dict}[${key}][dist_name]
        ...                                         parameter=${lanes_dict}[${key}][parameter]
        ...                                         value=${lanes_dict}[${key}][value]
        gnbscf.Activate Plan
        Wait Until Keyword Succeeds       600 sec    15 sec   Check Alarms And Affected Cells
        ...                                         wanted_fid=${lanes_dict}[${key}][alarm]
        ...                                         affected_cells=${lanes_dict}[${key}][affected_cells]
        gnbscf.Verify Parameter After Change        dist_name=${lanes_dict}[${key}][dist_name]
        ...                                         parameter=${lanes_dict}[${key}][parameter]
        ...                                         value=${lanes_dict}[${key}][verification_value]
        #Unlock
        gnbscf.Change Parameter                     dist_name=${lanes_dict}[${key}][dist_name]
        ...                                         parameter=${lanes_dict}[${key}][parameter]
        ...                                         value=${lanes_dict}[${key}][return_value]
        gnbscf.Activate Plan
        Wait Until Keyword Succeeds       600 sec    30 sec    gnbcell.Verify All Cells Are Onair
        gnbscf.Verify Parameter After Change        dist_name=${lanes_dict}[${key}][dist_name]
        ...                                         parameter=${lanes_dict}[${key}][parameter]
        ...                                         value=${lanes_dict}[${key}][return_verification_value]
    END

Modify Linkspeed in Loop
    [Documentation]    author: Julia Luszcz
    ...                contact: julia.luszcz@nokia.com
    [Arguments]    ${linkspeed_parameters}      ${max_linkspeed}    ${iterations}=${20}
    FOR  ${iter}    IN RANGE    ${iterations}
        gnbscf.Change Parameter                     dist_name=${linkspeed_parameters}[dist_name]
        ...                                         parameter=${linkspeed_parameters}[parameter]
        ...                                         value=${linkspeed_parameters}[value]
        gnbscf.Activate Plan
        Wait Until Keyword Succeeds       300 sec    15 sec   Check Alarms And Affected Cells
        ...                                         wanted_fid=${linkspeed_parameters}[alarm]
        ...                                         affected_cells=${linkspeed_parameters}[affected_cells]
        gnbscf.Verify Parameter After Change        dist_name=${linkspeed_parameters}[dist_name]
        ...                                         parameter=${linkspeed_parameters}[parameter]
        ...                                         value=${linkspeed_parameters}[verification_value]
        gnbscf.Change Parameter                     dist_name=${linkspeed_parameters}[dist_name]
        ...                                         parameter=${linkspeed_parameters}[parameter]
        ...                                         value=${linkspeed_parameters}[return_value]
        gnbscf.Activate Plan
        Wait Until Keyword Succeeds       600 sec    30 sec    gnbcell.Verify All Cells Are Onair
        gnbscf.Verify Parameter After Change        dist_name=${linkspeed_parameters}[dist_name]
        ...                                         parameter=${linkspeed_parameters}[parameter]
        ...                                         value=${linkspeed_parameters}[return_verification_value]
        gnbscf.Verify Parameter After Change        dist_name=${max_linkspeed}[dist_name]
        ...                                         parameter=${max_linkspeed}[parameter]
        ...                                         value=${max_linkspeed}[return_value]
    END

Configure Redundant Link and Switch between Two links in Loop
    [Documentation]    author: Julia Luszcz
    ...                contact: julia.luszcz@nokia.com
    [Arguments]    ${cablink_parameters}    ${iterations}=${20}
    FOR  ${iter}    IN RANGE    ${iterations}
        sfp.Create Cablink Instance                instance_id=7
        ...                                        cablink_params=${cablink_parameters}[7]
#        ...                                        activate=False          #    not implemented
        sfp.Delete Cablink Instance                instance_id=6
        ...                                        ethif_id=${cablink_parameters}[6][ethIfId]
        Wait Until Keyword Succeeds        600 sec    30 sec    gnbcell.Verify All Cells Are Onair
        sfp.Create Cablink Instance                instance_id=6
        ...                                        cablink_params=${cablink_parameters}[6]
#        ...                                        activate=False        #    not implemented
        sfp.Delete Cablink Instance                instance_id=7
        ...                                        ethif_id=${cablink_parameters}[7][ethIfId]
        Wait Until Keyword Succeeds        600 sec    30 sec    gnbcell.Verify All Cells Are Onair
    END

Reconfigure DL MIMO Mode 8x4
    [Documentation]    Reconfigures the downlink MIMO mode for specified cells. This keyword uses a delta template to apply the configuration changes.
    ...                **Arguments:**
    ...                - ${operation}:  Either 'enable' or 'disable', specifying the desired operation.
    ...                - ${delta_template}: A dictionary containing templates for enabling and disabling 8x4 DL MIMO.
    ...                - ${nrcellids}: A list of strings representing the IDs of the cells to be reconfigured, ex: ['0', '1']
    ...                **Return Value:**  'Success' if the operation completes successfully, otherwise an error message.
    ...                author: Radoslaw Serafin
    ...                contact: radoslaw.serafin@nokia.com
    [Arguments]    ${operation}    ${delta_template}    ${nrcellids}
    ${delta}=    Prepare_delta_reconfiguring_dl_mimo_mode    delta_dlmimomode_template=${delta_template}
    ...    operation=${operation}    nrcellids_to_reconfiguring_dlmimomode=${nrcellids}
    Run Keyword If    '${operation}' == 'disable'      gnbscf.perform_bts_delta_commissioning    delta=${delta}
    Run Keyword If    '${operation}' == 'enable'      gnbscf.perform_bts_delta_commissioning    delta=${delta}
    Wait Until Keyword Succeeds        600 sec    30 sec    gnbcell.Verify All Cells Are Onair
