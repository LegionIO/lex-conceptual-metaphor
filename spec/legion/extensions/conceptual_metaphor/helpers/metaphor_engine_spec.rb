# frozen_string_literal: true

RSpec.describe Legion::Extensions::ConceptualMetaphor::Helpers::MetaphorEngine do
  subject(:engine) { described_class.new }

  let(:metaphor) do
    engine.create_metaphor(
      source_domain: :money,
      target_domain: :time,
      metaphor_type: :structural,
      mappings:      { spend: :waste, save: :conserve }
    )
  end

  describe '#create_metaphor' do
    it 'creates and stores a metaphor' do
      result = metaphor
      expect(result).to be_a(Legion::Extensions::ConceptualMetaphor::Helpers::Metaphor)
      expect(result.source_domain).to eq(:money)
    end

    it 'rejects invalid metaphor types' do
      result = engine.create_metaphor(
        source_domain: :a, target_domain: :b,
        metaphor_type: :invalid, mappings: {}
      )
      expect(result[:success]).to be false
    end

    it 'records history' do
      metaphor
      expect(engine.history.size).to eq(1)
    end
  end

  describe '#apply_metaphor' do
    it 'maps a source concept to target' do
      result = engine.apply_metaphor(metaphor_id: metaphor.id, source_concept: :spend)
      expect(result[:mapped]).to be true
      expect(result[:target_concept]).to eq(:waste)
    end

    it 'returns found: false for unknown metaphor' do
      result = engine.apply_metaphor(metaphor_id: 'nonexistent', source_concept: :spend)
      expect(result[:found]).to be false
    end

    it 'returns mapped: false for unmapped concept' do
      result = engine.apply_metaphor(metaphor_id: metaphor.id, source_concept: :borrow)
      expect(result[:mapped]).to be false
    end
  end

  describe '#add_entailment' do
    it 'adds entailment to metaphor' do
      result = engine.add_entailment(metaphor_id: metaphor.id, entailment: 'time is valuable')
      expect(result[:success]).to be true
      expect(result[:entailment_count]).to eq(1)
    end

    it 'returns error for unknown metaphor' do
      result = engine.add_entailment(metaphor_id: 'bad', entailment: 'test')
      expect(result[:success]).to be false
    end
  end

  describe '#find_by_domain' do
    it 'finds metaphors involving the domain' do
      metaphor
      results = engine.find_by_domain(domain: :time)
      expect(results.size).to eq(1)
    end
  end

  describe '#find_by_source' do
    it 'finds metaphors by source domain' do
      metaphor
      results = engine.find_by_source(source_domain: :money)
      expect(results.size).to eq(1)
    end
  end

  describe '#find_by_target' do
    it 'finds metaphors by target domain' do
      metaphor
      results = engine.find_by_target(target_domain: :time)
      expect(results.size).to eq(1)
    end
  end

  describe '#conventional_metaphors' do
    it 'returns metaphors with high conventionality' do
      engine.create_metaphor(
        source_domain: :war, target_domain: :argument,
        metaphor_type: :structural, mappings: { attack: :criticize },
        conventionality: 0.9
      )
      expect(engine.conventional_metaphors.size).to eq(1)
    end
  end

  describe '#novel_metaphors' do
    it 'returns metaphors with low conventionality' do
      engine.create_metaphor(
        source_domain: :ocean, target_domain: :emotion,
        metaphor_type: :ontological, mappings: { depth: :intensity },
        conventionality: 0.1
      )
      expect(engine.novel_metaphors.size).to eq(1)
    end
  end

  describe '#strongest' do
    it 'returns metaphors sorted by strength' do
      metaphor
      engine.create_metaphor(
        source_domain: :war, target_domain: :argument,
        metaphor_type: :structural, mappings: {}, strength: 0.9
      )
      results = engine.strongest(limit: 2)
      expect(results.first.strength).to be >= results.last.strength
    end
  end

  describe '#by_type' do
    it 'filters by metaphor type' do
      metaphor
      engine.create_metaphor(
        source_domain: :container, target_domain: :mind,
        metaphor_type: :ontological, mappings: { full: :knowledgeable }
      )
      structural = engine.by_type(metaphor_type: :structural)
      expect(structural.size).to eq(1)
    end
  end

  describe '#decay_all' do
    it 'reduces strength of all metaphors' do
      original = metaphor.strength
      engine.decay_all
      expect(metaphor.strength).to be < original
    end
  end

  describe '#prune_weak' do
    it 'removes very weak metaphors' do
      weak = engine.create_metaphor(
        source_domain: :a, target_domain: :b,
        metaphor_type: :structural, mappings: {}, strength: 0.03
      )
      30.times { weak.decay! }
      pruned = engine.prune_weak
      expect(pruned).to be >= 1
    end
  end

  describe '#to_h' do
    it 'returns summary stats' do
      metaphor
      stats = engine.to_h
      expect(stats[:total_metaphors]).to eq(1)
      expect(stats[:total_domains]).to eq(2)
      expect(stats).to include(:type_counts, :conventional_count, :novel_count)
    end
  end
end
