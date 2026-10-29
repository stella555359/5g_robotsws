import logging
import re
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations
from taf.rfrl.bts.devices.generic_bts import login_logout
import testsuite.Krakow.SISO.resources.ru_map_variables as rmv


class RuMap(GnbRuOperations):
    @login_logout
    def get_ru_map(self, bts_id=0, du_id=0):
        connection = self.rest_alias.format(bts_id, du_id)
        ru_mapping = []
        data = self.admin.get_detected_hw_info(connection=connection)
        for ru in data["radioModules"]["rmod"]:
            ant_ids = []
            cells_map = []
            ru_product_name = ru["productName"]
            ru_serial_number = ru["serialNumber"]
            ru_pos = rmv.ru_matrix_pos[str(ru_serial_number)]
            ru_id = int(re.search(r'-(?P<RU_ID>\d+)$', ru["id"]["internal"]).group('RU_ID'))
            for i in range(1, 5, 1):
                ant_ids.append(str(int(ru_pos) * 4 + i))
            print(ant_ids)
            cell_ids = self.admin.get_cell_mapping_by_module_id(module_id=ru["id"]["internal"],
                                                                connection=connection)
            for cell_id in cell_ids:
                used_ants_ids = set()
                cell_info = self.admin.get_cell_specific_info(cell_id=cell_id, connection=connection)
                cell_type = cell_info["nrCellType"]
                ports = ""
                if ru_product_name == "AHPB" or ru_product_name == "AHPH" or (ru_product_name == "FRIJ"
                                                                              and (cell_type == "2DL2UL"
                                                                                   or cell_type == "2DL4UL")):
                    exp_dl_tput = rmv.tput_value_for_freq_AHPB_AHPH_FRIJ[cell_info['chBwDl']]['exp_dl_tput']
                    exp_ul_tput = rmv.tput_value_for_freq_AHPB_AHPH_FRIJ[cell_info['chBwDl']]['exp_ul_tput']
                elif ru_product_name == "FRIJ" and cell_type == "4DL4UL":
                    exp_dl_tput = rmv.tput_value_for_freq_FRIJ_celltype_4DL4UL[cell_info['chBwDl']]['exp_dl_tput']
                    exp_ul_tput = rmv.tput_value_for_freq_FRIJ_celltype_4DL4UL[cell_info['chBwDl']]['exp_ul_tput']
                else:
                    exp_dl_tput = rmv.exp_dl_tput
                    exp_ul_tput = rmv.exp_ul_tput
                for ant_id in cell_info["carrierList"]:
                    used_ants_ids.add(int(
                        re.search(r'-(?P<ANT_ID>\d+)$', ant_id["antennaLineId"]["internal"]).group('ANT_ID')))

                if cell_type == "2DL2UL" or ru_product_name == "AHPB" or ru_product_name == "AHPH":
                    if used_ants_ids == {3, 4}:
                        ports = str(ant_ids[2]) + ":" + str(ant_ids[3]) + ":0:0"
                    else:
                        ports = str(ant_ids[0]) + ":" + str(ant_ids[1]) + ":0:0"
                else:
                    for i in range(0, 4):
                        ports += str(ant_ids[i])
                        ports += ":"
                cell_map = {
                    "cell_id": cell_info["globalCellId"],
                    "nr_cell_type": cell_type,
                    "chBwDl": cell_info["chBwDl"],
                    "chBwUl": cell_info["chBwUl"],
                    "exp_dl_tput": exp_dl_tput,
                    "exp_ul_tput": exp_ul_tput,
                    "used_ants": list(used_ants_ids),
                    "ports": ports
                }
                cells_map.append(cell_map)

            mapping = {"ru_id": ru_id,
                       "product_name": ru_product_name,
                       "serial_number": ru["serialNumber"],
                       "ant_ids": ant_ids,
                       "cells": cells_map
                       }
            ru_mapping.append(mapping)
        logging.warning(ru_mapping)
        return ru_mapping
