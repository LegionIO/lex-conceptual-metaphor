# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module ConceptualMetaphor
      module Helpers
        class Metaphor
          include Constants

          attr_reader :id, :source_domain, :target_domain, :metaphor_type,
                      :mappings, :entailments, :strength, :conventionality,
                      :use_count, :created_at, :last_used_at

          def initialize(source_domain:, target_domain:, metaphor_type:,
                         mappings:, strength: nil, conventionality: nil)
            @id              = SecureRandom.uuid
            @source_domain   = source_domain
            @target_domain   = target_domain
            @metaphor_type   = metaphor_type
            @mappings        = mappings
            @entailments     = []
            @strength        = (strength || DEFAULT_STRENGTH).to_f.clamp(STRENGTH_FLOOR, STRENGTH_CEILING)
            @conventionality = (conventionality || DEFAULT_STRENGTH).to_f.clamp(STRENGTH_FLOOR, STRENGTH_CEILING)
            @use_count       = 0
            @created_at      = Time.now.utc
            @last_used_at    = @created_at
          end

          def use!
            @use_count   += 1
            @last_used_at = Time.now.utc
            @strength     = (@strength + REINFORCEMENT_BOOST).clamp(STRENGTH_FLOOR, STRENGTH_CEILING)
            increase_conventionality
          end

          def add_entailment(entailment)
            @entailments << entailment
          end

          def map_concept(source_concept)
            @mappings[source_concept]
          end

          def coverage
            return 0.0 if @mappings.empty?

            @mappings.values.compact.size.to_f / @mappings.size
          end

          def conventional?
            @conventionality >= CONVENTIONALITY_THRESHOLD
          end

          def novel?
            @conventionality <= NOVELTY_THRESHOLD
          end

          def conventionality_label
            CONVENTIONALITY_LABELS.find { |range, _| range.cover?(@conventionality) }&.last || :unknown
          end

          def strength_label
            STRENGTH_LABELS.find { |range, _| range.cover?(@strength) }&.last || :unknown
          end

          def decay!
            @strength = (@strength - DECAY_RATE).clamp(STRENGTH_FLOOR, STRENGTH_CEILING)
          end

          def stale?
            (Time.now.utc - @last_used_at) > STALE_THRESHOLD
          end

          def to_h
            {
              id:                    @id,
              source_domain:         @source_domain,
              target_domain:         @target_domain,
              metaphor_type:         @metaphor_type,
              mappings:              @mappings,
              entailments:           @entailments,
              strength:              @strength,
              conventionality:       @conventionality,
              conventionality_label: conventionality_label,
              strength_label:        strength_label,
              use_count:             @use_count,
              coverage:              coverage,
              created_at:            @created_at,
              last_used_at:          @last_used_at
            }
          end

          private

          def increase_conventionality
            increment = REINFORCEMENT_BOOST * 0.5
            @conventionality = (@conventionality + increment).clamp(STRENGTH_FLOOR, STRENGTH_CEILING)
          end
        end
      end
    end
  end
end
