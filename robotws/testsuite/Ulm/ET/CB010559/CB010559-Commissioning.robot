*** Settings ***
Documentation
...    author:
...    Team:
...    Email:
...    Description: Keywords for CB010559 commissioning

Resource    ../resources/SQD65/sqd65_commissioning.robot

*** Variables ***

${SCF}                  scf_10559-A.xml
${NIDD_VERSION}         NRBTSCL26R1_2520_101
&{plmn_tmo}             mcc=310  mnc=260  mncLength=3

*** Keywords ***

Commissioning
    scf.Load Scf        ${P_ORIG_SCF}
    Add NRADJGNB        nrAdjGnbId=1     gNodeBId=${TGT_GNB['apId']}
    Add NRADJGNB        nrAdjGnbId=2     gNodeBId=${OTH_GNB['apId']}
    Add NRADJNRCELL     gNB=${TGT_GNB}
    Add NRADJNRCELL     gNB=${OTH_GNB}
    Add NRREL           nrRelId=1   gNodeBId=1  lcrId=3   # intra gNB HO
    Add NRREL           nrRelId=2   gNodeBId=3  lcrId=${TGT_GNB['nrci']}
    Add NRREL           nrRelId=3   gNodeBId=4  lcrId=${OTH_GNB['nrci']}
    Add XNLINK          xnLinkId=1  cPlaneIpAddr=${TGT_GNB['xnIpAddr']}
    Add XNLINK          xnLinkId=2  cPlaneIpAddr=${OTH_GNB['xnIpAddr']}
    Enable Tracing
    Enable VoNR
    Set Element         NRBTS-1/NRADJNRCELL-1           lcrId                3
    Set Element         NRBTS-1/NRADJNRCELL-1           physCellId           53
    Set Element         NRBTS-1                         actRrcRREUnprepgNB   intergNB
    Set Element         MNL-1/MNLENT-1/PMCADM-1         reportingIntervalPm  5min
    Set Element         NRBTS-1/NRPMRNL-1               miNrRRCC             5min
    Set Element         NRBTS-1/NRPMRNL-1               miNrRRCD             5min
    ${ts_conf_dir}=     Get Test Suite Config Directory
    scf.Save Scf        ${ts_conf_dir}/${SCF}
    Execute Full Commissioning    gnb_id=0    scf_path=${ts_conf_dir}/${SCF}

Add NRADJGNB
    [Arguments]  ${nrAdjGnbId}=1  ${gNodeBId}=3
    ${dist_name}=             Set Variable    NRBTS-1/NRADJGNB-${nrAdjGnbId}
    Set Object                class_name=NRADJGNB   dist_name=${dist_name}
    FOR   ${p_name}                         ${value}      IN
    ...   administrativeState               Unlocked
    ...   gNbIdLength                       22
    ...   gNodeBId                          ${gNodeBId}
    ...   gNodeBIdCtrl                      oamControlled
    ...   xnLinkRef                         ${nrAdjGnbId}
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.Add List To Scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.Add Item To List      dist_name=${dist_name}    list_name=gnbPlmn       elements=${plmn_tmo}


Add NRADJNRCELL
    [Arguments]  ${gNB}=${TGT_GNB}
    ${dist_name}=             Set Variable             NRBTS-1/NRADJNRCELL-${gNB['apId']}
    Set Object                class_name=NRADJNRCELL   dist_name=${dist_name}
    FOR   ${p_name}                         ${value}      IN
    ...   cellDepType                       SA+NSA
    ...   fiveGsTac                         200
    ...   freqBandIndicatorNR               ${gNB['freqband']}
    ...   gNbId                             ${gNB['apId']}
    ...   gNbIdLength                       22
    ...   lcrId                             ${gNB['nrci']}
    ...   nrarfcn                           ${gNB['nrarfcn']}
    ...   physCellId                        ${gNB['pci']}
    ...   ssbFrequency                      ${gNB['ssbfreq']}
    ...   cellReservedForOperatorUse        notReserved
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.Add List To Scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.Add Item To List      dist_name=${dist_name}    list_name=gnbPlmn       elements=${plmn_tmo}

Add NRREL
    [Arguments]  ${nrRelId}=1  ${gNodeBId}=3  ${lcrId}=48
    ${dist_name}=             Set Variable             NRBTS-1/NRCELL-1/NRREL-${nrRelId}
    Set Object                class_name=NRREL         dist_name=${dist_name}
    FOR   ${p_name}                         ${value}      IN
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
    scf.Add List To Scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.Add Item To List      dist_name=${dist_name}    list_name=gnbPlmn       elements=${plmn_tmo}

Add XNLINK
    [Arguments]  ${xnLinkId}=1  ${cPlaneIpAddr}=10.0.1.7
    ${dist_name}=             Set Variable             NRBTS-1/XNLINK-${xnLinkId}
    Set Object                class_name=XNLINK        dist_name=${dist_name}
    FOR   ${p_name}           ${value}      IN
    ...   cPlaneIpAddr        ${cPlaneIpAddr}
    ...   cPlaneIpAddrCtrl    oamControlled
    Set Element   ${dist_name}  ${p_name}  ${value}
    END

Enable Tracing
    Set Element         MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1  actInternalTrace  true
    Set Element         MRBTS-1/MNL-1/TCEADM-1/TCE-2       tceIpAddress      10.0.1.1
    Set Element         MRBTS-1/MNL-1/TCEADM-1/TCE-2       tcePortNumber     ${TCE_PORT_NUMBER}
    Set Element         MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2   localIpPrefixLength  28

Enable VoNR
    ${cell_nbr}   testline.Get Number Of Cells  cell_type=NRCEL
    ${cell_list}  scf.Get All Dist Names Of Specific Class  mo_class=NRCELL
    ${cell_nbr2}  Get Length  ${cell_list}
    FOR  ${id}  IN RANGE  1   ${cell_nbr}+1
       Set Element   NRBTS-1/NRCELL-${id}  actVoNR               true
       Set Element   NRBTS-1/NRCELL-${id}  actEmergencyCall      true
       Set Element   NRBTS-1/NRCELL-${id}  emergencyCallFails    true
       Set Element   NRBTS-1/NRCELL-${id}  emergencyCallLimServ  true
    END
