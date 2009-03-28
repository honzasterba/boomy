module BoomHelper
  
  def pretty_date(date)
    diff = Time.now - date
    if diff <= 1.minute
      return "před "+diff.to_i.to_s+" sekundami"
    elsif diff <= 1.hour
      return "před "+(diff/60).to_i.to_s+" minutami"
    elsif diff <= 1.day
      return "před "+(diff/(60*60)).to_i.to_s+" hodinami"
    elsif diff <= 1.month
      return "před "+(diff/(60*60*24)).to_i.to_s+" dny"
    elsif diff <= 1.year
      return "před "+(diff/(60*60*24*30)).to_i.to_s+" měsíci"
    else
      return "před "+(diff/(60*60*24*30*12)).to_i.to_s+" roky"
    end
  end
  
  def block_to_remote(params, options, &block)
    concat link_to_remote(capture(&block), params, options), block.binding
  end
  
  def link_to_block(opts, html_opts = nil, &block)
    concat link_to(capture(&block), opts, html_opts), block.binding
  end
end
