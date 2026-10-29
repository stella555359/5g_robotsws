"""
:copyright: Nokia Networks
:author: Grzegorz Kaczor
:contact: grzegorz.kaczor@nokia.com
"""

cell_001F = {
                "id": 1,
                "attenuators": [
                    {
                        "attenuator_id": '0',
                        'ports': [1, 20]
                    }
                ],
                "throughput_dl": "204",
                "throughput_ul": "120",
                "technology": "NR"
            }


cell_002F = {
                "id": 2,
                "attenuators": [
                    {
                        "attenuator_id": '0',
                        'ports': [1, 2]
                    }
                ],
                "throughput_dl": "160",
                "throughput_ul": "70",
                "technology": "NR"
            }


cell_003F = {
                "id": 3,
                "attenuators": [
                    {
                        "attenuator_id": '0',
                        'ports': [13, 14, 15, 16]
                    }
                ],
                "throughput_dl": "510",
                "throughput_ul": "170",
                "technology": "NR"
            }


cell_004F = {
                "id": 4,
                "attenuators": [
                    {
                        "attenuator_id": '0',
                        'ports': [3, 4]
                    }
                ],
                "throughput_dl": "185",
                "throughput_ul": "100",
                "technology": "NR"
            }


cell_235F = {
                "id": 235,
                "attenuators": [
                    {
                        "attenuator_id": '0',
                        'ports': [1, 2, 3, 4]
                    }
                ],
                "throughput_dl": "950",
                "throughput_ul": "106",
                "technology": "NR"
            }


cell_236F = {
                "id": 236,
                "attenuators": [
                    {
                        "attenuator_id": '0',
                        'ports': [5, 6, 7, 8]
                    }
                ],
                "throughput_dl": "950",
                "throughput_ul": "241",
                "technology": "NR"
            }


cell_237F = {
                "id": 237,
                "attenuators": [
                    {
                        "attenuator_id": '0',
                        'ports': [9, 10, 11, 12]
                    }
                ],
                "throughput_dl": "950",
                "throughput_ul": "106",
                "technology": "NR"
            }


cell_002C = {
                "id": 2,
                "attenuators": [
                    {
                        "attenuator_id": '0',
                        'ports': [1, 2]
                    }
                ],
                "throughput_dl": "162",
                "throughput_ul": "70",
                "technology": "NR",
                "cells_to_block": [123]
            }


cell_123C = {
                "id": 123,
                "attenuators": [
                    {
                        "attenuator_id": '0',
                        'ports': [1, 2]
                    }
                ],
                "throughput_dl": "170",
                "throughput_ul": "62",
                "technology": "LTE",
                "cells_to_block": [2, 31, 3]
            }


cell_134C = {
                "id": 134,
                "attenuators": [
                    {
                        "attenuator_id": '0',
                        'ports': [3, 4]
                    }
                ],
                "throughput_dl": "170",
                "throughput_ul": "62",
                "technology": "LTE",
                "cells_to_block": [3, 31]
            }


cell_003C = {
                "id": 3,
                "attenuators": [
                    {
                        "attenuator_id": '0',
                        'ports': [13, 14, 15, 16]
                    }
                ],
                "throughput_dl": "410",
                "throughput_ul": "110",
                "technology": "NR",
                "cells_to_block": [31, 133]
            }


cell_031C = {
                "id": 31,
                "attenuators": [
                    {
                        "attenuator_id": '0',
                        'ports': [15, 16]
                    }
                ],
                "throughput_dl": "122",
                "throughput_ul": "52",
                "technology": "NR",
                "cells_to_block": [3, 133]
            }


cell_133C = {
                "id": 133,
                "attenuators": [
                    {
                        "attenuator_id": '0',
                        'ports': [13, 14]
                    }
                ],
                "throughput_dl": "170",
                "throughput_ul": "62",
                "technology": "LTE",
                "cells_to_block": [3, 31]
            }

mapping = {
    "C": [
            cell_002C,
            cell_134C,
            cell_003C,
            cell_133C
    ],
    "F": [
            cell_002F,
            cell_003F,
            cell_236F
    ]
}
