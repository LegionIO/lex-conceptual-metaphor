# frozen_string_literal: true

RSpec.describe Legion::Extensions::ConceptualMetaphor::Runners::ConceptualMetaphor do
  let(:runner_host) do
    obj = Object.new
    obj.extend(described_class)
    obj
  end

  describe '#create_metaphor' do
    it 'creates a metaphor successfully' do
      result = runner_host.create_metaphor(
        source_domain: :money, target_domain: :time,
        metaphor_type: :structural, mappings: { spend: :waste }
      )
      expect(result[:success]).to be true
      expect(result[:metaphor_id]).to be_a(String)
    end

    it 'rejects invalid metaphor type' do
      result = runner_host.create_metaphor(
        source_domain: :a, target_domain: :b,
        metaphor_type: :invalid, mappings: {}
      )
      expect(result[:success]).to be false
    end
  end

  describe '#apply_metaphor' do
    it 'maps a concept through a metaphor' do
      created = runner_host.create_metaphor(
        source_domain: :money, target_domain: :time,
        metaphor_type: :structural, mappings: { spend: :waste }
      )
      result = runner_host.apply_metaphor(
        metaphor_id: created[:metaphor_id], source_concept: :spend
      )
      expect(result[:success]).to be true
      expect(result[:target_concept]).to eq(:waste)
    end
  end

  describe '#add_metaphor_entailment' do
    it 'adds an entailment' do
      created = runner_host.create_metaphor(
        source_domain: :money, target_domain: :time,
        metaphor_type: :structural, mappings: {}
      )
      result = runner_host.add_metaphor_entailment(
        metaphor_id: created[:metaphor_id],
        entailment:  'wasting time is losing money'
      )
      expect(result[:success]).to be true
    end
  end

  describe '#find_metaphors_for' do
    it 'finds metaphors for a domain' do
      runner_host.create_metaphor(
        source_domain: :money, target_domain: :time,
        metaphor_type: :structural, mappings: {}
      )
      result = runner_host.find_metaphors_for(domain: :time)
      expect(result[:success]).to be true
      expect(result[:count]).to eq(1)
    end
  end

  describe '#conventional_metaphors' do
    it 'returns conventional metaphors' do
      runner_host.create_metaphor(
        source_domain: :war, target_domain: :argument,
        metaphor_type: :structural, mappings: {},
        conventionality: 0.9
      )
      result = runner_host.conventional_metaphors
      expect(result[:success]).to be true
      expect(result[:count]).to eq(1)
    end
  end

  describe '#novel_metaphors' do
    it 'returns novel metaphors' do
      runner_host.create_metaphor(
        source_domain: :ocean, target_domain: :emotion,
        metaphor_type: :ontological, mappings: {},
        conventionality: 0.1
      )
      result = runner_host.novel_metaphors
      expect(result[:success]).to be true
      expect(result[:count]).to eq(1)
    end
  end

  describe '#strongest_metaphors' do
    it 'returns strongest metaphors' do
      runner_host.create_metaphor(
        source_domain: :a, target_domain: :b,
        metaphor_type: :structural, mappings: {}, strength: 0.9
      )
      result = runner_host.strongest_metaphors(limit: 3)
      expect(result[:success]).to be true
    end
  end

  describe '#metaphors_by_type' do
    it 'filters by type' do
      runner_host.create_metaphor(
        source_domain: :a, target_domain: :b,
        metaphor_type: :orientational, mappings: {}
      )
      result = runner_host.metaphors_by_type(metaphor_type: :orientational)
      expect(result[:success]).to be true
      expect(result[:count]).to eq(1)
    end
  end

  describe '#update_conceptual_metaphor' do
    it 'runs decay and prune cycle' do
      result = runner_host.update_conceptual_metaphor
      expect(result[:success]).to be true
      expect(result).to include(:pruned)
    end
  end

  describe '#conceptual_metaphor_stats' do
    it 'returns stats' do
      result = runner_host.conceptual_metaphor_stats
      expect(result[:success]).to be true
      expect(result).to include(:total_metaphors, :total_domains)
    end
  end
end
