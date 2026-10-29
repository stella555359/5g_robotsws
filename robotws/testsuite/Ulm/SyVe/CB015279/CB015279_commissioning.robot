*** Settings ***
Documentation   Generic gNB Commissioning: CB015279
...             This is a Robot Test Suite for feature: CB015279
...             Feature:  CB015279_FR1_UL_CA_with_non-collocated_SCell
...             Author:  Antje Jooss
...             Team: MI MN RAN RD VRF ULM 4
...             Email: OU_MI_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com


Resource    ../resources/syve_commissioning.robot
Resource    ../resources/scf_info.robot
Library     taf.config.scf


*** Keywords ***
Execute GNB Delta Commission JSON For CB015279 GNB-0
    [Arguments]    ${nrbts_id}  ${lnbts_id}  ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}
    [Documentation]    Commissioning of gnb-0 for CB015279, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.

    scf_info.Set MNL Version String For Branch    basic_scf_name=${basic_scf_name_gnb_0}
    Log To Console  Start commissioning for gnb-${source_node_id}
    scf.Load SCF  ${basic_scf_name_gnb_${source_node_id}}


    # !!! sepecial attention to  \$ after e.g.  NRCELL-1  !!! if this is not given also NRCELL-11, NRCELL-15 ... are modified!
    # this wildcard behavior is not clear from taf documentation.

    @{GNB_PARAMS_IN_SCF}   Create List
    ...  modify:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}\$:actEnDcDssCellsCoex=LTE DSS SCell band blacklist
    ...  modify:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}\$:actLteNrDss=true
    ...  modify:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2\$:allowTrafficConcentration=false
    ...  modify:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2\$:lteNrDssMode=DSS_Phase_III
    ...  modify:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/LNCEL_FDD-0\$:blankedPucch=8
    ...  modify:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/LNCEL_FDD-0\$:dlChBw=10 MHz
    ...  modify:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/LNCEL_FDD-0\$:earfcnDL=68686
    ...  modify:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/LNCEL_FDD-0\$:earfcnUL=133222
    ...  modify:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/LNCEL_FDD-0\$:ulChBw=10 MHz
    ...  modify:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/LNCEL_FDD-0/APUCCH_FDD-0\$:selectPrachRegion=InnerUpperEdge
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}\$:actLteNrDss=true
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:actCsiImRandomizationFddNonDss=false
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:actDlCqiIncrRestriction=false
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:actDlPowerBoost=disabled
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:actDownSampling=false
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:actLAForHiReliab=false
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:expectedCellSize=10km
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:lteNrDssMode=DSS_Phase_3
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:msg1FrequencyStart=7
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:pagingOffset=2
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:prachConfigurationIndex=40
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1\$:type0SearchSpaceConfigurationIndex=15
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRCELL_FDD-1\$:chBwDl=10MHz
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRCELL_FDD-1\$:chBwUl=10MHz
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRCELL_FDD-1\$:nrarfcnDl=125400
    ...  modify:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRCELL_FDD-1\$:nrarfcnUl=134600
    ...  add:[NOKLTE:DSSNR, MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0, NRBTSCL${version}, create]
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:actAsymmetricDss=false
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:actLteNrDssFastAlloc=false
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:actLteNrDssVoNr=false
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:actPrbBlankingAtBothEdges=false
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:dssNrCellId=1
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:lteNrDssFastAllocPerfEnh=disabled
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:maxLteDssSibRb=0
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:lteNrDssDlRatio
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:lteNrDssDlRatio:{"dlResourceSharingAlgo":"DL PRB load based"}
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:lteNrDssDlRatio:dssLteRelSchedWeight=1
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:lteNrDssDlRatio:dssNrRelSchedWeight=1
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:lteNrDssDlRatio:maxNrDssRatio=70
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:lteNrDssDlRatio:minNrDssRatio=5
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:lteNrDssUlRatio
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:lteNrDssUlRatio:{"dssLteRelSchedWeight":"1"}
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:lteNrDssUlRatio:dssNrRelSchedWeight=1
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:lteNrDssUlRatio:maxNrDssRatio=70
    ...  add:MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0:lteNrDssUlRatio:minNrDssRatio=5
    ...  add:[NOKLTE:CRMINFO, MRBTS-${nrbts_id}/LNBTS-${lnbts_id}/LNCEL-2/DSSNR-0/CRMINFO-0, NRBTSCL${version}, create]
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1:actEnhHOCommandHandling=false
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1:pdcchAutoConfig:pucchSizeLTE=4
    ...  add[com.nokia.srbts.nrbts:NRDSSLTE, MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1, NRBTSCL${version}, create]
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:actAsymmetricDss=false
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:actDssMsg3Enh=true
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:actLteNrDssFastAlloc=false
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:actLteNrDssLteCatM=false
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:actLteNrDssPdcchLoadResAlloc=false
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:actRateMatchedCsiIm=true
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:actUlAdaptReTxEnhDss=false
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:dssDlTPollRetr=ms100
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:dssDlTProhib=ms50
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:dssMaxNumberOfDlDcis=1
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:dssUlTPollRetr=ms100
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:dssUlTProhib=ms150
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:eNodeBId=452271
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:lcrId=2
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:lteNrDssFastAllocPerfEnh=disabled
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:ltePhyCellId=2
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:ssbPosition=pos1
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:enbPlmn
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:enbPlmn:{"mcc":"540"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:enbPlmn:mnc=1
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:enbPlmn:mncLength=2
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:lteNrDssDlRatio
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:lteNrDssDlRatio:{"dlResourceSharingAlgo":"DL PRB load based"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:lteNrDssDlRatio:maxNrDssRatio=70
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:lteNrDssDlRatio:minNrDssRatio=5
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:lteNrDssUlRatio
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:lteNrDssUlRatio:{"maxNrDssRatio":"70"}
    ...  add:MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1/NRDSSLTE-1:lteNrDssUlRatio:minNrDssRatio=5

    scf.Perform SCF Modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.Save SCF  ${target_scf_name_gnb}

    ${actMeasBasedSCellAdditionSa_elements}  Create List
    ...    A4-based

    scf.Modify SCF Element
    ...  value=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/BWP_PROFILE-1700
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...  p_name=bwpDN
    ...  list_name=cellBwpList
    ...  index=0

    scf.Modify SCF Element
    ...  value=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/BWP_PROFILE-1701
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...  p_name=bwpDN
    ...  list_name=cellBwpList
    ...  index=1

    scf.Modify SCF Element
    ...  value=false
    ...  dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...  p_name=actUpperThrAckNackHrFiltering
    ...  list_name=cellBwpList
    ...  index=1

    scf.Save SCF  ${target_scf_name_gnb}
    scf.Calculate Delta SCF
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${source_node_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}
