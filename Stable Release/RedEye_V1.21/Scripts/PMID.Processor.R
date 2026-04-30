process_pmids_batch <- function(pmids) {
  
  myquery <- paste(paste(pmids, "[PMID]", sep = ""), collapse = " OR ")
  
  pubmedID <- tryCatch({
    withTimeout(get_pubmed_ids(myquery), timeout = 25)
  }, error = function(e) NULL)
  
  if (is.null(pubmedID)) return(NULL)
  
  abstractXML <- fetch_pubmed_data(pubmedID)
  if (is.null(abstractXML) || length(abstractXML) == 0) return(NULL)
  
  abstractlist <- articles_to_list(abstractXML)
  if (length(abstractlist) == 0) return(NULL)
  
  lapply(abstractlist, function(article) {
    article_to_df(article, autofill = TRUE, max_chars = 10)
  })
}
