from pathlib import Path

from docx import Document
from docx.enum.table import WD_ALIGN_VERTICAL
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Inches, Pt, RGBColor
from docx.oxml import OxmlElement
from docx.oxml.ns import qn


SOURCE = Path(
    r"C:\Users\mkmk3\AppData\Local\Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm\LocalState\sessions\C97FEF5AFF59043ED9E0871FB8C0132D5D8BD0CC\transfers\2026-43\change draft 1.docx"
)
OUTPUT = Path(r"C:\Users\mkmk3\OneDrive\Documents\edupulse\MC3_report_reformatted.docx")


def set_run_font(run, size, bold=None, italic=None):
    run.font.name = "Times New Roman"
    run.font.size = Pt(size)
    run.font.color.rgb = RGBColor(0, 0, 0)
    rpr = run._element.get_or_add_rPr()
    rfonts = rpr.rFonts
    if rfonts is None:
        rfonts = OxmlElement("w:rFonts")
        rpr.append(rfonts)
    for key in ("ascii", "hAnsi", "eastAsia", "cs"):
        rfonts.set(qn(f"w:{key}"), "Times New Roman")
    if bold is not None:
        run.bold = bold
    if italic is not None:
        run.italic = italic


def set_paragraph_font(paragraph, size, bold=None, italic=None):
    for run in paragraph.runs:
        set_run_font(run, size, bold=bold, italic=italic)


def make_heading(paragraph, centered=False):
    paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER if centered else WD_ALIGN_PARAGRAPH.LEFT
    pf = paragraph.paragraph_format
    pf.space_before = Pt(12)
    pf.space_after = Pt(6)
    pf.line_spacing = 1.0
    pf.keep_with_next = True
    set_paragraph_font(paragraph, 14, bold=True, italic=False)


def make_body(paragraph):
    paragraph.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    pf = paragraph.paragraph_format
    pf.space_before = Pt(0)
    pf.space_after = Pt(6)
    pf.line_spacing = 1.15
    pf.first_line_indent = Inches(0)
    set_paragraph_font(paragraph, 12, bold=None, italic=None)


def remove_runs(paragraph):
    for run in list(paragraph.runs):
        run._element.getparent().remove(run._element)


def replace_text(paragraph, text, size=12, bold=False, italic=False):
    remove_runs(paragraph)
    run = paragraph.add_run(text)
    set_run_font(run, size, bold=bold, italic=italic)
    return run


def set_cell_shading(cell, fill):
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = tc_pr.find(qn("w:shd"))
    if shd is None:
        shd = OxmlElement("w:shd")
        tc_pr.append(shd)
    shd.set(qn("w:fill"), fill)
    shd.set(qn("w:val"), "clear")


def set_cell_borders(cell, color="BFBFBF"):
    tc_pr = cell._tc.get_or_add_tcPr()
    borders = tc_pr.first_child_found_in("w:tcBorders")
    if borders is None:
        borders = OxmlElement("w:tcBorders")
        tc_pr.append(borders)
    for side in ("top", "left", "bottom", "right", "insideH", "insideV"):
        tag = qn(f"w:{side}")
        element = borders.find(tag)
        if element is None:
            element = OxmlElement(f"w:{side}")
            borders.append(element)
        element.set(qn("w:val"), "single")
        element.set(qn("w:sz"), "6")
        element.set(qn("w:color"), color)


def style_case_table(table):
    table.autofit = True
    for row_index, row in enumerate(table.rows):
        for cell in row.cells:
            cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
            set_cell_borders(cell)
            if row_index == 0:
                set_cell_shading(cell, "E7E6E6")
            for paragraph in cell.paragraphs:
                paragraph.paragraph_format.space_before = Pt(2)
                paragraph.paragraph_format.space_after = Pt(2)
                paragraph.paragraph_format.line_spacing = 1.0
                paragraph.alignment = (
                    WD_ALIGN_PARAGRAPH.CENTER if row_index == 0 else WD_ALIGN_PARAGRAPH.LEFT
                )
                set_paragraph_font(paragraph, 11, bold=(row_index == 0), italic=False)


doc = Document(SOURCE)

# The case study begins at paragraph 231 (zero-based 230) in the supplied document.
case_start = 230
paragraphs = doc.paragraphs

# Preserve the research paper's two-column IEEE-style section and format the case study
# as the supplied one-column academic report reference.
for section in doc.sections[12:]:
    section.top_margin = Inches(0.85)
    section.bottom_margin = Inches(0.85)
    section.left_margin = Inches(0.85)
    section.right_margin = Inches(0.85)

# Report title and case-study title.
make_heading(paragraphs[230], centered=True)
make_heading(paragraphs[231], centered=True)

heading_indices = {233, 237, 241, 247, 251, 254, 257, 261, 267, 276, 282, 286}
caption_indices = {243, 264}
reference_indices = set(range(287, 293))
title_indices = {230, 231}
blank_indices = {232, 236, 240, 244, 245, 246, 250, 253, 256, 260, 263, 265, 266, 275, 279, 281, 285}

for index in range(case_start, len(paragraphs)):
    paragraph = paragraphs[index]
    if index in heading_indices:
        make_heading(paragraph, centered=False)
    elif index in caption_indices:
        paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
        paragraph.paragraph_format.space_before = Pt(4)
        paragraph.paragraph_format.space_after = Pt(4)
        paragraph.paragraph_format.line_spacing = 1.0
        set_paragraph_font(paragraph, 12, bold=True, italic=False)
    elif index in reference_indices:
        paragraph.alignment = WD_ALIGN_PARAGRAPH.LEFT
        paragraph.paragraph_format.space_before = Pt(0)
        paragraph.paragraph_format.space_after = Pt(3)
        paragraph.paragraph_format.line_spacing = 1.0
        set_paragraph_font(paragraph, 11, bold=False, italic=False)
    elif index not in title_indices and index not in blank_indices:
        make_body(paragraph)

# Make the seven protection-plan labels bold without bolding their explanatory text.
for index in range(268, 275):
    paragraph = paragraphs[index]
    text = paragraph.text
    label, separator, remainder = text.partition(":")
    if separator:
        remove_runs(paragraph)
        lead = paragraph.add_run(f"{label}:")
        set_run_font(lead, 12, bold=True)
        tail = paragraph.add_run(remainder)
        set_run_font(tail, 12, bold=False)
    make_body(paragraph)

# Replace the one unsupported WIPO attribution with a supportable, cited recommendation.
replace_text(
    paragraphs[274],
    "Step 7 – Monitor and enforce: Track potential infringement and maintain records of registrations, licenses and ownership. This helps the company respond if a third party misuses its IP [1].",
    size=12,
)
make_body(paragraphs[274])
lead, separator, remainder = paragraphs[274].text.partition(":")
if separator:
    replace_text(paragraphs[274], "", size=12)
    label_run = paragraphs[274].add_run(f"{lead}:")
    set_run_font(label_run, 12, bold=True)
    body_run = paragraphs[274].add_run(remainder)
    set_run_font(body_run, 12, bold=False)

# Use complete, verifiable WIPO references. Existing in-text citations [1]-[6] map
# directly to these entries and have been retained.
references = [
    "World Intellectual Property Organization (WIPO), \"What is Intellectual Property?\" 2020. [Online]. Available: https://www.wipo.int/publications/en/details.jsp?id=4528. [Accessed: Oct. 26, 2026].",
    "World Intellectual Property Organization (WIPO), \"Frequently Asked Questions: Patents.\" [Online]. Available: https://www.wipo.int/en/web/patents/faq_patents. [Accessed: Oct. 26, 2026].",
    "World Intellectual Property Organization (WIPO), \"Standard Essential Patents.\" [Online]. Available: https://www.wipo.int/en/web/patents/topics/sep. [Accessed: Oct. 26, 2026].",
    "World Intellectual Property Organization (WIPO), \"WIPO Guide to Trade Secrets and Innovation,\" 2024. [Online]. Available: https://www.wipo.int/publications/en/details.jsp?id=4748. [Accessed: Oct. 26, 2026].",
    "World Intellectual Property Organization (WIPO), \"Internet of Things: Patent Landscape Analysis.\" [Online]. Available: https://www.wipo.int/edocs/pubdocs/en/internet_of_things.pdf. [Accessed: Oct. 26, 2026].",
    "World Intellectual Property Organization (WIPO), \"Technology Transfer Agreements.\" [Online]. Available: https://www.wipo.int/en/web/technology-transfer/agreements. [Accessed: Oct. 26, 2026].",
]
for index, reference in zip(sorted(reference_indices), references):
    replace_text(paragraphs[index], reference, size=11)
    paragraphs[index].alignment = WD_ALIGN_PARAGRAPH.LEFT
    paragraphs[index].paragraph_format.space_after = Pt(3)
    paragraphs[index].paragraph_format.line_spacing = 1.0

# Add citations to the two remaining source-based statements in the case analysis.
replace_text(
    paragraphs[259],
    "The company should use confidentiality agreements, access controls, employee policies, secure repositories and need-to-know permissions to preserve secrecy. Trade-secret protection can be lost if confidential information is publicly disclosed [4].",
    size=12,
)
make_body(paragraphs[259])
replace_text(
    paragraphs[278],
    "The main lesson is that IP planning should begin during the innovation process rather than after product launch. Public disclosure before an appropriate patent strategy is in place can affect patent rights in some jurisdictions, while uncontrolled disclosure can undermine trade-secret protection [2], [4]. Inventors and",
    size=12,
)
make_body(paragraphs[278])

# The final academic note stays readable but visually secondary.
note = paragraphs[293]
note.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
note.paragraph_format.space_before = Pt(6)
note.paragraph_format.space_after = Pt(0)
note.paragraph_format.line_spacing = 1.0
set_paragraph_font(note, 11, italic=True)

# Case-study tables are the final three tables in the supplied document.
for table in doc.tables[-3:]:
    style_case_table(table)

doc.core_properties.title = "MC3 Research Paper and Case Study Report"
doc.core_properties.subject = "Technical Paper Writing and Intellectual Property Rights"
doc.core_properties.comments = "Case-study report reformatted with corrected WIPO source references."
doc.save(OUTPUT)
print(OUTPUT)
