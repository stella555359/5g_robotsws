*** Settings ***
Library         String
Library         OperatingSystem
Library         Process
Library         SSHLibrary
Library         Collections
Library         DateTime
Library         ute_syslog
Library         XML  use_lxml=true
Library         taf.sbts.oam.coam.admin  WITH NAME  admin

Documentation
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  13.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-307 - Adaptation to CB008660. For parameters with isDistname=true
...                                                                 error type changed from relations error to deffinition error.
...  24.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-309 - Remove Comba RET antModel from Additional Data
...  13.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-494 - Fix for ALD.11_ALD_HDLC_Communication_management_in_runtime to handle RAE alarms
...  13.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-514 - Fix for tests related with fault 4141/4142. DC voltage in runtime...
...  xx.xx.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${ALD_expected_states}=               administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${ALD_expected_states_idle}=          administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", usageState=regex"(?i)Idle"
${ALD_expected_state_degraded}=       availabilityStatus=regex"(?i)degraded", operationalState=regex"(?i)Enabled"
${ALD_expected_state_dependency}=     availabilityStatus=regex"(?i)dependency", operationalState=regex"(?i)Disabled"
${ALD_expected_state_failed}=         availabilityStatus=regex"(?i)failed", operationalState=regex"(?i)Disabled"
${ALD_expected_state_notInstalled}=   availabilityStatus=regex"(?i)not\\s?installed", operationalState=regex"(?i)Disabled"
${ALD_expected_state_powerOff}=       availabilityStatus=regex"(?i)power\\s?off", operationalState=regex"(?i)Disabled"
${ALD_expected_state_offline}=        availabilityStatus=regex"(?i)off\\s?line", operationalState=regex"(?i)Disabled"
${ALD_expected_state_busy}=           usageState=regex"(?i)busy"

*** Keywords ***
##########################
### BASIC ALD KEYWORDS ###
##########################

Sorting ALD_R by type
    [Documentation]
    ...  **Author:** tomasz.marchewka@nokia.com
    ...
    ...  KW return:
    ...  {ALD_R_RAEs}= [/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-5,
    ...                 /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-6]
    ...  {ALD_R_MHAs}= [/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-1,
    ...                 /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-2]
    ...  {ALD_R_RETs}= [/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-3,
    ...                 /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-4]
    ...  {ALD_R_ALL}= [/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-1,
    ...                /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-2,
    ...                /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-3,
    ...                /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-4,
    ...                /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-5,
    ...                /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-6]
    ...
    ...  ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    ...
    ${ALD_R_ALL}=  admin.get ids for all  ALD
    ${ald_parameters}=  admin.get managed objects  ALD_R
    ${ALD_R_RAEs}=  Create List
    ${ALD_R_MHAs}=  Create List
    ${ALD_R_RETs}=  Create List
    FOR  ${ald_id}  ${ald_parameter}  IN ZIP  ${ALD_R_ALL}  ${ald_parameters}
        Run Keyword If  '${ald_parameter['parameters']['mhaType']}'=='None' and '${ald_parameter['parameters']['retDeviceType']}'=='None'
        ...  Append To List  ${ALD_R_RAEs}  ${ald_id}
        ...  ELSE IF  '${ald_parameter['parameters']['mhaType']}'=='None' and '${ald_parameter['parameters']['retDeviceType']}'=='SingleAntennaDevice'
        ...  Append To List  ${ALD_R_RETs}  ${ald_id}
        ...  ELSE
        ...  Append To List  ${ALD_R_MHAs}  ${ald_id}
    END
    ${num_of_RAEs}=  Get Length  ${ALD_R_RAEs}
    ${num_of_RETs}=  Get Length  ${ALD_R_RETs}
    ${num_of_MHAs}=  Get Length  ${ALD_R_MHAs}
    ${num_of_ALDs}=  Evaluate  ${num_of_RAEs}+${num_of_RETs}+${num_of_MHAs}
    [Return]  ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}  ${ALD_R_ALL}
    ...  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}

Mapping RET To ProductCode
    [Documentation]  Mapping RET-ProductCode
    ...  **Author:** tomasz.marchewka@nokia.com
    [Arguments]  ${ALD_R_RETs}
    Log  ${ALD_R_RETs}  console=${True}
    ${ALD_R_ALL}=  admin.get ids for all  ALD
    ${ald_parameters}=  admin.get managed objects  ALD_R
    ${RET_prodCode}=  Create Dictionary
    FOR  ${ald_id}  ${ald_parameter}  IN ZIP  ${ALD_R_ALL}  ${ald_parameters}
        Run Keyword If  '${ald_parameter['parameters']['mhaType']}'=='None'
        ...  Set To Dictionary  ${RET_prodCode}  ${ald_id}  ${ald_parameter['parameters']['productCode']}
    END
    [Return]  ${RET_prodCode}

Mapping RET To Vendor And RET To SW Version
    [Documentation]  Keyword check how many Kathrein, Andrew and Comba RETs are in configuration.
    ...  **Author:** tomasz.marchewka@nokia.com
    [Arguments]  ${ALD_R_RETs}
    Log  ${ALD_R_RETs}  console=${True}
    ${ALD_R_ALL}=  admin.get ids for all  ALD
    ${ald_parameters}=  admin.get managed objects  ALD_R
    ${RET_vendor}=  Create Dictionary
    ${RET_SW}=  Create Dictionary
    FOR  ${ald_id}  ${ald_parameter}  IN ZIP  ${ALD_R_ALL}  ${ald_parameters}
        Run Keyword If  '${ald_parameter['parameters']['mhaType']}'=='None'  Run Keywords
        ...  Set To Dictionary  ${RET_vendor}  ${ald_id}  ${ald_parameter['parameters']['productCode']}
        ...  AND
        ...  Set To Dictionary  ${RET_SW}  ${ald_id}  ${ald_parameter['parameters']['swVersion']}
    END
    [Return]  ${RET_vendor}  ${RET_SW}

Mapping MHA ALD_A To ProductCode
    ${ald_obj}=  admin.get managed objects  ALD_A
    ${MHA_ALD_A_prodCode}=  Create Dictionary
    FOR  ${item}  IN  @{ald_obj}
        Run Keyword If  '${item['parameters']['mhaType']}'!='None'
        ...  Set To Dictionary  ${MHA_ALD_A_prodCode}  ${item['distName']}  ${item['parameters']['productCode']}
    END
    [Return]  ${MHA_ALD_A_prodCode}

Mapping RET ALD_A To ProductCode
    ${ald_obj}=  admin.get managed objects  ALD_A
    ${RET_ALD_A_prodCode}=  Create Dictionary
    FOR  ${item}  IN  @{ald_obj}
        Run Keyword If  '${item['parameters']['mhaType']}'=='None'
        ...  Set To Dictionary  ${RET_ALD_A_prodCode}  ${item['distName']}  ${item['parameters']['productCode']}
    END
    [Return]  ${RET_ALD_A_prodCode}

Detect Single Band MHA Connected To BTS
    [Documentation]  Keyword checks how many single band MHAs is in configuration.
    ...  **Author:** tomasz.marchewka@nokia.com
    [Arguments]  ${MHA_ALD_A_prodCode}
    ${prodCode_list}=  Get Dictionary Values  ${MHA_ALD_A_prodCode}
    ${ald_a_list}=  Get Dictionary Keys  ${MHA_ALD_A_prodCode}
    ${prodCodes_single_band_MHA}=  Create List
    ${ald_a_prodCode_single_band}=  Create Dictionary
    ${ald_a_single}=  Create List
    FOR  ${productCode}  ${ald}  IN ZIP  ${prodCode_list}  ${ald_a_list}
        ${prod}=  Get Regexp Matches  ${productCode}  47\\d+A|CS\\d+
        ${status}  ${msg}=  Run Keyword If  ${prod}!=[]
        ...  Run Keyword And Ignore Error  Evaluate  re.findall(r'(${PATTERN_SINGLEBAND_MHA})','''${prod}''')  re
        Run Keyword If  '${status}'!='None' and ${msg}!=[]  Append To List  ${ald_a_single}  ${ald}
    END
    [Return]  ${ald_a_single}

Count Expected RETs In Configuration
    [Documentation]  Keyword checks how many Kathrein, Comba and Andrew RETs are in configuration.
    ...  **Author:** tomasz.marchewka@nokia.com
    [Arguments]  ${RET_vendor}
    ${KA_86010148}=  Create List
    ${AN_ATM3}=  Create List
    ${CB_RCU003}=  Create List
    FOR  ${RET}  IN  @{RET_vendor.keys()}
        ${ITEM}=  Get From Dictionary  ${RET_vendor}  ${RET}
        Run Keyword If  '${ITEM}'=='86010148'
        ...  Append To List  ${KA_86010148}   ${ITEM}
        ...  ELSE IF  '${ITEM}'=='ATM3'
        ...  Append To List  ${AN_ATM3}   ${ITEM}
        ...  ELSE IF  '${ITEM}'=='RCU-003(IV)'
        ...  Append To List  ${CB_RCU003}  ${ITEM}
    END
    ${num_of_86010148}=  Get Length  ${KA_86010148}
    ${num_of_ATM3}=  Get Length  ${AN_ATM3}
    ${num_of_CB_RCU003}=  Get Length  ${CB_RCU003}
    Set Test Variable  ${KA_86010148}
    Set Test Variable  ${AN_ATM3}
    Set Test Variable  ${CB_RCU003}
    Set Test Variable  ${num_of_86010148}
    Set Test Variable  ${num_of_ATM3}
    Set Test Variable  ${num_of_CB_RCU003}

Get Current RET SW Version
    [Documentation]  Keyword checks current software version on Kathrein, Andrew and Comba RETs.
    ...  **Author:** tomasz.marchewka@nokia.com
    ${ald_param}=  admin.get managed objects  ALD_R
    ${KA_swVersion}=  Create List
    ${AN_swVersion}=  Create List
    ${CB_swVersion}=  Create List
    FOR  ${ITEM}  IN  @{ald_param}
        Run Keyword If  '${ITEM['parameters']['retDeviceType']}'=='SingleAntennaDevice' and '${ITEM['parameters']['productCode']}'=='ATM3'
        ...  Append To List  ${AN_swVersion}  ${ITEM['parameters']['swVersion']}
        ...  ELSE IF  '${ITEM['parameters']['retDeviceType']}'=='SingleAntennaDevice' and '${ITEM['parameters']['productCode']}'=='86010148'
        ...  Append To List  ${KA_swVersion}  ${ITEM['parameters']['swVersion']}
        ...  ELSE IF  '${ITEM['parameters']['retDeviceType']}'=='SingleAntennaDevice' and '${ITEM['parameters']['productCode']}'=='RCU-003(IV)'
        ...  Append To List  ${CB_swVersion}  ${ITEM['parameters']['swVersion']}
    END
    ${KA_swVersion}=  Remove Duplicates  ${KA_swVersion}
    ${AN_swVersion}=  Remove Duplicates  ${AN_swVersion}
    ${CB_swVersion}=  Remove Duplicates  ${CB_swVersion}
    ${msg}  ${KA_swVersion}=  Run Keyword And Ignore Error  Get From List  ${KA_swVersion}  0
    ${msg}  ${AN_swVersion}=  Run Keyword And Ignore Error  Get From List  ${AN_swVersion}  0
    ${msg}  ${CB_swVersion}=  Run Keyword And Ignore Error  Get From List  ${CB_swVersion}  0
    Set Test Variable  ${KA_swVersion}
    Set Test Variable  ${AN_swVersion}
    Set Test Variable  ${CB_swVersion}

ALD Recovery Action
    [Documentation]  Recovery action for faults 1806, 1842, 1844, 1871 and 1874 related with ALDs.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  ALD Recovery Action  1874
    ...
    [Arguments]  ${faultId}
    Run Keyword If  '${faultId}'=='1806'
    ...  Log  \nRecovery action for faultId ${faultId} - "Antenna Line Device failure"  console=${True}
    ...  ELSE IF  '${faultId}'=='1842'
    ...  Log  \nRecovery action for faultId ${faultId} - "RET Antenna control failure"  console=${True}
    ...  ELSE IF  '${faultId}'=='1844'
    ...  Log  \nRecovery action for faultId ${faultId} - "RET Antenna control failure"  console=${True}
    ...  ELSE IF  '${faultId}'=='1871'
    ...  Log  \nRecovery action for faultId ${faultId} - "Antenna Line Device failure"  console=${True}
    ...  ELSE IF  '${faultId}'=='1874'
    ...  Log  \nRecovery action for faultId ${faultId} - "Antenna Line Device Operation Failure"  console=${True}
    ${ALD_R_MHAs}  ${ALD_R_RETs}  ${ALD_R_ALL}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    FOR  ${RET}  IN  @{ALD_R_RETs}
        Calibrate Tilt  ${RET}
    END

Get defined ALDs Connected To BTS
    [Documentation]  This keyword return ALD_L and ALD_R distName parameters for defined ALD connected to BTS.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  Get defined ALDs Connected To BTS  RET
    ...  Get defined ALDs Connected To BTS  MHA
    ...  Get defined ALDs Connected To BTS  ALL
    ...
    [Arguments]  ${deviceType}
    ${parameters_to_check}=    Create Dictionary
    ${ALD_L_param}=  admin.get managed objects  ALD_L
    ${ALD_L_dn_list}=  Create List
    ${ALD_L_sn}=  Create List
    FOR  ${ALD}  IN  @{ALD_L_param}
        Run Keyword If  '${deviceType}'=='${ALD['parameters']['deviceType']}'
        ...  Append To List  ${ALD_L_dn_list}  ${ALD['distName']}
        ...  ELSE IF  '${deviceType}'=='ALL'
        ...  Append To List  ${ALD_L_dn_list}  ${ALD['distName']}
    END
    ${ALD_R_param}=  admin.get managed objects  ALD_R
    ${parameters_to_check}=    Create Dictionary
    ${ALD_R_dn_list}=  Create List
    ${ALD_A_dn_list}=  Create List
    FOR  ${ALD}  IN  @{ALD_R_param}
        Run Keyword If  '${deviceType}'=='MHA' and '${ALD['parameters']['mhaType']}'!='None'  Run Keywords
        ...  Append To List  ${ALD_R_dn_list}  ${ALD['distName']}
        ...  AND
        ...  Append To List  ${ALD_A_dn_list}  ${ALD['parameters']['configDN']}
        ...  ELSE IF  '${deviceType}'=='RET' and '${ALD['parameters']['mhaType']}'=='None'  Run Keywords
        ...  Append To List  ${ALD_R_dn_list}  ${ALD['distName']}
        ...  AND
        ...  Append To List  ${ALD_A_dn_list}  ${ALD['parameters']['configDN']}
        ...  ELSE IF  '${deviceType}'=='ALL'  Run Keywords
        ...  Append To List  ${ALD_R_dn_list}  ${ALD['distName']}  Run Keywords
        ...  AND  Append To List  ${ALD_A_dn_list}  ${ALD['parameters']['configDN']}
        ...  AND  Set To Dictionary  ${parameters_to_check}  ${ALD['distName']}_productCode=${ALD['parameters']['mhaType']}
        ...  AND  Set To Dictionary  ${parameters_to_check}  ${ALD['distName']}_productCode=${ALD['parameters']['productCode']}
        ...  AND  Set To Dictionary  ${parameters_to_check}  ${ALD['distName']}_serialNumber=${ALD['parameters']['serialNumber']}
        ...  AND  Set To Dictionary  ${parameters_to_check}  ${ALD['distName']}_vendorCode=${ALD['parameters']['vendorCode']}
    END
    [Return]  ${ALD_L_dn_list}  ${ALD_R_dn_list}  ${ALD_A_dn_list}   ${parameters_to_check}

Check Received RAE Info
    [Documentation]  This keyword return RAE sensor data info
    ...  **Author:** mateusz.gadek@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  Check Received RAE Info  &{ID}
    ...
    [Arguments]  ${ALD_A_ID}
    ${RAE_parameters}=  Create List
    ${RAEU_A_param}=  admin.get managed objects  RAEU_A
    FOR  ${ALD}  IN  @{RAEU_A_param}
        ${ignore}  ${distName}=  Split String From Right  ${ALD['distName']}  separator=APEQM_A-1/
        Run Keyword If  '${distName}'=='ALD_A-${ALD_A_ID}/RAEU_A-1'  Run Keywords
        ...  Append To List  ${RAE_parameters}  ${ALD['parameters']['antLatitude']}
        ...  AND  Append To List  ${RAE_parameters}  ${ALD['parameters']['antLongitude']}
        ...  AND  Append To List  ${RAE_parameters}  ${ALD['parameters']['antAltitude']}
        ...  AND  Append To List  ${RAE_parameters}  ${ALD['parameters']['antBearing']}
        ...  AND  Append To List  ${RAE_parameters}  ${ALD['parameters']['mechanicalAngle']}
    END
    FOR  ${parameter}  IN  @{RAE_parameters}
        ${data_type}=  Evaluate  type(${parameter})
        ${data_type_str}=  Convert To String  ${data_type}
        Run Keyword If  "${data_type_str}"=="<class 'int'>" or "${data_type_str}"=="<class 'float'>"
        ...  Log  The data received from RAE is correct: ${parameter}  console=${true}
        ...  ELSE  Fail  msg=${data_type_str} Data type is not correct
    END

Select Random RET
    [Documentation]  Keyword returning distName to randomly selected RET.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...
    ...  {ALD_R_RETs}= [/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-5,
    ...                 /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-6,
    ...                 /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-7,...]
    ...  {chosen_RET}= [/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-6]
    ...
    [Arguments]  ${ALD_R_RETs}
    ${chosen_RET}=  Evaluate  random.choice(${ALD_R_RETs})  random
    ${ret_parameters}=  admin.get managed objects  ALD_R
    FOR  ${ret}  IN  @{ret_parameters}
        ${ignore}  ${ald_r}=  Split String From Right  ${ret['distName']}  separator=APEQM_R-1/
        Run Keyword If  '${ret['distName']}'=='${chosen_RET}'
        ...  Log  Random choice for RET: ${ald_r} (serialNumber:${ret['parameters']['serialNumber']})  console=${true}
    END
    [Return]  ${chosen_RET}

Select Random RAE
    [Documentation]  Keyword returning distName to randomly selected RAE.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...
    ...  {ALD_R_RETs}= [/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-5,
    ...                 /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-6,
    ...                 /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-7,...]
    ...  {chosen_RAE}= [/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-6]
    ...
    [Arguments]  ${ALD_R_RAEs}
    ${chosen_RAE}=  Evaluate  random.choice(${ALD_R_RAEs})  random
    ${rae_parameters}=  admin.get managed objects  ALD_R
    FOR  ${rae}  IN  @{rae_parameters}
        ${ignore}  ${ald_r}=  Split String From Right  ${rae['distName']}  separator=APEQM_R-1/
        Run Keyword If  '${rae['distName']}'=='${chosen_RAE}'
        ...  Log  Random choice for RAE: ${ald_r} (serialNumber:${rae['parameters']['serialNumber']})  console=${true}
    END
    [Return]  ${chosen_RAE}

Select Random MHA
    [Documentation]  Keyword returning distName to randomly selected MHA.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...
    ...  {ALD_R_MHAs}= [/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-1,
    ...                 /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-2,
    ...                 /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-3,...]
    ...  {chosen_MHA}= [/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/ALD_R-3]
    ...
    [Arguments]  ${ALD_R_MHAs}
    ${chosen_MHA}=  Evaluate  random.choice(${ALD_R_MHAs})  random
    ${mha_parameters}=  admin.get managed objects  ALD_R
    FOR  ${mha}  IN  @{mha_parameters}
        ${ignore}  ${ald_r}=  Split String From Right  ${mha['distName']}  separator=APEQM_R-1/
        Run Keyword If  '${mha['distName']}'=='${chosen_MHA}'
        ...  Log  Random choice for MHA: ${ald_r} (serialNumber:${mha['parameters']['serialNumber']})  console=${true}
    END
    [Return]  ${chosen_MHA}

Select Random LNA
    ${LNA_random}=   Evaluate  random.randint(1, 2)  modules=random
    [Return]  ${LNA_random}

Mapping ALD With Loglinks
    [Documentation]  This keyword maps selected ALD with corresponded loglinks
    ...  **Author:** mateusz.gadek@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  Mapping ALD With Loglinks  ALD_A-3
    [Arguments]  ${selected_ald}
    ${loglink_list_firstEP}=  Create List
    ${loglink_list_secondEP}=  Create List

    ${loglink_params}=  admin.get managed objects  LOGLINK_A
    FOR  ${loglink}  IN  @{loglink_params}
        ${FIRST_ENDPOINT}=  Set Variable  ${loglink['parameters']['firstEndpointDN']}
        ${ALD_LOGLINK}=  Run Keyword And Return Status  Should Contain  ${FIRST_ENDPOINT}  ${selected_ald}
        Run Keyword If  ${ALD_LOGLINK}==${TRUE}
        ...  Append To List  ${loglink_list_firstEP}  ${loglink['distName']}
    END
    FOR  ${loglink}  IN  @{loglink_params}
        ${SECOND_ENDPOINT}=  Set Variable  ${loglink['parameters']['secondEndpointDN']}
        ${ALD_LOGLINK}=  Run Keyword And Return Status  Should Contain  ${SECOND_ENDPOINT}  ${selected_ald}
        Run Keyword If  ${ALD_LOGLINK}==${TRUE}
        ...  Append To List  ${loglink_list_secondEP}  ${loglink['distName']}
    END
    ${loglink_list}=  Combine Lists  ${loglink_list_firstEP}  ${loglink_list_secondEP}
    ${loglink_list}=  Remove Duplicates  ${loglink_list}
    ${LOGLINK_ID_LIST}=  Create List
    FOR  ${i}  IN  @{loglink_list}
        ${LOGLINK_ID}=  Evaluate  re.search(r'LOGLINK_A-(\\d+)','''${i}''').group(1)  re
        Append To List  ${LOGLINK_ID_LIST}  ${LOGLINK_ID}
    END
    [Return]  ${LOGLINK_ID_LIST}

Create Delta Remove For Selected ALD
    [Documentation]  This keyword create delta commissioning which remove ALD and objects related with this ALD.
    [Arguments]  ${chosen_ald}  ${deviceType}
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
    ${ALD_A}=  Get From Dictionary  ${ALD_R_to_ALD_A}  ${chosen_ald}
    ${ignore}  ${ALD_A_TO_MAP}  Split String From Right  ${ALD_A}  separator=/  max_split=1
    ${ID}=   Evaluate  re.search(r'ALD_A-(\\d+)','''${ALD_A}''').group(1)  re
    ${delta_ald}  Set Variable    ${deviceType}_remove
    admin.create delta  ${delta_ald}
    ${LOGLINK_LIST}=  Mapping ALD With Loglinks  ${ALD_A_TO_MAP}
    FOR  ${i}  IN  @{LOGLINK_LIST}
    admin.append managed object to delta  MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/LOGLINK-${i}  delete  ${delta_ald}
    END
    admin.append managed object to delta  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-${id}  delete  ${delta_ald}
    admin.get delta  ${delta_ald}
    ${json_path}=  Set Variable  ${RESULTS}/delete_${deviceType}_obj.json
    admin.save delta  ${json_path}  delta_id=${delta_ald}
    admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Log  Reset counter after applying delta: ${post_action_reset_number}  console=${True}
    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
    Run Keyword If  ${counter_diff}!=${0}
    ...  Fail  msg=Detected unexpected BTS reset
    Check If Selected ALD Is Removed  ${chosen_ald}

Check If Selected ALD Is Removed
    [Arguments]  ${ald_r}
    ${reduced_path}=  Should Match Regexp  ${ald_r}  ALD_R-\\d+
    ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
    ${verdict}  ${output}=  Run Keyword And Ignore Error  Get From Dictionary  ${ALD_R_to_ALD_A}  ${ald_r}
    Run Keyword If  '${output}'=='None'
    ...  Log  ${reduced_path} was removed properly from commissioning  console=${True}
    ...  ELSE  Fail   message=ALD was not removed

Create Delta Remove For ALD
    [Documentation]  This keyword remove ALD depending on device type (MHA, RET or all ALDs)
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  Create Delta Remove For ALD  ${ALD_R_RETs}  deviceType=RET
    ...  Create Delta Remove For ALD  ${ALD_R_MHAs}  deviceType=MHA
    ...  Create Delta Remove For ALD  ${ALD_R_ALL}  deviceType=ALL
    ...
    [Arguments]  ${ALD_R}  ${deviceType}
    Run Keyword If  '${deviceType}'=='RET'  Run Keywords
    ...  Log  Delta preparation for all ${deviceType} devices
    ...  AND  Prepare Appropriate Delta File  ${ALD_R}  ${deviceType}
    ...  ELSE IF  '${deviceType}'=='MHA'  Run Keywords
    ...  Log  Delta preparation for all ${deviceType} devices
    ...  AND  Prepare Appropriate Delta File  ${ALD_R}  ${deviceType}
    ...  ELSE IF  '${deviceType}'=='ALL'  Run Keywords
    ...  Log  Delta preparation for all ALDs
    ...  AND  Prepare Appropriate Delta File  ${ALD_R}  ${deviceType}

Prepare Appropriate Delta File
    [Arguments]  ${ALD_R}  ${deviceType}
    ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
    ${delta_del}  Set Variable  ${deviceType}_ALD_remove
    admin.create delta  ${delta_del}
    FOR  ${ald}  IN  @{ALD_R}
        ${ALD_A}=  Get From Dictionary  ${ALD_R_to_ALD_A}  ${ald}
        ${ID}=   Evaluate  re.search(r'ALD_A-(\\d+)','''${ALD_A}''').group(1)  re
        Log  ALD-${ID} will be removed from configuration  console=${true}
        admin.append managed object to delta  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-${ID}  delete  ${delta_del}
    END
    ${loglink_list}=  admin.get managed objects  LOGLINK_A
    FOR  ${loglink}  IN  @{loglink_list}
        ${LOGLINK_DISTNAME}=  Set Variable  ${loglink['distName']}
        ${LOGLINK_ID}=   Evaluate  re.search(r'LOGLINK_A-(\\d+)','''${LOGLINK_DISTNAME}''').group(1)  re
        Log  LOGLINK-${LOGLINK_ID} will be removed from configuration  console=${true}
        admin.append managed object to delta  MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/LOGLINK-${LOGLINK_ID}  delete  ${delta_del}
    END
    admin.get delta  ${delta_del}
    ${json_path}=  Set Variable  ${RESULTS}/delete_${deviceType}_ALD_obj.json
    admin.save delta  ${json_path}  delta_id=${delta_del}
    admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}

Get First Unused Passdev Number
    [Documentation]  This keyword return first free PASSDEV ID
    ${passdev}=  admin.get managed objects  PASSDEV_A
    ${passdev_ids_list}   Create List
    FOR  ${passd}  IN  @{passdev}
        ${id}=  Evaluate  re.search(r'PASSDEV_A-(\\d+)','''${passd}''').group(1)  re
        ${pass_dev_num_int}  Convert To Integer  ${id}
        Append To List   ${passdev_ids_list}  ${pass_dev_num_int}
    END
    Run Keyword If  ${passdev_ids_list}==@{empty}
    ...   Append To List  ${passdev_ids_list}  ${0}
    ${free_passdev_id}=  Evaluate  max(${passdev_ids_list})+1
    ${free_passdev_id}  Convert To String  ${free_passdev_id}
    [Return]    ${free_passdev_id}

Get First Unused Loglink
    [Documentation]   This keyword return first free loglink ID
    ${loglink_a_param}=  admin.get managed objects  LOGLINK_A
    ${loglink_numbers}=  Create List
    FOR  ${loglink}  IN  @{loglink_a_param}
        ${id}=  Evaluate  re.search(r'LOGLINK_A-(\\d+)','''${loglink}''').group(1)  re
        ${loglink_num_int}  Convert To Integer  ${id}
        Append To List   ${loglink_numbers}  ${loglink_num_int}
    END
    Run Keyword If  ${loglink_numbers}==@{empty}
    ...   Append To List  ${loglink_numbers}  ${0}
    ${free_loglink_id}=  Evaluate  max(${loglink_numbers})+1
    ${free_loglink_id}  Convert To String  ${free_loglink_id}
    [Return]    ${free_loglink_id}

Change RETU Parameters
    [Arguments]  ${ALD_R_RETs}
    Mapping ALD_R to RETU_R
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    FOR  ${RET}  IN  @{ALD_R_RETs}
        ${ALD_R}=  Should Match Regexp  ${RET}  ALD_R-\\d+
        Log  New angle parameters for ${ALD_R}/RETU_R-1  console=${true}
        ${my_ret_param}=  Get RETU Parameters  ${RET}
        ${ret_angle}  ${ret_maxAngle}  ${ret_minAngle}  ${ret_mechAngle}  Get RETU Angles  ${my_ret_param}
        ${new_angle}  ${new_mechAngle}  Generate New Valid Angle And MechanicalAngle  ${ret_angle}  ${ret_maxAngle}  ${ret_minAngle}  ${ret_mechAngle}
        ${new_angle}=  Convert To Number  ${new_angle}
        ${new_mechAngle}=  Convert To Number  ${new_mechAngle}
        ${ret_minAngle}=  Convert To Number  ${ret_minAngle}
        ${ret_maxAngle}=  Convert To Number  ${ret_maxAngle}
        Send Tilt Angle  ${RET}  ${new_angle}
        Send MechanicalAngle  ${RET}  ${new_mechAngle}
        Calibrate Tilt  ${RET}
        ${my_ret_param}=  Get RETU Parameters  ${RET}
        ${read_ret_angle}  ${read_ret_maxAngle}  ${read_ret_minAngle}  ${read_ret_mechanicalAngle}  Get RETU Angles  ${my_ret_param}
        ${read_ret_angle}=  Convert To Number  ${read_ret_angle}
        ${read_ret_maxAngle}=  Convert To Number  ${read_ret_maxAngle}
        ${read_ret_minAngle}=  Convert To Number  ${read_ret_minAngle}
        ${read_ret_mechanicalAngle}=  Convert To Number  ${read_ret_mechanicalAngle}
        Should Be Equal As Numbers  ${new_angle}  ${read_ret_angle}
        Should Be Equal As Numbers  ${new_mechAngle}  ${read_ret_mechanicalAngle}
        Should Be Equal As Numbers  ${ret_minAngle}  ${read_ret_minAngle}
        Should Be Equal As Numbers  ${ret_maxAngle}  ${read_ret_maxAngle}
    END
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Log  Reset counter after applying delta: ${post_action_reset_number}  console=${True}
    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
    Run Keyword If  ${counter_diff}!=${0}
    ...  Fail  msg=Detected unexpected BTS reset

Select New Angle Range
    [Arguments]  ${confFile_set}  ${current_angle_range}
    ${ranges}=  Get Dictionary Keys  ${confFile_set}
    ${new_angle_range}=  Evaluate  random.choice(${ranges})  random
    ${input_file}=  Get From Dictionary  ${confFile_set}  ${new_angle_range}
    Should Not Be Equal  ${new_angle_range}  ${current_angle_range}
    ${range_file_dict}=  Create Dictionary  ${new_angle_range}=${input_file}
    [Return]  ${range_file_dict}

Send Tilt Angle
    [Arguments]  ${chosen_RET}  ${generated_ret_angle}
    ${ignore}  ${reduced_path}  Split String From Right  ${chosen_RET}  separator=MRBTS_R-1/
    ${status}  Run Keyword And Return Status  admin.set tilt angle  MRBTS-${MRBTS_ID}/${reduced_path}/RETU_R-1  ${generated_ret_angle}
    Run Keyword If  ${status}
    ...  Log  Sending tilt angle for MRBTS-${MRBTS_ID}/${reduced_path}/RETU_R-1 - completed  console=${true}
    ...  ELSE  Fail  msg=RET angle value change for MRBTS-${MRBTS_ID}/${reduced_path}/RETU_R-1 failed
    Sleep  10s

Send MechanicalAngle
    [Arguments]  ${chosen_RET}  ${generated_ret_mechanicalAngle}
    ${ignore}  ${reduced_path}  Split String From Right  ${chosen_RET}  separator=MRBTS_R-1/
    ${status}  Run Keyword And Return Status  admin.configure tilt  ${chosen_RET}/RETU_R-1  tilt_angle=${generated_ret_mechanicalAngle}
    Run Keyword If  ${status}
    ...  Log  Sending mechanical angle for MRBTS-${MRBTS_ID}/${reduced_path}/RETU_R-1 - completed  console=${true}
    ...  ELSE  Fail  msg=RET mechanical angle value change for MRBTS-${MRBTS_ID}/${reduced_path}/RETU_R-1 failed
    Sleep  10s

Calibrate Tilt
    [Arguments]  ${chosen_RET}
    ${ignore}  ${reduced_path}  Split String From Right  ${chosen_RET}  separator=MRBTS_R-1/
    ${status}  Run Keyword And Return Status  admin.calibrate tilt  MRBTS-${MRBTS_ID}/${reduced_path}/RETU_R-1  timeout=240
    Run Keyword If  ${status}
    ...  Log  RET calibration for MRBTS-${MRBTS_ID}/${reduced_path}/RETU_R-1 - completed  console=${true}
    ...  ELSE  Fail  msg=RET calibration for MRBTS-${MRBTS_ID}/${reduced_path}/RETU_R-1 failed
    Sleep  10s

Get RETU Parameters
    [Arguments]  ${chosen_RET}
    ${ret_parameters}=  admin.get managed objects  RETU_R
    FOR  ${ret}  IN  @{ret_parameters}
        Run Keyword IF  not '${ret['distName']}'=='${chosen_RET}/RETU_R-1'
        ...  Remove Values From List  ${ret_parameters}  ${ret}
    END
    [Return]  ${ret_parameters}

Get RETU Angles
    [Arguments]  ${my_ret_param}
    FOR  ${ret}  IN  @{my_ret_param}
        ${ret_angle}=  Set Variable  ${ret['parameters']['angle']}
        ${ret_maxAngle}=  Set Variable  ${ret['parameters']['maxAngle']}
        ${ret_minAngle}=  Set Variable  ${ret['parameters']['minAngle']}
        ${ret_mechanicalAngle}=  Set Variable  ${ret['parameters']['mechanicalAngle']}
    END
    [Return]  ${ret_angle}  ${ret_maxAngle}  ${ret_minAngle}  ${ret_mechanicalAngle}

Generate New Valid Angle And MechanicalAngle
    [Arguments]  ${ret_angle}  ${ret_maxAngle}  ${ret_minAngle}  ${ret_mechanicalAngle}
    ${status}  ${generated_ret_angle}=  Run Keyword And Ignore Error
    ...  Wait Until Keyword Succeeds  5x  2s  Generate Random RET Angle Value  ${ret_angle}  ${ret_maxAngle}  ${ret_minAngle}
    Run Keyword If  '${status}'=='PASS'  Log  Generated RETU angle: ${generated_ret_angle}  console=${true}
    ${status}  ${generated_ret_mechanicalAngle}=  Run Keyword And Ignore Error
    ...  Wait Until Keyword Succeeds  5x  2s  Generate Random RET MechanicalAngle Value  ${ret_mechanicalAngle}
    Run Keyword If  '${status}'=='PASS'  Log  Generated RETU mechanical angle: ${generated_ret_mechanicalAngle}  console=${true}
    [Return]  ${generated_ret_angle}  ${generated_ret_mechanicalAngle}

Generate Random RET Angle Value
    [Arguments]  ${ret_angle}  ${ret_maxAngle}  ${ret_minAngle}
    ${new_ret_angle}=  Evaluate  round(random.uniform(${ret_minAngle}, ${ret_maxAngle}),1)  modules=random
#    ${new_ret_angle}=  Evaluate  random.randint(${ret_minAngle}, ${ret_maxAngle})  modules=random
    ${ret_angle_converted}=  Convert To Number  ${ret_angle}
    ${new_ret_angle_converted}=  Convert To Number  ${new_ret_angle}
    Should Not Be Equal As Numbers  ${ret_angle_converted}  ${new_ret_angle_converted}
    ${generated_ret_angle}=  Convert To String  ${new_ret_angle}
    [Return]  ${generated_ret_angle}

Generate Random RET MechanicalAngle Value
    [Arguments]  ${ret_mechanicalAngle}
    ${new_ret_mechanicalAngle}=  Evaluate  round(random.uniform(-90, 90),1)  modules=random
#    ${new_ret_mechanicalAngle}=  Evaluate  random.randint(-90, 90)  modules=random
    ${ret_mechanicalAngle_converted}=  Convert To Number  ${ret_mechanicalAngle}
    ${new_ret_mechanicalAngle_converted}=  Convert To Number  ${new_ret_mechanicalAngle}
    Should Not Be Equal As Numbers  ${new_ret_mechanicalAngle_converted}  ${ret_mechanicalAngle_converted}
    ${generated_ret_mechanicalAngle}=  Convert To String  ${new_ret_mechanicalAngle}
    [Return]  ${generated_ret_mechanicalAngle}

ALD Connection Mapping
    ${loglink_r_conf}=  Get Loglink List With linkModeConfiguration On True
    ${conf}=  Create List
    FOR  ${item}  IN  @{loglink_r_conf}
        ${loglink_r_param}=  admin.get parameters  ${item}
        ${ald_id_conf_dist}=  Get From Dictionary  ${loglink_r_param}  secondEndpointDN
        ${dist_RMOD_conf}=  Get From Dictionary  ${loglink_r_param}  firstEndpointDN
        ${RMOD_conf}=  Get Regexp Matches  ${ald_id_conf_dist}  RMOD_R-\\d+
        Run Keyword If  ${RMOD_conf}
        ...  Append To List  ${conf}  ${RMOD_conf[0]}
        ${RMOD_conf_1}=  Get Regexp Matches  ${dist_RMOD_conf}  RMOD_R-\\d+
        Run Keyword If  ${RMOD_conf_1}
        ...  Append To List  ${conf}  ${RMOD_conf_1[0]}
        ${ald_id_conf}=  Get Regexp Matches  ${ald_id_conf_dist}  ALD_R-\\d+
        Run Keyword If  ${ald_id_conf}
        ...  Append To List  ${conf}  ${ald_id_conf[0]}
        ${ald_id_conf_1}=  Get Regexp Matches  ${dist_RMOD_conf}  ALD_R-\\d+
        Run Keyword If  ${ald_id_conf_1}
        ...  Append To List  ${conf}  ${ald_id_conf_1[0]}
    END
    ${loglink_r_dc}=  Get Loglink List With linkModeDC On True
    ${dc}=  Create List
    FOR  ${item}  IN  @{loglink_r_dc}
        ${loglink_r_param}=  admin.get parameters  ${item}
        ${ALD_id_dc_dist}=  Get From Dictionary  ${loglink_r_param}  secondEndpointDN
        ${dist_RM_DC}=  Get From Dictionary  ${loglink_r_param}  firstEndpointDN
        ${RMOD_DC}=  Get Regexp Matches  ${ALD_id_dc_dist}  RMOD_R-\\d+
        Run Keyword If  ${RMOD_DC}
        ...  Append To List  ${dc}  ${RMOD_DC[0]}
        ${RMOD_DC}=  Get Regexp Matches  ${dist_RM_DC}  RMOD_R-\\d+
        Run Keyword If  ${RMOD_DC}
        ...  Append To List  ${dc}  ${RMOD_DC[0]}
        ${ALD_id_DC}=  Get Regexp Matches  ${ALD_id_dc_dist}  ALD_R-\\d+
        Run Keyword If  ${ALD_id_DC}
        ...  Append To List  ${dc}  ${ALD_id_DC[0]}
        ${ALD_id_DC}=  Get Regexp Matches  ${dist_RM_DC}  ALD_R-\\d+
        Run Keyword If  ${ALD_id_DC}
        ...  Append To List  ${dc}  ${ALD_id_DC[0]}
    END
    [Return]  ${dc}  ${conf}

Get Loglink List With linkModeConfiguration On True
    ${loglink_r_linkModeConfiguration_true}=  Create List
    ${loglink_parameters}=  admin.get managed objects  LOGLINK_R
    FOR  ${loglink}  IN  @{loglink_parameters}
        Run Keyword If  '${loglink['parameters']['linkModeConfiguration']}'=='True'
        ...  Append To List  ${loglink_r_linkModeConfiguration_true}  ${loglink['distName']}
    END
    [Return]  ${loglink_r_linkModeConfiguration_true}

Get Loglink List With linkModeDC On True
    ${loglink_r_linkModeDC_true}=  Create List
    ${loglink_parameters}=  admin.get managed objects  LOGLINK_R
    FOR  ${loglink}  IN  @{loglink_parameters}
        Run Keyword If  '${loglink['parameters']['linkModeDC']}'=='True'
        ...  Append To List  ${loglink_r_linkModeDC_true}  ${loglink['distName']}
    END
    [Return]  ${loglink_r_linkModeDC_true}

Check ALD With Rmod Connection
    [Documentation]  This keyword return ALD lists which are configured and get DC from selected RM module.
    [Arguments]  ${rmod}
    ${DC}  ${conf}  ALD Connection Mapping
    ${lenDC}=  Get Length  ${DC}
    ${lenConf}=  Get Length  ${conf}
    ${ALD_DC}  Create List
    ${ALD_conf}  Create List
    FOR  ${i}  IN RANGE  0  ${lenDC}-1
        Run Keyword If  '${DC[${i}]}'=='${rmod}'
        ...  Append To List  ${ALD_DC}  ${DC[${i}+1]}
    END
    FOR  ${i}  IN RANGE   0  ${lenConf}-1
       Run Keyword If  '${conf[${i}]}'=='${rmod}'
       ...  Append to List  ${ALD_conf}   ${conf[${i}+1]}
    END
    [Return]  ${ALD_DC}  ${ALD_conf}

Check ALD State After RM Lock
    [Documentation]  This keyword check all ald state after RM lock.
    [Arguments]  ${ALD_DC}  ${ALD_conf}
    ${ALD_list}=  admin.get ids for all  ALD
    ${beginning}=  Get Regexp Matches  ${ALD_list[0]}  (.*)\/EQM_R-\\d+\/APEQM_R-\\d+
    ${ALD_state_disabled}=  Combine Lists  ${ALD_DC}  ${ALD_conf}
    ${ALD_state_disabled}=  Remove Duplicates  ${ALD_state_disabled}
    ${ALD_state_enabled}=  Remove Duplicates  ${ALD_list}
    ${ALD_state_disabled_full_path}=  Create List
    FOR  ${i}  IN  @{ALD_state_disabled}
        ${ALD_disabled}=  Convert To String  ${beginning[0]}/${i}
        Remove Values From List  ${ALD_state_enabled}  ${ALD_disabled}
        Append To List  ${ALD_state_disabled_full_path}  ${ALD_disabled}
    END
    FOR  ${i}  IN  @{ALD_state_enabled}
        ${state}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  5min  30s  admin.assert  ALD  ${i}  ${ALD_expected_states}
        ${ald_r}=  Should Match Regexp  ${i}  ALD_R-\\d+
        Run Keyword If  ${state} != True
        ...  Fail  msg=Incorrect ${ald_r} state
        ...  ELSE  Log  ${ald_r} state is correct  console=${true}
    END
    FOR  ${i}  IN  @{ALD_state_disabled_full_path}
        ${state}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  5min  30s  admin.assert  ALD  ${i}  ${ALD_expected_state_dependency}
        ${ald_r}=  Should Match Regexp  ${i}  ALD_R-\\d+
        Run Keyword If  ${state} != True
        ...  Fail  msg=Incorrect ${ald_r} state
        ...  ELSE  Log  ${ald_r} state is correct  console=${true}
    END

DC Voltage Switching OFF
    [Documentation]  This keyword create delta commissioning which switching off DC voltage
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${antl_rmod}=  Mapping ANTL_A To RMOD_A
    ${delta_id_off}  Set Variable  dc_voltage_off
    admin.create delta  ${delta_id_off}
    ${dn_prefix}=  Catenate  SEPARATOR=  MRBTS-${MRBTS_ID}/  EQM-1/  APEQM-1/
    FOR  ${key}  IN  @{antl_rmod.keys()}
        ${rmod_antenna}=  Get From Dictionary  ${antl_rmod}  ${key}
        Log  ----- DC OFF on RMOD-${rmod_antenna[0]} ANTL-${rmod_antenna[1]}   console=${True}
        ${ANTL_DN}=  Catenate  SEPARATOR=  ${dn_prefix}  RMOD-${rmod_antenna[0]}/  ANTL-${rmod_antenna[1]}
        admin.append parameter update to delta  ${ANTL_DN}  dcVoltage  OFF  ${delta_id_off}
    END
    ${rsl_rmod}=  Mapping RMOD_A To RSL_A
    FOR  ${key}  IN  @{rsl_rmod.keys()}
        Log   ----- DC OFF on RMOD-${key} RSL-${rsl_rmod["${key}"]}   console=${True}
        ${RSL_DN}=  Catenate  SEPARATOR=  ${dn_prefix}  RMOD-${key}/  RSL-${rsl_rmod["${key}"]}
        admin.append parameter update to delta  ${RSL_DN}   dcVoltageEnabled   false  ${delta_id_off}
    END
    admin.get delta  ${delta_id_off}
    ${json_path}=  Set Variable  ${RESULTS}/delta_dc_off.json
    admin.save delta  ${json_path}  ${delta_id_off}
    admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}  ${should_activate}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Log  Reset counter after applying delta: ${post_action_reset_number}  console=${True}
    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
    Run Keyword If  ${counter_diff}!=${0}
    ...  Fail  msg=Detected unexpected BTS reset

HDLC Switching OFF
    [Documentation]  This keyword create delta commissioning which switching off HDLC
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${antl_rmod}=  Mapping ANTL_A To RMOD_A
    #  RMOD_excluded_pc contains produck codes of radio modules not supporting HDLC hdlcCommunicationAllowed
    #  RMs from this list will be skipped during HDLC switching and alarm checks
    # AVQL, AZHN
    @{RMOD_excluded_pc}=  Set Variable  476204A  475547A
    # Only ANT1 and ANT2 is supporting HDLC
    # AHPMDA
    @{RMOD_twoant_pc}=  Set Variable  473997A  XXXXXXA
    # Only ANT1 is supporting HDLC
    # AZQW, FZNI
    @{RMOD_oneant_pc}=  Set Variable  475742A  472652A
    ${RMOD_A_objects}=  admin.get managed objects  RMOD_A
    ${RMOD_A_product_codes}=  Create Dictionary
    FOR  ${item}  IN  @{RMOD_A_objects}
        Set To Dictionary  ${RMOD_A_product_codes}  ${item['distName']}  ${item['parameters']['prodCodePlanned']}
    END
    ${excluded_RMOD_A}=  Create List
    ${twoant_RMOD_A}=  Create List
    ${oneant_RMOD_A}=  Create List
    FOR  ${item}  IN  @{RMOD_A_product_codes.keys()}
        ${rmod}=  Get From Dictionary  ${RMOD_A_product_codes}  ${item}
        ${rmod}=  Get Substring  ${rmod}  0  7
        ${ignore}  ${dn}  Split String  ${item}  separator=SCF-1/  max_split=1
        Run Keyword If  $rmod in $RMOD_excluded_pc
        ...  Append To List  ${excluded_RMOD_A}  ${dn}
        Run Keyword If  $rmod in $RMOD_twoant_pc
        ...  Append To List  ${twoant_RMOD_A}  ${dn}
        Run Keyword If  $rmod in $RMOD_oneant_pc
        ...  Append To List  ${oneant_RMOD_A}  ${dn}
    END
    Set Test Variable  ${excluded_RMOD_A}
    Set Test Variable  ${twoant_RMOD_A}
    Set Test Variable  ${oneant_RMOD_A}

    ${delta_id_off}  set variable  hdlc_off
    admin.create delta  ${delta_id_off}
    ${dn_prefix}=  Catenate  SEPARATOR=  MRBTS-${MRBTS_ID}/  EQM-1/  APEQM-1/
    ${dn_a_prefix}=  Catenate  SEPARATOR=  MRBTS_A-${MRBTS_ID}/  EQM_A-1/  APEQM_A-1/
    ${parameter}=  Set Variable  hdlcCommunicationAllowed
    ${special_RMOD_A}=  Combine Lists  ${excluded_RMOD_A}  ${twoant_RMOD_A}  ${oneant_RMOD_A}
    ${selant_RMOD_A}=  Combine Lists  ${twoant_RMOD_A}  ${oneant_RMOD_A}
    Set Test variable  ${special_RMOD_A}
    Set Test variable  ${selant_RMOD_A}
    FOR  ${key}  IN  @{antl_rmod.keys()}
        ${rmod_antenna}=  Get From Dictionary  ${antl_rmod}  ${key}
        ${RMOD_A_DN}=  Catenate  SEPARATOR=  ${dn_a_prefix}  RMOD_A-${rmod_antenna[0]}
        ${RMOD_DN}=  Catenate  SEPARATOR=  ${dn_prefix}  RMOD-${rmod_antenna[0]}
        ${ANTL_DN}=  Catenate  SEPARATOR=  ${dn_prefix}  RMOD-${rmod_antenna[0]}/  ANTL-${rmod_antenna[1]}
        ${ANTL_DN_2}=  Catenate  SEPARATOR=  ${dn_prefix}  RMOD-${rmod_antenna[0]}/  ANTL-2
        Run Keyword If  $RMOD_A_DN not in $special_RMOD_A    Run Keywords
        ...  Log  ----- HDLC OFF on RMOD-${rmod_antenna[0]} ANTL-${rmod_antenna[1]}   console=${True}
        ...  AND
        ...  admin.append parameter update to delta  ${ANTL_DN}  ${parameter}  false  ${delta_id_off}
        Run Keyword If  $RMOD_A_DN in $selant_RMOD_A and ${rmod_antenna[1]}==1  Run Keywords
        ...  Log  ----- HDLC OFF on RMOD-${rmod_antenna[0]} ANTL-${rmod_antenna[1]}   console=${True}
        ...  AND
        ...  admin.append parameter update to delta  ${ANTL_DN}  ${parameter}  false  ${delta_id_off}
        Run Keyword If  $RMOD_A_DN in $twoant_RMOD_A and ${rmod_antenna[1]}==3  Run Keywords
        ...  Log  ----- HDLC OFF on RMOD-${rmod_antenna[0]} ANTL-2   console=${True}
        ...  AND
        ...  admin.append parameter update to delta  ${ANTL_DN_2}  ${parameter}  false  ${delta_id_off}
    END

    ${rsl_rmod}=  Mapping RMOD_A To RSL_A
    FOR  ${key}  IN  @{rsl_rmod.keys()}
        Log   ----- HDLC OFF on RMOD-${key} RSL-${rsl_rmod["${key}"]}   console=${True}
        ${RSL_DN}=  Catenate  SEPARATOR=  ${dn_prefix}  RMOD-${key}/  RSL-${rsl_rmod["${key}"]}
        admin.append parameter update to delta  ${RSL_DN}  ${parameter}  false  ${delta_id_off}
    END
    admin.get delta  ${delta_id_off}
    ${json_path}=  Set Variable  ${RESULTS}/delta_dc_off.json
    admin.save delta  ${json_path}  ${delta_id_off}
    admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}  ${should_activate}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Log  Reset counter after applying delta: ${post_action_reset_number}  console=${True}
    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
    Run Keyword If  ${counter_diff}!=${0}
    ...  Fail  msg=Detected unexpected BTS reset

DC Voltage Switching ON
    [Documentation]  This keyword create delta commissioning which switching on DC voltage
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${antl_rmod}=  Mapping ANTL_A To RMOD_A
    ${delta_id_on}  set variable  dc_voltage_on
    admin.create delta  ${delta_id_on}
    ${dn_prefix}=  Catenate  SEPARATOR=  MRBTS-${MRBTS_ID}/  EQM-1/  APEQM-1/
    FOR  ${key}  IN  @{antl_rmod.keys()}
        ${rmod_antenna}=  Get From Dictionary  ${antl_rmod}  ${key}
        Log  ----- DC ON on RMOD-${rmod_antenna[0]} ANTL-${rmod_antenna[1]}   console=${True}
        ${ANTL_DN}=  Catenate  SEPARATOR=  ${dn_prefix}  RMOD-${rmod_antenna[0]}/  ANTL-${rmod_antenna[1]}
        admin.append parameter update to delta  ${ANTL_DN}  dcVoltage  AUTO  ${delta_id_on}
    END
    ${rsl_rmod}=  Mapping RMOD_A To RSL_A
    FOR  ${key}  IN  @{rsl_rmod.keys()}
        Log   ----- DC ON on RMOD-${key} RSL-${rsl_rmod["${key}"]}   console=${True}
        ${RSL_DN}=  Catenate  SEPARATOR=  ${dn_prefix}  RMOD-${key}/  RSL-${rsl_rmod["${key}"]}
        admin.append parameter update to delta  ${RSL_DN}   dcVoltageEnabled   true  ${delta_id_on}
    END
    admin.get delta  ${delta_id_on}
    ${json_path}=  Set Variable  ${RESULTS}/delta_dc_on.json
    admin.save delta  ${json_path}  ${delta_id_on}
    admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}  ${should_activate}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Log  Reset counter after applying delta: ${post_action_reset_number}  console=${True}
    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
    Run Keyword If  ${counter_diff}!=${0}
    ...  Fail  msg=Detected unexpected BTS reset

HDLC Switching ON
    [Documentation]  This keyword create delta commissioning which switching on HDLC
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${antl_rmod}=  Mapping ANTL_A To RMOD_A
    ${delta_id_on}  set variable  hdlc_on
    admin.create delta  ${delta_id_on}
    ${dn_prefix}=  Catenate  SEPARATOR=  MRBTS-${MRBTS_ID}/  EQM-1/  APEQM-1/
    ${dn_a_prefix}=  Catenate  SEPARATOR=  MRBTS_A-${MRBTS_ID}/  EQM_A-1/  APEQM_A-1/
    ${parameter}=  Set Variable  hdlcCommunicationAllowed
    FOR  ${key}  IN  @{antl_rmod.keys()}
        ${rmod_antenna}=  Get From Dictionary  ${antl_rmod}  ${key}
        ${RMOD_A_DN}=  Catenate  SEPARATOR=  ${dn_a_prefix}  RMOD_A-${rmod_antenna[0]}
        ${RMOD_DN}=  Catenate  SEPARATOR=  ${dn_prefix}  RMOD-${rmod_antenna[0]}
        ${ANTL_DN}=  Catenate  SEPARATOR=  ${dn_prefix}  RMOD-${rmod_antenna[0]}/  ANTL-${rmod_antenna[1]}
        Run Keyword If  $RMOD_A_DN not in $excluded_RMOD_A    Run Keywords
        ...  Log  ----- HDLC ON on RMOD-${rmod_antenna[0]} ANTL-${rmod_antenna[1]}   console=${True}
        ...  AND
        ...  admin.append parameter update to delta  ${ANTL_DN}  ${parameter}  true  ${delta_id_on}
        Run Keyword If  $RMOD_A_DN in $selant_RMOD_A and ${rmod_antenna[1]}==1  Run Keywords
        ...  Log  ----- HDLC ON on RMOD-${rmod_antenna[0]} ANTL-${rmod_antenna[1]}   console=${True}
        ...  AND
        ...  admin.append parameter update to delta  ${ANTL_DN}  ${parameter}  true  ${delta_id_on}
        Run Keyword If  $RMOD_A_DN in $twoant_RMOD_A and ${rmod_antenna[1]}==2  Run Keywords
        ...  Log  ----- HDLC ON on RMOD-${rmod_antenna[0]} ANTL-${rmod_antenna[1]}   console=${True}
        ...  AND
        ...  ${ANTL_DN}=  Catenate  SEPARATOR=  ${dn_prefix}  RMOD-${rmod_antenna[0]}/  ANTL-2
        ...  AND
        ...  admin.append parameter update to delta  ${ANTL_DN}  ${parameter}  false  ${delta_id_on}
    END
    ${rsl_rmod}=  Mapping RMOD_A To RSL_A
    FOR  ${key}  IN  @{rsl_rmod.keys()}
        Log   ----- HDLC ON on RMOD-${key} RSL-${rsl_rmod["${key}"]}   console=${True}
        ${RSL_DN}=  Catenate  SEPARATOR=  ${dn_prefix}  RMOD-${key}/  RSL-${rsl_rmod["${key}"]}
        admin.append parameter update to delta  ${RSL_DN}  ${parameter}  true  ${delta_id_on}
    END
    admin.get delta  ${delta_id_on}
    ${json_path}=  Set Variable  ${RESULTS}/delta_hdlc_on.json
    admin.save delta  ${json_path}  ${delta_id_on}
    admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}  ${should_activate}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Log  Reset counter after applying delta: ${post_action_reset_number}  console=${True}
    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
    Run Keyword If  ${counter_diff}!=${0}
    ...  Fail  msg=Detected unexpected BTS reset

DC Voltage Switch
    [Documentation]  This keyword create delta commissioning which switching on/off DC voltage
    ...  **Author:** tomasz.marchewka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------+----------------------------------------------------------------------------+
    ...  | switchType | Description                                                                |
    ...  +============+============================================================================+
    ...  | OFF        | Set dcVoltage - OFF on each ANTL and dcVoltageEnabled - false on each RSL  |
    ...  +------------+----------------------------------------------------------------------------+
    ...  | AUTO       | Set dcVoltage - AUTO on each ANTL and dcVoltageEnabled - true on each RSL  |
    ...  +------------+----------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  DC Voltage Switch  switchType=OFF
    ...  DC Voltage Switch  switchType=AUTO
    ...
    [Arguments]  ${switchType}
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${ANTL_A}=  Get ANTL_A List
    ${RSL_A}=  Get RSL_A List
    ${RMOD_ANTL_ID_ID}=  Create Dictionary
    FOR  ${ITEM}  IN  @{ANTL_A}
        ${ANTL_ID}=  Evaluate  re.search(r'ANTL_A-(\\d+)','''${ITEM}''').group(1)  re
        ${RMOD_ID}=  Evaluate  re.search(r'RMOD_A-(\\d+)','''${ITEM}''').group(1)  re
        ${reduced_path}=  Fetch From Right  ${ITEM}  APEQM_A-1/
        ${ID_ID}=  Create List
        Append To List  ${ID_ID}  ${RMOD_ID}  ${ANTL_ID}
        Set To Dictionary  ${RMOD_ANTL_ID_ID}  ${reduced_path}  ${ID_ID}
    END
#    FOR  ${ANTL}  IN  @{RMOD_ANTL_ID_ID.keys()}
#        ${rmodID_antlID}=  Get From Dictionary  ${RMOD_ANTL_ID_ID}  ${ANTL}
#        ${even_antl}=  Evaluate  (${rmodID_antlID[1]} % 2)==0
#        Run Keyword If  ${even_antl}
#        ...  Remove From Dictionary  ${RMOD_ANTL_ID_ID}  ${ANTL}
#    END
    Set Variable  ${RMOD_ANTL_ID_ID}
    ${RMOD_RSL_ID_ID}=  Create Dictionary
    FOR  ${ITEM}  IN  @{RSL_A}
        ${RSL_ID}=  Evaluate  re.search(r'RSL_A-(\\d+)','''${ITEM}''').group(1)  re
        ${RMOD_ID}=  Evaluate  re.search(r'RMOD_A-(\\d+)','''${ITEM}''').group(1)  re
        ${reduced_path}=  Fetch From Right  ${ITEM}  APEQM_A-1/
        ${ID_ID}=  Create List
        Append To List  ${ID_ID}  ${RMOD_ID}  ${RSL_ID}
        Set To Dictionary  ${RMOD_RSL_ID_ID}  ${reduced_path}  ${ID_ID}
    END
    Set Variable  ${RMOD_RSL_ID_ID}
    ${delta_dc}  Set Variable    dcVoltage_${switchType}
    admin.create delta  ${delta_dc}
    ${ANTL_DN}=  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_ID_ANTL_ID[0]}/ANTL-${RMOD_ID_ANTL_ID[1]}
    FOR  ${ITEM}  IN  @{RMOD_ANTL_ID_ID.keys()}
        ${RMOD_ID_ANTL_ID}=  Get From Dictionary  ${RMOD_ANTL_ID_ID}  ${ITEM}
        Run Keyword If  '${switchType}'=='OFF'  Run Keywords
        ...  Log  DC Voltage turn ${switchType} for RMOD-${RMOD_ID_ANTL_ID[0]}/ANTL-${RMOD_ID_ANTL_ID[1]}  console=${true}
        ...  AND
        ...  admin.append parameter update to delta  ${ANTL_DN}  dcVoltage  OFF  ${delta_dc}
        ...  ELSE IF  '${switchType}'=='AUTO'  Run Keywords
        ...  Log  DC Voltage turn ON for RMOD-${RMOD_ID_ANTL_ID[0]}/ANTL-${RMOD_ID_ANTL_ID[1]}  console=${true}
        ...  AND
        ...  admin.append parameter update to delta  ${ANTL_DN}  dcVoltage  AUTO  ${delta_dc}
    END
    ${RSL_DN}=  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_ID_RSL_ID[0]}/RSL-${RMOD_ID_RSL_ID[1]}
    FOR  ${ITEM}  IN  @{RMOD_RSL_ID_ID.keys()}
        ${RMOD_ID_RSL_ID}=  Get From Dictionary  ${RMOD_RSL_ID_ID}  ${ITEM}
        Run Keyword If  '${switchType}'=='OFF'  Run Keywords
        ...  Log  DC Voltage turn ${switchType} for RMOD-${RMOD_ID_RSL_ID[0]}/RSL-${RMOD_ID_RSL_ID[1]}  console=${true}
        ...  AND
        ...  admin.append parameter update to delta  ${RSL_DN}  dcVoltageEnabled  false  ${delta_dc}
        ...  ELSE IF  '${switchType}'=='AUTO'  Run Keywords
        ...  Log  DC Voltage turn ON for RMOD-${RMOD_ID_RSL_ID[0]}/RSL-${RMOD_ID_RSL_ID[1]}  console=${true}
        ...  AND
        ...  admin.append parameter update to delta  ${RSL_DN}  dcVoltageEnabled  true  ${delta_dc}
    END
    admin.get delta  ${delta_dc}
    ${json_path}=  Set Variable  ${RESULTS}/delta_${delta_dc}.json
    admin.save delta  ${json_path}  ${delta_dc}
    admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}  ${should_activate}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Log  Reset counter after applying delta: ${post_action_reset_number}  console=${True}
    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
    Run Keyword If  ${counter_diff}!=${0}
    ...  Fail  msg=Detected unexpected BTS reset

Make DC Settings Backup
    [Documentation]  Keyword create dictionaries with backup DC settings
    ${RSL_BACKUP}=  Create Dictionary
    ${ANTL_BACKUP}=  Create Dictionary
    ${RSL_A}=  admin.get managed objects  RSL_A
    ${RSL_regex}=  Set Variable  APEQM_A-\\d+/RMOD_A-\\d+/RSL_A-\\d+
    FOR  ${RSL}  IN  @{RSL_A}
        ${status}  ${rsl_param}=  Run Keyword And Ignore Error  Should Match Regexp  ${RSL['distName']}  ${RSL_regex}
        Run Keyword If  '${status}'=='PASS'  Set To Dictionary  ${RSL_BACKUP}  ${RSL['distName']}  ${RSL['parameters']['dcVoltageEnabled']}
    END
    ${ANTL_A}=  admin.get managed objects  ANTL_A
    ${ANTL_regex}=  Set Variable  APEQM_A-\\d+/RMOD_A-\\d+/ANTL_A-\\d+
    FOR  ${ANTL}  IN  @{ANTL_A}
        ${status}  ${antl_param}=  Run Keyword And Ignore Error  Should Match Regexp  ${ANTL['distName']}  ${ANTL_regex}
        Run Keyword If  '${status}'=='PASS'  Set To Dictionary  ${ANTL_BACKUP}  ${ANTL['distName']}  ${ANTL['parameters']['dcVoltage']}
    END
    Set Test Variable  ${RSL_BACKUP}
    Set Test Variable  ${ANTL_BACKUP}

Make HDLC Settings Backup
    [Documentation]  Keyword create dictionaries with backup HDLC settings
    ${RSL_BACKUP}=  Create Dictionary
    ${ANTL_BACKUP}=  Create Dictionary
    ${RSL_A}=  admin.get managed objects  RSL_A
    ${RSL_regex}=  Set Variable  APEQM_A-\\d+/RMOD_A-\\d+/RSL_A-\\d+
    FOR  ${RSL}  IN  @{RSL_A}
        ${status}  ${rsl_param}=  Run Keyword And Ignore Error  Should Match Regexp  ${RSL['distName']}  ${RSL_regex}
        Run Keyword If  '${status}'=='PASS'  Set To Dictionary  ${RSL_BACKUP}  ${RSL['distName']}  ${RSL['parameters']['hdlcCommunicationAllowed']}
    END
    ${ANTL_A}=  admin.get managed objects  ANTL_A
    ${ANTL_regex}=  Set Variable  APEQM_A-\\d+/RMOD_A-\\d+/ANTL_A-\\d+
    FOR  ${ANTL}  IN  @{ANTL_A}
        ${status}  ${antl_param}=  Run Keyword And Ignore Error  Should Match Regexp  ${ANTL['distName']}  ${ANTL_regex}
        Run Keyword If  '${status}'=='PASS'  Set To Dictionary  ${ANTL_BACKUP}  ${ANTL['distName']}  ${ANTL['parameters']['hdlcCommunicationAllowed']}
    END
    Set Test Variable  ${RSL_BACKUP}
    Set Test Variable  ${ANTL_BACKUP}

Restore DC Settings
    [Documentation]  Keyword applying delta with backup DC settings
    ${delta_restore_dc}=  Set Variable  dc_restore
    admin.create delta  ${delta_restore_dc}
    FOR  ${key}  IN  @{RSL_BACKUP.keys()}
        ${key_1}  Remove String  ${key}  _A
        ${key_1}  Fetch From Right  ${key_1}  SCF-1\/
        ${value}   Convert To string  ${RSL_backup["${key}"]}
        ${value}   Convert To Lowercase   ${value}
        admin.append parameter update to delta  ${key_1}  dcVoltageEnabled  ${value}  ${delta_restore_dc}
    END
    FOR  ${key}  IN  @{ANTL_BACKUP.keys()}
        ${key_1}  Remove String  ${key}  _A
        ${key_1}  Fetch From Right  ${key_1}  SCF-1\/
        ${value}   Convert To string  ${ANTL_backup["${key}"]}
        admin.append parameter update to delta  ${key_1}  dcVoltage  ${value}  ${delta_restore_dc}
    END
    admin.get delta  ${delta_restore_dc}
    ${json_path}=  Set Variable  ${RESULTS}/delta_${delta_restore_dc}.json
    admin.save delta  ${json_path}  ${delta_restore_dc}
    admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}

Restore HDLC Settings
    [Documentation]  Keyword applying delta with backup HDLC settings
    ${delta_restore_hdlc}=  Set Variable  hdlc_restore
    admin.create delta  ${delta_restore_hdlc}
    ${parameter}=  Set Variable  hdlcCommunicationAllowed
    FOR  ${key}  IN  @{RSL_BACKUP.keys()}
        ${key_1}  Remove String  ${key}  _A
        ${key_1}  Fetch From Right  ${key_1}  SCF-1\/
        ${value}   Convert To string  ${RSL_backup["${key}"]}
        ${value}   Convert To Lowercase   ${value}
        admin.append parameter update to delta  ${key_1}  ${parameter}  ${value}  ${delta_restore_hdlc}
    END
    FOR  ${key}  IN  @{ANTL_BACKUP.keys()}
        ${key_1}  Remove String  ${key}  _A
        ${key_1}  Fetch From Right  ${key_1}  SCF-1\/
        ${value}   Convert To string  ${ANTL_backup["${key}"]}
        ${value}   Convert To Lowercase   ${value}
        admin.append parameter update to delta  ${key_1}  ${parameter}  ${value}  ${delta_restore_hdlc}
    END
    admin.get delta  ${delta_restore_hdlc}
    ${json_path}=  Set Variable  ${RESULTS}/delta_${delta_restore_hdlc}.json
    admin.save delta  ${json_path}  ${delta_restore_hdlc}
    admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}

Get ANTL_A List
    ${ANTL_A}=  Create List
    ${antl_a_parameters}=  admin.get managed objects  ANTL_A
    ${regex}=  Set Variable  APEQM_A-\\d+\/RMOD_A-\\d+\/ANTL_A-\\d+
    FOR  ${antl_a_parameter}  IN  @{antl_a_parameters}
        ${status}  ${antl}=  Run Keyword And Ignore Error  Should Match Regexp  ${antl_a_parameter['distName']}  ${regex}
        Run Keyword If  '${status}'=='PASS'  Append To List  ${ANTL_A}  ${antl}
    END
    [Return]  ${ANTL_A}

Get RSL_A List
    ${RSL_A}=  Create List
    ${rsl_a_parameters}=  admin.get managed objects  RSL_A
    ${regex}=  Set Variable  APEQM_A-\\d+\/RMOD_A-\\d+\/RSL_A-\\d+
    FOR  ${rsl_a_parameter}  IN  @{rsl_a_parameters}
        ${status}  ${rsl}=  Run Keyword And Ignore Error  Should Match Regexp  ${rsl_a_parameter['distName']}  ${regex}
        Run Keyword If  '${status}'=='PASS'  Append To List  ${RSL_A}  ${rsl}
    END
    [Return]  ${RSL_A}

Get Antenna Alarm Sources
    [Documentation]  Keyword return ANTL without DC loglink
    Find All ANTLs and RSL with DC Loglink
    ${antl_rmod_}=  Mapping ANTL_A To RMOD_A
    ${keys_ant}  Get Dictionary Keys  ${DC_ANTL_LOGLINK}
    FOR  ${key}  IN  @{keys_ant}
       Remove From Dictionary  ${antl_rmod_}  ${key}
    END
    [Return]   ${antl_rmod_}

Set RSL Alarm Sources
    [Documentation]  Keyword read RSL alarm source
    ${rsl_without_ald}=  Get RSL Without DC Loglink
    ${RSL_ALARM_SOURCES}=  Create List
    FOR  ${key}  IN  @{rsl_without_ald.keys()}
        ${rsl_alarm_source}=   convert to string  ${source_beginning[0]}/RMOD-${key}/RSL-${rsl_without_ald["${key}"]}
        Append To List   ${RSL_ALARM_SOURCES}  ${rsl_alarm_source}
    END
    Set Test Variable   ${RSL_ALARM_SOURCES}

ALD Alarm Source
    [Documentation]  Keyword get ALD alarm source
    ${lna_source}=  Create List
    ${retu_source}=  Create List
    FOR  ${ALD_source}  IN  @{ALD_source_list}
      ${mha}  ${ret_source}  Check ALD Source  ${ALD_source}
      ${lna_source}  Combine Lists  ${lna_source}  ${mha}
      ${retu_source}  Combine Lists  ${retu_source}  ${ret_source}
    END
    ${ALDS_SOURCES}=  Combine Lists   ${lna_source}    ${retu_source}
    Set Test Variable   ${ALDS_SOURCES}

Check ALD Source
    [Documentation]  Keyword read what type ALD is alarm source
    [Arguments]   ${ALD_source}
    ${ret_source}=  Create List
    ${mha}=  Create List
    ${RETU_RAEU_ALARM_SOURCE}=  Create List
    ${ald_alarm_source}=  Create List
    FOR  ${key}  IN  @{ALD_source.keys()}
        ${ald_alarm_source}=  Set Variable If  '${ALD_source["${key}"]}' !='NULL'    ${source_beginning[0]}/ALD-${key}/LNA-${ALD_source["${key}"]}
        ${ret}=  Set Variable If   '${ALD_source["${key}"]}' == 'NULL'       ${key}
            Run Keyword If    '${ald_alarm_source}'!= 'None'
            ...   Append To List   ${mha}  ${ald_alarm_source}
       Run Keyword If   ${ret} != None  Set RETU And RAEU Id   ${ret}
       ${ret_source}  Combine Lists   ${ret_source}  ${RETU_RAEU_ALARM_SOURCE}
    END
    [Return]  ${mha}  ${ret_source}

Check Alarm 4142
   Run Keyword If  ${SOURCE_ACTIVE_4142}  Verify Alarms Sources 4142

Find Source Of Reported 4142 Faults
    [Documentation]  Keyword which finding active 4142 faults, creating list of source faults 4142 and set this list as test variable
    ${alarms}=  admin.get active alarms
    ${source_active_4142}=  Create List
    FOR  ${i}  IN  @{alarms}
        Run Keyword If  ${i['faultId']}==4142  Run Keywords
        ...  Append To List  ${source_active_4142}  ${i['configObjectName']}
        ...  AND
        ...  Log  ---- Fault 4142 is reported on source: ${i.configObjectName}    console=${True}
    END
    Set Test Variable  ${source_active_4142}

Verify Alarms Sources 4142
    [Documentation]  Keyword check if reported alarms are same as in the assumption
    Set RSL Alarm Sources
    ALD Alarm Source
    ${dn_prefix}=  Catenate  SEPARATOR=  MRBTS_A-${MRBTS_ID}/  EQM_A-1/  APEQM_A-1/
    FOR  ${item}  IN  @{ANT_ALARM_SOURCES}
        ${alarm_rmod}  Evaluate  re.search(r'RMOD-(\\d+)','''${item}''').group(1)  re
        ${alarm_rmod_dn}=  Catenate  SEPARATOR=  ${dn_prefix}  RMOD_A-${alarm_rmod}
        ${ignore}  ${alarm_antl}=  Split String  ${item}  separator=ANTL-  max_split=1
        ${ant2}  Catenate  SEPARATOR=  ${ignore}  ANTL-2
        Run Keyword If  $alarm_rmod_dn in $excluded_RMOD_A
        ...  Remove Values From List  ${ANT_ALARM_SOURCES}  ${item}
        Run Keyword If  $alarm_rmod_dn in $twoant_RMOD_A and ${alarm_antl}==3  Run Keywords
        ...  Remove Values From List  ${ANT_ALARM_SOURCES}  ${item}
        ...  AND
        ...  Append To List  ${ANT_ALARM_SOURCES}  ${ant2}
        Run Keyword If  $alarm_rmod_dn in $oneant_RMOD_A and ${alarm_antl}!=1
        ...  Remove Values From List  ${ANT_ALARM_SOURCES}  ${item}
        Run Keyword If  $alarm_rmod_dn in $twoant_RMOD_A and ${alarm_antl}!=1 and ${alarm_antl}!=3
        ...  Remove Values From List  ${ANT_ALARM_SOURCES}  ${item}

    END
    ${alarm_sources}=  Set Variable  ${ALDS_SOURCES}
#    ${alarm_sources}=  Combine Lists  ${RSL_ALARM_SOURCES}  ${ALDS_SOURCES}
    ${alarm_sources}=  Remove Duplicates  ${alarm_sources}
    Sort List  ${source_active_4142}
    Sort List  ${alarm_sources}
    ${verdict}  Run Keyword And Ignore Error  Lists Should Be Equal  ${SOURCE_ACTIVE_4142}  ${alarm_sources}
    Run keyword If  '${verdict[0]}'== 'PASS'
    ...  Log  \n---- Fault 4142 sources are properly reported    console=${True}
    ...  ELSE
    ...  Fail   msg=Fault 4142 sources are not properly reported

Get Alarm Source 4142
    [Documentation]  Keyword read beginning string of alarm source
    ${ANTL_without_ALD}=  Get Antenna Alarm Sources
    Run Keyword If  ${source_active_4142}  Run Keywords
    ...  Get Specific Part Of Source dist_name 4142
    ...  Antenna Alarm Source
    ...  ELSE
    ...  Log  There is no active 4142 Fault  console=${True}

Get Specific Part Of Source dist_name 4142
    [Documentation]  Keyword read beginning string of alarm source
    ${source_beginning}  Get Regexp Matches  ${source_active_4142[0]}  (.*)\/EQM-\\d+\/APEQM-\\d+
    Set Test Variable  ${source_beginning}

Find Source Of Reported 4141 Faults
    [Documentation]  Keyword which finding active 4141 faults, creating list of source faults 4141 and set this list as test variable
    ${alarms}=  admin.get active alarms
    ${source_active_4141}=  Create List
    FOR  ${i}  IN  @{alarms}
        Run Keyword If  ${i['faultId']}==4141  Run Keywords
        ...  Append To List  ${source_active_4141}  ${i['configObjectName']}
        ...  AND
        ...  Log  ---- Fault 4141 is reported on source: ${i.configObjectName}    console=${True}
    END
    Set Test Variable  ${source_active_4141}

Get Alarm Source 4141
    [Documentation]  Keyword read beginning string of alarm source
    ${ANTL_without_ALD}=  Get Antenna Alarm Sources
    Run Keyword If  ${source_active_4141}  Run Keywords
    ...  Get Specific Part Of Source dist_name 4141
    ...  Antenna Alarm Source
    ...  ELSE
    ...  Log  There is no active 4141 Fault  console=${True}

Get Specific Part Of Source dist_name 4141
    [Documentation]  Keyword read beginning string of alarm source
    ${source_beginning}  Get Regexp Matches  ${source_active_4141[0]}  (.*)\/EQM-\\d+\/APEQM-\\d+
    Set Test Variable  ${source_beginning}

Check Alarm 4141
   Run Keyword If  ${SOURCE_ACTIVE_4141}  Verify Alarms Sources 4141

Verify Alarms Sources 4141
    [Documentation]  Keyword check if reported alarms are same as in the assumption
    Set RSL Alarm Sources
    ALD Alarm Source
    ${sw_rel}=  Run Keyword And Return Status  Should Contain  ${active_sw_version}  FSM3
    ${alarm_sources}=  Run Keyword If  ${sw_rel}==${TRUE}  Run keyword
    ...  Combine Lists  ${ANT_ALARM_SOURCES}  ${RSL_ALARM_SOURCES}  ${ALDS_SOURCES}
    ...  ELSE
    ...  Set Variable  ${ALDS_SOURCES}
#    ${alarm_sources}=  Combine Lists  ${RSL_ALARM_SOURCES}  ${ALDS_SOURCES}
    ${alarm_sources}=  Remove Duplicates  ${alarm_sources}
    Sort List  ${source_active_4141}
    Sort List  ${alarm_sources}
    ${verdict}  Run Keyword And Ignore Error  Lists Should Be Equal  ${SOURCE_ACTIVE_4141}  ${alarm_sources}
    Run keyword If  '${verdict[0]}'== 'PASS'
    ...  Log  \n---- Fault 4141 sources are properly reported    console=${True}
    ...  ELSE
    ...  Fail   msg=Fault 4141 sources are not properly reported

Find Source Of Reported 10 Faults
    [Documentation]  Keyword return active 10 alarm
    ${alarms}=  admin.get active alarms
    ${source_active_10}=  Create List
    FOR  ${i}  IN  @{alarms}
        Run Keyword If  ${i['faultId']}==10  Run Keywords
        ...  Append To List  ${source_active_10}  ${i['configObjectName']}
        ...  AND
        ...  Log  ---- Fault 10 is reported on source: ${i.configObjectName}    console=${True}
        Run Keyword If  ${i['faultId']}==4141
        ...  Fail  msg=Fault 4141 should be closed after reset
    END
    Set Test Variable  ${source_active_10}

Verify Alarms Sources After Reset
    [Documentation]  Keyword check if reported alarms are same as in the assumption
    ${alarm_sources}=  Copy list  ${ALDS_SOURCES}
    ${alarm_sources}=  Remove Duplicates  ${alarm_sources}
    Sort List  ${source_active_10}
    Sort List  ${alarm_sources}
    ${verdict}  Run Keyword And Ignore Error  Lists Should Be Equal  ${source_active_10}  ${alarm_sources}
    Run Keyword If  '${verdict[0]}'=='PASS'
    ...  Log  ---- Fault 10 sources are properly reported    console=${True}
    ...  ELSE
    ...  Fail   msg=Fault 10 sources are not properly reported

Set RETU And RAEU Id
    [Documentation]  Keyword get Set RETU And RAEU Id of alarm source
    [Arguments]  ${ald}
    ${ald_param}=  admin.get managed objects  ALD_R
    ${RETU_RAEU_ALARM_SOURCE}=  Create List
    FOR  ${item}  IN  @{ald_param}
        ${ald_a_id}=  Evaluate  re.search(r'ALD_A-(\\d+)','''${item['parameters']['configDN']}''').group(1)  re
        ${mhaType}=  Get From Dictionary    ${item['parameters']}    mhaType
        ${retDeviceType}=  Get From Dictionary    ${item['parameters']}    retDeviceType
        Run Keyword If   "${ald_a_id}"=="${ald}" and "${mhaType}"=="None" and "${retDeviceType}"=="SingleAntennaDevice"
        ...    Append To List    ${RETU_RAEU_ALARM_SOURCE}  ${source_beginning[0]}/ALD-${ald}/RETU-1
        Run Keyword If   "${ald_a_id}"=="${ald}" and "${mhaType}"=="None" and "${retDeviceType}"=="None"
        ...    Append To List    ${RETU_RAEU_ALARM_SOURCE}  ${source_beginning[0]}/ALD-${ald}/RAEU-1
    END
    Set Test Variable  ${RETU_RAEU_ALARM_SOURCE}

Antenna Alarm Source
    [Documentation]  Keyword read antenna alarm source
    ${ant_without_ald}=  Get Antenna Alarm Sources
    ${ANT_ALARM_SOURCES}  create list
    FOR    ${key}    IN    @{ant_without_ald.keys()}
       ${rmod_antenna}=  Get From Dictionary  ${ant_without_ald}  ${key}
       ${ant_alarm_source}=   convert to string  ${source_beginning[0]}/RMOD-${rmod_antenna[0]}/ANTL-${rmod_antenna[1]}
       append to list   ${ANT_ALARM_SOURCES}  ${ant_alarm_source}
    END
    Set Test Variable   ${ANT_ALARM_SOURCES}

Get ANTL_A Full DistName String
    [Arguments]  ${ANTL_A}
    ${ant_a_param}=  admin.get managed objects  ANTL_A
    ${ant_a}=  Create List
    ${regex}=  Set Variable  APEQM_A-\\d+/RMOD_A-\\d+/ANTL_A-\\d+
    FOR  ${ant}  IN  @{ant_a_param}
        ${status}  ${antl}=  Run Keyword And Ignore Error  Should Match Regexp  ${ant['distName']}  ${regex}
        Run Keyword If  '${status}'=='PASS'  Append To List  ${ant_a}  ${ant['distName']}
    END
    ${beginning}=   Get Regexp Matches  ${ant_a[0]}  .*/APEQM_A-\\d+
    ${beginning}=  Evaluate  "".join(${beginning})
    ${distName}=  Catenate  SEPARATOR=  ${beginning}  ${ANTL_A}
	[Return]  ${distName}

Get RSL_A Full DistName String
    [Arguments]  ${RMOD_A}
    ${rsl_a_param}=  admin.get managed objects  RSL_A
    ${rsl_a}=  Create List
    ${regex}=  Set Variable  APEQM_A-\\d+/${RMOD_A}/RSL_A-\\d+
    FOR  ${rsl}  IN  @{rsl_a_param}
        ${status}  ${rsl_dn}=  Run Keyword And Ignore Error  Should Match Regexp  ${rsl['distName']}  ${regex}
        Run Keyword If  '${status}'=='PASS'  Append To List  ${rsl_a}  ${rsl['distName']}
    END
    ${distName}=  Get From List  ${rsl_a}  0
	[Return]  ${distName}

Get Affected LNAs And MHAs
    [Arguments]  ${ant_a}
    ${loglink_R_conf_link}=  Get Loglink Parameter List With linkModeDC On True
    ${lna_dist_names}=  Create List
    ${ald_objects}=  Create List
    ${lna_objects}=  Create List
    ${ant_r}  Get ANTL_R Related To ANTL_A  ${ant_a}
    FOR  ${loglink}  IN  @{loglink_R_conf_link}
        Run Keyword If  '${loglink['parameters']['secondEndpointDN']}' == '${ant_r}'
        ...  Append To List  ${lna_dist_names}  ${loglink['parameters']['firstEndpointDN']}
    END
    FOR  ${lna}  IN  @{lna_dist_names}
        ${ALD}  Remove String Using Regexp  ${lna}  \/LNA_R-\\d+
    END
    [Return]    ${ALD}  ${lna_dist_names}

Get RETU and ALDs Affected By Fault 4069
    [Arguments]  ${rsl_a}
    ${loglink_R_conf_link}=  Get Loglink Parameter List With linkModeDC On True
    ${ald_dist_names}=  Create List
    ${ald_objects}=  Create List
    ${retu_objects}=  Create List
    ${rsl_r}  Get RSL_R Related To RSL_A  ${rsl_a}
    FOR  ${loglink}  IN  @{loglink_R_conf_link}
        Run Keyword If  '${loglink['parameters']['secondEndpointDN']}' == '${rsl_r}'
        ...  Append To List  ${ald_dist_names}  ${loglink['parameters']['firstEndpointDN']}
    END
    FOR  ${i}  IN  @{ald_dist_names}
        ${retu}  Remove String Using Regexp  ${i}  \/LNA_R-\\d+
        Append To List  ${retu_objects}  ${retu}
    END
    [Return]    ${retu_objects}  ${ald_dist_names}

Get RSL_R Related To RSL_A
    [Arguments]  ${rsl_a_dist_name}
    ${rsl_r}  Create List
    ${rsl_r_param}=  admin.get managed objects  RSL_R
    ${rsl_r_dist_names}=  Create List
    FOR  ${rsl_r}  IN  @{rsl_r_param}
        Append To List  ${rsl_r_dist_names}  ${rsl_r['distName']}
    END
    FOR  ${rsl_r_dn}  IN  @{rsl_r_param}
      ${rsl_r_dist_name}=  Set Variable  ${rsl_r_dn['parameters']['configDN']}
      Return From Keyword If  '${rsl_r_dist_name}' == '${rsl_a_dist_name}'  ${rsl_r_dn['distName']}
    END

Find All ANTLs and RSL with DC Loglink
    [Documentation]  Keyword finding RSL and ANTL with DC loglink and set them as test variable
    ${loglink_DC}  ${secondEndpointDN}  ${firstEndpointDN}=  Get Loglink_A List With linkModeDC On True
    ${DC_ANTL_LOGLINK}  Create Dictionary
    ${DC_RSL_LOGLINK}  Create Dictionary
    ${ALD_source_list}  Create List
    FOR  ${item1}  ${item2}  IN ZIP  ${secondEndpointDN}  ${firstEndpointDN}
        ${specific_part_source}  Fetch From Right  ${item1}  /APEQM_A-1
        ${vedrdict}  ${ANTL_id}  run keyword and ignore error  Evaluate  re.search(r'ANTL_A-(\\d+)','''${item1}''').group(1)  re
        ${RSL_id}  run keyword and ignore error  Evaluate  re.search(r'RSL_A-(\\d+)','''${item1}''').group(1)  re
        ${RMOD_id}  Evaluate  re.search(r'RMOD_A-(\\d+)','''${item1}''').group(1)  re
        ${rmod_antl_list}  Create List
        Run Keyword If  '${vedrdict}'=='PASS'  Run Keywords
        ...  Append To List  ${rmod_antl_list}  ${RMOD_id}  ${ANTL_id}
        ...  AND
        ...  Set To Dictionary  ${DC_ANTL_LOGLINK}  ${specific_part_source}  ${rmod_antl_list}
        ...  ELSE
        ...  Set To Dictionary  ${DC_RSL_LOGLINK}  ${RMOD_id}  ${RSL_id[1]}
       ${ALD_id}  Evaluate  re.search(r'ALD_A-(\\d+)','''${item2}''').group(1)  re
       ${LNA_id}  Run Keyword And Ignore Error  Evaluate  re.search(r'LNA_A-(\\d+)','''${item2}''').group(1)  re
       ${ALD_source}  Create Dictionary
       Run Keyword If  '${LNA_id[0]}'=='PASS'
       ...   Set To Dictionary   ${ALD_source}   ${ALD_id}  ${LNA_id[1]}
       ...   ELSE
       ...   Set To Dictionary   ${ALD_source}   ${ALD_id}  NULL
       Append To List   ${ALD_source_list}   ${ALD_source}
    END
    Set Test Variable    ${DC_ANTL_LOGLINK}
    Set Test Variable    ${DC_RSL_LOGLINK}
    Set Test Variable    ${ALD_source_list}

Get Loglink_A List With linkModeDC On True
    ${loglink_a_linkModeDC_true}=  Create List
    ${secondEndpointDN}=  Create List
    ${firstEndpointDN}=  Create List
    ${loglink_parameters}=  admin.get managed objects  LOGLINK_A
    FOR  ${loglink}  IN  @{loglink_parameters}
        Run Keyword If  '${loglink['parameters']['linkModeDC']}'=='True'  Run Keywords
        ...  Append To List  ${loglink_a_linkModeDC_true}  ${loglink['distName']}
        ...  AND
        ...  Append To List  ${secondEndpointDN}  ${loglink['parameters']['secondEndpointDN']}
        ...  AND
        ...  Append To List  ${firstEndpointDN}  ${loglink['parameters']['firstEndpointDN']}
    END
    [Return]  ${loglink_a_linkModeDC_true}  ${secondEndpointDN}  ${firstEndpointDN}

Get Loglink_A List With linkModeData On True
    ${loglink_a_linkModeData_true}=  Create List
    ${loglink_a_firstEndpointDN}=  Create List
    ${loglink_parameters}=  admin.get managed objects  LOGLINK_A
    FOR  ${loglink}  IN  @{loglink_parameters}
        Run Keyword If  '${loglink['parameters']['linkModeData']}'=='True'  Run Keywords
        ...  Append To List  ${loglink_a_linkModeData_true}  ${loglink['distName']}
        ...  AND
        ...  Append To List  ${loglink_a_firstEndpointDN}  ${loglink['parameters']['firstEndpointDN']}
    END
    [Return]  ${loglink_a_linkModeData_true}  ${loglink_a_firstEndpointDN}

Mapping ALD_R to RETU_R
    ${ALD_R_to_RETU_R}=  Create Dictionary
    ${retu_parameters}=  admin.get managed objects  RETU_R
    FOR  ${i}  IN  @{retu_parameters}
        ${ALD_R_distName}  ${ignore}  Split String From Right  ${i['distName']}  separator=/  max_split=1
        Set To Dictionary   ${ALD_R_to_RETU_R}  ${ALD_R_distName}=${i['distName']}
    END

Mapping ALD_R To ALD_A
    ${ald_ids}=  admin.get ids for all  ALD
    ${ald_parameters}=  admin.get managed objects  ALD_R
    ${ALD_R_to_ALD_A}=  Create Dictionary
    FOR  ${ald_id}  ${ald_parameter}  IN ZIP  ${ald_ids}  ${ald_parameters}
        Set To Dictionary  ${ALD_R_to_ALD_A}  ${ald_id}=${ald_parameter['parameters']['configDN']}
    END
    [Return]  ${ALD_R_to_ALD_A}

Mapping ALD_A To ALD_R
    ${ald_ids}=  admin.get ids for all  ALD
    ${ald_parameters}=  admin.get managed objects  ALD_R
    ${ALD_A_to_ALD_R}=  Create Dictionary
    FOR  ${ald_id}  ${ald_parameter}  IN ZIP  ${ald_ids}  ${ald_parameters}
        Set To Dictionary  ${ALD_A_to_ALD_R}  ${ald_parameter['parameters']['configDN']}=${ald_id}
    END
    [Return]  ${ALD_A_to_ALD_R}

Mapping ANTL_R To ANTL_A
    ${antl_param}=  admin.get managed objects  ANTL_R
    ${antl_r_antl_a}=  Create Dictionary
    FOR  ${antl}  IN  @{antl_param}
        Set To Dictionary  ${antl_r_antl_a}  ${antl['distName']}  ${antl['parameters']['configDN']}
    END
    [Return]  ${antl_r_antl_a}

Mapping RMOD_R To RMOD_A
    ${rmod_param}=  admin.get managed objects  RMOD_R
    ${RMOD_R_to_RMOD_A}=  Create Dictionary
    FOR  ${ITEM}  IN  @{rmod_param}
        Set To Dictionary  ${RMOD_R_to_RMOD_A}  ${ITEM['distName']}  ${ITEM['parameters']['configDN']}
    END
    [Return]  ${RMOD_R_to_RMOD_A}

Mapping RMOD_A To RMOD_R
    ${rmod_param}=  admin.get managed objects  RMOD_R
    ${RMOD_A_to_RMOD_R}=  Create Dictionary
    FOR  ${ITEM}  IN  @{rmod_param}
        Set To Dictionary  ${RMOD_A_to_RMOD_R}  ${ITEM['parameters']['configDN']}  ${ITEM['distName']}
    END
    [Return]  ${RMOD_A_to_RMOD_R}

Mapping ANTL_A To RMOD_A  #Get ANTL
    [Documentation]  Keyword read commissioned ANTL and RMOD
    ${ANTL_A_list}=  admin.get managed objects  ANTL_A
    ${ANTL_RMOD}=  Create Dictionary
    ${ANTL_A}=  Create List
    ${regex}=  Set Variable  MRBTS_A-\\d+/EQM_A-\\d+/APEQM_A-\\d+/RMOD_A-\\d+/ANTL_A-\\d+
    FOR  ${item}  IN  @{ANTL_A_list}
        ${status}  ${msg}=  Run Keyword And Ignore Error  Should Match Regexp  ${item['distName']}  ${regex}
        Run Keyword If  '${status}'=='PASS'
        ...  Append To List  ${ANTL_A}  ${item['distName']}
    END
    FOR  ${item}  IN  @{ANTL_A}
        ${ANTL_id}=  Evaluate  re.search(r'ANTL_A-(\\d+)','''${item}''').group(1)  re
        ${RMOD_id}=  Evaluate  re.search(r'RMOD_A-(\\d+)','''${item}''').group(1)  re
        ${rmod_antl_list}=  Create List
        ${specific_part_source}  Fetch From Right  ${item}  /APEQM_A-1
        Append to list  ${rmod_antl_list}  ${RMOD_id}  ${ANTL_id}
        Set To Dictionary  ${ANTL_RMOD}   ${specific_part_source}   ${rmod_antL_list}
    END
    FOR  ${key}  IN  @{ANTL_RMOD.keys()}
        ${antl}=  Get From Dictionary  ${ANTL_RMOD}  ${key}
        ${even_antl}=  Evaluate  (${antl[1]} % 2)==0
        Run Keyword If  ${even_antl}
        ...  Remove From Dictionary  ${ANTL_RMOD}  ${key}
    END
    [Return]  ${ANTL_RMOD}

Mapping RMOD_A To RSL_A  #Get RSL
    [Documentation]  Keyword read commissioned RSL and RMOD
    ${RSL_A_list}=  admin.get managed objects  RSL_A
    ${RSL_RMOD}=  Create Dictionary
    ${RSL_A}=  Create List
    ${regex}=  Set Variable  MRBTS_A-\\d+/EQM_A-\\d+/APEQM_A-\\d+/RMOD_A-\\d+/RSL_A-\\d+
    FOR  ${ITEM}  IN  @{RSL_A_list}
        ${status}  ${msg}=  Run Keyword And Ignore Error  Should Match Regexp  ${ITEM['distName']}  ${regex}
        Run Keyword If  '${status}'=='PASS'
        ...  Append To List  ${RSL_A}  ${ITEM['distName']}
    END
    FOR  ${RSL}  IN  @{RSL_A}
        ${RSL_ID}=  Evaluate  re.search(r'RSL_A-(\\d+)','''${RSL}''').group(1)  re
        ${RMOD_ID}=  Evaluate  re.search(r'RMOD_A-(\\d+)','''${RSL}''').group(1)  re
        Set To Dictionary  ${RSL_RMOD}  ${RMOD_ID}  ${RSL_ID}
    END
    [Return]  ${RSL_RMOD}

Get ANTL_R wihtout MHA
    ${antl_parameters}=  admin.get managed objects  ANTL_R
    ${ANTL_R}=  Create List
    FOR  ${antl}  IN  @{antl_parameters}
        Append To List  ${ANTL_R}  ${antl['distName']}
    END
    Remove Duplicates  ${ANTL_R}
    Set Variable  ${ANTL_R}
    ${loglink_r_linkModeData_true}=  Get Loglink with linkModeDate on True
    FOR  ${loglink}  IN  @{loglink_r_linkModeData_true}
        ${loglink_parameters}=  admin.get parameters  ${loglink}
        Remove Values From List  ${ANTL_R}  ${loglink_parameters['secondEndpointDN']}
    END
    [Return]  ${ANTL_R}

Set Parameter Under ANTL Object
    [Documentation]  This keyword sets indicated parameter and value under ANTL object.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  Set Parameter Under ANTL Object  /RMOD_A-1/ANTL_A-5  cwaThreshold  200
    ...
    [Arguments]  ${ANTL_A}  ${parameter}  ${value}
    ${ANTL_ID}=  Evaluate  re.search(r'ANTL_A-(\\d+)','''${ANTL_A}''').group(1)  re
    ${RMOD_ID}=  Evaluate  re.search(r'RMOD_A-(\\d+)','''${ANTL_A}''').group(1)  re
    ${delta_id}=  Set Variable  ${parameter}_${value}_RMOD_A-${RMOD_ID}_ANTL_A-${ANTL_ID}
    admin.create delta  ${delta_id}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_ID}/ANTL-${ANTL_ID}  ${parameter}  ${value}  ${delta_id}
    admin.get delta  ${delta_id}
    ${json_path}=  Set Variable  ${RESULTS}/delta_${parameter}_${value}_rmod_a-${RMOD_ID}_antl_a-${ANTL_ID}.json
    admin.save delta  ${json_path}  ${delta_id}
    admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}  ${should_activate}

Get ANTL_R Related To ANTL_A
    [Arguments]  ${antl_a_dist_name}
    ${antl_r}  Create List
    ${antl_r_param}=  admin.get managed objects  ANTL_R
    ${antl_r_dist_names}=  Create List
    FOR  ${ant_r}  IN  @{antl_r_param}
        Append To List  ${antl_r_dist_names}  ${ant_r['distName']}
    END
    FOR  ${antl_r_dn}  IN  @{antl_r_param}
      ${antl_r_dist_name}=  Set Variable  ${antl_r_dn['parameters']['configDN']}
      Return From Keyword If  '${antl_r_dist_name}' == '${antl_a_dist_name}'  ${antl_r_dn['distName']}
    END

Get RSL Without DC Loglink
    [Documentation]  Keyword return RSL without DC loglink
    ${rsl_rmod_}=  Mapping RMOD_A To RSL_A
    ${RMOD_with_loglink_DC_on_RSL}=  Get Dictionary Keys  ${DC_RSL_LOGLINK}
    FOR  ${key}  IN  @{RMOD_with_loglink_DC_on_RSL}
        Remove From Dictionary  ${rsl_rmod_}  ${key}
    END
    [Return]  ${rsl_rmod_}

Get ANTLs Without MHA With Channel
    ${unused_ANTL_R}=  Get ANTL_R wihtout MHA
    ${ANTL_A_with_channel}=  Get ANTL_A with Channel
    ${antl_r_antl_a}=  Mapping ANTL_R To ANTL_A
    ${unused_ANTL_A}=  Create List
    FOR  ${item}  IN  @{unused_ANTL_R}
        ${antl_a}=  Get From Dictionary  ${antl_r_antl_a}  ${item}
        Append To List  ${unused_ANTL_A}  ${antl_a}
    END
    ${unused_ANTL_A_with_channel}=  Create List
    FOR  ${item}  IN  @{unused_ANTL_A}
        Run Keyword If  '${item}' in ${ANTL_A_with_channel}
        ...  Append To List  ${unused_ANTL_A_with_channel}  ${item}
    END
    [Return]  ${unused_ANTL_A_with_channel}

Get ANTL_A with Channel
    ${antl_a_param}=  admin.get managed objects  CHANNEL_A
    ${antl_cell}=  Create List
    FOR  ${item}  IN  @{antl_a_param}
        Append To List  ${antl_cell}  ${item['parameters']['antlDN']}
    END
    ${antl_with_cell}=  Remove Duplicates  ${antl_cell}
    [Return]  ${antl_with_cell}

Select Random ANTL Without MHA With Channel
    [Arguments]  ${unused_ANTL_A_with_channel}
    ${selected_antl_a}=  Evaluate  random.choice(${unused_ANTL_A_with_channel})  random
    ${RMOD_ID_A}=  Evaluate  re.search(r'RMOD_A-(\\d+)','''${selected_antl_a}''').group(1)  re
    ${ANTL_ID_A}=  Evaluate  re.search(r'ANTL_A-(\\d+)','''${selected_antl_a}''').group(1)  re
    [Return]  ${RMOD_ID_A}  ${ANTL_ID_A}

Check FEG On Antl With MHA
    ${loglink_r_linkModeData_true}=  Get Loglink with linkModeDate on True
    FOR  ${loglink}  IN  @{loglink_r_linkModeData_true}
        ${loglink_parameters}=  admin.get parameters  ${loglink}
        ${antl_r}=  Should Match Regexp  ${loglink_parameters['secondEndpointDN']}  RMOD_R-\\d+\/ANTL_R-\\d+
        Log  Checking FEG for: ${antl_r}  console=${true}
        ${rmod_R}=  Should Match Regexp  ${loglink_parameters['secondEndpointDN']}  RMOD_R-\\d+
        ${rmod_r_distName}  ${ignore}  Split String From Right  ${loglink_parameters['secondEndpointDN']}  separator=/  max_split=1
        ${type_radio}=  admin.get parameters  ${rmod_r_distName}
        ${rmod_feg}=  Set Variable  0
        ${feg_calculated}=  Calculating FEG  ${loglink_parameters}
        ${feg}=  Evaluate  ${feg_calculated}+${rmod_feg}
        Log  FEG calculated by system is equal to: ${feg} dB  console=${true}
        ${read_feg}=  Get FEG From IM  ${loglink_parameters}
        Log  FEG readed from InfoModel is equal to: ${read_feg} dB  console=${true}
        ${feg_diff}  Evaluate  abs(${feg} - ${read_feg})
        Run Keyword If  ${feg_diff}==${0}
        ...  Log  FEG is correct  console=${true}
        ...  ELSE
        ...  Fail  msg=FEG calculated is different
    END

Check FEG On Antl Without MHA
    ${antl_all}=  Get ANTL_R wihtout MHA
    Remove Duplicates  ${antl_all}
    FOR  ${antl}  IN  @{antl_all}
        ${antl_r}=  Should Match Regexp  ${antl}  RMOD_R-\\d+\/ANTL_R-\\d+
        Log  Checking FEG for ${antl_r} wihtout MHA  console=${true}
        Log  FEG calculated by system is equal to: ${0} dB  console=${true}
        ${read_feg}=  Get FEG From IM for given ANTL_R  ${antl}
        Log  FEG readed from InfoModel is equal to: ${read_feg} dB  console=${true}
        ${feg_diff}  Evaluate  abs(${0} - ${read_feg})
        Run Keyword If  ${feg_diff}==${0}
        ...  Log  FEG is correct  console=${true}
        ...  ELSE
        ...  Fail  msg=FEG calculated is different
    END

Check FEG On ANTL Where Is Loglink With Recovery
    [Documentation]
    ...  This keyword check if FEG is correctly calculated on ANTL where is MHA when recovery action is done.
    ${loglink_DN}=  Create List
    ${secondEndpointDN}=  Create List
    ${loglink_parameters}=  admin.get managed objects  LOGLINK_R
    FOR  ${loglink}  IN  @{loglink_parameters}
        Run Keyword If  '${loglink['parameters']['linkModeData']}'=='True'  Run Keywords
        ...  Append To List  ${loglink_DN}  ${loglink['distName']}
        ...  AND
        ...  Append To List  ${secondEndpointDN}  ${loglink['parameters']['secondEndpointDN']}
    END
    FOR  ${ITEM}  IN  @{secondEndpointDN}
        ${totalloss}=  admin.get parameters  ${ITEM}/ANTL_CONF_M-1  totalLoss
        ${totalloss}=  Get From Dictionary  ${totalloss}  totalLoss
        Log  FEG readed from InfoModel is equal to: ${totalloss} dB  console=${true}
        ${recovery_feg}=  Evaluate  abs(${0}-${totalloss})
        Log  FEG calculated by system is equal to: ${recovery_feg} dB  console=${true}
        ${feg_diff}  Evaluate  abs(${recovery_feg} - ${totalloss})
        Run Keyword If  ${feg_diff}==${0}
        ...  Log  FEG is correct  console=${true}
        ...  ELSE
        ...  Fail  msg=FEG calculated is different
    END

Get FEG From IM for given ANTL_R
    [Arguments]  ${antl}
    ${calcFEG}=  admin.get parameters  ${antl}  calcFEG
    ${calcFEG}=  Get From Dictionary  ${calcFEG}  calcFEG
    [Return]  ${calcFEG}

Get Loglink with linkModeDate on True
    ${loglink_r_linkModeData_true}=  Create List
    ${loglink_parameters}=  admin.get managed objects  LOGLINK_R
    FOR  ${loglink}  IN  @{loglink_parameters}
        Run Keyword If  '${loglink['parameters']['linkModeData']}'=='True'
        ...  Append To List  ${loglink_r_linkModeData_true}  ${loglink['distName']}
    END
    [Return]  ${loglink_r_linkModeData_true}

Get Loglink Parameter List With linkModeDC On True
    ${loglink_r_linkModeDC_true}=  Create List
    ${loglink_parameters}=  admin.get managed objects  LOGLINK_R
    FOR  ${loglink}  IN  @{loglink_parameters}
        Run Keyword If  '${loglink['parameters']['linkModeDC']}'=='True'
        ...  Append To List  ${loglink_r_linkModeDC_true}  ${loglink}
    END
    [Return]  ${loglink_r_linkModeDC_true}

Get FEG From IM
    [Arguments]  ${loglink_parameters}
    ${calcFEG}=  admin.get parameters  ${loglink_parameters['secondEndpointDN']}  calcFEG
    ${calcFEG}=  Get From Dictionary  ${calcFEG}  calcFEG
    [Return]  ${calcFEG}

Calculating FEG
    [Arguments]  ${loglink_parameters}
    #MHA Gain
    ${mha_gain}=  admin.get parameters  ${loglink_parameters['firstEndpointDN']}  gain$
    ${status}  ${gain_mha}=  Run Keyword And Ignore Error  Get From Dictionary  ${mha_gain}  gain
    ${mha_gain}=  Set Variable If  '${status}'=='FAIL'  0  '${status}'=='PASS'  ${gain_mha}
    #PASSDEV Gain
    ${passdev_gain}=  admin.get parameters  ${loglink_parameters['firstEndpointDN']}  additionalRxGain
    ${status}  ${passdv_gain_}=  Run Keyword And Ignore Error  Get From Dictionary  ${passdev_gain}  additionalRxGain
    ${passdev_gain}=  Set Variable If  '${status}'=='FAIL'  0  '${status}'=='PASS'  ${passdv_gain_}
    #totalLoss
    ${total_loss}=  admin.get parameters  ${loglink_parameters['secondEndpointDN']}/ANTL_CONF_M-1  totalLoss
    ${total_loss}=  Get From Dictionary  ${total_loss}  totalLoss
    ${release_status}=  Compare Release  23R4
    ${loss}=  Set Variable If  ${passdev_gain}  0  ${total_loss}
    ${loss}=  Set Variable If  ${release_status}  ${total_loss}  ${loss}
    ${loss}=  Set Variable If  ${release_status} and '${mha_gain}'=='0' and '${passdev_gain}'=='0'  0  ${loss}
    ${feg_calculated}=  Evaluate  ${mha_gain} - ${loss} + ${passdev_gain}
    ${feg_calculated}=  Evaluate  round(${feg_calculated}, 1)
    [Return]      ${feg_calculated}

Compare Release
  	[Documentation]
  	...  Keyword checks if active SW release is newer or same as argument
  	...  Returns true if release <= active sw
  	...  Returns false if release > active sw or FSM3 software is detected
  	[Arguments]  ${release}
  	${checked_s}=  Remove String  ${release}  R
  	${active_sbts}  ${active_rest}=  Split String  ${active_sw_version}  separator=_  max_split=1
    ${active_hw}  ${ignore}=  Split String  ${active_rest}  separator=_  max_split=1
  	${active_release}=  Fetch From Right  ${active_sbts}  marker=SBTS
  	${active_s}=  Remove String  ${active_release}  R
  	${active}=  Convert To Integer  ${active_s}
  	${checked}=  Convert To Integer  ${checked_s}
  	${status}=  Set Variable If  '${checked}'<='${active}' and '${active_hw}'=='ENB'  True  False
  	Log  Release check status is ${status}  console=${True}
  	[Return]  ${status}

Get RMOD_R
    [Arguments]  ${loglink['parameters']['secondEndpointDN']}
    ${RMOD_R}=  Should Match Regexp  ${loglink['parameters']['secondEndpointDN']}  RMOD_R-\\d+
    Set Test Variable  ${RMOD_R}
    [Return]  ${RMOD_R}

Get RMOD_R parameters
    [Arguments]  ${RMOD_R}
    ${rmod_r_parameters}=  admin.get managed objects  ${RMOD_R}
    [Return]  ${rmod_r_parameters}

Detect Dual Band MHA Connected To BTS
    [Documentation]  Keyword checks how many dual band MHAs is in configuration.
    ...  **Author:** grzegorz.huchla@nokia.com
    [Arguments]  ${MHA_ALD_A_prodCode}
    ${prodCode_list}=  Get Dictionary Values  ${MHA_ALD_A_prodCode}
    ${ald_a_list}=  Get Dictionary Keys  ${MHA_ALD_A_prodCode}
    ${prodCodes_dual_band_MHA}=  Create List
    ${ald_a_prodCode_dual_band}=  Create Dictionary
    ${ald_a_dual}=  Create List
    FOR  ${productCode}  ${ald}  IN ZIP  ${prodCode_list}  ${ald_a_list}
        ${prod}=  Get Regexp Matches  ${productCode}  47\\d+A|CS\\d+
        ${status}  ${msg}=  Run Keyword If  ${prod}!=[]
        ...  Run Keyword And Ignore Error  Evaluate  re.findall(r'(${PATTERN_DUALBAND_MHA})','''${prod}''')  re
        Run Keyword If  '${status}'!='None' and ${msg}!=[]  Append To List  ${ald_a_dual}  ${ald}
    END
    [Return]  ${ald_a_dual}

Detect Triple Band MHA Connected To BTS
    [Documentation]  Keyword checks how many triple band MHAs is in configuration.
    ...  **Author:** grzegorz.huchla@nokia.com
    [Arguments]  ${MHA_ALD_A_prodCode}
    ${prodCode_list}=  Get Dictionary Values  ${MHA_ALD_A_prodCode}
    ${ald_a_list}=  Get Dictionary Keys  ${MHA_ALD_A_prodCode}
    ${prodCodes_triple_band_MHA}=  Create List
    ${ald_a_prodCode_triple_band}=  Create Dictionary
    ${ald_a_triple}=  Create List
    FOR  ${productCode}  ${ald}  IN ZIP  ${prodCode_list}  ${ald_a_list}
        ${prod}=  Get Regexp Matches  ${productCode}  47\\d+A|CS\\d+
        ${status}  ${msg}=  Run Keyword If  ${prod}!=[]
        ...  Run Keyword And Ignore Error  Evaluate  re.findall(r'(${PATTERN_TRIPLEBAND_MHA})','''${prod}''')  re
        Run Keyword If  '${status}'!='None' and ${msg}!=[]  Append To List  ${ald_a_triple}  ${ald}
    END
    [Return]  ${ald_a_triple}

Check Syslog For RAE Sensor Data Reading
    [Arguments]  ${start_end}
    ${start_timer_query_print}=  Set Variable If  '${start_end}'=='start'  startTimerQueryTelemetryData, start 300000ms timer to query telemetry data
    ${handle_action_response_print}=  Set Variable If  '${start_end}'=='end'  handleActionResponse: RAEDeviceDataQuery_38 on device
    Run Keyword If  '${start_end}'=='start'  Run Keywords
    ...  ute_syslog.wait for message in syslog file  regexp=${start_timer_query_print}  timeout=15min  alias=ute_syslog
    ...  AND  Log  Message ${start_timer_query_print} in syslog found  console=${true}

    Run Keyword If  '${start_end}'=='end'  Run Keywords
    ...  ute_syslog.wait for message in syslog file  regexp=${handle_action_response_print}  timeout=15min  alias=ute_syslog
    ...  AND  Log  Message ${handle_action_response_print} in syslog found  console=${true}

Select RMOD with connected RETs
    [Documentation]    Keyword selects ranodomly chosen RMOD with connected RETs
    ${chosen_RMOD}=  Evaluate  random.choice(${rmods})  random
    ${ignore}    ${rmodid}=   Split String From Right  ${chosen_RMOD}  separator=RMOD-
    Mapping RMOD_A To RMOD_R
    ${RMOD_A_to_RMOD_R}=  Mapping RMOD_A To RMOD_R
    ${dic_kayes}=    Get Dictionary Keys    ${RMOD_A_to_RMOD_R}
    FOR    ${i}    IN    @{dic_kayes}
        ${distname_short}    ${ignore}=   Split String From Right  ${i}  separator=APEQM_A-1/
        ${distname_short}=    Set Variable    ${distname_short}
    END
    ${key_DN}=    Set Variable   ${distname_short}APEQM_A-1/RMOD_A-${rmodid}
    ${RMOD_R_distName}=  Get From Dictionary  ${RMOD_A_to_RMOD_R}  ${key_DN}
    ${rmod}=  Should Match Regexp  ${RMOD_R_distName}  RMOD_R-\\d+
    ${ALD_DC}  ${ALD_conf}  Check ALD With Rmod Connection  ${rmod}
    ${RET_list}=    Create List
    FOR    ${i}    IN    @{ALD_R_RETs}
        ${ignore}    ${ald_r}=   Split String From Right  ${i}  separator=APEQM_R-1/
        Append To List   ${RET_list}    ${ald_r}
    END
    ${RETs_connected_to_rmod}=    Evaluate    set(${RET_list}) & set(${ALD_conf})
    Should Not Be Empty    ${RETs_connected_to_rmod}
    [Return]  ${RETs_connected_to_rmod}    ${chosen_RMOD}

Print radio connected to ALD
    [Documentation]  this keyword returns the radio module to which the ALD is connected
    ...  **Example of simple usage:**
    ...  Print radio connected to ALD  ALD_R-25
    [Arguments]  ${ALD_R}
    ${DC}  ${conf}    ALD Connection Mapping
    ${ALD_index}    Get Index From List    ${DC}    ${ALD_R}
    ${rmod}    Set Variable  ${DC[${ALD_index}-1]}
    [Return]    ${rmod}
