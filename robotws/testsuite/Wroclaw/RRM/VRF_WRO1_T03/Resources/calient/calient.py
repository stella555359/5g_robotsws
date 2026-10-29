import requests
import re
import json
import os

# Replace with your actual switch IP and credentials
CALIENT_API_URL = "https://10.44.234.100/rest/"
USERNAME = "auto"
PASSWORD = "CSrqFn7j%xd4ZZ"
CONN_TO_RESTORE_FILE = 'del_connections_to_restore.json'
CONN_FOR_55217 = [
    {'in': 137, 'out': 125, 'name': 'AUTO_VRF_1_3'},
    {'in': 138, 'out': 126, 'name': 'AUTO_VRF_1_3'},
    {'in': 140, 'out': 127, 'name': 'AUTO_VRF_1_3'},
    {'in': 139, 'out': 128, 'name': 'AUTO_VRF_1_3'}
    ]


def post_request(endpoint, data):
    """Sends a POST request to the Calient API."""
    url = f"{CALIENT_API_URL}{endpoint}"
    headers = {"Content-Type": "application/json"}

    try:
        response = requests.post(url, auth=(USERNAME, PASSWORD), json=data, headers=headers, timeout=10, verify=False)
        return handle_response(response)
    except requests.exceptions.RequestException as e:
        return {"error": "Request failed", "message": str(e)}


def handle_response(response):
    """Handles API responses."""
    if response.status_code in [200, 201, 204]:
        return response.json() if response.content else {"message": "Success"}
    else:
        return {"error": f"Failed: {response.status_code}", "message": response.text}


def delete_request(endpoint):
    """Sends a DELETE request to the Calient API."""
    url = f"{CALIENT_API_URL}{endpoint}"
    headers = {"Content-Type": "application/json"}

    try:
        response = requests.delete(url, auth=(USERNAME, PASSWORD), headers=headers, timeout=10, verify=False)
        return handle_response(response)
    except requests.exceptions.RequestException as e:
        return {"error": "Request failed", "message": str(e)}


def get_request(endpoint):
    """Sends a GET request to the Calient API."""
    url = f"{CALIENT_API_URL}{endpoint}"
    headers = {"Content-Type": "application/json"}

    try:
        response = requests.get(url, auth=(USERNAME, PASSWORD), headers=headers, timeout=10, verify=False)
        return handle_response(response)
    except requests.exceptions.RequestException as e:
        return {"error": "Request failed", "message": str(e)}


def search_conn_id_for_out_port(out_port_list):
    """Fetches active connections and filters them using regex."""
    response = get_request("crossconnects/?id=list")

    if "error" in response:
        return response  # Return error response if API call fails

    connections = response if isinstance(response, list) else []

    filtered_connections_out = [
        conn for conn in connections if matches_out_port_pattern(conn.get("connid"), out_port_list)
    ]
    filtered_connections_in = [
        conn for conn in connections if matches_in_port_pattern(conn.get("connid"), out_port_list)
    ]
    return filtered_connections_out, filtered_connections_in


def search_conn_id_for_in_port(in_port_list):
    """Fetches active connections and filters them using regex."""
    response = get_request("crossconnects/?id=list")

    if "error" in response:
        return response  # Return error response if API call fails

    connections = response if isinstance(response, list) else []

    filtered_connections_in = [
        conn for conn in connections if matches_in_port_pattern(conn.get("connid"), in_port_list)
    ]
    return filtered_connections_in


def matches_out_port_pattern(value, out_ports):
    pattern = r">(\d+)"
    for port in out_ports:
        m = re.search(pattern, value)
        if m and int(m.group(1)) == int(port):
            return value


def matches_in_port_pattern(value, in_ports):
    pattern = r"(\d+)>"
    for port in in_ports:
        m = re.search(pattern, value)
        if m and int(m.group(1)) == int(port):
            return value


def convert_to_regex(num_list):
    """Converts a list of numbers into a list of regex string patterns."""
    return [rf"{num}" for num in num_list]


def delete_conn(del_conn):
    deleted_con = []
    print(del_conn)
    for in_out_list in del_conn:
        for con in in_out_list:
            con_id = con.get("connid")
            con_name = con.get("name")
            con_group = con.get("group")
            print(f"DELETE: {con_id} {con_name} {con_group}")
            print(delete_request(
                f"crossconnects/?id=delete&conn={con_id}&group={con_group}&name={con_name}"))
            deleted_con.append({"in": re.match(r"^(\d+)>", con_id).group(1),
                                "out": re.search(r">(\d+)", con_id).group(1),
                                "name": re.match(r'([a-zA-Z]+)_', con_name).group(1)})
    return deleted_con


def create_conn(conn_list):
    for conn in conn_list:
        in_port = conn["in"]
        out_port = conn["out"]
        name = conn["name"]
        conn_name = f"{name}_{in_port}>{out_port}"
        print(f"CREATE: IN:{in_port} OUT:{out_port} NAME:{conn_name}")
        print(post_request(
            f"crossconnects/?id=add", {"in": in_port, "out": out_port, "conn": conn_name, "dir": "uni"}))


def prepare_calient_connections(new_con=CONN_FOR_55217):
    port_list_out = [item['out'] for item in new_con]
    regex_out_list = convert_to_regex(port_list_out)
    active_con = search_conn_id_for_out_port(regex_out_list)
    deleted_con_list = delete_conn(active_con)
    port_list_in = [item['in'] for item in new_con]
    regex_in_list = convert_to_regex(port_list_in)
    active_con = search_conn_id_for_in_port(regex_in_list)
    deleted_con_list = delete_conn(active_con)
    if deleted_con_list:
        with open(CONN_TO_RESTORE_FILE, "w") as f:
            json.dump(deleted_con_list, f, indent=4)
    create_conn(new_con)
    return deleted_con_list


def clean_and_restore_calient_connections(con_list=CONN_FOR_55217):
    out_list = [item['out'] for item in con_list]
    regex_out_list = convert_to_regex(out_list)
    active_con = search_conn_id_for_out_port(regex_out_list)
    delete_conn(active_con)
    if os.path.exists(CONN_TO_RESTORE_FILE):
        with open(CONN_TO_RESTORE_FILE, "r") as file:
            conn_to_restore = json.load(file)
        create_conn(conn_to_restore)
        os.remove(CONN_TO_RESTORE_FILE)
