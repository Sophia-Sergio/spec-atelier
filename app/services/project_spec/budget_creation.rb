module ProjectSpec
  class BudgetCreation
    attr_reader :specification

    def initialize(specification)
      @specification = specification
    end

    def generate
      task = Spreadsheet::Workbook.new
      sheet = task.create_worksheet
      row = 0
      row = write_project_info(sheet, row)
      write_project_products(sheet, row)
      (0..8).each {|i| sheet.column(i).width = 20 }
      temp_file = StringIO.new
      task.write(temp_file)
      temp_file.string
    end

    def project_info
      [
        ["Nombre de proyecto", project.name],
        ["Tipo de proyecto", project.project_type_spa],
        ["Ciudad", project.city],
        ["Descripción", project.description],
        ["Nombre de usuario", user.name || user.email],
        ["Última actualizacióm", specification.updated_at.strftime("%d-%m-%Y")],
        ["Deadline", project.delivery_date&.strftime("%d-%m-%Y")],
        ["m2", project.size],
      ]
    end

    def write_project_info(sheet, row)
      project_info.each.with_index(1) do |info, i|
        sheet.row(i).concat info
        sheet.row(i).default_format = normal_row_format
        row = i
      end
      sheet.row(row + 1).concat []
      row + 2
    end

    def write_project_products(sheet, row)
      sheet.row(row).concat product_title
      sheet.row(row).default_format = title_row_format
      specification.blocks.products.each.with_index(row + 1) do |product, i|
        sheet.row(i).concat product_info(product)
        sheet.row(i).default_format = normal_row_format
      end
    end

    def user
      @user ||= project.user
    end

    def project
      @project ||= specification.project
    end

    def normal_row_format
      Spreadsheet::Format.new weight: :normal, size: 12, align: :left
    end

    def title_row_format
      Spreadsheet::Format.new weight: :bold, size: 12, align: :center
    end

    def product_info(block)
      [
        block.item.name,
        '',
        '',
        block.product_order,
        block.spec_item.name,
        block.spec_item.brand&.name,
        block.spec_item.price,
        '',
        '',
      ]
    end

    def product_title
      [
        'Nombre Partida',
        'Sistema',
        'Código Sistema',
        'Posición relativa',
        'Producto - Nombre',
        'Producto - Marca',
        'Producto - Precio',
        'Cantidad',
        'Total',
      ]
    end
  end
end
