*** Settings ***
Resource   Common.robot


*** Variables ***


*** Keywords ***
COAM WebEM SSH Get Release
    [Arguments]   ${ssh_ip}=${oam_addr}   ${ssh_username}=${oam_username}   ${ssh_password}=${oam_password}   ${connection}=ssh_release
    csn.Connect To   hostname=${ssh_ip}   username=${ssh_username}   password=${ssh_password}   alias=${connection}
    ${info}   csn.Execute   command=ls /ffs/run/TargetBD*xml   connection=${connection}
    ${release}   Set Variable   ${info.split('_')[1]}
    [Return]   ${release}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}


COAM WebEM Login
    Log To Console   COAM WebEM Login
    Run Keyword And Ignore Error   selenium_sbts.enable_virtual_display

    ${version}   COAM WebEM SSH Get Release

    selenium_sbts.login
    ...   url=https://${WEBUI_ADDR}
    ...   username=${WEBUI_USER}
    ...   password=${WEBUI_PASSWORD}
    ...   version=${version}

    Run Keyword And Ignore Error   selenium_sbts.disable_message_box
    Run Keyword And Ignore Error   selenium_sbts.disable_screen_lock

    ${exists}   selenium_sbts.start_up_view_window_exists
    Run Keyword If   ${exists}   selenium_sbts.close_start_up_view_window

    # Run Keyword And Ignore Error   selenium_sbts.continue_after_plug_and_play_modal_appear   timeout=${10}
    Log To Console   COAM WebEM Login Finished.


COAM WebEM Logout
    ${logout_status}   Run Keyword And Return Status   selenium_sbts.logout
    run keyword if  not ${logout_status}   Run Keyword And Ignore Error   selenium_sbts.close_browser
    Run Keyword And Ignore Error   selenium_sbts.disable_virtual_display


COAM ADMIN Check Cell Onair
    [Arguments]   ${connection}=COAM
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=${60}
    ${cell_info}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
    ...   Set Variable   ${bts_info['requestMessage']['cells']}
    ...   ELSE   Set Variable   ${bts_info['cells']}
    ${cell_list}   Get Dictionary Values   ${cell_info}
    ${cell_list}   Evaluate   [item for sublist in ${cell_list} for item in sublist]

    FOR   ${cell}   IN   @{cell_list}
        ${operationalState}         Get Variable Value   ${cell['status']['operationalState']}      N/A
        ${usageState}               Get Variable Value   ${cell['status']['usageState']}            N/A
        ${proceduralStatus}         Get Variable Value   ${cell['status']['proceduralStatus']}      N/A
        ${administrativeState}      Get Variable Value   ${cell['status']['administrativeState']}   N/A
        ${availabilityStatus}       Get Variable Value   ${cell['status']['availabilityStatus']}    N/A

        Run Keyword If   "${operationalState}"!="N/A"
        ...   Should Be Equal   ${operationalState.lower()}       enabled
        # # Sometimes usageState=Idle
        # Run Keyword If   "${usageState}"!="N/A"
        # ...   Should Be Equal   ${usageState.lower()}             active
        Run Keyword If   "${proceduralStatus}"!="N/A"
        ...   Should Be Equal   ${proceduralStatus.lower()}       configured
        Run Keyword If   "${administrativeState}"!="N/A"
        ...   Should Be Equal   ${administrativeState.lower()}    unlocked
        Run Keyword And Continue On Failure
        ...   Run Keyword If   "${availabilityStatus}"!="N/A"
        ...   Should Not Be Equal   ${availabilityStatus.lower()}   degraded
    END


Perform Golden SCF Commission
    ${TL_total}   Get Length   ${tl.gnbs}
    FOR   ${gNB}   IN RANGE   0   ${TL_total}
        CI_commssion.common commissioning   gnb_index=${gNB}
        Run Keyword And Continue On Failure   Check Golden SCF Validation Error   gNB=${gNB}
    END


Check Golden SCF Validation Error
     [Arguments]   ${gNB}
     ${connection}   Set Variable If    ${gNB}==0   GNB_OAM   GNB_OAM_${gNB}
     Connect to gnb coam via ssl   connection=${connection}   gnb_index=${gNB}
     ${Active_SW_version}   Get Active SW Version   connection=${connection}
     Set Suite Variable   ${Active_SW_version}
     ${Golden_SCF_Path}   Get Golden SCF Path    gnb_index=${gNB}
         ${error}   coam.validate_scf_online   scf_file=${Golden_SCF_Path}
     ...   validation_type=NIDD_AND_RELATIONS   skip_parameter_relation_errors=True    timeout=60   connection=${connection}
     Should Be Equal   ${error['requestMessage']['niddValidationResult']['status']}   OK
     Should Be Equal   ${error['requestMessage']['pdlValidationResult']['status']}   OK
     [Teardown]   run keyword and ignore error   COAM Teardown gnb connections    connection=${connection}
