run_email_validation <- function(hb_excel, final_outdir) {
  py_install("pyIsEmail", pip = TRUE)
  source_python(Email_check_source)
  
  py_main <- import_main()
  validated <- py_main$validate_emails(hb_excel)
  
  final_file <- file.path(final_outdir, basename(validated))
  file.rename(validated, final_file)
  final_file
}
