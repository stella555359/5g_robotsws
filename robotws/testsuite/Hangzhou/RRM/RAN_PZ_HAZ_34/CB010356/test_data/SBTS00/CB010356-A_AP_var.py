PARAMS_IN_SCF = [
    # 10356 disabled
    "NRCELL:actHPPosMethodOptList=disabled",
    # nGRanAccessPointPosition
    "NRCELL:nGRanAccessPointPosition:altitude=0",
    "NRCELL:nGRanAccessPointPosition:confidence=100",
    "NRCELL:nGRanAccessPointPosition:degreesOfLatitude=0",
    "NRCELL:nGRanAccessPointPosition:degreesOfLongitude=0",
    "NRCELL:nGRanAccessPointPosition:directionOfAltitude=Height",
    "NRCELL:nGRanAccessPointPosition:latitudeSign=North",
    "NRCELL:nGRanAccessPointPosition:orientationOfMajorAxis=0",
    "NRCELL:nGRanAccessPointPosition:uncertaintyAltitude=0",
    "NRCELL:nGRanAccessPointPosition:uncertaintySemiMajor=0",
    "NRCELL:nGRanAccessPointPosition:uncertaintySemiMinor=0",
    # NRPOSINFO
    "NRCELL/NRPOSINFO-1",
    # SRS setting
    "NRCELL:srsForPositioning:comb=comb2",
    "NRCELL:srsForPositioning:cSRS=0",
    "NRCELL:srsForPositioning:numberOfCS=4 cycle shifts",
    "NRCELL:srsForPositioning:srsUePeriodicity=slots40",
    # sFNInitialisationTime related param
    "NRCELL:timingAdvanceOffset=n25600",
]

CB010356_3CELLS_ENABLE = [
    "NRCELL-4:actHPPosMethodOptList=UL-TDOA",
    "NRCELL-5:actHPPosMethodOptList=UL-TDOA",
    "NRCELL-6:actHPPosMethodOptList=UL-TDOA",
]

if __name__ == "__main__":
    print("hello")
