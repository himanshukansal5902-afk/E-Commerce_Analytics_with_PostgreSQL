--core joins indexes
CREATE INDEX idx_invoices_invoice_no
ON invoices(invoice_no);

CREATE INDEX idx_invoice_items_invoice_no
ON invoice_items(invoice_no);

CREATE INDEX idx_invoices_customer_id
ON invoices(customer_id);

--filter and analytics indexes
CREATE INDEX idx_invoice_items_not_cancelled
ON invoice_items(invoice_no)
WHERE is_cancellation = FALSE;

CREATE INDEX idx_invoices_invoice_date
ON invoices(invoice_date);

--product analytics self-join
CREATE INDEX idx_invoice_items_invoice_stock
ON invoice_items(invoice_no, stock_code)
WHERE is_cancellation = FALSE;
