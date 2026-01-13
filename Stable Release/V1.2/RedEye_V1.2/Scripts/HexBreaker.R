run_hex_breaker <- function(pmid_outdir, hb_outdir) {
  py_install(c("pandas", "openpyxl", "tqdm"), pip = TRUE)
  source_python(file.path(SCRIPTS_ROOT, "Hex_Breaker.py"))
  
  pmid_outdir_abs <- normalizePath(pmid_outdir)
  hb_outdir_abs   <- normalizePath(hb_outdir)
  
  excel_file <- combine_and_process_csv_files(pmid_outdir_abs)
  
  final_path <- file.path(hb_outdir_abs, basename(excel_file))
  file.rename(excel_file, final_path)
  final_path
}
