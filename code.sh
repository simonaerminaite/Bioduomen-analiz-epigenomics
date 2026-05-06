# Failų parsisiuntimas:
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR116/053/SRR11647653/SRR11647653_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR116/053/SRR11647653/SRR11647653_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR116/055/SRR11647655/SRR11647655_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR116/055/SRR11647655/SRR11647655_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR116/063/SRR11647663/SRR11647663_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR116/063/SRR11647663/SRR11647663_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR116/065/SRR11647665/SRR11647665_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR116/065/SRR11647665/SRR11647665_2.fastq.gz
# FastQC:
mkdir fastq_raw
fastqc -o fastq_raw -t 8 *.fastq.gz
# Trimming:
mkdir fastq_trimmed
trim_galore -o fastq_trimmed -j 8 --quality 20 --length 20 --paired SRR11647653_1.fastq.gz SRR11647653_2.fastq.gz
trim_galore -o fastq_trimmed -j 8 --quality 20 --length 20 --paired SRR11647655_1.fastq.gz SRR11647655_2.fastq.gz
trim_galore -o fastq_trimmed -j 8 --quality 20 --length 20 --paired SRR11647663_1.fastq.gz SRR11647663_2.fastq.gz
trim_galore -o fastq_trimmed -j 7 --quality 20 --length 20 --paired SRR11647665_1.fastq.gz SRR11647665_2.fastq.gz
cd fastq_trimmed
mkdir fastqc_trimmed
fastqc -o fastqc_trimmed -t 8 *.fq.gz
# Mappinimas, kuriam nereikia atskiro indeksavimo žingsnio, jam reikia conda env susikurti:
conda create -n bsmap_env bioconda::bsmap
conda activate bsmap_env
cd ~/HW2/raw_data
mkdir bam_files
cd bam_files
bsmap -a ~/HW2/raw_data/fastq_trimmed/SRR11647653_1_val_1.fq.gz -b ~/HW2/raw_data/fastq_trimmed/SRR11647653_2_val_2.fq.gz -d ~/HW1/references/GRCh38.primary_assembly.genome.fa -o SRR11647653.bam -p 6                  
bsmap -a ~/HW2/raw_data/fastq_trimmed/SRR11647655_1_val_1.fq.gz -b ~/HW2/raw_data/fastq_trimmed/SRR11647655_2_val_2.fq.gz -d ~/HW1/references/GRCh38.primary_assembly.genome.fa -o SRR11647655.bam -p 6                  
bsmap -a ~/HW2/raw_data/fastq_trimmed/SRR11647663_1_val_1.fq.gz -b ~/HW2/raw_data/fastq_trimmed/SRR11647663_2_val_2.fq.gz -d ~/HW1/references/GRCh38.primary_assembly.genome.fa -o SRR11647663.bam -p 6                  
bsmap -a ~/HW2/raw_data/fastq_trimmed/SRR11647665_1_val_1.fq.gz -b ~/HW2/raw_data/fastq_trimmed/SRR11647665_2_val_2.fq.gz -d ~/HW1/references/GRCh38.primary_assembly.genome.fa -o SRR11647665.bam -p 6 
# bam failų sorting:
samtools sort -@ 6 SRR11647653.bam -o SRR11647653.sorted.bam
samtools sort -@ 6 SRR11647655.bam -o SRR11647655.sorted.bam
samtools sort -@ 6 SRR11647663.bam -o SRR11647663.sorted.bam
samtools sort -@ 6 SRR11647665.bam -o SRR11647665.sorted.bam
# mbias pasižiūrėjimas:
conda activate methyldackel_env
MethylDackel mbias ~/HW1/references/GRCh38.primary_assembly.genome.fa SRR11647653.sorted.bam SRR11647653_mbias_plot
MethylDackel mbias ~/HW1/references/GRCh38.primary_assembly.genome.fa SRR11647655.sorted.bam SRR11647655_mbias_plot
MethylDackel mbias ~/HW1/references/GRCh38.primary_assembly.genome.fa SRR11647663.sorted.bam SRR11647663_mbias_plot
MethylDackel mbias ~/HW1/references/GRCh38.primary_assembly.genome.fa SRR11647665.sorted.bam SRR11647665_mbias_plot
# OP ir OB original top strand ir original bottom strand
# Gauti suggestions for inclusions:
# [E::idx_find_and_load] Could not retrieve index file for 'SRR11647653.sorted.bam'                                                           
# Couldn't load the index for SRR11647653.sorted.bam, will attempt to build it.                                                               
# Suggested inclusion options: --OT 2,0,2,111 --OB 2,124,15,124                                                                               
# [E::idx_find_and_load] Could not retrieve index file for 'SRR11647655.sorted.bam'                                                           
# Couldn't load the index for SRR11647655.sorted.bam, will attempt to build it.                                                               
# Suggested inclusion options: --OT 2,0,2,113 --OB 2,124,12,124                                                                               
# [E::idx_find_and_load] Could not retrieve index file for 'SRR11647663.sorted.bam'                                                           
# Couldn't load the index for SRR11647663.sorted.bam, will attempt to build it.                                                               
# Suggested inclusion options: --OT 3,0,2,119 --OB 2,123,6,124                                                                                
# [E::idx_find_and_load] Could not retrieve index file for 'SRR11647665.sorted.bam'                                                           
# Couldn't load the index for SRR11647665.sorted.bam, will attempt to build it.                                                               
# Suggested inclusion options: --OT 3,0,2,120 --OB 2,123,5,124      
# Per picard:
conda create -n picard bioconda::picard
conda activate picard
picard AddOrReplaceReadGroups I=SRR11647653.sorted.bam O=SRR11647653.rg.bam RGID=SRR11647653 RGLB=lib1 RGPL=ILLUMINA RGPU=unit1 RGSM=SRR11647653
picard AddOrReplaceReadGroups I=SRR11647655.sorted.bam O=SRR11647655.rg.bam RGID=SRR11647655 RGLB=lib1 RGPL=ILLUMINA RGPU=unit1 RGSM=SRR11647655
picard AddOrReplaceReadGroups I=SRR11647663.sorted.bam O=SRR11647663.rg.bam RGID=SRR11647663 RGLB=lib1 RGPL=ILLUMINA RGPU=unit1 RGSM=SRR11647663
picard AddOrReplaceReadGroups I=SRR11647665.sorted.bam O=SRR11647665.rg.bam RGID=SRR11647665 RGLB=lib1 RGPL=ILLUMINA RGPU=unit1 RGSM=SRR11647665
picard MarkDuplicates I=SRR11647653.rg.bam O=SRR11647653.dedup.bam M=SRR11647653_metrics.txt REMOVE_DUPLICATES=false
picard MarkDuplicates I=SRR11647655.rg.bam O=SRR11647655.dedup.bam M=SRR11647655_metrics.txt REMOVE_DUPLICATES=false
picard MarkDuplicates I=SRR11647663.rg.bam O=SRR11647663.dedup.bam M=SRR11647663_metrics.txt REMOVE_DUPLICATES=false
picard MarkDuplicates I=SRR11647665.rg.bam O=SRR11647665.dedup.bam M=SRR11647665_metrics.txt REMOVE_DUPLICATES=false
# Galima pamatyti duplicates rate
# Methylation col'inimas;
MethylDackel extract --OT 2,0,2,111 --OB 2,124,15,124 ~/HW1/references/GRCh38.primary_assembly.genome.fa SRR11647653.dedup.bam -r chr20 -o SRR11647653_methylation_chr20
MethylDackel extract --OT 2,0,2,113 --OB 2,124,12,124 ~/HW1/references/GRCh38.primary_assembly.genome.fa SRR11647655.dedup.bam -r chr20 -o SRR11647655_methylation_chr20
MethylDackel extract --OT 3,0,2,119 --OB 2,123,6,124 ~/HW1/references/GRCh38.primary_assembly.genome.fa SRR11647663.dedup.bam -r chr20 -o SRR11647663_methylation_chr20
MethylDackel extract --OT 3,0,2,120 --OB 2,123,5,124 ~/HW1/references/GRCh38.primary_assembly.genome.fa SRR11647665.dedup.bam -r chr20 -o SRR11647665_methylation_chr20
# head sample_methylation_CpG.bedGraph: chromosomas; CpG pradžios pozicija; Cpg pabaigos pozicija; procentai; kiek read pagrindžia metilinimo state; kiek read, kurie pagrindžia ne metilinimo state
# Gauni metilinimą (jo įverčius) per visus genomo CpG (teoriškai metilinimas turi būti simetriškas tarp grandinių)
# Tam, kad patikrinti mapping rate:
samtools flagstat SRR11647653.bam
samtools view -F 0x904 SRR11647653.sorted.bam | cut -f1 | sort -u | wc -l
# 331343206
samtools flagstat SRR11647655.bam
samtools view -F 0x904 SRR11647655.sorted.bam | cut -f1 | sort -u | wc -l
# 308442243
samtools flagstat SRR11647663.bam
samtools view -F 0x904 SRR11647663.sorted.bam | cut -f1 | sort -u | wc -l
# 328316585
samtools flagstat SRR11647665.bam
samtools view -F 0x904 SRR11647665.sorted.bam | cut -f1 | sort -u | wc -l
# 326443688
zcat SRR11647653_1_val_1.fq.gz | wc -l
# 1436305744
# total reads = 1436305744 / 4 = 359076436
# Mapping rate = 331343206 / 359076436 * 100 = 92.28%
zcat SRR11647655_1_val_1.fq.gz | wc -l
# 1343089328
# total reads = 1343089328 / 4 = 335772332
# Mapping rate = 308442243 / 335772332 * 100 = 91.86%
zcat SRR11647663_1_val_1.fq.gz | wc -l
# 1422208320
# total reads = 1422208320 / 4 = 355552080
# Mapping rate = 328316585 / 355552080 * 100 = 92.34%
zcat SRR11647665_1_val_1.fq.gz | wc -l
# 1416716644
# total reads = 1416716644 / 4 = 354179161
# Mapping rate = 326443688 / 354179161 * 100 = 92.17%
# Tada galima eiti į R
R
library(pacman)
p_load(data.table, dplyr, ggplot2, bsseq, GenomicRanges, reshape, gridExtra, patchwork, annotatr, pheatmap, dendextend, DSS, dmrseq, data.table, tidyverse, readr)

sample_cols <- c(
  "SRR11647653",
  "SRR11647655",
  "SRR11647663",
  "SRR11647665"
)

methyl53 <- readr::read_table("SRR11647653_methylation_chr20_CpG.bedGraph", col_names = FALSE, comment = "track")
methyl55 <- readr::read_table("SRR11647655_methylation_chr20_CpG.bedGraph", col_names = FALSE, comment = "track")
methyl63 <- readr::read_table("SRR11647663_methylation_chr20_CpG.bedGraph", col_names = FALSE, comment = "track")
methyl65 <- readr::read_table("SRR11647665_methylation_chr20_CpG.bedGraph", col_names = FALSE, comment = "track")
colnames(methyl53) <- colnames(methyl55) <- colnames(methyl63) <- colnames(methyl65) <- c(
  "chrom",
  "start",
  "end",
  "percent_methylation",
  "methylated",
  "unmethylated"
)

methyl53 <- as.data.table(methyl53)
methyl55 <- as.data.table(methyl55)
methyl63 <- as.data.table(methyl63)
methyl65 <- as.data.table(methyl65)

methyl53[, cpg_id := paste0(chrom, ":", start)]
methyl55[, cpg_id := paste0(chrom, ":", start)]
methyl63[, cpg_id := paste0(chrom, ":", start)]
methyl65[, cpg_id := paste0(chrom, ":", start)]

methyl53[, SRR11647653 := methylated / (methylated + unmethylated)]
methyl55[, SRR11647655 := methylated / (methylated + unmethylated)]
methyl63[, SRR11647663 := methylated / (methylated + unmethylated)]
methyl65[, SRR11647665 := methylated / (methylated + unmethylated)]

methyl53[, cov_SRR11647653 := methylated + unmethylated]
methyl55[, cov_SRR11647655 := methylated + unmethylated]
methyl63[, cov_SRR11647663 := methylated + unmethylated]
methyl65[, cov_SRR11647665 := methylated + unmethylated]

coords <- unique(rbind(
  methyl53[, .(cpg_id, chrom, position = start)],
  methyl55[, .(cpg_id, chrom, position = start)],
  methyl63[, .(cpg_id, chrom, position = start)],
  methyl65[, .(cpg_id, chrom, position = start)]
))

methylation_dt <- Reduce(function(x, y) merge(x, y, by = "cpg_id", all = TRUE),
  list(
    coords,
    methyl53[, .(cpg_id, SRR11647653)],
    methyl55[, .(cpg_id, SRR11647655)],
    methyl63[, .(cpg_id, SRR11647663)],
    methyl65[, .(cpg_id, SRR11647665)]
  )
)

coverage_dt <- Reduce(function(x, y) merge(x, y, by = "cpg_id", all = TRUE),
  list(
    coords,
    methyl53[, .(cpg_id, SRR11647653 = cov_SRR11647653)],
    methyl55[, .(cpg_id, SRR11647655 = cov_SRR11647655)],
    methyl63[, .(cpg_id, SRR11647663 = cov_SRR11647663)],
    methyl65[, .(cpg_id, SRR11647665 = cov_SRR11647665)]
  )
)

meth_mat <- as.matrix(methylation_dt[, ..sample_cols])
rownames(meth_mat) <- methylation_dt$cpg_id
mode(meth_mat) <- "numeric"

cov_mat <- as.matrix(coverage_dt[, ..sample_cols])
rownames(cov_mat) <- coverage_dt$cpg_id
mode(cov_mat) <- "numeric"

theme_set(theme_bw(base_size = 12))

sample_info <- data.frame(
  sample_id = sample_cols,
  condition = c("non_tumor", "non_tumor", "tumor", "tumor"),
  group = c("non_tumor", "non_tumor", "tumor", "tumor")
)

rownames(sample_info) <- sample_info$sample_id

condition_cols <- c(
  non_tumor = "#C8A2C8",
  tumor = "#89CFF0"
)

# Mappimg rate:
mapping_df <- data.frame(
  sample_id = sample_cols,
  mapping_rate = c(92.28, 91.86, 92.34, 92.17),
  condition = sample_info$condition
)

png("mapping_rates.png", width=800, height=600)
ggplot(mapping_df, aes(x = sample_id, y = mapping_rate, fill = condition)) +
  geom_col() +
  scale_fill_manual(values = condition_cols) +
  scale_y_continuous(limits = c(0, 100), expand = c(0, 0)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "Mapping Rate per Sample",
    x = "Sample",
    y = "Mapping Rate (%)",
    fill = "Type"
  )
dev.off()

# Reads per sample:
total_reads_df <- data.frame(
  sample_id = sample_cols,
  total_reads = colSums(coverage_dt[, ..sample_cols], na.rm = TRUE),
  condition = sample_info$condition
)

png("reads_per_sample.png", width=800, height=600)
ggplot(total_reads_df, aes(x = sample_id, y = total_reads, fill = condition)) +
  geom_col() +
  scale_fill_manual(values = condition_cols) +
  scale_y_continuous(labels = scales::comma) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "Total Reads per Sample",
    x = "Sample",
    y = "Total reads",
    fill = "Type"
  )
dev.off()

# Covered CpGs per sample:
covered_df <- data.frame(
  sample_id = sample_cols,
  covered_CpGs = colSums(coverage_dt[, ..sample_cols] > 0, na.rm = TRUE),
  condition = sample_info$condition
)

png("covered_CpGs_per_sample.png", width=800, height=600)
ggplot(covered_df, aes(x = sample_id, y = covered_CpGs, fill = condition)) +
  geom_col() +
  scale_fill_manual(values = condition_cols) +
  scale_y_continuous(labels = scales::comma) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "Number of Covered CpGs per Sample",
    x = "Sample",
    y = "Covered CpGs",
    fill = "Type"
  )
dev.off()

# Coverage distribution per sample:
coverage_long <- data.table::melt(
  as.data.table(coverage_dt),
  id.vars = c("cpg_id", "chrom", "position"),
  measure.vars = sample_cols,
  variable.name = "sample_id",
  value.name = "coverage"
)

coverage_long <- as.data.frame(coverage_long)
coverage_long <- coverage_long[!is.na(coverage_long$coverage), ]

png("coverage_distribution_per_sample.png", width=800, height=600)
ggplot(coverage_long, aes(x = coverage)) +
  geom_histogram(binwidth = 1, fill = "#C8A2C8", color = "white") +
  geom_vline(
    data = data.frame(sample_id = unique(coverage_long$sample_id)),
    aes(xintercept = 10),
    color = "red",
    linetype = "dashed",
    linewidth = 0.8
  ) +
  facet_wrap(~ sample_id, ncol = 2) +
  coord_cartesian(xlim = c(0, 100)) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Coverage Distribution per Sample",
    x = "Coverage depth",
    y = "Number of CpGs"
  )
dev.off()

# CpG retention:
thresholds <- c(1, 5, 10, 20)

retention_df <- rbindlist(lapply(sample_cols, function(s) {
  data.table(
    sample_id = s,
    threshold = paste0(thresholds, "x"),
    percent_retained = sapply(thresholds, function(t) {
      mean(coverage_dt[[s]] >= t, na.rm = TRUE) * 100
    })
  )
}))

retention_df$threshold <- factor(
  retention_df$threshold,
  levels = c("1x", "5x", "10x", "20x")
)

retention_df <- merge(retention_df, sample_info, by = "sample_id")

png("CpG_retention_plot.png", width=800, height=600)
ggplot(retention_df, aes(x = sample_id, y = percent_retained, fill = threshold)) +
  geom_col(position = "dodge") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "CpG Retention at Different Coverage Thresholds",
    x = "Sample",
    y = "% CpGs retained",
    fill = "Coverage"
  )
dev.off()

# Correlation heatmap:
keep_10x <- rowSums(cov_mat >= 10, na.rm = TRUE) >= 2
meth_mat_10x <- meth_mat[keep_10x, ]

cor_mat <- cor(
  meth_mat_10x,
  use = "pairwise.complete.obs",
  method = "pearson"
)

annotation_row = annotation_col[rownames(cor_mat), , drop = FALSE]
annotation_col = annotation_col[colnames(cor_mat), , drop = FALSE]

ann_colors <- list(
  condition = condition_cols
)

png("Correlation_heatmap.png", width=800, height=600, type="cairo")
pheatmap(
  cor_mat,
  annotation_col = annotation_col,
  annotation_row = annotation_row,
  annotation_colors = ann_colors,
  clustering_method = "complete",
  display_numbers = TRUE,
  number_format = "%.2f",
  fontsize_number = 8,
  border_color = "grey70",
  color = colorRampPalette(c("white", "#2C7FB8"))(100),
  main = "Pearson Correlation Heatmap, ≥10x in at least 2 samples"
)
dev.off()

# PCA plot:
meth_pca <- meth_mat_10x[complete.cases(meth_mat_10x), ]
meth_pca <- meth_pca[apply(meth_pca, 1, var) > 0, ]

pca <- prcomp(t(meth_pca), scale. = TRUE)

pca_df <- data.frame(
  sample_id = rownames(pca$x),
  PC1 = pca$x[, 1],
  PC2 = pca$x[, 2]
)

pca_df <- merge(pca_df, sample_info, by = "sample_id")

png("PCA_plot.png", width=800, height=600, type="cairo")
ggplot(pca_df, aes(x = PC1, y = PC2, color = condition, label = sample_id)) +
  geom_point(size = 3) +
  geom_text(vjust = -0.8, size = 2.7, show.legend = FALSE) +
  coord_equal() +
   scale_color_manual(values = condition_cols) +
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(
    breaks = seq(-1000, 1000, by = 500),
    labels = scales::comma
  ) +
  coord_cartesian(ylim = c(-1000, 1000)) +
  labs(
    title = "PCA of Methylation Levels, ≥10x in at least 2 samples",
    x = "PC1",
    y = "PC2",
    color = "Type"
  )
dev.off()

# PCA under different coverages:
make_pca_df <- function(cutoff) {
  keep <- rowSums(cov_mat >= cutoff, na.rm = TRUE) >= 2
  
  meth_filtered <- meth_mat[keep, ]
  meth_filtered <- meth_filtered[complete.cases(meth_filtered), ]
  meth_filtered <- meth_filtered[apply(meth_filtered, 1, var) > 0, ]
  
  pca_tmp <- prcomp(t(meth_filtered), scale. = TRUE)
  
  pca_tmp_df <- data.frame(
    sample_id = rownames(pca_tmp$x),
    PC1 = pca_tmp$x[, 1],
    PC2 = pca_tmp$x[, 2],
    filter = paste0("≥", cutoff, "x")
  )
  
  merge(pca_tmp_df, sample_info, by = "sample_id")
}

pca_compare_df <- rbind(
  make_pca_df(5),
  make_pca_df(15),
  make_pca_df(20)
)

pca_compare_df$filter <- factor(
  pca_compare_df$filter,
  levels = c("≥5x", "≥15x", "≥20x")
)

png("PCA_different_coverages.png", width=800, height=600, type="cairo")
ggplot(pca_compare_df, aes(x = PC1, y = PC2, color = condition, label = sample_id)) +
  geom_point(size = 3) +
  geom_text(vjust = -0.8, size = 2.7, show.legend = FALSE) +
  facet_wrap(~ filter, nrow = 1) +
  scale_color_manual(values = condition_cols) +
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(
    breaks = seq(-1000, 1000, by = 500),
    labels = scales::comma
  ) +
  coord_cartesian(ylim = c(-1000, 1000)) +
  labs(
    title = "PCA under Different Coverage Filters",
    x = "PC1",
    y = "PC2",
    color = "Type"
  )
dev.off()

# Coverage across CpG coordinates:
png("coverage_across_CpG.png", width=800, height=600)
ggplot(coverage_long, aes(x = position, y = coverage)) +
  geom_point(size = 0.15, alpha = 0.15, color = "#C8A2C8") +
  geom_smooth(se = FALSE, linewidth = 0.7, color = "black") +
  facet_wrap(~ sample_id, ncol = 2) +
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(labels = scales::comma) +
  coord_cartesian(ylim = c(0, 100)) +
  labs(
    title = "Coverage Across CpG Genomic Coordinates",
    x = "CpG genomic position",
    y = "Coverage"
  )
dev.off()

# Duplication rates:
dup_df <- data.frame(
  sample_id = c("SRR11647653", "SRR11647655", "SRR11647663", "SRR11647665"),
  duplication_rate = c(0.275329, 0.042431, 0.100874, 0.064618),
  condition = c("non_tumor", "non_tumor", "tumor", "tumor")
)

png("duplication_rates.png", width=800, height=600)
ggplot(dup_df, aes(x = sample_id, y = duplication_rate * 100, fill = condition)) +
  geom_col() +
  scale_fill_manual(values = condition_cols) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "Duplication Rate per Sample",
    x = "Sample",
    y = "Duplication Rate (%)",
    fill = "Type"
  )
dev.off()