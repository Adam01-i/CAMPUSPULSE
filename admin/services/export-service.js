export function exportExcel(rows, filename) {
  if (window.XLSX) {
    const worksheet = XLSX.utils.json_to_sheet(rows);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, 'CampusPulse');
    XLSX.writeFile(workbook, `${filename}.xlsx`);
    return;
  }

  const csv = rows.map((row) => Object.values(row).join(',')).join('\n');
  download(new Blob([csv], { type: 'text/csv' }), `${filename}.csv`);
}

export function exportPdf(title, rows) {
  if (window.jspdf?.jsPDF) {
    const doc = new jspdf.jsPDF();
    doc.text(title, 14, 18);
    rows.slice(0, 45).forEach((row, index) => {
      doc.text(Object.values(row).join(' | ').slice(0, 110), 14, 30 + index * 6);
    });
    doc.save(`${title}.pdf`);
    return;
  }

  window.print();
}

function download(blob, filename) {
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  link.click();
  URL.revokeObjectURL(url);
}
