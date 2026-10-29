*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    ../Resources/CB005770_common_keyword.robot
Resource    ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Variables    ./variables_5770.py
Library    ../lib/check_errors.py
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli

Documentation
...    author: Shufei Chen
...    contact: shufei.chen@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
#${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
#${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
#${AEUB_100M_nrarfcn_max}    2700000
#${Active_SW_version}        0.400.1221
${TS_CASE_LOG_PATH}         /home/ute
${WEBUI_ADDR}               ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}               Nemuadmin
${WEBUI_USER}               nemuuser
#${OUTPUT_DIR}               /home/ute/JWW
#${SUITE_LOG_PATH}           /home/ute/JWW
*** Keywords ***
Connect to gnb via ssl
    [Arguments]  ${connection}=GNB_OAM    ${bts_host}=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

Test Suite Setup
    log to console    \n***case Suite Setup***
#    run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup
    Connect to gnb via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    [teardown]  COAM Teardown gnb connections

Test Suite Teardown
    log to console    \n***case Suite Teardown***
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb via ssl
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}
#    ...    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    COAM Teardown gnb connections
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

COAM Login via webUI
    [Documentation]  Author: Ding Binmei HGZ_SG4
    ...              Description: If case failed, the snapshot from webUI will be stored in the ${download_dir} folder
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${timeout}=${60}
    ...            ${gnb_index}=${0}
    ...            ${urladdr}=https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${urladdr}
    ...                    username=${username}
    ...                    password=${password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    selenium_coam.disable_message_box

Case Test Setup
    log to console    \n***Case Test Setup***
#    Generate test case log path
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb via ssl
#    run keyword and ignore error  should contain  ${TEST_NAME}  &{ru_info}[productName]
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    should be true    ${cell_status}
    Run Keyword And Ignore Error    selenium_coam.close_browser
    [Teardown]  COAM Teardown gnb connections

Case Test Teardown
    log to console    \n***Case Test Teardown***
    COAM Login via webUI
    log to console  ${CURDIR}
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    log to console    ${SCF_PATH}
    COAM WEBUI Load SCF    file_path=${SCF_PATH}/scf/scf_AEUB_normal.xml
    COAM WEBUI Validate Plan
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_ANT_PHYANT_Configuration_MMW
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify gNB static HW validation function with WebEM online.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.14.2021 - - Created
    ...    *******************
    ...    shufei.chen@nokia-sbell.com
    COAM Login via webUI
    log to console  ${CURDIR}
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    log to console    ${SCF_PATH}
    COAM WEBUI Load SCF    file_path=${SCF_PATH}/scf/scf_AEUB_ANT_PHYANT.xml
    COAM WEBUI Validate Plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors}=    catenate    SEPARATOR=    Whenever RMOD_BP_R-1 having RMOD_BP_R-1.bfType (value: Analog) not equal t
    ...    o Digital or RMOD_BP_R-1.supportsPhysicalAntennaPorts (value: false) not equal to true, it is required that e
    ...    mbedded assertion valid (Namely: Whenever RMOD-* having RMOD_R-1.configDN (value: MRBTS-330/EQM-1/APEQM-1/RMO
    ...    D-1) equal to RMOD.distname, it is required that embedded assertion valid (Namely: Whenever for each NRCELL.r
    ...    ModDNList, NRCELL.rModDNList.element equal to RMOD.distname, it is required that NRCELL.actExternalAntennaBF n
    ...    ot equal to true))
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-330/EQM-1/APEQM-1/RMOD-1
    ...    msg=${errors}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_Bandwidth_Configuration_MMW
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify gNB static HW validation function with WebEM online.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.14.2021 - - Created
    ...    *******************
    ...    shufei.chen@nokia-sbell.com
    COAM Login via webUI
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    COAM WEBUI Load SCF    file_path=${SCF_PATH}/scf/scf_AEUB_bandwidth.xml
#    ${modify_params}  create list
#    ${item}  create dictionary  dist_name=MRBTS-330/NRBTS-2/NRCELL-1
#    ...    filter_param=Channel bandwidth    p_name=chBw    value=${chbw_modify}
#    append to list  ${modify_params}  ${item}
#    Modify the Parameters On Webem    modify_params=${modify_params}
#    selenium_coam.validate_plan
    COAM WEBUI Validate Plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-330/NRBTS-2/NRCELL-1
#    ...    msg=Value of NRCELL-1.chBw (value: ${chbw_modify}) must be supported by the Radio Module RMOD
    ...    msg=Value of NRCELL-1.chBw (value: 30MHz) must be supported by the Radio Module RMOD
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_RMOD_EAC_lines_Configuration_MMW
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of RMOD EAC
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    COAM Login via webUI
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    COAM WEBUI Load SCF    file_path=${SCF_PATH}/scf/scf_AEUB_RMOD.xml
    COAM WEBUI Validate Plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-330/EQM-1/APEQM-1/RMOD-1/EAC_IN-1
    ...    msg=It is required that portId value must be less than or equal to number of supported EAC inputs for this RMOD
    should be equal as strings  ${status}    True
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-330/EQM-1/APEQM-1/RMOD-1/EAC_OUT-1
    ...    msg=It is required that portId value must be less than or equal to number of supported EAC outputs for this RMOD
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_SMOD_EAC_lines_Configuration_MMW
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of SMOD EAC
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    COAM Login via webUI
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    COAM WEBUI Load SCF    file_path=${SCF_PATH}/scf/scf_AEUB_SMOD.xml
    COAM WEBUI Validate Plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors1}=    catenate    SEPARATOR=    it is required that EAC_IN.portId less/equal to SMOD_BP_R-1.numOfEACInputs (va
    ...    lue: 12))
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-330/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...    msg=${errors1}
    should be equal as strings  ${status}    True
    ${errors2}=    catenate    SEPARATOR=    it is required that EAC_OUT.portId less/equal to SMOD_BP_R-1.numOfEACOutput
    ...    s (value: 6))
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-330/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...    msg=${errors2}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_Cell_Power_Configuration_MMW
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verity hw capabilities of cell power
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    COAM Login via webUI
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    COAM WEBUI Load SCF    file_path=${SCF_PATH}/scf/scf_AEUB_pmax.xml
#    ${pmax}    evaluate    ${AEQQ_pmax} + 0
#    ${modify_params}  create list
#    ${item}  create dictionary  dist_name=MRBTS-330/NRBTS-2/NRCELL-1  filter_param=Maximum output power
#    ...    p_name=pMax    value=${pmax}
#    append to list  ${modify_params}  ${item}
#    Modify the Parameters On Webem    modify_params=${modify_params}
    COAM WEBUI Validate Plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors}=    catenate    SEPARATOR=    NRCELL-1.pMax (value: 39dBm) value of pMax can be se
    ...    t to any value that not exceed the maximum value supported by radio module
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-330/NRBTS-2/NRCELL-1
    ...    msg=${errors}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_Frequency_Configuration_MMW
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify gNB static HW validation function with WebEM online.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.14.2021 - - Created
    ...    *******************
    ...    shufei.chen@nokia-sbell.com
    COAM Login via webUI
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    COAM WEBUI Load SCF    file_path=${SCF_PATH}/scf/scf_AEUB_normal.xml
#    ${modify_params}  create list
#    ${nrarfcn}    evaluate    ${AZQF_20M_nrarfcn_min} - 0
#    ${item}  create dictionary  dist_name=MRBTS-330/NRBTS-2/NRCELL-1
#    ...    filter_param=NR Absolute radio frequency channel number    p_name=nrarfcn    value=${nrarfcn}
#    append to list  ${modify_params}  ${item}
#    Modify the Parameters On Webem    modify_params=${modify_params}
#    selenium_coam.validate_plan
    COAM WEBUI Load SCF    file_path=${SCF_PATH}/scf/scf_AEUB_freqmin.xml
    COAM WEBUI Validate Plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors_tx_min}=    catenate    SEPARATOR=    NRCELL-1.nrarfcn (value: 140600) is not in allowed range defined b
    ...    y minimum RX frequency for 5G band configured in freqBandIndicatorNR supported by the PHYANT Radio Module
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-330/NRBTS-2/NRCELL-1
    ...    msg=${errors_tx_min}
    ${errors_rx_min}=    catenate    SEPARATOR=    NRCELL-1.nrarfcn (value: 140600) is not in allowed range defined by mi
    ...    nimum TX frequency for 5G band configured in freqBandIndicatorNR supported by the PHYANT Radio Module
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-330/NRBTS-2/NRCELL-1
    ...    msg=${errors_rx_min}
    should be equal as strings  ${status}    True
    COAM WEBUI Load SCF    file_path=${SCF_PATH}/scf/scf_AEUB_freqmax.xml
    COAM WEBUI Validate Plan
#    ${modify_params}  create list
#    ${nrarfcn}    evaluate    ${AEUB_100M_nrarfcn_max} + 0
#    ${item}  create dictionary  dist_name=MRBTS-330/NRBTS-2/NRCELL-1
#    ...    filter_param=NR Absolute radio frequency channel number    p_name=nrarfcn    value=${nrarfcn}
#    append to list  ${modify_params}  ${item}
#    Modify the Parameters On Webem    modify_params=${modify_params}
#    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
#    ${errors_tx_max}=    catenate    SEPARATOR=     is not in allowed range defined by maximum TX frequency for 5G band configu
#    ...    red in freqBandIndicatorNR supported by the ANTL Radio Module
    ${errors_tx_max}=    catenate    SEPARATOR=    NRCELL-1.nrarfcn (value: 2700000) is not in allowed range defined by m
    ...    aximum RX frequency for 5G band configured in freqBandIndicatorNR supported by the PHYANT Radio Module
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-330/NRBTS-2/NRCELL-1
    ...    msg=${errors_tx_max}
    should be equal as strings  ${status}    True
    ${errors_rx_max}=    catenate    SEPARATOR=    NRCELL-1.nrarfcn (value: 2700000) is not in allowed range defined by m
    ...    aximum TX frequency for 5G band configured in freqBandIndicatorNR supported by the PHYANT Radio Module
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-330/NRBTS-2/NRCELL-1
    ...    msg=${errors_rx_max}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_Split_Mode_Configuration_MMW
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of split mode
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    COAM Login via webUI
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    COAM WEBUI Load SCF    file_path=${SCF_PATH}/scf/scf_AEUB_SplitMode_left.xml
    COAM WEBUI Validate Plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors}=    catenate    SEPARATOR=    Whenever NRCELL-1.mMimoAntArrayMode (value: Left 32TRX Array (4x4x2)) is equ
    ...    al to Left 32TRX Array (4x4x2), it is required that related RMOD must support Left massive MIMO (mMIMO) anten
    ...    na array mode
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-330/NRBTS-2/NRCELL-1    msg=${errors}
    should be equal as strings  ${status}    True
    selenium_coam.refresh_page
    sleep    5
    COAM WEBUI Load SCF    file_path=${SCF_PATH}/scf/scf_AEUB_SplitMode_bottom.xml
    COAM WEBUI Validate Plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors}=    catenate    SEPARATOR=    Whenever NRCELL-1.mMimoAntArrayMode (value: Bottom 32TRX Array (2x8x2)) is wi
    ...    thin range Bottom 32TRX Array (2x8x2)|Bottom 16TRX Array (1x8x2), it is required that related RMOD must suppor
    ...    t Bottom massive MIMO (mMIMO) antenna array mode
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-330/NRBTS-2/NRCELL-1    msg=${errors}
    should be equal as strings  ${status}    True
    selenium_coam.refresh_page
    sleep    5
    COAM WEBUI Load SCF    file_path=${SCF_PATH}/scf/scf_AEUB_SplitMode_right.xml
    COAM WEBUI Validate Plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors}=    catenate    SEPARATOR=    Whenever NRCELL-1.mMimoAntArrayMode (value: Right 32TRX Array (4x4x2)) is eq
    ...    ual to Right 32TRX Array (4x4x2), it is required that related RMOD must support Right massive MIMO (mMIMO) an
    ...    tenna array mode
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-330/NRBTS-2/NRCELL-1    msg=${errors}
    should be equal as strings  ${status}    True
    selenium_coam.refresh_page
    sleep    5
    COAM WEBUI Load SCF    file_path=${SCF_PATH}/scf/scf_AEUB_SplitMode_top.xml
    COAM WEBUI Validate Plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors}=    catenate    SEPARATOR=    Whenever NRCELL-1.mMimoAntArrayMode (value: Top 32TRX Array (2x8x2)) is with
    ...    in range Top 32TRX Array (2x8x2)|Top 16TRX Array (1x8x2), it is required that related RMOD must support Top m
    ...    assive MIMO (mMIMO) antenna array mode
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-330/NRBTS-2/NRCELL-1    msg=${errors}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_Cell_Duplex_Mode_Configuration_MMW
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of cell duplex mode
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    COAM Login via webUI
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    COAM WEBUI Load SCF    file_path=${SCF_PATH}/scf/scf_AEUB_Cell_Duplex_Mode.xml
    COAM WEBUI Validate Plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors}=    catenate    SEPARATOR=    If there exists at least one CABLINK that connects SMOD and RMOD which is supp
    ...    orting only TDD technology then other RMODs connected to this SMOD must also support TDD technology
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-322/EQM-1/APEQM-1/RMOD-1    msg=${errors}
    should be equal as strings  ${status}    True
    ${errors}=    catenate    SEPARATOR=    If there exists at least one CABLINK that connects SMOD and RMOD which is sup
    ...    porting only TDD technology then all other RMODs connected to this SMOD must also support TDD technology
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-322/EQM-1/APEQM-1/RMOD-2    msg=${errors}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_Radio_Protocol_Type_Configuration_MMW
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of radio protocol type
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    COAM Login via webUI
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    COAM WEBUI Load SCF    file_path=${SCF_PATH}/scf/scf_AEUB_Protocol_Type.xml
    COAM WEBUI Validate Plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors}=    catenate    SEPARATOR=    Whenever MNL-1 having embedded assertion valid (Namely: It is required that th
    ...    ere exist MOs NRBTS-* having NRBTS.tmpParam1 equal to 1), it is required that embedded assertion valid (Namely
    ...    : Whenever CABLINK-* having getClassName(CABLINK.firstEndpointDN) equal to BBMOD or getClassName(CABLINK.first
    ...    EndpointDN) equal to SMOD and getClassName(CABLINK.secondEndpointDN) equal to RMOD and CABLINK.radioProtocolTy
    ...    pe equal to CPRI or CABLINK.radioProtocolType equal to FDDCPRI or CABLINK.radioProtocolType equal to TDDCPRI, i
    ...    t is required that embedded assertion valid (Namely: Whenever RMOD-* having embedded assertion valid (Namely: I
    ...    t is required that there exist MOs NRCELL.rModDNList, whenever for each NRCELL.rModDNList, NRCELL.rModDNList.el
    ...    ement equal to RMOD.distname) and RMOD.distname equal to CABLINK.secondEndpointDN, it is required that embedde
    ...    d assertion valid (Namely: Whenever RMOD_R-* having RMOD_R.configDN equal to RMOD.distname, it is required tha
    ...    t RMOD_BP_R.interfaceType is configured and RMOD_BP_R.interfaceType contains the value of CPRI-A or RMOD_BP_R.i
    ...    nterfaceType contains the value of CPRI-N)))
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-322/MNL-1    msg=${errors}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser