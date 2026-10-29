import os
import traceback
from itertools import islice
from taf.converters.eventdecoder import EventDecoderConverterFactory
from taf.analyzer.ttitrace import TtitraceReader as TtitraceReaderMulti
from taf.analyzer.ttitrace_eventdecoder import TtitraceReader as TtitraceReadereventDecoder

import logging

logging.basicConfig(level=logging.INFO)  # Set desired log level
logger = logging.getLogger(__name__)


def decode_events_using_multi_decoder(file_name, events_to_analyze, num_of_events=None):
    return [
        event
        for event in islice(
            TtitraceReaderMulti.from_file(
                file_path=file_name),
            num_of_events)
        if event.type in events_to_analyze]


class ConverterFactory(EventDecoderConverterFactory):
    def _create_builtin(self):
        raise AssertionError


def validate_input(file_name, events_to_analyze):
    if not os.path.isfile(file_name):
        raise FileNotFoundError(f"File not found: {file_name}")
    if not isinstance(events_to_analyze, list):
        raise ValueError("events_to_analyze should be a list.")


def decode_events_using_event_decoder(file_name, events_to_analyze, num_of_events=None,
                                      tti_dec_path="/opt/tti-dec/tti-dec-bin/"):
    try:
        validate_input(file_name, events_to_analyze)
        filtered_events = []
        factory = ConverterFactory()
        base_name, _ = os.path.splitext(file_name)
        converter = factory.create(
            configuration=dict(
                input_file_path=file_name,
                output_file_path=base_name,
                output_file_format="json",
                tti_dec_path=tti_dec_path,
            ),
            existing_arguments={})
        converter.convert()

        with open(base_name + ".json", 'rb') as file_obj:
            for event in islice(TtitraceReadereventDecoder(file_obj=file_obj), num_of_events):
                if event.type in events_to_analyze:
                    filtered_events.append(event)
    except FileNotFoundError as e:
        print(f"Error: {e}. Please check the input file path.")
    except Exception as e:
        details = traceback.format_exc()
        print(f"Unexpected error: {e}. details={details}")
    logger.info(f"Processed {len(filtered_events)} events.")
    return filtered_events


def decode_events_using_event_decoder_v1(file_name, events_to_analyze, num_of_events=None,
                                         tti_dec_path="/opt/tti-dec/tti-dec-bin/"):
    filtered_events = []
    factory = ConverterFactory()
    base_name, _ = os.path.splitext(file_name)
    converter = factory.create(
        configuration=dict(
            input_file_path=file_name,
            output_file_path=base_name,
            output_file_format="json",
            tti_dec_path=tti_dec_path,
        ),
        existing_arguments={})
    converter.convert()

    with open(base_name + ".json", 'rb') as file_obj:
        for event in islice(TtitraceReadereventDecoder(file_obj=file_obj), num_of_events):
            if event.type in events_to_analyze:
                filtered_events.append(event)

    return filtered_events


def ttieventextractor(file_name, events_to_analyze, useMultiDecoder, num_of_events=None):
    if useMultiDecoder:
        return decode_events_using_multi_decoder(file_name, events_to_analyze, num_of_events=None)
    else:
        file_name = file_name.replace("udp", "pcap")
        return decode_events_using_event_decoder(file_name, events_to_analyze, num_of_events=None)
