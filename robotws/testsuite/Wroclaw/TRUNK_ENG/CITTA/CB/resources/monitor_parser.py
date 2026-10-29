import os
import json


def get_cpu_statistics(cpu_statistics_dir):
    """
    Parses CPU statistics JSON files from the given directory and returns an HTML table.

    Each file is expected to contain a structure under:
    sysstat -> hosts[0] -> statistics[0] -> cpu-load

    Args:
        cpu_statistics_dir (str): Directory containing 'cpu_stats*.json' files.

    Returns:
        str: HTML string with a table of CPU load metrics over time.
    """
    sorted_files = _get_statistics_files("cpu_stats", cpu_statistics_dir)

    output = ""
    for file_path in sorted_files:
        try:
            with open(file_path, "r") as file:
                json_data = json.load(file)
                data = json_data["sysstat"]["hosts"][0]
                cpu_statistics = data["statistics"][0]
                timestamp = f"{data['date']} {cpu_statistics['timestamp']}"
                cpu_load_column_names = cpu_statistics["cpu-load"][0].keys()
                cpu_load_html = "".join(
                    f"{''.join(f'<td>{v}</td>' for v in statistic.values())}</tr>"
                    for statistic in cpu_statistics["cpu-load"]
                )
                output += f"<tr><td rowspan='5'>{timestamp}</td>{cpu_load_html}"
        except json.JSONDecodeError as e:
            print(f"Could not parse {file_path}: {e}")
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
    return f"""<table border='1' cellpadding='4' cellspacing='0'>
        <thead><th>timestamp</th>{"".join(f"<th>{v}</th>" for v in cpu_load_column_names)}</thead>
        <tbody>{output}<tbody></table>"""


def get_mem_statistics(cpu_statistics_dir):
    """
    Parses memory statistics JSON files from the given directory and returns an HTML table.

    Each file may contain nested dictionaries which are flattened into single-key entries.

    Args:
        cpu_statistics_dir (str): Directory containing 'mem_stats*.json' files.

    Returns:
        str: HTML string with a table of flattened memory usage data.
    """
    sorted_files = _get_statistics_files("mem_stats", cpu_statistics_dir)
    output = ""
    for file_path in sorted_files:
        try:
            with open(file_path, "r") as file:
                data = json.load(file)
                data_flattened = {
                    f"{k1}_{k2}" if k2 else k1: v2
                    for k1, v in data.items()
                    for k2, v2 in (v.items() if isinstance(v, dict) else [("", v)])
                }
                mem_load_column_names = data_flattened.keys()
                mem_load_html = f"<tr>{''.join(f'<td>{v}</td>' for v in data_flattened.values())}</tr>"
                output += mem_load_html
        except json.JSONDecodeError as e:
            print(f"Could not parse {file_path}: {e}")
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
    return f"""<table border='1' cellpadding='4' cellspacing='0'>
        <thead>{"".join(f"<th>{v}</th>" for v in mem_load_column_names)}</thead>
        <tbody>{output}<tbody></table>"""


def _get_statistics_files(stats_type, cpu_statistics_dir):
    """
    Retrieves and sorts JSON files from the given directory that match the specified type.

    Args:
        stats_type (str): Substring to match in filenames (e.g., 'cpu_stats' or 'mem_stats').
        cpu_statistics_dir (str): Directory path to search.

    Returns:
        List[str]: Sorted list of full file paths matching the type.
    """
    all_files = [
        os.path.join(cpu_statistics_dir, f)
        for f in os.listdir(cpu_statistics_dir)
        if f.endswith(".json") and stats_type in f
    ]
    return sorted(all_files, key=os.path.getmtime)
