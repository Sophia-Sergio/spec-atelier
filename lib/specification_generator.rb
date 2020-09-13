class SpecificationGenerator
  def initialize(specification)
    @specification = specification
    @blocks = @specification.blocks.order(:order)
  end

  def generate
    generate_file
    upload_file
  end

  private

  def upload_file
    file = File.new(file_name_path)
    file_stored = GoogleStorage.new(project, file, 'specification').perform(file_name)
    remove_file
    attach_to_specification(file_stored)
  end

  def remove_file
    File.delete(file_name_path)
  end

  def attach_to_specification(file_stored)
    attached_document = Attached::Specification.find_or_create_by!(url: file_stored.public_url, name: file_name)
    if attached_document.new_record?
      create_resourse_file(@specification, deber seimage, 'specification_document')
    end
    attached_document.url
  end

  def create_resourse_file(owner, attached_file, kind)
    Attached::ResourceFile.create!(owner: owner, attached: attached_file, kind: kind)
  end

  def generate_file
    Caracal::Document.save file_name_path do |docx|
      styles(docx)
      docx.p project.name, style: 'header_project'
      docx.hr
      @blocks.each do |block|
        section(docx, block) if block.spec_item.class.to_s == 'Section'
        item(docx, block) if block.spec_item.class.to_s == 'Item'
        product(docx, block) if block.spec_item.class.to_s == 'Product'
      end
    end
  end

  def file_name_path
    "tmp/#{file_name}"
  end

  def file_name
    'EETT-' + project.name.parameterize.underscore + '.docx'
  end

  def project
    @project ||= @specification.project
  end

  def product(docx, block)
    if block.product_image.present?
      c1 = Caracal::Core::Models::TableCellModel.new do
        img block.spec_item.images.first.all_formats[:medium], width: 150, height: 150
      end

      c2 = Caracal::Core::Models::TableCellModel.new do
        p block.spec_item.name, style: 'header_product'
        p block.spec_item.long_desc
        p ('Sistema constructivo: ' + block.spec_item.subitem.name), style: 'header_product'
        p 'Referencia ' + block.spec_item.reference
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

  def caracal_table_cell

  end

  def product_format(docx, block)
    docx.p block.spec_item.name, style: 'header_product'
    docx.p block.spec_item.long_desc
    docx.p ('Sistema constructivo: ' + block.spec_item.subitem.name), style: 'header_product'
    docx.p 'Referencia ' + block.spec_item.reference
    docx.p block.text.text.strip_tags if block.text.present?
    docx.p
  end

  def item(docx, block)
    docx.p block.spec_item.name, style: 'header_item'
    docx.p block.text.text.strip_tags if block.text.present?
    docx.p
  end

  def section(docx, block)
    docx.p block.spec_item.name
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
      id 'header_item'
      name 'header item'
      bold true
      italic false
      size 24
    end
  end
end
