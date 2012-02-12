class String
  def indent(str_or_number_of_spaces)
    indent= str_or_number_of_spaces.is_a?(Fixnum) ? ' '*str_or_number_of_spaces : str_or_number_of_spaces
    gsub /\A|([\n\r]+)(?=[^\n\r])/, '\1' + indent
  end
end

class Array
  def indent(str_or_number_of_spaces)
    indent= str_or_number_of_spaces.is_a?(Fixnum) ? ' '*str_or_number_of_spaces : str_or_number_of_spaces
    map {|e| "#{indent}#{e}" if e}
  end
end
