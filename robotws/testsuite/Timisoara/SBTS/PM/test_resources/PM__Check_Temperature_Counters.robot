*** Settings ***
Documentation
    ...  This TC is checking the following temperature counters: SBTS_RMOD_TEMPERATURE (M40008C1),
    ...  SBTS_SMOD_TEMPERATURE (M40009C0), SBTS_BBMOD_TEMPERATURE (M40010C0), SBTS_SFP_RMOD (M40005C2),
    ...  SBTS_SFP_SMOD (M40006C2) and SBTS_SFP_BBMOD (M40007C2).
    ...  First, reporting interval and all corresponding parameters are set to 15 minutes. TC waits for new PM report
    ...  to be generated on SBTS and it must contain required counters.
    ...  Then, all parameters are disabled and TC waits another 15 minutes to check if counters are not
    ...  reported anymore by veryfing that new PM report does not contain any of them.

Resource  ../../common_resources/ca_PM_general.robot


*** Keywords ***
TC__PM__Check_Temperature_Counters
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27829
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  24.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27829 - Initial TAT creation
    ...  03.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28487 - Change counters check
    ...  13.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28612 - Fix parameter name
    ...  02.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29310 - Exclude O-RAN RMODs
    ...  18.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29416 - Add fault 4639 to watchdog monitoring
    ...  31.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29658 - Exclude ETHERNET SFP port
    ...  21.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30231 - Check temperature counters in PM reports instead of WebEM

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com
    ...  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_vrf  PHASE-CRT
    ...  FEATURE-CB009514

    Step0: TC Variables
    Step1: Change Parameters To 15min If Needed
    Step2: Check Counters To Be Reported
    Step3: Disable Parameters
    Step4: Check Counters To Be Not Reported


Step0: TC Variables
    ${param_list}  Create List  reportingIntervalPm
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  ${param_list}
    ${reporting_interval}  Set Variable  ${parameter}[0][parameters][reportingIntervalPm]
    IF  '${reporting_interval}'!='15min'
        Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  reportingIntervalPm  update  15min
        ...  skip_parameter_relation_errors=True
    END

    ${rmods_dn}  Create List
    ${rmod_distnames}  Get Ids For All  RMOD
    FOR  ${rmod_id}  IN  @{rmod_distnames}
        ${rmod_r_params}  coam.Get Parameters  ${rmod_id}  pattern=configDN
        ${rmod_a_params}  coam.Get Parameters  ${rmod_r_params}[configDN]
        IF  '${rmod_a_params}[protocol]'=='O-RAN'  CONTINUE
        Append To List  ${rmods_dn}  ${rmod_id}
    END

    ${smods_dn}  Get Ids For All  SMOD

    ${rmods_with_sfp_dn}  Create List
    ${smods_with_sfp_dn}  Create List
    ${bbmods_with_sfp_dn}  Create List
    ${sfp_distnames}  Get Ids For All  SFP
    FOR  ${sfp_id}  IN  @{sfp_distnames}
        ${sfp_params}  coam.Get Parameters  ${sfp_id}  pattern=physicalPort
        IF  '${sfp_params}[physicalPort]'=='ETHERNET'  CONTINUE
        IF  'RMOD' in '${sfp_id}'
            Append To List  ${rmods_with_sfp_dn}  ${sfp_id}
        ELSE IF  'SMOD' in '${sfp_id}'
            Append To List  ${smods_with_sfp_dn}  ${sfp_id}
        ELSE
            Append To List  ${bbmods_with_sfp_dn}  ${sfp_id}
        END
    END

    ${rmods_number}  Get Length  ${rmods_dn}
    ${smods_number}  Get Length  ${smods_dn}
    ${rmods_with_sfp_number}  Get Length  ${rmods_with_sfp_dn}
    ${smods_with_sfp_number}  Get Length  ${smods_with_sfp_dn}

    ${COUNTERS_AND_PARAMS_DICT}  Create Dictionary  M40008C1=mtSBTSRMODTemperature  M40009C0=mtSBTSSMODTemperature
    ...  M40005C2=mtSBTSSfpRMOD  M40006C2=mtSBTSSfpSMOD
    ${COUNTERS_AND_MEAS_DICT}  Create Dictionary  M40008C1=SBTS_RMOD_TEMPERATURE  M40009C0=SBTS_SMOD_TEMPERATURE
    ...  M40005C2=SBTS_SFP_RMOD  M40006C2=SBTS_SFP_SMOD
    ${COUNTERS_AND_MODULES_NUMBER}  Create Dictionary  M40008C1=${rmods_number}  M40009C0=${smods_number}  M40005C2=${rmods_with_sfp_number}
    ...  M40006C2=${smods_with_sfp_number}

    ${bbmods_dn}  Get Ids For All  BBMOD
    ${bbmods_number}  Get Length  ${bbmods_dn}
    IF  ${bbmods_number} > 0
        Set To Dictionary  ${COUNTERS_AND_PARAMS_DICT}  M40010C0=mtSBTSBBMODTemperature  M40007C2=mtSBTSSfpBBMOD
        ${bbmods_with_sfp_number}  Get Length  ${bbmods_with_sfp_dn}
        Set To Dictionary  ${COUNTERS_AND_MEAS_DICT}  M40010C0=SBTS_BBMOD_TEMPERATURE  M40007C2=SBTS_SFP_BBMOD
        Set To Dictionary  ${COUNTERS_AND_MODULES_NUMBER}  M40010C0=${bbmods_number}  M40007C2=${bbmods_with_sfp_number}
    END

    Set Test Variable  ${COUNTERS_AND_PARAMS_DICT}
    Set Test Variable  ${COUNTERS_AND_MEAS_DICT}
    Set Test Variable  ${COUNTERS_AND_MODULES_NUMBER}
    Set Test Variable  ${PMMNL_PATH}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1


Step1: Change Parameters To 15min If Needed
    Log  \nStep1: Change Parameters To 15min If Needed  console=true
    ${param_list}  Get Dictionary Values  ${COUNTERS_AND_PARAMS_DICT}
    ${parameters}  Get Parameter By Distname  ${PMMNL_PATH}  ${param_list}
    FOR  ${parameter_name}  IN  @{param_list}
        ${value}  Set Variable  ${parameters}[0][parameters][${parameter_name}]
        IF  '${value}'!='15min'  Perform Parameter Recommissioning  ${PMMNL_PATH}  ${parameter_name}  update  15min
        ...  skip_parameter_relation_errors=True
    END


Step2: Check Counters To Be Reported
    Log  \nStep2: Check Counters To Be Reported  console=${TRUE}
    Sleep Until New Cycle  15min
    Sleep Until New Cycle  15min
    Sleep  1min  TC waits until new PM reported is generated on SBTS.

    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=get_pm_report
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]
    ${last_xml_file}  Extract Last Gz File From SBTS AND Get XML File Name
    SSHLibrary.Get File  /rom/uri/PERFMON_FILES/${last_xml_file}  ${BTS_FILES}/PM_Report_Meas_On_15min.xml

    ${counters}  Get Dictionary Keys  ${COUNTERS_AND_MODULES_NUMBER}
    ${o_me_s}  Parse XML  ${BTS_FILES}/PM_Report_Meas_On_15min.xml
    FOR  ${counter}  IN  @{counters}
        ${modules_dns}  Create List
        ${xpath_result}  Evaluate Xpath  ${o_me_s}
        ...  //PMSetup[@interval="15"][last()]//NE-WBTS_1.0[@measurementType="${COUNTERS_AND_MEAS_DICT}[${counter}]"]
        ${counter_not_reported}  Run Keyword And Return Status  Should Not Be Empty  ${xpath_result}
        ...  ${counter}:${COUNTERS_AND_MEAS_DICT}[${counter}] is not generated in ${BTS_FILES}/PM_Report_Meas_On_15min.xml.
        FOR  ${ne_wbts_xpath}  IN  @{xpath_result}
            ${dn_element}  Get Element  ${ne_wbts_xpath}  preceding-sibling::MO[@dimension="network_element"]
            ${distname}  Get Element Text  ${dn_element}
            ${distname}  Remove String  ${distname}  PLMN-PLMN/  \n
            Append To List  ${modules_dns}  ${distname}
        END
        ${modules_dns}  Remove Duplicates  ${modules_dns}
        ${modules_length}  Get Length  ${modules_dns}
        IF  ${modules_length}!=${COUNTERS_AND_MODULES_NUMBER}[${counter}]
            Log  ${counter} is not reported for all modules, just for: ${modules_dns}.  level=ERROR
            Set Test Failed  ${counter} is not reported for all modules, just for: ${modules_dns}.
        ELSE
            Log  ${counter} is reported for ${modules_dns}.  console=true
        END
    END

    [Teardown]  Run Keywords  SSHLibrary.Execute Command  rm /rom/uri/PERFMON_FILES/${last_xml_file}  AND  SSHLibrary.Close Connection


Step3: Disable Parameters
    Log  \nStep3: Disable Parameters  console=true
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    ${param_list}  Get Dictionary Values  ${COUNTERS_AND_PARAMS_DICT}
    FOR  ${parameter_name}  IN  @{param_list}
        Append Parameter Update To Delta  ${PMMNL_PATH}  ${parameter_name}  disabled  ${delta_id}
    END
    Save Delta  ${BTS Files}/disable_temp_counters.json  delta_id=${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/disable_temp_counters.json  skip_parameter_relation_errors=True

    [Teardown]  Run Keywords  Remove Delta  ${delta_id}  AND  Run keyword And Ignore Error  Remove File
    ...  ${BTS_Files}/disable_temp_counters.json


Step4: Check Counters To Be Not Reported
    Log  \nStep4: Check Counters To Be Not Reported  console=true
    Sleep Until New Cycle  15min
    Sleep  1min  TC waits until new PM reported is generated on SBTS.

    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=get_pm_report
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]
    ${last_xml_file}  Extract Last Gz File From SBTS AND Get XML File Name
    SSHLibrary.Get File  /rom/uri/PERFMON_FILES/${last_xml_file}  ${BTS_FILES}/PM_Report_Meas_Disabled.xml

    ${counters}  Get Dictionary Keys  ${COUNTERS_AND_MODULES_NUMBER}
    ${o_me_s}  Parse XML  ${BTS_FILES}/PM_Report_Meas_Disabled.xml
    FOR  ${counter}  IN  @{counters}
        ${modules_dns}  Create List
        ${xpath_result}  Evaluate Xpath  ${o_me_s}  //PMSetup[@interval="15"][last()]//NE-WBTS_1.0/${counter}
        ${counter_is_visible}  Run Keyword And Return Status  Should Not Be Empty  ${xpath_result}
        IF  ${counter_is_visible}
            Log  ${counter} is still reported in ${BTS_FILES}/PM_Report_Meas_Disabled.xml.  level=ERROR
            Set Test Failed  ${counter} is still reported in ${BTS_FILES}/PM_Report_Meas_Disabled.xml.
        ELSE
            Log  ${counter} is not reported in ${BTS_FILES}/PM_Report_Meas_Disabled.xml.  console=true
        END
    END

    [Teardown]  Run Keywords  SSHLibrary.Execute Command  rm /rom/uri/PERFMON_FILES/${last_xml_file}  AND  SSHLibrary.Close Connection


TC Setup
    Common Test Setup  tc_name=PM__Check_Temperature_Counters


TC Teardown
    Common Test Teardown
