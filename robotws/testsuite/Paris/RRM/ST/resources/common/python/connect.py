"""
Module with help functions for connections
"""


def get_test_pc_for_nodeb(tl, nodeb):
    return [test_pc for test_pc in tl.test_pcs for obj in test_pc.connections if obj is nodeb][0]
