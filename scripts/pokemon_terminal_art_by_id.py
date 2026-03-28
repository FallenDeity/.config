#!/usr/bin/env python3
"""Print all compact fullcolor Pokémon terminal art variants for a given Pokémon ID.

This script searches the GitHub repository tree of:
  https://github.com/shinya/pokemon-terminal-art
for files matching:
  compact/fullcolor/<category>/<id>.txt
and prints every matching variant in the terminal.
"""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from typing import Iterable, List, Optional


DEFAULT_REPO = "shinya/pokemon-terminal-art"
API_BASE = "https://api.github.com"
RAW_BASE = "https://raw.githubusercontent.com"


@dataclass
class Variant:
    category: str
    path: str
    url: str


def _http_get_json(url: str, timeout: float) -> dict:
    request = urllib.request.Request(
        url,
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": "pokemon-terminal-art-by-id-script",
        },
    )
    with urllib.request.urlopen(request, timeout=timeout) as response:
        payload = response.read().decode("utf-8")
    return json.loads(payload)


def _http_get_text(url: str, timeout: float) -> str:
    request = urllib.request.Request(
        url,
        headers={
            "User-Agent": "pokemon-terminal-art-by-id-script",
        },
    )
    with urllib.request.urlopen(request, timeout=timeout) as response:
        return response.read().decode("utf-8", errors="replace")


def _resolve_default_branch(owner: str, repo: str, timeout: float) -> str:
    url = f"{API_BASE}/repos/{owner}/{repo}"
    data = _http_get_json(url, timeout=timeout)
    branch = data.get("default_branch")
    if not branch:
        raise RuntimeError("Could not resolve repository default branch.")
    return branch


def _fetch_tree(owner: str, repo: str, branch: str, timeout: float) -> list[dict]:
    branch_escaped = urllib.parse.quote(branch, safe="")
    url = f"{API_BASE}/repos/{owner}/{repo}/git/trees/{branch_escaped}?recursive=1"
    data = _http_get_json(url, timeout=timeout)
    tree = data.get("tree")
    if not isinstance(tree, list):
        raise RuntimeError("GitHub tree API returned an unexpected payload.")
    return tree


def _id_candidates(pokemon_id: int) -> set[str]:
    return {
        str(pokemon_id),
        f"{pokemon_id:03d}",
        f"{pokemon_id:04d}",
    }


def _find_compact_fullcolor_variants(
    tree: Iterable[dict],
    pokemon_id: int,
    owner: str,
    repo: str,
    branch: str,
) -> list[Variant]:
    candidates = _id_candidates(pokemon_id)
    variants: List[Variant] = []

    for node in tree:
        if node.get("type") != "blob":
            continue

        path = node.get("path")
        if not isinstance(path, str):
            continue

        if not path.startswith("compact/fullcolor/") or not path.endswith(".txt"):
            continue

        parts = path.split("/")
        if len(parts) < 4:
            continue

        file_stem = parts[-1][:-4]
        if file_stem not in candidates:
            continue

        category = parts[2]
        raw_url = f"{RAW_BASE}/{owner}/{repo}/{branch}/{path}"
        variants.append(Variant(category=category, path=path, url=raw_url))

    variants.sort(key=lambda item: (item.category.lower(), item.path.lower()))
    return variants


def _parse_repo(repo: str) -> tuple[str, str]:
    if "/" not in repo:
        raise ValueError("--repo must be in the format <owner>/<repo>")
    owner, name = repo.split("/", 1)
    if not owner or not name:
        raise ValueError("--repo must be in the format <owner>/<repo>")
    return owner, name


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Search pokemon-terminal-art for compact/fullcolor variants by Pokémon ID "
            "and print all matching variants in the terminal."
        )
    )
    parser.add_argument("pokemon_id", type=int, help="Pokémon National Dex ID (e.g. 25)")
    parser.add_argument(
        "--repo",
        default=DEFAULT_REPO,
        help=f"GitHub repo in owner/name format (default: {DEFAULT_REPO})",
    )
    parser.add_argument(
        "--branch",
        default=None,
        help="Git branch to use (default: repository default branch)",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=20.0,
        help="HTTP timeout in seconds (default: 20)",
    )
    parser.add_argument(
        "--list-only",
        action="store_true",
        help="Only print matched file paths, do not print art bodies",
    )
    return parser


def main() -> int:
    parser = build_arg_parser()
    args = parser.parse_args()

    if args.pokemon_id < 1:
        print("pokemon_id must be >= 1", file=sys.stderr)
        return 2

    try:
        owner, repo = _parse_repo(args.repo)
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 2

    try:
        branch = args.branch or _resolve_default_branch(owner, repo, timeout=args.timeout)
        tree = _fetch_tree(owner, repo, branch, timeout=args.timeout)
        variants = _find_compact_fullcolor_variants(
            tree=tree,
            pokemon_id=args.pokemon_id,
            owner=owner,
            repo=repo,
            branch=branch,
        )
    except urllib.error.HTTPError as exc:
        print(f"GitHub API HTTP error: {exc.code} {exc.reason}", file=sys.stderr)
        if exc.code == 403:
            print("Hint: unauthenticated GitHub API rate limit may be exceeded.", file=sys.stderr)
        return 1
    except urllib.error.URLError as exc:
        print(f"Network error: {exc.reason}", file=sys.stderr)
        return 1
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1

    if not variants:
        print(
            f"No compact/fullcolor variants found for Pokémon ID {args.pokemon_id} in {owner}/{repo}@{branch}.",
            file=sys.stderr,
        )
        return 1

    print(
        f"Found {len(variants)} compact/fullcolor variant(s) for ID {args.pokemon_id} "
        f"in {owner}/{repo}@{branch}."
    )

    for index, variant in enumerate(variants, start=1):
        header = f"[{index}/{len(variants)}] category={variant.category} path={variant.path}"
        print("\n" + "=" * len(header))
        print(header)
        print("=" * len(header))

        if args.list_only:
            continue

        try:
            art = _http_get_text(variant.url, timeout=args.timeout)
        except urllib.error.HTTPError as exc:
            print(f"Failed to fetch {variant.path}: {exc.code} {exc.reason}", file=sys.stderr)
            continue
        except urllib.error.URLError as exc:
            print(f"Failed to fetch {variant.path}: {exc.reason}", file=sys.stderr)
            continue

        print(art, end="" if art.endswith("\n") else "\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
