# -*- coding: utf-8 -*-
# @Time    : 2024/11/20 16:36
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : analysis_emil.py
# @Software: PyCharm
import json


def _normalize_json_contents(json_content_field):
    """EMIL rows: JsonContent can be list[dict] or dict. Normalize to list[dict]."""
    if isinstance(json_content_field, list):
        return [x for x in json_content_field if isinstance(x, dict)]
    if isinstance(json_content_field, dict):
        return [json_content_field]
    return []


def get_ue_contains_measconfig_from_emil(emil_content):
    result = {
        "add_meas_ids": [],
        "remove_meas_ids": [],
        "add_meas_objects": [],
        "report_configs": []
    }
    for row in emil_content["emil_data"]["rows"]:
        try:
            user_data = row["User_data"]
            assert "DL RRC: rrcReconfiguration" in user_data
            for json_content in _normalize_json_contents(row.get("JsonContent")):
                try:
                    rrcReconfiguration = json_content["DL-DCCH-Message"]["message"]["c1"]["rrcReconfiguration"]
                    measConfig = rrcReconfiguration["criticalExtensions"]["rrcReconfiguration"]["measConfig"]
                    for add_meas_id in measConfig["measIdToAddModList"]:
                        result["add_meas_ids"].append(add_meas_id["measId"])
                    for remove_meas_id in measConfig["measIdToRemoveList"]:
                        result["remove_meas_ids"].append(remove_meas_id)
                    for add_meas_object in measConfig["measObjectToAddModList"]:
                        result["add_meas_objects"].append(add_meas_object["measObjectId"])
                    for report_config in measConfig["reportConfigToAddModList"]:
                        result["report_configs"].append(report_config["reportConfigId"])
                except KeyError:
                    pass
        except KeyError:
            pass
        except TypeError:
            pass
        except AssertionError:
            pass
    return result


def get_ue_contains_measreport_from_emil(emil_content):
    result = {
        "ser_cell_ids": [],
        "neigh_cell_ids": []
    }
    for row in emil_content["emil_data"]["rows"]:
        try:
            user_data = row["User_data"]
            assert "measurementReport" in user_data
            for json_content in _normalize_json_contents(row.get("JsonContent")):
                try:
                    measurementreport = json_content["UL-DCCH-Message"]["message"]["c1"]["measurementReport"]
                    measresults = measurementreport["criticalExtensions"]["measurementReport"]["measResults"]

                    for ser_item in (measresults.get("measResultServingMOList") or []):
                        ser_cell = (ser_item or {}).get("measResultServingCell")
                        if isinstance(ser_cell, dict) and "physCellId" in ser_cell:
                            result["ser_cell_ids"].append(ser_cell["physCellId"])

                    neigh_list = (measresults.get("measResultNeighCells") or {}).get("measResultListNR") or []
                    for neigh_cell in neigh_list:
                        if isinstance(neigh_cell, dict) and "physCellId" in neigh_cell:
                            result["neigh_cell_ids"].append(neigh_cell["physCellId"])
                except KeyError:
                    pass
        except KeyError:
            pass
        except TypeError:
            pass
        except AssertionError:
            pass
    return result
