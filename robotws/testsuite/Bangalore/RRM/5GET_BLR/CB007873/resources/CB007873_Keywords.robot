*** Settings ***
Documentation     [PURPOSE] Set of keywords used for 5GC001948 feature tests cases
...
...               Automation author           : vandana.b@nokia.com
...               Automation contact          : vandana.b@nokia.com
...               Creation Date               : 20-October-2020
...               Modified Date               : 10-August-2021
...               Last Modified by            : vandana.b@nokia.com

Variables    ta5g_global_var
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Library        ../../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Resource       ../../resources/robot/TTI_Traces.robot
Resource       ../../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../../resources/robot/Setup_Env.robot
Library        luashark_tools.analyzer       WITH NAME       analyzer
#Library        ute_admin                         WITH NAME   ute_adm
Library         taf.sbts.oam.coam.admin     WITH NAME   ute_adm
Library        taf.collectors.core   WITH NAME   core
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library        ../../resources/python/BIP_Capture.py
Library        ../../resources/python/CPRT_Capture.py

*** Variables ***
${NRBTS_DISTNAME}               ${EMPTY}    # MRBTS-1/NRBTS-1# Bearer path definition list inside SCF
${NRCELL}             NRCELL-2
${NRCELL_dist_name_main}        MRBTS-1/NRBTS-1
${NRCELL_dist_name_cell}        MRBTS-1/NRBTS-1/NRCELL-1
${NRCELL_dist_name_cell1}       MRBTS-1/NRBTS-1/NRCELL-1
${NRCELL_dist_name_cell2}       MRBTS-1/NRBTS-1/NRCELL-2
${mrbtsID}    1
${WEBUI_URL}      https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${WEBUI_PASSWORD}       ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${PM_counter_ULDataVol_Pcell1}       M55323C03006   #UL data volume counter
${PM_counter_RLCPDU_Pcell1}          M55311C42006   #DL_UL_Counter_DL_RLC_PDU_volume_transmitted_over_primary_path (Grouo6)
${PM_counter_RLCPDU_Pcell2}          M55311C43006   #DL_UL_Counter_DL_RLC_PDU_volume_transmitted_over_primary_path (Grouo6)
${PM_counter_RLCPDU_Pcell3}          M55311C44006   #DL_UL_Counter_DL_RLC_PDU_volume_transmitted_over_primary_path (Grouo6)
${PM_counter_RLCPDU_Pcell4}          M55311C45006   #DL_UL_Counter_DL_RLC_PDU_volume_transmitted_over_primary_path (Grouo6)
${PM_Counter_ReconfScell}	        M55118C05505   #Number of RRC Reconfiguration configuring 1 SCell in DL in SA mode
${PM_Counter_RRC_ReconfScell}       M55118C05506   #Number of successful RRC Reconfiguration configuring 1 SCell in DL in SA mode ()
${PM_Counter_UEinPcellwithScell}    M55118C05507   #Number of CA UEs in the current cell configured as a PCell,
#which have 1 configured SCell in DL (M55118C05507)
${PM_Counter_UEinScellwithPcell}    M55118C05508   #Number of CA UEs in the current cell configured as a SCell,
#which have 1 configured SCell in DL (M55118C05508)
${PM_Counter_ScellTraffic}          M55310C01006   #DL_RLC_VOL_TX_L_QOS_GRP_06
${PM_Counter_UEinPcellwith0ActScell}            M55316C03000   #PSCELL_UE_0_ACT_SCELL_DL - PSCell UEs with 0 activated SCells in DL
${PM_Counter_UEinPcellwith1ActScell}            M55316C03001   #PSCELL_UE_1_ACT_SCELL_DL - PSCell UEs with 1 activated SCells in DL
#NMAX_PSCELL_UE_0_ACT_SCELL_DL - Maximum amount of PSCell UEs with 0 activated SCells in DL
${PM_Counter_MaxUEinPcellwith0ActScell}         M55316C05000
#NMAX_PSCELL_UE_0_ACT_SCELL_DL - Maximum amount of PSCell UEs with 1 activated SCells in DL
${PM_Counter_MaxUEinPcellwith1ActScell}         M55316C05001
#NMAX_PSCELL_UE_0_ACT_SCELL_DL - Maximum amount of PSCell UEs with 1 activated SCells in DL
${PM_Counter_UlRLCDdataPDUsReceivedByLowRLC}         M55310C04006
#SCell deactivations due to Buffer Status
${PM_Counter_ScellDeactBufferStatus}         M55316C09001
#SCell deactivations due to Channel State
${PM_Counter_ScellDeactChannelState}         M55316C09002
#L2HI counters
#DL RLC PDU volume transmitted by High RLC - QoS Group 01
${PM_Counter_DL_RLC_PDU_volume_QOS1}         M55311C01001
#DL RLC PDU volume transmitted by High RLC - QoS Group 05
${PM_Counter_DL_RLC_PDU_volume_QOS5}         M55311C01005
#DL RLC PDU volume transmitted by High RLC - QoS Group 06
${PM_Counter_DL_RLC_PDU_volume_QOS6}         M55311C01006
#DL RLC PDU volume transmitted over primary path - QoS Group 01
${PM_Counter_DL_RLC_PDU_volume_primary_QOS1}         M55311C42001
#DL RLC PDU volume transmitted over primary path - QoS Group 05
${PM_Counter_DL_RLC_PDU_volume_primary_QOS5}         M55311C42005
#DL RLC PDU volume transmitted over primary path - QoS Group 06
${PM_Counter_DL_RLC_PDU_volume_primary_QOS6}         M55311C42006
#DL RLC PDU volume transmitted over secondary path - QoS Group 01
${PM_Counter_DL_RLC_PDU_volume_secondary_QOS1}         M55311C44001
#DL RLC PDU volume transmitted over secondary path - QoS Group 05
${PM_Counter_DL_RLC_PDU_volume_secondary_QOS5}         M55311C44005
#DL RLC PDU volume transmitted over secondary path - QoS Group 06
${PM_Counter_DL_RLC_PDU_volume_secondary_QOS6}         M55311C44006
#SCELL_ACTIVATIONS
${PM_Counter_ScellActivationScell}    M55316C09000
#DL slots with DSS
${PM_Counter_DSSDlSlots}         M55332C00001
#UL PRB with DSS
${PM_Counter_DSSUlPRB}         M55332C01001
&{PM_Counter_ReconfScell_WITHID_EXPECTED}           counter=${PM_Counter_ReconfScell}            objId=${PCellID}
&{PM_Counter_RRC_ReconfScell_WITHID_EXPECTED}       counter=${PM_Counter_RRC_ReconfScell}        objId=${PCellID}
&{PM_Counter_UEinPcellwithScell_WITHID_EXPECTED}    counter=${PM_Counter_UEinPcellwithScell}     objId=${PCellID}
&{PM_Counter_UEinScellwithPcell_WITHID_EXPECTED}    counter=${PM_Counter_UEinScellwithPcell}     objId=${SCellID}
&{PM_Counter_ScellTraffic_WITHID_EXPECTED}          counter=${PM_Counter_ScellTraffic}           objId=${SCellID}
&{PM_Counter_UEinPcellwith0ActScell_PCell_WITHID_EXPECTED}          counter=${PM_Counter_UEinPcellwith0ActScell}        objId=${PCellID}
&{PM_Counter_UEinPcellwith1ActScell_PCell_WITHID_EXPECTED}          counter=${PM_Counter_UEinPcellwith1ActScell}        objId=${PCellID}
&{PM_Counter_UEinPcellwith0ActScell_SCell_WITHID_EXPECTED}          counter=${PM_Counter_UEinPcellwith0ActScell}        objId=${SCellID}
&{PM_Counter_UEinPcellwith1ActScell_SCell_WITHID_EXPECTED}          counter=${PM_Counter_UEinPcellwith1ActScell}        objId=${SCellID}
&{PM_Counter_MaxUEinPcellwith0ActScell_PCell_WITHID_EXPECTED}       counter=${PM_Counter_MaxUEinPcellwith0ActScell}     objId=${PCellID}
&{PM_Counter_MaxUEinPcellwith1ActScell_PCell_WITHID_EXPECTED}       counter=${PM_Counter_MaxUEinPcellwith1ActScell}     objId=${PCellID}
&{PM_Counter_MaxUEinPcellwith0ActScell_SCell_WITHID_EXPECTED}       counter=${PM_Counter_MaxUEinPcellwith0ActScell}     objId=${SCellID}
&{PM_Counter_MaxUEinPcellwith1ActScell_SCell_WITHID_EXPECTED}       counter=${PM_Counter_MaxUEinPcellwith1ActScell}     objId=${SCellID}
&{PM_Counter_UlRLCDdataPDUsReceivedByLowRLC_PCell_WITHID_EXPECTED}    counter=${PM_Counter_UlRLCDdataPDUsReceivedByLowRLC}    objId=${PCellID}
&{PM_Counter_UlRLCDdataPDUsReceivedByLowRLC_SCell_WITHID_EXPECTED}    counter=${PM_Counter_UlRLCDdataPDUsReceivedByLowRLC}    objId=${SCellID}
&{PM_Counter_ScellDeactBufferStatus_SCell_WITHID_EXPECTED}          counter=${PM_Counter_ScellDeactBufferStatus}        objId=${SCellID}
&{PM_Counter_ScellDeactChannelState_SCell_WITHID_EXPECTED}          counter=${PM_Counter_ScellDeactChannelState}        objId=${SCellID}
&{PM_Counter_ScellActivationScell_SCell_WITHID_EXPECTED}            counter=${PM_Counter_ScellActivationScell}        objId=${SCellID}
&{PM_Counter_DSSDlSlots_PCell_WITHID_EXPECTED}          counter=${PM_Counter_DSSDlSlots}        objId=${PCellID}
&{PM_Counter_DSSUlPRB_PCell_WITHID_EXPECTED}            counter=${PM_Counter_DSSUlPRB}          objId=${PCellID}
#Test for Chhean new KW.
&{PM_counter_RLCPDU_Pcell_WITHID_EXPECTED1}           counter=${PM_counter_RLCPDU_Pcell1}          obj=NRDU         objId=${rnduID}
&{PM_counter_ULDataVol_Pcell_WITHID_EXPECTED}           counter=${PM_counter_ULDataVol_Pcell1}     obj=NRBTS     objId=${PCellID}
&{PM_counter_RLCPDU_Pcell_WITHID_EXPECTED2}           counter=${PM_counter_RLCPDU_Pcell2}          obj=NRDU         objId=${rnduID}
&{PM_counter_RLCPDU_Pcell_WITHID_EXPECTED3}           counter=${PM_counter_RLCPDU_Pcell3}          obj=NRDU         objId=${rnduID}
&{PM_counter_RLCPDU_Pcell_WITHID_EXPECTED4}           counter=${PM_counter_RLCPDU_Pcell4}          obj=NRDU         objId=${rnduID}
${pm_files_path}       ${LOG_PATH}
${latest_pm_file_name}
@{FilterPSPeer}     ScellUeSchedulingReq
...                 ScellUeSchedulingResp
...                 ScellPucchReceiveIndPs
...                 ScellPuschReceiveIndPs
...                 UeDataDeliveryStatusInd

@{FilterPSPeerDRX}     ScellUeSchedulingInd
${PCellID}                            2
${SCellID}                            1
${rnduID}                            1
${TRF_ID1}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${TRF_ID5}    5
${TRF_ID6}    6
${TRF_ID7}    7
${TRF_ID8}    8
${TRF_ID9}    9
${TRF_ID10}    10
${TRF_ID11}    11
${TRF_ID12}    12
${SW_BRANCH}                       SBTS00    # SBTS22R2
${SW_VERSION}                      ${EMPTY}    # SBTS00
&{GNB_ASIK}       ip=10.43.54.188    username=toor4nsn    password=oZPS0POrRieRtu    connection=GNBDU
&{AP_ASIK}        ip=192.168.200.1   username=toor4nsn    password=oZPS0POrRieRtu    connection=AP
${__EGATE_PORT__}    20000
@{__EDAEMON_PORTS__}    10000    30000
${__EGATE_IP__}    0.0.0.0
${__EGATE_COMMAND_TIMEOUT___}    10s
${__TIME_FOR_NSA_LUA_SETUP__}    3s
${NOKIA_LOGIN}    toor4nsn
${NOKIA_PASS}     oZPS0POrRieRtu
${GNB_IP}     192.168.255.129
${AP_IP}     192.168.200.1

*** Keywords ***
setup 2255
    suite setup from scratch    keepAllUeDataInCfgFile=${True}    #automaticTeardown=${True}
    Init Variables
    CB007873_Keywords.Get Original Configuration
    #5GC002255_Keywords.Setup configuration files
    #5GC002255_Keywords.Setup configuration files
    #Copy File                       ${SCF_SETUP_PATH}     ${SCF_TypeSETUP_PATH}.ori
    #Config Update                               scf_file=${SCF_SETUP_PATH}

Init Variables
    &{MIRROR_L2_GNB}                create dictionary
    ...                             sport1=21                               sport2=29
    ...                             dport=3                                 host=${GNB_DU.sys[0].M}
    Set Suite Variable              ${MIRROR_L2_GNB}
    ${slaveHost}                    Call method
    ...                             ${GNB_DU}                               getSysSlaveHost
    ${CAPTURE_L2_GNB}               newCapture
    ...                                 host=${slaveHost}
    ...                                 interface=etha01
    ...                                 prefix=L2Traces
    ${CAPTURE_L2_GNB.withTN}        Set Variable                            ${True}
    Set Suite Variable              ${CAPTURE_L2_GNB}

teardown 2255
    Setup.Suite Teardown       reset_ap=${True}
    CB007873_Keywords.Put back original config files
#RETRAIT TEMPORAIRE car pb de variable    [Teardown]             GenericTest.Display diagnosis
    sleep     1s

#Config Update
Check Cell on Air
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
    &{bts_info}    coam.Get Bts Statuses    connection=coam_admin
    Should Be Equal    ${bts_info['proceduralState']}    onAir    ignore_case=true

Cell_Lock_id1
#  Classical_connections.Connect to gNB Asik Master
   Oam.OAM Cell Lock  cell_id=1

Check CRNTI
    [Arguments]    ${crnti}=1
    ${CrntiOK} =    Set Variable    false
    : FOR    ${order}    IN RANGE    0    4
    \    Tools.Dated Log    ${order}
    \    Run Keyword If    '@{cellid0}[${order}]' == '${crnti}'    InCellId0    ${crnti}    ${order}
    \    Tools.Dated Log    Suite du KW
    : FOR    ${order}    IN RANGE    0    4
    \    Dated Log    ${order}
    \    Run Keyword If    '@{cellid1}[${order}]' == '${crnti}'    InCellId1    ${crnti}    ${order}
    \    Dated Log    Suite du KW
    Dated Log    la valeur de CrntiOK est ${CrntiOK}
    Run Keyword If    '${CrntiOK}'=='false'    BuiltIn.Log    rien de trouvé
    ${crnti}=   Set Variable     0      # reset crnti value
    Should be equal    ${CrntiOK}    true

Get CRNTI
    ${output}                       SSH Wait For Connect and Cmd
    ...                             command=cd ${tl.core.dir_path}; grep -i crnti: uec_1.log*
    ...                             host=${HOST_EPCSIM}
    ${output}    common_frt.Ssh Execute With Timeout       connection=lteemu
    should contain	${output}	crnti:
    ${crnti}                 SSH Wait For Connect and Cmd
    ...                      command=cd ${tl.core.dir_path}; grep -i crnti: uec_1.log* | awk -F "crnti:" '{print $2}' | awk '{print $1}' | tail -1
    ...                      host=${HOST_EPCSIM}
    ${crnti}=    Convert To Integer   ${crnti}
    Dated Log   crnti = ${crnti}
    Set Global Variable    ${crnti}

Get Original Configuration
    [Documentation]      KW used to get the current gNB configuration: swconfig, WTS

    # Get EPC file configuration:
    ${alias_epc}                    SSH Wait For Connect                ${HOST_EPCSIM}
    csn.download_file               remote_path=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                             local_path=${LOG_PATH}/TL50_CA_SA_NSA_L1BP.cfg
    ...                             connection=${alias_epc}

Set SCF Context
    Copy File                       ${SCF_SETUP_PATH}     ${SCF_SETUP_PATH}.ori
    #Config Update                               scf_file=${SCF_SETUP_PATH}
    SCF StartSession                scf_file=${SCF_SETUP_PATH}

    ${dist_name}         Set Variable    MRBTS-1/NRBTS-2
    SCF Set element    dist_name=${dist_name}    element_name=actGeneralConnectivityGold  element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=actLteNrDss   element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=sCellActivationMethod   element_value=blind

    ${dist_name}         Set Variable    MRBTS-1/NRBTS-2/NRCELL-1
    SCF Set element    dist_name=${dist_name}    element_name=sCellDeactivationTimerGNB   element_value=infinity
    SCF Set element    dist_name=${dist_name}    element_name=srPeriodicity   element_value=slots80

    ${dist_name}         Set Variable    MRBTS-1/NRBTS-2/NRCELL-2
    SCF Set element    dist_name=${dist_name}    element_name=actPRBBlanking   element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=actPdschAtSsbSlots   element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=actPdschRmCsirsForTracking   element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=lteNrDssMode   element_value=DL_CRS_TDM_UL_FDM
    SCF Set element    dist_name=${dist_name}    element_name=msg1FrequencyStart   element_value=9
    SCF Set element    dist_name=${dist_name}    element_name=nbrOfBlankedPRBsHighEdgeDL   element_value=2
    SCF Set element    dist_name=${dist_name}    element_name=nbrOfBlankedPRBsHighEdgeUL   element_value=2
    SCF Set element    dist_name=${dist_name}    element_name=pagingOffset   element_value=2
    SCF Set element    dist_name=${dist_name}    element_name=pucchF3ModulationScheme   element_value=pi2bpsk
    SCF Set element    dist_name=${dist_name}    element_name=trsMutingInBlankedPRBsEnabled   element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=type0SearchSpaceConfigurationIndex   element_value=15
    SCF Set element    dist_name=${dist_name}    element_name=sCellDeactivationTimerGNB   element_value=infinity
    SCF Set element    dist_name=${dist_name}    element_name=srPeriodicity   element_value=slots80

    SCF Remove list    dist_name=${dist_name}    list_name=cellBwpList
    SCF Add list       dist_name=${dist_name}    list_name=cellBwpList

    &{cellBwpList}     Create Dictionary    bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-162   cellBwpId=0
    SCF Add items to list   dist_name=${dist_name}    list_name=cellBwpList   elements=${cellBwpList}
    &{cellBwpList}     Create Dictionary    bwpDN=MRBTS-1/NRBTS-2/BWP_PROFILE-173   cellBwpId=1
    SCF Add items to list   dist_name=${dist_name}    list_name=cellBwpList   elements=${cellBwpList}

    SCF Set element in List    dist_name=${dist_name}    list_name=csirsForTracking     element_name=csirsTrackingPeriod   element_value=40ms

    ${dist_name}         Set Variable    MRBTS-1/NRBTS-2/NRCELL-2/NRREL-0
    SCF Set element    dist_name=${dist_name}    element_name=gNbId   element_value=2

    ${dist_name}         Set Variable    MRBTS-1/NRBTS-2/NRSYSINFO_PROFILE-2
    SCF Set element    dist_name=${dist_name}    element_name=siWindowLength   element_value=s160
    SCF Set element    dist_name=${dist_name}    element_name=systemInformationTargetRate   element_value=0

    SCF Remove list    dist_name=${dist_name}    list_name=sibSchedulingList
    SCF Add list       dist_name=${dist_name}    list_name=sibSchedulingList

    &{sibSchedulingList}     Create Dictionary    sibBroadcastStatus=broadcasting   sibPeriodicity=rf64   sibScope=cellSpecific   sibType=sibType2
    SCF Add items to list   dist_name=${dist_name}    list_name=sibSchedulingList   elements=${sibSchedulingList}
    &{sibSchedulingList}     Create Dictionary    sibBroadcastStatus=broadcasting   sibPeriodicity=rf64   sibScope=cellSpecific   sibType=sibType3
    SCF Add items to list   dist_name=${dist_name}    list_name=sibSchedulingList   elements=${sibSchedulingList}
    &{sibSchedulingList}     Create Dictionary    sibBroadcastStatus=broadcasting   sibPeriodicity=rf64   sibScope=cellSpecific   sibType=sibType4
    SCF Add items to list   dist_name=${dist_name}    list_name=sibSchedulingList   elements=${sibSchedulingList}
    &{sibSchedulingList}     Create Dictionary    sibBroadcastStatus=broadcasting   sibPeriodicity=rf64   sibScope=cellSpecific   sibType=sibType5
    SCF Add items to list   dist_name=${dist_name}    list_name=sibSchedulingList   elements=${sibSchedulingList}

    SCF StopSession      scf_file=${SCF_SETUP_PATH}
    Dated Log    ----> Modifications completed.\n

    OAM Perform Full Commissioning          scf_file=${SCF_SETUP_PATH}
    WA Airscale Wait For Ready                  ${GNB_DU}

InCellId0
    [Arguments]    ${a}    ${b}
    Dated Log    le CRNTI ${a} est trouve en index ${b} dans cellid0
    ${CrntiOK} =    Set Variable    true
    #    ${nb} =    Set Variable    ${b}
    #    ${cellid} =    Set Variable    0
    Set Global Variable    ${CrntiOK}
    #    Set Global Variable    ${cellid}
    Exit For Loop

InCellId1
    [Arguments]    ${a}    ${b}
    Dated Log    le CRNTI ${a} est trouve en index ${b} dans cellid1
    ${CrntiOK} =    Set Variable    true
    #    ${nb} =    Set Variable    ${b}
    #    ${cellid} =    Set Variable    1
    Set Global Variable    ${CrntiOK}
    #    Set Global Variable    ${cellid}
    Exit For Loop

Put back original config files
    [Documentation]      KW used to put back TL configuration: swconfig, WTS

    # Get EPC file configuration:
    ${alias_epc}                    SSH Wait For Connect                ${HOST_EPCSIM}
    csn.upload_file                 remote_path=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                             local_path=${LOG_PATH}/basic_wts_ori.cfg
    ...                             connection=${alias_epc}

    # Get EPC xml configuration:
    ${file}                         Get XML AirPhoneConfig Path
    ${alias_epc}                    SSH Wait For Connect                ${HOST_EPCSIM}
    csn.upload_file                 remote_path=${tl.core.dir_path}/${file}
    ...                             local_path=${LOG_PATH}/AP_Config_ori.xml
    ...                             connection=${alias_epc}

Restart
    Restart TL              isOAMRebooted=${True}

Setup configuration files
# Set EPC file configuration:
    ${alias_epc}                    SSH Wait For Connect                ${HOST_EPCSIM}
    csn.upload_file                 remote_path=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                             local_path=${CURDIR}/../config/basic_wts.cfg
    ...                             connection=${alias_epc}
 	BuiltIn.Log to Console          upload ${tl.core.dir_path}/${tl.core.cfg_filename}

# Set EPC xml configuration:
    ${file}                         Get XML AirPhoneConfig Path
    ${alias_epc}                    SSH Wait For Connect                ${HOST_EPCSIM}
    csn.upload_file                 remote_path=${tl.core.dir_path}/${file}
    ...                             local_path=${CURDIR}/../config/AirPhoneConfig.xml
    ...                             connection=${alias_epc}
	BuiltIn.Log to Console          upload ${tl.core.dir_path}/${file}

    # Set swconfig file gNB
    #  ${alias_gnb}                    SSH Wait For Connect                ${GNB_DU.entryCard[0]}
    #  csn.upload_file                 remote_path=${SWCONFIG_PATH}
    #  ...                             local_path=${CURDIR}/../config/swconfig_gNB.txt
    #  ...                             connection=${alias_gnb}

    #  # Set swconfig file AP
    #  ${alias_ap}                    SSH Wait For Connect                ${AP_DU.entryCard[0]}
    #  csn.upload_file                 remote_path=${SWCONFIG_PATH}
    #  ...                             local_path=${CURDIR}/../config/swconfig-AiP.txt
    #  ...                             connection=${alias_ap}

    # # Set iphy file AP
    #  ${alias_ap}                    SSH Wait For Connect                ${AP_DU.entryCard[0]}
    #  csn.upload_file                 remote_path=/ffs/run/simmode/iphy.xml
    #  ...                             local_path=${CURDIR}/../config/iphy-5MHz-3Cells.xml
    #  ...                             connection=${alias_ap}

#Change parameters online
Change in commissioning
    [Documentation]                 Generic test for 5GC002300 tests
    [Arguments]                     ${param}
  #  GenericTest.Init Sequence       ${param}
    Set MRBTSID and NRBTSID
    #${len}             Get Length    ${param}
    #Run Keyword if     ${len} > 1
    #...                Set Context_Element Manager         ${param}
    #...                ELSE
    #...                Set Context_Element Manager1390     ${param}
    Set Context_Element Manager1390     ${param}

Set MRBTSID and NRBTSID
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
    &{bts_info}    coam.Get Bts Info    connection=coam_admin
    ${mrbtsID} =           Get From Dictionary     ${bts_info}     mrbtsID
    Run    echo ${bts_info} >/tmp/bts_info.txt
    ${nrbtsID}    Run    grep -oE "NRBTS-[0-9]+" /tmp/bts_info.txt | awk -F '-' '{print $2}' | awk 'NR==1'
    ${dist_nameDU} =       Set Variable    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ${dist_name} =         Set Variable    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2
    ${ch_dist_name} =      Set Variable    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCELL_FDD-1
    ${MRBTS} =       Set Variable    MRBTS-${mrbtsID}
    Set Suite Variable             ${dist_name}
    Set Suite Variable             ${dist_nameDU}
    Dated log                      ${dist_name}
    Set Suite Variable             ${ch_dist_name}
    Set Suite Variable          ${MRBTS}

Set MRBTSID and NRBTSID_RWorked
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
    &{bts_info}    coam.Get Bts Info    connection=coam_admin
    ${mrbtsID} =           Get From Dictionary     ${bts_info}     mrbtsID
    Run    echo ${bts_info} >/tmp/bts_info.txt
    ${nrbtsID}    Run    grep -oE "NRBTS-[0-9]+" /tmp/bts_info.txt | awk -F '-' '{print $2}' | awk 'NR==1'
    ${MRBTS} =       Set Variable    MRBTS-${mrbtsID}
    ${DU} =       Set Variable    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ${dist_nameDU} =       Set Variable    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ${dist_name1} =         Set Variable    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ${dist_name2} =         Set Variable    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2
    ${Meth_name} =         Set Variable    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRREL-0
    ${ch_dist_name} =      Set Variable    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCELL_FDD-1
    Set Suite Variable             ${dist_name2}
    Dated log                      ${dist_name2}
    Set Suite Variable             ${Meth_name}
    Dated log                      ${Meth_name}
    Set Suite Variable             ${dist_nameDU}
    Dated log                      ${dist_name2}
    Set Suite Variable             ${ch_dist_name}
    Set Suite Variable          ${dist_name1}
    Set Suite Variable          ${DU}
    Set Suite Variable          ${MRBTS}


Set Context_Element Manager1390
    [Arguments]                     ${param}
    &{modify_param1}    Create Dictionary
    ...    parameter=carrierAggregationSupportList
    ...    dist_name=${dist_nameDU}
    ...    value=${param.carrierAggregationSupportList}
    @{modify_param}    Create List    ${modify_param1}
    Dated log                         Parameters to modify:\n ${modify_param}
    Oam.OAM Set Params
    ...                 ${modify_param}

Set Feature 2255
    Set parameters for 2255 in SCF
    Dated log                       Activated 2255: set actInterNumerologyCa to:                   first=True
    Dated log                       \t${param}

# Pcap Keywords

Capture L2PsPeer Messages
    [Documentation]                 Return pertinent capture L2PS GNB data structure
#    [Arguments]                     ${useWA}=True
    # ${capture}                      Dictionary Get                          ${CAPTURE_L2_GNB}
    ${capture}                      copyInstance                            ${CAPTURE_L2_GNB}
    [Return]                        ${capture}

Start Capture L2PS
   ${CaptureL2PS}                  Capture L2PsPeer Messages
   Capture Set Mirror			   ${MIRROR_L2_GNB}
   Capture Init                    ${CaptureL2PS}    withTN=True
   ${CaptureL2PS.filter}           Get Filter For Particular Msgs     ${FilterPSPeer}
   Capture Start                   ${CaptureL2PS}
   Set Suite Variable              ${CaptureL2PS}

Start Capture L2PS-DRX
   ${CaptureL2PS}                  Capture L2PsPeer Messages
   Capture Set Mirror			   ${MIRROR_L2_GNB}
   Capture Init                    ${CaptureL2PS}   withTN=True
   ${CaptureL2PS.filter}           Get Filter For Particular Msgs     ${FilterPSPeerDRX}
   Capture Start                   ${CaptureL2PS}
   Set Suite Variable              ${CaptureL2PS}


Stop Capture L2PS
   Capture Stop                    ${CaptureL2PS}

Start Capture CPRT ASIB
    ${CaptureCPRT_ASIB}             Capture CPRT Set Upon Config
    ${CaptureCPRT_ASIB.filter}      set Variable      sctp
    Set Suite Variable              ${CaptureCPRT_ASIB}
    Capture Init                    capture=${CaptureCPRT_ASIB}
    Capture Start                   ${CaptureCPRT_ASIB}

Start Capture CPRT ABIO 2slots
    ${CaptureCPRT}                  Capture on ABIO 2 slots            captureType=CPRT
    ${CaptureCPRT.filter}           set Variable      ether dst 02:40:43:80:11:33 or 02:40:43:80:12:33 or 02:40:43:80:11:22
    Set Suite Variable              ${CaptureCPRT}
    Capture Init                    capture=${CaptureCPRT}
    Capture Start                   ${CaptureCPRT}

Start Capture BIP ABIO 2slots
    ${CaptureL1L2}                  Capture on ABIO 2 slots            captureType=BIP
    Set Suite Variable              ${CaptureL1L2}
    Capture Init                    capture=${CaptureL1L2}
    Capture Start                   ${CaptureL1L2}

Stop Capture L1L2
   Capture Stop                    ${CaptureL1L2}

Stop Capture CPRT ASIB
   Capture Stop                    ${CaptureCPRT_ASIB}

Check_K1_Values_In_L2_PS_Cell_Setup_Resp_with_filter
    [Arguments]                   ${pcapFile}
    Dated Log                     pcapFile=${pcapFile}
    ${FilteredPcap}=              analyzer.filter_pcap
    #...                    pcapInFile=${pcapFile}    filterExp=itf_l2_ps_cell_CellSetupResp.CellSetupResp.nrCellIdentity == 0x0000000000004002
    ...                    pcapInFile=${pcapFile}    filterExp=itf_l2_ps_cell_CellSetupResp.CellSetupResp.nrCellIdentity
    ${pdmlFile}=                  analyzer.pcap_to_pdml           ${FilteredPcap}
    Dated Log                     pdmlFile=${pdmlFile}

    ${retvalue}      analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                                  packetName=itf_l2_ps_cell_cellsetupresp
    ...                                                  path=itf_l2_ps_cell_CellSetupResp.dlDataToUlAck.dlDataToUlAck_item_0
    ...                                                  kind="value"
    ...                                                  startPacket=2
    ...                                                  endPacket=2

    Dated Log                       retvalue=${retvalue}
    ${result_1}=	Convert To Integer	${retvalue}
    Dated Log                       result=${result_1}
    ${retvalue2}      analyzer.get_unique               pdmlFile=${pdmlFile}
    ...                                                  packetName=itf_l2_ps_cell_cellsetupresp
    ...                                                  path=itf_l2_ps_cell_CellSetupResp.dlDataToUlAck.dlDataToUlAck_item_1
    ...                                                  kind="value"
    ...                                                  startPacket=2
    ...                                                  endPacket=2
    Dated Log                       retvalue2=${retvalue2}
    ${result_2}=	Convert To Integer	${retvalue2}
    Dated Log                       result_1=${result_2}

    ### compare items
    ${valSum} =  Evaluate       ${result_1}+2
    Dated Log                       valSum=${valSum}
    should be equal as integers     ${valSum}    ${result_2}

Check_PsCell_NrRell_SCellSetupResponse
    [Arguments]                     ${pcapFile}
    Dated Log                       pcapFile=${pcapFile}
    #${FilteredPcap}=                analyzer.filter_pcap    pcapInFile=${pcapFile}    filterExp=itf_l2_ps_cell_nrrelscellsetupresp
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFile}
    ${pCell}                        set variable                        itf_l2_ps_cell_NrRelSCellSetupResp.NrRelSCellSetupResp.pCellNrCellIdentity
    ${sCell}                        set variable                        itf_l2_ps_cell_NrRelSCellSetupResp.NrRelSCellSetupResp.sCellNrCellIdentity
    Dated Log                       pdmlFile=${pdmlFile}
    analyzer.check_list             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_cell_nrrelscellsetupresp
    ...                             path=${pCell}
    ...                             value=^pCellNrCellIdentity*
    ...                             kind=showname
    ...                             test=MATCH
    analyzer.check_list             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_cell_nrrelscellsetupresp
    ...                             path=${sCell}
    ...                             value=^sCellNrCellIdentity*
    ...                             kind=showname
    ...                             test=MATCH

Check_PsPeerCtrl_ScellUeSchedulingReqResp
    [Arguments]                     ${pcapFile}
    Dated Log                       pcapFile=${pcapFile}
    #${FilteredPcap}=                analyzer.filter_pcap    pcapInFile=${pcapFile}
    #...                             filterExp=itf_l2_ps_peerctrl_scellueschedulingreq || itf_l2_ps_peerctrl_scellueschedulingresp
    #${pdmlFile}=                    analyzer.pcap_to_pdml           ${FilteredPcap}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFile}
    ${pCell}                        set variable                 itf_l2_ps_peerctrl_ScellUeSchedulingReq.ScellUeSchedulingReq.pCellNrCellIdentity
    ${sCell}                        set variable                 itf_l2_ps_peerctrl_ScellUeSchedulingReq.ScellUeSchedulingReq.sCellNrCellIdentity
    ${status}                       set variable                 itf_l2_ps_peerctrl_ScellUeSchedulingResp.messageResult.status
    Dated Log                       pdmlFile=${pdmlFile}
    analyzer.check_list             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_peerctrl_scellueschedulingreq
    ...                             path=${pCell}
    ...                             value=^pCellNrCellIdentity*
    ...                             kind=showname
    ...                             test=MATCH
    analyzer.check_list             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_peerctrl_scellueschedulingreq
    ...                             path=${sCell}
    ...                             value=^sCellNrCellIdentity*
    ...                             kind=showname
    ...                             test=MATCH
    analyzer.check_list             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_peerctrl_scellueschedulingresp
    ...                             path=${status}$
    ...                             value=.*EStatus5G_Ok.
    ...                             kind=showname
    ...                             test=MATCH

Check_PsPeerCtrl_ScellPucchReceiveRespPs
    [Arguments]                     ${pcapFile}
    Dated Log                       pcapFile=${pcapFile}
    #${FilteredPcap}=                analyzer.filter_pcap    pcapInFile=${pcapFile}
    #...                             filterExp=itf_l2_ps_peerctrl_scellpucchreceiveindps
    #${pdmlFile}=                    analyzer.pcap_to_pdml           ${FilteredPcap}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFile}
    ${TotalScellPucchReceiveIndPs}  Run
    ...                 cat ${pdmlFile} | grep -i "itf_l2_ps_peerctrl_ScellPucchReceiveIndPs.ueFeedbackList_item_55.csiBitIndex" -c
    ${csiBitIndexNoAck}             Run
    ...                 cat ${pdmlFile} | grep -i "itf_l2_ps_peerctrl_ScellPucchReceiveIndPs.ueFeedbackList_item_55.csiBitIndex" | grep -i "(0)" -c
    ${csiBitIndexAck}               Run
    ...                 cat ${pdmlFile} | grep -i "itf_l2_ps_peerctrl_ScellPucchReceiveIndPs.ueFeedbackList_item_55.csiBitIndex" | grep -i "(1)" -c
    ${csiBitIndexOther}             Run
    ...                 cat ${pdmlFile} | grep -i "itf_l2_ps_peerctrl_ScellPucchReceiveIndPs.ueFeedbackList_item_55.csiBitIndex" | grep -i "(2)" -c
    ${TotalScellPucchReceiveIndPs}=    Convert To Integer  ${TotalScellPucchReceiveIndPs}
    ${csiBitIndexNoAck}=               Convert To Integer  ${csiBitIndexNoAck}
    ${csiBitIndexAck}=                 Convert To Integer  ${csiBitIndexAck}
    ${csiBitIndexOther}=               Convert To Integer  ${csiBitIndexOther}
    ${csiBitIndexTotal}=               Evaluate   ${csiBitIndexNoAck}+${csiBitIndexAck}+${csiBitIndexOther}
#    ${csiBitIndexTotal}=               Evaluate   ${csiBitIndexNoAck}+${csiBitIndexAck}
    Should be equal as integers        ${TotalScellPucchReceiveIndPs}    ${csiBitIndexTotal}
    Dated Log                          ${TotalScellPucchReceiveIndPs}=${csiBitIndexTotal}
    #Dated Log                       ${csiBitIndexNoAck}
    #${uci}                          set variable                        itf_l2_ps_peerctrl_ScellPucchReceiveIndPs.uciBits.uciBits_item_0
    #Dated Log                       pdmlFile=${pdmlFile}
    #analyzer.check_list             pdmlFile=${pdmlFile}
    #...                             packetName=itf_l2_ps_peerctrl_scellpucchreceiveindps
    #...                             path=${uci}
    #...                             value=1e
    #...                             kind=value
    #...                             test=MATCH
    #...                             startPacket=1
    #...                             endPacket=1

Check_PsPeerCtrl_ScellPuschReceiveIndPs
    [Arguments]                     ${pcapFile}
    Dated Log                       pcapFile=${pcapFile}
    #${FilteredPcap}=                analyzer.filter_pcap    pcapInFile=${pcapFile}
    #...                             filterExp=itf_l2_ps_peerctrl_scellpuschreceiveindps
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFile}
    ${uci}                          set variable    itf_l2_ps_peerctrl_ScellPuschReceiveIndPs.uciCsiPart1Bits.uciCsiPart1Bits_item_0
    Dated Log                       pdmlFile=${pdmlFile}
    analyzer.check_list             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_peerctrl_scellpuschreceiveindps
    ...                             path=${uci}
    ...                             value=9e                     # from 1e to 9e With latest AiP, RI=1 by default
    ...                             kind=value
    ...                             test=MATCH
    ...                             startPacket=1
    ...                             endPacket=1

Check_L2_Ps_User_userSetup_Req
    [Arguments]                     ${pcapFile}
    Dated Log                       pcapFile=${pcapFile}
    #${FilteredPcap}=                analyzer.filter_pcap    pcapInFile=${pcapFile}
    #...                             filterExp=itf_l2_ps_peerctrl_scellpuschreceiveindps
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFile}
    ${scellActivationMethod}        set variable    itf_l2_ps_user_UserSetupReq.UserSetupReq.sCellActivationMethod
    Dated Log                       pdmlFile=${pdmlFile}
    analyzer.check_list             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_user_usersetupreq
    ...                             path=${scellActivationMethod}$
    ...                             value=01
    ...                             kind=value
    ...                             test=MATCH
    ...                             startPacket=1
    ...                             endPacket=1

Check_uedatadeliverystatusind
    [Arguments]                     ${pcapFile}    ${mode}=NoOH
    ${startPacketOH}                set variable   1
    #Dated Log                       ${startPacketOH}
    ${startPacketNoOH}              set variable   2
    #Dated Log                       ${startPacketNoOH}
    ${startPacket}=                 set variable if    '${mode}'=='NoOH'    ${startPacketNoOH}    ${startPacketOH}
    Dated Log                       ${startPacket}
    ${FilteredPcap}=                analyzer.filter_pcap
    ...                             pcapInFile=${pcapFile}    filterExp=eth.src == 02:40:43:80:01:3a
    ${FilteredPcap2}=               analyzer.filter_pcap
    ...                             pcapInFile=${FilteredPcap}
    #...                             filterExp=itf_l2_lo_data_UeDataDeliveryStatusInd.drbStatusInfo_item_255.l2loActivatedForData == 1
    ...                             filterExp=itf_l2_lo_data_UeDataDeliveryStatusInd.drbStatusInfo_item_0.l2loActivatedForData == 1
    ${pdmlFileFiltered}=            analyzer.pcap_to_pdml           ${FilteredPcap}
    ${pdmlFileFiltered2}=           analyzer.pcap_to_pdml           ${FilteredPcap2}
    Dated Log                       pdmlFile=${pdmlFileFiltered}
#    ${l2loActivatedForData}         set variable    itf_l2_lo_data_UeDataDeliveryStatusInd.drbStatusInfo_item_255.l2loActivatedForData
    ${l2loActivatedForData}         set variable    .*l2loActivatedForData$
    analyzer.check_exists_once      pdmlFile=${pdmlFileFiltered}
    ...                             packetName=itf_l2_lo_data_uedatadeliverystatusind
    ...                             path=${l2loActivatedForData}
    ...                             value=00
    ...                             kind=value
    ...                             test=MATCH
    ...                             startPacket=1
    ...                             endPacket=-1
    analyzer.check_exists_once      pdmlFile=${pdmlFileFiltered2}
    ...                             packetName=itf_l2_lo_data_uedatadeliverystatusind
    ...                             path=${l2loActivatedForData}
    ...                             value=01
    ...                             kind=value
    ...                             test=MATCH
    ...                             startPacket=${startPacket}
    ...                             endPacket=-1

Collect PM Counters File
    [Documentation]                 KW to get counters and store in specific directory with day date

    ${date}                          robot.libraries.DateTime.Get Current Date
    ${date_in_dir_name}              robot.libraries.DateTime.Convert Date         ${date}     result_format=%d%m%Y_%H%M
    ${log_path_pm}                   Set Variable         ${LOG_PATH}/PM_${date_in_dir_name}
    BuiltIn.Log              The PM counters file collected from gnb will be stored under : ${log_path_pm}
    ${pm_latest}                    Counters.Collect PM files from BTS    ${log_path_pm}
    set Suite Variable              ${LATEST_FILE}       ${pm_latest}
    set Suite Variable              ${log_path_pm}
    BuiltIn.Log     Latest pm counters file : ${LATEST_FILE}

Check ScellAdditionCounters
    [Arguments]         ${expectedValue}    ${expectedValue2}
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}   &{PM_Counter_ReconfScell_WITHID_EXPECTED}
    Dated Log           Valeur de ${PM_Counter_ReconfScell} ${val}
    should be true      ${expectedValue} == ${val}
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_RRC_ReconfScell_WITHID_EXPECTED}
    Dated Log           Valeur de ${PM_Counter_RRC_ReconfScell} ${val}
    should be true      ${expectedValue} == ${val}
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_UEinPcellwithScell_WITHID_EXPECTED}
    Dated Log           Valeur de ${PM_Counter_UEinPcellwithScell} ${val}
    should be true      ${expectedValue2} < ${val}

Check ScellAdditionCounterinScell
    [Arguments]         ${expectedValue}
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_UEinScellwithPcell_WITHID_EXPECTED}
    Dated Log           Valeur de ${PM_Counter_UEinScellwithPcell} ${val}
    should be true      ${expectedValue} < ${val}

Check TrafficInScell
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_ScellTraffic_WITHID_EXPECTED}
    Dated Log           Valeur de ${PM_Counter_ScellTraffic} ${val}
    should be true      ${val} > 0

Check ScellActivationCounters
    [Arguments]         ${expValue1}=0    ${expValue2}=0    ${expValue3}=0    ${expValue4}=0
    ...                 ${expValue5}=0    ${expValue6}=0    ${expValue7}=0    ${expValue8}=0
    ...                 ${expValue9}=0
    #M55316C0300x for Pcell
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_UEinPcellwith0ActScell_PCell_WITHID_EXPECTED}
    Dated Log           Value of ${PM_Counter_UEinPcellwith0ActScell} ${val} in Pcell
    ${expValue1}=    Evaluate  ${expValue1} * 1
    #Run Keyword if      ${expValue1}==0
    Run Keyword if      ${expValue1}!=0
    #...                 should be true      ${expValue1} == ${val}
    #...                 ELSE
    #...                 should be true      ${expValue1}*3 > ${val} >= ${expValue1}*2
    ...                 should be true      ${expValue1}*3 > ${val} >= ${expValue1}*1
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_UEinPcellwith1ActScell_PCell_WITHID_EXPECTED}
    Dated Log           Value of ${PM_Counter_UEinPcellwith1ActScell} ${val} in Pcell
    ${expValue2}=    Evaluate  ${expValue2} * 1
    #Run Keyword if      ${expValue2}==0
    Run Keyword if      ${expValue2}!=0
    #...                 should be true      ${expValue2} == ${val}
    #...                 ELSE
    ...                 should be true      ${expValue2} > ${val}
    #M55316C0300x for Scell
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_UEinPcellwith0ActScell_SCell_WITHID_EXPECTED}
    Dated Log           Value of ${PM_Counter_UEinPcellwith0ActScell} ${val} in Scell
    ${expValue3}=    Evaluate  ${expValue3} * 1
    Run Keyword if      ${expValue3}!=0
    #...                 should be true      ${expValue3} == ${val}
    #...                 ELSE
    ...                 should be true      ${expValue3}*3 > ${val} >= ${expValue3}*2
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_UEinPcellwith1ActScell_SCell_WITHID_EXPECTED}
    Dated Log           Value of ${PM_Counter_UEinPcellwith1ActScell} ${val} in Scell
    ${expValue4}=    Evaluate  ${expValue4} * 1
    Run Keyword if      ${expValue4}!=0
    #...                 should be true      ${expValue4} == ${val}
    #...                 ELSE
    ...                 should be true      ${expValue4}*3 > ${val} >= ${expValue4}*2
    #M55316C0500x for Pcell
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_MaxUEinPcellwith0ActScell_PCell_WITHID_EXPECTED}
    Dated Log           Value of ${PM_Counter_MaxUEinPcellwith0ActScell} ${val} in Pcell
    ${expValue5}=       Evaluate  ${expValue5} * 1
    Run Keyword if      ${expValue5}!=0
    ...                 should be true      ${expValue5} <= ${val} <= ${expValue5}*3
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_MaxUEinPcellwith1ActScell_PCell_WITHID_EXPECTED}
    Dated Log           Value of ${PM_Counter_MaxUEinPcellwith1ActScell} ${val} in Pcell
    ${expValue6}=       Evaluate  ${expValue6} * 1
    Run Keyword if      ${expValue6}!=0
    ...                 should be true      ${expValue6} <= ${val} <= ${expValue6}*2
    #M55316C0500x for Scell
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_MaxUEinPcellwith0ActScell_SCell_WITHID_EXPECTED}
    Dated Log           Value of ${PM_Counter_MaxUEinPcellwith0ActScell} ${val} in Scell
    Run Keyword if      ${expValue7}!=0
    ...                 should be true      ${expValue7} == ${val}
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_MaxUEinPcellwith1ActScell_SCell_WITHID_EXPECTED}
    Dated Log           Value of ${PM_Counter_MaxUEinPcellwith1ActScell} ${val} in Scell
    Run Keyword if      ${expValue8}!=0
    ...                 should be true      ${expValue8} == ${val}
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_ScellActivationScell_SCell_WITHID_EXPECTED}
    Dated Log           Value of ${PM_Counter_ScellActivationScell} ${val} in Scell
    Run Keyword if      ${expValue9}!=0
    ...                 should be true      ${expValue9} == ${val}


Check TrafficUplink
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_UlRLCDdataPDUsReceivedByLowRLC_PCell_WITHID_EXPECTED}
    Dated Log           Value of ${PM_Counter_UlRLCDdataPDUsReceivedByLowRLC} ${val} in Pcell
    #should be true      ${expValue1} < ${val} < ${expValue2}
    should be true      0 < ${val}
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_UlRLCDdataPDUsReceivedByLowRLC_SCell_WITHID_EXPECTED}
    Dated Log           Value of ${PM_Counter_UlRLCDdataPDUsReceivedByLowRLC} ${val} in Pcell
    should be true      0 == ${val}

Check ScellDeactivationCounter
    [Arguments]         ${expValue1}
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_ScellDeactBufferStatus_SCell_WITHID_EXPECTED}
    Dated Log           Value of ${PM_Counter_ScellDeactBufferStatus} ${val} in Scell
    should be true      ${expValue1} == ${val}

Check ScellDeactivationCounterChannelState
    [Arguments]         ${expValue1}
    ${val}=    Counters.Retrieve Sum of Values Counter From Pm Files with CellID
    ...        ${log_path_pm}    &{PM_Counter_ScellDeactChannelState_SCell_WITHID_EXPECTED}
    Dated Log           Value of ${PM_Counter_ScellDeactChannelState} ${val} in Scell
    should be true      ${expValue1} == ${val}

5GC002255_PMCounterCheck_In_A_Range
     [Documentation]   Check the value of a counter is in range of MinRange and MaxRage
    ...                before using this Keyword you must call 5GC002255_Keywords.Collect PM Counters File
    ...                with arguments
    ...                ${Counter_Id1}: name of the counter (ex : M55311C01001)
    ...                &{MinRange}: min value of the counter
    ...                &{MaxRange}: max value of the counter
    CB007873_Keywords.Collect PM Counters File
    [Arguments]         ${Counter_Id1}         ${MinRange}         ${MaxRange}
    ${val}=    Counters.Retrieve Latest Single Counter Value From Pm File           ${LATEST_FILE}        ${Counter_Id1}
    Dated Log           [5GC002255_PMCounterCheck_In_A_Range] Value of ${Counter_Id1} = ${val}
    should be true      ${MinRange} <= ${val} <= ${MaxRange}

5GC002255_PMCounterCheck_Expected_Value
     [Documentation]   Check the value of a counter is egal to an exepted value
    ...                before using this Keyword you must call 5GC002255_Keywords.Collect PM Counters File
    ...                with arguments
    ...                ${Counter_Id1}: name of the counter (ex : M55311C01001)
    ...                &{ExpValue}: value expected
    [Arguments]         ${Counter_Id1}         ${ExpValue}
    ${val}=    Counters.Retrieve Latest Single Counter Value From Pm File           ${LATEST_FILE}        ${Counter_Id1}
    Dated Log           [5GC002255_PMCounterCheck_Expected_Value] Value of ${Counter_Id1} = ${val}
    should be true      ${val} == ${ExpValue}

5GC002255_PMCounterCheck_Compare_Counters_egal
     [Documentation]   Check the value of 2 counters are egal
    ...                before using this Keyword you must call 5GC002255_Keywords.Collect PM Counters File
    ...                with arguments
    ...                ${Counter_Id1}: name of the first counter (ex : M55311C01001)
    ...                ${Counter_Id2}: name of the second counter (ex : M55311C01002)
    [Arguments]         ${Counter_Id1}         ${Counter_Id2}
    ${val1}=    Counters.Retrieve Latest Single Counter Value From Pm File           ${LATEST_FILE}        ${Counter_Id1}
    Dated Log           [5GC002255_PMCounterCheck_Compare_Counters_egal] Value of ${Counter_Id1} = ${val1}
    ${val2}=    Counters.Retrieve Latest Single Counter Value From Pm File           ${LATEST_FILE}        ${Counter_Id2}
    Dated Log           [5GC002255_PMCounterCheck_Compare_Counters_egal] Value of ${Counter_Id2} = ${val2}
    should be true      ${val1} == ${val2}

5GC002255_PMCounterCheck_Sum_eqal
     [Documentation]   Check the sum of 2 first counters are egal to the third counter with range 1
    ...                before using this Keyword you must call 5GC002255_Keywords.Collect PM Counters File
    ...                with arguments
    ...                ${Counter_Id1}: name of the first counter (ex : M55311C01001)
    ...                ${Counter_Id2}: name of the second counter (ex : M55311C01002)
    ...                ${Counter_Id3}: name of the third counter (ex : M55311C01003)
    [Arguments]         ${Counter_Id1}         ${Counter_Id2}         ${Counter_Id3}
    ${val1}=    Counters.Retrieve Latest Single Counter Value From Pm File           ${LATEST_FILE}        ${Counter_Id1}
    Dated Log           [5GC002255_PMCounterCheck_Sum_eqal] Value of ${Counter_Id1} = ${val1}
    ${val2}=    Counters.Retrieve Latest Single Counter Value From Pm File           ${LATEST_FILE}        ${Counter_Id2}
    Dated Log           [5GC002255_PMCounterCheck_Sum_eqal] Value of ${Counter_Id2} = ${val2}
    ${val3}=    Counters.Retrieve Latest Single Counter Value From Pm File           ${LATEST_FILE}        ${Counter_Id3}
    Dated Log           [5GC002255_PMCounterCheck_Sum_eqal] Value of ${Counter_Id3} = ${val3}
    should be true      (${val3} -1) <=(${val1} + ${val2}) <= (${val3} +1)

5GC002255_Check _DRX_Mode
     [Documentation]   Check the DRX configuration in last RRC RECONF in egate
    ...                with arguments
    ...                ${LongCycleStart}: value of the drx-InactivityTimer expeted
    ...                ${InactivityTimer}: value of the drx-LongCycleStartOffset expeted
    [Arguments]         ${LongCycleStart}         ${InactivityTimer}
    ${cmd}      Catenate
    ...                      cd ${tl.core.dir_path};
    ...                      grep -i drx-InactivityTimer egate_console.log | tail -1
    ${output}                       SSH Wait For Connect and Cmd
    ...                             command=${cmd}
    ...                             host=${HOST_EPCSIM}
    should contain	${output}	drx-InactivityTimer ${InactivityTimer}
    ${cmd}      Catenate
    ...                      cd ${tl.core.dir_path};
    ...                      grep -i drx-LongCycleStartOffset egate_console.log | tail -1
    ${output}                       SSH Wait For Connect and Cmd
    ...                             command=${cmd}
    ...                             host=${HOST_EPCSIM}
    should contain	${output}   drx-LongCycleStartOffset ${LongCycleStart} :

Check TrafficDownlink
    # When buffer based and traffic 20Mbps both legs should traffic. M55311C42006 M55311C44006 should increase their values
    [Arguments]         ${expValue1}    ${expValue2}
     log to console     ${expValue1}    ${expValue2}

Check DSS Counters
    [Arguments]         ${DLSlots}    ${ULPRB}
    ${val}=    Retrieve Latest Single Counter Value From Pm File with CellID
    ...        ${LATEST_FILE}    ${PM_Counter_DSSDlSlots}    2
    Dated Log           Value of ${PM_Counter_DSSDlSlots} ${val} in Pcell
    ${minDLSlots}=   Evaluate  ${DLSlots}*0.9
    ${maxDLSlots}=   Evaluate  ${DLSlots}*1.1
    should be true    ${minDLSlots} < ${val} <= ${maxDLSlots}
    ${val}=    Retrieve Latest Single Counter Value From Pm File with CellID
    ...        ${LATEST_FILE}    ${PM_Counter_DSSUlPRB}    2
    Dated Log           Value of ${PM_Counter_DSSUlPRB} ${val} in Pcell
    ${minULPRB}=   Evaluate  ${ULPRB}*0.9
    ${maxULPRB}=   Evaluate  ${ULPRB}*1.1
    should be true    ${minULPRB} < ${val} <= ${maxULPRB}

Set SCF Context DSS
    Copy File                       ${SCF_SETUP_PATH}     ${SCF_SETUP_PATH}.ori
    #Config Update                               scf_file=${SCF_SETUP_PATH}
    SCF StartSession                scf_file=${SCF_SETUP_PATH}

    ${dist_name}         Set Variable    MRBTS-1
    SCF Set element    dist_name=${dist_name}    element_name=btsName  element_value=5GC002255-G

    ${dist_name}         Set Variable    MRBTS-1/NRBTS-1
    SCF Set element    dist_name=${dist_name}    element_name=actGeneralConnectivityGold  element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=actLteNrDss   element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=sCellActivationMethod   element_value=blind

    ${dist_name}         Set Variable    MRBTS-1/NRBTS-1/NRCELL-1
    SCF Set element    dist_name=${dist_name}    element_name=sCellDeactivationTimerGNB   element_value=infinity
    SCF Set element    dist_name=${dist_name}    element_name=srPeriodicity   element_value=slots80

    ${dist_name}         Set Variable    MRBTS-1/NRBTS-1/NRCELL-2
    SCF Set element    dist_name=${dist_name}    element_name=actPRBBlanking   element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=actPdschAtSsbSlots   element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=actPdschRmCsirsForTracking   element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=lteNrDssMode   element_value=DL_CRS_TDM_UL_FDM
    SCF Set element    dist_name=${dist_name}    element_name=msg1FrequencyStart   element_value=9
    SCF Set element    dist_name=${dist_name}    element_name=nbrOfBlankedPRBsHighEdgeDL   element_value=2
    SCF Set element    dist_name=${dist_name}    element_name=nbrOfBlankedPRBsHighEdgeUL   element_value=2
    SCF Set element    dist_name=${dist_name}    element_name=pagingOffset   element_value=2
    SCF Set element    dist_name=${dist_name}    element_name=pucchF3ModulationScheme   element_value=pi2bpsk
    SCF Set element    dist_name=${dist_name}    element_name=trsMutingInBlankedPRBsEnabled   element_value=true
    SCF Set element    dist_name=${dist_name}    element_name=type0SearchSpaceConfigurationIndex   element_value=15
    SCF Set element    dist_name=${dist_name}    element_name=sCellDeactivationTimerGNB   element_value=infinity
    SCF Set element    dist_name=${dist_name}    element_name=srPeriodicity   element_value=slots80

    SCF Remove list    dist_name=${dist_name}    list_name=cellBwpList
    SCF Add list       dist_name=${dist_name}    list_name=cellBwpList

    &{cellBwpList}     Create Dictionary    bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-162   cellBwpId=0
    SCF Add items to list   dist_name=${dist_name}    list_name=cellBwpList   elements=${cellBwpList}
    &{cellBwpList}     Create Dictionary    bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-173   cellBwpId=1
    SCF Add items to list   dist_name=${dist_name}    list_name=cellBwpList   elements=${cellBwpList}

    SCF Set element in List    dist_name=${dist_name}    list_name=csirsForTracking     element_name=csirsTrackingPeriod   element_value=40ms

    ${dist_name}         Set Variable    MRBTS-1/NRBTS-1/NRCELL-2/NRREL-0
    SCF Set element    dist_name=${dist_name}    element_name=gNbId   element_value=2

    ${dist_name}         Set Variable    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-2
    SCF Set element    dist_name=${dist_name}    element_name=siWindowLength   element_value=s160
    SCF Set element    dist_name=${dist_name}    element_name=systemInformationTargetRate   element_value=0

    SCF Remove list    dist_name=${dist_name}    list_name=sibSchedulingList
    SCF Add list       dist_name=${dist_name}    list_name=sibSchedulingList

    &{sibSchedulingList}     Create Dictionary    sibBroadcastStatus=broadcasting   sibPeriodicity=rf64   sibScope=cellSpecific   sibType=sibType2
    SCF Add items to list   dist_name=${dist_name}    list_name=sibSchedulingList   elements=${sibSchedulingList}
    &{sibSchedulingList}     Create Dictionary    sibBroadcastStatus=broadcasting   sibPeriodicity=rf64   sibScope=cellSpecific   sibType=sibType3
    SCF Add items to list   dist_name=${dist_name}    list_name=sibSchedulingList   elements=${sibSchedulingList}
    &{sibSchedulingList}     Create Dictionary    sibBroadcastStatus=broadcasting   sibPeriodicity=rf64   sibScope=cellSpecific   sibType=sibType4
    SCF Add items to list   dist_name=${dist_name}    list_name=sibSchedulingList   elements=${sibSchedulingList}
    &{sibSchedulingList}     Create Dictionary    sibBroadcastStatus=broadcasting   sibPeriodicity=rf64   sibScope=cellSpecific   sibType=sibType5
    SCF Add items to list   dist_name=${dist_name}    list_name=sibSchedulingList   elements=${sibSchedulingList}

    SCF StopSession      scf_file=${SCF_SETUP_PATH}
    Dated Log    ----> Modifications completed.\n

    ${SCF_SETUP_PATH}         OAM Change String in SCF          oldVal=MRBTS-1/NRBTS-1     newVal=MRBTS-1/NRBTS-2

    OAM Perform Full Commissioning          scf_file=${SCF_SETUP_PATH}
    WA Airscale Wait For Ready                  ${GNB_DU}
    Dated Log    ----> Airscale Ready.\n


Capture Set Mirror
    [Documentation]                 Apply a mirroring setting
    [Arguments]                     ${mirror}
    # Apply mirroring for sport1, and sport2 if required
    Dbgrrc Mirror                   ${mirror.sport1}                        ${mirror.dport}         ${mirror.host}
    Dbgrrc Mirror                   ${mirror.sport2}                        ${mirror.dport}         ${mirror.host}

Dbgrrc Mirror
    [Documentation]                 Basic service to mirror a source port onto a destination port
    [Arguments]                     ${sport}                                ${dport}
    ...                             ${host}
    Run Keyword if                  ${sport}>0                              Run Keywords
    ...                             Dated log                               Set mirror on ${host.alias} : mirror sport ${sport} on ${dport}
    ...                             AND
    ...                             SSH Wait For Connect and Cmd            dbgrrc mirror sport ${sport} dport ${dport} enable both
    ...                             host=${host}

Setup UEs Profiles
    @{UE_profiles_list}    Create List     ${BASIC_UE_SA}    ${BASIC_UE_SA}    ${BASIC_UE_SA}    ${BASIC_UE_SA}    ${BASIC_UE_SA}    ${BASIC_UE_SA}
    FOR    ${index}    IN RANGE     1    6
        ${elem}     set variable     ${UE_profiles_list}[${index-1}]
        ${elem.ue}        Set Variable     3
        ${elem.pdu}       Set Variable     3
        ${elem.qfi}       Set Variable If
        ...     ${index+1}==1        1
        ...     ${index+1}==2        1
        ...     ${index+1}==3        2
        ...     ${index+1}==4        2
        ...     ${index+1}==5        3
        ...     ${index+1}==6        3
        ${elem.trf_id}        Set Variable          ${index}
    END
    Set Suite Variable     ${UE_profiles_list}

#Full Commission SCF
#    [Arguments]    ${scf_file}
##    ${scf_file_path}    ==      scf file path     ${scf_file}
##    COAM.Setup Admin
#    ute_adm.Setup Admin    alias=cOAM
##    ${join_scf_path}=    OperatingSystem.Join Path    ${scf_path}    ${SW_BRANCH}    ${scf_file}
#    ute_adm.Perform Commissioning
#    ...    bts_id=1
#    ...    scf_file=${scf_file}
#    ...    skip_parameter_relation_errors=True
#    ...    should_activate=True
#    ...    timeout=500
##    ...    alias=cOAM
#    Run Keyword And Ignore Error    ute_adm.Teardown Admin    alias=cOAM

Full Commission SCF
    [Arguments]    ${scf_file}
    ute_adm.Setup Admin    alias=cOAM
    ${join_scf_path}=    OperatingSystem.Join Path    ${scf_path}    ${SW_BRANCH}    ${scf_file}
    ute_adm.Perform Commissioning
    ...    bts_id=1
    ...    scf_file=${join_scf_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=500
    ...    alias=cOAM
    Run Keyword And Ignore Error    ute_adm.Teardown Admin    alias=cOAM



Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}
#    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    5min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    ${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    set Suite variable      ${file_name}
#    Check gNB Airscale is Ready - ${BBoard_Type}
#    Start Collecting Syslog    NAME=cell_setup
#    run keyword if     '${BBoard_Type}'=='ABIL'     CPRT Monitoring Start ABIL
#    ...    ELSE        Start CPRT Trace Capturing
    Log To console     loading cfg file
    Start WTS Using WTS_Runner      ${wts_cfg_file}
#    run keyword if     '${BBoard_Type}'=='ABIL'     CPRT Monitoring Stop Collect ASOE      ${LOG_PATH}
#    ...    ELSE        Stop CPRT capture     ${CaptureCPRT}
#    run keyword if     '${BBoard_Type}'=='ABIL'     Move File      ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/${file_name}
#    ...    ELSE        Move File      ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/${file_name}
#    run keyword if     '${BBoard_Type}'=='ABIL'     Move File      ${LOG_PATH}/External_NODECPRT_GNB.pcap
#    ...     ${LOG_PATH}/External_NODECPRT_GNB_cellsetup.pcap
    log to console     ${file_name}
# Stop Collecting Syslog     NAME=cell_setup
#    CellSetupRequest Should contain powersavingBWP in the capture       ${file_name}

#Check gNB Airscale is Ready - ${AirScale}
#    Dated log   \n  Check gNB Airscale is Ready - ABIL
#    ${GNB_NODE_1}=    get variable value  ${AIRSCALE_GNB.listNodeId[0]}
#    ${GNB_NODE_2}=    get variable value  ${AIRSCALE_GNB.listNodeId[1]}
#    run keyword if    '${AirScale}'=='ASIK'    gNB Check Airscale One Time for ${GNB_NODE_1} and ${GNB_NODE_2}
#    run keyword if    '${AirScale}'=='ASIB'    gNB Check Airscale One Time for ${GNB_NODE_1} and ${GNB_NODE_2}
#    run keyword if    '${AirScale}'=='ASOE'    gNB Check Airscale One Time for ${GNB_NODE_1} and ${GNB_NODE_1}
#    run keyword if    '${AirScale}'=='ABIL'    gNB Check Airscale One Time for ${GNB_NODE_1} and ${GNB_NODE_1}

Set CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture init        ${capture_var_cprt}
    Capture start       ${capture_var_cprt}

Set L1L2 capture
    [Arguments]         ${capture_var_l1l2}
    Capture init        ${capture_var_l1l2}
    Capture start       ${capture_var_l1l2}

Stop CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture stop        ${capture_var_cprt}

Stop L1L2 capture
    [Arguments]         ${capture_var_l1l2}
    Capture stop        ${capture_var_l1l2}

Start CPRT Trace Capturing
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set suite variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}

Start L2 BIP Trace Capturing
    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set suite variable    ${CaptureL1L2}    ${capture_l1l2}
    Set L1L2 capture  ${CaptureL1L2}

Start Collecting Syslog
    [Arguments]    ${NAME}      ${VM_IP}=${tl.test_pc.default_ssh_connection_details.addr}
    ${ports}=   Create List   51000    51001    51003    50011
    ${CURRENT_SYSLOG_PATH}  Set Variable     ${LOG_PATH}/
    set suite variable      ${CURRENT_SYSLOG_PATH}
    set suite variable      ${logname}     syslog_${NAME}.log
    Start Syslog  log_dir=${CURRENT_SYSLOG_PATH}  log_name=${logname}   ip=192.168.255.126
    ...    host_ip=${VM_IP}   ssh_username=ute    ssh_password=ute    ports=${ports}  alias=${NAME}

Stop Collecting Syslog
    [Arguments]    ${NAME}
    ${file_path}    Collect Syslog Results    alias=${NAME}
    [Return]      ${file_path}

Stop Btslog Collect
    [Timeout]  3 hours
    [Arguments]               ${names}=${NAME}     ${target_dir}=${LOG_PATH}
    log to console     Stopping BTS logger
    run keyword and ignore error      core.stop_collectors    names=${names}
    run keyword and ignore error      core.collect_collectors      names=${names}    target_dir=${target_dir}
    core.teardown_collectors      names=${names}

Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Get_Snapshot_gNB
    Setup.Get Snapshot

CB007873_Keywords.Start WTS Using WTS_Runner
    [Arguments]             ${wts_cfg_file}
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                      file=${wts_cfg_file}
    wtsrunner.read_wtsemu_output_until_re    expected=SimMode is ready now     timeout=240
    wtsrunner.sim_state_disp
    wtsrunner.read_wtsemu_output_until_re    expected=The state is ACTIVE   timeout=120
    sleep    120s

UE Register should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}


Generate 300mpbs traffic
    [Arguments]    ${ue_id}    ${pdu_id}     ${qfi_id}
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID1}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID2}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID3}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID4}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID5}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID6}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID7}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID8}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID9}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID10}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID11}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID12}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID13}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID14}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID15}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID16}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID17}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID18}      qfi_id=${qfi_id}
    sleep   5s

Send Swconfig for GNB
    [Arguments]    ${gnb_swconfig}
    [Documentation]    This keyword is used to put swconfig.txt to GNB.
    ...    | Input Parameters | Man. | Description |
    ...    | ${gnb_swconfig} | Yes | gnb_swconfig.txt with absolute path |
    ...
    ...    Examples:
    ...    | Send Swconfig for GNB | ${CURDIR}/config_files/gnb_swconfig.txt |
    ute_fsmaccess.Setup Enb Fsm Access
    ute_fsmaccess.Put Enb Swconfig File    ${gnb_swconfig}    partition=active
    ute_fsmaccess.Execute Command On Enb    crasign /ffs/run/swconfig.txt
    ute_fsmaccess.Teardown Enb Fsm Access

Send Swconfig for AP
    [Arguments]    ${ap_swconfig}
    [Documentation]    This keyword is used to put swconfig.txt to Airphone.
    ...    | Input Parameters | Man. | Description |
    ...    | ${ap_swconfig} | Yes | ap_swconfig.txt with absolute path |
    ...
    ...    Examples:
    ...    | Send Swconfig for AP | ${CURDIR}/config_files/ap_swconfig.txt |
    ute_fsmaccess.Setup Wts Fsm Access
    ute_fsmaccess.Put Wts File    ${ap_swconfig}    /ffs/run/swconfig.txt    partition=active
    ute_fsmaccess.Execute Command On Wts    crasign /ffs/run/swconfig.txt
    ute_fsmaccess.Teardown Wts Fsm Access

Validate PM Counters
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-1

Check PM counter value equal
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        checks that the value of a counter in the last reporting period is equal to a given value
    ...
    ...        :param expected_value is the value compared to counter value
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${expected_value}   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   Get PM counter value   ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    ${expected_value}=   convert to integer    ${expected_value}
    should be equal  ${pi_value}   ${expected_value}     PM Counter ${pi_id} expected to be == ${expected_value} but is ${pi_value}



Collect PM Counter
    [Documentation]    :Author: Jing Liang
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param collector_alias: (default gnb_pm_counters) alias name for collector
    ...    :param target_dir: (default None) save PM Counter files to path
    ...    :param component: (default=DU, options : DU/CU) If oam type is cloud coam for vRAN 1.0
    ...          the DU component is commissioned by default
    ...
    ...    :return: Location of collected PM counter files
    [Arguments]    ${gnb_id}=0    ${du_id}=0    ${collector_alias}=gnb_pm_counters    ${target_dir}=None  ${component}=DU
    Check if CU http port is configured for classical GNB
    ${oam_type}=    testline.Get OAM Type    gnb_id=${gnb_id}
    ${du_host_ip}=   gnb_lib.Get GNB DU Host IP   ${tl.gnbs[${gnb_id}].dus[${du_id}]}
    ${webservice}=  Run Keyword if  '${oam_type}'=='cloud_coam' and '${component}'=='DU'
    ...  Create Dictionary
    ...    host=${du_host_ip}
    ...    user=Nemuadmin
    ...    password=nemuuser
    ...    port=443
    ...    ELSE  Create Dictionary
    ...    host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...    user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...    port=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}

    ${oam_type}=    Set Variable If
    ...    '${oam_type}'=='megazone'    mzoam
    ...    '${oam_type}'=='coam' or '${oam_type}'=='cloud_coam' and '${component}'=='DU'         coam
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    collect_pm.Create PM Collector    name=${collector_alias}    webservice=${webservice}    oam_type=${oam_type}
    collect_pm.Setup Collectors       names=${collector_alias}
    collect_pm.Collect Collectors     names=${collector_alias}    target_dir=${target_dir}
    collect_pm.Teardown Collectors    names=${collector_alias}
    [Return]    ${target_dir}/${collector_alias}

conv_KB_to_MB
    [Arguments]         ${val}
        ${megabyte}=  Set Variable     float(0.008)
        ${convert_mb}=  Evaluate    ${megabyte}*${val}
        Dated Log           Valeur de ${convert_mb}
        [Return]                        ${convert_mb}

Throughput_UL
    [Arguments]         ${megabytes_UL}    ${expectedValue}
    ${val}=  Evaluate    float(${megabytes_UL}) / 300
    Dated Log           Valeur de ${val}
    ${expectedValue1} =  Evaluate     ${expectedValue} + 2
    ${expectedValue2} =  Evaluate     ${expectedValue} - 10
    should be true       '${expectedValue2}'<'${val}' or '${expectedValue1}'>'${val}'

Throughput
    [Arguments]         ${megabytes1}    ${megabytes2}    ${expectedValue}
    ${sum_val}=  Evaluate    ${megabytes1} + ${megabytes2}
    ${val}=  Evaluate    float(${sum_val}) / 300
    Dated Log           Valeur de ${val}
    ${expectedValue1} =  Evaluate     ${expectedValue} + 2
    ${expectedValue2} =  Evaluate     ${expectedValue} - 25
    should be true       '${expectedValue2}'<'${val}' or '${expectedValue1}'>'${val}'

Modify Iphy Xml
    [Arguments]    ${wts_ap_xml}    ${xml_params_dict}
    Get Iphy Xml From Airphone    ${output_dir}
    Modify Xml File    ${file_path}    ${wts_ap_xml}    ${xml_params_dict}
    Send Iphy Xml To Airphone    ${output_dir}/iphy.xml


Get IPHY XML From Airphone
    [Arguments]    ${save_dir}
    [Documentation]    This keyword is to get iphy.xml from Airphone, return file_path include name
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${save_dir} | Yes | where to save iphy.xml |
    ...
    ...    Examples:
    ...    | ${iphy_path} | Get IPHY XML From Airphone | ${OUTPUT_DIR} |
    ...
    OperatingSystem.Run    sshpass -p ${AP_ASIK.password} scp ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy.xml ${save_dir}
    OperatingSystem.Should Exist    ${save_dir}/iphy.xml
    ${iphy_path}    Set Variable    ${save_dir}/iphy.xml
    [Return]    ${iphy_path}



Modify XML File
    [Arguments]    ${file_path}    ${params_dict}    ${count}=-1
    [Documentation]    This Keywod Is Used For Modifying XML File Current Content With Give Items
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | file path, such as /opt/iphy/latest/AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml |
    ...    | ${params_dict} | Yes | items to be changed, use dict in robotframework |
    ...    | ${count} | Yes | replace times if there are many mathes items, default -1 means replace all |
    ...
    ...    Example 1:
    ...    | ${file_path} | Set Variable | /opt/iphy/latest/AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml |
    ...    | &{xml_params_dict} | Create Dictionary | prachStartSymbol=2 | prachPreambleFormat=8 | bestBeamRsrp=555 |
    ...    | Modify XML File | ${file_path} | ${xml_params_dict} |
    ...
    ...    Example 2:
    ...    | *** Variables *** |
    ...    | ${wts_ap_xml} | /opt/iphy/latest/AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml |
    ...    | &{xml_params_dict} | prachStartSymbol=2 | prachPreambleFormat=8 | bestBeamRsrp=555 |
    ...
    ...    | *** Keywords *** |
        ...    | Modify XML File | ${wts_ap_xml} | ${xml_params_dict} |
    ${content}    OperatingSystem.Get File    path=${file_path}
#        Log    ${content}
        FOR    ${patt}    ${value}    IN ZIP    ${old_params_list}    ${new_params_list}
             Log Many    ${patt}    ${value}
             ${content}=    String.Replace String Using Regexp
        ...    string=${content}
        ...    pattern=${patt}
        ...    replace_with=${value}
        END
        OperatingSystem.Create File    path=${file_path}    content=${content}

Modify XML File new
    [Arguments]    ${file_path}    ${old_params_list}    ${new_params_list}
    [Documentation]    This keyword is used for modifying Text file content, like .txt, .Cfg
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | file path, such as /opt/iphy/latest/basic_fullstack_nsa_call_tdd_cmwv.Cfg |
    ...    | ${old_params_list} | Yes |  params list which need to be changed    https://www.runoob.com/regexp/regexp-syntax.html |
    ...    | ${new_params_list} | Yes |  new params list which corressponding to old params |
    ...
    ...    Example 1:
    ...    | ${file_path} | Set Variable | /opt/iphy/latest/basic_fullstack_nsa_call_tdd_cmwv.Cfg |
    ...    | @{old_params_list} | Create List | plmn=[0-9]+:[0-9]+ | ue_nr_capabilities=[0-9a-zA-Z]+ |
    ...    | @{new_params_list} | Create List | plmn=302:610 | ${empty} |
    ...    | Modify Text File | ${file_path} | ${old_params_list} | ${new_params_list} |
    ...
    ...    Example 2:
    ...    | *** Variables *** |
    ...    | ${wts_cfg} | /opt/iphy/latest/basic_fullstack_nsa_call_tdd_cmwv.Cfg |
    ...    | @{cfg_old_params} | plmn=[0-9]+:[0-9]+ | ue_nr_capabilities=[0-9a-zA-Z]+ |
    ...    | @{cfg_new_params} | plmn=302:610 | ${empty} |
    ...
    ...    | *** Keywords *** |
    ...    | Modify Text File | ${wts_cfg} | ${cfg_old_params} | ${cfg_new_params} |
    ${content}    OperatingSystem.Get File    path=${file_path}
#    Log    ${content}
    FOR    ${patt}    ${value}    IN ZIP    ${old_params_list}    ${new_params_list}
#         Log Many    ${patt}    ${value}
         ${content}=    String.Replace String Using Regexp
    ...    string=${content}
    ...    pattern=${patt}
    ...    replace_with=${value}
    END
    OperatingSystem.Create File    path=${file_path}    content=${content}


Send IPHY XML To Airphone
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} rm -f /ffs/run/simmode/*
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy_modify.xml
    Should Be Equal As Integers    ${rc}    0
    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} ${soft_link}
    Should Be Equal As Integers    ${rc}    0

Get swconfig files for gNB for Pcell
    [Documentation]    This keyword is to get the swconfig flags for both Gnb and AP for SBTS22R1 and SBTS00
    Run Keyword If    "${AP_FCT_BOARD_TYPE}"=="ABIO"    CB007873_Keywords.Send Swconfig for GNB
    ...    ${config_path}/gnb_swconfig_pcell.txt

Get swconfig files for gNB for Scell
    [Documentation]    This keyword is to get the swconfig flags for both Gnb and AP for SBTS22R1 and SBTS00
    Run Keyword If    "${AP_FCT_BOARD_TYPE}"=="ABIO"    CB007873_Keywords.Send Swconfig for GNB
    ...    ${config_path}/gnb_swconfig_scell.txt

Get swconfig files for AP
    [Documentation]    This keyword is to get the swconfig flags for both Gnb and AP for SBTS22R1 and SBTS00
    Run Keyword If    "${AP_FCT_BOARD_TYPE}"=="ABIO"    CB007873_Keywords.Send Swconfig for GNB
    ...    ${config_path}/ap_swconfig.txt

add routes
    [Documentation]    This keyword is to get the swconfig flags for both Gnb and AP for SBTS22R1 and SBTS00
#    Run    sudo ip addr add 10.0.1.2/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3

Check counter value is non zero
    [Arguments]   ${Counter_on}
    Run keyword and continue on failure  Should be true  ${Counter_on} > 0


Get Max PM Counter Value With Admin
    [Arguments]    ${counter_id}
    [Documentation]    This keyword is to get the max value of couter from Admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | Yes | Counte id, such as M55323C14001 |
    ...
    ...    Examples:
    ...    | Get Latest PM Counter Value From Coam | M55323C14001 |
    ...
    ${counter_value_list}    CB007873_Keywords.Get All Counter Values List With Admin    ${counter_id}
    ${max_counter_value}    Evaluate    max(${counter_value_list})
    [Return]    ${max_counter_value}


Get All Counter Values List With Admin
    [Arguments]    ${counter_id}
    [Documentation]    This keyword is to get the couter value list from Admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | Yes | Counte id, such as M55323C14001 |
    ...
    ...    Examples:
    ...    | Get All Counter Values List With Admin | M55323C14001 |
    ...
    COAM.Setup Admin
    ${counter}    COAM.Get Pm Counters    ${counter_id}
    ${counter_str}    Convert To String    ${counter}
    ${counter_value_list}    String.Get Regexp Matches    ${counter_str}    '\\d+':\\s*(?P<${counter_id}>\\d+)    ${counter_id}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${counter_value_list}


Lock Cell
	COAM_Admin.lockcell    ${NRCELL}
	sleep    20s

Unlock Cell
	COAM_Admin.unlock_cell    ${NRCELL}
	sleep    60s

Delta Commission With SCF File
    [Arguments]    ${delta_json}
    [Documentation]    This keyword is to update parameters with delta file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | delta_json | Yes | delta file name.It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${delta_json}. |
    ...    |  |  | ${SW_BRANCH} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${scf_path} | Set Variable | ${CURDIR}/config |
    ...    | Delta Commission With SCF File | Delta_Conf_5GC002504.json |    |
    ...    Example2:
    ...    | ${delta_json} | Set Variable | ${CURDIR}/delta.json |
    ...    | Delta Commission With SCF File | ${delta_json} |    |
    Log To Console    Perform delta commissioning...
    COAM.Setup Admin
    #${delta_path}=    OperatingSystem.Join Path    ${scf_path}    ${SW_BRANCH}    SCF    ${delta_json}
    ${join_delta_path}=    OperatingSystem.Join Path    ${scf_path}    ${SW_BRANCH}    ${delta_json}
    ${is_join_path_file_exist}=    Run Keyword And Return Status    File Should Exist    ${join_delta_path}
    ${delta_path}    Set Variable If    ${is_join_path_file_exist}==True    ${join_delta_path}    ${delta_json}
    Modify File Parameter    ${delta_path}    MRBTS-[0-9]+/NRBTS-[0-9]+    ${NRBTS_DISTNAME}
    COAM.Perform Delta Recommissioning
    ...    delta_file=${delta_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown


Generate 40mpbs traffic
    [Arguments]    ${ue_id}    ${pdu_id}     ${qfi_id}
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID1}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=17      pdu_id=${pdu_id}    trf_id=${TRF_ID2}      qfi_id=${qfi_id}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=6      pdu_id=${pdu_id}    trf_id=${TRF_ID3}      qfi_id=${qfi_id}
    sleep   5s

Get File Type
    [Arguments]    ${file}
    [Documentation]    This keyword is to get the name extension of a file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file} | Yes | file name need to get the name extension |
    ...
    ...    Examples:
    ...    | Get File Type | delta.json |
    ...    | Get File Type | scf.xml |
    @{file_list}    String.Split String    ${file}    .
    [Return]    ${file_list[-1]}



Set fixed bler for CA Capable UE
    # For DL BLER
    ${bler}     Set Variable     wtsrunner.bler_testmode_nr profile_id=1 dl_bler=500,500,500,500,500,500,500,500 ul_bler=0,0,0,0,0,0,0,0
    ...    pdcch_misd_rate=0
    ${output}   ute_wtssim.Execute Egate Command    cmd=${bler}

Attach one FDD CA capable UE and 10 Non CA TDD UEs
    CB007873_Keywords.Attach and do data transfer     ${16}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${11}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${12}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${13}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${14}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${30}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${31}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${32}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${33}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${34}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${35}
    sleep    2

Attach one FDD CA capable UE and 10 Non CA FDD UEs
    CB007873_Keywords.Attach and do data transfer     ${16}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${15}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${20}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${21}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${22}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${23}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${24}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${25}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${26}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${27}
    sleep    2
    CB007873_Keywords.Attach and do data transfer     ${28}
    sleep    2

Attach and do data transfer
    [Arguments]     ${ue_id}     #${count}={1}
    ${attach}   set Variable    ue_attach id=${ue_id}
    ${output}   ute_wtssim.Execute Egate Command    cmd=${attach}
    sleep   3s
    ${endc}     Set Variable     enb_endc_param ue=${ue_id} serving_cell_index_range_scg=5:31
    ${output}   ute_wtssim.Execute Egate Command    cmd=${endc}
    sleep   3s
    ${ue_dc}     Set Variable     ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=2 bearer=2 type=split_scg
    ${output}   ute_wtssim.Execute Egate Command    cmd=${ue_dc}
    sleep   3s
    ${egate1}    Set variable      trf_data_start ue=${ue_id_1} id=2 dir=dl trf_id=1 mbps=150
    ${output}   ute_wtssim.Execute Egate Command    cmd=${egate1}
    sleep   3s
    ${egate2}    Set variable      trf_data_start ue=${ue_id} id=2 dir=dl trf_id=2 mbps=150
    ${output}   ute_wtssim.Execute Egate Command    cmd=${egate2}
    sleep   3s
    ${egate3}    Set variable      trf_data_start ue=${ue_id} id=2 dir=dl trf_id=3 mbps=150
    ${output}   ute_wtssim.Execute Egate Command    cmd=${egate3}
    sleep   3s
    ${egate4}    Set variable      trf_data_start ue=${ue_id} id=2 dir=ul trf_id=1 mbps=10
    ${output}   ute_wtssim.Execute Egate Command    cmd=${egate4}
    sleep   3s
    ${mcg}    Set variable      bearer_stats ue=${ue_id} id=2 dir=dl trf_id=1 type=l3 dc_cell_group=mcg
    ${output}   ute_wtssim.Execute Egate Command    cmd=${mcg}
    sleep   3s
    ${scg}    Set variable      bearer_stats ue=${ue_id} id=2 dir=dl trf_id=1 type=l3 dc_cell_group=scg
    ${output}   ute_wtssim.Execute Egate Command    cmd=${scg}
    sleep   3s

Attach and do CBRA_HO
    [Arguments]     ${ue_id}     #${count}={1}
    ${gnb2}     set Variable    enb_x2_link_up enb=1 target=2
    ${output}   ute_wtssim.Execute Egate Command    cmd=${gnb2}
#    Log To Console ${output}
    sleep   3s
    ${gnb3}     set Variable    enb_x2_link_up enb=1 target=3
    ${output}   ute_wtssim.Execute Egate Command    cmd=${gnb3}
#    Log To Console ${output}
    sleep   3s
    ${attach}   set Variable    ue_attach id=${ue_id}
    ${output}   ute_wtssim.Execute Egate Command    cmd=${attach}
#    Log To Console ${output}
    sleep   3s
    ${endc}     Set Variable     ue_dc_enb_start ue=${ue_id} target_gnb=3 target_cells=3 bearer=2 type=split_scg
    ${output}   ute_wtssim.Execute Egate Command    cmd=${endc}
#    Log To Console ${output}
    sleep   3s
    ${meas}     Set Variable    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${output}   ute_wtssim.Execute Egate Command      cmd=${meas}
#    Log To Console ${output}
    sleep   3s
    ${ho}   Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=${ue_id}
    ...     srsrq_nr=${ue_id} phycell_id=50 nrsrp_nr=30 nrsrq_nr=20
    ${output}   ute_wtssim.Execute Egate Command    cmd=${ho}
#    Log To Console ${output}
    sleep   3s
    ${detach}   set Variable    ue_detach id=${ue_id}
    ${output}   ute_wtssim.Execute Egate Command    cmd=${detach}
#    Log To Console ${output}


Start WTS Using WTS_Runner
    [Arguments]             ${wts_cfg_file}
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                      file=${wts_cfg_file}
    wtsrunner.read_wtsemu_output_until_re    expected=SimMode is ready now     timeout=240
    wtsrunner.sim_state_disp
    wtsrunner.read_wtsemu_output_until_re    expected=The state is ACTIVE   timeout=120
    sleep    120s


Stop Capture CPRT
   Capture Stop                    ${CaptureCPRT}

Start Capture CPRT
   ${CaptureCPRT}                  Capture CPRT Set Upon Config            airscale=${GNB_DU}
   Capture Init                    ${CaptureCPRT}
   #${CaptureCPRT.filter}           Get Filter For SCTP          ${CaptureCPRT}
   #Set Suite Variable              ${CaptureCPRT.filter}
   Capture Start                   ${CaptureCPRT}
   Set Suite Variable              ${CaptureCPRT}


Activate Bler profile
    # For DL BLER
    ${bler}     Set Variable     ue_testmode_set_nr id=16 scell=5 testmode=bler action=activate profile_id=1
    ${output}   ute_wtssim.Execute Egate Command    cmd=${bler}

Check counter value is greater than previous
    [Arguments]   ${Counter_current}    ${Counter_previous}
    Run keyword and continue on failure  Should be true  ${Counter_current}>${Counter_previous}


CB007873 Counters validation
    #DL RLC PDU volume transmitted over primary path - QoS Group 09 (M55311C42009) # BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_VOL_TX_PRI_QOS_GRP_09
    ${M55311C42009_1} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55311C42009
    Check counter value is non zero     ${M55311C42009_1}
    #DL RLC PDUs transmitted over primary path- QoS Group 09 (M55311C43009) #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_PDU_TX_PRI_QOS_GRP_09
    ${M55311C43009_1} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55311C43009
    Check counter value is non zero     ${M55311C43009_1}
    #DL RLC PDU volume transmitted over secondary path - QoS Group 09 (M55311C44009)  #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_VOL_TX_SEC_QOS_GRP_09
    ${M55311C44009_1} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55311C44009
    Check counter value is non zero     ${M55311C44009_1}
    #DL RLC PDUs transmitted over secondary path- QoS Group 09 (M55311C45009) #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_PDU_TX_SEC_QOS_GRP_09
    ${M55311C45009_1} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55311C45009
    Check counter value is non zero     ${M55311C45009_1}
    #DL RLC data PDU volume transmitted by Low RLC  - QoS Group 09 (M55310C01009) #CELLS/NRCELL-1/NLRLC/DL_RLC_VOL_TX_L_QOS_GRP_09
    ${M55310C01009_1} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55310C01009
    Check counter value is non zero     ${M55310C01009_1}
    #UL RLC data PDU volume received by Low RLC - QoS Group 09 (M55310C03009) #CELLS/NRCELL-1/NLRLC/UL_RLC_VOL_RX_L_QOS_GRP_09
    ${M55311C43006_1} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55311C43006
    Check counter value is non zero     ${M55311C43006_1}
    #UL RLC data PDUs received by Low RLC - QoS Group 09 (M55310C04009) #CELLS/NRCELL-1/NLRLC/UL_RLC_PDU_RX_L_QOS_GRP_09
    ${M55311C43006_1} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55310C04009
    Check counter value is non zero     ${M55311C43006_1}
    #DL RLC data PDU volume transmitted by Low RLC  - QoS Group 09 (M55310C01009) #CELLS/NRCELL-2/NLRLC/DL_RLC_VOL_TX_L_QOS_GRP_09
    ${M55310C01009_1} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55310C01009
    Check counter value is non zero     ${M55310C01009_1}
    #UL RLC data PDU volume received by Low RLC - QoS Group 09 (M55310C03009)  #CELLS/NRCELL-2/NLRLC/UL_RLC_VOL_RX_L_QOS_GRP_09
    ${M55310C03009_1} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55310C03009
    Check counter value is non zero     ${M55310C03009_1}
    #UL RLC data PDUs received by Low RLC - QoS Group 09 (M55310C04009) #CELLS/NRCELL-2/NLRLC/UL_RLC_PDU_RX_L_QOS_GRP_09
    ${M55310C04009_1} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55310C04009
    Check counter value is non zero     ${M55310C04009_1}


CB007873 Counters validation for PCell
     #DL RLC PDU volume transmitted over primary path - QoS Group 09 (M55311C42009)  # BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_VOL_TX_PRI_QOS_GRP_09
    ${M55311C42009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55311C42009
    Check counter value is greater than previous     ${M55311C42009_2}    ${M55311C42009_1}
    #DL RLC PDUs transmitted over primary path- QoS Group 09 (M55311C43009) #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_PDU_TX_PRI_QOS_GRP_09
    ${M55311C43009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55311C43009
    Check counter value is greater than previous      ${M55311C43009_2}     ${M55311C43009_1}
    #DL RLC PDU volume transmitted over secondary path - QoS Group 09 (M55311C44009)  #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_VOL_TX_SEC_QOS_GRP_09
    ${M55311C44009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55311C44009
    Check counter value is greater than previous     ${M55311C44009_2}    ${M55311C44009_1}
    #DL RLC PDUs transmitted over secondary path- QoS Group 09 (M55311C45009) #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_PDU_TX_SEC_QOS_GRP_09
    ${M55311C45009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55311C45009
    Check counter value is greater than previous       ${M55311C45009_2}    ${M55311C45009_1}
    #DL RLC data PDU volume transmitted by Low RLC  - QoS Group 09 (M55310C01009)  #CELLS/NRCELL-1/NLRLC/DL_RLC_VOL_TX_L_QOS_GRP_09
    ${M55310C01009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55310C01009
    Check counter value is greater than previous      ${M55310C01009_2}     ${M55310C01009_2}
    #UL RLC data PDU volume received by Low RLC - QoS Group 09 (M55310C03009) #CELLS/NRCELL-1/NLRLC/UL_RLC_VOL_RX_L_QOS_GRP_09
    ${M55311C43006_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55311C43006
    Check counter value is greater than previous      ${M55311C43006_2}     ${M55311C43006_1}
    #UL RLC data PDUs received by Low RLC - QoS Group 09 (M55310C04009)  #CELLS/NRCELL-1/NLRLC/UL_RLC_PDU_RX_L_QOS_GRP_09
    ${M55311C43006_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55310C04009
    Check counter value is greater than previous     ${M55311C43006_2}       ${M55311C43006_1}
    #DL RLC data PDU volume transmitted by Low RLC  - QoS Group 09 (M55310C01009)  #CELLS/NRCELL-2/NLRLC/DL_RLC_VOL_TX_L_QOS_GRP_09
    ${M55310C01009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55310C01009
    Check counter value is greater than previous      ${M55310C01009_2}      ${M55310C01009_1}
    #UL RLC data PDU volume received by Low RLC - QoS Group 09 (M55310C03009)  #CELLS/NRCELL-2/NLRLC/UL_RLC_VOL_RX_L_QOS_GRP_09
    ${M55310C03009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55310C03009
    Check counter value is greater than previous      ${M55310C03009_2}     ${M55310C03009_1}
    #UL RLC data PDUs received by Low RLC - QoS Group 09 (M55310C04009) #CELLS/NRCELL-2/NLRLC/UL_RLC_PDU_RX_L_QOS_GRP_09
    ${M55310C04009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55310C04009
    Check counter value is greater than previous     ${M55310C04009_2}     ${M55310C04009_1}


CB007873 Counters validation for SCell
     #DL RLC PDU volume transmitted over primary path - QoS Group 09 (M55311C42009) # BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_VOL_TX_PRI_QOS_GRP_09
    ${M55311C42009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55311C42009
    Check counter value is greater than previous     ${M55311C42009_2}    ${M55311C42009_1}
    #DL RLC PDUs transmitted over primary path- QoS Group 09 (M55311C43009)  #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_PDU_TX_PRI_QOS_GRP_09
    ${M55311C43009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55311C43009
    Check counter value is greater than previous      ${M55311C43009_2}     ${M55311C43009_1}
    #DL RLC PDU volume transmitted over secondary path - QoS Group 09 (M55311C44009) #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_VOL_TX_SEC_QOS_GRP_09
    ${M55311C44009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55311C44009
    Check counter value is greater than previous     ${M55311C44009_2}    ${M55311C44009_1}
    #DL RLC PDUs transmitted over secondary path- QoS Group 09 (M55311C45009) #BTS/NRBTS-1/NRDU-1/NHRLC/DL_RLC_PDU_TX_SEC_QOS_GRP_09
    ${M55311C45009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55311C45009
    Check counter value is greater than previous       ${M55311C45009_2}    ${M55311C45009_1}
    #DL RLC data PDU volume transmitted by Low RLC  - QoS Group 09 (M55310C01009) #CELLS/NRCELL-1/NLRLC/DL_RLC_VOL_TX_L_QOS_GRP_09
    ${M55310C01009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55310C01009
    Check counter value is greater than previous      ${M55310C01009_2}     ${M55310C01009_2}
    #UL RLC data PDU volume received by Low RLC - QoS Group 09 (M55310C03009)   #CELLS/NRCELL-1/NLRLC/UL_RLC_VOL_RX_L_QOS_GRP_09
    ${M55311C43006_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55311C43006
    Check counter value is greater than previous      ${M55311C43006_2}     ${M55311C43006_1}
    #UL RLC data PDUs received by Low RLC - QoS Group 09 (M55310C04009) #CELLS/NRCELL-1/NLRLC/UL_RLC_PDU_RX_L_QOS_GRP_09
    ${M55311C43006_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55310C04009
    Check counter value is greater than previous     ${M55311C43006_2}       ${M55311C43006_1}
    #DL RLC data PDU volume transmitted by Low RLC  - QoS Group 09 (M55310C01009) #CELLS/NRCELL-2/NLRLC/DL_RLC_VOL_TX_L_QOS_GRP_09
    ${M55310C01009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55310C01009
    Check counter value is greater than previous      ${M55310C01009_2}      ${M55310C01009_1}
    #UL RLC data PDU volume received by Low RLC - QoS Group 09 (M55310C03009) #CELLS/NRCELL-2/NLRLC/UL_RLC_VOL_RX_L_QOS_GRP_09
    ${M55310C03009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55310C03009
    Check counter value is greater than previous      ${M55310C03009_2}     ${M55310C03009_1}
    #UL RLC data PDUs received by Low RLC - QoS Group 09 (M55310C04009) #CELLS/NRCELL-2/NLRLC/UL_RLC_PDU_RX_L_QOS_GRP_09
    ${M55310C04009_2} =    CB007873_Keywords.Get Max PM Counter Value With Admin    M55310C04009
    Check counter value is greater than previous     ${M55310C04009_2}     ${M55310C04009_1}


Attach UE and perform data transfer_CB007873D_B1_4
    [Arguments]     ${ue_16}   ${ue_11}   ${ue_12}   ${ue_13}   ${ue_14}   ${ue_30}
    wtsrunner.enb_endc_param  id=1 serving_cell_index_range_scg=5:31
    sleep  6s
    wtsrunner.ue_attach  id=${ue_16}
    sleep   15s
    wtsrunner.enb_ue_dc_start  ue=${ue_16}   target_gnb=2   target_cells=2   bearer=2   type=split_scg
    sleep   10s
    wtsrunner.trf_data_start   ue=${ue_16}   id=2   dir=dl   trf_id=1   mbps=150
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_16}   id=2   dir=dl   trf_id=1   mbps=150
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_16}   id=2   dir=dl   trf_id=1   mbps=100
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_16}   id=2   dir=dl   trf_id=1    mbps=10
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_16}   id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=mcg
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_16}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=scg
    sleep  6s
    wtsrunner.ue_attach  id=${ue_11}
    sleep  15s
    wtsrunner.enb_ue_dc_start  ue=${ue_11}  target_gnb=2  target_cells=2  bearer=2  type=split_scg
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_11}  id=2   dir=dl   trf_id=1   mbps=10
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_11}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=mcg
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_11}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=scg
    sleep  6s
    wtsrunner.ue_attach  id=${ue_12}
    sleep  15s
    wtsrunner.enb_ue_dc_start  ue=${ue_12}   target_gnb=2   target_cells=2    bearer=2   type=split_scg
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_12}   id=2   dir=dl    trf_id=1   mbps=10
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_12}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=mcg
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_12}  id=2    dir=dl   trf_id=1    type=l3   dc_cell_group=scg
    sleep  6s
    wtsrunner.ue_attach  id=${ue_13}
    sleep  15s
    wtsrunner.enb_ue_dc_start  ue=${ue_13}    target_gnb=2   target_cells=2   bearer=2   type=split_scg
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_13}    id=2   dir=dl   trf_id=1   mbps=10
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_13}  id=2   dir=dl   trf_id=1    type=l3   dc_cell_group=mcg
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_13}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=scg
    sleep  6s
    wtsrunner.ue_attach  id=${ue_14}
    sleep  15s
    wtsrunner.enb_ue_dc_start  ue=${ue_14}   target_gnb=2   target_cells=2   bearer=2   type=split_scg
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_14}   id=2    dir=dl   trf_id=1   mbps=10
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_14}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=mcg
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_14}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=scg
    sleep  6s
    wtsrunner.ue_attach  id=${ue_30}
    sleep  15s
    wtsrunner.enb_ue_dc_start  ue=${ue_30}   target_gnb=2    target_cells=2   bearer=2   type=split_scg
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_30}   id=2   dir=dl   trf_id=1   mbps=10
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_30}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=mcg
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_30}  id=2   dir=dl    trf_id=1    type=l3   dc_cell_group=scg

Attach UE and perform data transfer_CB007873D_B2_6
    [Arguments]     ${ue_16}   ${ue_15}   ${ue_20}   ${ue_21}   ${ue_22}   ${ue_23}    ${ue_24}
    wtsrunner.enb_endc_param  id=1 serving_cell_index_range_scg=5:31
    sleep  6s
    wtsrunner.ue_attach  id=${ue_16}
    sleep   15s
    wtsrunner.enb_ue_dc_start  ue=${ue_16}   target_gnb=2   target_cells=2   bearer=2   type=split_scg
    sleep   10s
    wtsrunner.trf_data_start   ue=${ue_16}   id=2   dir=dl   trf_id=1   mbps=150
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_16}   id=2   dir=dl   trf_id=1   mbps=150
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_16}   id=2   dir=dl   trf_id=1   mbps=100
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_16}   id=2   dir=dl   trf_id=1    mbps=10
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_16}   id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=mcg
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_16}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=scg
    sleep  6s
    wtsrunner.ue_attach  id=${ue_15}
    sleep  15s
    wtsrunner.enb_ue_dc_start  ue=${ue_15}  target_gnb=2  target_cells=2  bearer=2  type=split_scg
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_15}  id=2   dir=dl   trf_id=1   mbps=10
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_15}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=mcg
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_15}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=scg
    sleep  6s
    wtsrunner.ue_attach  id=${ue_20}
    sleep  15s
    wtsrunner.enb_ue_dc_start  ue=${ue_20}   target_gnb=2   target_cells=2    bearer=2   type=split_scg
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_20}   id=2   dir=dl    trf_id=1   mbps=10
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_20}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=mcg
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_20}  id=2    dir=dl   trf_id=1    type=l3   dc_cell_group=scg
    sleep  6s
    wtsrunner.ue_attach  id=${ue_21}
    sleep  15s
    wtsrunner.enb_ue_dc_start  ue=${ue_21}    target_gnb=2   target_cells=2   bearer=2   type=split_scg
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_21}    id=2   dir=dl   trf_id=1   mbps=10
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_21}  id=2   dir=dl   trf_id=1    type=l3   dc_cell_group=mcg
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_21}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=scg
    sleep  6s
    wtsrunner.ue_attach  id=${ue_22}
    sleep  15s
    wtsrunner.enb_ue_dc_start  ue=${ue_22}   target_gnb=2   target_cells=2   bearer=2   type=split_scg
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_22}   id=2    dir=dl   trf_id=1   mbps=10
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_22}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=mcg
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_22}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=scg
    sleep  6s
    wtsrunner.ue_attach  id=${ue_23}
    sleep  15s
    wtsrunner.enb_ue_dc_start  ue=${ue_23}   target_gnb=2    target_cells=2   bearer=2   type=split_scg
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_23}   id=2   dir=dl   trf_id=1   mbps=10
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_23}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=mcg
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_23}  id=2   dir=dl    trf_id=1    type=l3   dc_cell_group=scg
    sleep  6s
    wtsrunner.ue_attach  id=${ue_24}
    sleep  15s
    wtsrunner.enb_ue_dc_start  ue=${ue_24}   target_gnb=2    target_cells=2   bearer=2   type=split_scg
    sleep  6s
    wtsrunner.trf_data_start   ue=${ue_24}   id=2   dir=dl   trf_id=1   mbps=10
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_24}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=mcg
    sleep  6s
    wtsrunner.bearer_stats  ue=${ue_24}  id=2   dir=dl    trf_id=1    type=l3   dc_cell_group=scg


Perform Bler Activation
    [Arguments]   ${scell_id}
    wtsrunner.ue_testmode_set_nr   id=16   scell=${scell_id}       testmode=bler   action=activate   profile_id=1

Set bler for CA Capable UE
     wtsrunner.bler_testmode_nr   profile_id=1 dl_bler=500,500,500,500,500,500,500,500 ul_bler=0,0,0,0,0,0,0,0

Setup X2 Link
    [Documentation]                 Establish on WTSEmu the X2 link between eNB and gNB.
    ...                             Wait for cell cetup for each cell by using keyword 'UE Cell Setup Check'.
    ...                             See keyword 'UE Cell Setup Check' for more details.
    ...
    ...                             *Argument details:*
    ...                             - alias: vm connection alias (default value = dynamically retrieved)
    [Arguments]                     ${alias}=${HOST_EPCSIM.alias}
    Log To Console     ${alias}
    wtsrunner.Enb X2 Link Up           enb=${ENB_ID}                               target=${GNB_ID}
    sleep                           3s
    wtsrunner.Read Wtsemu Output Until Re
    ...                             expected=ENB-${ENB_ID}: X2AP Link with [EG]NB-${GNB_ID} \\((\\d+\\.){3}\\d+\\:\\d+\\[\\d\\]\\) is up
    ...                             timeout=500


Get swconfig files for gNB

    Run Keyword If    "${AP_FCT_BOARD_TYPE}"=="ABIO"    CB007873_Keywords.Send Swconfig for GNB
    ...    ${config_path}/gnb_swconfig_CB007873_D_B1_B2.txt


Add AP RadParam
    Log To Console  Adding AP RadParam to swconfig...
    SSHLibrary.open connection    ${AP_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    SSHLibrary.execute command    echo "0x70686=0" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    echo "0x70673=1" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection

Add GNB RadParam for PDU_Enabled and SchedDelay_Disabled
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    ${GNB_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    SSHLibrary.execute command    echo "0x580307=0x6FE" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    echo "0x5900B1=1" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    echo "0x5B021F=0x1" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    echo "0x5B0220=0x5" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    echo "0x5B0221=0xfe" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    echo "0x5B021D=1" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    echo "0x5B021E=0" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    echo "0x5B021C=1" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection
