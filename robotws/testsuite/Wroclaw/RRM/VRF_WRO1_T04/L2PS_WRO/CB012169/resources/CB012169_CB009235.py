import subprocess
import importlib
import sys


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


class CB012169_CB009235(object):
    df = None

    def __init__(self):
        self.pandas_numpy_libs = None

    def get_pandas_numpy_libs(self):
        if self.pandas_numpy_libs is None:
            self.pandas_numpy_libs = import_with_auto_install(["pandas", "numpy"])
        return self.pandas_numpy_libs

    def count_pairs(self, filepath, cell_ids):
        """
        Args:
            filepath: Path to the CSV file.
            cell_ids: physCellIds
        """
        try:
            df = self.get_pandas_numpy_libs()[0].read_csv(filepath)
            result = all(any(df[(df['physCellId'] == cell_id) & (~df['dlFdSchedData.numOfPrb'].isna())].groupby(
                ['sfn', 'slot']).size() > 10) for cell_id in cell_ids)
            return result
        except FileNotFoundError:
            print(f"Error: File not found at {filepath}")
            return False
        except KeyError as e:
            print(f"Error: Missing column in CSV: {e}")
            return False
