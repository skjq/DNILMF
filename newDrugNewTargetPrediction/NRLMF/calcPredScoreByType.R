calcPredScoreByType <- function(U,
                                V,
                                simDrug,
                                simTarget,
                                knownDrugIndex,
                                knownTargetIndex,
                                testIndexRow,
                                testIndexCol,
                                K = 5,
                                testLabel,
                                idxNewDNewT) {
## INPUT:
  
## OUTPUT:
  
  
  if (K < 0) {
    stop("K MUST be '>=' 0! \n")
  }
  
  if (K > 0) {
    ## cat("with K smoothing! \n")
    ## for drug
    indexTestD <- unique(testIndexRow)
    testD <- U[indexTestD, ]
    testD <- cbind(indexTestD, testD)
    numTest <- length(indexTestD)
    numColTestD <- ncol(testD)
    simDrugKnown <- simDrug[, knownDrugIndex]
    numDrugKnown <- length(knownDrugIndex)
    
    for (i in 1:numTest) {
      indexCurr <- indexTestD[i]
      isNewDrug <- !(indexCurr %in% knownDrugIndex)
      if (isNewDrug) {
        simDrugNew <- simDrugKnown[indexCurr, ] 
        indexRank <- rank(simDrugNew) 
        indexNeig <- which(indexRank > (numDrugKnown - K))
        simCurr <- simDrugNew[indexNeig]
        ## index for U
        index4U <- knownDrugIndex[indexNeig]
        U_Known <- U[index4U, , drop = FALSE]
        ## vec %*% matrix => matrix
        testD[i, 2:numColTestD] <- (simCurr %*% U_Known) / sum(simCurr)
      }
    }
    
    Unew <- U
    Unew[indexTestD, ] <- testD[, -1]
    
    ## for target
    ## unique index for test target
    indexTestT <- unique(testIndexCol)
    testT <- V[indexTestT, ]
    ## add first column as labels
    testT <- cbind(indexTestT, testT)
    ## number of unique test set
    numTest <- length(indexTestT)
    ## number of column for testT
    numColTestT <- ncol(testT)
    ## known similarity matrix for targets
    simTargetKnown <- simTarget[, knownTargetIndex]
    ## number of known targets
    numTargetKnown <- length(knownTargetIndex)
    
    for (i in 1:numTest) {
      indexCurr <- indexTestT[i]
      isNewTarget <- !(indexCurr %in% knownTargetIndex)
      if (isNewTarget) {
        simTargetNew <- simTargetKnown[indexCurr, ] 
        indexRank <- rank(simTargetNew) 
        ## selected neighbor index with top K neighbor
        indexNeig <- which(indexRank > (numTargetKnown - K))
        ## get similarity value of K
        simCurr <- simTargetNew[indexNeig]
        ## index for V
        index4V <- knownTargetIndex[indexNeig]
        V_Known <- V[index4V, , drop = FALSE]
        testT[i, 2:numColTestT] <- (simCurr %*% V_Known) / sum(simCurr)
      }
    }
    
    Vnew <- V
    Vnew[indexTestT, ] <- testT[, -1]
    
    Vnewt <- t(Vnew)
    UnewVnewt <- Unew %*% Vnewt

    val <- UnewVnewt

    if (!is.null(idxNewDNewT)) {
      ndnt <- val[idxNewDNewT]
      ndnt <- exp(ndnt) / (1 + exp(ndnt))
    } else {
      ndnt <- NULL
    }
    result <- list()
    result$ndnt <- ndnt
  } else {
    Vt <- t(V)
    UVt <- U %*% Vt
    val <- Uvt
    if (!is.null(idxNewDNewT)) {
      ndnt <- val[idxNewDNewT]
      ndnt <- exp(ndnt) / (1 + exp(ndnt))
    } else {
      ndnt <- NULL
    }
    result <- list()
    result$ndnt <- ndnt
  }
  return(result)
}




