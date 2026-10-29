*** Settings ***
Documentation  This resource contains all common keywords from FM CA.

Library  XML
Library  taf.rnc.oms.nwi3
Library  hran_radio
Library  python_resources/ims_parser.py  WITH NAME  ims_parser
Resource  ca_SBTS_general.robot
Resource  ../../resources/ca_FM_common.robot


*** Variables ***
@{LIST_NAMES_ASIA}  ASIA AirScale Common  ASIA  FCTJ  FCTN
@{LIST_NAMES_ASIB}  ASIB AirScale Common  ASIB  FCTM
@{LIST_NAMES_ASIK}  ASIK  FCTL
@{LIST_NAMES_ASIL}  ASIL AirScale Common  ASIL  FCTP
@{LIST_NAMES_ASIM}  ASIM AirScale Common  ASIM  FCTQ
@{LIST_NAMES_ASOE}  ASOE AirScale Core  ASOE  ASCE
@{LIST_NAMES_ASOF}  ASOF AirScale Core  ASOF  ASCF
@{LIST_NAMES_ASOG}  ASOG AirScale Core  ASOG  ASCG
@{LIST_NAMES_ASOH}  ASOH AirScale Core  ASOH  ASCH
@{LIST_NAMES_FLEXI}  Flexi System Module Outdoor FSMF  FSMF  FCTB  FCTG  Flexi System Module Indoor FSIH  FSIH

&{COMMON_MODULES}
...  ASIA=${LIST_NAMES_ASIA}
...  ASIB=${LIST_NAMES_ASIB}
...  ASIK=${LIST_NAMES_ASIK}
...  ASIL=${LIST_NAMES_ASIL}
...  ASIM=${LIST_NAMES_ASIM}
...  ASOE=${LIST_NAMES_ASOE}
...  ASOF=${LIST_NAMES_ASOF}
...  ASOG=${LIST_NAMES_ASOG}
...  ASOH=${LIST_NAMES_ASOH}
...  Flexi=${LIST_NAMES_FLEXI}

@{LIST_NAMES_ABIA}  ABIA AirScale Capacity  ABIA  FSPJ
@{LIST_NAMES_ABIC}  ABIC AirScale Capacity  ABIC  ASPB
@{LIST_NAMES_ABIL}  ABIL AirScale Capacity  ABIL  ASPA
@{LIST_NAMES_ABIN}  ABIN AirScale Capacity  ABIN  ASPC
@{LIST_NAMES_ABIO}  ABIO AirScale Capacity  ABIO  ASPD
@{LIST_NAMES_ABIP}  ABIP AirScale Capacity  ABIP  ASPE
@{LIST_NAMES_ABIQ}  ABIQ AirScale Capacity  ABIQ  ASPF
@{LIST_NAMES_FLEXI_BB}  FBBA  FBBC

&{CAPACITY_MODULES}
...  ABIA=${LIST_NAMES_ABIA}
...  ABIC=${LIST_NAMES_ABIC}
...  ABIL=${LIST_NAMES_ABIL}
...  ABIO=${LIST_NAMES_ABIO}
...  ABIN=${LIST_NAMES_ABIN}
...  ABIP=${LIST_NAMES_ABIP}
...  ABIQ=${LIST_NAMES_ABIQ}
...  Flexi=${LIST_NAMES_FLEXI_BB}

${SKIP_RMOD_POWER_CHECK}  ${FALSE}  # Setting this variable to TRUE, will skip execution of KWs:
#  Get all Tx Power from all RMs
#  Compare TXs


*** Keywords ***
Check Commissioned Technologies
    [Documentation]
    ...  This KW was created to check what kind of technologies are commissioned on tested SBTS
    ...  This is generic KW. It can be used within all link breakes (where removing/adding VLANs is used as testing method)
    ...  When specific link break is about to be tested it's necessary to point this as a parameter - requiredRATS
    ...  This is a list which can take: none,LTE,GSM,WCDMA as input parameters (different combinations allowed)
    ...  If whole link is tested none should be provided.
    ...  Eg:  Check commissioned technologies  none
    ...  Eg:  Check commissioned technologies  GSM
    ...  Eg:  Check commissioned technologies  GSM,LTE,WCDMA
    [Arguments]  @{required_rats}

    ${wcdma}  Run Keyword And Return Status  Should Not Be Equal As Strings  ${SCF_COUNT_WCDMA}  0
    IF  ${wcdma}  Log  WCDMA is commissioned: ${wcdma}  console=true
    ${should_be_commissioned}  Run Keyword And Return Status  List Should Contain Value  ${required_rats}  WCDMA
    IF  '${should_be_commissioned}' == 'True' and '${wcdma}' == 'False'
        ${wcdma_message}  Catenate  WCDMA is not commissioned there is no point to proceed with futher steps
        ...                         because IuB link break is not possible, test will be set to failed
        Fail  ${wcdma_message}
    END

    ${gsm}  Run Keyword And Return Status  Should Not Be Equal As Strings  ${SCF_COUNT_GSM}  0
    IF  ${gsm}  Log  GSM is commissioned: ${gsm}  console=true
    ${should_be_commissioned}  Run Keyword And Return Status  List Should Contain Value  ${required_rats}  GSM
    IF  '${should_be_commissioned}' == 'True' and '${gsm}' == 'False'
        ${gsm_message}  Catenate  GSM is not commissioned there is no point to proceed with futher steps
        ...                       because Abis link break is not possible, test will be set to failed
        Fail  ${gsm_message}
    END

    ${lte}  Run Keyword And Return Status  Should Not Be Equal As Strings  ${SCF_COUNT_LTE}  0
    IF  ${lte}  Log  LTE is commissioned: ${lte}  console=true
    ${should_be_commissioned}  Run Keyword And Return Status  List Should Contain Value  ${required_rats}  LTE
    IF  '${should_be_commissioned}' == 'True' and '${lte}' == 'False'
        ${lte_message}  Catenate  LTE is not commissioned there is no point to proceed with futher steps
        ...                       because S1 link break is not possible, test will be set to failed
        Fail  ${lte_message}
    END

    ${nr}  Run Keyword And Return Status  Should Not Be Equal As Strings  ${SCF_COUNT_NR}  0
    IF  ${nr}  Log  NR is commissioned: ${nr}  console=true
    ${should_be_commissioned}  Run Keyword And Return Status  List Should Contain Value  ${required_rats}  NR
    IF  '${should_be_commissioned}' == 'True' and '${nr}' == 'False'
        ${nr_message}  Catenate  NR is not commissioned there is no point to proceed with futher steps
        ...                     because NR link break is not possible, test will be set to failed
        Fail  ${nr_message}
    END


Connect To Nokia Serving Switch And Perform Action
    [Documentation]  Checking availability of serving switch and performing action: add or remove vlans
    [Arguments]  ${switch_ip_address}  ${switch_user}  ${switch_password}  ${vlan}  ${interface}  ${action}

    ${status}  Check If Target Is Stable  ${switch_ip_address}  30  30  90
    Run Keyword If  ${status}
    ...  Log  Serving switch with IP address ${switch_ip_address} is reachable, test will be continued  console=true
    ...  ELSE
    ...  Fail  msg=Serving switch with IP address ${switch_ip_address} is not reachable, test will be set as failed

    Log  Opening ssh connection to switch: ${switch_ip_address} and performing operation: ${action} VLAN  console=true
    SSHLibrary.Open Connection  host=${switch_ip_address}
    SSHLibrary.Login  username=${switch_user}  password=${switch_password}
    SSHLibrary.Set Client Configuration  prompt=>#

    SSHLibrary.Write  configure service vpls ${vlan} sap 1/1/${interface}:${vlan} ${action}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections

    Log  Operation is done, test case will be continued [OK]  console=true


Connect To Nokia Serving Switch And Perform Action On Port
    [Documentation]  Checking availability of serving switch and performing action on ports: shutdown or no shutdown
    [Arguments]  ${switch_ip_address}  ${switch_user}  ${switch_password}  ${interface}  ${action}

    ${status}  Check If Target Is Stable  ${switch_ip_address}  30  30  90
    Run Keyword If  ${status}
    ...  Log  Serving switch with IP address ${switch_ip_address} is reachable, test will be continued  console=true
    ...  ELSE
    ...  Fail  msg=Serving switch with IP address ${switch_ip_address} is not reachable, test will be set as failed

    Log  Opening ssh connection to switch: ${switch_ip_address} and performing operation: ${action} VLAN  console=true
    SSHLibrary.Open Connection  host=${switch_ip_address}
    SSHLibrary.Login  username=${switch_user}  password=${switch_password}
    SSHLibrary.Set Client Configuration  prompt=>#

    SSHLibrary.Write  configure port 1/1/${interface} ${action}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections

    Log  Operation is done, test case will be continued [OK]  console=true


Connect To Nokia Serving Switch And Perform Short Interuption
    [Documentation]  Checking availability of serving switch and performing action: add or remove vlans
    [Arguments]  ${switch_ip_address}  ${switch_user}  ${switch_password}  ${vlan}  ${interface}

    ${status}  Check If Target Is Stable  ${switch_ip_address}  30  30  90
    Run Keyword If  ${status}
    ...  Log  Serving switch with IP address ${switch_ip_address} is reachable, test will be continued  console=true
    ...  ELSE
    ...  Fail  msg=Serving switch with IP address ${switch_ip_address} is not reachable, test will be set as failed

    Log  Opening ssh connection to switch: ${switch_ip_address} and performing operation: short interuptions VLAN  console=true
    SSHLibrary.Open Connection  host=${switch_ip_address}
    SSHLibrary.Login  username=${switch_user}  password=${switch_password}
    SSHLibrary.Set Client Configuration  prompt=>#

    FOR  ${loop}  IN RANGE  0  ${NUMBER_OF_LOOPS}
        ${loop_incrementation}  Evaluate  ${loop} + 1
        Log  Current loop is: ${loop_incrementation}  console=true
        SSHLibrary.Write  configure service vpls ${vlan} sap 1/1/${interface}:${vlan} shutdown
        SSHLibrary.Read Until Prompt
        Wait Random Time
        SSHLibrary.Write  configure service vpls ${vlan} sap 1/1/${interface}:${vlan} no shutdown
        SSHLibrary.Read Until Prompt
    END
    SSHLibrary.Close All Connections
    Log  Operation is done, test case will be continued [OK]  console=true


Connect To Nokia Serving Switch And Perform Short Port Interuption
    [Documentation]  Checking availability of serving switch and performing action: add or remove vlans
    [Arguments]  ${switch_ip_address}  ${switch_user}  ${switch_password}  ${interface}

    ${status}  Check If Target Is Stable  ${switch_ip_address}  30  30  90
    Run Keyword If  ${status}
    ...  Log  Serving switch with IP address ${switch_ip_address} is reachable, test will be continued  console=true
    ...  ELSE
    ...  Fail  msg=Serving switch with IP address ${switch_ip_address} is not reachable, test will be set as failed

    Log  Opening ssh connection to switch: ${switch_ip_address} and performing operation: short interuptions VLAN  console=true
    SSHLibrary.Open Connection  host=${switch_ip_address}
    SSHLibrary.Login  username=${switch_user}  password=${switch_password}
    SSHLibrary.Set Client Configuration  prompt=>#

    FOR  ${loop}  IN RANGE  0  ${NUMBER_OF_LOOPS}
        ${loop_incrementation}  Evaluate  ${loop} + 1
        Log  Current loop is: ${loop_incrementation}  console=true
        SSHLibrary.Write  configure port 1/1/${interface} shutdown
        SSHLibrary.Read Until Prompt
        Wait Random Time
        SSHLibrary.Write  configure port 1/1/${interface} no shutdown
        SSHLibrary.Read Until Prompt
    END
    SSHLibrary.Close All Connections
    Log  Operation is done, test case will be continued [OK]  console=true


Check If TRXs Are In WO State
    [Documentation]
    ...  To check if all TRXs under specified BCF are in WO state

    Log  Querring IM to get BCF ID  console=true
    ${bcf_id}  Infomodel Get BcfId
    Log  BCF ID is equal to: ${bcf_id}  console=true
    Log  TRXs state will be checked under pattern: operational state should be WO  console=true
    ${operational_state}  Get Trxs State  ${bcf_id}  operational

    FOR  ${trx_state}  IN  @{operational_state}
        ${status}  Run Keyword And Return Status
        ...  List Should Contain Value  ${trx_state}  WO
        Run Keyword If  ${status}
        ...  Log  ${trx_state[0]} is in ${trx_state[1]} state TC will continue [OK]  console=true
        ...  ELSE
        ...  Fail  msg=${trx_state[0]} is ${trx_state[1]} state TC will be failed [NOK]
    END


Check Links Status
    [Documentation]
    ...  To check availability status of Abis, S1, DNBAP and CNBAP link statuses
    ...  Link status is added as argument to cover both options available/ unavailable
    [Arguments]  ${link_status}

    ${s1_link_status}  Convert To Lowercase  ${link_status}
    IF  ${SCF_COUNT_LTE}
        S1 Link Status  ${s1_link_status}
    ELSE
        Log  S1 Link status won't be checked because LTE is not commissioned [Info]  console=true
    END

    IF  ${SCF_COUNT_WCDMA}
        CNBAP Link Status  ${link_status}
    ELSE
        Log  CNBAP Link status won't be checked because WCDMA is not commissioned [Info]  console=true
    END

    IF  ${SCF_COUNT_WCDMA}
        DNBAP Link Status  ${link_status}
    ELSE
        Log  DNBAP Link status won't be checked because WCDMA is not commissioned [Info]  console=true
    END

    IF  ${SCF_COUNT_GSM}
        Abis Link Status  ${link_status}
    ELSE
        Log  Abis Link status won't be checked because GSM is not commissioned [Info]  console=true
    END


S1 Link Status
    [Documentation]
    ...  To check S1 link with given status
    ...  Link status is added as argument to cover both options available/ unavailable
    [Arguments]  ${link_status}

    ${lnmme_list}  Get Parameters For All  LNMME
    ${status}  Assert Every  LNMME  s1LinkStatus=${link_status}
    IF  ${status}
        Log  Status of S1 link is correctly set to: ${lnmme_list[0].s1LinkStatus} test will continue [OK]  console=true
    ELSE
        Fail  Status of S1 link is not correctly set to: ${lnmme_list[0].s1LinkStatus} test will be set to failed
    END


CNBAP Link Status
    [Documentation]
    ...  To check CNBAP link with given status
    ...  Link status is added as argument to cover both options available/ unavailable
    [Arguments]  ${link_status}

    ${rnc_list}  Get Parameters For All  RNC

    ${status}  Run Keyword And Return Status  Should Contain  ${rnc_list[0].cnbapLinkStatus}  ${link_status}
    IF  ${status}
        Log  Status of CNBAP link is correctly set to: ${rnc_list[0].cnbapLinkStatus} test will continue [OK]  console=true
    ELSE
        Fail  msg=Status of CNBAP link is not correctly set to: ${rnc_list[0].cnbapLinkStatus} test will be set to failed
    END


DNBAP Link Status
    [Documentation]
    ...  To check DNBAP link with given status
    ...  Link status is added as argument to cover both options available/ unavailable
    [Arguments]  ${link_status}

    ${rnc_list}  Get Parameters For All  RNC

    ${status}  Run Keyword And Return Status  Should Contain  ${rnc_list[0].dnbapLinkStatus}  ${link_status}
    IF  ${status}
        Log  Status of DNBAP link is correctly set to: ${rnc_list[0].dnbapLinkStatus} test will continue [OK]  console=true
    ELSE
        Fail  msg=Status of DNBAP link is not correctly set to: ${rnc_list[0].dnbapLinkStatus} test will be set to failed
    END


Abis Link Status
    [Documentation]
    ...  To check Abis link with given status
    ...  Link status is added as argument to cover both options available/ unavailable
    [Arguments]  ${link_status}

    ${status}  Run Keyword And Return Status  Query Infomodel  every /MRBTS-*/RAT-*/GTS-*/BCF_L-* is [abisOMLinkStatus = ${link_status}]
    IF  ${status}
        Log  Status of Abis link is correctly set to: ${link_status} [OK]  console=true
    ELSE
        Fail  msg=Status of abisOMLinkStatus is not correctly set test will be set to failed
    END


Check CNBAP And DNBAP Link
    [Documentation]  To check state of CNBAP and DNBAP links after Abis link break

    ${status_cnbap}  Run Keyword And Return Status
    ...  CNBAP Link Status  Available
    Run Keyword If  ${status_cnbap}
    ...  Log  CNBAP link status is correctly set after link break [OK]  console=TRUE
    ...  ELSE
    ...  Fail  msg= CNBAP link status is not correctly set after link break

    ${status_dnbap}  Run Keyword And Return Status
    ...  DNBAP Link Status  Available
    Run Keyword If  ${status_dnbap}
    ...  Log  DNBAP link status is correctly set after link break [OK]  console=TRUE
    ...  ELSE
    ...  Fail  msg= DNBAP link status is not correctly set after link break


Check S1 Link Iub Link Break
    [Documentation]  This keyword is used to check S1 link Iub link break.

    ${status_s1}  Run Keyword And Return Status
    ...  S1 Link Status  available
    Run Keyword If  ${status_s1}==${FALSE}
    ...  Fail  msg= S1 link status is not correctly set after link break


Check Abis Link Iub Link Break
    [Documentation]  This keyword is used to check Abis link Iub link break.

    ${status_abis}  Run Keyword And Return Status
    ...  Abis Link Status  Available
    Run Keyword If  ${status_abis}==${FALSE}
    ...  Fail  msg= Abis link status is not correctly set after link break


Check LTE Cells Abis Link Break
    [Documentation]  To check state of LTE cells after Abis link break

    ${status}  Run Keyword And Return Status
    ...  Assert Every  LNCEL  proceduralState=${ON_AIR_DONE}, operationalState=${ENABLED}  timeout=60
    Run Keyword If  ${status}
    ...  Log  Status of LTE cells after Abis link break is correct, test will continue [OK]  console=true
    ...  ELSE
    ...  Fail  msg=Status of LTE cells after Abis link break is correct, test will be set to failed


Check S1 Link
    [Documentation]  To check state of S1 link after Abis link break

    ${status_s1}  Run Keyword And Return Status
    ...  S1 Link Status  available
    Run Keyword If  ${status_s1}
    ...  Log  S1 link status is correctly set after link break [OK]  console=TRUE
    ...  ELSE
    ...  Fail  msg= S1 link status is not correctly set after link break


Get Used VLANs
    [Documentation]
    ...  To collect information about VLAN conifguration
    ...  Output: VLANs are put in list which is create at beginning and then set as test variable

    ${vlans}  coam.Get Managed Objects  VLANIF_A
    ${vlanids}  Create List
    FOR  ${vlan}  IN  @{vlans}
        Append To List  ${vlanids}  ${vlan}[parameters][vlanId]
    END

    Log  List of VLANs which are used on tested SBTS: ${vlanids}  console=true
    Set Test Variable  ${VLANIDS}


Get All Tx Power From All RMs
    [Documentation]
    ...  To collect TX Powers for all RMs and store this information in list
    ...  As an imput KW takes empty list
    [Arguments]  ${rmods_powers}

    Run Keyword If  ${SKIP_RMOD_POWER_CHECK}
    ...  Return From Keyword

    ${rmod_list}  Query Infomodel  get list //RUNTIME_VIEW-*//RMOD_R-*
    FOR  ${rmod}  IN  @{rmod_list}
        ${ref_rmod}  Query Infomodel  get object ${rmod.dist_name}/REF-*
        ${im_rmod_object}  Query Infomodel  get object ${ref_rmod.distName}
        Log  ${\n}TX-Power for ${im_rmod_object.serialNumber} ${im_rmod_object.productName}  console=true
        Run Keyword If  '${im_rmod_object.masterAgentDN}'=='${EMPTY}'
        ...  Continue For Loop
        ${im_sysmod_object}  Query Infomodel  get object ${im_rmod_object.masterAgentDN}
        ${connection}  Run Keyword If  "${OAM_SC_IP}" in "${im_sysmod_object.ipAddress}"
        ...  Set Variable  fct-4a
        ...  ELSE IF  "FSMF" in "${im_sysmod_object.productName}"
        ...  Set Variable  fct
        ...  ELSE
        ...  Set Variable  ${im_sysmod_object.ipAddress}
        ${status}  ${tx_power}  Run Keyword And Ignore Error
        ...  Get Tx Power  ${im_rmod_object.ipAddress}  ${connection}  ${im_rmod_object.productName}
        Run Keyword If  '${status}'=='FAIL'
        ...  Run Keywords
        ...  Log  RMOD ${rmod.productName} with serial number: ${rmod.serialNumber} isn't a supported radio type. Will be skipped.  console=true
        ...  AND
        ...  Continue For Loop
        Set To Dictionary  ${rmods_powers}  ${im_rmod_object.serialNumber}  ${tx_power}
    END


Compare TXs
    [Documentation]  This KW was created to compare powers on RMs before and after some operations
    [Arguments]  ${all_rmods_power_after_operation}  ${all_rmods_power_before_operation}

    Run Keyword If  ${SKIP_RMOD_POWER_CHECK}
    ...  Return From Keyword

    FOR  ${element}  IN  @{all_rmods_power_after_operation.keys()}
        Log  ${element}  console=true
        ${first_list}  Get From Dictionary  ${all_rmods_power_before_operation}  ${element}
        ${second_list}  Get From Dictionary  ${all_rmods_power_after_operation}  ${element}
        ${as_required}  Compare Tx Power  ${first_list}  ${second_list}  10.0
        ${first_list_lenght}  Get Length  ${first_list}
        ${second_list_lenght}  Get Length  ${second_list}
        ${length_status}  Run Keyword And Return Status
        ...  Should Be Equal As Numbers  ${first_list_lenght}  ${second_list_lenght}
        Run Keyword If  ${as_required}
        ...  Log  TxPowers are in range with given dBm tolerance.[OK]  console=true
        ...  ELSE
        ...  Set Test Restriction  TxPowers are different with given dBm tolerance. [NOK]
        Run Keyword If  ${length_status}
        ...  Log  Amount of TxPowers is the same.[OK]  console=true
        ...  ELSE
        ...  Log  Amount of TxPowers are different, investigation should be started. [NOK]  console=true  level=WARN
    END


Checking RNCid And WBTSid From IM
    [Documentation]
    ...  To check what is RNC and WBTS IDs from IM

    ${query_rnc_wbts}  Query Infomodel  get list //RNC_L-*  timeout=30
    FOR  ${entity}  IN  @{query_rnc_wbts}
        Set Test Variable  ${RNC_ID}  ${entity.rncId}
        Set Test Variable  ${WBTS_ID}  ${entity.wbtsId}
    END

    Run Keyword If  ${RNC_ID} and ${WBTS_ID}
    ...  Log To Console  RNCid is: ${RNC_ID}, WBTSid is: ${WBTS_ID}
    ...  ELSE
    ...  Fail  msg=RNCid or WBTSid cannot be received from IM.


Check If WCDMA Cells Are In Working State From RNC PoV
    [Documentation]
    ...  To check if all WCMDA cells under specified RNC are in working state
    ...  This KW returns whether WCell state is WORKING or not (true or false). Result is put in list for all WCells.
    [Arguments]  ${rnc_id}  ${wbts_id}  ${oms_rnc_address}

    ${cells_state}  Create List
    ${wcells_ids}  Infomodel Get All WCELL IDs
    ${oms_params_status}  Run Keyword And Return Status
    ...  Setup NWI3  ${rnc_id}  ${oms_rnc_address}  ${RNC["RNC_USER"]}  ${RNC["RNC_PASSWORD"]}
    Run Keyword If  ${oms_params_status}==${FALSE}
    ...  Fail  msg=Error during OMS parameters setting
    FOR  ${cell}  IN  @{wcells_ids}
        ${current_value}  Get WCEL Parameter  ${wbts_id}  ${cell}  WCelState
        ${is_equal}  Run Keyword And Return Status
        ...  Should Be Equal  ${current_value}  0
        Append To List  ${cells_state}  ${is_equal}
        Run Keyword If  ${is_equal}
        ...  Log  WCell ID: ${cell} is in WORKING state on RNC  console=true
        ...  ELSE
        ...  Log  WCell ID: ${cell} is not in WORKING state on RNC  console=true
    END

    [Return]  ${cells_state}


Get All GSM Tx Power From All RMs
    [Documentation]
    ...  This KW is created to collect GSM TX Powers for all RMs and store this information in list
    [Arguments]  ${rmods_powers}

    ${rmod_list}  Query Infomodel  get list //RUNTIME_VIEW-*//RMOD_R-*
    FOR  ${rmod}  IN  @{rmod_list}
        ${ref_rmod}  Query Infomodel  get object ${rmod.dist_name}/REF-*
        ${im_rmod_object}  Query Infomodel  get object ${ref_rmod.distName}
        ${im_sysmod_object}  Query Infomodel  get object ${im_rmod_object.masterAgentDN}
        ${connection}  Run Keyword If  "${OAM_SC_IP}" in "${im_sysmod_object.ipAddress}"
        ...  Set Variable  fct-4a
        ...  ELSE IF  "FSMF" in "${im_sysmod_object.productName}"
        ...  Set Variable  fct
        ...  ELSE
        ...  Set Variable  ${im_sysmod_object.ipAddress}
        ${status}  ${tx_power}  Run Keyword And Ignore Error
        ...  Get Tx Power  ${im_rmod_object.ipAddress}  ${connection}  ${im_rmod_object.productName}
        Run Keyword If  '${status}'=='FAIL'
        ...  Run Keywords
        ...  Log  RMOD ${rmod.productName} with serial number: ${rmod.serialNumber} isn't a supported radio type. Will be skipped.  console=true
        ...  AND
        ...  Continue For Loop
        Check If TX Power Is OFF  ${tx_power}  GSM
        Append To List  ${rmods_powers}  ${tx_power}
    END


Get All WCDMA Tx Power From All RMs
    [Documentation]
    ...  This KW is created to collect WCDMA TX Powers for all RMs and store this information in list
    [Arguments]  ${rmods_powers}

    ${rmod_list}  Query Infomodel  get list //RUNTIME_VIEW-*//RMOD_R-*
    FOR  ${rmod}  IN  @{rmod_list}
        ${ref_rmod}  Query Infomodel  get object ${rmod.dist_name}/REF-*
        ${im_rmod_object}  Query Infomodel  get object ${ref_rmod.distName}
        ${im_sysmod_object}  Query Infomodel  get object ${im_rmod_object.masterAgentDN}
        ${connection}  Run Keyword If  "${OAM_SC_IP}" in "${im_sysmod_object.ipAddress}"
        ...  Set Variable  fct-4a
        ...  ELSE IF  "FSMF" in "${im_sysmod_object.productName}"
        ...  Set Variable  fct
        ...  ELSE
        ...  Set Variable  ${im_sysmod_object.ipAddress}
        ${status}  ${tx_power}  Run Keyword And Ignore Error
        ...  Get Tx Power  ${im_rmod_object.ipAddress}  ${connection}  ${im_rmod_object.productName}
        Run Keyword If  '${status}'=='FAIL'
        ...  Run Keywords
        ...  Log  RMOD ${rmod.productName} with serial number: ${rmod.serialNumber} isn't a supported radio type. Will be skipped.  console=true
        ...  AND
        ...  Continue For Loop
        Check If TX Power Is OFF  ${tx_power}  WCDMA
        Append To List  ${rmods_powers}  ${tx_power}
    END


Get All LTE Tx Power From All RMs
    [Documentation]
    ...  This KW is created to collect LTE TX Powers for all RMs and store this information in list
    [Arguments]  ${rmods_powers}

    ${rmod_list}  Query Infomodel  get list //RUNTIME_VIEW-*//RMOD_R-*
    FOR  ${rmod}  IN  @{rmod_list}
        ${ref_rmod}  Query Infomodel  get object ${rmod.dist_name}/REF-*
        ${im_rmod_object}  Query Infomodel  get object ${ref_rmod.distName}
        ${im_sysmod_object}  Query Infomodel  get object ${im_rmod_object.masterAgentDN}
        ${connection}  Run Keyword If  "${OAM_SC_IP}" in "${im_sysmod_object.ipAddress}"
        ...  Set Variable  fct-4a
        ...  ELSE IF  "FSMF" in "${im_sysmod_object.productName}"
        ...  Set Variable  fct
        ...  ELSE
        ...  Set Variable  ${im_sysmod_object.ipAddress}
        ${status}  ${tx_power}  Run Keyword And Ignore Error
        ...  Get Tx Power  ${im_rmod_object.ipAddress}  ${connection}  ${im_rmod_object.productName}
        Run Keyword If  '${status}'=='FAIL'
        ...  Run Keywords
        ...  Log  RMOD ${rmod.productName} with serial number: ${rmod.serialNumber} isn't a supported radio type. Will be skipped.  console=true
        ...  AND
        ...  Continue For Loop
        Check If TX Power Is OFF  ${tx_power}  LTE
        Append To List  ${rmods_powers}  ${tx_power}
    END


Check If TX Power Is OFF
    [Documentation]
    ...  This KW is created to check if TX Power for Technology (set as parameter) is set to OFF
    [Arguments]  ${txpower}  ${technology}

    FOR  ${key}  IN  @{txpower.keys()}
        ${as_required}  Run Keyword And Return Status
        ...  Should Contain  ${txpower["${key}"]}  OFF
        Log  ${txpower["${key}"]}  console=true
        Run Keyword If  ${as_required}==${FALSE}
        ...  Set Test Restriction  ${technology} TX Power from id: ${key} equals to ${txpower["${key}"]} but it should be OFF.
    END


Change Parameter ActForce(Unit)AutoReset
    [Documentation]  This KW is created to change parameter actForceUnitAutoReset or actForceAutoReset.
    [Arguments]  ${value}  ${parameter_name}

    ${dist_name_bts_id}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    ${get_parameter_value}  Get ActForce(Unit)AutoReset Value From Infomodel  ${parameter_name}
    Run Keyword If  '${get_parameter_value}'!='${value}'
    ...  Run Keywords
    ...  coam.Perform Parameter Recommissioning  ${dist_name_bts_id}
    ...  ${parameter_name}
    ...  update
    ...  ${value}
    ...  skip_parameter_relation_errors=True
    ...  should_activate=True
    ...  timeout=300
    ...  AND
    ...  Log  ${parameter_name} will be changed to ${value}  console=true


Get ActForce(Unit)AutoReset Value From Infomodel
    [Documentation]  This KW is created to check what value has parameter actForceUnitAutoReset or actForceAutoReset.
    [Arguments]  ${im_parameter}

    ${parametr_name}  Convert To String  ${im_parameter}
    ${parameter_object}  Query Infomodel  get object /MRBTS-1/RAT-1//MNL_A-1/MNLENT_A-1/FMCADM_A-1
    ${parameter_object_value_string}  Convert To String  ${parameter_object.${parametr_name}}
    ${parameter_object_lower}  Convert To Lowercase  ${parameter_object_value_string}

    [Return]  ${parameter_object_lower}


Get List Of DSP For Given Technology Inline With NodeId
    [Documentation]
    ...  This KW is created to collect DSP info for choosen technology inline with nodeId
    [Arguments]  ${rat}

    ${dsp_list}  Create List

    ${dsp_l_list}  Query Infomodel  get list //DSP_L-1/SOFTWARE_ENTITY-* is [rat="${rat}"]
    FOR  ${entity}  IN  @{dsp_l_list}
        ${dsp_dict}  Create Dictionary
        ${dsp_object}  Query Infomodel  get object ${entity.deviceDN}
        ${node_id}  Convert To Hex  ${dsp_object.nodeId}
        Set To Dictionary  ${dsp_dict}  ${entity.deviceDN}  ${node_id}
        Append To List  ${dsp_list}  ${dsp_dict}
    END

    [Return]  ${dsp_list}


Save The Log And Restart Infomodel
    [Documentation]  This KW is for saving the .ims2 log and restarting IM connection
    [Arguments]  ${ims_path}

    Log  Save infomodel before connection restart  console=true
    Save Infomodel Log  ${ims_path}
    Teardown Infomodel
    Log  Connection to infomodel terminated  console=true
    Run Keyword And Continue On Failure
    ...  Start Infomodel


Get FBBX Hosting LTE
    [Documentation]  KW supported when LTE is hosted by one FBBX.
    ...  Output: BBMOD_L string.

    ${layout_entity_list}  Query Infomodel  get list /MRBTS-1/RAT-1/DEM-1/LAYOUT_MAP-*/LAYOUT_ENTITY-*
    FOR  ${layout_entity}  IN  @{layout_entity_list}
        ${deployment}  Set Variable  ${layout_entity.deployment}
        ${bbu_dn}  Set Variable  ${layout_entity.bbuDN}
        ${status}  Run Keyword And Return Status
        ...  Should Be True  "BBMOD" in "${bbu_dn}"
        ${lte_fbbx}  Run Keyword If  ${status} == ${TRUE} and '${deployment}' == 'FDD_6DspPool_Basic'
        ...  Set Variable  ${layout_entity.bbuDN}
        Exit For Loop If  '${lte_fbbx}'!='None'
    END
    ${bbmod}  Fetch From Left  ${lte_fbbx}  /BBU_L-
    Log  Selected BBMOD hosting LTE: ${bbmod}  console=true

    [Return]  ${bbmod}


Check If Any Connector Port Is Used
    [Documentation]  To check if any FBBX port is used.
    ...  Input: BBMOD_L string.
    ...  Output: CONNECTOR_L, connector status.
    [Arguments]  ${bbmod}

    ${conn_status}  Run Keyword And Return Status
    ...  Query Infomodel  get object ${bbmod}/CONNECTOR_L-* is [stateInfo.operationalState="Enabled"]
    ${connector}  Set Variable  ${EMPTY}
    ${connector}  Run Keyword If  ${conn_status}
    ...  Query Infomodel  get object ${bbmod}/CONNECTOR_L-* is [stateInfo.operationalState="Enabled"]
    Run Keyword If  ${conn_status}
    ...  Log  Used connector: ${connector}  console=true
    ...  ELSE
    ...  Log  No FBBX port is used.  console=true

    [Return]  ${connector}


Get Rmod Related To FBBX Connector
    [Documentation]  To collect RMOD object related to used FBBX cablink.
    [Arguments]  ${connector}

    ${cablnk}  Query Infomodel  get object //CABLNK_L-* is [destinationDistName="${connector.dist_name}"]
    ${rmod_connector_dn}  Set Variable  ${cablnk.sourceDistName}
    ${rmod_l_object}  Fetch From Left  ${rmod_connector_dn}  /CONNECTOR_L-
    ${rmod_l_object}  Query Infomodel  get object ${rmod_l_object}
    Log  Serial number of RMOD connected to FBBX: ${rmod_l_object.serialNumber}  console=true

    [Return]  ${rmod_l_object}


Collect Cells Deployed On Rmod And Fsp
    [Documentation]  To collect cells deployed on RMOD and FSP, and also each cell's RAT for further checks.
    ...  RMOD and BBU added as arguments.
    [Arguments]  ${rmod_l_object}  ${bbmod}

    ${rmod_cells}  Infomodel Get Cells Deployed On RMOD  ${rmod_l_object}
    ${bbmod_object}  Query Infomodel  get object ${bbmod}
    ${selected_fbbx_sn}  Set Variable  ${bbmod_object.serialNumber}
    ${fsp_cells}  Infomodel Get Cells Deployed On FSP  ${bbmod_object}
    Sort List  ${rmod_cells}
    Sort List  ${fsp_cells}
    ${rmod_cells_rat}  Create List  @{EMPTY}
    FOR  ${cell}  IN  @{rmod_cells}
        Append To List  ${rmod_cells_rat}  ${cell.rat}
    END
    ${fsp_cells_rat}  Create List  @{EMPTY}
    FOR  ${cell}  IN  @{fsp_cells}
        Append To List  ${fsp_cells_rat}  ${cell.rat}
    END

    [Return]  ${selected_fbbx_sn}  ${rmod_cells_rat}  ${fsp_cells_rat}


Check FBBX Mode
    [Documentation]  To check if FBBX is working in transparent or local mode.
    ...  KW compares RAT deployment between RMOD and FSP.
    [Arguments]  ${selected_fbbx_sn}  ${rmod_cells_rat}  ${fsp_cells_rat}

    ${fsp_cells_rat_status}  Run Keyword And Return Status
    ...  List Should Contain Value  ${fsp_cells_rat}  LTE
    ${rmod_cells_rat_status}  Run Keyword And Return Status
    ...  List Should Not Contain Value  ${rmod_cells_rat}  LTE
    Run Keyword If  ${fsp_cells_rat_status}==${rmod_cells_rat_status}
    ...  Log  FBBX serial number: ${selected_fbbx_sn} is in Transparent Mode.  console=true
    ...  ELSE
    ...  Log  FBBX serial number: ${selected_fbbx_sn} is in Local Mode.  console=true


Gsm Active Carriers
    [Documentation]  In this keyword the state of GSM carriers will be checked.

    Log  \nCheck GSM Carriers  console=true
    ${active_carriers}  Create List
    ${gsm_cell_list}  Query Infomodel  get list //GNCEL_L-*
    ${gsm_lenght}  Get Length  ${gsm_cell_list}

    Log  List of GSM cells is ${gsm_cell_list}
    Log  Number of GSM cells is ${gsm_lenght}  console=true

    FOR  ${gcell}  IN  @{gsm_cell_list}
        ${temp_string}  Convert To String  ${gcell['bcchCarrierGroupDNs']}
        ${bcch_path}  Get Substring  ${temp_string}  4  -2
        Log  BCCH path is ${bcch_path}  console=true
        ${query_uplane_carrier}  Catenate  get list //GNCEL_L-${gcell.lcrId}/CARRIER_GROUP_L-*/UPLANE_CARRIER_L-* is
        ...  [direction=Downlink,stateInfo.availabilityStatus=Online,stateInfo.operationalState=Enabled]
        ${carrier_type}  Query Infomodel  ${query_uplane_carrier}
        Log  Carrier type ${carrier_type}
        ${active_carriers}  Combine Lists  ${active_carriers}  ${carrier_type}
    END

    Log  list of active GSM carriers is ${active_carriers}
    ${nbr_carriers}  Get Length  ${active_carriers}
    Log  Total number of GSM carriers is ${nbr_carriers}  console=true

    [Return]  ${nbr_carriers}


Lte Active Carriers
    [Documentation]  In this keyword the state of LTE carriers will be checked.

    Log  \nCheck LTE Carriers  console=true
    ${active_carriers}  Create List
    ${lte_cell_list}  Query Infomodel  get list //LNCEL_L-* is [technology=fdd]
    ${lte_lenght}  Get Length  ${lte_cell_list}

    Log  List of LTE cells is ${lte_cell_list}
    Log  Number of LTE cells is ${lte_lenght}  console=true

    FOR  ${lcell}  IN  @{lte_cell_list}
        ${lcell_name}  Convert To String  ${lcell['dist_name']}
        Log  Cell name is ${lcell_name}  console=true
        ${carrier_type}  Query Infomodel
        ...  get list ${lcell_name}/CARRIER_GROUP_L-1/UPLANE_CARRIER_L-* is [direction=Downlink,stateInfo.availabilityStatus=Online]
        Log  Carrier type ${carrier_type}
        ${active_carriers}  Combine Lists  ${active_carriers}  ${carrier_type}
    END

    Log  list of active LTE carriers is ${active_carriers}
    ${nbr_carriers}  Get Length  ${active_carriers}
    Log  Total number of LTE carriers is ${nbr_carriers}  console=true

    [Return]  ${nbr_carriers}


Wcdma Active Carriers
    [Documentation]  In this keyword the state of WCDMA carriers will be checked.

    Log  \nCheck WCDMA Carriers  console=true
    ${active_carriers}  Create List
    ${3g_cell_list}  Query Infomodel  get list //WNCEL_L-*
    ${3g_lenght}  Get Length  ${3g_cell_list}

    Log  List of WCDMA cells is ${3g_cell_list}
    Log  Number of WCDMA cells is ${3g_lenght}  console=true

    FOR  ${3gcell}  IN  @{3g_cell_list}
        ${3gcell_name}  Convert To String  ${3gcell['dist_name']}
        Log  Cell name is ${3gcell_name}  console=true

        ${carrier_type}  Query Infomodel
        ...  get list ${3gcell_name}/CARRIER_GROUP_L-1/UPLANE_CARRIER_L-* is [direction=Downlink,stateInfo.availabilityStatus=Online]
        Log  Carrier type ${carrier_type}
        ${active_carriers}  Combine Lists  ${active_carriers}  ${carrier_type}
    END

    Log  list of active WCDMA carriers is ${active_carriers}
    ${nbr_carriers}  Get Length  ${active_carriers}
    Log  Total number of WCDMA carriers is ${nbr_carriers}  console=true

    [Return]  ${nbr_carriers}


Get ActFaultSignature Value From Infomodel
    [Documentation]
    ...  This KW is created to check what value has parameter actFaultSignature
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${im_parameter}

    ${parametr_name}  Convert To String  ${im_parameter}
    ${parameter_object}  Query Infomodel  get object //MNL_A-1/MNLENT_A-1/FEATCADM_A-1
    ${parameter_object_value_string}  Convert To String  ${parameter_object.${parametr_name}}
    ${parameter_object_lower}  Convert To Lowercase  ${parameter_object_value_string}

    [Return]  ${parameter_object_lower}


Change Parameter ActFaultSignature
    [Documentation]
    ...  This KW is created to change parameter actFaultSignature
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${value}  ${parameter_name}

    ${dist_name_bts_id}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${get_parameter_value}  Get ActFaultSignature Value From Infomodel  ${parameter_name}

    Run Keyword If  '${get_parameter_value}'!='${value}'
    ...  Run Keywords
    ...  Log  ${parameter_name} will be changed to ${value}  console=true
    ...  AND
    ...  coam.Perform Parameter Recommissioning  ${dist_name_bts_id}
    ...  ${parameter_name}
    ...  update
    ...  ${value}
    ...  skip_parameter_relation_errors=True
    ...  should_activate=True
    ...  timeout=300


Check Which Core Is Primary
    [Documentation]  This KW is created to set primary core prefix needed to create sic addresses

    ${bts_l}  Query Infomodel  get list //BTS_L-*
    ${bts_l_lenght}  Get Length  ${bts_l}
    ${element}  Get From List  ${bts_l}  0

    Run Keyword If  ${bts_l_lenght} == 1
    ...  Get Single Core Prefix  ${element}
    ...  ELSE
    ...  Get Dual Core Prefix


Get Single Core Prefix
    [Documentation]  This KW is created to set primary core prefix if config is sigle core
    [Arguments]  ${bts}

    Log  BTS is single core and hwapiDomainId is: ${bts.hwapiDomainId}  console=true
    ${status}  Run Keyword And Return Status
    ...  Should Contain  '${bts.hwapiDomainId}'  1

    Run Keyword If  ${status}
    ...  Run Keywords
    ...  Set Test Variable  ${PRIMARY_CORE_BTS_L}  BTS_L-1
    ...  AND
    ...  Log  Primary core has been found under 0x1011  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Set Test Variable  ${PRIMARY_CORE_BTS_L}  BTS_L-4
    ...  AND
    ...  Log  Primary core has been found under 0x2011  console=true
    Set Test Variable  ${PRIMARY_CORE_PREFIX}  ${PRIMARY_CORE_BTS_L}

    [Return]  ${PRIMARY_CORE_PREFIX}


Get Dual Core Prefix
    [Documentation]  This KW is created to set primary core prefix if config is dual core

    ${bts_l}  Query Infomodel  get list //BTS_L-* is [storedRole=Active]
    ${bts_l_lenght}  Get Length  ${bts_l}

    ${element}  Get From List  ${bts_l}  0

    ${status}  Run Keyword And Return Status
    ...  Should Contain  ${element["dist_name"]}  /MRBTS-1/RAT-1/BTS_L-1

    Run Keyword If  ${status}
    ...  Run Keywords
    ...  Set Test Variable  ${PRIMARY_CORE_BTS_L}  BTS_L-1
    ...  AND
    ...  Log  Primary core has been found under 0x1011  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Set Test Variable  ${PRIMARY_CORE_BTS_L}  BTS_L-4
    ...  AND
    ...  Log  Primary core has been found under 0x2011  console=true
    Set Test Variable  ${PRIMARY_CORE_PREFIX}  ${PRIMARY_CORE_BTS_L}

    [Return]  ${PRIMARY_CORE_PREFIX}


Crash VN On AirScale
    [Documentation]  This KW is created to crash VN using kill-9 <PID> command.
    [Arguments]  ${vnu_dist_name}  ${low_node_id}

    Log  ${vnu_dist_name.dist_name}.  console=true
    ${is_on_secondary}  Run Keyword And Return Status  Should Not Contain  ${vnu_dist_name}[dist_name]  ${PRIMARY_CORE_BTS_L}
    ${is_on_bbmod}  Run Keyword And Return Status  Should Contain  ${vnu_dist_name.dist_name}  BBMOD_L
    IF  ${is_on_bbmod}
      ${bbmod_position}  Get BBMOD Position From Vnu Dist Name  ${vnu_dist_name}[dist_name]
    END
    Open Connection To Primary Core
    IF  ${is_on_secondary}  Open Connection To Secondary Core
    IF  ${is_on_bbmod}  Open Connection To SOC  ${bbmod_position}  0

    SSHLibrary.Write  lxc-attach -n ${low_node_id} ps aux | grep btssw
    ${result}  SSHLibrary.Read Until Prompt
    ${regex}  Get Regexp Matches  ${result}  btssw\\s+\\d+
    ${length_list}  Get Length  ${regex}
    ${random_regex}  Evaluate  random.randint(0, ${length_list}-1)  modules=random
    ${from_list}  Get From List  ${regex}  ${random_regex}
    ${words}  Split String  ${from_list}
    ${process_id}  Get From List  ${words}  1
    SSHLibrary.Write  lxc-attach -n ${low_node_id} -- kill -9 ${process_id}
    ${kill}  SSHLibrary.Read Until Prompt


Get BBMOD Position From Vnu Dist Name
    [Documentation]  This keyword is used to get BBMOD position from vnu dist name.
    [Arguments]  ${dist_name}

    ${is_bbu}  Run Keyword And Return Status  Should Contain  ${dist_name}  BBU
    ${is_board}  Run Keyword And Return Status  Should Contain  ${dist_name}  BOARD
    ${string}  Set Variable If
    ...  ${is_bbu}  /BBU
    ...  ${is_board}  /BOARD
    ${bbmod_distname}  Fetch From Left  ${dist_name}  ${string}
    ${bbmod_l}  coam.Get Parameters  ${bbmod_distname}
    ${fbb_info}  Get FBB Info
    FOR  ${item}  IN  @{fbb_info}
        ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${item}[serialNumber]  ${bbmod_l}[serialNumber]
        ${bbmod_r}  Set Variable If  ${status}  ${item}[id][internal]
        IF  ${status}  BREAK
    END
    ${position}  Get Module Vertical Position  ${bbmod_r}

    [Return]  ${position}


Crash VN On FSMF
    [Documentation]  This KW is created to crash L3Pool VN using kill-9 <PID> command on FSMF platform
    [Arguments]  ${vnu_dist_name}  ${low_node_id}

    ${rio_list_msm}  Create List  192.168.253.18  192.168.253.19  192.168.253.20
    ${rio_list_esm}  Create List  192.168.253.34  192.168.253.35  192.168.253.36
    ${status}  Run Keyword And Return Status
    ...  Should Not Contain  ${vnu_dist_name.dist_name}  ${PRIMARY_CORE_BTS_L}
    ${smod_ip}  Set Variable If  ${status}  ${OAM_SC_IP}  ${OAM_BTS_IP}
    Run Keyword If  ${status}
    ...  RIO-IP Check  ${vnu_dist_name.dist_name}  ${rio_list_esm}
    ...  ELSE
    ...  RIO-IP Check  ${vnu_dist_name.dist_name}  ${rio_list_msm}

    Log  FSP is: ${FSP_IP}  console=true

    Crash Container  ${FSP_IP}  ${low_node_id}  ${smod_ip}


RIO-IP Check
    [Documentation]  To set appropriate FSP IP keeping in mind VNU location
    [Arguments]  ${dist_name}  ${rio_list}

    ${status_fct}  Run Keyword And Return Status
    ...  Should Contain  ${dist_name}  SMOD_L-1
    ${status_bbmod_1}  Run Keyword And Return Status
    ...  Should Contain  ${dist_name}  BBMOD_L-1
    ${status_bbmod_2}  Run Keyword And Return Status
    ...  Should Contain  ${dist_name}  BBMOD_L-2
    ${status_list}  Create List  ${status_fct}  ${status_bbmod_1}  ${status_bbmod_2}

    ${helper}  Set Variable  0
    FOR  ${item}  IN  @{status_list}
        Run Keyword If  '${item}' == 'True'
        ...  Run Keywords
        ...  Set Test Variable  ${FSP_IP}  ${rio_list[${helper}]}
        ...  AND
        ...  Exit For Loop
        ${helper}  Evaluate  ${helper}+1
    END


Check WCDMA Cells
    [Documentation]  To check state of WCDMA cells after operation
    [Arguments]  ${usage_state}  ${operational_state}  ${availability_state}=${EMPTY}

    ${string}  Set Variable If  '${availability_state}'=='${EMPTY}'  usageState=${usage_state}, operationalState=${operational_state}
    ...  '${availability_state}'!='${EMPTY}'
    ...  usageState=${usage_state}, operationalState=${operational_state}, availabilityStatus=${availability_state}

    ${status}  Run Keyword And Return Status
    ...  Assert Every  WNCEL  ${string}  timeout=45
    Run Keyword If  ${status}
    ...  Log  Status of WCDMA cells after operation is correct: ${usage_state}, ${operational_state}, ${availability_state}. Test will continue [OK]
    ...  console=TRUE
    ...  ELSE
    ...  Fail  msg=Status of WCDMA cells after operation is not correct, test will be set to failed [NOK]


Check WCDMA Cells Abis Link Break
    [Documentation]  To check state of WCDMA cells after Abis link break

    ${status}  Run Keyword And Return Status
    ...  Assert Every  WNCEL  usageState=${ACTIVE}, operationalState=${ENABLED}  timeout=120
    Run Keyword If  ${status}
    ...  Log  Status of WCDMA cells after Abis link break is correct, test will continue [OK]  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Restore Abis Link
    ...  AND
    ...  Fail  msg=Status of WCDMA cells after Abis link break is not correct, test will be set to failed


Check GSM Cells
    [Documentation]  To check state of GSM cells after operation
    [Arguments]  ${usage_state}  ${operational_state}  ${availability_state}=${EMPTY}

    ${string}  Set Variable If  '${availability_state}'=='${EMPTY}'  usageState=${usage_state}, operationalState=${operational_state}
    ...  '${availability_state}'!='${EMPTY}'
    ...  usageState=${usage_state}, operationalState=${operational_state}, availabilityStatus=${availability_state}

    ${status}  Run Keyword And Return Status
    ...  Assert Every  GNCEL  ${string}  timeout=180
    Run Keyword If  ${status}
    ...  Log  Status of GSM cells after operation is correct: ${usage_state}, ${operational_state}, ${availability_state}. Test will continue [OK]
    ...  console=TRUE
    ...  ELSE
    ...  Fail  msg=Status of GSM cells after operation is not correct, test will be set to failed [NOK]


Check GSM Cells IuB Link Break
    [Documentation]  To check state of GSM cells after IuB link break
    [Arguments]  ${usage_state}  ${operational_state}  ${availability_state}=${EMPTY}

    ${string}  Set Variable If  '${availability_state}'=='${EMPTY}'  usageState=${usage_state}, operationalState=${operational_state}
    ...  '${availability_state}'!='${EMPTY}'
    ...  usageState=${usage_state}, operationalState=${operational_state}, availabilityStatus=${availability_state}

    ${status}  Run Keyword And Return Status
    ...  Assert Every  GNCEL  ${string}  timeout=180
    Run Keyword If  ${status}
    ...  Log  Status of GSM cells after IuB link break is correct: ${usage_state}, ${operational_state}, ${availability_state}.Test will continue
    ...  console=true
    ...  ELSE
    ...  Fail  msg=Status of GSM cells after IuB link break is correct, test will be set to failed


Get SM Variant For RMOD
    [Documentation]  KW returns variant of tested SM
    ...   Possible returns:
    ...   'AirScale'
    ...   'FSMr3'
    [Arguments]  ${rmod}

    ${smod}  Query Infomodel  get object ${rmod.masterAgentDN}
    ${is_fsmf}  Run Keyword And Return Status
    ...  Should Contain  ${smod.productName}  FSMF
    Return From Keyword If  ${is_fsmf}  FSMr3
    ${is_airscale}  Run Keyword And Return Status
    ...  Should Contain  ${smod.productName}  AirScale
    Return From Keyword If  ${is_airscale}  AirScale


Get SM Variant FM
    [Documentation]  KW returns variant of tested SM
    ...   Possible returns:
    ...   'AirScale'
    ...   'FSMr3'

    ${sm_dn}  Get Id For Current  SMOD
    Log  SM variant: ${sm_dn}  console=true
    ${smod_obj}  Get Parameters For  class_name=SMOD  id_num=${sm_dn}
    ${is_fsmf}  Run Keyword And Return Status
    ...  Should Contain  ${smod_obj.productName}  FSMF
    Return From Keyword If  ${is_fsmf}  FSMr3
    ${is_airscale}  Run Keyword And Return Status
    ...  Should Contain  ${smod_obj.productName}  AirScale
    Return From Keyword If  ${is_airscale}  AirScale


Get SM Variant From Node
    [Documentation]  This keyword is used to get SM variant from node.
    [Arguments]  ${dist_name}

    ${bts_l_dist_name}  Fetch From Left  ${dist_name}  /EQM_L-1
    ${smod_l_dist_name}  Catenate  SEPARATOR=  ${bts_l_dist_name}  /EQM_L-1/CABINET_L-1/SMOD_L-1
    ${smod_l}  Query Infomodel  get object ${smod_l_dist_name}
    ${is_airscale}  Run Keyword And Return Status
    ...  Should Match Regexp  ${smod_l.productName}  (ASIA|ASIB|ASIL|ASIM)
    ${is_flexi}  Run Keyword And Return Status
    ...  Should Match Regexp  ${smod_l.productName}  (FSMF|FSIH)
    ${type}  Set Variable If  ${is_airscale}  AirScale  Flexi

    [Return]  ${type}


Get SctpWaitTimeInitSeqRetryX2 Value
    [Documentation]
    ...  This KW is created to check what value has parameter sctpWaitTimeInitSeqRetryX2
    ...  *AUTHOR* laura.craciunel@nokia.com

    [Arguments]  ${parameter}

    ${list}  Create List  ${parameter}
    ${object}  Get Parameter By Distname  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/SCTP-1  ${list}
    ${actual_value}  Set Variable  ${object}[0][parameters][${parameter}]
    Log  Current parameter value ${actual_value}.  console=true

    RETURN  ${actual_value}



Remove NbIot Cells From List
    [Documentation]  This keyword is used to remove NbIot cells from list.
    [Arguments]  ${cell_list}

    FOR  ${cell}  IN  @{cell_list}
        ${nbiot_status}  Run Keyword And Return Status
        ...  Query Infomodel  get object ${cell.dist_name}/LNCEL_M-* is [technology=NbIotFddGuardband]
        Run Keyword If  ${nbiot_status}
        ...  Remove Values From List  ${cell_list}  ${cell}
    END

    [Return]  ${cell_list}


Check If Affected Cells Have IoT Associated Cells And Add Them To List
    [Documentation]  Adds IoT-associated cells to the list of affected cells and returns the complete list.
    [Arguments]  ${affected_cells}

    ${complete_affected_cells}  Create List
    Append To List  ${complete_affected_cells}  @{affected_cells}
    FOR  ${cell}  IN  @{affected_cells}
        ${ref_obj}  coam.Get Parameters  ${cell}/REF-1
        ${cell_l_obj}  coam.Get Parameters  ${ref_obj}[distName]
        ${nbIoTMode}  Evaluate  $cell_l_obj.get('nbIoTMode')
        IF  '${nbIoTMode}'=='${None}'  CONTINUE
        ${iot_cell_status}  Run Keyword And Return Status  Should Match Regexp  '${cell_l_obj}[nbIotLinkedCellId]'  [0-9]+
        IF  not(${iot_cell_status})  CONTINUE
        ${lncel_l_objects}  coam.Get Managed Objects  LNCEL_L
        FOR  ${lncel_l_object}  IN  @{lncel_l_objects}
            IF  '${lncel_l_object}[parameters][lcrId]'=='${cell_l_obj}[nbIotLinkedCellId]'
                ${iot_cell_r}  ${id}  Split String From Right  ${cell}  -  1
                Append To List  ${complete_affected_cells}  ${iot_cell_r}-${lncel_l_object}[lnCelId]
                BREAK
            END
        END
    END

    RETURN  ${complete_affected_cells}


Get Cores Pool Used By Given Cell
    [Documentation]
    ...  This KW was created to return cell to pool mapping and pool to cores mapping by given cell
    ...  *AUTHOR* bogdan.boldurean@nokia.com
    [Arguments]  ${cell_to_pool_mapping}

    ${core_pool_list}  Create List
    FOR  ${element}  IN  @{cell_to_pool_mapping.cellSlots}
        Log  ${element}[poolDN]
        Append To List  ${core_pool_list}  ${element}[poolDN]
    END
    ${core_pool_list_edit}  Remove Duplicates  ${core_pool_list}
    ${list}  Create List
    FOR  ${pool}  IN  @{core_pool_list_edit}
        ${pool_obj}  Query Infomodel  get object ${pool}
        Log  ${pool_obj}[cores]  console=true
        ${core_dn}  Return CoreDN  ${pool_obj}[cores]
        Append To List  ${list}  @{core_dn}
    END

    [Return]  ${list}


Return CoreDN
    [Documentation]
    ...  This KW was created to return coreDN dist name list from core pool given
    ...  *AUTHOR* bogdan.boldurean@nokia.com
    [Arguments]  ${core}

    ${core_dn_list}  Create List
    FOR  ${object}  IN  @{core}
        Log  ${object}[coreDN]  console=true
        Append To List  ${core_dn_list}  ${object}[coreDN]
    END

    [Return]  ${core_dn_list}


Restore Link
    [Documentation]  KW to restore given VLAN link for link break tests.
    [Arguments]  ${vlan}

    Wait Until Keyword Succeeds  5min  1min
    ...  Connect To Nokia Serving Switch And Perform Action  ${SWITCH_IP}  ${SWITCH_USER}  ${SWITCH_PASSWORD}  ${vlan}  ${INTERFACE_ID}  no shutdown


Check NR Status
    [Documentation]
    ...  To check X2 link and NR cell status are in expected state.
    ...  *AUTHOR* bogdan.boldurean@nokia.com
    [Arguments]  ${operational_state}  ${x2_link}

    Assert Every  NRCEL  operationalState=${operational_state}  timeout=60
    LTEENB Link Status  ${x2_link}


LTEENB Link Status
    [Documentation]
    ...  To check X2 link has given status
    ...  Link status is added as argument to cover both options available/ unavailable
    ...  *AUTHOR* bogdan.boldurean@nokia.com
    [Arguments]  ${link_status}

    ${link_status_lower}  Convert To Lowercase  ${link_status}
    ${lteenb}  Query Infomodel  get list //LTEENB_R-*
    FOR  ${element}  IN  @{lteenb}
        Run Keyword If  '${element.x2LinkStatus}'=='${link_status_lower}'
        ...  Log  Status of X2 link is correctly set to: ${element.x2LinkStatus} test will continue [OK]  console=true
        ...  ELSE
        ...  Fail  Status of X2 link is not correctly set to: ${element.x2LinkStatus} test will be set to failed
    END


Get MaxNumX2Links Parameter Value From Infomodel
    [Documentation]
    ...  This KW is created to check the value of maxNumX2Links parameter.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${im_parameter}

    ${parameter_name}  Convert To String  ${im_parameter}
    ${parameter_object}  Query Infomodel  get object //NRBTS_A-*
    ${parameter_object_value_string}  Convert To String  ${parameter_object.${parameter_name}}
    ${parameter_object_lower}  Convert To Lowercase  ${parameter_object_value_string}

    [Return]  ${parameter_object_lower}


Get ActEnhancedX2LinkSupervision Parameter Value From Infomodel
    [Documentation]
    ...  This KW is created to check the value of actEnhancedX2LinkSupervision parameter.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${im_parameter}

    ${parameter_name}  Convert To String  ${im_parameter}
    ${parameter_object}  Query Infomodel  get object //NRBTS_A-*
    ${parameter_object_value_string}  Convert To String  ${parameter_object.${parameter_name}}
    ${parameter_object_lower}  Convert To Lowercase  ${parameter_object_value_string}

    [Return]  ${parameter_object_lower}


Change Parameter MaxNumX2Links
    [Documentation]
    ...  This KW is created to change the value of maxNumX2Links parameter.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${value}  ${parameter_name}  ${dist_name_parameter}

    ${get_parameter_value}  Get MaxNumX2Links Parameter Value From Infomodel  ${parameter_name}
    Run Keyword If  '${get_parameter_value}'!='${value}'
    ...  Run Keywords
    ...  coam.Perform Parameter Recommissioning  ${dist_name_parameter}
    ...  ${parameter_name}
    ...  update
    ...  ${value}
    ...  skip_parameter_relation_errors=True
    ...  should_activate=True
    ...  timeout=100
    ...  AND
    ...  Log  ${parameter_name} was changed to ${value}  console=true


Change Parameter ActEnhancedX2LinkSupervision
    [Documentation]
    ...  This KW is created to change the value of actEnhancedX2LinkSupervision parameter.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${value}  ${parameter_name}  ${dist_name_parameter}

    ${get_parameter_value}  Get ActEnhancedX2LinkSupervision Parameter Value From Infomodel  ${parameter_name}
    Run Keyword If  '${get_parameter_value}'!='${value}'
    ...  Run Keywords
    ...  coam.Perform Parameter Recommissioning  ${dist_name_parameter}
    ...  ${parameter_name}
    ...  update
    ...  ${value}
    ...  skip_parameter_relation_errors=True
    ...  should_activate=True
    ...  timeout=100
    ...  AND
    ...  Log  ${parameter_name} was changed to ${value}  console=true


Set actAlarmsSuppression to disabled
    [Documentation]
    ...  This keyword updates actAlarmsSuppression to disabled under ALARMSUPP.
    ...  If actAlarmsSuppression is already disabled, no delta or recommissioning is performed.
    ...  *AUTHOR* laura.craciunel@nokia.com

    ${list}  Create List  actAlarmsSuppression
    ${object}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  ${list}
    ${actual_value}  Convert To String  ${object}[0][parameters][actAlarmsSuppression]
    ${actual_value}  Convert To Lower Case  ${actual_value}
    IF  '${actual_value}' == 'disabled'
        Log  actAlarmsSuppression is already disabled under ALARMSUPP, no change needed.  console=true
        RETURN
    END
    Log  actAlarmsSuppression will be set to disabled under ALARMSUPP.  console=true
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  disabled  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_actAlarmsSuppression_disabled.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta_actAlarmsSuppression_disabled.json  timeout=120
    Remove Delta  ${delta_id}


Add Given MOC And Severity To SuppressAlarmsByMOCList
    [Documentation]
    ...  This keyword adds given structure of alarmSeverity/moc/mocDN/productCode to suppressAlarmsByMOCList under ALARMSUPP.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${suppress_alarms_by_moc_list}

    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append List Items To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  suppressAlarmsByMOCList
    ...  @{suppress_alarms_by_moc_list}  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  suppressAlarms  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_suppress_by_moc_list.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta_suppress_by_moc_list.json  timeout=120
    Remove Delta  ${delta_id}
    Log  suppressAlarmsByMOCList changed to:\n${suppress_alarms_by_moc_list}.  console=true


Add Given Alarm And Severity To AllowedAlarmList
    [Documentation]
    ...  This keyword adds given alarm structure with alarm ids with severity to allowedAlarmList under ALARMSUPP.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${allowed_alarm_list}

    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append List Items To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  allowedAlarmList
    ...  @{allowed_alarm_list}  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  allowAlarms  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_allow_by_alarm_list.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta_allow_by_alarm_list.json  timeout=120
    Remove Delta  ${delta_id}
    Log  allowedAlarmList changed to:\n${allowed_alarm_list}.  console=true


Check If Only Allowed Alarms And Faults Are Active
    [Documentation]
    ...  This keyword checks if only allowed alarms and faults ids are active in WebEM.
    ...  This keyword is used in CB010788 testing when allowedAlarmList or allowedFaultList is configured.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${list_ids}  ${severity}  ${alarm_or_fault}

    ${active_alarms}  Assert Alarm Active
    ${active_warning_ids}  Create List
    ${active_minor_ids}  Create List
    ${active_major_ids}  Create List
    ${active_critical_ids}  Create List
    FOR  ${alarm}  IN  @{active_alarms}
         IF  '${alarm_or_fault}'=='alarm'
           ${id}  Convert To Integer  ${alarm}[alarmId]
         ELSE IF  '${alarm_or_fault}'=='fault'
           ${id}  Convert To Integer  ${alarm}[faultId]
         ELSE
           Fail  Incorect argument value for keyword.
         END
         IF  '${alarm}[severity]'=='Warning'
           Append To List  ${active_warning_ids}  ${id}
         ELSE IF  '${alarm}[severity]'=='Minor'
           Append To List  ${active_minor_ids}  ${id}
         ELSE IF  '${alarm}[severity]'=='Major'
           Append To List  ${active_major_ids}  ${id}
         ELSE IF  '${alarm}[severity]'=='Critical'
           Append To List  ${active_critical_ids}  ${id}
         END
    END
    ${active_warning_ids}  Remove Duplicates  ${active_warning_ids}
    ${active_minor_ids}  Remove Duplicates  ${active_minor_ids}
    ${active_minor_warning}  Combine Lists  ${active_minor_ids}  ${active_warning_ids}
    ${active_minor_warning}  Remove Duplicates  ${active_minor_warning}
    IF  '${severity}'=='Warning'
      Lists Should Be Equal  ${active_warning_ids}  ${list_ids}  ignore_order=True
      ...  msg=Expected ${severity} ${alarm_or_fault} with ids ${list_ids} differs than active ids ${active_warning_ids}.
    ELSE IF  '${severity}'=='Minor'
      Lists Should Be Equal  ${active_minor_ids}  ${list_ids}  ignore_order=True
      ...  msg=Expected ${severity} ${alarm_or_fault} with ids ${list_ids} differs than active ids ${active_minor_ids}.
    ELSE IF  '${severity}'=='Minor_Warning'
      Lists Should Be Equal  ${active_minor_warning}  ${list_ids}  ignore_order=True
      ...  msg=Expected ${severity} ${alarm_or_fault} with ids ${list_ids} differs than active ids ${active_minor_warning}.
    ELSE
      Fail  Given severity can be only Minor or Warning.
    END
    Log  Allowed ${alarm_or_fault} ids : ${list_ids} .  console=true
    Log  Active ${alarm_or_fault} with severity Warning : ${active_warning_ids} .  console=true
    Log  Active ${alarm_or_fault} with severity Minor : ${active_minor_ids} .  console=true
    Log  Active ${alarm_or_fault} with severity Major : ${active_major_ids} .  console=true
    Log  Active ${alarm_or_fault} with severity Critical : ${active_critical_ids} .  console=true


Perform Site Reset And Verify Fault 4592
    [Documentation]  Performs site reset and verifies that fault 4592 reaches the expected status.
    [Arguments]  ${system_module}  ${status_fault_4592}

    ${date_time_raw_suppresed}  Get BTS Time In UTC Format  %Y-%m-%d %H:%M:%S
    ${date_time_raw_history}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    Change FMCADM Parameter  fault4592CancellationTimer  1800
    Log  Site reset will be performed.  console=true
    coam.Reset Site
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  1min  Check Modules And Cells
    Verify Fault 4592 Presence  system_module=${system_module}  status_fault_4592=${status_fault_4592}
    ...  time_raw_suppresed=${date_time_raw_suppresed}  time_raw_history=${date_time_raw_history}


Power Off/On System Module And Verify Fault 4592
    [Documentation]  Powers off and on the system module and verifies fault 4592 status.
    [Arguments]  ${system_module}  ${status_fault_4592}

    ${date_time_raw_suppresed}  Get BTS Time In UTC Format  %Y-%m-%d %H:%M:%S
    ${date_time_raw_history}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    Change FMCADM Parameter  fault4592CancellationTimer  1800
    Log  Power off interface SMOD_${system_module}[serialNumber].  console=true
    Pdu BTS Interface Off  SMOD_${system_module}[serialNumber]
    Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=300
    Log  Power on interface SMOD_${system_module}[serialNumber].  console=true
    Pdu BTS Interface On  SMOD_${system_module}[serialNumber]
    Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=300
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check Modules And Cells
    Log  Modules and cells enabled after power off/on.  console=true
    Verify Fault 4592 Presence  system_module=${system_module}  status_fault_4592=${status_fault_4592}
    ...  time_raw_suppresed=${date_time_raw_suppresed}  time_raw_history=${date_time_raw_history}


Verify Fault 4592 Presence
    [Documentation]  Verifies that fault 4592 is present (or absent) with the expected status in the given time range.
    [Arguments]  ${system_module}  ${status_fault_4592}  ${time_raw_suppresed}  ${time_raw_history}

    ${string_module_id}  Replace String Using Regexp  ${system_module}[id][internal]  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    ${dn_internal}  Catenate  SEPARATOR=/  PLMN-PLMN  ${string_module_id}
    Log  Waiting for fault 4592 to be ${status_fault_4592} in WebEM.  console=true
    ${fault_parameters_4592}  Get String With Alarm Parameters  ${FAULT_4592_MINOR}
    ${alarm_parameters}  Catenate  ${fault_parameters_4592},  alarmingResource=${system_module}[id][runtime]
    ${check_minor_fault_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    IF  '${status_fault_4592}'=='active'
      Should Be True  ${check_minor_fault_webem}  Fault ${FAULT_4592_MINOR} is not active in WebEM. [NOK]
      Log  Fault ${FAULT_4592_MINOR} is active in WebEM. [OK]  console=true
    ELSE IF  '${status_fault_4592}'=='inactive'
      Should Not Be True  ${check_minor_fault_webem}
      ...  Fault should be suppressed and not reported. Fault ${FAULT_4592_MINOR} is active in WebEM. [NOK]
      Log  Fault is suppresed. Fault ${FAULT_4592_MINOR} is not active in WebEM. [OK]  console=true
    END
    Verify Alarm In RawAlarmHistory File  4592  ${time_raw_history}
    IF  '${status_fault_4592}'=='inactive'
      Log  Checking if fault 4592 is found in suppressed alarms in RawSuppressedAlarmHistory.txt file.  console=true
      Verify Alarm In RawSuppressedAlarmHistory File  fault_number=4592  current_date_time=${time_raw_suppresed}
    END
    Log  Waiting for fault 4592 to be ${status_fault_4592} in Netact.  console=true
    ${check_minor_fault_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min  Check Additional Information For Given Alarm And Fault  &{FAULT_4592_MINOR}
    ...  object_id=${dn_internal}
    IF  '${status_fault_4592}'=='active'
      Should Be True  ${check_minor_fault_netact}  Fault ${FAULT_4592_MINOR} is not active in Netact. [NOK]
      Log  Fault ${FAULT_4592_MINOR} is active in Netact. [OK]  console=true
    ELSE IF  '${status_fault_4592}'=='inactive'
      Should Not Be True  ${check_minor_fault_netact}
      ...  Fault should be suppressed and not reported. Fault ${FAULT_4592_MINOR} is active in Netact. [NOK]
      Log  Fault is suppresed. Fault ${FAULT_4592_MINOR} is not active in Netact. [OK]  console=true
    END


Modify EAC_IN Under Object With Given Severity
    [Documentation]  Creates or updates EAC_IN object under the given management object DN with the specified severity.
    [Arguments]  ${operation}  ${managment_object_dn}  ${severity}

    Log  EAC_IN ${operation} object under ${managment_object_dn}.  console=true
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  ${managment_object_dn}/EAC_IN-1  ${operation}  ${delta_id}
    Append Parameter Update To Delta  ${managment_object_dn}/EAC_IN-1  descr  Alarm ${severity}  ${delta_id}
    Append Parameter Update To Delta  ${managment_object_dn}/EAC_IN-1  inUse  true  ${delta_id}
    Append Parameter Update To Delta  ${managment_object_dn}/EAC_IN-1  polarity  Normally_closed  ${delta_id}
    Append Parameter Update To Delta  ${managment_object_dn}/EAC_IN-1  portId  1  ${delta_id}
    Append Parameter Update To Delta  ${managment_object_dn}/EAC_IN-1  severity  ${severity}  ${delta_id}
    IF  '${operation}'=='create'  Append Parameter Update To Delta  ${managment_object_dn}/EAC_IN-1  eacInId  1  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/${operation}_eac_in_${severity}.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/${operation}_eac_in_${severity}.json  timeout=120
    Remove Delta  ${delta_id}


Delete EAC_IN Object
    [Documentation]  Deletes the EAC_IN object under the given management object DN.
    [Arguments]  ${managment_object_dn}

    Log  Deleting EAC_IN object under ${managment_object_dn}.  console=true
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  ${managment_object_dn}/EAC_IN-1  delete  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delete_eac_in.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delete_eac_in.json  skip_parameter_relation_errors=True  timeout=120
    Remove Delta  ${delta_id}


Modify EAC_IN Object And Verify Fault 1400
    [Documentation]  Modifies EAC_IN object and verifies that fault 1400 reaches the expected status and severity.
    [Arguments]  ${operation}  ${system_module}  ${status_fault_1400}  ${severity_fault}

    ${date_time_raw_suppresed}  Get BTS Time In UTC Format  %Y-%m-%d %H:%M:%S
    ${date_time_raw_history}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    Modify EAC_IN Under Object With Given Severity  operation=${operation}  managment_object_dn=${system_module}[id][configuration]
    ...  severity=${severity_fault}
    Verify Fault 1400 Presence  ${status_fault_1400}  ${severity_fault}  ${date_time_raw_suppresed}  ${date_time_raw_history}


Verify Fault 1400 Presence
    [Documentation]  Verifies that fault 1400 is present with the expected status and severity in the given time range.
    [Arguments]  ${status_fault_1400}  ${severity_fault}  ${time_raw_suppresed}  ${time_raw_history}

    Log  Waiting for fault 1400 to be ${status_fault_1400} in WebEM.  console=true
    ${fault_parameters_1400}  Get String With Alarm Parameters  ${FAULT_1400_${severity_fault}}
    ${alarm_parameters}  Catenate  ${fault_parameters_1400}
    ${check_fault_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    IF  '${status_fault_1400}'=='active'
      Should Be True  ${check_fault_webem}  Fault ${FAULT_1400_${severity_fault}} is not active in WebEM. [NOK]
      Log  Fault ${FAULT_1400_${severity_fault}} is active in WebEM. [OK]  console=true
    ELSE IF  '${status_fault_1400}'=='inactive'
      Should Not Be True  ${check_fault_webem}
      ...  Fault should be suppressed and not reported. Fault ${FAULT_1400_${severity_fault}} is active in WebEM. [NOK]
      Log  Fault is suppressed. Fault ${FAULT_1400_${severity_fault}} is not active in WebEM. [OK]  console=true
    END
    Verify Alarm In RawAlarmHistory File  1400  ${time_raw_history}
    IF  '${status_fault_1400}'=='inactive'
      Log  Checking if fault 1400 is found in suppressed alarms in RawSuppressedAlarmHistory.txt file.  console=true
      Verify Alarm In RawSuppressedAlarmHistory File  fault_number=1400  current_date_time=${time_raw_suppresed}
    END
    Log  Waiting for fault 1400 to be ${status_fault_1400} in Netact.  console=true
    ${check_alarm_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min  Check Additional Information For Given Alarm And Fault  &{FAULT_1400_${severity_fault}}
    IF  '${status_fault_1400}'=='active'
      Should Be True  ${check_alarm_netact}  Fault ${FAULT_1400_${severity_fault}} is not active in Netact. [NOK]
      Log  Fault ${FAULT_1400_${severity_fault}} is active in Netact. [OK]  console=true
    ELSE IF  '${status_fault_1400}'=='inactive'
      Should Not Be True  ${check_alarm_netact}
      ...  Fault should be suppressed and not reported. Fault ${FAULT_1400_${severity_fault}} is active in Netact. [NOK]
      Log  Fault is suppresed. Fault ${FAULT_1400_${severity_fault}} is not active to Netact. [OK]  console=true
    END


Power Off/On Radio Module And Verify Faults
    [Documentation]  Powers off and on the radio module and verifies faults 10 and 4589 reach the expected statuses.
    [Arguments]  ${radio_module}  ${status_fault_10}  ${status_fault_4589}

    ${date_time_raw_suppresed}  Get BTS Time In UTC Format  %Y-%m-%d %H:%M:%S
    ${date_time_raw_history}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    Log  Power off radio module with serial number: ${radio_module}[serialNumber].  console=true
    Pdu Bts Interface Off  RMOD_${radio_module}[serialNumber]
    Verify Fault 10 Presence  ${radio_module}  ${status_fault_10}  ${date_time_raw_suppresed}  ${date_time_raw_history}  ${ALARM_TIMEOUT}
    Log  Power on radio module with serial number: ${radio_module}[serialNumber].  console=true
    Pdu Bts Interface On  RMOD_${radio_module}[serialNumber]
    Verify Fault 4589 Presence  ${radio_module}  ${status_fault_4589}  ${date_time_raw_suppresed}  ${date_time_raw_history}
    ${modules_cells_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check Modules And Cells
    Should Be True  ${modules_cells_status}  Not all modules or cells are onAir after.
    Log  All modules and cells are onAir.  console=true


Verify Fault 10 Presence
    [Documentation]  Verifies that fault 10 is present (or absent) with the expected status for the radio module.
    [Arguments]  ${radio_module}  ${status_fault_10}  ${time_raw_suppresed}  ${time_raw_history}  ${timeout}

    Log  Waiting for fault 10 to be ${status_fault_10} in WebEM.  console=true
    ${string_module_id}  Replace String Using Regexp  ${radio_module}[id][internal]  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    ${dn_internal}  Catenate  SEPARATOR=/  PLMN-PLMN  ${string_module_id}
    ${fault_parameters_10}  Get String With Alarm Parameters  ${FAULT_10_CRITICAL}
    ${alarm_parameters}  Catenate  ${fault_parameters_10},  alarmingResource=${string_module_id}
    ${check_critical_fault_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${alarm_parameters}  timeout=${timeout}
    IF  '${status_fault_10}'=='active'
        Should Be True  ${check_critical_fault_webem}  Fault ${FAULT_10_CRITICAL} is not active in WebEM. [NOK]
        Log  Fault ${FAULT_10_CRITICAL} is active in WebEM. [OK]  console=true
    ELSE IF  '${status_fault_10}'=='inactive'
        Should Not Be True  ${check_critical_fault_webem}
        ...  Fault should be suppressed and not reported. Fault ${FAULT_10_CRITICAL} is active in WebEM. [NOK]
        Log  Fault is suppressed. Fault ${FAULT_10_CRITICAL} is not active in WebEM. [OK]  console=true
    END
    Verify Alarm In RawAlarmHistory File  10  ${time_raw_history}
    IF  '${status_fault_10}'=='inactive'
        Log  Checking if fault 10 is found in suppressed alarms in RawSuppressedAlarmHistory.txt file.  console=true
        Verify Alarm In RawSuppressedAlarmHistory File  fault_number=10  current_date_time=${time_raw_suppresed}
    END
    Log  Waiting for fault 10 to be ${status_fault_10} in Netact.  console=true
    ${check_critical_alarm_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min  Check Additional Information For Given Alarm And Fault  &{FAULT_10_CRITICAL}
    ...                                                                                                                object_id=${dn_internal}
    IF  '${status_fault_10}'=='active'
        Should Be True  ${check_critical_alarm_netact}  Fault ${FAULT_10_CRITICAL} is not active in Netact. [NOK]
        Log  Fault ${FAULT_10_CRITICAL} is active in Netact. [OK]  console=true
    ELSE IF  '${status_fault_10}'=='inactive'
        Should Not Be True  ${check_critical_alarm_netact}
        ...  Fault should be suppressed and not reported to Netact. Fault ${FAULT_10_CRITICAL} is active in Netact. [NOK]
        Log  Fault is suppresed. Fault ${FAULT_10_CRITICAL} is not active to Netact. [OK]  console=true
    END


Verify Fault 4589 Presence
    [Documentation]  Verifies that fault 4589 is present (or absent) with the expected status for the radio module.
    [Arguments]  ${radio_module}  ${status_fault_4589}  ${time_raw_suppresed}  ${time_raw_history}

    Log  Waiting for fault 4589 to be ${status_fault_4589} in WebEM.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    ${string_module_id}  Replace String Using Regexp  ${radio_module}[id][internal]  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    ${dn_internal}  Catenate  SEPARATOR=/  PLMN-PLMN  ${string_module_id}
    ${fault_parameters_4589}  Get String With Alarm Parameters  ${FAULT_4589_UNIT_POWER_RST}
    ${alarm_parameters}  Catenate  ${fault_parameters_4589},  alarmingResource=${radio_module}[id][runtime]
    ${check_warming_alarm_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    IF  '${status_fault_4589}'=='active'
        Should Be True  ${check_warming_alarm_webem}  Fault ${FAULT_4589_UNIT_POWER_RST} is not active in WebEM. [NOK]
        Log  Fault ${FAULT_4589_UNIT_POWER_RST} is active in WebEM. [OK]  console=true
    ELSE IF  '${status_fault_4589}'=='inactive'
        Should Not Be True  ${check_warming_alarm_webem}
        ...  Fault should be suppressed and not reported to Netact. Fault ${FAULT_4589_UNIT_POWER_RST} is active in WebEM. [NOK]
        Log  Fault is suppresed. Fault ${FAULT_4589_UNIT_POWER_RST} is not active in WebEM. [OK]  console=true
    END
    Log  Waiting for fault 4589 to be ${status_fault_4589} in Netact.  console=true
    ${check_warming_alarm_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  1min
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4589_UNIT_POWER_RST}
    ...                                                                               time_from=${start_time}
    ...                                                                               object_id=${dn_internal}
    IF  '${status_fault_4589}'=='active'
        Should Be True  ${check_warming_alarm_netact}  Fault ${FAULT_4589_UNIT_POWER_RST} was not reported in NetAct. [NOK]
        Log  Fault ${FAULT_4589_UNIT_POWER_RST} was reported and cleared in NetAct. [OK]  console=true
    ELSE IF  '${status_fault_4589}'=='inactive'
        Should Not Be True  ${check_warming_alarm_netact}
        ...  Fault should be suppressed and not reported to Netact. Fault ${FAULT_4589_UNIT_POWER_RST} was reported in Netact. [NOK]
        Log  Fault is suppresed. Fault ${FAULT_4589_UNIT_POWER_RST} was not reported to Netact. [OK]  console=true
    END
    Verify Alarm In RawAlarmHistory File  4589  ${time_raw_history}  ${None}  inactive
    IF  '${status_fault_4589}'=='inactive'
        Log  Checking if fault 4589 is found in suppressed alarms in RawSuppressedAlarmHistory.txt file.  console=true
        Verify Alarm In RawSuppressedAlarmHistory File  fault_number=4589  current_date_time=${time_raw_suppresed}  alarm_status=inactive
    END
    IF  '${status_fault_4589}'=='active'  Check Fault Signature If Fault 4589 Was Raised At Power Off/On For Radio Module


Check If System Module Is Powered On
    [Documentation]  Verifies that the given system module is powered on.
    [Arguments]  ${system_module}

    Log  \nCheck if primary core is powered on.  console=true
    ${ping_status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=120
    IF  ${ping_status}
        Log  Primary core reachable, no need to power on system module.  console=true
        RETURN
    ELSE
        Pdu BTS Interface On  SMOD_${system_module}[serialNumber]
        Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=300
        Assert Every  SMOD  operationalState=${ENABLED}
    END


Check If All RMODs Are Powered On
    [Documentation]  Verifies that all radio modules (RMODs) are powered on.

    Log  \nCheck if all RMODs are powered on.  console=true
    ${rmods_serial_numbers}  Create List
    ${rmods_list}  coam.Get Frm
    FOR  ${rmod}  IN  @{rmods_list}
       Append To List  ${rmods_serial_numbers}  ${rmod}[serialNumber]
    END
    ${check_rmods_status}  Run Keyword And Return Status  Assert Any  RMOD  availabilityStatus=${NOT_INSTALLED}
    IF  '${check_rmods_status}'=='False'  RETURN
    FOR  ${serial_number}  IN  @{rmods_serial_numbers}
      Pdu Bts Interface On  RMOD_${serial_number}
    END
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check Modules And Cells


Performing Commisioning With Backup SCF
    [Documentation]  Performs commissioning using the backup SCF file and waits for modules and cells to be ready.

    Log  \nCommissioning will be performed.  console=true
    coam.Perform Commissioning  bts_id=${BTS_ID}  scf_file=${BTS_FILES}/backup_scf.xml  skip_parameter_relation_errors=true  timeout=600
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check Modules And Cells


Create DSP List
    [Documentation]  KW was created to return dspsDNs list from BBTOP_M/LAYOUT_MAP/BBPOOL_L
    ...  AUTHOR-laura.craciunel@nokia.com
    [Arguments]  ${technology}

    ${dsps_dn_list}  Create List
    ${layout_bbpool}  Query Infomodel  get list //BBTOP_M-*/LAYOUT_MAP-*/BBPOOL_L-*  timeout=60
    FOR  ${element}  IN  @{layout_bbpool}
        ${assigned_cells}  Get From Dictionary  ${element}  assignedLCellsDNs
        ${list_lenght}  Get Length  ${assigned_cells}
        ${status}  Run Keyword And Return Status
        ...  Assigned Cells Type  ${assigned_cells}  ${technology}_M-1
        Run Keyword If  '${status}' == 'True' and '${list_lenght}' != '0'
        ...  Append To DSP List  ${dsps_dn_list}  ${element.dspsDNs}
    END

    [Return]  ${dsps_dn_list}


Set Cells Mapped On FSP
    [Documentation]  Gets cell mapping for the BBMOD and sets test variable CELLS_LIST_ON_FSP.

    ${cells_found}  Get Cell Mapping By Module Id  ${BBMOD_DN}
    Set Test Variable  ${CELLS_LIST_ON_FSP}  ${cells_found}
    Log  Cells on FSP: ${CELLS_LIST_ON_FSP}  console=true


Check Cells Type
    [Documentation]  Verifies that all cells in the list are of the given cell type.
    [Arguments]  ${cells_list}  ${cell_type}

    FOR  ${cell}  IN  @{cells_list}
        ${status}  Run Keyword And Return Status
        ...  Should Contain Any  ${cell}  @{cell_type}
        Exit For Loop If  ${status}
    END

    RETURN  ${status}


Checking Cells On The Given FSP
    [Documentation]  Checks that cells on the FSP have the expected availability status and operational state.
    [Arguments]  ${cells_on_fsp}  ${cell_availability_status}  ${cell_operational_state}

    Log  Cells on FSP will be checked.  console=true
    FOR  ${cell}  IN  @{cells_on_fsp}
        Wait Until Keyword Succeeds  300s  10s  Get And Check Cell Status  ${cell}  ${cell_availability_status}  ${cell_operational_state}
    END


Get And Check Cell Status
    [Documentation]  Gets cell status and verifies availability status and operational state match expected values.
    [Arguments]  ${cell}  ${cell_availability_status}  ${cell_operational_state}

    Log  Checking if availabilityStatus and operationalState are under cell status.
    ${cell_obj}  Get Cell Specific Info  ${cell}
    Log  Checking if availabilityStatus and operationalState are under cell object.
    ${availability}  Run Keyword And Return Status  Should Contain  ${cell_availability_status}  ${cell_obj}[status][availabilityStatus]
    ${operational}  Run Keyword And Return Status  Should Contain  ${cell_operational_state}  ${cell_obj}[status][operationalState]
    IF  ${availability} and ${operational}
      Log  Cell ${cell_obj}[id][internal] is in expected state. [OK]  console=true
    ELSE
      Fail  Cell ${cell_obj}[id][internal] in unexpected state: ${cell_obj}[status][availabilityStatus] and ${cell_obj}[status][operationalState].
    END


Assigned Cells Type
    [Documentation]  KW was created to determine if given cells are assigned to a given technology
    ...  AUTHOR-laura.craciunel@nokia.com
    [Arguments]  ${cells_list}  ${technology}

    ${match}  Set Variable  False
    FOR  ${cell}  IN  @{cells_list}
        Should Contain  ${cell}  ${technology}
        ${match}  Set Variable  True
    END

    [Return]  ${match}


Append To DSP List
    [Documentation]  KW was created to append dsp to list and return dsp list
    ...  AUTHOR-laura.craciunel@nokia.com
    [Arguments]  ${dsps_list}  ${dsps_dns}

    FOR  ${dsp}  IN  @{dsps_dns}
        Append To List  ${dsps_list}  ${dsp}
    END

    [Return]  ${dsps_list}


Random Core Rel3
    [Documentation]  This keyword is used to set a random core rel3.

    ${core}  Evaluate  random.randint(1, 4)  modules=random
    Set Test Variable  ${CORE}


Random Core Rel4
    [Documentation]  This keyword is used to set a random core rel4.

    ${core}  Evaluate  random.randint(1, 8)  modules=random
    Set Test Variable  ${CORE}


Get Reset Counter
    [Documentation]  This keyword is used to get reset counter.

    ssh.Connect To  ${OAM_BTS_IP}  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]
    ${output}  ssh.Execute  cd /ffs/run/config/lifedata/
    ${lifedata_match}  Run Keyword And Return Status  Should Not Contain  ${output}  No such file or directory
    ${path}  Set Variable If  ${lifedata_match}  /ffs/run/config/lifedata  /ffs/run/logs/lifetimedata
    ${output_blackbox}  ssh.Execute  cat ${path}/blackbox
    ${matches}  Get Regexp Matches  ${output_blackbox}  RESET COUNTER: \\d+
    ${value}  Fetch From Right  ${matches}[0]  ${SPACE}

    [Teardown]  ssh.Disconnect
    [Return]  ${value}


Check If Cells OnAir Or PowerSaving Enabled
    [Documentation]  KW checks whether cell is enabled. If not enabled, checks energy saving, if not - KW failed.

    ${cells_list}  Get Cell List
    ${4_g_5_g_cells}  Combine Lists  ${cells_list['cells']['lte']}  ${cells_list['cells']['nr']}
    FOR  ${cell}  IN  @{4_g_5_g_cells}
        ${operational_state}  Get From Dictionary  ${cell}[status]  operationalState
        ${energy_saving_state}  Get From Dictionary  ${cell}  energySavingState
        ${operational_state}  Evaluate  "${operational_state}".upper()
        ${energy_saving_state}  Evaluate  "${energy_saving_state}".upper()
        Run Keyword If  '${operational_state}'!='1'
        ...  Should Be True  '${operational_state}'=='ENABLED' or '${energy_saving_state}'=='ENERGYSAVING'
    END


Get ENB Id
    [Documentation]  This KW is created to get BTS id.

    ${bts_params}  coam.Get Parameters For All  BTS
    ${bts_params}  Get From List  ${bts_params}  0
    ${bts_id}  Get From Dictionary  ${bts_params}  btsId
    ${bts_id_string}  Convert To String  ${bts_id}

    [Return]  ${bts_id_string}


Get RAT As String
    [Documentation]  KW takes dictionary value (list or string) and returns value as string.
    [Arguments]  ${rat}

    ${status}  ${value}  Run Keyword And Ignore Error
    ...  Evaluate  type(${rat})
    ${rat_value}  Run Keyword If  '${status}'=='PASS'
    ...  Checking The Value Of RAT  ${rat}
    ...  ELSE
    ...  Set Variable  ${rat}

    [Return]  ${rat_value}


Checking The Value Of RAT
    [Documentation]  This keyword is used to check the value of RAT.
    [Arguments]  ${rat}

    ${status_1}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${rat}
    ${status_2}  Run Keyword And Return Status
    ...  Should Not Contain  '${rat}'  None
    Run Keyword If  ${status_1} and ${status_2}
    ...  Return From Keyword  ${rat}[0]


Add Variables In Interfaces
    [Documentation]  This KW is created to add variable_name to INTERFACES.
    ...  *AUTHOR* cristina.adam@nokia.com
    [Arguments]  ${variable_name}  ${variable_value}

    Log  Adding variable ${variable_name} to interfaces.  console=true
    Set To Dictionary  ${INTERFACES}  ${variable_name}=${variable_value}


Verify And Change FaultSnapshotTriggers Values
    [Documentation]
    ...  This keywords verifies if fault is present in faultSnapshotTriggers list
    ...  If fault is not present, it is added to the list
    ...  *AUTHOR* cristina.adam@nokia.com
    [Arguments]  ${fault_number}  ${trigger_type}

    ${trblcadm_object}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-1/MRBTS_A-${BTS_ID}/MNL_A-1/MNLENT_A-1/TRBLCADM_A-1
    ${fault_snapshot_triggers_list}  Set Variable  ${trblcadm_object}[faultSnapshotTriggers]
    ${fault_appearence_counter}  Set Variable  0
    FOR  ${fault}  IN  @{fault_snapshot_triggers_list}
        ${status_fault_number}  Run Keyword And Return Status
        ...  Should Contain  '${fault}[faultNumber]'  ${fault_number}
        Exit For Loop If  ${status_fault_number}
        ${fault_appearence_counter}  Evaluate  ${fault_appearence_counter} + 1
    END
    ${list_length}  Get Length  ${fault_snapshot_triggers_list}
    Run Keyword If  ${fault_appearence_counter} == ${list_length}
    ...  Change FaultSnapshottriggers  ${fault_number}  ${trigger_type}
    ...  ELSE
    ...  Log  faultSnapshotTriggers already contains ${fault_number} fault, no need to add it.  console=true


Change FaultSnapshottriggers
    [Documentation]
    ...  This keyword adds faultNumber and triggerType parameters to faultSnapshotTriggers list
    ...  *AUTHOR* cristina.adam@nokia.com
    [Arguments]  ${fault_number}  ${trigger_type}

    ${parameters_dictionary}  Create Dictionary
    Set To Dictionary  ${parameters_dictionary}  faultNumber=${fault_number}
    Set To Dictionary  ${parameters_dictionary}  triggerType=${trigger_type}
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  update  ${delta_id}
    Append Complex Item To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  list_name=faultSnapshotTriggers  &{parameters_dictionary}
    ...  delta_id=${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}
    Log  faultSnapshotTriggers updated with fault ${fault_number}  console=true


Change Parameter ActL1FastAutoHealing/diagSnapDestination Value
    [Documentation]
    ...  This keyword verifies if specific parameter has the desired value, if not, value is updated.
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${given_value}  ${parameter_name}  ${parameter_object}  ${parameter_object_no}

    ${dist_name_bts_id}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/${parameter_object}
    ${actual_value}  Get ActL1FastAutoHealing/diagSnapDestination Value  ${parameter_name}  ${parameter_object_no}
    IF  '${actual_value}'!='${given_value}'
        coam.Perform Parameter Recommissioning  ${dist_name_bts_id}
        ...                                     parameter=${parameter_name}
        ...                                     operation=update
        ...                                     value=${given_value}
        ...                                     skip_parameter_relation_errors=True
        ...                                     should_activate=True
        ...                                     timeout=300
        Log  ${parameter_name} value changed to ${given_value}  console=true
    ELSE
        Log  ${parameter_name} value already has the requested value. Parameter change will be skipped.  console=true
    END


Get ActL1FastAutoHealing/diagSnapDestination Value
    [Documentation]
    ...  This keyword returns value of ActL1FastAutoHealing or diagSnapDestination parameter.
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${parameter_name}  ${parameter_object_no}

    ${parameter_object}  Fetch From Left  ${parameter_object_no}  -
    ${objects_list}  coam.Get Managed Objects  ${parameter_object}
    ${list_is_empty}  Run Keyword And Return Status  Should Be Empty  ${objects_list}
    IF  ${list_is_empty}
        Fail  There are no ${parameter_object} objects on SBTS. [NOK]
    END
    FOR  ${object}  IN  @{objects_list}
        Should Contain  ${object}[distName]
        ...             ${parameter_object_no}
        ...             msg=Parameter object ${parameter_object_no} not found under ${parameter_object}. [NOK]
        BREAK
    END

    RETURN  ${object}[parameters][${parameter_name}]


Get Random SOC Dist_name
    [Documentation]
    ...  This kewyord chooses a random SOC dist_name that has a specific hwVariant,
    ...  rat type and is mapped on a specific BBMOD.
    ...  Example:  Set random SOC dist_name  Loki  LTE  ABIO
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${hw_variant}  ${rat_type}  ${unit_type}  ${serial_number}=${EMPTY}

    ${hw_variant_soc_list}  Query Infomodel  get list //SOC_L-* is [hwVariant=${hw_variant}]
    ${hw_variant_rat_type_soc_list}  Create List
    FOR  ${soc}  IN  @{hw_variant_soc_list}
        IF  '${hw_variant}'=='Loki' and '${unit_type}' != 'ASOE' and '${unit_type}' != 'ASOF'
            ${bbmod_l_dn}  Fetch From Left  ${soc}[dist_name]  /BBU_L
        ELSE
            ${bbmod_l_dn}  Fetch From Left  ${soc}[dist_name]  /BOARD_L
        END
        IF  '${unit_type}' == ('ASOE' or 'ASOF')
            ${bbmod_l_parameters}  Get Parameters For  SMOD  ${bbmod_l_dn}
        ELSE
            ${bbmod_l_parameters}  Get Parameters For  BBMOD  ${bbmod_l_dn}
        END
        ${status_bbmod_product_name}  Run Keyword And Return Status
        ...  Should Contain  ${bbmod_l_parameters}[productName]  ${unit_type}
        IF  '${serial_number}'!='${EMPTY}' and "${serial_number}"!="${bbmod_l_parameters}[serialNumber]"
            CONTINUE
        END
        ${status_soc}  Run Keyword And Return Status  Should Not Be Empty  ${soc}[rat]
        IF  ${status_soc}==${FALSE}  CONTINUE
        IF  '${soc}[rat][0]' == '${rat_type}' and ${status_bbmod_product_name}
            Append To List  ${hw_variant_rat_type_soc_list}  ${soc}[dist_name]
        END
    END
    ${status_soc_list}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${hw_variant_rat_type_soc_list}
    IF  ${status_soc_list}==${FALSE}  Fail  There are no ${hw_variant} SOCs on ${rat_type} - ${unit_type}.
    FOR  ${soc_dn}  IN  @{hw_variant_rat_type_soc_list}
        ${cells}  Get Cell Mapping By Module Id  ${soc_dn}
        ${is_cell}  _Check Cell Type Is On Soc  ${cells}  ${rat_type}
        IF  ${is_cell}  BREAK
    END

    RETURN  ${soc_dn}


_Check Cell Type Is On Soc
    [Documentation]  This keyword is used to check cell type is on soc.
    [Arguments]  ${cell_list}  ${type}

    ${rat_cell}  Create Dictionary  GSM=GNCELL  WCDMA=WNCELL  LTE=LNCELL  NR=NRCELL
    FOR  ${cell}  IN  @{cell_list}
        Return From Keyword If  '${type}' in '${cell}'  ${TRUE}
    END

    [Return]  ${FALSE}


Get Module Horizontal Position
    [Documentation]
    ...  This keyword returns module horizontal position from runtime object dist_name (SMOD_R or BBMOD_R).
    ...  In case of ASOE/ASOF/ASOG/ASOH core unit keyword will return 0.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${module_r_dn}

    ${module_parameters}  coam.Get Parameters  ${module_r_dn}
    ${module_horizontal_position}  Set Variable If  '${module_parameters}[horizontalPosition]' != '${None}'  ${module_parameters}[horizontalPosition]
    ...  0

    [Return]  ${module_horizontal_position}


Get SOC Position
    [Documentation]
    ...  This keyword returns SOC position for Loki, Thor, Magni
    ...  For test with devmem command.
    ...  Not to be used in case of RAT reset tests.
    ...  *AUTHOR* bogdan.boldurean@nokia.com
    [Arguments]  ${soc_dn}  ${module_product_name}

    ${status_abil}  Run Keyword And Return Status  Should Contain  ${module_product_name}  ABIL
    ${status_abin}  Run Keyword And Return Status  Should Contain  ${module_product_name}  ABIN
    ${status_abio}  Run Keyword And Return Status  Should Contain  ${module_product_name}  ABIO
    ${status_abip}  Run Keyword And Return Status  Should Contain  ${module_product_name}  ABIP
    ${status_abiq}  Run Keyword And Return Status  Should Contain  ${module_product_name}  ABIQ
    ${status_asof}  Run Keyword And Return Status  Should Contain  ${module_product_name}  ASOF
    ${status_asog}  Run Keyword And Return Status  Should Contain  ${module_product_name}  ASOG
    ${soc_position}  IF  ${status_abil}  Set Variable  2
    ...  ELSE IF  ${status_abin}  Set Variable  1
    ...  ELSE IF  ${status_abio}  Get ABIO SoC  ${soc_dn}
    ...  ELSE IF  ${status_abip}  Get ABIP SoC  ${soc_dn}
    ...  ELSE IF  ${status_abiq}  Get ABIQ SoC  ${soc_dn}
    ...  ELSE IF  ${status_asof}  Get ASOF SoC  ${soc_dn}
    ...  ELSE IF  ${status_asog}  Get ASOG SoC  ${soc_dn}
    ...  ELSE  Fail  Please run the test other unit type.

    RETURN  ${soc_position}


Get ABIO SoC
    [Documentation]
    ...  If Power Group 1 with SoC 2 (Loki), SoC is 1, because is the first one.
    ...  If Power Group 2 with SoC 1 (Loki), SoC is 2, because is the second one.
    ...  *AUTHOR* bogdan.boldurean@nokia.com
    [Arguments]  ${soc_dn}

    ${soc_id}  Get Substring  ${soc_dn}  -1
    IF  ${soc_id} == 1
        ${soc_position}  Set Variable  2
    ELSE IF  ${soc_id} == 2
        ${soc_position}  Set Variable  1
    ELSE
        Fail  ABIO SoC could not be determined.
    END

    RETURN  ${soc_position}


Get ABIP SoC
    [Documentation]  In ABIP case SoC is always 1.
    ...  *AUTHOR* bogdan.boldurean@nokia.com
    [Arguments]  ${soc_dn}

    ${soc_id}  Get Substring  ${soc_dn}  -1
    IF  ${soc_id} == 2
        ${soc_position}  Set Variable  1
    ELSE
        Fail  ABIP SoC could not be determined.
    END

    RETURN  ${soc_position}


Get ABIQ SoC
    [Documentation]  In ABIQ case SoC is always 1.
    ...  *AUTHOR* bogdan.boldurean@nokia.com
    [Arguments]  ${soc_dn}

    ${soc_id}  Get Substring  ${soc_dn}  -1
    IF  ${soc_id} == 2
        ${soc_position}  Set Variable  1
    ELSE
        Fail  ABIQ SoC could not be determined.
    END

    RETURN  ${soc_position}


Get ASOF SoC
    [Documentation]
    ...  If Power Group 1 with SoC 2 (Loki), SoC is 1, because is the first one.
    ...  If Power Group 2 with SoC 1 (Loki), SoC is 2, because is the second one.
    ...  *AUTHOR* bogdan.boldurean@nokia.com
    [Arguments]  ${soc_dn}

    ${soc_id}  Get Substring  ${soc_dn}  -1
    IF  ${soc_id} == 1
        ${soc_position}  Set Variable  2
    ELSE IF  ${soc_id} == 2
        ${soc_position}  Set Variable  1
    ELSE
        Fail  ASOF SoC could not be determined.
    END

    RETURN  ${soc_position}


Get ASOG SoC
    [Documentation]
    ...  If Power Group 1 with SoC 2 (Loki), SoC is 1, because is the first one.
    ...  If Power Group 2 with SoC 1 (Loki), SoC is 2, because is the second one.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${soc_dn}

    ${soc_id}  Get Substring  ${soc_dn}  -1
    IF  ${soc_id} == 1
        ${soc_position}  Set Variable  2
    ELSE IF  ${soc_id} == 2
        ${soc_position}  Set Variable  1
    ELSE
        Fail  ASOG SoC could not be determined.
    END

    RETURN  ${soc_position}


Verify NUM_L1_AUTO_HEALING_BTS Counter To Be Incremented
    [Documentation]
    ...  This keyword verifies M40002C3 counter to be incremented corectly
    ...  *AUTHOR* cristina.adam@nokia.com
    [Arguments]  ${counter_value}

    Log  Verifying NUM_L1_AUTO_HEALING_BTS counter to be incremented.  console=true
    Sleep  60s  Waiting one minute for counter to appear.
    ${counter_value}  Convert To Integer  ${counter_value}
    ${counter_dict}  coam.Get Pm Counters  counter_ids=M40002C3
    ${dict}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'
    ...  ${counter_dict}[BTS][MRBTS-${BTS_ID}][SBTS_Energy_Consumption][M40002C3]
    ...  ${counter_dict}[BTS][BTS][MRBTS-${BTS_ID}][SBTS_Energy_Consumption][M40002C3]
    ${status_counter}  Run Keyword And Return Status
    ...  Dictionary Should Contain Value  ${dict}  ${counter_value}
    Run Keyword If  ${status_counter}
    ...  Log  Counter NUM_L1_AUTO_HEALING_BTS is incremented correctly.  console=true
    ...  ELSE
    ...  Fail  Counter NUM_L1_AUTO_HEALING_BTS is not incremented correctly.


Change Parameter ActForce(Unit)AutoReset To False
    [Documentation]  The purpose of this KW is to perform specific actions at the end of the test scenario, no matter if TC passes or fails.

    Log  Check if actForceAutoReset value is false  console=true
    ${flag_value}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    Log  Value of actForceAutoReset is ${flag_value}  console=true
    ${flag_status}  Run Keyword And Return Status
    ...  Should Contain  ${flag_value}  false
    Run Keyword If  ${flag_status}==${FALSE}
    ...  Run Keywords
    ...  Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset
    ...  AND
    ...  Log  Flag value has been changed  console=true


Verify RMOD Status
    [Documentation]  This keyword is used to verify RMOD status.
    [Arguments]  ${operational_status}  ${availability_status}=${EMPTY}

    ${string}  Set Variable If  '${availability_status}'=='${EMPTY}'  operationalState=${operational_status}  '${availability_status}'!='${EMPTY}'
    ...  operationalState=${operational_status}, availabilityStatus=${availability_status}
    ${status}  Run Keyword And Return Status
    ...  Assert Any  RMOD  ${string}  timeout=45
    Run Keyword If  ${status}
    ...  Log  RMOD is in expected status.  console=true
    ...  ELSE
    ...  Set Test Restriction  RMOD is in unexpected status.


Set ActFaultSignature Value
    [Documentation]  This keyword is used to set actFaultSignature value.
    [Arguments]  ${value}

    ${parameter_initial_value}  Get ActFaultSignature Value From Infomodel  actFaultSignature
    ${status}  Run Keyword And Return Status
    ...  Should Contain  ${parameter_initial_value}  ${value}
    Run Keyword If  ${status}
    ...  Log  actFaultSignature already set to ${value}, no need to be changed.  console=true
    ...  ELSE
    ...  Change Parameter ActFaultSignature  ${value}  actFaultSignature


Restore Abis Link
    [Documentation]  This keyword is used to restore abis link.

    FOR  ${vlan}  IN  @{GSM_VLAN}
        Log  Restoring vlan: ${vlan}.  console=true
        Restore Link  ${vlan}
    END


Create Data.Dat And Put 0xFFFF
    [Documentation]  This KW is created to create file data.dat in /tmp and put value 0xFFFF into it

    Log  Creating file data.dat which will store value of 0xFFFF.  console=true
    ${obligatory_files}  Create List  data.dat
    ssh.Connect To  ${OAM_BTS_IP}  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]
    ssh.Execute  echo 0xFFFF > /tmp/data.dat
    ${ssh_file_status}  Verify Files From Given Path  ${OAM_BTS_IP}  /tmp  ${obligatory_files}
    Run Keyword If  ${ssh_file_status}
    ...  Log  File data.dat has been created successfully. [OK]  console=true
    ...  ELSE
    ...  Fail  File data.dat has not been created successfully. [NOK]

    Log  Checking if newly created file contains value 0xFFFF.  console=true
    ${send_command_2}  ssh.Execute  cat /tmp/data.dat
    ${output_status}  Run Keyword And Return Status
    ...  Should Contain  ${send_command_2}  0xFFFF\r\n
    Run Keyword If  ${output_status}
    ...  Log  File data.dat contains value 0xFFFF. [OK]  console=true
    ...  ELSE
    ...  Fail  File data.dat doesn't contain value 0xFFFF. [NOK]


Remove Ssh Keys
    [Documentation]  This keyword is used to remove ssh keys.

    Open Connection To Primary Core
    Log  Host keys will be removed from primary core.  console=true
    SSHLibrary.Write  rm /user/toor4nsn/.ssh/known_hosts
    Open Connection To Secondary Core
    Log  Host keys will be removed from secondary core.  console=true
    SSHLibrary.Write  rm /user/toor4nsn/.ssh/known_hosts
    SSHLibrary.Close Connection


Recover Unit
    [Documentation]  This keyword is used to recover a specific radio unit.
    [Arguments]  ${operation}  ${rmod_side}  ${stored_role}  ${rmod_ip}  ${rmod_username}  ${rmod_password}

    Log  Test failed. Trying to recover services.  console=true
    Open Connection To Radio Module  ${rmod_side}  ${stored_role}  ${rmod_ip}  ${rmod_username}  ${rmod_password}
    Run Keyword  ${operation}
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10
    ...  Check All Cells


Open Connection To Radio Module
    [Documentation]  This keyword is used to open connection to Radio Module.
    [Arguments]  ${smod_side}  ${stored_role}  ${rmod_ip}  ${username}  ${password}

    Open Connection To Primary Core
    IF  '${stored_role}' == 'Idle'  Open Connection To Secondary Core
    SSHLibrary.Set Client Configuration  timeout=10
    SSHLibrary.Write  lxc-attach -n 0x${smod_side}018
    ${lxc_attach_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${lxc_attach_output}  FHNET  msg=lxc-attach command not working
    SSHLibrary.Write  rm /user/toor4nsn/.ssh/known_hosts
    SSHLibrary.Read Until Prompt
    SSHLibrary.Set Client Configuration  prompt=(yes/no/[fingerprint])?
    IF  '${username}' == '' and '${password}' == ''
        SSHLibrary.Write  ssh ${rmod_ip}
        SSHLibrary.Read Until Prompt
        SSHLibrary.Write  yes
    ELSE
        SSHLibrary.Write  ssh ${username}@${rmod_ip}
        SSHLibrary.Read Until Prompt
        SSHLibrary.Write  yes
        SSHLibrary.Read Until  password:
        SSHLibrary.Write  ${password}
    END
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(~#|\\$|\\n\\$|~ >)
    ${rmod_connection_output}  SSHLibrary.Read Until Prompt
    Should Not Contain  ${rmod_connection_output}
    ...                 Permission denied, please try again.
    ...                 msg=Wrong password for RMOD with ip: ${rmod_ip}.
    Should Not Contain  ${rmod_connection_output}
    ...                 No route to host
    ...                 msg=Not able to connect on RMOD with ip: ${rmod_ip}.
    Log  Connection on RMOD with ip: ${rmod_ip} successfully done.  console=true


Check Presence Of PMMNL Object
    [Documentation]
    ...  This KW was created to check if PMMNL is created under MRBTS-xxxxx/MNL-1/MNLENT-1/ .
    ...  If object doesn't exist, KW will perform delta recommisioning .
    ...  Ojbect if needed for counters reporting in CB0008397 testing.
    ...  *AUTHOR* laura.craciunel@nokia.com

    ${pmmnl_objects_list}  coam.Get Managed Objects  PMMNL_A
    ${list_is_empty}  Run Keyword And Return Status  Should Be Empty  ${pmmnl_objects_list}
    IF  ${list_is_empty}
        Commission PMMNL Object
    ELSE
        Log  PMMNL present under MRBTS-${BTS_ID}/MNL-1/MNLENT-1/.  console=true
    END


Commission PMMNL Object
    [Documentation]  This keyword is used to commission PMMNL object.

    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  create  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  cteStatisticsInterval  15min  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  dteStatisticsInterval  15min  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  eCpriMasterStatisticsInterval  15min  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  loosePhaseAndTimeStatisticsInterval  15min  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  miFddAssistedHoldoverPeriod  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  miGnssTimeError  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  miPtpMasterBH  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  miRxWindowStats  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  miSynceNetworkRearrangements  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  miTdd4gAssistedHoldoverPeriod  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  miTdd5gAssistedHoldoverPeriod  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  miTopPhaseSync_1  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  miTopPhaseSync_2  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  miTopPhaseSync_3  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  miTopPhaseSync_4  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  miTrRxWindowStats  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtBtsEnergyMonitoring  15min  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtEthernetSidehaul  15min  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSBTSASIRMODTemperature  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSBTSAntennaLine  60min  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSBTSBBMODTemperature  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSBTSRMODTemperature  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSBTSRfmEnergyMonitoring  60min  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSBTSSMODTemperature  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSBTSSfpBBMOD  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSBTSSfpRMOD  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSBTSSfpSMOD  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSBTSSmEnergyMonitoring  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSbtsSfpBbmodLane  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSbtsSfpFhs  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSbtsSfpFhsLane  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSbtsSfpRmodLane  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSbtsSfpSmodLane  disabled  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSfp  15min  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  ntpStatisticsInterval  15min  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  s1X2TacStatisticsInterval  15min  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  topFreqSyncStatisticsInterval  15min  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  topPhaseSyncStatisticsInterval  15min  delta_id=${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_1.json  delta_id=${delta_id}
    Log  Performing delta recommissioning.  console=true
    ${status}  Run Keyword And Return Status
    ...  coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_1.json  skip_parameter_relation_errors=True  timeout=180
    IF  ${status}
        Log  Recommissioning was performed.  console=true
    ELSE
        Set Test Restriction  Recommissioning failed.
    END
    Remove Delta  ${delta_id}


Change Parameter AllowBbPoolRecoveryReset
    [Documentation]
    ...  This KW is created to change parameter allowBbPoolRecoveryReset.
    ...  *AUTHOR* bogdan.boldurean@nokia.com
    [Arguments]  ${value}

    ${dist_name_bts_id}  Set Variable  MRBTS-${BTS_ID}/EQM-1/APEQM-1
    ${get_parameter_value}  Get AllowBbPoolRecoveryReset Value From Infomodel
    Run Keyword If  '${get_parameter_value}'!='${value}'
    ...  Run Keywords
    ...  Log  Parameter allowBbPoolRecoveryReset will be changed to ${value}  console=true
    ...  AND
    ...  coam.Perform Parameter Recommissioning  ${dist_name_bts_id}
    ...  allowBbPoolRecoveryReset
    ...  update
    ...  ${value}
    ...  skip_parameter_relation_errors=True
    ...  should_activate=True
    ...  timeout=300
    ...  ELSE
    ...  Log  Parameter allowBbPoolRecoveryReset is ${value}, no need to change  console=true


Get AllowBbPoolRecoveryReset Value From Infomodel
    [Documentation]
    ...  This KW is created to check what value has parameter allowBbPoolRecoveryReset.
    ...  *AUTHOR* bogdan.boldurean@nokia.com

    ${parametr_name}  Convert To String  allowBbPoolRecoveryReset
    ${parameter_object}  Query Infomodel  get object //APEQM_CONF_M-1
    ${parameter_object_value_string}  Convert To String  ${parameter_object.${parametr_name}}
    ${parameter_object_lower}  Convert To Lowercase  ${parameter_object_value_string}

    [Return]  ${parameter_object_lower}


Remove SoC Routes
    [Documentation]
    ...  This keyword removes all the routes on the soc.

    SSHLibrary.Write  syscomctl routing list
    ${output}  SSHLibrary.Read Until Prompt
    ${rules}  Get Regexp Matches  ${output}  [0-9a-zA-Z]+\/[0-9]+
    FOR  ${rule}  IN  @{rules}
        SSHLibrary.Write  syscomctl routing remove ${rule}
        SSHLibrary.Read Until Prompt
    END
    Log  All routes have been removed.  console=true


Get SoC Position Based On SoC Dist Name
    [Documentation]
    ...  This keyword returns Loki position for any BBMOD type.
    ...  *AUTHOR* andrada.baleti@nokia.com
    [Arguments]  ${random_soc_dn}

    ${power_group}  Get Regexp Matches  ${random_soc_dn}  POWER_GROUP_L-\\d
    ${power_group_id}  Fetch From Right  ${power_group}[0]  -

    [Return]  ${power_group_id}


Verify Parameters
    [Documentation]  To check if object has acceptable parameters states
    [Arguments]  ${parent_object}  ${scope}=${EMPTY}  &{parameters_states}

    FOR  ${object}  IN  @{parent_object}
        ${keys}  Get Dictionary Keys  ${object}
        ${dn_key}  Evaluate  'distName' if 'distName' in ${keys} else 'dist_name'
        ${params}  Get Infomodel Object  ${object.${dn_key}}
        ${as_required}  Run Keyword And Return Status
        ...  Dictionary Should Contain Sub Dictionary  ${params${scope}}  ${parameters_states}
        Run Keyword If  ${as_required}==${FALSE}
        ...  Set Test Restriction  ${object.${dn_key}} status wrong. Required: ${parameters_states}. Current: ${params${scope}}
        Run Keyword If  ${as_required}
        ...  Log  States of object ${object.${dn_key}} are correctly set ${parameters_states}  console=true
    END


Check SBTS Status During Recovery Site Reset
    [Documentation]  This keyword is used to check SBTS status during recovery site reset.
    [Arguments]  ${ping_timeout}

    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${ping_timeout}
    Run Keyword If  ${ping_loss_status}==${False}
    ...  Set Test Failed  Ping has not been lost within timeout=${ping_timeout}
    ...  ELSE
    ...  Log  Ping is lost  console=true
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${ping_timeout}
    Run Keyword If  ${ping_regain_status}==${False}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  Target is Reachable  console=true


Check Fault 1815 In Case It Will Be Visible
    [Documentation]  This KW checks if fault 1815 will be visible on any CABLINK from SoC.
    ...  Fault 1815 will be visible if reasoningStatus from CABLNK_L is BasebandBusSyncronizationFailed
    ...  and availabilityStatus from RMOD_R->RMOD_L/RU_L is Online (RMOD_R is the secondEndPoint of CABLINK_R).
    ...  Severity of fault 1815 is Critical if there are cells mapped on CABLINK. Otherwise it will be Minor.
    ...
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${module_r_dn}  ${soc_type}  ${soc_dn}

    ${cablinks_r_dn}  Get Cablinks With Fault 1815  ${module_r_dn}  ${soc_type}  ${soc_dn}
    ${cablinks_length}  Get Length  ${cablinks_r_dn}
    IF  ${cablinks_length} == 0
        Log  Fault 1815 will not be visible on any CABLINK.  console=true
        RETURN
    END
    FOR  ${cablink_r_dn}  IN  @{cablinks_r_dn}
        ${affected_cells}  Get Cell Mapping By Module Id  ${cablink_r_dn}
        ${cells_length}  Get Length  ${affected_cells}
        ${severity}  Set Variable If  ${cells_length}  Critical  Minor
        ${cablink_r_id}  Fetch From Right  ${cablink_r_dn}  /
        ${fault_1815_params}  Get String With Alarm Parameters  ${FAULT_1815}
        ${fault_1815_params}  Catenate  SEPARATOR=,${SPACE}  ${fault_1815_params}  severity="${severity}"  alarmingResource="${cablink_r_dn}"
        ${webem_status}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_1815_params}  timeout=200
        IF  ${webem_status}
            Log  WebEM: Fault 1815 "Not able to synchronize baseband bus" is active on ${cablink_r_id}. [OK]  console=true
        ELSE
            Fail  WebEM: Fault 1815 "Not able to synchronize baseband bus" is not active on ${cablink_r_id}. [NOK]
        END
        ${netact_status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  60  10  Check Additional Information For Given Alarm And Fault  &{FAULT_1815}
        ...                                                                                               severity=${severity}
        ...                                                                                               object_id=${cablink_r_id}
        IF  ${netact_status}
            Log  NetAct: Fault 1815 "Not able to synchronize baseband bus" is active on ${cablink_r_id}. [OK]  console=true
        ELSE
            Fail  NetAct: Fault 1815 "Not able to synchronize baseband bus" is not active on ${cablink_r_id}. [NOK]
        END
    END


Get Cablinks With Fault 1815
    [Documentation]  This keyword is used to get cablinks with fault 1815.
    [Arguments]  ${module_r_dn}  ${soc_type}  ${soc_dn}

    ${all_cablinks}  Get Parameters For All  CABLINK
    ${ports}  Get Loki Ports  ${soc_type}  ${soc_dn}
    ${1815_cablinks}  Create List
    FOR  ${link}  IN  @{all_cablinks}
        IF  '${link}[firstEndpointDN]' != '${module_r_dn}'  CONTINUE
        ${link_parameters}  coam.Get Parameters  ${link}[id]
        ${port_id}  Convert To String  ${link_parameters}[firstEndpointPortId]
        ${status_first_endpoint_port_id}  Run Keyword And Return Status
        ...  List Should Contain Value  ${ports}  ${port_id}
        IF  ${status_first_endpoint_port_id}
            ${check_1815}  Check Cablink And Rmod Statuses For Fault 1815 To Be Activated  ${link}[id]  ${link}[secondEndpointDN]
        ELSE
            ${check_1815}  Set Variable  ${False}
        END
        IF  ${check_1815}  Append To List  ${1815_cablinks}  ${link}[id]
    END

    RETURN  ${1815_cablinks}


Check Cablink And Rmod Statuses For Fault 1815 To Be Activated
    [Documentation]  This keyword is used to check cablink and rmod statuses for fault 1815 to be activated.
    [Arguments]  ${cablink_r_dn}  ${rmod_r_dn}

    ${cablink_ref}  Get Logical Object From Runtime Reference  ${cablink_r_dn}
    ${cablink_l}  coam.Get Parameters  ${cablink_ref}[distName]
    ${rmod_ref}  Get Logical Object From Runtime Reference  ${rmod_r_dn}
    ${ru_l}  coam.Get Parameters  ${rmod_ref}[distName]/RU_L-1
    ${reasoning_status}  Check Reasoning Statuses  ${cablink_l}[stateInfo][reasoningStatus]
    IF  ${reasoning_status} and '${ru_l}[stateInfo][availabilityStatus]'=='Online'  RETURN  ${TRUE}

    RETURN  ${FALSE}


Check Reasoning Statuses
    [Documentation]  This keyword is used to check reasoning statuses.
    [Arguments]  ${reasoning_statuses}

    FOR  ${reasoning_status}  IN  @{reasoning_statuses}
        IF  '${reasoning_status}'=='BasebandBusSynchronizationFailed'  RETURN  ${TRUE}
    END

    RETURN  ${FALSE}


Get Module Info Based On Technology
    [Documentation]
    ...  This KW returns module dist_name, serial number and cells deployed on it, based on technology and module type.
    ...  First, module found with given technology is chosen.
    ...  Used with: Parse cells list and verify technology
    ...  Ex: ${dist_name}  ${serial_number}  ${cells}  Get module info based on technology  RMOD  LNCEL
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${module_class}  ${technology}  ${bbmod_type}=${None}

    ${modules}  Get Parameters For All  ${module_class}
    FOR  ${module}  IN  @{modules}
        ${module_cells}  Get Cell Mapping By Module Id  ${module}[id]
        ${status_module_cells}  Parse Cells List And Verify Technology  ${module_cells}  ${technology}
        ${bbmod_type_status}  Run Keyword If  $bbmod_type is $None
        ...  Set Variable  ${TRUE}
        ...  ELSE
        ...  Run Keyword And Return Status
        ...  Should Contain  ${module}[productName]  ${bbmod_type}
        Run Keyword If  ${status_module_cells} and ${bbmod_type_status}
        ...  Return From Keyword  ${module}[id]  ${module}[serialNumber]  ${module_cells}
    END
    Fail  No ${module_class} found with given technology: ${technology}.


Parse Cells List And Verify Technology
    [Documentation]
    ...  This KW verifies if a certain technology exists in a list of cells.
    ...  Used in: Get module info based on technology
    ...  Ex: ${status_exists}  Parse cells list and verify technology  ${cells_on_rmod}  LNCEL
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${cells_list}  ${technology}

    FOR  ${cell}  IN  @{cells_list}
        ${status_cell}  Run Keyword And Return Status
        ...  Should Contain  ${cell}  ${technology}
        Run Keyword If  ${status_cell}
        ...  Return From Keyword  True
    END


Verify If Cells Are Deployed On Another Module
    [Documentation]
    ...  This KW verifies if cells deployed on certain module, are deployed on another module too.
    ...  Module serial number and cells deployed on it, must be discovered beforehand.
    ...  Ex: ${deployment_status}  Verify if cells are deployed on another module  RMOD  1M174051490  ${rmod_cells}
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${module_class}  ${module_sn}  ${chosen_module_cells}

    ${modules}  Get Parameters For All  ${module_class}
    FOR  ${module}  IN  @{modules}
        Run Keyword If  '${module}[serialNumber]'=='${module_sn}'
        ...  Continue For Loop
        ${current_module_cells}  Get Cell Mapping By Module Id  ${module}[id]
        ${list_status}  Run Keyword And Return Status
        ...  List Should Contain Sublist  ${current_module_cells}  ${chosen_module_cells}
        Run Keyword If  ${list_status}
        ...  Return From Keyword  True
    END
    Return From Keyword  False


Set SyncSigTxMode Parameter For LTE
    [Documentation]
    ...  This KW changes syncSigTxMode value to TxDiv for LTE cells deployed on two rmods.
    ...  Ex: Set syncSigTxMode parameter for LTE  ${rmod_cells}
    ...  *AUTHOR* anna.benzar@nokia.com
    ...  *MAINTAINER* andrada-lavinia.baleti@nokia.com
    [Arguments]  ${module_cells}

    FOR  ${cell}  IN  @{module_cells}
        ${cell_status}  Run Keyword And Return Status  Should Contain  ${cell}  LNCEL
        IF  not ${cell_status}  CONTINUE
        ${conf_ref_params}  coam.Get Parameters  ${cell}/CONF_REF-1
        ${lncel_obj_a_params}  coam.Get Parameters  ${conf_ref_params}[distName]/LNCEL_FDD_A-0
        IF  '${lncel_obj_a_params}[syncSigTxMode]' == 'TxDiv'    CONTINUE
        ${cell_path}  Replace String Using Regexp  ${cell}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
        ${cell_path}  Remove String Using Regexp  ${cell_path}  _R
        Perform Parameter Recommissioning  dist_name=${cell_path}/LNCEL_FDD-0  parameter=syncSigTxMode  operation=update  value=TxDiv
        ...  skip_parameter_relation_errors=True  should_activate=True
    END


Perform Recommissioning With EAC Plan
    [Documentation]  This keyword is used to perform recommissioning with EAC plan.
    [Arguments]  ${id}  ${severity}

    Log  Delta recommissioning with plan will be performed.  console=true
    ${status}  Query Infomodel  check //MRBTS_A-${BTS_ID}/EQM_A-1/APEQM_A-1/CABINET_A-1/SMOD_A-1/EAC_IN_A-1  allow_negative_result=True
    ${operation}  Set Variable If  ${status}  update  create
    ${delta_id}  Set Variable  ${id}
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1  ${operation}  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1  cancelDelay  0  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1  descr  EAC_1  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1  inUse  true  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1  polarity  Normally_closed  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1  portId  1  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1  startDelay  0  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1  severity  ${severity}  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_${delta_id}.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta_${delta_id}.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}


Perform Recommissioning To Clear EAC Fault
    [Documentation]  This keyword is used to perform recommissioning to clear EAC fault.

    Log  Delta recommissioning with plan will be performed.  console=true
    ${delta_id}  Set Variable  4
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1  delete  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_clear.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta_clear.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}


Get Module L Dist Name
    [Documentation]
    ...  This kewyord returns module L dist name by serial number.
    ...  Ex: ${module_l_dn}  Get module L dist name  EA192171673  BBMOD
    ...  *AUTHOR* andrada.baleti@nokia.com
    [Arguments]  ${module_sn}  ${module_type}

    ${bts_info}  coam.Get Bts Info
    ${modules}  Set Variable If  '${module_type}'=='SMOD'  systemModules  basebandModules
    ${modules_info}  Set Variable  ${bts_info}[${modules}]
    FOR  ${module_info}  IN  @{modules_info}
        Run Keyword If  '${module_sn}'=='${module_info}[serialNumber]'
        ...  Exit For Loop
    END
    ${ports}  Set Variable  ${module_info}[ports]
    FOR  ${port}  IN  @{ports}
        Exit For Loop If  "${module_type}_L" in "${port}[id][internal]"
    END
    ${module_l_dn}  Fetch From Left  ${port}[id][internal]  /CONNECTOR_L

    [Return]  ${module_l_dn}


Kill Process On SOC
    [Documentation]
    ...  This keyword kills a process from a SOC.
    ...  Ex: Kill process on SOC  LTEL2  LTE/LTEL2NODE
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${process}  ${container}

    SSHLibrary.Write  ps aux | grep ${process}
    ${output_ps}  SSHLibrary.Read Until Prompt
    ${lines}  Get Lines Containing String  ${output_ps}  ${container}
    ${split}  Split String  ${lines}
    ${name_process}  Set Variable  ${split}[10]
    ${pid}  Set Variable  ${split}[1]
    SSHLibrary.Write  kill -11 ${pid}

    [Return]  ${name_process}


Get Random Module Based On Its Type
    [Documentation]
    ...  This keyword returns a random module object based on module type.
    ...  Ex: Get random module based on its type  ABIO  BBMOD
    ...  *AUTHOR* andrada.baleti@nokia.com
    [Arguments]  ${module_type}  ${smod_bbmod_type}

    ${module_objects}  coam.Get Parameters For All  ${smod_bbmod_type}
    ${module_list}  Create List
    FOR  ${module_object}  IN  @{module_objects}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${module_object}[productName]  ${module_type}
        Run Keyword If  ${status}
        ...  Append To List  ${module_list}  ${module_object}
    END
    ${module_list_length}  Get Length  ${module_list}
    ${random_module_object}  Run Keyword If  ${module_list_length}==1
    ...  Set Variable  ${module_list}[0]
    ...  ELSE
    ...  Evaluate  random.choice(${module_list})  random

    [Return]  ${random_module_object}


Get SoC Position And Dist Name Based On Hardware Variant
    [Documentation]
    ...  This keyword returns random SOC dist name and position
    ...  based on hardware variant and module dist name.
    ...  Ex: Get SoC position and dist name based on hardware variant  Loki  /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-2
    ...  It uses "Get SoC position based on SoC dist name" keyword.
    ...  *AUTHOR* andrada.baleti@nokia.com
    [Arguments]  ${soc_hw_variant}  ${module_l_dn}

    ${soc_objects}  Query Infomodel  get list //SOC_L-* is [hwVariant=${soc_hw_variant}]
    ${loki_soc_list}  Create List
    FOR  ${soc_object}  IN  @{soc_objects}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${soc_object}[dist_name]  ${module_l_dn}
        Run Keyword If  ${status}
        ...  Append To List  ${loki_soc_list}  ${soc_object}[dist_name]
    END
    ${loki_soc_list_length}  Get Length  ${loki_soc_list}
    ${random_soc_dn}  Run Keyword If  ${loki_soc_list_length}==1
    ...  Set Variable  ${loki_soc_list}[0]
    ...  ELSE
    ...  Evaluate  random.choice(${loki_soc_list})  random
    ${soc_position}  Get SoC Position Based On SoC Dist Name  ${random_soc_dn}

    [Return]  ${random_soc_dn}  ${soc_position}


Get BBMOD IP If ASIA
    [Documentation]  This keyword is used to get BBMOD IP if ASIA.
    [Arguments]  ${vertical}

    SSHLibrary.Write  cat /etc/hosts
    ${output}  SSHLibrary.Read Until Prompt
    ${lines}  Get Lines Matching Regexp  ${output}  fsp-.a  partial_match=True
    ${lines_list}  Split To Lines  ${lines}
    ${first}  Split String  ${lines_list}[${vertical-1}]

    [Return]  ${first}[0]


Connect To BBMOD Using Ssh
    [Documentation]  This keyword is used to connect to BBMOD using ssh.
    [Arguments]  ${vertical}  ${ssh_alias}

    ${ip}  Get BBMOD IP If ASIA  ${vertical}
    SSHLibrary.Open Connection  ${ip}  prompt=:~ >
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]  jumphost_index_or_alias=${ssh_alias}


Connect To BBMOD Using Bsh
    [Documentation]  This keyword is used to connect to BBMOD using bsh.
    [Arguments]  ${vertical_position}

    SSHLibrary.Write  bsh ${vertical_position}:0
    SSHLibrary.Read Until Prompt


Check If Alarm Changed On BTS
    [Documentation]  This keyword is used to check if alarm changed on BTS.
    [Arguments]  @{alarms}  ${alarm_name}  ${severity}

    FOR  ${alarm}  IN  @{alarms}
        Run Keyword If  '${alarm}[alarmDetail]' == '${alarm_name}'
        ...  Should Be Equal  ${alarm}[severity]  ${severity}
    END


Get Secondary Core Parameters
    [Documentation]  This keyword returns parameters for secondary core object.

    ${smods}  Get Fsm Info
    FOR  ${smod}  IN  @{smods}
        Run Keyword If  '${smod}[activeRole]'=='Secondary'
        ...  Return From Keyword  ${smod}
    END


Get Core Restart Counter Value
    [Documentation]  This keyword returns the value for core restart counter for primary or
    ...  secondary core. SMOD L dist name is required as parameter.
    [Arguments]  ${smod_l_dn}

    ${smod_l_params}  coam.Get Parameters  ${smod_l_dn}
    ${restart_value}  Convert To Integer  ${smod_l_params}[coreRestartCounter]

    [Return]  ${restart_value}


Get Cells On RMODs With Syncronization Cablink On Secondary Core
    [Documentation]  This KW returns cells mapped on RMODs which have syncronization cablink
    ...  linked to one BBMOD from secondary core.
    ...
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${sc_r_dn}

    ${bbmods_on_secondary}  Get BBMODs On Secondary Core  ${sc_r_dn}
    ${rmods_with_syncro_on_sc}  Get RMODs With Syncro Cablink On Secondary Core  ${bbmods_on_secondary}
    ${affected_cells_on_rmods}  Create List
    FOR  ${rmod_id}  IN  @{rmods_with_syncro_on_sc}
        ${cells_on_rmod}  Get Cell Mapping By Module Id  ${rmod_id}
        Append To List  ${affected_cells_on_rmods}  @{cells_on_rmod}
    END
    ${affected_cells_on_rmods}  Remove Duplicates  ${affected_cells_on_rmods}

    [Return]  ${affected_cells_on_rmods}


Get BBMODs On Secondary Core
    [Documentation]  This keyword is used to get BBMODs on secondary core.
    [Arguments]  ${sc_r_dn}

    ${bbmods_on_secondary}  Create List
    ${cablink_list}  Query Infomodel  get list //CABLINK_R-* is [firstEndpointDN=${sc_r_dn}]
    FOR  ${cablink}  IN  @{cablink_list}
        Append To List  ${bbmods_on_secondary}  ${cablink}[secondEndpointDN]
    END

    [Return]  ${bbmods_on_secondary}


Get RMODs With Syncro Cablink On Secondary Core
    [Documentation]  This keyword is used to get RMODs with syncro cablink on secondary core.
    [Arguments]  ${bbmods_on_secondary}

    ${rmods_with_syncro_on_sc}  Create List
    ${all_rmods}  Get Ids For All  RMOD
    FOR  ${rmod_id}  IN  @{all_rmods}
        ${syncro_cablink}  Query Infomodel  get object //CABLINK_R-* is [secondEndpointDN=${rmod_id}, linkModeSynchronization=true]
        ...  allow_negative_result=True
        ${syncro_cablink_is_none}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${syncro_cablink}  None
        Run Keyword If  ${syncro_cablink_is_none}
        ...  Continue For Loop
        ${rmod_has_syncro_cablink_on_sc}  Run Keyword And Return Status
        ...  List Should Contain Value  ${bbmods_on_secondary}  ${syncro_cablink}[firstEndpointDN]
        Run Keyword If  ${rmod_has_syncro_cablink_on_sc}
        ...  Append To List  ${rmods_with_syncro_on_sc}  ${rmod_id}
    END

    [Return]  ${rmods_with_syncro_on_sc}


Get Cells Mapped On PC If RAT Is Mapped On Both PC And SC
    [Documentation]  This KW is searching for cells from a given RAT which are mapped on primary core.
    ...  If a specific RAT is mapped on both cores, then cells id from primary core will be returned.
    ...
    ...  * PARAMETERS *
    ...  cells_type  -  it can be GNCEL, WNCEL, LNCEL, NRCELL
    ...
    ...  * RETURN VALUE *
    ...  cells_on_primary_core  -  list with cells id which are mapped on primary core
    ...
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${cells_type}

    ${cells_from_rat_on_primary_core}  Create List
    ${secondary_core_object}  Get Secondary Core Parameters
    ${cells_on_secondary_core}  Get Cell Mapping By Module Id  ${secondary_core_object}[id][internal]
    ${cells_on_sc_status}  Cells From RAT Are Mapped On SC  ${cells_type}  ${cells_on_secondary_core}
    Run Keyword If  ${cells_on_sc_status}==${FALSE}
    ...  Return From Keyword  ${cells_from_rat_on_primary_core}
    ${cells_on_primary_core}  Get All Cells On Bts
    Remove Values From List  ${cells_on_primary_core}  @{cells_on_secondary_core}
    FOR  ${cell_id}  IN  @{cells_on_primary_core}
        ${rat_status}  Run Keyword And Return Status
        ...  Should Contain  ${cell_id}  ${cells_type}
        Run Keyword If  ${rat_status}
        ...  Append To List  ${cells_from_rat_on_primary_core}  ${cell_id}
    END

    [Return]  ${cells_from_rat_on_primary_core}


Cells From RAT Are Mapped On SC
    [Documentation]  This keyword is used to verify if cells from RAT are mapped on SC.
    [Arguments]  ${cells_type}  ${cells_on_secondary_core}

    FOR  ${cell_id}  IN  @{cells_on_secondary_core}
        ${rat_status}  Run Keyword And Return Status
        ...  Should Contain  ${cell_id}  ${cells_type}
        Run Keyword If  ${rat_status}
        ...  Return From Keyword  ${True}
    END

    [Return]  ${False}


Trigger Fault 246
    [Documentation]  This keyword is triggering fault 246 on secondary core.
    ...  * PARAMETERS *
    ...  sc_l_dn - object L dist name for secondary core (e.g. /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/SMOD_L-1)
    ...  msg_id  - message id for fault 246 (it can be 0x2062 or 0x206B)
    ...    * 0x2062 - enable clock, HWAPI_ENABLE_CLOCK_OUTPUT_RESP_MSG
    ...    * 0x206B - disable clock, HWAPI_DISABLE_CLOCK_OUTPUT_RESP_MSG
    ...
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${sc_l_dn}  ${msg_id}

    ${bts_l_matches}  Get Regexp Matches  ${sc_l_dn}  BTS_L-\\d
    ${id}  Fetch From Right  ${bts_l_matches}[0]  -
    ${fault_params_left_side}  Create List  3
    ${fault_params_right_side}  Create List  1
    Run Keyword If  '${id}'=='1'
    ...  Send Fault Ind Msg  269550357  269550771  18  7  fault_params=${fault_params_left_side}  sic_message_id=${msg_id}
    ...  ELSE
    ...  Send Fault Ind Msg  537985813  537986227  18  7  fault_params=${fault_params_right_side}  sic_message_id=${msg_id}



Check Cells On RMOD To Be Degraded Or Disabled
    [Documentation]
    ...  This kw checks availabilityStatus and operationalState for every cell mapped on a RMOD.
    ...  Some cells are mapped on two RMODs, so when triggering a fault, some of them will be degraded, and some will be disabled.
    ...  Example of usage:
    ...  Check cells on RMOD to be degraded or disabled  ${RMOD_CELLS}
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${rmod_cells}

    FOR  ${cell}  IN  @{rmod_cells}
        ${cell_parameters}  coam.Get Parameters  ${cell}
        ${degraded_status}  Run Keyword And Return Status
        ...  Should Contain  ${DEGRADED}  ${cell_parameters}[availabilityStatus]
        ${disabled_status}  Run Keyword And Return Status
        ...  Should Contain  ${DISABLED}  ${cell_parameters}[operationalState]
        Run Keyword If  ${degraded_status}==${FALSE} and ${disabled_status}==${FALSE}
        ...  Fail  Cells are not degraded or disabled. [NOK]
    END
    Log  All cells mapped on RMOD are degraded or disabled. [OK]  console=true


_Get Rmod Object By Serial Number
    [Documentation]  This keyword is used to get Rmod Object By Serial Number.
    [Arguments]  ${rmod_serial_number}

    ${rmod_r_obj}  Query Infomodel  get object //RMOD_R-* is [serialNumber=${rmod_serial_number}]
    ${ref_obj}  Query Infomodel  get object ${rmod_r_obj.dist_name}/REF-*
    ${rmod_l_obj}  Query Infomodel  get object ${ref_obj.distName}

    [Return]  ${rmod_l_obj}


Set Unit Position For Fault Signature
    [Documentation]  This keyword was created to obtain unit position for checking fault signature.
    [Arguments]  ${module_r_dn}

    ${module_parameters}  coam.Get Parameters  ${module_r_dn}
    ${horizontal_position}  Set Variable  ${module_parameters}[horizontalPosition]
    ${vertical_position}  Set Variable  ${module_parameters}[verticalPosition]
    IF  '${horizontal_position}'=='${None}' and '${vertical_position}'=='${None}'
        ${unit_position}  Set Variable  0
    ELSE IF  ${horizontal_position}==1
        ${unit_position}  Evaluate  ${vertical_position} - 1
    ELSE
        ${unit_position}  Evaluate  ${horizontal_position} + ${vertical_position} + 1
    END
    Set Test Variable  ${CORE_UNIT_POSITION}  ${unit_position}
    Set Test Variable  ${UNIT_POSITION}  ${horizontal_position}${vertical_position}


Get SoC With 2 RATs
    [Documentation]  This keyword is used to get SoC with 2 specific RATs.
    [Arguments]  ${hw_variant}  ${rat_type1}  ${rat_type2}

    ${hw_variant_soc_list}  Query Infomodel  get list //SOC_L-* is [hwVariant=${hw_variant}]
    FOR  ${soc}  IN  @{hw_variant_soc_list}
        ${cells}  Get Cell Mapping By Module Id  ${soc}[dist_name]
        ${rats_status}  Check 2 Rats On List  ${cells}  ${rat_type1}  ${rat_type2}
        Run Keyword If  ${rats_status}
        ...  Log  SoC with 2 available RATs: ${soc} \n cells: ${cells}  console=true
        Return From Keyword If  ${rats_status}  ${soc}
    END
    Log  Unable to find ${hw_variant} SoC with 2 RATs.  console=true

    [Return]  ${FALSE}


Check 2 Rats On List
    [Documentation]  This keyword is used to check if exists 2 rats on list.
    [Arguments]  ${list}  ${rat_type1}  ${rat_type2}

    ${rat_cell}  Create Dictionary  GSM=GNCELL  WCDMA=WNCELL  LTE=LNCEL  NR=NRCELL
    ${rat_1}  Set Variable  ${FALSE}
    ${rat_2}  Set Variable  ${FALSE}
    FOR  ${rat}  IN  @{list}
        ${rat_1}  Run Keyword If  '${rat_cell}[${rat_type1}]' in '${rat}'
        ...  Set Variable  ${TRUE}
        Exit For Loop If  ${rat_1}
    END
    FOR  ${rat}  IN  @{list}
        ${rat_2}  Run Keyword If  '${rat_cell}[${rat_type2}]' in '${rat}'
        ...  Set Variable  ${TRUE}
        Exit For Loop If  ${rat_2}
    END
    Return From Keyword If  ${rat_1} and ${rat_2}  ${TRUE}

    [Return]  ${FALSE}


Get Slave SoC HwVariant Based On Unit Type
    [Documentation]  Default returned value is Loki for ABIO, ABIN, ASOE, ASOF
    [Arguments]  ${unit_type}

    Run Keyword If  "${unit_type}"=="ABIP"
    ...  Return From Keyword  Thor
    ...  ELSE IF  "${unit_type}"=="ABIQ"
    ...  Return From Keyword  Magni
    ...  ELSE
    ...  Return From Keyword  Loki


Check If 2RAT
    [Documentation]  To check if at least 2 RATs are commissioned.

    ${commissioned_technologies}  Create List
    ${check_gsm}  Run Keyword And Return Status  Should Not Be Equal  '${SCF_COUNT_GSM}'  '0'
    Append To List  ${commissioned_technologies}  ${check_gsm}
    ${check_lte}  Run Keyword And Return Status  Should Not Be Equal  '${SCF_COUNT_LTE}'  '0'
    Append To List  ${commissioned_technologies}  ${check_lte}
    ${status}  Run Keyword And Return Status  Should Contain  '${commissioned_technologies}'  True
    IF  ${status}
      Log  At least one other technology than WCDMA is commissioned. Test will continue. [OK]  console=true
    ELSE
      Fail  msg=Only one techonology is commissioned. At least one other than WCDMA is required. Test will not continue. [NOK]
    END


Choose DSP For Crash
    [Documentation]  This KW is created to select DSP randomly from desired RAT which will be crashed during test scenario.
    [Arguments]  ${rat}
    [Timeout]  15 min

    Log  Choose DSP and its CORE which will be crashed.  console=true
    ${dsps_dist_names}  Infomodel Get All DSPs Dist Names For Given RAT  ${rat}
    ${list_length}  Get Length  ${dsps_dist_names}
    ${crashed_dsp}  Evaluate  random.randint(0, ${list_length}-1)  modules=random
    ${dist_name}  Get From List  ${dsps_dist_names}  ${crashed_dsp}
    Check System Module Release For DSP Chosen  ${dist_name}
    ${is_as}  Run Keyword And Return Status  Should Match Regexp  ${SMOD_TYPE}  (ASIA|ASIB|ASIM|ASIL|ASOG|Flexi.*FSMF)
    IF  ${is_as}  Set Attribute For BBMOD/SMOD Chosen  ${dist_name}
    ${core}  Evaluate  random.randint(1, ${CORES})  modules=random
    ${core_id}  Query Infomodel  get object ${dist_name}/CORE_L-${core}
    ${node_id}  Convert To Hex  ${core_id.nodeId}  prefix=0x
    Log  Chosen node_id: ${node_id}  console=true
    Set Test Variable  ${CORE_DN}  ${core_id}[dist_name]
    ${dsp_l_dn}  Fetch From Left  ${CORE_DN}  /CORE
    Set Test Variable  ${DSP_L_DN}
    Set Test Variable  ${CORE_ID}
    Set Test Variable  ${NODE_ID}


Check System Module Release For DSP Chosen
    [Documentation]  To check what kind of module is being tested.
    [Arguments]  ${dsp_distname}

    ${smod_l}  Fetch From Left  ${dsp_distname}  /EQM_L-1
    ${module}  Catenate  SEPARATOR=  ${smod_l}  /EQM_L-1/CABINET_L-1/SMOD_L-1
    ${smod_object}  Query Infomodel  get object ${module}
    ${smod_type}  Set Variable  ${smod_object.productName}
    Set Test Variable  ${SMOD_TYPE}
    ${is_as}  Run Keyword And Return Status  Should Match Regexp  ${SMOD_TYPE}  (ASIA|ASIB|ASIM|ASIL|ASOG)
    ${cores}  IF  ${is_as}  Evaluate  8  ELSE  Evaluate  4
    Set Test Variable  ${CORES}


Set Attribute For BBMOD/SMOD Chosen
    [Documentation]  Sets test variables for the chosen BBMOD/SMOD from the given distinguished name.
    [Arguments]  ${dist_name}

    ${soc_dn}  Fetch From Left  ${dist_name}  /DSP_L
    ${is_as}  Run Keyword And Return Status  Should Match Regexp  ${SMOD_TYPE}  (ASIA|ASIB|ASIM|ASIL|Flexi.*FSMF)
    IF  ${is_as}
      ${soc_position}  Set Variable  0
      ${unit_l_dn}  Fetch From Left  ${dist_name}  /BBU_L
    ELSE
      ${soc_position}  Get ASOG SoC  ${soc_dn}
      ${unit_l_dn}  Fetch From Left  ${dist_name}  /BOARD_L
    END
    ${unit_r_dn}  Get Runtime Object Dist_name From Logical Object Dist_name  ${unit_l_dn}
    ${soc_vertical_position}  Get Module Vertical Position  ${unit_r_dn}
    ${stored_role}  Get StoredRole From MODULE_L  ${unit_l_dn}
    Set Test Variable  ${SOC_VERTICAL_POSITION}  ${soc_vertical_position}
    Set Test Variable  ${SOC_HORIZONTAL_POSITION}  ${soc_position}
    Set Test Variable  ${STORED_ROLE}  ${stored_role}


Verify SMOD Type And Trigger DSP Crash
    [Documentation]  Verifies SMOD type and triggers a DSP crash (e.g. for ASIM/ASIL/ASOG types).

    Open Connection To Primary Core
    IF  '${STORED_ROLE}'=='Idle'  Open Connection To Secondary Core
    ${is_as}  Run Keyword And Return Status  Should Match Regexp  ${SMOD_TYPE}  (ASIM|ASIL|ASOG)
    IF  ${is_as}
      Open Connection To SOC  ${SOC_VERTICAL_POSITION}  ${SOC_HORIZONTAL_POSITION}
      Trigger DSP Crash
    ELSE
      Trigger DSP Crash
    END


Trigger DSP Crash
    [Documentation]  Triggers a DSP crash via rioboot write to the node (used for fault injection tests).

    SSHLibrary.Set Client Configuration  prompt=REGEXP:(#|>)
    SSHLibrary.Write  echo 0XFFFF > /tmp/data.dat
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  rioboot -c write -a 0x128FFFFF -f /tmp/data.dat ${NODE_ID}
    SSHLibrary.Read Until Prompt


Convert Days To Hours
    [Documentation]  This KW is created to convert the number of days from the output of "uptime" command into total hours.
    ...  Example: if the output is "11:42:26 up 14 days, 2 users", the KW will take only the number of days, which in this case is 14.
    ...  This number will then be multiplied by 24 (hours in one day) to obtain the total number of hours.
    [Arguments]  ${string}

    ${left_string}  Fetch From Right  ${string}  up${SPACE}
    ${time}  Fetch From Left  ${left_string}  ,
    ${time}  Fetch From Left  ${time}  ${SPACE}
    ${hours}  Evaluate  ${time} * 24
    Return From Keyword  ${hours}


Convert Hour Time In Hours
    [Documentation]  This KW is created to get the number of hours from the output of "uptime" command.
    ...  Example: if the output is "11:42:26 up 18:24, 2 users", the KW will take only the number of hours, which in this case is 18.
    [Arguments]  ${string}

    ${left_string}  Fetch From Right  ${string}  up${SPACE}
    ${time}  Fetch From Left  ${left_string}  ,
    ${hours}  Fetch From Left  ${time}  :
    ${hours}  Fetch From Left  ${hours}  ${SPACE}min
    Return From Keyword  ${hours}


Convert Complex Time To Total Hours
    [Documentation]  This KW is created to convert complex time from the output of "uptime" command into total hours.
    ...  Example: if the output is "11:42:26 up 1 day 16:20, 2 users", the KW will take only the number of days and hours,
    ...  which in this case is 1 day and 16:20.
    ...  This number of days will then be multiplied by 24 (hours in one day) to obtain the total number of hours.
    ...  Then, this number will be added to the number of hours. The result will be the total number of hours.
    [Arguments]  ${string}

    ${days}  Fetch From Left  ${string}[0]  ${SPACE}day
    ${hours_from_days}  Evaluate  ${days} * 24
    ${left_string}  Fetch From Left  ${string}[0]  :
    ${hours}  Fetch From Right  ${left_string}  ${SPACE}
    ${all_hours}  Evaluate  ${hours_from_days} + ${hours}
    Return From Keyword  ${all_hours}


Check Fault Signature In WebEM For All Radio Modules
    [Documentation]  This keyword is used to check fault signature of alarm in WebEM for all radio modules.
    [Arguments]
    ...  ${fault}
    ...  ${alarm_severity}
    ...  ${rmods_serial_numbers}
    ...  ${numbers_of_rmods}
    ...  ${test_category}
    ...  ${test_scope}
    ...  ${test_extra_info}
    ...  ${active_software}
    ...  ${test_date}
    ...  ${numbers_of_appearances}=3

    Log  Checking fault signature in historical alarms.  console=true
    ${alarm_list}  Create List
    ${historical_alarms}  Get Historic Alarms
    FOR  ${item}  IN  @{historical_alarms}
        ${check_alarm_severity}  Run Keyword And Return Status
        ...  Should Match Regexp  ${alarm_severity}  (?i)(${item}[severity])
        Run Keyword If  '${item}[faultId]'=='${fault}' and '${check_alarm_severity}'=='True'
        ...  Append To List  ${alarm_list}  ${item}[faultSignature]
    END
    ${fault_signature_list}  Create List
    FOR  ${alarm}  IN  @{alarm_list}
        ${category_field}  Run Keyword And Return Status
        ...  Should Be Equal  '${alarm}[category]'  '${test_category}'
        ${component_field}  Run Keyword And Return Status
        ...  List Should Contain Value  ${rmods_serial_numbers}  ${alarm}[component]
        ${date_field}  Run Keyword And Return Status
        ...  Should Match Regexp  ${alarm}[date]  (${test_date})[0-9]{6}\.
        ${extra_info_field}  Run Keyword And Return Status
        ...  Should Match Regexp  ${alarm}[extraInfo]  ${test_extra_info}
        ${load_name_field}  Run Keyword And Return Status
        ...  Should Be Equal  '${alarm}[loadName]'  '${active_software}'
        ${scope_field}  Run Keyword And Return Status
        ...  Should Be Equal  '${alarm}[scope]'  '${test_scope}'
        ${condition}  Catenate  SEPARATOR=${SPACE}and${SPACE}  ${category_field}  ${component_field}  ${date_field}  ${extra_info_field}
        ...  ${load_name_field}  ${scope_field}
        Run Keyword If  ${condition}
        ...  Run Keywords
        ...  Log  Fault signature of alarm matches pattern.  console=true
        ...  AND
        ...  Append To List  ${fault_signature_list}  ${alarm}
    END
    ${signature_matches}  Get Length  ${fault_signature_list}
    ${alarm_count_by_rmod}  Evaluate  ${numbers_of_rmods}*${numbers_of_appearances}
    ${compare_alarm_count}  Run Keyword And Return Status
    ...  Should Be Equal  ${alarm_count_by_rmod}  ${signature_matches}
    ${log_message}  Catenate  Number of RMODs tested: ${numbers_of_rmods}
    ...  Recovery should be performed ${numbers_of_appearances} times per radio module.  Number of alarms in historical alarms: ${signature_matches}.
    ${set_test_failed_message}  Catenate  Number of RMODs tested: ${numbers_of_rmods}.
    ...  Recovery should be performed ${numbers_of_appearances} times per radio module.  Number of alarms in historical alarms: ${signature_matches}.
    Run Keyword If  ${compare_alarm_count}
    ...  Log  ${log_message}  console=true
    ...  ELSE
    ...  Fail  ${set_test_failed_message}


Check Fault Signature Of Alarm In WebEM
    [Documentation]
    ...  Keyword checks if fault signature of alarm matches regexp.
    ...  Expected fault id nedeed as argument for filtering out the alarms in alarms history.
    ...  Additionally fault name and minor field can be used to filter out alarms history.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]
    ...  ${fault_id}=${None}
    ...  ${filtering_fault_name}=${EMPTY}
    ...  ${filtering_minor_field}=${EMPTY}
    ...  ${category}=${EMPTY}
    ...  ${component}=${EMPTY}
    ...  ${extra_info}=${EMPTY}
    ...  ${info}=${EMPTY}
    ...  ${load_name}=${EMPTY}
    ...  ${minor}=${EMPTY}
    ...  ${reset_counter}=${EMPTY}
    ...  ${rfm_cpri}=${EMPTY}
    ...  ${rfm_fpga}=${EMPTY}
    ...  ${rfm_gpp}=${EMPTY}
    ...  ${scope}=${EMPTY}
    ...  ${full_product_name}=${EMPTY}
    ...  ${serial_number}=${EMPTY}
    ...  ${core_serial_number}=${EMPTY}
    ...  ${vendor_unit_number}=${EMPTY}
    ...  ${core_vendor_unit_number}=${EMPTY}
    ...  ${unit_position}=${EMPTY}
    ...  ${core_unit_position}=${EMPTY}

    ${bts_date}  Get BTS time in UTC format  %Y-%m-%d %H:%M:%S
    ${expected_date}  Convert Date  ${bts_date}  %Y%m%d
    ${historical_alarms}  Get Historic Alarms
    Reverse List  ${historical_alarms}
    FOR  ${item}  IN  @{historical_alarms}
        ${faultsig}  Set Variable  ${item}[faultSignature]
        ${condition_filtering}  Set Variable If  '${filtering_fault_name}' != '${EMPTY}'  '${item}[faultName]'=='${filtering_fault_name}'
        ...  '${filtering_minor_field}' != '${EMPTY}'  '${faultsig}[minor]'=='${filtering_minor_field}'  False
        ${condition_with_fault_id}  Set Variable If  ${condition_filtering}==False  '${item}[faultId]'=='${fault_id}'
        ...  '${item}[faultId]'=='${fault_id}' and ${condition_filtering}
        ${alarm}  Set Variable If  ${condition_with_fault_id}  ${item}
        IF  ${condition_with_fault_id}  BREAK
    END
    ${fault_signature}  Set Variable  ${alarm}[faultSignature]
    Log  Fault signature in alarm will checked in WebEM.  console=true
    Check Regexp  ${fault_signature}[category]  ${category}  Category not matched.
    Check Component Field  ${fault_signature}[component]  ${component}  ${full_product_name}  ${serial_number}  ${core_serial_number}
    ...  ${vendor_unit_number}  ${core_vendor_unit_number}  ${unit_position}  ${core_unit_position}
    ${status_date}  Run Keyword And Return Status  Check Regexp  ${fault_signature}[date]  (${expected_date})[0-9]{6}\.  None
    IF  not ${status_date}
        ${yesterday_date}  Subtract Time From Date  ${bts_date}  1 day
        ${expected_yesterday}  Convert Date  ${yesterday_date}  %Y%m%d
        ${yesterday_date_status}  Run Keyword And Return Status  Check Regexp  ${text5_dict}[DATE]  ${expected_yesterday}  None
        IF  not ${yesterday_date_status}  Fail  Date field did not matched.
    END
    Check Regexp  ${fault_signature}[extraInfo]  ${extra_info}  Extra info field did not matched.
    Check Regexp  ${fault_signature}[info]  ${info}  Info field did not matched.
    Check Equality  ${fault_signature}[loadName]  ${load_name}  Load name field did not matched.
    Check Regexp  ${fault_signature}[minor]  ${minor}  Minor field did not matched.
    ${fault_signature_reset_counter}  Convert To String  ${fault_signature}[resetCounter]
    Check Regexp  ${fault_signature_reset_counter}  ${reset_counter}  msg=Reset counter field is null.
    Check Equality  ${fault_signature}[rfmCpri]  ${rfm_cpri}  rfmCpri field did not matched.
    Check Equality  ${fault_signature}[rfmFpga]  ${rfm_fpga}  rfmFpga field did not matched.
    Check Regexp  ${fault_signature}[rfmGpp]  ${rfm_gpp}  rfmGpp field did not matched.
    Check Equality  ${fault_signature}[scope]  ${scope}  Scope field did not matched.
    Log  Fault signature in WebEM is field correctly. [OK]  console=True


Check Fault Signature If Fault 4589 Was Raised At Power Off/On For Radio Module
    [Documentation]  Verifies fault signature and that fault 4589 (unit power reset) is inactive after power off/on.

    ${fault_4589_params}  Get String With Alarm Parameters  ${FAULT_4589_UNIT_POWER_RST}
    Assert Alarm Inactive  parameters=${fault_4589_params}  timeout=120
    Sleep  30s  Waiting for alarm history to update.
    ${historical_alarms}  coam.Get Historic Alarms
    Reverse List  ${historical_alarms}
    ${faults_4589_list}  Create List
    FOR  ${alarm}  IN  @{historical_alarms}
       ${status_fault_id}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultId]  ${FAULT_4589_UNIT_POWER_RST}[fault_id]
       IF  ${status_fault_id}  Append To List  ${faults_4589_list}  ${alarm}
    END
    ${number_of_4589_alarms}  Get Length  ${faults_4589_list}
    IF  '${number_of_4589_alarms}' == '0'  RETURN
    Log  Fault 4589 found in alarm history, check for fault signature will be performed.  console=true
    ${scope}  Set Variable  RFM
    ${category}  Set Variable  POWER_OFF
    ${reset_counter}  Set Variable  [0-9]+
    FOR  ${alarm}  IN  @{faults_4589_list}
       ${fault_signature}  Set Variable  ${alarm}[faultSignature]
       Log  Fault signature in alarm will checked in WebEM.  console=true
       Check Regexp  ${fault_signature}[category]  ${category}  Category not matched.
       ${fault_signature_reset_counter}  Convert To String  ${fault_signature}[resetCounter]
       Check Regexp  ${fault_signature_reset_counter}  ${reset_counter}  msg=Reset counter field is null.
       Check Equality  ${fault_signature}[scope]  ${scope}  Scope field did not matched.
       Check Component Field  ${fault_signature}[component]  ${alarm}[serialNo]
       Check Equality  ${fault_signature}[loadName]  ${SW_VERSION}  Load name field did not matched.
       Log  Fault signature in WebEM is field correctly. [OK]  console=True
    END


Save Alarm For Later Checks
    [Documentation]  This keyword was designed to save alarm from an alarm list.
    ...  Filtering will be made based on fault id, fault name, alarm id, alarm name and sevrity.
    ...  This keyword can be used e.g to save alarm from assert alarm active output before recovery site reset and later check fault signature.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${alarms_list}  ${fault_to_save}

    FOR  ${alarm}  IN  @{alarms_list}
       ${condition}  Catenate  SEPARATOR=${SPACE}and${SPACE}
       ...  ${alarm}[faultId]==${fault_to_save}[fault_id]
       ...  ${alarm}[alarmId]==${fault_to_save}[alarm_id]
       ...  '${alarm}[faultName]'=='${fault_to_save}[fault_name]'
       ...  '${alarm}[alarmName]'=='${fault_to_save}[alarm_name]'
       ...  '${alarm}[severity]'=='${fault_to_save}[severity]'
       ${matched_alarm}  Set Variable If  ${condition}  ${alarm}
       IF  ${condition}  BREAK
    END

    RETURN  ${matched_alarm}


Check Fault Signature Of Saved Alarm WebEM
    [Documentation]  This keyword was designed to check fault signature fields from a saved alarm.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]
    ...  ${saved_alarm}
    ...  ${category}=${EMPTY}
    ...  ${component}=${EMPTY}
    ...  ${extra_info}=${EMPTY}
    ...  ${info}=${EMPTY}
    ...  ${load_name}=${EMPTY}
    ...  ${minor}=${EMPTY}
    ...  ${reset_counter}=${EMPTY}
    ...  ${rfm_cpri}=${EMPTY}
    ...  ${rfm_fpga}=${EMPTY}
    ...  ${rfm_gpp}=${EMPTY}
    ...  ${scope}=${EMPTY}
    ...  ${full_product_name}=${EMPTY}
    ...  ${serial_number}=${EMPTY}
    ...  ${core_serial_number}=${EMPTY}
    ...  ${vendor_unit_number}=${EMPTY}
    ...  ${core_vendor_unit_number}=${EMPTY}
    ...  ${unit_position}=${EMPTY}
    ...  ${core_unit_position}=${EMPTY}

    ${date}  Get BTS time in UTC format  %Y%m%d
    ${fault_signature}  Set Variable  ${saved_alarm}[faultSignature]
    Log  Fault signature in alarm will checked in WebEM.  console=true
    Check Regexp  ${fault_signature}[category]  ${category}  Category not matched.
    Check Component Field  ${fault_signature}[component]  ${component}  ${full_product_name}  ${serial_number}  ${core_serial_number}
    ...  ${vendor_unit_number}  ${core_vendor_unit_number}  ${unit_position}  ${core_unit_position}
    Check Regexp  ${fault_signature}[date]  (${date})[0-9]{6}\.  msg=Date field did not matched.
    Check Regexp  ${fault_signature}[extraInfo]  ${extra_info}  Extra info field did not matched.
    Check Regexp  ${fault_signature}[info]  ${info}  Info field did not matched.
    Check Equality  ${fault_signature}[loadName]  ${load_name}  Load name field did not matched.
    Check Regexp  ${fault_signature}[minor]  ${minor}  Minor field did not matched.
    ${fault_signature_reset_counter}  Convert To String  ${fault_signature}[resetCounter]
    Check Regexp  ${fault_signature_reset_counter}  ${reset_counter}  msg=Reset counter field is null.
    Check Equality  ${fault_signature}[rfmCpri]  ${rfm_cpri}  rfmCpri field did not matched.
    Check Equality  ${fault_signature}[rfmFpga]  ${rfm_fpga}  rfmFpga field did not matched.
    Check Equality  ${fault_signature}[rfmGpp]  ${rfm_gpp}  rfmGpp field did not matched.
    Check Equality  ${fault_signature}[scope]  ${scope}  Scope field did not matched.
    Log  Fault signature in WebEM is field correctly. [OK]  console=True


Get GTPU ID
    [Documentation]  Returns the GTPU ID from the infomodel (GTPU_R object).

    ${gtpu_r_object}  Query Infomodel  get object //GTPU_R-*
    ${gtpu_id}  Fetch From Right  ${gtpu_r_object}[dist_name]  -

    [Return]  ${gtpu_id}


Get MNL ID
    [Documentation]  Returns the MNL ID from the infomodel (MNL_R object).

    ${mnl_r_object}  Query Infomodel  get object //MNL_R-*
    ${mnl_id}  Fetch From Right  ${mnl_r_object}[dist_name]  -

    [Return]  ${mnl_id}


Get CMD ID
    [Documentation]  Returns the CMD ID from the infomodel (CMD_A object).

    ${cmd_a_object}  Query Infomodel  get object //CMD_A-*
    ${cmd_id}  Fetch From Right  ${cmd_a_object}[dist_name]  -

    [Return]  ${cmd_id}


Get MNLENT ID
    [Documentation]  Returns the MNLENT ID from the infomodel (MNLENT_A object).

    ${mnlent_a_object}  Query Infomodel  get object //MNLENT_A-*
    ${mnlent_id}  Fetch From Right  ${mnlent_a_object}[dist_name]  -

    [Return]  ${mnlent_id}


Get FMCADM ID
    [Documentation]  Returns the FMCADM ID from the infomodel (FMCADM_A object).

    ${fmcadm_a_object}  Query Infomodel  get object //FMCADM_A-*
    ${fmcadm_id}  Fetch From Right  ${fmcadm_a_object}[dist_name]  -

    [Return]  ${fmcadm_id}


Set ALTOGGSUPP Path
    [Documentation]  Sets the ALTOGGSUPP path test variable from BTS ID and infomodel IDs (MNL, MNLENT, FMCADM).

    ${bts_id}  Admin Get BTS ID
    ${mnl_id}  Get MNL ID
    ${mnlent_id}  Get MNLENT ID
    ${fmcadm_id}  Get FMCADM Id
    Set Test Variable  ${ALTOGGSUPP_PATH}  MRBTS-${bts_id}/MNL-${mnl_id}/MNLENT-${mnlent_id}/FMCADM-${fmcadm_id}/ALTOGGSUPP-1


Create Or Update ALTOGGSUPP Object
    [Documentation]  Creates or updates the ALTOGGSUPP object under FMCADM with the given alarm toggling parameters.
    [Arguments]  ${operation}  ${al_togg_amount}  ${al_togg_conditon_time}  ${al_togg_clearence_time}  ${fault_id}  ${in_use}

    Log  ${operation} ALTOGGSUPP Object Under FMCADM.  console=true
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  ${ALTOGGSUPP_PATH}  ${operation}  ${delta_id}
    Append Parameter Update To Delta  ${ALTOGGSUPP_PATH}  alToggAmount  ${al_togg_amount}  ${delta_id}
    Append Parameter Update To Delta  ${ALTOGGSUPP_PATH}  alToggConditonTime  ${al_togg_conditon_time}  ${delta_id}
    Append Parameter Update To Delta  ${ALTOGGSUPP_PATH}  alToggClearenceTime  ${al_togg_clearence_time}  ${delta_id}
    Append Parameter Update To Delta  ${ALTOGGSUPP_PATH}  inUse  ${in_use}  ${delta_id}
    Append List Items To Delta  ${ALTOGGSUPP_PATH}  faultId  ${fault_id}  delta_id=${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_create.json  delta_id=${delta_id}
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_create.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}


Disable Alarm Toggling
    [Documentation]  Disables alarm toggling by setting ALTOGGSUPP inUse to false via delta.

    Log  Disable Alarm Toggling.  console=true
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Parameter Update To Delta  ${ALTOGGSUPP_PATH}  inUse  false  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_disable.json  delta_id=${delta_id}
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_disable.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}


Delete ALTOGGSUPP Object
    [Documentation]  Deletes the ALTOGGSUPP object under FMCADM via delta.

    Log  Delete ALTOGGSUPP Object Under FMCADM.  console=true
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  ${ALTOGGSUPP_PATH}  delete  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_delete.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta_delete.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}


Block online cells for given RAT
    [Documentation]  Blocks (disables) online cells for the given RAT.
    [Arguments]  ${rat}

    ${cells_list}  Get Cells Info  ${rat}
    ${online_cells}  Create List
    FOR  ${cell}  IN  @{cells_list}
        ${status}  Run Keyword And Return Status  Should Contain  ${ENABLED}  ${cell}[status][operationalState]
        Run Keyword If  ${status}
        ...  Append To List  ${online_cells}  ${cell}[id][internal]
    END
    FOR  ${cell}  IN  @{online_cells}
        Block Cell  dist_name=${cell}  timeout=180
    END


Check Fault 4592 Information In WebEM Alarm History
    [Documentation]  Keyword designed to check duration and reason for fault 4592 in WebEM alarm history.
    ...  Alarm should appear 5 minutes after BTS reset and it should be active in WebEm for the time defined by fault4592CancellationTimer parameter.
    ...  Alarm duration is calculated as the diference between clearedTime and btsObservationTime fields.
    ...  Alarm duration time is checked to be in fault4592CancellationTimer-10s and fault4592CancellationTimer10s time period.
    [Arguments]  ${fault_reason}  ${fault_id}=4592

    ${list}  Create List  fault4592CancellationTimer
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  ${list}
    ${timer}  Set Variable  ${parameter}[0][parameters][fault4592CancellationTimer]
    ${timer}  Convert To Integer  ${timer}
    Log  Getting alarm history from WebEM.  console=true
    ${historic_alarms}  coam.Get Historic Alarms
    FOR  ${item}  IN  @{historic_alarms}
        ${alarm}  Set Variable If  ${item}[faultId]==${fault_id}  ${item}
        IF  ${item}[faultId]==${fault_id}  BREAK
    END
    Log  ${alarm}[btsObservationTime]  console=true
    Log  ${alarm}[clearedTime]  console=true
    ${time_stamp_observation_time}  Convert Timestamp From BtsObservationTime  ${alarm}[btsObservationTime]
    ${time_stamp_cleared_time}  Convert Timestamp From BtsObservationTime  ${alarm}[clearedTime]
    ${alarm_duration}  Subtract Time From Time  ${time_stamp_cleared_time}  ${time_stamp_observation_time}
    ${alarm_duration}  Convert To Integer  ${alarm_duration}
    ${alarm_total_time}  Evaluate  ${timer}-10 <= ${alarm_duration} <= ${timer}+10
    IF  ${alarm_total_time}
        Log  Duration of fault 4592 BTS Reset is: ${alarm_duration}. Value within tolerance defined by fault4592CancellationTimer=${timer}.
        ...  console=true
    ELSE
        Fail  Duration of fault 4592 BTS Reset is: ${alarm_duration}. Value not within tolerance defined by fault4592CancellationTimer=${timer}.
    END
    Check Supplementary Alarm Information  ${alarm}  ${fault_reason}


Convert Timestamp From BtsObservationTime
    [Documentation]  Converts BTS observation time timestamp to HH:MM:SS format.
    [Arguments]  ${alarm_timestamp}

    ${time}  Convert To List  ${alarm_timestamp}
    ${hour_time_stamp}  Catenate  SEPARATOR=  ${time}[8]${time}[9]  :${time}[10]${time}[11]  :${time}[12]${time}[13]
    ${time_stamp_observation_time}  Convert To String  ${hour_time_stamp}

    RETURN  ${time_stamp_observation_time}


Create NOTES Object
    [Documentation]  Creates a NOTES object under MNL with the given attribute name and value via delta.
    [Arguments]   ${attribName}  ${attribValue}

    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/NOTES-1  create  ${delta_id}
    Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/NOTES-1/NOTE-1  create  ${delta_id}
    ${structure_1}  Create Dictionary
    Set To Dictionary  ${structure_1}  attribName  ${attribName}
    Set To Dictionary  ${structure_1}  attribValue  ${attribValue}
    Append Complex Item To Delta  MRBTS-${BTS_ID}/MNL-1/NOTES-1/NOTE-1  list_name=attribute  &{structure_1}  delta_id=${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_Files}/delta.json  delta_id=${delta_id}
    coam.Perform Delta Recommissioning  ${BTS_Files}/delta.json  skip_parameter_relation_errors=True  timeout=300
    Remove delta  ${delta_id}
    Remove File  ${BTS_Files}/delta.json


Delete NOTES Object
    [Documentation]  Deletes the NOTES object (MRBTS/MNL-1/NOTES-1) via delta.

    Log  Deleting NOTES object...  console=true
    ${delta_id}  Set variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/NOTES-1  delete  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_Files}/delta.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_Files}/delta.json  skip_parameter_relation_errors=True  timeout=240
    Remove delta  ${delta_id}
    Remove File  ${BTS_Files}/delta.json
    Log  Deletion of NOTES object is done.  console=true


Parse Syslog Files And Verify Fault Signature
    [Documentation]
    ...  This keyword verifies fault signature in all syslog files(SYSLG_BTS_UDP or SYSLOG_PC_UDP and SYSLOG_SC_UDP).
    ...  It uses "Unarchive Syslogs From UDPLogs Directory" from syslog_resource.robot
    ...  and "Check FaultSignature Info In Syslog File" from ca_FM_general.robot.
    ...  After verification, unarchived syslogs are deleted with
    ...  "Delete Unarchived Syslogs From UDPLogs Directory" keyword from syslog_resource.robot.

    Unarchive Syslogs From UDPLogs Directory
    ${syslog_files}  OperatingSystem.List Directory  ${UDP_LOGS}/Unarchived
    FOR  ${file}  IN  @{syslog_files}
        ${file_status}  Run Keyword And Return Status  Check FaultSignature Info In Syslog File  ${UDP_LOGS}/Unarchived/${file}
        Run Keyword If  ${file_status}
        ...  Run Keywords
        ...  Log  All fault signature fields from syslog file: "${file}" are correctly set. [OK]  console=true
        ...  AND
        ...  Return From Keyword
    END
    Fail  Fault signature fields from syslog files: ${syslog_files} are incorrect. [NOK]


    [Teardown]  Run Keyword And Ignore Error  Delete Unarchived Syslogs From UDPLogs Directory


Check FaultSignature Info In Syslog File
    [Documentation]
    ...  This keyword verifies fault signature fields in given syslog file.
    ...  Fault signature fields that are verified are: product_name, serial_number, category, scope, sofware_version,
    ...                                                reset_counter, product_code, unit_position, minor and info.
    ...  In syslog files, only these fields appear and can be verified.
    ...  All fields must be set as test variables in current test, only the file is given as an argument.
    [Arguments]  ${file}

    ${short_product_name}  Fetch From Left  ${PRODUCT_NAME}  ${SPACE}
    ${component_line}  Grep File  ${file}  inventoryUnitType: (${short_product_name}|${PRODUCT_NAME})?; serialNumber: ${SERIAL_NUMBER};
    ...  encoding_errors=replace  regexp=True
    Should Not Be Empty  ${component_line}  Component line didn't match. [NOK]
    ${category_matches}  Get Regexp Matches  ${component_line}  \\[CATEGORY: ${CATEGORY}\\]
    Should Not Be Empty  ${category_matches}  CATEGORY field didn't match. [NOK]
    ${scope_matches}  Get Regexp Matches  ${component_line}  \\[SCOPE: ${SCOPE}\\]
    Should Not Be Empty  ${scope_matches}  SCOPE field didn't match. [NOK]
    ${load_matches}  Get Regexp Matches  ${component_line}  \\[LOAD_NAME: ${SW_VERSION}\\]
    Should Not Be Empty  ${load_matches}  LOAD_NAME field didn't match. [NOK]
    ${reset_counter_matches}  Get Regexp Matches  ${component_line}  \\[RESET_COUNTER: ${RESET_COUNTER}\\]
    ${reset_counter_status}  Run Keyword And Return Status  Should Not Be Empty  ${reset_counter_matches}
    IF  ${reset_counter_status} == ${FALSE}  Set Test Restriction  Reset counter didn't match. [NOK]
    ${info_line}  Grep File  ${file}  INFO: ${INFO}  encoding_errors=replace  regexp=True
    Should not Be Empty  ${info_line}  Info line didn't match.[NOK]
    ${position_matches}  Get Regexp Matches  ${info_line}  unitPosition: ${UNIT_POSITION}\\]
    Should not Be Empty  ${position_matches}  Unit position field didn't match. [NOK]
    ${status}  Run Keyword And Return Status  Variable Should Exist  ${MINOR_INFO_LIST}
    IF  ${status}
      ${fields_status}  Run Keyword And Return Status  Verify Minor And Info List  ${file}
    ELSE
      ${fields_status}  Set Variable  ${FALSE}
    END
    IF  ${fields_status}  RETURN
    ${minor_matches}  Get Regexp Matches  ${info_line}  \\[MINOR: ${MINOR}\\]
    Should not Be Empty  ${minor_matches}  Minor field didn't match. [NOK]


Verify Minor And Info List
    [Documentation]  Verifies that the file contains expected [MINOR: x] [INFO: y] entries from MINOR_INFO_LIST.
    [Arguments]  ${file}

    FOR  ${item}  IN  @{MINOR_INFO_LIST}
        ${minor_info_line}  Grep File  ${file}  \\[MINOR: ${item}[minor]\\] \\[INFO: ${item}[info]  encoding_errors=replace  regexp=True
        Should Not Be Empty  ${minor_info_line}  Minor and info fields didn't match, should be: ${item}. [NOK]
    END


Get CPRI And ECPRI RMODS Uptime
    [Documentation]  Returns dictionary with CPRI/ECPRI rmods serial number and uptime.
    ...  KW can be used only with builds from 25R1 onwards

    Return From Keyword If  '${ENB_BRANCH}'!='SBTS00' and '${ENB_BRANCH}'<='SBTS24R3'
    ${rmods}    Get Parameters For All  RMOD
    ${cpri_ecpri_dictionary}  Create Dictionary
    FOR  ${rmod}  IN  @{rmods}
      Continue For Loop If  'CPRI' not in '${rmod}[l3Protocol]'
      ${rmod_uptime}  Get Rmod Measurements By Id  ${rmod}[id]  filter=uptime
      Set To Dictionary  ${cpri_ecpri_dictionary}  ${rmod}[serialNumber]  ${rmod_uptime}[uptime][seconds]
    END

    [Return]  ${cpri_ecpri_dictionary}


Check CPRI And ECPRI Did Not Reset
    [Documentation]  ${ru_initial_uptime} must be provided by Get CPRI And ECPRI RMODS Uptime as the initial time.
    ...  KW can be used only with builds from 24R3
    [Arguments]  ${ru_initial_uptime}

    Return From Keyword If  '${ENB_BRANCH}'!='SBTS00' and '${ENB_BRANCH}'<='SBTS24R2'
    ${ru_uptime}  Get CPRI And ECPRI RMODS Uptime
    FOR  ${rmod}  IN  @{ru_uptime}
      Run Keyword If  ${ru_uptime}[${rmod}]<${ru_initial_uptime}[${rmod}]
      ...  Fail  CPRI/ECPRI RMOD ${rmod} reset was detected.
    END


Check l3Protocol For Given RMOD Type
    [Documentation]  Verifies that all RMODs of the given radio type have the expected l3Protocol value.
    [Arguments]  ${radio_type}  ${l3_protocol}

    ${rmod_d_ns_list}  Get Ids For All  RMOD
    FOR  ${rmod_dn}  IN  @{rmod_d_ns_list}
         ${rmod_parameters}  coam.Get Parameters  ${rmod_dn}
         ${chosen_rmod}  Set Variable If  '${rmod_parameters}[productName]'=='${radio_type}'  ${rmod_parameters}
         Exit For Loop If  '${rmod_parameters}[productName]'=='${radio_type}'
    END
    ${status}  Run Keyword And Return Status  Should Match Regexp  ${chosen_rmod}[l3Protocol]  ${l3_protocol}

    [Return]  ${status}


Get Matching Lcr Ids String For All RAT Cells
    [Documentation]  Keyword will get all RAT cells from Get Parameter By Class keyword output.
    ...  For each cell LCR id will be saved. LCR IDs list will be sorted.
    ...  Based on LCR IDs, string for checking extra info will be constructed.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${cell_type}

    ${parameter_list}  Create List
    Append To List  ${parameter_list}  lcrId
    ${lncel_list}  Get Parameter By Class  class_name=${cell_type}  include_children=False  parameter_list=${parameter_list}
    ${lcr_ids}  Create List
    FOR  ${cell}  IN  @{lncel_list}
        Append To List  ${lcr_ids}  ${cell}[parameters][lcrId]
    END
    Sort List  ${lcr_ids}
    ${string}  Set Variable  ${EMPTY}
    ${sorted_lcrs_list}  Sort Lcr Ids list For Extra Info Field  ${lcr_ids}
    FOR  ${id}  IN  @{sorted_lcrs_list}
        ${string}  Catenate  SEPARATOR=,  ${string}  ${id}
    END
    ${string_lcr_ids}  Get Substring  ${string}  1

    [Return]  ${string_lcr_ids}


Sort Lcr Ids list For Extra Info Field
    [Documentation]  Keyword will sort lcr_ids based on internal logic used for constructing extra info field in fault signature.
    ...  Extra info field e.g : 'extraInfo': 'faulty_cells=LTE:0,1,10,2,3,4,5,6'
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${lcr_ids}

    ${beginning_with_0}  Create List
    ${beginning_with_1}  Create List
    ${beginning_with_2}  Create List
    ${beginning_with_3}  Create List
    ${beginning_with_4}  Create List
    ${beginning_with_5}  Create List
    ${beginning_with_6}  Create List
    ${beginning_with_7}  Create List
    ${beginning_with_8}  Create List
    ${beginning_with_9}  Create List
    FOR  ${id}  IN  @{lcr_ids}
        ${number}  Convert To String  ${id}
        ${reg_exp_0}  Run Keyword And Return Status
        ...  Should Start With  ${number}  0
        Run Keyword If  ${reg_exp_0}
        ...  Append To List  ${beginning_with_0}  ${number}
        ${reg_exp_1}  Run Keyword And Return Status
        ...  Should Start With  ${number}  1
        Run Keyword If  ${reg_exp_1}
        ...  Append To List  ${beginning_with_1}  ${number}
        ${reg_exp_2}  Run Keyword And Return Status
        ...  Should Start With  ${number}  2
        Run Keyword If  ${reg_exp_2}
        ...  Append To List  ${beginning_with_2}  ${number}
        ${reg_exp_3}  Run Keyword And Return Status
        ...  Should Start With  ${number}  3
        Run Keyword If  ${reg_exp_3}
        ...  Append To List  ${beginning_with_3}  ${number}
        ${reg_exp_4}  Run Keyword And Return Status
        ...  Should Start With  ${number}  4
        Run Keyword If  ${reg_exp_4}
        ...  Append To List  ${beginning_with_4}  ${number}
        ${reg_exp_5}  Run Keyword And Return Status
        ...  Should Start With  ${number}  5
        Run Keyword If  ${reg_exp_5}
        ...  Append To List  ${beginning_with_5}  ${number}
        ${reg_exp_6}  Run Keyword And Return Status
        ...  Should Start With  ${number}  6
        Run Keyword If  ${reg_exp_6}
        ...  Append To List  ${beginning_with_6}  ${number}
        ${reg_exp_7}  Run Keyword And Return Status
        ...  Should Start With  ${number}  7
        Run Keyword If  ${reg_exp_7}
        ...  Append To List  ${beginning_with_7}  ${number}
        ${reg_exp_8}  Run Keyword And Return Status
        ...  Should Start With  ${number}  8
        Run Keyword If  ${reg_exp_8}
        ...  Append To List  ${beginning_with_8}  ${number}
        ${reg_exp_9}  Run Keyword And Return Status
        ...  Should Start With  ${number}  9
        Run Keyword If  ${reg_exp_9}
        ...  Append To List  ${beginning_with_9}  ${number}
    END
    ${sorted_lcrs_list}  Combine Lists  ${beginning_with_0}  ${beginning_with_1}  ${beginning_with_2}  ${beginning_with_3}  ${beginning_with_4}
    ...  ${beginning_with_5}  ${beginning_with_6}  ${beginning_with_7}  ${beginning_with_8}  ${beginning_with_9}

    [Return]  ${sorted_lcrs_list}


Set Test Variables For Fault Signature In LTE CCplane crashes
    [Documentation]  Sets test variables (EXTRA_INFO, MINOR) for fault signature checks in LTE C-plane crashes.

    Set Test Variable  ${EXTRA_INFO}  faulty_cells=LTE:[0-9]+.*
    ${node_id}  Convert To Hex  ${ELEMENT}[nodeId]  prefix=0x
    ${low_node_id}  Convert To Lowercase  ${node_id}
    Set Test Variable  ${MINOR}  C_CPNODE ${low_node_id}
    ${smod_l_dn}  Fetch From Left  ${ELEMENT}[dist_name]  /SMOD_L-1
    ${smod_l_parameters}  Query Infomodel  get object ${smod_l_dn}/SMOD_L-1
    Set Test Variable  ${PRODUCT_NAME}  ${smod_l_parameters}[productName]
    Set Test Variable  ${PRODUCT_CODE}  ${smod_l_parameters}[productCode]
    Set Test Variable  ${SERIAL_NUMBER}  ${smod_l_parameters}[serialNumber]
    ${smod_r}  Query Infomodel  get object //SMOD_R-* is [serialNumber=${smod_l_parameters}[serialNumber]]
    Set Unit Position For Fault Signature  ${smod_r}[dist_name]
    Set Test Variable  ${EXPECTED_FAULT_ID}  ${FAULT_4383_RAT_AUTO_RST}[fault_id]
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${SCOPE}  LTE RAT
    Set Test Variable  ${INFO}  CCS supervised command exited
    Set Test Variable  ${RESET_COUNTER}  [0-9]+


Set Fault Signature Variables For WCDMA DSP Crash
    [Documentation]  Sets test variables for fault signature verification in WCDMA DSP crash scenarios.

    Log  Setting variables for fault signature.  console=true
    ${dsp_node_id}  Get Substring  ${NODE_ID}  0  5
    Set Test Variable  ${MINOR}   ${dsp_node_id}
    ${soc_l}  Fetch From Left  ${CORE_ID}[dist_name]  /DSP_L
    ${is_bbu}  Run Keyword And Return Status  Should Contain  ${soc_l}  BBU_L
    IF  ${is_bbu}
      ${module_l_dn}  Fetch From Left  ${soc_l}  /BBU_L
    ELSE
      ${module_l_dn}  Fetch From Left  ${soc_l}  /BOARD_L
    END
    ${is_bbmod}  Run Keyword And Return Status  Should Contain  ${module_l_dn}  BBMOD
    ${type}  Set Variable If  ${is_bbmod}  BBMOD  SMOD
    ${module_parameters}  coam.Get Parameters For  ${type}  ${module_l_dn}
    Set Test Variable  ${PRODUCT_NAME}  ${module_parameters}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${module_parameters}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${module_parameters}[productCode]
    ${module_r_dn}  Get Runtime Object Dist_name From Logical Object Dist_name  ${module_l_dn}
    Set Unit Position For Fault Signature  ${module_r_dn}
    Set Test Variable  ${EXPECTED_FAULT_ID}  ${FAULT_6707_RAT_AUTO_RST}[fault_id]
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=WCDMA:[0-9]+.*(gracefully_shutdown_cells:[0-9]+)?
    Set Test Variable  ${INFO}  .*FATAL EXCEPTION Nid:${MINOR}.*
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Set Test Variable  ${SCOPE}  WCDMA RAT


Get Alarm From List Of Alarms In WebEM
    [Documentation]  Keyword will return a given alarm from WebEM alarm history list.
    ...  Keyword will return alarm based on faultid, fault name, alarm id, alarm name, severity and notifier.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]
    ...  ${alarm_list}
    ...  ${fault_id}
    ...  ${fault_name}
    ...  ${alarm_id}
    ...  ${alarm_name}
    ...  ${severity}
    ...  ${filtering_time}
    ...  ${additional_severity}=${None}
    ...  ${notifier}=${None}

    FOR  ${alarm}  IN  @{alarm_list}
        IF  '${notifier}'=='${None}'
            ${check_alarm_notifier}  Set Variable  ${TRUE}
        ELSE
            ${check_alarm_notifier}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[notifier]  ${notifier}
        END
        ${check_alarm_severity}  Run Keyword And Return Status  Should Match Regexp  ${alarm}[severity]  (?i)(${severity}|${additional_severity})
        ${check_fault_id}  Run Keyword And Return Status  Should Be Equal As Integers  ${alarm}[faultId]  ${fault_id}
        ${check_fault_name}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultName]  ${fault_name}
        ${check_alarm_id}  Run Keyword And Return Status  Should Be Equal As Integers  ${alarm}[alarmId]  ${alarm_id}
        ${check_alarm_name}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[alarmName]  ${alarm_name}
        ${timestamp}  Fetch From Left  ${alarm}[btsObservationTime]  +
        ${time}  Convert Date  ${timestamp}
        ${alarm_condition}  Catenate  SEPARATOR=${SPACE}and${SPACE}
         ...  ${check_fault_id}
         ...  ${check_fault_name}
         ...  ${check_alarm_id}
         ...  ${check_alarm_name}
         ...  ${check_alarm_severity}
         ...  ${check_alarm_notifier}
         ...  '${time}'>'${filtering_time}'
         IF  ${alarm_condition}  RETURN  ${alarm}
    END


Compare Alarm Content Between WebEM And Netact
    [Documentation]  Keyword will compare alarm content between alarms in WebEM and Netact.
    ...  Keyword will check : additionalText1, additionalText2, additionalText3, additionalText5, alarmText, specificProblem, dn, liftedDN,
    ...  eventType, alarmTime and alarm severity.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${alarm_webem}  ${alarm_netact}

    ${alarmAttribute}  Get From Dictionary  ${alarm_webem}  alarmAttribute
    ${dict_affected_cells}  ${dict_faulty_cells}  ${dict_degraded_cells}  ${dict_path}  ${dict_serial_no}  ${dict_unitName}
    ...  Get Dictionary From alarmAttribute Field  ${alarmAttribute}

    Log  additionalText1 will be checked.  console=true
    ${status_systemTime}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm_webem}[systemTime]  Default System Time
    ${with_systemTime}  Catenate  SEPARATOR=;  ${alarm_webem}[faultName]  Default System Time
    ${string_additionalText1}  Set Variable If  ${status_systemTime}  ${with_systemTime}  ${alarm_webem}[faultName]
    Should Be Equal As Strings  ${string_additionalText1}  ${alarm_netact}[additionalText1]

    Log  additionalText2 will be checked.  console=true
    ${affected_cells_exists}  Run Keyword And Return Status  Should Not Be Empty  ${dict_affected_cells}
    ${degraded_cells_exists}  Run Keyword And Return Status  Should Not Be Empty  ${dict_degraded_cells}
    ${faulty_cells_exists}  Run Keyword And Return Status  Should Not Be Empty  ${dict_faulty_cells}

    IF  ${affected_cells_exists}
        ${string_affected_cells_attributeName}  Get From Dictionary  ${dict_affected_cells}  attributeName
        ${string_affected_cells_attributeValue}  Get From Dictionary  ${dict_affected_cells}  attributeValue
        ${string_affected_cells}  Set Variable  ${string_affected_cells_attributeName}=${string_affected_cells_attributeValue}
        Should Contain  ${alarm_netact}[additionalText2]  ${string_affected_cells}
    END

    IF  ${degraded_cells_exists}
        ${string_degraded_cells_attributeName}  Get From Dictionary  ${dict_degraded_cells}  attributeName
        ${string_degraded_cells_attributeValue}  Get From Dictionary  ${dict_degraded_cells}  attributeValue
        ${string_degraded_cells}  Set Variable  ${string_degraded_cells_attributeName}=${string_degraded_cells_attributeValue}
        Should Contain  ${alarm_netact}[additionalText2]  ${string_degraded_cells}
    END

    IF  ${faulty_cells_exists}
        ${string_faulty_cells_attributeName}  Get From Dictionary  ${dict_faulty_cells}  attributeName
        ${string_faulty_cells_attributeValue}  Get From Dictionary  ${dict_faulty_cells}  attributeValue
        ${string_faulty_cells}  Set Variable  ${string_faulty_cells_attributeName}=${string_faulty_cells_attributeValue}
        Should Contain  ${alarm_netact}[additionalText2]  ${string_faulty_cells}
    END

    Log  additionalText3 will be checked.  console=true
    ${alarm_fault_id}  Convert To String  ${alarm_webem}[faultId]
    ${alarm_additional_fault_id}  Convert To String  ${alarm_webem}[additionalFaultID]
    ${unit_name_exists}  Run Keyword And Return Status  Should Not Be Empty  ${dict_unitName}
    ${path_exists}  Run Keyword And Return Status  Should Not Be Empty  ${dict_path}
    Should Contain  ${alarm_netact}[additionalText3]  ${alarm_fault_id}
    IF  ${unit_name_exists}
        Should Contain  ${alarm_netact}[additionalText3]  ${dict_unitName}[attributeName]=${dict_unitName}[attributeValue]
    END
    IF  ${path_exists}
        Should Contain  ${alarm_netact}[additionalText3]  ${dict_path}[attributeName]=${dict_path}[attributeValue]
    END
    Should Contain  ${alarm_netact}[additionalText3]  additionalFaultID=${alarm_additional_fault_id}

    Log  additionalText5 will be checked.  console=true
    Compare fault signature between alarm WebEM and Netact  ${alarm_webem}[faultSignature]  ${alarm_netact}[additionalText5]

    Log  alarmText will be checked.  console=true
    Should Be Equal As Strings  ${alarm_webem}[alarmName]  ${alarm_netact}[alarmText]

    Log  specificProblem will be checked.  console=true
    Should Be Equal As Integers  ${alarm_webem}[alarmId]  ${alarm_netact}[specificProblem]

    Log  dn will be checked.  console=true
    ${string}  Fetch From Right  ${alarm_webem}[notifier]  ]${SPACE}
    ${dn}  Catenate  SEPARATOR=  PLMN-PLMN/  ${string}
    ${liftedDN}  Fetch From Left  ${dn}  /CABINET
    Should Be Equal As Strings  ${dn}  ${alarm_netact}[dn]

    Log  additionalAttributes liftedDN of alarm in Netact will be checked.  console=true
    ${dict_additionalAttributes}  Get From Dictionary  ${alarm_netact}  additionalAttributes
    Should Be Equal As Strings  ${liftedDN}  ${dict_additionalAttributes}[liftedDN]

    Log  Severity of alarm in Netact will be checked.  console=true
    ${alarm_additionalAttributes}  Get From Dictionary  ${alarm_netact}  additionalAttributes
    ${uppercase_severity}  Convert To Upper Case  ${alarm_webem}[severity]
    Should Be Equal As Strings  ${uppercase_severity}  ${alarm_additionalAttributes}[severity]

    Log  additionalAttributes originAlarmTime of alarm in Netact will be checked.  console=true
    ${string_originAlarmTime_1}  Format Webem Alarm Time To Netact Alarm Time  ${alarm_webem}[btsObservationTime]  format1
    Should Be Equal As Strings  ${string_originAlarmTime_1}  ${alarm_netact}[additionalAttributes][originAlarmTime]

    Log  alarmTime of alarm in Netact will be checked.  console=true
    ${string_originAlarmTime_2}  Format Webem Alarm Time To Netact Alarm Time  ${alarm_webem}[btsObservationTime]  format2
    Should Be Equal As Strings  ${string_originAlarmTime_2}  ${alarm_netact}[alarmTime]

    Log  eventType of alarm in Netact will be checked.  console=true
    ${string_event_type}  Convert To Upper Case  ${alarm_webem}[eventType]
    Should Be Equal As Strings  ${string_event_type}  ${alarm_netact}[eventType]


Get Dictionary From alarmAttribute Field
    [Documentation]  Keyword will return alarmAttribute fields from a given alarm from WebEM.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${alarm_attribute_list}

    ${dict_affected_cells}  Set Variable  ${EMPTY}
    ${dict_faulty_cells}  Set Variable  ${EMPTY}
    ${dict_degraded_cells}  Set Variable  ${EMPTY}
    ${dict_path}  Set Variable  ${EMPTY}
    ${dict_serial_no}  Set Variable  ${EMPTY}
    ${dict_unitName}  Set Variable  ${EMPTY}

    FOR  ${item}  IN  @{alarm_attribute_list}
         ${status_unitName}  Run keyword and return status  Dictionary should contain item  ${item}  attributeName  unitName
         ${dict_unitName}  Set variable if  ${status_unitName}  ${item}  ${dict_unitName}
         Continue for loop if   ${status_unitName}
         ${status_serial_no}  Run keyword and return status  Dictionary should contain item  ${item}  attributeName  serial_no
         ${dict_serial_no}  Set variable if  ${status_serial_no}  ${item}  ${dict_serial_no}
         Continue for loop if   ${status_serial_no}
         ${status_path}  Run keyword and return status  Dictionary should contain item  ${item}  attributeName  path
         ${dict_path}  Set variable if  ${status_path}  ${item}  ${dict_path}
         Continue for loop if   ${status_path}
         ${status_affected_cells}  Run keyword and return status  Dictionary should contain item  ${item}  attributeName  affected_cells
         ${dict_affected_cells}  Set variable if  ${status_affected_cells}  ${item}  ${dict_affected_cells}
         Continue for loop if  ${status_affected_cells}
         ${status_degraded_cells}  Run keyword and return status  Dictionary should contain item  ${item}  attributeName  degraded_cells
         ${dict_degraded_cells}  Set variable if  ${status_degraded_cells}  ${item}  ${dict_degraded_cells}
         Continue for loop if  ${status_degraded_cells}
         ${status_faulty_cells}  Run keyword and return status  Dictionary should contain item  ${item}  attributeName  faulty_cells
         ${dict_faulty_cells}  Set variable if  ${status_faulty_cells}  ${item}  ${dict_faulty_cells}
         Continue for loop if  ${status_faulty_cells}
    END

    RETURN  ${dict_affected_cells}  ${dict_faulty_cells}  ${dict_degraded_cells}  ${dict_path}  ${dict_serial_no}  ${dict_unitName}


Compare fault signature between alarm WebEM and Netact
    [Documentation]  Keyword will compare fault signature content between alarms in WebEM and Netact.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${faultSignature_WebEM}  ${faultSignature_Netact}

    ${match_category}  Set variable  (OAM_RESET|PLATFORM_RESET|ASSERT|EXCEPTION|TIMEOUT|POWER_OFF|SW_FAILURE|HW_FAILURE|UNKNOWN)
    ${match_scope}  Set variable  (Site|Board|Partial|DSP group|DSP group|SoC|BBPOOL|RFM|ESM|GSM RAT|WCDMA RAT|LTE RAT|NR RAT|vCU|vDU|Virtual Node)

     Run keyword if  '${faultSignature_WebEM}[category]'!='-'
     ...  Run Keywords
     ...  Should match regexp  ${faultSignature_Netact}  .*[CATEGORY: ${match_category}].*
     ...  AND
     ...  Should Contain  ${faultSignature_Netact}  [CATEGORY: ${faultSignature_WebEM}[category]]

     Run keyword if  '${faultSignature_WebEM}[component]'!='-'
     ...  Should Contain  ${faultSignature_Netact}  [COMPONENT: ${faultSignature_WebEM}[component]]

     ${string_date}  Format webem alarm time to netact alarm time  ${faultSignature_WebEM}[date]  format1
     Run keyword if  '${faultSignature_WebEM}[date]'!='-'
     ...  Should Contain  ${faultSignature_Netact}  [DATE: ${string_date}]

     Run keyword if  '${faultSignature_WebEM}[extraInfo]'!='-'
     ...  Should Contain  ${faultSignature_Netact}  [EXTRA_INFO: ${faultSignature_WebEM}[extraInfo]]

     Run keyword if  '${faultSignature_WebEM}[info]'!='-'
     ...  Should Contain  ${faultSignature_Netact}  [INFO: ${faultSignature_WebEM}[info]]

     Run keyword if  '${faultSignature_WebEM}[loadName]'!='-'
     ...  Should Contain  ${faultSignature_Netact}  [LOAD_NAME: ${faultSignature_WebEM}[loadName]]

     Run keyword if  '${faultSignature_WebEM}[minor]'!='-'
     ...  Should Contain  ${faultSignature_Netact}  [MINOR: ${faultSignature_WebEM}[minor]]

     Run keyword if  '${faultSignature_WebEM}[resetCounter]'!='-'
     ...  Should Contain  ${faultSignature_Netact}  [RESET_COUNTER: ${faultSignature_WebEM}[resetCounter]]

     Run keyword if  '${faultSignature_WebEM}[rfmCpri]'!='-'
     ...  Should Contain  ${faultSignature_Netact}  [RFM_CPRI: ${faultSignature_WebEM}[rfmCpri]]

     Run keyword if  '${faultSignature_WebEM}[rfmFpga]'!='-'
     ...  Should Contain  ${faultSignature_Netact}  [RFM_FPGA: ${faultSignature_WebEM}[rfmFpga]]

     Run keyword if  '${faultSignature_WebEM}[rfmGpp]'!='-'
     ...  Should Contain  ${faultSignature_Netact}  [RFM_GPP: ${faultSignature_WebEM}[rfmGpp]]

     Run keyword if  '${faultSignature_WebEM}[scope]'!='-'
     ...  Run Keywords
     ...  Should match regexp  ${faultSignature_Netact}  .*[SCOPE: ${match_scope}].*
     ...  AND
     ...  Should Contain  ${faultSignature_Netact}  [SCOPE: ${faultSignature_WebEM}[scope]]


Format Webem Alarm Time To Netact Alarm Time
    [Documentation]  Example of Netact formats:
    ...  'originAlarmTime': '2023-08-28T21:45:46+03:00' - FORMAT 1
    ...  'alarmTime': '2023-08-28T21:45:46.000+0300' - FORMAT 2
    [Arguments]  ${webem_date_time}  ${format}

    ${year}  Get substring  ${webem_date_time}  0  4
    ${month}  Get substring  ${webem_date_time}  4  6
    ${date}  Get substring  ${webem_date_time}  6  8
    ${hour}  Get substring  ${webem_date_time}  8  10
    ${minutes}  Get substring  ${webem_date_time}  10  12
    ${seconds}  Get substring  ${webem_date_time}  12  14
    ${time_zone}  Get substring  ${webem_date_time}  -4
    ${time_zone_hour}  Get substring  ${time_zone}  0  2
    ${time_zone_minutes}  Get substring  ${time_zone}  2  4
    ${string_1}  Catenate  SEPARATOR=
    ...  ${year}-
    ...  ${month}-
    ...  ${date}T
    ...  ${hour}:
    ...  ${minutes}:
    ...  ${seconds}+
    ...  ${time_zone_hour}:
    ...  ${time_zone_minutes}
    ${string_2}  Catenate  SEPARATOR=
    ...  ${year}-
    ...  ${month}-
    ...  ${date}T
    ...  ${hour}:
    ...  ${minutes}:
    ...  ${seconds}.000+
    ...  ${time_zone_hour}
    ...  ${time_zone_minutes}
    ${string}  Set variable if  '${format}'=='format1'
    ...  ${string_1}
    ...  ${string_2}

    [Return]  ${string}


Compare Alarms Between WebEM And Netact
    [Documentation]  Keyword will get given alarm from WebEM alarm history and Netact cleared alarms.
    ...  Keyword will compare alarms content between WebEM and Netact.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${test_alarm}  ${filtering_time_webem}  ${filtering_time_netact}

    Log  Compare Alarms Between WebEM And Netact.  console=true
    ${webem_historical_alarms}  coam.Get Historic Alarms
    Reverse List  ${webem_historical_alarms}
    ${alarm_in_webem}  Get Alarm From List Of Alarms In WebEM  ${webem_historical_alarms}  &{test_alarm}  filtering_time=${filtering_time_webem}
    ${time_to}  Get Current Date  time_zone=UTC  result_format=datetime
    ${netact_alarm_history}  netact.Get Cleared Alarms  dist_name=${MRBTS_DN}  time_from=${filtering_time_netact}  time_to=${time_to}
    ${alarm_in_netact}  Get Alarm From List Of Alarms In Netact  ${netact_alarm_history}  &{test_alarm}
    Compare Alarm Content Between WebEM And Netact  ${alarm_in_webem}  ${alarm_in_netact}


Create Maintenance Window
    [Documentation]  This keyword is designed to create a maintenance window for the current day,
    ...  based on the exact hour and minute when the test is executed.
    ...  At the end, the day is returned, as it will be used later in the 'Delete Maintenance Window' keyword.

    ${dict_days_of_week}  Create Dictionary  Monday=1  Tuesday=2  Wednesday=4  Thursday=8  Friday=16  Saturday=32  Sunday=64
    ${day_of_week}  Get Current Date  result_format=%A
    ${start_time}  Get BTS time in UTC format  %H:%M
    ${new_values}  Create Dictionary  daysOfWeek=${dict_days_of_week}[${day_of_week}]  gracefulCellShutdown=yes  inUse=true
    ...  startTime=${start_time}  windowDuration=30
    ${list_values}  Create List  ${new_values}
    coam.Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  maintenanceWindow  update  ${list_values}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=600
    Log  maintenanceWindow was changed to ${new_values}.  console=true
    Set Test Variable  ${DICT_DAYS_OF_WEEK}  ${dict_days_of_week}[${day_of_week}]


Delete Maintenance Window
    [Documentation]  This keyword is designed to delete the maintenance window for the current execution day.

    ${new_values}  Create Dictionary  gracefulCellShutdown=yes
    ${list_values}  Create List  ${new_values}
    coam.Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  maintenanceWindow  delete  ${list_values}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=600
    Log  maintenanceWindow was deleted.  console=true


Check Equality For Force Recovery Parameter
    [Documentation]  This keyword is created to handle the comparison between two values
    ...  in order to verify the FORCED_RECOVERY_INFO parameter from the InfoModel.
    [Arguments]  ${parameter_value_webem}  ${expected_value}  ${fail_message}

    IF  '${expected_value}' != '${EMPTY}'
        Should Be Equal  ${parameter_value_webem}  ${expected_value}  msg=${fail_message}
    END


Get Forced Recovery Parameter When Is Completed
    [Documentation]  This keyword is created to verify that the forcedRecoveryStatus field of the FORCED_RECOVERY_INFO
    ...  parameter from the InfoModel is set to Completed and then retrieve the entire FORCED_RECOVERY_INFO parameter.

    ${forced_recovery_object}  Query Infomodel  get list /MRBTS-1/RAT-1/FRI-*/FORCED_RECOVERY_INFO-*
    ${parameter_object}  Get From Dictionary  ${forced_recovery_object}[0]  forcedRecoveryStatus
    IF  '${parameter_object}'=='Completed'
        Log  forcedRecoveryStatus parameter is correctly completed.  console=true
    ELSE
        Fail  forcedRecoveryStatus parameter is not correctly completed.
    END

    RETURN  ${forced_recovery_object}


Verify Force Recovery Parameters
    [Documentation]  This keyword is created to verify the following sub-parameters of the FORCED_RECOVERY_INFO parameter
    ...  from the InfoModel: forcedRecoveryStatus, faultId, recoveryExecutionResult, resultAlreadySent, and status.
    ...  It also checks whether the maintenanceWindowResult from the Parameter Editor matches the recoveryExecutionResult from the InfoModel
    ...  and similarly checks if it matches the recoveryExecutionResult obtained from Netact.
    [Arguments]  ${parameters_values}
    ...  ${fault_dict}
    ...  ${recovery_execution_result}=${EMPTY}
    ...  ${forced_recovery_status}=${EMPTY}

    ${forced_recovery_status_webem}  Get From Dictionary  ${parameters_values}[0]  forcedRecoveryStatus
    ${fault_id_list}  Set Variable  ${parameters_values}[0][recoveryList]
    ${recovery_target_dns}  Get From Dictionary  ${parameters_values}[0][recoveryList][0]  recoveryTargetDNs
    ${recovery_execution_result_webem}  Get From Dictionary  ${parameters_values}[0][recoveryResult]  recoveryExecutionResult
    ${recovery_already_sent}  Get From Dictionary  ${parameters_values}[0][recoveryResult]  resultAlreadySent
    ${recovery_already_sent}  Convert To String  ${recovery_already_sent}
    ${recovery_result}  Get From Dictionary  ${parameters_values}[0][recoveryResult]  status

    IF  '${recovery_execution_result}'=='${EMPTY}'
        Check Equality For Force Recovery Parameter  ${forced_recovery_status_webem}  Completed  Forced Recovery Status did not matched.
    ELSE
        Check Equality For Force Recovery Parameter  ${forced_recovery_status_webem}  ${forced_recovery_status}
        ...  Forced Recovery Status did not matched.
    END
    FOR  ${fault_item}  IN  @{fault_id_list}
        ${fault_id}  Get From Dictionary  ${fault_item}  faultId
        ${status}  Run Keyword And Return Status  Check Equality For Force Recovery Parameter  ${fault_id}  ${fault_dict}[fault_id]
        ...  Fault id did not matched.
        Continue For Loop If  not(${status})
    END
    IF  '${recovery_execution_result}'!='${EMPTY}'
        Check Equality For Force Recovery Parameter  ${recovery_execution_result_webem}  ${recovery_execution_result}
        ...  Recovery Execution Result did not matched.
    ELSE
        ${rat_id_partial}  Fetch From Right  ${recovery_target_dns}[0]  MRBTS_R-
        ${rat_id}  Fetch From Right  ${rat_id_partial}  /
        ${string}  Replace String  ${rat_id}  _R  ${EMPTY}
        ${recovery_execution_result}  Set Variable  RAT recovery reset:MRBTS-${BTS_ID}/${string}
        Check Equality For Force Recovery Parameter  ${recovery_execution_result_webem}  ${recovery_execution_result}
        ...  Recovery Execution Result did not matched.
    END
    Check Equality For Force Recovery Parameter  ${recovery_already_sent}  True  Recovery Already Sent Result did not matched.
    Check Equality For Force Recovery Parameter  ${recovery_result}  Succeeded  Status did not matched.

    ${list}  Create List  maintenanceWindowResult
    Log  \nVerifying maintenance window result in Parameter Editor to be equal to recoveryExecutionResult from Info Model.  console=true
    ${maintenance_window_result_object}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1  ${list}
    ${actual_value_parameter_editor}  Set Variable  ${maintenance_window_result_object}[0][parameters][maintenanceWindowResult]
    Check Equality For Force Recovery Parameter  ${recovery_execution_result_webem}  ${actual_value_parameter_editor}
    ...  Maintenance Window Result did not matched.

    Log  \nVerifying maintenance window result from Netact to be equal to recoveryExecutionResult from Parameter Editor.  console=true
    Log  The configuration must be uploaded via CM Operations Manager, then the parameter can be searched in CM Editor.  console=true
    ${maintenance_window_result_netact}  Upload Configuration and Get Maintenance Window Result From Netact

    Check Equality For Force Recovery Parameter  ${actual_value_parameter_editor}  ${maintenance_window_result_netact}[maintenanceWindowResult]
    ...  Maintenance Window Result From Parameter Editor did not matched the one from Netact.


Upload Configuration and Get Maintenance Window Result From Netact
    [Documentation]  This KW is created to upload configuration from CM Operations Manager so that the latest changes are visible in CM Editor.
    ...  It returns the maintenance window result from Netact.

    ${parameters}  Create Dictionary  -lteHwContentInUse=${TRUE}  -sranBtsHwContentInUse=${TRUE}
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${BTS_ID}  parameters=${parameters}  verbose=True
    Sleep  10s  Wait for Actual Plan to be uploaded in CM Editor.
    ${actual_configuration}  netact.Get Actual Configuration
    ${managed_object}  netact.Get Managed Object  ${actual_configuration}  PLMN-PLMN/MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1
    Should Contain  ${managed_object.parameters}  maintenanceWindowResult
    ...  msg=The managed object from the given path in Netact does not contain maintenanceWindowResult.

    RETURN  ${managed_object.parameters}


Open Telnet Connection to OBSAI RMOD
    [Documentation]  This keyword opens telnet connection to OBSAI RMOD.
    [Arguments]  ${rmod_ip}  ${stored_role}  ${smod_side}

    Open Connection To Primary Core
    IF  '${stored_role}' == 'Idle'  Open Connection To Secondary Core
    SSHLibrary.Write  lxc-attach -n 0x${smod_side}018
    ${lxc_attach_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${lxc_attach_output}  FHNET  msg=lxc-attach command not working
    SSHLibrary.Write  telnet ${rmod_ip} 2323
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(>|\\$)
    ${rmod_connection_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${rmod_connection_output}  Connected to ${rmod_ip}  msg=Not able to connect on RMOD with ip:${rmod_ip}


Get Sfp Transceiver Identifier For Radio Module
    [Documentation]  Returns the SFP transceiver identifier(s) for the given radio module runtime DN.
    [Arguments]  ${rmod_r_dist_name}

    ${sfps_data}  Get Sfp Data
    ${sfps_for_rmod}  Create List
    FOR  ${sfp}  IN  @{sfps_data}[connected]
        IF  '${sfp}[source][id]'=='${rmod_r_dist_name}'  Append To List  ${sfps_for_rmod}  ${sfp}
    END
    ${transceiver_info}  Create List
    FOR  ${sfp}  IN  @{sfps_for_rmod}
        Append To List  ${transceiver_info}  ${sfp}[source][connector][sfp][transceiverIdentifier]
    END

    RETURN  ${transceiver_info}[0]


Collect Snapshot And Verify Counter Value By Date And Time Criteria
    [Documentation]  This keyword collects snapshot from SBTS and verifies given counter value.
    ...  Collect Snapshot And Verify Counter Value By Date And Time Criteria  counter_name=DSP_L1_AUTO_HEALING_BTS
    ...                                                                       counter_value=1
    ...                                                                       snapshot_file_name=Snapshot
    ...                                                                       pattern=.*RD.BTS.*\.xml\.gz
    ...                                                                       date=${date}
    ...                                                                       time=${time}
    [Arguments]
    ...  ${counter_name}
    ...  ${counter_value}
    ...  ${snapshot_file_name}
    ...  ${pattern}
    ...  ${date}
    ...  ${time}
    ...  ${second_pattern}=${EMPTY}
    ...  ${second_date}=${EMPTY}
    ...  ${second_time}=${EMPTY}
    [Timeout]  60 minutes

    Sleep  400s  Wait for file to be generated
    Wait Until Keyword Succeeds  40min  2min  Collect Snapshot  ${BTS_FILES}/${snapshot_file_name}.zip

    ${status}  ${file_paths}  Run Keyword And Ignore Error
    ...  Get Files From Snapshot By Name Pattern  ${BTS_FILES}/${snapshot_file_name}.zip  ${pattern}
    IF  '${status}' == 'FAIL'
        ${file_paths}  Get Files From Snapshot By Name Pattern  ${BTS_FILES}/${snapshot_file_name}.zip  ${second_pattern}
        ${file_matches_15min}  Create List
        FOR  ${file}  IN  @{file_paths}
             ${status}  Run Keyword And Return Status  Should Contain Any  ${file}  0000  1500  3000  4500
             IF  ${status}  Append To List  ${file_matches_15min}  ${file}
        END
        ${file_path}  Get First File Matching Date And After Time  ${file_matches_15min}  ${second_date}  ${second_time}
    ELSE
         ${file_path}  Get First File Matching Date And After Time  ${file_paths}  ${date}  ${time}
    END
    ${parameter_value}  Get Parameter Value From Xml In Archive  ${file_path}  ${counter_name}
    Should Be Equal As Strings  ${parameter_value}  ${counter_value}  msg=${counter_name} value is not correctly incremented.
    Log  ${counter_name} value is correct: ${counter_value}  console=true

    [Teardown]  Run Keyword And Ignore Error  coam.Snapshot Cancel


Verify Blackbox Reset File Content
    [Documentation]  This keyword searches from given regexp string in blackbox file.
    ...  Time filtering is used to filter entries bassed on test time.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${time_filtering}  ${regexp_syntax}

    ${content_blackbox_reset}  Get Blackbox Reset File
    ${matches_blackbox_file}  Get Regexp Matches  ${content_blackbox_reset}  ${regexp_syntax}
    ${syntax_matches}  Set Variable  0
    ${found_strings}  Create List
    FOR  ${match}  IN  @{matches_blackbox_file}
        ${date_time_match}  Get Regexp Matches  ${match}  [0-9]+-[0-9]+-[0-9]+[a-zA-Z]+[0-9]+:[0-9]+:[0-9]+
        ${entry_time}  Replace String  ${date_time_match}[0]  T  ${SPACE}
        IF  '''${entry_time}'''>'''${time_filtering}'''
            ${syntax_matches}  Evaluate  ${syntax_matches} + 1
            Append To List  ${found_strings}  ${match}
        ELSE
            ${syntax_matches}  Evaluate  ${syntax_matches} + 0
        END
    END
    IF  ${syntax_matches}!=0
        Log  Entry that match ${regexp_syntax} are present in blackbox_reset file. [OK]  console=true
        Log  Entries found:\n  console=true
        FOR  ${entry}  IN  @{found_strings}
            Log  \t${entry}  console=true
        END
    ELSE
        Fail  No entries that match ${regexp_syntax} - not found in blackbox_reset file. [NOK].
    END


Get Blackbox Reset File
    [Documentation]  This keyword collects blackbox reset file from SBTS.
    ...  *AUTHOR* laura.craciunel@nokia.com

    SSHLibrary.Open Connection  ${OAM_BTS_IP}  encoding=unicode_escape
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]
    SSHLibrary.Get File  /ffs/run/logs/lifetimedata/blackbox_reset  ${BTS_FILES}/blackbox_reset
    ${file_content}  OperatingSystem.Get File  ${BTS_FILES}/blackbox_reset

    RETURN  ${file_content}
    [Teardown]  SSHLibrary.Close Connection


Get SW Line For Specific RMOD
    [Documentation]  This keyword returns SW Line for given RMOD.
    [Arguments]  ${rmod_r_dn}

    ${rmod_parameters}  coam.Get Parameters  ${rmod_r_dn}
    ${active_sw_build}  Split String  ${rmod_parameters}[activeSwBuild]  .
    ${sw_line}  Set Variable  ${active_sw_build}[1]

    [Return]  ${sw_line}


Recover SBTS If Passive SW Is Active
    [Documentation]  This keyword needs to be used in combination with Get Active And Passive Partitions Ids keyword to set test variable
    ...  ACTIVE_PARTITION_ID at the beginning of test.

    Log  Recover SBTS if passive SW is active.  console=true
    ${after_active_partition_id}  ${after_passive_partition_id}  Get Active And Passive Partitions Ids
    IF  ${after_active_partition_id}!=${ACTIVE_PARTITION_ID}
        Rollback Software
        Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_TIMEOUT}
        coam.Reset Admin
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}s  30s  Check modules and cells
    END
    ${after_active_partition_id}  ${after_passive_partition_id}  Get Active And Passive Partitions Ids
    IF  ${after_active_partition_id}!=${ACTIVE_PARTITION_ID}  Fatal Error  Rollback to partition active at the beggining failled. Stop execution.


Trigger T3 Watchdog Recovery
    [Documentation]  Triggers T3 watchdog recovery via /dev/watchdog on the primary core.

    Log  Trigger T3 watchdog recovery.  console=true
    Open Connection To Primary Core
    SSHLibrary.Write  echo "disable" > /dev/watchdog
    SSHLibrary.Write  echo "setT3_1" > /dev/watchdog
    SSHLibrary.Write  echo "enable" > /dev/watchdog

    [Teardown]  SSHLibrary.Close Connection


Save Reset Data Output
    [Documentation]  Runs reset-data get on primary core and saves the output to BTS_FILES.

    Open Connection To Primary Core
    SSHLibrary.Execute Command  reset-data get > /tmp/reset_data_output.txt
    SSHLibrary.Get File  /tmp/reset_data_output.txt  ${BTS_FILES}/
    SSHLibrary.Write  rm /tmp/reset_data_output.txt

    [Teardown]  SSHLibrary.Close Connection


Maintenance Window Cleanup
    [Documentation]  Removes the maintenance window from FMCADM if it is currently set.

    Log  If the maintenance window is currently set, it must be deleted.  console=true
    ${list}  Create List  maintenanceWindow
    ${parameter_list}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  ${list}
    ${parameter_dict}  Set Variable  ${parameter_list}[0]
    ${status}  Run Keyword And Return Status  Dictionary Should Contain Key  ${parameter_dict}[parameters]  maintenanceWindow
    IF  ${status}
        Log  Maintenance Window Parameters is set and should be deleted.  console=true
        Delete Maintenance Window
    ELSE
        Log  Maintenance Window Parameters is not set.  console=true
    END


Check Fault 4003
    [Documentation]  Verifies fault 4003 for the given list of cell runtime DNs.
    [Arguments]  ${cells_runtime_dn}

    FOR  ${cell_dn}  IN  @{cells_runtime_dn}
        ${cell_id}  Replace String Using Regexp  ${cell_dn}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
        ${cell_id}  Remove String  ${cell_id}  _R
        ${cell_info}  coam.Get Cell Specific Info  ${cell_id}
        ${antl_list}  Get Failed Channels For Given Cell  ${cell_info}
        Check Fault 4003 On Each Channel   ${antl_list}  ${cell_id}  ${cell_info}[cellName]
    END


Get Failed Channels For Given Cell
    [Documentation]  Returns the list of failed channels (carriers) for the given cell info.
    [Arguments]  ${cell_info}

    ${failed_channels_m}  Create List
    FOR  ${carrier}  IN  @{cell_info}[carrierList]
        ${channel_parameters}  coam.Get Parameters  ${carrier}[id][internal]
        ${status_regexp}  Run Keyword And Return Status  Should Match Regexp  ${channel_parameters}[stateInfo][availabilityStatus]  Failed|failed
        IF  ${status_regexp}  Append To List  ${failed_channels_m}  ${carrier}
    END
    ${antl_list}  Create List
    FOR  ${channel}  IN  @{failed_channels_m}
        ${ref_channels_m}  coam.Get Parameters  ${channel}[id][internal]/REF-10
        ${rmod_antl_r}  Set Variable  ${ref_channels_m}[distName]
        ${rmod_antl_r}  Fetch From Right  ${rmod_antl_r}  RUNTIME_VIEW
        ${rmod_antl_r}  Get Substring  ${rmod_antl_r}  3
        Append To List  ${antl_list}  ${rmod_antl_r}
    END
    ${antl_list}  Remove Duplicates  ${antl_list}

    RETURN  ${antl_list}


Check Fault 4003 On Each Channel
    [Documentation]  Checks fault 4003 on each channel (ANTL) for the given cell.
    [Arguments]  ${antl_list}  ${cell_id}  ${cell_name}

    ${bts_name}  Get Bts Name
    ${string}  Set Variable  ${EMPTY}
    Sort List  ${antl_list}
    FOR  ${antl}  IN  @{antl_list}
        ${string}  Catenate  SEPARATOR=,${SPACE}  ${string}  ${antl}
    END
    ${string_antenna_lines}  Get Substring  ${string}  2
    IF  '${cell_name}'=='--'
        ${config_object_string}  Catenate  SEPARATOR=${SPACE}  [${bts_name}]  ${cell_id}
    ELSE
        ${config_object_string}  Catenate  SEPARATOR=  [${bts_name}]  [${cell_name}]  ${SPACE}${cell_id}
    END
    ${fault_4003_initial_params}  Get String With Alarm Parameters  ${FAULT_4003}
    ${fault_4003_params}  Catenate  ${fault_4003_initial_params},  configObjectName="${config_object_string}"
    ...  supplAlarmInfo=regex"(A|a)ffected (A|a)ntenna line(\\(s\\))?: ${string_antenna_lines}"
    Assert Alarm Active  parameters=${fault_4003_params}
    Log  Active alarm in WebEM : ${fault_4003_params}  console=true
    Wait Until Keyword Succeeds  60  10s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4003}  object_id=${cell_id}  additional_fault_id=${FAULT_4003}[fault_id]
    ...  suppl_info=(A|a)ffected (A|a)ntenna line(\\(s\\))?: ${string_antenna_lines}
    Log  Active alarm in Netact : ${fault_4003_params}  console=true



Get CPRI RMOD Info In A Dictionary
    [Documentation]
    ...  Returns a dictionary with CPRI RMOD information for a given RMOD type.
    ...  Searches FRM for the first RMOD whose product name matches the given type.
    ...  If cells_type is provided, only RMODs with that cell technology are considered.
    ...
    ...  Arguments:
    ...  - rmod_type: RMOD product name to match (e.g. AHLOA, AHFIG)
    ...  - cells_type: Optional cell technology filter (e.g. GNCEL, NRCEL). Default: empty
    ...
    ...  Returns: Dictionary with keys: dn, dn_nms, sn, cells, user, password, type.
    ...  Fails if no matching RMOD is found on the SBTS.
    ...
    ...  Example:
    ...  | ${rmod_info}= | Get CPRI RMOD Info In A Dictionary | AHLOA | NRCEL |
    ...
    ...  Author:
    ...  anna.beke@nokia.com
    [Arguments]  ${rmod_type}  ${cells_type}=${EMPTY}

    ${rmods_info}  Get Frm
    FOR  ${rmod}  IN  @{rmods_info}
        ${product_name_match}  Get Regexp Matches  ${rmod}[productName]  ${rmod_type}
        ${status}  Run Keyword And Return Status  Should Not Be Empty  ${product_name_match}
        IF  not ${status}  CONTINUE
        ${rmod_cells}  Get Cell Mapping By Module Id  ${rmod}[id][internal]
        IF  '${cells_type}'!='${EMPTY}'
            ${cells}  ${status_cells_type}  Verify Cells Technology On RMOD  ${rmod_cells}  ${cells_type}
            IF  not ${status_cells_type}  CONTINUE
        END
        ${sw_line}  Get SW Line For Specific RMOD  ${rmod}[id][internal]
        ${rmod_user}  ${rmod_password}  Get User And Password For RMOD  ${sw_line}  ${rmod_type}
        ${rmod_dn_nms}  Get Regexp Matches  ${rmod}[id][internal]  /EQM_R.*
        ${rmod_dn_nms}  Catenate  SEPARATOR=  PLMN-PLMN/  MRBTS-${BTS_ID}  ${rmod_dn_nms}[0]
        ${rmod_dictionary}  Create Dictionary  dn=${rmod}[id][internal]
        ...                                    dn_nms=${rmod_dn_nms}
        ...                                    sn=${rmod}[serialNumber]
        ...                                    cells=${rmod_cells}
        ...                                    user=${rmod_user}
        ...                                    password=${rmod_password}
        ...                                    type=${rmod_type}
        BREAK
    END
    Variable Should Exist  ${rmod_dictionary}  msg=RMOD ${rmod_type} not found on SBTS.

    RETURN  ${rmod_dictionary}


Get List Of OBSAI RMODs
    [Documentation]
    ...  Retrieves a list of OBSAI RMODs filtered by product name with cells mapping.
    ...
    ...  Arguments:
    ...  - obsai_rmod_type: Optional OBSAI RMOD product name to match. Default: empty (any Fxxx pattern)
    ...  - cells_type: Optional cell technology filter (e.g. GNCEL, NRCEL). Default: empty
    ...
    ...  Returns: List of dictionaries, each with keys: id, serialNumber, cells.
    ...  Fails if no OBSAI RMOD is found on the SBTS.
    ...
    ...  Example:
    ...  | ${rmods}= | Get List Of OBSAI RMODs | FABC | NRCEL |
    ...
    ...  Author:
    ...  anna.beke@nokia.com
    [Arguments]  ${obsai_rmod_type}=${EMPTY}  ${cells_type}=${EMPTY}

    ${rmods_info}  Get Frm
    ${rmods_list}  Create List
    FOR  ${rmod}  IN  @{rmods_info}
        IF  '${obsai_rmod_type}'!='${EMPTY}'
            ${status}  Run Keyword And Return Status  Should Contain  ${rmod}[productName]  ${obsai_rmod_type}
        ELSE
            ${product_name_match}  Get Regexp Matches  ${rmod}[productName]  ^F[A-Z]{3,4}
            ${status}  Run Keyword And Return Status  Should Not Be Empty  ${product_name_match}
        END
        IF  not ${status}  CONTINUE
        ${rmod_cells}  Get Cell Mapping By Module Id  ${rmod}[id][internal]
        IF  '${cells_type}'!='${EMPTY}'
            ${cells}  ${status_cells_type}  Verify Cells Technology On RMOD  ${rmod_cells}  ${cells_type}
            IF  not ${status_cells_type}  CONTINUE
        END
        ${rmod_dictionary}  Create Dictionary  id=${rmod}[id][internal]  serialNumber=${rmod}[serialNumber]  cells=${rmod_cells}
        Append To List  ${rmods_list}  ${rmod_dictionary}
    END
    Should Not Be Empty  ${rmods_list}  No OBSAI RMOD found on SBTS.

    RETURN  ${rmods_list}


Get Random OBSAI RMOD Info In A Dictionary
    [Documentation]
    ...  Picks a random OBSAI RMOD from the list and returns its data as a dictionary.
    ...  The chosen RMOD is removed from the input list so it is not selected again in subsequent calls.
    ...
    ...  Arguments:
    ...  - obsai_rmods_list: List of OBSAI RMOD dictionaries (e.g. from Get List Of OBSAI RMODs)
    ...
    ...  Returns: Dictionary with keys: dn, dn_nms, sn, cells.
    ...
    ...  Example:
    ...  | ${rmod_info}= | Get Random OBSAI RMOD Info In A Dictionary | ${obsai_rmods_list} |
    ...
    ...  Author:
    ...  anna.beke@nokia.com
    [Arguments]  ${obsai_rmods_list}

    ${chosen_rmod}  Evaluate  random.choice(${obsai_rmods_list})
    Remove Values From List  ${obsai_rmods_list}  ${chosen_rmod}
    Set Test Variable  ${OBSAI_RMODS_LIST}
    ${rmod_dn_nms}  Get Regexp Matches  ${chosen_rmod}[id]  /EQM_R.*
    ${rmod_dn_nms}  Catenate  SEPARATOR=  PLMN-PLMN/  MRBTS-${BTS_ID}  ${rmod_dn_nms}[0]
    ${rmod_dictionary}  Create Dictionary  dn=${chosen_rmod}[id]
    ...                                    dn_nms=${rmod_dn_nms}
    ...                                    sn=${chosen_rmod}[serialNumber]
    ...                                    cells=${chosen_rmod}[cells]

    RETURN  ${rmod_dictionary}


Trigger Fault On CPRI RMOD And Verify State
    [Documentation]
    ...  Triggers a fault on CPRI RMOD via SSH and verifies the fault state.
    ...  For runtime faults, waits 4 minutes after radio detection before triggering.
    ...  Verifies alarm in WebEM and Mantaray. For recovered state checks alarm cleared;
    ...  for degraded state verifies at least one cell degraded. Ensures RMOD returns online.
    ...
    ...  Arguments:
    ...  - fault_dictionary: Fault definition (fault_id, etc.)
    ...  - rmod_side: RMOD side
    ...  - rmod_stored_role: Stored role of the RMOD
    ...  - rmod_ip: RMOD IP address
    ...  - rmod_user: SSH user for RMOD
    ...  - rmod_password: SSH password for RMOD
    ...  - commands: List of SSH commands to trigger the fault
    ...  - rmod_dn: Distinguished name of the RMOD
    ...  - rmod_dn_nms: RMOD DN for NMS (Mantaray)
    ...  - rmod_cells: List of cells associated with the RMOD
    ...  - state: Expected state after fault (recovered or degraded)
    ...  - runtime: If True, wait 4 minutes before triggering. Default: False
    ...
    ...  Example:
    ...  | Trigger Fault On CPRI RMOD And Verify State | ${fault_dict} | ${side} | ${role} |
    ...  | ... | ${ip} | ${user} | ${pwd} | ${commands} | ${dn} | ${dn_nms} | ${cells} | recovered |
    ...
    ...  Author:
    ...  anna.beke@nokia.com
    [Arguments]
    ...  ${fault_dictionary}
    ...  ${rmod_side}
    ...  ${rmod_stored_role}
    ...  ${rmod_ip}
    ...  ${rmod_user}
    ...  ${rmod_password}
    ...  ${commands}
    ...  ${rmod_dn}
    ...  ${rmod_dn_nms}
    ...  ${rmod_cells}
    ...  ${state}
    ...  ${runtime}=${FALSE}

    IF  ${runtime}
        Log  Wait more than 4 minutes after radio detection...  console=true
        Sleep  242s  Wait at least 4 minutes to send fault.
    END
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime
    Log  \nTrigger fault ${fault_dictionary}[fault_id] with commands: ${commands}...  console=true
    Wait Until Keyword Succeeds  180s  10s
    ...  Open Connection To Radio Module  ${rmod_side}  ${rmod_stored_role}  ${rmod_ip}  ${rmod_user}  ${rmod_password}
    FOR  ${command}  IN  @{commands}
        SSHLibrary.Write  ${command}
        SSHLibrary.Read Until Prompt
        Sleep  2s  Wait to send next command.
    END
    ${fault_parameters}  Get String With Alarm Parameters  ${fault_dictionary}
    IF  '${state}'=='recovered'
        Assert Alarm Active  parameters=${fault_parameters}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${fault_dictionary} is active in WebEM.  console=true
        Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{fault_dictionary}
        ...                                                                               object_id=${rmod_dn_nms}
        ...                                                                               time_from=${time_from}
        Log  Fault ${fault_dictionary} reported & cleared from Mantaray.  console=true
    ELSE
        Assert Alarm Active  parameters=${fault_parameters}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${fault_dictionary} is active in WebEM.  console=true
        Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault  &{fault_dictionary}
        ...                                                          object_id=${rmod_dn_nms}
        Log  Fault ${fault_dictionary} is active in Mantaray.  console=true
        Verify That At Least One Cell Is Degraded  ${rmod_cells}
    END
    Assert  RMOD  ${rmod_dn}  operationalState=${ENABLED}  timeout=300s
    Log  RMOD(${rmod_dn}) is back online.  console=true

    [Teardown]  SSHLibrary.Close All Connections


Trigger Fault On OBSAI RMOD And Verify State
    [Documentation]
    ...  Triggers a fault on an OBSAI RMOD via SSH and verifies the fault state.
    ...  For runtime faults, waits 4 minutes after radio detection before triggering.
    ...  Verifies alarm in WebEM and Mantaray. For recovered state checks alarm cleared;
    ...  for degraded state verifies at least one cell degraded. Ensures RMOD returns online.
    ...
    ...  Arguments:
    ...  - fault_dictionary: Fault definition (fault_id, etc.)
    ...  - rmod_ip: RMOD IP address
    ...  - rmod_stored_role: Stored role of the RMOD
    ...  - rmod_side: RMOD side
    ...  - commands: List of SSH commands to trigger the fault
    ...  - rmod_dn: Distinguished name of the RMOD
    ...  - rmod_dn_nms: RMOD DN for NMS (Mantaray)
    ...  - rmod_cells: List of cells associated with the RMOD
    ...  - state: Expected state after fault (recovered or degraded)
    ...  - runtime: If True, wait 4 minutes before triggering. Default: False
    ...
    ...  Example:
    ...  | Trigger Fault On OBSAI RMOD And Verify State | ${fault_dict} | ${ip} | ${role} |
    ...  | ... | ${side} | ${commands} | ${dn} | ${dn_nms} | ${cells} | recovered |
    ...
    ...  Author:
    ...  anna.beke@nokia.com
    [Arguments]
    ...  ${fault_dictionary}
    ...  ${rmod_ip}
    ...  ${rmod_stored_role}
    ...  ${rmod_side}
    ...  ${commands}
    ...  ${rmod_dn}
    ...  ${rmod_dn_nms}
    ...  ${rmod_cells}
    ...  ${state}
    ...  ${runtime}=${FALSE}

    IF  ${runtime}
        Log  Wait more than 4 minutes after radio detection...  console=true
        Sleep  242s  Wait at least 4 minutes to send fault.
    END
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime
    Log  Trigger fault ${fault_dictionary}[fault_id] with commands: ${commands}...  console=true
    Wait Until Keyword Succeeds  180s  10s
    ...  Open Telnet Connection to OBSAI RMOD  ${rmod_ip}  ${rmod_stored_role}  ${rmod_side}
    FOR  ${command}  IN  @{commands}
        SSHLibrary.Write  ${command}
        SSHLibrary.Read Until Prompt
    END

    ${fault_parameters}  Get String With Alarm Parameters  ${fault_dictionary}
    IF  '${state}'=='recovered'
        Assert Alarm Active  parameters=${fault_parameters}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${fault_dictionary} is active in WebEM.  console=true
        Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{fault_dictionary}
        ...                                                                               object_id=${rmod_dn_nms}
        ...                                                                               time_from=${time_from}
        Log  Fault ${fault_dictionary} reported & cleared from Mantaray.  console=true
        Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${rmod_cells}  operationalState=${ENABLED}
    ELSE
        Assert Alarm Active  parameters=${fault_parameters}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${fault_dictionary} is active in WebEM.  console=true
        Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault  &{fault_dictionary}
        ...                                                          object_id=${rmod_dn_nms}
        Log  Fault ${fault_dictionary} is active in Mantaray.  console=true
        Verify That At Least One Cell Is Degraded  ${rmod_cells}
    END
    Assert  RMOD  ${rmod_dn}  operationalState=${ENABLED}  timeout=300s
    Log  RMOD(${rmod_dn}) is back online.  console=true

    [Teardown]  SSHLibrary.Close All Connections


Update RMOD Side IP And Stored Role By Serial Number
    [Documentation]
    ...  Refreshes side, ip and stored_role in a RMOD dictionary after a reset.
    ...  These values can change after reset. Updates the dictionary in place.
    ...
    ...  Arguments:
    ...  - rmod_data: RMOD dictionary (from Get Random OBSAI RMOD Info In A Dictionary or Get CPRI RMOD Info In A Dictionary)
    ...
    ...  Example:
    ...  | Update RMOD Side IP And Stored Role By Serial Number | ${rmod_data} |
    ...
    ...  Author:
    ...  anna.beke@nokia.com
    [Arguments]  ${rmod_data}

    Log  Refreshing network info for RMOD ${rmod_data}[dn] after reset...  console=true
    ${rmod_side}  ${rmod_ip}  ${rmod_stored_role}  Find RMOD Ip By Serial Number  ${rmod_data}[sn]
    Set To Dictionary  ${rmod_data}  side=${rmod_side}  ip=${rmod_ip}  stored_role=${rmod_stored_role}
    Log  Updated values - side: ${rmod_side}, ip: ${rmod_ip}, stored_role: ${rmod_stored_role}  console=true


Perform RMOD Reset
    [Documentation]
    ...  Performs RMOD reset and verifies operational state.
    ...  Resets the RMOD unit and waits for it to become operational.
    ...  For branches < 26R1, also verifies DISABLED state before ENABLED.
    ...
    ...  Arguments:
    ...  - rmod_data: RMOD dictionary (from Get Random OBSAI RMOD Info In A Dictionary or Get CPRI RMOD Info In A Dictionary)
    ...
    ...  Example:
    ...  | Perform RMOD Reset | ${rmod_data} |
    ...
    ...  Author:
    ...  anna.beke@nokia.com
    [Arguments]  ${rmod_data}

    coam.Reset Unit  ${rmod_data}[dn]  timeout=300
    IF  ${ENB_BRANCH}<'SBTS26R1'  Assert  RMOD  ${rmod_data}[dn]  operationalState=${DISABLED}  timeout=300s
    Assert  RMOD  ${rmod_data}[dn]  operationalState=${ENABLED}  timeout=300s
    Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${rmod_data}[cells]  operationalState=${ENABLED}


Check If Test Runs Only On Baseband ABIA With LTE Cells
    [Documentation]  This keyword verifies that test case is run on baseband ABIA with LTE cells mapped and useFullCapacity is set to false.
    ...   The keyword requires the BBMOD_LIST and ACCEPTED_CELLS_LIST variables to be defined either within the *** Variables *** section
    ...   or by assigning values using Set Test Variable within the Robot file.

    ${bbmod_abia}  Create List  ABIA
    ${status_abia}  Run Keyword And Return Status  Lists Should Be Equal  ${BBMOD_LIST}  ${bbmod_abia}
    ${lte_list}  Create List  LTE
    ${status_lte}  Run Keyword And Return Status  Lists Should Be Equal  ${ACCEPTED_CELLS_LIST}  ${lte_list}
    IF  ${status_abia}
        ${status_use_full_capacity}  Check If UseFullCapacity Value False On ABIA
    ELSE
        ${status_use_full_capacity}  Set Variable  ${FALSE}
    END
    IF  ${status_abia} and ${status_lte} and ${status_use_full_capacity}  RETURN  ${TRUE}

    RETURN  ${FALSE}


Check If UseFullCapacity Value False On ABIA
    [Documentation]  Returns True if the first BBMOD (ABIA) has fullCapacityInUse set to No.

    ${bbmods_list}  Get Fbb Info
    FOR  ${bbmod}  IN  @{bbmods_list}
        IF  '${bbmod}[fullCapacityInUse]'=='No' and '${bbmod}[serialNumber]'=='${BBMODS_SN}[0]'  RETURN  ${TRUE}
    END

    RETURN  ${FALSE}


Check If Fault 1868 Was Raised Throughout Baseband Recovery
    [Documentation]  This keyword verifies that fault 1868 was raised throughout baseband recovery.
    ...  Keyword checks if fault 1868 occurred and cleared on LTE cells from ABIA within two minutes following an ABIA baseband reset.
    ...  The time difference is determined by subtracting the clearedTime of fault 1868 from the btsObservationTime of the baseband fault.
    ...  If this calculated time difference is less than 120 seconds, the presence of fault 1868 is considered acceptable.
    ...  Before using this keyword in a Robot file, STATUS_BASEBAND variables must be assigned using Set Test Variable.
    [Arguments]  ${bbmod_reset_fault}  ${start_time_webem}  ${start_time_netact}

    ${webem_alarm_history}  coam.Get Historic Alarms
    Reverse List  ${webem_alarm_history}
    ${fault_bbmod_webem}  Get Alarm From List Of Alarms In WebEM  ${webem_alarm_history}  &{bbmod_reset_fault}  filtering_time=${start_time_webem}
    ${fault_1868_webem}  Get Alarm From List Of Alarms In WebEM  ${webem_alarm_history}  &{FAULT_1868_CRITICAL}  filtering_time=${start_time_webem}
    ${status_fault_1868}  Run Keyword And Return Status  Should Not Be Equal As Strings  ${fault_1868_webem}  ${None}
    IF  ${status_fault_1868}
        ${time_difference}  Get Time Difference Between Two Alarms  first_alarm=${fault_bbmod_webem}  second_alarm=${fault_1868_webem}
        ...  2nd_time_condition=clearedTime
        IF  ${STATUS_BASEBAND}
            IF  ${time_difference}<120
                Log  Fault 1868 found in history. Time difference between fault and BBMOD reset is under 120s: ${time_difference}s.  console=true
                Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1868_CRITICAL}
                ...  time_from=${start_time_netact}  additional_fault_id=${FAULT_1868_CRITICAL}[fault_id]
                Log  Fault ${FAULT_1868_CRITICAL} appeared & cleared from NetAct.  console=true
            ELSE
                Fail  Fault 1868 found in history. Time difference between fault and BBMOD reset is greater 120s: ${time_difference}s.
            END
        ELSE
            Fail  Fault 1868 found in alarm history.
        END
    ELSE
        Log  Fault 1868 not found in alarm history.  console=true
    END


Get Time Difference Between Two Alarms
    [Documentation]
    ...  *AUTHOR* laura.craciunel@nokia.com
    ...
    ...  Calculates the time difference in seconds between two alarms based on a specified timestamp field.
    ...
    ...  Extracts the timestamp value identified by ``${1st_time_condition}`` from ``${first_alarm}``
    ...  and the timestamp value identified by ``${2nd_time_condition}`` from ``${second_alarm}``,
    ...  then returns the difference ``second_alarm_time - first_alarm_time`` as an integer number of seconds.
    ...  Timestamps are expected to contain a ``+`` character (timezone offset); only the part before it is parsed.
    ...
    ...  *Arguments*
    ...  - ``${first_alarm}``        - Dictionary representing the first alarm (e.g. from a NetAct alarm query).
    ...  - ``${second_alarm}``       - Dictionary representing the second alarm.
    ...  - ``${1st_time_condition}`` - Key used to retrieve the timestamp from ``${first_alarm}``. Defaults to ``btsObservationTime``.
    ...  - ``${2nd_time_condition}`` - Key used to retrieve the timestamp from ``${second_alarm}``. Defaults to ``btsObservationTime``.
    ...
    ...  *Returns*
    ...  Integer number of seconds between the two alarm timestamps (``${second_alarm}`` time minus ``${first_alarm}`` time).
    ...  A positive value means ``${second_alarm}`` occurred after ``${first_alarm}``.
    ...
    ...  *Example*
    ...  | ${diff}= | Get Time Difference Between Two Alarms | ${alarm1} | ${alarm2} |
    ...  | ${diff}= | Get Time Difference Between Two Alarms | ${alarm1} | ${alarm2} | alarmTime | alarmTime |
    [Arguments]
    ...  ${first_alarm}
    ...  ${second_alarm}
    ...  ${1st_time_condition}=btsObservationTime
    ...  ${2nd_time_condition}=btsObservationTime

    ${1st_timestamp}  Fetch From Left  ${first_alarm}[${1st_time_condition}]  +
    ${1st_time}  Convert Date  ${1st_timestamp}
    ${2nd_timestamp}  Fetch From Left  ${second_alarm}[${2nd_time_condition}]  +
    ${2nd_time}  Convert Date  ${2nd_timestamp}
    Log  ${1st_time_condition} for fault ${first_alarm}[faultId]: ${1st_time}  console=true
    Log  ${2nd_time_condition} for fault ${second_alarm}[faultId]: ${2nd_time}  console=true
    ${time_difference}  Subtract Date From Date  ${2nd_time}  ${1st_time}  number
    ${time_difference}  Convert To Integer  ${time_difference}

    RETURN  ${time_difference}


Crash Process With Sigstop
    [Documentation]
    ...  *AUTHOR* laura.craciunel@nokia.com
    ...
    ...  Sends a SIGSTOP signal to a randomly selected instance of a process running on the system.
    ...
    ...  *Arguments:*
    ...  - ``name``: (Mandatory) The 4-character process name to target (e.g., CPUE).
    ...  - ``open_sc_connection``: (Optional) Boolean flag to open connection to secondary core.
    ...    Default is ${FALSE}.
    ...  - ``soc``: (Optional) SOC identifier for additional connection. Default is ${EMPTY}.
    ...
    ...  *Returns:* None
    ...
    ...  *Example:*
    ...  | Crash Process With Sigstop | CPUE |
    ...  | Crash Process With Sigstop | UPUE | open_sc_connection=${TRUE} |
    [Arguments]
    ...  ${name}
    ...  ${open_sc_connection}=${FALSE}
    ...  ${soc}=${EMPTY}

    Log  Crash ${name} process using SIGSTOP.  console=true
    ${first_two}  Get Substring  ${name}  0  2
    ${last_two}  Get Substring  ${name}  2  4
    ${grep_string}  Convert To Lower Case  ${first_two}_${last_two}
    Open Connection To Primary Core
    IF  ${open_sc_connection}  Open Connection To Secondary Core
    IF  "${soc}"!="${EMPTY}"  Open Connection To SOC  ${soc}  0
    SSHLibrary.Write  ps -elf | grep ${grep_string}
    ${output}  SSHLibrary.Read Until Prompt
    ${lines}  Get Lines Matching Regexp  ${output}  [0-9].*\/opt\/nokia\/SS_CPLANE\/.*${grep_string}.*

    ${root}  Get Regexp Matches  ${lines}  root *[0-9]*
    ${process_id}  Evaluate  random.choice(${root})  random
    ${id}  Get Regexp Matches  ${process_id}  [0-9]+
    SSHLibrary.Write  kill -s SIGSTOP ${id}[0]
    SSHLibrary.Read Until Prompt

    [Teardown]  SSHLibrary.Close Connection