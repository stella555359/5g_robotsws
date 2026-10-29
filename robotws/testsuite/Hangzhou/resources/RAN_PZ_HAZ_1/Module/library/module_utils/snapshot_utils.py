"""
:copyright: Nokia
:author: winnie.he
:contact: winnie.he@nokia-sbell.com
:maintainer winnie.he:
:contact winnie.he@nokia-sbell.com
This class use for handle the snapshot file, to unzip the file from snapshot
"""
import os
import re
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class snapshot_utils:
    def __init__(self):
        """
        Initialize the SnapshotUtils with the path to the PM file.
        :param pmfile_path: Path to the PM file directory.
        """
        pass

    def get_pmfile_from_snapshot_file_vran(self, snapshot_file_path, file_reg):
        zip_file = None
        pmcounter_zip_file_path = None
        base_path = os.path.dirname(snapshot_file_path)
        with open(snapshot_file_path, 'r') as f:
            for line in f.readlines():
                if line.strip().endswith(":"):
                    zip_file = line.strip()
                if re.search(file_reg, line) is not None and zip_file is not None:
                    pmcounter_zip_file_path = os.path.join(base_path,
                                                           zip_file.replace(":", ""))
                    logging.info(f"unzip -o {pmcounter_zip_file_path} -d {base_path}")
                    os.system(f"unzip -o {pmcounter_zip_file_path} -d {base_path}")
                    pmcounter_zip_file_path = os.path.join(base_path, line.strip())
                    logging.info(f"unzip -o {pmcounter_zip_file_path} -d {base_path}")
                    os.system(f"unzip -o {pmcounter_zip_file_path} -d {base_path}")
                    logging.info(f"gunzip {base_path}/*.gz")
                    os.system(f"gunzip -f {base_path}/*.gz")
        for root, dirs, files in os.walk(base_path):
            for file in files:
                if not file.endswith(".xml.gz") and not file.endswith(".xml"):
                    os.remove(os.path.join(root, file))
        return base_path

    def get_pmfile_from_snapshot_file_classical(self, snapshot_file_path, file_reg):
        zip_file = None
        pmcounter_zip_file_path = None
        base_path = os.path.dirname(snapshot_file_path)
        with open(snapshot_file_path, 'r') as f:
            for line in f.readlines():
                if line.strip().endswith(":"):
                    zip_file = line.strip()
                if re.search(file_reg, line) is not None and zip_file is not None:
                    pmcounter_zip_file_path = os.path.join(base_path,
                                                           zip_file.replace(":", ""))
                    # logging.info(f"unzip -o {pmcounter_zip_file_path} -d {base_path}")
                    os.system(f"unzip -o {pmcounter_zip_file_path} -d {base_path}")
                    # logging.info(f"gunzip {base_path}/*.gz")
                    os.system(f"gunzip -f {base_path}/*.gz")
        for root, dirs, files in os.walk(base_path):
            for file in files:
                if not file.endswith(".xml") and re.search(file_reg, file) is None:
                    os.remove(os.path.join(root, file))
        return base_path

    def process_gz_file(self, pmfile_path):
        for root, dirs, files in os.walk(pmfile_path):
            for file in files:
                if file.endswith(".gz"):
                    gz_file_path = os.path.join(root, file)
                    # try to unzip the gz
                    result = os.system(f"gunzip -f {gz_file_path}")
                    # check and remove the unusefull file
                    if result != 0 or not os.path.exists(gz_file_path.replace(".gz", "")):
                        logging.warning(f"Failed to process {gz_file_path}. Deleting it.")
                        os.remove(gz_file_path)
