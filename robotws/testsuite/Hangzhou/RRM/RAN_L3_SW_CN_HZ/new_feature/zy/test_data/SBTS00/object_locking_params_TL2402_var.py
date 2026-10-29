# ############################## for PARAMS_IN_SCF ##############################
PARAMS_IN_SCF = [
    # 10356/10332 disabled
    "NRCELL:actHPPosMethodOptList=disabled",
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
    # SRS setting
    "NRCELL:srsForPositioning:comb=comb2",
    "NRCELL:srsForPositioning:cSRS=0",
    "NRCELL:srsForPositioning:numberOfCS=4 cycle shifts",
    "NRCELL:srsForPositioning:srsUePeriodicity=slots40",
]

# ############################## for delta commission ##############################
DISABLE_10332_IN_ALL_CELLS = "NRCELL:actHPPosMethodOptList=disabled"
