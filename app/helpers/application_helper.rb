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
  	if !params[:status].nil? || key == 'status'
  		status = (key == 'status') ? value : params[:status]
  		qs.append("status=#{status}") if !status.nil?
  	end
  	if !params[:order].nil? || key == 'order'
  		order = (key == 'order') ? value : params[:order]
  		qs.append("order=#{order}") if !order.nil?
  	end
  	if !params[:category].nil? || key == 'category'
  		category = (key == 'category') ? value : params[:category]
  		qs.append("category=#{category}") if !category.nil?
  	end 
  	qs.join('&')
  end

  def bitcoin_client
    BitcoinClient.new
  end

  def redirect_with_error(errmsg)
    redirect_to root_path, :flash => { :error => errmsg }
  end
end
