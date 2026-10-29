"""
PM Period Segment Analyzer Library

This library provides functionality to analyze PM period segments and calculate
free periods between defined subscenarios.
"""

import logging
from typing import List, Dict, Any, Tuple


class Segment:
    """Represents a segment with offset and duration."""

    def __init__(self, offset, duration, name=""):
        """Initialize a segment."""
        self.offset = offset
        self.duration = duration
        self.name = name

    @property
    def start(self):
        """Start position of the segment."""
        return self.offset

    @property
    def end(self):
        """End position of the segment (inclusive)."""
        return self.offset + self.duration - 1

    def __str__(self):
        if self.name:
            return (f"{self.name}: offset={self.offset}, "
                    f"duration={self.duration} "
                    f"(periods {self.start}-{self.end})")
        return (f"offset={self.offset}, duration={self.duration} "
                f"(periods {self.start}-{self.end})")


class PMPeriodSegmentAnalyzer:
    """
    PM Period Segment Analyzer.

    Analyzes PM period segments and calculates free periods.

    This class takes a global segment definition and subscenario
    definitions, then calculates the remaining free segments between
    the subscenarios.
    """

    def __init__(self):
        """Initialize the segment analyzer."""
        self.global_segment = None
        self.subscenarios = []
        self.free_segments = []
        self.all_segments = []

        logging.info("PM Period Segment Analyzer initialized")

    def validate_global_segment(self, initial_offset: int,
                                total_periods: int) -> Tuple[int, int]:
        """
        Validate global segment parameters.

        Args:
            initial_offset (int): Starting PM period value
            total_periods (int): Number of periods in the segment

        Returns:
            tuple: (initial_offset, total_periods) validated values

        Raises:
            ValueError: If parameters are invalid
        """
        if not isinstance(initial_offset, int):
            raise ValueError(
                f"Initial offset must be an integer, "
                f"got: {type(initial_offset)}"
            )

        if not isinstance(total_periods, int) or total_periods <= 0:
            raise ValueError(
                f"Total periods must be a positive integer, "
                f"got: {total_periods}"
            )

        return initial_offset, total_periods

    def validate_subscenario_dict(
            self, sub_dict: Dict[str, Any]) -> Tuple[str, int, int]:
        """
        Validate and extract subscenario parameters from dictionary.

        Args:
            sub_dict (dict): Dictionary containing 'name', 'offset',
                           and 'duration'

        Returns:
            tuple: (name, offset, duration) validated values

        Raises:
            ValueError: If required keys are missing or values are invalid
        """
        required_keys = ['name', 'offset', 'duration']
        missing_keys = [key for key in required_keys if key not in sub_dict]

        if missing_keys:
            raise ValueError(
                f"Missing required keys in subscenario dictionary: "
                f"{missing_keys}"
            )

        name = str(sub_dict['name'])
        if not name.strip():
            raise ValueError("Subscenario name cannot be empty")

        try:
            offset = int(sub_dict['offset'])
            duration = int(sub_dict['duration'])
        except (ValueError, TypeError) as e:
            raise ValueError(f"Offset and duration must be integers: {e}")

        if offset < 0:
            raise ValueError(f"Offset must be non-negative, got: {offset}")

        if duration <= 0:
            raise ValueError(f"Duration must be positive, got: {duration}")

        return name, offset, duration

    def check_subscenario_bounds(self, name: str, offset: int,
                                 duration: int,
                                 global_start: int,
                                 global_end: int) -> None:
        """
        Check if subscenario fits within global segment bounds.

        Args:
            name (str): Subscenario name
            offset (int): Subscenario offset
            duration (int): Subscenario duration
            global_start (int): Global segment start
            global_end (int): Global segment end

        Raises:
            ValueError: If subscenario is out of bounds
        """
        sub_start = offset
        sub_end = offset + duration - 1

        if sub_start < global_start:
            raise ValueError(
                f"Subscenario '{name}' starts at {sub_start} "
                f"before global segment start {global_start}"
            )

        if sub_end > global_end:
            raise ValueError(
                f"Subscenario '{name}' ends at {sub_end} "
                f"after global segment end {global_end}"
            )

    def detect_overlaps(
            self, subscenarios: List[Segment]) -> List[Tuple[str, str]]:
        """
        Detect overlapping subscenarios.

        Args:
            subscenarios (list): List of Segment objects

        Returns:
            list: List of tuples with overlapping subscenario names
        """
        overlaps = []

        for i, sub1 in enumerate(subscenarios):
            for j, sub2 in enumerate(subscenarios[i+1:], i+1):
                # Check if segments overlap
                if not (sub1.end < sub2.start or sub2.end < sub1.start):
                    overlaps.append((sub1.name, sub2.name))

        return overlaps

    def calculate_free_segments(self, global_start: int, global_end: int,
                                subscenarios: List[Segment]) -> List[Segment]:
        """
        Calculate free segments between subscenarios.

        Args:
            global_start (int): Global segment start
            global_end (int): Global segment end
            subscenarios (list): List of subscenario segments

        Returns:
            list: List of free segments
        """
        if not subscenarios:
            # No subscenarios, entire segment is free
            duration = global_end - global_start + 1
            return [Segment(offset=global_start, duration=duration,
                            name="free")]

        # Sort subscenarios by start position
        sorted_subs = sorted(subscenarios, key=lambda s: s.start)

        free_segments = []
        current_pos = global_start

        for sub in sorted_subs:
            # Check if there's a gap before this subscenario
            if current_pos < sub.start:
                gap_duration = sub.start - current_pos
                free_segments.append(
                    Segment(offset=current_pos, duration=gap_duration,
                            name="free")
                )

            # Move current position to end of this subscenario
            current_pos = sub.end + 1

        # Check if there's a gap after the last subscenario
        if current_pos <= global_end:
            gap_duration = global_end - current_pos + 1
            free_segments.append(
                Segment(offset=current_pos, duration=gap_duration,
                        name="free")
            )

        return free_segments

    def analyze_segments(self, initial_offset: int, total_periods: int,
                         subscenario_list: List[Dict[str, Any]],
                         allow_overlaps: bool = False) -> Dict[str, Any]:
        """
        Analyze PM period segments and calculate free periods.

        Args:
            initial_offset (int): Starting PM period value (e.g., 2)
            total_periods (int): Number of periods in the segment (e.g., 16)
            subscenario_list (list): List of subscenario dictionaries
            allow_overlaps (bool): Whether to allow overlapping subscenarios

        Returns:
            dict: Analysis results with segments and statistics

        Example:
            analyzer = PMPeriodSegmentAnalyzer()
            result = analyzer.analyze_segments(
                initial_offset=2,
                total_periods=16,
                subscenario_list=[
                    {"name": "subSce1", "offset": 6, "duration": 2},
                    {"name": "subSce2", "offset": 12, "duration": 2}
                ]
            )
        """
        # Validate global segment
        initial_offset, total_periods = self.validate_global_segment(
            initial_offset, total_periods
        )

        global_start = initial_offset
        global_end = initial_offset + total_periods - 1

        # Store global segment info
        self.global_segment = Segment(
            offset=global_start, duration=total_periods, name="global"
        )

        # Validate and create subscenario segments
        subscenarios = []
        for i, sub_dict in enumerate(subscenario_list):
            try:
                name, offset, duration = self.validate_subscenario_dict(
                    sub_dict
                )
                self.check_subscenario_bounds(
                    name, offset, duration, global_start, global_end
                )

                segment = Segment(offset=offset, duration=duration, name=name)
                subscenarios.append(segment)

            except Exception as e:
                raise ValueError(f"Error processing subscenario {i}: {e}")

        # Check for overlaps
        overlaps = self.detect_overlaps(subscenarios)
        if overlaps and not allow_overlaps:
            overlap_pairs = [
                f"'{pair[0]}' and '{pair[1]}'" for pair in overlaps
            ]
            raise ValueError(
                f"Overlapping subscenarios detected: {', '.join(overlap_pairs)}"
            )

        # Calculate free segments
        free_segments = self.calculate_free_segments(
            global_start, global_end, subscenarios
        )

        # Store results
        self.subscenarios = subscenarios
        self.free_segments = free_segments
        self.all_segments = subscenarios + free_segments

        # Sort all segments by start position
        self.all_segments.sort(key=lambda s: s.start)

        # Create result dictionary
        result = {
            "global_segment": {
                "start": global_start,
                "end": global_end,
                "duration": total_periods,
                "range": list(range(global_start, global_end + 1))
            },
            "subscenarios": [
                {"name": s.name, "offset": s.offset, "duration": s.duration}
                for s in subscenarios
            ],
            "free_segments": [
                {"offset": s.offset, "duration": s.duration}
                for s in free_segments
            ],
            "all_segments_ordered": [
                {
                    "name": s.name if s.name != "free" else f"free_{i}",
                    "offset": s.offset,
                    "duration": s.duration,
                    "type": "subscenario" if s.name != "free" else "free"
                }
                for i, s in enumerate(self.all_segments)
            ],
            "statistics": {
                "total_periods": total_periods,
                "subscenario_count": len(subscenarios),
                "free_segment_count": len(free_segments),
                "subscenario_periods": sum(s.duration for s in subscenarios),
                "free_periods": sum(s.duration for s in free_segments),
                "utilization_percent": round(
                    (sum(s.duration for s in subscenarios) / total_periods)
                    * 100, 2
                ),
                "overlaps_detected": len(overlaps) if overlaps else 0
            }
        }

        logging.info(
            f"Segment analysis completed: {len(subscenarios)} subscenarios, "
            f"{len(free_segments)} free segments, "
            f"{result['statistics']['utilization_percent']}% utilization"
        )

        return result

    def get_simple_segment_list(self) -> List[Dict[str, int]]:
        """
        Get a simple list of segments as requested in the example.

        Returns:
            list: List of dictionaries with offset and duration only

        Example output for the given example:
            [{"offset": 2, "duration": 4}, {"offset": 6, "duration": 2},
             {"offset": 8, "duration": 4}, {"offset": 12, "duration": 2},
             {"offset": 14, "duration": 4}]
        """
        if not self.all_segments:
            raise ValueError(
                "No analysis performed yet. Call analyze_segments() first."
            )

        return [
            {"offset": s.offset, "duration": s.duration}
            for s in self.all_segments
        ]

    def print_visual_timeline(self) -> None:
        """Print a visual representation of the timeline."""
        if not self.global_segment:
            print("No analysis performed yet.")
            return

        start = self.global_segment.start
        end = self.global_segment.end
        print(f"\nVisual Timeline (PM periods {start} to {end}):")
        print("=" * 60)

        # Print period numbers
        periods = list(range(start, end + 1))
        period_line = "Periods: " + " ".join(f"{p:2d}" for p in periods)
        print(period_line)

        # Print segment assignments
        segment_assignments = ["  "] * len(periods)

        for segment in self.all_segments:
            start_idx = segment.start - self.global_segment.start
            for i in range(segment.duration):
                if start_idx + i < len(segment_assignments):
                    if segment.name == "free":
                        segment_assignments[start_idx + i] = "F "
                    else:
                        segment_assignments[start_idx + i] = "S "

        assignment_line = "Types:   " + "".join(segment_assignments)
        print(assignment_line)
        print("Legend: F=Free, S=Subscenario")

        # Print detailed segments
        print("\nDetailed Segments:")
        for i, segment in enumerate(self.all_segments):
            segment_type = (
                "FREE" if segment.name == "free" else "SUBSCENARIO"
            )
            print(f"  {i+1}. {segment_type:11} - {segment}")
