"""This Module is responsible for
    - extracting counters from snapshot
    - converting counters to DF, DICTIONARY, JSON, CSV format

    Compatible with PM Counters and RD Counters

    Example Usage:
        python /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/counters.py \
            --counters_dir  './testsuite/Ulm/ET/Performance_Test/resources/test/test_files/rd_ctr_files' \
            --log_level WARN \
            --to_csv test.csv \
            --counters_list AVG_DL_UE_SLOT_LIM_UE_POOL,AVG_UL_UE_SLOT_LIM_UE_POOL

        python /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/counters.py \
            --snapshot_dir  snapshot.zip \
            --log_level WARN \
            --to_csv test.csv \
            --counters_list AVG_DL_UE_SLOT_LIM_UE_POOL,AVG_UL_UE_SLOT_LIM_UE_POOL
"""

import argparse
import logging
import pathlib
import typing
import tempfile
import json

import shutil

import pandas as pd
import taf.file.pack

from testsuite.Ulm.resources.Common.python import pmcounters

logger = logging.getLogger()


class Counters:
    """RdCounter"""

    def __init__(self,
                 counters_dir,
                 file_pattern=r'*BTS*RD*',
                 counters_list=None,
                 inactive_cells: list = None,
                 inactive_cellgrp: list = None):
        """
        :param counters_dir: directory where PM files are saved
        :param counters: list of counters to fetch
        :param inactive_cells: list: remove cells from the result
        """
        self.counters_dir = pathlib.Path(counters_dir)
        self.counters_list = counters_list
        self.inactive_cells = inactive_cells
        self.inactive_cellgrp = inactive_cellgrp
        self.file_pattern = file_pattern
        self.counter_list = list(i for i in self.counters_dir.glob(self.file_pattern))
        self.counter_list.sort(reverse=True)
        if len(self.counter_list) == 0:
            logger.warning("No files matching '%s' found", self.file_pattern)

    def get_from_index(self, index: int = 0):
        """Return an xml path where index 0 is the latest file"""
        return self.counter_list[index]

    def get_counters_in_dictionary_format(self, counters: typing.List[str]):
        return pmcounters.get_pi_dict(str(self.counters_dir), counters, pi_file_pattern=self.file_pattern)

    def get_counter_df_using_pd(
            self,
            counters_list: list = None,
            index: int = -1):
        """
        :param counters: list of counters to fetch
        :param index: -1 for the last measurement
        :param inactive_cells: list: remove cells from the result
        :return: df
        """
        if counters_list is None:
            if self.counters_list is not None:
                counters_list = self.counters_list
            else:
                raise Counters.Exc.CountersNoneError
        pm_dict = self.get_counters_in_dictionary_format(counters_list)
        logger.debug("Counters Dictionary: %s", json.dumps(pm_dict, indent=4))
        try:
            logger.debug("Parse Dictionary as DF")
            df = pd.DataFrame(pm_dict).T.iloc[int(index)]
        except IndexError as e:
            logger.error("Unable to Parse DF from counters: %s", e)
            return {}
        df = Counters._generate_new_df_from_counters_list(df, counters_list)
        logger.info("Dataframe length: %d", len(df))
        df = Counters._remove_inactive_from_df(df, 'NRCELL', self.inactive_cells)
        df = Counters._remove_inactive_from_df(df, 'NRCELGP', self.inactive_cellgrp)
        return df

    @staticmethod
    def _remove_inactive_from_df(df, prefix: str, digit_list: int):
        logger.debug("Remove Inactive %s: %s", prefix, len(df))
        if digit_list is not None:
            indices_to_drop = [
                idx for idx in df.index
                for cell in digit_list
                if f"{prefix}-{cell}" in idx
            ]
            df = df.drop(indices_to_drop)
        return df

    @staticmethod
    def _generate_new_df_from_counters_list(df, counters: list):
        logger.debug("Generate New DF from Counters List: %s", len(df))
        df = pd.DataFrame(df).T
        frames = []
        for counter in counters:
            new_frame = pd.json_normalize(df[counter]).T
            new_frame.columns = [counter]
            frames.append(new_frame)
        # df = pd.concat(frames, axis=1).astype('Int64')
        df = pd.concat(frames, axis=1).astype('float')
        return df

    def to_csv(self,
               target: pathlib.Path,
               counters: list = None,
               index: int = -1,
               simple_header: bool = True):
        df = self.get_counter_df_using_pd(counters_list=counters, index=index).T
        if simple_header:
            df = df.rename(columns=lambda x: pathlib.Path(x).name)
        target = pathlib.Path(target)
        target.parent.mkdir(parents=True, exist_ok=True)
        df.to_csv(target, sep=',', encoding='utf-8', index=True, header=True)
        return target.absolute()

    def get_counter_dictionary(self,
                               counters: list = None,
                               ignore_zero: bool = True,
                               index: int = -1) -> dict:
        """
        :param counters: list of counters to fetch if df is none
        :param ignore_zero: igrone zero values when calculating mean
        :param index: -1 for the last measurement
        :return: dictionary with all pmcounters in the following format
            {
                '< pm Name: str >' : {
                    "dn" : {
                        < distname: str > : < INT >,
                        ...
                    },
                    "mean" : < INT >
                },
                ...
            }
        """
        df = self.get_counter_df_using_pd(counters_list=counters, index=index)
        logger.debug("Start get_counter_dictionary")
        logger.debug("Add Mean Value to the dn: %s", len(df))
        df.loc['mean'] = df.astype(float).mean()
        result = df.apply(lambda x: [x.dropna()], axis=0).to_json()  # need to converst to json to add the mean
        parsed = json.loads(result)
        parsed_clean = {}
        _default_mean_value_if_not_found = 0
        _first_json_index = "0"
        for key, value in parsed.items():
            # re-structure the table to remove the outer '0' key
            data = value.get(_first_json_index, {'mean': _default_mean_value_if_not_found})
            if ignore_zero and data.get('mean', _default_mean_value_if_not_found) == 0:
                continue
            mean_value = data.pop('mean')
            parsed_clean.update({
                key: {
                    "dn": data,
                    "mean": mean_value
                }
            })
        logger.debug("End get_counter_dictionary")
        return parsed_clean

    class Exc:
        """Exc"""
        class DataFrameParseError(Exception):
            """DataFrameParseError"""

        class CountersNoneError(Exception):
            """CountersNoneError"""


class Snapshot:
    """Snapshot"""

    def __init__(self, snapshot_path):
        self.snapshot_path = pathlib.Path(snapshot_path)
        if not self.snapshot_path.is_file():
            raise FileNotFoundError(f"Snapshot not found: {self.snapshot_path}")

    def extract_rd_counters(self, target: pathlib.Path):
        target = pathlib.Path(target)
        target.mkdir(parents=True, exist_ok=True)
        try:
            with tempfile.TemporaryDirectory() as tmpdirname:
                tmpdir = pathlib.Path(tmpdirname)
                selections = {
                    ".": "BTS*_*_*.zip",
                    "**/*.zip": "BTS*_*_RD.BTS*.ANY.xml.gz",
                    "**/*_RD.BTS*.ANY.xml.gz": "*"
                }
                taf.file.pack.extract(
                    path=str(self.snapshot_path),
                    output_dir=str(tmpdir),
                    **selections
                )
                for rd in list(i for i in tmpdir.glob(r'**/BTS*RD.BTS*.xml') if i.is_file()):
                    shutil.copy(rd, target.joinpath(rd.name))
        except RuntimeError:
            logger.error('No RD Counters Extracted from %s', self.snapshot_path)
            return None
        return target


###########
# Robot Framework Interfaces
###########
def snapshot_to_csv(snapshot_dir: str, target: str, counters: typing.Union[list, str]) -> str:
    if isinstance(counters, str):
        counters = counters.split(',')
    with tempfile.TemporaryDirectory() as tmpdirname:
        Snapshot(snapshot_dir).extract_rd_counters(tmpdirname)
        cobj = Counters(tmpdirname, counters_list=counters)
        cobj.to_csv(target)
    return target


def snapshot_to_dictionary(snapshot_dir: str, counters: typing.Union[list, str]) -> dict:
    if isinstance(counters, str):
        counters = counters.split(',')
    with tempfile.TemporaryDirectory() as tmpdirname:
        Snapshot(snapshot_dir).extract_rd_counters(tmpdirname)
        cobj = Counters(tmpdirname, counters_list=counters)
        return cobj.get_counter_dictionary()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--log_level', default="INFO")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--counters_dir', default=None)
    group.add_argument('--snapshot_dir', default=None)
    parser.add_argument('--to_csv', default=None)
    parser.add_argument('--counters_list', default=None, required=True)
    parser.add_argument('--extract_pm', default=None)
    parser.add_argument('--index', default=-1, type=int)
    args = parser.parse_args()

    logging.basicConfig(
        format="%(asctime)s|%(levelname)s:%(message)s",
        encoding='utf-8',
        level=getattr(logging, args.log_level)
    )
    cobj = None
    logger.info("Start Script")
    with tempfile.TemporaryDirectory() as tmpdirname:
        if args.extract_pm is not None:
            tmpdirpath = pathlib.Path(args.extract_pm)
            tmpdirpath.mkdir(parents=True, exist_ok=True)
        else:
            tmpdirpath = pathlib.Path(tmpdirname)
        logger.debug(f"Temporary directory created at {tmpdirpath}")
        counters_list = args.counters_list.split(",")
        if args.snapshot_dir is not None:
            Snapshot(args.snapshot_dir).extract_rd_counters(target=tmpdirpath)
            cobj = Counters(tmpdirpath, counters_list=counters_list)

        if args.counters_dir is not None:
            cobj = Counters(args.counters_dir, counters_list=counters_list)

        if cobj is not None:
            if args.to_csv is not None:
                csv_file = cobj.to_csv(pathlib.Path(args.to_csv), index=args.index)
                print(f"\nCSV File generated: {csv_file}\n")


if __name__ == "__main__":
    main()
