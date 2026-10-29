"""
Robot Framework library for handling IP Traffic Capture operations via a REST API.

This library provides keywords to start, stop, generate, and download
network traffic capture files.
"""

import base64
import gzip
import os
import re
import shutil
import tempfile
import time
import requests
import pyshark
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def log_response(step, response):
    """Log HTTP response status and content."""
    print(f"[DEBUG] {step} | Status: {response.status_code}")
    if "application/json" in response.headers.get("Content-Type", ""):
        print(f"[DEBUG] {step} | Response: {response.text or 'No content'}")
    else:
        print(f"[DEBUG] {step} | Binary response truncated")


def get_token(base_url, username, password):
    """Authenticate and return token and session."""
    credentials = f"{username}:{password}".encode()
    encoded = base64.b64encode(credentials).decode()
    url = f"{base_url}/api/licensed/sec/v1/login"
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": f"Basic {encoded}",
    }
    session = requests.Session()
    response = session.post(url, headers=headers, verify=False, timeout=30)
    log_response("Login", response)
    if response.ok:
        return response.json().get("Token"), session
    raise AssertionError("Authentication failed.")


def api_call(session, token, base_url, method, endpoint, json_data=None):
    """Perform generic API call with authentication."""
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": f"Bearer {token}",
    }
    url = f"{base_url}{endpoint}"
    response = session.request(
        method,
        url,
        headers=headers,
        json=json_data,
        verify=False,
        timeout=180,
    )
    log_response(endpoint, response)
    return response


def check_pcap(compressed_file, pcap_filter):
    """Decompress and apply PyShark filter to a PCAP file."""
    if not os.path.exists(compressed_file):
        print(f"[ERROR] Missing file: {compressed_file}")
        return 0

    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pcap") as temp_f:
            with gzip.open(compressed_file, "rb") as f_in:
                shutil.copyfileobj(f_in, temp_f)
            decompressed_pcap = temp_f.name

        cap = pyshark.FileCapture(decompressed_pcap, display_filter=pcap_filter)
        count = sum(1 for _ in cap)
        cap.close()
        os.remove(decompressed_pcap)
        return count
    except Exception as err:  # pylint: disable=broad-except
        print(f"[ERROR] Filter check failed: {err}")
        return 0


def perform_traffic_capture(base_url, username, password, action, plane_type,
                            pod_names, measurement_point, pcap_filter=None,
                            sleep_duration=30):
    """Perform traffic capture operation end-to-end."""
    token, session = get_token(base_url, username, password)

    start_data = {
        "captureType": "plane",
        "planeType": plane_type.split(","),
        "podNames": pod_names.split(","),
        "measurementPoint": measurement_point,
    }

    api_call(session, token, base_url, "post",
             "/api/licensed/v1/ip-traffic-capture/start", start_data)
    time.sleep(int(sleep_duration))

    api_call(session, token, base_url, "post",
             "/api/licensed/v1/ip-traffic-capture/stop")
    time.sleep(int(sleep_duration))

    if action == "start_stop_only":
        return ["SUCCESS", "START/STOP only"]

    api_call(session, token, base_url, "post",
             "/api/licensed/v1/ip-traffic-capture/generate")
    time.sleep(int(sleep_duration))

    r_status = api_call(session, token, base_url, "get",
                        "/api/licensed/v1/ip-traffic-capture/status")
    gnb_files = re.findall(r'"(gNB[^"]+)"', r_status.text)
    if not gnb_files:
        raise AssertionError("No gNB capture files found.")

    total_packets = 0
    for file_name in gnb_files:
        r_activate = api_call(session, token, base_url, "post",
                              "/api/licensed/v1/ip-traffic-capture/files/activate-upload")
        if not r_activate.ok:
            continue
        op_id = r_activate.json().get("operationId")
        d_url = f"/api/licensed/v1/ip-traffic-capture/upload/{op_id}/{file_name}"
        r_download = api_call(session, token, base_url, "get", d_url)
        if r_download.ok:
            with open(file_name, "wb") as file_out:
                file_out.write(r_download.content)
            if pcap_filter:
                total_packets += check_pcap(file_name, pcap_filter)
        api_call(session, token, base_url, "delete",
                 "/api/licensed/v1/ip-traffic-capture/files/activate-upload")

    return ["SUCCESS", total_packets]
