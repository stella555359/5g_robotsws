import subprocess
import importlib
import sys
import warnings
import time


def install(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])


def import_with_auto_install(packages):
    results = []
    for package in packages:
        try:
            results.append(importlib.import_module(package))
        except ImportError:
            install(package)
            results.append(importlib.import_module(package))
            print("\n\ninstalling: {}\nfinal result = {}".format(package, results))
    return results


class CB008662(object):
    df = None

    def __init__(self):
        self.pandas_numpy_libs = None

    def get_pandas_numpy_libs(self):
        if self.pandas_numpy_libs is None:
            self.pandas_numpy_libs = import_with_auto_install(["pandas", "numpy"])
        return self.pandas_numpy_libs

    def regular_mcs_dl_check(self, file_path):
        df = self.get_pandas_numpy_libs()[0].read_csv(f'{file_path}.csv', sep=',')
        df['dlFdSchedData.rrmDlUsedMcs'] = self.get_pandas_numpy_libs()[0].to_numeric(
            df['dlFdSchedData.rrmDlUsedMcs'],
            errors='coerce'
        )
        df = df[df['dlFdSchedData.rrmDlUsedMcs'].notna()]
        df['dlFdSchedData.rrmDlUsedMcs'] = df['dlFdSchedData.rrmDlUsedMcs'].astype(int)

        not_regular = (df['dlFdSchedData.rrmDlUsedMcs'] > 27).any()

        if not_regular:
            raise ValueError("Regular MCSes are not used while no re-transmission")

        return not_regular

    def regular_mcs_ul_check(self, file_path):
        df = self.get_pandas_numpy_libs()[0].read_csv(f'{file_path}.csv', sep=',')
        df['ulFdSchedData.rrmUlUsedMcs'] = self.get_pandas_numpy_libs()[0].to_numeric(
            df['ulFdSchedData.rrmUlUsedMcs'],
            errors='coerce'
        )
        df = df[df['ulFdSchedData.rrmUlUsedMcs'].notna()]
        df['ulFdSchedData.rrmUlUsedMcs'] = df['ulFdSchedData.rrmUlUsedMcs'].astype(int)

        not_regular = (df['ulFdSchedData.rrmUlUsedMcs'] > 27).any()

        if not_regular:
            raise ValueError("Regular MCSes are not used while no re-transmission")

        return not_regular

    def reserved_mcs_dl_check(self, file_path):
        df = self.get_pandas_numpy_libs()[0].read_csv(f'{file_path}.csv', sep=',')
        df['dlFdSchedData.rrmDlUsedMcs'] = self.get_pandas_numpy_libs()[0].to_numeric(
            df['dlFdSchedData.rrmDlUsedMcs'],
            errors='coerce'
        )
        df = df[df['dlFdSchedData.rrmDlUsedMcs'].notna()]
        df['dlFdSchedData.rrmDlUsedMcs'] = df['dlFdSchedData.rrmDlUsedMcs'].astype(int)

        reserved = (df['dlFdSchedData.rrmDlUsedMcs'] > 27).any()

        if not reserved:
            raise ValueError("Reserved MCSes are not used while HARQ re-transmission triggered")

        return reserved

    def reserved_mcs_ul_check(self, file_path):
        df = self.get_pandas_numpy_libs()[0].read_csv(f'{file_path}.csv', sep=',')
        df['ulFdSchedData.rrmUlUsedMcs'] = self.get_pandas_numpy_libs()[0].to_numeric(
            df['ulFdSchedData.rrmUlUsedMcs'],
            errors='coerce'
        )
        df = df[df['ulFdSchedData.rrmUlUsedMcs'].notna()]
        df['ulFdSchedData.rrmUlUsedMcs'] = df['ulFdSchedData.rrmUlUsedMcs'].astype(int)

        reserved = (df['ulFdSchedData.rrmUlUsedMcs'] > 27).any()

        if not reserved:
            raise ValueError("Reserved MCSes are not used while HARQ re-transmission triggered")

        return reserved
