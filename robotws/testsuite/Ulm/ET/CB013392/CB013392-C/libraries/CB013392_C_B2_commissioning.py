from testsuite.Ulm.ET.L2.libraries.ScfChanges import ScfChanges
from CB013392_C_B1_commissioning import *
import importlib

c_meas_profile = importlib.import_module(
    "testsuite.Ulm.ET.CB013392.CB013392-C.configurations.CB013392_C_profile")


def get_data_for_commissioning(scf_data: str, tdd_cells='11', fdd_cells='2'):
    scf_changes = ScfChanges(scf_data)
    add_changes_for_NRBTS(scf_changes)
    add_changes_for_NRCELLGRP(scf_changes)

    create_and_populate_NRHOIF(scf_changes, tdd_cells, '77', '663264', True)  # to have A2 HO configured after HO
    add_changes_for_tdd_NRCELL_config(scf_changes, tdd_cells, "false", "dlOnly")
    add_changes_for_fdd_NRCELL_config(scf_changes, fdd_cells)

    create_NRMEAS_PROFILE(scf_changes)
    create_and_populate_NRMEASPR_IAF(scf_changes, 1)
    create_and_populate_NRMEASPR_IAF(scf_changes, 2)
    create_NRMEASPR_MA_NSA(scf_changes)
    create_and_populate_NRMEASPR_IEF(scf_changes, 1)
    create_and_populate_NRMEASPR_IEF(scf_changes, 2)
    delete_unnecessary_NRREL(scf_changes)
    add_changes_for_NRDU(scf_changes)
    other_cell_changes(scf_changes)
    scf_changes.add_change({"regex": "MRBTS-1/NRBTS-1/NRCELL-[0-9]+",
                            "p_name": "a2MeasSCellRelEnabled",
                            "value": "none"})
    prepare_incoming_handover(scf_changes)
    return scf_changes.get_modifications_for_commissioning()
