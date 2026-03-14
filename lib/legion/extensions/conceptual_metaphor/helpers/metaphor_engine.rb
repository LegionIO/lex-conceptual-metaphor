# frozen_string_literal: true

module Legion
  module Extensions
    module ConceptualMetaphor
      module Helpers
        class MetaphorEngine
          include Constants

          attr_reader :history

          def initialize
            @metaphors = {}
            @domains   = Set.new
            @history   = []
          end

          def create_metaphor(source_domain:, target_domain:, metaphor_type:,
                              mappings:, strength: nil, conventionality: nil)
            evict_oldest if @metaphors.size >= MAX_METAPHORS

            return { success: false, reason: :invalid_metaphor_type } unless METAPHOR_TYPES.include?(metaphor_type)

            metaphor = Metaphor.new(
              source_domain:   source_domain,
              target_domain:   target_domain,
              metaphor_type:   metaphor_type,
              mappings:        mappings,
              strength:        strength,
              conventionality: conventionality
            )

            @metaphors[metaphor.id] = metaphor
            register_domain(source_domain)
            register_domain(target_domain)
            record_history(:created, metaphor.id)
            metaphor
          end

          def apply_metaphor(metaphor_id:, source_concept:)
            metaphor = @metaphors[metaphor_id]
            return { found: false } unless metaphor

            target = metaphor.map_concept(source_concept)
            return { found: true, mapped: false } unless target

            metaphor.use!
            record_history(:applied, metaphor_id)
            build_apply_result(metaphor, source_concept, target)
          end

          def add_entailment(metaphor_id:, entailment:)
            metaphor = @metaphors[metaphor_id]
            return { success: false, reason: :not_found } unless metaphor

            metaphor.add_entailment(entailment)
            record_history(:entailment_added, metaphor_id)
            { success: true, metaphor_id: metaphor_id, entailment_count: metaphor.entailments.size }
          end

          def find_by_target(target_domain:)
            @metaphors.values.select { |m| m.target_domain == target_domain }
          end

          def find_by_source(source_domain:)
            @metaphors.values.select { |m| m.source_domain == source_domain }
          end

          def find_by_domain(domain:)
            @metaphors.values.select do |m|
              m.source_domain == domain || m.target_domain == domain
            end
          end

          def conventional_metaphors
            @metaphors.values.select(&:conventional?)
          end

          def novel_metaphors
            @metaphors.values.select(&:novel?)
          end

          def strongest(limit: 5)
            @metaphors.values.sort_by { |m| -m.strength }.first(limit)
          end

          def by_type(metaphor_type:)
            @metaphors.values.select { |m| m.metaphor_type == metaphor_type }
          end

          def decay_all
            @metaphors.each_value(&:decay!)
          end

          def prune_weak
            weak_ids = @metaphors.select { |_id, m| m.strength <= 0.05 }.keys
            weak_ids.each { |id| @metaphors.delete(id) }
            weak_ids.size
          end

          def to_h
            {
              total_metaphors:    @metaphors.size,
              total_domains:      @domains.size,
              conventional_count: conventional_metaphors.size,
              novel_count:        novel_metaphors.size,
              history_count:      @history.size,
              domains:            @domains.to_a,
              type_counts:        type_counts
            }
          end

          private

          def build_apply_result(metaphor, source_concept, target)
            {
              found:          true,
              mapped:         true,
              source_concept: source_concept,
              target_concept: target,
              strength:       metaphor.strength,
              metaphor_id:    metaphor.id
            }
          end

          def register_domain(domain)
            @domains.add(domain)
            @domains.delete(@domains.first) if @domains.size > MAX_DOMAINS
          end

          def evict_oldest
            oldest_id = @metaphors.min_by { |_id, m| m.last_used_at }&.first
            @metaphors.delete(oldest_id) if oldest_id
          end

          def record_history(event, metaphor_id)
            @history << { event: event, metaphor_id: metaphor_id, at: Time.now.utc }
            @history.shift while @history.size > MAX_HISTORY
          end

          def type_counts
            @metaphors.values.each_with_object(Hash.new(0)) do |m, counts|
              counts[m.metaphor_type] += 1
            end
          end
        end
      end
    end
  end
end
