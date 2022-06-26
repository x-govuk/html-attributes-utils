require "active_support/core_ext/hash/keys"

module HTMLAttributesUtils
  # DEFAULT_MERGEABLE_ATTRIBUTES is a list of HTML attributes where the value
  # contain multiple elements separated by spaces. We use it to target values
  # to split so the arrays can be cleanly merged.
  #
  # They are stored as nested arrays so when we're walking multiple
  # levels on the deep merge the structure can be identified. This means
  # the library works with the Rails-preferred format of
  # `aria: { describedby: "xyz" }` rather than `aria-describdby: `xyz`
  DEFAULT_MERGEABLE_ATTRIBUTES = [
    %i(class),
    %i(aria controls),
    %i(aria describedby),
    %i(aria flowto),
    %i(aria labelledby),
    %i(aria owns),
  ].freeze

  refine Hash do
    # Merge the incoming hash into the current one in a way that suits
    # HTML attributes.
    #
    # @param custom [Hash] the incoming hash
    # @param parents [Array] used to keep track of the keys that have already been
    #   merged, *don't supply this unless the method is called during recursion*
    # @mergeable_attributes [Array<Array<Symbol>>] Mergeable attributes are
    #   HTML attributes can contain lists made from space-separated strings. We
    #   convert them to arrays so they can be cleanly merged. Rails accepts them
    #   as arrays so there's no need to convert back to strings.
    #
    # @example
    #   original = { class: "red", data: { size: "medium", controller: "comment" } }
    #   incoming = { class: "blue", data: { controller: "reply" } }
    #
    #   original.deep_merge_html_attributes(incoming)
    #
    #   => { class: "blue", data: { size: "medium", controller: "reply" } }
    #
    def deep_merge_html_attributes(custom, parents = [], mergeable_attributes: DEFAULT_MERGEABLE_ATTRIBUTES)
      return custom unless custom.is_a?(Hash)

      overrides = custom.deep_symbolize_keys
      originals = deep_symbolize_keys

      originals.each_with_object(originals) { |(key, value), merged|
        next unless overrides.key?(key)

        merged[key] = combine_values(
          value,
          overrides[key],
          parents: [*parents, *key],
          mergeable_attributes: mergeable_attributes
        )

        overrides.delete(key)
      }.merge(overrides)
    end

    # Remove unwanted attributes from a the hash and any values that are hashes
    # recursively. In particular we don't care for empty hashes, arrays,
    # strings that are empty or just contain spaces and nils.
    #
    # It preserves +true+ and +false+.
    #
    # @return [Hash] the tidied hash
    # @example
    #   { class: "blue", title: nil, lang: "", aria: { describedby: [] } }.deep_tidy_html_attributes
    #
    #   => { class: "blue" }
    #
    def deep_tidy_html_attributes
      each_with_object({}) do |(key, value), tidy|
        (tidy[key] = tidy_value(value)) unless skippable_value?(value)
      end
    end

  private

    def tidy_value(value)
      case value
      when Hash
        value.deep_tidy_html_attributes.presence
      when Array
        value.reject(&:blank?).map(&:to_s).map(&:strip).presence
      else
        value.to_s.strip.presence
      end
    end

    # Identiy attribute values we don't care about.
    #
    # We can't check for this using Rails' `#presence` because we want `false` to be
    # included so some HTML attributes that default to on can be disabled, like
    # `autocomplete: false`
    #
    # FIXME: there is probably a nicer way of doing this...
    def skippable_value?(value)
      return false if [true, false].include?(value)

      value.blank?
    end

    def combine_values(value, override, **kwargs)
      case split_attribute_list(value, **kwargs)
      when Array
        combine_array(value, override, **kwargs)
      when Hash
        combine_hash(value, override, **kwargs)
      else
        split_attribute_list(override, **kwargs)
      end
    end

    def combine_array(originals, overrides, parents:, mergeable_attributes:)
      return overrides if overrides.nil?
      return overrides unless mergeable_attributes.include?(parents)

      (try_split(originals) + try_split(overrides)).uniq
    end

    def try_split(value)
      value.is_a?(String) ? value.split : value
    end

    def combine_hash(originals, overrides, parents:, mergeable_attributes:)
      originals.deep_merge_html_attributes(overrides, parents, mergeable_attributes: mergeable_attributes)
    end

    def split_attribute_list(value, parents:, mergeable_attributes:)
      return value.split if value.is_a?(String) && mergeable_attributes.include?(parents)

      value
    end
  end
end
