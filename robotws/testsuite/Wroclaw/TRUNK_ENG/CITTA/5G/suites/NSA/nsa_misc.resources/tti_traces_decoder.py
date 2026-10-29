# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Monika Kurzyp
:contact: monika.kurzyp@nokia.com
"""
import logging
import os
import subprocess
import requests
import tempfile

from zipfile import ZipFile
from urllib.parse import urlunparse

logger = logging.getLogger(__file__)


def _prepare_venv(decoder_dir):
    venv_path = f"{decoder_dir}/.venv"
    deps_file = f"{decoder_dir}/requirements.txt"

    logger.debug(f"Creating new virtual environment under {venv_path}")
    venv = subprocess.run(
        args=["python", "-m", "venv", venv_path],
        capture_output=True,
        text=True,
    )
    if venv.returncode != 0:
        logger.error(venv.stderr)
        raise RuntimeError("Failed to create virtual environment")

    logger.debug(f"Installing dependencies from {deps_file} into virtual environment")
    pip = subprocess.run(
        args=[
            f"{venv_path}/bin/python",
            "-m",
            "pip",
            "install",
            "-q",
            "-r",
            deps_file,
        ],
        capture_output=True,
        text=True,
    )
    if pip.returncode != 0:
        logger.error(pip.stderr)
        raise RuntimeError("Failed to install TtiTraceDecoder dependencies")


def _run_tti_trace_decoder(decoder_dir, tti_file_path, output_format):
    """
    Run TtiTraceDecoder.py in order to decode tti file into chosen format
    :param str decoder_dir: path to TtiTraceDecoder.py parent directory
    :param str tti_file_path: path to the tti file
    :param str output_format: json, legacyCsv
    :return:
    """
    _python = f"{decoder_dir}/.venv/bin/python"

    if os.path.isfile(_python):
        logger.debug(f"Found vitual environment inside {decoder_dir}.")
    else:
        _prepare_venv(decoder_dir)

    logger.debug(f"Using {_python} for decoder script execution.")
    p = subprocess.run(
        args=[_python, "./TtiTraceDecoder.py", tti_file_path, output_format],
        capture_output=True,
        cwd=decoder_dir,
        text=True,
    )
    logger.debug(p.stdout)
    if p.returncode != 0:
        logger.error(p.stderr)
        raise RuntimeError("Failed. TTI file was not decoded.")
    if "Following output files generated. Ciao!" in p.stdout:
        logger.info("TTI file was decoded successfully")
    else:
        logger.warning("This should never have happen")


def download_tti_decoder(branch, build, output_path="/tmp"):
    """Downloads TTI trace decoder from Artifactory to output_path

    :param str branch: SW branch name
    :param str build: tested SW build
    :param str output_path: target directory for TTI trace decoder download
    :return: str tti_decoder_file_path: direct path to compresed TTI trace decoder file
    """
    file_name = f"{build}_tti-dec_qemux86-64-static.txz"
    url = urlunparse(
        (
            "https",
            "artifactory-espoo2.int.net.nokia.com",
            f"artifactory/mn-cosi-sran-central-public-local/build/{branch}/{build}/{file_name}",
            "",
            "",
            ""
        )
    )
    session = requests.Session()
    session.trust_env = False

    with open("/etc/token/ca_ute_artifactory_readonly", "r") as token_file:
        access_token = token_file.read().rstrip()
    headers = {"Authorization": f"Bearer {access_token}"}

    request = session.get(url, headers=headers, stream=True)
    if request.status_code == 404:
        msg = f"TTI not found, URL seems to be invalid: {url}"
        logger.error(msg)
        raise Exception(msg)
    request.raise_for_status()
    tti_decoder_file_path = os.path.abspath(os.path.join(output_path, file_name))
    with open(tti_decoder_file_path, "wb") as file_:
        for chunk in request.iter_content(1024):
            file_.write(chunk)
    return tti_decoder_file_path


def extract_tti_file_from_snapshot(tti_snapshot_path, target_directory):
    """
    Extract *first* tti traces file 'XXX_EventsSnapshot.bin' from snapshot to target directory.
    :param str tti_snapshot_path: path to snapshot
    :param str target_directory: path to directory where 'XXX_EventsSnapshot.bin' file will be saved
    :return: str snapshot_tti_file_target_path: path to 'XXX_EventsSnapshot.bin' file
    """
    logger.info('Extracting tti file from snapshot: %s' % tti_snapshot_path)
    with ZipFile(tti_snapshot_path, 'r') as zipObj:
        temp_directory_path = tempfile.mkdtemp()
        zipObj.extractall(temp_directory_path)
    for file in os.listdir(temp_directory_path):
        if file.endswith('.zip'):
            file_path = temp_directory_path + '/' + file
            with ZipFile(file_path, 'r') as zipObj:
                listOfFileNames = zipObj.namelist()
                for f in listOfFileNames:
                    if f.endswith('EventsSnapshot.bin.xz'):
                        zipObj.extract(f, target_directory)
                        snapshot_tti_file_target_path_xz = target_directory + '/' + f
                        subprocess.check_output(['unxz', snapshot_tti_file_target_path_xz])
                        return os.path.splitext(snapshot_tti_file_target_path_xz)[0]
    logger.warn("We could not find any tti trace file in {}".format(tti_snapshot_path))
    return None


def decode_tti_file(tti_decoder_path, tti_file_path, format):
    """
    Decode tti file into indicated format by decoder assign to the SW build
    :param tti_decoder_path: path to TTI decoder
    :param tti_file_path: path to the TTI file
    :param format: json, legacyCsv
    """
    root_dir = tti_decoder_path + "/tti-dec-bin"
    _run_tti_trace_decoder(root_dir, tti_file_path, format)
