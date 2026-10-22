# AOPMapper supplementary data

LLM-extracted Key Event Components and assay descriptions for AOP-Wiki, with cross-model consensus and schema-valid XML exports.

Zenodo record: <https://doi.org/10.5281/zenodo.23554426>

Source knowledge base: AOP-Wiki, <https://aopwiki.org>

Methods2AOP (the recommendation for per-assay metadata on which the proposed assay XML schema is based): <https://f1000research.com/articles/14-1375>

These data are used to enrich AOPMapper: <https://aop.adma.ai>

Code that generates all of it: <https://github.com/ideaconsult/aopmapper-curation>

Browsable consensus views (GitHub Pages): open `index.html`, which links the KEC and assay consensus views, the XML exports (also rendered), the schemas and the stylesheets.

Supplementary data for "From AOP-Wiki to AOPMAPPER: trust-aware AI-assisted enrichment of Adverse Outcome Pathway knowledge".

Large language models extracted two kinds of knowledge from AOP-Wiki text: Key Event Components (KEC: object-process-action triples) and the experimental assays used to measure Key Events (extracted from the free-text measurement methodology; AOP-Wiki has no structured field for them). Their outputs were then compared and combined across models. The pipeline code is in the `aopmapper-curation` repository; the model outputs are archived here because they cannot be regenerated exactly - they depend on the specific model checkpoints, quantisations and serving stacks used.

## Archives

1. `aopmapper_20260401_kec116.zip` - the KEC116 pilot, a set of 116 Key Events (AOP-Wiki release 2026-04-01). One folder per model, each with the extracted triples (`kec.json`), the ontology grounding and IRI validation reports, the matching against the curated triples, the logprob calibration, a model summary and figures. `crossmodel/manuscript` holds the cross-model comparison, the SMAA ranking and the ensemble-selection variants used in the paper.
2. `aopmapper_20260701_KEC_ALL.zip` - the full corpus (AOP-Wiki release 2026-07-01). Ten model folders with the same per-model files as above. `crossmodel/manuscript` holds the consensus triples, the SMAA ranking, the ensemble selection (`default/pareto_smaa`), the consensus view (`viz_consensus.json` and `.html`) and the figures. `default/pareto_smaa/xml/` holds `kec_consensus.xml`, the KEC consensus export (clustered triples with support, models, confirmed / missed / novel status against the curated triples, and the per-model member triples), its HTML view and `xml_report.json`.
3. `aopmapper_20260701_ASSAYS.zip` - the assay extraction for the same ten models (release 2026-07-01). Each model folder has `assays.json` (the extracted assay records), `assays_errors.json`, `assays_logprobs.jsonl` (the raw model responses; by far the largest file), and the evidence-check, logprob-calibration and IRI-validation reports. `crossmodel/manuscript` holds the cross-model assay consensus, the SMAA ranking, the assay landscape, the KE coverage and near-duplicate summaries, the KEC-versus-assay consistency analysis and the figures.
4. `aopmapper_20260701_curated.zip` - the curated assay set derived from the consensus: Solr-ready assay documents, technique statistics, the technique-synonym resolution, and `xml/assays.xml`, the curated assays in the proposed assay schema (assays, techniques and a lookup section, with an optional extracted `kec-triple` per assay), plus its HTML view and the export report.

## XML, schemas and stylesheets

The curated assays and the KEC consensus are exported as XML (in the `xml/` folders of the archives). Both are validated against the XSD schemas, provided as separate files in the Zenodo record and in the `schemas/` folder of this repository:

- `methods2aop_schema_proposal.xsd` - the proposed assay schema, based on the Methods2AOP recommendation: a top-level `<assays>` container with techniques, assays and a lookup section, extending the AOP-Wiki XML (`aop-xml`) namespace.
- `kec_consensus_schema.xsd` - the cross-model KEC consensus.
- `assays.xsl` and `kec_consensus.xsl` - XSLT stylesheets that render the XML as HTML.

Following AOP-Wiki practice, objects carry UUIDs and stable numeric identifiers appear only in the lookup sections. The identifiers `ASSAY<n>` and `TECH<n>` are permanent. Both schemas use XSD 1.1, so validate with an XSD 1.1 validator, for example Python `xmlschema`.

## Format

Everything is JSON, JSONL, TSV, CSV, XML, HTML or PNG, and all of it is plain text except the PNG figures. The HTML files are self-contained views and need no server. Notebooks, logs, ontology caches and the parsed AOP-Wiki XML are not included.

## Models

The ten models used for the full corpus (folder names as in the archives):

- `BrainForge--Devstral-2-123B-Instruct-2512-NVFP4`
- `Qwen--Qwen3.6-27B`
- `google--gemma-3-27b-it`
- `google--gemma-4-26B-A4B-it`
- `ibm-granite--granite-4.0-h-small-FP8`
- `nvidia--NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4`
- `poolside--Laguna-S-2.1-NVFP4`
- `radm--Athene-V2-Chat-AWQ`
- `rdtand--Gemma4-31B-IT-PrismaQuant-5.5bit-vllm`
- `rdtand--Gemma4-31B-IT-PrismaQuant-6bit-vllm`

The full pilot panel of 72 models, with the criteria used for ranking and a `Selected` column marking these ten, is in `models/model_panel.tsv` (Table S1 of the paper).

Outputs reflect the checkpoints and settings used at the time and will not be reproduced exactly by a rerun.

## How to use

Start with the cross-model consensus files in `crossmodel/manuscript`. The paper's figures and numbers are generated from these files by `export_manuscript_results.py` with `env.manuscript.yaml` in the code repository.

## Data licensing

The full licence text is in the `LICENSE` file.

The data in this repository are made available under the Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) license.

The dataset contains structured information derived from Key Event (KE) and Key Event Relationship (KER) content from AOP-Wiki. AOP-Wiki KE and KER pages are licensed under CC BY-SA. AOP-Wiki is acknowledged as the source, and source identifiers and provenance are retained in the accompanying data.

The repository also contains structured annotations and analytical results generated in this study, including LLM-assisted extractions, logprobe results, and calculated statistics. These are released as part of this data release under the terms stated above, to the extent that the project has the rights to do so.

Where third-party material is incorporated into the dataset and is subject to separate licensing or attribution requirements, those requirements remain applicable. See `provenance.json` for source and transformation information.

The software used to generate the dataset is maintained in a separate repository and is licensed under the GNU Affero General Public License v3.0 or later (AGPL-3.0-or-later).
