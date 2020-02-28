class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery with: :null_session

  protected

  def store_controller_config(name, value)
    session[key_for_controller_session] ||= {}
    session[key_for_controller_session][name] = value
  end

  def get_controller_config(name)
    session[key_for_controller_session].try(:[], name.to_s)
  end

  def clear_controller_config
    session.delete key_for_controller_session
  end

  private

  def set_order
    if params[:order]
      o = order(params[:order])

      @order = o.field
      @asc_desc = o.asc_desc

      store_controller_config(:order, @order)
      store_controller_config(:asc_desc, @asc_desc)
    else
      @order = get_controller_config(:order)
      @asc_desc = get_controller_config(:asc_desc)
    end
  end

  def self.paginated_action(options = {})
    before_filter(options) do |controller|
      if request.headers['Range-Unit'] == 'items' && request.headers['Range'].present?
        requested_from = nil
        requested_to = nil
        if request.headers['Range'] =~ /(\d+)-(\d*)/
          requested_from, requested_to = $1.to_i, ($2.present? ? $2.to_i : Float::INFINITY)
        end

        if (requested_from.to_i > requested_to.to_i)
          response.status = 416
          headers['Content-Range'] = "*/#{total_items}"
          render text: 'invalid pagination range'
          return false
        end
        @kp_per_page = requested_to.to_i - requested_from.to_i + 1
        @kp_page = requested_to.to_i / @kp_per_page + 1
      end
    end

    after_filter(options) do |controller|
      results = instance_variable_get("@#{controller_name}") # ex @users
      if results &&results.length > 0
        response.status = 206
        headers['Accept-Ranges'] = 'items'
        headers['Range-Unit'] = 'items'
        total_items = results.total_count
        current_page = results.current_page
        per = @kp_per_page || 1

        requested_from = (results.current_page - 1) * per
        available_to = (results.length - 1) + requested_from
        headers['Content-Range'] = "#{requested_from}-#{available_to}/#{total_items < Float::INFINITY ? total_items : '*'}"
      elsif request.xhr?
        response.status = 204
        headers['Content-Range'] = "*/0"
        headers['Accept-Ranges'] = 'items'
        headers['Range-Unit'] = 'items'
      end
    end
  end

  def key_for_controller_session
    modulo = self.class.to_s.deconstantize
    "#{modulo}#{controller_name}"
  end
end
