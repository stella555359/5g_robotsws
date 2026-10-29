*** Settings ***
Documentation     Author: wenchao.zhang@nokia-sbell.com
...
...               example case for RAN HZ L2 SG11. test step description in QC as below:
...
...               modify CB007922 configuration file

Resource    ${CURDIR}/../../../../resources/KISS/robot/common_resource.robot
Resource    ${CURDIR}/internal_python_lib.robot
Library     ${CURDIR}/../python/scfc_modify/
Library     ta_a2a
Library     taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN


*** Variables ***
${GNB_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${GNB_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${GNB_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

*** Keywords ***
modify_swconfig_by_CB007922
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}
	${local_save_path}=     Download All Common Config Files From Golden Server
	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node   0x340000:15        #as PM counter period update to 15/15=1min
    teardown_txt
	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    #add_txt_node     0x70670:0        #22R1
    #If 4 subcells are deployed in gNB side ABIL/ABIO, then at AP side 2 AP ABILs needed to support such config blocks.
    #R&D flag value will be 0x70685=2 for such config blocks
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

modify_swconfig_by_CB008247
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}    ${add_node1}=none    ${add_node2}=none    ${add_node3}=none    ${add_node4}=rdSrsCodebookAndTas0
	${local_save_path}=     Download All Common Config Files From Golden Server
	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node    0x340000:15         #as PM counter period update to 15/15=1min
	add_txt_node    0x41001b:1          #CP-NRT log level (0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
    add_txt_node    0x590105:1          #rdSelectedBeamset 1 is DFT beam, 0 is Gob beam
    add_txt_node    0x580477:1          #print beam calc log
    add_txt_node    0x580264:0x1F           #rdDlSrsLogControl
    add_txt_node    0x590104:0          #rdPriorSrsForDlBm: 0: TAS[default], 1: codebook
    add_txt_node    0x5806d7:1          #CNI89341 -rdEnableNewSrsBmCode
#    add_txt_node    0x580267:0
    Run Keyword if    '${add_node4}'=='rdSrsCodebookAndTas1'    add_txt_node    0x590103:1
    ...        ELSE    add_txt_node    0x590103:0
    Run Keyword if    '${add_node1}'=='p8'    add_txt_node    0x580265:0
    Run Keyword if    '${add_node1}'=='1csirs'    add_txt_node    0x580265:1
    Run Keyword if    '${add_node2}'=='rdDisableBestPmiBeamForPdcch'    add_txt_node    0x580421:0
    Run Keyword if    '${add_node3}'=='rdDlCoMaAgedCycle2'    add_txt_node    0x580262:0x2
    modify_txt_node    0x590072:1         #CP-RT log level (0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
    teardown_txt

	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    add_txt_node    0x70690:1         #enable 1086 and 8247
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

modify_swconfig_by_CB008360
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}    ${add_node1}=none    ${add_node2}=none    ${add_node3}=none    ${add_node4}=rdSrsCodebookAndTas0
	${local_save_path}=     Download All Common Config Files From Golden Server
	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node    0x340000:15         #as PM counter period update to 15/15=1min
    add_txt_node    0x580550:7          #8360-D
    add_txt_node    0x5806d7:1          #CNI89341 -rdEnableNewSrsBmCode
    add_txt_node    0x58057a:3          # set the rdFeatureFlagBitmapLevel
    add_txt_node    0x580477:1          #The UL CoMa log enabling flag(rdUlSrsCoMaLogEnabled)
    
    #add_txt_node    0x58057e:8388608            # 23 bit counter only 2^23
    Run Keyword if    '${add_node1}'=='rdDlSrsLogControl'    add_txt_node    0x580264:0x3
    Run Keyword if    '${add_node2}'=='rdRescaledSuSINR'    add_txt_node    0x580543:0x46
    Run Keyword if    '${add_node3}'=='rdSINRusedForRank1LA'    add_txt_node    0x58037c:0x1
    teardown_txt

	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    add_txt_node    0x70690:1         #enable 1086 and 8247
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

modify_swconfig_by_CB010659
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}    @{Rdparameter}
	${local_save_path}=     Download All Common Config Files From Golden Server
	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    FOR    ${parameter}    IN    @{Rdparameter}
        ${key}    ${value}    Split String    ${parameter}    :
        run keyword and ignore error    delete txt node    ${key}
        add txt node    ${parameter}
    END
    teardown_txt

	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

add_ca_relation_CB7922
    [Arguments]    ${scfc_path}
    comment    Inter L2RT intra band CA Cell2&Cell3 Inter L2RT inter band CA Cell4&Cell1 Intra L2RT intra band CA Cell1&Cell2 Intra L2RT
    comment    inter band CA Cell3&Cell4
    add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
    add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
    add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
    add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1

modify_swconfig_by_CB008305
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}
	${local_save_path}=     Download All Common Config Files From Golden Server
	#${path_gnb}=            QC Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
    ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node   0x340000:15        #as PM counter period update to 15/15=1min
	add_txt_node   0x580264:0x3         #coma log
	add_txt_node   0x580477:1         #print beam calc log
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt

QC Find Match GNB swconfig Golden Files
    [Arguments]    ${scfc_file}=${EMPTY}    ${AP_configs_local_path}=${GOLDEN_LOCAL_PATH}
    [Documentation]    This keyword is to get GNB swconfig file from dic
    ...    | Input Parameters | Man. | Description |
    ...    | ${scfc_file} | No | scfc file, default ${EMPTY} where download SCF from GNB |
    ...    | ${AP_configs_local_path} | No | local AP config path which download from golden server |
    ...    Examples:
    ...    | Find Match GNB swconfig Golden Files | scfc.xml |
    ${dic}=     qc parse yaml file and return dict   ${scfc_file}     ${AP_configs_local_path}
    ${gnb_swconfig_file}=    Collections.Get From Dictionary    ${dic}   gNB_swconfig
    ${gnb_swconfig_path}=    Catenate     SEPARATOR=${/}    ${AP_configs_local_path}    ${gnb_swconfig_file}
    [Return]    ${gnb_swconfig_path}

qc parse yaml file and return dict
    [Arguments]    ${scfc_file}=${EMPTY}    ${AP_configs_local_path}=${GOLDEN_LOCAL_PATH}
    [Documentation]    This keyword is to find git qt file path, and return dict
    ...    | Input Parameters | Man. | Description |
    ...    | ${scfc_file} | No | scfc file, default ${EMPTY} where download SCF from GNB |
    ...    | ${AP_configs_local_path} | No | local AP config path which download from golden server |
    ...    Examples:
    ...    | parse yaml file and return dict  | scfc.xml |
    ${nrbts_distname}=    Get NRBTS DistName    ${scfc_file}
    ${scfc_file_tmp}=    Run Keyword If    '${scfc_file}'=='${EMPTY}'    Backup Scf    /tmp
    ${scfc_file}=    Set Variable If    '${scfc_file}'=='${EMPTY}'    ${scfc_file_tmp}    ${scfc_file}
    ${gnb_cu_type}=    Get GNB Type    ${scfc_file}    ${nrbts_distname}
    ${celltechnology}=    Get CELL Technology    ${scfc_file}    ${nrbts_distname}
    ${fr}=    Get FR Type    ${scfc_file}   ${nrbts_distname}
    Run Keyword If     "${L1_TYPE}"=="${EMPTY}"    Get L1Bypass Type
    Run Keyword If     "${RF_TYPE}"=="${EMPTY}"    Get Radio Protocol Type    ${scfc_file}
    Run Keyword If     "${SW_VERSION}"=="${EMPTY}"    Get GNB Software Version
    Run Keyword If     "${FCT_BOARD_TYPE}"=="${EMPTY}"    Get Control Board Type
    Run Keyword If     "${ASP_BOARD_TYPE}"=="${EMPTY}"    Get Base Band Board Type
    ${config_yaml}=    Set Variable    ${AP_configs_local_path}/${SW_VERSION}/${gnb_cu_type}/L1b/config.yaml
    ${dic}=    YAMLPARSER.Parse Yaml    file_name=${config_yaml}
    ...    duplex=${celltechnology}
    ...    FH_mode=${RF_TYPE}
    ...    RF_mode=${fr}
    ...    gNB_common_unit=${FCT_BOARD_TYPE}
    ...    gNB_capacity_unit=${ASP_BOARD_TYPE}
    Log    ${dic}
    [Return]    ${dic}

modify_swconfig_by_CB010602
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}    ${add_node1}=none
	${local_save_path}=     Download All Common Config Files From Golden Server
	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node    0x340000:15         #as PM counter period update to 15/15=1min
    add_txt_node    0x580394:0x1E
    add_txt_node    0x580395:0x1E
    add_txt_node    0x580264:0x3
    add_txt_node    0x580477:1
    add_txt_node    0x580263:3000
    Run Keyword if    '${add_node1}'=='1csirs'    add_txt_node    0x580265:1
    teardown_txt

	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    add_txt_node    0x70690:1         #enable 1086 and 8247
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

 
modify_swconfig_by_CB007113
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}
	${local_save_path}=     Download All Common Config Files From Golden Server
	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node    0x420068:6         #rdTddPoolingFeaturesEnable
	add_txt_node    0x580612:1         #interl1sppoolingenable
    add_txt_node    0x450027:1         
    add_txt_node    0x590072:1 
    add_txt_node    0x45000A:1 	
    add_txt_node    0x340000:15
    #add_txt_node    0x580787:1         #rdActBbPoolTddFr1AlgEnh=true  	
    teardown_txt

	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    add_txt_node    0x1003F:2         
    add_txt_node    0x10042:0xC0A8C87E         	
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
	
	
modify_vendor_file_for_CB007113
    TAF_ADMIN.Setup Admin
    ${vendor_path}    Set Variable    ${test_log_directory()}/vendor_ini.xml
    TAF_ADMIN.Download Vendor File    ${vendor_path} 
    Modify Vendor XML File    ${vendor_path}
    TAF_ADMIN.Set Vendor File    ${vendor_path}
	TAF_ADMIN.teardown admin



Modify Vendor XML File 
    [Arguments]    ${vendor_path} 
    ${vendor_list32}    create list    ${EMPTY}
    ${vendor_list64}    create list    ${EMPTY}
    ${status0}    ${msg0}    Run Keyword And Ignore Error    Variable Should Exist    ${VENDOR_PARAMETER_C32}
    ${status1}    ${msg1}    Run Keyword And Ignore Error    Variable Should Exist    ${VENDOR_PARAMETER_C64}
    ${vendor_list32}    Run Keyword If    '${status0}'=='PASS'    Modify vendor C32    ${vendor_list32}
    ${vendor_list64}    Run Keyword If    '${status0}'=='PASS'    Modify vendor C64    ${vendor_list64}
    ${modify_list}    Combine Lists    ${vendor_list32}    ${vendor_list64}
    Modify Xml    ${vendor_path}    ${vendor_path}    ${modify_list}

Modify vendor C64
    [Arguments]    ${vendor_list64}
    FOR    ${parameter}    IN    @{VENDOR_PARAMETER_C64}
        ${key}    ${val}    Split String    ${parameter}    :
        ${element}    Set Variable    text|${val}|//*[@name\='bbL1SpPrbInitCapacity']/item[4]/*[@name\='${key}']
        Append To List    ${vendor_list64}    ${element}
    END
    [Return]    ${vendor_list64}

Modify vendor C32
    [Arguments]    ${vendor_list32}
    FOR    ${parameter}    IN    @{VENDOR_PARAMETER_C32}
        ${key}    ${val}    Split String    ${parameter}    :
        ${element}    Set Variable    text|${val}|//*[@name\='bbL1SpPrbInitCapacity']/item[1]/*[@name\='${key}']
        Append To List    ${vendor_list32}    ${element}
    END
    [Return]    ${vendor_list32}	
	
modify_swconfig_by_CB008247 and CNI92005
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}    ${add_node1}=none
	${local_save_path}=     Download All Common Config Files From Golden Server
	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node    0x340000:15         #as PM counter period update to 15/15=1min
	add_txt_node    0x41001b:1          #CP-NRT log level (0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
    add_txt_node    0x590105:1          #rdSelectedBeamset 1 is DFT beam, 0 is Gob beam
    add_txt_node    0x580477:1          #print beam calc log
    add_txt_node    0x580264:0x1F           #rdDlSrsLogControl
    add_txt_node    0x590104:0          #rdPriorSrsForDlBm: 0: TAS[default], 1: codebook
	add_txt_node    0x590103:0          
    #control skipping the last pdsch symbol in SSB slot. 0:disable, 1:skip slot0 ssbSlot, 2:skip all ssbSlot
	#add_txt_node    0x5806CE:0x1 
    Run Keyword if    '${add_node1}'=='disable'    add_txt_node    0x5806CE:0x0
	Run Keyword if    '${add_node1}'=='slot0'    add_txt_node    0x5806CE:0x1
	Run Keyword if    '${add_node1}'=='all'    add_txt_node    0x5806CE:0x2
    modify_txt_node    0x590072:1         #CP-RT log level (0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
    teardown_txt

	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    add_txt_node    0x70690:1         #enable 1086 and 8247
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt	

modify_gnb_swconfig_by_10659
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${gnb_swcfg_src_file}    ${rad_para_dict}
    [Documentation]    This keyword is to set GNB rad flag in swconfig
    ...    Author: shuisheng.he@nokia-sbell.com
    setup_txt    src_file=${gnb_swcfg_src_file}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    FOR    ${key}    IN    @{rad_para_dict}
        ${value}    Get From Dictionary    ${rad_para_dict}    ${key}
        add_txt_node    ${key}:${value}
    END
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt

	
modify_swconfig_by_CB009198
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${gnb_swcfg_src_file}    ${add_node1}=none
	[Documentation]    This keyword is to set gNB forced to use modulation
    setup_txt    src_file=${gnb_swcfg_src_file}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    Run Keyword if    '${add_node1}'=='Pi2BPSK'    add_txt_node    0x580010:0x02
	Run Keyword if    '${add_node1}'=='QPSK'    add_txt_node    0x580010:0x100
	teardown_txt
	GNB Upload Swconfig    ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt	


modify_swconfig_by_CB009235
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}    ${add_node1}=0x19    ${add_node2}=0x12C
	${local_save_path}=     Download All Common Config Files From Golden Server
	#${path_gnb}=            QC Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
    ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node   0x340000:0x0F        #as PM counter period update to 15/15=1min
	add_txt_node   0x580776:1         #rdDlMuSbBfMode
	add_txt_node   0x580789:1        #disableRD by NIDD
	add_txt_node   0x580539:9       #rdNumUeThdForTrace
	#add_txt_node   0x58075A:0x19      #rdNumberOfCorrelationCalculationUe:25
	#add_txt_node   0x58075B:0x12C      #rdNumberOfCorrelationCalculationTotal:300
    add_txt_node    0x58075A:${add_node1}    #rdNumberOfCorrelationCalculationUe:25
	add_txt_node    0x58075B:${add_node2}    #rdNumberOfCorrelationCalculationTotal:300	
	add_txt_node   0x58077E:1      #rdEnableMuAwareTdSchTtiTrace:true
	#add_txt_node   0x58057F:0x80000000      #DL.MUMIMO_ENHANCED.MU_AWARE_TD_SCH:true	
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt	
	
	
Active_GNB_L2_debug_traces
    [Arguments]    ${local_path}     ${position}=5    
    TAF_SSH.connect to    ${GNB_IP}   ${GNB_USERNAME}    ${GNB_PASSWORD}   alias=bsh
    ${vpath}    Set Variable    /ffs/run/swpool/L2RT/addons
    ${ret}    TAF_SSH.execute    rm -rf /ffs/run/boardcfg/${position}/A/mcu-aspd/addons/trace.tgz    connection=bsh
    ${ret}    TAF_SSH.execute    rm -rf /ffs/run/boardcfg/${position}/A/mcu-aspd/addons/trace.tgz.p7    connection=bsh
    ${ret}    TAF_SSH.execute    rm -rf ${vpath}/.*    connection=bsh
    ${ret}    TAF_SSH.execute    mkdir -p ${vpath}    connection=bsh
    #${local_path}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/feature_log_activation.txt
    OperatingSystem.Run    mkdir -p ${test_log_directory()}/var/preserve/
    OperatingSystem.Run    cp ${local_path} ${test_log_directory()}/var/preserve/
    OperatingSystem.Run    cd ${test_log_directory()};tar czf trace.tgz var/preserve/feature_log_activation.txt
    ${cmd}=    Set Variable    sshpass -p ${GNB_PASSWORD} scp ${test_log_directory()}/trace.tgz ${GNB_USERNAME}@${GNB_IP}:${vpath}
    OperatingSystem.Run    ${cmd}
    ${ret}    TAF_SSH.execute    crasign ${vpath}/trace.tgz    connection=bsh
    ${ret}    TAF_SSH.execute    ln ${vpath}/trace.tgz /ffs/run/boardcfg/${position}/A/mcu-aspd/addons/trace.tgz    connection=bsh
    ${ret}    TAF_SSH.execute    ln ${vpath}/trace.tgz.p7 /ffs/run/boardcfg/${position}/A/mcu-aspd/addons/trace.tgz.p7    connection=bsh
    ${ret}    TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh	
