from robot.libraries.BuiltIn import BuiltIn, logger
from typing import NoReturn


def get_bts_info_from_init_file() -> dict:
    bts_info = {
        "gnb_mplane_addr": BuiltIn().get_variable_value(
            '${tl.gnbs[0].cu.ngu.v4}').split("/")[0],
        "username": BuiltIn().get_variable_value(
            '${tl.gnbs[0].cu.oam_ssh_connection_details.username}'),
        "password": BuiltIn().get_variable_value(
            '${tl.gnbs[0].cu.oam_ssh_connection_details.password}'),
        "gnb_bts_id": BuiltIn().get_variable_value(
            '${tl.gnbs[0].global_bts_id}')
    }
    return bts_info


def get_bts_id(bts_type: str) -> NoReturn:
    bts_hw_info = get_bts_info_from_init_file()
    if bts_type == "enb":
        return bts_hw_info["enb_bts_id"]
    elif bts_type == "gnb":
        return bts_hw_info["gnb_bts_id"]
    else:
        raise Exception(f"{bts_type} unknow base stationt type. Select enb or gnb")
