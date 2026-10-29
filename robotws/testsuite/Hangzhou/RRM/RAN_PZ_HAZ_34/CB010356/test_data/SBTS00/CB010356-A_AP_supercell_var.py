PARAMS_IN_SCF = [
    # 10356 enabled
    "NRCELL:actHPPosMethodOptList=disabled",
    # SRS setting
    "NRCELL:srsForPositioning:comb=comb2",
    "NRCELL:srsForPositioning:cSRS=0",
    "NRCELL:srsForPositioning:numberOfCS=4 cycle shifts",
    "NRCELL:srsForPositioning:srsUePeriodicity=slots40",
    # sFNInitialisationTime related param
    "NRCELL:timingAdvanceOffset=n25600",
    # NRPOSINFO mapping to subcell
    "NRCELL/NRPOSINFO-1",
    "NRCELL/NRPOSINFO-2",
]

CB010356_ngRanAccessPointPosition = [
    # nGRanAccessPointPosition mapping to subcell
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:confidence=100|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:degreesOfLatitude=0|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:degreesOfLongitude=0|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:directionOfAltitude=Height|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:latitudeSign=North|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:orientationOfMajorAxis=0|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:uncertaintyAltitude=0|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:uncertaintySemiMajor=0|altitude=0",
    "NRCELL/NRPOSINFO-1:nGRanAccessPointPosition:uncertaintySemiMinor=0|altitude=0",
    "NRCELL/NRPOSINFO-2:nGRanAccessPointPosition:confidence=100|altitude=1",
    "NRCELL/NRPOSINFO-2:nGRanAccessPointPosition:degreesOfLatitude=2|altitude=1",
    "NRCELL/NRPOSINFO-2:nGRanAccessPointPosition:degreesOfLongitude=3|altitude=1",
    "NRCELL/NRPOSINFO-2:nGRanAccessPointPosition:directionOfAltitude=Depth|altitude=1",
    "NRCELL/NRPOSINFO-2:nGRanAccessPointPosition:latitudeSign=South|altitude=1",
    "NRCELL/NRPOSINFO-2:nGRanAccessPointPosition:orientationOfMajorAxis=4|altitude=1",
    "NRCELL/NRPOSINFO-2:nGRanAccessPointPosition:uncertaintyAltitude=5|altitude=1",
    "NRCELL/NRPOSINFO-2:nGRanAccessPointPosition:uncertaintySemiMajor=6|altitude=1",
    "NRCELL/NRPOSINFO-2:nGRanAccessPointPosition:uncertaintySemiMinor=7|altitude=1",
    # 10356 enabled
    "NRCELL:actHPPosMethodOptList=UL-TDOA",
    "NRBTS:actLocationReportingSA=true",
]
if __name__ == "__main__":
    print("hello")
