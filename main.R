main <- function(prov, path_param, path_program) {
  
  if (prov == "SMN") {
    
    source(paste0("SMN/genera_norm_smn.R"))
    genera_norm_smn(path_param, path_program)
    
  } else if (prov == "INUMET") {
    
    print("INUMET programs coming soon...")
    
  } else {
    
    print("Data provider not available.. yet..")
    
  }
  
}
