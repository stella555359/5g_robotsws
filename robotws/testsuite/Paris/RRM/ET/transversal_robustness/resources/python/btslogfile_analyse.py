import os
import shutil
import logging
import time
from datetime import datetime
import threading
import re


class CircularFileParser:
    def __init__(self, source_directory, destination_directory_base,
                 include_filter_file, exclude_filter_file, log_file, polling_interval=10):
        self.source_directory = source_directory
        self.destination_directory_base = destination_directory_base
        self.include_filter_file = include_filter_file
        self.exclude_filter_file = exclude_filter_file
        self.polling_interval = polling_interval
        self.processed_files = set()
        self.thread = None
        self.stop_thread = threading.Event()

        # Load filters
        self.include_patterns = self.load_patterns(self.include_filter_file)
        self.exclude_patterns = self.load_patterns(self.exclude_filter_file)

    def load_patterns(self, file_path):
        with open(file_path, 'r') as file:
            return [line.strip() for line in file.readlines()]

    def get_files_in_directory(self, directory):
        pattern = re.compile(r'SYSLOG_[0-5]\.LOG')
        return [os.path.join(directory, f) for f in os.listdir(directory)
                if os.path.isfile(os.path.join(directory, f)) and pattern.match(f)]

    def search_in_file(self, file_path):
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                content = file.read()
        except UnicodeDecodeError:
            with open(file_path, 'r', encoding='latin-1') as file:
                content = file.read()

        include_matches = [pattern for pattern in self.include_patterns if re.search(pattern, content)]
        exclude_matches = [pattern for pattern in self.exclude_patterns if re.search(pattern, content)]
        return include_matches, exclude_matches

    def run(self):
        time.sleep(self.polling_interval)

        # Log the matches
        log_message = f"New log_file opening"
        with open('/tmp/btslog2/log_summary.log', 'a') as log_file:
            log_file.write(f"{datetime.now()} - {log_message}\n")

        while not self.stop_thread.is_set():
            try:
                files = self.get_files_in_directory(self.source_directory)
                files.sort(key=os.path.getmtime)  # Sort files by modification time
                if len(files) < 2:
                    print("No complete file to process continue !!!")
                    time.sleep(self.polling_interval)
                    continue

                # Get the second last file
                second_last_file = files[-2]

                # Check if the second last file has been processed
                if second_last_file not in self.processed_files:
                    include_matches, exclude_matches = self.search_in_file(second_last_file)
                    if include_matches and not exclude_matches:
                        # Create a unique destination directory with a timestamp suffix
                        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                        destination_directory = f"{self.destination_directory_base}_{timestamp}"
                        os.makedirs(destination_directory, exist_ok=True)

                        # Move the second last files to the destination directory
                        shutil.move(second_last_file, destination_directory)

                        # Log the matches
                        log_message = f"File: {second_last_file} - Include Matches: {', '.join(include_matches)}"

                        # Write the log message to a file
                        with open('/tmp/btslog2/log_summary.log', 'a') as log_file:
                            log_file.write(f"{datetime.now()} - {log_message}\n")
                        print(f"{datetime.now()} - {log_message}\n")  # debug print

                time.sleep(self.polling_interval)
            except Exception as e:
                print(f"Exception occured: {e}")

    def start(self):
        self.thread = threading.Thread(target=self.run)
        self.thread.start()

    def stop(self):
        self.stop_thread.set()
        self.thread.join()
