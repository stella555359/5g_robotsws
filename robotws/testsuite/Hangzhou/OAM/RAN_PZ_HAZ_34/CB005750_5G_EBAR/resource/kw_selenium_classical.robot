#-----------------------------------------------------------------------

Documentation
...    author: Zhu felix
...    contact: felix.zhu@nokia-sbell.com
...    Feature 5G_CB005750 in 5G21A program
#
# File: kw_selenium_classical.robot
#
# Set of keywords related to 5gNB-DU WebEM.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
*** Settings ***
#-----------------------------------------------------------------------

# WARNING: assume that robot and TAF libraries are loaded in caller.


#-----------------------------------------------------------------------
*** Variables ***
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
*** Keywords ***
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# RELATED TO SCF.
#-----------------------------------------------------------------------

Backup DU SCF via DU WebEM
    [Arguments]
    ...    ${du_scf_path}
    ...    ${du_webem_url}=${DU_WEBEM_URL}
    ...    ${du_webem_username}=${DU_WEBEM_USERNAME}
    ...    ${du_webem_password}=${DU_WEBEM_PASSWORD}

    ${scf_file_path}=    sel.save_scf_file
    ...    url=${du_webem_url}
    ...    username=${du_webem_username}
    ...    password=${du_webem_password}

    file should exist    ${scf_file_path}    msg=Cannot save_bts_configuration!

    ${du_scf_path}=    OperatingSystem.Copy File    ${scf_file_path}    ${du_scf_path}
    set suite variable    ${du_scf_path}
    log to console    \n....... - du_scf_path = ${du_scf_path}


Restore DU SCF via DU WebEM
    [Arguments]
    ...    ${du_scf_path}
    ...    ${du_webem_url}=${DU_WEBEM_URL}
    ...    ${du_webem_username}=${DU_WEBEM_USERNAME}
    ...    ${du_webem_password}=${DU_WEBEM_PASSWORD}

    ${passed}=    sel.perform_commissioning    ${du_scf_path}
    log to console    \n....... - passed = ${passed}
    should be true    ${passed}


Import DU SCF via DU WebEM
    [Arguments]
    ...    ${du_scf_path}
    ...    ${du_webem_url}=${DU_WEBEM_URL}
    ...    ${du_webem_username}=${DU_WEBEM_USERNAME}
    ...    ${du_webem_password}=${DU_WEBEM_PASSWORD}

    ${passed}=    sel.perform_commissioning    ${du_scf_path}
    log to console    \n....... - passed = ${passed}
    should be true    ${passed}


#-----------------------------------------------------------------------
# RELATED TO EQUIPMENT STATUS.
#-----------------------------------------------------------------------

Open session
    [Arguments]
    ...     ${url}
    ...     ${username}
    ...     ${password}

    ${passed}=    sel.open_session    ${url}    ${username}    ${password}
    should be true    ${passed}    DU WebEM [${url}] is not accessible!


Close session
    sel.close_session


Check DU status via DU WebEM
    ${status}=    sel.get_bts_status
    puts    - status = ${status}
    should be equal as strings    ${status}    On air    ignore_case=${True}


Check SMOD status via DU WebEM
    ${status}=    sel.is_smod_operational
    puts    - status = ${status}
    should be true    ${status}    SMOD is not operational!


Check BBMOD status via DU WebEM
    ${status}=    sel.is_bbmod_operational
    puts    - status = ${status}
    should be true    ${status}    BBMOD is not operational!


Check RU status via DU WebEM
    ${status}=    sel.is_ru_operational
    puts    - status = ${status}
    should be true    ${status}    RU is not operational!


Check GNSS status via DU WebEM
    ${status}=    sel.is_gnss_operational
    puts    - status = ${status}
    should be true    ${status}    GNSS is not operational!


Check Cell onAir via DU WebEM
    [Arguments]
    ...    ${cell_index}=${1}

    ${status}=    sel.is_cell_on_air    ${cell_index}
    puts    - status = ${status}
    should be true    ${status}    CELL ${cell_index} is not on air!


#-----------------------------end-of-file-------------------------------
