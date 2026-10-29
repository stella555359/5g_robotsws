PARAMS_IN_SCF = [
    # 10332 enabled
    "NRCELL-3:actHPPosMethodOptList=UL-TDOA",
    "NRCELL-4:actHPPosMethodOptList=UL-TDOA",
    "NRCELL-5:actHPPosMethodOptList=UL-TDOA",
    "NRCELL-6:actHPPosMethodOptList=UL-TDOA",
    # nGRanAccessPointPosition mapping to subcell
    "NRCELL:nGRanAccessPointPosition:confidence=100|altitude=0",
    "NRCELL:nGRanAccessPointPosition:degreesOfLatitude=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:degreesOfLongitude=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:directionOfAltitude=Height|altitude=0",
    "NRCELL:nGRanAccessPointPosition:latitudeSign=North|altitude=0",
    "NRCELL:nGRanAccessPointPosition:orientationOfMajorAxis=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:uncertaintyAltitude=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:uncertaintySemiMajor=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:uncertaintySemiMinor=0|altitude=0",
    # SRS setting
    "NRCELL-2:srsForPositioning:comb=comb2",
    "NRCELL-2:srsForPositioning:cSRS=0",
    "NRCELL-2:srsForPositioning:numberOfCS=4 cycle shifts",
    "NRCELL-2:srsForPositioning:srsUePeriodicity=slots40",
    "NRCELL-3:srsForPositioning:comb=comb2",
    "NRCELL-3:srsForPositioning:cSRS=0",
    "NRCELL-3:srsForPositioning:numberOfCS=4 cycle shifts",
    "NRCELL-3:srsForPositioning:srsUePeriodicity=slots5",
    "NRCELL-4:srsForPositioning:comb=comb2",
    "NRCELL-4:srsForPositioning:cSRS=0",
    "NRCELL-4:srsForPositioning:numberOfCS=2 cycle shifts",
    "NRCELL-4:srsForPositioning:srsUePeriodicity=slots2560",
    "NRCELL-5:srsForPositioning:comb=comb4",
    "NRCELL-5:srsForPositioning:cSRS=63",
    "NRCELL-5:srsForPositioning:numberOfCS=4 cycle shifts",
    "NRCELL-5:srsForPositioning:srsUePeriodicity=slots20",
    "NRCELL-6:srsForPositioning:comb=comb4",
    "NRCELL-6:srsForPositioning:cSRS=63",
    "NRCELL-6:srsForPositioning:numberOfCS=2 cycle shifts",
    "NRCELL-6:srsForPositioning:srsUePeriodicity=slots2560",
    # sFNInitialisationTime related param
    "NRCELL:timingAdvanceOffset=n25600",
    # NRPOSINFO mapping to subcell
    "NRCELL/NRPOSINFO-1",
]

Activate_ULTDOA = [
    "NRCELL-2:actHPPosMethodOptList=UL-TDOA",
]

Deactivate_ULTDOA = [
    "NRCELL-2:actHPPosMethodOptList=disabled",
]


if __name__ == "__main__":
    print("hello")
