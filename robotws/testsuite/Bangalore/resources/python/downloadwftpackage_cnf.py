# downloadwftpackage_cnf.py
"""
This library is used for fetching build-related information,
such as version numbers, URLs, and metadata for Cloud RAN from WFT.

It can be imported into Robot Framework using:

    Library    build_fetcher.py

    ...   author: CIT T04, sudarshan.kanapuram@nokia.com
    ...   contact: CIT T04, sudarshan.kanapuram@nokia.com
    ...   Description: CIT basic TC, sudarshan.kanapuram@nokia.com
Version: 1.0
"""

import os
import json
from tqdm import tqdm
import requests
import re
from datetime import datetime, timedelta, time, timezone
from dateutil.parser import parse as parse_date


class DownloadWftPackageCnf:
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self.SOURCE_URL = (
            "https://wft.int.net.nokia.com:8091/ALL/api/v1/promotion.json?access_key="
            "apJbdeEE72Bj6gkiqoTtFhvDokuehdk4NNCH8vsD&view[page]=1&view[items]=20&view[sorting_field]=created_at&view"
            "[sorting_direction]=DESC&view[group_by]=promotion_tag.tag&view[columns][][id]=branch.title&view[columns][]"
            "[id]=build.baseline&view[columns][][id]=created_at&view[view_filters_attributes][991947975982228][column]="
            "active&view[view_filters_attributes][991947975982228][operation]=eq&view[view_filters_attributes]"
            "[991947975982228][value][]=1&")

        self.ATTR_URL_TEMPLATE = (
            "https://wft.int.net.nokia.com/api/v1/CRAN/CI_RAN/builds/{}/attributes.json?"
            "access_key=apJbdeEE72Bj6gkiqoTtFhvDokuehdk4NNCH8vsD")
        self.DOWNLOAD_URL_TEMPLATE = (
            "https://artifactory-hz1.int.net.nokia.com/artifactory/"
            "mnp5g-central-public-remote/System_Release/{}/{}/{}.zip"
        )

    def fetch_json(self, url, desc):
        try:
            print(f"[INFO] Fetching {desc} from {url}")
            response = requests.get(url, timeout=15)
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            raise RuntimeError(f"[ERROR] Failed to fetch {desc}: {e}")

    def download_cnf_sw_file(self, cnf, build_id, output_dir):
        if "-amd64" in build_id:
            url = self.DOWNLOAD_URL_TEMPLATE.format(
                cnf, build_id.replace("-amd64", ""), build_id)
        else:
            url = self.DOWNLOAD_URL_TEMPLATE.format(
                cnf, build_id, build_id + "-amd64")
        filename = os.path.join(output_dir, f"{build_id}.zip")
        if os.path.exists(filename):
            print(f"[INFO] File already exists, skipping download: {filename}")
            return True
        try:
            response = requests.get(url, stream=True, timeout=30)
            response.raise_for_status()

            total = int(response.headers.get('content-length', 0))
            os.makedirs(output_dir, exist_ok=True)

            with open(filename, 'wb') as f, tqdm(
                desc=f"Downloading {build_id}",
                total=total,
                unit='iB',
                unit_scale=True,
                unit_divisor=1024,
            ) as bar:
                for chunk in response.iter_content(1024):
                    f.write(chunk)
                    bar.update(len(chunk))

            print(f"[INFO] File saved to {filename}")
        except requests.RequestException as e:
            raise RuntimeError(f"[ERROR] Failed to download file: {e}")

    def extract_vdu_build_id(self, data, time_frame):
        now_utc = datetime.now(timezone.utc)  # Timezone-aware

        # Define yesterday 5:30 PM and today 5:30 PM in UTC
        end_time = now_utc.replace(
            hour=int(
                time_frame.split("-")[0]),
            minute=int(
                time_frame.split("-")[1]),
            second=int(
                time_frame.split("-")[2]),
            microsecond=0)
        if now_utc < end_time:
            # If current time is before 5:30 PM, then 'today 5:30 PM' is
            # actually in future
            end_time = end_time
            start_time = end_time - timedelta(days=1)
        else:
            # Else today 5:30 PM is now or earlier
            start_time = end_time
            end_time = end_time + timedelta(days=1)

        print("Time window:", start_time, "to", end_time)

        for item in data["items"]["REGRESSION"]:
            if item.get("branch.title") == "vDUCNF00":
                created = parse_date(item["created_at"])
                print("Build created_at:", created)
                if start_time <= created < end_time:
                    return item["build.baseline"]

        return None

    def extract_vcu_build_id(self, attribute_data):
        for item in attribute_data:
            raw_value = item.get('value')
            if not raw_value:
                continue
            try:
                parsed = json.loads(raw_value)
                vcu_list = parsed.get("vCUCNF", [])
                if vcu_list:
                    return vcu_list[0]  # first vCUCNF ID
            except json.JSONDecodeError as e:
                print(f"Failed to parse JSON in 'value': {e}")
        return None

    def extract_build_number(self, build_id, suffix="-amd64"):
        """
        Extract numeric build number from a build_id string.
        Example: 'vDUCNF00_0.300.31234-amd64' → '31234'
        """
        print(f"[DEBUG] Received build_id: {build_id} ({type(build_id)})")
        if not isinstance(build_id, str):
            raise TypeError(
                f"Expected string, got {type(build_id).__name__}: {build_id}")
            # Escape the suffix safely in case it's not '-amd64'
        escaped_suffix = re.escape(suffix)

        # Match pattern: _0.300.31033-amd64 → capture 31033
        pattern = rf'_(\d+\.\d+)\.(\d+){escaped_suffix}$'
        match = re.search(pattern, build_id)
        if match:
            return match.group(2)
        else:
            raise ValueError(
                f"Failed to extract build number from: {build_id}")

    def update_plan_variable(
            self,
            file_path,
            variable_name,
            pattern_prefix,
            new_value,
            full_replace=False):
        """
        Update a variable in the given file:
        - If full_replace is False, replaces only the numeric suffix after the pattern_prefix
          e.g., vCUCNF00_0.250.30413 → vCUCNF00_0.250.30435
        - If full_replace is True, replaces the entire string with new_value
        """
        updated = False

        with open(file_path, "r") as f:
            lines = f.readlines()

        new_lines = []
        for line in lines:
            if variable_name in line:
                original_line = line
                print("new_line test3 ", line)
                if full_replace:
                    # Replace the whole assignment string with new_value
                    new_line = re.sub(
                        rf'({re.escape(variable_name)}\s*=\s*")[^"]+(")',
                        rf'\1{new_value}\2',
                        line
                    )
                    print("new_line test1 ", new_line)
                else:
                    # Replace only the number suffix in the string matching
                    # pattern_prefix
                    pattern = rf'({re.escape(pattern_prefix)})(\d+)'

                    def replacer(match):
                        return f"{match.group(1)}{new_value}"
                    new_line = re.sub(pattern, replacer, line)
                if new_line != original_line:
                    updated = True
                    print(
                        f"[INFO] Updated line: {original_line.strip()} → {new_line.strip()}")
                new_lines.append(new_line)
            else:
                new_lines.append(line)

        with open(file_path, "w") as f:
            f.writelines(new_lines)

        if updated:
            print(f"[SUCCESS] '{variable_name}' updated in file: {file_path}")
        else:
            print(
                f"[WARN] No update made for '{variable_name}' in file: {file_path}")

    def fetch_and_prepare_builds(self, time_frame="12-00-00"):
        """
        This method will fetch the promoted vDU and vCU build versions under "REGRESSION" from WFT
        """
        # Step 1: Get vDUCNF00
        builds_data = self.fetch_json(self.SOURCE_URL, "vDU build list")
        vdu_build_id = self.extract_vdu_build_id(builds_data, time_frame)
        if not vdu_build_id:
            raise ValueError("No vDUCNF00 build found for today.")

        print(f"[INFO] Found vDU_build_id: {vdu_build_id}")

        # Step 2: Get vCUCNF00
        attr_data = self.fetch_json(
            self.ATTR_URL_TEMPLATE.format(vdu_build_id),
            "vDU attributes")
        print(attr_data)
        vcu_build_id = self.extract_vcu_build_id(attr_data)
        if not vcu_build_id:
            raise ValueError("vCUCNF00 not found in attributes.")

        print(f"[INFO] Found vCU_build_id: {vcu_build_id}")
        return vdu_build_id + "-amd64", vcu_build_id + "-amd64"
