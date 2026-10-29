*** Settings ***
Library  DateTime
Library  ute_syslog
Library  taf.sbts.oam.coam.admin  WITH NAME  admin

Documentation
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.


*** Keywords ***
Check which RAT are on given TestLine
    ${GSM_DEPLOYED}  admin.get ids for all  GNCEL
    ${WCDMA_DEPLOYED}  admin.get ids for all  WNCEL
    ${LTE_DEPLOYED}  admin.get ids for all  LNCEL
    ${NR_DEPLOYED}  admin.get ids for all  NRCEL
    ${IF_GSM_EXIST}  Set Variable If  ${GSM_DEPLOYED}!=[]  EXIST  NO
    ${IF_WCDMA_EXIST}  Set Variable If  ${WCDMA_DEPLOYED}!=[]  EXIST  NO
    ${IF_LTE_EXIST}  Set Variable If  ${LTE_DEPLOYED}!=[]  EXIST  NO
    ${IF_NR_EXIST}  Set Variable If  ${NR_DEPLOYED}!=[]  EXIST  NO
    Set Suite Variable  ${IF_GSM_EXIST}
    Set Suite Variable  ${IF_WCDMA_EXIST}
    Set Suite Variable  ${IF_LTE_EXIST}
    Set Suite Variable  ${IF_NR_EXIST}


Set Dist Name For Objects
    Check which RAT are on given TestLine
    IF  '${IF_LTE_EXIST}'=='EXIST'  Set Test Variable  ${LNBTS_DistName}  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
    IF  '${IF_NR_EXIST}'=='EXIST'  Set Test Variable  ${NRBTS_DistName}  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    Set Test Variable  ${FEATCADM_DistName}  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    Set Test Variable  ${FEATLADM_DistName}  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1


Get Lncel Ids From PSGRP
    [Documentation]  Keyword get value from lnCelId parameter in PSGRP

    ${psgrp_parameter_list}  admin.get managed objects  PSGRP_A
    Set Test Variable  ${psgrp_parameter_list}
    ${cells_in_psgrp}  Create List
    FOR  ${psgrp_parameter}  IN  @{psgrp_parameter_list}
      ${lbpsCellList}  Get From Dictionary  ${psgrp_parameter['parameters']}  lbpsCellList
      Set Test Variable  ${lbpsCellList}
    END
    FOR  ${parameter}  IN  @{lbpsCellList}
        ${lnCelId}  Get From Dictionary  ${parameter}  lnCelId
        Append To List  ${cells_in_psgrp}  LNCEL_R-${lnCelId}
    END
     Set Test Variable  ${cells_in_psgrp}


Get Nrcells Ids From NRPGRP
    [Documentation]  Keyword get value from nrCelId parameter in NRPGRP

    ${nrpgrp_parameter_list}  admin.get managed objects  NRPGRP_A
    Set Test Variable  ${nrpgrp_parameter_list}
    ${cells_in_nrpgrp}  Create List
    FOR  ${nrpgrp_parameter}  IN  @{nrpgrp_parameter_list}
      ${lbpsCellList}  Get From Dictionary  ${nrpgrp_parameter['parameters']}  lbpsCellList
      Set Test Variable  ${lbpsCellList}
    END
    FOR  ${parameter}  IN  @{lbpsCellList}
        ${nrCelId}  Get From Dictionary  ${parameter}  nrCellId
        Append To List  ${cells_in_nrpgrp}  NRCELL_R-${nrCelId}
    END
     Set Test Variable  ${cells_in_nrpgrp}


Return PS And Not PS LTE Cells
    [Documentation]  Keyword gets ids for all LNCEL, then compare them with ids
    ...  from cells in PSGRP, and return two separate lists

    Log To Console  Check If any LNCELs included in PSGRP
    ${LTE_DEPLOYED}  admin.get ids for all  LNCEL
    ${LTE_DEPLOYED_IDs}  Create List
    FOR  ${item}  IN  @{LTE_DEPLOYED}
        ${split_for_id}  Split String From Right  ${item}  separator=/  max_split=1
        ${lncelId}  Get From List  ${split_for_id}  1
        Append To List  ${LTE_DEPLOYED_IDs}  ${lncel_id}
    END
    Set Test Variable  ${LTE_DEPLOYED_IDs}
    Get Lncel Ids From PSGRP
    ${ps_cells_LTE}  Evaluate  [LNCEl_R for LNCEl_R in @{LTE_DEPLOYED_IDs} if LNCEl_R in ${cells_in_psgrp}]
    Set Test Variable  ${ps_cells_LTE}
    ${ps_cells_LTE}  Evaluate  [LNCEL_DN for LNCEL_DN in @{LTE_DEPLOYED} if any(LNCEl_R for LNCEl_R in ${ps_cells_LTE} if LNCEL_DN.endswith(LNCEl_R))]
    ${not_ps_cells_LTE}  Evaluate  [LNCEl_DN for LNCEl_DN in @{LTE_DEPLOYED} if LNCEl_DN not in ${ps_cells_LTE}]

    RETURN  ${not_ps_cells_LTE}  ${ps_cells_LTE}


Return PS And Not PS NR Cells
    [Documentation]  Keyword gets ids for all NRCEL, then compare them with ids
    ...  from cells in NRPGRP, and return two separate lists

    Log To Console  Check If any NRCELs included in NRPGRP
    ${NR_DEPLOYED}  admin.get ids for all  NRCEL
    ${NR_DEPLOYED_IDs}  Create List
    FOR  ${item}  IN  @{NR_DEPLOYED}
        ${split_for_id}  Split String From Right  ${item}  separator=/  max_split=1
        ${nrcelId}  Get From List  ${split_for_id}  1
        Append To List  ${NR_DEPLOYED_IDs}  ${nrcelId}
    END
    Set Test Variable  ${NR_DEPLOYED_IDs}
    Get Nrcells Ids From NRPGRP
    ${ps_cells_NR}  Evaluate  [NRCEl_R for NRCEl_R in @{NR_DEPLOYED_IDs} if NRCEl_R in ${cells_in_nrpgrp}]
    Set Test Variable  ${ps_cells_NR}
    ${ps_cells_NR}  Evaluate  [NRCEL_DN for NRCEL_DN in @{NR_DEPLOYED} if any(NRCEl_R for NRCEl_R in ${ps_cells_NR} if NRCEL_DN.endswith(NRCEl_R))]
    ${not_ps_cells_NR}  Evaluate   [NRCEL_DN for NRCEL_DN in @{NR_DEPLOYED} if NRCEL_DN not in ${ps_cells_NR}]

    RETURN  ${not_ps_cells_NR}  ${ps_cells_NR}
