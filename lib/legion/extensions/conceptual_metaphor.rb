# frozen_string_literal: true

require 'legion/extensions/conceptual_metaphor/version'
require 'legion/extensions/conceptual_metaphor/helpers/constants'
require 'legion/extensions/conceptual_metaphor/helpers/metaphor'
require 'legion/extensions/conceptual_metaphor/helpers/metaphor_engine'
require 'legion/extensions/conceptual_metaphor/runners/conceptual_metaphor'
require 'legion/extensions/conceptual_metaphor/client'

module Legion
  module Extensions
    module ConceptualMetaphor
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
