module ApplicationHelper
  def full_title(page_title)
    base_title = "BitBet :: bet on bitcoin"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def aside_for(aside)
    "asides/#{aside}"
  end

  def query_string(params, key, value)
    qs = []
    %w[status order category].each do |k|
      if !params[k.to_sym].nil? || key == k
        status = key == k ? value : params[k.to_sym]
        qs.append("#{k}=#{status}") unless status.nil?
      end
    end
    qs.join('&')
  end

  def redirect_with_error(errmsg)
    redirect_to root_path, :flash => { :error => errmsg }
  end
end
