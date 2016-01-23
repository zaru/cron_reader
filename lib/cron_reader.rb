require "cron_reader/version"

module CronReader

  attr_reader :text

  def initialize(text)
    @text = text
  end

  def text
    elements = @text.split("\s")

    min = minute(elements[0])
    h = hour(elements[1])
    d = day(elements[2])
    m = month(elements[3])
    w = week(elements[4])

    result = ''
    result += '毎年' unless m.include?('毎')
    result += m unless m.include?('毎') && d.include?('毎')
    result += d unless d.include?('毎') && h.include?('毎')
    result += w
    result += h unless h.include?('毎') && min.include?('毎')
    result += min

    result
  end

  def parse(element:, unit_text:, max:, zero_one: false)
    if '*' == element
      return '毎' + unit_text
    end

    if element.include?(',')
      return element + unit_text
    end

    if element.include?('*/')
      divisor = element.split('/')[1].to_i
      lists = (BigDecimal("#{max}") / BigDecimal("#{divisor}")).ceil.times.map do |i|
        num = i * divisor
        num += 1 if zero_one
      end
      return lists.join(',') + unit_text
    end

    element + unit_text
  end

  def minute(element)
    parse(element:element, unit_text:'分', max:59)
  end

  def hour(element)
    parse(element:element, unit_text:'時', max:23)
  end

  def day(element)
    parse(element:element, unit_text:'日', max:30, zero_one:true)
  end

  def month(element)
    parse(element:element, unit_text:'月', max:11, zero_one:true)
  end

  def week(element)
    if '*' == element
      return ''
    end

    if (0..7).include? element.to_i
      weeks = %w[日 月 火 水 木 金 土 日]
      return weeks[element.to_i] + '曜日'
    end

    ''
  end

end
