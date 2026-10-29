*** Settings ***
Documentation
...    author: Agnieszka Bylica
...    contact: agnieszka.bylica@nokia.com
...    Generic Robot keywords for OAM 5G.


Library     taf.gnb.oam.commissioning           WITH NAME  commissioning
Library     taf.config.scf                      WITH NAME  scf
Library     ${CURDIR}/../python/keywords/OAM5G_keywords.py
Library     ${CURDIR}/../python/keywords/AirScaleGnb_keywords.py
Library     ${CURDIR}/../python/keywords/Selenium_keywords.py
Library     ${CURDIR}/../python/keywords/AsiMgr_keywords.py
Resource    ${CURDIR}/AirScaleGnb_keywords.robot
Resource    ${CURDIR}/AsiMgr_keywords.robot
Resource    ${CURDIR}/Hub_keywords.robot


*** Keywords ***

Enable actAsi flag
    [Documentation]    Enable the actAsi parameter in downloaded commissioning file and then perform commissioning.
    Download Current Commissioning File
    Set the actAsi param to True
    ${container_id} =    Wait Until Keyword Succeeds    5x    60s    AirScale.Get Asi Container Id
    Wait For Container To Get Up    name=${container_id}

Disable actAsi flag
    [Documentation]    Disable the actAsi parameter in downloaded commissioning file and then perform commissioning.
    Download Current Commissioning File
    Set the actAsi param to False
    Download Current Commissioning File
    Check Value Of Param    file_path=${current_commissioning_local_path}    param_name=actAsi    should_be=False

Download Current Commissioning File
    ${current_commissioning_local_path} =    RestAPI.Get Current Commissioning    log_dir=${SCF FILE LOCAL PATH}
    ...                                      scf_name=${SCF FILENAME}
    Set Test Variable    ${current_commissioning_local_path}

Set the actAsi param to True
    Check Value Of Param    file_path=${current_commissioning_local_path}    param_name=actAsi    should_be=False
    AirScale.Set actAsi To True    scf_dir=${config_dir}    current_scf_name=Current_SCF_enable.xml
    ...  modify_scf_name=Modify_SCF_enable.xml

Set the actAsi param to False
    Check Value Of Param    file_path=${current_commissioning_local_path}    param_name=actAsi    should_be=True
    AirScale.Set actAsi To False    scf_dir=${config_dir}    current_scf_name=Current_SCF_disable.xml
    ...  modify_scf_name=Modify_SCF_disable.xml

Check Value Of Param
    [Documentation]  Check value of parameter in the commissioning file.
    ...              Value should be equal to given should_be argument.
    [Arguments]    ${file_path}    ${param_name}    ${should_be}

    scf.Load Scf    file_path=${file_path}
    ${param_value} =    scf.Get Value From Scf    p_name=${param_name}
    Should Be Equal    ${should_be}    ${param_value}

Check no alarms present
    Check Alarms On Asimgr
    Check Active Alarms On Gnb

Check only allowed alarms present
    Check Active Alarms On Gnb   allowed_alarms=${allowed_alarms_list}
    Wait Until Keyword Succeeds  6x  20s  Check Alarms On Asimgr    allowed_alarms=${allowed_alarms_list_asimgr}

Check required alarms present
    Run Keyword And Continue On Failure    Check Active Alarms On Gnb    allowed_alarms=${allowed_alarms_list}
    ...                                    required_alarms=${required_alarms_list}
    Check Alarms On Asimgr    allowed_alarms=${allowed_alarms_list_asimgr}
    ...    required_alarms=${required_alarms_list_asimgr}

Check only allowed alarms present for disabled actAsi
    Check Active Alarms On Gnb   allowed_alarms=${allowed_alarms_list_no_x2_link}

Verify gNB Cells setup
    [Documentation]    Check all cells status in WebUI is online.
    ...                To do: check cells status in journalctl.
    Check All Cells Status    expected_status=online

Verify gNB not onAir
    ${status} =    Wait for onAir    raise_error=${false}
    Should Not Be True    ${status}    msg=gNB is onAir

Verify gNB Cells are down
    Check All Cells Status    expected_status=offline

Verify RF
    Wait Until Keyword Succeeds    5 min    30 sec    Check Rf Status Is  ${true}

Check Rf Status Is
    [Arguments]  ${expected_status}
    ${status}=    Check Rf Status    raise_error=${false}
    Should Be Equal      ${expected_status}    ${status}

Check Hub And Antennas Are Visible
    [Arguments]    ${expected_antennas_nr}=${expected_number_of_antennas}  ${number_of_hubs}=${1}
    AsiMgr_keywords.check_hub_and_antennas_visibility    expected_antennas_nr=${expected_antennas_nr}   number_of_hubs=${number_of_hubs}
    Check_if_antennas_detected_on_hubs    antennas_dict=${expected_antennas_dict}
