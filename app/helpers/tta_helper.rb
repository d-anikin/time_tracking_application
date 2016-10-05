module TtaHelper
  def tta_status_raw(data)
    if data.status.nil?
      return "none"
    elsif data.status &&
          data.status_updated_at &&
          5.minutes.ago < data.status_updated_at
      return data.status.capitalize
    else
      return "Offline"
    end
  end

  def tta_status(data)
    result = tta_status_raw(data)
    return case result
            when "Offline" then "<span style='color: #900'>#{result}</span>"
            when "Online" then "<span style='color: #090'>#{result}</span>"
            when "Busy" then "<span style='color: #009'>#{result}</span>"
            else result
          end.html_safe
  end
end
