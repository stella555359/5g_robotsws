"""
Author: Dandan Fang
Documentation: This file is used to define the template for NIDD parameters
"""
import json
# ------------------------SCF----------------------------------
# For cells: SCF Modify

CNI99270_IWK_FOR_ALL_CELLS = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"actCsirsMultiplexing",
            "value":"true"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"actPerCsiReportBundlingTddFr1",
            "value":"true"}}
]
'''
