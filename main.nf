#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// -------------------------
// Process definitions
// -------------------------
process fastp {
    input:
      path fq
    output:
      path 'fastp_output.fastq.gz'
    script:
    """
    fastp -i ${fq} -o fastp_output.fastq.gz
    """
}

process spades {
    input:
      path fq
    output:
      path 'spades_contigs.fasta'
    script:
    """
    spades.py --only-assembler -s ${fq} -o spades_out
    cp spades_out/contigs.fasta spades_contigs.fasta
    """
}

process seqkit {
    input:
      path fq
    output:
      stdout
    script:
    """
    seqkit stats ${fq}
    """
}

// -------------------------
// Workflow wiring
// -------------------------
workflow {
    // 1) Define input channel
    ch_fastq = Channel.fromPath('data/test.fastq.gz')

    // 2) Run fastp
    processed = fastp(ch_fastq)

    // 3) Run spades & seqkit in parallel
    assembly = spades(processed)
    metrics  = seqkit(processed)

    // 4) Print outputs
    assembly.view { file -> println "Assembly file: ${file}" }
    metrics.view  { stats -> println "Seqkit stats:\n${stats}" }
}
