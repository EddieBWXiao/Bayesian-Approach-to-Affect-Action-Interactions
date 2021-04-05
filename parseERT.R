parseERT <- function(){
  #converts E-Prime txt files to csv
  
  mypath ="/Users/xiaobowen/Desktop/ERTwork/EmoRegTXT"
  #change this to folder where txt files are stored
  
  partI <- list.files(path = mypath, pattern = "partI.txt")
  partII <- list.files(path = mypath, pattern = "partII.txt")
  # print(allfiles)
  pI <- data.frame()
  for (i in seq(length(partI))) {
    bothids <- sub(".*_CC(.*)_v.*","\\1",partI[i])
    #jointid <- c(jointidp1,jointidp2)
    id1 <- sub(".*_CC(.*)_1.*","\\1",partI[i])
    id2 <- sub(".*_(.*)_v.*","\\1",partI[i])
    version <- sub(".*_version(.*)_.*","\\1",partI[i])
    addrow <- data.frame(id1,id2,bothids,version)
    pI <- rbind(pI,addrow)
  }
  
  pII <- data.frame()
  for (i in seq(length(partII))) {
    bothids <- sub(".*_CC(.*)_v.*","\\1",partII[i])
    #jointid <- c(jointidp1,jointidp2)
    id1 <- sub(".*_CC(.*)_1.*","\\1",partII[i])
    id2 <- sub(".*_(.*)_v.*","\\1",partII[i])
    version <- sub(".*_version(.*)_.*","\\1",partII[i])
    addrow <- data.frame(id1,id2,bothids,version)
    pII <- rbind(pII,addrow)
  }
  
  # id1, id2, version, part
  jointidp1 <- sub(".*_CC(.*)_v.*","\\1",partI)
  jointidp2 <- sub(".*_CC(.*)_v.*","\\1",partII)
  #jointid <- c(jointidp1,jointidp2)
  id1p1 <- sub(".*_CC(.*)_1.*","\\1",partI)
  id2p1 <- sub(".*_(.*)_v.*","\\1",partI)
  id1p2 <- sub(".*_CC(.*)_1.*","\\1",partII)
  id2p2 <- sub(".*_(.*)_v.*","\\1",partII)
  versionp1 <- sub(".*_version(.*)_.*","\\1",partI)
  
  nid1p1 <- as.numeric(id1p1)
  nid1p2 <- as.numeric(id1p2)
  
  dropout <- setdiff(nid1p1,nid1p2) #find who has not been in part II
  dropout_id2 <- setdiff(id2p1,id2p2)
  
  lengthcheck <-c(class(id2p1),class(id2p1))
  #iteration to create mastertable
  
  #filter out dropouts, create master table
  require(sqldf)
  p1p2 <- sqldf('SELECT * FROM pI INTERSECT SELECT * FROM pII')
  # this is a dataframe documenting id and versions of tasks done
  
  #begin parsing txt files
  library("rprime")
  #import data
  for (i in 1:nrow(p1p2)) {
    fullid <- p1p2[i,3]
    vers <- p1p2[i,4]
    tp1 <-"/Users/xiaobowen/Desktop/ERTwork/EmoRegTXT/EmotionRegulation_CCxxx_versionQQQ_partI.txt"
    fname1 <- sub('xxx',fullid,tp1)
    fname1 <- sub('QQQ',vers,fname1)
    tp2 <-"/Users/xiaobowen/Desktop/ERTwork/EmoRegTXT/EmotionRegulation_CCxxx_versionQQQ_partII.txt"
    fname2 <- sub('xxx',fullid,tp2)
    fname2 <- sub('QQQ',vers,fname2)
    partI_raw <- read_eprime(fname1)
    partII_raw <- read_eprime(fname2)
    partI <- FrameList(partI_raw)
    # preview_levels(partI)
    partII <- FrameList(partII_raw)
    #remove information about session
    partI <- keep_levels(partI, 3)
    partII <- keep_levels(partII, 3)
    #partI <- filter_out(partI, "Instruction", "Please try and absorb yourself in the next film clip to return your mood to normal.")
    
    #preview_frames(partI)
    
    p1out <- to_data_frame(partI)
    p2out <- to_data_frame(partII)
    
    # select what to keep
    c_keep <- c("Running", "Instruction","Rating1", "Rating2", "Rating3","Film","VASSlide1.RT","VASSlide2.RT","VASSlide3.RT")
    p1out <- p1out[c_keep]
    p2out <- p2out[c_keep]
    print(names(p1out))
    print(names(p2out))
    colnames(p1out) <- c("Running", "Instruction","Rating1", "Rating2", "Rating3","Film","RT1","RT2","RT3")
    colnames(p2out) <- c("Running", "Instruction","Rating1", "Rating2", "Rating3","Film","RT1","RT2","RT3")

    
    saven1 <- "/Users/xiaobowen/Desktop/ERTwork/EmoRegCSV/XX_QQ_partI.csv"
    csvn1 <- sub('XX',fullid,saven1)
    csvn1 <- sub('QQ',vers,csvn1)
    
    saven2 <- "/Users/xiaobowen/Desktop/ERTwork/EmoRegCSV/XX_QQ_partII.csv"
    csvn2 <- sub('XX',fullid,saven2)
    csvn2 <- sub('QQ',vers,csvn2)
    #print(p1out[1:10,])
    write.csv(p1out,csvn1)#with row names
    write.csv(p2out,csvn2)
    print(fullid)
    print(i)
  }
  write.csv(p1p2,"/Users/xiaobowen/Desktop/ERTwork/table_idwithversion.csv",row.names = FALSE)
  #note that return ends the function...
  return(p1p2)
}
