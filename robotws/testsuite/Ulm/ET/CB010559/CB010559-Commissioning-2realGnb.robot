*** Settings ***
Documentation
...    author:
...    Team:
...    Email:
...    Description: Keywords for CB010559 commissioning

Resource    ../resources/SQD65/sqd65_commissioning.robot

*** Variables ***

${SCF}                  scf_10559-2realGnb
${NIDD_VERSION}         NRBTSCL26R1_2520_101

*** Keywords ***

Commissioning
    Source gNB
    Target gNB

Source gNB
    ${current_scf}=     Load Current SCF
    Add NRREL           nrRelId=2   gNodeBId=${TGT_GNB['nrBtsId']}  lcrId=${TGT_GNB['nrci']}  nrBtsId=${SRC_GNB['nrBtsId']}
    ...  nrcell=${SRC_GNB['nrci']}
    Add NRREL           nrRelId=3   gNodeBId=${OTH_GNB['nrBtsId']}  lcrId=${OTH_GNB['nrci']}  nrBtsId=${SRC_GNB['nrBtsId']}
    ...  nrcell=${SRC_GNB['nrci']}
    Add NRADJNRCELL     adj_gnb=${OTH_GNB}
    Add NRADJNRCELL     adj_gnb=${OTH2_GNB}
    Set Element         NRBTS-1/NRADJNRCELL-1      ssbFrequency         ${TGT_GNB['ssbfreq']}   # WA
    Adapt NRHOIF
    Common Settings
    Full Commissioning

Target gNB
    ${current_scf}=     Load Current SCF       gnb_id=${TGT_GNB['node']}
    Add NRADJNRCELL     nrBtsId=${TGT_GNB['nrBtsId']}  adj_gnb=${SRC_GNB}
    Add NRADJNRCELL     nrBtsId=${TGT_GNB['nrBtsId']}  adj_gnb=${OTH_GNB}
    Add NRREL           nrRelId=1   gNodeBId=${SRC_GNB['nrBtsId']}    lcrId=${SRC_GNB['nrci']}
    Add NRREL           nrRelId=2   gNodeBId=${OTH_GNB['nrBtsId']}    lcrId=${OTH_GNB['nrci']}
    Set Element         NRBTS-${TGT_GNB['nrBtsId']}/NRCELL-${TGT_GNB['nrci']}/NRHOIF-1  ssbFrequency       ${SRC_GNB['ssbfreq']}
    Common Settings     nrBtsId=${TGT_GNB['nrBtsId']}
    Full Commissioning  node=${TGT_GNB['node']}

Full Commissioning
    [Arguments]   ${node}=0
    ${ts_conf_dir}=               Get Test Suite Config Directory
    scf.save_scf                  ${ts_conf_dir}/${SCF}-gNB${node}.xml
    Execute full commissioning    gnb_id=${node}    scf_path=${ts_conf_dir}/${SCF}-gNB${node}.xml

Common Settings
    [Arguments]   ${nrBtsId}=${1}
    Set Element                 MRBTS-1/NRBTS-${nrBtsId}           actRrcRREUnprepgNB        intergNB
    Set Element                 MRBTS-1/MNL-1/AMGR-1/LUAC-1        webEMSessionLogoutTimer   7200
    Set Element                 MNL-1/MNLENT-1/PMCADM-1            reportingIntervalPm       5min
    Set Element                 NRBTS-${nrBtsId}/NRPMRNL-1         miNrRRCC                  5min
    Set Element                 NRBTS-${nrBtsId}/NRPMRNL-1         miNrRRCD                  5min
    Set Element                 NRBTS-${nrBtsId}/NRPMRNL-1         miNrNGC2                  5min
    Set Element                 MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1  actInternalTrace          true
    Set Element                 MRBTS-1/NRBTS-${nrBtsId}           actPCMDReport             true
    Set Element                 MRBTS-1/NRBTS-${nrBtsId}           actCellTraceReport        true
    Set Element                 MRBTS-1/NRBTS-${nrBtsId}           actIntraNRMRO             false
    Set Element                 MRBTS-1/NRBTS-${nrBtsId}/NRDU-1    actInterGnbCa             disabled
    Set Element                 MRBTS-1/NRBTS-${nrBtsId}           actIntraNrNgHo            sourceAndTarget
    Set Element                 MRBTS-1/NRBTS-${nrBtsId}           tNgRelocExecDeltN         3000
    Set Element                 MRBTS-1/NRBTS-${nrBtsId}           tNgRelocPrepN             2000
    Set Element                 MRBTS-1/NRBTS-${nrBtsId}           tNgRelocCancelN           2000
    Set Element                 MRBTS-1/NRBTS-${nrBtsId}           tNgRelocOverallN          3000
    Set Element                 MRBTS-1/NRBTS-${nrBtsId}           suppCnPartialAdNgHo       false
    Add NRADJGNB                nrBtsId=${nrBtsId}
    Add XNLINK                  nrBtsId=${nrBtsId}
    Add Trace Control Entity    tceIdentifier=${nrBtsId}
    Add Radio CU Trace Session  nrBtsId=${nrBtsId}
#    Enable VoNR

Add NRADJGNB
    [Arguments]  ${nrAdjGnbId}=${OTH_GNB['nrBtsId']}  ${nrBtsId}=1
    ${dist_name}=             Set Variable    NRBTS-${nrBtsId}/NRADJGNB-${nrAdjGnbId}
    Set Object                class_name=NRADJGNB   dist_name=${dist_name}
    FOR   ${p_name}                         ${value}      IN
    ...   administrativeState               Unlocked
    ...   gNbIdLength                       22
    ...   gNodeBId                          ${nrAdjGnbId}
    ...   gNodeBIdCtrl                      oamControlled
    ...   xnLinkRef                         ${nrAdjGnbId}
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn       elements=${plmn}

Add NRADJNRCELL
    [Arguments]  ${adj_gnb}  ${nrBtsId}=1
    ${dist_name}=             Set Variable             NRBTS-${nrBtsId}/NRADJNRCELL-${adj_gnb['nrci']}
    Set Object                class_name=NRADJNRCELL   dist_name=${dist_name}
    FOR   ${p_name}                         ${value}      IN
    ...   cellDepType                       SA+NSA
    ...   fiveGsTac                         200
    ...   freqBandIndicatorNR               ${adj_gnb['freqband']}
    ...   gNbId                             ${adj_gnb['nrBtsId']}
    ...   gNbIdLength                       22
    ...   lcrId                             ${adj_gnb['nrci']}
    ...   nrarfcn                           ${adj_gnb['nrarfcn']}
    ...   physCellId                        ${adj_gnb['pci']}
    ...   ssbFrequency                      ${adj_gnb['ssbfreq']}
    ...   cellReservedForOperatorUse        notReserved
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn       elements=${plmn}

Add NRREL
    [Arguments]  ${nrRelId}=1  ${gNodeBId}=4  ${lcrId}=4  ${nrBtsId}=${TGT_GNB['nrBtsId']}  ${nrcell}=${TGT_GNB['nrci']}
    ${dist_name}=             Set Variable             NRBTS-${nrBtsId}/NRCELL-${nrcell}/NRREL-${nrRelId}
    Set Object                class_name=NRREL         dist_name=${dist_name}
    FOR   ${p_name}                         ${value}   IN
    ...   cellIndividualSsbRsrpOffset       0dB
    ...   cellIndividualSsbRsrqOffset       0dB
    ...   gNbId                             ${gNodeBId}
    ...   gNbIdLength                       22
    ...   handoverAllowedSA                 allowed
    ...   handoverAllowedSARedCap           forbidden
    ...   isRplCellForPSCell                false
    ...   lcrId                             ${lcrId}
    ...   nrDcAllowed                       false
    ...   removeNotAllowed                  false
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn       elements=${plmn}

Adapt NRHOIF
    ${nrhoif1}         Set Variable             NRBTS-1/NRCELL-1/NRHOIF-1
    ${nrhoif2}         Set Variable             NRBTS-1/NRCELL-1/NRHOIF-2

    Set Element        ${nrhoif1}               freqBandIndicatorNR                ${TGT_GNB['freqband']}
    Set Element        ${nrhoif1}               ssbFrequency                       ${TGT_GNB['ssbfreq']}

    ${mo_exist}=       scf.Is Object In Scf     dist_name=${nrhoif2}
    IF                 ${mo_exist}              scf.Remove Mo With Descendant Mos  dist_name=${nrhoif2}
    scf.Clone MO with Descendant MOS            ${nrhoif1}                         ${nrhoif2}
    Set Element        ${nrhoif2}               freqBandIndicatorNR                ${OTH2_GNB['freqband']}
    Set Element        ${nrhoif2}               ssbFrequency                       ${OTH2_GNB['ssbfreq']}

Add XNLINK
    [Arguments]  ${xnLinkId}=${OTH_GNB['nrBtsId']}  ${cPlaneIpAddr}=${GNB3_XN_IP}  ${nrBtsId}=1
    ${dist_name}=             Set Variable             NRBTS-${nrBtsId}/XNLINK-${xnLinkId}
    Set Object                class_name=XNLINK        dist_name=${dist_name}
    FOR   ${p_name}           ${value}      IN
    ...   cPlaneIpAddr        ${cPlaneIpAddr}
    ...   cPlaneIpAddrCtrl    oamControlled
    Set Element   ${dist_name}  ${p_name}  ${value}
    END

Enable VoNR
    ${cell_nbr}   testline.Get Number Of Cells  cell_type=NRCEL
    ${cell_list}  scf.get_all_dist_names_of_specific_class  mo_class=NRCELL
    ${cell_nbr2}  Get Length  ${cell_list}
    FOR  ${id}  IN RANGE  1   ${cell_nbr}+1
       Set Element   NRBTS-1/NRCELL-${id}  actVoNR               true
       Set Element   NRBTS-1/NRCELL-${id}  actEmergencyCall      true
       Set Element   NRBTS-1/NRCELL-${id}  emergencyCallFails    true
       Set Element   NRBTS-1/NRCELL-${id}  emergencyCallLimServ  true
    END