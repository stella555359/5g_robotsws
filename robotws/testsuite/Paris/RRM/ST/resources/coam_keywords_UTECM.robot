*** Settings ***
Documentation
...     keywords for coam testing

Library        taf.gnb.oam.coam.admin     WITH NAME    coam


*** Keywords ***
Check Cell on air
    [Documentation]     Checks that BTS is on air. Requires prior connection to WebUI.
    [Arguments]         ${BTS_Path}

    ${bts_status}=  coam.get_bts_statuses  connection=coa_coam_admin
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir


Wait for BTS to be operational
    [Documentation]     Wait for BTS to reboot and cell to be on air
    [Arguments]         ${BTS_Path}     ${WEBUI_URL}
    ...                 ${WEBUI_NAME}=Nemuadmin   ${WEBUI_PWD}=nemuuser
    ...                 ${timeout}=10 min

    coam.connect_to  bts_host=${COAM_ADMIN_IP}  bts_port=${COAM_ADMIN_PORT}
    ...  username=${COAM_ADMIN_username}  password=${COAM_ADMIN_password}  use_ssl=True  update_interval=5000
    ...  admin_api_log_dir=${PATH_Storage}  name=coa_coam_admin

    wait until Keyword Succeeds     ${timeout}  30 s    Check Cell On Air   ${BTS_Path}

    coam.teardown  connection=coa_coam_admin
