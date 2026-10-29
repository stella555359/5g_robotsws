*** Settings ***
Documentation
...    Author: Alin Necula (alin.necula@nokia.com)
...    Maintainer: Alin Necula (alin.necula@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: Doors
...    Feature Description: CB006758-SR__CB005770
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/Auto5G/testsuite/OAM/ET/BTS_OAM_FMRECOV/CB006758-SR__CB005770/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        taf.selenium.gnb.oam.coam.classical    WITH NAME    selenium_coam
Library        ./check_errors.py


Resource       ../../resources/admin.robot
Resource       ../../resources/pretest_posttest.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${enb_web_alias}   ENB
${SCF_path}=       ${CURDIR}/SCF_AEQA_mMimoAntArrayMode_init.xml
${Old_Chrome_Driver_Path}=               /opt/ute/chromedriver
#${New_Chrome_Driver_Path}=               ${CURDIR}/../../Resources/chromedriver

*** Keywords ***
mMimoAntArrayMode_Trigger_the_offline_HW_validation_from_WebEM
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify gNB static HW validation function with WebEM online.
    ...     TC verifies that offline HW validation for mMimoAntArrayMmode works when WebEM is used.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.04.2021 - - Created
    ...    *******************
    ...    alin.necula@nokia.com

    Replace Chrome Driver
    Login to WebUI
    Load SCF    file_path=${SCF_path}  coam=${enb_web_alias}
    Validate Plan  coam=${enb_web_alias}
    ${hardware_errors}      selenium_coam.get_hardware_errors  coam=${enb_web_alias}
    Should Be Empty    ${hardware_errors}
    Log to Console    ${hardware_errors}
    ${modify_param_mMimoAntArrayMode_Full64TRXArray}  Create List
    ${item}  Create Dictionary  dist_name=MRBTS-1/NRBTS-1/NRCELL-1  filter_param=Massive MIMO Antenna Array Mode
    ...    p_name=mMimoAntArrayMode   value=Full 64TRX Array (4x8x2)
    Append to List  ${modify_param_mMimoAntArrayMode_Full64TRXArray}  ${item}
    Modify the Parameters On Webem Planned Config    ${modify_param_mMimoAntArrayMode_Full64TRXArray}
    Validate Plan  coam=${enb_web_alias}
    ${hardware_errors_Full64TRXArray}      selenium_coam.get_hardware_errors  coam=${enb_web_alias}
    Should Be Empty    ${hardware_errors_Full64TRXArray}
    Log to Console    ${hardware_errors_Full64TRXArray}
    ${modify_param_mMimoAntArrayMode_Left32TRXArray}  Create List
    ${item}  Create Dictionary  dist_name=MRBTS-1/NRBTS-1/NRCELL-1  filter_param=Massive MIMO Antenna Array Mode
    ...    p_name=mMimoAntArrayMode   value=Left 32TRX Array (4x4x2)
    Append to List  ${modify_param_mMimoAntArrayMode_Left32TRXArray}  ${item}
    Modify the Parameters On Webem Planned Config    ${modify_param_mMimoAntArrayMode_Left32TRXArray}
    Validate Plan  coam=${enb_web_alias}
    ${hardware_errors_Left32TRXArray}      selenium_coam.get_hardware_errors  coam=${enb_web_alias}
    Log to Console    ${hardware_errors_Left32TRXArray}
    ${status}    get_errors_common    error_msg=${hardware_errors_Left32TRXArray}  module=MRBTS-1/NRBTS-1/NRCELL-1
    ...    msg=it is required that related RMOD must support Left massive MIMO (mMIMO) antenna array mode
    Should Be Equal as Strings  ${status}    True
    [Teardown]  Logout And Close Browser





supportsPhysicalAntennaPortsTrue_Trigger_the_online_HW_validation_from_WebEM
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify gNB static HW validation function with WebEM online.
    ...           The TC verifies online HW validation for supportsPhysicalAntennaPorts is working when WebEM is used.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 16.04.2021 - - Created
    ...    *******************
    ...    alin.necula@nokia.com

    Replace Chrome Driver
    Login to WebUI
    Validate Plan  coam=${enb_web_alias}
    Get All Validation Errors
    ${modify_param_actExternalAntennaBF_true}  Create List
    ${item}  Create Dictionary  dist_name=MRBTS-10004/NRBTS-1/NRCELL-1
    ...     filter_param=Activate external antenna beamforming
    ...    p_name=actExternalAntennaBF   value=true
    Append to List  ${modify_param_actExternalAntennaBF_true}   ${item}
    Modify the Parameters On Webem Current Config  ${modify_param_actExternalAntennaBF_true}
    Validate Plan  coam=${enb_web_alias}
    ${hardware_errors_actExternalAntennaBF_true}      selenium_coam.get_hardware_errors  coam=${enb_web_alias}
    Should Be Empty    ${hardware_errors_actExternalAntennaBF_true}
    Log to Console    ${hardware_errors_actExternalAntennaBF_true}
    ${PHYANT_object}    selenium_coam.get_object_name_list  object_name=PHYANT  coam=${enb_web_alias}
    Should Be Empty    ${PHYANT_object}
    Log to Console  There are NO PHYANT objects
    selenium_coam.add_object
    ...     object_name=RMOD-1
    ...     object_class_name=PHYANT
    ...     id_value=1
    ...     is_load_default_values=true
    ...     coam=${enb_web_alias}
    Validate Plan  coam=${enb_web_alias}
    ${hardware_errors_PHYANT}      selenium_coam.get_hardware_errors  coam=${enb_web_alias}
    Log to Console    ${hardware_errors_PHYANT}
    ${status}    get_errors_common    error_msg=${hardware_errors_PHYANT}  module=MRBTS-10004/EQM-1/APEQM-1/RMOD-1
    ...    msg=antenna line connectors under the related RMOD there shall be ANTL object and no PHYANT object defined
    Should Be Equal as Strings  ${status}    True
    [Teardown]  Logout And Close Browser



Get All Validation Errors
    ${hardware_errors}      selenium_coam.get_hardware_errors  coam=${enb_web_alias}
    Should Be Empty    ${hardware_errors}
    Log to Console    ${hardware_errors}
    ${relation_errors}      selenium_coam.get_relation_errors  coam=${enb_web_alias}
    Should Be Empty    ${relation_errors}
    Log to Console    ${relation_errors}
    ${definition_errors}      selenium_coam.get_definition_errors  coam=${enb_web_alias}
    Should Be Empty    ${definition_errors}
    Log to Console    ${definition_errors}


Modify the Parameters On Webem Current Config
    [Arguments]  ${modify_params}  ${is_activate}=${True}  ${despite_errors}=${False}    ${bts_configuration}=Current
      ...           ${coam}=${enb_web_alias}
    FOR  ${item}  IN  @{modify_params}
        selenium_coam.set_parameter_value    dist_name=&{item}[dist_name]    bts_configuration=${bts_configuration}
        ...    filter_param=&{item}[filter_param]
        ...    abbr=&{item}[p_name]    new_value=&{item}[value]  coam=${coam}
    END


Modify the Parameters On Webem Planned Config
    [Arguments]  ${modify_params}  ${is_activate}=${True}  ${despite_errors}=${False}    ${bts_configuration}=Planned
      ...           ${coam}=${enb_web_alias}
    FOR  ${item}  IN  @{modify_params}
        selenium_coam.set_parameter_value    dist_name=&{item}[dist_name]    bts_configuration=${bts_configuration}
        ...    filter_param=&{item}[filter_param]
        ...    abbr=&{item}[p_name]    new_value=&{item}[value]  coam=${coam}
    END


Load SCF
    [Arguments]   ${file_path}=${SCF_path}  ${coam}=${None}
    ${status}   selenium_coam.load_commissioning_file_and_check_load_status
    ...   file_path=${file_path}
    ...   timeout=${400}
    ...   coam=${coam}
    [Return]   ${status}


Validate Plan
    [Documentation]   Validate Plan
    [Arguments]     ${coam}=${None}
    selenium_coam.validate_plan   coam=${coam}
    Sleep   10s


Login to WebUI
    selenium_coam.Enable Virtual Display
    selenium_coam.Login   url=https://192.168.255.129  username=Nemuadmin  password=nemuuser  browser=Firefox    #browser=Chrome - issue with Chrome
    ...         alias=${enb_web_alias}
    selenium_coam.disable_message_box   coam=${enb_web_alias}
    selenium_coam.disable_screen_lock   coam=${enb_web_alias}
    Run Keyword and Ignore Error  selenium_coam.close_start_up_view_window  coam=${enb_web_alias}


Logout And Close Browser
    Run Keyword And Ignore Error    selenium_coam.Logout  coam=${enb_web_alias}
    Run Keyword And Ignore Error    selenium_coam.close_browser  coam=${enb_web_alias}

Replace Chrome Driver
    Run And Return Rc And Output   sshpass -p 'zO&n1W*ktp7' scp coam@10.5.25.105:/opt/coam/NU_STERGE/chromedriver.zip /tmp
#    Run And Return Rc And Output    cp /tmp/chromedriver.zip ${New_Chrome_Driver_Path}/
    Run Keyword And Continue On Failure     Run    rm ${Old_Chrome_Driver_Path}/chromedriver
    OperatingSystem.File Should Not Exist    ${Old_Chrome_Driver_Path}/chromedriver
    Run    unzip -o /tmp/chromedriver.zip -d ${Old_Chrome_Driver_Path}
    Run Keyword And Continue On Failure     Run    rm /tmp/chromedriver.zip
#    Run And Return Rc And Output    cp ${New_Chrome_Driver_Path}/chromedriver ${Old_Chrome_Driver_Path}
    OperatingSystem.File Should Exist    ${Old_Chrome_Driver_Path}/chromedriver
    Run And Return Rc And Output    chmod 777 ${Old_Chrome_Driver_Path}/chromedriver

