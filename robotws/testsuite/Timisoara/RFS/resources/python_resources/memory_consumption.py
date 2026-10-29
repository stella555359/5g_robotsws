import subprocess
import time
import threading
from datetime import datetime
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s:%(message)s')


class memory_consumption:
    ROBOT_LIBRARY_SCOPE = 'TEST CASE'

    def __init__(self):
        self._monitoring_threads = {}
        self._stop_flags = {}
        self._memory_data = {}

    def start_continuous_memory_monitoring(self, monitor_id, process_pattern, interval=5):
        if monitor_id in self._monitoring_threads and self._monitoring_threads[monitor_id].is_alive():
            logging.warning(f"Monitoring for {monitor_id} is already running")
            return

        self._memory_data[monitor_id] = []
        self._stop_flags[monitor_id] = threading.Event()

        thread = threading.Thread(
            target=self._monitor_loop,
            args=(monitor_id, process_pattern, float(interval)),
            daemon=True
        )
        thread.start()
        self._monitoring_threads[monitor_id] = thread

        logging.debug(f"Started continuous memory monitoring for {monitor_id}")

    def _monitor_loop(self, monitor_id, process_pattern, interval):
        while not self._stop_flags[monitor_id].is_set():
            try:
                timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                command = (
                    f"ps aux | grep '{process_pattern}' | grep -v grep | "
                    "awk '{printf \"%s|%s|%s|%.2f\\n\", $2, $11, $4, $6/1024/1024}' "
                    "| tr '\\n' ' ' | sed 's/ $//'"
                )
                command_output = subprocess.getoutput(command)
                logging.debug(f"Command output for {monitor_id}: {command_output}")
                command_output_splits = command_output.split('|')
                if len(command_output_splits) < 4:
                    logging.warning(f"No matching process found for pattern '{process_pattern}' at {timestamp}")
                    time.sleep(interval)
                    continue
                else:
                    pid = command_output_splits[0]
                    comm = command_output_splits[1]
                    mem_percent = command_output_splits[2]
                    rss_gb = command_output_splits[3]
                    data_point = {
                        'timestamp': timestamp,
                        'pid': pid,
                        'command': comm,
                        'mem_percent': float(mem_percent),
                        'rss_gb': float(rss_gb)
                    }
                    self._memory_data[monitor_id].append(data_point)
            except Exception as e:
                logging.warning(f"Error in monitoring loop for {monitor_id}: {str(e)}")

            time.sleep(interval)

    def stop_continuous_memory_monitoring(self, monitor_id):
        if monitor_id not in self._stop_flags:
            logging.warning(f"No monitoring session found for {monitor_id}")
            return 0

        self._stop_flags[monitor_id].set()

        if monitor_id in self._monitoring_threads:
            self._monitoring_threads[monitor_id].join(timeout=5)

        data_count = len(self._memory_data.get(monitor_id, []))
        logging.debug(f"Stopped memory monitoring for {monitor_id}. Collected {data_count} data points.")

        return data_count

    def get_memory_statistics(self, monitor_id):
        if monitor_id not in self._memory_data or not self._memory_data[monitor_id]:
            logging.warning(f"No data found for {monitor_id}")
            return {
                'count': 0,
                'max_rss_gb': 0,
                'latest_rss_gb': 0,
                'max_mem_percent': 0,
                'latest_mem_percent': 0
            }

        data = self._memory_data[monitor_id]
        rss_values = [d['rss_gb'] for d in data]
        mem_percent_values = [d['mem_percent'] for d in data]

        stats = {
            'count': len(data),
            'max_rss_gb': max(rss_values),
            'latest_rss_gb': rss_values[-1],
            'max_mem_percent': max(mem_percent_values),
            'latest_mem_percent': mem_percent_values[-1],
        }
        logging.debug(stats)
        return stats

    def _get_all_memory_data(self, monitor_id):
        return self._memory_data.get(monitor_id, [])

    def clear_memory_data(self, monitor_id):
        if monitor_id in self._memory_data:
            del self._memory_data[monitor_id]
            logging.debug(f"Cleared memory data for {monitor_id}")

    def save_memory_data_to_file(self, monitor_id, file_path, mode):
        data = self._get_all_memory_data(monitor_id)
        if not data:
            logging.warning(f"No data to save for {monitor_id}")
            return
        with open(file_path, 'x', newline='') as file:
            file.write(f"Memory consumed by {monitor_id} in {mode} mode:\n")
            for row in data:
                file.write(f"timestamp:{row['timestamp']}\n")
                file.write(f"pid:{row['pid']}\n")
                file.write(f"command:{row['command']}\n")
                file.write(f"mem_percent:{row['mem_percent']}\n")
                file.write(f"rss_gb:{row['rss_gb']}\n")
                file.write("=======================================\n")
        logging.debug(f"Saved {len(data)} data points to {file_path}")
