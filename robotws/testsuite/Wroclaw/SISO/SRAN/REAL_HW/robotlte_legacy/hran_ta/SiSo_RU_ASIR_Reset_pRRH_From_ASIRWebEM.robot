*** Settings ***
Documentation
...    Author:        przemyslaw.kempa@nokia.com
...    Maintainer:    Przemysław Kempa

Resource    ../tc_scenarios.robot
Resource    resources/ca_Recovery_link_break.robot
#Resource    ../SiSo_L3_Call.robot
Library     taf.sbts.oam.sc.rest   WITH NAME  rest


*** Variables ***
${SISO_L3_CALL}          False

*** Keywords ***
TC_SiSo_RU_ASIR_Reset_pRRH_From_ASIRWebEM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-28933
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this scenario is to validate Reset ASiR PRRHs by ASiR WebEM
    ...  We can provide S/N of tested pRRH or test all of them as default
    ...  Optional variable in cfg to perform test
    ...  e.g.
    ...  pRRH=NH230800640
    ...
    ...  *** Test Variable For L3 Call ***
    ...  ${SISO_L3_CALL}             False  #default value for L3 call is False, set test variable as True to perform test with L3 call
    ...  ${CELLS_YAML_PATH}                 #mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
    ...
    ...  *****************
    ...  History of change
    ...  *****************
    ...

    Set Tags	CA-CM    AUTHOR-przemyslaw.kempa@nokia.com    MAINTAINER-przemyslaw.kempa@nokia.com
    ...		    GROUP_IN_CHARGE- MN RAN Pz 4 WRO 8     PHASE-CRT  FEATURE-CB00
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute Recommissioning On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
    FOR  ${node}  IN  @{cfg['active_bts_list']}
      Step 1: ASIR Reset pRRH From ASIRWebEM  alias=${node}
      Step 2: Check States After pRRH restored  alias=${node}
    END
  [Teardown]    Common Test Teardown


Step 1: ASIR Reset pRRH From ASIRWebEM
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  === Step 1: ASIR Reset pRRH From ASIRWebEM ===  console=${TRUE}
    Asir Check Active Alarms   ${alias}
    ${antmod_dict}  Asir Get All Antmods Info  alias=${alias}
    ${all_antmod_list}  Get Dictionary Keys  ${antmod_dict}
    ${antmod_status}   Run Keyword And Return Status  Variable Should Exist  ${cfg.pRRH}
    ${provided_antmod}  Run Keyword If  ${antmod_status}  Changing Provided Serial Number To ANTMOD Distname  ${antmod_dict}  ${all_antmod_list}
    ${antmod_list}  Set Variable If  ${antmod_status}  ${provided_antmod}  ${all_antmod_list}
    Set test variable  ${ANTMOD_LIST}  ${antmod_list}
    FOR  ${antmod}  IN  @{ANTMOD_LIST}
        Asir Reset Unit  ASI-1/${antmod}  alias=${alias}
        ${affected_cells_list}  Get From Dictionary  ${antmod_dict['${antmod}']}  cells_list_cfg
        Adding Allowed Alarms  ${affected_cells_list}
    END

Step 2: Check States After pRRH restored
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  === Step 2: Check States After pRRH restored ===  console=${TRUE}
    ${node}  Fetch from right  ${alias}  _
    Verify BTS State  ${node}
    Verify Alarms  ${alias}
    Asir Check Active Alarms  ${alias}
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For All Cells  ${cfg['test_logs_path']}  ${alias}
    ...    ELSE  Log To Console  L3 Call skipped  console=True

Changing Provided Serial Number To ANTMOD Distname
    [Arguments]  ${antmod_dict}  ${all_antmod_list}
    ${provided_antmod}  Create List
    FOR  ${antmod}  IN  @{all_antmod_list}
        Run Keyword If  "${antmod_dict['${antmod}']['serial_number_pRRH']}"=="${cfg.pRRH}"  Append To List  ${provided_antmod}  ${antmod}
        Exit For Loop If  "${antmod_dict['${antmod}']['serial_number_pRRH']}"=="${cfg.pRRH}"
    END
    [Return]  ${provided_antmod}

Adding Allowed Alarms
    [Arguments]  ${cells_list}
    FOR  ${cell_cfg_dn}  IN  @{cells_list}
        Append To List  ${GLO_ADMIN_ALLOWED_ALARMS}  faultId=4479, severity=Critical, configObjectName=regex".*${cell_cfg_dn}"
    END
