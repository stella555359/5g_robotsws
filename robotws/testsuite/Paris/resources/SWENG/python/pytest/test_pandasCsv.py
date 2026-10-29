from __future__ import print_function
from builtins import object
import importlib
import os
import sys
import traceback
import subprocess
# import pandas
import pytest

# Reactivate to perform pytests, comment to respect PEP8

# sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from PandasCsv import PandasCsv

filepath = "SherpaCsvFiles/micro__l1l2Trace.csv"
filepath2 = "Traces/L1L2_pcapprocessed.csv"


def install(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])


def import_with_auto_install(packages):
    results = []
    for package in packages:
        try:
            results.append(importlib.import_module(package))
            print(f"\n\nimporting: {results}")
        except ImportError:
            install(package)
            results.append(importlib.import_module(package))
            print(f"\n\ninstalling: {package}\nfinal result = {results}")
    return results


class TestPandasCsv(object):
    mylittle_pd = None
    df_dict = None

    @pytest.fixture
    def stuff_setup(self):
        try:
            self.mylittle_pd = PandasCsv()
            self.mylittle_pd.setup_reader(os.path.realpath(filepath))
            self.df_dict = dict()
            self.pd = self.mylittle_pd.get_pandas_numpy_libs()[0]
        except Exception:
            exc_type, exc_value, exc_tb = sys.exc_info()
            traceback.print_exception(exc_type, exc_value, exc_tb)

    @pytest.fixture
    def stuff_setup2(self):
        try:
            self.mylittle_pd = PandasCsv()
            self.mylittle_pd.setup_reader(os.path.realpath(filepath2), use_sqlquery=False)
            self.df_dict = dict()
            self.pd = self.mylittle_pd.get_pandas_numpy_libs()[0]
        except Exception:
            exc_type, exc_value, exc_tb = sys.exc_info()
            traceback.print_exception(exc_type, exc_value, exc_tb)

    def test_ListOperations(self, stuff_setup):
        assert "micro__l1l2Trace" in self.mylittle_pd.filepath
        assert type(self.mylittle_pd.df) is self.pd.DataFrame

    def test_ListOperations2(self, stuff_setup2):
        assert "L1L2_pcapprocessed" in self.mylittle_pd.filepath
        assert type(self.mylittle_pd.df) is self.pd.DataFrame
        print(f"\n\nColumns are:\n{self.mylittle_pd.df.columns}")
        print(f"Rows number is: {len(self.mylittle_pd.df)}")
        assert len(self.mylittle_pd.df) == 3181
        assert len(self.mylittle_pd.df.columns) == 10
        print(f"\nFirst 10 rows are:\n{self.mylittle_pd.df.head(10)}")

    def test_readSql(self, stuff_setup):
        self.mylittle_pd.read_sql_df("SELECT TIME,MSGID,TEXT FROM l1l2Traces",
                                     "WHERE MSGID LIKE '%PrbPollingAllocationReport%'")
        assert self.mylittle_pd.sql_df is not None

    def test_splitbygroups(self, stuff_setup):
        self.mylittle_pd.read_sql_df("SELECT TIME,MSGID,TEXT FROM l1l2Traces",
                                     "WHERE MSGID LIKE '%PrbPollingAllocationReport%'")
        df_dict, list_grp_totreat = self.mylittle_pd.split_bygroup()
        print(f"\nList grp:\n{list_grp_totreat}")
        assert len(df_dict) == 2
        assert len(list_grp_totreat) == 2
        assert set(list_grp_totreat) == set(["Ul PrbPollingAllocationReport(45)",
                                             "Dl PrbPollingAllocationReport(45)"])

    def test_content_treat_for_text(self, stuff_setup):
        self.mylittle_pd.read_sql_df("SELECT TIME,MSGID,TEXT FROM l1l2Traces",
                                     "WHERE MSGID LIKE '%PrbPollingAllocationReport%'")
        df_dict, list_grp_totreat = self.mylittle_pd.split_bygroup()
        for elem in list_grp_totreat:
            df_res = self.mylittle_pd.content_treat_for_text(df_dict[elem])
            assert type(df_res) is self.pd.DataFrame

    def test_readSql2(self, stuff_setup):
        self.mylittle_pd.read_sql_df("SELECT TIME,MSGID,`AIR TTI`,TEXT FROM l1l2Traces")
        assert self.mylittle_pd.sql_df is not None

    def test_content_treat_for_airtti(self, stuff_setup):
        df_res = self.mylittle_pd.content_treat_for_airtti('AIR TTI', '.', ['AIR TTI SFN', 'AIR TTI SLOT'])
        print(f"\ndf_res type is: {type(df_res)}")
        assert type(df_res) is self.pd.DataFrame

    def test_groups_saveCsv(self, stuff_setup):
        self.mylittle_pd.read_sql_df("SELECT TIME,MSGID,TEXT FROM l1l2Traces",
                                     "WHERE MSGID LIKE '%PrbPollingAllocationReport%'")
        df_dict, list_grp_totreat = self.mylittle_pd.split_bygroup()
        for key, elem in df_dict.items():
            # print(f"\n\nKey:  {key}\n\nStuff:\n{elem}")
            saved_stuff = self.mylittle_pd.save_tocsv(elem, key)
            # print(f"Saved to:\n{saved_stuff}")
            assert os.path.exists(saved_stuff)
            assert key in list_grp_totreat
            os.remove(saved_stuff)
        for key, elem in df_dict.items():
            saved_stuff = self.mylittle_pd.save_tocsv(elem, key, separator=';')
            assert os.path.exists(saved_stuff)
            if 'Dl_Prb' in saved_stuff:
                with open(saved_stuff) as fp:
                    for i, line in enumerate(fp):
                        if i == 5:
                            print(f"\nLine is:\n{line}")
                            assert 'PrbPollingAllocationReport(45);Type:DL,Mode:LB,Period=50ms,PoolId=14,' in line or \
                                'maxNumPdschPerSlot=3,maxNumPuschPerSlot=3,maxNumPucchF1perSlot=3' in line
            os.remove(saved_stuff)

    def test_extract_cvs_files_forcolumn(self, stuff_setup):
        savedfiles = self.mylittle_pd.extract_cvs_files_forcolumn()
        for savedfile in savedfiles:
            print(f"\nSAVE file:\n{savedfile}")
            print("OK" if os.path.exists(savedfile) else "NOK")
            assert os.path.exists(savedfile)
            if 'Dl_Prb' in savedfile:
                with open(savedfile) as fp:
                    for i, line in enumerate(fp):
                        if i == 5:
                            assert "108" in line
                            assert "109,3" in line
                            assert "1443.24,419.03" in line
            os.remove(savedfile)

    def test_generate_cvs_file_with_splitted_column(self, stuff_setup):
        savedfile = self.mylittle_pd.generate_cvs_file_with_splitted_column()
        print(f"\nSAVE file:\n{savedfile}")
        print("OK" if os.path.exists(savedfile) else "NOK")
        assert os.path.exists(savedfile)
        assert "Splitted_AIR_TTI" in savedfile
        with open(savedfile) as fp:
            for i, line in enumerate(fp):
                if i == 10:
                    assert "Dl SlotTypeReq" in line
        os.remove(savedfile)

    def test_both_worlds(self, stuff_setup):
        savedfile = self.mylittle_pd.generate_cvs_file_with_splitted_column()
        print(f"\nSAVE file:\n{savedfile}")
        self.mylittle_pd = PandasCsv()
        self.mylittle_pd.setup_reader(os.path.realpath(savedfile), ",")
        self.mylittle_pd.read_sql_df("SELECT TIME,`AIR TTI SFN`,`AIR TTI SLOT`,MSGID,TEXT FROM l1l2Traces",
                                     "WHERE MSGID LIKE '%PrbPollingAllocationReport%'")
        assert "AIR TTI SFN" in self.mylittle_pd.sql_df.head()
        savedfiles = self.mylittle_pd.\
            extract_cvs_files_forcolumn(select_columns="TIME,`AIR TTI SFN`,`AIR TTI SLOT`,MSGID,TEXT")
        for savedfile in savedfiles:
            print(f"\nSAVE file:\n{savedfile}")
            print("OK" if os.path.exists(savedfile) else "NOK")
            assert os.path.exists(savedfile)
            if 'Dl_Prb' in savedfile:
                with open(savedfile) as fp:
                    for i, line in enumerate(fp):
                        if i == 5:
                            assert "108" in line
                            assert "109" in line
                            assert "419,3" in line
            os.remove(savedfile)

    def test_check_max_for_column(self, stuff_setup2):
        max_value = self.mylittle_pd.check_max_for_column("3gpp.slot")
        print(f"\n\nMax value is: {max_value}")
        assert int(max_value) == 19

    def test_get_columns_with_same_values(self, stuff_setup2):
        columns = self.mylittle_pd.get_columns_with_same_values()
        print(f"\n\nColumns with same values:\n{columns}")
        assert len(columns) == 5
        assert columns[0] == "UlData_puschReceiveReqGrant_t.numOfLayers"

    def test_get_columns_with_long_names(self, stuff_setup2):
        columns = self.mylittle_pd.get_columns_with_long_names()
        print(f"\n\nColumns with long names:\n{columns}")
        assert len(columns) == 0

    def test_check_unique_value_for_column(self, stuff_setup2):
        import numpy as np
        unique_value = self.mylittle_pd.check_unique_value_for_column("UlData_puschReceiveReqGrant_t.mcs")
        print(f"\n\nUnique value for UlData_puschReceiveReqGrant_t.mcs is: {unique_value}")
        assert unique_value[1].astype(int) == 27.0

    def test_get_column_values(self, stuff_setup2):
        import numpy as np
        values = self.mylittle_pd.get_column_values("UlData_pucchReceiveReqPucchResource_t.additionalDmrs")
        print(f"\n\nValues for column UlData_pucchReceiveReqPucchResource_t.additionalDmrs:\n{values}")
        assert len(values) == 3181
        assert np.isnan(values[0])

    def test_get_first_column_value(self, stuff_setup2):
        import numpy as np
        value = self.mylittle_pd.get_first_column_value("UlData_pucchReceiveReqPucchResource_t.additionalDmrs")
        print(f"\n\nFirst value for column UlData_pucchReceiveReqPucchResource_t.additionalDmrs is: {value}")
        assert value[0] == 1
        assert value[1] == '0'

    def test_get_number_of_not_empty_cells(self, stuff_setup2):
        number = self.mylittle_pd.get_number_of_not_empty_cells("UlData_pucchReceiveReqPucchResource_t.additionalDmrs")
        print(f"\n\nNumber of not empty cells for UlData_pucchReceiveReqPucchResource_t.additionalDmrs is: {number}")
        assert number.astype(int) == 405

    def test_count_values(self, stuff_setup2):
        count = self.mylittle_pd.count_values("UlData_pucchReceiveReqPucchResource_t.additionalDmrs")
        print(f"\n\nCount values for column UlData_pucchReceiveReqPucchResource_t.additionalDmrs is: {count}")
        assert count['0'] == 400
        assert count['0,0'] == 5
