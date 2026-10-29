"""
Author: Lingxue Cui For CB010413 CB008985
Documentation: This file is used to define the template for NIDD parameters
"""


CU_SCF_MODIFY_DISABLE_CIPHER = '''
[
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "nea0",
        "value": "0"}},
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "nea1_128",
        "value": "3"}},
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "nea2_128",
        "value": "2"}},
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "nea3_128",
        "value": "1"}},
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "nia0",
        "value": "0"}},
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "nia1_128",
        "value": "3"}},
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "nia2_128",
        "value": "2"}},
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "nia3_128",
        "value": "1"}}
]
'''


DU_SCF_MODIFY_CELL = '''
[
    {{
        "dist_name": "{dist_name}",
        "p_name": "actSuperCell",
        "value": "true"}},
    {{
        "dist_name": "{dist_name}",
        "p_name": "actBeamforming",
        "value": "false"}},
    {{
        "dist_name": "{dist_name}",
        "p_name": "numOfSubSectors",
        "value": "0sub-sector "}},
    {{
        "dist_name": "{dist_name}",
        "p_name": "nrCellType",
        "value": "4DL4UL"}},
    {{
        "dist_name": "{dist_name}",
        "p_name": "pucchModeSelect",
        "value": "longPucch"}},
    {{
        "dist_name": "{dist_name}",
        "p_name": "actCellCsiRsImTddNonBf",
        "value": "false"}}
]
'''
