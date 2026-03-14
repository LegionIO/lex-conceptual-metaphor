# frozen_string_literal: true

module Legion
  module Extensions
    module ConceptualMetaphor
      class Client
        include Runners::ConceptualMetaphor

        def initialize(engine: nil)
          @engine = engine || Helpers::MetaphorEngine.new
        end
      end
    end
  end
end
