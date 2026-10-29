"""
:copyright: Nokia Networks
:author: Lixia Tang
:contact: lixia.tang@nokia-sbell.com
"""

import os
from taf.sbts.oam.coam.admin import admin


def get_admin_cells_mrbts(connection):
    """
    Returns dist_name values for all cells as a list
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: list of dist_name values for all cells from admin info model
    :rtype: (list of str)
    """
    adm = admin()
    subcells_info_output = adm.get_subcells_info(connection=connection)

    dist_name_list = []

    for cell_groups, cell_groups_values in subcells_info_output.items():
        for nr_cell, nr_cell_values in cell_groups_values.items():
            dist_name_list.append(nr_cell_values['NRCELL_R']['distName'])
    return dist_name_list
