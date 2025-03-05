class RbDig::Display
  def initialize(response_object)
    @response = response_object
  end

  def pretty_print
    puts "HEADER: opcode: QUERY, id: #{@response.header[:query_id]}"
    # puts "flags: #{}"
    puts "ANSWER: #{@response.answers.size}, AUTHORITY: #{@response.authorities.size}, ADDITIONAL: #{@response.additional.size}"
    puts "\n"

    puts 'QUESTION SECTION:'
    puts "#{@response.body[:question]}\t\t#{q_type(@response.body[:q_type])}"
    puts "\n\n"

    print_answer
    print_authority
    puts "\n"
    print_additional
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
