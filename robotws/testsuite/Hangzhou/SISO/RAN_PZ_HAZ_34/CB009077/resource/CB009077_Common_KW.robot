*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/SBTS_Setup_And_Teardown.robot
Library     ../lib/xmlparser.py      WITH NAME   xmlparser

*** Variables ***
${ENB_INDEX}    ${0}
${LNBTS_ID}     ${tl.enbs[${ENB_INDEX}].global_bts_id}

${conf_altitude}    ${2000}
${conf_latitude}    ${900000000}
${conf_longitude}   ${10000000}
${XPATH_ConfiguredLocation}   .//managedObject[@distName="moduleConfiguredLocation"]/parameter[parameterName="Location"]/value
${XPATH_DetectedLocation}   .//managedObject[@distName="moduleDetectedLocation"]/parameter[parameterName="Location"]/value
${XPATH_btsInformation}   .//managedObject[@distName="btsInformation"]/parameter[parameterName="BtsVersion"]/value

${XPATH_Timestamp}   .//managedObject[@distName="btsInformation"]/parameter[parameterName="Timestamp"]/value
${XPATH_ModuleSerialNumber}   .//managedObject[@distName="moduleDetectedLocation"]/parameter[parameterName="ModuleSerialNumber"]/value

${PRIVATE_KEY}  SEPARATOR=\n
...  -----BEGIN PRIVATE KEY-----
...  MIIJQwIBADANBgkqhkiG9w0BAQEFAASCCS0wggkpAgEAAoICAQDagfML6VsDD996
...  cvLthZ3lDDEUkE4uUO3h2tF4EAqf+2S1Cox6r7qz/GsMXtAJ75baZhhng58VVqHx
...  in3hZ/6b9nIdUdnidObCrmz2ytXGBN5kKbzSV5IAqtbNiSpwICchq6sWMXe4+DUM
...  GrfVAdUlc8GAIf3dsIsmTOCwXxBayVkjz3RxRGdh2fcM2aCAO/aJ1JTKTvjVX45c
...  vx0rVPItc1oleSRXrwLDom0gwTIx6sPzN1Mt1g+vEVmI5FTl6tHzDqcgZ9pEkJuB
...  mupcEmdtE7hFLGLqZ75YCjRuEcW86CimumdQjytQ3WNYRfNPXEC7QehNujqutDmY
...  WJp9Ls6vl3NITK5QsKtM2g6LCjVKpQpLe1n9SVkgfyelYAY9bj3k8a2Sy1A00gVH
...  QlHGmaJsPoCDqFiqwXG/0107ms2xzxO4Q9zH0bZ+CmZMsvmQie0qJsHUqYlAZhUR
...  5uA7FRry3VQju+1NRK7zgQk8hUozTJE9WMXOC5k1TsjBGYDIP/BVUDv0X1bcu5vt
...  XbjtbEa/6DMBc1s3KzEsvaa+wOpwqRDd/uETrztEwNQ6bN7VjFsOkJ6jXR8MtVGP
...  Ayn3I86QeBtM887MWtUXIVkgn5GH5zlkcYfWMMCmlkJz7aD5PEjelRwEErNbBSXd
...  QH7Vmw4QIGEpOPzbAnADpj91kQfU2QIDAQABAoICAEKrO5j6zkYU5b7aq7xE9HQa
...  UC9SCEihcLNkrFzRqCw/6+5BFbOpQnIAJjlUBG3DqGdilzeeNT+xex/Tfaz0qf60
...  JwVDIBO0T2Q/DAgQw0Dz41b0VSRoi6egeIGlxEkJxmbDliPjXAAX2zeiP0zCjmIq
...  +3M469hkMVCyTCwEFV1d6dC/T2vvzwtQEczd6da2dPaA4hUIG2wfB7TMqv25oVq0
...  w2CDoc8PGuzN9jX0PHh2hOsEimCF26syw/q8kBrGluBuLBf7F+GrrYbR2YfWJbBm
...  P+b7MAMNPEpocq7SxV5qB103qqYtyK2XnuQkE6S3JRj9dv+gPp9nZdtRzXE8gtsH
...  5JPelR9DchFGqzqpyptwLM7wyjAy8bTq+qLFPH+Frb/50Ow1yVs5v01h/AVsH897
...  CJSiV29CI7UJUtz+B3PfFPjUTCu1NdpYxzKR1LsHBg4G7SXLvEfxP1ivBxoWvhy1
...  bxALfYY1yLlTnLgDiU8JbaRGvhxF8C54fzQNkjC+4tBdu6VAn/Pvag4usj2sT+PX
...  Oyx6sQCm8v4jdI0f58JkqMr8jKzW6wr/jhLCXX2Ou8dTUCKWBSpbdVx2S2EA9keZ
...  2dpjtaRDTwNTzpNo9hDMXCrnCVMRjIoevZ+HrRpiyEBu/wOy6nmgRLhKD+LxQdsg
...  ZYVIfkmIgszQl63QZ2LBAoIBAQD7k7wTNNJuW0w/arSn6cZyjYSPA7TQGGIEnYun
...  iqIi87Z+SWydUwnTzezNLMPClota4u4tTXUSDo2igaFsmBDdJcrz1mccFAUvhOY0
...  jSeCHwEwcDvKH9mP6c5ESCjrnCfx/men0RIayVx7m31FI9xOLN2KB+UREpgdLacI
...  AIlpxLrixaTF0U/yPg8BLd/lPLBZb6u9ZSDJt3TOwMPEsdJKLW3tXl6qsyECUB7/
...  /O6pKQZecv6ygzlYW4h/+GRNF55X8xrN8mgn9npcPvRx4S+LV5oUXhgl6m0ZTTcC
...  +8U2GkxX/kgZjBVEJKXbvowQfPVh+9K8hDxZ1bQ+51zt2YbdAoIBAQDeWWFFFixD
...  oH7hDC/Vzxxo3pmU6B4Bf7wDBT0byfLV82j9VxCIw7+Qv2D+/AztNGQNqIwSXoIf
...  MVPs2hZntoAjViQXX6McjBlQcH15XNTUyTr5wqj+HHzwmkNmX596jvtr0wb3aZaI
...  FgvT1LxUDbnYfOHTUfizFOwMghqsR+JwhgzTAwy3NUvcL8JJ5bCzrLPZ88iNLdAE
...  vP6spio/FyYfp3mgpcSxeGS/ea6L9r7WlKL3B5Egs+O+DyuyDZTvGZHMJ1J+JZ9V
...  mXHe8GUhVAqxcSMsNAI3s7aNgI1Mzqg4vm5MfH1ru+3KcthCsa3zLdqmoEJi0gHE
...  DBUVP27s9aAtAoIBAAax179rGG53X4AQht4xCmbh/TURFC61d2ZICv9aYRYtBh42
...  Nf25x/kq8bJEDrGO8AZrI4txFDx2xq4cZP9OzKQV7WCvw+6rWbf6AWZEm1iLGqz/
...  T5gBYPjDcAnBIdWjQizeaEO+/IxZ72wapyq/2Yz7BKo3q5DYvdOI83jzCrUV1yNR
...  vyDEgSwhGqUdY2fmRYsbvaY8mrLDfwhBePQzBzWSH+rBKCPCwI4fM7P8Nx2pSdIZ
...  nU2C0HPZe7hsE785ca1FeuEgIkVt+bOauUaOh4Vdv2vrVRktM9oIg/5AVO8ro/xz
...  d9e2MpqtnvxKBdAqgx0oZmM94Z1CYpmJ7p8lusECggEBAJyGARJ4XGqy9f6I7Lev
...  18j/QtBvYogdmoXpzy3byUXR10vYWXxdiGJmRurZFmR5aCGxUAGyZBl/SRxIHlOe
...  RrAZeMi3e4SiH0PgHIQt1GmCyzB9VyejeFSL0/yiPgsx0k4CPTo4K07bbjIN5RGq
...  o/SBXRu87b1rcgwQHqS+6enag/abg/0I2MFFIZmRxwWFAwrgMYMpB/H99a4mP0Ew
...  k5be96EecMuZ/BpKl5RR+9/kvJ/3xLNnz1/BIDp0ky6KKne0Cr9gzryci2usgRSo
...  K+rjwSXh6tm5ej48i7vREtz3OYBAdq47mlbU5+ZzXAf/dJet423bdoDDHKhbgkPv
...  WXUCggEBAIWrqtZ9bwnz+C8iDyKdKC5SRID2/vKN14dwg/K9bEfqll5wFgr6bfeg
...  JYVRb8hZJeh7Rz3d3zCOoyd7iCUKjUa87kHJcUK/wm9cCauSO9uQxbdMOuSIwLbF
...  IAJ/40yWCnH2r1DmbbCmfjkQVJBXt3quNOrcU5F/JLV9gEKcWSTfan4H0v3Kmbjt
...  wbPZRooeiIfD57HwjnGWzt9dDbkTXKtapC4lQaBM34bVC5CMCHqDlwB6kzIGk8QD
...  VuIjoK48+079TF7wtwis97xU0iS3tW7CpN8X8dpUhObWZ42e3nyY7xLSwmvQ51LP
...  FfahPQpy6/UhBhsrWVIPvL6pS7p3BOw=
...  -----END PRIVATE KEY-----

*** Keywords ***
Load Case SCF
    [Arguments]    ${gnb_index}=0
    set test variable   ${cell_type}   lte
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    ${Status}    ${key}   run keyword and ignore error   get specified scf
    ${SCF_Path}    set variable if      '${Status}'=='PASS'    ${key}[0]    ${Golden_SCF_Path}
    ${SCF_Status}    set variable if      '${Status}'=='PASS'    ${key}[1]    ${False}
    Set Test Variable    ${Case_SCF_Path}    ${SCF_Path}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Run Keyword If    ${SCF_Status}==${True} and ${gnb_index}==0
    ...    Commissioning SCF And Check Enb On Air     scf_path=${SCF_Path}   connection=${connection}

Commissioning SCF And Check Enb On Air
   [Arguments]    ${scf_path}   ${connection}
   COAM Commission with scf file   scf_file_path=${scf_path}
   ...   timeout=600   is_pdl_checking_needed=${if_pdl_check}   connection=${connection}
    Sleep   300s
    Wait Until Keyword Succeeds    5min    30s    Verify all cells should be onair   cell_type=${cell_type}

Configure_customer_LCS_parameters_manually_for_4G_AQQL
    [Arguments]
    Load Case SCF
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${CellNum}    selenium_coam.get_number_of_cells
    FOR    ${cell_id}    IN RANGE    1   ${CellNum+1}
        ${result}   Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=E-UTRAN access point position   abbr=eutranAccessPointPosition
        Run Keyword If    '${result[0]}'=='PASS'    Run keywords    selenium_coam.validate_plan   AND
        ...   selenium_coam.activate_plan   AND
        ...   Wait Until Keyword Succeeds    5min    30s    Verify all cells should be onair   cell_type=${cell_type}
        selenium_coam.add_element
        ...    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=E-UTRAN access point position    abbr=eutranAccessPointPosition    timeout=15
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Altitude    abbr=altitude
        ...    new_value=${1}    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Degrees of latitude    abbr=degreesOfLatitude
        ...    new_value=${0}    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Degrees of longitude    abbr=degreesOfLongitude
        ...    new_value=${8388607}    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Direction of altitude    abbr=directionOfAltitude
        ...    new_value=height    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Latitude sign    abbr=latitudeSign
        ...    new_value=south    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Uncertainty semi-major    abbr=uncertaintySemiMajor
        ...    new_value=${127}    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Uncertainty semi-minor    abbr=uncertaintySemiMinor
        ...    new_value=${0}    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Orientation of major axis   abbr=orientationOfMajorAxis
        ...    new_value=${179}    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Uncertainty altitude    abbr=uncertaintyAltitude
        ...    new_value=${127}    node_index=${0}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan

    FOR    ${cell_id}    IN RANGE    1   ${CellNum+1}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Antenna gain    abbr=antennaGain
        ...    new_value=${-256}    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Maximum Antenna Range    abbr=maxAntRange
        ...    new_value=${100000}    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=SFN initialisation time    abbr=sfnInitialisationTime
        ...    new_value=${429496729}    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Terrain average height    abbr=terrainAverageHeight
        ...    new_value=${-1000}    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}
        ...    filter_param=Terrain standard deviation    abbr=terrainHeightStdDeviation
        ...    new_value=${1000}    node_index=${0}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    # Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    [Teardown]    Run keywords    Selenium Logout And Close Browser

Storing_location_into_RU_NVM_5G_AQQL
    [Arguments]
    Step1: Configure 5G LCS parameters under structure NRCELL lcsConfig
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${False}   Check_DetectedLocation=${False}
    Step2: Configure the feature flag from disabled to enabled
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${False}   Check_DetectedLocation=${True}
    Step3: Reset the gNB and then check the encrypted location info from RU NVM
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${False}   Check_DetectedLocation=${True}
    Step4: Configure the location info and then check the encrypted location info
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${True}   Check_DetectedLocation=${True}
    Step5: Updates accuracy level configuration accLevSet to high
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${True}   Check_DetectedLocation=${True}
    Step6: Configure the feature flag from enabled to disabled
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${False}   Check_DetectedLocation=${False}
    Step7: Configure the feature flag from disabled to enabled
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${True}   Check_DetectedLocation=${True}

Storing_location_into_RU_NVM_4G_AQQL
    [Arguments]
    Load Case SCF
    Remove Module position information From RU
    Step1: Configure the feature flag from enabled to disabled
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${False}   Check_DetectedLocation=${False}
    Step2: Configure the feature flag from disabled to enabled
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${False}   Check_DetectedLocation=${True}
#    Step3: Reset the gNB and then check the encrypted location info from RU NVM
#    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${False}   Check_DetectedLocation=${True}
    Step4: Configure the location info and then check the encrypted location info
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${True}   Check_DetectedLocation=${True}
    Step5: Updates accuracy level configuration accLevSet to high
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${True}   Check_DetectedLocation=${True}
    Step6: Configure the feature flag from enabled to disabled
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${False}   Check_DetectedLocation=${False}
    Step7: Configure the feature flag from disabled to enabled
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${True}   Check_DetectedLocation=${True}

Storing_location_into_RU_NVM_5G_AWHHF
    [Arguments]   ${ru_index}=1
    Load Case SCF
    Step1: Configure 5G LCS parameters under structure NRCELL lcsConfig  ru_index=${ru_index}
    Remove Module position information From RU  ru_index=${ru_index}
    Check Location Info In RU Location File  ru_index=${ru_index}   Check_ConfiguredLocation=${False}   Check_DetectedLocation=${False}
    Step2: Configure the feature flag from disabled to enabled
    Check Location Info In RU Location File  ru_index=${ru_index}   Check_ConfiguredLocation=${False}   Check_DetectedLocation=${True}
#    Step3: Reset the gNB and then check the encrypted location info from RU NVM
#    Check Location Info In RU Location File  ru_index=${ru_index}   Check_ConfiguredLocation=${False}   Check_DetectedLocation=${True}
    Step4: Configure the location info and then check the encrypted location info
    Check Location Info In RU Location File  ru_index=${ru_index}   Check_ConfiguredLocation=${True}   Check_DetectedLocation=${True}
    Step5: Updates accuracy level configuration accLevSet to high
    Check Location Info In RU Location File  ru_index=${ru_index}   Check_ConfiguredLocation=${True}   Check_DetectedLocation=${True}
    Step6: Configure the feature flag from enabled to disabled
    Check Location Info In RU Location File  ru_index=${ru_index}   Check_ConfiguredLocation=${False}   Check_DetectedLocation=${False}
    Step7: Configure the feature flag from disabled to enabled
    Check Location Info In RU Location File  ru_index=${ru_index}   Check_ConfiguredLocation=${True}   Check_DetectedLocation=${True}

Remove Module position information From RU
    [Arguments]    ${ru_index}=${1}
    log to console   Remove Module position information From RU${ru_index}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${result}   Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    filter_param=Module position information   abbr=modulePositionInformation
    Run Keyword If    '${result[0]}'=='PASS'    Run keywords    selenium_coam.validate_plan   AND
    ...   selenium_coam.activate_plan   AND
    ...   Wait Until Keyword Succeeds    5min    30s    Verify all cells should be onair   cell_type=${cell_type}
    [Teardown]    Run keywords    Selenium Logout And Close Browser


Get Location File Contents From RU
    [Arguments]    ${ru_index}=1    ${file_name}=permanent.xml    ${download_dir}=${TS_CASE_LOG_PATH}
    ...    ${remote_path}=/mnt/runtime/rfsw/uoam
    Connect to Common Unit Master
    Log to console    \n********* check RU File exists *********
    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
    csn.send command    command=cd ${remote_path};ls    connection=RU_${ru_index}
    Sleep    2s
    ${result}    csn.read output    connection=RU_${ru_index}
    Should contain     ${result}    ${file_name}
    csn.Download file    remote_path=${remote_path}/${file_name}    local_path=${download_dir}/${file_name}     connection=RU_${ru_index}
    Log to console    \n************ get file content *************
    ${bbox5_content}    Run    command=cat ${download_dir}/${file_name}
    ${local_path}    set variable   ${download_dir}/${file_name}
    csn.Disconnect    connection=RU_${ru_index}
    [Return]   ${local_path}

Check Location Info In RU Location File
    [Arguments]   ${ru_index}=1   ${Check_ConfiguredLocation}=${False}   ${Check_DetectedLocation}=${False}
    log to console   Check Location Info In RU Location File
    ${file_path}   Get Location File Contents From RU      ru_index=${ru_index}
    ${Location}   xmlparser.get_element_value   ${file_path}   ${XPATH_ConfiguredLocation}
    Run Keyword If    ${Check_ConfiguredLocation}  Check Configure Location Info From String    ${Location}
        ...    ELSE    Should Be Equal     ${Location}   ${None}

    ${Location}   xmlparser.get_element_value   ${file_path}   ${XPATH_DetectedLocation}
    Run Keyword If    ${Check_DetectedLocation}   Check Detected Location Info From String    ${Location}
        ...    ELSE    Should Be Equal     ${Location}   ${None}

    ${value}   xmlparser.get_element_value   ${file_path}   ${XPATH_btsInformation}
    Should Not Be Empty     ${value}
    ${value}   xmlparser.get_element_value   ${file_path}   ${XPATH_Timestamp}
    Should Not Be Empty     ${value}
    ${value}   xmlparser.get_element_value   ${file_path}   ${XPATH_ModuleSerialNumber}
    Run Keyword If    ${Check_DetectedLocation}   Should Not Be Empty     ${value}
        ...    ELSE    Should Be Equal     ${value}   ${None}

Check Configure Location Info From String
    [Arguments]   ${location}
#    ${input_string}   Decode Location Info   ${location}
#    ${altitude}    ${longitude}    ${latitude}   Get Location Info From String   ${input_string}
#    Should Be Equal As Numbers    ${altitude}    ${conf_altitude}
#    Should Be Equal As Numbers    ${longitude}    ${conf_longitude * 0.0000001}
#    Should Be Equal As Numbers    ${latitude}    ${conf_latitude * 0.0000001}
    Should Not Be Empty   ${location}

Check Detected Location Info From String
    [Arguments]   ${location}
#    ${input_string}   Decode Location Info   ${location}
#    ${altitude}    ${longitude}    ${latitude}   Get Location Info From String   ${input_string}
#    Should Not Be Empty    ${altitude}
#    Should Not Be Empty    ${longitude}
#    Should Not Be Empty   ${latitude}
    Should Not Be Empty   ${location}

Decode Location Info
       [Arguments]   ${Location}
       ${output}    Run    command=echo "${Location}" | base64 -d > myfile
       ${output}    Run    command=echo "${PRIVATE_KEY}" > bbox-loc_20240313.pem
       ${output}    Run    openssl pkeyutl -decrypt -inkey bbox-loc_20240313.pem -in myfile -out output-file-here.txt
       ${output}    Run    cat output-file-here.txt
       [Return]   ${output}

Get Location Info From String
    [Arguments]   ${input_string}
    @{fields}    Split String    ${input_string}    ,
    ${altitude}    Set Variable    ${EMPTY}
    ${longitude}    Set Variable    ${EMPTY}
    ${latitude}    Set Variable    ${EMPTY}
    FOR    ${field}    IN    @{fields}
        ${name}    ${value}    Split String    ${field}    =
        Run Keyword If    '${name}' == 'Altitude'    Set Test Variable    ${altitude}    ${value}
        ...    ELSE IF    '${name}' == 'Longitude'    Set Test Variable    ${longitude}    ${value}
        ...    ELSE IF    '${name}' == 'Latitude'    Set Test Variable    ${latitude}    ${value}
    END
    Log Many    ${altitude}    ${longitude}    ${latitude}
    [Return]    ${altitude}    ${longitude}    ${latitude}

Get Cell List From RU
    [Documentation]  Auther: xuewen.zhang@nokia-sbell.com
    ...               Description: return cell index for RU.
    ...               cell_type: LNCEL or NRCELL
    [Arguments]     ${ru_index}=1    ${cell_type}=NRCELL
    ${ru_info}    selenium_coam.get_ru_info   ru_index=${ru_index}
    ${cell_list_dict}=  Get From Dictionary   ${ru_info}  Cell list
    ${nrcell_list}=  Create List
    FOR  ${cell}  IN  @{cell_list_dict}
        Run Keyword If  "${cell_type}" in "${cell}"   Append To List  ${nrcell_list}  ${cell.split('-')[1]}
    END
    Log List  ${nrcell_list}
    [Return]  ${nrcell_list}

Step1: Configure 5G LCS parameters under structure NRCELL lcsConfig
    [Arguments]     ${ru_index}=1
    log to console   Step1: Configure 5G LCS parameters under structure NRCELL lcsConfig
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${cell_list}   Get Cell List From RU   ru_index=${ru_index}   cell_type=NRCELL
    FOR    ${cell_id}    IN   @{cell_list}
        ${result}   Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=LCS configuration   abbr=lcsConfig
        Run Keyword If    '${result[0]}'=='PASS'    Run keywords    selenium_coam.validate_plan   AND
        ...   selenium_coam.activate_plan   AND
        ...   Wait Until Keyword Succeeds    5min    30s    Verify all cells should be onair   cell_type=${cell_type}
        selenium_coam.add_element
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=LCS configuration    abbr=lcsConfig    timeout=15
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Antenna opening    abbr=antennaOpening
        ...    new_value=${10}    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Antenna orientation    abbr=antennaOrientation
        ...    new_value=${20}    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Geographical area identity uncertainty   abbr=gaiUncertainty
        ...    new_value=${1}    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=LCS information    abbr=lcsInformation
        ...    new_value=inService    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Potential repeater   abbr=potentialRepeater
        ...    new_value=withoutRepeater    node_index=${0}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    # Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    [Teardown]    Run keywords    Selenium Logout And Close Browser

Step${step_id}: Configure the feature flag from ${old_value} to ${actLocInfoStore}
    [Arguments]
    log to console   Step${step_id}: Configure the feature flag from ${old_value} to ${actLocInfoStore}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${actLocInfoStore}    set variable if      '${actLocInfoStore}'=='enabled'    true   false
    Selenium Login And Disable Screen Lock    version=${stream}
    Run Keyword And Ignore Error    selenium_coam.delete_parameter    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=List of parameters prevented to be modified    abbr=preventParamModifList
    ...    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate location information store    abbr=actLocInfoStore
    ...    new_value=${actLocInfoStore}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Accuracy level setting   abbr=accLevSet
    ...    new_value=Low    node_index=${0}
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    [Teardown]    Run keywords    Selenium Logout And Close Browser

Step3: Reset the gNB and then check the encrypted location info from RU NVM
   [Arguments]
   log to console   Step3: Reset the gNB and then check the encrypted location info from RU NVM
   Perform BTS Site Reset
   Sleep   500s
   Connect to gnb coam via ssl
   Wait Until Keyword Succeeds    6min    30s    Verify all cells should be onair   cell_type=${cell_type}

Step4: Configure the location info and then check the encrypted location info
    [Arguments]    ${RU_index}=${1}
    log to console   Step4: Configure the location info and then check the encrypted location info
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${result}   Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}
    ...    filter_param=Module position information   abbr=modulePositionInformation
    Run Keyword If    '${result[0]}'=='PASS'    Run keywords    selenium_coam.validate_plan   AND
    ...   selenium_coam.activate_plan   AND
    ...   Wait Until Keyword Succeeds    5min    30s    Verify all cells should be onair   cell_type=${cell_type}
    selenium_coam.add_element
    ...    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}
    ...    filter_param=Module position information   abbr=modulePositionInformation    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}
    ...    filter_param=Altitude    abbr=altitude
    ...    new_value=${conf_altitude}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}
    ...    filter_param=Latitude    abbr=latitude
    ...    new_value=${conf_latitude}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}
    ...    filter_param=Longitude   abbr=longitude
    ...    new_value=${conf_longitude}    node_index=${0}
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    [Teardown]    Run keywords    Selenium Logout And Close Browser

Step5: Updates accuracy level configuration accLevSet to high
    [Arguments]
    log to console   Step5: Updates accuracy level configuration accLevSet to high
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${CellNum}    set variable     ${1}
    FOR    ${cell_id}    IN RANGE    1   ${CellNum+1}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    filter_param=Accuracy level setting   abbr=accLevSet
        ...    new_value=High    node_index=${0}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    [Teardown]    Run keywords    Selenium Logout And Close Browser

Storing_location_into_RU_NVM_with_removing_configured_modulePositionInformation
    [Arguments]
    Step1: Configure the feature flag and accuracy level and the location info
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${True}   Check_DetectedLocation=${True}
    Step2: Remove the configured modulePositionInformation from the MO of RU
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${False}   Check_DetectedLocation=${True}

Step1: Configure the feature flag and accuracy level and the location info
    [Arguments]
    Step1: Configure 5G LCS parameters under structure NRCELL lcsConfig
    Step2: Configure the feature flag from disabled to enabled
    Step4: Configure the location info and then check the encrypted location info

Step2: Remove the configured modulePositionInformation from the MO of RU
    [Arguments]    ${RU_index}=${1}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${result}   Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}
    ...    filter_param=Module position information   abbr=modulePositionInformation
    Run Keyword If    '${result[0]}'=='PASS'    Run keywords    selenium_coam.validate_plan   AND
    ...   selenium_coam.activate_plan   AND
    ...   Wait Until Keyword Succeeds    5min    30s    Verify all cells should be onair   cell_type=${cell_type}
    [Teardown]    Run keywords    Selenium Logout And Close Browser

Clear_location_info_in_RU_NVM
    [Arguments]
    Step1: Configure the feature flag and accuracy level and the location info
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${True}   Check_DetectedLocation=${True}
    Step2: Configure the feature flag from enabled to disabled
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${False}   Check_DetectedLocation=${False}
    Perform RU Reset
    Check Location Info In RU Location File  ru_index=1   Check_ConfiguredLocation=${False}   Check_DetectedLocation=${False}
