import subprocess
from robot.api import logger

artifactory_api_key = "AKCp5cc6qcfvRmnWFrznCzBbxvK73vsBJ8CCVPprVxPPTKzSMtqxsNi4TqaNpW59CTMpWwfzM"


def download_file_from_artifactory(download_path, filename, artifactory_url):
    """Keyword download a given filename from given artifactory to a download_path localization on VM

       Arguments:
       - `download_path` [mandatory] string - file path where the file will be downloaded
       - 'filename' [mandatory] string - name of the file to download
       - 'artifactory_url [mandatory] string - link to artifactory folder where file is located"""
    logger.console("Downloading " + filename)
    download_command = (
        f"cd {download_path} && wget --continue --header 'X-JFrog-Art-Api:{artifactory_api_key}' "
        f"{artifactory_url}{filename}")
    process = subprocess.Popen(download_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    logger.debug(f"WGET returned code {process.returncode}")
    if process.returncode == 0:
        logger.info(stdout.decode())
        logger.console("Download complete")
    else:
        logger.debug(stderr.decode())
        raise Exception(f"Download failed! WGET returned code {process.returncode}")
    return download_path + filename
