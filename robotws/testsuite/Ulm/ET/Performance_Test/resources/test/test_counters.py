
import os
import pathlib
import tempfile

import pytest

from testsuite.Ulm.ET.Performance_Test.resources.python import counters


@pytest.mark.skipif(os.name == 'nt', reason="taf.file.pack is not supported in windows")
@pytest.mark.skipif(not pathlib.Path(__file__).parent.joinpath('test_files', 'snapshot.zip').exists(),
                    reason="Due to rule: Thou shall not toss in trash.")
def test_snapshot_extract():
    test_files_path = pathlib.Path(__file__).parent.joinpath('test_files')
    snapshot_path = test_files_path.joinpath('snapshot')
    assert snapshot_path.is_file()
    snapshot = counters.Snapshot(snapshot_path)
    with tempfile.TemporaryDirectory() as tmpdirname:
        rd_extracted_path = snapshot.extract_rd_counters(target=tmpdirname)
        # Modified by AI: 2024-06-10 - Simplified list comprehension for glob iterator
        file_list = list(rd_extracted_path.glob(r"BTS*RD.BTS*.xml"))
        assert len(file_list) > 1


def test_latest_rd_file():
    rd_path = pathlib.Path(__file__).parent.joinpath('test_files', 'rd_ctr_files')
    rd_obj = counters.Counters(rd_path)
    assert rd_obj.get_from_index(0).name == 'BTS104719559_2011_RD.BTS-104719559.20251118.051000.ANY.xml'


def test_rd_counter_is_readble_by_common_kw():
    rd_path = pathlib.Path(__file__).parent.joinpath('test_files', 'rd_ctr_files')
    rd_obj = counters.Counters(rd_path, counters_list=['NORMAL_LOAD_UL'])
    counters_res = rd_obj.get_counters_in_dictionary_format(
        ['NORMAL_LOAD_UL']
    )
    print(counters_res)
    assert isinstance(counters_res, dict)
    assert len(counters_res) > 0
    counter_view = counters_res[r'2025-11-18 05:00:00+00:00'][r'NORMAL_LOAD_UL']
    assert counter_view[r'MRBTS-104719559/NRBTS-1/NRCELGP-0'] == '77334'


def test_rd_counter_to_dict():
    rd_path = pathlib.Path(__file__).parent.joinpath('test_files', 'rd_ctr_files')
    rd_obj = counters.Counters(rd_path, counters_list=['NORMAL_LOAD_UL'])
    pd_res = rd_obj.get_counter_dictionary()
    assert pd_res['NORMAL_LOAD_UL']['dn'][r'MRBTS-104719559/NRBTS-1/NRCELGP-0'] == 86545.0
