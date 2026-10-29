*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keywords ***
Beamforming_Grid_Selection_Modification_via_WEBEM_Requires_Object_Locking
    ${dist_name}   Get Dist Name From SCF
    ${new_value}   Return New Parameter Value
    COAM Update Parameter   dist_name=${dist_name}   parameter=beamformingGridSel   value=${new_value}
    ${cell_Status}   Run Keyword And Return Status   COAM Check All Cells Onair
    Should Not Be True   ${cell_Status}
    Sleep   1m

Case Setup 2355
    COAM Login
    COAM Backup SCF
    COAM Reset Site
    Wait Until Keyword Succeeds   20m   1m   COAM Check BTS OnAir
    ${BTS_ID}   Set Variable   ${tl.gnbs[0].instance_id}

Case Teardown 2355
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   20m   1m   COAM Login
    COAM SCF Commission
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   20m   1m   COAM Login
    Wait Until Keyword Succeeds   20m   1m   COAM Check BTS OnAir
    Run Keyword And Ignore Error   COAM Logout

Get Dist Name From SCF
    [Arguments]   ${file_path}=${OUTPUT_DIR}/old_commission.xml
    ${XML}   Parse XML   ${file_path}
    ${dist_name}   Get Element Attribute   source=${XML}   name=distName   xpath=(cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"])[1]
    [Return]   ${dist_name}

Return New Parameter Value
    [Arguments]   ${file_path}=${OUTPUT_DIR}/old_commission.xml
    ${XML}   Parse XML   ${file_path}
    ${origin_value}   Get Element Text   source=${XML}   xpath=(cmData/managedObject/p[@name="beamformingGridSel"])[1]
    ${new_value}   Set Variable If
    ...   '${origin_value}'=='ABFG120'   ABFG90
    ...   '${origin_value}'=='ABFG90'   ABFG120
    [Return]   ${new_value}
