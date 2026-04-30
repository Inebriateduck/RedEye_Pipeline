build_output_paths <- function(input_path, output_path) {
  
  base <- normalizePath(output_path)  # use the provided output_path exactly
  
  paths <- list(
    base    = base,
    interim = file.path(base, "Interim_Data"),
    SYKO    = file.path(base, "Interim_Data", "SYKO"),
    pmid    = file.path(base, "Interim_Data", "PMID_Data"),
    ULTRA      = file.path(base, "Interim_Data", "ULTRA"),
    final   = file.path(base, "Final_Output")
  )
  
  lapply(paths, dir.create, recursive = TRUE, showWarnings = FALSE)
  return(paths)
}
