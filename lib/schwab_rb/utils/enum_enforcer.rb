module EnumEnforcer
  def enforce_enums?
    @enforce_enums ||= false
  end

  def enforce_enums=(value)
    @enforce_enums = value
  end

  def type_error(value, required_enum_type)
    possible_members_message = ''

    if value.is_a? String
      possible_members = required_enum_type.constants.filter_map do |member|
        fullname = "#{required_enum_type}::#{member}"
        fullname if fullname.include?(value)
      end

      if possible_members.any?
        possible_members_message = 'Did you mean ' +
          possible_members[0..-2].join(', ') +
          (possible_members.size > 1 ? ' or ' : '') +
          possible_members[-1].to_s + '? '
      end
    end

    raise ArgumentError, "expected type \"#{required_enum_type}\", got type \"#{value.class}\". #{possible_members_message}(initialize with enforce_enums: false to disable this checking)"
  end

  def convert_enum(value, required_enum_type)
    return nil if value.nil?

    if value.is_a?(required_enum_type)
      value.value
    elsif enforce_enums
      type_error(value, required_enum_type)
    else
      value
    end
  end

  def convert_enum_iterable(iterable, required_enum_type)
    return nil if iterable.nil?

    if iterable.is_a?(required_enum_type)
      return [iterable.value]
    end

    values = []
    iterable.each do |value|
      if value.is_a?(required_enum_type)
        values << value.value
      elsif enforce_enums
        type_error(value, required_enum_type)
      else
        values << value
      end
    end

    values
  end

  def set_enforce_enums(enforce_enums)
    @enforce_enums = enforce_enums
  end
end