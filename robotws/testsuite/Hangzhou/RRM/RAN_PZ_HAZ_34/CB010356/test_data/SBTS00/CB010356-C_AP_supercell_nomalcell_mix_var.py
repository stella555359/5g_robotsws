NRPLMNDNLIST = "MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3,MRBTS-1/NRBTS-1/NRPLMN-4"

PARAMS_IN_SCF = [
    # 10356 disabled
    "NRCELL:actHPPosMethodOptList=disabled",
    # nGRanAccessPointPosition mapping to normal cell subcell and supercell-1 subcell-0
    "NRCELL:nGRanAccessPointPosition:confidence=100|altitude=0",
    "NRCELL:nGRanAccessPointPosition:degreesOfLatitude=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:degreesOfLongitude=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:directionOfAltitude=Height|altitude=0",
    "NRCELL:nGRanAccessPointPosition:latitudeSign=North|altitude=0",
    "NRCELL:nGRanAccessPointPosition:orientationOfMajorAxis=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:uncertaintyAltitude=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:uncertaintySemiMajor=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:uncertaintySemiMinor=0|altitude=0",
    # nGRanAccessPointPosition mapping to supercell-1 subcell-1
    "NRCELL-1:nGRanAccessPointPosition:confidence=100|altitude=1",
    "NRCELL-1:nGRanAccessPointPosition:degreesOfLatitude=2|altitude=1",
    "NRCELL-1:nGRanAccessPointPosition:degreesOfLongitude=3|altitude=1",
    "NRCELL-1:nGRanAccessPointPosition:directionOfAltitude=Height|altitude=1",
    "NRCELL-1:nGRanAccessPointPosition:latitudeSign=North|altitude=1",
    "NRCELL-1:nGRanAccessPointPosition:orientationOfMajorAxis=4|altitude=1",
    "NRCELL-1:nGRanAccessPointPosition:uncertaintyAltitude=5|altitude=1",
    "NRCELL-1:nGRanAccessPointPosition:uncertaintySemiMajor=6|altitude=1",
    "NRCELL-1:nGRanAccessPointPosition:uncertaintySemiMinor=7|altitude=1",
    # SRS setting
    "NRCELL:srsForPositioning:comb=comb2",
    "NRCELL:srsForPositioning:cSRS=0",
    "NRCELL:srsForPositioning:numberOfCS=4 cycle shifts",
    "NRCELL:srsForPositioning:srsUePeriodicity=slots40",
    # sFNInitialisationTime related param
    "NRCELL:timingAdvanceOffset=n25600",
    # NRPOSINFO mapping to supercell-1 subcell
    "NRCELL-1/NRPOSINFO-1",
    "NRCELL-1/NRPOSINFO-2",
    # NRPOSINFO mapping to normal cell-2/4 subcell
    "NRCELL-2/NRPOSINFO-1",
    "NRCELL-4/NRPOSINFO-1",

    # ransharing 5GC001630
    "NRBTS-1:actRanSharing=true",
    "NRBTS-1:actRanSharingEnh=max_10_PLMNs",
    "NRBTS-1:actNgcFlexSaMode=true",
    "delete:NRCELL:trackingAreaDN",
    "delete:NRCELL:configuredEpsTac",

    # Multi AMF and PLMN and NRPLMNSET_SA_NSA
    "SERVEDAMF-1:amfIPAddress=10.0.1.1",
    "SERVEDAMF-2:amfIPAddress=10.0.1.102",
    "SERVEDAMF-3:amfIPAddress=10.0.1.103",
    "NRPLMN-1:mcc=311",
    "NRPLMN-1:mnc=489",
    "NRPLMN-1:mncLength=3",
    "NRPLMN-2:mcc=311",
    "NRPLMN-2:mnc=402",
    "NRPLMN-2:mncLength=3",
    "NRPLMN-3:mcc=311",
    "NRPLMN-3:mnc=403",
    "NRPLMN-3:mncLength=3",
    "NRPLMN-4:mcc=311",
    "NRPLMN-4:mnc=404",
    "NRPLMN-4:mncLength=3",
    "NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200",
    f"NRCELL/NRPLMNSET_SA-1:nrPlmnDNList={NRPLMNDNLIST}",

    # SNSSAI,TRACKINGAREA
    f"SNSSAI-1:nrPlmnDNList={NRPLMNDNLIST}",
    "TRACKINGAREA-200:fiveGsTac=200",
    "TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1",
]

Lock_ALL_AMF = [
    "SERVEDAMF-1:administrativeState=Locked",
    "SERVEDAMF-2:administrativeState=Locked",
    "SERVEDAMF-3:administrativeState=Locked",
]

Unlock_ALL_AMF = [
    "SERVEDAMF-1:administrativeState=Unlocked",
    "SERVEDAMF-2:administrativeState=Unlocked",
    "SERVEDAMF-3:administrativeState=Unlocked",
]

Lock_AMF1_Unlock_NRCells = [
    "SERVEDAMF-1:administrativeState=Locked",
    "NRCELL:administrativeState=Unlocked"
]

if __name__ == "__main__":
    print("hello")
