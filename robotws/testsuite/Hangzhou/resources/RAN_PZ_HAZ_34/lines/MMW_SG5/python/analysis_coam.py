# -*- coding: utf-8 -*-
# @Time    : 2024/3/20 17:52
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : analysis_coam.py
# @Software: PyCharm
from taf.sbts.oam.coam.admin.interface import admin
import time


def get_cells_history_status(duration=300, interval_time=2, cell_type="nr", connection="GNB_OAM"):
    cells_status = {}
    for i in range(duration):
        cells_info = admin().get_cells_info(cell_type=cell_type, timeout=30, connection=connection)
        for cell_info in cells_info:
            cell_name = cell_info["id"]["configuration"].split("/")[-1]
            cell_status = cell_info["status"]["usageState"]
            if cell_name not in cells_status:
                cells_status[cell_name] = []
                cells_status[cell_name].append(cell_status)
            elif cells_status[cell_name][-1] != cell_status:
                cells_status[cell_name].append(cell_status)
        time.sleep(interval_time)
    print(cells_status)
    return cells_status
