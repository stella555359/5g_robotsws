*** Settings ***

Documentation
...    author: Chen Shufei
...    contact: shufei.chen@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${origrin_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00.xml

*** Keywords ***
Cell_on_air_after_actDlSrsBm_or_actCsirsMultiplexing_changed
      Selenium Login With Version
      Modify actCsirsMultiplexing Parameter    actCsirsMultiplexing=false
      COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
      Modify actDlSrsBm Parameter    actDlSrsBm=false
      COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
      [Teardown]    run keywords    COAM Commission with scf file    scf_file_path=${origrin_scf}   timeout=15min    AND
      ...    Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air    connection=GNB_OAM    AND
      ...    selenium logout and close browser

Modify actCsirsMultiplexing Parameter
    [Arguments]    ${actCsirsMultiplexing}
    ${actCsirsMultiplexing_currect_status}    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate multiple CSI-RS resources multiplexing in slot    abbr=actCsirsMultiplexing
    log to console    ${actCsirsMultiplexing_currect_status}
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate multiple CSI-RS resources multiplexing in slot  p_name=actCsirsMultiplexing
    ...    value=${actCsirsMultiplexing}
    append to list  ${modify_params}  ${item}
    Run Keyword If    '${actCsirsMultiplexing_currect_status}'!='${actCsirsMultiplexing}'    Modify Parameters On Webem
    ...    modify_params=${modify_params}

Modify actDlSrsBm Parameter
    [Arguments]    ${actDlSrsBm}
    ${actDlSrsBm_currect_status}    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate downlink SRS based beam management    abbr=actDlSrsBm
    log to console    ${actDlSrsBm_currect_status}
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate downlink SRS based beam management  p_name=actDlSrsBm    value=${actDlSrsBm}
    append to list  ${modify_params}  ${item}
    Run Keyword If    '${actDlSrsBm_currect_status}'!='${actDlSrsBm}'    Modify Parameters On Webem
    ...    modify_params=${modify_params}

Cell_Setup_with_NDM_SRS_configuration_SRS_resource
    Selenium Login With Version
    Modify actUlSrsBm Parameter    actUlSrsBm=true    mMimoAntArrayMode=Full 64TRX Array (4x8x2)
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    verify actUlSrsBm and mMimoAntArrayMode value    actUlSrsBm=true    mMimoAntArrayMode=Full 64TRX Array (4x8x2)
    [Teardown]    run keywords    COAM Commission with scf file    scf_file_path=${origrin_scf}   timeout=15min    AND
      ...    Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air    connection=GNB_OAM    AND
      ...    selenium logout and close browser

Modify actUlSrsBm Parameter
    [Arguments]    ${actUlSrsBm}    ${mMimoAntArrayMode}
    ${actUlSrsBm_currect_status}    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate uplink SRS based beam management    abbr=actUlSrsBm
    log to console    ${actUlSrsBm_currect_status}
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate uplink SRS based beam management  p_name=actUlSrsBm    value=${actUlSrsBm}
    append to list  ${modify_params}  ${item}
    ${item_1}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Massive MIMO Antenna Array Mode  p_name=mMimoAntArrayMode    value=${mMimoAntArrayMode}
    append to list  ${modify_params}  ${item_1}
    Modify Parameters On Webem    modify_params=${modify_params}    timeout=120

verify actUlSrsBm and mMimoAntArrayMode value
    [Arguments]    ${actUlSrsBm}    ${mMimoAntArrayMode}
    log to console    verify actUlSrsBm and mMimoAntArrayMode value
    ${actUlSrsBm_currect_status}    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate uplink SRS based beam management    abbr=actUlSrsBm
    ${mMimoAntArrayMode_currect_status}    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Massive MIMO Antenna Array Mode    abbr=mMimoAntArrayMode
    Should Be Equal As Strings    ${actUlSrsBm_currect_status}    ${actUlSrsBm}
    Should Be Equal As Strings    ${mMimoAntArrayMode_currect_status}    ${mMimoAntArrayMode}