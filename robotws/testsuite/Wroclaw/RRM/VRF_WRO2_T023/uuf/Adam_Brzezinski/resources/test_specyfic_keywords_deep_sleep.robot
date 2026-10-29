*** Settings ***
Documentation
...  Author:        Marcin Wolczynski
...  Contact:       marcin.wolczynski@nokia.com



Library         taf.sbts.oam.coam.admin                                                WITH NAME     coam
Library         taf.sw.reporting_portal
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/Adam_Brzezinski/resources/test_specific_keywords_deep_sleep.py


*** Variables ***
${5G_connection_allias}     gNB
${timeout}                 30min
${retry_interval}          15sec

*** Keywords ***

Check 5G deep sleep RU status after SCF upload
    [Arguments]
    ...    ${5g_radio_modules}
    ...    ${ru_status}
    ...    ${ru_serial}
    Wait Until Keyword Succeeds    ${timeout}    ${retry_interval}       Check 5G Deep Sleep RU Status RJIO     ${5g_Radio_modules}
    ...                                                                  ${ru_status}   ${ru_serial}

Check 5G Deep Sleep RU Status RJIO
    [Arguments]
    ...    ${5g_radio_modules}
    ...    ${ru_status}
    ...    ${ru_serial}

    Conect to gNB
    ${5g_bts_info}    coam.get_bts_info    60    ${5G_connection_allias}
    ${5g_ru_info}  Set Variable    ${5g_bts_info['radioModules']['rmod']}
     verify_deep_sleep_activation_RIJO   ${5g_Radio_modules}    ${ru_status}    ${ru_serial}    @{5g_ru_info}

Upload SCF for test
    upload_scf_UUF     Deep_sleep

Conect to gNB
    [Arguments]    ${connection}=gNB
    coam.connect to        bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
                  ...      username=${tl.gnbs[0].cu.oam_http_connection_details.username}
                  ...      password=${tl.gnbs[0].cu.oam_http_connection_details.password}
                  ...      name=${connection}


Deep Sleep Test case for RJIO
    Upload SCF for test
    Check 5G deep sleep RU status after SCF upload    AVQA        SLEEP       L1251400628
    change_of_parameter_to_trigger_DS
    Check 5G deep sleep RU status after SCF upload    AVQA        AWAKE       L1251400628
    Check 5G deep sleep RU status after SCF upload    AVQA        SLEEP       L1251400628
