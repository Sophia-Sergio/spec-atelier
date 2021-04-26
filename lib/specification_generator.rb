class SpecificationGenerator
  attr_reader :config

  def initialize(specification)
    @specification = specification
    @blocks = @specification.blocks.order(:order)
    @config = specification.project.config
  end

  def generate
    generate_file
    url = upload_file
    remove_file
    url
  end

  private

  def upload_file
    file = File.new(file_name_path)
    file_stored = GoogleStorage.new(project, file, 'specification').perform(file_name)
    attach_to_specification(file_stored)
  end

  def remove_file
    File.delete(file_name_path)
  end

  def attach_to_specification(file_stored)
    attached_document = Attached::Specification.find_or_create_by!(
      url: "#{file_stored.public_url}?generation=#{file_stored.generation}",
      name: file_name
    )
    create_resourse_file(@specification, attached_document, 'specification_document') if attached_document.new_record?
    attached_document.url
  end

  def create_resourse_file(owner, attached_file, kind)
    Attached::ResourceFile.create!(owner: owner, attached: attached_file, kind: kind)
  end

  def generate_file
    Caracal::Document.save file_name_path do |docx|
      styles(docx)
      project_summarize(docx)
      @blocks.each do |block|
        %w[section item product].each do |block_type|
          send(block_type, docx, block) if block.spec_item_type == block_type.capitalize
        end
      end
    end
  end

  def file_name_path
    "tmp/#{file_name}"
  end

  def project_summarize(docx)
    docx.p project.name, style: 'header_project'
    docx.p "Tipo de Proyecto: #{project.project_type_spa.capitalize}"
    docx.p "Descripción: #{project.description}" if project.description.present?
    docx.p "m²: #{project.size}" if project.size.present?
    docx.p "Ciudad: #{project.city}" if project.city.present?
    docx.p "Arquitecto: #{project.user.name}" if project.user.name.present?
    docx.p "Contacto: #{project.user.email}" if project.user.email.present?
    docx.hr
  end

  def file_name
    "EETT-#{project.name.parameterize.underscore}.docx"
  end

  def project
    @project ||= @specification.project
  end

  def product(docx, block)
    if block.product_image.present?
      c1 = Caracal::Core::Models::TableCellModel.new do
        img block.spec_item.images.first.all_formats[:medium], width: 150, height: 150
      end

      product_name = product_name(block)

      c2 = Caracal::Core::Models::TableCellModel.new do
        p product_name, style: 'header_product'
        p block.spec_item.short_desc&.to_s if config.product_visibility['short_desc']
        p block.spec_item.long_desc&.to_s if config.product_visibility['long_desc']
        p block.spec_item.brand_name if config.product_visibility['brand']
        p "Referencia #{block.spec_item.reference&.to_s}" if config.product_visibility['reference']
        p block.text.text.strip_tags if block.text.present?
        p
      end

      docx.table [[c1, c2]] do
        cell_style cols[0], width: 3000
      end
    else
      product_format(docx, block)
    end
  end

  def product_name(block)
    "#{block.section_order}.#{block.item_order}.#{block.product_order}. #{block.spec_item.name}"
  end

  def product_format(docx, block)
    docx.p product_name(block), style: 'header_product'
    docx.p block.spec_item.short_desc&.to_s if config.product_visibility['short_desc']
    docx.p block.spec_item.long_desc&.to_s if config.product_visibility['long_desc']
    docx.p block.spec_item.brand_name if config.product_visibility['brand']
    docx.p "Referencia #{block.spec_item.reference&.to_s}" if config.product_visibility['reference']
    docx.p block.text.text.strip_tags if block.text.present?
    docx.p
  end

  def item(docx, block)
    docx.p "#{block.section_order}.#{block.item_order}.#{block.spec_item.name}", style: 'header_item'
    docx.p block.text.text.strip_tags if block.text.present?
    docx.p
  end

  def section(docx, block)
    docx.p "#{block.section_order}.#{block.spec_item.name}", style: 'header_section'
    docx.p block.text.text.strip_tags if block.text.present?
    docx.p
  end

  def styles(docx)
    docx.style do
      id 'header_product'
      name 'header product'
      bold true
    end

    docx.style do
      id 'header_project'
      name 'header project'
      bold true
      italic false
      size 34
    end

    docx.style do
      id 'header_section'
      name 'header section'
      bold true
      italic false
      size 30
    end

    docx.style do
      id 'header_item'
      name 'header item'
      bold true
      italic false
      size 24
    end
  end
end
