"""
Author: Ding Binmei
Documentation: This file is used to define the template for NIDD parameters
"""
import json
# ------------------------SCF----------------------------------
# For cells: SCF Modify
SCF_MODIFY_TEMPLATE_FRAME_STRUCTURE_1116_0 = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"frameStructureType",
            "value":"tdLte"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"guardPeriodLength",
            "value":"6Symbols"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"lteToNrFrameShift",
            "value":"0ms"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"tdLteUlDlConfig",
            "value":"tdLteConfig2"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"ulDlDataSlotRatio",
            "value":"2/8"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"prachConfigurationIndex",
            "value":"97"}}
]
'''

SCF_MODIFY_TEMPLATE_FRAME_STRUCTURE_1116_3 = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"frameStructureType",
            "value":"tdLte"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"guardPeriodLength",
            "value":"6Symbols"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"lteToNrFrameShift",
            "value":"3ms"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"tdLteUlDlConfig",
            "value":"tdLteConfig2"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"ulDlDataSlotRatio",
            "value":"2/8"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"prachConfigurationIndex",
            "value":"160"}}
]
'''
