from testsuite.Ulm.ET.L2.libraries.ScfChanges import ScfChanges
from CB013392_B_B2_commissioning import *
import logging
import importlib

a_profile = importlib.import_module("testsuite.Ulm.ET.CB013392.CB013392-A.configurations.CB013392_A_profile")


def get_data_for_commissioning(scf_data: str, tdd_cells='11', fdd_cells='2'):
    scf_changes = ScfChanges(scf_data)
    add_changes_for_NRBTS(scf_changes)
    add_changes_for_NRCELLGRP(scf_changes)

    create_and_populate_NRHOIF(scf_changes, tdd_cells)
    create_NRMEAS_PROFILE(scf_changes)
    create_and_populate_NRMEASPR_IAF(scf_changes, 1)
    create_and_populate_NRMEASPR_IAF(scf_changes, 2)
    create_NRMEASPR_MA_SA(scf_changes)
    # create_and_populate_NRMEASPR_IEF(scf_changes)
    delete_unnecessary_nrrel(scf_changes)
    update_nrrel_for_tdd(scf_changes, tdd_cells)
    update_nrrel_for_fdd(scf_changes, fdd_cells)
    add_changes_for_tdd_NRCELL_config(scf_changes, tdd_cells)
    add_changes_for_fdd_NRCELL_config(scf_changes, fdd_cells)
    add_b5_changes_for_fdd_NRCELL_config(scf_changes, fdd_cells)
    create_and_populate_NRREDRT(scf_changes, tdd_cells, fdd_cells)
    add_changes_for_NRDU(scf_changes)
    other_cell_changes(scf_changes, "b7")
    add_changes_for_NRMOPR(scf_changes)
    return scf_changes.get_modifications_for_commissioning()


def add_b5_changes_for_fdd_NRCELL_config(scf_changes_object: ScfChanges, fdd_cells):
    regex = f"MRBTS-1/NRBTS-1/NRCELL-{fdd_cells}"

    ssb_dict = {
        "a2MeasSCellRelSsbRsrp": a_profile.A2_MEAS_DICT[fdd_cells]["a2MeasSCellRelSsbRsrp"]
    }
    for ssb_name, ssb_param in ssb_dict.items():
        for p_name, value in ssb_param.items():
            scf_changes_object.add_change({"regex": regex, "list_name": ssb_name,
                                           "p_name": p_name, "value": value})
