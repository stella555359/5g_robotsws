delta_parameter_a = [
    {

        "distName": "MRBTS-{}/NRBTS-{}/NRCELL-1",

        "operation": "update",

        "parameters":
            [
                {

                    "parameterName": "actHPPosMethodOptList",

                    "value": ["disabled"],

                    "operation": "update",

                }
            ],

    }
]

delta_parameter_b = [
    {
        "distName": "MRBTS-75175/NRBTS-75175/NRCELL-0",
        "operation": "update",

        "parameters":
            [
                {
                    "parameterName": "actHPPosMethodOptList",
                    "value": ["UL-TDOA"],
                    "operation": "update"},

                {
                    "parameterName": "nGRanAccessPointPosition",
                    "value": "",
                    "operation": "delete"},

                {
                    "parameterName": "srsForPositioning",
                    "value":
                        [
                            {

                                "comb": "comb2",
                                "cSRS": "15",
                                "numberOfCS": "4 cycle shifts",
                                "srsUePeriodicity": "slots40"
                            }
                        ],

                    "operation": "update"}
            ]
    },

    {
        "distName": "MRBTS-75175/NRBTS-75175/NRCELL-1",
        "operation": "update",

        "parameters": [
            {
                "parameterName": "actHPPosMethodOptList",
                "value": ["UL-TDOA"],

                "operation": "update"},

            {
                "parameterName": "nGRanAccessPointPosition",
                "value": "",

                "operation": "delete"},
            {"parameterName": "srsForPositioning",

             "value":
                 [
                     {
                         "comb": "comb2",
                         "cSRS": "13",

                         "numberOfCS": "4 cycle shifts",

                         "srsUePeriodicity": "slots40"
                     }
                 ],

             "operation": "update"}
        ]
    },

    {
        "distName": "MRBTS-75175/NRBTS-75175/NRCELL-2",
        "operation": "update",

        "parameters": [
            {
                "parameterName": "actHPPosMethodOptList",
                "value": ["UL-TDOA"],
                "operation": "update"
            },

            {

                "parameterName": "nGRanAccessPointPosition",
                "value": "",
                "operation": "delete"
            },

            {
                "parameterName": "srsForPositioning",
                "value":
                    [
                        {
                            "comb": "comb2",
                            "cSRS": "15",
                            "numberOfCS": "4 cycle shifts",
                            "srsUePeriodicity": "slots40"}
                    ],

                "operation": "update"
            }
        ]
    },
    {"distName": "MRBTS-75175/NRBTS-75175/NRCELL-3",
     "operation": "update",

     "parameters":
         [
             {

                 "parameterName": "actHPPosMethodOptList",
                 "value": ["UL-TDOA"],

                 "operation": "update"
             },

             {

                 "parameterName": "nGRanAccessPointPosition",
                 "value": "",

                 "operation": "delete"},

             {

                 "parameterName": "srsForPositioning",

                 "value":
                     [
                         {

                             "comb": "comb2",
                             "cSRS": "13",

                             "numberOfCS": "4 cycle shifts",

                             "srsUePeriodicity": "slots40"
                         }
                     ],

                 "operation": "update"}
         ]
     },

    {
        "distName": "MRBTS-75175/NRBTS-75175/NRCELL-0/NRPOSINFO-1",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nGRanAccessPointPosition",
                    "value":
                        [
                            {

                                "altitude": "260",
                                "confidence": "100",
                                "degreesOfLatitude": "1",
                                "degreesOfLongitude": "1",

                                "directionOfAltitude": "Height",
                                "latitudeSign": "North",
                                "orientationOfMajorAxis": "1",

                                "uncertaintyAltitude": "1",
                                "uncertaintySemiMajor": "1",
                                "uncertaintySemiMinor": "1"
                            }
                        ],

                    "operation": "update"}
            ]
    },

    {
        "distName": "MRBTS-75175/NRBTS-75175/NRCELL-1/NRPOSINFO-1",
        "operation": "create",

        "parameters":
            [
                {
                    "parameterName": "nGRanAccessPointPosition",
                    "value":
                        [
                            {

                                "altitude": "260",
                                "confidence": "100",
                                "degreesOfLatitude": "1",

                                "degreesOfLongitude": "1",
                                "directionOfAltitude": "Height",

                                "latitudeSign": "North",
                                "orientationOfMajorAxis": "1",

                                "uncertaintyAltitude": "1",
                                "uncertaintySemiMajor": "1",

                                "uncertaintySemiMinor": "1"
                            }
                        ],

                    "operation": "update"
                }
            ]
    },

    {

        "distName": "MRBTS-75175/NRBTS-75175/NRCELL-2/NRPOSINFO-1",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nGRanAccessPointPosition",
                    "value":
                        [
                            {

                                "altitude": "260",
                                "confidence": "100",
                                "degreesOfLatitude": "1",
                                "degreesOfLongitude": "1",

                                "directionOfAltitude": "Height",
                                "latitudeSign": "North",
                                "orientationOfMajorAxis": "1",

                                "uncertaintyAltitude": "1",
                                "uncertaintySemiMajor": "1",
                                "uncertaintySemiMinor": "1"
                            }
                        ],

                    "operation": "update"}
            ]
    },

    {
        "distName": "MRBTS-75175/NRBTS-75175/NRCELL-3/NRPOSINFO-1",
        "operation": "create",

        "parameters":
            [
                {
                    "parameterName": "nGRanAccessPointPosition",
                    "value":
                        [
                            {
                                "altitude": "260",
                                "confidence": "100",
                                "degreesOfLatitude": "1",

                                "degreesOfLongitude": "1",
                                "directionOfAltitude": "Height",

                                "latitudeSign": "North",
                                "orientationOfMajorAxis": "1",

                                "uncertaintyAltitude": "1",
                                "uncertaintySemiMajor": "1",

                                "uncertaintySemiMinor": "1"
                            }
                        ],

                    "operation": "update"
                }
            ]
    }
]
