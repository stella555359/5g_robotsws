#!/usr/bin/python3
# -*- coding: utf-8 -*-

import os
import zipfile
import logging


class TraceFastRingDecoderTool:

    def __init__(self, logger=None):
        self.logger = logger or logging.getLogger('TraceFastRingDecoder')
        self.app_path = '/home/ute/l1sw/tools/l1radio/tracefastringdecoder/trace_fast_ring_decoder.py'
        self.tool_location = '/home/ute/l1sw/tools/l1radio/tracefastringdecoder'
        # self.gitlab_url = 'https://gitlabe2.ext.net.nokia.com/p5li/tracefastringdecoder.git'
        # current is not available link, will add correct one later
        self.gitlab_url = 'https://gerrit.ext.net.nokia.com/gerrit/MN/L1/l1sw.git'

    def _exec_local_command(self, command):
        self.logger.info('Run command: {}'.format(command))
        return os.popen(command).read()

    def prepare_app(self):
        """
        This method ensures the tracefastringdecoder tool is available locally.
        If not, it downloads and prepares the tool.
        """
        if not os.path.exists(self.tool_location):
            self.logger.info('tracefastringdecoder does not exist. Downloading...')
            zip_path = '/tmp/tracefastringdecoder.zip'
            cmd_download = f'wget -O {zip_path} {self.gitlab_url}'
            self._exec_local_command(cmd_download)

            self.logger.info('Extracting the zip file...')
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall('/tmp/')

            self.logger.info('Cleaning up zip file...')
            os.remove(zip_path)
        else:
            self.logger.info(f'tracefastringdecoder already exists :: {self.tool_location}.')

        # Ensure the tool is executable
        self._exec_local_command('sudo chmod +x ' + self.app_path)
        self.logger.info('tracefastringdecoder is ready to use.')

    def run_decoder(self, target_path):
        """
        This method runs the trace_fast_ring_decoder.py tool to parse the target file.
        :param target_path: The path to the target .dat file to be parsed.
        """
        if not os.path.exists(target_path):
            raise FileNotFoundError(f'Target file does not exist: {target_path}')

        # Generate output file path by replacing .dat with .txt
        output_path = target_path.replace('.dat', '.txt')

        # Run the decoder tool
        cmd = f'{self.app_path} {target_path} > {output_path}'
        self._exec_local_command(cmd)

        return output_path

    def _cleanup_files(self):
        """
        cleanup .dat and .txt files in the tool directory.
        """
        self.logger.info('Cleaning up .dat and .txt files in the tool directory...')
        for file_name in os.listdir(self.tool_location):
            if file_name.endswith('.dat') or file_name.endswith('.txt'):
                file_path = os.path.join(self.tool_location, file_name)
                os.remove(file_path)
                self.logger.info(f'Deleted file: {file_path}')

    def decode_target_file(self, target_file):
        """
        Keyword to prepare the tool and decode the target file.
        :param target_file: The path to the target .dat file.
        """
        self.logger.info(f'Starting decoding process for: {target_file}')
        self.prepare_app()
        self._cleanup_files()
        output_file = self.run_decoder(target_file)
        self.logger.info(f'Decoding completed. Output file: {output_file}')
        return output_file
