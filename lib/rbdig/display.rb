class RbDig::Display
  def initialize(response_object, opts)
    @response = response_object
    @opts = opts
  end

  def print
    case RbDig::PRINT_OPTIONS[@opts[:print]]
    when 'short'
      puts message_short
    when 'noall'
      puts message_noall
    when 'all'
      pretty_print
    when 'silent'
      nil
    else
      raise ArgumentError, 'Unknown print option'
    end
  end

  # "198.162.0.1"
  def message_short
    return 'No answers found' unless @response.answers.any?

    "\n### Found answer:\n#{@response.answers[0][:rr_data]}"
  end

  # "example.com             164     IN      A       96.7.128.198"
  def message_noall
    return 'No answers found' unless @response.answers.any?

    print_resource(@response.answers[0])
  end

  def pretty_print
    print_header
    print_question

    print_answer
    print_authority
    puts "\n"
    print_additional
  end

  def print_header
    puts "HEADER: opcode: QUERY, id: #{@response.header[:query_id]}"
    # puts "flags: #{}"
    puts "ANSWER: #{@response.answers.size}, AUTHORITY: #{@response.authorities.size}, ADDITIONAL: #{@response.additional.size}"
    puts "\n"
  end

  def print_question
    puts 'QUESTION SECTION:'
    puts "#{@response.body[:question]}\t\t#{q_type(@response.body[:q_type])}"
    puts "\n\n"
  end

  def print_answer
    return unless @response.answers.any?

    puts 'ANSWER SECTION:'
    @response.answers.each { |a| print_resource(a) }
  end

  def print_authority
    return unless @response.authorities.any?

    puts 'AUTHORITY SECTION:'
    @response.authorities.each { |a| print_resource(a) }
  end

  def print_additional
    return unless @response.additional.any?

    puts 'ADDITIONAL SECTION:'
    @response.additional.each { |a| print_resource(a) }
  end

  def print_resource(r)
    puts "#{r[:rr_name]}\t\t#{r[:ttl]}\tIN\t#{q_type(r[:rr_type])}\t#{r[:rr_data]}"
  end

  def q_type(type)
    RbDig::QUERY_TYPES[type]
  end
end
