package com.inventory.utils;

import com.inventory.utils.DBUtil;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/PDFExporter")
public class PDFExporter extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public PDFExporter() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=order_summary.pdf");

        try (Connection conn = DBUtil.getConnection()) {
            Document doc = new Document();
            PdfWriter.getInstance(doc, response.getOutputStream());
            doc.open();

            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18);
            Font tableHeader = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12);
            Font tableBody = FontFactory.getFont(FontFactory.HELVETICA, 11);

            doc.add(new Paragraph("📄 Order Summary", titleFont));
            doc.add(new Paragraph(" "));

            PdfPTable table = new PdfPTable(4);
            table.setWidthPercentage(100);
            table.setSpacingBefore(10);
            table.setWidths(new float[] { 1.5f, 3.5f, 3.5f, 2f });

            table.addCell(new PdfPCell(new Phrase("Order ID", tableHeader)));
            table.addCell(new PdfPCell(new Phrase("Customer", tableHeader)));
            table.addCell(new PdfPCell(new Phrase("Date", tableHeader)));
            table.addCell(new PdfPCell(new Phrase("Total ₹", tableHeader)));

            PreparedStatement stmt = conn.prepareStatement(
                "SELECT o.order_id, o.order_date, o.total_amount, c.name AS customer_name " +
                "FROM orders o JOIN customers c ON o.customer_id = c.customer_id " +
                "ORDER BY o.order_date DESC"
            );
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                table.addCell(new PdfPCell(new Phrase(String.valueOf(rs.getInt("order_id")), tableBody)));
                table.addCell(new PdfPCell(new Phrase(rs.getString("customer_name"), tableBody)));
                table.addCell(new PdfPCell(new Phrase(rs.getTimestamp("order_date").toString(), tableBody)));
                table.addCell(new PdfPCell(new Phrase("₹ " + String.format("%.2f", rs.getDouble("total_amount")), tableBody)));
            }

            doc.add(table);
            doc.close();

        } catch (Exception e) {
            throw new ServletException("Error generating PDF: " + e.getMessage(), e);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response); // Allow both GET and POST
    }
}
