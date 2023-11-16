require 'google_drive'

class Table
  include Enumerable

  attr_accessor :rows, :cols, :exception, :worksheet, :headers

  def initialize(session, spreadsheet_key, worksheet_title)
    @worksheet = session.spreadsheet_by_key(spreadsheet_key).worksheet_by_title(worksheet_title)
    @headers = @worksheet.rows.first
    @table_matrix = []
    @rows = []
    @cols = []
    @exception = %w[total subtotal]

    @worksheet.rows.each { |row| @table_matrix.push(row) unless row.any? { |i| @exception.include? i.downcase } }
    create_rows
    create_cols
    create_header_functions
  end

  def create_header_functions
    @table_matrix[0].each do |el|
      tmp = el.to_s.split
      tmp[0] = tmp[0].downcase
      define_singleton_method(tmp.join) do
        index = @table_matrix[0].find_index(el)
        return @cols[index]
      end
    end
  end

  def create_rows
    @table_matrix.each { |row| @rows.push(Column.new(row, self, @rows.length)) }
  end

  def create_cols
    @table_matrix.transpose.each { |col| @cols.push(Column.new(col, self, @cols.length)) }
  end

  def cela_tabela
    @table_matrix
  end

  def row(par)
    @table_matrix[par]
  end

  def [](kol)
      index = @headers.find_index(kol)
      @cols[index]

  end

  def refresh(arr, index)
    @rows.each_with_index do |el, id|
      el.change_value_at(index, arr[id])
      @worksheet[id + 1, index + 1] = arr[id]
      @worksheet.save
    end
    @table_matrix = []
    @rows.each { |el| @table_matrix.push(el.inspect) }
  end

  def by_index
    self
  end

  def +(other_table)
    session = GoogleDrive::Session.from_config("config.json")
    spreadsheet_key = "1_uropqd2z4e0_kEFgv7LRFzMkOvrbl4PH3ouahNNHxg"
    worksheet_title = "Sheet1"
    raise 'Headers do not match' unless @headers == other_table.headers
  
    result_table = Table.new(session, spreadsheet_key, worksheet_title)
    result_table.headers = @headers
  
    # Assuming @worksheet is a GoogleDrive::Worksheet
    result_table.worksheet = merge_worksheets(@worksheet, other_table.worksheet)
  
    result_table.create_cols
    result_table
  end
  
  def merge_worksheets(worksheet1, worksheet2)
    merged_data = worksheet1.rows + worksheet2.rows

    new_worksheet = worksheet1.spreadsheet.add_worksheet('MergedSheet')
  
    merged_data.each_with_index do |row, index|
      row.each_with_index do |cell, col_index|
        new_worksheet[index + 1, col_index + 1] = cell
      end
    end
  
    new_worksheet.save
    new_worksheet
  end

  def -(other_table)
    session = GoogleDrive::Session.from_config("config.json")
    spreadsheet_key = "1_uropqd2z4e0_kEFgv7LRFzMkOvrbl4PH3ouahNNHxg"
    worksheet_title = "Sheet1"
    raise 'Headers do not match' unless @headers == other_table.headers
  
    result_table = Table.new(session, spreadsheet_key, worksheet_title)
    result_table.headers = @headers
  
    result_table.worksheet = subtract_worksheets(@worksheet, other_table.worksheet)
  
    result_table.create_cols
    result_table
  end
  
  def subtract_worksheets(worksheet1, worksheet2)
    subtracted_data = worksheet1.rows - worksheet2.rows

    new_worksheet = worksheet1.spreadsheet.add_worksheet('SubtractedSheet')

    subtracted_data.each_with_index do |row, index|
      row.each_with_index do |cell, col_index|
        new_worksheet[index + 1, col_index + 1] = cell
      end
    end
  
    new_worksheet.save
    new_worksheet
  end


  def method_missing(method_name, *args, &block)
    return @rows.find { |row| row[index] == $1 } unless method_name =~ /^rn(\d+)$/
  end

  def find_row_by_identifier(method_name, identifier)
    index = @headers.index(method_name.to_s)
    raise "Identifier column '#{method_name}' not found in headers." unless index

    
  end
end

  class Column
    include Enumerable

    def initialize(column, table, index)
      @index = index
      @table = table
      @arr = column
    end

    def inspect
        @arr
    end
    def change_value_at(index, value)
        @arr = @arr.dup
        @arr[index] = value
    end
    
    def sum
        sum = 0
        @arr.each { |el| sum += el.to_i }
        sum
    end
    def avg
        (self.sum / @arr.length).to_f.round(2)
    end

    def map(&block)
        @arr.each.map { |row| block.call(row[@index]) }
    end
    
    def select(&block)
      @arr.each.select { |row| block.call(row[@index]) }
    end

    def reduce(initial, &block)
      @arr.each.reduce(initial) { |acc, row| block.call(acc, row[@index]) }
    end

    def [](index)
      @table.row(index)[@index]
    end

    def []=(brackets, data)
        change_value_at(brackets, data)
        @table.refresh(@arr, @index)
    end

    def each
        @table_matrix.each { |row| yield row }
      end
  end