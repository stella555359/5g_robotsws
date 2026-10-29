"""
Author: Tang Tony
Documentation: This file is used to define the template for NIDD parameters for align bwp
"""
import json
# ------------------------SCF----------------------------------
# For cells: SCF Modify


SCF_MODIFY_TEMPLATE_F20M = '''
[
    {{
            "dist_name":"{dist_name}/NRCELL_FDD-1",
            "p_name":"chBwDl",
            "value":"20MHz"}},
    {{
            "dist_name":"{dist_name}/NRCELL_FDD-1",
            "p_name":"chBwUl",
            "value":"20MHz"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"msg1FrequencyStart",
            "value":"13"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"0",
            "value":"{value}/BWP_PROFILE-{bwp_id_initial}"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"1",
            "value":"{value}/BWP_PROFILE-{bwp_id_dedicate}"}}
]
'''

SCF_MODIFY_TEMPLATE_T100M_1116 = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"chBw",
            "value":"100MHz"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"msg1FrequencyStart",
            "value":"30"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"reqMinNumPuschPrb",
            "value":"240"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"0",
            "value":"{value}/BWP_PROFILE-{bwp_id_initial}"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"1",
            "value":"{value}/BWP_PROFILE-{bwp_id_dedicate}"}}
]
'''

SCF_MODIFY_TEMPLATE_T60M_1116 = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"chBw",
            "value":"60MHz"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"msg1FrequencyStart",
            "value":"30"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"reqMinNumPuschPrb",
            "value":"126"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"0",
            "value":"{value}/BWP_PROFILE-{bwp_id_initial}"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"1",
            "value":"{value}/BWP_PROFILE-{bwp_id_dedicate}"}}
]
'''
