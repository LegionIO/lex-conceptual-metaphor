# frozen_string_literal: true

RSpec.describe Legion::Extensions::ConceptualMetaphor::Helpers::Metaphor do
  subject(:metaphor) do
    described_class.new(
      source_domain:   :money,
      target_domain:   :time,
      metaphor_type:   :structural,
      mappings:        { spend: :waste, save: :conserve, invest: :dedicate },
      strength:        0.6,
      conventionality: 0.8
    )
  end

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(metaphor.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores source and target domains' do
      expect(metaphor.source_domain).to eq(:money)
      expect(metaphor.target_domain).to eq(:time)
    end

    it 'stores metaphor type' do
      expect(metaphor.metaphor_type).to eq(:structural)
    end

    it 'stores mappings' do
      expect(metaphor.mappings).to eq({ spend: :waste, save: :conserve, invest: :dedicate })
    end

    it 'clamps strength within bounds' do
      over = described_class.new(source_domain: :a, target_domain: :b, metaphor_type: :structural,
                                 mappings: {}, strength: 2.0)
      expect(over.strength).to eq(1.0)
    end
  end

  describe '#use!' do
    it 'increments use count' do
      expect { metaphor.use! }.to change(metaphor, :use_count).by(1)
    end

    it 'boosts strength' do
      original = metaphor.strength
      metaphor.use!
      expect(metaphor.strength).to be > original
    end

    it 'increases conventionality' do
      original = metaphor.conventionality
      metaphor.use!
      expect(metaphor.conventionality).to be >= original
    end
  end

  describe '#map_concept' do
    it 'returns mapped target concept' do
      expect(metaphor.map_concept(:spend)).to eq(:waste)
    end

    it 'returns nil for unmapped concept' do
      expect(metaphor.map_concept(:borrow)).to be_nil
    end
  end

  describe '#coverage' do
    it 'returns ratio of mapped concepts' do
      expect(metaphor.coverage).to eq(1.0)
    end

    it 'returns 0.0 for empty mappings' do
      empty = described_class.new(source_domain: :a, target_domain: :b,
                                  metaphor_type: :structural, mappings: {})
      expect(empty.coverage).to eq(0.0)
    end
  end

  describe '#conventional?' do
    it 'returns true when conventionality is high' do
      expect(metaphor).to be_conventional
    end
  end

  describe '#novel?' do
    it 'returns false when conventionality is high' do
      expect(metaphor).not_to be_novel
    end

    it 'returns true when conventionality is low' do
      fresh = described_class.new(source_domain: :a, target_domain: :b,
                                  metaphor_type: :structural, mappings: {},
                                  conventionality: 0.2)
      expect(fresh).to be_novel
    end
  end

  describe '#conventionality_label' do
    it 'returns a label symbol' do
      expect(metaphor.conventionality_label).to eq(:dead)
    end
  end

  describe '#strength_label' do
    it 'returns a label symbol' do
      expect(metaphor.strength_label).to be_a(Symbol)
    end
  end

  describe '#decay!' do
    it 'reduces strength' do
      original = metaphor.strength
      metaphor.decay!
      expect(metaphor.strength).to be < original
    end
  end

  describe '#add_entailment' do
    it 'adds entailment to the list' do
      metaphor.add_entailment('wasting time is losing money')
      expect(metaphor.entailments).to include('wasting time is losing money')
    end
  end

  describe '#to_h' do
    it 'returns a hash representation' do
      hash = metaphor.to_h
      expect(hash).to include(:id, :source_domain, :target_domain, :mappings,
                              :strength, :conventionality, :coverage)
    end
  end
end
