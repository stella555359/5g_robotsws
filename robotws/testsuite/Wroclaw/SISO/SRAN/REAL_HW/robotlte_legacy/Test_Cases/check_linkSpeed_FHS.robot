*** Settings ***
Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Library  XML  use_lxml=${TRUE}


*** Variables ***

*** Keywords ***
Execute Check Link Speed Under FHS On Every Node
  [Documentation]
  ...  Description:
  ...  Check if 'LinkSpeed' parameter for CABLINK BBMOD-FHS-RMODS on BTS is consistent with value indicated in the SCF file
  ...  'LinkSpeed' parameter value is required for the tested CABLINKS.
  ...
  ...  |  **Author:**  daria.wronska@nokia.com
  ...  |  **Maintainer:**  daria.wronska@nokia.com
  ...
  ${btsId_list}  Create List
  ${btsId_list}  Set Variable  ${cfg.active_bts_list}
  FOR  ${bts_id}  IN  @{btsId_list}
    Set Test Variable  ${BTS_ID}  ${bts_id}
#  Reset Site  connection=${BTS_ID}
#  Verify Multi BTS State
#  Verify Alarms On All Nodes
    Checking Link Speed Under FHS
  END

Checking Link Speed Under FHS
  ${cablinkConf_linkSpeed_dict}=  Link Speed SCF
  Link Speed BTS  ${cablinkConf_linkSpeed_dict}

Link Speed BTS
  [Arguments]  ${cablinkConf_linkSpeed_dict}
  [Documentation]
  ...  Description:
  ...  Creates list of LinkSpeed parameters for cablinks between BBMOD-FHS-RMODS on current BTS config.
  ...
  ...  |  **Author:**  daria.wronska@nokia.com
  ...  |  **Maintainer:**  daria.wronska@nokia.com
  ...
  ...  Arguments:
  ...  +----------------------------+-------+------------------------------------------------------------------------+
  ...  | Return  | Man.  | Description  |
  ...  +====================+=======+=======+========================================================================+
  ...  | cablinkConf_linkSpeed_dict | Yes  | Dictionary keys contains distName of cablink configuration par.  |
  ...  |  |  | Dictionary values contains  values 'linkSpeed' parameter  |
  ...  +----------------------------+-------+------------------------------------------------------------------------+

  ${scf_bts_path}=  admin.Get Current SCF File  ${cfg.test_logs_path}  SCF_current_BTS.xml  connection=${BTS_ID}
  ...  export_type=configurationAndRuntimeObjects
  FOR  ${distname_conf}  IN  @{cablinkConf_linkSpeed_dict.keys()}
    ${class_configDN}=  Set Variable  contains(@class, "CABLINK_R") and p[contains(@name, "configDN")
    ${linkspeed_bts_list}=
    ...  Evaluate Xpath  ${scf_bts_path}
    ...  .//managedObject[${class_configDN} and contains(text(), "${distname_conf}")]]/p[@name="linkSpeed"]/text()
    Checking Values Are Equal  ${cablinkConf_linkSpeed_dict}  ${distname_conf}  ${linkspeed_bts_list}
  END

Checking Values Are Equal
  [Arguments]  ${cablinkConf_linkSpeed_dict}  ${distname_conf}  ${linkspeed_bts_list}
  [Documentation]
  ...  Description:
  ...  Comparison of value 'linkSpeed' parameter on BTS and scf, for cablinks BBMOD-FHS-RMODS.
  ...
  ...  |  **Author:**  daria.wronska@nokia.com
  ...  |  **Maintainer:**  daria.wronska@nokia.com
  ...
  ...  Arguments:
  ...  +----------------------------+-------+------------------------------------------------------------------------+
  ...  | Argument  | Man.  | Description  |
  ...  +====================+=======+=======+========================================================================+
  ...  | cablinkConf_linkSpeed_dict | Yes  | Dictionary keys contains distName of cablink configuration par.  |
  ...  |  |  | Dictionary values contains  values 'linkSpeed' parameter  |
  ...  +----------------------------+-------+------------------------------------------------------------------------+
  ...  | distname_conf  | Yes  | Variable containing distname CABLINK for BBMOD->FHS.  |
  ...  +----------------------------+-------+------------------------------------------------------------------------+
  ...  | linkspeed_bts  | Yes  | Contains value of 'linkSpeed' parameter on BTS.  |
  ...  +----------------------------+-------+------------------------------------------------------------------------+

  Convert To List  ${linkspeed_bts_list}
  FOR  ${distname_scf}  IN  @{cablinkConf_linkSpeed_dict.keys()}
    Run Keyword If  '${distname_conf}'=='${distname_scf}'
    ...  Ckecking LinkSpeed  ${cablinkConf_linkSpeed_dict}  ${distname_conf}  ${linkspeed_bts_list}  ${distname_scf}
  END

Ckecking LinkSpeed
  [Arguments]  ${cablinkConf_linkSpeed_dict}  ${distname_conf}  ${linkspeed_bts_list}  ${distname_scf}
  FOR  ${linkspeed_scf}  IN  @{cablinkConf_linkSpeed_dict.values()}
    Ckecking LinkSpeed BTS/SCF  ${linkspeed_bts_list}  ${distname_conf}  ${linkspeed_scf}  ${distname_scf}
  END

Ckecking LinkSpeed BTS/SCF
  [Arguments]  ${linkspeed_bts_list}  ${distname_conf}  ${linkspeed_scf}  ${distname_scf}
  [Documentation]
  ...  Description:
  ...  Comparison of value 'linkSpeed' parameter on BTS and scf, for cablinks BBMOD-FHS-RMODS.
  ...
  ...  |  **Author:**  daria.wronska@nokia.com
  ...  |  **Maintainer:**  daria.wronska@nokia.com
  ...
  ...  Arguments:
  ...  +----------------------------+-------+------------------------------------------------------------------------+
  ...  | Argument  | Man.  | Description  |
  ...  +====================+=======+=======+========================================================================+
  ...  | cablinkConf_linkSpeed_dict | Yes  | Dictionary keys contains distName of cablink configuration par.  |
  ...  |  |  | Dictionary values contains  values 'linkSpeed' parameter  |
  ...  +----------------------------+-------+------------------------------------------------------------------------+
  ...  | distname_conf  | Yes  | Variable containing distname CABLINK for BBMOD->FHS.  |
  ...  +----------------------------+-------+------------------------------------------------------------------------+
  ...  | linkspeed_bts_list  | Yes  | Contains value of 'linkSpeed' parameter on BTS.  |
  ...  +----------------------------+-------+------------------------------------------------------------------------+
  ...  | linkSpeed_values_list  | Yes  | Contains value of 'linkSpeed' parameter on scf.  |
  ...  +----------------------------+-------+------------------------------------------------------------------------+

  Convert To List  ${linkspeed_bts_list}
  FOR  ${linkspeed_bts}  IN  @{linkspeed_bts_list}
    Run Keyword If  '${distname_conf}'=='${distname_scf}'  Run Keyword
    ...  Run Keyword If  '${linkspeed_scf}'=='Auto'
    ...  List Should Contain Value  ${LINKSPEED_VALUES_LIST}  ${linkspeed_bts}
    ...  ELSE IF
    ...  '${linkspeed_bts}'=='${linkspeed_scf}'
    ...  Log  \nValues of 'linkSpeed' parameter are equal on BTS and scf  console=True
    ...  ELSE IF
    ...  "${linkspeed_scf}"==""
    ...  List Should Contain Value  ${LINKSPEED_VALUES_LIST}  ${linkspeed_bts}
    ...  ELSE
    ...  Fail
    ...  For ${distname_conf} values of 'linkSpeed' parameter are not equal in cofiguration and on BTS,
    ...  perform analysis towards pronto.
  END

Link Speed SCF
  [Documentation]
  ...  Description:
  ...  Creates dictionary with values 'LinkSpeed' parameters and distname for cablinks between BBMOD-FHS-RMODS.
  ...
  ...  |  **Author:**  daria.wronska@nokia.com
  ...  |  **Maintainer:**  daria.wronska@nokia.com
  ...
  ...  Return:
  ...  +----------------------------+-------+------------------------------------------------------------------------+
  ...  | Return  | Man.  | Description  |
  ...  +====================+=======+=======+========================================================================+
  ...  | cablinkConf_linkSpeed_dict | Yes  | Dictionary keys contains distName of cablink configuration par.  |
  ...  |  |  | Dictionary values contains  values 'linkSpeed' parameter  |
  ...  +----------------------------+-------+------------------------------------------------------------------------+

  ${linkSpeed_values_list}  Create List
  ...  Obsai3Gbps  Obsai6Gbps  Cpri2  Cpri3  Cpri5  Cpri6  Cpri7  eCpri10  eCpri25  eCpri50
  Set Test Variable  ${LINKSPEED_VALUES_LIST}  ${linkSpeed_values_list}
  ${cablink_xml}  Set Variable  (@class, "CABLINK") and not(contains(@class, "_R"))
  ${fhs_xml}  Set Variable  (@name, "secondEndpointDN") and contains(text(), "FHS")
  ${scf_path}=  admin.Get Current SCF File  ${cfg.test_logs_path}  SCF_current_BTS.xml  connection=${BTS_ID}
  ...  export_type=configurationAndRuntimeObjects
  ${distname_scfBbmod_list}=
  ...  Evaluate Xpath  ${scf_path}
  ...  .//managedObject[contains${cablink_xml} and p[contains${fhs_xml} ]]/@distName
  ${cablinkRmod_xml}  Set Variable  (@class, "CABLINK") and not(contains(@class, "_R"))
  ${fhsRmod_xml}  Set Variable  (@name, "firstEndpointDN") and contains(text(), "FHS")
  ${distname_scfRmod_list}=
  ...  Evaluate Xpath  ${scf_path}
  ...  .//managedObject[contains${cablinkRmod_xml} and p[contains${fhsRmod_xml} ]]/@distName
  ${distname_scfFHS_list}  Combine Lists  ${distname_scfBbmod_list}  ${distname_scfRmod_list}
  ${linkSpeed_value_list}  Create List
  &{cablinkConf_linkSpeed_dict}=  Create Dictionary
  FOR  ${distname_conf}  IN  @{distname_scfFHS_list}
    ${linkspeed_conf}=
    ...  Evaluate Xpath  ${scf_path}
    ...  string(.//managedObject[@distName="${distname_conf}"]/p[@name='linkSpeed'])
    Append To List  ${linkSpeed_value_list}  ${linkspeed_conf}
    Set To Dictionary  ${cablinkConf_linkSpeed_dict}  ${distname_conf}=${linkspeed_conf}
  END
  [Return]  ${cablinkConf_linkSpeed_dict}
