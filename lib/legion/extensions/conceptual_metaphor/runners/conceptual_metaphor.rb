# frozen_string_literal: true

module Legion
  module Extensions
    module ConceptualMetaphor
      module Runners
        module ConceptualMetaphor
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def create_metaphor(source_domain:, target_domain:, metaphor_type:,
                              mappings:, strength: nil, conventionality: nil, **)
            unless Helpers::Constants::METAPHOR_TYPES.include?(metaphor_type)
              return { success: false, error: :invalid_metaphor_type,
                       valid_types: Helpers::Constants::METAPHOR_TYPES }
            end

            result = engine.create_metaphor(
              source_domain:   source_domain,
              target_domain:   target_domain,
              metaphor_type:   metaphor_type,
              mappings:        mappings,
              strength:        strength,
              conventionality: conventionality
            )

            return result unless result.is_a?(Helpers::Metaphor)

            Legion::Logging.debug "[conceptual_metaphor] created #{source_domain}->#{target_domain} " \
                                  "type=#{metaphor_type} id=#{result.id[0..7]}"
            { success: true, metaphor_id: result.id, source_domain: source_domain,
              target_domain: target_domain, metaphor_type: metaphor_type,
              strength: result.strength, conventionality: result.conventionality }
          end

          def apply_metaphor(metaphor_id:, source_concept:, **)
            result = engine.apply_metaphor(metaphor_id: metaphor_id, source_concept: source_concept)
            Legion::Logging.debug "[conceptual_metaphor] apply id=#{metaphor_id[0..7]} " \
                                  "concept=#{source_concept} mapped=#{result[:mapped]}"
            { success: true }.merge(result)
          end

          def add_metaphor_entailment(metaphor_id:, entailment:, **)
            result = engine.add_entailment(metaphor_id: metaphor_id, entailment: entailment)
            Legion::Logging.debug "[conceptual_metaphor] entailment id=#{metaphor_id[0..7]} " \
                                  "success=#{result[:success]}"
            result
          end

          def find_metaphors_for(domain:, **)
            metaphors = engine.find_by_domain(domain: domain)
            Legion::Logging.debug "[conceptual_metaphor] find domain=#{domain} count=#{metaphors.size}"
            { success: true, domain: domain, metaphors: metaphors.map(&:to_h), count: metaphors.size }
          end

          def conventional_metaphors(**)
            metaphors = engine.conventional_metaphors
            Legion::Logging.debug "[conceptual_metaphor] conventional count=#{metaphors.size}"
            { success: true, metaphors: metaphors.map(&:to_h), count: metaphors.size }
          end

          def novel_metaphors(**)
            metaphors = engine.novel_metaphors
            Legion::Logging.debug "[conceptual_metaphor] novel count=#{metaphors.size}"
            { success: true, metaphors: metaphors.map(&:to_h), count: metaphors.size }
          end

          def strongest_metaphors(limit: 5, **)
            metaphors = engine.strongest(limit: limit)
            Legion::Logging.debug "[conceptual_metaphor] strongest limit=#{limit} count=#{metaphors.size}"
            { success: true, metaphors: metaphors.map(&:to_h), count: metaphors.size }
          end

          def metaphors_by_type(metaphor_type:, **)
            metaphors = engine.by_type(metaphor_type: metaphor_type)
            Legion::Logging.debug "[conceptual_metaphor] by_type=#{metaphor_type} count=#{metaphors.size}"
            { success: true, metaphor_type: metaphor_type, metaphors: metaphors.map(&:to_h),
              count: metaphors.size }
          end

          def update_conceptual_metaphor(**)
            engine.decay_all
            pruned = engine.prune_weak
            Legion::Logging.debug "[conceptual_metaphor] decay+prune pruned=#{pruned}"
            { success: true, pruned: pruned }
          end

          def conceptual_metaphor_stats(**)
            stats = engine.to_h
            Legion::Logging.debug "[conceptual_metaphor] stats total=#{stats[:total_metaphors]}"
            { success: true }.merge(stats)
          end

          private

          def engine
            @engine ||= Helpers::MetaphorEngine.new
          end
        end
      end
    end
  end
end
