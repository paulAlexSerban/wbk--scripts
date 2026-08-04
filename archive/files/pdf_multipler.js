import { PDFDocument } from 'pdf-lib';
import fs from 'fs';

async function createMultipleInteractivePDFsFromPage() {
  // Source PDF
  const filename = 'FS_Employer_Confirmation_Bachelor_EN.pdf';

  // Read original PDF bytes once
  const existingPdfBytes = fs.readFileSync(filename);

  // CONFIGURATION
  const totalFiles = 4;

  // PDF page to extract
  // NOTE:
  // Human page numbers start at 1
  // pdf-lib page indexes start at 0
  const targetPageNumber = 3;

  // Convert to zero-based index
  const targetPageIndex = targetPageNumber - 1;

  for (let i = 0; i < totalFiles; i++) {
    // Create a completely new PDF document
    const newPdf = await PDFDocument.create();

    // Load a fresh copy of the source PDF each iteration
    // This prevents shared form references/state pollution
    const sourcePdf = await PDFDocument.load(existingPdfBytes);

    // Copy ONLY the target page
    const [copiedPage] = await newPdf.copyPages(sourcePdf, [
      targetPageIndex,
    ]);

    // Add copied page
    newPdf.addPage(copiedPage);

    // Save WITHOUT flattening
    // This preserves:
    // - text fields
    // - checkboxes
    // - dropdowns
    // - signatures
    // - all AcroForm interactivity
    const pdfBytes = await newPdf.save({
      useObjectStreams: false,
    });

    const outputFilename = `Interactive_Page_${targetPageNumber}_Copy_${
      i + 1
    }.pdf`;

    fs.writeFileSync(outputFilename, pdfBytes);

    console.log(`Generated interactive PDF: ${outputFilename}`);
  }

  console.log('\nDone. All PDFs preserve form interactivity.');
}

createMultipleInteractivePDFsFromPage().catch(console.error);