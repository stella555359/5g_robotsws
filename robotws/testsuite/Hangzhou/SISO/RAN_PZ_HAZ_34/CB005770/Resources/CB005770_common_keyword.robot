*** Settings ***
Variables    ./variables_5770.py
Library    ../lib/check_errors.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot

Documentation
...    author: Shufei Chen
...    contact: shufei.chen@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}

*** Keywords ***
Modify the Parameters On Webem
    [Arguments]  ${modify_params}  ${is_activate}=${True}  ${despite_errors}=${False}    ${bts_configuration}=Planned
    FOR  ${item}  IN  @{modify_params}
        selenium_coam.set_parameter_value    dist_name=${item}[dist_name]    bts_configuration=${bts_configuration}
        ...    filter_param=${item}[filter_param]
        ...    abbr=${item}[p_name]    new_value=${item}[value]
    END

WebEM_Online_Static_HW_Capabilities_Validation_With_Beamforming_Set_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify gNB static HW validation function with WebEM online.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.14.2021 - - Created
    ...    *******************
    ...    shufei.chen@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AEQQ_normal.xml
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-5947/NRBTS-5947/NRCELL-1  filter_param=Basic Beam Set
    ...    p_name=basicBeamSet    value=${beamset_modify}
    append to list  ${modify_params}  ${item}
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors}=    catenate    SEPARATOR=    it is required that NRCELL-1.beamSet-1.basicBeamSet (value: beamSet_2_2_2_2
    ...    ) is equal to one of the pre-defined beam set values supported by the related radio
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-5947/NRBTS-5947/NRCELL-1.beamSet-1
    ...    msg=${errors}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_ANT_PHYANT_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify gNB static HW validation function with WebEM online.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.14.2021 - - Created
    ...    *******************
    ...    shufei.chen@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    log to console  ${CURDIR}
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    log to console    ${SCF_PATH}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AZQR.xml
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors}=    catenate    SEPARATOR=    If Radio module supports antenna line connectors under the related RMOD ther
    ...    e shall be ANTL object and no PHYANT object defined
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-5941/EQM-1/APEQM-1/RMOD-1
    ...    msg=${errors}
    should be equal as strings  ${status}    True
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AEQQ.xml
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors}=    catenate    SEPARATOR=    If Radio module not supports antenna line connectors (integrated antenna pan
    ...    els are used) under the related RMOD there shall be PHYANT object and no ANTL object defined
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-5947/EQM-1/APEQM-1/RMOD-1
    ...    msg=${errors}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_Bandwidth_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify gNB static HW validation function with WebEM online.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.14.2021 - - Created
    ...    *******************
    ...    shufei.chen@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AZQF_normal.xml
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-5954/NRBTS-5954/NRCELL-1
    ...    filter_param=Channel bandwidth    p_name=chBw    value=${chbw_modify}
    append to list  ${modify_params}  ${item}
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-5954/NRBTS-5954/NRCELL-1
    ...    msg=Value of NRCELL-1.chBw (value: ${chbw_modify}) must be supported by the Radio Module
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_ANT_Port_ID_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify gNB static HW validation function with WebEM online.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.14.2021 - - Created
    ...    *******************
    ...    shufei.chen@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AHPF_normal.xml
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-51142/EQM-1/APEQM-1/RMOD-1/ANTL-4
    ...    filter_param=Antenna port identifier    p_name=antPortId    value=5
    append to list  ${modify_params}  ${item}
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-51142/EQM-1/APEQM-1/RMOD-1/ANTL-4
    ...    msg=The antPortId must be contained by portNo
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_Frequency_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify gNB static HW validation function with WebEM online.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.14.2021 - - Created
    ...    *******************
    ...    shufei.chen@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AZQF_normal.xml
    ${modify_params}  create list
    ${nrarfcn}    evaluate    ${AZQF_20M_nrarfcn_min} - 2
    ${item}  create dictionary  dist_name=MRBTS-5954/NRBTS-5954/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    p_name=nrarfcn    value=${nrarfcn}
    append to list  ${modify_params}  ${item}
    #AZQF_lower_than_min_value
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors_tx_min}=    catenate    SEPARATOR=    is not in allowed range defined by minimum TX frequency for 5G band configur
    ...    ed in freqBandIndicatorNR supported by the ANTL Radio Module
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-5954/NRBTS-5954/NRCELL-1
    ...    msg=${errors_tx_min}
    ${errors_rx_min}=    catenate    SEPARATOR=    is not in allowed range defined by minimum RX frequency for 5G band configur
    ...    ed in freqBandIndicatorNR supported by the ANTL Radio Module
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-5954/NRBTS-5954/NRCELL-1
    ...    msg=${errors_rx_min}
    should be equal as strings  ${status}    True
    ${modify_params}  create list
    ${nrarfcn}    evaluate    ${AZQF_20M_nrarfcn_max} + 2
    ${item}  create dictionary  dist_name=MRBTS-5954/NRBTS-5954/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    p_name=nrarfcn    value=${nrarfcn}
    append to list  ${modify_params}  ${item}
    #AZQF_higher_than_max_value
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors_tx_max}=    catenate    SEPARATOR=     is not in allowed range defined by maximum TX frequency for 5G band configu
    ...    red in freqBandIndicatorNR supported by the ANTL Radio Module
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-5954/NRBTS-5954/NRCELL-1
    ...    msg=${errors_tx_max}
    should be equal as strings  ${status}    True
    ${errors_rx_max}=    catenate    SEPARATOR=     is not in allowed range defined by maximum RX frequency for 5G band configu
    ...    red in freqBandIndicatorNR supported by the ANTL Radio Module
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-5954/NRBTS-5954/NRCELL-1
    ...    msg=${errors_rx_max}
    should be equal as strings  ${status}    True
    # AAHF_ul_dl_lower_than_min_value
    selenium_coam.refresh_page    wait_bar_menu_timeout=300
#    sleep    5
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AHPF_normal.xml
    ${nrarfcn_ul_min}    evaluate    ${AHPF_20M_nrarfcn_min_ul} - 20
    ${nrarfcn_dl_min}    evaluate    ${AHPF_20M_nrarfcn_min_dl} - 20
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-51142/NRBTS-51142/NRCELL-1/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in downlink
    ...    p_name=nrarfcnDl    value=${nrarfcn_dl_min}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-51142/NRBTS-51142/NRCELL-1/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in uplink
    ...    p_name=nrarfcnUl    value=${nrarfcn_ul_min}
    append to list  ${modify_params}  ${item}
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-51142/NRBTS-51142/NRCELL-1/NRCELL_FDD-1
    ...    msg=${errors_tx_min}
    should be equal as strings  ${status}    True
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-51142/NRBTS-51142/NRCELL-1/NRCELL_FDD-1
    ...    msg=${errors_rx_min}
    should be equal as strings  ${status}    True
    # AAHF_ul_dl_higher_than_max_value
    selenium_coam.refresh_page    wait_bar_menu_timeout=300
#    sleep    5
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AHPF_normal.xml
    ${nrarfcn_ul_max}    evaluate    ${AHPF_20M_nrarfcn_max_ul} + 20
    ${nrarfcn_dl_max}    evaluate    ${AHPF_20M_nrarfcn_max_dl} + 20
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-51142/NRBTS-51142/NRCELL-1/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in downlink
    ...    p_name=nrarfcnDl    value=${nrarfcn_dl_max}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-51142/NRBTS-51142/NRCELL-1/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in uplink
    ...    p_name=nrarfcnUl    value=${nrarfcn_ul_max}
    append to list  ${modify_params}  ${item}
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-51142/NRBTS-51142/NRCELL-1/NRCELL_FDD-1
    ...    msg=${errors_tx_max}
    should be equal as strings  ${status}    True
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-51142/NRBTS-51142/NRCELL-1/NRCELL_FDD-1
    ...    msg=${errors_rx_max}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

Modify beamformingtype On Webem And Check errors
    [Arguments]    ${filter_param}   ${p_name}   ${value}   ${module}    ${msg}    ${mrbts_id}    ${nrbts_id}
    ...    ${bts_configuration}=Planned
    log to console  ${value}
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1  filter_param=${filter_param}
    ...    p_name=${p_name}    value=${value}
    append to list  ${modify_params}  ${item}
    Modify the Parameters On Webem    modify_params=${modify_params}    bts_configuration=${bts_configuration}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=${module}
    ...    msg=${msg}
    [Return]    ${status}

WebEM_Online_Static_HW_Capabilities_Validation_With_Beamforming_Type_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify gNB Beamforming type configuration with WebEM online.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.19.2021 - - Created
    ...    *******************
    ...    zhenzhen.ren@nokia-sbell.com
    ${mrbts_id_dic}    create dictionary    AEQQ=5947    AZQF=5954    AZQO=1134
    ${nrbts_id_dic}    create dictionary    AEQQ=5947    AZQF=5954   AZQO=1134
    ${ru_list}    create list    AEQQ  AZQF  AZQO
    ${AEQQ_sta}    create list    False  False  False  False  True  False
    ${AZQF_sta}    create list    True  True  False  False  True  False
    ${AZQO_sta}    create list    False  False  False  False  False  False
    ${Status_dic}    create dictionary    AEQQ=${AEQQ_sta}    AZQF=${AZQF_sta}    AZQO=${AZQO_sta}
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    FOR  ${ru_name}  IN  @{ru_list}
        selenium_coam.refresh_page    wait_bar_menu_timeout=300
#        sleep    5
        selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_${ru_name}_normal.xml
        selenium_coam.validate_plan
        ${mrbts_id}    Get From Dictionary    ${mrbts_id_dic}    ${ru_name}
        ${nrbts_id}    Get From Dictionary    ${nrbts_id_dic}    ${ru_name}
        ${status_list}    create list
        ${status1}   modify beamformingtype On Webem And Check errors
        ...    filter_param=Activate Beamforming
        ...    p_name=actBeamforming    value=true    module=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
        ...    msg= it is required that NRCELL-1.actBeamforming (value: true) is not equal to true
        ...    mrbts_id=${mrbts_id}
        ...    nrbts_id=${nrbts_id}
        ${status1}    convert to string    ${status1}
        append to list    ${status_list}    ${status1}
        ${errors}=    catenate    SEPARATOR=    Whenever NRCELL-1.actBeamforming (value: true) is equal to true, it is r
        ...    equired that related Radio module must support beamforming types for the 5G massive MIMO radios
        ${status2}   modify beamformingtype On Webem And Check errors
        ...    filter_param=Activate Beamforming
        ...    p_name=actBeamforming    value=true    module=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
        ...    msg=${errors}
        ...    mrbts_id=${mrbts_id}
        ...    nrbts_id=${nrbts_id}
        ${status2}    convert to string    ${status2}
        append to list    ${status_list}    ${status2}
        ${status3}   modify beamformingtype On Webem And Check errors
        ...    filter_param=Activate Beamforming
        ...    p_name=actBeamforming    value=false    module=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
        ...    msg= it is required that NRCELL.actBeamforming not equal to true
        ...    mrbts_id=${mrbts_id}
        ...    nrbts_id=${nrbts_id}
        ${status3}    convert to string    ${status3}
        append to list    ${status_list}    ${status3}
        ${status4}   modify beamformingtype On Webem And Check errors
        ...    filter_param=Activate Beamforming
        ...    p_name=actBeamforming    value=false    module=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
#        ...    msg=it is required that RMOD_BP_R.bfType is within range Digital|Analog
        ...    msg=${errors}
        ...    mrbts_id=${mrbts_id}
        ...    nrbts_id=${nrbts_id}
        ${status4}    convert to string    ${status4}
        append to list    ${status_list}    ${status4}
        ${release}    Get program version based on gNB active version
        ${errors_21A}=    catenate    SEPARATOR=    it is required that related Radio module supports antenna line connector
        ...    s and beamforming types for the radio is Digital
        ${errors_SBTS}=    catenate    SEPARATOR=    it is required that related Radio module supports antenna line connector
        ...    s and beamforming types for the 5G massive MIMO radios is Digital
        ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
        ...    ELSE    set variable    ${errors_SBTS}
        ${status5}   modify beamformingtype On Webem And Check errors
        ...    filter_param=Activate external antenna beamforming
        ...    p_name=actExternalAntennaBF    value=true    module=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
        ...    msg=${errors}
        ...    mrbts_id=${mrbts_id}
        ...    nrbts_id=${nrbts_id}
        ${status5}    convert to string    ${status5}
        append to list    ${status_list}    ${status5}
        ${status6}   modify beamformingtype On Webem And Check errors
        ...    filter_param=Activate external antenna beamforming
        ...    p_name=actExternalAntennaBF    value=false    module=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
        ...    msg=it is required that NRCELL.actExternalAntennaBF not equal to true
        ...    mrbts_id=${mrbts_id}
        ...    nrbts_id=${nrbts_id}
        ${status6}    convert to string    ${status6}
        append to list    ${status_list}    ${status6}
        ${RU_status}    Get From Dictionary    ${Status_dic}    ${ru_name}
        should be equal    ${status_list}    ${RU_status}
    END
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_Carriers_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of carriers
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AZQR_8CC.xml
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${antl_index_list}    create list    1    2    3    4
    FOR  ${index}  IN  @{antl_index_list}
        ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-5941/EQM-1/APEQM-1/RMOD-1/ANTL-${index}
        ...    msg=number of NR cells TX CHANNELs is higher than supported by radio module
        should be equal as strings  ${status}    True
    END
    selenium_coam.refresh_page    wait_bar_menu_timeout=300
#    sleep    5
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AEQQ_3CC.xml
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${release}    Get program version based on gNB active version
    ${errors}    Run keyword if    '${release}'=='master'
    ...    set variable    Number of LCELNR with CHANNELGROUP/CHANNEL.resourceDN contains this RMOD is higher than supported by radio module    ELSE
    ...    set variable    Number of LCELNR with CHANNELGROUP/CHANNEL:resourceDN contains this RMOD is higher than supported by radio module
    ${status}    get_errors_common    error_msg=${hardware_errors}  module=MRBTS-5995/EQM-1/APEQM-1/RMOD-1
    ...    msg=${errors}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_Cell_Power_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verity hw capabilities of cell power
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AEQQ_normal.xml
    ${pmax}    evaluate    ${AEQQ_pmax} + 1
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-5947/NRBTS-5947/NRCELL-1  filter_param=Maximum output power
    ...    p_name=pMax    value=${pmax}
    append to list  ${modify_params}  ${item}
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${release}    Get program version based on gNB active version
    ${errors_21A}    set variable    value of pMax must be supported by radio module
    ${errors_SBTS}    set variable    value of pMax can be set to any value that not exceed the maximum value supported by radio module
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE    set variable    ${errors_SBTS}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-5947/NRBTS-5947/NRCELL-1
    ...    msg=${errors}
    should be equal as strings  ${status}    True
    #check AHBCC
    selenium_coam.refresh_page    wait_bar_menu_timeout=300
#    sleep    5
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AHBCC_normal.xml
    ${pmax}    evaluate    ${AHBCC_pmax} + 1
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-992/NRBTS-1107/NRCELL-1  filter_param=Maximum output power
    ...    p_name=pMax    value=${pmax}
    append to list  ${modify_params}  ${item}
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-992/NRBTS-1107/NRCELL-1
    ...    msg=value of pMax is not supported by radio module for selected band
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_MultiBand_Bandwidth_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of multiband bandwidth
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AHBCC_normal.xml
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-992/NRBTS-1107/NRCELL-1/NRCELL_FDD-1  filter_param=Channel bandwidth in downlink
    ...    p_name=chBwDl    value=30MHz
    append to list  ${modify_params}  ${item}
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-992/NRBTS-1107/NRCELL-1/NRCELL_FDD-1
    ...    msg=Value of NRCELL_FDD-1.chBwDl (value: 30MHz) must be supported by the Radio Module
    should be equal as strings  ${status}    True
    selenium_coam.refresh_page    wait_bar_menu_timeout=300
#    sleep    5
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AHBCC_normal.xml
    ${item}  create dictionary  dist_name=MRBTS-992/NRBTS-1107/NRCELL-1/NRCELL_FDD-1  filter_param=Channel bandwidth in uplink
    ...    p_name=chBwUl    value=30MHz
    append to list  ${modify_params}  ${item}
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-992/NRBTS-1107/NRCELL-1/NRCELL_FDD-1
    ...    msg=Value of NRCELL_FDD-1.chBwUl (value: 30MHz) must be supported by the Radio Module
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_RMOD_EAC_lines_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of RMOD EAC
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AEQQ_RMOD.xml
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-51003/EQM-1/APEQM-1/RMOD-1/EAC_OUT-2
    ...    msg=portId value must be less than or equal to number of supported EAC outputs for this RMOD
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_SMOD_EAC_lines_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of SMOD EAC
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AEQQ_SMOD.xml
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${release}    Get program version based on gNB active version
    ${errors_21A}    set variable    EAC_IN.PortId - value must be included in NumOfEACInputs parameter range
    ${errors_SBTS}    set variable    it is required that EAC_IN.portId - value must be supported by SMOD - Number of EAC inputs)
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE    set variable    ${errors_SBTS}
    ${module_21A}    set variable    MRBTS-51003/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ${module_SBTS}    set variable    MRBTS-51003/MNL-1
    ${module}    Run keyword if    '${release}'=='21A'     set variable    ${module_21A}
    ...    ELSE    set variable    ${module_SBTS}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=${module}
    ...    msg=${errors}
    Run keyword if    '${release}'=='21A'    should be equal as strings  ${status}    True
    ${errors}    Run keyword if    '${release}'=='master' or '${release}'=='SBTS22R3'
    ...    set variable    EAC_OUT.PortId - value must be included in EAC outputs on system module    ELSE
    ...    set variable    it is required that EAC_OUT.portId less/equal to SMOD_BP_R-1.numOfEACOutputs
    ${module}    Run keyword if    '${release}'=='master' or '${release}'=='SBTS22R3'
    ...    set variable    MRBTS-51003/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_OUT-1    ELSE
    ...    set variable    MRBTS-51003/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=${module}
    ...    msg=${errors}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_Passive_MHA_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of passive MHA
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_UHIE.xml
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-5945/EQM-1/HWTOP-1/LOGLINK-2
    ...    msg=LOGLINK is pointing to ALD/LNA where controlProtocol is set to CWA and ANTL of RMOD that does not support passive MHA
    should be equal as strings  ${status}    True
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-5945/EQM-1/HWTOP-1/LOGLINK-4
    ...    msg=LOGLINK is pointing to ALD/LNA where controlProtocol is set to CWA and ANTL of RMOD that does not support passive MHA
    should be equal as strings  ${status}    True
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-5945/EQM-1/HWTOP-1/LOGLINK-2  filter_param=Link Mode Data
    ...    p_name=linkModeData    value=false
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-5945/EQM-1/HWTOP-1/LOGLINK-4  filter_param=Link Mode Data
    ...    p_name=linkModeData    value=false
    append to list  ${modify_params}  ${item}
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-5945/EQM-1/HWTOP-1/LOGLINK-2
    ...    msg=LOGLINK is pointing to ALD/LNA where controlProtocol is set to CWA and ANTL of RMOD that does not support passive MHA
    should be equal as strings  ${status}    False
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_MHA_TxGain_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of MHA TxGain
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AHPF_TxGain.xml
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-51142/EQM-1/APEQM-1/ALD-1/LNA-1  filter_param=Mast head amplifier gain
    ...    p_name=gain   value=14
    append to list  ${modify_params}  ${item}
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-51142/EQM-1/APEQM-1/RMOD-1
    ...    msg=then the allowable value of ALD-z/LNA-q.gain shall be 12 or 13
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_VSWR_Measurement_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of VSWR Measurement
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AHPF_normal.xml
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-51142/EQM-1/APEQM-1/RMOD-1/ANTL-1
    ...    filter_param=VSWR minor alarm threshold
    ...    p_name=vswrMinorThreshold   value=1
    append to list  ${modify_params}  ${item}
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${release}    Get program version based on gNB active version
    ${errors_21A_minor}=    catenate    SEPARATOR=    it is required that ANTL-1.vswrMinorThreshold (value: 1) greater/e
                  ...    qual to ANTL_BP_R.vswrMinorAlarmMinThreshold)
    ${errors_SBTS_minor}    set variable    ANTL.vswrMinorThreshold is lower than
    ${errors_21A_major}=    catenate    SEPARATOR=    it is required that ANTL-1.vswrMajorThreshold (value: 4) less/equa
                  ...    l to ANTL_BP_R.vswrMajorAlarmMaxThreshold)
    ${errors_SBTS_major}    set variable    ANTL.vswrMajorThreshold exceeded
    ${errors_minor}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A_minor}
    ...    ELSE    set variable    ${errors_SBTS_minor}
    ${errors_major}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A_major}
    ...    ELSE    set variable    ${errors_SBTS_major}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-51142/EQM-1/APEQM-1/RMOD-1/ANTL-1
    ...    msg=${errors_minor}
    should be equal as strings  ${status}    True
    selenium_coam.refresh_page    wait_bar_menu_timeout=300
#    sleep    5
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AHPF_normal.xml
    ${item}  create dictionary  dist_name=MRBTS-51142/EQM-1/APEQM-1/RMOD-1/ANTL-1
    ...    filter_param=VSWR major alarm threshold
    ...    p_name=vswrMajorThreshold   value=4
    append to list  ${modify_params}  ${item}
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-51142/EQM-1/APEQM-1/RMOD-1/ANTL-1
    ...    msg=${errors_major}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_Split_Mode_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of split mode
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AEQE.xml
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${release}    Get program version based on gNB active version
    ${errors_21A}=    catenate    SEPARATOR=    When NRCELL.mMimoAntArrayMode equals Left 32TRX Array (4x4x2) in the relate
                  ...    d RMOD there must be value Left defined in RMOD_BP_R.mimoAntArrayMode
    ${errors_SBTS}=    catenate    SEPARATOR=    Whenever NRCELL-1.mMimoAntArrayMode (value: Left 32TRX Array (4x4x2)) is equ
                  ...    al to Left 32TRX Array (4x4x2), it is required that related RMOD must support Left massive MIM
                  ...    O (mMIMO) antenna array mode
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE    set variable    ${errors_SBTS}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-5947/NRBTS-5947/NRCELL-1    msg=${errors}
    should be equal as strings  ${status}    True
    selenium_coam.refresh_page    wait_bar_menu_timeout=300
#    sleep    5
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AAHF.xml
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors_21A}=    catenate    SEPARATOR=    When NRCELL.mMimoAntArrayMode equals Bottom 32TRX Array (2x8x2) in the relate
                  ...    d RMOD there must be value Bottom defined in RMOD_BP_R.mimoAntArrayMode
    ${errors_SBTS}=    catenate    SEPARATOR=    Whenever NRCELL-1.mMimoAntArrayMode (value: Bottom 32TRX Array (2x8x2)) is w
                  ...    ithin range Bottom 32TRX Array (2x8x2)|Bottom 16TRX Array (1x8x2), it is required that related R
                  ...    MOD must support Bottom massive MIMO (mMIMO) antenna array mode
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE    set variable    ${errors_SBTS}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-5947/NRBTS-5947/NRCELL-1    msg=${errors}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_SFP_Speed_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of sfp speed
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AEQQ_normal.xml
    ${release}    Get program version based on gNB active version
    ${errors_21A}    set variable    inkSpeed can only be configured to value supported by the radio module
    ${errors_SBTS}    set variable    linkSpeed cannot be set to value not supported by the radio module
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE    set variable    ${errors_SBTS}
    FOR  ${speed}  IN  @{linkspeed}
         ${modify_params}  create list
         ${item}  create dictionary  dist_name=MRBTS-5947/EQM-1/HWTOP-1/CABLINK-2
         ...    filter_param=Link speed
         ...    p_name=linkSpeed    value=${speed}
         append to list  ${modify_params}  ${item}
         Modify the Parameters On Webem    modify_params=${modify_params}
         selenium_coam.validate_plan
         ${hardware_errors}      selenium_coam.get_hardware_errors
         log to console    ${hardware_errors}
         ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-5947/EQM-1/APEQM-1/RMOD-1
         ...    msg=${errors}
         ${result}    set variable if    '${speed}'=='Cpri7' or '${speed}'=='eCpri10' or '${speed}'=='eCpri25'    False    True
         should be equal as strings  ${status}    ${result}
     END
    #AZQF
    selenium_coam.refresh_page    wait_bar_menu_timeout=300
#    sleep    5
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AZQF_normal.xml
    FOR  ${speed}  IN  @{linkspeed}
         ${modify_params}  create list
         ${item}  create dictionary  dist_name=MRBTS-5954/EQM-1/HWTOP-1/CABLINK-2
         ...    filter_param=Link speed
         ...    p_name=linkSpeed    value=${speed}
         append to list  ${modify_params}  ${item}
         Modify the Parameters On Webem    modify_params=${modify_params}
         selenium_coam.validate_plan
         ${hardware_errors}      selenium_coam.get_hardware_errors
         log to console    ${hardware_errors}
         ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-5954/EQM-1/APEQM-1/RMOD-1
         ...    msg=${errors}
         ${result}    set variable if    '${speed}'=='Obsai6Gbps' or '${speed}'=='Cpri6' or '${speed}'=='Cpri7'    False    True
         should be equal as strings  ${status}    ${result}
    END
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_Path_Delay_Measurement_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of path delay measurement
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AZQF_Delay_Measurement.xml
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${release}    Get program version based on gNB active version
    ${errors_21A}    set variable    RMOD_BP_R.antennaDelayMeasurementSupported equal to true
    ${errors_SBTS}    set variable    it is required that at least one Radio Module which supports antenna delay measurements is commissioned
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE    set variable    ${errors_SBTS}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-5941/MNL-1/MNLENT-1/FEATCADM-1
    ...    msg=${errors}
    should be equal as strings  ${status}    True
    ${errors_21A}=    catenate    SEPARATOR=    Whenever ANTL-1 having ANTL-1.antennaPathDeltaGroupDelay (value: 100ns) is c
                  ...    onfigured, it is required that embedded assertion valid (Namely: It is required that there exis
                  ...    t MOs FEATCADM-* having FEATCADM.actAntennaPathDelayMeasurement equal to true) and embedded ass
                  ...    ertion valid (Namely: It is required that there exist MOs RMOD_R/RMOD_BP_R, whenever RMOD_R-* h
                  ...    aving RMOD_R.configDN equal to MRBTS-5941/EQM-1/APEQM-1/RMOD-1.distname, RMOD_BP_R-* having RMO
                  ...    D_BP_R.antennaDelayMeasurementSupported equal to true)
    ${errors_SBTS}=    catenate    SEPARATOR=    ANTL-1.antennaPathDeltaGroupDelay (value: 100ns) can be set only if activat
                  ...    e antenna path delay measurement (FEATCADM.actAntennaPathDelayMeasurement) is set to true and r
                  ...    adio module supports antenna delay measurements
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE    set variable    ${errors_SBTS}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-5941/EQM-1/APEQM-1/RMOD-1/ANTL-1    msg=${errors}
    should be equal as strings  ${status}    True
    ${errors_21A}=    catenate    SEPARATOR=    Whenever ANTL-1 having ANTL-1.useMeasuredRoundTripDelay (value: true) equa
                  ...    l to true, it is required that embedded assertion valid (Namely: It is required that there exis
                  ...    t MOs RMOD_R/RMOD_BP_R, whenever RMOD_R-* having RMOD_R.configDN equal to MRBTS-5941/EQM-1/APEQ
                  ...    M-1/RMOD-1.distname, RMOD_BP_R-* having RMOD_BP_R.antennaDelayMeasurementSupported equal to true)
    ${errors_SBTS}=    catenate    SEPARATOR=    Whenever ANTL-1.useMeasuredRoundTripDelay (value: true) is equal to true, i
                  ...    t is required that radio connected to the antenna has RMOD_BP_R:antennaDelayMeasurementSupporte
                  ...    d set to true
    ${errors_master}=    catenate    SEPARATOR=    Whenever ANTL-1.useMeasuredRoundTripDelay (value: true) is equal to true, i
                  ...    t is required that radio connected to the antenna supports antenna delay measurements
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE IF    '${release}'=='master'     set variable    ${errors_master}
    ...    ELSE    set variable    ${errors_SBTS}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-5941/EQM-1/APEQM-1/RMOD-1/ANTL-1    msg=${errors}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_RAT_Sharing_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of RAT sharing
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AEQQ_RAT_Sharing.xml
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-995/EQM-1/SMOD_EXT-1  filter_param=Evolved universal terrestrial radio access
    ...    p_name=eutraSupport   value=true
    append to list  ${modify_params}  ${item}
    Modify the Parameters On Webem    modify_params=${modify_params}
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${release}    Get program version based on gNB active version
    ${errors_21A}    set variable    a CABLINK between RMOD and SMOD_EXT, then if SMOD_EXT supports GERAN, then RMOD must also support GERAN
    ${errors_SBTS}=    catenate    SEPARATOR=    CABLINK instance must not exist if RMOD does not support GERAN when cable li
                  ...    nk connect SMOD_EXT with geranSupport = true to a radio module
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE    set variable    ${errors_SBTS}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-995/EQM-1/SMOD_EXT-1
    ...    msg=${errors}
    should be equal as strings  ${status}    True
    ${errors_21A}    set variable    a CABLINK between RMOD and SMOD_EXT, then if SMOD_EXT supports UTRAN, then RMOD must also support UTRAN
    ${errors_SBTS}=    catenate    SEPARATOR=    CABLINK instance must not exist if RMOD does not support UTRAN when cable li
                  ...    nk connect SMOD_EXT with utranSupport = true to a radio module
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE    set variable    ${errors_SBTS}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-995/EQM-1/SMOD_EXT-1
    ...    msg=${errors}
    should be equal as strings  ${status}    True
    ${errors_21A}    set variable    a CABLINK between RMOD and SMOD_EXT, then if SMOD_EXT supports EUTRAN, then RMOD must also support EUTRAN
    ${errors_SBTS}=    catenate    SEPARATOR=    CABLINK instance must not exist if RMOD does not support EUTRA when cable l
                  ...    ink connect SMOD_EXT with eutraSupport = true to a radio module
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE    set variable    ${errors_SBTS}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-995/EQM-1/SMOD_EXT-1
    ...    msg=${errors}
    should be equal as strings  ${status}    True
#    ${errors_21A}=    catenate    SEPARATOR=    a CABLINK between RMOD and SMOD_EXT, then if SMOD_EXT supports SRAN, the
#                  ...    n RMOD must also support EUTRA or UTRAN or GERAN
#    ${errors_SBTS}=    catenate    SEPARATOR=    CABLINK instance must not exist if RMOD does not support SRAN when cable lin
#                  ...    k connect SMOD_EXT with sranSupport = true to a radio module
#    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
#    ...    ELSE    set variable    ${errors_SBTS}
#    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-995/EQM-1/SMOD_EXT-1
#    ...    msg=${errors}
#    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_RET_Port_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of RET port
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AZQR_RET_Port.xml
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-5945/EQM-1/APEQM-1/RMOD-1/ANTL-1
    ...    msg=If there is no connectorType = RET for the RMOD, then there should be no loglink pointing to RET port
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_Cell_Duplex_Mode_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of cell duplex mode
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AZQR_Cell_Duplex_Mode.xml
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${release}    Get program version based on gNB active version
    ${errors_21A}=    catenate    SEPARATOR=    If there exists a CABLINK that connects BBMOD object and RMOD object that su
                  ...    pports TDD, then all other RMOD objects connected to this BBMOD object must also support TDD
    ${errors_SBTS1}=    catenate    SEPARATOR=    If there exists at least one CABLINK that connects BBMOD and RMOD which i
                  ...    s supporting only FDD technology then all other RMODs connected to this BBMOD must also support F
                  ...    DD technology
    ${errors_SBTS2}=    catenate    SEPARATOR=    If there exists at least one CABLINK that connects BBMOD and RMOD which i
                  ...    s supporting only TDD technology then all other RMODs connected to this BBMOD must also support T
                  ...    DD technology
    @{errors_SBTS}=    create list    ${errors_SBTS1}    ${errors_SBTS2}
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE    set variable    ${errors_SBTS}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-5941/EQM-1/APEQM-1/RMOD-1    msg=${errors}
    should be equal as strings  ${status}    True
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE    set variable    ${errors_SBTS}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-5941/EQM-1/APEQM-1/RMOD-2    msg=${errors}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser

WebEM_Online_Static_HW_Capabilities_Validation_With_Radio_Protocol_Type_Configuration
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify hw capabilities of radio protocol type
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.23.2021 - - Created
    ...    *******************
    ...    jiangjin.lin@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -10
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AZQR_Protocol_Type.xml
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${release}    Get program version based on gNB active version
    ${errors_21A}=    catenate    SEPARATOR=   Whenever NRCELL-1.numberOfRxBeamforming (value: 4Rx) is equal to 4Rx, it is r
                  ...    equired that the cell linked RMOD has parameter interfaceType contains eCPRI and the cell linke
                  ...    d BBMOD/SMOD has list socVariant contains Loki or Loner
    ${errors_SBTS}=    catenate    SEPARATOR=   Whenever NRCELL-1.numberOfRxBeamforming (value: 4Rx) is equal to 4Rx, it is r
                  ...    equired that the cell linked RMOD has parameter interfaceType contains eCPRI and the cell linke
                  ...    d BBMOD/SMOD has list socVariant contains Loki or Loner
#    ${errors_master}=    catenate    SEPARATOR=    Whenever NRCELL-1.numberOfRxBeamforming (value: 4Rx) is equal to 4Rx, it is required that the cel
#              ...    l linked RMOD has parameter interfaceType contains eCPRI and the cell linked BBMOD/SMOD has list socVariant contains Loki or L
#              ...    oner or Thor
    ${errors_master}=    catenate    SEPARATOR=    It is required that the value of NRCELL.numberOfRxBeamforming is sup
              ...    ported for the planned or installed BBMOD/SMOD that is linked (via eCPRI) to this NRCELL. Please change to default value
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE IF    '${release}'=='master'     set variable    ${errors_master}
    ...    ELSE    set variable    ${errors_SBTS}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=MRBTS-5941/NRBTS-5941/NRCELL-1    msg=${errors}
    should be equal as strings  ${status}    True
    ${errors_21A}=    catenate    SEPARATOR=    Whenever MNL-1 having MNL-1.productVariantPlanned (value: 5gClassicalBTS) eq
                  ...    ual to 5gClassicalBTS or MNL-1.productVariantPlanned (value: 5gClassicalBTS) equal to 5gDU or M
                  ...    NL-1.productVariantPlanned (value: 5gClassicalBTS) equal to 5gvDU, it is required that embedde
                  ...    d assertion valid (Namely: Whenever CABLINK-* having getClassName(CABLINK.firstEndpointDN) equa
                  ...    l to BBMOD or getClassName(CABLINK.firstEndpointDN) equal to SMOD and getClassName(CABLINK.seco
                  ...    ndEndpointDN) equal to RMOD and CABLINK.radioProtocolType equal to eCPRI or CABLINK.radioProtoc
                  ...    olType equal to 10eCPRI or CABLINK.radioProtocolType equal to 25eCPRI, it is required that embe
                  ...    dded assertion valid (Namely: Whenever RMOD-* having RMOD.distname equal to CABLINK.secondEndpo
                  ...    intDN, it is required that embedded assertion valid (Namely: Whenever RMOD_R-* having RMOD_R.co
                  ...    nfigDN equal to RMOD.distname, it is required that RMOD_BP_R.interfaceType is configured and RM
                  ...    OD_BP_R.interfaceType contains the value of eCPRI or RMOD_BP_R.interfaceType contains the valu
                  ...    e of ECPRI or RMOD_BP_R.interfaceType contains the value of eCpri)))
    ${errors_SBTS}=    catenate    SEPARATOR=    If RMOD links to at least one NRCELL and CABLINK.firstEndpointDN points to BB
                  ...    MOD or SMOD, and CABLINK.secondEndpointDN points to RMOD: when CABLINK.radioProtocolType equal
                  ...    s eCPRI or 10eCPRI or 25eCPRI, the related radio module interface Type must contain eCPRI
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE    set variable    ${errors_SBTS}
    ${module_21A}    set variable    MRBTS-5941/MNL-1
    ${module_SBTS}    set variable    MRBTS-5941/EQM-1/APEQM-1/RMOD-1
    ${module}    Run keyword if    '${release}'=='21A'     set variable    ${module_21A}
    ...    ELSE    set variable    ${module_SBTS}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=${module}    msg=${errors}
    should be equal as strings  ${status}    True
    selenium_coam.refresh_page    wait_bar_menu_timeout=300
#    sleep    5
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${SCF_PATH}/scf/scf_AEHC_Protocol_Type.xml
    selenium_coam.validate_plan
    ${hardware_errors}      selenium_coam.get_hardware_errors
    log to console    ${hardware_errors}
    ${errors_21A}=    catenate    SEPARATOR=    Whenever MNL-1 having MNL-1.productVariantPlanned (value: 5gClassicalBTS) eq
                  ...    ual to 5gClassicalBTS or MNL-1.productVariantPlanned (value: 5gClassicalBTS) equal to 5gDU or M
                  ...    NL-1.productVariantPlanned (value: 5gClassicalBTS) equal to 5gvDU, it is required that embedde
                  ...    d assertion valid (Namely: Whenever CABLINK-* having getClassName(CABLINK.firstEndpointDN) equa
                  ...    l to BBMOD or getClassName(CABLINK.firstEndpointDN) equal to SMOD and getClassName(CABLINK.seco
                  ...    ndEndpointDN) equal to RMOD and CABLINK.radioProtocolType equal to CPRI or CABLINK.radioProtoco
                  ...    lType equal to FDDCPRI or CABLINK.radioProtocolType equal to TDDCPRI, it is required that embed
                  ...    ded assertion valid (Namely: Whenever RMOD-* having RMOD.distname equal to CABLINK.secondEndpoi
                  ...    ntDN, it is required that embedded assertion valid (Namely: Whenever RMOD_R-* having RMOD_R.con
                  ...    figDN equal to RMOD.distname, it is required that RMOD_BP_R.interfaceType is configured and RMO
                  ...    D_BP_R.interfaceType contains the value of CPRI-A or RMOD_BP_R.interfaceType contains the valu
                  ...    e of CPRI-N)))
    ${errors_SBTS}=    catenate    SEPARATOR=    If RMOD links to at least one NRCELL and CABLINK.firstEndpointDN points to B
                  ...    BMOD or SMOD, and CABLINK.secondEndpointDN points to RMOD: when CABLINK.radioProtocolType equal
                  ...    s CPRI or FDDCPRI or TDDCPRI, the related radio module interface Type must contain CPRI-A or CP
                  ...    RI-N.
    ${errors}    Run keyword if    '${release}'=='21A'     set variable    ${errors_21A}
    ...    ELSE    set variable    ${errors_SBTS}
    ${module_21A}    set variable    MRBTS-5997/MNL-1
    ${module_SBTS}    set variable    MRBTS-5997/EQM-1/APEQM-1/RMOD-1
    ${module}    Run keyword if    '${release}'=='21A'     set variable    ${module_21A}
    ...    ELSE    set variable    ${module_SBTS}
    ${status}    get_errors_common    error_msg=${hardware_errors}    module=${module}    msg=${errors}
    should be equal as strings  ${status}    True
    [Teardown]  Selenium Logout And Close Browser
