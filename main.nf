ch_files = Channel.create()

Channel.fromPath("${params.vcf_dir}/*.vcf.gz")
    .toSortedList()
    .subscribe onNext: { items ->
        items.each { ch_files << it }
    },
    onComplete: { ch_files.close() }

ch_files2 = ch_files.take(params.file_count)

process vcf_header {
    label 'bcftools'
    publishDir "${params.outdir}", mode: 'copy'

    input:
    file(ingvcf) from ch_files2

    output:
    file("${ingvcf.simpleName}.head.txt") into ch_header_files

    script:
    if (params.delete_input)
    """
    bcftools view -h ${ingvcf} > ${ingvcf.simpleName}.head.txt
    
    # delete input file to save disk size
    rm ${ingvcf}
    """
    else
    """
    bcftools view -h ${ingvcf} > ${ingvcf.simpleName}.head.txt
    """
}
