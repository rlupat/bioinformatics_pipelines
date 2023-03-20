
from typing import Optional, List, Dict, Any

FastaDict = str
String = str
Filename = str
Int = int
Float = float
Double = float
Boolean = str
File = str
Directory = str
Stdout = str
Stderr = str
Array = List
class PythonTool:
    File = str
    Directory = str

def code_block(
    reference: FastaDict, output_filename: str = "output.txt"
) -> Dict[str, Any]:
    """
    :param reference: Reference file to generate vardict header lines for (must have ^.dict) pattern
    :param output_filename: Filename to output to
    """
    from re import sub

    ref_dict = sub("\.fa(sta)?$", ".dict", reference)

    with open(output_filename, "w+") as out, open(ref_dict) as inp:
        out.write("##source=vardict\n")
        for line in inp:
            if not line.startswith("@SQ"):
                continue
            pieces = line.split("\t")
            chrom = pieces[1].replace("SN:", "")
            length = pieces[2].replace("LN:", "")

            out.write(f"##contig=<ID={chrom},length={length}>\n")

        return {"out": output_filename}



