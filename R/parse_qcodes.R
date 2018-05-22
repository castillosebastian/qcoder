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

parse_qcodes <- function(filename, doc_id,...){
  
  #read in the file
  filestring <- read_file(filename)
  #replace newlines
  filestring <- str_replace_all(filestring, "[\r\n]", "<br>")
  
  #define the empty data frame to fill
  df <- data.frame(doc=character(), qcode=factor(), text=character(), stringsAsFactors = FALSE)
  
  #parse the file a kind of foolish way, results in individual entries of form:
  #text(/Qcode){#qcode
  #where text is the text that was coded, and qcode is the code asigned to the text
  
  #parsed <- unlist( str_extract_all(filestring,pattern=regex( "(?<=(QCODE\\))).*?(?=(\\}))" )) )
  parsed <- unlist( str_extract_all(filestring,pattern=regex( "(?<=(QCODE\\))).*?(?=(\\{#)).*?(?=(\\}))" )) )
  
  #parse each qcode flagged item and add it to the data frame as a new row
  for(item in parsed){
    splititems <- unlist(strsplit(item, "\\(/QCODE\\)\\{#"))
    
    #handle cases where multiple codes are assigned to one text block
    if( str_detect(splititems[2], ",[ ]*#") ){
      splitcodes <- unlist(strsplit(splititems[2], ",[ ]*#"))
      print(splitcodes)
      
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
  
  return(df)
}

###test case
#dfret <- parse_qcodes(filename = "inst/Example_Data_Markedup/CoC_Example1_mod_MU.txt", doc_id = "1m")
#View(dfret)


