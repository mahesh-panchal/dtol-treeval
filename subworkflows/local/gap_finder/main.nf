#!/usr/bin/env nextflow

//
// MODULE IMPORT BLOCK
//
include { SEQTK_CUTN        } from '../../../modules/nf-core/seqtk/cutn/main'
include { GAP_LENGTH        } from '../../../modules/local/gap/length/main'
include { TABIX_BGZIPTABIX  } from '../../../modules/nf-core/tabix/bgziptabix/main'

workflow GAP_FINDER {
    take:
    reference_tuple     // Channel: tuple [ val(meta), path(fasta) ]

    main:
    ch_versions     = Channel.empty()

    //
    // MODULE: GENERATES A GAP SUMMARY FILE
    //
    SEQTK_CUTN (
        reference_tuple
    )
    ch_versions     = ch_versions.mix( SEQTK_CUTN.out.versions )

    //
    // MODULE: ADD THE LENGTH OF GAP TO BED FILE - INPUT FOR PRETEXT MODULE
    //
    GAP_LENGTH (
        SEQTK_CUTN.out.bed
    )
    ch_versions     = ch_versions.mix( GAP_LENGTH.out.versions )

    //
    // MODULE: BGZIP AND TABIX THE GAP FILE
    //
    TABIX_BGZIPTABIX (
        SEQTK_CUTN.out.bed
    )
    ch_versions     = ch_versions.mix( TABIX_BGZIPTABIX.out.versions )

    emit:
    gap_file        = GAP_LENGTH.out.bedgraph
    gap_tabix       = TABIX_BGZIPTABIX.out.gz_csi
    versions        = ch_versions
}
