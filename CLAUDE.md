# lex-conceptual-metaphor

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-conceptual-metaphor`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::ConceptualMetaphor`

## Purpose

Implements Lakoff & Johnson's conceptual metaphor theory as a cognitive extension. Metaphors are structured mappings from a source domain to a target domain — "ARGUMENT IS WAR", "TIME IS MONEY", "MIND IS A CONTAINER". Each metaphor has typed mappings (source concepts -> target concepts), entailments (inferences the metaphor licenses), strength, and a conventionality score. Repeated use increases both strength and conventionality. Novel metaphors (low conventionality) are creative; dead metaphors (high conventionality) are automatic/invisible.

## Gem Info

- **Gemspec**: `lex-conceptual-metaphor.gemspec`
- **Require**: `lex-conceptual-metaphor`
- **Ruby**: >= 3.4
- **License**: MIT
- **Homepage**: https://github.com/LegionIO/lex-conceptual-metaphor

## File Structure

```
lib/legion/extensions/conceptual_metaphor/
  version.rb
  helpers/
    constants.rb          # Metaphor types, conventionality/strength labels, decay/boost constants
    metaphor.rb           # Metaphor class — one structured source->target mapping
    metaphor_engine.rb    # MetaphorEngine — registry with decay, prune, history
  runners/
    conceptual_metaphor.rb  # Runner module — public API
  client.rb
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `MAX_METAPHORS` | 200 | Evicts oldest-used when exceeded |
| `MAX_MAPPINGS` | 500 | Defined, not enforced |
| `MAX_DOMAINS` | 100 | Max unique domains tracked; oldest removed when exceeded |
| `MAX_HISTORY` | 300 | Ring buffer for event history |
| `DEFAULT_STRENGTH` | 0.5 | Starting strength and conventionality |
| `REINFORCEMENT_BOOST` | 0.1 | Strength increase per `use!` call |
| `DECAY_RATE` | 0.02 | Strength reduction per `decay!` call |
| `STALE_THRESHOLD` | 120 | Seconds since `last_used_at` before stale |
| `CONVENTIONALITY_THRESHOLD` | 0.7 | `conventional?` true when conventionality >= this |
| `NOVELTY_THRESHOLD` | 0.3 | `novel?` true when conventionality <= this |

`METAPHOR_TYPES`: `[:structural, :orientational, :ontological]`

Conventionality labels: `0.8+` = `:dead`, `0.6..0.8` = `:conventional`, `0.4..0.6` = `:familiar`, `0.2..0.4` = `:novel`, `< 0.2` = `:creative`

Strength labels: `0.8+` = `:dominant`, `0.6..0.8` = `:strong`, `0.4..0.6` = `:moderate`, `0.2..0.4` = `:weak`, `< 0.2` = `:fading`

## Key Classes

### `Helpers::Metaphor`

One structured source-to-target conceptual mapping.

- `use!` — increments `use_count`, updates `last_used_at`, increases strength by `REINFORCEMENT_BOOST`, increases conventionality by `REINFORCEMENT_BOOST * 0.5`
- `add_entailment(entailment)` — appends string/symbol to `@entailments` array
- `map_concept(source_concept)` — looks up `@mappings[source_concept]`; returns nil if not mapped
- `coverage` — ratio of non-nil mapping values to total mapping entries
- `conventional?` — conventionality >= 0.7; `novel?` — conventionality <= 0.3
- `decay!` — decreases strength by `DECAY_RATE`
- `stale?` — based on seconds since `last_used_at`
- Fields: `id` (UUID), `source_domain`, `target_domain`, `metaphor_type`, `mappings` (hash), `entailments` (array), `strength`, `conventionality`, `use_count`

### `Helpers::MetaphorEngine`

Registry with history and analytics.

- `create_metaphor(source_domain:, target_domain:, metaphor_type:, mappings:, strength:, conventionality:)` — evicts oldest-by-`last_used_at` when at `MAX_METAPHORS`; returns `{ success: false, reason: :invalid_metaphor_type }` for invalid type (before eviction check)
- `apply_metaphor(metaphor_id:, source_concept:)` — calls `use!` on the metaphor; returns `{ found: false }` or `{ found: true, mapped: false }` or `{ found: true, mapped: true, target_concept:, strength:, metaphor_id: }`
- `find_by_target(target_domain:)` / `find_by_source(source_domain:)` / `find_by_domain(domain:)` — filter collections
- `conventional_metaphors` / `novel_metaphors` / `strongest(limit:)` / `by_type(metaphor_type:)` — filter/sort
- `decay_all` — calls `decay!` on every metaphor
- `prune_weak` — deletes metaphors with `strength <= 0.05`; returns count removed

## Runners

Module: `Legion::Extensions::ConceptualMetaphor::Runners::ConceptualMetaphor`

| Runner | Key Args | Returns |
|---|---|---|
| `create_metaphor` | `source_domain:`, `target_domain:`, `metaphor_type:`, `mappings:`, `strength:`, `conventionality:` | `{ success:, metaphor_id:, source_domain:, target_domain:, metaphor_type:, strength:, conventionality: }` or error |
| `apply_metaphor` | `metaphor_id:`, `source_concept:` | `{ success: true }` merged with engine result (`found:`, `mapped:`, `target_concept:`) |
| `add_metaphor_entailment` | `metaphor_id:`, `entailment:` | `{ success:, metaphor_id:, entailment_count: }` or error |
| `find_metaphors_for` | `domain:` | `{ success:, domain:, metaphors:, count: }` |
| `conventional_metaphors` | — | `{ success:, metaphors:, count: }` |
| `novel_metaphors` | — | `{ success:, metaphors:, count: }` |
| `strongest_metaphors` | `limit:` | `{ success:, metaphors:, count: }` |
| `metaphors_by_type` | `metaphor_type:` | `{ success:, metaphor_type:, metaphors:, count: }` |
| `update_conceptual_metaphor` | — | `{ success:, pruned: }` (runs decay_all + prune_weak) |
| `conceptual_metaphor_stats` | — | `{ success:, total_metaphors:, total_domains:, conventional_count:, novel_count:, history_count:, domains:, type_counts: }` |

No `engine:` injection keyword. Engine is a private memoized `@engine`.

## Integration Points

- No actors defined; `update_conceptual_metaphor` should be called periodically for decay + prune
- `apply_metaphor` is the cognitive inference operation — maps source concepts to target domain equivalents
- `conventional_metaphors` and `novel_metaphors` expose the spectrum from automatic to creative reasoning
- `add_metaphor_entailment` records licensed inferences that flow from the metaphor mapping
- All state is in-memory per `MetaphorEngine` instance

## Development Notes

- Invalid `metaphor_type` is caught at the runner level first (returns `{ success: false, error: :invalid_metaphor_type }`) and again at the engine level (returns `{ success: false, reason: :invalid_metaphor_type }`)
- `create_metaphor` at the runner level returns a compact hash (not the full metaphor `to_h`)
- `apply_metaphor` at the engine level returns an unconventional hash (not wrapped in `success:`) — the runner adds `success: true` via merge
- Prune threshold is `<= 0.05` (stricter than conceptual-blending's `< 0.1`)
- Domain registry uses a `Set` — max 100 domains, oldest removed when exceeded
- Metaphors are stored as a `Hash` (unlike conceptual-blending which also uses Hash) — eviction is LRU by `last_used_at`
