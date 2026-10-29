*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_commissioning.robot

Suite Setup       Test Suite Setup
Suite Teardown    No Operation
Test Setup        Testcase Setup
Test Teardown     Testcase Teardown


*** Test Cases ***
Create_SCF_for_CLOUD_5G_I_MP_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD
    Initialize Source SCF    topology=CLOUD_5G_I_LO_AP_LOOO    variant=SANSA_FS_CPRI_CMWV_FDD_APRN    file=scfc.xml

    FOR                 ${dist_name}                                ${p_name}                       ${value}      IN
    ...                 ${distNames_NRBTS[0]}                       actPucchF3BasedTaGrantsRed      false
    ...                 ${distNames_NRBTS[0]}                       actBbPoolExtensionTddFr1        true
    ...                 ${distNames_NRBTS[0]}                       actBbPoolTddFr1                 true
    ...                 ${distNames_NRBTS[0]}                       actBbPoolTddFr1AlgEnh           true
    ...                 ${distNames_NRBTS[0]}                       actBbPoolTddFr1Enh              true
    ...                 ${distNames_NRBTS[0]}                       actLargeBbPoolTddFr1            true
    ...                 ${distNames_NRBTS[0]}                       actSlowPrbPoolingFddFr1Enh      true
    ...                 ${distNames_BRGPRT[0]}                      l2BurstSize                     4190208
    ...                 ${distNames_BRGPRT[0]}                      l2ShaperRate                    25000000
    ...                 ${distNames_BRGPRT[1]}                      l2BurstSize                     1048576
    ...                 ${distNames_BRGPRT[1]}                      l2ShaperRate                    1000000
    ...                 ${distNames_CABLINK[4]}                     firstEndpointPortId             4
    ...                 ${distNames_CABLINK[5]}                     firstEndpointPortId             5
    ...                 ${distNames_CABLINK[6]}                     firstEndpointPortId             6
    ...                 ${distNames_NRDU[0]}                        flexibleCAMode                  NumberCellAmount   # FDD Only
        Set Element     ${dist_name}                                ${p_name}                       ${value}
    END

    #All Cells
    FOR  ${dist_name}  IN  @{distNames_NRCELL}
        Set Element     ${dist_name}                                actShortBsrLimitAdaptation      true
        Set List Value  ${dist_name}                                fPdcchMonOccsnPo                2  # required

        # ?
        # Set Element     ${dist_name}                                actDynPdcchTdMode                disabled
        # Set Element     ${dist_name}                                actMacBSRIndexAlign              false
        # Set Element     ${dist_name}                                actMaxInitDeltaCqiClampVoNR      false
        # Set Element     ${dist_name}                                pucchF3MaxCodeRate               zeroDot25
        # Set Element     ${dist_name}                                reqMinNumPuschPrb                96
        # Set Element     ${dist_name}                                ulDMRSAdditionalPosition         No additional DMRS
    END

    Modify Public Keys

    scf.Save Scf    ${WORKSPACE}/archive/CLOUD_5G_I_MP_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD_scfc.xml


Create_SCF_for_CLOUD_5G_I_MP_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
    Initialize Source SCF    topology=CLOUD_5G_I_LO_AP_LOOO    variant=SANSA_FS_ECPRI_CMWV_TDD    file=scfc.xml

    FOR                 ${dist_name}                                ${p_name}                       ${value}      IN
    ...                 ${distNames_NRBTS[0]}                       actPucchF3BasedTaGrantsRed      false
    ...                 ${distNames_NRBTS[0]}                       actBbPoolExtensionTddFr1        true
    ...                 ${distNames_NRBTS[0]}                       actBbPoolTddFr1                 true
    ...                 ${distNames_NRBTS[0]}                       actBbPoolTddFr1AlgEnh           true
    ...                 ${distNames_NRBTS[0]}                       actBbPoolTddFr1Enh              true
    ...                 ${distNames_NRBTS[0]}                       actLargeBbPoolTddFr1            true
    ...                 ${distNames_NRBTS[0]}                       actSlowPrbPoolingFddFr1Enh      true
    ...                 ${distNames_BRGPRT[0]}                      l2BurstSize                     4190208
    ...                 ${distNames_BRGPRT[0]}                      l2ShaperRate                    25000000
    ...                 ${distNames_CABLINK[4]}                     firstEndpointPortId             4
    ...                 ${distNames_CABLINK[5]}                     firstEndpointPortId             5
    ...                 ${distNames_CABLINK[6]}                     firstEndpointPortId             6
    ...                 ${distNames_NRBTS[0]}                       actEnhancedNgRanSupport         false  # ?
    ...                 ${distNames_NRBTS[0]}                       actSchedFairnessUlOlc           false  # ?
    ...                 ${distNames_NRBTS[0]}                       actSliceAwareScheduler          false  # ?
    ...                 ${distNames_NRBTS[0]}                       actUnsupportedIEsHandling       false  # ?
    ...                 ${distNames_NRBTS[0]}                       actUnsupportedIEsHandling23R4   false  # ?
    ...                 MRBTS-1/NRBTS-1/NRDRB_PDCP-1                pdcpDelayThreshRetxMode         disabled
    ...                 MRBTS-1/NRBTS-1/NRDRB_PDCP-2                pdcpDelayThreshRetxMode         disabled
    ...                 MRBTS-1/NRBTS-1/NRDRB_PDCP-3                pdcpDelayThreshRetxMode         disabled
    ...                 MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1         systemInformationTargetRate     251
    ...                 MRBTS-1/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-5     connectorLabel                  S-RF4
    ...                 MRBTS-1/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-6     connectorLabel                  S-RF5
    ...                 MRBTS-1/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-7     connectorLabel                  S-RF6
        Set Element     ${dist_name}                                ${p_name}                       ${value}
    END
    #...                 ${distNames_BRGPRT[1]}                      l2BurstSize                     1048576
    #...                 ${distNames_BRGPRT[1]}                      l2ShaperRate                    1000000

    Set List Value      ${distNames_NRBTS[0]}                       srb1RlcAmProf                   ms45    p_name=dlTPollRetr
    Set List Value      ${distNames_NRBTS[0]}                       srb2RlcAmProf                   ms45    p_name=dlTPollRetr

    FOR                 ${dist_name}                                ${p_name}                                    IN
    ...                 ${distNames_NRBTS[0]}                       numNonGbrPdcpSduDiscard
    ...                 ${distNames_NRBTS[0]}                       numNonGbrRlcSduDiscard
    ...                 ${distNames_NRBTS[0]}                       pdcpBufUsageThreshold
    ...                 ${distNames_NRBTS[0]}                       rlcBufUsageThreshold
        Remove Element  ${dist_name}                                ${p_name}
    END

    #All Cells
    FOR  ${dist_name}  IN  @{distNames_NRCELL}
        Set Element     ${dist_name}                                actAdaptiveSr                    false
        Set Element     ${dist_name}                                actDlRbgRandomization            disabled
        Set Element     ${dist_name}                                actDrxRetransTimerSupport        false
        Set Element     ${dist_name}                                actDtxOptimizedScheduler         false
        Set Element     ${dist_name}                                actDynPdcchTdMode                disabled
        Set Element     ${dist_name}                                actEnhDtxOptimizedScheduler      false
        Set Element     ${dist_name}                                actFdmSchedulingInitialBWP       false
        Set Element     ${dist_name}                                actPerCsiReportBundlingTddFr1    true
        Set Element     ${dist_name}                                actPrachMultiplexing             true
        Set Element     ${dist_name}                                actShortBsrLimitAdaptation       true  # required
        Remove Element  ${dist_name}                                dlHpReservedRbgs
        Set Element     ${dist_name}                                dlMuMaxNumPairedUEs              8
        Remove Element  ${dist_name}                                dlSCellConfigLevel
        Remove Element  ${dist_name}                                dlSCellConfigLevelNum
        Set Element     ${dist_name}                                dllaDeltaCqiMax                  30
        Set Element     ${dist_name}                                dllaDeltaCqiMin                  -30
        Set Element     ${dist_name}                                dllaIniMcs                       0
        Remove Element  ${dist_name}                                minRbReservedForNonSiPaging
        Remove Element  ${dist_name}                                nrUlClpcProfileDN
        Remove Element  ${dist_name}                                raMsg2TargetRate
        Set Element     ${dist_name}                                sCellDeactivationTimerGNB        ms1280
        Set Element     ${dist_name}                                ssPbchBlockPower                 0
        Set Element     ${dist_name}                                ulLimitedMcsStepupSizeBler       1
        Remove List     ${dist_name}                                allowUnsuppBcOrBcs
        Set List Value  ${dist_name}                                csirsForTracking                 52RB        p_name=rbAllocation
        Set List Value  ${dist_name}                                drxProfile1                      20ms        p_name=drxInactivityTimer
        Set List Value  ${dist_name}                                drxProfile1                      40ms        p_name=drxLongCycle
        Set List Value  ${dist_name}                                drxProfile1                      16slot      p_name=drxRetransTimerDl
        Set List Value  ${dist_name}                                drxProfile1                      16slot      p_name=drxRetransTimerUl
        Set List Value  ${dist_name}                                fPdcchMonOccsnPo                 2  # required
        Set List Value  ${dist_name}                                periodicCsiAcquisition           0           p_name=csirsPower
    END

    # All NRDRB
    FOR  ${dist_name}  IN  @{distNames_NRDRB}
        Set Element     ${dist_name}                                actDlTxResumeOnPdcpStatRep       false
        Set Element     ${dist_name}                                actLostPduFastRetx               false
        Remove Element  ${dist_name}                                pdcpStatRepWaitTimer
        Remove Element  ${dist_name}                                pdcpStatRepWaitTimerOffset
        Remove Element  ${dist_name}                                reTxPrioritizationType
    END

    Remove Object       MRBTS-1/NRBTS-1/NRULCLPC_PROFILE-0
    Modify SibSchedulingList

    scf.Save Scf    ${WORKSPACE}/archive/CLOUD_5G_I_MP_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD_scfc.xml


*** Keywords ***
Test Suite Setup
    ute_workarounds.UTE Cloud Workaround
    Store Current SCF From GNB                 # ${P_ORIG_SCF}
    Create Test Suite Log Folders              # ${P_resultSuiteBaseDir} ${P_resultSuiteConfigDir} ${P_resultSuiteLogDir}
    Create Directory                           ${WORKSPACE}/archive
    Set Suite Variable                         $P_Console    ${True}


Testcase Setup
    Create Testcase Log Directory              # ${P_resultTestDir}


Testcase Teardown
    No Operation


Initialize Source SCF
    [Arguments]    ${topology}    ${variant}    ${file}=scfc.xml
    ${scf_path}       Catenate    /home/ute/DEVELOPMENT/performance/jenkins/configs/${topology}/${variant}/${file}
    scf.Load Scf      ${scf_path}
    Initialize Distnames    ${scf_path}


Modify Public Keys
    ${rootUserPublicKeys}    Catenate    SEPARATOR=    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqj6rBHtMjXndjZyApiMZv4B5T
    ...    L8KJy6mY1w9AFcsBNybZ2hJZk6Vrnyd291dngS7N/8lIDMs8EE6Zmniho6He3BhfqsJWpaQ4NQxUH3TfVtU8nP6BCVhZ6NEueNvPbGuYtDUP
    ...    OW2CO1vlUAH/zW2VVVjtQsjd3bg8UyxoGuGxsvJXucGB7APfac+c9afhPedcRfaYqMReGYAl0CAdcc3IRbMCEWVB8OXeL1zvTQ82gDWXnPSr
    ...    pqaWiSsIhpbkzBpCAHkHKHtnp4AqNubd3HSRIczBr5X411v6lcswO0yBujgXlOB/A0l28CiIoL1utL8N3/51d9ZU7i2PKnbRWrwV

    FOR  ${dist_name}  IN  @{distNames_SECADM}
        Set List Value    ${dist_name}      rootUserPublicKeys      ${rootUserPublicKeys}    p_name=keyValue
        Set List Value    ${dist_name}      serviceUserPublicKeys   ${rootUserPublicKeys}    p_name=keyValue
    END


Modify SibSchedulingList
    [Arguments]    ${dist_name}=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    ...            ${sibPeriodicity}=rf8
    ${list_name}                        Set Variable                    sibSchedulingList
    Set List                            dist_name=${dist_name}          list_name=${list_name}

    FOR    ${sibtype}    IN RANGE    2    9
        ${sibSchedulingList_dict}       Create Dictionary               sibBroadcastStatus                broadcasting
        ...                                                             sibPeriodicity                    ${sibPeriodicity}
        ...                                                             sibScope                          cellSpecific
        ...                                                             sibType                           sibType${sibtype}
        scf.Add Item To List            dist_name=${dist_name}          list_name=${list_name}            elements=${sibSchedulingList_dict}
    END

    ${sibSchedulingList_dict}           Create Dictionary               sibBroadcastStatus                broadcasting
    ...                                                                 sibPeriodicity                    ${sibPeriodicity}
    ...                                                                 sibScope                          cellSpecific
    ...                                                                 sibType                           sibType8
    scf.Add Item To List                dist_name=${dist_name}          list_name=${list_name}            elements=${sibSchedulingList_dict}


Initialize Distnames
    [Arguments]    ${scf}
    ${distNames_NRBTS}=     Get DistNames From Local SCF File  scf_path=${scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distNames_NRCELL}=    Get DistNames From Local SCF File  scf_path=${scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    ${distNames_NRDU}=      Get DistNames From Local SCF File  scf_path=${scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDU-[0-9]+
    ${distNames_NRDRB}=     Get DistNames From Local SCF File  scf_path=${scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDRB-[0-9]+
    ${distNames_BRGPRT}=    Get DistNames From Local SCF File  scf_path=${scf}
    ...                                                        regex=MRBTS-[0-9]+/TNLSVC-[0-9]+/TNL-[0-9]+/ETHSVC-[0-9]+/L2SWI-[0-9]+/BRGPRT-[0-9]+

    ${distNames_CABLINK}=   Get DistNames From Local SCF File  scf_path=${scf}  regex=MRBTS-[0-9]+/EQM-[0-9]+/HWTOP-[0-9]+/CABLINK-[0-9]+
    ${distNames_ETHLK}=     Get DistNames From Local SCF File  scf_path=${scf}  regex=MRBTS[0-9]+/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-[0-9]+
    ${distNames_SECADM}=    Get DistNames From Local SCF File  scf_path=${scf}  regex=MRBTS-[0-9]+/MNL-[0-9]+/MNLENT-[0-9]+/SECADM-[0-9]+

    ${distNameslist}=       Create List    distNames_NRBTS      distNames_NRCELL    distNames_NRDU      distNames_NRDRB    distNames_BRGPRT
    ...                                    distNames_CABLINK    distNames_ETHLK     distNames_SECADM

    FOR     ${distNames}    IN    @{distNameslist}
        Sort List             ${${distNames}}
        Set Suite Variable    $${distNames}
    END
