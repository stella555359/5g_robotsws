"""
:copyright: Nokia Networks
:author: 'Monika Ceglarek', 'Wojciech Peciak'
:contact: 'monika.ceglarek@nokia.com', ' wojciech.peciak@nokia.com'
:maintainer: 'Monika Ceglarek', 'Wojciech Peciak'
:contact: 'monika.ceglarek@nokia.com', ' wojciech.peciak@nokia.com'
:version: 0.1
"""

from Emil import Emil
import os
import shutil
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T023.resources.Downloader import Downloader
import csv
from pathlib import Path


class TtiMisc:
    @staticmethod
    def get_max_prb_value(file_path, column_name="dlFdSchedData.numOfPrb"):
        """
        Gets and returns max PRB value from given column.

        :param file_path: Absolute path to TTI trace .csv file.
        :param column_name: Name of column in TTI trace file from which max PRB will be taken.
        :return Max PRB value from given column.
        """

        prb_dict = TtiMisc.read_csv_columns_values(file_path, [column_name])
        prb_list = prb_dict[column_name]
        logger.debug(f"\nprb_list={prb_list}")
        return max(map(lambda prb_val: float(prb_val) if prb_val else None, prb_list))

    @staticmethod
    def unzip_tti(zipfile_path, destination_path, file_search_str, unzipped_path="/tmp/utf_unzipped"):
        """
        Extracts TTI trace file from UTF ZIP to specified directory.

        :param zipfile_path: Absolute path to ZIP archive with UTF logs.
        :param destination_path: Absolute path to directory where TTI trace file will be saved.
        :param file_search_str: Search string containing part of TTI .pcap file name.
        :param unzipped_path: Absolute path to directory where ZIP UTF logs
               will be extracted. Default value: "/tmp/utf_unzipped"
        :return Absolute path to unzipped TTI .pcap file.
        """

        Emil.extract_logs(zipfile_path, unzipped_path)
        file_paths = [
            str(file_path)
            for file_path in list(Path(unzipped_path).rglob(f"*.pcap"))
            if file_search_str in file_path.name
        ]

        logger.debug(f"\nfile_paths={file_paths}")

        file_name = os.path.basename(file_paths[0])
        logger.debug(f"\nfile_name={file_name}")

        logger.debug(f"\ndestination_path={destination_path}")
        unzipped_tti_path = os.path.join(destination_path, file_name)
        logger.debug(f"\nunzipped_tti_path={unzipped_tti_path}")
        Downloader.check_and_create_dest_dir(destination_path)
        shutil.copyfile(file_paths[0], unzipped_tti_path)

        return unzipped_tti_path

    @staticmethod
    def read_csv_columns_values(file_path: str, columns_name: list[str]) -> dict[str, list[str]]:
        """
            Gets values from a specified columns in a CSV file.
            :param file_path: The path to the CSV file.
            :param columns_name: The name of the columns to read.
            :return: A dict of lists of values from the specified columns as keys.
            :raises ValueError: If any of the specified column is not found in the CSV file.
        """
        columns_dict = {column_name: [] for column_name in columns_name}

        with open(file_path, mode='r', encoding='utf-8') as file:
            csv_reader = csv.DictReader(file)
            for row in csv_reader:
                TtiMisc._get_available_columns_values_from_row(columns_dict, row)

        return columns_dict

    @staticmethod
    def _get_available_columns_values_from_row(columns_dict, row):
        for column_name in columns_dict.keys():
            TtiMisc._get_column_value(column_name, columns_dict, row)

    @staticmethod
    def _get_column_value(column_name, columns_dict, row):
        try:
            if row[column_name] != "":
                columns_dict[column_name].append(row[column_name])
            else:
                columns_dict[column_name].append(None)
        except ValueError:
            raise ValueError(f"Column '{column_name}' not found in the CSV file.")


class SlotBlankig:
    @staticmethod
    def verify_slotBlanking_with_desired_ratio(file_path: str, blanking_ratio: str) -> bool:
        """
            Verifies if in TTI Trace CSV file slotBlanking is occurring
            and if it has consistent desired blanking ratio.
            :param file_path: The path to the CSV file.
            :param blanking_ratio: Desired slot blanking ratio.
            :return: Bool result of verification.
        """
        TMR_COL_NAME = 'dlSlotBlankingInfo.targetMutingRatio'
        SMFRC_COL_NAME = 'dlSlotBlankingInfo.slotMutedForRfCooling'

        columns_values_dic = TtiMisc.read_csv_columns_values(file_path, [TMR_COL_NAME, SMFRC_COL_NAME])

        blanked_slots_count = SlotBlankig._count_blanked_slots(columns_values_dic[SMFRC_COL_NAME])
        targetMutingRatio_verified = SlotBlankig._verify_targetMutingRatio_value(
            blanking_ratio,
            columns_values_dic[TMR_COL_NAME])

        logger.debug(f'Total blanked slots count: {blanked_slots_count}')
        logger.debug(
            f'Blanking ratio: {blanking_ratio} consistent' if targetMutingRatio_verified
            else f'Blanking ratio: {blanking_ratio} inconsistent')

        return (blanked_slots_count >= 0) and targetMutingRatio_verified

    @staticmethod
    def _verify_targetMutingRatio_value(target_value, slots):
        target_value = int(target_value)
        for slot_value in slots:
            if int(float(slot_value)) != target_value:
                return False
        return True

    @staticmethod
    def _count_blanked_slots(slots):
        blanked_slots_count = 0
        for slot in slots:
            if int(float(slot)) == 1:
                blanked_slots_count += 1
        return blanked_slots_count


class tti_trace(SlotBlankig, TtiMisc):
    """
        Class contain interface for robot framework
    """
