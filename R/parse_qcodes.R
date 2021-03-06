# parse_qcodes.R
# J.Draper 22 May 2018
# part of the rOpenSci Unconf18 project "qcoder"
#
# requires stringr, readr
#
# Fuction to take a text document containing coded text of the form:
# "stuff to ignore (QCODE) coded text we care about (/QCODE){#qcode} more stuff to ignore"
# and turn it into a dataframe with one row per coded item, of the form:
# docid,qcode,text
#
# replaces newline characters [\n\r] with <br> in the captured text
#
#

library(stringr, readr)

parse_qcodes <- function(x, ...){

  #read in the file
  #filestring <- readr::read_file(filename)
  #replace newlines
  x$document_text <- stringr::str_replace_all(x$document_text, "[\r\n]", "<br>")
  #filestring <- stringr::str_replace_all(filestring, "[\r\n]", "<br>")
  #define the empty data frame to fill

  df <- data.frame(doc = integer(), qcode = factor(),
                   text = character(), stringsAsFactors = FALSE)

  #parse the file for qcodes; results in individual entries of form:
  #coded_text(/Qcode){#qcode, #qcode2
  for (i in 1:nrow(x)) {
  parsed <- unlist( stringr::str_extract_all(x$document_text[i],pattern=regex( "(?<=(QCODE\\))).*?(?=(\\{#)).*?(?=(\\}))" )) )
  doc_id <- x$doc_id[i]
  #parse each qcode flagged item and add it to the data frame as a new row
  for(item in parsed){
    splititems <- unlist(strsplit(item, "\\(/QCODE\\)\\{#"))

    #handle cases where multiple codes are assigned to one text block
    if( str_detect(splititems[2], ",[ ]*#") ){
      splitcodes <- unlist(strsplit(splititems[2], ",[ ]*#"))

      for(code in splitcodes){
        rowtoadd <- data.frame(doc = doc_id, qcode = as.factor(code), text = splititems[1])
        df <- rbind(df,rowtoadd)
      }
    }
    #otherwise just add the one entry to the df
    else{
      rowtoadd <- data.frame(doc = doc_id, qcode = as.factor(splititems[2]), text = splititems[1])
      df <- rbind(df,rowtoadd)
    }
  }
  }

  return(df)
}

###test case
#dfret <- parse_qcodes(filename = "inst/Example_Data_Markedup/CoC_Example1_mod_MU.txt", doc_id = "1m")
#View(dfret)



