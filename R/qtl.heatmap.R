qtl.heatmap = function (lod, chr=NULL, borders = TRUE, ...) 
{
  old.par = par(no.readonly = TRUE)
  # Strip off the location data.
  hdr = lod[, 1:3]
  lod = as.matrix(lod[, -1:-3])
  # Get the chr boundaries and midpoints.
  chrbnd = table(hdr$Chr)
  chrbnd = chrbnd[order(as.numeric(names(chrbnd)))]
  chrbnd = cumsum(chrbnd)
  chrmid = c(0, chrbnd[-length(chrbnd)]) + diff(c(0, chrbnd)) * 0.5
  # Exponentiate the data and then scale each phenotype between 0 and 1.
  lod = exp(lod)
  lod = lod/matrix(apply(lod, 2, max, na.rm = TRUE), nrow(lod),
                   ncol(lod), byrow = TRUE)
  # Cluster the LOD profiles.
  lod.cor = cor(lod, use = "pair")
  lod.cl = hclust(as.dist(1 - lod.cor), method = "average")
  lod = lod[, lod.cl$order]
  dend = as.dendrogram(lod.cl)
  # Create the heatmap.
  layout(matrix(1:2, 1, 2), widths = c(0.1, 0.9))
  par(plt = c(0, 1, 0.1, 0.9))
  plot(dend, horiz = TRUE, axes = FALSE, yaxs = "i", leaflab = "none")
  par(las = 1, plt = c(0, 0.8, 0.1, 0.9))
  breaks = 0:100/100
  col = colorRampPalette(c(gray(10:2/10), rgb(1, 0.5, 0), rgb(1, 0, 0)))(length(breaks) - 1)
  if(!is.null(chr)){
    lod=subset(lod, hdr$Chr==chr)
    hdr=subset(hdr, hdr$Chr==chr)}
  image(1:nrow(lod), 1:ncol(lod), lod, breaks = breaks, col = col, 
        ann = FALSE, axes = FALSE)
  #add the borders if TRUE
  if(borders){
    if(!is.null(chr)){
      abline(h = 0:ncol(lod) + 0.5, col = "grey30")
    }else{
      #only add vertical borders if plotting whole genome
      abline(v = c(0, chrbnd), col = "grey30")
      abline(h = 0:ncol(lod) + 0.5, col = "grey30")
    }
  }
  mtext(text = colnames(lod), side = 4, at = 1:ncol(lod))
  #add chr # one x-axis if plotting whole genome
  if(is.null(chr)){
    mtext(names(chrbnd), side = 1, line = 0, at = chrmid, font = 2)
    mtext(names(chrbnd), side = 3, line = 0, at = chrmid, font = 2)
  }else{
    #add cM locations if plotting single chr
    cM=seq(0, ceiling(max(hdr$cM)), by=20)
    mtext(cM, side = 1, line = 0, at = seq(nrow(hdr)*0.02,nrow(hdr), by=nrow(hdr)/length(cM)), font = 2)
    mtext(cM, side = 3, line = 0, at = seq(nrow(hdr)*0.02,nrow(hdr), by=nrow(hdr)/length(cM)), font = 2)
  }
  # Legend along bottom.
  width = nrow(lod)/length(col)
  pin = par("pin")
  usr = par("usr")
  mai = par("mai")
  usr.per.in = (usr[4] - usr[3])/pin[2]
  top = -mai[1] * 0.25 * usr.per.in
  bottom = top - usr.per.in * 0.25
  par(xpd = NA)
  for (i in 1:length(col)) {
    rect((i - 1) * width, bottom, i * width, top, col = col[i], 
         border = NA)
  }
  par(old.par)
}
