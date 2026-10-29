*** Settings ***
Library           ute_admin_infomodel
Library           Collections

*** Variables ***

*** Keywords ***

Infomodel Get Passive SW Version
  [Arguments]    ${module}=MSM  ${im_param}=passiveSoftwareVersion  ${alias}=default
  [Documentation]
  ...  Return passive software version
  ...  For more details, see documentation for `Infomodel Get Active SW Version`.
  ...
  ...  *PARAMETERS*
  ...   | =Parameter=       | =Man.= | =Description=                                                            | =Default=               |
  ...   | `module`          | no     | Determines from which SMOD the SW Version is obtained (MSM, ESM, all).   | MSM                     |
  ...   | 'im_param'        | no     | Determines which parameter should be taken to read passive sw version    | passiveSoftwareVersion  |
  ...   | `alias`           | no     | Determines alias in connection to infomodel                              | default                 |
  ...
  ...  *RETURN VALUE*
  ...  - Passive SW version
  ...
  ...    *AUTHOR*
  ...    andrzej.cichon@nokia.com
  ${sw_version}=    _Get SW Version For SMOD    module=${module}    im_param=${im_param}  alias=${alias}
  [Return]    ${sw_version}

_Get SW Version For SMOD
    [Arguments]    ${module}=MSM    ${im_param}=activeSoftwareVersion  ${alias}=default
    ${working_modes}=    Create Dictionary    MSM=Active    ESM=Idle    all=Active

    ${mode}=    Get From Dictionary    ${working_modes}    ${module}

    ${swm_objs}  ute_admin_infomodel.Query Infomodel  get list //RAT-1/SWM-* is [workingMode=${mode}]  allow_negative_result=${True}  alias=${alias}
    Return From Keyword If    not ${swm_objs}    ${EMPTY}

    ${sw_versions}=    Create List

    FOR    ${swm_obj}    IN    @{swm_objs}
        ${bts_l_dn}=    Set Variable    ${swm_obj.hardwareViewDNs[0]}
        ${bts_conf_obj}=    ute_admin_infomodel.Query Infomodel    get object ${bts_l_dn}/BTS_CONF-1  alias=${alias}
        ${sw_version}=    Get From Dictionary    ${bts_conf_obj}    ${im_param}
        Append To List    ${sw_versions}    ${sw_version}
    END
    Return From Keyword If    '${module}'=='all'    ${sw_versions}  # return the whole list
    [Return]    ${sw_versions[0]}

Get SM variant
 	[Documentation]
    ...  Return list of System Module variants in use. First is master second (if exist) slave
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jakub.kokoszka@nokia.com
    ...  | **Released with version:** -
    ...
	${sm_variant}=  Create list
	${sm_variant_list}=  Get SM variant with full name
	FOR  ${sm}  IN  @{sm_variant_list}
	    ${match}  ${group}=  Should match regexp  ${sm}  (FSMF|FSIH|ASIA|ASIB|ASIAB)
	    Append To List  ${sm_variant}  ${match}
	END
	[Return]  ${sm_variant}

Get SM variant with full name
 	[Documentation]
    ...  Return list of System Module variants in use with full name. First is master second (if exist) slave
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** -
    ...
	${sm_variant}=  Create list
	${status}  ${sm_primary}=  Run keyword and ignore error  ute_admin_infomodel.Query Infomodel  get object //EQM_R-*//SMOD_R-* is [activeRole=empty]
    Run keyword if  '${status}'=='PASS'  Run keywords
    ...  Append To List  ${sm_variant}  ${sm_primary}[productName]
    ...  AND             Return from keyword  ${sm_variant}

 	${sm_primary}=      ute_admin_infomodel.Query Infomodel  get object //EQM_R-*//SMOD_R-* is [activeRole=Primary]
    ${sm_secondary}=    ute_admin_infomodel.Query Infomodel  get object //EQM_R-*//SMOD_R-* is [activeRole=Secondary]
 	Append To List  ${sm_variant}  ${sm_primary}[productName]  ${sm_secondary}[productName]
 	Log  SM variant: ${sm_variant}  console=${True}
	[Return]  ${sm_variant}

Infomodel Get Objects Parameter
  [Arguments]  ${objects_dist_name}  ${parameter}  ${allow_negative_result}=False
  [Documentation]
  ...  KW for obtaining list of values of one specified parameter for all InfoModel objects matching 'objects_dist_name'
  ...
  ...  *Author*: Tomasz Filipek
  ...
  ...  | Parameter             | Man. | Description |
  ...  | objects_dist_name     | Yes  | Objects dist_name complies with query_infomodel syntax |
  ...  | parameter             | Yes  | Parameters name |
  ...  | allow_negative_result | No   | Allow False to be returned instead of InfoModelQueryTimeoutException |
  ...
  ...  *RETURN*
  ...  | Parameter        | Description              |
  ...  | parameter_values | List of parameter values |
  ...
  ...  *EXAMPLE*
  ...  | ${parameter_values}= | Infomodel Get Objects Parameter | //EQM_L-1//SMOD_L-* | serialNumber

  ${objects}=  ute_admin_infomodel.Query Infomodel  get list ${objects_dist_name}  allow_negative_result=${allow_negative_result}
  ${parameter_values}=  Create List
  FOR  ${object}  IN  @{objects}
      Append To List  ${parameter_values}  ${object['${parameter}']}
  END
  [Return]  ${parameter_values}
