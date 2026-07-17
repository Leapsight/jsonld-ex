# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and
[Keep a CHANGELOG](http://keepachangelog.com).


## Unreleased (Leapsight fork)

### Fixed

- JSON-LD Framing: fixed an O(n²) performance issue in blank-node-identifier
  pruning (`JSON.LD.Framing.prune_blank_node_identifiers/2`). Previously, for
  every blank node occurring exactly once in the framed result, the pruner
  re-scanned the *entire* result tree to determine whether that blank node's
  id was required by a `@type: @id` property. Any input with many
  single-occurrence blank nodes — e.g. one embedded/nested object per row in
  a multi-row result — paid a cost proportional to `blank_nodes × tree_size`,
  making `frame/2` scale quadratically with row count instead of linearly.
  The check now runs as a single O(n) pass that collects every id needed by
  an `@type: @id` property up front, then does an O(1) lookup per candidate
  blank node.

- JSON-LD Framing: fixed incorrect compaction of `@default` values used to
  fill in a missing property during framing (e.g.
  `"url": {"@default": {"@type": "schema:URL", "@value": "..."}}}`). Two
  compounding bugs: (1) `JSON.LD.Expansion` never recursively expanded a
  map-shaped `@default` value, so nested `@type`/`@id` CURIEs were never
  resolved to full IRIs; (2) `JSON.LD.Framing.merge_framing_keywords/2`
  unconditionally overwrote `@default` in the expanded frame with the raw,
  unexpanded value from the original frame, which would have silently
  undone fix (1) on its own. The injected default now compacts using its
  proper term (e.g. `url`) and, where the term has matching `@type`
  coercion, simplifies to a bare literal — instead of falling back to a
  generic CURIE key with an uncompacted value object.

### Changed

- Pulled forward three warning-cleanup commits from upstream
  `rdf-elixir/jsonld-ex` (`62ced20` "Fix warnings under Elixir v1.19",
  `b65b16c` "Fix Credo warning", `d6abca7` "Fix warnings under Elixir
  v1.20"): a `mix.exs` migration off the deprecated `:preferred_cli_env`
  project key to `def cli/0`, and Elixir 1.19/1.20 type-checker fixes in
  `context.ex`, `context/term_definition.ex`, `compaction.ex`, and
  `iri_expansion.ex` (the latter two reapplied by hand, since this fork's
  versions of those files have diverged substantially from upstream to
  support Framing). No upstream Framing code was pulled in — upstream has
  no Framing implementation to sync from; this fork's Framing engine is
  original work. `json_ld` now compiles with zero warnings under Elixir
  1.19.4/OTP 28 (`mix compile --warnings-as-errors`).


## 1.0.0 - 2025-04-09

This version upgrades the implementation to support JSON-LD 1.1.

The functions on the top level `JSON.LD` module now behave fully-conformant with the API 
functions of the JsonLdProcessor interface as specified in the spec by supporting also
references to remote documents and contexts to be used as input. 

Note: This also adapts the more strict remote document handling to reject results 
with invalid content-types as specified with an error.  

Elixir versions < 1.15 and OTP version < 25 are no longer supported

### Added

- `JSON.LD.to_rdf/2` and `JSON.LD.from_rdf/2` delegator functions to complete the 
  JsonLdProcessor API interface
- Support for custom Tesla-based HTTP clients

### Changed

- Switched from HTTPoison to Tesla HTTP client, which means you should now configure 
  a respective adapter in your application config.
- Extracted the default remote document loading into general `JSON.LD.DocumentLoader.RemoteDocument.load/3` 
  function for better reuse in a custom `JSON.LD.DocumentLoader` implementations
- Unified error handling under a single `JSON.LD.Error` exception with dedicated error
  creation functions for all error types from the JSON-LD spec, making it easier for users
  to catch and handle errors and being more close to the spec

[Compare v0.3.9...v1.0.0](https://github.com/rdf-elixir/jsonld-ex/compare/v0.3.9...v1.0.0)



## 0.3.9 - 2024-08-07

This version is just upgraded to RDF.ex 2.0.

Elixir versions < 1.13 and OTP version < 23 are no longer supported

[Compare v0.3.8...v0.3.9](https://github.com/rdf-elixir/jsonld-ex/compare/v0.3.8...v0.3.9)



## 0.3.8 - 2023-12-18

### Added

- Support for httpoison 2.0 ([@maennchen](https://github.com/maennchen))

[Compare v0.3.7...v0.3.8](https://github.com/rdf-elixir/jsonld-ex/compare/v0.3.7...v0.3.8)



## 0.3.7 - 2023-01-23

### Added

- Support Link header when fetching remote contexts ([@cheerfulstoic](https://github.com/cheerfulstoic))

[Compare v0.3.6...v0.3.7](https://github.com/rdf-elixir/jsonld-ex/compare/v0.3.6...v0.3.7)



## 0.3.6 - 2022-11-03

This version is just upgraded to RDF.ex 1.0.

Elixir versions < 1.11 are no longer supported

[Compare v0.3.5...v0.3.6](https://github.com/rdf-elixir/jsonld-ex/compare/v0.3.5...v0.3.6)



## 0.3.5 - 2022-04-26

### Added

- the `JSON.LD.Encoder` now supports implicit compaction by providing a context
  as a map, a `RDF.PropertyMap` or a URL string for a remote context with the 
  new `:context` option

### Changed

- context maps can be given now with atom keys or as a `RDF.PropertyMap` to
  `JSON.LD.context/2` and `JSON.LD.compact/3`
- the base IRI of a `RDF.Graph` or the `RDF.default_base_iri/0` is used as the  
  default `:base` in the `JSON.LD.Encoder`
- `RDF.Vocabulary.Namespace` modules can be set as base IRI 


[Compare v0.3.4...v0.3.5](https://github.com/rdf-elixir/jsonld-ex/compare/v0.3.4...v0.3.5)



## 0.3.4 - 2021-12-13

Elixir versions < 1.10 are no longer supported

### Fixed

- remote contexts with a list couldn't be processed correctly (but failed with a `JSON.LD.InvalidLocalContextError`)

[Compare v0.3.3...v0.3.4](https://github.com/rdf-elixir/jsonld-ex/compare/v0.3.3...v0.3.4)



## 0.3.3 - 2020-10-13

This version mainly upgrades to RDF.ex 0.9.
 
### Added

- proper typespecs so that Dialyzer passes without warnings ([@rustra](https://github.com/rustra))

[Compare v0.3.2...v0.3.3](https://github.com/rdf-elixir/jsonld-ex/compare/v0.3.2...v0.3.3)



## 0.3.2 - 2020-06-19

### Added

Support for remote contexts ([@KokaKiwi](https://github.com/KokaKiwi) and [@rustra](https://github.com/rustra))

[Compare v0.3.1...v0.3.2](https://github.com/rdf-elixir/jsonld-ex/compare/v0.3.1...v0.3.2)



## 0.3.1 - 2020-06-01

This version just upgrades to RDF.ex 0.8. With that Elixir version < 1.8 are no longer supported.

[Compare v0.3.0...v0.3.1](https://github.com/rdf-elixir/jsonld-ex/compare/v0.3.0...v0.3.1)



## 0.3.0 - 2018-09-17

No significant changes. Just some adoptions to work with RDF.ex 0.5. 
But together with RDF.ex 0.5, Elixir versions < 1.6 are no longer supported.

[Compare v0.2.3...v0.3.0](https://github.com/rdf-elixir/jsonld-ex/compare/v0.2.3...v0.3.0)



## 0.2.3 - 2018-07-11

- Upgrade to Jason 1.1
- Pass options to `JSON.LD.Encoder.encode/2` and `JSON.LD.Encoder.encode!/2` 
  through to Jason; this allows to use the new Jason pretty printing options  

[Compare v0.2.2...v0.2.3](https://github.com/rdf-elixir/jsonld-ex/compare/v0.2.2...v0.2.3)



## 0.2.2 - 2018-03-17

### Added

- JSON-LD encoder can handle `RDF.Graph`s and `RDF.Description`s 

### Changed

- Use Jason instead of Poison for JSON encoding and decoding, since it's faster and more standard conform


[Compare v0.2.1...v0.2.2](https://github.com/rdf-elixir/jsonld-ex/compare/v0.2.1...v0.2.2)



## 0.2.1 - 2018-03-10

### Changed

- Upgrade to RDF.ex 0.4.0
- Fixed all warnings ([@talklittle](https://github.com/talklittle)) 


[Compare v0.2.0...v0.2.1](https://github.com/rdf-elixir/jsonld-ex/compare/v0.2.0...v0.2.1)



## 0.2.0 - 2017-08-24

### Changed

- Upgrade to RDF.ex 0.3.0


[Compare v0.1.1...v0.2.0](https://github.com/rdf-elixir/jsonld-ex/compare/v0.1.1...v0.2.0)



## 0.1.1 - 2017-08-06

### Changed

- Don't support Elixir versions < 1.5, since `URI.merge` is broken in earlier versions  


[Compare v0.1.0...v0.1.1](https://github.com/rdf-elixir/jsonld-ex/compare/v0.1.0...v0.1.1)



## 0.1.0 - 2017-06-25

Initial release
