*** Settings ***
Documentation
...  TC for Radio module reset from admin

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_siso_hran.robot
Resource    ../../../../resources/ca_4G_RRM_carrier_aggregation.robot
Library    hran_bsc
Library    taf.ul.oam_kpi_calculations  WITH NAME  kpi


*** Variables ***
${RMOD_SERIAL_NUMBER}                       # Serial number reseted radio module, if empty reset all radio modules.
${RESET_TIMEOUT}      180                   # Timeout in seconds for waitting for positive procedure (reset unit) result.
${RESETTYPE}          Warm                  # reset_type (string) for KW Unit Reset Cp  Soft|Hard|Warm, if SW is SBTS17 please use Hard
${BCF_VERIFICATION_TIMEOUT}    5 minutes    # Timeout for verification of BCF states (TRX, sectors, OAM link should have state WO)


*** Keywords ***
TC__STATE__Radio_module_reset_from_admin
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-6816
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Expected radio states before and after reset:
    ...     availabilityStatus=Online,
    ...     blockingState=Unblocked,
    ...     operationalState=Enabled
    ...
    ...  Expected cell states before and after reset:
    ...     availabilityStatus=Online,
    ...     blockingState=Unblocked,
    ...     administrativeState=Unlocked,
    ...     operationalState=Enabled
    ...
    ...  step1:
    ...  Radio reset from ADMIN
    ...
    ...  step2:
    ...  SBTS is restored
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-6816 - Initial creation
    ...  - 09.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8279 - Added ute_admin before keyword Reset Unit
    ...                 and switch from infomodel to abstraction layer
    ...  - 06.12.2017 - https://jira3.int.net.nokia.com/browse/TAT-8516 - Added sleep 60s after reset.
    ...  - 04.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12424 - accepted alarms due RP001063
    ...  - 13.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-13127 - add timeout for radio reset due to problem with radio reset
    ...  - 11.12.2018 - https://jira3.int.net.nokia.com/browse/TAT-13611 - increase Sleep to 2 min after reset
    ...  - 25.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15222 - Fixed when ${RMOD_SERIAL_NUMBER} is wrong
    ...  - 29.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15533 - Added needs parametr for KW Unit Reset Cp
    ...  - 01.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15604 - Fixed logic for reset single rmod
    ...  - 10.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15679 - Added input parametr resetType for KW Unit Reset Cp
    ...  - 30.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-12333 - BCF state verification after RMOD reset
    ...  - 07.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-16061 - Add open/close connection to BSC
    ...  - 04.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-17807 - Increase default value ${RESET_TIMEOUT}
    ...  - 30.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21764 - [CNI-61110] STATE TCs alignment
	...  - 01-09-2022 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-12197 - migration hran_ta to robotws
	...  - 28-11-2023 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-40861 - RM reset KPI
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-6816.png#


    Set Tags    CA-STATE    OWNER-rafal.wisniewski@nokia.com    AUTHOR-michal.kwasniewicz@nokia.com
    ...    MAINTAINER-daniel.bartkowiak@nokia.com    GROUP_IN_CHARGE-WRO_8_Vrf    PHASE-CIT    SW-SBTS17    SW-SBTS18
    ...    SW-SBTS19    FEATURE-RP001498_RP000923    FEATURE-RP001621_RP000923    FEATURE-RP001486_RP000923
    ...    FEATURE-RP001307_RP000923    FEATURE-RP0001145_RP000923

    Step1 Radio reset from ADMIN
    Step2 SBTS is restored

Step1 Radio reset from ADMIN
    Log    \nStep1 check all required states and radio reset from ADMIN.\n    console=yes
    Run Keyword If  ${LOG_TX_POWER}  Run Keyword And Ignore Error  Log All Carriers Power  direction=TX
    ${status}  ${alarms_msg}=  Run Keyword And Ignore Error  Siso Check Unexpected Alarms
    Run Keyword If  "${alarms_msg}"!="None"  Log  Unexpected alarms are present: ${alarms_msg}  console=${TRUE}
    Run Keyword If    '${RMOD_SERIAL_NUMBER}'
    ...  _Reset Radio Module
    ...  ELSE
    ...  _Reset All Radio Modules
    Run Keyword If  ${SCF_COUNT_GSM}  Verify BCF States

Step2 SBTS is restored
    Log  \nStep2 check all reqiuired states after reset.\nTimeout 10 min\n    console=yes
    Sleep    120s
    Wait Until Keyword Succeeds    9 minutes    20 sec    Check All Required States
    ${status}  ${alarms_msg}=  Run Keyword And Ignore Error  Siso Check Unexpected Alarms
    Run Keyword If  "${alarms_msg}"!="None"  Log  Unexpected alarms are present: ${alarms_msg}  console=${TRUE}
    Run Keyword If  ${LOG_TX_POWER}  Run Keyword And Ignore Error  Log All Carriers Power  direction=TX

_Reset All Radio Modules
    ${param}=  admin.Get Frm  connection=default
    ${kpi_list}  Create List  kpi51a
    FOR  ${rmod}  IN  @{param}
       admin.Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=${rmod['serialNumber']}_reset  update_interval=50
        Log  Reset radio with dist name: ${rmod['id']['internal']}  console=yes
        admin.Reset Unit  dist_name=${rmod['id']['internal']}  timeout=${RESET_TIMEOUT}  connection=default
        Store KPI Value    kpi_names=${kpi_list}  prefix=${rmod['serialNumber']}_reset  rm_name=${rmod['productName']}
        Teardown admin  alias=${rmod['serialNumber']}_reset
    END

_Reset Radio Module
    ${rmod}=  _Get Radio Module with given serial number  ${RMOD_SERIAL_NUMBER}
    Log  Reset radio with dist name: ${rmod}  console=yes
    admin.Reset Unit  dist_name=${rmod}  timeout=${RESET_TIMEOUT}  connection=default

_Get Radio Module with given serial number
    [Arguments]  ${serial_number}
    ${rmods}=  admin.Get Frm  connection=default
    FOR  ${rmod}  IN  @{rmods}
        Run Keyword If    '${serial_number}'=='${rmod['serialNumber']}'  Return from keyword  ${rmod['id']['internal']}
    END
    Fail  ${serial_number} is wrong, please set correct RMOD_SERIAL_NUMBER

Check All Required States
    admin.Assert Every    RMOD    ${STATES_ONAIR_RMOD}  connection=default
    Run Keyword If    ${SCF_COUNT_LTE}   Run Keywords
    ...    admin.Assert Every    LNCEL    ${STATES_ONAIR_LG}  search_for_iot_cells=${True}  connection=default
    ...    AND
    ...    admin.Assert No  LNCEL  ${DEGRADED_CELL_REGEX}  search_for_iot_cells=${True}  timeout=20  connection=default
    Run Keyword If    ${SCF_COUNT_GSM}   Run Keywords
    ...    admin.Assert Every    GNCEL    ${STATES_ONAIR_LG}  connection=default
    ...    AND
    ...    admin.Assert No  GNCEL  ${DEGRADED_CELL_REGEX}  timeout=20  connection=default
    Run Keyword If    ${SCF_COUNT_WCDMA}   Run Keywords
    ...    admin.Assert Every    WNCEL    ${STATES_ONAIR_WCDMA}  connection=default
    ...    AND
    ...    admin.Assert No  WNCEL  ${DEGRADED_CELL_REGEX}  timeout=20  connection=default
	Run Keyword If    ${SCF_COUNT_NR}   Run Keywords
    ...    admin.Assert Every    NRCEL    ${STATES_ONAIR_LG}  connection=default
    ...    AND
    ...    admin.Assert No  NRCEL  ${DEGRADED_CELL_REGEX}  timeout=20  connection=default

Verify BCF States
    Log    Verifying BCF state (TRXs, sectors, OAM link)   console=${True}
    admin.Get Current SCF File  ${Test Files}  current_SCF.xml  connection=default
    ${bcf_id}=    SiSo Get Parameter Value From SCF  param_name=bcfId  scf_path=${Test Files}/current_SCF.xml
    hran_bsc.Bsc SSH Connection  host=${BSC['ip']}  username=${BSC['user']}  password=${BSC['password']}
    Wait Until Keyword Succeeds    ${BCF_VERIFICATION_TIMEOUT}    20 sec    _BCF States Checker    ${bcf_id[0]}
    [Teardown]    hran_bsc.Close All Connections

_BCF States Checker
    [Arguments]    ${bcf_id}
    ${sectors_state}=    hran_bsc.Get Sectors State    ${bcf_id}    operational
    ${sectors_state}=    Evaluate    all([state[1]=='WO' for state in ${sectors_state}])

    ${trxs_state}=    hran_bsc.Get TRXs State    ${bcf_id}    operational
    ${trxs_state}=    Evaluate    all([state[1]=='WO' for state in ${trxs_state}])

    ${om_link_state}=    hran_bsc.Get OM Link State    ${bcf_id}
    ${om_link_state}=    Evaluate    '${om_link_state}'=='WO'

    Should Be True    ${sectors_state} and ${trxs_state} and ${om_link_state}

Store KPI Value
    [Arguments]  ${kpi_names}  ${prefix}  ${rm_name}
    Sleep  20s
    Collect Infomodel Log From Current Session
    ...  target_file_name=${Test Results Dir}/${prefix}/IM_infomodel_kpi.ims2
    ...  timeout=300  leave_disconnect_logs=True  alias=${prefix}

    Run Keyword And Ignore Error  Calculate Kpis  kpi_names=${kpi_names}
    ...  ims_file_path=${Test Results Dir}/${prefix}/IM_infomodel_kpi.ims2
    FOR  ${kpi_param}  IN  @{kpi_names}
        ${kpi}=  Get All Deltas  kpi_name=${kpi_param}
        ${kpi_value}=  Run Keyword And Continue On Failure  Set Variable  ${kpi[-1]}
        Append To File  ${Test Results Dir}/kpi_values.txt  ${rm_name}_SN_${prefix}:\n${kpi_param} - ${kpi_value}\n
    END

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
