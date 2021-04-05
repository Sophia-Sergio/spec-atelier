class String
  def strip_tags
    ActionController::Base.helpers.strip_tags(self)
  end
end

module ActiveRecordUnion
  extend ActiveSupport::Concern

  class_methods do
    def union(*relations)
      raise ArgumentError, "wrong number of arguments (given 0, expected 1+)" if relations.empty?

      valid_relations = relations.select do |relation|
        raise_type_mismatch_error if table_name != relation.table_name
        relation.to_sql.present?
      end

      mapped_sql = valid_relations.map(&:to_sql).join(") UNION (")
      unionized_sql = "((#{mapped_sql})) #{table_name}"

      where(id: from(unionized_sql))
    end

    def paginated_format(decorator, params = {})
      params[:page] = params[:page].presence&.to_i || 0
      params[:offset] = params[:offset].presence&.to_i || params[:limit].presence&.to_i || 10
      params[:limit] = params[:limit].presence&.to_i || 10
      list = all
      {
        total: list.count,
        list: paginated_list(list, decorator, params),
        next_page: (params[:page] + 1) * params[:limit] < list.count ? params[:page] + 1 : nil
      }
    end

    private

    def paginated_list(list, decorator, params)
      ordered = list.pluck(:id)
      decorator.decorate_collection(
        list.offset(params[:limit] * params[:page]).limit(params[:limit]).find_ordered(ordered),
        context: params
      )
    end

    def raise_type_mismatch_error
      raise ArgumentError, "type mismatch. Base model table #{table_name} does not match table #{relation.table_name} of at least one relation"
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecordUnion)
