# frozen_string_literal: true

module Legion
  module Extensions
    module ConceptualMetaphor
      module Helpers
        module Constants
          MAX_METAPHORS = 200
          MAX_MAPPINGS = 500
          MAX_DOMAINS = 100
          MAX_HISTORY = 300

          DEFAULT_STRENGTH = 0.5
          STRENGTH_FLOOR = 0.0
          STRENGTH_CEILING = 1.0

          REINFORCEMENT_BOOST = 0.1
          DECAY_RATE = 0.02
          STALE_THRESHOLD = 120

          CONVENTIONALITY_THRESHOLD = 0.7
          NOVELTY_THRESHOLD = 0.3

          METAPHOR_TYPES = %i[structural orientational ontological].freeze

          CONVENTIONALITY_LABELS = {
            (0.8..)     => :dead,
            (0.6...0.8) => :conventional,
            (0.4...0.6) => :familiar,
            (0.2...0.4) => :novel,
            (..0.2)     => :creative
          }.freeze

          STRENGTH_LABELS = {
            (0.8..)     => :dominant,
            (0.6...0.8) => :strong,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :weak,
            (..0.2)     => :fading
          }.freeze
        end
      end
    end
  end
end
