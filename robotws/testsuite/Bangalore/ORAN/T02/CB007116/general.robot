*** Settings ***
Documentation
...    Author: palepu.ramesh@nokia.com
...    Maintainer: palepu.ramesh@nokia
...    Test Description: This test set is designed to verify proper displayed status of E2 link
...    Confluence link: link
...    Group in charge: I_MN_RAN_RD_VRF_BLR1_T02_FRONTLINERS_SQD_GMS <I_MN_RAN_RD_VRF_BLR1_T02_FRONTLINERS_SQD@internal.nsn.com>
...    References:
...    QualityCenter:
...    Sample execution: robot --variable CONFIGURATION:Bangalore.XXX -b debug.log -d /home/ute/results/
...    Review:
...    AC/REQ:

Resource    ./testsuite/Bangalore/ORAN/T02/CB007116/resources_CB007116_BOAM_ET/resources.robot
Library    BuiltIn
Library    ute_fsmaccess
Library    SeleniumLibrary
Library    Process
Library    DateTime
Library    Collections
Library    FtpLibrary
Library    OperatingSystem
Library    Screenshot
Library    String
Library    Telnet
Library    taf.sbts.oam.coam.admin
Library    taf.config.scf   WITH NAME  scf
Library    taf.sw.scout    WITH NAME    scout
Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions

Force Tags
...    STATE_CONFIGURED    CRT    QCD_MN_RAN    QCP_RAN_VRF
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS24R3    SBTS24R2    FL00
...    CA_BTS_OAM_PDZ    QCD_MN_RAN    QCP_RAN_VRF

*** Variables ***
&{[1][1.0]CB007116-5G-A_Changing_of_NRE2LINK_status_via_delta_recommissioning}    QC_ID_FL00=QC_31071
&{[1][2.0]CB007116-5G-A_Checking_visualization_of_NRNEARRTRIC_in_WebEM_when_NRE2LINK_is_properly_configured_and_connection_is_established}
...    QC_ID_FL00=QC_31072
&{[1][3.0]CB007116-5G-A_Checking_visualization_of_NRNEARRTRIC_in_WebEM_when_NRE2LINK_is_not_estabilished}    QC_ID_FL00=QC_31073
&{[1][4.0]CB007116-5G-A_Locking_and_unlocking_of_NRE2LINK}    QC_ID_FL00=QC_31075
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            False
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             False

*** Test Cases ***
[1][1.0]CB007116-5G-A_Changing_of_NRE2LINK_status_via_delta_recommissioning
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC01
    [Setup]    Run Keywords
    ...    resources.Test Preconditions CB007116
    [1][1.0]CB007116-5G-A_Changing_of_NRE2LINK_status_via_delta_recommissioning
    Sleep    120s
    FSM Access Open Connection
    FSM Access Get eNB HW Version And Set eNB Side
    FSM Access Get Active And Passive Enb Sw Versions
    Get BTS SW Active Release
    FSM Access Close Connection
    Sleep    120s
    [Teardown]    run keywords
    ...    Set QC_Tag
    ...    Test Postconditions CB007116
    ...    Link SCOUT SCF to Configuration ID for Reporting


[1][2.0]CB007116-5G-A_Checking_visualization_of_NRNEARRTRIC_in_WebEM_when_NRE2LINK_is_properly_configured_and_connection_is_established
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC02
    [Setup]    Run Keywords
    ...    resources.Test Preconditions CB007116
    [1][2.0]CB007116-5G-A_Checking_visualization_of_NRNEARRTRIC_in_WebEM_when_NRE2LINK_is_properly_configured_and_connection_is_established
    Sleep    120s
    FSM Access Open Connection
    FSM Access Get eNB HW Version And Set eNB Side
    FSM Access Get Active And Passive Enb Sw Versions
    Get BTS SW Active Release
    FSM Access Close Connection
    Sleep    120s
    [Teardown]    run keywords
    ...    Set QC_Tag
    ...    Test Postconditions CB007116
    ...    Link SCOUT SCF to Configuration ID for Reporting

[1][3.0]CB007116-5G-A_Checking_visualization_of_NRNEARRTRIC_in_WebEM_when_NRE2LINK_is_not_estabilished
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC03
    [Setup]    Run Keywords
    ...    resources.Test Preconditions CB007116
    [1][3.0]CB007116-5G-A_Checking_visualization_of_NRNEARRTRIC_in_WebEM_when_NRE2LINK_is_not_estabilished
    Sleep    120s
    FSM Access Open Connection
    FSM Access Get eNB HW Version And Set eNB Side
    FSM Access Get Active And Passive Enb Sw Versions
    Get BTS SW Active Release
    FSM Access Close Connection
    Sleep    120s
    [Teardown]    run keywords
    ...    Set QC_Tag
    ...    Test Postconditions CB007116
    ...    Link SCOUT SCF to Configuration ID for Reporting

[1][4.0]CB007116-5G-A_Locking_and_unlocking_of_NRE2LINK
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC04
    [Setup]    Run Keywords
    ...    resources.Test Preconditions CB007116
    [1][4.0]CB007116-5G-A_Locking_and_unlocking_of_NRE2LINK
    Sleep    120s
    FSM Access Open Connection
    FSM Access Get eNB HW Version And Set eNB Side
    FSM Access Get Active And Passive Enb Sw Versions
    Get BTS SW Active Release
    FSM Access Close Connection
    Sleep    120s
    [Teardown]    run keywords
    ...    Set QC_Tag
    ...    Test Postconditions CB007116
    ...    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
FSM Access Get eNB HW Version And Set eNB Side
    [Arguments]    ${alias}=fsm_access
    [Documentation]    Author:    artur.krolak@nokia.com
    FSM Access Get eNB HW Version    alias=${alias}
    FSM Access Set eNB Side    alias=${alias}

FSM Access Get eNB HW Version
    [Arguments]    ${alias}=fsm_access
    ${out_hw_version}=    Get Enb Hw Version    alias=${alias}
    Set Suite Variable    ${OUT_HW_VERSION}    ${out_hw_version}
    [Return]    ${out_hw_version}

FSM Access Get Enb Sw Version
    [Arguments]    ${partition}=active
    ...            ${alias}=fsm_access
    ${out_enb_sw}=    Get Enb Sw Version    partition=${partition}
    ...                                     alias=${alias}
    [Return]    ${out_enb_sw}

FSM Access Open Connection
    [Arguments]    ${alias}=fsm_access
    Setup Enb Fsm Access    alias=${alias}

FSM Access Close Connection
    [Arguments]    ${alias}=fsm_access
    Teardown Enb Fsm Access    alias=${alias}

FSM Access Get Active And Passive Enb Sw Versions
    ${out_enb_active_sw}=    FSM Access Get Acive Enb Sw Version
    [Return]    ${out_enb_active_sw}

FSM Access Get Acive Enb Sw Version
    ${out_enb_active_sw}=    FSM Access Get Enb Sw Version    partition=active
    Set Suite Variable    ${OUT_ENB_ACTIVE_SW}    ${out_enb_active_sw}
    [Return]    ${out_enb_active_sw}

FSM Access Set eNB Side
    [Arguments]    ${alias}=fsm_access
    ${out_bts_side}=    Execute Command On Enb    ddal -s ddal_sysinfo_module_get_domain_id 0| tail -c 2    alias=${alias}
    ${out_bts_side}=    Set Variable If    ('${out_bts_side}'=='1' or '${out_bts_side}'=='0')    1
    ...                                    ('${out_bts_side}'=='2')    4
    Set Suite Variable    ${OUT_BTS_SIDE}    ${out_bts_side}
    [Return]    ${out_bts_side}

Get BTS SW Active Release
    ${release}=    Fetch From Left    ${OUT_ENB_ACTIVE_SW}    _
    ${branch_check}=    Split string    ${OUT_ENB_ACTIVE_SW}     separator=_    max_split=3
    ${sw_release}=
    ...     Run Keyword If    "${branch_check[2]}"=="9999"    Set Variable    FL00
    ...     ELSE    Set Variable    ${release}
    Set Suite Variable    ${sw_release}

Set QC_Tag
    [Documentation]    Author:    kacper.halas@nokia.com
    ...                
    ...    Maintainer:    kacper.halas@nokia.com, tomasz.blaszczyszyn@nokia.com, dawid.wojciechowski@nokia.com
    ${QC_ID}=    Set Variable    ${${TEST_NAME}}[QC_ID_${sw_release}]
    Set Tags    ${QC_ID}

Set QC_Tag depending on SW version and HW version
    [Documentation]    Author:    dawid.wojciechowski@nokia.com
    ...                Maintainer:    kacper.halas@nokia.com, tomasz.blaszczyszyn@nokia.com
    ${QC_ID}=    Set Variable    &{${TEST_NAME}}[QC_ID_${sw_release}_${OUT_HW_VERSION}]
    Set Tags    ${QC_ID}

Link SCOUT SCF to Configuration ID for Reporting
    ${scout_testline_name}=    Run    hostname
    [Documentation]    :Author: Mallikarjuna 
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    ${list}=    Split String    ${scout_testline_name}    -
    ${scout_testline_name}=    Evaluate    "_".join(${list})
    log    ${scout_testline_name}
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${TC_ID}=   scout.request_scf   use_scout_internal_id=${True}
    scout.teardown_scout_api
    ${TC_ID}    set variable    ute:id:${TC_ID}
    Set Tags  ${TC_ID}
    Sleep    120s
