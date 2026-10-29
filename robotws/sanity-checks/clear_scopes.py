"""
Clears out every path unrelated to the given paths.
"""

from __future__ import annotations

import sys
from collections import namedtuple
from pathlib import Path
from shutil import rmtree

cli_args = namedtuple("args", ("start_from", "target_scope", "ignored_paths"))


def remove(path: Path):
    if path.is_dir():
        rmtree(path)
    else:
        path.unlink()


def prune_tree(start_from: Path, ignore: list[Path]) -> None:
    """Remove all subtrees of start_from.

    Ignores all subpaths of start_from present in the ignore list and their
    parent directories.
    """
    assert start_from.is_absolute()

    ignored_parents = []
    for path in ignore:
        ignored_parents.extend(start_from / node for node in nodes_on_path(path))

    ignored = [start_from / ignored_path for ignored_path in ignore]

    for file_or_directory in start_from.iterdir():
        if file_or_directory in ignored:
            continue
        if file_or_directory in ignored_parents:
            ignored_subpaths = [
                path.relative_to(file_or_directory)
                for path in ignored
                if path.is_relative_to(file_or_directory)
            ]
            prune_tree(file_or_directory, ignored_subpaths)
            continue

        # For safety
        assert file_or_directory.name != ".git"

        remove(file_or_directory)


def parse_args() -> cli_args:
    prog_name, *all_arguments = sys.argv

    if len(all_arguments) < 2:
        print(f"Usage: {prog_name} start_from target_scope [ignored paths]")
        sys.exit(1)

    start_from, target_scope, *ignored_paths = [Path(arg) for arg in all_arguments]

    assert start_from.is_dir(), "start path must be a valid directory path."
    assert (
        start_from / target_scope
    ).is_dir(), (
        "target scope must be a valid directory path under the starting directory."
    )

    for ignored in ignored_paths:
        if not (start_from / ignored).exists():
            print(f"WARNING: ignored path {ignored!s} does not exist")

    return cli_args(start_from, target_scope, ignored_paths)


def ignore_adjecent_on_the_way(adjecent_name: str, scope: Path) -> list[Path]:
    nodes = nodes_on_path(scope)
    return [Path(adjecent_name)] + [p / adjecent_name for p in nodes]


def nodes_on_path(path: Path) -> list[Path]:
    return [p for p in path.parents if p != Path(".")][::-1]


if __name__ == "__main__":
    start_from, target_scope, ignored_paths = parse_args()
    start_from = start_from.expanduser().resolve()
    ignored_paths += ignore_adjecent_on_the_way("resources", target_scope)
    ignored_paths += ignore_adjecent_on_the_way("__init__.py", target_scope)

    additional_inits_to_ignore = []
    for path in ignored_paths:
        init_paths = ignore_adjecent_on_the_way("__init__.py", path)
        additional_inits_to_ignore.extend(init_paths)

    ignored_paths += additional_inits_to_ignore
    ignored_paths = list(set(ignored_paths))

    ignored_paths.append(target_scope)
    prune_tree(start_from, ignore=ignored_paths)
