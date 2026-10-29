import os
import re
import ast
import shutil
from pathlib import Path
from typing import List, Tuple, Set, Dict
from datetime import datetime


class VariableListConverter:
    """Converts Python files to use variable_list pattern."""

    def __init__(self, backup: bool = True, verbose: bool = True):
        self.backup = backup
        self.verbose = verbose
        self.stats = {"processed": 0, "succeeded": 0, "failed": 0, "skipped": 0}

    def log(self, message: str, level: str = "INFO"):
        """Log a message if verbose is enabled."""
        if self.verbose:
            timestamp = datetime.now().strftime("%H:%M:%S")
            print(f"[{timestamp}] {level}: {message}")

    def extract_imports(self, content: str) -> str:
        """Extract all import statements from the file content."""
        lines = content.split("\n")
        imports = []
        in_import_block = True

        for line in lines:
            stripped = line.strip()

            if stripped.startswith("import ") or stripped.startswith("from "):
                imports.append(line)
            elif stripped.startswith("#") or not stripped:
                # Keep comments and blank lines in import section
                if in_import_block:
                    imports.append(line)
            else:
                # First non-import, non-comment line
                in_import_block = False
                break

        return "\n".join(imports)

    def extract_variables_from_ast(
        self, content: str
    ) -> List[Tuple[str, int, int, str]]:
        """Extract variable assignments with their position in the file."""
        try:
            tree = ast.parse(content)
        except SyntaxError as e:
            self.log(f"Syntax error parsing file: {e}", "ERROR")
            return []

        variables = []
        lines = content.split("\n")

        for node in tree.body:
            if isinstance(node, ast.Assign):
                for target in node.targets:
                    if isinstance(target, ast.Name):
                        var_name = target.id
                        start_line = node.lineno - 1
                        end_line = node.end_lineno

                        # Extract the full assignment including continuations
                        var_lines = []
                        for i in range(start_line, end_line):
                            if i < len(lines):
                                var_lines.append(lines[i])

                        var_value = "\n".join(var_lines)
                        # Remove variable name and = from start
                        var_value = re.sub(
                            r"^\s*" + re.escape(var_name) + r"\s*=\s*",
                            "",
                            var_value,
                            count=1,
                        )

                        variables.append(
                            (var_name, start_line, end_line, var_value.strip())
                        )

        return variables

    def find_variable_dependencies(
        self, var_name: str, var_value: str, all_vars: Set[str]
    ) -> List[str]:
        """Find which other variables this variable depends on."""
        dependencies = []
        for other_var in sorted(all_vars):  # Sort for consistent ordering
            if other_var != var_name:
                # Look for the variable as a whole word
                pattern = r"\b" + re.escape(other_var) + r"\b"
                if re.search(pattern, var_value):
                    dependencies.append(other_var)
        return dependencies

    def topological_sort(
        self, variables: List[Tuple[str, int, int, str]]
    ) -> List[Tuple[str, str]]:
        """Sort variables based on their dependencies."""
        var_dict = {name: value for name, _, _, value in variables}
        var_names = set(var_dict.keys())

        # Build dependency graph
        dependencies = {}
        for name, _, _, value in variables:
            dependencies[name] = self.find_variable_dependencies(name, value, var_names)

        # Topological sort using DFS
        sorted_vars = []
        visited = set()
        temp_mark = set()

        def visit(var_name):
            if var_name in temp_mark:
                # Circular dependency detected, continue anyway
                return
            if var_name in visited:
                return

            temp_mark.add(var_name)
            for dep in dependencies.get(var_name, []):
                if dep in var_names:
                    visit(dep)
            temp_mark.remove(var_name)
            visited.add(var_name)
            sorted_vars.append((var_name, var_dict[var_name]))

        # Visit all variables
        for name in var_dict.keys():
            if name not in visited:
                visit(name)

        return sorted_vars

    def replace_variable_references(self, value: str, var_names: Set[str]) -> str:
        """Replace references to other variables with var_dict['var_name']."""
        result = value

        # Sort by length (longest first) to avoid partial replacements
        sorted_vars = sorted(var_names, key=len, reverse=True)

        for var_name in sorted_vars:
            # Skip if already a var_dict reference
            if (
                f"var_dict['{var_name}']" in result
                or f'var_dict["{var_name}"]' in result
            ):
                continue

            # Replace standalone variable references with var_dict access
            # Only replace if not already inside quotes
            pattern = r"\b" + re.escape(var_name) + r"\b"

            # Parse character by character to avoid replacing inside strings
            new_result = []
            in_string = False
            quote_char = None
            i = 0

            while i < len(result):
                char = result[i]

                # Handle string delimiters (single or double quotes)
                if char in ('"', "'") and (i == 0 or result[i - 1] != "\\"):
                    if not in_string:
                        # Entering a string
                        in_string = True
                        quote_char = char
                        new_result.append(char)
                    elif char == quote_char:
                        # Exiting a string
                        in_string = False
                        quote_char = None
                        new_result.append(char)
                    else:
                        # Different quote type inside string
                        new_result.append(char)
                else:
                    new_result.append(char)

                i += 1

            # Now replace in non-string sections
            # Rebuild by splitting on quotes and only replacing outside strings
            temp = "".join(new_result)
            parts = []
            current_part = ""
            in_str = False
            q_char = None

            for idx, ch in enumerate(temp):
                if ch in ('"', "'") and (idx == 0 or temp[idx - 1] != "\\"):
                    if not in_str:
                        # Process the non-string part before entering string
                        if current_part:
                            current_part = re.sub(
                                pattern, f"var_dict['{var_name}']", current_part
                            )
                        parts.append(current_part)
                        current_part = ch
                        in_str = True
                        q_char = ch
                    elif ch == q_char:
                        # Exiting string - don't process this part
                        current_part += ch
                        parts.append(current_part)
                        current_part = ""
                        in_str = False
                        q_char = None
                    else:
                        current_part += ch
                else:
                    current_part += ch

            # Process any remaining part
            if current_part:
                if not in_str:
                    current_part = re.sub(
                        pattern, f"var_dict['{var_name}']", current_part
                    )
                parts.append(current_part)

            result = "".join(parts)

        return result

    def format_assignment(
        self, var_name: str, var_value: str, indent: str = "    "
    ) -> str:
        """Format a variable assignment with proper indentation."""
        lines = var_value.split("\n")

        if len(lines) == 1:
            return f"{indent}var_dict['{var_name}'] = {var_value}"

        # Multi-line assignment
        result = [f"{indent}var_dict['{var_name}'] = {lines[0]}"]
        for line in lines[1:]:
            # Preserve relative indentation
            result.append(f"{indent}{line}")

        return "\n".join(result)

    def convert_content(self, content: str) -> str:
        """Convert file content to use variable_list pattern."""
        # Extract imports
        imports = self.extract_imports(content)

        # Extract variables
        variables = self.extract_variables_from_ast(content)

        if not variables:
            self.log("No variables found to convert", "WARNING")
            return content

        self.log(f"Found {len(variables)} variable(s)")

        # Sort variables by dependencies
        sorted_vars = self.topological_sort(variables)

        # Get all variable names
        var_names = {name for name, _ in sorted_vars}

        # Build the new file content
        new_content = []
        new_content.append(imports)
        new_content.append("")
        new_content.append("def _build_variable_list():")
        new_content.append("    var_dict = {}")
        new_content.append("    ")

        for var_name, var_value in sorted_vars:
            # Replace variable references in the value
            updated_value = self.replace_variable_references(
                var_value, var_names - {var_name}
            )

            # Format and add the assignment
            assignment = self.format_assignment(var_name, updated_value)
            new_content.append(assignment)
            new_content.append("    ")

        new_content.append("    return var_dict")
        new_content.append("")
        new_content.append("test_alarms_list = _build_variable_list()")

        return "\n".join(new_content)

    def backup_file(self, file_path: Path) -> Path:
        """Create a backup of the file."""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_path = file_path.with_suffix(f".backup_{timestamp}{file_path.suffix}")
        shutil.copy2(file_path, backup_path)
        self.log(f"Backup created: {backup_path.name}")
        return backup_path

    def process_file(self, file_path: Path, replace: bool = True) -> bool:
        """Process a single file."""
        self.log(f"Processing: {file_path}")
        self.stats["processed"] += 1

        try:
            # Read original content
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()

            # Convert content
            new_content = self.convert_content(content)

            # Check if conversion made changes
            if new_content == content:
                self.log("No changes needed", "WARNING")
                self.stats["skipped"] += 1
                return True

            # Create backup if enabled
            if self.backup and replace:
                self.backup_file(file_path)

            # Write converted content
            if replace:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(new_content)
                self.log(f"✓ File converted successfully", "SUCCESS")
            else:
                output_path = file_path.with_suffix(".converted.py")
                with open(output_path, "w", encoding="utf-8") as f:
                    f.write(new_content)
                self.log(f"✓ Converted file saved to: {output_path.name}", "SUCCESS")

            self.stats["succeeded"] += 1
            return True

        except Exception as e:
            self.log(f"✗ Error: {e}", "ERROR")
            self.stats["failed"] += 1
            return False

    def process_folder(
        self, folder_path: Path, replace: bool = True, pattern: str = "*.py"
    ) -> None:
        """Process all Python files in a folder."""
        if not folder_path.exists():
            self.log(f"Folder does not exist: {folder_path}", "ERROR")
            return

        if not folder_path.is_dir():
            self.log(f"Path is not a folder: {folder_path}", "ERROR")
            return

        # Find all Python files
        python_files = list(folder_path.glob(pattern))

        # Exclude backup files
        python_files = [f for f in python_files if ".backup_" not in f.name]

        if not python_files:
            self.log(f"No Python files found in {folder_path}", "WARNING")
            return

        self.log(f"Found {len(python_files)} file(s) to process")
        self.log("=" * 60)

        for file_path in python_files:
            self.process_file(file_path, replace)
            print()  # Blank line between files

        self.print_summary()

    def print_summary(self):
        """Print processing summary."""
        self.log("=" * 60)
        self.log("SUMMARY:")
        self.log(f"  Total processed: {self.stats['processed']}")
        self.log(f"  Succeeded: {self.stats['succeeded']}")
        self.log(f"  Failed: {self.stats['failed']}")
        self.log(f"  Skipped: {self.stats['skipped']}")


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description="Convert Python files to use variable_list pattern",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-f", "--file", type=str, help="Single file to convert")
    group.add_argument(
        "-d", "--directory", type=str, help="Directory containing files to convert"
    )

    parser.add_argument(
        "--no-replace",
        action="store_true",
        help="Create new files instead of replacing existing ones",
    )
    parser.add_argument(
        "--no-backup",
        action="store_true",
        help="Do not create backup files (use with caution!)",
    )
    parser.add_argument(
        "-p",
        "--pattern",
        type=str,
        default="*.py",
        help="File pattern to match (default: *.py)",
    )
    parser.add_argument(
        "-q", "--quiet", action="store_true", help="Suppress output messages"
    )

    args = parser.parse_args()

    # Create converter
    converter = VariableListConverter(backup=not args.no_backup, verbose=not args.quiet)

    # Process file or directory
    if args.file:
        file_path = Path(args.file)
        if not file_path.exists():
            print(f"Error: File not found: {args.file}")
            return 1
        converter.process_file(file_path, replace=not args.no_replace)
        converter.print_summary()
    else:
        folder_path = Path(args.directory)
        converter.process_folder(
            folder_path, replace=not args.no_replace, pattern=args.pattern
        )

    return 0 if converter.stats["failed"] == 0 else 1


if __name__ == "__main__":
    exit(main())
