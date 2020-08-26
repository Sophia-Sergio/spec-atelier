module MetaLookupTable
  extend ActiveSupport::Concern

  included do
    def self.searcheable_attributes
      @searcheable_attributes ||= new.attribute_names - %w[id created_at updated_at]
    end

    def self.fields
      @fields ||= if LookupTable.all.count.positive?
        JSON.parse(LookupTable.all.to_json).select {|item| searcheable_attributes.include? item['category'] }
      else
        []
      end
    end

    fields.map {|a| a['category'] }.uniq.each {|field| new.send(:enum_methods, field) }
    after_find :define_methods
    after_update :define_methods
  end

  private

  def enum_methods(field)
    if send(field.to_sym).is_a? Array
      self.class.fields.map {|a| a['category'] }.uniq.each do |field_|
        self.class.send :define_method, "#{field_}_values" do
          send(field_.to_sym).map(&:to_i).map do |item|
            self.class.fields.select {|a| a['category'] == field_ && a['code'] == item }.first['value']
          end
        end

        self.class.fields.select {|item| item['category'] == field_ }.each do |filtered_field|
          self.class.send :define_method, "#{filtered_field['value']}?" do
            send(field_.to_sym).map(&:to_i).include? filtered_field['code']
          end
        end
      end
    else
      self.class.send :enum, field.to_sym => enum_constructor(field)
    end
  end

  def enum_constructor(field)
    self.class.fields.select {|a| a['category'] == field }.each_with_object({}) {|i, h| h[i['value']] = i['code'] }
  end

  def define_methods
    self.class.fields.map {|a| a['category'] }.uniq.each do |field|
      self.class.send :define_method, "#{field}_spa" do
        if send(field.to_sym).is_a? Array
          send(field.to_sym).map do |value|
            self.class.fields.select {|b| b['code'] == value.to_i }.first['translation_spa']
          end
        else
          self.class.fields.select {|b| b['value'] == send(field.to_sym) }.first['translation_spa']
        end
      end

      self.class.send :define_method, "#{field}_key_value" do
        if send(field.to_sym).is_a? Array
          send(field.to_sym).map do |value|
            { id: value.to_i, name: self.class.fields.select {|b| b['code'] == value.to_i }.first['translation_spa'] }
          end
        else
          { id: value.to_i, name: self.class.fields.select {|b| b['value'] == send(field.to_sym) }.first['translation_spa'] }
        end
      end
    end
  end
end
