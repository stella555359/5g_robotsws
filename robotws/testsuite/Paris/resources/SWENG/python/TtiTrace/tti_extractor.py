import os
import traceback
from itertools import islice
from taf.converters.eventdecoder import EventDecoderConverterFactory
from taf.analyzer.ttitrace import TtitraceReader as TtitraceReaderMulti
from taf.analyzer.ttitrace_eventdecoder import TtitraceReader as TtitraceReadereventDecoder
from robot.libraries.BuiltIn import BuiltIn
import logging
import json

logging.basicConfig(level=logging.INFO)  # Set desired log level
logger = logging.getLogger(__name__)


def decode_events_using_multi_decoder(file_name, events_to_analyze, num_of_events=None):
    return [event for event in islice(TtitraceReaderMulti.from_file(file_path=file_name), num_of_events)
            if event.type in events_to_analyze]


class ConverterFactory(EventDecoderConverterFactory):
    def _create_builtin(self):
        raise AssertionError


def validate_input(file_name, events_to_analyze):
    if events_to_analyze is None:
        events_to_analyze = []
    if not os.path.isfile(file_name):
        raise FileNotFoundError(f"File not found: {file_name}")
    if not isinstance(events_to_analyze, list):
        raise ValueError("events_to_analyze should be a list.")
    BuiltIn().log(f"events_to_analyze: {events_to_analyze}")
    return events_to_analyze


def decode_events_using_event_decoder(file_name, events_to_analyze, num_of_events=None,
                                      tti_dec_path="/opt/tti-dec/tti-dec-bin/", return_stuff=False):
    filtered_events = []
    try:
        events_to_analyze = validate_input(file_name, events_to_analyze) if events_to_analyze is None\
            else events_to_analyze
        if events_to_analyze != [] and 'utcTimestampData' not in events_to_analyze:
            events_to_analyze.append('utcTimestampData')
        BuiltIn().log(f"CONTENT of events_to_analyze: {events_to_analyze}")
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
                if events_to_analyze and event._event_data is not None and event.type in events_to_analyze:
                    filtered_events.append(event)
    except FileNotFoundError as e:
        print(f"Error: {e}. Please check the input file path.")
    except Exception as e:
        details = traceback.format_exc()
        print(f"Unexpected error: {e}. details={details}")
    if return_stuff:
        # Save filtered events to a new JSON file
        filtered_events_file = base_name + "_filtered.json"
        with open(filtered_events_file, 'w') as f:
            json.dump({"events": [event._event_data for event in filtered_events]}, f, indent=4)
        BuiltIn().log(f"Processed {len(filtered_events)} events and saved to {filtered_events_file}.")
        return filtered_events
    else:
        BuiltIn().log(f"Processed {len(filtered_events)} events.")


def decode_events_using_event_decoder_v1(file_name, tti_dec_path="/opt/tti-dec/tti-dec-bin/"):
    try:
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
    except FileNotFoundError as e:
        print(f"Error: {e}. Please check the input file path.")
    except Exception as e:
        details = traceback.format_exc()
        print(f"Unexpected error: {e}. details={details}")


def ttieventextractor(file_name, events_to_analyze, useMultiDecoder, num_of_events=None):
    if useMultiDecoder:
        return decode_events_using_multi_decoder(file_name, events_to_analyze, num_of_events=None)
    else:
        file_name = file_name.replace("udp", "pcap")
        return decode_events_using_event_decoder(file_name, events_to_analyze, num_of_events=None)
