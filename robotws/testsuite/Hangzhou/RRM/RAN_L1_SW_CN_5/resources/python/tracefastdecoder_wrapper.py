#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import os
from tracefastringdecoder_tool import TraceFastRingDecoderTool

# Global variable
_decoder_tool = None


def _get_decoder():
    """Get decoder instance"""
    global _decoder_tool
    if _decoder_tool is None:
        from tracefastringdecoder_tool import TraceFastRingDecoderTool
        _decoder_tool = TraceFastRingDecoderTool()
    return _decoder_tool


# Robot Framework keyword functions
def prepare_app():
    """Prepare decoding application"""
    decoder = _get_decoder()
    decoder.prepare_app()
    return "Decoder tool preparation completed"


def run_decoder(target_path):
    """Run decoder to decode specified file"""
    decoder = _get_decoder()
    return decoder.run_decoder(target_path)


def decode_target_file(target_file):
    """One-step decoding of target file"""
    decoder = _get_decoder()
    return decoder.decode_target_file(target_file)


# Test functions
if __name__ == '__main__':
    print("Testing wrapper...")
    prepare_app()
    print("Test completed")
