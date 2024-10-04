import subprocess
from pathlib import Path

from lxml import etree
from rich.console import Console
from rich.table import Table

# error codes for domain, type, and level found here:
# https://gitlab.gnome.org/GNOME/libxml2/-/blob/master/doc/devhelp/libxml2-xmlerror.html
DOMAIN_COLOR = "orange3"
XML_ERROR_DOMAINS = {
    0: f"[{DOMAIN_COLOR}]XML_FROM_NONE[/{DOMAIN_COLOR}]: [dim]No error[/dim]",
    1: f"[{DOMAIN_COLOR}]XML_FROM_PARSER[/{DOMAIN_COLOR}]: [dim]The XML parser[/dim]",
    2: f"[{DOMAIN_COLOR}]XML_FROM_TREE[/{DOMAIN_COLOR}]: [dim]The tree module[/dim]",
    3: f"[{DOMAIN_COLOR}]XML_FROM_NAMESPACE[/{DOMAIN_COLOR}]: [dim]The XML Namespace module[/dim]",
    4: f"[{DOMAIN_COLOR}]XML_FROM_DTD[/{DOMAIN_COLOR}]: [dim]The XML DTD validation with parser context[/dim]",
    5: f"[{DOMAIN_COLOR}]XML_FROM_HTML[/{DOMAIN_COLOR}]: [dim]The HTML parser[/dim]",
    6: f"[{DOMAIN_COLOR}]XML_FROM_MEMORY[/{DOMAIN_COLOR}]: [dim]The memory allocator[/dim]",
    7: f"[{DOMAIN_COLOR}]XML_FROM_OUTPUT[/{DOMAIN_COLOR}]: [dim]The serialization code[/dim]",
    8: f"[{DOMAIN_COLOR}]XML_FROM_IO[/{DOMAIN_COLOR}]: [dim]The Input/Output stack[/dim]",
    9: f"[{DOMAIN_COLOR}]XML_FROM_FTP[/{DOMAIN_COLOR}]: [dim]The FTP module[/dim]",
    10: f"[{DOMAIN_COLOR}]XML_FROM_HTTP[/{DOMAIN_COLOR}]: [dim]The HTTP module[/dim]",
    11: f"[{DOMAIN_COLOR}]XML_FROM_XINCLUDE[/{DOMAIN_COLOR}]: [dim]The XInclude processing[/dim]",
    12: f"[{DOMAIN_COLOR}]XML_FROM_XPATH[/{DOMAIN_COLOR}]: [dim]The XPath module[/dim]",
    13: f"[{DOMAIN_COLOR}]XML_FROM_XPOINTER[/{DOMAIN_COLOR}]: [dim]The XPointer module[/dim]",
    14: f"[{DOMAIN_COLOR}]XML_FROM_REGEXP[/{DOMAIN_COLOR}]: [dim]The regular expressions module[/dim]",
    15: f"[{DOMAIN_COLOR}]XML_FROM_DATATYPE[/{DOMAIN_COLOR}]: [dim]The W3C XML Schemas Datatype module[/dim]",
    16: f"[{DOMAIN_COLOR}]XML_FROM_SCHEMASP[/{DOMAIN_COLOR}]: [dim]The W3C XML Schemas parser module[/dim]",
    17: f"[{DOMAIN_COLOR}]XML_FROM_SCHEMASV[/{DOMAIN_COLOR}]: [dim]The W3C XML Schemas validation module[/dim]",
    18: f"[{DOMAIN_COLOR}]XML_FROM_RELAXNGP[/{DOMAIN_COLOR}]: [dim]The Relax-NG parser module[/dim]",
    19: f"[{DOMAIN_COLOR}]XML_FROM_RELAXNGV[/{DOMAIN_COLOR}]: [dim]The Relax-NG validator module[/dim]",
    20: f"[{DOMAIN_COLOR}]XML_FROM_CATALOG[/{DOMAIN_COLOR}]: [dim]The Catalog module[/dim]",
    21: f"[{DOMAIN_COLOR}]XML_FROM_C14N[/{DOMAIN_COLOR}]: [dim]The Canonicalization module[/dim]",
    22: f"[{DOMAIN_COLOR}]XML_FROM_XSLT[/{DOMAIN_COLOR}]: [dim]The XSLT engine from libxslt[/dim]",
    23: f"[{DOMAIN_COLOR}]XML_FROM_VALID[/{DOMAIN_COLOR}]: [dim]The XML DTD validation with valid context[/dim]",
    24: f"[{DOMAIN_COLOR}]XML_FROM_CHECK[/{DOMAIN_COLOR}]: [dim]The error checking module[/dim]",
    25: f"[{DOMAIN_COLOR}]XML_FROM_WRITER[/{DOMAIN_COLOR}]: [dim]The xmlwriter module[/dim]",
    26: f"[{DOMAIN_COLOR}]XML_FROM_MODULE[/{DOMAIN_COLOR}]: [dim]The dynamically loaded module module[/dim]",
    27: f"[{DOMAIN_COLOR}]XML_FROM_I18N[/{DOMAIN_COLOR}]: [dim]The module handling character conversion[/dim]",
    28: f"[{DOMAIN_COLOR}]XML_FROM_SCHEMATRONV[/{DOMAIN_COLOR}]: [dim]The Schematron validator module[/dim]",
    29: f"[{DOMAIN_COLOR}]XML_FROM_BUFFER[/{DOMAIN_COLOR}]: [dim]The buffers module[/dim]",
    30: f"[{DOMAIN_COLOR}]XML_FROM_URI[/{DOMAIN_COLOR}]: [dim]The URI module[/dim]",
}

# too many error types and i've only seen a handful of them so will add them as needed
TYPE_COLOR = "orange3"
XML_ERROR_TYPES = {
    1826: f"[{TYPE_COLOR}]XML_SCHEMAV_CVC_DATATYPE_VALID_1_2_3[/{TYPE_COLOR}]: [dim]1826[/dim]",
    1845: f"[{TYPE_COLOR}]XML_SCHEMAV_CVC_ELT_1[/{TYPE_COLOR}]: [dim]1845[/dim]",
    1871: f"[{TYPE_COLOR}]XML_SCHEMAV_ELEMENT_CONTENT[/{TYPE_COLOR}]: [dim]1871[/dim]",
}

# severity of the issue
XML_ERROR_LEVELS = {
    0: "[light_green]XML_ERR_NONE[/light_green]: [dim]No error[/dim]",
    1: "[gold1]XML_ERR_WARNING[/gold1]: [dim]A simple warning[/dim]",
    2: "[orange_red1]XML_ERR_ERROR[/orange_red1]: [dim]A recoverable error[/dim]",
    3: "[red1]XML_ERR_FATAL[/red1]: [dim]A fatal error[/dim]",
}


def validate_xml(xsd_path, xml_path):
    console = Console()
    # load and parse the XSD file
    with open(xsd_path, "rb") as xsd_file:
        xsd_tree = etree.XMLSchema(etree.parse(xsd_file))

    # load and parse the XML file
    with open(xml_path, "rb") as xml_file:
        xml_tree = etree.parse(xml_file)

    # validate the XML against the XSD
    is_valid = xsd_tree.validate(xml_tree)

    # handling the results
    if is_valid:
        console.print(
            "󰚔  the XML file is valid according to the XSD schema 󰇵 ",
            style="bold green",
        )
    else:
        console.print("  the XML file is not valid 󰇸 ", style="bold red")
        # create the table for the error log
        table = Table(
            title=f"{xml_path}", show_header=True, header_style="bold magenta"
        )

        # create the table columns to display the errors
        table.add_column("Line", style="dim", width=6, justify="right")
        table.add_column("Column", style="dim", width=6, justify="right")
        table.add_column("Domain", width=18, overflow="fold")
        table.add_column("Type", width=12, overflow="fold")
        table.add_column("Level", style="dim", width=12, overflow="fold")
        table.add_column("Message", overflow="fold")
        for error in xsd_tree.error_log:
            domain_description = XML_ERROR_DOMAINS.get(
                error.domain,
                f"[{DOMAIN_COLOR}]Unknown domain[/{DOMAIN_COLOR}] [dim]({error.domain})[/dim]",
            )
            type_description = XML_ERROR_TYPES.get(
                error.type,
                f"[{TYPE_COLOR}]Unknown type[/{TYPE_COLOR}] [dim]({error.type})[/dim]",
            )
            level_description = XML_ERROR_LEVELS.get(
                error.level, f"[red]Unknown Level[/red] [dim]({error.level})[/dim]"
            )
            table.add_row(
                str(error.line),
                str(error.column),
                domain_description,
                type_description,
                level_description,
                error.message,
            )
        console.print(table)


def main():
    data_directory = "data"

    try:
        fzf_command = [
            "fzf",
            "--prompt=  select an xml file   ",
            "--height=50%",
            "--layout=reverse",
            "--border",
            "--exit-0",
            "--ansi",
        ]

        result = subprocess.run(
            fzf_command, stdout=subprocess.PIPE, text=True, cwd=data_directory
        )
        selected_file = result.stdout.strip()

        if not selected_file:
            print("No file selected")
            return

        # hardcode schema
        xsd_path = Path("schema/extensions/SDTC/infrastructure/cda/CDA_SDTC.xsd")

        # supply XML file path from the cli
        xml_path = Path(data_directory) / selected_file

        validate_xml(xsd_path, xml_path)
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()
