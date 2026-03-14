# lex-conceptual-metaphor

A LegionIO cognitive architecture extension implementing Lakoff & Johnson's conceptual metaphor theory. Abstractions are understood through structured mappings from concrete source domains to abstract target domains — "ARGUMENT IS WAR", "TIME IS MONEY", "MIND IS A CONTAINER". Metaphors that are used repeatedly become conventional; rarely-used metaphors remain novel or creative.

## What It Does

Manages a registry of **metaphors** — each a typed source-to-target domain mapping with explicit concept pairings, entailments (inferences the metaphor licenses), strength, and a conventionality score.

- **Structural metaphors** map relational structure from one domain to another (ARGUMENT IS WAR)
- **Orientational metaphors** organize concepts in terms of spatial orientation (MORE IS UP)
- **Ontological metaphors** treat abstract processes as entities (THE MIND IS A MACHINE)

Metaphor strength increases with use and decreases through periodic decay. Conventionality tracks how automatic a metaphor has become — dead metaphors (conventionality >= 0.7) operate without conscious awareness; creative metaphors (conventionality < 0.2) are fresh and attention-demanding.

## Usage

```ruby
require 'lex-conceptual-metaphor'

client = Legion::Extensions::ConceptualMetaphor::Client.new

# Create a structural metaphor: ARGUMENT IS WAR
result = client.create_metaphor(
  source_domain:   :war,
  target_domain:   :argument,
  metaphor_type:   :structural,
  mappings:        { soldier: :debater, weapon: :evidence, victory: :agreement },
  strength:        0.6,
  conventionality: 0.8
)
# => { success: true, metaphor_id: "uuid...", source_domain: :war,
#      target_domain: :argument, metaphor_type: :structural,
#      strength: 0.6, conventionality: 0.8 }

metaphor_id = result[:metaphor_id]

# Apply the metaphor to map a source concept to the target domain
client.apply_metaphor(metaphor_id: metaphor_id, source_concept: :soldier)
# => { success: true, found: true, mapped: true,
#      source_concept: :soldier, target_concept: :debater,
#      strength: 0.7, metaphor_id: "uuid..." }

# Add an entailment — an inference licensed by the mapping
client.add_metaphor_entailment(
  metaphor_id: metaphor_id,
  entailment:  'arguments can be won or lost'
)
# => { success: true, metaphor_id: "uuid...", entailment_count: 1 }

# Find all metaphors involving a domain
client.find_metaphors_for(domain: :argument)
# => { success: true, domain: :argument, metaphors: [...], count: 1 }

# Retrieve conventional vs. novel metaphors
client.conventional_metaphors
client.novel_metaphors

# Top metaphors by strength
client.strongest_metaphors(limit: 5)

# Periodic maintenance: decay strength, prune very weak metaphors (strength <= 0.05)
client.update_conceptual_metaphor
# => { success: true, pruned: 0 }

# Engine statistics
client.conceptual_metaphor_stats
# => { success: true, total_metaphors: 1, total_domains: 2,
#      conventional_count: 1, novel_count: 0, domains: [:war, :argument],
#      type_counts: { structural: 1 } }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
