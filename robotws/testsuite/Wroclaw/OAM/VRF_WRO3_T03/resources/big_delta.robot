*** Settings ***
Library         taf.sbts.oam.coam.admin  WITH NAME  admin
Resource        ../resources/common.robot

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
...  06.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-392 - resource file creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${SKIP_PARAMETER_RELATION_ERRORS}=  True
${SHOULD_ACTIVATE}=  True

*** Keywords ***
Generate And Activate Big Delta Plan - LTE Neighbouring Objects
    [Documentation]  Keyword generates a large number (over 1000) of objects (LNADJ/LNADJW/LNADJG) and activates plan.
    ${current_date}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${LNBTS_ID}=  Get LNBTS ID
    ${big_delta}=  Set Variable  big_lte_delta
    admin.create delta  ${big_delta}
    ${LNADJ_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNADJ
    &{plmnId}=  Create Dictionary  mcc=555  mnc=10  mncLength=2
    FOR  ${i}  IN RANGE  0  256
        admin.append managed object to delta    ${LNADJ_DN}-${i}  create  ${big_delta}
        admin.append parameter update to delta  ${LNADJ_DN}-${i}  adjEnbId  ${i}  ${big_delta}
        admin.append parameter update to delta  ${LNADJ_DN}-${i}  cPlaneIpAddr  192.168.243.${i}  ${big_delta}
        admin.append parameter update to delta  ${LNADJ_DN}-${i}  cPlaneIpAddrCtrl  enbControlled  ${big_delta}
        admin.append parameter update to delta  ${LNADJ_DN}-${i}  lnAdjId  ${i}  ${big_delta}
        admin.append complex item to delta      ${LNADJ_DN}-${i}  list_name=plmnId  &{plmnId}  delta_id=${big_delta}
        admin.append parameter update to delta  ${LNADJ_DN}-${i}  rlfBasedRCRsupported  false  ${big_delta}
        admin.append list items to delta        ${LNADJ_DN}-${i}  uPlaneIpAddrList  192.168.243.${i}  delta_id=${big_delta}
    END
    ${LNADJW_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNADJW
    FOR  ${i}  IN RANGE  0  500
        admin.append managed object to delta    ${LNADJW_DN}-${i}  create  ${big_delta}
        admin.append parameter update to delta  ${LNADJW_DN}-${i}  lnAdjWId  ${i}  ${big_delta}
        admin.append complex item to delta      ${LNADJW_DN}-${i}  list_name=primaryPlmnId  &{plmnId}  delta_id=${big_delta}
        admin.append parameter update to delta  ${LNADJW_DN}-${i}  srvccHoInd  PSandCS  ${big_delta}
        Run Keyword If  ${0}<=${i}<=${9}
        ...  admin.append parameter update to delta  ${LNADJW_DN}-${i}  uTargetCid  6500${i}  ${big_delta}
        ...  ELSE IF  ${10}<=${i}<=${99}
        ...  admin.append parameter update to delta  ${LNADJW_DN}-${i}  uTargetCid  650${i}  ${big_delta}
        ...  ELSE IF  ${100}<=${i}<=${499}
        ...  admin.append parameter update to delta  ${LNADJW_DN}-${i}  uTargetCid  65${i}  ${big_delta}
        admin.append parameter update to delta  ${LNADJW_DN}-${i}  uTargetFreq  2950  ${big_delta}
        Run Keyword If  ${0}<=${i}<=${9}
        ...  admin.append parameter update to delta  ${LNADJW_DN}-${i}  uTargetLac  6500${i}  ${big_delta}
        ...  ELSE IF  ${10}<=${i}<=${99}
        ...  admin.append parameter update to delta  ${LNADJW_DN}-${i}  uTargetLac  650${i}  ${big_delta}
        ...  ELSE IF  ${100}<=${i}<=${499}
        ...  admin.append parameter update to delta  ${LNADJW_DN}-${i}  uTargetLac  65${i}  ${big_delta}
        admin.append parameter update to delta  ${LNADJW_DN}-${i}  uTargetRac  0  ${big_delta}
        admin.append parameter update to delta  ${LNADJW_DN}-${i}  uTargetRncId  ${i}  ${big_delta}
        admin.append parameter update to delta  ${LNADJW_DN}-${i}  uTargetScFdd  ${i}  ${big_delta}
    END
    ${LNADJG_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNADJG
    FOR  ${i}  IN RANGE  0  256
        admin.append managed object to delta    ${LNADJG_DN}-${i}  create  ${big_delta}
        admin.append parameter update to delta  ${LNADJG_DN}-${i}  arfcnValueGeran  10  ${big_delta}
        admin.append parameter update to delta  ${LNADJG_DN}-${i}  bandIndicatorGeran  dcs1800  ${big_delta}
        admin.append parameter update to delta  ${LNADJG_DN}-${i}  basestationColourCode  1  ${big_delta}
        Run Keyword If  ${0}<=${i}<=${9}
        ...  admin.append parameter update to delta  ${LNADJG_DN}-${i}  gTargetCi  6500${i}  ${big_delta}
        ...  ELSE IF  ${10}<=${i}<=${99}
        ...  admin.append parameter update to delta  ${LNADJG_DN}-${i}  gTargetCi  650${i}  ${big_delta}
        ...  ELSE IF  ${100}<=${i}<=${499}
        ...  admin.append parameter update to delta  ${LNADJG_DN}-${i}  gTargetCi  65${i}  ${big_delta}
        admin.append parameter update to delta  ${LNADJG_DN}-${i}  dtm  false  ${big_delta}
        Run Keyword If  ${0}<=${i}<=${9}
        ...  admin.append parameter update to delta  ${LNADJG_DN}-${i}  gTargetLac  6500${i}  ${big_delta}
        ...  ELSE IF  ${10}<=${i}<=${99}
        ...  admin.append parameter update to delta  ${LNADJG_DN}-${i}  gTargetLac  650${i}  ${big_delta}
        ...  ELSE IF  ${100}<=${i}<=${499}
        ...  admin.append parameter update to delta  ${LNADJG_DN}-${i}  gTargetLac  65${i}  ${big_delta}
        admin.append parameter update to delta  ${LNADJG_DN}-${i}  mcc  555  ${big_delta}
        admin.append parameter update to delta  ${LNADJG_DN}-${i}  mnc  10  ${big_delta}
        admin.append parameter update to delta  ${LNADJG_DN}-${i}  mncLength  2  ${big_delta}
        admin.append parameter update to delta  ${LNADJG_DN}-${i}  networkColourCode  1  ${big_delta}
        admin.append parameter update to delta  ${LNADJG_DN}-${i}  networkControlOrder  RESET  ${big_delta}
        admin.append parameter update to delta  ${LNADJG_DN}-${i}  gTargetRac  0  ${big_delta}
        admin.append parameter update to delta  ${LNADJG_DN}-${i}  systemInfoType  none  ${big_delta}
    END
    admin.get delta  ${big_delta}
    ${json_path}=  Set Variable  ${RESULTS}/${big_delta}_${current_date}.json
    admin.save delta  ${json_path}  ${big_delta}
    Log To Console  Activating big delta plan with large number of LTE neighbouring objects
    admin.perform delta recommissioning  ${json_path}
    ...  skip_parameter_relation_errors=${SKIP_PARAMETER_RELATION_ERRORS}  should_activate=${SHOULD_ACTIVATE}

Generate And Activate Big Delta Plan Removal - LTE Neighbouring Objects
    [Documentation]  Keyword removes all objects LNADJ, LNADJW, LNADJG created on BTS.
    ${LNBTS_ID}=  Get LNBTS ID
    ${LNADJ_A}=   admin.get managed objects  LNADJ_A
    ${LNADJW_A}=  admin.get managed objects  LNADJW_A
    ${LNADJG_A}=  admin.get managed objects  LNADJG_A
    ${current_date}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${LNADJ_DN}=   Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNADJ
    ${LNADJG_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNADJG
    ${LNADJW_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNADJW
    ${big_delta_del}=  Set Variable  lte_neighbouring_del
    admin.create delta  ${big_delta_del}
    FOR  ${lnadj}  IN  @{LNADJ_A}
        ${ID}=   Evaluate  re.search(r'LNADJ_A-(\\d+)','''${lnadj['distName']}''').group(1)  re
        admin.append managed object to delta  ${LNADJ_DN}-${ID}  delete  delta_id=${big_delta_del}
    END
    FOR  ${lnadjw}  IN  @{LNADJW_A}
        ${ID}=   Evaluate  re.search(r'LNADJW_A-(\\d+)','''${lnadjw['distName']}''').group(1)  re
        admin.append managed object to delta  ${LNADJW_DN}-${ID}  delete  delta_id=${big_delta_del}
    END
    FOR  ${lnadjg}  IN  @{LNADJG_A}
        ${ID}=   Evaluate  re.search(r'LNADJG_A-(\\d+)','''${lnadjg['distName']}''').group(1)  re
        admin.append managed object to delta  ${LNADJG_DN}-${ID}  delete  delta_id=${big_delta_del}
    END
    admin.get delta  ${big_delta_del}
    ${json_path}=  Set Variable  ${RESULTS}/${big_delta_del}_${current_date}.json
    admin.save delta  ${json_path}  ${big_delta_del}
    ${json_body}=  Load JSON File  ${json_path}
    ${json_body}=  Convert To String  ${json_body}
    ${if_json_not_empty}=  Run Keyword And Return Status  Should Match Regexp  '${json_body}'  distName
    Run Keyword If  ${if_json_not_empty}  Run Keywords
    ...  Log To Console  Deleting all LTE neighbouring objects
    ...  AND  admin.perform delta recommissioning  ${json_path}
    ...  skip_parameter_relation_errors=${SKIP_PARAMETER_RELATION_ERRORS}  should_activate=${SHOULD_ACTIVATE}

Generate And Activate Big Delta Plan - NR Neighbouring gNodeBs
    [Documentation]  Keyword generates a large number of NRADJGNB, XNLINK objects and activates plan.
    ${current_date}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${big_delta}=  Set Variable  big_nr_delta
    admin.create delta  ${big_delta}
    ${NRADJGNB_DN}=  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRADJGNB
    &{gnbPlmn}=  Create Dictionary  mcc=555  mnc=10  mncLength=2
    FOR  ${i}  IN RANGE  1  256
        admin.append managed object to delta    ${NRADJGNB_DN}-${i}  create  ${big_delta}
		admin.append parameter update to delta  ${NRADJGNB_DN}-${i}  administrativeState  Unlocked  ${big_delta}
		admin.append parameter update to delta  ${NRADJGNB_DN}-${i}  gNbIdLength  22  ${big_delta}
		admin.append complex item to delta      ${NRADJGNB_DN}-${i}  list_name=gnbPlmn  &{gnbPlmn}  delta_id=${big_delta}
        Run Keyword If  ${0}<=${i}<=${9}
        ...  admin.append parameter update to delta  ${NRADJGNB_DN}-${i}  gNodeBId  9000${i}  ${big_delta}
        ...  ELSE IF  ${10}<=${i}<=${99}
        ...  admin.append parameter update to delta  ${NRADJGNB_DN}-${i}  gNodeBId  900${i}  ${big_delta}
        ...  ELSE IF  ${100}<=${i}<=${256}
        ...  admin.append parameter update to delta  ${NRADJGNB_DN}-${i}  gNodeBId  90${i}  ${big_delta}
		admin.append parameter update to delta  ${NRADJGNB_DN}-${i}  gNodeBIdCtrl  oamControlled  ${big_delta}
		admin.append parameter update to delta  ${NRADJGNB_DN}-${i}  nrAdjGnbId  ${i}  ${big_delta}
		admin.append parameter update to delta  ${NRADJGNB_DN}-${i}  xnLinkRef  ${i}  ${big_delta}
    END
    ${XNLINK_DN}=  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/XNLINK
    FOR  ${i}  IN RANGE  1  256
		admin.append managed object to delta    ${XNLINK_DN}-${i}  create  ${big_delta}
		admin.append parameter update to delta  ${XNLINK_DN}-${i}  cPlaneIpAddr  192.168.243.${i}  ${big_delta}
		admin.append parameter update to delta  ${XNLINK_DN}-${i}  cPlaneIpAddrCtrl  oamControlled  ${big_delta}
		admin.append parameter update to delta  ${XNLINK_DN}-${i}  xnLinkId  ${i}  ${big_delta}
    END
    admin.get delta  ${big_delta}
    ${json_path}=  Set Variable  ${RESULTS}/${big_delta}_${current_date}.json
    admin.save delta  ${json_path}  ${big_delta}
    Log To Console  Activating big delta plan with large number of NR neighbouring gNodeB objects
    admin.perform delta recommissioning  ${json_path}
    ...  skip_parameter_relation_errors=${SKIP_PARAMETER_RELATION_ERRORS}  should_activate=${SHOULD_ACTIVATE}

Generate And Activate Big Delta Plan Removal - NR Neighbouring Objects
    [Documentation]  Keyword removes all objects NRADJGNB, XNLINK created on BTS.
    ${NRADJGNB_A}=   admin.get managed objects  NRADJGNB_A
    ${XNLINK_A}=     admin.get managed objects  XNLINK_A
    ${current_date}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${NRADJGNB_DN}=  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRADJGNB
    ${XNLINK_DN}=    Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/XNLINK
    ${big_delta_del}=  Set Variable  nr_neighbouring_del
    admin.create delta  ${big_delta_del}
    FOR  ${nradjgnb}  IN  @{NRADJGNB_A}
        ${ID}=   Evaluate  re.search(r'NRADJGNB_A-(\\d+)','''${nradjgnb['distName']}''').group(1)  re
        admin.append managed object to delta  ${NRADJGNB_DN}-${ID}  delete  delta_id=${big_delta_del}
    END
    FOR  ${xnlink}  IN  @{XNLINK_A}
        ${ID}=   Evaluate  re.search(r'XNLINK_A-(\\d+)','''${xnlink['distName']}''').group(1)  re
        admin.append managed object to delta  ${XNLINK_DN}-${ID}  delete  delta_id=${big_delta_del}
    END
    admin.get delta  ${big_delta_del}
    ${json_path}=  Set Variable  ${RESULTS}/${big_delta_del}_${current_date}.json
    admin.save delta  ${json_path}  ${big_delta_del}
    ${json_body}=  Load JSON File  ${json_path}
    ${json_body}=  Convert To String  ${json_body}
    ${if_json_not_empty}=  Run Keyword And Return Status  Should Match Regexp  '${json_body}'  distName
    Run Keyword If  ${if_json_not_empty}  Run Keywords
    ...  Log To Console  Deleting all NR neighbouring objects
    ...  AND  admin.perform delta recommissioning  ${json_path}
    ...  skip_parameter_relation_errors=${SKIP_PARAMETER_RELATION_ERRORS}  should_activate=${SHOULD_ACTIVATE}
