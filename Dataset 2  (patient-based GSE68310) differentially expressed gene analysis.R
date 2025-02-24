rm(list=ls())
gc()

setwd('K:\\Dataset_2 ')
getwd()

expreset_probe_id <-read.table('Dataset_2.txt',sep = '\t', quote = "",fill = T, comment.char = "!",header = T)
probe_id_and_gene_symbol <-read.table('probe_id_and_gene_symbol.txt',sep = '\t',quote = "",fill = T, comment.char = "!",header = T)
names(expreset_probe_id)[1]  <- 'ID'
expreset_gene_symbol <- merge(expreset_probe_id,probe_id_and_gene_symbol,by="ID",all.x=T)
expreset_gene_symbol[,1] <- expreset_gene_symbol[,84]
names(expreset_gene_symbol)[1]  <- 'gene symbol'
expreset_gene_symbol <- expreset_gene_symbol[,-84]
expreset_agg <- aggregate(x = expreset_gene_symbol[,2:83],by = list(expreset_gene_symbol$`gene symbol`),FUN = mean)
rownames(expreset_agg) <- expreset_agg$Group.1
expreset_agg <- expreset_agg[,-1]

library(limma)
group_list <- c(rep('B',41),rep('I',41))
design <- model.matrix(~0+factor(group_list))
colnames(design) <- levels(factor(group_list))
rownames(design) <- colnames(expreset_agg)

contrast.matrix <-makeContrasts(I-B,levels=design)
contrast.matrix

fit <- lmFit(expreset_agg,design)
fit2 <- contrasts.fit(fit,contrast.matrix)
fit2 <- eBayes(fit2)

tempOutput <- topTable(fit2,coef = 1,n=Inf)
DEG <- na.omit(tempOutput)
head(DEG)

diff_gene <-subset(DEG, P.Value< 0.05 & (logFC > 0.584962500721156 | logFC < -1))
write.csv(diff_gene,"DEGs_Dataset_2.csv")
