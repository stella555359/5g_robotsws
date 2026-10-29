*** Settings ***
Documentation     [SUITE PURPOSE] Commoin keywords fo CB012605
...
...               Test Case Scenario author   : blandine.garnier@nokia.com
...               Test Case automation author : blandine.garnier@nokia.com / laurent.puchelle@nokia.com
...               Creation Date               : 2024-07-01
...               Modified Date               : 2024-10-15
...               Last Modified by            : laurent.puchelle@nokia.com
...               Modification:
...                       2024-07-01          | Creation
...                       2024-10-15          | refactoring


Library           BuiltIn
Library           DateTime
Library           OperatingSystem
Library           taf.wts.runner    WITH NAME    wtsemu
Library           taf.config.scf    WITH NAME    scf
Library           taf.sbts.oam.coam.admin    WITH NAME    sbts_coam
Library           ../../../../../resources/SWENG/python/CoamParameter.py    WITH NAME    coam_parameter
Library           ../../../../../resources/SWENG/python/ScfVendorOperations.py

Library           ../python/CB012605_checkTTItrace.py

Resource          ../../../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../../../resources/SWENG/robot/CallSetup.robot
Resource          ../../../../../resources/SWENG/robot/Capture.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/KPIs.robot
Resource          ../../../../../resources/SWENG/robot/Restart.robot
Resource          ../../../../../resources/SWENG/robot/Scf.robot
Resource          ../../../../../resources/SWENG/robot/SetConfig.robot
Resource          ../../../../../resources/SWENG/robot/Tools.robot
Resource          ../../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Resource          ../../../../../resources/SWENG/robot/Syslogs.robot


*** Variables ***

# RAD parameters definition
${rdBbPoolTddFr1Ecpri72e}                  0x42009D
#Bit 0: UE pooling
${valBbPoolTddFr1Ecpri72e_UEpooling}       1
#Bit 1: PUCCH stream-PRB pooling
${valBbPoolTddFr1Ecpri72e_PUCCH}           2
#Bit 2: DL PDCCH/PDSCH layer-PRB pooling
${valBbPoolTddFr1Ecpri72e_PDxCH}           4
#Bit 3: UL PUSCH layer-PRB pooling
${valBbPoolTddFr1Ecpri72e_PUSCH}           8
#Bit 4: DL subcell deactivation
${valBbPoolTddFr1Ecpri72e_DLscellDeact}    16
${rdHARQDisableIncrRedundancyDl}           0x580001
${rdFakeUeSchedulingEnable}                0x5801CB
${enabledNewCeFrameworkFlagInDu}           0x8000A6
${rdAaSysLogInputLevel}                    0x01003F
${rdFEAT_DBG_Rpmag}                        0x0000F5
${rdFEAT_DBG_BTSOM_APW}                    0x0000FC
${rdFEAT_DBG_BTSOM_BBC}                    0x000113




*** Keywords ***
CB012605_Set_RAD_Parameters
    [Documentation]
    ...     Actions:    Add or modify RAD parameters for CB012605
    ...     Parameters: None
    ...     Return:     None

    Dated Log New Line             ====> Update RAD parameters for CB012605
    ${BbPoolTddFr1Ecpri72e_Val}    Evaluate    ${valBbPoolTddFr1Ecpri72e_PDxCH}
	${rad_param_1}                 create dictionary       field=${rdBbPoolTddFr1Ecpri72e}           value=${BbPoolTddFr1Ecpri72e_Val}
    ${rad_param_2}                 create dictionary       field=${rdFakeUeSchedulingEnable}         value=0
    ${rad_param_3}                 create dictionary       field=${rdHARQDisableIncrRedundancyDl}    value=1
    ${rad_param_4}                 create dictionary       field=${rdAaSysLogInputLevel}             value=1
    ${rad_param_5}                 create dictionary       field=${rdFEAT_DBG_BTSOM_BBC}             value=1
    ${rad_param_6}                 create dictionary       field=${rdFEAT_DBG_Rpmag}                 value=2
	${rad_param_7}                 create dictionary       field=${rdFEAT_DBG_BTSOM_APW}             value=2
    ${rad_param_list}              Create List    ${rad_param_1}    ${rad_param_2}    ${rad_param_3}
    # Don't set RAD parameters for specific traces
    #...                                           ${rad_param_4}    ${rad_param_5}    ${rad_param_6}    ${rad_param_7}

    Set Fields in swconfig DU      param_list=${rad_param_list}


CB012605_Custom_Setup
    [Documentation]
    ...     Actions:     Apply customized configuration then launch cell setup.
    ...     Parameters:  SCF: customized SCF
    ...                  CFG: customized basic CFG file
    ...                  IPHY: airphone iphy file
    ...                  rdParam: list of RAD parameters
    ...                  vendorParam: list of vendor parameters
    ...     Return:      None
    [Arguments]              ${SCF}    ${CFG}=${EMPTY}    ${IPHY}=${EMPTY}
    ...                      ${rdParam}=${EMPTY}    ${vendorParam}=${EMPTY}

    Apply Custom Config
    ...      scfc=${SCF}
    ...      cfg=${CFG}
    ...      iphy=${IPHY}
    ...      rad_params=@{rdParam}
    ...      vendor_params=@{vendorParam}

	#Restart TL

    ${syslog}                SYSLOG Start    host=${GNB_DU.sys[0].M}    name=cellSetup
    Setup Wtsemu SA          shouldUseLua=False
    ${syslogFile}            SYSLOG Stop     syslog=${syslog}
    RETURN                   ${syslogFile}


CB012605_Wait_End_ZOI
    [Documentation]
    ...     Actions:         Wait for a Zone Of Interest including TTI trace capture and counters files collection
    ...     Parameters:      PMdir:  target directory of counters files
    ...                      TTIdir: target directory of TTI trace
    ...                      TTIduration: duration of TTI trace
    ...                      suffix: suffix to add to TTI trace pcap name
    ...     Return:          TTI trace captured and last PM file collected
    [Arguments]              ${PMdir}    ${TTIdir}    ${TTIduration}=5    ${suffix}=${EMPTY}

    ${zoi}                   ZOI Start

    Dated Log New Line       ====> Start TTI trace capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2
    Traced Sleep             ${TTIduration}    msg=capture TTI trace
    ${TTI_trace}             Stop TTI Traces in Streaming mode
    ...                      tti_trace_path=${TTIdir}
    ...                      tti_trace_filename=TTItrace${suffix}

    ZOI Wait End             zoi=${zoi}
    ${PM_lastFile}           Counters.Collect PM files from BTS    ${PMdir}
    RETURN                   ${TTI_trace}    ${PM_lastFile}


CB012605_Check_cells_distribution
    [Documentation]
    ...     Actions:         Check the cell distribution on both L1pool and on each L1subpool (2 by L1pool with different Id))
    ...     Parameters:      syslog:  SYSLOG file captured while cell setup
    ...     Return:          True/False according to the check status
    [Arguments]              ${syslog}

    ${L1pool}                Run    grep "itf::l2::ps::cell::CellSetupReq:" ${syslog} |grep -oP '(?<=l1PoolId":)[0-9]+'
    @{L1poolList}            Split String    ${L1pool}
    @{L1poolUsed}            Remove Duplicates    ${L1poolList}
    ${nbL1poolUsed}          Get length    ${L1poolUsed}

    ${Subpool}               Run    grep "itf::l2::ps::cell::CellSetupReq:" ${syslog} |grep -oP '(?<=l1SubPoolId\":)[0-9]+'
    @{SubpoolList}           Split String    ${Subpool}
    @{SubpoolUsed}           Remove Duplicates    ${SubpoolList}
    ${nbSubpoolUsed}         Get length    ${SubpoolUsed}

    ${distribStatus}         Set Variable    ${true}
    IF    ${nbL1poolUsed} != 2
        Dated log new line      ===> ERROR: cell distribution done on ${nbL1poolUsed} L1pool (expected on 2 L1pool)
        ${distribStatus}        Set Variable    ${false}
    END
    IF    ${nbSubpoolUsed} != 4
        Dated log new line      ===> ERROR: cell distribution done on ${nbSubpoolUsed} L1subpool (expected on 4 L1subpool)
        ${distribStatus}        Set Variable    ${false}
    END

    RETURN                   ${distribStatus}
