"""test
"""
import pathlib
import re
import tempfile

from testsuite.Ulm.ET.Performance_Test.resources.python import scf_manager


def test_change_mrbts_nrbts_index():
    """test
    """
    mrbts = 123
    nrbts = 123
    scf_path = pathlib.Path(__file__).parent.joinpath("test_files", "test_scf_manager_scfc.xml")
    scf_path_unique_id = scf_manager.change_mrbts_nrbts_index(scf_path, mrbts, nrbts,
                                                              scf_name='scfc_unique_id.xml',
                                                              target=tempfile.gettempdir())
    print("\n".join(scf_manager.cached_log("test")))
    with open(scf_path_unique_id, "r", encoding="utf-8") as rstream:
        scf_unique_id = rstream.read()
    mrbts_re = re.findall(r"MRBTS-[0-9]+", scf_unique_id)
    nrbts_re = re.findall(r"MRBTS-[0-9]+/NRBTS-[0-9]+", scf_unique_id)
    for item in mrbts_re:
        assert item == f"MRBTS-{mrbts}"
    for item in nrbts_re:
        assert item == f"MRBTS-{mrbts}/NRBTS-{nrbts}"


def test_change_all_nrrel_gnbid():
    """test
    """
    original = 1234
    mrbts = 222
    nrbts = 222
    scf_path = pathlib.Path(__file__).parent.joinpath("test_files", "test_scf_manager_scfc.xml")
    scf_path_unique_id = scf_manager.change_mrbts_nrbts_index(scf_path, mrbts, nrbts,
                                                              scf_name='scfc_unique_id.xml',
                                                              target=tempfile.gettempdir())
    temp_scf_dir = pathlib.Path(tempfile.gettempdir()).joinpath('scfc.xml')
    scf_manager.get_scf_obj().load_scf(scf_path_unique_id)
    scf_manager.change_all_nrrel_gnbid(scf_path_unique_id, original, mrbts, connection='dummy')
    scf_manager.get_scf_obj().save_scf(temp_scf_dir)
    print("\n".join(scf_manager.cached_log("")))
    with open(temp_scf_dir, "r", encoding="utf-8") as rstream:
        scfc_mod = rstream.read()
    gnbid_re = re.findall(r"<p name=\"gNbId\">[0-9]+</p>", scfc_mod)
    for item in gnbid_re:
        assert item == f"<p name=\"gNbId\">{mrbts}</p>"


def test_shorten_distname():
    test_strings = [
        ("MRBTS-31207/MNL-1/MNLENT-1/PMCADM-1/reportingIntervalPm", "MNLENT-1/PMCADM-1/reportingIntervalPm"),
        ("MRBTS-31207/NRBTS-3120", "MRBTS-31207/NRBTS-3120"),
    ]
    for distname, expected in test_strings:
        assert scf_manager.shorten_distname(distname) == expected
