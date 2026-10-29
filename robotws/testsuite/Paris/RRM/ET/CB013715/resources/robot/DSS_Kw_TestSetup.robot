*** Settings ***
Documentation     [PURPOSE] Set of keywords used for 5GC002574 feature FDD tests cases
...
...               Automation author           : christophe.samson@nokia.com
...               Automation contact          : christophe.samson@nokia.com
...               Creation Date               : September 23 2021
...               Modified Date               : September 23 2021
...               Last Modified by            : christophe.samson@nokia.com

Resource                            ../../../../../resources/SWENG/robot/Tools.robot
Resource                            ../../../../../resources/SWENG/robot/PacketSearch.robot
Resource                            ../../../../../resources/SWENG/robot/Restart.robot
Resource                            ../../../../../resources/SWENG/robot/Capture.robot
Resource                            ../../../../../resources/SWENG/robot/CallSetup.robot
Resource                            ../../../../../resources/SWENG/robot/Traffic.robot
Resource                            ../../../../../resources/SWENG/robot/SetConfig.robot
Resource                            ../../../../../resources/SWENG/robot/Setup.robot
Resource                            ../../../../../resources/SWENG/robot/CaptureFilter.robot
Resource                            ../../../../../resources/SWENG/robot/WtsXmlConfig.robot
Resource                            ../../../../../resources/SWENG/robot/WtsCfgConfig.robot

# DSS specific
Resource                            ../../../resources/DSS/robot/common_Dss_Keywords.robot

# TARF specific
Resource                            ../TARF/robot/testline-Keywords.robot

Library                             ../../../resources/python/luashark_tools.py
Library                             luashark_tools.analyzer       WITH NAME       analyzer
Library                             taf.config.wts                WITH NAME       wts_cfg
Library                             ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME     coam_parameter

Library                             ../TARF/python/tools.py       WITH NAME        nps_tarf_tools
# Library                             ../../../resources/TRF/python/tools.py       WITH NAME          nps_tarf_tools

Variables                           ../../../../../resources/SWENG/python/ReadConfig.py

# to use the Constants.py file (from resources/python dir)
Variables                           ../TARF/python/Constants-features.py

*** Variables ***

# MRBTS-1/NRBTS-1
&{NRBTS_FDD_DSS}       actLteNrDss=true
...                    mcc=311
...                    mnc=489
...                    mncLength=3
...                    actFdmScheduling=true
...                    actInactDetNSAUe=true
...                    drbInactivityTimerSA=600
...                    srbInactivityTimerSA=600
&{NRBTS_FDD_DSS_FDM}   actLteNrDss=true
...                    mcc=311
...                    mnc=489
...                    mncLength=3
...                    actFdmScheduling=true
...                    actInactDetNSAUe=true
...                    drbInactivityTimerSA=600
...                    srbInactivityTimerSA=600
&{NRBTS_TRBLCADM}      actInternalTrace=true
&{NRBTS_FEATCADM}      actCli=true
&{NRBTS_FDD_NoDSS}     actLteNrDss=false
# NIDD param NRBTS.tmpParam7 ( 0 = disabled [default]; 1 = enabled )
# NRBTS.tmpParam7=1    for 1586-M (742)
&{NRBTS_FDD_DSS_742_ON}       tmpParam7=1
&{NRBTS_FDD_DSS_742_OFF}       tmpParam7=0
# MRBTS-1/NRBTS-1/NRCELL-1/NRCELL_FDD-1
&{NRCELL_FDD5MHz}      chBwDl=5MHz
...                    chBwUl=5MHz
...                    nrarfcnDl=125900
...                    nrarfcnUl=135100
&{NRCELL_FDD10MHz}     chBwDl=10MHz
...                    chBwUl=10MHz
...                    nrarfcnDl=127100
...                    nrarfcnUl=136300
...                    lteearfcnDl=68771
...                    lteearfcnUl=133307
&{NRCELL_FDD10MHz_DSS_Ph3}     chBwDl=10MHz
...                    chBwUl=10MHz
...                    nrarfcnDl=127100
...                    nrarfcnUl=136300
...                    lteearfcnDl=68771
...                    lteearfcnUl=133307
&{NRCELL_FDD15MHz_DSS_Ph3}     chBwDl=15MHz
...                    chBwUl=15MHz
...                    nrarfcnDl=127100
...                    nrarfcnUl=136300
...                    lteearfcnDl=68771
...                    lteearfcnUl=133307
&{NRCELL_FDD20MHz_DSS_Ph3}     chBwDl=20MHz
...                    chBwUl=20MHz
...                    nrarfcnDl=127100
...                    nrarfcnUl=136300
# ...                    nrarfcnDl=127420
# ...                    nrarfcnUl=136620
...                    lteearfcnDl=68771
...                    lteearfcnUl=133307
# MRBTS-1/NRBTS-1/NRCELLGRP-0
&{NRCELLGRP_5MHz}      csiReportPeriodicity=slots320
&{NRCELLGRP_10MHz}     csiReportPeriodicity=slots160
&{NRCELLGRP_15MHz}     csiReportPeriodicity=slots160
&{NRCELLGRP_20MHz}     csiReportPeriodicity=slots160
# MRBTS-1/NRBTS-1/NRCELL-1
&{NRCELL5MHz}          gscn=1
...                    type0CoresetConfigurationIndex=0
...                    dlDMRSAdditionalPosition=No additional DMRS
...                    ulDMRSAdditionalPosition=No additional DMRS
...                    cellName=Cell1
...                    dmrsTypeAPosition=pos2
...                    lteNrDssMode=none
...                    msg1FrequencyStart=0
...                    ullaIniMcs=0
...                    actPRBBlanking=false
...                    trsMutingInBlankedPRBsEnabled=false
...                    prachConfigurationIndex=12
&{NRCELL10MHz_DSS_Ph3}         gscn=1588
...                    type0CoresetConfigurationIndex=6
...                    dlDMRSAdditionalPosition=No additional DMRS
...                    ulDMRSAdditionalPosition=No additional DMRS
...                    cellName=DSS-Ph3 Cell1
...                    dmrsTypeAPosition=pos3
...                    lteNrDssMode=DSS_Phase_3
...                    msg1FrequencyStart=10
...                    ullaIniMcs=3
...                    actPRBBlanking=false
...                    trsMutingInBlankedPRBsEnabled=false
...                    tmpActFeat1=32
...                    prachConfigurationIndex=12
&{NRCELL15MHz_DSS_Ph3}         gscn=1588
...                    type0CoresetConfigurationIndex=6
...                    dlDMRSAdditionalPosition=No additional DMRS
...                    ulDMRSAdditionalPosition=No additional DMRS
...                    cellName=DSS-Ph3 Cell1
...                    dmrsTypeAPosition=pos3
...                    lteNrDssMode=DSS_Phase_3
...                    msg1FrequencyStart=10
...                    ullaIniMcs=3
...                    actPRBBlanking=false
...                    trsMutingInBlankedPRBsEnabled=false
...                    tmpActFeat1=32
...                    prachConfigurationIndex=12
&{NRCELL20MHz_DSS_Ph3_BLE_OLD}      gscn=1591
...                    type0CoresetConfigurationIndex=7
...                    dlDMRSAdditionalPosition=No additional DMRS
...                    ulDMRSAdditionalPosition=No additional DMRS
...                    cellName=DSS-Ph3 Cell1
...                    dmrsTypeAPosition=pos3
...                    lteNrDssMode=DSS_Phase_3
...                    msg1FrequencyStart=6
...                    ullaIniMcs=8
...                    actPRBBlanking=true
...                    trsMutingInBlankedPRBsEnabled=false
...                    tmpActFeat1=32
...                    prachConfigurationIndex=12
# CB013715 modifications
&{NRCELL_FDD10MHz_BLE}     chBwDl=10MHz
...                    chBwUl=10MHz
...                    nrarfcnDl=127420
...                    nrarfcnUl=136620
...                    lteearfcnDl=68787
...                    lteearfcnUl=133323
# config for 10MHz BLE=1 and BHE=3
&{NRCELL_FDD10MHz_BLE_2}     chBwDl=10MHz
...                    chBwUl=10MHz
...                    nrarfcnDl=127820
...                    nrarfcnUl=137020
...                    lteearfcnDl=68807
...                    lteearfcnUl=133343
# config for 10MHz BLE=2 and BHE=2
&{NRCELL_FDD10MHz_BLE_3}     chBwDl=10MHz
...                    chBwUl=10MHz
...                    nrarfcnDl=127620
...                    nrarfcnUl=136820
...                    lteearfcnDl=68797
...                    lteearfcnUl=133333
&{NRCELL_FDD15MHz_BLE}     chBwDl=15MHz
...                    chBwUl=15MHz
...                    nrarfcnDl=127420
...                    nrarfcnUl=136620
...                    lteearfcnDl=68787
...                    lteearfcnUl=133323
&{NRCELL_FDD15MHz_NO_BL}     chBwDl=15MHz
...                    chBwUl=15MHz
...                    nrarfcnDl=127420
...                    nrarfcnUl=136620
...                    lteearfcnDl=68787
...                    lteearfcnUl=133323
&{NRCELL_FDD20MHz_BLE}     chBwDl=20MHz
...                    chBwUl=20MHz
...                    nrarfcnDl=127420
...                    nrarfcnUl=136620
...                    lteearfcnDl=68787
...                    lteearfcnUl=133323
&{NRCELL_FDD20MHz_NO_BL}     chBwDl=20MHz
...                    chBwUl=20MHz
...                    nrarfcnDl=127420
...                    nrarfcnUl=136620
...                    lteearfcnDl=68787
...                    lteearfcnUl=133323
&{NRCELL10MHz_DSS_Ph3_BLE}         gscn=1592
...                    type0CoresetConfigurationIndex=6
...                    dlDMRSAdditionalPosition=No additional DMRS
...                    ulDMRSAdditionalPosition=No additional DMRS
...                    cellName=DSS-Ph3 Cell1
...                    dmrsTypeAPosition=pos3
...                    lteNrDssMode=DSS_Phase_3
...                    msg1FrequencyStart=10
...                    ullaIniMcs=3
...                    actPRBBlanking=false
...                    trsMutingInBlankedPRBsEnabled=false
...                    tmpActFeat1=32
...                    prachConfigurationIndex=12
# config for 10MHz BLE=1 and BHE=3
&{NRCELL10MHz_DSS_Ph3_BLE_2}         gscn=1597
...                    type0CoresetConfigurationIndex=6
...                    dlDMRSAdditionalPosition=No additional DMRS
...                    ulDMRSAdditionalPosition=No additional DMRS
...                    cellName=DSS-Ph3 Cell1
...                    dmrsTypeAPosition=pos3
...                    lteNrDssMode=DSS_Phase_3
...                    msg1FrequencyStart=9
...                    ullaIniMcs=3
...                    actPRBBlanking=false
...                    trsMutingInBlankedPRBsEnabled=false
...                    tmpActFeat1=32
...                    prachConfigurationIndex=12
# config for 10MHz BLE=2 and BHE=2
&{NRCELL10MHz_DSS_Ph3_BLE_3}         gscn=1596
...                    type0CoresetConfigurationIndex=7
...                    dlDMRSAdditionalPosition=No additional DMRS
...                    ulDMRSAdditionalPosition=No additional DMRS
...                    cellName=DSS-Ph3 Cell1
...                    dmrsTypeAPosition=pos3
...                    lteNrDssMode=DSS_Phase_3
...                    msg1FrequencyStart=8
...                    ullaIniMcs=3
...                    actPRBBlanking=false
...                    trsMutingInBlankedPRBsEnabled=false
...                    tmpActFeat1=32
...                    prachConfigurationIndex=12
&{NRCELL15MHz_DSS_Ph3_BLE}         gscn=1592
...                    type0CoresetConfigurationIndex=6
...                    dlDMRSAdditionalPosition=No additional DMRS
...                    ulDMRSAdditionalPosition=No additional DMRS
...                    cellName=DSS-Ph3 Cell1
...                    dmrsTypeAPosition=pos3
...                    lteNrDssMode=DSS_Phase_3
...                    msg1FrequencyStart=11
...                    ullaIniMcs=3
...                    actPRBBlanking=false
...                    trsMutingInBlankedPRBsEnabled=true
...                    tmpActFeat1=32
...                    prachConfigurationIndex=12
# End Of CB013715 modifications
&{NRCELL10MHz_DSS_Ph3_BLE_OLD}      gscn=1591
...                    type0CoresetConfigurationIndex=7
...                    dlDMRSAdditionalPosition=No additional DMRS
...                    ulDMRSAdditionalPosition=No additional DMRS
...                    cellName=DSS-Ph3 Cell1
...                    dmrsTypeAPosition=pos3
...                    lteNrDssMode=DSS_Phase_3
...                    msg1FrequencyStart=6
...                    ullaIniMcs=8
...                    actPRBBlanking=true
...                    trsMutingInBlankedPRBsEnabled=false
...                    tmpActFeat1=32
...                    prachConfigurationIndex=12
&{NRCELL20MHz_DSS_Ph3}         gscn=1588
# ...                    gscn=1592
# ...                    type0CoresetConfigurationIndex=7
...                    type0CoresetConfigurationIndex=6
...                    dlDMRSAdditionalPosition=No additional DMRS
...                    ulDMRSAdditionalPosition=No additional DMRS
...                    cellName=DSS-Ph3 Cell1
...                    dmrsTypeAPosition=pos3
...                    lteNrDssMode=DSS_Phase_3
...                    msg1FrequencyStart=10
...                    ullaIniMcs=3
...                    actPRBBlanking=false
...                    trsMutingInBlankedPRBsEnabled=false
...                    tmpActFeat1=32
...                    prachConfigurationIndex=12
&{NRCELL20MHz_DSS_Ph3_BLE}         gscn=1592
...                    type0CoresetConfigurationIndex=6
...                    dlDMRSAdditionalPosition=No additional DMRS
...                    ulDMRSAdditionalPosition=No additional DMRS
...                    cellName=DSS-Ph3 Cell1
...                    dmrsTypeAPosition=pos3
...                    lteNrDssMode=DSS_Phase_3
...                    msg1FrequencyStart=10
...                    ullaIniMcs=3
...                    actPRBBlanking=false
...                    trsMutingInBlankedPRBsEnabled=false
...                    tmpActFeat1=32
...                    prachConfigurationIndex=12
&{NRCELL10MHz}         gscn=1592
...                    type0CoresetConfigurationIndex=7
...                    dlDMRSAdditionalPosition=No additional DMRS
...                    ulDMRSAdditionalPosition=No additional DMRS
...                    cellName=DSS Cell1
...                    dmrsTypeAPosition=pos3
...                    lteNrDssMode=DSS_Phase_3
...                    msg1FrequencyStart=10
...                    ullaIniMcs=8
...                    actPRBBlanking=false
...                    trsMutingInBlankedPRBsEnabled=false
...                    tmpActFeat1=32
...                    prachConfigurationIndex=12
&{NRCELL10MHzNoDSS}     gscn=1592
...                    type0CoresetConfigurationIndex=7
...                    dlDMRSAdditionalPosition=No additional DMRS
...                    ulDMRSAdditionalPosition=No additional DMRS
...                    cellName=DSS Cell1
...                    dmrsTypeAPosition=pos3
...                    lteNrDssMode=none
...                    msg1FrequencyStart=0
...                    ullaIniMcs=8
...                    actPRBBlanking=false
...                    trsMutingInBlankedPRBsEnabled=false
...                    tmpActFeat1=32
...                    prachConfigurationIndex=12


# MRBTS-1/NRBTS-1/NRPMRNL-1
&{NRPMRNL_5MHz}        miNrEnDssPerCell=15min
...                    miNrCellUtilization=15min
&{NRPMRNL_10MHz}       miNrEnDssPerCell=5min
...                    miNrCellUtilization=5min
&{NRPMRNL_15MHz}       miNrEnDssPerCell=5min
...                    miNrCellUtilization=5min
&{NRPMRNL_20MHz}       miNrEnDssPerCell=5min
...                    miNrCellUtilization=5min
&{NRPMRNL_10MHz_NoDSS}       miNrEnDssPerCell=15min
...                          miNrCellUtilization=15min

# MRBTS-1
&{MRBTS5MHz}           btsName="NPS TL 5MHz"
&{MRBTS10MHzNoDSS}     btsName="NPS TL 10MHz Without Feature DSS"
&{MRBTS10MHz}          btsName="NPS TL 10MHz Feature DSS On - 13715"
&{MRBTS10MHz_DSS_Ph3}          btsName=- NPS TL 10MHz Feature DSS Phase3 On - 13715 -
&{MRBTS15MHz_DSS_Ph3}          btsName=- NPS TL 15MHz Feature DSS Phase3 On - 13715 -
&{MRBTS20MHz_DSS_Ph3}          btsName=- NPS TL 20MHz Feature DSS Phase3 On - 13715 -


# MRBTS-1/NRBTS-1/NRCELL-1/NRDSSLTE-1
&{NRCELL_NRDSSLTE}         dssDlTPollRetr=ms80
...                    dssDlTProhib=ms0
...                    dssUlTPollRetr=ms5
...                    dssUlTProhib=ms0
...                    eNodeBId=1
...                    lcrId=1
...                    ltePhyCellId=11
...                    ssbPosition=pos1
...                    actLteNrDssFastAlloc=false
...                    lteNrDssFastAllocPerfEnh=disabled
...                    dssMaxNumberOfDlDcis=1
...                    actRateMatchedCsiIm=false
...                    actLteNrDssLteCatM=false
...                    actUlAdaptReTxEnhDss=false
...                    actDssMsg3Enh=true
&{NRCELL_NRDSSLTE_DSS_Ph3}          dssDlTPollRetr=ms80
...                                 dssDlTProhib=ms0
...                                 dssUlTPollRetr=ms5
...                                 dssUlTProhib=ms0
...                                 eNodeBId=1
...                                 lcrId=1
...                                 ltePhyCellId=11
...                                 ssbPosition=pos1
...                                 dssMaxNumberOfDlDcis=1
...                                 actLteNrDssFastAlloc=true
...                                 lteNrDssFastAllocPerfEnh=exc_msg_reduction_static
...                                 actRateMatchedCsiIm=true
...                                 actLteNrDssLteCatM=false
...                                 actDssMsg3Enh=true
...                                 actUlAdaptReTxEnhDss=false
&{NRCELL_NRDSSLTE_DSS_Ph3_Cell2}    dssDlTPollRetr=ms80
...                                 dssDlTProhib=ms0
...                                 dssUlTPollRetr=ms5
...                                 dssUlTProhib=ms0
...                                 eNodeBId=1
...                                 lcrId=2
...                                 ltePhyCellId=12
...                                 ssbPosition=pos1
...                                 dssMaxNumberOfDlDcis=1
...                                 actLteNrDssFastAlloc=false
...                                 lteNrDssFastAllocPerfEnh=disabled
...                                 actRateMatchedCsiIm=true
...                                 actLteNrDssLteCatM=false
...                                 actDssMsg3Enh=true
...                                 actUlAdaptReTxEnhDss=false
&{NRCELL_NRDSSLTE_SSB_POS6}         dssDlTPollRetr=ms80
...                                 dssDlTProhib=ms0
...                                 dssUlTPollRetr=ms5
...                                 dssUlTProhib=ms0
...                                 eNodeBId=1
...                                 lcrId=1
...                                 ltePhyCellId=11
...                                 ssbPosition=pos6
...                                 dssMaxNumberOfDlDcis=1
...                                 actLteNrDssFastAlloc=false
...                                 lteNrDssFastAllocPerfEnh=disabled
...                                 actRateMatchedCsiIm=true
...                                 actLteNrDssLteCatM=true
...                                 actDssMsg3Enh=true
...                                 actUlAdaptReTxEnhDss=false

&{NRCELL_NRDSSLTE_enbPlmn}         mcc=311
...                    mnc=489
...                    mncLength=3
&{NRCELL_NRDSSLTE_lteNrDssDlRatio}         maxNrDssRatio=100
...                    minNrDssRatio=30
...                    dlResourceSharingAlgo=DL PRB load based
&{NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}         maxValue=50
...                    minValue=50
&{NRCELL_NRDSSLTE_lteNrDssUlRatio}         maxNrDssRatio=50
...                    minNrDssRatio=50

${IPIF-XP-ID}                                          1
${XPIF_XPIFREMOTE}                                  10.0.1.137
${IPIF}                                             10.0.1.111

# ${XPIF_XPIFREMOTE}                                  10.0.1.1
# ${IPIF}                                             10.0.1.2

# MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1
&{MRBTS_XPIF}         sctpAssocMaxRetrans=7
...                    sctpDscp=46
...                    sctpHeartbeatInterval=20
...                    sctpMaxPayloadSize=1395
...                    sctpRtoMax=30000
...                    sctpRtoMin=1000
...                    sctpSackDelay=200
...                    sctpSackFreq=2
...                    sctpWaitTimeInitSeqRetry=240
...                    udpDscp=18
...                    ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-6/IPADDRESSV4-1
...                    localNeDN=MRBTS-1/NRBTS-1

# MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1
&{MRBTS_XPIF_XPIFREMOTE}         ipAddress=${XPIF_XPIFREMOTE}

# MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
&{MRBTS_IPIF}         localIpAddr=${IPIF}

# MRBTS-1/NRBTS-1/NRDRB-1
# MRBTS-1/NRBTS-1/NRDRB-2
# MRBTS-1/NRBTS-1/NRDRB-3
# .....
# MRBTS-1/NRBTS-1/NRDRB-14
# nsaDrbParam ulDataPath
&{NRDRB_DSS}        ulDataPath=ulOverNr
...                 ulDataSplitThreshold=infinity
...                 dlDataSplitMode=dlOverF1U
&{NRDRB}            ulDataPath=uloverltenr
...                 ulDataSplitThreshold=b102400
...                 dlDataSplitMode=dloverf1ux2u

# NIDD param NRBTS.tmpParam7 ( 0 = disabled [default]; 1 = enabled )
# NRBTS.tmpParam7=1    for 1586-M
&{NRBTS_1586M_ON}     tmpParam7=1
&{NRBTS_1586M_OFF}     tmpParam7=0

#----------------------------------------------------------------------------------------------------------------------------------------------------
#                  WA to reach Cellsetup with UTE TL !!!
#----------------------------------------------------------------------------------------------------------------------------------------------------

# NRCELL	Parameter=actDl256Qam		                                                     true
# NRCELL	Parameter=msg1FrequencyStart	                                                 3
# NRCELL	Parameter=numOfPagingFrames	                                                     quatert
# NRCELL	Parameter=pagingOffset			                                                 2
# NRCELL	Parameter=pucchModeSelect			                                             longpucch
# NRCELL	Parameter=raResponseWindow	                                                     sl80
# NRCELL	Parameter=type0SearchSpaceConfigurationIndex		                             15
# NRCELL	Parameter=csirsTrackingPeriod	               ListName=csirsForTracking         80ms
# NRCELL	Parameter=actDlDataDmrsFdm   	               ListName=dlDataDmrsFdm		     true
# NRCELL	Parameter=csiReportPeriodicity	               ListName=periodicCsiAcquisition	 slots160

&{NRCELL_WA}           actDl256Qam=true
...                    msg1FrequencyStart=3
...                    numOfPagingFrames=quaterT
...                    pagingOffset=2
...                    pucchModeSelect=longPucch
...                    raResponseWindow=sl80
...                    type0SearchSpaceConfigurationIndex=15
...                    csirsTrackingPeriod=80ms
...                    actDlDataDmrsFdm=true
...                    csiReportPeriodicity=slots160

&{NRCELL_PAGING}       numOfPagingFrames=quaterT
...                    pagingOffset=2
...                    numPagingOccsnPagingFrame=one
...                    fPdcchMonOccsnPo=0
...                    type0SearchSpaceConfigurationIndex=15
...                    csirsTrackingPeriod=80ms

&{NRCELL_WA_SSB6}      actDl256Qam=true
...                    msg1FrequencyStart=3
...                    numOfPagingFrames=quaterT
...                    pagingOffset=2
...                    pucchModeSelect=longPucch
...                    raResponseWindow=sl80
...                    type0SearchSpaceConfigurationIndex=11
...                    csirsTrackingPeriod=80ms
...                    actDlDataDmrsFdm=true
...                    csiReportPeriodicity=slots160

&{NRSYSINFO_PROFILE_WA}   sibPeriodicity=rf64
...                       siWindowLength=s160

#----------------------------------------------------------------------------------------------------------------------------------------------------
&{Scf5MHz}             mrbts=${MRBTS5MHz}      nrbts=${NRBTS_FDD_NoDSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD5MHz}      nrcell=${NRCELL5MHz}     nrbts_featcadm=${NRBTS_FEATCADM}
...                    nrcellgrp=${NRCELLGRP_5MHz}      nrpmrnl=${NRPMRNL_5MHz}    nrdrb=${NRDRB}    apSwconfig=0
&{Scf10MHzDSS_OLD}         mrbts=${MRBTS10MHz}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}    nrcellfdd=${NRCELL_FDD10MHz}
...                    nrcell=${NRCELL10MHz}     ipif=${MRBTS_IPIF}
...                    nrcellgrp=${NRCELLGRP_10MHz}     nrpmrnl=${NRPMRNL_10MHz}    nrdrb=${NRDRB_DSS}    nrdsslte=${NRCELL_NRDSSLTE}
...                    enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}     lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   nrbts742=${NRBTS_FDD_DSS_742_OFF}    apSwconfig=0

&{Scf10MHzDSS}         mrbts=${MRBTS10MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD10MHz_DSS_Ph3}   nrcell=${NRCELL10MHz_DSS_Ph3}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_10MHz}     nrpmrnl=${NRPMRNL_10MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=4CCEs      actPRBBlanking=false      BlankedPRBs=${NRCELL20MHz_wo_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

&{Scf10MHzDSS_BLE}     mrbts=${MRBTS10MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD10MHz_BLE}   nrcell=${NRCELL10MHz_DSS_Ph3_BLE}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_10MHz}     nrpmrnl=${NRPMRNL_10MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=2CCEs      actPRBBlanking=true      BlankedPRBs=${NRCELL10MHz_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false
# config for 10MHz BLE=1 and BHE=3
&{Scf10MHzDSS_BLE_2}   mrbts=${MRBTS10MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD10MHz_BLE_2}   nrcell=${NRCELL10MHz_DSS_Ph3_BLE_2}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_10MHz}     nrpmrnl=${NRPMRNL_10MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=2CCEs      actPRBBlanking=true      BlankedPRBs=${NRCELL10MHz_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false
# config for 10MHz BLE=2 and BHE=2
&{Scf10MHzDSS_BLE_3}   mrbts=${MRBTS10MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD10MHz_BLE_3}   nrcell=${NRCELL10MHz_DSS_Ph3_BLE_3}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_10MHz}     nrpmrnl=${NRPMRNL_10MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=2CCEs      actPRBBlanking=true      BlankedPRBs=${NRCELL10MHz_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

&{Scf15MHzDSS_BLE}     mrbts=${MRBTS15MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD15MHz_BLE}   nrcell=${NRCELL15MHz_DSS_Ph3_BLE}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_15MHz}     nrpmrnl=${NRPMRNL_15MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=4CCEs      actPRBBlanking=true      BlankedPRBs=${NRCELL15MHz_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

&{Scf15MHzDSS_NO_BL}   mrbts=${MRBTS15MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD15MHz_NO_BL}   nrcell=${NRCELL15MHz_DSS_Ph3_BLE}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_15MHz}     nrpmrnl=${NRPMRNL_15MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=4CCEs      actPRBBlanking=false      BlankedPRBs=${NRCELL20MHz_wo_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

&{Scf20MHzDSS_BLE}     mrbts=${MRBTS20MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD20MHz_BLE}   nrcell=${NRCELL20MHz_DSS_Ph3_BLE}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_20MHz}     nrpmrnl=${NRPMRNL_20MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=4CCEs      actPRBBlanking=true      BlankedPRBs=${NRCELL20MHz_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

&{Scf20MHzDSS_BLE_Cell2}     mrbts=${MRBTS20MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD20MHz_BLE}   nrcell=${NRCELL20MHz_DSS_Ph3_BLE}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_20MHz}     nrpmrnl=${NRPMRNL_20MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3_Cell2}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}
...                    lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=4CCEs      actPRBBlanking=true      BlankedPRBs=${NRCELL20MHz_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

&{Scf20MHzDSS_NO_BL}   mrbts=${MRBTS20MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD20MHz_NO_BL}   nrcell=${NRCELL20MHz_DSS_Ph3_BLE}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_20MHz}     nrpmrnl=${NRPMRNL_20MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=4CCEs      actPRBBlanking=false      BlankedPRBs=${NRCELL20MHz_wo_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

&{Scf10MHzDSS_2574}         mrbts=${MRBTS10MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD10MHz_DSS_Ph3}   nrcell=${NRCELL10MHz_DSS_Ph3}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_10MHz}     nrpmrnl=${NRPMRNL_10MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=4CCEs      actPRBBlanking=false      BlankedPRBs=${NRCELL20MHz_wo_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

&{Scf10MHzDSS_2574_BLE}         mrbts=${MRBTS10MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD10MHz_DSS_Ph3}   nrcell=${NRCELL10MHz_DSS_Ph3_BLE}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_10MHz}     nrpmrnl=${NRPMRNL_10MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=2CCEs      actPRBBlanking=true      BlankedPRBs=${NRCELL10MHz_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

&{Scf15MHzDSS}         mrbts=${MRBTS15MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD15MHz_DSS_Ph3}   nrcell=${NRCELL15MHz_DSS_Ph3}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_15MHz}     nrpmrnl=${NRPMRNL_15MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=4CCEs      actPRBBlanking=false      BlankedPRBs=${NRCELL20MHz_wo_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

&{Scf15MHzDSS_2574}         mrbts=${MRBTS15MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD15MHz_DSS_Ph3}   nrcell=${NRCELL15MHz_DSS_Ph3}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_15MHz}     nrpmrnl=${NRPMRNL_15MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=4CCEs      actPRBBlanking=false      BlankedPRBs=${NRCELL20MHz_wo_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

&{Scf10MHzDSS_2574_Pos6}         mrbts=${MRBTS10MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD10MHz_DSS_Ph3}   nrcell=${NRCELL10MHz_DSS_Ph3}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_10MHz}     nrpmrnl=${NRPMRNL_10MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA_SSB6}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=4CCEs      actPRBBlanking=false      BlankedPRBs=${NRCELL20MHz_wo_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

&{NRCELL20MHz_wo_BLE_AL4}      nbrOfBlankedPRBsHighEdgeDL=0
...                         nbrOfBlankedPRBsHighEdgeUL=0
...                         nbrOfBlankedPRBsLowEdgeDL=0
...                         nbrOfBlankedPRBsLowEdgeUL=0
...                         msg=

&{NRCELL15MHz_BLE_AL4}      nbrOfBlankedPRBsHighEdgeDL=0
...                         nbrOfBlankedPRBsHighEdgeUL=0
...                         nbrOfBlankedPRBsLowEdgeDL=4
...                         nbrOfBlankedPRBsLowEdgeUL=4
...                         msg=BLE 4PRB

&{NRCELL20MHz_BLE_AL4}      nbrOfBlankedPRBsHighEdgeDL=0
...                         nbrOfBlankedPRBsHighEdgeUL=0
...                         nbrOfBlankedPRBsLowEdgeDL=3
...                         nbrOfBlankedPRBsLowEdgeUL=3
...                         msg=BLE 3PRB

&{NRCELL20MHz_BHE_AL4}      nbrOfBlankedPRBsHighEdgeDL=3
...                         nbrOfBlankedPRBsHighEdgeUL=3
...                         nbrOfBlankedPRBsLowEdgeDL=0
...                         nbrOfBlankedPRBsLowEdgeUL=0
...                         msg=BHE 3PRB

&{NRCELL10MHz_BLE_AL4}      nbrOfBlankedPRBsHighEdgeDL=0
...                         nbrOfBlankedPRBsHighEdgeUL=0
...                         nbrOfBlankedPRBsLowEdgeDL=3
...                         nbrOfBlankedPRBsLowEdgeUL=3
...                         msg=BLE 3PRB

&{Scf20MHzDSS_2574_BLE}         mrbts=${MRBTS20MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD20MHz_DSS_Ph3}   nrcell=${NRCELL20MHz_DSS_Ph3_BLE}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_20MHz}     nrpmrnl=${NRPMRNL_20MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=4CCEs      actPRBBlanking=true      BlankedPRBs=${NRCELL20MHz_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

&{Scf20MHzDSS_2574_BHE}         mrbts=${MRBTS20MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD20MHz_DSS_Ph3}   nrcell=${NRCELL20MHz_DSS_Ph3_BLE}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_20MHz}     nrpmrnl=${NRPMRNL_20MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=4CCEs      actPRBBlanking=true      BlankedPRBs=${NRCELL20MHz_BHE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

&{Scf20MHzDSS}         mrbts=${MRBTS20MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD20MHz_DSS_Ph3}   nrcell=${NRCELL20MHz_DSS_Ph3}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_20MHz}     nrpmrnl=${NRPMRNL_20MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=4CCEs      actPRBBlanking=false      BlankedPRBs=${NRCELL20MHz_wo_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

# 20MHz BW case : PDCCH profil to upade later !!!
&{Scf20MHzDSS_2574}         mrbts=${MRBTS20MHz_DSS_Ph3}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD20MHz_DSS_Ph3}   nrcell=${NRCELL20MHz_DSS_Ph3}      nrbts_featcadm=${NRBTS_FEATCADM}
...                    ipif=${MRBTS_IPIF}   nrcellgrp=${NRCELLGRP_20MHz}     nrpmrnl=${NRPMRNL_20MHz}    nrdrb=${NRDRB_DSS}
...                    nrdsslte=${NRCELL_NRDSSLTE_DSS_Ph3}   enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}   lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}
...                    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   apSwconfig=0
...                    nrcell_wa=${NRCELL_WA}      nrsysinfo_profile_wa=${NRSYSINFO_PROFILE_WA}
...                    aggregationLevel=4CCEs      actPRBBlanking=false      BlankedPRBs=${NRCELL20MHz_wo_BLE_AL4}
...                    trsMutingInBlankedPRBsEnabled=false

&{Scf10MHzDSS_1586M}         mrbts=${MRBTS10MHz}     nrbts=${NRBTS_FDD_DSS}    nrbts_trblcadm=${NRBTS_TRBLCADM}    nrcellfdd=${NRCELL_FDD10MHz}
...                    nrcell=${NRCELL10MHz}      nrbts_featcadm=${NRBTS_FEATCADM}     ipif=${MRBTS_IPIF}
...                    nrcellgrp=${NRCELLGRP_10MHz}     nrpmrnl=${NRPMRNL_10MHz}    nrdrb=${NRDRB_DSS}    nrdsslte=${NRCELL_NRDSSLTE}
...                    enbPlmn=${NRCELL_NRDSSLTE_enbPlmn}     lteNrDssDlRatio=${NRCELL_NRDSSLTE_lteNrDssDlRatio}
...                    lteNrDssMbsfnRatio=${NRCELL_NRDSSLTE_lteNrDssMbsfnRatio}    lteNrDssUlRatio=${NRCELL_NRDSSLTE_lteNrDssUlRatio}
...                    xpif=${MRBTS_XPIF}    xpif_xpifremote=${MRBTS_XPIF_XPIFREMOTE}   nrbts742=${NRBTS_FDD_DSS_742_ON}    apSwconfig=0


&{Scf10MHzNoDSS}       mrbts=${MRBTS10MHzNoDSS}     nrbts=${NRBTS_FDD_NoDSS}   nrbts_trblcadm=${NRBTS_TRBLCADM}
...                    nrcellfdd=${NRCELL_FDD10MHz}    nrbts_featcadm=${NRBTS_FEATCADM}    ipif=${MRBTS_IPIF}
...                    nrcell=${NRCELL10MHzNoDSS}       nrcellgrp=${NRCELLGRP_10MHz}     nrpmrnl=${NRPMRNL_10MHz_NoDSS}    nrdrb=${NRDRB}
...                    apSwconfig=0

&{wtsXml5MHz}          dlNrArfcn=125900      ulNrArfcn=135100     dlUlBandwidth=25     ssBlockPrbOffset=3    bw=5MHz
&{wtsXml10MHz}         dlNrArfcn=127100      ulNrArfcn=136300     dlUlBandwidth=52     ssBlockPrbOffset=16    bw=10MHz
&{wtsXml10MHz_BLE}     dlNrArfcn=127420      ulNrArfcn=136620     dlUlBandwidth=52     ssBlockPrbOffset=16    bw=10MHz
# config for 10MHz BLE=1 and BHE=3
&{wtsXml10MHz_BLE_2}   dlNrArfcn=127820      ulNrArfcn=137020     dlUlBandwidth=52     ssBlockPrbOffset=16    bw=10MHz
# &{wtsXml10MHz_BLE_2}   dlNrArfcn=127520      ulNrArfcn=136720     dlUlBandwidth=52     ssBlockPrbOffset=16    bw=10MHz
# config for 10MHz BLE=2 and BHE=2
&{wtsXml10MHz_BLE_3}   dlNrArfcn=127620      ulNrArfcn=136620     dlUlBandwidth=52     ssBlockPrbOffset=16    bw=10MHz
&{wtsXml15MHz}         dlNrArfcn=127100      ulNrArfcn=136300     dlUlBandwidth=79     ssBlockPrbOffset=46    bw=15MHz
&{wtsXml15MHz_NO_BL}   dlNrArfcn=127420      ulNrArfcn=136620     dlUlBandwidth=79     ssBlockPrbOffset=46    bw=15MHz
&{wtsXml15MHz_BLE}     dlNrArfcn=127420      ulNrArfcn=136620     dlUlBandwidth=79     ssBlockPrbOffset=46    bw=15MHz
&{wtsXml20MHz}         dlNrArfcn=127100      ulNrArfcn=136300     dlUlBandwidth=106    ssBlockPrbOffset=73    bw=20MHz
&{wtsXml20MHz_BLE}     dlNrArfcn=127420      ulNrArfcn=136620     dlUlBandwidth=106    ssBlockPrbOffset=73    bw=20MHz
&{wtsXml20MHz_NO_BL}   dlNrArfcn=127420      ulNrArfcn=136620     dlUlBandwidth=106    ssBlockPrbOffset=73    bw=20MHz


#----------------------------------------------------------------------------------------------------------------------------------------------------
# DSS Cell 5G part:                                                          ulSR                   20%	          30%	           40%
#                               Customer	                    case #	    Num_Carrier	         tput_DSS_p1	tput_DSS_p2	     tput_DSS_p3
#		5G_FDD_FR1,UL_DL,1x10,MIMO1x1,64qam,-	            ULDL_dlSR70%		1	               4,2          	6,3	           8,4
#       5G_FDD_FR1,UL_DL,1x15,MIMO1x1,64qam,-	            ULDL_dlSR70%		1	               6,3	            9,3	           12,7
# 		5G_FDD_FR1,UL_DL,1x20,MIMO1x1,64qam,-	             ULDL_dlSR70%		1	               8,4	            12,7	       16,9
# DSS Cell 5G part:                                                             ulSR            50%	           60%	           70%
#                               Customer	                                              tput_DSS_p4      tput_DSS_p5	 tput_DSS_p6  	tputL1_ENDC#
#		5G_FDD_FR1,UL_DL,1x10,MIMO1x1,64qam,-	            ULDL_dlSR70%		1	           10,7	          12,7	         14,3	         30,7
#       5G_FDD_FR1,UL_DL,1x15,MIMO1x1,64qam,-	            ULDL_dlSR70%		1	           15,6     	  19,2           22,1            46,1
# 		5G_FDD_FR1,UL_DL,1x20,MIMO1x1,64qam,-	             ULDL_dlSR70%		1	           21,4	          25,3	         29,9	         61,5
#
#----------------------------------------------------------------------------------------------------------------------------------------------------

# DL pattern 100 % : 1011111111-1111111111-1011111111-1111111111-1011111111-1111111111-1011111111-1111111111
# DL pattern 70 % :  0011101110-0111101110-0011101110-0111101110-0011101110-0111101110-0011101110-0111101110

# T1 is for DL RATIO = 70/95 % and UL RATION = 70 %
# DL pattern and assigned_dl_maximum_share_to_nr are adapted
&{T1}                 feature2574=${true}      totalUE=1    loop=1      bandwidth=10MHz    technology=FDD    ul_throughput=30    dl_throughput=90
...                   timeDuration=3s    stopTraffic=${False}  shouldBeCheck=${False}     dirTraffic=ul    CellLTEId=1   CellNRId=2
...                   ULNbrOfPrb=35
# ...                   dl_allocated_normal_subframes=1011111111-1111111111-1011111111-1111111111-1011111111-1111111111-1011111111-1111111111
...                   dl_allocated_normal_subframes=0001100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
...                   ul_allocation_type=max_share
...                   dl_allocation_type=max_share
...                   Dl_MeasuredNgbrNnbrLoad=64   Ul_MeasuredNgbrNnbrLoad=64   dl_qos_load_meas_timer=200    ul_qos_load_meas_timer=200
#CSI tracking value to check for ssb position in l2 - settings for SSB Pos1
...                   SlotOffsetValue_1=0x00000001
...                   SlotOffsetValue_2=0x00000002
...                   SymbolValue_1=10
...                   SymbolValue_2=6
#CSI tracking value to check for ssb position in RRC Reconf - settings for SSB Pos1
...                   row1Value_1=10
...                   row1Value_2=10
...                   slots80Value_1=1
...                   slots80Value_2=2
#Adding 1745 specific params
...                    assigned_dl_minimum_share_to_nr=30
...                    assigned_dl_maximum_share_to_nr=70
...                    assigned_ul_minimum_share_to_nr=20
...                    assigned_ul_maximum_share_to_nr=70
...                    DssFastAllocValue=0x00000001
...                    SharingAlgoValue=01
...                    xpSharingAlgoValue=01000000
...                    ue_nr_capa_value=${ue_nr_capabilities_DSSPH3_10MHz}   ue_ue_eutra_nr_capa=${ue_ue_eutra_nr_capabilities_DSSPH3_10MHz}
#Adding 2574 specific params
...                    CatMinfo=${CatMinfo_10MHz}

&{T1_Counters_RATIO_70}   feature2574=${true}    totalUE=1    loop=1      bandwidth=10MHz    technology=FDD    ul_throughput=30    dl_throughput=90
...                   timeDuration=3s    stopTraffic=${False}  shouldBeCheck=${False}     dirTraffic=ul    CellLTEId=1   CellNRId=2
...                   ULNbrOfPrb=35
# ...                   dl_allocated_normal_subframes=1011111111-1111111111-1011111111-1111111111-1011111111-1111111111-1011111111-1111111111
...                   dl_allocated_normal_subframes=0001100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
...                   ul_allocation_type=max_share
...                   dl_allocation_type=max_share
...                   Dl_MeasuredNgbrNnbrLoad=64   Ul_MeasuredNgbrNnbrLoad=64   dl_qos_load_meas_timer=200    ul_qos_load_meas_timer=200
#CSI tracking value to check for ssb position in l2 - settings for SSB Pos1
...                   SlotOffsetValue_1=0x00000001
...                   SlotOffsetValue_2=0x00000002
...                   SymbolValue_1=10
...                   SymbolValue_2=6
#CSI tracking value to check for ssb position in RRC Reconf - settings for SSB Pos1
...                   row1Value_1=10
...                   row1Value_2=10
...                   slots80Value_1=1
...                   slots80Value_2=2
#Adding 1745 specific params
...                    assigned_dl_minimum_share_to_nr=30
...                    assigned_dl_maximum_share_to_nr=70
...                    assigned_ul_minimum_share_to_nr=20
...                    assigned_ul_maximum_share_to_nr=70
...                    DssFastAllocValue=0x00000001
...                    SharingAlgoValue=01
...                    xpSharingAlgoValue=01000000
...                    ue_nr_capa_value=${ue_nr_capabilities_DSSPH3_10MHz}   ue_ue_eutra_nr_capa=${ue_ue_eutra_nr_capabilities_DSSPH3_10MHz}
#Adding 2574 specific params
...                    CatMinfo=${CatMinfo_10MHz}

# T2 is for DL RATIO = 100 % and UL RATIO = 70 %
# DL pattern and assigned_dl_maximum_share_to_nr are adapted
&{T2}                 feature2574=${true}      totalUE=1    loop=1      bandwidth=10MHz    technology=FDD    ul_throughput=15    dl_throughput=40
...                   timeDuration=3s    stopTraffic=${False}  shouldBeCheck=${False}     dirTraffic=ul    CellLTEId=1   CellNRId=2
...                   ULNbrOfPrb=35
# ...                   ULNbrOfPrb=44
...                   dl_allocated_normal_subframes=1011111111-1111111111-1011111111-1111111111-1011111111-1111111111-1011111111-1111111111
...                   ul_allocation_type=max_share
...                   dl_allocation_type=max_share
...                   Dl_MeasuredNgbrNnbrLoad=6
#CSI tracking value to check for ssb position in l2 - settings for SSB Pos1
...                   SlotOffsetValue_1=0x00000001
...                   SlotOffsetValue_2=0x00000002
...                   SymbolValue_1=10
...                   SymbolValue_2=6
#CSI tracking value to check for ssb position in RRC Reconf - settings for SSB Pos1
...                   row1Value_1=10
...                   row1Value_2=10
...                   slots80Value_1=1
...                   slots80Value_2=2
...                    DssFastAllocValue=0x00000001
...                    SharingAlgoValue=0
...                    xpSharingAlgoValue=00000000
...                    assigned_dl_minimum_share_to_nr=30
...                    assigned_dl_maximum_share_to_nr=100
...                    assigned_ul_minimum_share_to_nr=20
...                    assigned_ul_maximum_share_to_nr=70
...                    ue_nr_capa_value=${ue_nr_capabilities_DSSPH3_10MHz}   ue_ue_eutra_nr_capa=${ue_ue_eutra_nr_capabilities_DSSPH3_10MHz}
#Adding 2574 specific params
...                    CatMinfo=${CatMinfo_10MHz_CatMData_CatMPaging_CatMSib1Br_mPBCH_DLRATIO_100}

# T3 is for 20MHz case
&{T3}                 feature2574=${true}      totalUE=1    loop=1      bandwidth=20MHz    technology=FDD    ul_throughput=50    dl_throughput=50
...                   timeDuration=3s    stopTraffic=${False}  shouldBeCheck=${False}     dirTraffic=ul    CellLTEId=1   CellNRId=2
...                   ULNbrOfPrb=70
# ...                   dl_allocated_normal_subframes=1011111111-1111111111-1011111111-1111111111-1011111111-1111111111-1011111111-1111111111
...                   dl_allocated_normal_subframes=0011100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
...                   ul_allocation_type=max_share
...                   dl_allocation_type=max_share
...                   Dl_MeasuredNgbrNnbrLoad=64   Ul_MeasuredNgbrNnbrLoad=64   dl_qos_load_meas_timer=200    ul_qos_load_meas_timer=200
#CSI tracking value to check for ssb position in l2 - settings for SSB Pos1
...                   SlotOffsetValue_1=0x00000001
...                   SlotOffsetValue_2=0x00000002
...                   SymbolValue_1=10
...                   SymbolValue_2=6
#CSI tracking value to check for ssb position in RRC Reconf - settings for SSB Pos1
...                   row1Value_1=10
...                   row1Value_2=10
...                   slots80Value_1=1
...                   slots80Value_2=2
...                    DssFastAllocValue=0x00000001
...                    SharingAlgoValue=0
...                    xpSharingAlgoValue=00000000
...                    assigned_dl_minimum_share_to_nr=30
...                    assigned_dl_maximum_share_to_nr=100
...                    assigned_ul_minimum_share_to_nr=20
...                    assigned_ul_maximum_share_to_nr=70
...                    ue_nr_capa_value=${ue_nr_capabilities_DSSPH3_20MHz}   ue_ue_eutra_nr_capa=${ue_ue_eutra_nr_capabilities_DSSPH3_20MHz}
#Adding 2574 specific params
...                    CatMinfo=${CatMinfo_20MHz}

&{T3_BLE}                 feature2574=${true}      totalUE=1    loop=1      bandwidth=10MHz    technology=FDD    ul_throughput=50    dl_throughput=50
...                   timeDuration=3s    stopTraffic=${False}  shouldBeCheck=${False}     dirTraffic=ul    CellLTEId=1   CellNRId=2
...                   startPrb=6    ULNbrOfPrb=70
# ...                   dl_allocated_normal_subframes=1011111111-1111111111-1011111111-1111111111-1011111111-1111111111-1011111111-1111111111
...                   dl_allocated_normal_subframes=0011100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
# ...                   dl_allocated_normal_subframes=0011101000-0111101110-0011101000-0111101110-0011101000-0111101110-0011101000-0111101110
...                   ul_allocation_type=max_share
...                   dl_allocation_type=max_share
...                   Dl_MeasuredNgbrNnbrLoad=64   Ul_MeasuredNgbrNnbrLoad=64   dl_qos_load_meas_timer=200    ul_qos_load_meas_timer=200
#CSI tracking value to check for ssb position in l2 - settings for SSB Pos1
...                   SlotOffsetValue_1=0x00000001
...                   SlotOffsetValue_2=0x00000002
...                   SymbolValue_1=10
...                   SymbolValue_2=6
#CSI tracking value to check for ssb position in RRC Reconf - settings for SSB Pos1
...                   row1Value_1=10
...                   row1Value_2=10
...                   slots80Value_1=1
...                   slots80Value_2=2
...                    DssFastAllocValue=0x00000001
...                    SharingAlgoValue=0
...                    xpSharingAlgoValue=00000000
...                    assigned_dl_minimum_share_to_nr=30
...                    assigned_dl_maximum_share_to_nr=100
...                    assigned_ul_minimum_share_to_nr=20
...                    assigned_ul_maximum_share_to_nr=70
...                    ue_nr_capa_value=${ue_nr_capabilities_DSSPH3_20MHz}   ue_ue_eutra_nr_capa=${ue_ue_eutra_nr_capabilities_DSSPH3_20MHz}
#Adding 2574 specific params
...                    CatMinfo=${CatMinfo_20MHz_BLE_3PRB}

&{T3_BHE}                 feature2574=${true}      totalUE=1    loop=1      bandwidth=20MHz    technology=FDD    ul_throughput=50    dl_throughput=50
...                   timeDuration=3s    stopTraffic=${False}  shouldBeCheck=${False}     dirTraffic=ul    CellLTEId=1   CellNRId=2
...                   startPrb=6    ULNbrOfPrb=70
...                   dl_allocated_normal_subframes=1011111111-1111111111-1011111111-1111111111-1011111111-1111111111-1011111111-1111111111
...                   ul_allocation_type=max_share
...                   dl_allocation_type=max_share
...                   Dl_MeasuredNgbrNnbrLoad=64   Ul_MeasuredNgbrNnbrLoad=64   dl_qos_load_meas_timer=200    ul_qos_load_meas_timer=200
#CSI tracking value to check for ssb position in l2 - settings for SSB Pos1
...                   SlotOffsetValue_1=0x00000001
...                   SlotOffsetValue_2=0x00000002
...                   SymbolValue_1=10
...                   SymbolValue_2=6
#CSI tracking value to check for ssb position in RRC Reconf - settings for SSB Pos1
...                   row1Value_1=10
...                   row1Value_2=10
...                   slots80Value_1=1
...                   slots80Value_2=2
...                    DssFastAllocValue=0x00000001
...                    SharingAlgoValue=0
...                    xpSharingAlgoValue=00000000
...                    assigned_dl_minimum_share_to_nr=30
...                    assigned_dl_maximum_share_to_nr=100
...                    assigned_ul_minimum_share_to_nr=20
...                    assigned_ul_maximum_share_to_nr=70
...                    ue_nr_capa_value=${ue_nr_capabilities_DSSPH3_20MHz}   ue_ue_eutra_nr_capa=${ue_ue_eutra_nr_capabilities_DSSPH3_20MHz}
#Adding 2574 specific params
...                    CatMinfo=${CatMinfo_20MHz_BHE_3PRB}

# T4 is for 15MHz case
&{T4}                 feature2574=${true}      totalUE=1    loop=1      bandwidth=15MHz    technology=FDD    ul_throughput=15    dl_throughput=40
...                   timeDuration=3s    stopTraffic=${False}  shouldBeCheck=${False}     dirTraffic=ul    CellLTEId=1   CellNRId=2
...                   ULNbrOfPrb=52
...                   dl_allocated_normal_subframes=0001100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
...                   ul_allocation_type=max_share
...                   dl_allocation_type=max_share
...                   Dl_MeasuredNgbrNnbrLoad=64   Ul_MeasuredNgbrNnbrLoad=64   dl_qos_load_meas_timer=200    ul_qos_load_meas_timer=200
#CSI tracking value to check for ssb position in l2 - settings for SSB Pos1
...                   SlotOffsetValue_1=0x00000001
...                   SlotOffsetValue_2=0x00000002
...                   SymbolValue_1=10
...                   SymbolValue_2=6
#CSI tracking value to check for ssb position in RRC Reconf - settings for SSB Pos1
...                   row1Value_1=10
...                   row1Value_2=10
...                   slots80Value_1=1
...                   slots80Value_2=2
...                    DssFastAllocValue=0x00000001
...                    SharingAlgoValue=0
...                    xpSharingAlgoValue=00000000
...                    assigned_dl_minimum_share_to_nr=30
...                    assigned_dl_maximum_share_to_nr=100
...                    assigned_ul_minimum_share_to_nr=20
...                    assigned_ul_maximum_share_to_nr=70
...                    ue_nr_capa_value=${ue_nr_capabilities_DSSPH3_15MHz}   ue_ue_eutra_nr_capa=${ue_ue_eutra_nr_capabilities_DSSPH3_15MHz}
#Adding 2574 specific params
...                    CatMinfo=${CatMinfo_15MHz}

# T5 is for 20MHz case
&{T5}                 feature2574=${true}      totalUE=1    loop=1      bandwidth=20MHz    technology=FDD    ul_throughput=15    dl_throughput=40
...                   timeDuration=3s    stopTraffic=${False}  shouldBeCheck=${False}     dirTraffic=ul    CellLTEId=1   CellNRId=2
...                   ULNbrOfPrb=70
...                   dl_allocated_normal_subframes=1011111111-1111111111-1011111111-1111111111-1011111111-1111111111-1011111111-1111111111
...                   ul_allocation_type=max_share
...                   dl_allocation_type=max_share
...                   Dl_MeasuredNgbrNnbrLoad=64   Ul_MeasuredNgbrNnbrLoad=64   dl_qos_load_meas_timer=200    ul_qos_load_meas_timer=200
#CSI tracking value to check for ssb position in l2 - settings for SSB Pos1
...                   SlotOffsetValue_1=0x00000001
...                   SlotOffsetValue_2=0x00000002
...                   SymbolValue_1=10
...                   SymbolValue_2=6
#CSI tracking value to check for ssb position in RRC Reconf - settings for SSB Pos1
...                   row1Value_1=10
...                   row1Value_2=10
...                   slots80Value_1=1
...                   slots80Value_2=2
...                    DssFastAllocValue=0x00000001
...                    SharingAlgoValue=0
...                    xpSharingAlgoValue=00000000
...                    assigned_dl_minimum_share_to_nr=30
...                    assigned_dl_maximum_share_to_nr=100
...                    assigned_ul_minimum_share_to_nr=20
...                    assigned_ul_maximum_share_to_nr=70
...                    ue_nr_capa_value=${ue_nr_capabilities_DSSPH3_20MHz}   ue_ue_eutra_nr_capa=${ue_ue_eutra_nr_capabilities_DSSPH3_20MHz}
#Adding 2574 specific params
...                    CatMinfo=${CatMinfo_20MHz_CatMData_CatMPaging_CatMSib1Br_mPBCH_DLRATIO_100}


# Test parameters for DSS
&{CatMinfo_10MHz}           repeated_mpbch=false      start_symbol=3     catm_dl_data_index=3      paging_starting_index=4
...        num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=2
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-5,6+0,0,4-40-44,7+0,2,4-40-44,7+0,4,4-40-14,6+0,6,4-40-44,7
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_C_sib1br=
...        prb_area_D_sib1br=
...        prb_area_catm_paging=0001000100-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000

&{CatMinfo_15MHz}           repeated_mpbch=false      start_symbol=3     catm_dl_data_index=3      paging_starting_index=4
...        num_of_catm_paging_records=4      sib1br_starting_index=8      num_of_catm_sib1br_records=4
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,0-1-70,6+0,1,0-640-46,7+0,1,1-640-46,7+0,1,2-640-46,7
...        prb_area_reservation_list_2=+0,1,3-640-46,7+0,0,4-40-46,7+0,2,4-40-58,7+0,4,4-40-70,7+0,6,4-40-9,6
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_C_sib1br=0000000000-0000000000-0000000000-0000000000-0000100000-0000000000-0000000000-0000000000
...        prb_area_D_sib1br=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000100000-0000000000
...        prb_area_catm_paging=0000000000-1111000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000

&{CatMinfo_10MHz_CatMData_Slot_6_period_1}       repeated_mpbch=false      start_symbol=3     catm_dl_data_index=3      paging_starting_index=4
...        num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=2
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-5,6+0,0,4-40-44,7+0,2,4-40-44,7+0,4,4-40-14,6+0,6,4-40-44,7
...        prb_area_A_sib1br=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_C_sib1br=
...        prb_area_D_sib1br=
...        prb_area_catm_paging=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000

# only CatM data defined with StartPRB=5, NbrOfPrb=6 and period=1
&{CatMinfo_10MHz_CatMDataOnly_Slot_6_period_1}       repeated_mpbch=false      start_symbol=3     catm_dl_data_index=3      paging_starting_index=4
...        num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=2
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-5,6+0,0,4-40-44,7+0,2,4-40-44,7+0,4,4-40-14,6+0,6,4-40-44,7
...        prb_area_A_sib1br=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_C_sib1br=
...        prb_area_D_sib1br=
...        prb_area_catm_paging=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000

# only CatM data and CatM paging
&{CatMinfo_10MHz_CatMData_CatMPaging_Slot_6_period_1}       repeated_mpbch=false    start_symbol=3    catm_dl_data_index=3   paging_starting_index=4
...        num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=2
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-5,6+0,0,4-40-44,7+0,2,4-40-44,7+0,4,4-40-14,6+0,6,4-40-44,7
...        prb_area_A_sib1br=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_C_sib1br=
...        prb_area_D_sib1br=
...        prb_area_catm_paging=0000100000-0000000000-0000100000-0000000000-0000100000-0000000000-0000100000-0000000000

# only CatM data and CatM paging => 20MHz case
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":0,"subframeNumber":0,"extensions":{}},"periodicity":1,"prbRangeList":[{"startPrb":95,
#   "amountOfPrbs":7}]},      CATM data
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":1,"subframeNumber":0,"extensions":{}},"periodicity":640,"prbRangeList":
#   [{"startPrb":95,"amountOfPrbs":7}]},    CatM paging
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":1,"subframeNumber":1,"extensions":{}},"periodicity":640,"prbRangeList":
#   [{"startPrb":95,"amountOfPrbs":7}]},
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":1,"subframeNumber":2,"extensions":{}},"periodicity":640,"prbRangeList":
#   [{"startPrb":95,"amountOfPrbs":7}]},
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":1,"subframeNumber":3,"extensions":{}},"periodicity":640,"prbRangeList":
#   [{"startPrb":95,"amountOfPrbs":7}]},
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":0,"subframeNumber":4,"extensions":{}},"periodicity":80"prbRangeList":
#   [{"startPrb":89,"amountOfPrbs":7}]},       CatM Sib1Br
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":2,"subframeNumber":4,"extensions":{}},"periodicity":80,"prbRangeList":
#   [{"startPrb":11,"amountOfPrbs":6}]},
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":4,"subframeNumber":4, "extensions":{}},"periodicity":80,"prbRangeList":
#   [{"startPrb":23,"amountOfPrbs":6}]},
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":6,"subframeNumber":4,"extensions":{}},"periodicity":80,"prbRangeList":
#   [{"startPrb":59,"amountOfPrbs":7}]}]},

# 10MHz case
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":0,"subframeNumber":0,"extensions":{}},"periodicity":1,"prbRangeList":
# [{"startPrb":8,"amountOfPrbs":6}]},  CatM data
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":1,"subframeNumber":0,"extensions":{}},"periodicity":640,"prbRangeList":
#   [{"startPrb":44,"amountOfPrbs":7}]},  CatM paging
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":1,"subframeNumber":1,"extensions":{}},"periodicity":640,"prbRangeList":
#   [{"startPrb":44,"amountOfPrbs":7}]},
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":1,"subframeNumber":2,"extensions":{}},"periodicity":640,"prbRangeList":
#   [{"startPrb":44,"amountOfPrbs":7}]},
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":1,"subframeNumber":3,"extensions":{}},"periodicity":640,"prbRangeList":
#   [{"startPrb":44,"amountOfPrbs":7}]},
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":0,"subframeNumber":4,"extensions":{}},"periodicity":40,"prbRangeList":
#   [{"startPrb":14,"amountOfPrbs":6}]},   catM Sib1Br
# {"patternStartTime":{"hyperframeNumber":0,"systemFrameNumber":2,"subframeNumber":4,"extensions":{}},"periodicity":40,"prbRangeList":
#   [{"startPrb":44,"amountOfPrbs":7}]}]

# slot 0, 5 and 9 are forbiden
&{CatMinfo_10MHz_CatMData_CatMPaging_CatMSib1Br_DLRATIO_70}   repeated_mpbch=false    start_symbol=3   catm_dl_data_index=3   paging_starting_index=4
...        num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=2
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-8,6+0,1,1-40-44,7+0,1,2-40-44,7+0,0,4-40-14,6+0,2,4-40-44,7
...        prb_area_catm_paging=0000000000-0110000000-0000000000-0000000000-0000000000-0110000000-0000000000-0000000000
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000100000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000100000-0000000000
...        prb_area_C_sib1br=
...        prb_area_D_sib1br=

&{CatMinfo_10MHz_CatMData_CatMPaging_CatMSib1Br_DLRATIO_70_OLD}   repeated_mpbch=false    start_symbol=3   catm_dl_data_index=3
...        paging_starting_index=4
...        num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=2
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-5,6+0,1,1-40-44,7+0,1,2-40-44,7+0,0,4-40-14,6+0,2,4-40-44,7
...        prb_area_catm_paging=0000000000-0110000000-0000000000-0000000000-0000000000-0110000000-0000000000-0000000000
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000100000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000100000-0000000000
...        prb_area_C_sib1br=
...        prb_area_D_sib1br=

&{CatMinfo_10MHz_CatMData_CatMPaging_CatMSib1Br_DLRATIO_70_2}  repeated_mpbch=false   start_symbol=3   catm_dl_data_index=3   paging_starting_index=4
...        num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=2
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-44,7+0,1,1-40-14,6+0,1,2-40-14,6+0,0,4-40-14,6+0,2,4-40-44,7
...        prb_area_catm_paging=0000000000-0110000000-0000000000-0000000000-0000000000-0110000000-0000000000-0000000000
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000100000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000100000-0000000000
...        prb_area_C_sib1br=
...        prb_area_D_sib1br=

# slot 0, 5 and 9 are forbiden
&{CatMinfo_10MHz_CatMData_CatMSib1Br_DLRATIO_70}   repeated_mpbch=false    start_symbol=3   catm_dl_data_index=3   paging_starting_index=4
...        num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=2
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-5,6+0,1,1-40-44,7+0,1,2-40-44,7+0,0,4-40-14,6+0,2,4-40-44,7
...        prb_area_catm_paging=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000100000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000100000-0000000000
...        prb_area_C_sib1br=
...        prb_area_D_sib1br=

# with slot 0, 5 and 9
# CRM client shall send requests for:
# DL & UL data -- each subframe for 1NB (6 PRBs)
# PBCH  - every 10 ms in subframe 9 and 0 for 6 central PRBs
#         in all slots 0 and 9, for PRB [23..29] 10Mz, PRB [36..42] 15Mhz and PRB[50..56] 20Mhz , symbols [3¡?13].
# SIB1-BR  -
#       10 MHz -- 2 requests every 40 ms in subframe 4 for each of 2-element NBs set based on PCI
#       15 & 20MHz -- 4 requests every 80 ms in subframe 4 for each of 4-element NBs set based on PCI
# Paging -- every page opportunity (typical values is 80,160, 320 640ms), set of consecutive
#       subframes starting in subframe 9. Request shall cover number of page repetition as well as DL invalid
#       subframes which are skipped by CAT-M paging. PRBs are defined by rule based on PCI
&{CatMinfo_10MHz_CatMData_CatMPaging_CatMSib1Br_mPBCH_DLRATIO_100}   repeated_mpbch=true    start_symbol=3   catm_dl_data_index=3
...        paging_starting_index=4    num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=2
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-8,6+0,1,1-40-44,7+0,1,2-40-44,7+0,0,4-40-14,6+0,2,4-40-44,7
...        prb_area_catm_paging=0000000001-1000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000100000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000100000-0000000000
...        prb_area_C_sib1br=
...        prb_area_D_sib1br=

&{CatMinfo_10MHz_CatMData_CatMPaging_CatMSib1Br_mPBCH_DLRATIO_100_OLD}   repeated_mpbch=true    start_symbol=3   catm_dl_data_index=3
...        paging_starting_index=4    num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=2
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-5,6+0,1,1-40-44,7+0,1,2-40-44,7+0,0,4-40-14,6+0,2,4-40-44,7
...        prb_area_catm_paging=0000000001-1000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000100000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000100000-0000000000
...        prb_area_C_sib1br=
...        prb_area_D_sib1br=

&{CatMinfo_15MHz_CatMData_CatMPaging_CatMSib1Br_mPBCH_DLRATIO_100}           repeated_mpbch=true      start_symbol=3     catm_dl_data_index=3
...        paging_starting_index=4      num_of_catm_paging_records=4      sib1br_starting_index=8      num_of_catm_sib1br_records=4
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,0-1-70,7+0,1,0-640-15,6+0,1,1-640-15,6+0,1,2-640-15,6
...        prb_area_reservation_list_2=+0,1,3-640-15,6+0,0,4-80-64,7+0,2,4-80-64,7+0,4,4-80-64,7+0,6,4-80-64,7
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_C_sib1br=0000000000-0000000000-0000000000-0000000000-0000100000-0000000000-0000000000-0000000000
...        prb_area_D_sib1br=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000100000-0000000000
...        prb_area_catm_paging=0000000000-1111000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000


&{CatMinfo_20MHz_CatMData_CatMPaging_CatMSib1Br_mPBCH_DLRATIO_100}   repeated_mpbch=true    start_symbol=3   catm_dl_data_index=3
...        paging_starting_index=4    num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=4
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-8,6+0,0,4-40-44,7+0,2,4-40-44,7+0,4,4-40-44,7+0,6,4-40-44,7
...        prb_area_reservation_list_2=+0,6,3-40-44,7+0,6,7-40-44,7
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_C_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_D_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_catm_paging=0001000100-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000

&{CatMinfo_20MHz_CatMData_CatMPaging_CatMSib1Br_mPBCH_DLRATIO_100_CatMData_HighEdge}   repeated_mpbch=true    start_symbol=3   catm_dl_data_index=3
...        paging_starting_index=4    num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=4
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-95,7+0,0,4-40-95,7+0,2,4-40-95,7+0,4,4-40-89,7+0,6,4-40-11,6
...        prb_area_reservation_list_2=+0,6,3-40-23,6+0,6,7-40-59,7
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_C_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_D_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_catm_paging=0001000100-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000

&{CatMinfo_20MHz_BLE_CatMData_CatMPaging_CatMSib1Br_mPBCH_DLRATIO_100_CatMData_HighEdge}   repeated_mpbch=true    start_symbol=3
...        catm_dl_data_index=3    paging_starting_index=4    num_of_catm_paging_records=2      sib1br_starting_index=6
...        num_of_catm_sib1br_records=4
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-95,7+0,0,4-40-95,7+0,2,4-40-95,7+0,4,4-40-89,7+0,6,4-40-17,6
...        prb_area_reservation_list_2=+0,6,3-40-23,6+0,6,7-40-59,7
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_C_sib1br=0000000000-0000000000-0000000000-0000000000-0000100000-0000000000-0000000000-0000000000
...        prb_area_D_sib1br=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000100000-0000000000
...        prb_area_catm_paging=0000000001-1000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000

&{CatMinfo_20MHz_CatMData_CatMPaging_CatMSib1Br_mPBCH_DLRATIO_100_CatMData_LowEdge}   repeated_mpbch=true    start_symbol=3   catm_dl_data_index=3
...        paging_starting_index=4    num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=4
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-17,6+0,0,4-40-95,7+0,2,4-40-95,7+0,4,4-40-89,7+0,6,4-40-11,6
...        prb_area_reservation_list_2=+0,6,3-40-23,6+0,6,7-40-59,7
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_C_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_D_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_catm_paging=0001000100-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000

&{CatMinfo_20MHz}           repeated_mpbch=false      start_symbol=3     catm_dl_data_index=3      paging_starting_index=4
...        num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=4
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-5,6+0,0,4-40-44,7+0,2,4-40-44,7+0,4,4-40-44,7+0,6,4-40-44,7
...        prb_area_reservation_list_2=+0,6,3-40-44,7+0,6,7-40-44,7
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_C_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_D_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_catm_paging=0001000100-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000

&{CatMinfo_20MHz_BLE_3PRB}           repeated_mpbch=false      start_symbol=3     catm_dl_data_index=3      paging_starting_index=4
...        num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=4
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-8,6+0,0,4-40-44,7+0,2,4-40-44,7+0,4,4-40-44,7+0,6,4-40-44,7
...        prb_area_reservation_list_2=+0,6,3-40-44,7+0,6,7-40-44,7
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_C_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_D_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_catm_paging=0001000100-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000

&{CatMinfo_20MHz_CatMData_Slot_6_period_10}       repeated_mpbch=false      start_symbol=3     catm_dl_data_index=3      paging_starting_index=4
...        num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=4
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-5,6+0,0,4-40-44,7+0,2,4-40-44,7+0,4,4-40-44,7+0,6,4-40-44,7
...        prb_area_reservation_list_2=+0,6,3-40-44,7+0,6,7-40-44,7
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_C_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_D_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_catm_paging=0001000100-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000

&{CatMinfo_20MHz_BHE_3PRB}           repeated_mpbch=false      start_symbol=3     catm_dl_data_index=3      paging_starting_index=4
...        num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=4
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,3-1-5,6+0,0,4-40-41,7+0,2,4-40-41,7+0,4,4-40-41,7+0,6,4-40-41,7
...        prb_area_reservation_list_2=+0,6,4-40-44,7+0,6,4-40-44,7
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_C_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_D_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_catm_paging=0001000100-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000

&{CatMinfo_20MHz_BHE_3PRB_dl_ratio_100}           repeated_mpbch=true      start_symbol=3     catm_dl_data_index=3      paging_starting_index=4
...        num_of_catm_paging_records=2      sib1br_starting_index=6      num_of_catm_sib1br_records=4
...        prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none+0,0,6-1-92,7+0,0,4-40-92,7+0,2,4-40-92,7+0,4,4-40-89,7+0,6,4-40-11,6
...        prb_area_reservation_list_2=+0,6,3-40-23,6+0,6,7-40-59,7
...        prb_area_A_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_B_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_C_sib1br=0000100000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_D_sib1br=0000000000-0000000000-0000100000-0000000000-0000000000-0000000000-0000000000-0000000000
...        prb_area_catm_paging=0001000100-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000

&{Context}            cellDepType=SA+NSA    eNBId=1    eNBId_cellid=1   gNBId=2   gNBId_cellid=1   UeId1=1    UeId2=2    UeId3=3   DSS_Phase=Phase-3
...                   lte_dlNrArfcn=133307      lte_ulNrArfcn=68771    WtsWaitingPattern=Received DSS DL Resource Area Allocation Response
...                   nrCellType=2DL2UL    superfast_allocation=off

&{Context_2}          cellDepType=SA+NSA    eNBId=1    eNBId_cellid=1   gNBId=2   gNBId_cellid=1   UeId1=1    UeId2=2    UeId3=3   DSS_Phase=Phase-3
...                   lte_dlNrArfcn=133328      lte_ulNrArfcn=68792    WtsWaitingPattern=Received DSS DL Resource Area Allocation Response
...                   nrCellType=2DL2UL    superfast_allocation=off

&{Context_3}          cellDepType=SA+NSA    eNBId=1    eNBId_cellid=1   gNBId=2   gNBId_cellid=1   UeId1=1    UeId2=2    UeId3=3   DSS_Phase=Phase-3
...                   lte_dlNrArfcn=133333      lte_ulNrArfcn=68797    WtsWaitingPattern=Received DSS DL Resource Area Allocation Response
...                   nrCellType=2DL2UL    superfast_allocation=off

&{Context_Cell2}      cellDepType=SA+NSA    eNBId=1   eNBId_cellid=2    gNBId=2    gNBId_cellid=2  UeId1=1    UeId2=2    UeId3=3   DSS_Phase=Phase-3
...                   lte_dlNrArfcn=133307      lte_ulNrArfcn=68771    WtsWaitingPattern=Received DSS DL Resource Area Allocation Response
...                   nrCellType=2DL2UL    superfast_allocation=off

# Test parameters for DSS [10MHz]
&{TestDSS10Mhz}           seq=${T1}       wtsXmlFile=${wtsXml10MHz}     scfFile=${Scf10MHzDSS}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParamcprt679_A_0x590050=0
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff    RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS10Mhz_Pos6}      seq=${T1}       wtsXmlFile=${wtsXml10MHz}     scfFile=${Scf10MHzDSS_2574_Pos6}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParamcprt679_A_0x590050=0
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff    RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS10Mhz_2574_A3_Counters}       seq=${T1_Counters_RATIO_70}    wtsXmlFile=${wtsXml10MHz}    scfFile=${Scf10MHzDSS_2574}   Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParamcprt679_A_0x590050=0
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff    RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS10Mhz_2574_A3}       seq=${T1}       wtsXmlFile=${wtsXml10MHz}     scfFile=${Scf10MHzDSS_2574}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParamcprt679_A_0x590050=0
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff    RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS10Mhz_2574_A5}       seq=${T2}       wtsXmlFile=${wtsXml10MHz}     scfFile=${Scf10MHzDSS_2574}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS20Mhz}           seq=${T5}       wtsXmlFile=${wtsXml20MHz}     scfFile=${Scf20MHzDSS}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS20Mhz_2574_A5}       seq=${T5}       wtsXmlFile=${wtsXml20MHz}     scfFile=${Scf20MHzDSS_2574}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS15Mhz}           seq=${T4}       wtsXmlFile=${wtsXml15MHz}     scfFile=${Scf15MHzDSS}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS15Mhz_2574}       seq=${T4}       wtsXmlFile=${wtsXml15MHz}     scfFile=${Scf15MHzDSS_2574}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS20Mhz_2574_A}       seq=${T3}       wtsXmlFile=${wtsXml20MHz}     scfFile=${Scf20MHzDSS_2574}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParamcprt679_A_0x590050=0
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff    RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS20Mhz_2574_BLE}       seq=${T3_BLE}       wtsXmlFile=${wtsXml20MHz}     scfFile=${Scf20MHzDSS_2574_BLE}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS20Mhz_2574_BHE}       seq=${T3_BHE}       wtsXmlFile=${wtsXml20MHz}     scfFile=${Scf20MHzDSS_2574_BHE}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS10Mhz_BLE}       seq=${T2}       wtsXmlFile=${wtsXml10MHz_BLE}     scfFile=${Scf10MHzDSS_BLE}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1
# config for 10MHz BLE=1 and BHE=3
&{TestDSS10Mhz_BLE_2}     seq=${T2}       wtsXmlFile=${wtsXml10MHz_BLE_2}   scfFile=${Scf10MHzDSS_BLE_2}       Context=${Context_2}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1
# config for 10MHz BLE=2 and BHE=3
&{TestDSS10Mhz_BLE_3}     seq=${T2}       wtsXmlFile=${wtsXml10MHz_BLE_3}   scfFile=${Scf10MHzDSS_BLE_3}       Context=${Context_3}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS15Mhz_BLE}       seq=${T4}       wtsXmlFile=${wtsXml15MHz_BLE}     scfFile=${Scf15MHzDSS_BLE}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS15Mhz_NO_BL}     seq=${T4}       wtsXmlFile=${wtsXml15MHz_NO_BL}   scfFile=${Scf15MHzDSS_NO_BL}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS20Mhz_BLE}       seq=${T5}       wtsXmlFile=${wtsXml20MHz_BLE}     scfFile=${Scf20MHzDSS_BLE}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS20Mhz_BLE_Cell2}       seq=${T5}       wtsXmlFile=${wtsXml20MHz_BLE}     scfFile=${Scf20MHzDSS_BLE_Cell2}     Context=${Context_Cell2}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS20Mhz_NO_BL}     seq=${T5}       wtsXmlFile=${wtsXml20MHz_NO_BL}   scfFile=${Scf20MHzDSS_NO_BL}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS20Mhz_NO_BL_Cell2}     seq=${T5}       wtsXmlFile=${wtsXml20MHz_NO_BL}   scfFile=${Scf20MHzDSS_NO_BL}       Context=${Context_Cell2}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

&{TestDSS10Mhz_2574_A5_BLE}     seq=${T2}       wtsXmlFile=${wtsXml10MHz}     scfFile=${Scf10MHzDSS_2574_BLE}       Context=${Context}
...                       rdEnableFDMPdschDmrs_0x5801a6=1     RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6=1
...                       RadParam_rdSupportedUlMCS_0x580010=0x1fffffff     RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7=1

*** Keywords ***
# robocop: off=unused-argument
# robocop: off=possible-variable-overwriting

#----------------------------------------------------------------------------------------------------------------------------------------------------
#         Other Procedures
#----------------------------------------------------------------------------------------------------------------------------------------------------

get cellDepType from SCF
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${LOG_PATH}/SCF.xml
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${cellDepType}	 scf.get_value_from_scf   p_name=cellDepType
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    [return]     ${cellDepType}

set UEId in Context
    [Arguments]           ${testParam}     ${UeId1}=1      ${UeId2}=2     ${UeId3}=3
    BuiltIn.log       bandwidth is ${testParam.seq.bandwidth}
    ${testParam.Context.UeId1}     set Variable    ${UeId1}
    ${testParam.Context.UeId2}     set Variable    ${UeId2}
    ${testParam.Context.UeId3}     set Variable    ${UeId3}


update eNBId and gNBId In Context
    [Arguments]           ${testParam}     ${eNBId}=1     ${gNBId}=2
    ${testParam.seq.eNBId}        set Variable     ${eNBId}
    ${testParam.seq.gNBId}        set Variable     ${gNBId}
    ${testParam.Context.eNBId}    set Variable     ${eNBId}
    ${testParam.Context.gNBId}    set Variable     ${gNBId}
    # 1745 is tested only with SA
    run Keyword if   '${testParam.Context.cellDepType}' == 'SA+NSA'  DSS_Kw_TestSetup.set UEId in Context    ${testParam}    1    2    3

Backup Iphy AirphoneConfig
    [Documentation]                 Backup current iphy file on AP

    # ${alias}                        SSH Connect                          ${AP_DU.sys[0].M}
    ${alias}             connect.Connect to Airphone Common Unit

    ${file}                         SSH Cmd                              command=readlink -f /rom/simmode/iphy.xml
    ...                             alias=${alias}
    Dated log                       On Airphone, backing up file ${file}
    ${file}                         Strip String                         ${file}
    ${iphy_backup_exists}=          SSH Cmd                              command=test -f ${file}.backup && echo -n "okman" || echo -n "noway"
    ...                             alias=${alias}
    ${iphy_file_exist}              SSH Cmd                              command=test -f ${file} && echo -n "okman" || echo -n "noway"
    ...                             alias=${alias}
    run keyword if                  '${iphy_file_exist}'=='okman' and '${iphy_backup_exists}'!='okman'
    ...                             SSH Cmd                              command=cp ${file} ${file}.backup     alias=${alias}
    Dated log                       On Airphone, ${file} is backed up

Dedicated Set Context_Cell IPHY
    [Arguments]          ${testParam}
    DSS_Kw_TestSetup.Backup Iphy AirphoneConfig
    #set cell
    DedicatedXmlConfig.startSession iphy
    DedicatedXmlConfig.dedicated setListEltText        //RE[1]//cell                   ${testParam.Context.gNBId}.1
    DedicatedXmlConfig.setListEltText                  //RE[2]//cell                   ${testParam.Context.gNBId}.2
    # csamson : to improve later => only for 2TDD+2FDD
    DedicatedXmlConfig.setListEltText                  //RE[3]//cell                   ${testParam.Context.gNBId}.3
    DedicatedXmlConfig.stopSession iphy


Set Context_Cell IPHY
    [Arguments]          ${testParam}
    DSS_Kw_TestSetup.Backup Iphy AirphoneConfig
    WtsXmlConfig.startSession           file=iphy
    #set cell
    # WtsXmlConfig.setListEltText         //cell                          ${testParam.Context.gNBId}.1
    WtsXmlConfig.setListEltText         //RE[1]//cell                   ${testParam.Context.gNBId}.1
    WtsXmlConfig.setListEltText         //RE[2]//cell                   ${testParam.Context.gNBId}.2
    # csamson : to improve later => only for 2TDD+2FDD
    WtsXmlConfig.setListEltText         //RE[3]//cell                   ${testParam.Context.gNBId}.3
    WtsXmlConfig.stopSession            file=iphy

Dedicated Set Context_AP IPHY
    [Arguments]          ${testParam}    ${cell_id}=1
    DedicatedXmlConfig.startSession iphy
    #set GSCN
    # update only gscn for cell1
    DedicatedXmlConfig.dedicated setListEltText         //RE[${cell_id}]//GSCN             ${testParam.scfFile.nrcell.gscn}
    DedicatedXmlConfig.stopSession iphy

Test Setup DSS
    [Arguments]         ${testParam}     ${gnb_scf}
    # iPHY gscn update depending of chBwDl
    Dated Log      iPHY gscn update with ${testParam.scfFile.nrcell.gscn} : chBwDl=${testParam.scfFile.nrcellfdd.chBwDl}
    DSS_Kw_TestSetup.Dedicated Set Context_Cell IPHY    ${testParam}
    # iPHY Cell update
    Dated Log      iPHY Cell update with ${testParam.Context.gNBId}.1
    DSS_Kw_TestSetup.Dedicated Set Context_AP IPHY    ${testParam}    ${fdd_cell_1}
    return from keyword If     '${UPDATE_SCF}'=='0'
    DSS_Kw_TestSetup.Set SCF DSS   ${testParam}    ${gnb_scf}
    DSS_Kw_TestSetup.Set SCF NRCELL WA for DSS   ${testParam}     ${gnb_scf}
    nps_tarf_tools.log_to_console_with_time_prefix   Scf update for DSS specific ${testParam.scfFile.nrcellfdd.chBwDl} parameters   level=INFO
    # scf for DSS specific parameters (parameters not BW dependant )
    DSS_Kw_TestSetup.Set SCF NRDBR         ${testParam}    ${gnb_scf}
    DSS_Kw_TestSetup.Set SCF NRDDSSLTE     ${testParam}    ${gnb_scf}
    # XIPIF already present in SCF during the TL preparation
    DSS_Kw_TestSetup.Set SCF XPIF          ${testParam}    ${gnb_scf}
    # scf for DSS specific parameters (parameters BW dependant )
    DSS_Kw_TestSetup.Set SCF     ${testParam}    ${gnb_scf}

Test Setup DSS Cell2
    [Arguments]         ${testParam}     ${gnb_scf}
    # iPHY gscn update depending of chBwDl
    Dated Log      iPHY gscn update with ${testParam.scfFile.nrcell.gscn} : chBwDl=${testParam.scfFile.nrcellfdd.chBwDl}
    DSS_Kw_TestSetup.Dedicated Set Context_Cell IPHY    ${testParam}
    # iPHY Cell update
    Dated Log      iPHY Cell update with ${testParam.Context.gNBId}.1
    DSS_Kw_TestSetup.Dedicated Set Context_AP IPHY    ${testParam}     ${fdd_cell_2}
    return from keyword If     '${UPDATE_SCF}'=='0'
    DSS_Kw_TestSetup.Set SCF DSS Cell2   ${testParam}    ${gnb_scf}
    DSS_Kw_TestSetup.Set SCF NRCELL WA for DSS Cell2   ${testParam}     ${gnb_scf}
    nps_tarf_tools.log_to_console_with_time_prefix   Scf update for DSS specific ${testParam.scfFile.nrcellfdd.chBwDl} parameters   level=INFO
    # scf for DSS specific parameters (parameters not BW dependant )
    # DSS_Kw_TestSetup.Set SCF NRDBR         ${testParam}    ${gnb_scf}
    DSS_Kw_TestSetup.Set SCF NRDDSSLTE Cell2     ${testParam}    ${gnb_scf}
    # XIPIF already present in SCF during the TL preparation
    # DSS_Kw_TestSetup.Set SCF XPIF          ${testParam}    ${gnb_scf}
    # scf for DSS specific parameters (parameters BW dependant )
    DSS_Kw_TestSetup.Set SCF Cell2     ${testParam}    ${gnb_scf}

Set SCF DSS
    [Arguments]          ${testParam}    ${gnb_scf}
    @{distName_NRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}             ${p_name}                   ${value}        IN
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    nbrOfBlankedPRBsHighEdgeDL        0
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    nbrOfBlankedPRBsHighEdgeUL        0
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    nbrOfBlankedPRBsLowEdgeDL         0
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    nbrOfBlankedPRBsLowEdgeUL         0
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    actLteNrDssFastAlloc   ${testParam.scfFile.nrdsslte.actLteNrDssFastAlloc}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    actRateMatchedCsiIm    ${testParam.scfFile.nrdsslte.actRateMatchedCsiIm}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    actLteNrDssLteCatM     ${testParam.scfFile.nrdsslte.actLteNrDssLteCatM}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    actDssMsg3Enh          ${testParam.scfFile.nrdsslte.actDssMsg3Enh}
    Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    &{lteNrDssDlRatio}   Create Dictionary   dlResourceSharingAlgo=${testParam.scfFile.lteNrDssDlRatio.dlResourceSharingAlgo}
    ...                                     maxNrDssRatio=${testParam.scfFile.lteNrDssDlRatio.maxNrDssRatio}
    ...                                     minNrDssRatio=${testParam.scfFile.lteNrDssDlRatio.minNrDssRatio}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssDlRatio
    ...                    p_name=dlResourceSharingAlgo
    ...                    value=${testParam.scfFile.lteNrDssDlRatio.dlResourceSharingAlgo}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssDlRatio
    ...                    p_name=maxNrDssRatio
    ...                    value=${testParam.scfFile.lteNrDssDlRatio.maxNrDssRatio}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssDlRatio
    ...                    p_name=minNrDssRatio
    ...                    value=${testParam.scfFile.lteNrDssDlRatio.minNrDssRatio}

Set SCF DSS Cell2
    [Arguments]          ${testParam}    ${gnb_scf}
    @{distName_NRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}             ${p_name}                   ${value}        IN
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    nbrOfBlankedPRBsHighEdgeDL        0
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    nbrOfBlankedPRBsHighEdgeUL        0
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    nbrOfBlankedPRBsLowEdgeDL         0
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    nbrOfBlankedPRBsLowEdgeUL         0
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    actLteNrDssFastAlloc   ${testParam.scfFile.nrdsslte.actLteNrDssFastAlloc}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    actRateMatchedCsiIm    ${testParam.scfFile.nrdsslte.actRateMatchedCsiIm}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    actLteNrDssLteCatM     ${testParam.scfFile.nrdsslte.actLteNrDssLteCatM}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    actDssMsg3Enh          ${testParam.scfFile.nrdsslte.actDssMsg3Enh}
    Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    &{lteNrDssDlRatio}   Create Dictionary   dlResourceSharingAlgo=${testParam.scfFile.lteNrDssDlRatio.dlResourceSharingAlgo}
    ...                                     maxNrDssRatio=${testParam.scfFile.lteNrDssDlRatio.maxNrDssRatio}
    ...                                     minNrDssRatio=${testParam.scfFile.lteNrDssDlRatio.minNrDssRatio}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssDlRatio
    ...                    p_name=dlResourceSharingAlgo
    ...                    value=${testParam.scfFile.lteNrDssDlRatio.dlResourceSharingAlgo}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssDlRatio
    ...                    p_name=maxNrDssRatio
    ...                    value=${testParam.scfFile.lteNrDssDlRatio.maxNrDssRatio}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssDlRatio
    ...                    p_name=minNrDssRatio
    ...                    value=${testParam.scfFile.lteNrDssDlRatio.minNrDssRatio}

Modify sibSchedulingList
    [Arguments]    ${dist_name}=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    ...            ${sibPeriodicity}=rf8
    ${list_name}                        Set Variable                    sibSchedulingList
    Set List                            dist_name=${dist_name}          list_name=${list_name}

    FOR    ${sibtype}    IN RANGE    2    9
        ${sibSchedulingList_dict}       Create dictionary               sibBroadcastStatus                broadcasting
        ...                                                             sibPeriodicity                    ${sibPeriodicity}
        ...                                                             sibScope                          cellSpecific
        ...                                                             sibType                           sibType${sibtype}
        scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}            elements=${sibSchedulingList_dict}
    END

    ${sibSchedulingList_dict}           Create dictionary               sibBroadcastStatus                broadcasting
    ...                                                                 sibPeriodicity                    ${sibPeriodicity}
    ...                                                                 sibScope                          cellSpecific
    ...                                                                 sibType                           sibType8
    scf.add_item_to_list                dist_name=${dist_name}          list_name=${list_name}            elements=${sibSchedulingList_dict}

Set SCF NRCELL WA for DSS
    [Arguments]          ${testParam}      ${gnb_scf}
    @{distName_NRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${type0SearchSpaceConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell_wa.type0SearchSpaceConfigurationIndex}
    FOR    ${dist_name}             ${p_name}                   ${value}        IN
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actDl256Qam        ${testParam.scfFile.nrcell_wa.actDl256Qam}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    msg1FrequencyStart   ${testParam.scfFile.nrcell_wa.msg1FrequencyStart}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    numOfPagingFrames      ${testParam.scfFile.nrcell_wa.numOfPagingFrames}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    pagingOffset        ${testParam.scfFile.nrcell_wa.pagingOffset}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    pucchModeSelect   ${testParam.scfFile.nrcell_wa.pucchModeSelect}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    raResponseWindow      ${testParam.scfFile.nrcell_wa.raResponseWindow}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    type0SearchSpaceConfigurationIndex    ${type0SearchSpaceConfigurationIndex_value}
    ...    ${distName_NRBTS[0]}/NRSYSINFO_PROFILE-1     siWindowLength    ${testParam.scfFile.nrsysinfo_profile_wa.siWindowLength}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    actLteNrDssFastAlloc   ${testParam.scfFile.nrdsslte.actLteNrDssFastAlloc}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    actRateMatchedCsiIm    ${testParam.scfFile.nrdsslte.actRateMatchedCsiIm}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    actLteNrDssLteCatM     ${testParam.scfFile.nrdsslte.actLteNrDssLteCatM}
    Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

    Modify sibSchedulingList    dist_name=${distName_NRBTS[0]}/NRSYSINFO_PROFILE-1
    ...                         sibPeriodicity=${testParam.scfFile.nrsysinfo_profile_wa.sibPeriodicity}

    &{csirsForTracking}    Create Dictionary     csirsTrackingPeriod=${testParam.scfFile.nrcell_wa.csirsTrackingPeriod}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}
    ...                    list_name=csirsForTracking
    ...                    p_name=csirsTrackingPeriod
    ...                    value=${testParam.scfFile.nrcell_wa.csirsTrackingPeriod}

    &{dlDataDmrsFdm}    Create Dictionary     actDlDataDmrsFdm=${testParam.scfFile.nrcell_wa.actDlDataDmrsFdm}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}
    ...                    list_name=dlDataDmrsFdm
    ...                    p_name=actDlDataDmrsFdm
    ...                    value=${testParam.scfFile.nrcell_wa.actDlDataDmrsFdm}

    &{periodicCsiAcquisition}    Create Dictionary     csiReportPeriodicity=${testParam.scfFile.nrcell_wa.csiReportPeriodicity}
    Modify Item To List      dist_name=${distName_NRCELL[${fdd_cell_1}-1]}
    ...                      list_name=periodicCsiAcquisition
    ...                      p_name=csiReportPeriodicity
    ...                      value=${testParam.scfFile.nrcell_wa.csiReportPeriodicity}

    # &{sibSchedulingListItem1}    Create Dictionary     sibPeriodicity=${testParam.scfFile.nrsysinfo_profile_wa.sibPeriodicity}
    # &{sibSchedulingListItem2}    Create Dictionary     sibPeriodicity=${testParam.scfFile.nrsysinfo_profile_wa.sibPeriodicity}
    # &{sibSchedulingListItem3}    Create Dictionary     sibPeriodicity=${testParam.scfFile.nrsysinfo_profile_wa.sibPeriodicity}
    # &{sibSchedulingListItem4}    Create Dictionary     sibPeriodicity=${testParam.scfFile.nrsysinfo_profile_wa.sibPeriodicity}
    # &{sibSchedulingListItem5}    Create Dictionary     sibPeriodicity=${testParam.scfFile.nrsysinfo_profile_wa.sibPeriodicity}
    # &{sibSchedulingListItem6}    Create Dictionary     sibPeriodicity=${testParam.scfFile.nrsysinfo_profile_wa.sibPeriodicity}
    # @{sibSchedulingList_values}    create list
    # Append To List    ${sibSchedulingList_values}    ${sibSchedulingListItem1}    ${sibSchedulingListItem2}   ${sibSchedulingListItem3}
    # Append To List    ${sibSchedulingList_values}    ${sibSchedulingListItem4}    ${sibSchedulingListItem5}
    # Set Element To List    dist_name=${distName_NRBTS[0]}/NRSYSINFO_PROFILE-1
    # ...                    list_name=sibSchedulingList
    # ...                    elements=&{sibSchedulingList_values}

Set SCF NRCELL WA for DSS Cell2
    [Arguments]          ${testParam}      ${gnb_scf}
    @{distName_NRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${type0SearchSpaceConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell_wa.type0SearchSpaceConfigurationIndex}
    FOR    ${dist_name}             ${p_name}                   ${value}        IN
    ...    ${distName_NRCELL[${fdd_cell_1}-2]}    actDl256Qam        ${testParam.scfFile.nrcell_wa.actDl256Qam}
    ...    ${distName_NRCELL[${fdd_cell_1}-2]}    msg1FrequencyStart   ${testParam.scfFile.nrcell_wa.msg1FrequencyStart}
    ...    ${distName_NRCELL[${fdd_cell_1}-2]}    numOfPagingFrames      ${testParam.scfFile.nrcell_wa.numOfPagingFrames}
    ...    ${distName_NRCELL[${fdd_cell_1}-2]}    pagingOffset        ${testParam.scfFile.nrcell_wa.pagingOffset}
    ...    ${distName_NRCELL[${fdd_cell_1}-2]}    pucchModeSelect   ${testParam.scfFile.nrcell_wa.pucchModeSelect}
    ...    ${distName_NRCELL[${fdd_cell_1}-2]}    raResponseWindow      ${testParam.scfFile.nrcell_wa.raResponseWindow}
    ...    ${distName_NRCELL[${fdd_cell_1}-2]}    type0SearchSpaceConfigurationIndex    ${type0SearchSpaceConfigurationIndex_value}
    ...    ${distName_NRBTS[0]}/NRSYSINFO_PROFILE-1     siWindowLength    ${testParam.scfFile.nrsysinfo_profile_wa.siWindowLength}
    ...    ${distName_NRCELL[${fdd_cell_1}-2]}/NRDSSLTE-1    actLteNrDssFastAlloc   ${testParam.scfFile.nrdsslte.actLteNrDssFastAlloc}
    ...    ${distName_NRCELL[${fdd_cell_1}-2]}/NRDSSLTE-1    actRateMatchedCsiIm    ${testParam.scfFile.nrdsslte.actRateMatchedCsiIm}
    ...    ${distName_NRCELL[${fdd_cell_1}-2]}/NRDSSLTE-1    actLteNrDssLteCatM     ${testParam.scfFile.nrdsslte.actLteNrDssLteCatM}
    Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

    Modify sibSchedulingList    dist_name=${distName_NRBTS[0]}/NRSYSINFO_PROFILE-1
    ...                         sibPeriodicity=${testParam.scfFile.nrsysinfo_profile_wa.sibPeriodicity}

    &{csirsForTracking}    Create Dictionary     csirsTrackingPeriod=${testParam.scfFile.nrcell_wa.csirsTrackingPeriod}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}
    ...                    list_name=csirsForTracking
    ...                    p_name=csirsTrackingPeriod
    ...                    value=${testParam.scfFile.nrcell_wa.csirsTrackingPeriod}

    &{dlDataDmrsFdm}    Create Dictionary     actDlDataDmrsFdm=${testParam.scfFile.nrcell_wa.actDlDataDmrsFdm}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}
    ...                    list_name=dlDataDmrsFdm
    ...                    p_name=actDlDataDmrsFdm
    ...                    value=${testParam.scfFile.nrcell_wa.actDlDataDmrsFdm}

    &{periodicCsiAcquisition}    Create Dictionary     csiReportPeriodicity=${testParam.scfFile.nrcell_wa.csiReportPeriodicity}
    Modify Item To List      dist_name=${distName_NRCELL[${fdd_cell_2}-1]}
    ...                      list_name=periodicCsiAcquisition
    ...                      p_name=csiReportPeriodicity
    ...                      value=${testParam.scfFile.nrcell_wa.csiReportPeriodicity}

    # &{sibSchedulingListItem1}    Create Dictionary     sibPeriodicity=${testParam.scfFile.nrsysinfo_profile_wa.sibPeriodicity}
    # &{sibSchedulingListItem2}    Create Dictionary     sibPeriodicity=${testParam.scfFile.nrsysinfo_profile_wa.sibPeriodicity}
    # &{sibSchedulingListItem3}    Create Dictionary     sibPeriodicity=${testParam.scfFile.nrsysinfo_profile_wa.sibPeriodicity}
    # &{sibSchedulingListItem4}    Create Dictionary     sibPeriodicity=${testParam.scfFile.nrsysinfo_profile_wa.sibPeriodicity}
    # &{sibSchedulingListItem5}    Create Dictionary     sibPeriodicity=${testParam.scfFile.nrsysinfo_profile_wa.sibPeriodicity}
    # &{sibSchedulingListItem6}    Create Dictionary     sibPeriodicity=${testParam.scfFile.nrsysinfo_profile_wa.sibPeriodicity}
    # @{sibSchedulingList_values}    create list
    # Append To List    ${sibSchedulingList_values}    ${sibSchedulingListItem1}    ${sibSchedulingListItem2}   ${sibSchedulingListItem3}
    # Append To List    ${sibSchedulingList_values}    ${sibSchedulingListItem4}    ${sibSchedulingListItem5}
    # Set Element To List    dist_name=${distName_NRBTS[0]}/NRSYSINFO_PROFILE-1
    # ...                    list_name=sibSchedulingList
    # ...                    elements=&{sibSchedulingList_values}

Set SCF NRDBR
    [Arguments]          ${testParam}       ${gnb_scf}
    @{distName_NRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${param_list}    Create List
#      TestParam is ${testParam}
    FOR    ${dist_name}       ${list}       ${p_name}               ${value}        IN
    ...    ${distName_NRBTS[0]}/NRDRB-2     nsaDrbParam    ulDataPath   ${testParam.scfFile.nrdrb.ulDataPath}
    ...    ${distName_NRBTS[0]}/NRDRB-2     nsaDrbParam    ulDataSplitThreshold   ${testParam.scfFile.nrdrb.ulDataSplitThreshold}
    ...    ${distName_NRBTS[0]}/NRDRB-2     nsaDrbParam    dlDataSplitMode   ${testParam.scfFile.nrdrb.dlDataSplitMode}
    ...    ${distName_NRBTS[0]}/NRDRB-3     nsaDrbParam    ulDataPath   ${testParam.scfFile.nrdrb.ulDataPath}
    ...    ${distName_NRBTS[0]}/NRDRB-3     nsaDrbParam    ulDataSplitThreshold   ${testParam.scfFile.nrdrb.ulDataSplitThreshold}
    ...    ${distName_NRBTS[0]}/NRDRB-3     nsaDrbParam    dlDataSplitMode   ${testParam.scfFile.nrdrb.dlDataSplitMode}
    ...    ${distName_NRBTS[0]}/NRDRB-4     nsaDrbParam    ulDataPath   ${testParam.scfFile.nrdrb.ulDataPath}
    ...    ${distName_NRBTS[0]}/NRDRB-4     nsaDrbParam    ulDataSplitThreshold   ${testParam.scfFile.nrdrb.ulDataSplitThreshold}
    ...    ${distName_NRBTS[0]}/NRDRB-4     nsaDrbParam    dlDataSplitMode   ${testParam.scfFile.nrdrb.dlDataSplitMode}
    ...    ${distName_NRBTS[0]}/NRDRB-5     nsaDrbParam    ulDataPath   ${testParam.scfFile.nrdrb.ulDataPath}
    ...    ${distName_NRBTS[0]}/NRDRB-5     nsaDrbParam    ulDataSplitThreshold   ${testParam.scfFile.nrdrb.ulDataSplitThreshold}
    ...    ${distName_NRBTS[0]}/NRDRB-5     nsaDrbParam    dlDataSplitMode   ${testParam.scfFile.nrdrb.dlDataSplitMode}
    ...    ${distName_NRBTS[0]}/NRDRB-6     nsaDrbParam    ulDataPath   ${testParam.scfFile.nrdrb.ulDataPath}
    ...    ${distName_NRBTS[0]}/NRDRB-6     nsaDrbParam    ulDataSplitThreshold   ${testParam.scfFile.nrdrb.ulDataSplitThreshold}
    ...    ${distName_NRBTS[0]}/NRDRB-6     nsaDrbParam    dlDataSplitMode   ${testParam.scfFile.nrdrb.dlDataSplitMode}
    ...    ${distName_NRBTS[0]}/NRDRB-7     nsaDrbParam    ulDataPath   ${testParam.scfFile.nrdrb.ulDataPath}
    ...    ${distName_NRBTS[0]}/NRDRB-7     nsaDrbParam    ulDataSplitThreshold   ${testParam.scfFile.nrdrb.ulDataSplitThreshold}
    ...    ${distName_NRBTS[0]}/NRDRB-7     nsaDrbParam    dlDataSplitMode   ${testParam.scfFile.nrdrb.dlDataSplitMode}
    ...    ${distName_NRBTS[0]}/NRDRB-8     nsaDrbParam    ulDataPath   ${testParam.scfFile.nrdrb.ulDataPath}
    ...    ${distName_NRBTS[0]}/NRDRB-8     nsaDrbParam    ulDataSplitThreshold   ${testParam.scfFile.nrdrb.ulDataSplitThreshold}
    ...    ${distName_NRBTS[0]}/NRDRB-8     nsaDrbParam    dlDataSplitMode   ${testParam.scfFile.nrdrb.dlDataSplitMode}
    ...    ${distName_NRBTS[0]}/NRDRB-9     nsaDrbParam    ulDataPath   ${testParam.scfFile.nrdrb.ulDataPath}
    ...    ${distName_NRBTS[0]}/NRDRB-9     nsaDrbParam    ulDataSplitThreshold   ${testParam.scfFile.nrdrb.ulDataSplitThreshold}
    ...    ${distName_NRBTS[0]}/NRDRB-9     nsaDrbParam    dlDataSplitMode   ${testParam.scfFile.nrdrb.dlDataSplitMode}
    Append To List       ${param_list}    modify:${dist_name}:${list}:${p_name}=${value}
    END
    BuiltIn.log     param_list=${param_list}
    scf.perform_scf_modification    modification_strings=${param_list}

Set SCF NRDDSSLTE
    [Arguments]          ${testParam}      ${gnb_scf}
    @{distName_NRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}

#      TestParam is ${testParam}
    &{enbPlmn}    Create Dictionary     mcc=${testParam.scfFile.enbPlmn.mcc}
    ...                 mnc=${testParam.scfFile.enbPlmn.mnc}
    ...                 mncLength=${testParam.scfFile.enbPlmn.mncLength}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=enbPlmn
    ...                    p_name=mcc
    ...                    value=${testParam.scfFile.enbPlmn.mcc}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=enbPlmn
    ...                    p_name=mnc
    ...                    value=${testParam.scfFile.enbPlmn.mnc}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=enbPlmn
    ...                    p_name=mncLength
    ...                    value=${testParam.scfFile.enbPlmn.mncLength}

    &{lteNrDssDlRatio}   Create Dictionary   dlResourceSharingAlgo=${testParam.scfFile.lteNrDssDlRatio.dlResourceSharingAlgo}
    ...                                     maxNrDssRatio=${testParam.scfFile.lteNrDssDlRatio.maxNrDssRatio}
    ...                                     minNrDssRatio=${testParam.scfFile.lteNrDssDlRatio.minNrDssRatio}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssDlRatio
    ...                    p_name=dlResourceSharingAlgo
    ...                    value=${testParam.scfFile.lteNrDssDlRatio.dlResourceSharingAlgo}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssDlRatio
    ...                    p_name=maxNrDssRatio
    ...                    value=${testParam.scfFile.lteNrDssDlRatio.maxNrDssRatio}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssDlRatio
    ...                    p_name=minNrDssRatio
    ...                    value=${testParam.scfFile.lteNrDssDlRatio.minNrDssRatio}

    &{lteNrDssMbsfnRatio}    Create Dictionary     maxValue=${testParam.scfFile.lteNrDssMbsfnRatio.maxValue}
    ...                 minValue=${testParam.scfFile.lteNrDssMbsfnRatio.minValue}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssMbsfnRatio
    ...                    p_name=maxValue
    ...                    value=${testParam.scfFile.lteNrDssMbsfnRatio.maxValue}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssMbsfnRatio
    ...                    p_name=minValue
    ...                    value=${testParam.scfFile.lteNrDssMbsfnRatio.minValue}

    &{lteNrDssUlRatio}    Create Dictionary     maxNrDssRatio=${testParam.scfFile.lteNrDssUlRatio.maxNrDssRatio}
    ...                 minNrDssRatio=${testParam.scfFile.lteNrDssUlRatio.minNrDssRatio}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssUlRatio
    ...                    p_name=maxNrDssRatio
    ...                    value=${testParam.scfFile.lteNrDssUlRatio.maxNrDssRatio}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssUlRatio
    ...                    p_name=minNrDssRatio
    ...                    value=${testParam.scfFile.lteNrDssUlRatio.minNrDssRatio}

    FOR    ${dist_name}             ${p_name}                   ${value}        IN
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    dssDlTPollRetr      ${testParam.scfFile.nrdsslte.dssDlTPollRetr}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    dssDlTProhib        ${testParam.scfFile.nrdsslte.dssDlTProhib}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    dssUlTPollRetr      ${testParam.scfFile.nrdsslte.dssUlTPollRetr}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    dssUlTProhib        ${testParam.scfFile.nrdsslte.dssUlTProhib}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    eNodeBId            ${testParam.scfFile.nrdsslte.eNodeBId}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    lcrId               ${testParam.scfFile.nrdsslte.lcrId}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    ltePhyCellId        ${testParam.scfFile.nrdsslte.ltePhyCellId}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    ssbPosition            ${testParam.scfFile.nrdsslte.ssbPosition}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    dssMaxNumberOfDlDcis   ${testParam.scfFile.nrdsslte.dssMaxNumberOfDlDcis}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    actLteNrDssFastAlloc   ${testParam.scfFile.nrdsslte.actLteNrDssFastAlloc}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    lteNrDssFastAllocPerfEnh   ${testParam.scfFile.nrdsslte.lteNrDssFastAllocPerfEnh}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    actRateMatchedCsiIm   ${testParam.scfFile.nrdsslte.actRateMatchedCsiIm}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    actLteNrDssLteCatM   ${testParam.scfFile.nrdsslte.actLteNrDssLteCatM}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    actDssMsg3Enh   ${testParam.scfFile.nrdsslte.actDssMsg3Enh}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    actUlAdaptReTxEnhDss   ${testParam.scfFile.nrdsslte.actUlAdaptReTxEnhDss}
    Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

Set SCF NRDDSSLTE Cell2
    [Arguments]          ${testParam}      ${gnb_scf}
    @{distName_NRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}

#      TestParam is ${testParam}
    &{enbPlmn}    Create Dictionary     mcc=${testParam.scfFile.enbPlmn.mcc}
    ...                 mnc=${testParam.scfFile.enbPlmn.mnc}
    ...                 mncLength=${testParam.scfFile.enbPlmn.mncLength}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1
    ...                    list_name=enbPlmn
    ...                    p_name=mcc
    ...                    value=${testParam.scfFile.enbPlmn.mcc}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1
    ...                    list_name=enbPlmn
    ...                    p_name=mnc
    ...                    value=${testParam.scfFile.enbPlmn.mnc}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1
    ...                    list_name=enbPlmn
    ...                    p_name=mncLength
    ...                    value=${testParam.scfFile.enbPlmn.mncLength}

    &{lteNrDssDlRatio}   Create Dictionary   dlResourceSharingAlgo=${testParam.scfFile.lteNrDssDlRatio.dlResourceSharingAlgo}
    ...                                     maxNrDssRatio=${testParam.scfFile.lteNrDssDlRatio.maxNrDssRatio}
    ...                                     minNrDssRatio=${testParam.scfFile.lteNrDssDlRatio.minNrDssRatio}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssDlRatio
    ...                    p_name=dlResourceSharingAlgo
    ...                    value=${testParam.scfFile.lteNrDssDlRatio.dlResourceSharingAlgo}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssDlRatio
    ...                    p_name=maxNrDssRatio
    ...                    value=${testParam.scfFile.lteNrDssDlRatio.maxNrDssRatio}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssDlRatio
    ...                    p_name=minNrDssRatio
    ...                    value=${testParam.scfFile.lteNrDssDlRatio.minNrDssRatio}

    &{lteNrDssMbsfnRatio}    Create Dictionary     maxValue=${testParam.scfFile.lteNrDssMbsfnRatio.maxValue}
    ...                 minValue=${testParam.scfFile.lteNrDssMbsfnRatio.minValue}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssMbsfnRatio
    ...                    p_name=maxValue
    ...                    value=${testParam.scfFile.lteNrDssMbsfnRatio.maxValue}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssMbsfnRatio
    ...                    p_name=minValue
    ...                    value=${testParam.scfFile.lteNrDssMbsfnRatio.minValue}

    &{lteNrDssUlRatio}    Create Dictionary     maxNrDssRatio=${testParam.scfFile.lteNrDssUlRatio.maxNrDssRatio}
    ...                 minNrDssRatio=${testParam.scfFile.lteNrDssUlRatio.minNrDssRatio}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssUlRatio
    ...                    p_name=maxNrDssRatio
    ...                    value=${testParam.scfFile.lteNrDssUlRatio.maxNrDssRatio}
    Modify Item To List    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssUlRatio
    ...                    p_name=minNrDssRatio
    ...                    value=${testParam.scfFile.lteNrDssUlRatio.maxNrDssRatio}

    FOR    ${dist_name}             ${p_name}                   ${value}        IN
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    dssDlTPollRetr      ${testParam.scfFile.nrdsslte.dssDlTPollRetr}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    dssDlTProhib        ${testParam.scfFile.nrdsslte.dssDlTProhib}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    dssUlTPollRetr      ${testParam.scfFile.nrdsslte.dssUlTPollRetr}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    dssUlTProhib        ${testParam.scfFile.nrdsslte.dssUlTProhib}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    eNodeBId            ${testParam.scfFile.nrdsslte.eNodeBId}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    lcrId               ${testParam.scfFile.nrdsslte.lcrId}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    ltePhyCellId        ${testParam.scfFile.nrdsslte.ltePhyCellId}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    ssbPosition            ${testParam.scfFile.nrdsslte.ssbPosition}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    dssMaxNumberOfDlDcis   ${testParam.scfFile.nrdsslte.dssMaxNumberOfDlDcis}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    actLteNrDssFastAlloc   ${testParam.scfFile.nrdsslte.actLteNrDssFastAlloc}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    lteNrDssFastAllocPerfEnh   ${testParam.scfFile.nrdsslte.lteNrDssFastAllocPerfEnh}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    actRateMatchedCsiIm   ${testParam.scfFile.nrdsslte.actRateMatchedCsiIm}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    actLteNrDssLteCatM   ${testParam.scfFile.nrdsslte.actLteNrDssLteCatM}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    actDssMsg3Enh   ${testParam.scfFile.nrdsslte.actDssMsg3Enh}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRDSSLTE-1    actUlAdaptReTxEnhDss   ${testParam.scfFile.nrdsslte.actUlAdaptReTxEnhDss}
    Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

Set SCF NRDDSSLTE version1
    [Arguments]          ${testParam}      ${gnb_scf}
    @{distName_NRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}

#      TestParam is ${testParam}
    &{enbPlmn}    Create Dictionary     mcc=${testParam.scfFile.enbPlmn.mcc}
    ...                 mnc=${testParam.scfFile.enbPlmn.mnc}
    ...                 mncLength=${testParam.scfFile.enbPlmn.mncLength}
    Set Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=enbPlmn
    ...                    elements=&{enbPlmn}

    &{lteNrDssDlRatio}   Create Dictionary   dlResourceSharingAlgo=${testParam.scfFile.lteNrDssDlRatio.dlResourceSharingAlgo}
    ...                                     maxNrDssRatio=${testParam.scfFile.lteNrDssDlRatio.maxNrDssRatio}
    ...                                     minNrDssRatio=${testParam.scfFile.lteNrDssDlRatio.minNrDssRatio}
    Set Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssDlRatio
    ...                    elements=&{lteNrDssDlRatio}

    &{lteNrDssMbsfnRatio}    Create Dictionary     maxValue=${testParam.scfFile.lteNrDssMbsfnRatio.maxValue}
    ...                 minValue=${testParam.scfFile.lteNrDssMbsfnRatio.minValue}
    Set Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssMbsfnRatio
    ...                    elements=&{lteNrDssMbsfnRatio}

    &{lteNrDssUlRatio}    Create Dictionary     maxNrDssRatio=${testParam.scfFile.lteNrDssUlRatio.maxNrDssRatio}
    ...                 minNrDssRatio=${testParam.scfFile.lteNrDssUlRatio.minNrDssRatio}
    Set Item To List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1
    ...                    list_name=lteNrDssUlRatio
    ...                    elements=&{lteNrDssUlRatio}

    FOR    ${dist_name}             ${p_name}                   ${value}        IN
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    dssDlTPollRetr      ${testParam.scfFile.nrdsslte.dssDlTPollRetr}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    dssDlTProhib        ${testParam.scfFile.nrdsslte.dssDlTProhib}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    dssUlTPollRetr      ${testParam.scfFile.nrdsslte.dssUlTPollRetr}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    dssUlTProhib        ${testParam.scfFile.nrdsslte.dssUlTProhib}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    eNodeBId            ${testParam.scfFile.nrdsslte.eNodeBId}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    lcrId               ${testParam.scfFile.nrdsslte.lcrId}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    ltePhyCellId        ${testParam.scfFile.nrdsslte.ltePhyCellId}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    ssbPosition            ${testParam.scfFile.nrdsslte.ssbPosition}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRDSSLTE-1    dssMaxNumberOfDlDcis   ${testParam.scfFile.nrdsslte.dssMaxNumberOfDlDcis}
    Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

Set SCF
    [Arguments]          ${testParam}     ${gnb_scf}
    @{distName_NRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    @{distName_MRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${gnb_scf}
    ...    regex=MRBTS-[0-9]+
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    nps_tarf_tools.log_to_console_with_time_prefix   Scf update for Cell-${fdd_cell_1}   level=INFO
    ${btsName}=     Catenate    ${testParam.scfFile.mrbts.btsName} ${testline_name}
#      TestParam is ${testParam}
    FOR    ${dist_name}             ${p_name}                   ${value}        IN
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1    chBwDl        ${testParam.scfFile.nrcellfdd.chBwDl}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1    chBwUl        ${testParam.scfFile.nrcellfdd.chBwUl}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1    nrarfcnDl     ${testParam.scfFile.nrcellfdd.nrarfcnDl}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1    nrarfcnUl     ${testParam.scfFile.nrcellfdd.nrarfcnUl}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    gscnOrSsPbchArfcn   ${testParam.scfFile.nrcell.gscn}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    type0CoresetConfigurationIndex  ${testParam.scfFile.nrcell.type0CoresetConfigurationIndex}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    dlDMRSAdditionalPosition   ${testParam.scfFile.nrcell.dlDMRSAdditionalPosition}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    cellName    ${testParam.scfFile.nrcell.cellName}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    dmrsTypeAPosition     ${testParam.scfFile.nrcell.dmrsTypeAPosition}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actFdmSchedulingInitialBWP     false
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    lteNrDssMode          ${testParam.scfFile.nrcell.lteNrDssMode}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    msg1FrequencyStart    ${testParam.scfFile.nrcell.msg1FrequencyStart}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    ullaIniMcs     ${testParam.scfFile.nrcell.ullaIniMcs}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    ulDMRSAdditionalPosition     ${testParam.scfFile.nrcell.ulDMRSAdditionalPosition}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actPRBBlanking          ${testParam.scfFile.nrcell.actPRBBlanking}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    trsMutingInBlankedPRBsEnabled    ${testParam.scfFile.nrcell.trsMutingInBlankedPRBsEnabled}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    aggregationLevel          ${testParam.scfFile.aggregationLevel}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    prachConfigurationIndex     ${testParam.scfFile.nrcell.prachConfigurationIndex}
    ...    ${distName_NRBTS[0]}/NRPMRNL-1     miNrEnDssPerCell    ${testParam.scfFile.nrpmrnl.miNrEnDssPerCell}
    ...    ${distName_NRBTS[0]}/NRPMRNL-1     miNrCellUtilization    ${testParam.scfFile.nrpmrnl.miNrCellUtilization}
    ...    ${distName_NRBTS[0]}    mcc    ${testParam.scfFile.nrbts.mcc}
    ...    ${distName_NRBTS[0]}    mnc    ${testParam.scfFile.nrbts.mnc}
    ...    ${distName_NRBTS[0]}    mncLength    ${testParam.scfFile.nrbts.mncLength}
    ...    ${distName_NRBTS[0]}    actFdmScheduling    ${testParam.scfFile.nrbts.actFdmScheduling}
    ...    ${distName_NRBTS[0]}    actInactDetNSAUe    ${testParam.scfFile.nrbts.actInactDetNSAUe}
    ...    ${distName_NRBTS[0]}    drbInactivityTimerSA    ${testParam.scfFile.nrbts.drbInactivityTimerSA}
    ...    ${distName_NRBTS[0]}    srbInactivityTimerSA    ${testParam.scfFile.nrbts.srbInactivityTimerSA}
    ...    ${distName_MRBTS[0]}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1  localIpAddr  ${testParam.scfFile.ipif.localIpAddr}
    ...    ${distName_MRBTS[0]}    btsName  ${btsName[0:78]}
    ...    ${distName_NRBTS[0]}    actLteNrDss    ${testParam.scfFile.nrbts.actLteNrDss}
    Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

Set SCF Cell2
    [Arguments]          ${testParam}     ${gnb_scf}
    @{distName_NRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    @{distName_MRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${gnb_scf}
    ...    regex=MRBTS-[0-9]+
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    nps_tarf_tools.log_to_console_with_time_prefix   Scf update for Cell-${fdd_cell_2}   level=INFO
    ${btsName}=     Catenate    ${testParam.scfFile.mrbts.btsName} ${testline_name}
#      TestParam is ${testParam}
    FOR    ${dist_name}             ${p_name}                   ${value}        IN
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1    chBwDl        ${testParam.scfFile.nrcellfdd.chBwDl}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1    chBwUl        ${testParam.scfFile.nrcellfdd.chBwUl}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1    nrarfcnDl     ${testParam.scfFile.nrcellfdd.nrarfcnDl}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1    nrarfcnUl     ${testParam.scfFile.nrcellfdd.nrarfcnUl}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    gscnOrSsPbchArfcn   ${testParam.scfFile.nrcell.gscn}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    type0CoresetConfigurationIndex  ${testParam.scfFile.nrcell.type0CoresetConfigurationIndex}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    dlDMRSAdditionalPosition   ${testParam.scfFile.nrcell.dlDMRSAdditionalPosition}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    cellName    Dss-Ph3 Cell2
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    dmrsTypeAPosition     ${testParam.scfFile.nrcell.dmrsTypeAPosition}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actFdmSchedulingInitialBWP     false
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    lteNrDssMode          ${testParam.scfFile.nrcell.lteNrDssMode}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    msg1FrequencyStart    ${testParam.scfFile.nrcell.msg1FrequencyStart}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    ullaIniMcs     ${testParam.scfFile.nrcell.ullaIniMcs}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    ulDMRSAdditionalPosition     ${testParam.scfFile.nrcell.ulDMRSAdditionalPosition}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actPRBBlanking          ${testParam.scfFile.nrcell.actPRBBlanking}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    trsMutingInBlankedPRBsEnabled    ${testParam.scfFile.nrcell.trsMutingInBlankedPRBsEnabled}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    aggregationLevel          ${testParam.scfFile.aggregationLevel}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    prachConfigurationIndex     ${testParam.scfFile.nrcell.prachConfigurationIndex}
    ...    ${distName_NRBTS[0]}/NRPMRNL-1     miNrEnDssPerCell    ${testParam.scfFile.nrpmrnl.miNrEnDssPerCell}
    ...    ${distName_NRBTS[0]}/NRPMRNL-1     miNrCellUtilization    ${testParam.scfFile.nrpmrnl.miNrCellUtilization}
    ...    ${distName_NRBTS[0]}    mcc    ${testParam.scfFile.nrbts.mcc}
    ...    ${distName_NRBTS[0]}    mnc    ${testParam.scfFile.nrbts.mnc}
    ...    ${distName_NRBTS[0]}    mncLength    ${testParam.scfFile.nrbts.mncLength}
    ...    ${distName_NRBTS[0]}    actFdmScheduling    ${testParam.scfFile.nrbts.actFdmScheduling}
    ...    ${distName_NRBTS[0]}    actInactDetNSAUe    ${testParam.scfFile.nrbts.actInactDetNSAUe}
    ...    ${distName_NRBTS[0]}    drbInactivityTimerSA    ${testParam.scfFile.nrbts.drbInactivityTimerSA}
    ...    ${distName_NRBTS[0]}    srbInactivityTimerSA    ${testParam.scfFile.nrbts.srbInactivityTimerSA}
    ...    ${distName_MRBTS[0]}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1  localIpAddr  ${testParam.scfFile.ipif.localIpAddr}
    ...    ${distName_MRBTS[0]}    btsName  ${btsName[0:78]}
    ...    ${distName_NRBTS[0]}    actLteNrDss    ${testParam.scfFile.nrbts.actLteNrDss}
    Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END


Set SCF XPIF
    [Arguments]          ${testParam}     ${gnb_scf}
    @{distName_NRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    @{distName_MRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${gnb_scf}
    ...    regex=MRBTS-[0-9]+
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${param_list}    Create List
#      TestParam is ${testParam}
    ${dist_ipV4AddressDN1}=    set variable    ${distName_MRBTS[0]}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${IPIF-XP-ID}/IPADDRESSV4-1
    FOR    ${dist_name}             ${p_name}                   ${value}        IN
    ...    ${distName_MRBTS[0]}/MNL-1/MNLENT-1/XPAP-1/XPIF-1     sctpAssocMaxRetrans    ${testParam.scfFile.xpif.sctpAssocMaxRetrans}
    ...    ${distName_MRBTS[0]}/MNL-1/MNLENT-1/XPAP-1/XPIF-1     sctpDscp    ${testParam.scfFile.xpif.sctpDscp}
    ...    ${distName_MRBTS[0]}/MNL-1/MNLENT-1/XPAP-1/XPIF-1     sctpHeartbeatInterval    ${testParam.scfFile.xpif.sctpHeartbeatInterval}
    ...    ${distName_MRBTS[0]}/MNL-1/MNLENT-1/XPAP-1/XPIF-1     sctpMaxPayloadSize    ${testParam.scfFile.xpif.sctpMaxPayloadSize}
    ...    ${distName_MRBTS[0]}/MNL-1/MNLENT-1/XPAP-1/XPIF-1     sctpRtoMax    ${testParam.scfFile.xpif.sctpRtoMax}
    ...    ${distName_MRBTS[0]}/MNL-1/MNLENT-1/XPAP-1/XPIF-1     sctpRtoMin    ${testParam.scfFile.xpif.sctpRtoMin}
    ...    ${distName_MRBTS[0]}/MNL-1/MNLENT-1/XPAP-1/XPIF-1     sctpSackDelay    ${testParam.scfFile.xpif.sctpSackDelay}
    ...    ${distName_MRBTS[0]}/MNL-1/MNLENT-1/XPAP-1/XPIF-1     sctpSackFreq    ${testParam.scfFile.xpif.sctpSackFreq}
    ...    ${distName_MRBTS[0]}/MNL-1/MNLENT-1/XPAP-1/XPIF-1     sctpWaitTimeInitSeqRetry    ${testParam.scfFile.xpif.sctpWaitTimeInitSeqRetry}
    ...    ${distName_MRBTS[0]}/MNL-1/MNLENT-1/XPAP-1/XPIF-1     udpDscp    ${testParam.scfFile.xpif.udpDscp}
    ...    ${distName_MRBTS[0]}/MNL-1/MNLENT-1/XPAP-1/XPIF-1     ipV4AddressDN1    ${dist_ipV4AddressDN1}
    ...    ${distName_MRBTS[0]}/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1     ipAddress    ${testParam.scfFile.xpif_xpifremote.ipAddress}
    Append To List       ${param_list}    modify:${dist_name}:${p_name}=${value}
    END
    BuiltIn.log     param_list=${param_list}
    scf.perform_scf_modification    modification_strings=${param_list}

Test Setup DSS TO KILL
    [Arguments]         ${testParam}

    Set Suite Variable     ${trunk}     True
    Run Keyword If   '${SHOULD_UPDATE_SCF_AND_RAD}' == '1'   DSS_Kw_TestSetup.Set SCF DSS   ${testParam}
    Run Keyword If   '${SHOULD_UPDATE_SCF_AND_RAD}' == '1'   DSS_Kw_TestSetup.Set SCF NRCELL WA for DSS   ${testParam}
    Run Keyword If   '${SHOULD_UPDATE_SCF_AND_RAD}' == '1'   DSS_Kw_TestSetup.Modify DSS searchSpaceDedicated related Parameters  ${testParam}
    Run Keyword If   '${SHOULD_UPDATE_SCF_AND_RAD}' == '1'   Modify DSS Initial BWP searchSpaceCommon related Parameters  ${testParam}
    Run Keyword If   '${SHOULD_UPDATE_SCF_AND_RAD}' == '1'   Modify DSS Dedicated BWP searchSpaceCommon related Parameters  ${testParam}
    # Run Keyword If   '${SHOULD_UPDATE_SCF_AND_RAD}' == '1'   Modify 2574 Dedicated BWP 1 coresetDedicated related Parameters  ${testParam}
    ${dss_swconfig_gnb}=    Run Keyword If   '${SHOULD_UPDATE_SCF_AND_RAD}' == '1'      Set 2574 Specific RAD     ${testParam}
    Run Keyword If   '${SHOULD_UPDATE_SCF_AND_RAD}' == '1'   common_Dss_Keywords.Set Specific RAD & scf parameters  ${testParam}
    ...                                                                                                             swconfig_gnb=${dss_swconfig_gnb}
    # Run Keyword If   '${SHOULD_UPDATE_SCF_AND_RAD}' == '1'   DSS_Kw_TestSetup.Set DSS Specifc Scf Param  ${testParam}

    # iPHY gscn update depending of chBwDl
    Dated Log      iPHY gscn update with ${testParam.scfFile.nrcell.gscn} : chBwDl=${testParam.scfFile.nrcellfdd.chBwDl}
    DSS_Kw_TestSetup.Dedicated Set Context_AP IPHY    ${testParam}    ${fdd_cell_1}

    # iPHY Cell update
    Dated Log      iPHY Cell update with ${testParam.Context.gNBId}.1
    DSS_Kw_TestSetup.Dedicated Set Context_Cell IPHY    ${testParam}

    # default configuration is 10MHz case , nothing to do in this case
    # Run Keyword If   '${testParam.seq.bandwidth}'!='10MHz'   Modify Bandwidth Parameters for WTS   ${testParam}
    # csamson : specific ue capa for dss PH3
    # 12/09/2022 : tempory WA for CB008325
    # => UTE Cloud TL : only nrCellType = 4DL4UL is supported for ABIP for the moment
    # and Ue capa delevered by UTE Cloud allow to support only 2 DL Layers => so in case of ABIP; the Ue capa are not forced for the moment
    # => to change when ABIP gNB will support nrCellType = 2DL2UL
    # ${w_force_ue_capa}=   set Variable if    '${GNB_DU.bb[0].M.boardType}'=='ABIP'    False
    # ...                                                                               True
    ${w_force_ue_capa}=   set Variable     False
    Modify Bandwidth Parameters for WTS   ${testParam}  w_force_ue_capa=${w_force_ue_capa}

    # ${isOAMRebooted}    Run Keyword If      '${SHOULD_UPDATE_SCF_AND_RAD}' == '1'    SSH Was OAM Rebooted     ${GNB_DU}          timeout=60

    # SCF.xml is used by procedure verifyFeatureActivation
    ${test_scf_file}             COAM Get SCF        local_dir_path=${LOG_PATH}      file=SCF.xml    alias=coam_gnb
    Set Suite Variable              ${test_scf_file}
    Dated Log                  Current DSS SCF file stored to ${test_scf_file}


gNB_ModifySCFwithNewGNBID
    [Arguments]    ${scf_path}    ${gnbID}=NRBTS-1
    run    command=sed -i 's|NRBTS-1|${gnbID}|g' ${scf_path}

gNB_ModifySCFwithNewMRBTSID_2
    [Arguments]    ${scf_path}    ${mrbtsID_original}=MRBTS-1     ${mrbtsID_new}=MRBTS-1
    run    command=sed -i 's|${mrbtsID_original}|${mrbtsID_new}|g' ${scf_path}

gNB_ModifySCFwithNewNRBTS
    [Arguments]    ${scf_path}    ${nrbtsID_original}=NRBTS-1     ${nrbtsID_new}=NRBTS-1
    run    command=sed -i 's|${nrbtsID_original}|${nrbtsID_new}|g' ${scf_path}

Commissioning SCF wo TL restart
    [Tags]                          INIT_AND_TEST
    [Arguments]                     ${ScfFile}
    Dated log                       Commisioning SCF : ${ScfFile}
    File should exist               ${ScfFile}                              SCF file ${ScfFile} not found
    OAM Perform Full Commissioning  scf_file=${ScfFile}
    Dated Log    End commissioning, wait for OAM to come back
    # OAM wait available
    Wait Until Keyword Succeeds   5min   20s   testline-Keywords.Verify Single BTS is Configured   connection=coam_gnb
    ${isOAMRebooted}     SSH Was OAM Rebooted        ${GNB_DU}          timeout=60
    # If gNB was rebooted after re-commissioning, wait until it's ready again.
    Run Keyword If                  '${isOAMRebooted}' == 'True'        Airscale Wait for Ready         ${GNB_DU}
    # Restart       isOAMRebooted=${isOAMRebooted}    OwnTLReset=${true}


Commissioning DSS SCF
    [Tags]                          INIT_AND_TEST
    [Arguments]                     ${ScfFile}
    Dated log                       Commisioning SCF : ${ScfFile}
    File should exist               ${ScfFile}                              SCF file ${ScfFile} not found
    # OAM Perform Full Commissioning  scf_file=${ScfFile}
    admin.perform_commissioning  scf_file=${ScfFile}  connection=coam_gnb
    ...  skip_parameter_relation_errors=true
    Dated Log    End commissioning, wait for OAM to come back
    # OAM wait available
    Wait Until Keyword Succeeds   5min   20s   testline-Keywords.Verify Single BTS is Configured   connection=coam_gnb


Test Line Preparation
   [Arguments]       ${testParam}

   ${test_scf_file}    COAM Get SCF        local_dir_path=${LOG_PATH}      file=SCFC_gNB0_DU_orig_FirstCommissioning.xml    alias=coam_gnb
   ${default_local_scf_file_path}    Copy file    source=${test_scf_file}    destination=${LOG_PATH}/DSS_delete/
   Set Suite Variable              ${test_scf_file}

   # Dated Log   =====> Lock in scf all RU and Cells Except CellId 1
   # ${status}   ${modified_scf_file_path}   run Keyword and ignore error    Lock in scf all RU and Cells Except CellId
   # ...                                                                                                 Cell=1
   # ...                                                                                                 test_scf_file=${default_local_scf_file_path}
   # ${modified_scf_file_path} =    run Keyword if   '${status}'!='PASS'     set variable   ${default_local_scf_file_path}
   # ...   ELSE                                                              set variable   ${modified_scf_file_path}

   ${modified_scf_file_path}     set variable     ${default_local_scf_file_path}

   ${cellDepType}=   DSS_Kw_TestSetup.get cellDepType from SCF
   ${testParam.Context.cellDepType}      set variable    ${cellDepType}
   # BEWARE : line commented here to keep eNBId=1 and gNBId=2 defined into ${testParam} to be able to perform SA and NSA 5g Call
   # run Keyword if   '${testParam.Context.cellDepType}' == 'SA+NSA'  DSS_Kw_TestSetup.update eNbId and gNBId In Context   ${testParam}   2   1

   # to update ${testParam.Context.gNBId_cellid} !! with ${fdd_cell_1}

   ${cellDepType}=      set variable      ${testParam.Context.cellDepType}
   set suite variable     ${NWtype}      ${cellDepType}

   ${default_local_scf_file_path}    Copy file    source=${modified_scf_file_path}    destination=${LOG_PATH}/DSS_delete/
   Set Suite Variable              ${default_local_scf_file_path}

   # needed for DELETE and ADD DSS obj
   nps_tarf_tools.log_to_console_with_time_prefix   NRBTS-original=NRBTS-${NRBTS_ID} modification with NRBTS-1
   ...                                             level=INFO
   DSS_Kw_TestSetup.gNB_ModifySCFwithNewNRBTS   ${default_local_scf_file_path}    nrbtsID_original=NRBTS-${NRBTS_ID}   nrbtsID_new=NRBTS-1

   ${cell1_is_Dss}=     Evaluate    '${fdd_cell_1}'=='${1}'
   ${local_path_dss_scf_file}      common_Dss_Keywords.Delete DSS Information If Exist     ${default_local_scf_file_path}
   ...                                                                                     cell1_is_Dss=${cell1_is_Dss}
   Set Suite Variable              ${local_path_dss_scf_file}

   IF    '${fdd_cell_1}' == '${1}'
        ${local_path_dss_scf_file}      common_Dss_Keywords.Delete DSS Cell1 Information If Exist      ${local_path_dss_scf_file}
   END


   IF    ${cell2_is_Dss} and '${fdd_cell_2}' == '${2}'
        ${local_path_dss_scf_file}      common_Dss_Keywords.Delete DSS Cell2 Information If Exist      ${local_path_dss_scf_file}
   END

   IF    '${fdd_cell_1}' == '${3}'
        ${local_path_dss_scf_file}      common_Dss_Keywords.Delete DSS Cell3 Information If Exist      ${local_path_dss_scf_file}
   END

   ${local_path_dss_scf_file_with_dss_info}     common_Dss_Keywords.Add DSS information to scf    ${local_path_dss_scf_file}  cellId=${fdd_cell_1}
   Set Suite Variable              ${local_path_dss_scf_file_with_dss_info}

   IF    '${fdd_cell_1}' == '${1}'
        ${local_path_dss_scf_file_with_dss_info}   common_Dss_Keywords.Add DSS information Cell1 to scf    ${local_path_dss_scf_file_with_dss_info}
        ...                                                                                                cellId=${fdd_cell_1}
        Set Suite Variable              ${local_path_dss_scf_file_with_dss_info}
   END

   IF    ${cell2_is_Dss} and '${fdd_cell_2}' == '${2}'
        ${local_path_dss_scf_file_with_dss_info}   common_Dss_Keywords.Add DSS information Cell2 to scf    ${local_path_dss_scf_file_with_dss_info}
        ...                                                                                                cellId=${fdd_cell_1}
        Set Suite Variable              ${local_path_dss_scf_file_with_dss_info}
   END

   IF    '${fdd_cell_1}' == '${3}'
        ${local_path_dss_scf_file_with_dss_info}   common_Dss_Keywords.Add DSS information Cell3 to scf    ${local_path_dss_scf_file_with_dss_info}
        ...                                                                                                cellId=${fdd_cell_1}
        Set Suite Variable              ${local_path_dss_scf_file_with_dss_info}
   END

   run Keyword if     '${cellDepType}' == 'SA+NSA'      common_Dss_Keywords.add SA cellBwpList to SCF     ${local_path_dss_scf_file_with_dss_info}
   ...                                                                                                    cellId=${fdd_cell_1}
   ...      ELSE          common_Dss_Keywords.add NSA cellBwpList to SCF     ${local_path_dss_scf_file_with_dss_info}
   ...                                                                       cellId=${fdd_cell_1}

   # we need to change GNBID with NRBTS-2 into all scf file (DSS purpose)
   nps_tarf_tools.log_to_console_with_time_prefix     NRBTS- modification with NRBTS-2    level=INFO
   DSS_Kw_TestSetup.gNB_ModifySCFwithNewGNBID    ${local_path_dss_scf_file_with_dss_info}    NRBTS-2

   Run Keyword If     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}' == '1'  DSS_Kw_TestSetup.Commissioning DSS SCF  ${local_path_dss_scf_file_with_dss_info}
   ...     ELSE        Dated log     =====> gNB not Commissioning because SHOULD_BE_COMMISSIONED_GNB_FIRST==0
   # Run Keyword If     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}' == '1'  common_Dss_Keywords.Get GNB BTS Info
   Run Keyword If     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}' == '1'  DSS_Kw_TestSetup.Get GNB BTS Info

   # needed for DELETE and ADD DSS obj
   # Dated Log New Line  =====> gNB_ModifySCFwithNewNRBTS with nrbtsID_original=NRBTS-${NRBTS_ID} and nrbtsID_new=NRBTS-1
   # DSS_Kw_TestSetup.gNB_ModifySCFwithNewNRBTS   ${local_path_dss_scf_file_with_dss_info}    nrbtsID_original=NRBTS-${NRBTS_ID}
   # ...                                                                                      nrbtsID_new=NRBTS-1
   # run Keyword if     '${cellDepType}' == 'SA+NSA'      common_Dss_Keywords.add SA cellBwpList to SCF     ${local_path_dss_scf_file_with_dss_info}
   # ...      ELSE          common_Dss_Keywords.add NSA cellBwpList to SCF     ${local_path_dss_scf_file_with_dss_info}

   # we need to change GNBID with NRBTS-2 into all scf file (DSS purpose)
   # Dated Log  =====> gNB_ModifySCFwithNewGNBID with NRBTS-2
   # DSS_Kw_TestSetup.gNB_ModifySCFwithNewGNBID    ${local_path_dss_scf_file_with_dss_info}    NRBTS-2

   # Run Keyword If     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}' == '1'  Commissioning SCF wo TL restart  ${local_path_dss_scf_file_with_dss_info}
   # ...     ELSE        Dated log     =====> gNB not Commissioning for SA/NSA cellBwpList change because SHOULD_BE_COMMISSIONED_GNB_FIRST==0

   return From Keyword If     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}' == '0'
   [return]    ${local_path_dss_scf_file_with_dss_info}


Get GNB BTS Info
    ${mrbts_str}=  Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+
    ${nrbts_str}=  Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${nrcell_str}=  Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort List     ${nrcell_str}
    ${mrbts_id}=    Remove String     ${mrbts_str[0]}     MRBTS-
    ${nrbts_id}=    Remove String     ${nrbts_str[0]}     MRBTS-${mrbts_id}/NRBTS-
    Set Suite Variable    ${MRBTS_ID}    ${mrbts_id}
    Set Suite Variable    ${NRBTS_ID}    ${nrbts_id}
    Set Suite Variable    ${NRCELL_DIST_NAME}    ${nrcell_str[0]}
    Dated log             \tMRBTS_ID=${MRBTS_ID}
    Dated log             \tNRBTS_ID=${NRBTS_ID}
    Dated log             \tNRCELL_DIST_NAME=${NRCELL_DIST_NAME}

Update DSS actLteNrDssLteCatM with "${actLteNrDssLteCatM}" into "${testParam}"
   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.scfFile.nrdsslte.actLteNrDssLteCatM}      set Variable     ${actLteNrDssLteCatM}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

Update DSS actLteNrDssLteCatM with
   [Arguments]         ${testParam}     ${actLteNrDssLteCatM}=false
   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.scfFile.nrdsslte.actLteNrDssLteCatM}      set Variable     ${actLteNrDssLteCatM}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

Update DSS lteNrDssFastAllocPerfEnh with "${lteNrDssFastAllocPerfEnh}" into "${testParam}"
   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.scfFile.nrdsslte.lteNrDssFastAllocPerfEnh}      set Variable     ${lteNrDssFastAllocPerfEnh}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

Update DSS superfast_allocation with "${superfast_allocation}" into "${testParam}"
   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.scfFile.nrdsslte.actLteNrDssFastAlloc}      set Variable     ${superfast_allocation}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

Update DSS superfast_allocation with
   [Arguments]         ${testParam}     ${superfast_allocation}=false
   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.scfFile.nrdsslte.actLteNrDssFastAlloc}      set Variable     ${superfast_allocation}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

Update assigned_dl_maximum_share_to_nr with "${assigned_dl_maximum_share_to_nr}" into "${testParam}"
   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.seq.assigned_dl_maximum_share_to_nr}      set Variable     ${assigned_dl_maximum_share_to_nr}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

Update assigned_dl_maximum_share_to_nr with
   [Arguments]         ${testParam}     ${assigned_dl_maximum_share_to_nr}=70
   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.seq.assigned_dl_maximum_share_to_nr}      set Variable     ${assigned_dl_maximum_share_to_nr}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}


Update CatMinfo with ${CatMinfo} into "${testParam}"
   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.seq.CatMinfo}      set Variable     ${CatMinfo}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

Get actLteNrDssFastAlloc from SCF
    [Arguments]          ${nodeType}=Classical  ${CellId}=1
    BuiltIn.log     nodeType is ${nodeType}
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${actLteNrDssFastAlloc}	 scf.get_value_from_scf   p_name=actLteNrDssFastAlloc
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}/NRDSSLTE-1
    # ...              nodeType=${nodeType}
    [return]     ${actLteNrDssFastAlloc}

Get lteNrDssFastAllocPerfEnh from SCF
    [Arguments]          ${nodeType}=Classical  ${CellId}=1
    BuiltIn.log     nodeType is ${nodeType}
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${lteNrDssFastAllocPerfEnh}	 scf.get_value_from_scf   p_name=lteNrDssFastAllocPerfEnh
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}/NRDSSLTE-1
    # ...              nodeType=${nodeType}
    [return]     ${lteNrDssFastAllocPerfEnh}

Get actLteNrDssLteCatM from SCF
    [Arguments]          ${nodeType}=Classical  ${CellId}=1
    BuiltIn.log     nodeType is ${nodeType}
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${actLteNrDssLteCatM}	 scf.get_value_from_scf   p_name=actLteNrDssLteCatM
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}/NRDSSLTE-1
    # ...              nodeType=${nodeType}
    [return]     ${actLteNrDssLteCatM}

Get actSlowPrbPooling from SCF
    [Arguments]          ${nodeType}=Classical  ${CellId}=1
    BuiltIn.log     nodeType is ${nodeType}
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1
    ${actSlowPrbPooling}	 scf.get_value_from_scf   p_name=actSlowPrbPooling
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...              nodeType=${nodeType}
    [return]     ${actSlowPrbPooling}

