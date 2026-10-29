import logging
import os
import re
from urllib.parse import urljoin

import requests
from requests.exceptions import (
    HTTPError, ConnectionError, Timeout, RequestException
)
from robot.api.deco import keyword


# Configure logging for the library
logger = logging.getLogger(__name__)
logger.addHandler(logging.NullHandler())


class DownloadError(Exception):
    """Custom exception for download-related errors."""
    pass


class BsrDownloader:
    """
    A Robot Framework library for downloading ZIP files from a Nokia Artifactory
    instance, specifically from the 'mnpute-rotta-local/BSR/' repository.
    """

    ARTIFACTORY_BASE_URL = (
        "https://artifactory-espoo1.ext.net.nokia.com:443/"
        "artifactory/mnpute-rotta-local/BSR/"
    )
    DEFAULT_HEADERS = {
        "User-Agent": "curl/7.88.1",
        "Accept": "*/*"
    }

    @keyword("Download Matching Zips")
    def download_matching_zips(
        self, user: str, user_token: str, file_name_prefix: str,
        target_dir: str, verify_ssl: bool = True
    ) -> list:
        """
        Downloads all ZIP files from the configured Artifactory repository
        whose names start with `file_name_prefix`.

        Files are saved into the `target_dir`.

        Args:
            user (str): The username for Artifactory authentication.
            user_token (str): The API token or password for Artifactory authentication.
            file_name_prefix (str): The prefix that matching ZIP filenames must start with.
            target_dir (str): The local directory where downloaded files will be saved.
            verify_ssl (bool, optional): Whether to verify SSL certificates.
                                          Defaults to True. Set to False to disable
                                          SSL verification (e.g., for self-signed certs
                                          in internal environments).
                                          WARNING: Disabling SSL verification is a security risk
                                          and should only be done in trusted environments with full
                                          understanding of the implications.

        Returns:
            list: A list of absolute paths to the successfully downloaded files.

        Raises:
            DownloadError: If any critical error occurs during the download process,
                           such as connection issues, authentication failures,
                           or if no matching files are found/downloaded.
        """
        os.makedirs(target_dir, exist_ok=True)
        if not verify_ssl:
            logger.warning(
                "SSL certificate verification is disabled. This is a security risk "
                "and should only be used in trusted environments."
            )
        html_content = self._get_directory_listing(user, user_token, verify_ssl)
        zip_filenames = self._parse_zip_filenames(html_content, file_name_prefix)
        if not zip_filenames:
            raise DownloadError(
                f"No ZIP files found matching the prefix '{file_name_prefix}' "
                f"in {self.ARTIFACTORY_BASE_URL}."
            )
        downloaded_files = []
        for filename in zip_filenames:
            try:
                file_path = self._download_file(filename, user, user_token, target_dir, verify_ssl)
                downloaded_files.append(file_path)
            except DownloadError as e:
                logger.error(str(e))
                continue
        if not downloaded_files:
            raise DownloadError(
                f"No files were successfully downloaded, although "
                f"{len(zip_filenames)} matching files were found. "
                f"Check logs for individual download errors."
            )
        return downloaded_files

    def _get_directory_listing(self, user, user_token, verify_ssl):
        """Fetches the HTML directory listing from Artifactory."""
        try:
            logger.info(f"Retrieving directory listing from: {self.ARTIFACTORY_BASE_URL}")
            response = requests.get(
                self.ARTIFACTORY_BASE_URL,
                auth=(user, user_token),
                headers=self.DEFAULT_HEADERS,
                verify=verify_ssl,
                timeout=30
            )
            response.raise_for_status()
            return response.text
        except HTTPError as e:
            if e.response is not None and e.response.status_code in (401, 403):
                raise DownloadError(
                    f"Authentication failed or access denied for Artifactory at "
                    f"{self.ARTIFACTORY_BASE_URL}. Status: {e.response.status_code}"
                ) from e
            raise DownloadError(
                f"HTTP error while fetching directory listing from "
                f"{self.ARTIFACTORY_BASE_URL}: {e}"
            ) from e
        except ConnectionError as e:
            raise DownloadError(
                f"Connection error while reaching Artifactory at "
                f"{self.ARTIFACTORY_BASE_URL}: {e}"
            ) from e
        except Timeout as e:
            raise DownloadError(
                f"Timeout while fetching directory listing from Artifactory at "
                f"{self.ARTIFACTORY_BASE_URL}: {e}"
            ) from e
        except RequestException as e:
            raise DownloadError(
                f"An unexpected requests error occurred while fetching directory "
                f"listing from {self.ARTIFACTORY_BASE_URL}: {e}"
            ) from e

    def _parse_zip_filenames(self, html_content, file_name_prefix):
        """Parses the HTML content to extract matching ZIP filenames."""
        pattern = (
            rf'(?<=href=")({re.escape(file_name_prefix)}\.zip)(?=")'
        )
        matches = re.findall(pattern, html_content)
        logger.debug(f"Found matching ZIP files: {matches}")
        return matches

    def _download_file(self, filename, user, user_token, target_dir, verify_ssl):
        """Downloads a single file and returns its absolute path. Raises DownloadError on failure."""
        file_url = urljoin(self.ARTIFACTORY_BASE_URL, filename)
        file_path = os.path.join(target_dir, filename)
        logger.info(f"Downloading '{filename}' to '{file_path}'...")
        try:
            with requests.get(
                file_url,
                auth=(user, user_token),
                verify=verify_ssl,
                stream=True,
                timeout=60
            ) as file_response:
                file_response.raise_for_status()
                with open(file_path, 'wb') as f:
                    for chunk in file_response.iter_content(chunk_size=8192):
                        if chunk:
                            f.write(chunk)
            logger.info(f"Successfully downloaded '{filename}'.")
            return os.path.abspath(file_path)
        except HTTPError as e:
            raise DownloadError(
                f"HTTP error while downloading '{filename}' from '{file_url}': {e}"
            ) from e
        except ConnectionError as e:
            raise DownloadError(
                f"Connection error while downloading '{filename}' from '{file_url}': {e}"
            ) from e
        except Timeout as e:
            raise DownloadError(
                f"Timeout while downloading '{filename}' from '{file_url}': {e}"
            ) from e
        except RequestException as e:
            raise DownloadError(
                f"Requests error while downloading '{filename}' from '{file_url}': {e}"
            ) from e
        except IOError as e:
            raise DownloadError(
                f"Error writing downloaded file '{filename}' to '{file_path}': {e}"
            ) from e
        except Exception as e:
            raise DownloadError(
                f"Unexpected error during download of '{filename}': {e}"
            ) from e
