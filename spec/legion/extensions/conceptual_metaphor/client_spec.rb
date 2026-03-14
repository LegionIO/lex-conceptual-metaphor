# frozen_string_literal: true

RSpec.describe Legion::Extensions::ConceptualMetaphor::Client do
  subject(:client) { described_class.new }

  it 'creates a metaphor' do
    result = client.create_metaphor(
      source_domain: :money, target_domain: :time,
      metaphor_type: :structural, mappings: { spend: :waste }
    )
    expect(result[:success]).to be true
  end

  it 'applies a metaphor' do
    created = client.create_metaphor(
      source_domain: :money, target_domain: :time,
      metaphor_type: :structural, mappings: { spend: :waste }
    )
    result = client.apply_metaphor(
      metaphor_id: created[:metaphor_id], source_concept: :spend
    )
    expect(result[:target_concept]).to eq(:waste)
  end

  it 'returns stats' do
    result = client.conceptual_metaphor_stats
    expect(result[:success]).to be true
  end
end
