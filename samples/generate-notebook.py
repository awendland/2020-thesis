"""
Script to generate a runnable Jupyter notebook from any `samples/*.wat` files.
A valid `ipynb` file (which is JSON) will be written to `stdout`.

Each `.wat` file is expected to follow a loosely structured comment format. See
the existing files to get an intuitive sense for it, or review the regex below
to understand how parsing occurs. Sorry, it's just working with what I haphazardly
wrote for comments several months ago.

P.S. this apology is for future Alex, since he's the only one that will ever
read this file. Sorry future Alex, if you ever, for some odd reason, decide to
revisit this and add more `.wat` samples.
"""
import glob
import json
import re
from pathlib import Path

re_sections = re.compile(
    r";; ======\n([\s\S]+?)\n;; ======(?:\n([\s\S]+?)((?=;; ======)|\Z))?"
)
re_comment_lines = re.compile(r"^;; ?", re.MULTILINE)

re_title = re.compile(r"\A\s*(.+?)$", re.MULTILINE)
re_reference = re.compile(r"^\s*Reference: (.+?)$", re.MULTILINE)
re_dependencies = re.compile(r"^\s*Dependencies: (.+?)$", re.MULTILINE)
re_extra_notes = re.compile(r"^\s*Dependencies: .+?\n\n([\s\S]+?)\Z", re.MULTILINE)

re_addendum = re.compile(r"^\s*Addendum: ([\s\S]+)", re.MULTILINE)


def parse_content(sample_content):
    for section in re_sections.finditer(sample_content):
        header = re_comment_lines.sub("", section.group(1)).strip()
        content = section.group(2).strip() if section.group(2) else None

        addendum = re_addendum.search(header)
        if addendum is not None:
            yield {"type": "addendum", "notes": addendum.group(1), "content": content}

        else:
            extra_notes = re_extra_notes.search(header)
            yield {
                "type": "main",
                "title": re_title.search(header).group(1),
                "reference": re_reference.search(header).group(1),
                "dependencies": re_dependencies.search(header).group(1),
                "extra_notes": extra_notes.group(1) if extra_notes else None,
                "content": content,
            }


def nb_cells(data):
    if data["type"] == "main":
        yield {
            "cell_type": "markdown",
            "metadata": {},
            "source": f"""\
### {data["title"]}

{data["extra_notes"] if data["extra_notes"] is not None else ""}

This is related to {data["reference"]}. It leverages {data["dependencies"]}.""",
        }
    elif data["type"] == "addendum":
        yield {
            "cell_type": "markdown",
            "metadata": {},
            "source": "#### " + data["notes"],
        }

    if data["content"] is not None and len(data["content"]) > 0:
        yield {
            "cell_type": "code",
            "metadata": {},
            "source": data["content"],
            "execution_count": None,
            "outputs": [],
        }


wat_files = sorted(list(Path(__file__).parent.glob("*.wat")))
wat_content = (f.read_text() for f in wat_files)
wat_data = (parse_content(c) for c in wat_content)
cells = (
    c for ds in wat_data for d in ds for c in nb_cells(d)
)  # double-nested generator flattenning

notebook = {
    "metadata": {
        "kernelspec": {
            "display_name": "WebAssembly Reference Interpreter",
            "language": "wat",
            "name": "wasm_spec",
        },
        "language_info": {
            "codemirror_mode": "commonlisp",
            "file_extension": ".wat",
            "mimetype": "text/x-common-lisp",
            "name": "wasm_spec",
        },
    },
    "nbformat": 4,
    "nbformat_minor": 4,
    "cells": [
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": """\
# Thesis: Code Samples

This notebook is for my ([Alex Wendland](https://blog.alexwendland.com/)) undergraduate thesis for Honors in Computer Science at Harvard called [WebAssembly as a Multi-Language Platform](https://github.com/awendland/2020-thesis).

The following code samples are taken from the thesis and made runnable inside this Jupyter notebook via [wasm-spec-kernel](https://github.com/awendland/wasm_spec_kernel).

For my thesis I added support for abstract types (similar to [OCaml's abstract types](https://ocaml.org/learn/tutorials/modules.html#Abstract-types)) to the [reference interpreter](https://github.com/WebAssembly/spec/tree/master/interpreter) for WebAssembly. My extended interpreter can be found at [awendland/webassembly-spec-abstypes](https://github.com/awendland/webassembly-spec-abstypes).
Each demo will specify if they need this language extension by saying `leverages Core WebAssembly + abstract types`. Demos that don't include `+ abstract types` can be run using an WebAssembly v1 compliant engine.
If you launched this notebook via the Binder link in the README, wasm-spec-kernel will already be properly configured to use my extended interpreter. Otherwise, see the [wasm-spec-kernel repo](https://github.com/awendland/wasm_spec_kernel) for configuration instructions.
""",
        },
    ]
    + list(cells),
}

print(json.dumps(notebook, indent=2))
