"""
:copyright: Nokia Networks
:author: Damian Zak, Mateusz Plinta, Mateusz Pajor
:maintainer: Damian Zak, Mateusz Plinta, Mateusz Pajor
:contact: damian.zak@nokia.com, mateusz.plinta@nokia.com, mateusz.pajor@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG, MN_RAN_L2_SW_2_KRK_Vrf_SG
"""

from taf.config.wts import wts

from ue_caps_variables import UE_CAPS_MRDC_FR2_NSA


def prepare_wts_config(target_path, nr_ue_caps=None, mrdc_ue_caps=None,
                       pcell="1", cells_arfcn_gscn=None, ue_ids=(1,)):
    wts_instance = wts()
    wts_instance.load_wts_cfg("/opt/wts/latest/basic_setup.cfg")
    _delete_existing_cells(wts_instance)
    _add_cells(wts_instance, cells_arfcn_gscn)
    _modify_ue_capabilities_common(
        wts_instance=wts_instance,
        nr_ue_caps=nr_ue_caps,
        mrdc_ue_caps=mrdc_ue_caps,
        ue_ids=ue_ids
    )
    _set_pcell_for_ues(wts_instance, pcell, ue_ids)
    _add_nr_compress_proxy_proto(wts_instance)
    wts_instance.save_wts_cfg(target_path)
    return target_path


def prepare_wts_config_a_b6(target_path, nr_ue_caps=None, nr_ue_caps_fr1_sa=None, nr_ue_caps_fr2_nsa=None, pcell="1",
                            ues_fr2_sa=(), ues_fr2_nsa=()):
    wts_instance = wts()
    wts_instance.load_wts_cfg("/opt/wts/latest/basic_setup.cfg")
    _delete_existing_cells(wts_instance)
    cells_arfcn_gscn = {"2071591:2071591 ": "22446", "2073257:2073257": "22452", "2074923:2074923": "22458",
                        "2076589:2076589": "22464", "2078255:2078255 ": "22470", "2079921:2079921": "22476",
                        "2081587:2081587": "22482", "2083253:2083253": "22488", "2059001:2059001": "22402",
                        "2060665:2060665": "22408"}
    pci_list = ["17:0", "17:1", "17:2", "18:0", "18:1", "18:2", "19:0", "19:1", "19:2", "20:0"]
    _add_cells(wts_instance, cells_arfcn_gscn, pci_list)
    _modify_ue_capabilities_b6_b7(
        wts_instance=wts_instance, nr_ue_caps=nr_ue_caps, nr_ue_caps_fr1_sa=nr_ue_caps_fr1_sa,
        nr_ue_caps_fr2_nsa=nr_ue_caps_fr2_nsa, ues_fr2_sa=ues_fr2_sa, ues_fr2_nsa=ues_fr2_nsa)
    _set_pcell_for_ues(wts_instance, pcell, ues_fr2_sa)
    _add_nr_compress_proxy_proto(wts_instance)
    wts_instance.save_wts_cfg(target_path)
    return target_path


def prepare_wts_config_a_b7(target_path, nr_ue_caps=None, nr_ue_caps_fr1_sa=None, nr_ue_caps_fr2_nsa=None, pcell="1",
                            ues_fr2_sa=(), ues_fr1_sa=()):
    wts_instance = wts()
    wts_instance.load_wts_cfg("/opt/wts/latest/basic_setup.cfg")
    _delete_existing_cells(wts_instance)
    cells_arfcn_gscn = {"2071591:2071591 ": "22446", "2073257:2073257": "22452", "2074923:2074923": "22458",
                        "2076589:2076589": "22464", "2078255:2078255 ": "22470", "2079921:2079921": "22476",
                        "2081587:2081587": "22482", "2083253:2083253": "22488", "650000:650000": "8019",
                        "640000:640000": "7915"}
    pci_list = ["17:0", "17:1", "17:2", "18:0", "18:1", "18:2", "19:0", "19:1", "19:2", "20:0"]
    _add_cells(wts_instance, cells_arfcn_gscn, pci_list)
    _modify_ue_capabilities_b6_b7(
        wts_instance=wts_instance, nr_ue_caps=nr_ue_caps, nr_ue_caps_fr1_sa=nr_ue_caps_fr1_sa,
        nr_ue_caps_fr2_nsa=nr_ue_caps_fr2_nsa, ues_fr2_sa=ues_fr2_sa, ues_fr1_sa=ues_fr1_sa)
    _set_pcell_for_ues(wts_instance, pcell, ues_fr2_sa)
    _set_pcell_for_ues(wts_instance, 9, ues_fr1_sa)
    _add_nr_compress_proxy_proto(wts_instance)
    wts_instance.save_wts_cfg(target_path)
    return target_path


def prepare_wts_config_d_b102(target_path, nr_ue_caps=None):
    wts_instance = wts()
    wts_instance.load_wts_cfg("/opt/wts/latest/basic_setup.cfg")
    _delete_existing_cells(wts_instance)
    cells_arfcn_gscn = {
        "2071591:2071591 ": "22446", "2073257:2073257": "22452", "2074923:2074923": "22458",
        "2076589:2076589": "22464", "2078255:2078255 ": "22470", "2079921:2079921": "22476",
        "2081587:2081587": "22482", "2083253:2083253": "22488", "2090395:2090395": "22512",
        "2092061:2092061": "22518", "2097307:2097307": "22536", "2098973:2098973": "22542"
    }
    pci_list = ["17:0", "17:1", "17:2", "18:0", "18:1", "18:2", "19:0", "19:1", "19:2", "20:0", "20:1", "20:2"]
    _add_cells(wts_instance, cells_arfcn_gscn, pci_list)
    wts_instance.modify(command="ue_param id=1", modification=f"ue_nr_capabilities={nr_ue_caps}")
    wts_instance.modify(command="set_ue simulated id=1", modification="cell=9")
    _add_nr_compress_proxy_proto(wts_instance)
    wts_instance.save_wts_cfg(target_path)
    return target_path


def _delete_existing_cells(wts_instance):
    wts_instance.delete(command="set_cell gnb=2")


def _add_cells(wts_instance, cells_arfcn_gscn=None, pci_list=None):
    if cells_arfcn_gscn is None:
        cells_arfcn_gscn = {"2071591:2071591 ": "22446", "2073257:2073257": "22452", "2074923:2074923": "22458",
                            "2076589:2076589": "22464", "2078255:2078255 ": "22470", "2079921:2079921": "22476",
                            "2081587:2081587": "22482", "2083253:2083253": "22488"}
    pci_list = ["17:0", "17:1", "17:2", "18:0", "18:1", "18:2", "19:0", "19:1"] if pci_list is None else pci_list
    for cell_id, (arfcn, gscn) in enumerate(cells_arfcn_gscn.items()):
        wts_instance.insert(
            [
                f"set_cell id={cell_id + 1} gnb=2 pci={pci_list[cell_id]} tac=788 nrci=0x{cell_id + 1:02d} tdd_cell=on "
                f"proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn={arfcn} gscn={gscn} "
                f"mandatory_for_activation=off"
            ],
            "after", "set_uec id=1"
        )


def _modify_ue_capabilities_common(wts_instance, nr_ue_caps, mrdc_ue_caps, ue_ids):
    for ue in ue_ids:
        if nr_ue_caps and ue in range(1, 10):
            wts_instance.modify(command=f"ue_param id={ue}", modification=f"ue_nr_capabilities={nr_ue_caps}")
        if mrdc_ue_caps and ue in range(11, 20):
            wts_instance.modify(command=f"ue_param id={ue}", modification=f"ue_eutra_nr_capabilities={mrdc_ue_caps}")
            wts_instance.modify(command="enb_endc_param id=1", modification="serving_cell_index_range_scg=8:9")


def _modify_ue_capabilities_b6_b7(wts_instance, nr_ue_caps, nr_ue_caps_fr1_sa, nr_ue_caps_fr2_nsa, ues_fr2_sa=(),
                                  ues_fr1_sa=(), ues_fr2_nsa=()):
    if ues_fr2_sa:
        for ue in ues_fr2_sa:
            wts_instance.modify(command=f"ue_param id={ue}", modification=f"ue_nr_capabilities={nr_ue_caps}")
    if ues_fr1_sa:
        for ue in ues_fr1_sa:
            wts_instance.modify(command=f"ue_param id={ue}", modification=f"ue_nr_capabilities={nr_ue_caps_fr1_sa}")
    if ues_fr2_nsa:
        for ue in ues_fr2_nsa:
            wts_instance.modify(
                command=f"ue_param id={ue}",
                modification=f"ue_nr_capabilities={nr_ue_caps_fr2_nsa} ue_eutra_nr_capabilities={UE_CAPS_MRDC_FR2_NSA}")
            wts_instance.modify(command="enb_endc_param id=1", modification="serving_cell_index_range_scg=8:9")


def _set_pcell_for_ues(wts_instance, pcell, ue_ids):
    for ue in ue_ids:
        if ue in range(1, 10):
            wts_instance.modify(command=f"set_ue simulated id={ue}", modification=f"cell={pcell}")


def _add_nr_compress_proxy_proto(wts_instance):
    """
    This function is required to prevent the SCell Addition (UEC crash) issue, without this line
    UEProxy was not receiving all SCell info sent via UEC - this command will compress the msgs to be sent to proxy
    :param wts_instance:
    """
    wts_instance.insert(
        command="sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled",
        location="after",
        reference="sim_trace amf=1"
    )
