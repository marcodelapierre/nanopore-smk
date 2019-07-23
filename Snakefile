configfile: "config.yaml"


rule run_upstream:
 input: expand("{sample}_blast.tsv", sample=config['inputs']['read_dirs'])


rule run_upstream_diamond:
 input: expand("{sample}_diamond.tsv", sample=config['inputs']['read_dirs'])


rule run_align:
 input: expand("{sample}_aligned_{seqid}.bam", sample=config['inputs']['read_dirs'], seqid=config['inputs']['seqids'])


rule basecall:
 input: "{sample}"
 output: "{sample}_basecalled.fastq"
 params: outdir="{sample}_basecalled"
 shadow:  "minimal"
 threads: config['threads']['basecall']
 singularity: config['containers']['guppy']
 shell:
  "guppy_basecaller "
  "   -i {input} -s {params.outdir} "
  "   --recursive "
  "   --records_per_fastq 0 "
  "   -c dna_r9.4.1_450bps_hac.cfg "
  "   --qscore_filtering --min_score 7 "
  "   --num_callers 1 --cpu_threads_per_caller {threads} "
  "&& mv {params.outdir}/pass/fastq_runid_*.fastq {output} "


rule chop:
 input: "{sample}_basecalled.fastq"
 output: "{sample}_chopped.fastq"
 shadow:  "minimal"
 threads: config['threads']['chop']
 singularity: config['containers']['pomoxis']
 shell:
  "porechop "
  "   -i {input} -o {output} "
  "   --discard_middle -t {threads} "


rule assemble:
 input: "{sample}_chopped.fastq"
 output: "{sample}_denovo_subset.fa"
 params: outdir="denovo", prefix="denovo", min_len_contig=config['params']['min_len_contig']
 shadow:  "minimal"
 threads: config['threads']['default']
 singularity: config['containers']['pomoxis']
 shell:
  "mini_assemble "
  "   -i {input} -p {params.prefix} -o {params.outdir} "
  "   -c -t {threads} "
  "&& awk -v min_len_contig={params.min_len_contig} "
  "   '{{ if( substr($1,1,1) == \">\" ){{ skip=0 ; s=gensub(/LN:i:/,\"\",1,$2) ; if( (s-0) < min_len_contig ){{ skip=1 }}}} ; if( skip == 0 ){{print}} }}' "
  "   {params.outdir}/{params.prefix}_final.fa >{output} "


rule blast:
 input: "{sample}_denovo_subset.fa"
 output: "{sample}_blast.tsv"
 params: prefix="{sample}_blast", blast_db=config['params']['blast_db'], evalue=config['params']['evalue']
 shadow:  "minimal"
 threads: config['threads']['default']
 singularity: config['containers']['blast']
 shell:
  "blastn "
  "   -query {input} -db {params.blast_db} "
  "   -outfmt 11 -out {params.prefix}.asn "
  "   -evalue {params.evalue} "
  "   -num_threads {threads} "
  "&& blast_formatter "
  "   -archive {params.prefix}.asn "
  "   -outfmt 5 -out {params.prefix}.xml "
  "&& blast_formatter "
  "   -archive {params.prefix}.asn "
  "   -outfmt \"6 qaccver saccver pident length evalue bitscore stitle\" -out {params.prefix}_unsort.tsv "
  "&& sort -n -r -k 6 {params.prefix}_unsort.tsv >{output} "


rule diamond:
 input: "{sample}_denovo_subset.fa"
 output: "{sample}_diamond.tsv"
 params: prefix="{sample}_diamond", diamond_db=config['params']['diamond_db'], evalue=config['params']['evalue']
 shadow:  "minimal"
 threads: config['threads']['default']
 singularity: config['containers']['diamond']
 shell:
  "diamond blastx "
  "   -q {input} -d {params.diamond_db} "
  "   -f \"6 qseqid  sseqid  pident length evalue bitscore stitle\" -o {params.prefix}_unsort.tsv "
  "   --evalue {params.evalue} "
  "   -p {threads} "
  "&& sort -n -r -k 6 {params.prefix}_unsort.tsv >{output} "


rule seqfile:
 output: "refseq_{seqid}.fasta"
 params: seqid="{seqid}", blast_db=config['params']['blast_db']
 shadow:  "minimal"
 threads: config['threads']['default']
 singularity: config['containers']['blast']
 shell:
  "blastdbcmd "
  "   -db {params.blast_db} -entry {params.seqid} "
  "   -line_length 60 "
  "   -out {output} "
  "&& sed -i '/^>/ s/ .*//g' {output} "


rule align:
 input: chop="{sample}_chopped.fastq", seq="refseq_{seqid}.fasta"
 output: "{sample}_aligned_{seqid}.bam"
 params: prefix="{sample}_aligned_{seqid}"
 shadow:  "minimal"
 threads: config['threads']['default']
 singularity: config['containers']['pomoxis']
 shell:
  "mini_align "
  "   -i {input.chop} -r {input.seq} "
  "   -p {params.prefix} "
  "   -t ${threads} "

