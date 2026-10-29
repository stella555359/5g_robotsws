# *** Settings ***
# Force Tags    PY36
# 
# Suite Setup        robot_common_operations.Common Suite Setup
# Suite Teardown     robot_common_operations.Common Suite Teardown
# 
# Documentation
# ...   author: xiaofeng.1.zhu@nokia-sbell.com
# ...   contact: xiaofeng.1.zhu@nokia-sbell.com
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    ../CB005750_EA/Resources/common_keyword.robot
# Library     ../CB005750_EA/Resources/5G000313_common_keywords.py
# Variables         Resources/5G000313_modify_para.py
# #Library           taf.gnb.oam.coam.admin                 WITH NAME   admin
# Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# 
# *** Variables ***
# ${default_scf_path}           ${CURDIR}/../../../commissionings/HGZ/${testline_name}/
# ${DU_OAM_IP_URL}            https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_WEBUI_IP}         ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_WEBUI_USER}        ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${DU_OAM_IP_TL}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_SSH_USERNAME_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# ${DU_OAM_SSH_PASSWORD_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# ${ru_alias}                    RU
# ${test_ute}                   ${tl.test_pc.default_ssh_connection_details.addr}
# ${ute_name}                   ${tl.test_pc.default_ssh_connection_details.username}
# ${test_password}              ${tl.test_pc.default_ssh_connection_details.password}
# ${DU_OAM_IP}                  ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# #${connection}        GNB_connection
# ${GNSS_mode}        GPS only       GLONASS only      Beidou only     GLONASS-Beidou    GPS-GLONASS    GPS-Beidou
# ${GPS_only}          GPS only
# ${GLONASS_only}      GLONASS only
# ${Beidou_only}      Beidou only
# ${GLONASS_Beidou}      GLONASS-Beidou
# ${GPS_GLONASS}      GPS-GLONASS
# ${GPS_Beidou}       GPS-Beidou
# 
# *** Test Cases ***
# [1]CB005750-5G-ECAE_5GC000662_A_001_FYGM_startup_automatic self_survey_with_automatic_location_mode
#     [Documentation]
#     [Tags]     CB005750-5G    CRT_21A    CRT_TRUNK    CRT_21B
#     common_keyword.Setup Commission SCF
#     Modify Common parameter via Coam for Trunk Method2
#     [Teardown]    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Login Web and DU
#     [Arguments]  ${connection}=GNB_OAM
#     log to console  login web and DU
#     #selenium_coam.login  url=${DU_OAM_IP_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
#     Connect to gnb coam via ssl    bts_host=${DU_OAM_IP_TL}    connection=${connection}
# 
# Logout Web and DU
#     [Arguments]  ${connection}=GNB_OAM
#     #Run keyword and ignore error    selenium_coam.logout
#     Run keyword and ignore error    COAM Teardown gnb connections
# 
# Modify Common parameter for 21B
#     [Arguments]  ${input_list}    ${GNSS_mode}    ${connection}=GNB_connection    ${bts_ip}=${DU_OAM_IP_TL}
#     log to console  Modify parameter:${GNSS_mode}
#     Login Web and DU     connection=${connection}
#     sleep    10s
#     FOR    ${item}  IN    @{input_list}
#         ${dict_value}    Get Content From Input Dict    input_dict=${item}
#         coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#     END
#     wait until keyword succeeds    15min    10s    Check GNSS status for 21A and 21B   ${GNSS_mode}
#     wait until keyword succeeds    15min    10s    Check cell on air     connection=${connection}
#     [Teardown]    Logout Web and DU     connection=${connection}
# 
# Modify Common parameter for Trunk
#     [Arguments]  ${input_list}    ${BeiDou}  ${GLONASS}   ${GPS}  ${connection}=GNB_connection    ${bts_ip}=${DU_OAM_IP_TL}
#     log to console  Modify parameter:${GNSS_mode}
#     Login Web and DU     connection=${connection}
#     sleep    10s
#     FOR    ${item}  IN    @{input_list}
#         ${dict_value}    Get Content From Input Dict    input_dict=${item}
#         coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#     END
#     wait until keyword succeeds    15min    10s    Check GNSS status for Trunk Method2
#     ...    BeiDou=${BeiDou}   GLONASS=${GLONASS}   GPS=${GPS}    connection=${connection}
#     wait until keyword succeeds    15min    10s    Check cell on air    connection=${connection}
#     [Teardown]    Logout Web and DU     connection=${connection}
# 
# Get Content From Input Dict
#     [Arguments]  ${input_dict}
#     ${dist_name}    get from dictionary     ${input_dict}    dist_name
#     ${parammeter}    get from dictionary    ${input_dict}    parameter
#     ${new_value}     get from dictionary    ${input_dict}    value
#     ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
#     [Return]  ${value_list}
# 
# Check cell on air
#     [Arguments]      ${connection}=GNB_OAM
#     log_to_console    Check cell on air
#     ${status}            coam.get_bts_statuses         connection=${connection}
#     ${bts_status}        get from dictionary     ${status}     proceduralState
#     should be equal      ${bts_status}      OnAir
# 
# Check GNSS status for 21A and 21B
#     [Arguments]  ${GNSS_mode}
#     ${Get_information_GNSS}    selenium_coam.get_gnss_info
#     ${product_name}    get from dictionary    ${Get_information_GNSS}    Product name
#     ${product_code}    get from dictionary    ${Get_information_GNSS}    Product code
#     ${serial_num}    get from dictionary    ${Get_information_GNSS}     Serial number
#     ${status}    get from dictionary    ${Get_information_GNSS}    Status
#     ${Availability_status}    get from dictionary    ${status}    Availability status
#     ${Position}    get from dictionary    ${Get_information_GNSS}    Position
#     ${Latitude}    get from dictionary    ${Position}    Latitude
#     ${Longitude}    get from dictionary    ${Position}    Longitude
#     ${Constellation_mode}    get from dictionary    ${Get_information_GNSS}     Constellation mode
#     ${Location_mode}    get from dictionary    ${Get_information_GNSS}     Location mode
# 
#     should not be equal    ${product_name}    -
#     should not be equal    ${product_code}    -
#     should not be equal    ${serial_num}    -
#     should not be equal    ${Latitude}    -
#     should not be equal    ${Longitude}    -
#     log to console  Availability_status is:${Availability_status}
#     Should be equal as strings    ${Availability_status}    Online
#     Should be equal as strings    ${Constellation_mode}    ${GNSS_mode}
#     Should be equal as strings    ${Location_mode}    automatic
# 
# Check GNSS status for Trunk
#     [Arguments]  ${BeiDou}   ${GLONASS}   ${GPS}
#     ${Get_information_GNSS}    selenium_coam.get_gnss_info
#     ${product_name}    get from dictionary    ${Get_information_GNSS}    Product name
#     ${product_code}    get from dictionary    ${Get_information_GNSS}    Product code
#     ${serial_num}    get from dictionary    ${Get_information_GNSS}     Serial number
#     ${status}    get from dictionary    ${Get_information_GNSS}    Status
#     ${Availability_status}    get from dictionary    ${status}    Availability status
#     ${Position}    get from dictionary    ${Get_information_GNSS}    Position
#     ${Latitude}    get from dictionary    ${Position}    Latitude
#     ${Longitude}    get from dictionary    ${Position}    Longitude
#     ${Allow_BeiDou}    get from dictionary    ${Get_information_GNSS}    Allow usage of BeiDou
#     ${Allow_GLONASS}    get from dictionary    ${Get_information_GNSS}    Allow usage of GLONASS
#     ${Allow_GPS}    get from dictionary    ${Get_information_GNSS}    Allow usage of GPS
#     ${Location_mode}    get from dictionary    ${Get_information_GNSS}     Location mode
# 
#     should not be equal    ${product_name}    -
#     should not be equal    ${product_code}    -
#     should not be equal    ${serial_num}    -
#     should not be equal    ${Latitude}    -
#     should not be equal    ${Longitude}    -
#     log to console  Availability_status is:${Availability_status}
#     Should be equal as strings    ${Availability_status}    Online
#     Should be equal as strings    ${Allow_BeiDou}    ${BeiDou}
#     Should be equal as strings    ${Allow_GLONASS}    ${GLONASS}
#     Should be equal as strings    ${Allow_GPS}    ${GPS}
#     Should be equal as strings    ${Location_mode}    automatic
# 
# Check GNSS status for Trunk Method2
#     [Arguments]  ${BeiDou}   ${GLONASS}   ${GPS}    ${connection}=GNB_OAM
#     ${Get_information_BTS}    coam.get_bts_info    connection=${connection}
#     ${Get_All_GNSS}     Set Variable    ${Get_information_BTS['gnsse']}
#     ${GNSS_1}    Set Variable    @{Get_All_GNSS}[0]
#     ${Get_parameters_GNSS}    Set Variable    ${GNSS_1['parameters']}
#     ${Get_position_GNSS}    Set Variable    ${GNSS_1['position']}
#     ${Get_sndParameters_GNSS}    Set Variable    ${GNSS_1['sndParameters']}
#     ${Get_stateInfo_GNSS}    Set Variable    ${GNSS_1['stateInfo']}
#     ${product_name}    get from dictionary    ${Get_parameters_GNSS}    productName
#     ${product_code}    get from dictionary    ${Get_parameters_GNSS}    productCode
#     ${serial_num}    get from dictionary    ${Get_parameters_GNSS}     serialNumber
#     ${Operational_status}    get from dictionary    ${Get_stateInfo_GNSS}    operationalState
#     ${Latitude}    get from dictionary    ${Get_position_GNSS}    latitude
#     ${Longitude}    get from dictionary    ${Get_position_GNSS}    longitude
#     ${Allow_BeiDou}    get from dictionary    ${Get_sndParameters_GNSS}    actBeidou
#     ${Allow_GLONASS}    get from dictionary    ${Get_sndParameters_GNSS}    actGlonass
#     ${Allow_GPS}    get from dictionary    ${Get_sndParameters_GNSS}    actGps
#     ${Location_mode}    get from dictionary    ${Get_sndParameters_GNSS}     locationMode
# 
#     should not be equal    ${product_name}    -
#     should not be equal    ${product_code}    -
#     should not be equal    ${serial_num}    -
#     should not be equal    ${Latitude}    -
#     should not be equal    ${Longitude}    -
#     # GNSS is ready if 'availabilityStatus' not in dict
#     Dictionary should not contain key    ${Get_stateInfo_GNSS}    availabilityStatus
#     log to console  Operational_status is:${Operational_status}
#     Should be equal as strings    ${Operational_status}    enabled
#     Should be equal as strings    ${Allow_BeiDou}    ${BeiDou}
#     Should be equal as strings    ${Allow_GLONASS}    ${GLONASS}
#     Should be equal as strings    ${Allow_GPS}    ${GPS}
#     Should be equal as strings    ${Location_mode}    automatic
#     log to console    beidou:${BeiDou}, glonass:${GLONASS}, gps:${GPS} executed
# 
# Modify Common parameter via Coam for 21B
#     Run Keyword And Continue On Failure       Modify Common parameter for 21B
#     ...     input_list=${PARAMS_TO_MODIFY_DomainNumber1}    GNSS_mode=${GLONASS_only}
#     Run Keyword And Continue On Failure       Modify Common parameter for 21B
#     ...     input_list=${PARAMS_TO_MODIFY_DomainNumber3}    GNSS_mode=${GLONASS_Beidou}
#     Run Keyword And Continue On Failure       Modify Common parameter for 21B
#     ...     input_list=${PARAMS_TO_MODIFY_DomainNumber4}    GNSS_mode=${GPS_GLONASS}
#     Run Keyword And Continue On Failure       Modify Common parameter for 21B
#     ...     input_list=${PARAMS_TO_MODIFY_DomainNumber5}    GNSS_mode=${GPS_Beidou}
#     Run Keyword And Continue On Failure       Modify Common parameter for 21B
#     ...     input_list=${PARAMS_TO_MODIFY_DomainNumber2}    GNSS_mode=${Beidou_only}
#     Run Keyword And Continue On Failure       Modify Common parameter for 21B
#     ...     input_list=${PARAMS_TO_MODIFY_DomainNumber0}    GNSS_mode=${GPS only}
# 
# Modify Common parameter via Coam for Trunk
#     Run Keyword And Continue On Failure     Modify Common parameter for Trunk
#     ...    input_list=${PARAMS_GPS_only}    BeiDou=No    GLONASS=No    GPS=Yes
#     Run Keyword And Continue On Failure     Modify Common parameter for Trunk
#     ...    input_list=${PARAMS_GLONASS_only}    BeiDou=No   GLONASS=Yes    GPS=No
#     Run Keyword And Continue On Failure     Modify Common parameter for Trunk
#     ...    input_list=${PARAMS_Beidou_only}     BeiDou=Yes    GLONASS=No   GPS=No
#     Run Keyword And Continue On Failure     Modify Common parameter for Trunk
#     ...    input_list=${PARAMS_GLONASS_Beidou}    BeiDou=Yes    GLONASS=Yes    GPS=No
#     Run Keyword And Continue On Failure     Modify Common parameter for Trunk
#     ...    input_list=${PARAMS_GPS_GLONASS}    BeiDou=No    GLONASS=Yes    GPS=Yes
#     Run Keyword And Continue On Failure     Modify Common parameter for Trunk
#     ...    input_list=${PARAMS_GPS_Beidou}    BeiDou=Yes    GLONASS=No     GPS=Yes
# 
# Modify Common parameter via Coam for Trunk Method2
#     Run Keyword And Continue On Failure     Modify Common parameter for Trunk
#     ...    input_list=${PARAMS_GPS_only}    BeiDou=False    GLONASS=False    GPS=True
#     Run Keyword And Continue On Failure     Modify Common parameter for Trunk
#     ...    input_list=${PARAMS_GLONASS_only}    BeiDou=False   GLONASS=True    GPS=False
#     Run Keyword And Continue On Failure     Modify Common parameter for Trunk
#     ...    input_list=${PARAMS_Beidou_only}     BeiDou=True    GLONASS=False   GPS=False
#     Run Keyword And Continue On Failure     Modify Common parameter for Trunk
#     ...    input_list=${PARAMS_GLONASS_Beidou}    BeiDou=True    GLONASS=True    GPS=False
#     Run Keyword And Continue On Failure     Modify Common parameter for Trunk
#     ...    input_list=${PARAMS_GPS_GLONASS}    BeiDou=False    GLONASS=True    GPS=True
#     Run Keyword And Continue On Failure     Modify Common parameter for Trunk
#     ...    input_list=${PARAMS_GPS_Beidou}    BeiDou=True    GLONASS=False     GPS=True
# 
# Get BTS Version And Return Flag
#     [Arguments]     ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    _
#     ${if_21B_flag}    Set Variable if    '@{version_list}[0]'=='SBTS21B'    ${True}    ${False}
#     [Return]    ${if_21B_flag}
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections
