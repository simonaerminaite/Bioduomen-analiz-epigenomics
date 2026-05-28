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

# DMC calling:
# 1:
R
library(pacman)
p_load(data.table, dplyr, ggplot2, bsseq, GenomicRanges, reshape, gridExtra, patchwork, annotatr, pheatmap, dendextend, DSS, dmrseq, data.table, tidyverse, readr, matrixTests, ggvenn, knitr, scales) 

sample_cols <- c("SRR11647653", "SRR11647655", "SRR11647663", "SRR11647665")
sample_info <- data.frame(
  sample_id = sample_cols,
  condition = c("non_tumor", "non_tumor", "tumor", "tumor")
)

SRR11647653 <- read_tsv(
  "SRR11647653_methylation_chr20_CpG.bedGraph",
  comment = "t",
  col_names = c("chr", "start", "end", "methylation_percent", "methylated_reads", "unmethylated_reads")
)
SRR11647655 <- read_tsv(
  "SRR11647655_methylation_chr20_CpG.bedGraph",
  comment = "t",
  col_names = c("chr", "start", "end", "methylation_percent", "methylated_reads", "unmethylated_reads")
)
SRR11647663 <- read_tsv(
  "SRR11647663_methylation_chr20_CpG.bedGraph",
  comment = "t",
  col_names = c("chr", "start", "end", "methylation_percent", "methylated_reads", "unmethylated_reads")
)
SRR11647665 <- read_tsv(
  "SRR11647665_methylation_chr20_CpG.bedGraph",
  comment = "t",
  col_names = c("chr", "start", "end", "methylation_percent", "methylated_reads", "unmethylated_reads")
)

SRR11647653 <- SRR11647653 %>%
  mutate(
    coverage = methylated_reads + unmethylated_reads,
    methylation_fraction = methylation_percent / 100
  )
SRR11647655 <- SRR11647655 %>%
  mutate(
    coverage = methylated_reads + unmethylated_reads,
    methylation_fraction = methylation_percent / 100
  )
SRR11647663 <- SRR11647663 %>%
  mutate(
    coverage = methylated_reads + unmethylated_reads,
    methylation_fraction = methylation_percent / 100
  )
SRR11647665 <- SRR11647665 %>%
  mutate(
    coverage = methylated_reads + unmethylated_reads,
    methylation_fraction = methylation_percent / 100
  )

SRR11647653 <- SRR11647653 %>%
  mutate(cpg_id = paste(chr, start, end, sep = "_"))

SRR11647655 <- SRR11647655 %>%
  mutate(cpg_id = paste(chr, start, end, sep = "_"))

SRR11647663 <- SRR11647663 %>%
  mutate(cpg_id = paste(chr, start, end, sep = "_"))

SRR11647665 <- SRR11647665 %>%
  mutate(cpg_id = paste(chr, start, end, sep = "_"))


methylation_dt <- SRR11647653 %>%
  select(cpg_id, chr, position = start, SRR11647653 = methylation_fraction) %>%
  inner_join(
    SRR11647655 %>% 
      select(cpg_id, SRR11647655 = methylation_fraction),
    by = "cpg_id"
  ) %>%
  inner_join(
    SRR11647663 %>% 
      select(cpg_id, SRR11647663 = methylation_fraction),
    by = "cpg_id"
  ) %>%
  inner_join(
    SRR11647665 %>% 
      select(cpg_id, SRR11647665 = methylation_fraction),
    by = "cpg_id"
  )

coverage_dt <- SRR11647653 %>%
  select(cpg_id, chr, position = start, SRR11647653 = coverage) %>%
  inner_join(
    SRR11647655 %>% select(cpg_id, SRR11647655 = coverage),
    by = "cpg_id"
  ) %>%
  inner_join(
    SRR11647663 %>% select(cpg_id, SRR11647663 = coverage),
    by = "cpg_id"
  ) %>%
  inner_join(
    SRR11647665 %>% select(cpg_id, SRR11647665 = coverage),
    by = "cpg_id"
  )

setDT(methylation_dt)
setDT(coverage_dt)

#| message: false
#| warning: false

sample_cols <- names(methylation_dt)[!names(methylation_dt) %in% c("cpg_id", "chr", "position")]

chr <- methylation_dt$chr
pos <- methylation_dt$position

#Create empty matrices for methylated reads and coverage
#M_matrix   = methylated read counts
#Cov_matrix = total coverage counts
M_matrix <- matrix(NA, nrow = nrow(methylation_dt), ncol = length(sample_cols))
Cov_matrix <- matrix(NA, nrow = nrow(methylation_dt), ncol = length(sample_cols))

#Fill the matrices sample by sample
  for(i in 1:length(sample_cols)) {
    sample <- sample_cols[i]
    
    meth <- methylation_dt[[sample]]
    cov <- coverage_dt[[sample]]
    
    M_matrix[, i] <- round(meth * cov, 0) #converts methylation fractions into approximate methylated-read counts.

    Cov_matrix[, i] <- cov #stores total coverage.
    
    M_matrix[is.na(M_matrix[, i]), i] <- 0
    Cov_matrix[is.na(Cov_matrix[, i]), i] <- 0  #replace missing values with 0
  }

colnames(M_matrix) <- sample_cols
colnames(Cov_matrix) <- sample_cols #This gives the matrices proper sample names.

#Create a BSseq object
BS <- BSseq(chr = chr,
            pos = pos,
            M = M_matrix,
            Cov = Cov_matrix,
            sampleNames = sample_cols)

pData(BS) <- sample_info
rownames(pData(BS)) <- sample_info$sample_id
saveRDS(BS, "bsseq_object.RDS")

# Define comparison
group1_samples <- c("SRR11647653", "SRR11647655")  # healthy / normal
group2_samples <- c("SRR11647663", "SRR11647665")  # tumor

selected_samples <- c(group1_samples, group2_samples)

# Check that samples are present
selected_samples %in% sampleNames(BS)

# Filtering BS data. What can happen if we skip this? 
#Filter low-coverage CpGs
cov_matrix <- getCoverage(BS)
samples_covered <- rowSums(
  cov_matrix[, selected_samples] >= 10,
  na.rm = TRUE
) #For every CpG, this counts how many selected samples have coverage at least 10

keep_cpgs <- samples_covered >= 2 #keeps CpGs where at least 2 samples have coverage >= 10

BS_filtered <- BS[keep_cpgs] #subsets the BSseq object to only those CpGs.
saveRDS(BS_filtered, "BS_filtered.RDS")

# Run DMC testing with DSS
# This runs differential methylation testing at individual CpG sites.
# DMLtest() compares methylation between groups
dmlTest <- DMLtest(BS_filtered, 
                  group1 = group1_samples,
                  group2 = group2_samples,
                  ncores = 1, 
                  smoothing = FALSE) #means DSS tests each CpG without smoothing methylation values across neighboring CpGs.

saveRDS(dmlTest, "dss_dmlTest_result.RDS")

# Convert DSS result to data.table
dml_dt <- as.data.table(dmlTest)

# 2:
# Case 1: only statistical significance
# Adjusted p-value / FDR threshold only
# It does not require the methylation difference to be large.
dmcs_fdr_only <- dml_dt[
  fdr < 0.05
]

# Case 2: statistical significance + methylation difference threshold
# FDR < 0.05 and methylation difference at least 10 percentage points
dmcs_fdr_delta <- dml_dt[
  fdr < 0.05 & abs(diff) >= 0.10
]

# Save both DMC lists
fwrite(dmcs_fdr_only, "DMCs_FDR_0.05_only.csv")
fwrite(dmcs_fdr_delta, "DMCs_FDR_0.05_delta_0.10.csv")

# 3: 

# Because group1 = healthy and group2 = tumor:
# diff = healthy - tumor
#
# Therefore:
# diff < 0 = hypermethylated in tumor
# diff > 0 = hypomethylated in tumor

dmc_summary <- data.frame(
  Case = c(
    "FDR < 0.05 only",
    "FDR < 0.05 and |diff| >= 0.10"
  ),
  Total_DMCs = c(
    nrow(dmcs_fdr_only),
    nrow(dmcs_fdr_delta)
  ),
  Tumor_hypermethylated = c(
    sum(dmcs_fdr_only$diff < 0, na.rm = TRUE),
    sum(dmcs_fdr_delta$diff < 0, na.rm = TRUE)
  ),
  Tumor_hypomethylated = c(
    sum(dmcs_fdr_only$diff > 0, na.rm = TRUE),
    sum(dmcs_fdr_delta$diff > 0, na.rm = TRUE)
  )
)
dmc_summary
#                            Case Total_DMCs Tumor_hypermethylated
# 1               FDR < 0.05 only       4937                   228
# 2 FDR < 0.05 and |diff| >= 0.10       4937                   228
#   Tumor_hypomethylated
# 1                 4709
# 2                 4709

# 4:
# Groups
non_tumor_samples <- c("SRR11647653", "SRR11647655")
tumor_samples <- c("SRR11647663", "SRR11647665")

# Use same filtered CpGs as DSS
meth_filtered <- methylation_dt[keep_cpgs, ]

# Methylation matrix
meth_wilcox <- as.matrix(meth_filtered[, ..sample_cols])
rownames(meth_wilcox) <- paste(meth_filtered$chr, meth_filtered$position, sep = ":")
mode(meth_wilcox) <- "numeric"

# Wilcoxon test
wilcox_test <- row_wilcoxon_twosample(
  meth_wilcox[, tumor_samples],
  meth_wilcox[, non_tumor_samples]
)

wilcox_results <- data.table(
  cpg_id = rownames(meth_wilcox),
  chr = meth_filtered$chr,
  position = meth_filtered$position,
  diff = rowMeans(meth_wilcox[, tumor_samples], na.rm = TRUE) -
         rowMeans(meth_wilcox[, non_tumor_samples], na.rm = TRUE),
  pval = wilcox_test$pvalue
)

wilcox_results[, fdr := p.adjust(pval, method = "BH")]

wilcox_dmcs <- wilcox_results[
  fdr < 0.05 & abs(diff) >= 0.10
]

# DSS DMCs using same threshold
dss_dt <- as.data.table(dmlTest)
dss_dt[, cpg_id := paste(chr, pos, sep = ":")]

dss_dmcs <- dss_dt[
  fdr < 0.05 & abs(diff) >= 0.10
]

overlap_ids <- intersect(dss_dmcs$cpg_id, wilcox_dmcs$cpg_id)

venn_list <- list(
  DSS = dss_dmcs$cpg_id,
  Wilcoxon = wilcox_dmcs$cpg_id
)

png("venn_diagram.png", width=800, height=600)
ggvenn(
  venn_list,
  fill_color = c("#C8A2C8", "#FFB6C1"),
  stroke_size = 0.5,
  set_name_size = 5,
  text_size = 5
) +
  labs(title = "Overlap of DMCs detected by DSS and Wilcoxon test")
dev.off()

dmc_method_table <- data.frame(
  Method = c("DSS", "Wilcoxon", "Overlap"),
  Number_of_DMCs = c(
    nrow(dss_dmcs),
    nrow(wilcox_dmcs),
    length(overlap_ids)
  ),
  Mean_effect_size = c(
    mean(abs(dss_dmcs$diff), na.rm = TRUE),
    mean(abs(wilcox_dmcs$diff), na.rm = TRUE),
    mean(abs(dss_dmcs[cpg_id %in% overlap_ids]$diff), na.rm = TRUE)
  )
)

knitr::kable(
  dmc_method_table,
  caption = "Comparison of DMCs detected by DSS and Wilcoxon test"
)

# Table: Comparison of DMCs detected by DSS and Wilcoxon test
# |Method   | Number_of_DMCs| Mean_effect_size|
# |:--------|--------------:|----------------:|
# |DSS      |           4937|        0.5624625|
# |Wilcoxon |              0|              NaN|
# |Overlap  |              0|              NaN|

# 5:
# Convert DSS result to data.table
dss_dt <- as.data.table(dmlTest)

# Threshold combinations using FDR-adjusted p-value
threshold_results <- data.frame(
  Threshold = c(
    "FDR<0.05, Δβ>0.1",
    "FDR<0.01, Δβ>0.1",
    "FDR<0.05, Δβ>0.2",
    "FDR<0.01, Δβ>0.2"
  ),
  DMC_count = c(
    nrow(dss_dt[fdr < 0.05 & abs(diff) >= 0.10]),
    nrow(dss_dt[fdr < 0.01 & abs(diff) >= 0.10]),
    nrow(dss_dt[fdr < 0.05 & abs(diff) >= 0.20]),
    nrow(dss_dt[fdr < 0.01 & abs(diff) >= 0.20])
  )
)

# Keep order
threshold_results$Threshold <- factor(
  threshold_results$Threshold,
  levels = threshold_results$Threshold
)

threshold_results
#          Threshold DMC_count
# 1 FDR<0.05, Δβ>0.1      4937
# 2 FDR<0.01, Δβ>0.1      1307
# 3 FDR<0.05, Δβ>0.2      4937
# 4 FDR<0.01, Δβ>0.2      1307

# Plot
png("threshold_stringency.png", width=800, height=600)
ggplot(threshold_results, aes(x = Threshold, y = DMC_count, fill = Threshold)) +
  geom_col(
    width = 0.65,
    color = "black",
    linewidth = 0.4,
    show.legend = FALSE
  ) +
  geom_text(
    aes(label = scales::comma(DMC_count)),
    vjust = -0.35,
    size = 4.5
  ) +
  scale_fill_manual(values = c(
    "#C8A2C8",
    "#89CFF0",
    "#FFB6C1",
    "#98FF98"
  )) +
  scale_y_continuous(
    labels = scales::comma,
    expand = expansion(mult = c(0, 0.08))
  ) +
  labs(
    title = "Number of DMCs under Different Thresholds",
    x = "Threshold combination",
    y = "Number of DMCs"
  ) +
  theme_bw(base_size = 14) +
  theme(
    aspect.ratio = 0.6,
    axis.text.x = element_text(angle = 15, hjust = 1),
    plot.title = element_text(hjust = 0.5, face = "bold")
  )
dev.off()

# 6:
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(GenomicRanges)
library(IRanges)
library(annotatr)
library(scales)

dmcs_dt <- as.data.table(dmcs_fdr_delta)

# Create GRanges object
dmcs_gr <- GRanges(
  seqnames = dmcs_dt$chr,
  ranges = IRanges(
    start = dmcs_dt$pos,
    width = 1
  ),
  diff = dmcs_dt$diff,
  fdr = dmcs_dt$fdr
)

# Build hg38 annotations

annotations <- build_annotations(
  genome = "hg38",
  annotations = c(
    "hg38_genes_promoters",
    "hg38_genes_exons",
    "hg38_genes_introns",
    "hg38_genes_intergenic"
  )
)

# Annotate DMCs

dmcs_annotated <- annotate_regions(
  regions = dmcs_gr,
  annotations = annotations,
  ignore.strand = TRUE,
  quiet = TRUE
)

dmcs_annot_dt <- as.data.table(dmcs_annotated)

# Clean annotation names

dmcs_annot_dt[, annot_type := annot.type]

dmcs_annot_dt[, annot_type := gsub("hg38_", "", annot_type)]
dmcs_annot_dt[, annot_type := gsub("genes_", "", annot_type)]

# Keep only desired genomic features
dmcs_annot_dt <- dmcs_annot_dt[
  grepl(
    "promoter|exon|intron|intergenic",
    annot_type,
    ignore.case = TRUE
  )
]

# Prioritize annotations
# promoter > exon > intron > intergenic

dmcs_annot_dt[, priority := fcase(
  grepl("promoter", annot_type, ignore.case = TRUE), 1,
  grepl("exon", annot_type, ignore.case = TRUE), 2,
  grepl("intron", annot_type, ignore.case = TRUE), 3,
  grepl("intergenic", annot_type, ignore.case = TRUE), 4,
  default = 99
)]

setorder(
  dmcs_annot_dt,
  seqnames,
  start,
  priority
)

# Keep highest-priority annotation per CpG
dmcs_unique <- dmcs_annot_dt[
  ,
  .SD[1],
  by = .(seqnames, start)
]

# Extract promoter DMCs

promoter_dmcs <- dmcs_unique[
  grepl("promoter", annot_type, ignore.case = TRUE)
]

# Summary table

annotation_summary <- dmcs_unique[
  ,
  .N,
  by = annot_type
]

annotation_summary <- annotation_summary[
  order(-N)
]

promoter_summary <- data.frame(
  Category = c(
    "All DMCs",
    "Promoter DMCs"
  ),
  Count = c(
    nrow(dmcs_unique),
    nrow(promoter_dmcs)
  )
)

print(promoter_summary)
#    Category Count
#1      All DMCs  4766
#2 Promoter DMCs   125

# Plot annotation distribution

p1 <- ggplot(
  annotation_summary,
  aes(
    x = reorder(annot_type, -N),
    y = N,
    fill = annot_type
  )
) +
  geom_col(
    width = 0.7,
    color = "black",
    linewidth = 0.4,
    show.legend = FALSE
  ) +
  geom_text(
    aes(label = comma(N)),
    vjust = -0.3,
    size = 4
  ) +
  scale_fill_manual(values = c(
    "#C8A2C8",
    "#89CFF0",
    "#FFB6C1",
    "#98FF98"
  )) +
  scale_y_continuous(
    labels = comma,
    expand = expansion(mult = c(0, 0.08))
  ) +
  labs(
    title = "Genomic Annotation of DMCs",
    x = "Genomic Feature",
    y = "Number of DMCs"
  ) +
  theme_bw(base_size = 14) +
  theme(
    axis.text.x = element_text(
      angle = 25,
      hjust = 1
    ),
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    )
  )

ggsave(
  "annotation_distribution.png",
  plot = p1,
  width = 8,
  height = 6,
  dpi = 300
)

# Add methylation direction

dmcs_unique[, direction := fifelse(
  diff < 0,
  "Hypermethylated in tumor",
  "Hypomethylated in tumor"
)]

promoter_dmcs <- dmcs_unique[
  grepl("promoter", annot_type, ignore.case = TRUE)
]

# Simplify feature categories

dmcs_unique[, feature_category := fcase(
  grepl("promoter", annot_type, ignore.case = TRUE), "Promoters",
  grepl("exon", annot_type, ignore.case = TRUE), "Exons",
  grepl("intron", annot_type, ignore.case = TRUE), "Introns",
  grepl("intergenic", annot_type, ignore.case = TRUE), "Intergenic",
  default = "Other"
)]

# Observed DMC distribution

feature_summary <- dmcs_unique[
  ,
  .N,
  by = feature_category
]

feature_summary[, percentage := 100 * N / sum(N)]

# Background CpGs

all_cpgs_dt <- dml_dt[
  ,
  .(
    chr = chr,
    pos = pos
  )
]

all_cpgs_gr <- GRanges(
  seqnames = all_cpgs_dt$chr,
  ranges = IRanges(
    start = all_cpgs_dt$pos,
    width = 1
  )
)

background_annotated <- annotate_regions(
  regions = all_cpgs_gr,
  annotations = annotations,
  ignore.strand = TRUE,
  quiet = TRUE
)

background_dt <- as.data.table(background_annotated)

background_dt[, annot_type := annot.type]

background_dt[, annot_type := gsub("hg38_", "", annot_type)]
background_dt[, annot_type := gsub("genes_", "", annot_type)]

# Keep only desired features
background_dt <- background_dt[
  grepl(
    "promoter|exon|intron|intergenic",
    annot_type,
    ignore.case = TRUE
  )
]

# Priority
background_dt[, priority := fcase(
  grepl("promoter", annot_type, ignore.case = TRUE), 1,
  grepl("exon", annot_type, ignore.case = TRUE), 2,
  grepl("intron", annot_type, ignore.case = TRUE), 3,
  grepl("intergenic", annot_type, ignore.case = TRUE), 4,
  default = 99
)]

setorder(
  background_dt,
  seqnames,
  start,
  priority
)

background_unique <- background_dt[
  ,
  .SD[1],
  by = .(seqnames, start)
]

# Simplified categories

background_unique[, feature_category := fcase(
  grepl("promoter", annot_type, ignore.case = TRUE), "Promoters",
  grepl("exon", annot_type, ignore.case = TRUE), "Exons",
  grepl("intron", annot_type, ignore.case = TRUE), "Introns",
  grepl("intergenic", annot_type, ignore.case = TRUE), "Intergenic",
  default = "Other"
)]

# Background percentages

background_summary <- background_unique[
  ,
  .N,
  by = feature_category
]

background_summary[
  ,
  bg_percentage := 100 * N / sum(N)
]

# Enrichment table

enrichment_table <- merge(
  feature_summary,
  background_summary[
    ,
    .(
      feature_category,
      bg_percentage
    )
  ],
  by = "feature_category",
  all = TRUE
)

enrichment_table[is.na(N), N := 0]
enrichment_table[is.na(percentage), percentage := 0]

enrichment_table[, enrichment := fifelse(
  bg_percentage > 0,
  percentage / bg_percentage,
  NA_real_
)]

enrichment_table[
  ,
  log2_enrichment := log2(enrichment)
]

print(enrichment_table)

# Key: <feature_category>
#    feature_category     N percentage bg_percentage enrichment log2_enrichment
#              <char> <int>      <num>         <num>      <num>           <num>
# 1:            Exons   229   4.804868      8.229803  0.5838376     -0.77636109
# 2:       Intergenic  1936  40.621066     35.077838  1.1580265      0.21166827
# 3:          Introns  2476  51.951322     50.461685  1.0295202      0.04197209
# 4:        Promoters   125   2.622744      6.230675  0.4209407     -1.24831124

# Enrichment plot

p2 <- ggplot(
  enrichment_table,
  aes(
    x = reorder(feature_category, enrichment),
    y = enrichment
  )
) +
  geom_col(
    aes(fill = enrichment > 1),
    width = 0.7,
    color = "black",
    linewidth = 0.4
  ) +
  geom_hline(
    yintercept = 1,
    linetype = "dashed"
  ) +
  geom_text(
    aes(label = round(enrichment, 2)),
    hjust = -0.2,
    size = 4
  ) +
  coord_flip() +
  scale_fill_manual(
    values = c(
      "TRUE" = "#F07167",
      "FALSE" = "#4DBBD5"
    ),
    labels = c(
      "TRUE" = "Enriched",
      "FALSE" = "Depleted"
    )
  ) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.08))
  ) +
  labs(
    title = "DMC Enrichment in Genomic Features",
    x = "Genomic Feature",
    y = "Enrichment (Observed / Expected)",
    fill = ""
  ) +
  theme_bw(base_size = 14) +
  theme(
    legend.position = "top",
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    )
  )

ggsave(
  "enrichment_in_genomic_feature.png",
  plot = p2,
  width = 8,
  height = 6,
  dpi = 300
)

# Hyper vs Hypo feature preference

feature_by_direction <- dmcs_unique[
  ,
  .N,
  by = .(
    feature_category,
    direction
  )
]

feature_by_direction[
  ,
  total := sum(N),
  by = direction
]

feature_by_direction[
  ,
  percentage := 100 * N / total
]

# Plot hyper vs hypo distribution

p3 <- ggplot(
  feature_by_direction,
  aes(
    x = feature_category,
    y = percentage,
    fill = direction
  )
) +
  geom_col(
    position = position_dodge(width = 0.9),
    width = 0.7,
    color = "black",
    linewidth = 0.4
  ) +
  geom_text(
    aes(label = paste0(round(percentage, 1), "%")),
    position = position_dodge(width = 0.9),
    vjust = -0.4,
    size = 4
  ) +
  scale_fill_manual(values = c(
    "Hypermethylated in tumor" = "#F07167",
    "Hypomethylated in tumor" = "#4DBBD5"
  )) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.08))
  ) +
  labs(
    title = "Genomic Feature Preferences: Hyper vs Hypo DMCs",
    x = "Genomic Feature",
    y = "Percentage of DMCs (%)",
    fill = "Direction"
  ) +
  theme_bw(base_size = 14) +
  theme(
    axis.text.x = element_text(
      angle = 30,
      hjust = 1
    ),
    legend.position = "top",
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    )
  )

ggsave(
  "genomic_feature_preference.png",
  plot = p3,
  width = 8,
  height = 6,
  dpi = 300
)

# Promoter-only analysis

promoter_feature_summary <- promoter_dmcs[
  ,
  .N,
  by = direction
]

print(promoter_feature_summary)

#  direction     N
#                      <char> <int>
# 1:  Hypomethylated in tumor    87
# 2: Hypermethylated in tumor    38

cat("\n")
cat("Total promoter DMCs:", nrow(promoter_dmcs), "\n")
cat("Total DMCs:", nrow(dmcs_unique), "\n")

#  Category Count
# 1      All DMCs  4766
# 2 Promoter DMCs   125

# 7:
dss_dt <- as.data.table(dmlTest)
dss_dt <- dss_dt[!is.na(fdr)]

# Flip DSS diff so positive = higher methylation in tumour
dss_dt[, tumor_diff := -diff]

dss_dt[, status := fifelse(
  fdr < 0.05 & tumor_diff >= 0.10,
  "Hypermethylated in tumor",
  fifelse(
    fdr < 0.05 & tumor_diff <= -0.10,
    "Hypomethylated in tumor",
    "Not significant"
  )
)]

png("volcano_plot.png", width=800, height=600)
ggplot(
  dss_dt,
  aes(
    x = tumor_diff,
    y = -log10(fdr),
    color = status
  )
) +
  geom_point(
    alpha = 0.5,
    size = 1
  ) +
  
  geom_vline(
    xintercept = c(-0.10, 0.10),
    linetype = "dashed",
    color = "black"
  ) +
  
  geom_hline(
    yintercept = -log10(0.05),
    linetype = "dashed",
    color = "black"
  ) +
  
  scale_color_manual(values = c(
    "Hypermethylated in tumor" = "#F07167",
    "Hypomethylated in tumor" = "#4DBBD5",
    "Not significant" = "grey75"
  )) +
  
  labs(
    title = "Volcano Plot of Differentially Methylated CpGs",
    x = expression(Delta * beta),
    y = expression(-log[10](FDR)),
    color = NULL
  ) +
  
  theme_bw(base_size = 13) +
  
  theme(
    aspect.ratio = 0.5,
    legend.position = "top",
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    )
  )
dev.off()

# 8:
# MA plot data
dss_dt <- as.data.table(dmlTest)

dss_dt[, tumor_diff := -diff]

dss_dt[, mean_methylation := (mu1 + mu2) / 2]

dss_dt[, status := fifelse(
  fdr < 0.05 & tumor_diff >= 0.10,
  "Hypermethylated in tumor",
  fifelse(
    fdr < 0.05 & tumor_diff <= -0.10,
    "Hypomethylated in tumor",
    "Not significant"
  )
)]

png("ma_plot.png", width=800, height=600)
ggplot(
  dss_dt,
  aes(
    x = mean_methylation,
    y = tumor_diff,
    color = status
  )
) +
  geom_point(
    alpha = 0.4,
    size = 0.8
  ) +
  geom_hline(
    yintercept = c(-0.10, 0.10),
    linetype = "dashed",
    color = "black"
  ) +
  scale_color_manual(values = c(
    "Hypermethylated in tumor" = "#F07167",
    "Hypomethylated in tumor" = "#4DBBD5",
    "Not significant" = "grey75"
  )) +
  labs(
    title = "MA Plot of Differential Methylation",
    x = "Average methylation level",
    y = expression(Delta * beta),
    color = NULL
  ) +
  theme_bw(base_size = 13) +
  theme(
    aspect.ratio = 0.5,
    legend.position = "top",
    plot.title = element_text(hjust = 0.5, face = "bold")
  )
dev.off()

# DMR calling:
# 1:
# Run DMR calling with different parameter sets

# Parameter set 1
dmr_set1 <- callDMR(
  dmlTest,
  p.threshold = 0.05,
  minCG = 3,
  minlen = 50
)

# Parameter set 2
dmr_set2 <- callDMR(
  dmlTest,
  p.threshold = 0.01,
  minCG = 5,
  minlen = 100
)

# Parameter set 3
dmr_set3 <- callDMR(
  dmlTest,
  p.threshold = 0.01,
  minCG = 7,
  minlen = 200
)

# Convert to data.tables

dmr1_dt <- as.data.table(dmr_set1)
dmr2_dt <- as.data.table(dmr_set2)
dmr3_dt <- as.data.table(dmr_set3)

# Add parameter labels

dmr1_dt[, parameter_set := "minCG=3, minlen=50, p=0.05"]
dmr2_dt[, parameter_set := "minCG=5, minlen=100, p=0.01"]
dmr3_dt[, parameter_set := "minCG=7, minlen=200, p=0.01"]

# Combine all DMRs

all_dmrs <- rbindlist(list(
  dmr1_dt,
  dmr2_dt,
  dmr3_dt
), fill = TRUE)

# Calculate DMR statistics

dmr_summary <- all_dmrs[
  ,
  .(
    Number_of_DMRs = .N,
    Mean_length_bp = round(mean(length), 1),
    Median_length_bp = round(median(length), 1),
    Mean_CpGs_per_DMR = round(mean(nCG), 1),
    Median_CpGs_per_DMR = round(median(nCG), 1),
    Mean_CpG_density = round(mean(nCG / length * 100), 2)
  ),
  by = parameter_set
]

dmr_summary
#                  parameter_set Number_of_DMRs Mean_length_bp Median_length_bp
#                         <char>          <int>          <num>            <num>
# 1:  minCG=3, minlen=50, p=0.05           2155          345.5              185
# 2: minCG=5, minlen=100, p=0.01            160          299.8              192
# 3: minCG=7, minlen=200, p=0.01             28          383.8              281
#    Mean_CpGs_per_DMR Median_CpGs_per_DMR Mean_CpG_density
#                <num>               <num>            <num>
# 1:               5.7                   5             3.81
# 2:               8.0                   7             4.17
# 3:              11.4                  10             3.77

# Plot number of DMRs

p1 <- ggplot(
  dmr_summary,
  aes(
    x = parameter_set,
    y = Number_of_DMRs,
    fill = parameter_set
  )
) +
  geom_col(
    width = 0.7,
    color = "black",
    linewidth = 0.4,
    show.legend = FALSE
  ) +
  geom_text(
    aes(label = scales::comma(Number_of_DMRs)),
    vjust = -0.35,
    size = 4
  ) +
  scale_fill_manual(values = c(
    "#F07167",
    "#4DBBD5",
    "#9B7EDE"
  )) +
  scale_y_continuous(
    labels = scales::comma,
    expand = expansion(mult = c(0, 0.08))
  ) +
  labs(
    title = "Number of DMRs",
    x = NULL,
    y = "Count"
  ) +
  theme_bw(base_size = 13) +
  theme(
    aspect.ratio = 0.65,
    axis.text.x = element_text(angle = 15, hjust = 1),
    plot.title = element_text(hjust = 0.5, face = "bold")
  )

# Plot DMR length distribution

p2 <- ggplot(
  all_dmrs,
  aes(
    x = length,
    fill = parameter_set
  )
) +
  geom_histogram(
    bins = 40,
    alpha = 0.7
  ) +
  scale_fill_manual(values = c(
    "#F07167",
    "#4DBBD5",
    "#9B7EDE"
  )) +
  labs(
    title = "DMR Length Distribution",
    x = "Length (bp)",
    y = "Count"
  ) +
  theme_bw(base_size = 13) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.position = "top"
  )

p2 <- p2 +
  theme(
    legend.text = element_text(size = 7),
    legend.title = element_text(size = 9)
  )

# Plot CpG density

all_dmrs[, CpG_density := nCG / length * 100]

p3 <- ggplot(
  all_dmrs,
  aes(
    x = parameter_set,
    y = CpG_density,
    fill = parameter_set
  )
) +
  geom_boxplot(
    color = "black",
    linewidth = 0.4,
    show.legend = FALSE
  ) +
  scale_fill_manual(values = c(
    "#F07167",
    "#4DBBD5",
    "#9B7EDE"
  )) +
  labs(
    title = "CpG Density",
    x = NULL,
    y = "CpGs per 100 bp"
  ) +
  theme_bw(base_size = 13) +
  theme(
    aspect.ratio = 0.65,
    axis.text.x = element_text(angle = 15, hjust = 1),
    plot.title = element_text(hjust = 0.5, face = "bold")
  )

combined_plot <- p1 + p3

ggsave(
  "combined_dmr_plots.png",
  plot = combined_plot,
  width = 12,
  height = 6,
  dpi = 300
)

ggsave(
  "dmr_count.png",
  plot = p1,
  width = 7,
  height = 5,
  dpi = 300
)

ggsave(
  "dmr_length_distribution.png",
  plot = p2,
  width = 7,
  height = 5,
  dpi = 300
)

ggsave(
  "cpg_density.png",
  plot = p3,
  width = 7,
  height = 5,
  dpi = 300
)

# 2:

# DMR CHARACTERIZATION
# Using optimal parameter set:
# minCG=5, minlen=100, p=0.01

# Use optimal DMR set
dmr_dt <- dmr2_dt

# Add useful variables

# Direction
# DSS areaStat follows sign of methylation difference
# diff = healthy - tumour
# negative = hypermethylated in tumour

dmr_dt[, direction := fifelse(
  areaStat < 0,
  "Hypermethylated in tumour",
  "Hypomethylated in tumour"
)]

# CpG density
dmr_dt[, CpG_density := nCG / length * 100]

# Absolute effect size
dmr_dt[, abs_areaStat := abs(areaStat)]

# 1. Length distribution

png("length_distribution.png", width=800, height=600)
ggplot(dmr_dt, aes(x = length)) +
  geom_histogram(
    bins = 40,
    fill = "#4DBBD5",
    color = "black",
    linewidth = 0.4
  ) +
  labs(
    title = "DMR Length Distribution",
    x = "DMR length (bp)",
    y = "Count"
  ) +
  theme_bw(base_size = 13) +
  theme(
    aspect.ratio = 0.65,
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    )
  )
dev.off()

# 2. CpGs per DMR distribution

cpg_count_summary <- dmr_dt[
  ,
  .N,
  by = nCG
]

# Plot
png("CpGs_per_DMR_distribution.png", width=800, height=600)
ggplot(
  cpg_count_summary,
  aes(x = nCG, y = N)
) +
  geom_col(
    fill = "#F07167",
    width = 0.8,
    color = "black",
    linewidth = 0.4
  ) +
  geom_text(
    aes(label = N),
    vjust = -0.3,
    size = 3
  ) +
  labs(
    title = "Distribution of CpGs per DMR",
    x = "Number of CpGs in a DMR",
    y = "Number of DMRs"
  ) +
  theme_bw(base_size = 13) +
  theme(
    aspect.ratio = 0.65,
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    )
  )
dev.off()

# 3. Chromosome distribution

chr_summary <- dmr_dt[
  ,
  .N,
  by = chr
]

setorder(chr_summary, chr)

png("chromosome_distribution.png", width=800, height=600)
ggplot(chr_summary,
       aes(x = chr,
           y = N)) +
  geom_col(
    fill = "#9B7EDE",
    color = "black",
    linewidth = 0.4
  ) +
  geom_text(
    aes(label = comma(N)),
    vjust = -0.3,
    size = 3
  ) +
  labs(
    title = "Chromosome Distribution of DMRs",
    x = "Chromosome",
    y = "Number of DMRs"
  ) +
  theme_bw(base_size = 13) +
  theme(
    aspect.ratio = 0.65,
    axis.text.x = element_text(angle = 15, hjust = 1),
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    )
  )
dev.off()

# 4. Hyper vs Hypo properties

direction_summary <- dmr_dt[
  ,
  .(
    Number_of_DMRs = .N,
    Mean_length = round(mean(length), 1),
    Mean_CpGs = round(mean(nCG), 1),
    Mean_density = round(mean(CpG_density), 2)
  ),
  by = direction
]

direction_summary
#                    direction Number_of_DMRs Mean_length Mean_CpGs Mean_density
#                       <char>          <int>       <num>     <num>        <num>
# 1:  Hypomethylated in tumour            157       303.3       8.0         4.10
# 2: Hypermethylated in tumour              3       114.0       8.7         7.84

png("hypo_and_hyper_methylated_DMRs.png", width=800, height=600)
ggplot(
  dmr_dt,
  aes(x = direction,
      fill = direction)
) +
  geom_bar(
    color = "black",
    linewidth = 0.4,
    show.legend = FALSE
  ) +
  geom_text(
    stat = "count",
    aes(label = after_stat(count)),
    vjust = -0.3
  ) +
  scale_fill_manual(values = c(
    "#F07167",
    "#4DBBD5"
  )) +
  labs(
    title = "Hypermethylated vs Hypomethylated DMRs",
    x = "",
    y = "Number of DMRs"
  ) +
  theme_bw(base_size = 13) +
  theme(
    aspect.ratio = 0.65,
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    )
  )
dev.off()

# 5. Density plot across genome

png("density_plot_across_chr20.png", width=800, height=600)
ggplot(dmr_dt, aes(x = start)) +
  geom_histogram(
    bins = 40,
    fill = "#4DBBD5",
    color = "black",
    linewidth = 0.4
  ) +
  scale_x_continuous(labels = scales::comma) +
  labs(
    title = "Distribution of DMRs across Chromosome 20",
    x = "Genomic position on chr20",
    y = "Number of DMRs"
  ) +
  theme_bw(base_size = 13) +
  theme(
    aspect.ratio = 0.65,
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    )
  )
dev.off()

# 6. Correlation between DMR length and effect size

# Absolute methylation difference
dmr_dt[, abs_diff := abs(diff.Methy)]

# Spearman correlation
cor_res <- cor.test(
  dmr_dt$length,
  dmr_dt$abs_diff,
  method = "spearman"
)

rho_value <- round(cor_res$estimate, 3)
p_value <- signif(cor_res$p.value, 2)

# Plot
png("spearman_corr.png", width=800, height=600)
ggplot(
  dmr_dt,
  aes(x = length, y = abs_diff)
) +
  
  geom_point(
    alpha = 0.6,
    size = 1.8,
    color = "#4DBBD5"
  ) +
  
  geom_smooth(
    method = "lm",
    color = "#F07167",
    fill = "grey70",
    linewidth = 1
  ) +
  
  annotate(
    "text",
    x = max(dmr_dt$length) * 0.62,
    y = max(dmr_dt$abs_diff) * 0.92,
    label = paste0(
      "Spearman rho = ",
      rho_value,
      "\n",
      "p = ",
      p_value
    ),
    size = 5
  ) +
  
  labs(
    title = "Correlation Between DMR Length and Effect Size",
    x = "DMR length (bp)",
    y = "Absolute methylation difference"
  ) +
  
  theme_bw(base_size = 13) +
  
  theme(
    aspect.ratio = 0.65,
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    panel.grid.minor = element_blank()
  )
dev.off()

# 3:

# Add direction
dmr_dt[, direction := fifelse(
  areaStat < 0,
  "Hypermethylated in tumour",
  "Hypomethylated in tumour"
)]
names(dmr_dt)

# [1] "chr"           "start"         "end"           "length"       
# [5] "nCG"           "meanMethy1"    "meanMethy2"    "diff.Methy"   
# [9] "areaStat"      "parameter_set" "direction"     "CpG_density"  
#[13] "abs_areaStat"  "abs_diff"     

# Final DMR table
dmr_final <- dmr_dt[, .(
  chr,
  start,
  end,
  length,
  nCG,
  mean_methylation_difference = diff.Methy,
  areaStat
)]

# 4:
# DMC GRanges

dmcs_dt <- dmcs_fdr_delta

dmc_gr <- GRanges(
  seqnames = dmcs_dt$chr,
  ranges = IRanges(
    start = dmcs_dt$pos,
    width = 1
  )
)

# DMR GRanges

dmr_gr <- GRanges(
  seqnames = dmr_dt$chr,
  ranges = IRanges(
    start = dmr_dt$start,
    end = dmr_dt$end
  )
)

# Overlap

hits <- findOverlaps(dmc_gr, dmr_gr)

dmc_in_dmr <- length(unique(queryHits(hits)))
total_dmcs <- length(dmc_gr)

dmc_fraction <- dmc_in_dmr / total_dmcs

comparison_summary <- data.frame(
  Category = c(
    "DMCs inside DMRs",
    "Isolated DMCs"
  ),
  Count = c(
    dmc_in_dmr,
    total_dmcs - dmc_in_dmr
  )
)

comparison_summary$Percentage <- round(
  100 * comparison_summary$Count / sum(comparison_summary$Count),
  1
)

comparison_summary$Label <- paste0(
  scales::comma(comparison_summary$Count),
  "\n(",
  comparison_summary$Percentage,
  "%)"
)

png("DMCs_within_DMRs.png", width=800, height=600)
ggplot(
  comparison_summary,
  aes(
    x = Category,
    y = Percentage,
    fill = Category
  )
) +
  geom_col(
    width = 0.7,
    color = "black",
    linewidth = 0.4,
    show.legend = FALSE
  ) +
  geom_text(
    aes(label = Label),
    vjust = -0.15,
    size = 4.5
  ) +
  scale_fill_manual(values = c(
    "#F07167",
    "#4DBBD5"
  )) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.18))
  ) +
  labs(
    title = "Fraction of DMCs Falling Within DMRs",
    x = "",
    y = "Percentage of DMCs (%)"
  ) +
  theme_bw(base_size = 13) +
  theme(
    aspect.ratio = 0.65,
    plot.title = element_text(hjust = 0.5, face = "bold")
  )
dev.off()

dmr_with_dmc <- unique(subjectHits(hits))

isolated_dmrs <- length(dmr_gr) - length(dmr_with_dmc)

isolated_summary <- data.frame(
  Category = c(
    "DMRs containing DMCs",
    "Isolated DMRs"
  ),
  Count = c(
    length(dmr_with_dmc),
    isolated_dmrs
  )
)

isolated_summary$Percentage <- round(
  100 * isolated_summary$Count / sum(isolated_summary$Count),
  1
)

isolated_summary$Label <- paste0(
  scales::comma(isolated_summary$Count),
  "\n(",
  isolated_summary$Percentage,
  "%)"
)

knitr::kable(
  isolated_summary
)

#|Category             | Count| Percentage|Label    |
#|:--------------------|-----:|----------:|:--------|
#|DMRs containing DMCs |   128|         80|128
#(80%) |
#|Isolated DMRs        |    32|         20|32
#(20%)  |

png("isolated_vs_DCM_containing_DMR.png", width=800, height=600)
ggplot(
  isolated_summary,
  aes(
    x = Category,
    y = Count,
    fill = Category
  )
) +
  geom_col(
    width = 0.7,
    color = "black",
    linewidth = 0.4,
    show.legend = FALSE
  ) +
  geom_text(
    aes(label = Label),
    vjust = -0.2,
    size = 4.2
  ) +
  scale_fill_manual(values = c(
    "#F07167",
    "#4DBBD5"
  )) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.18))
  ) +
  labs(
    title = "Isolated vs DMC-containing DMRs",
    x = NULL,
    y = "Number of DMRs"
  ) +
  theme_bw(base_size = 13) +
  theme(
    aspect.ratio = 0.65,
    axis.text.x = element_text(
      hjust = 0.5
    ),
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    )
  )
dev.off()

# DMR enrichment in promoters and CpG islands
# AFTER isolated DMR calculation

# Rebuild annotations INCLUDING CpG islands
dmr_annotations_set <- build_annotations(
  genome = "hg38",
  annotations = c(
    "hg38_cpgs",
    "hg38_genes_promoters"
  )
)

# Annotate DMRs
dmr_annotated <- annotate_regions(
  regions = dmr_gr,
  annotations = dmr_annotations_set,
  ignore.strand = TRUE,
  quiet = TRUE
)

dmr_annot_dt <- as.data.table(dmr_annotated)

# Clean annotation names
dmr_annot_dt[, annot_type := annot.type]
dmr_annot_dt[, annot_type := gsub("hg38_", "", annot_type)]
dmr_annot_dt[, annot_type := gsub("genes_", "", annot_type)]
dmr_annot_dt[, annot_type := gsub("cpg_", "", annot_type)]

# Make DMR ID
dmr_annot_dt[, dmr_id := paste(seqnames, start, end, sep = "_")]

# Total DMRs
total_dmrs <- length(dmr_gr)

# Count DMRs overlapping promoters
promoter_dmr_ids <- unique(
  dmr_annot_dt[annot_type == "promoters", dmr_id]
)

# Count DMRs overlapping CpG islands
cgi_dmr_ids <- unique(
  dmr_annot_dt[annot_type == "islands", dmr_id]
)

## Summary table
dmr_feature_summary <- data.table(
  Feature = c("CpG Islands", "Promoters"),
  Count = c(
    length(cgi_dmr_ids),
    length(promoter_dmr_ids)
  )
)

dmr_feature_summary[, Percentage := round(100 * Count / total_dmrs, 1)]

dmr_feature_summary[, Label := paste0(
  Count,
  "\n(",
  Percentage,
  "%)"
)]

# Plot DMR overlap with promoters and CpG islands

png("DMR_overlap.png", width=800, height=600)
ggplot(
  dmr_feature_summary,
  aes(x = Feature, y = Percentage, fill = Feature)
) +
  geom_col(
    width = 0.65,
    color = "black",
    linewidth = 0.4,
    show.legend = FALSE
  ) +
  geom_text(
    aes(label = Label),
    vjust = -0.2,
    size = 4.5
  ) +
  scale_fill_manual(values = c(
    "CpG Islands" = "#F07167",
    "Promoters" = "#4DBBD5"
  )) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.18))
  ) +
  labs(
    title = "DMR Overlap with Promoters and CpG Islands",
    x = "",
    y = "Percentage of DMRs (%)"
  ) +
  theme_bw(base_size = 13) +
  theme(
    aspect.ratio = 0.65,
    axis.text.x = element_text(
      hjust = 0.5
    ),
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    )
  )
dev.off()

# Odds ratio enrichment for DMRs in promoters and CpG islands

dmr_annotations_set <- build_annotations(
  genome = "hg38",
  annotations = c(
    "hg38_cpgs",
    "hg38_genes_promoters"
  )
)

dmr_annotated <- annotate_regions(
  regions = dmr_gr,
  annotations = dmr_annotations_set,
  ignore.strand = TRUE,
  quiet = TRUE
)

dmr_annot_dt <- as.data.table(dmr_annotated)

dmr_annot_dt[, annot_type := annot.type]
dmr_annot_dt[, annot_type := gsub("hg38_", "", annot_type)]
dmr_annot_dt[, annot_type := gsub("genes_", "", annot_type)]
dmr_annot_dt[, annot_type := gsub("cpg_", "", annot_type)]

dmr_annot_dt[, dmr_id := paste(seqnames, start, end, sep = "_")]

total_dmrs <- length(dmr_gr)

# Background = all tested CpGs/regions
background_gr <- GRanges(
  seqnames = dml_dt$chr,
  ranges = IRanges(start = dml_dt$pos, width = 1)
)

background_annotated <- annotate_regions(
  regions = background_gr,
  annotations = dmr_annotations_set,
  ignore.strand = TRUE,
  quiet = TRUE
)

background_dt <- as.data.table(background_annotated)

background_dt[, annot_type := annot.type]
background_dt[, annot_type := gsub("hg38_", "", annot_type)]
background_dt[, annot_type := gsub("genes_", "", annot_type)]
background_dt[, annot_type := gsub("cpg_", "", annot_type)]
background_dt[, bg_id := paste(seqnames, start, sep = "_")]

total_background <- length(background_gr)

# Function to calculate odds ratio and p-value
get_enrichment <- function(feature_name, feature_pattern) {
  
  dmr_feature_ids <- unique(
    dmr_annot_dt[
      grepl(feature_pattern, annot_type, ignore.case = TRUE),
      dmr_id
    ]
  )
  
  bg_feature_ids <- unique(
    background_dt[
      grepl(feature_pattern, annot_type, ignore.case = TRUE),
      bg_id
    ]
  )
  
  a <- length(dmr_feature_ids)
  b <- total_dmrs - a
  c <- length(bg_feature_ids)
  d <- total_background - c
  
  fisher_res <- fisher.test(
    matrix(c(a, b, c, d), nrow = 2)
  )
  
  data.frame(
    Feature = feature_name,
    Odds_ratio = as.numeric(fisher_res$estimate),
    p_value = fisher_res$p.value
  )
}

dmr_enrichment_or <- rbind(
  get_enrichment("CpG islands", "island|cpg"),
  get_enrichment("Promoters", "promoter")
)

dmr_enrichment_or$label <- paste0(
  "OR = ",
  round(dmr_enrichment_or$Odds_ratio, 2),
  "\n",
  "p = ",
  signif(dmr_enrichment_or$p_value, 3)
)

png("odds_ration_enrichment.png", width=800, height=600)
ggplot(
  dmr_enrichment_or,
  aes(
    x = Feature,
    y = Odds_ratio,
    fill = Feature
  )
) +
  geom_col(
    width = 0.65,
    color = "black",
    linewidth = 0.4,
    show.legend = FALSE
  ) +
  geom_hline(
    yintercept = 1,
    linetype = "dashed",
    color = "black"
  ) +
  geom_text(
    aes(label = label),
    vjust = -0.4,
    size = 4
  ) +
  scale_fill_manual(values = c(
    "CpG islands" = "#F07167",
    "Promoters" = "#4DBBD5"
  )) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.12))
  ) +
  labs(
    title = "Enrichment of DMRs in Promoters and CpG Islands",
    x = "Annotation category",
    y = "Odds ratio"
  ) +
  theme_bw(base_size = 13) +
  theme(
    aspect.ratio = 0.65,
    axis.text.x = element_text(hjust = 0.5),
    plot.title = element_text(hjust = 0.5, face = "bold")
  )
dev.off()

# 5:
# Heatmap 1: Top DMCs

top_dmcs <- dml_dt[
  fdr < 0.05 & abs(diff) >= 0.10
][order(fdr)][1:30]

top_dmc_ids <- paste(top_dmcs$chr, top_dmcs$pos, sep = ":")

meth_mat <- getMeth(BS_filtered, type = "raw")
rownames(meth_mat) <- paste(seqnames(BS_filtered), start(BS_filtered), sep = ":")

top_dmc_mat <- meth_mat[top_dmc_ids, ]

annotation_col <- data.frame(
  Condition = c("Non-tumour", "Non-tumour", "Tumour", "Tumour")
)
rownames(annotation_col) <- sampleNames(BS_filtered)

png("heatmap_for_DMC.png", width=1000, height=600)
pheatmap(
  top_dmc_mat,
  annotation_col = annotation_col,
  scale = "row",
  clustering_distance_rows = "euclidean",
  clustering_distance_cols = "euclidean",
  clustering_method = "complete",
  main = "Top 30 DMCs",
  fontsize = 11,
  fontsize_row = 8,
  fontsize_col = 10,
  border_color = "grey80",
  linewidths = 0.4,
  angle_col = 0,
  color = colorRampPalette(c(
    "#4DBBD5",
    "white",
    "#F07167"
  ))(100)
)
dev.off()

# Heatmap 2: Top DMRs

top_dmrs <- dmr_dt[
  order(abs(areaStat), decreasing = TRUE)
][1:30]

dmr_meth_matrix <- matrix(
  NA,
  nrow = nrow(top_dmrs),
  ncol = length(sampleNames(BS_filtered))
)

rownames(dmr_meth_matrix) <- paste0(
  top_dmrs$chr, ":", top_dmrs$start, "-", top_dmrs$end
)
colnames(dmr_meth_matrix) <- sampleNames(BS_filtered)

for (i in seq_len(nrow(top_dmrs))) {
  
  region_gr <- GRanges(
    seqnames = top_dmrs$chr[i],
    ranges = IRanges(
      start = top_dmrs$start[i],
      end = top_dmrs$end[i]
    )
  )
  
  cpg_gr <- granges(BS_filtered)
  hits <- findOverlaps(cpg_gr, region_gr)
  
  if (length(hits) > 0) {
    
    region_meth <- meth_mat[
      queryHits(hits),
      ,
      drop = FALSE
    ]
    
    dmr_meth_matrix[i, ] <- colMeans(
      region_meth,
      na.rm = TRUE
    )
  }
}

png("heatmap_for_DMR.png", width=1000, height=600)
pheatmap(
  dmr_meth_matrix,
  annotation_col = annotation_col,
  scale = "row",
  clustering_distance_rows = "euclidean",
  clustering_distance_cols = "euclidean",
  clustering_method = "complete",
  main = "Top 30 DMRs",
  fontsize = 11,
  fontsize_row = 8,
  fontsize_col = 10,
  border_color = "grey80",
  linewidths = 0.4,
  angle_col = 0,
  color = colorRampPalette(c(
    "#4DBBD5",
    "white",
    "#F07167"
  ))(100)
)
dev.off()

# Biological interpretation:
# 1:
library(data.table)
library(dplyr)
library(GenomicRanges)
library(IRanges)
library(annotatr)
library(clusterProfiler)
library(org.Hs.eg.db)
library(enrichplot)
library(ggplot2)
library(knitr)

# Input data

# Required objects:
# dmcs_fdr_delta
# dmr2_dt
# DMC filtering:
# FDR < 0.05
# abs(diff) >= 0.10
# DMR filtering:
# minCG = 5
# minlen = 100
# p.threshold = 0.01

# Convert to data.table

setDT(dmcs_fdr_delta)
setDT(dmr2_dt)

# Define methylation direction
# DSS convention:
# diff = non_tumor - tumor
# diff < 0:
# tumor has higher methylation
# = hypermethylated in tumor
# diff > 0:
# tumor has lower methylation
# = hypomethylated in tumor

dmcs_fdr_delta[, methylation_direction := fifelse(
diff < 0,
"Hypermethylated in tumor",
"Hypomethylated in tumor"
)]

# Build annotations

annotations <- build_annotations(
genome = "hg38",
annotations = c(
"hg38_genes_promoters",
"hg38_genes_exons",
"hg38_genes_introns",
"hg38_genes_intergenic"
)
)

# Create GRanges objects

dmc_gr <- GRanges(
seqnames = dmcs_fdr_delta$chr,
ranges = IRanges(
start = dmcs_fdr_delta$pos,
width = 1
)
)

dmr_gr <- GRanges(
seqnames = dmr2_dt$chr,
ranges = IRanges(
start = dmr2_dt$start,
end = dmr2_dt$end
)
)

# Annotate DMCs and DMRs

cat("Annotating DMCs...\n")

annotated_dmcs <- annotate_regions(
regions = dmc_gr,
annotations = annotations,
ignore.strand = TRUE,
quiet = TRUE
)

cat("Annotating DMRs...\n")

annotated_dmrs <- annotate_regions(
regions = dmr_gr,
annotations = annotations,
ignore.strand = TRUE,
quiet = TRUE
)

# Convert to data.frame

dmc_annot_df <- as.data.frame(annotated_dmcs)
dmr_annot_df <- as.data.frame(annotated_dmrs)

# Add DMC methylation direction

dmcs_fdr_delta[, DMC_id := paste(chr, pos, sep = "_")]

dmc_annot_df$DMC_id <- paste(
dmc_annot_df$seqnames,
dmc_annot_df$start,
sep = "_"
)

dmc_annot_df <- left_join(
dmc_annot_df,
as.data.frame(dmcs_fdr_delta)[,
c("DMC_id", "methylation_direction")
],
by = "DMC_id"
)

# Extract gene symbols safely

extract_gene_symbols <- function(annotation_df) {

possible_gene_cols <- c(
"annot.symbol",
"symbol",
"gene_name",
"gene_symbol",
"external_gene_name"
)

gene_col <- possible_gene_cols[
possible_gene_cols %in% names(annotation_df)
][1]

if (is.na(gene_col)) {
stop("No gene symbol column found.")
}

genes <- annotation_df[[gene_col]]

genes <- genes[!is.na(genes)]
genes <- genes[genes != ""]
genes <- unique(genes)

return(genes)
}

# Generate gene sets

# All DMC genes

all_dmc_genes <- extract_gene_symbols(
dmc_annot_df
)

# Hypermethylated DMC genes

hyper_dmc_genes <- extract_gene_symbols(
dmc_annot_df %>%
filter(
methylation_direction ==
"Hypermethylated in tumor"
)
)

# Hypomethylated DMC genes

hypo_dmc_genes <- extract_gene_symbols(
dmc_annot_df %>%
filter(
methylation_direction ==
"Hypomethylated in tumor"
)
)

# All DMR genes

all_dmr_genes <- extract_gene_symbols(
dmr_annot_df
)

# Promoter-associated DMR genes

promoter_dmr_genes <- extract_gene_symbols(
dmr_annot_df %>%
filter(
grepl(
"promoter",
annot.type,
ignore.case = TRUE
)
)
)

# Gene count summary

gene_summary <- data.frame(
Gene_Set = c(
"All DMC genes",
"Hypermethylated DMC genes",
"Hypomethylated DMC genes",
"All DMR genes",
"Promoter DMR genes"
),
Gene_Count = c(
length(all_dmc_genes),
length(hyper_dmc_genes),
length(hypo_dmc_genes),
length(all_dmr_genes),
length(promoter_dmr_genes)
)
)

print(
kable(
gene_summary,
caption = "Gene counts before Entrez conversion"
)
)
#Table: Gene counts before Entrez conversion

#|Gene_Set                  | Gene_Count|
#|:-------------------------|----------:|
#|All DMC genes             |        376|
#|Hypermethylated DMC genes |         95|
#|Hypomethylated DMC genes  |        319|
#|All DMR genes             |         34|
#|Promoter DMR genes        |          3|

# Convert gene symbols to Entrez IDs

convert_to_entrez <- function(
  gene_symbols,
  label = "Gene set"
) {

  gene_symbols <- unique(gene_symbols)

  gene_symbols <- gene_symbols[
    !is.na(gene_symbols)
  ]

  gene_symbols <- gene_symbols[
    gene_symbols != ""
  ]

  if (length(gene_symbols) < 1) {

    cat(
      label,
      "contains no valid genes.\n"
    )

    return(character(0))
  }

  converted <- suppressMessages(

    bitr(
      gene_symbols,
      fromType = "SYMBOL",
      toType = "ENTREZID",
      OrgDb = org.Hs.eg.db
    )
  )

  converted <- unique(converted)

  cat("\n")
  cat("==============================\n")
  cat(label, "\n")

  cat(
    "Input genes:",
    length(gene_symbols),
    "\n"
  )

  cat(
    "Mapped Entrez IDs:",
    nrow(converted),
    "\n"
  )

  cat(
    "Lost genes:",
    length(gene_symbols) - nrow(converted),
    "\n"
  )

  cat("==============================\n")

  return(
    unique(converted$ENTREZID)
  )
}

# Convert all gene sets

all_dmc_entrez <- convert_to_entrez(
all_dmc_genes,
"All DMC genes"
)
#All DMC genes 
#Input genes: 376 
#Mapped Entrez IDs: 376 
#Lost genes: 0 

hyper_dmc_entrez <- convert_to_entrez(
hyper_dmc_genes,
"Hyper DMC genes"
)
#Hyper DMC genes 
#Input genes: 95 
#Mapped Entrez IDs: 95 
#Lost genes: 0 

hypo_dmc_entrez <- convert_to_entrez(
hypo_dmc_genes,
"Hypo DMC genes"
)
#Hypo DMC genes 
#Input genes: 319 
#Mapped Entrez IDs: 319 
#Lost genes: 0 

all_dmr_entrez <- convert_to_entrez(
all_dmr_genes,
"All DMR genes"
)
#All DMR genes 
#Input genes: 34 
#Mapped Entrez IDs: 34 
#Lost genes: 0 

promoter_dmr_entrez <- convert_to_entrez(
promoter_dmr_genes,
"Promoter DMR genes"
)
#Promoter DMR genes 
#Input genes: 3 
#Mapped Entrez IDs: 3 
#Lost genes: 0 

# GO enrichment function

run_go_enrichment <- function(entrez_genes) {

if (length(entrez_genes) < 10) {

message(
  "Too few genes for stable GO enrichment: ",
  length(entrez_genes)
)

return(NULL)

}

enrichGO(
gene = entrez_genes,
OrgDb = org.Hs.eg.db,
keyType = "ENTREZID",
ont = "BP",
pAdjustMethod = "BH",
pvalueCutoff = 0.05,
qvalueCutoff = 0.20,
readable = TRUE
)
}

# KEGG enrichment function

run_kegg_enrichment <- function(entrez_genes) {

if (length(entrez_genes) < 10) {

message(
  "Too few genes for stable KEGG enrichment: ",
  length(entrez_genes)
)

return(NULL)

}

enrichKEGG(
gene = entrez_genes,
organism = "hsa",
pvalueCutoff = 0.05,
pAdjustMethod = "BH"
)
}

# Run GO enrichment

cat("\nRunning GO enrichment...\n")

GO_all_dmc <- run_go_enrichment(
all_dmc_entrez
)

GO_hyper_dmc <- run_go_enrichment(
hyper_dmc_entrez
)

GO_hypo_dmc <- run_go_enrichment(
hypo_dmc_entrez
)

GO_all_dmr <- run_go_enrichment(
all_dmr_entrez
)

GO_promoter_dmr <- run_go_enrichment(
promoter_dmr_entrez
)

# Run KEGG enrichment

cat("\nRunning KEGG enrichment...\n")

KEGG_all_dmc <- run_kegg_enrichment(
all_dmc_entrez
)

KEGG_hyper_dmc <- run_kegg_enrichment(
hyper_dmc_entrez
)

KEGG_hypo_dmc <- run_kegg_enrichment(
hypo_dmc_entrez
)

KEGG_all_dmr <- run_kegg_enrichment(
all_dmr_entrez
)

KEGG_promoter_dmr <- run_kegg_enrichment(
promoter_dmr_entrez
)
# Too few genes for stable KEGG enrichment: 3

# Count enrichment terms

count_terms <- function(enrichment_result) {

if (is.null(enrichment_result)) {
return(0)
}

enrichment_df <- as.data.frame(
enrichment_result
)

if (nrow(enrichment_df) == 0) {
return(0)
}

return(
nrow(enrichment_df)
)
}

# Enrichment summary

enrichment_summary <- data.frame(
Analysis = c(
"All DMC genes",
"Hypermethylated DMC genes",
"Hypomethylated DMC genes",
"All DMR genes",
"Promoter DMR genes"
),

GO_BP_Terms = c(
count_terms(GO_all_dmc),
count_terms(GO_hyper_dmc),
count_terms(GO_hypo_dmc),
count_terms(GO_all_dmr),
count_terms(GO_promoter_dmr)
),

KEGG_Pathways = c(
count_terms(KEGG_all_dmc),
count_terms(KEGG_hyper_dmc),
count_terms(KEGG_hypo_dmc),
count_terms(KEGG_all_dmr),
count_terms(KEGG_promoter_dmr)
)
)

print(
knitr::kable(
enrichment_summary,
caption = "Summary of enrichment results"
)
)
#Table: Summary of enrichment results

#|Analysis                  | GO_BP_Terms| KEGG_Pathways|
#|:-------------------------|-----------:|-------------:|
#|All DMC genes             |           2|             0|
#|Hypermethylated DMC genes |           0|             0|
#|Hypomethylated DMC genes  |           3|             0|
#|All DMR genes             |           0|             0|
#|Promoter DMR genes        |           0|             0|

# Display enrichment tables

show_top_table <- function(enrichment_object, caption_text, n = 10) {

if (is.null(enrichment_object)) {
message("No enrichment object: ", caption_text)
return(invisible(NULL))
}

enrichment_df <- as.data.frame(enrichment_object)

if (nrow(enrichment_df) == 0) {
message("Empty enrichment: ", caption_text)
return(invisible(NULL))
}

print(
knitr::kable(
head(enrichment_df, n),
caption = caption_text
)
)
}

# Show GO enrichment tables

show_top_table(
GO_all_dmc,
"GO enrichment: all DMC genes"
)
#Table: GO enrichment: all DMC genes

#|           |ID         |Description                    |GeneRatio |BgRatio   |  pvalue|  p.adjust|    qvalue|geneID                                                                                                           | Count|
#|:----------|:----------|:------------------------------|:---------|:---------|-------:|---------:|---------:|:----------------------------------------------------------------------------------------------------------------|-----:|
#|GO:0042742 |GO:0042742 |defense response to bacterium  |17/225    |330/18870 | 5.0e-07| 0.0013624| 0.0013402|DEFB128/DEFB129/DEFB119/DEFB121/DEFB124/BPIFA2/BPIFA1/BPI/PI3/SEMG1/SEMG2/WFDC2/EPPIN/WFDC10A/WFDC9/WFDC11/ZNFX1 |    17|
#|GO:0019731 |GO:0019731 |antibacterial humoral response |8/225     |70/18870  | 1.8e-06| 0.0025219| 0.0024809|BPIFA1/PI3/SEMG1/SEMG2/WFDC2/WFDC10A/WFDC9/WFDC11          

show_top_table(
GO_hyper_dmc,
"GO enrichment: hypermethylated DMC genes"
)
# Empty enrichment: GO enrichment: hypermethylated DMC genes

show_top_table(
GO_hypo_dmc,
"GO enrichment: hypomethylated DMC genes"
)
#Table: GO enrichment: hypomethylated DMC genes

#|           |ID         |Description                    |GeneRatio |BgRatio   |   pvalue|  p.adjust|    qvalue|geneID                                                                                                     | Count|
#|:----------|:----------|:------------------------------|:---------|:---------|--------:|---------:|---------:|:----------------------------------------------------------------------------------------------------------|-----:|
#|GO:0042742 |GO:0042742 |defense response to bacterium  |16/176    |330/18870 | 1.00e-07| 0.0002086| 0.0002042|DEFB128/DEFB129/DEFB119/DEFB121/DEFB124/BPIFA2/BPIFA1/BPI/PI3/SEMG1/SEMG2/WFDC2/EPPIN/WFDC10A/WFDC9/WFDC11 |    16|
#|GO:0019731 |GO:0019731 |antibacterial humoral response |8/176     |70/18870  | 3.00e-07| 0.0003438| 0.0003366|BPIFA1/PI3/SEMG1/SEMG2/WFDC2/WFDC10A/WFDC9/WFDC11                                                          |     8|
#|GO:0019730 |GO:0019730 |antimicrobial humoral response |8/176     |133/18870 | 3.55e-05| 0.0289120| 0.0283018|BPIFA1/PI3/SEMG1/SEMG2/WFDC2/WFDC10A/WFDC9/WFDC11      

show_top_table(
GO_all_dmr,
"GO enrichment: all DMR genes"
)
# Empty enrichment: GO enrichment: all DMR genes

show_top_table(
GO_promoter_dmr,
"GO enrichment: promoter-associated DMR genes"
)
# No enrichment object: GO enrichment: promoter-associated DMR genes

# Plot enrichment safely

plot_enrichment <- function(enrichment_object,
                            title_text,
                            show_n = 10) {

  # Handle NULL enrichment
  if (is.null(enrichment_object)) {
    message("No enrichment object: ", title_text)
    return(NULL)
  }

  df <- as.data.frame(enrichment_object)

  # Handle empty enrichment results
  if (is.null(df) || nrow(df) == 0) {
    message("No enriched terms: ", title_text)
    return(NULL)
  }

  # Create plot
  p <- enrichplot::dotplot(enrichment_object, showCategory = show_n) +
    ggplot2::ggtitle(title_text)

  print(p)

  return(p)
}

p1 <- plot_enrichment(
  GO_all_dmc,
  "GO enrichment: all DMC genes",
  10
)

if (!is.null(p1)) {
  ggsave("GO_enrichment_all_DMC.png", p1, width = 8, height = 6)
}


p2 <- plot_enrichment(
  GO_hyper_dmc,
  "GO enrichment: hypermethylated DMC genes",
  10
)

if (!is.null(p2)) {
  ggsave("GO_enrichment_hyper_DMC.png", p2, width = 8, height = 6)
}
# No enriched terms: GO enrichment: hypermethylated DMC genes

p3 <- plot_enrichment(
  GO_hypo_dmc,
  "GO enrichment: hypomethylated DMC genes",
  10
)

if (!is.null(p3)) {
  ggsave("GO_enrichment_hypo_DMC.png", p3, width = 8, height = 6)
}

p4 <- plot_enrichment(
  GO_all_dmr,
  "GO enrichment: all DMR genes",
  10
)

if (!is.null(p4)) {
  ggsave("GO_enrichment_all_DMR.png", p4, width = 8, height = 6)
}
# No enriched terms: GO enrichment: all DMR genes

p5 <- plot_enrichment(
  GO_promoter_dmr,
  "GO enrichment: promoter-associated DMR genes",
  10
)

if (!is.null(p5)) {
  ggsave("GO_enrichment_promoter_DMR.png", p5, width = 8, height = 6)
}
# No enrichment object: GO enrichment: promoter-associated DMR genes

k1 <- plot_enrichment(
  KEGG_all_dmc,
  "KEGG enrichment: all DMC genes",
  10
)

if (!is.null(k1)) {
  ggsave("KEGG_enrichment_all_DMC.png", k1, width = 8, height = 6)
}
# No enriched terms: KEGG enrichment: all DMC genes


k2 <- plot_enrichment(
  KEGG_hyper_dmc,
  "KEGG enrichment: hypermethylated DMC genes",
  10
)

if (!is.null(k2)) {
  ggsave("KEGG_enrichment_hyper_DMC.png", k2, width = 8, height = 6)
}
# No enriched terms: KEGG enrichment: hypermethylated DMC genes

k3 <- plot_enrichment(
  KEGG_hypo_dmc,
  "KEGG enrichment: hypomethylated DMC genes",
  10
)

if (!is.null(k3)) {
  ggsave("KEGG_enrichment_hypo_DMC.png", k3, width = 8, height = 6)
}
# No enriched terms: KEGG enrichment: hypomethylated DMC genes

k4 <- plot_enrichment(
  KEGG_all_dmr,
  "KEGG enrichment: all DMR genes",
  10
)

if (!is.null(k4)) {
  ggsave("KEGG_enrichment_all_DMR.png", k4, width = 8, height = 6)
}
# No enriched terms: KEGG enrichment: all DMR genes

k5 <- plot_enrichment(
  KEGG_promoter_dmr,
  "KEGG enrichment: promoter-associated DMR genes",
  10
)

if (!is.null(k5)) {
  ggsave("KEGG_enrichment_promoter_DMR.png", k5, width = 8, height = 6)
}
# No enrichment object: KEGG enrichment: promoter-associated DMR genes
